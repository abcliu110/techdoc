# DA5 数据模型 — K3Cloud CB现金管理

## 一、核心数据表

### 1.1 账户表

| 表名 | 用途 | 关键字段 | 证据 |
|---|---|---|---|
| CB_CASHACCOUNT | 现金账户 | FACCOUNTID, FACCOUNTNO, FACCOUNTNAME, FBALANCE, FCURRENCYID | E-DOC-001 §5.1 |
| CB_BANKACCOUNT | 银行账户 | FBANKACCOUNTID, FBANKACCOUNTNO, FBANKNAME, FACCOUNTNO, FBALANCE, FCURRENCYID | E-DOC-001 §5.1 |

### 1.2 流水表

| 表名 | 用途 | 关键字段 | 证据 |
|---|---|---|---|
| CB_RECEIVEFLOW | 收款流水 | FFLOWID, FACCOUNTID, FAMOUNT, FDATE, FSOURCEBILLID, FCURRENCYID | E-DOC-001 §5.1 |
| CB_PAYFLOW | 付款流水 | FPAYFLOWID, FACCOUNTID, FAMOUNT, FDATE, FSOURCEBILLID, FCURRENCYID | E-DOC-001 §5.1 |

### 1.3 对账表

| 表名 | 用途 | 关键字段 | 证据 |
|---|---|---|---|
| CB_RECONCILIATION | 对账记录 | FRECID, FBANKACCOUNTID, FPERIOD, FBALANCE, FRECONSTATUS | E-DOC-001 §5.2 |
| CB_BALANCEADJUSTMENT | 余额调节 | FADJID, FRECID, FADJTYPE, FAMOUNT, FDATE, FDESC | E-DOC-001 §5.2 |

## 二、事件分析

| 事件编号 | 事件名称 | 触发时机 | 涉及表 | 证据 |
|---|---|---|---|---|
| EVT-CB-01 | 收款登记 | 收款单审核通过 | CB_RECEIVEFLOW, CB_BANKACCOUNT | E-DOC-001 §5.1 |
| EVT-CB-02 | 付款登记 | 付款单审核通过 | CB_PAYFLOW, CB_BANKACCOUNT | E-DOC-001 §5.1 |
| EVT-CB-03 | 日记账生成 | 凭证生成 | CB_DAILYJOURNAL | E-DOC-001 §5.1 |
| EVT-CB-04 | 日报汇总 | 日末定时任务 | CB_DAILYSUMMARY | E-DOC-001 §5.1 |
| EVT-CB-05 | 银行对账 | 期末手动触发 | CB_RECONCILIATION | E-DOC-001 §5.2 |
| EVT-CB-06 | 余额调节 | 对账后 | CB_BALANCEADJUSTMENT | E-DOC-001 §5.2 |

## 三、索引设计

| 索引 | 表 | 用途 | 证据 |
|---|---|---|---|
| PK_CB_CASHACCOUNT | CB_CASHACCOUNT | 现金账户主键 | E-DOC-001 |
| PK_CB_BANKACCOUNT | CB_BANKACCOUNT | 银行账户主键 | E-DOC-001 |
| IX_CB_RECEIVEFLOW_DATE | CB_RECEIVEFLOW | 按日期查询收款 | E-DOC-001 |
| IX_CB_PAYFLOW_DATE | CB_PAYFLOW | 按日期查询付款 | E-DOC-001 |
| IX_CB_RECONCILIATION_PERIOD | CB_RECONCILIATION | 按期间对账 | E-DOC-001 |

## 四、全面性检查清单

- [x] 是否覆盖了所有核心数据表（6张）？
- [x] 是否覆盖了所有核心事件（6个）？
- [x] 索引设计是否满足查询需求？
- [x] 每个表是否有证据标注？
