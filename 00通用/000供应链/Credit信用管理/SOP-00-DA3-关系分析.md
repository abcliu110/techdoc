# 关系分析 — K3Cloud Credit信用管理

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Credit信用管理 |
| 分析时间 | 2026-08-07 |

---

## 一、核心关系（REL-Cred系列）

### 1.1 主体关系

| 关系ID | 关系名称 | 源概念 | 目标概念 | 关系类型 | 说明 |
|---|---|---|---|---|---|
| REL-Cred-01 | 客户-额度 | Customer | CreditLimit | 1:N | 客户拥有信用额度 |
| REL-Cred-02 | 额度-占用 | CreditLimit | CreditUsage | 1:N | 额度被多次占用 |
| REL-Cred-03 | 额度-冻结 | CreditLimit | CreditFreeze | 1:N | 额度可被多次冻结 |
| REL-Cred-04 | 客户-评级 | Customer | CreditRating | 1:1 | 客户当前有唯一评级 |
| REL-Cred-05 | 客户-预警 | Customer | CreditWarning | 1:N | 客户可触发多个预警 |
| REL-Cred-06 | 额度-调整 | CreditLimit | CreditLimitAdjust | 1:N | 额度有多次调整 |

### 1.2 跨模块关系

| 关系ID | 关系名称 | 源概念 | 目标概念 | 关系类型 | 说明 |
|---|---|---|---|---|---|
| REL-Cred-07 | Sal-Credit检查 | SalOrder | CreditCheck | 触发 | 销售订单触发信用检查 |
| REL-Cred-08 | Credit-AR占用 | ARBill | CreditUsage | 占用源 | AR记账触发额度占用 |
| REL-Cred-09 | Credit-AR释放 | ARPayment | CreditUsage | 释放源 | 收款触发额度释放 |
| REL-Cred-10 | Sal-Credit占用 | SalDelivery | CreditUsage | 占用源 | 出库触发额度占用 |
| REL-Cred-11 | Rating影响Limit | CreditRating | CreditLimit | 影响 | 评级影响额度计算 |

---

## 二、关系详情

### 2.1 REL-Cred-01 客户-额度关系

```
关系：客户拥有信用额度
类型：1:N（一个客户可有多个额度，如不同币种）

约束：
- 同一币种只能有一个生效额度
- 额度状态为NORMAL时可用
- 临时额度有失效日期

语义：
客户申请信用额度 → 信用管理员审批 → 额度生效
```

### 2.2 REL-Cred-02 额度-占用关系

```
关系：信用额度被交易占用
类型：1:N（一个额度可被多次占用）

约束：
- 同一订单只能有一条占用记录
- 占用金额不能超过可用额度
- 可部分释放

语义：
销售出库/AR记账 → 创建占用记录 → 更新可用额度
```

### 2.3 REL-Cred-07 Sal-Credit检查关系

```
关系：销售订单触发信用检查
类型：触发（Sal → Credit）

触发时机：
- 销售订单创建时
- 销售订单修改金额时

检查内容：
1. 查询客户当前额度
2. 计算可用额度 = 总额度 - 已占用 - 已冻结
3. 计算本次交易需占用额
4. 判断：可用额度 >= 本次交易额？

返回结果：
- 允许：订单可创建
- 拒绝：提示额度不足
```

### 2.4 REL-Cred-08 Credit-AR占用关系

```
关系：AR记账触发额度占用
类型：占用源（AR → Credit）

触发时机：
- 销售出库生成应收单时
- 应收单金额增加时

占用金额：
- 占用金额 = 应收单含税金额

语义：
销售出库 → 生成AR应收单 → 占用信用额度
```

### 2.5 REL-Cred-09 Credit-AR释放关系

```
关系：收款触发额度释放
类型：释放源（AR → Credit）

触发时机：
- 收款单审核时
- 应收单核销时

释放金额：
- 释放金额 = 本次核销金额

语义：
客户付款 → 收款确认 → 核销应收单 → 释放信用额度
```

---

## 三、业务路径

### 3.1 路径1：销售下单信用检查路径

```
路径：销售订单创建 → 信用检查 → 允许/拒绝
触发：销售员创建订单
节点：
  1. SalOrder.Create（销售员创建订单）
      ↓ 触发
  2. CreditCheck.Execute（系统执行检查）
      ├→ 查询CreditLimit（客户额度）
      ├→ 计算可用额度
      ├→ 判断额度充足
      ↓
  3. SalOrder.Create.Result（结果返回）
      ├→ 允许：订单创建成功
      └→ 拒绝：提示额度不足
```

**契约**：
```
输入：客户ID、订单金额
输出：是否允许、可用额度、拒绝原因（如有）
约束：原子性检查，不影响额度
```

### 3.2 路径2：出库触发额度占用路径

```
路径：销售出库 → AR记账 → 额度占用
触发：仓库员审核出库单
节点：
  1. SalDelivery.Audit（仓库员审核出库）
      ↓
  2. ARBill.Create（生成应收单）
      ↓ 触发
  3. CreditOccupy.Execute（系统执行占用）
      ├→ 创建CreditUsage记录
      ├→ 更新CreditLimit.可用额度
      ↓
  4. CreditOccupy.Result（结果返回）
      └→ 占用成功/失败
```

**契约**：
```
输入：客户ID、占用金额、关联单据
输出：占用成功/失败
约束：原子性更新，失败则回滚AR单据
```

### 3.3 路径3：收款触发额度释放路径

```
路径：收款确认 → 核销应收 → 额度释放
触发：财务专员确认收款
节点：
  1. ARPayment.Audit（财务专员审核收款）
      ↓
  2. ARBill.WriteOff（应收核销）
      ↓ 触发
  3. CreditRelease.Execute（系统执行释放）
      ├→ 查找对应CreditUsage记录
      ├→ 更新已释放金额
      ├→ 更新CreditLimit.可用额度
      ↓
  4. CreditRelease.Result（结果返回）
      └→ 释放成功/失败
```

**契约**：
```
输入：客户ID、释放金额、应收单ID
输出：释放成功/失败
约束：释放金额 ≤ 已占用金额
```

### 3.4 路径4：额度冻结/解冻路径

```
路径：风控决策 → 额度冻结 → 交易限制
触发：风控专员执行冻结
节点：
  1. CreditFreeze.Create（风控专员创建冻结）
      ├→ 输入冻结金额
      ├→ 选择冻结原因
      ↓
  2. CreditFreeze.Execute（系统执行冻结）
      ├→ 创建CreditFreeze记录
      ├→ 更新CreditLimit.可用额度
      ↓
  3. CreditCheck更新（冻结后检查结果变化）
      └→ 可用额度减少
```

---

## 四、关键业务契约

### 4.1 契约1：信用检查契约

```
契约名称：CreditCheckContract
参与者：Sal模块、Credit模块
前置条件：客户存在有效额度
后置条件：检查结果不影响额度

检查规则：
  1. 获取客户总额度
  2. 计算已占用金额（SUM of CreditUsage WHERE 状态=占用中）
  3. 计算已冻结金额（SUM of CreditFreeze WHERE 状态=冻结中）
  4. 计算可用额度 = 总额度 - 已占用 - 已冻结
  5. 判断：可用额度 >= 交易金额？

返回：
  {
    allowed: boolean,
    availableCredit: decimal,
    requiredCredit: decimal,
    reason: string (if not allowed)
  }
```

### 4.2 契约2：额度占用契约

```
契约名称：CreditOccupyContract
参与者：AR/Sal模块、Credit模块
前置条件：客户存在有效额度且可用额度充足
后置条件：可用额度减少，占用记录创建

占用规则：
  1. 检查可用额度 >= 占用金额（原子操作）
  2. 创建CreditUsage记录（状态=占用中）
  3. 更新CreditLimit.可用额度 -= 占用金额
  4. 返回占用结果

回滚规则：
  - 如更新失败，整个事务回滚
  - 不创建部分占用记录
```

### 4.3 契约3：额度释放契约

```
契约名称：CreditReleaseContract
参与者：AR模块、Credit模块
前置条件：存在可释放的占用记录
后置条件：可用额度增加，占用记录更新

释放规则：
  1. 查找对应CreditUsage记录
  2. 检查已释放金额 + 本次释放金额 <= 占用金额
  3. 更新已释放金额
  4. 如已释放金额 = 占用金额，更新状态=已释放
  5. 更新CreditLimit.可用额度 += 本次释放金额
  6. 返回释放结果

约束：
  - 释放金额不能超过剩余未释放金额
  - 不能释放已冻结部分的额度
```

---

## 五、数据流分析

### 5.1 主要数据流

```
销售员 ──▶ SalOrder.Create ──▶ CreditCheck ──▶ 返回结果
                                    │
                                    ▼
                               SalOrder创建成功/失败

SalDelivery.Audit ──▶ ARBill.Create ──▶ CreditOccupy ──▶ 额度更新
                                         │
                                         ▼
                                    AR单据审核成功

ARPayment.Audit ──▶ ARWriteOff ──▶ CreditRelease ──▶ 额度更新
                                   │
                                   ▼
                              收款确认成功
```

### 5.2 数据一致性保证

| 场景 | 一致性保证 |
|---|---|
| 占用时额度不足 | 原子检查+更新，失败回滚 |
| 释放金额超限 | 业务规则校验，释放金额<=未释放金额 |
| 冻结后占用 | 冻结操作在占用前完成可见 |
| 并发占用 | 数据库锁或乐观锁保证 |

---

## 六、DA3分析结论

**关系清单**：11个
- 主体关系：6个
- 跨模块关系：5个

**核心路径**：4条
- 销售下单信用检查路径
- 出库触发额度占用路径
- 收款触发额度释放路径
- 额度冻结/解冻路径

**关键契约**：3个
- CreditCheckContract（检查）
- CreditOccupyContract（占用）
- CreditReleaseContract（释放）

**进入DA4的输入**：
- 需建立业务规则（信用检查规则、占用释放规则）
- 需分析状态机（额度状态、占用状态）
- 需识别决策点（检查策略、占用策略）
