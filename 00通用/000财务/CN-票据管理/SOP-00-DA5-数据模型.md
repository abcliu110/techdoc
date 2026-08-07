# CN票据管理SOP-00-DA5-数据模型

## 文档信息
- **模块**: CN票据管理
- **阶段**: DA5-数据模型
- **版本**: V1.0 | **日期**: 2026-08-06

---

## 一、核心数据表（8张表）

### 1.1 表清单

| 序号 | 表名 | 用途 | 关键字段数 |
|---|---|---|---|
| 1 | CN_RECEIVEBILL | 应收票据主表 | 15+ |
| 2 | CN_PAYBILL | 应付票据主表 | 15+ |
| 3 | CN_BILLENDORSERECORD | 背书记录表 | 8 |
| 4 | CN_BILLCASHRECORD | 票据兑现记录表 | 10 |
| 5 | AR_RECEIVABLE | 应收单（关联） | 20+ |
| 6 | AP_PAYABLE | 应付单（关联） | 20+ |
| 7 | GL_VOUCHER | 凭证（关联） | 10+ |
| 8 | CB_BANKACCOUNT | 银行账户（关联） | 10+ |

---

## 二、核心表结构

### 2.1 CN_RECEIVEBILL（应收票据主表）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FBillID | BIGINT | 主键 | PK |
| FBillNo | VARCHAR(50) | 票据号码 | UNIQUE, NOT NULL |
| FBillType | INT | 票据类型(1=B/A, 2=C/A) | NOT NULL |
| FDrawer | VARCHAR(200) | 出票人 | NOT NULL |
| FDrawerBank | VARCHAR(200) | 出票银行 | |
| FPayee | VARCHAR(200) | 收票人 | NOT NULL |
| FPayeeBank | VARCHAR(200) | 收票银行 | |
| FAmount | DECIMAL(18,2) | 票面金额 | NOT NULL |
| FCashedAmount | DECIMAL(18,2) | 已兑现金额 | DEFAULT 0 |
| FCurrencyID | INT | 币别 | NOT NULL |
| FIssueDate | DATE | 出票日期 | NOT NULL |
| FDueDate | DATE | 到期日期 | NOT NULL |
| FBillStatus | INT | 票据状态 | NOT NULL |
| FEndorser | VARCHAR(200) | 当前持票人 | |
| FCustomerID | INT | 关联客户 | FK |
| FBankAccountID | INT | 托收银行账户 | FK |
| FRemark | VARCHAR(500) | 备注 | |
| FCreatorID | INT | 创建人 | |
| FCreateDate | DATETIME | 创建时间 | |
| FModifierID | INT | 修改人 | |
| FModifyDate | DATETIME | 修改时间 | |
| FAuditorID | INT | 审核人 | |
| FAuditDate | DATETIME | 审核时间 | |

**索引设计**:
- PK_CN_RECEIVEBILL (FBillID)
- IX_CN_RECEIVEBILL_NO (FBillNo)
- IX_CN_RECEIVEBILL_CUSTOMER (FCustomerID)
- IX_CN_RECEIVEBILL_STATUS (FBillStatus)
- IX_CN_RECEIVEBILL_DUEDATE (FDueDate)

### 2.2 CN_PAYBILL（应付票据主表）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FBillID | BIGINT | 主键 | PK |
| FBillNo | VARCHAR(50) | 票据号码 | UNIQUE, NOT NULL |
| FPayBillType | INT | 票据类型(1=B/A, 2=C/A) | NOT NULL |
| FDrawer | VARCHAR(200) | 出票人(企业) | NOT NULL |
| FDrawerBank | VARCHAR(200) | 出票银行 | |
| FPayee | VARCHAR(200) | 收款人 | NOT NULL |
| FPayeeBank | VARCHAR(200) | 收款银行 | |
| FAmount | DECIMAL(18,2) | 票面金额 | NOT NULL |
| FPayedAmount | DECIMAL(18,2) | 已付款金额 | DEFAULT 0 |
| FCurrencyID | INT | 币别 | NOT NULL |
| FIssueDate | DATE | 出票日期 | NOT NULL |
| FDueDate | DATE | 到期日期 | NOT NULL |
| FBillStatus | INT | 票据状态 | NOT NULL |
| FSupplierID | INT | 关联供应商 | FK |
| FBankAccountID | INT | 付款银行账户 | FK |
| FCreditLimit | DECIMAL(18,2) | 银行授信额度 | |
| FRemark | VARCHAR(500) | 备注 | |
| FCreatorID | INT | 创建人 | |
| FCreateDate | DATETIME | 创建时间 | |
| FAuditorID | INT | 审核人 | |
| FAuditDate | DATETIME | 审核时间 | |

**索引设计**:
- PK_CN_PAYBILL (FBillID)
- IX_CN_PAYBILL_NO (FBillNo)
- IX_CN_PAYBILL_SUPPLIER (FSupplierID)
- IX_CN_PAYBILL_STATUS (FBillStatus)
- IX_CN_PAYBILL_DUEDATE (FDueDate)

### 2.3 CN_BILLENDORSERECORD（背书记录表）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FEndorseID | BIGINT | 主键 | PK |
| FBillID | BIGINT | 票据ID | FK, NOT NULL |
| FBillNo | VARCHAR(50) | 票据号码 | NOT NULL |
| FEndorseSeq | INT | 背书序号 | NOT NULL |
| FEndorser | VARCHAR(200) | 背书人 | NOT NULL |
| FEndorsee | VARCHAR(200) | 被背书人 | NOT NULL |
| FEndorseeSupplierID | INT | 被背书人供应商ID | FK |
| FEndorseDate | DATE | 背书日期 | NOT NULL |
| FAmount | DECIMAL(18,2) | 背书金额 | NOT NULL |
| FRemark | VARCHAR(500) | 备注 | |

**索引设计**:
- PK_CN_BILLENDORSERECORD (FEndorseID)
- IX_CN_BILLENDORSE_BILL (FBillID)
- IX_CN_BILLENDORSE_DATE (FEndorseDate)

### 2.4 CN_BILLCASHRECORD（票据兑现记录表）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FCashID | BIGINT | 主键 | PK |
| FBillID | BIGINT | 票据ID | FK, NOT NULL |
| FBillNo | VARCHAR(50) | 票据号码 | NOT NULL |
| FCashType | INT | 兑现类型(1=托收, 2=付款) | NOT NULL |
| FCashDate | DATE | 兑现日期 | NOT NULL |
| FCashAmount | DECIMAL(18,2) | 兑现金额 | NOT NULL |
| FBankAccountID | INT | 收付银行账户 | FK |
| FVoucherID | BIGINT | 关联凭证ID | FK |
| FCashStatus | INT | 兑现状态(0=处理中, 1=成功, 2=失败) | |
| FRemark | VARCHAR(500) | 备注 | |

**索引设计**:
- PK_CN_BILLCASHRECORD (FCashID)
- IX_CN_BILLCASH_BILL (FBillID)
- IX_CN_BILLCASH_DATE (FCashDate)

---

## 三、事件模型（7个事件）

### 3.1 应收票据事件

| 事件ID | 事件名称 | 触发时机 | 影响表 | 事件数据 |
|---|---|---|---|---|
| EVT-CN-01 | 收票登记 | 收到票据 | CN_RECEIVEBILL | 票据基本信息 |
| EVT-CN-02 | 票据审核 | 审核通过 | CN_RECEIVEBILL | 审核人、时间 |
| EVT-CN-03 | 票据背书 | 背书转让 | CN_BILLENDORSERECORD | 背书人、被背书人 |
| EVT-CN-04 | 票据兑现 | 到期托收 | CN_BILLCASHRECORD | 兑现金额、日期 |
| EVT-CN-05 | 票据作废 | 人工作废 | CN_RECEIVEBILL | 作废原因 |

### 3.2 应付票据事件

| 事件ID | 事件名称 | 触发时机 | 影响表 | 事件数据 |
|---|---|---|---|---|
| EVT-CN-06 | 开票登记 | 开立票据 | CN_PAYBILL | 票据基本信息 |
| EVT-CN-07 | 票据付款 | 到期付款 | CN_BILLCASHRECORD | 付款金额、日期 |

---

## 四、数据一致性约束

### 4.1 表间一致性

| 约束ID | 约束内容 | 检查点 |
|---|---|---|
| DC-01 | 应收票据金额 = 关联AR未核销金额之和 | 登记/核销时 |
| DC-02 | 应付票据金额 = 关联AP未核销金额之和 | 登记/核销时 |
| DC-03 | 背书后票据状态 = 背书中(1) | 背书成功后 |
| DC-04 | 兑现后票据状态 = 已兑现(3) | 兑现成功后 |

### 4.2 金额一致性

| 约束ID | 约束内容 | 验证SQL |
|---|---|---|
| DC-05 | 应收票据已兑现金额 ≤ 票面金额 | `FCashedAmount ≤ FAmount` |
| DC-06 | 应付票据已付款金额 ≤ 票面金额 | `FPayedAmount ≤ FAmount` |
| DC-07 | 背书金额 = 票据票面金额 | `背书金额 = FAmount` |

---

## 五、DA5结论

### 5.1 产出汇总

| 产出 | 数量 |
|---|---|
| 核心数据表 | 8张 |
| 索引 | 20+个 |
| 事件 | 7个 |
| 数据一致性约束 | 7条 |

### 5.2 G5门禁检查

| 门禁项 | 状态 | 说明 |
|---|---|---|
| G5-A 表结构完整 | ✅ | 8张表覆盖票据全业务 |
| G5-B 索引设计合理 | ✅ | 关键字段均有索引 |
| G5-C 事件覆盖全 | ✅ | 7个事件覆盖票据生命周期 |
| G5-D 约束无遗漏 | ✅ | 7条一致性约束确保数据准确 |
| G5-E 与AP/AR表结构一致 | ✅ | 复用相同的核销字段设计 |
