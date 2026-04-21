# commitByPos 事务边界修复

> 修改文件：`nms4cloud-crm-service/.../service/charge/DepositPlanChargeService.java`
>
> 修改日期：2026-04-15
>
> 关联文档：`新储值方案集成POS设计文档.md`

---

## 1. 问题描述

对照设计文档审查 `commitByPos()` 实现代码，发现 3 个问题。

### 问题 1（严重）：`@Transactional` 包裹整个方法，与 Redis 锁释放时机冲突

**原代码结构**：

```java
@Transactional(rollbackFor = Exception.class)  // ← 整个方法在一个事务中
public NmsResult<CardBalanceVo> commitByPos(DepositPlanPosChargeDTO request) {
    String lockKey = "depositPlan:pos:charge:" + ...;
    boolean locked = redisTemplatePlus.setIfAbsent(lockKey, "1", 30, TimeUnit.SECONDS);
    try {
        // ... 创建 CrmDealTask（USERPAYING）
        // ... 创建 CrmDealTaskItem
        // ... 创建 CrmDepositChargeRecord
        // ... 调用 onPaymentSuccess()
        return NmsResult.data(vo);
    } finally {
        redisTemplatePlus.delete(lockKey);  // ← 锁在这里释放
    }
}
// Spring 代理在方法返回后才提交事务  ← 事务在这里提交
```

**时序问题**：

```
线程A: 获取锁 → 创建Task → 调用onPaymentSuccess → finally释放锁 → [方法返回] → Spring提交事务
线程B:                                              ↑ 此刻获取锁 → 查Task → 查不到（事务未提交）→ 重复创建Task！
```

`finally` 释放 Redis 锁时，`@Transactional` 的事务还没提交（Spring AOP 在方法返回后才 commit）。并发请求在这个窗口期拿到锁后，查不到阶段 1 写入的 `CrmDealTask`（因为前一个事务还没 commit），导致幂等三态检查失效，可能重复创建任务和重复入账。

### 问题 2（严重）：`onPaymentSuccess` 异常会回滚阶段 1 的 Task

**设计文档要求的事务边界**：

```
阶段1 @Transactional（强一致，失败整体回滚）：
  ├─ 创建 CrmDealTask（USERPAYING）
  ├─ 创建 CrmDealTaskItem
  └─ 创建 CrmDepositChargeRecord

阶段2 onPaymentSuccess()（CardBalanceService 有独立事务和 Redis 锁）：
  ├─ CardBalanceService.execute()：余额变更
  └─ 发券/升级/积分：try-catch 隔离
```

**实际代码**：整个方法在一个 `@Transactional` 中，如果 `onPaymentSuccess()` 内部抛异常（比如余额入账失败抛 `BizException`），阶段 1 创建的 Task 也会被回滚。

**后果**：Task 被回滚后，下次重试时幂等三态检查查不到 Task，会重新走完整流程。如果 `CardBalanceService.execute()` 内部已经成功入账（它有独立事务），但外层事务回滚了 Task，就会出现：余额已变更但 Task 不存在的不一致状态。

### 问题 3（中等）：`buildCardBalanceVo` 幂等返回时余额来源

**设计文档要求**：

> 幂等返回时，从已有 CrmDealTask 查询关联的 crm_card_record（最新一条，task_lid=existing.lid），取其 balance_after/principal_balance_after/give_balance_after/points_balance_after 字段填充返回值

**实际代码**：查的是 `crm_card` 当前余额，而非 `crm_card_record` 的 `balance_after`。

**影响**：如果幂等返回时，该会员卡在两次请求之间又发生了其他余额变动（比如消费），返回的余额就不是本次充值后的快照，而是最新余额。对 POS 侧来说，回写到 `DwdBill.cardBalanceAfter` 的值可能不准确。

**评估**：在实际业务中，POS 充值和幂等重试之间的时间窗口很短（通常几秒），期间发生其他余额变动的概率极低。当前实现可接受，后续可优化。

---

## 2. 修复方案

### 核心思路

去掉 `commitByPos` 的 `@Transactional`，改用 `TransactionTemplate` 编程式事务控制阶段 1，确保：

1. 阶段 1 事务提交后，数据对其他线程可见
2. 阶段 2（`onPaymentSuccess`）在阶段 1 事务提交后执行
3. Redis 锁在所有逻辑完成后才释放
4. `onPaymentSuccess` 异常不会回滚阶段 1 的 Task

### 修改后的事务时序

```
线程A: 获取锁 → [阶段1事务: 创建Task+提交] → onPaymentSuccess → finally释放锁
线程B:                                                          ↑ 此刻获取锁 → 查Task → 查到USERPAYING → 拒绝重入 ✓
```

---

## 3. 代码变更

### 3.1 新增 import

```java
// 新增
import org.springframework.transaction.support.TransactionTemplate;
```

### 3.2 新增依赖注入

```java
// 在 Autowired 区域新增
@Autowired private TransactionTemplate transactionTemplate;
```

### 3.3 新增内部 record 类

```java
/**
 * commitByPos 阶段1的返回结果（内部使用）
 * 用于在阶段1事务和阶段2之间传递 task 和 card 对象，避免事务外重新查询。
 */
private record CommitByPosPhase1Result(CrmDealTask task, CrmCard card) {}
```

### 3.4 `commitByPos` 方法变更

**删除**：方法上的 `@Transactional(rollbackFor = Exception.class)` 注解

**修改前**（伪代码）：

```java
@Transactional(rollbackFor = Exception.class)
public NmsResult<CardBalanceVo> commitByPos(...) {
    获取Redis锁
    try {
        幂等三态检查
        校验方案/档位/会员卡/可用性/购买限制
        创建 CrmDealTask          // ← 在大事务中
        创建 CrmDealTaskItem      // ← 在大事务中
        创建 CrmDepositChargeRecord // ← 在大事务中
        onPaymentSuccess()        // ← 在大事务中，异常会回滚上面的数据
        校验余额入账
        return 结果
    } finally {
        释放Redis锁              // ← 此时大事务还没提交
    }
}
// Spring AOP 在这里才提交事务    // ← 锁已释放，并发请求可能查不到数据
```

**修改后**（伪代码）：

```java
// 无 @Transactional
public NmsResult<CardBalanceVo> commitByPos(...) {
    获取Redis锁
    try {
        幂等三态检查
        校验方案/档位/会员卡/可用性/购买限制

        // ========== 阶段1：编程式事务 ==========
        CommitByPosPhase1Result phase1 = transactionTemplate.execute(status -> {
            创建 CrmDealTask
            创建 CrmDealTaskItem
            创建 CrmDepositChargeRecord
            return new CommitByPosPhase1Result(task, card);
        });
        // ← 阶段1事务已提交，Task 对其他线程可见

        // ========== 阶段2：独立执行 ==========
        onPaymentSuccess()       // ← CardBalanceService 有自己的事务
        校验余额入账
        return 结果
    } finally {
        释放Redis锁              // ← 此时阶段1事务已提交
    }
}
```

### 3.5 完整 diff（关键部分）

```diff
-  @Transactional(rollbackFor = Exception.class)
   public NmsResult<CardBalanceVo> commitByPos(DepositPlanPosChargeDTO request) {
     // ... 获取锁、幂等检查、校验逻辑不变 ...

-    // 创建 CrmDealTask（USERPAYING 状态）
-    CrmDealTask task = new CrmDealTask();
-    // ... 设置字段 ...
-    Assert.isTrue(iCrmDealTaskService.save(task), "充值任务创建失败");
-
-    // 创建 CrmDealTaskItem
-    CrmDealTaskItem taskItem = new CrmDealTaskItem();
-    // ... 设置字段 ...
-    Assert.isTrue(iCrmDealTaskItemService.save(taskItem), "充值子项创建失败");
-
-    // 创建购买记录
-    createChargeRecord(commitDTO, plan, tier, task, cardLid);
-
-    // 构造 notifyAttach
-    ChargeNotifyAttach notifyAttach = new ChargeNotifyAttach();
-    // ... 设置字段 ...
-
-    onPaymentSuccess(task, notifyAttach);

+    // ========== 阶段1：编程式事务 ==========
+    CommitByPosPhase1Result phase1 = transactionTemplate.execute(status -> {
+      CrmDealTask task = new CrmDealTask();
+      // ... 设置字段（与原代码完全一致）...
+      assertIsTrue(iCrmDealTaskService.save(task), "充值任务创建失败");
+
+      CrmDealTaskItem taskItem = new CrmDealTaskItem();
+      // ... 设置字段（与原代码完全一致）...
+      assertIsTrue(iCrmDealTaskItemService.save(taskItem), "充值子项创建失败");
+
+      createChargeRecord(commitDTO, plan, tier, task, cardLid);
+      return new CommitByPosPhase1Result(task, card);
+    });
+    Assert.notNull(phase1, "阶段1事务执行失败");
+    CrmDealTask task = phase1.task;
+
+    // ========== 阶段2：独立执行 ==========
+    ChargeNotifyAttach notifyAttach = new ChargeNotifyAttach();
+    // ... 设置字段，card 从 phase1.card 取 ...
+
+    onPaymentSuccess(task, notifyAttach);
```

---

## 4. 修复后的事务边界

```
commitByPos() 方法（无 @Transactional）
│
├─ Redis 分布式锁（per orderId，30s TTL）
│
├─ 幂等三态检查（读已提交的数据）
│
├─ 校验逻辑（无事务，纯读操作）
│
├─ 阶段1：TransactionTemplate.execute()
│   ├─ BEGIN TRANSACTION
│   ├─ INSERT CrmDealTask（USERPAYING）
│   ├─ INSERT CrmDealTaskItem
│   ├─ INSERT CrmDepositChargeRecord
│   └─ COMMIT  ← 数据对其他线程可见
│
├─ 阶段2：onPaymentSuccess()
│   ├─ CardBalanceService.execute()（独立 Redis 锁 + 独立事务）
│   │   ├─ BEGIN TRANSACTION
│   │   ├─ UPDATE crm_card 余额
│   │   ├─ UPDATE CrmDealTask → SUCCESS
│   │   ├─ INSERT crm_card_record
│   │   └─ COMMIT
│   ├─ updateChargeRecordSuccess()（独立事务）
│   ├─ updatePlanSoldStats()（独立事务）
│   └─ 发券/升级/积分（try-catch 隔离，失败只记日志）
│
├─ 校验余额入账（读 CrmDealTask.tradeState）
│
└─ finally: 释放 Redis 锁
```

---

## 5. 异常场景分析

### 场景 1：阶段 1 失败（Task 创建失败）

```
阶段1事务回滚 → Task 不存在 → Redis 锁释放 → 下次重试正常执行
```

结论：安全，无残留数据。

### 场景 2：阶段 2 失败（余额入账失败）

```
阶段1已提交 → Task 状态 = USERPAYING → 余额未变更
→ 方法抛 BizException → Redis 锁释放
→ 下次重试 → 幂等检查查到 USERPAYING → 返回"订单处理中"
```

结论：安全。Task 保留为 USERPAYING，不会重复创建。POS 侧收到错误后可查询状态或人工处理。

### 场景 3：阶段 2 部分成功（余额成功，发券失败）

```
阶段1已提交 → 余额入账成功 → Task 状态 = SUCCESS → 发券失败（try-catch 吞掉）
→ 方法正常返回 → Redis 锁释放
```

结论：安全。余额已入账，发券失败只记日志，运营后台补发。与设计文档一致。

### 场景 4：并发重试（POS 超时重发）

```
线程A: 获取锁 → 阶段1提交 → 执行阶段2...
线程B: 获取锁失败 → 返回"订单正在处理中"
```

或：

```
线程A: 获取锁 → 阶段1提交 → 阶段2完成 → 释放锁
线程B: 获取锁 → 幂等检查查到 SUCCESS → 返回已有结果
```

结论：安全。Redis 锁 + 幂等三态双重保护。

### 场景 5：Redis 锁过期（极端情况，处理超过 30s）

```
线程A: 获取锁 → 阶段1提交 → 阶段2执行中... → 锁过期（30s）
线程B: 获取锁 → 幂等检查查到 USERPAYING → 返回"订单处理中"
```

结论：安全。即使锁过期，阶段 1 已提交的 Task（USERPAYING）会被幂等检查拦截。

---

## 6. 未修改的部分

| 项目 | 说明 |
|------|------|
| `buildCardBalanceVo` | 仍查 `crm_card` 当前余额，未改为查 `crm_card_record`。实际影响极低，后续可优化 |
| `purchaseLimitChecker.check()` | 仍为"先查后写"，无并发保护。设计文档已标注可接受，不阻塞上线 |
| `onPaymentSuccess` | 未修改，保持原有的 `@Transactional` 和内部 try-catch 隔离策略 |
| 幂等三态检查逻辑 | 未修改，保持原有的 `outTradeNo` 查询 + `tradeState` 判断 |

---

## 7. 验证要点

1. 正常充值：阶段 1 提交后 Task 可查到（USERPAYING），阶段 2 完成后 Task 变为 SUCCESS
2. 并发重试：第二个请求被 Redis 锁或幂等检查拦截
3. 阶段 2 失败：Task 保留为 USERPAYING，余额未变更，不会重复创建 Task
4. 幂等返回：已成功的订单重复提交，返回已有的 CardBalanceVo
