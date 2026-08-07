# 实现映射 — K3Cloud Credit信用管理

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Credit信用管理 |
| 分析时间 | 2026-08-07 |

---

## 一、报表实现映射

### 1.1 信用报表清单

| 报表 | 类名 | 数据来源 | 关键方法 |
|---|---|---|---|
| 客户信用台账 | CustomerCreditLedgerRpt | T_CR_CREDITLIMIT | Query |
| 额度使用明细 | CreditUsageDetailRpt | T_CR_CREDITLIMITUSAGE | Query |
| 额度占用汇总 | CreditOccupancySummaryRpt | T_CR_CREDITLIMITUSAGE | Sum/Group |
| 信用预警汇总 | CreditWarningSummaryRpt | T_CR_CREDITWARNING | Query |
| 客户评级报表 | CustomerRatingRpt | T_CR_CREDITRATING | Query |
| 额度调整历史 | CreditAdjustHistoryRpt | T_CR_CREDITLIMITADJUST | Query |

### 1.2 报表插件模式

```
AbstractSysReportPlugIn
    │
    ├── 取数插件（Query）
    │   └── 自定义SQL/ORM查询
    │
    ├── 过滤插件（Filter）
    │   └── 权限过滤、数据过滤
    │
    └── 格式化插件（Format）
        └── 列格式化、金额显示
```

---

## 二、服务类实现映射

### 2.1 CreditService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| GetAvailableLimit | CreditService | 计算可用额度 |
| CheckCredit | CreditService | 信用检查入口 |
| OccupyLimit | CreditService | 额度占用入口 |
| ReleaseLimit | CreditService | 额度释放入口 |

### 2.2 CreditLimitService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | CreditLimitEdit | 保存校验 |
| OnAudit | CreditLimitEdit | 审批确认 |
| OnAdjust | CreditLimitEdit | 调整额度 |
| OnFreeze | CreditLimitEdit | 冻结额度 |
| OnUnfreeze | CreditLimitEdit | 解冻额度 |

### 2.3 CreditCheckService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| Check | CreditCheckPlugIn | 实时信用检查 |
| CheckAsync | CreditCheckPlugIn | 异步信用检查 |
| GetStatus | CreditStatusPlugIn | 获取信用状态 |

### 2.4 CreditOccupancyService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| Occupy | CreditOccupyPlugIn | 执行占用（原子操作） |
| Release | CreditReleasePlugIn | 执行释放（原子操作） |
| GetUsage | CreditUsagePlugIn | 获取占用明细 |

---

## 三、决策卡实现

### 3.1 DEC-Cred-01：检查策略

```
决策点：是否启用实时信用检查
输入：销售订单、客户ID
规则：
  IF 启用实时检查 THEN
    在订单创建时同步执行信用检查
    IF 检查通过 THEN
      允许创建订单
    ELSE
      拒绝创建或提交审批
    END IF
  ELSE
    执行异步检查
    允许先创建订单，后台检查
  END IF
输出：订单创建方式
```

### 3.2 DEC-Cred-02：占用时机

```
决策点：额度占用的触发时机
输入：出库单、应收单
规则：
  IF 出库审核时占用 THEN
    占用金额 = 出库单含税金额
    时机 = 出库审核后
  ELSE IF AR记账时占用 THEN
    占用金额 = 应收单含税金额
    时机 = AR记账后
  END IF
输出：占用时机和金额
```

### 3.3 DEC-Cred-03：释放时机

```
决策点：额度释放的触发时机
输入：收款单、核销单
规则：
  IF 收款审核时释放 THEN
    释放金额 = 收款金额
    时机 = 收款审核后
  ELSE IF 核销时释放 THEN
    释放金额 = 核销金额
    时机 = 核销后
  END IF
输出：释放时机和金额
```

### 3.4 DEC-Cred-04：额度不足处理

```
决策点：信用检查不通过时的处理方式
输入：检查结果
规则：
  差异 = 交易金额 - 可用额度
  IF 启用超额审批 THEN
    生成超额审批流程
    审批通过后允许创建订单
  ELSE
    直接拒绝订单创建
  END IF
输出：处理方式
```

### 3.5 DEC-Cred-05：冻结策略

```
决策点：额度冻结的方式
输入：客户ID、冻结原因
规则：
  IF 手动冻结 THEN
    风控专员手动执行冻结
  ELSE IF 自动冻结 THEN
    系统根据预警规则自动冻结
    逾期超过N天
    或评级下调超过2级
  END IF
输出：冻结方式
```

---

## 四、巨型类分析

### 4.1 巨型类清单

| 类名 | 行数 | 风险 | 建议拆分 |
|---|---|---|---|
| CreditService | ~2,800 | 中等 | 按功能模块拆分 |
| CreditCheckPlugIn | ~1,200 | 低 | 已是独立模块 |

### 4.2 CreditService拆分建议

```
原：CreditService (~2,800行)

拆分为：
  ├── CreditLimitService   (额度管理，~800行)
  ├── CreditCheckService   (信用检查，~600行)
  ├── CreditOccupancyService (占用释放，~600行)
  ├── CreditRatingService  (评级管理，~400行)
  └── CreditWarningService (预警服务，~400行)
```

---

## 五、DA7分析结论

**报表清单**：6个
- 信用台账报表：1个
- 额度使用报表：2个
- 预警报表：1个
- 评级报表：1个
- 调整历史报表：1个

**服务类**：4个核心
- CreditService（调度，~2,800行）
- CreditLimitService
- CreditCheckService
- CreditOccupancyService

**决策卡**：5个
- 检查策略（实时/异步）
- 占用时机（出库/AR）
- 释放时机（收款/核销）
- 额度不足处理（审批/拒绝）
- 冻结策略（手动/自动）

**巨型类风险**：1个
- CreditService

**进入DA8的输入**：
- 需验证假设与约束
- 需识别反证案例
