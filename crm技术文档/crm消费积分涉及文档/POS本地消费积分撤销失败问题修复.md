# POS 本地消费积分撤销失败问题修复

日期：2026-05-12
状态：已修复

## 1. 问题描述

### 现象

用户反馈：结账后触发退款时，CRM 撤销积分接口返回错误"消费任务未成功，不能补记积分"，导致会员积分未被撤销。

### 日志

```
java.lang.IllegalArgumentException: 消费任务未成功，不能补记积分
    at com.nms4cloud.crm.service.points.CrmConsumePointsServicePlus.revokeConsumePoints()
    at com.nms4cloud.crm.service.points.CrmConsumePointsServicePlus$$SpringCGLIB$$0.revokeConsumePoints()
    ...
Caused by: java.lang.IllegalArgumentException: POS账单LID不能为空
    at com.nms4cloud.crm.service.points.CrmConsumePointsServicePlus.validateConsumptionFact()
```

### 数据库状态（问题发生时）

| 表/字段 | 值 | 说明 |
|---|---|---|
| `crm_consume_points_round.status_` | `6`（撤销失败） | 撤销轮次状态异常 |
| `crm_consume_points_round.revoke_points_record_lid` | `NULL` | 撤销记录未创建 |
| `crm_card_points_record` | 有 +80 分记录（PID=59），无 -80 撤销记录 | 积分明细不完整 |
| POS 定时补偿重试 | 3次均失败 | 定时任务未能自动修复 |

### 影响

- 该笔消费的 +80 分积分未被撤销
- 会员 CRM 积分余额虚高 80 分
- 退款后应从 660 回退到 580，实际仍为 660

### 额外说明：支付退款链路本身也会触发退积分

本次排查里又确认了一条独立但相关的链路：`DwdBillOpsServiceImpl.refundPay(...)` 在支付退款时，必须先定位原始支付明细，再调用 `crmPointsEarnLocalService.recalculateConsumePointsAfterRefund(...)` 做消费赠分重算。

如果这条链路没有正确回到原始支付来源，或者退款明细没有带回正确的原支付类型、`payTradeOrderNo`、`payTradeMcntNo`，就会出现“退款成功但积分没有被退回”的现象。这个问题不是 CRM 撤销接口本身，而是 POS 退款侧没有把退积分所需的原支付来源、退款账单和退款明细正确串起来。

本次代码修复已经把这条链路补齐为：

- 先按原支付申请锁定退款记录
- 再从原订单支付明细中唯一定位原支付方式
- 生成退款账单和退款支付明细
- 最后调用 `recalculateConsumePointsAfterRefund(...)` 重新计算并撤回消费赠分

---

## 2. 根因分析

### 调用链路

```
POS 结账 → 触发 grantConsumePoints（+80分）→ 正常
POS 退款 → 触发 revokeConsumePoints（-80分）→ 失败
```

### CRM revokeConsumePoints 校验流程

```
revokeConsumePoints(request)
  → loadCard(mid, cardNo, cardLid)        [第153行] ✅ 正常
  → validateDealTask(request, card)        [第154行] ✅ dealTask = null（POS本地消费无CrmDealTask）
  → normalizeAndValidateRequest(...)      [第155行] ❌ 在此处抛出异常
      → normalizeLifecycleId(request)     ✅ lifecycleId = grant.lid，有值
      → validateConsumptionFact(...)       ❌ 抛出 "POS账单LID不能为空"
          → 当 dealTask=null 且 source=POS 时，要求 request.billLid 和 request.sid 非空
```

### 问题本质

`validateConsumptionFact` 方法对"POS 本地消费且无 CrmDealTask"的场景做了强校验，要求同时传入 `billLid` 和 `sid`：

```java
// CrmConsumePointsServicePlus.java 第292-300行
private void validateConsumptionFact(
    CrmCardOpRevokeConsumePointsDTO request, CrmDealTask dealTask) {
  if (Objects.nonNull(dealTask)
      || !ObjectUtil.equal(request.getSource(), CrmConsumePointsSourceEnum.POS)) {
    return;
  }
  Assert.notNull(request.getBillLid(), "POS账单LID不能为空"); // ← 校验失败
  Assert.notNull(request.getSid(), "POS门店ID不能为空");      // ← 同样缺失
}
```

但 **revoke 路径的实际需求与 grant 路径不同**：

| 场景 | 定位方式 | 是否需要 billLid/sid |
|---|---|---|
| grant（正向赠分） | 需要 billLid + sid 做关联校验 | 需要 |
| revoke（撤销积分） | 仅靠 `lifecycleId`（round.lid）即可唯一定位原 GRANT 任务 | 不需要 |

撤销时校验 billLid/sid 是多余的——lifecycleId 已经是 round 表的主键，用它定位原任务是最直接、最可靠的路径。额外校验 billLid/sid 反而增加了不必要的前置条件。

### 对比其他场景的影响

| 场景 | 涉及的方法 | 是否有同样问题 |
|---|---|---|
| POS 正向消费赠分（grant） | grantConsumePoints → `validateConsumptionFact(Grant)` | 无。grant 路径传入 billLid 和 sid，校验通过 |
| 储值消费（含 CrmDealTask） | grant/revoke → dealTask 非 null | 无。`validateConsumptionFact` 在 dealTask 非 null 时直接 return，不做校验 |
| **POS 本地消费撤销（revoke）** | revokeConsumePoints → `validateConsumptionFact(Revoke)` | **有。revoke 未传 sid，校验失败** |

---

## 3. 修改方案

### 修改文件

**CRM 侧** — `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/points/CrmConsumePointsServicePlus.java`

### 撤销路径 normalizeAndValidateRequest

**修改前（第274-280行）：**

```java
private void normalizeAndValidateRequest(
    CrmCardOpRevokeConsumePointsDTO request, CrmCard card, CrmDealTask dealTask) {
  normalizeLifecycleId(request);
  validateConsumptionFact(request, dealTask);  // ← POS无CrmDealTask时强制要求billLid+sid
  Long trustedSid = trustedSid(request.getSid(), card, dealTask);
  request.setSid(trustedSid);
}
```

**修改后：**

```java
private void normalizeAndValidateRequest(
    CrmCardOpRevokeConsumePointsDTO request, CrmCard card, CrmDealTask dealTask) {
  normalizeLifecycleId(request);
  // 撤销路径以 lifecycleId 唯一定位原赠分任务，不依赖 billLid/sid 做关联校验
  Long trustedSid = trustedSid(request.getSid(), card, dealTask);
  request.setSid(trustedSid);
}
```

### 修改说明

- 移除了 `validateConsumptionFact(request, dealTask)` 调用
- 撤销时使用 `lifecycleId`（即 `crm_consume_points_round.lid`）在 `CrmConsumePointsTask` 表中唯一定位原 GRANT 任务，`billLid` 和 `sid` 仅为辅助信息（非必需）
- grant 路径不受影响：其 `normalizeAndValidateRequest(CrmCardOpGrantConsumePointsDTO, ...)` 保留 `validateConsumptionFact` 调用

---

## 4. 验证方案

### 触发条件

在 POS 侧重新执行该笔账单的退款操作（账单号：2026051210001）

### 预期结果

| 检查点 | 预期值 |
|---|---|
| CRM `crm_card_points_record` | 新增一条 -80 分撤销记录，`related_points_record_lid` 指向 PID=59 |
| POS `crm_consume_points_round.status_` | 变为 `4`（REVOKED） |
| POS `crm_consume_points_round.revoke_points_record_lid` | 指向新创建的撤销记录 LID |
| 会员 CRM 积分余额 | 从 660 回退到 580 |

---

## 5. 相关代码文件

| 文件 | 说明 |
|---|---|
| `CrmConsumePointsServicePlus.java` | CRM 消费积分核心服务，含 grantConsumePoints / revokeConsumePoints |
| `CrmPointsEarnLocalService.java` | POS 本地消费积分服务，调用 CRM 接口 |
| `crm_consume_points_round` | POS 消费积分轮次表，记录本地积分生命周期 |
| `crm_consume_points_task` | CRM 消费积分任务表 |
| `crm_card_points_record` | CRM 积分明细表 |

---

## 6. 附：防御性增强（可选）

当前 revoke 请求中 POS 未传 `mid`，虽然靠 `cardLid` 仍能正确定位卡，但建议在 POS 侧补上，使接口更健壮：

```java
// POS CrmPointsEarnLocalService.revokeConsumePoints() 中，建议增加：
request.setMid(grant.getMid());
request.setLifecycleId(grant.getLid());
```
