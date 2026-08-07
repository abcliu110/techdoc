# 数据模型 — K3Cloud Credit信用管理

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Credit信用管理 |
| 分析时间 | 2026-08-07 |

---

## 一、核心数据表

### 1.1 信用额度表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_CR_CREDITLIMIT | 信用额度表头 | FID | 额度基本信息、客户、金额 |
| T_CR_CREDITLIMITENTRY | 信用额度明细 | FENTRYID | 不同币种/类型的额度明细 |

### 1.2 额度使用表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_CR_CREDITLIMITUSAGE | 额度使用记录 | FID | 占用/释放记录 |
| T_CR_CREDITLIMITFREEZE | 额度冻结记录 | FID | 冻结记录 |

### 1.3 信用评级表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_CR_CREDITRATING | 信用评级 | FID | 客户评级信息 |
| T_CR_CREDITRATINGHISTORY | 评级历史 | FID | 评级变更历史 |

### 1.4 预警表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_CR_CREDITWARNING | 信用预警 | FID | 预警记录 |
| T_CR_CREDITWARNINGRULE | 预警规则 | FID | 预警规则配置 |

---

## 二、表结构详情

### 2.1 T_CR_CREDITLIMIT（信用额度表头）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER, NOT NULL |
| FCREDITLIMIT | DECIMAL(18,6) | 信用额度 | NOT NULL |
| FAAVAILABLELIMIT | DECIMAL(18,6) | 可用额度 | |
| FOCCUPIEDLIMIT | DECIMAL(18,6) | 已占用额度 | |
| FFROZENLIMIT | DECIMAL(18,6) | 已冻结额度 | |
| FCURRENCYID | BIGINT | 币种ID | FK→T_BD_CURRENCY |
| FLIMITTYPE | VARCHAR(20) | 额度类型 | TEMPORARY/PERMANENT |
| FSTATUS | VARCHAR(20) | 状态 | NORMAL/FROZEN/EXPIRED |
| FEFFECTIVEDATE | DATE | 生效日期 | |
| FEXPIRYDATE | DATE | 失效日期 | |
| FCREATORID | BIGINT | 创建人 | |
| FCREATEDATE | DATETIME | 创建日期 | |
| FAPPROVERID | BIGINT | 审批人 | |
| FAPPROVEDATE | DATETIME | 审批日期 | |
| FORGID | BIGINT | 组织ID | FK→T_ORG_ORGANIZATIONS |

### 2.2 T_CR_CREDITLIMITUSAGE（额度使用记录）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER, NOT NULL |
| FCREDITLIMITID | BIGINT | 额度ID | FK→T_CR_CREDITLIMIT |
| FSOURCEBILLTYPE | VARCHAR(50) | 源单据类型 | SAL_ORDER/SAL_DELIVERY/AR_BILL |
| FSOURCEBILLID | BIGINT | 源单据ID | NOT NULL |
| FOCCUPYAMOUNT | DECIMAL(18,6) | 占用金额 | NOT NULL |
| FRELEASEDAMOUNT | DECIMAL(18,6) | 已释放金额 | DEFAULT 0 |
| FSTATUS | VARCHAR(20) | 状态 | OCCUPYING/PARTIAL/RELEASED |
| FOCCUPYTIME | DATETIME | 占用时间 | NOT NULL |
| FRELEASETIME | DATETIME | 释放时间 | |

### 2.3 T_CR_CREDITLIMITFREEZE（额度冻结记录）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER, NOT NULL |
| FCREDITLIMITID | BIGINT | 额度ID | FK→T_CR_CREDITLIMIT |
| FFREEZEAMOUNT | DECIMAL(18,6) | 冻结金额 | NOT NULL |
| FFREEZETYPE | VARCHAR(20) | 冻结类型 | ALL/PARTIAL |
| FFREEZEREASON | VARCHAR(50) | 冻结原因 | OVERDUE/VIOLATION/RISK/OTHER |
| FFREEZETIME | DATETIME | 冻结时间 | NOT NULL |
| FUNFREEZETIME | DATETIME | 计划解冻时间 | |
| FSTATUS | VARCHAR(20) | 状态 | FROZEN/UNFROZEN |
| FOPERATORID | BIGINT | 操作人 | |
| FMEMO | TEXT | 备注 | |

### 2.4 T_CR_CREDITRATING（信用评级）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER, UNIQUE |
| FRATINGLEVEL | VARCHAR(10) | 评级等级 | AAA/AA/A/BBB/BB/B/C/D |
| FRATINGDATE | DATE | 评级日期 | NOT NULL |
| FRATINGEXPIRYDATE | DATE | 评级到期日 | |
| FRATERID | BIGINT | 评级人 | |
| FRATINGBASIS | TEXT | 评级依据 | |
| FCREDITCOEFFICIENT | DECIMAL(5,4) | 信用系数 | DEFAULT 1.0 |

### 2.5 T_CR_CREDITWARNING（信用预警）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER, NOT NULL |
| FWARNINGLEVEL | VARCHAR(20) | 预警级别 | INFO/WARNING/CRITICAL |
| FWARNINGTYPE | VARCHAR(50) | 预警类型 | OVERDUE/LIMIT_EXCEED/RATING_DOWN |
| FTRIGGERCONDITION | TEXT | 触发条件 | |
| FTRIGGERTIME | DATETIME | 触发时间 | NOT NULL |
| FHANDLESTATUS | VARCHAR(20) | 处理状态 | PENDING/PROCESSING/HANDLED |
| FHANDLERID | BIGINT | 处理人 | |
| FHANDLETIME | DATETIME | 处理时间 | |
| FHANDLERESULT | TEXT | 处理结果 | |

---

## 三、索引设计

### 3.1 主键索引

| 表名 | 索引名 | 字段 |
|---|---|---|
| T_CR_CREDITLIMIT | PK_T_CR_CREDITLIMIT | FID |
| T_CR_CREDITLIMITUSAGE | PK_T_CR_CREDITLIMITUSAGE | FID |
| T_CR_CREDITLIMITFREEZE | PK_T_CR_CREDITLIMITFREEZE | FID |
| T_CR_CREDITRATING | PK_T_CR_CREDITRATING | FID |
| T_CR_CREDITWARNING | PK_T_CR_CREDITWARNING | FID |

### 3.2 业务索引

| 表名 | 索引名 | 字段 | 类型 |
|---|---|---|---|
| T_CR_CREDITLIMIT | IDX_CREDITLIMIT_CUST | FCUSTOMERID | |
| T_CR_CREDITLIMIT | IDX_CREDITLIMIT_STATUS | FSTATUS | |
| T_CR_CREDITLIMITUSAGE | IDX_CREDITUSAGE_CUST | FCUSTOMERID | |
| T_CR_CREDITLIMITUSAGE | IDX_CREDITUSAGE_SOURCE | FSOURCEBILLID, FSOURCEBILLTYPE | |
| T_CR_CREDITLIMITUSAGE | IDX_CREDITUSAGE_STATUS | FSTATUS | |
| T_CR_CREDITRATING | IDX_CREDITRATING_CUST | FCUSTOMERID | UNIQUE |
| T_CR_CREDITWARNING | IDX_CREDITWARNING_CUST | FCUSTOMERID | |
| T_CR_CREDITWARNING | IDX_CREDITWARNING_STATUS | FHANDLESTATUS | |

---

## 四、事件模型

### 4.1 额度事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnCreditLimitCreate | 额度申请创建 | 记录申请、状态=申请中 |
| OnCreditLimitApprove | 额度审批通过 | 更新状态、设置生效日期 |
| OnCreditLimitAdjust | 额度调整 | 更新额度、更新可用额度 |
| OnCreditLimitFreeze | 额度冻结 | 创建冻结记录、更新可用额度 |
| OnCreditLimitUnfreeze | 额度解冻 | 更新冻结状态、恢复可用额度 |

### 4.2 占用事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnCreditOccupy | 出库审核/AR记账 | 创建使用记录、更新可用额度 |
| OnCreditRelease | 收款确认/核销 | 更新释放金额、更新可用额度 |

### 4.3 预警事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnWarningTrigger | 定时检查/业务触发 | 创建预警记录、通知处理人 |
| OnWarningHandle | 预警处理 | 更新处理状态、记录处理结果 |

---

## 五、与其他模块的表关联

### 5.1 与Sal销售模块

| Credit表 | 关联字段 | Sal表 | 说明 |
|---|---|---|---|
| T_CR_CREDITLIMITUSAGE | FSOURCEBILLID | T_SAL_DELIVERY | 出库触发占用 |
| T_CR_CREDITLIMITUSAGE | FSOURCEBILLID | T_SAL_ORDER | 订单关联（参考） |

### 5.2 与AR应收模块

| Credit表 | 关联字段 | AR表 | 说明 |
|---|---|---|---|
| T_CR_CREDITLIMITUSAGE | FSOURCEBILLID | T_AR_RECEIVABLE | AR记账触发占用 |
| T_CR_CREDITLIMITUSAGE | FSOURCEBILLID | T_AR_RECEIPT | 收款触发释放 |

### 5.3 与基础数据模块

| Credit表 | 关联字段 | 基础表 | 说明 |
|---|---|---|---|
| T_CR_CREDITLIMIT | FCUSTOMERID | T_BD_CUSTOMER | 客户档案 |
| T_CR_CREDITLIMIT | FCURRENCYID | T_BD_CURRENCY | 币种 |
| T_CR_CREDITRATING | FCUSTOMERID | T_BD_CUSTOMER | 客户档案 |

---

## 六、DA5分析结论

**数据表清单**：9张
- 信用额度表：2张
- 额度使用表：2张
- 信用评级表：2张
- 预警表：2张
- 调整申请表：1张

**关键索引**：8个
- 主键索引：5个
- 业务索引：3个

**事件模型**：
- 额度事件：5个
- 占用事件：2个
- 预警事件：2个

**进入DA6的输入**：
- 需建立API契约
- 事件触发点需与API对应
