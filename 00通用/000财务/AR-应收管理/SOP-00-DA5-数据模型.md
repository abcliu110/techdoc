# DA5 数据模型 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 AP应付管理 SOP-00-DA5-数据模型.md，门禁检查 5 项全部通过（AR镜像）。

---

## 一、表结构清单（8张）

### 1.1 核心业务表（4张）

| 表名 | 表类型 | 用途 | 主键 | 关键索引 |
|---|---|---|---|---|
| AR_RECEIVABLE | 业务主表 | 应收单据主表 | FBillID | IX_AR_RECEIVABLE_NO, IX_AR_RECEIVABLE_CUSTOMER |
| AR_RECEIVABLEENTRY | 业务分录表 | 应收单据分录行 | FEntryID | IX_AR_RECEIVABLEENTRY_BILL |
| AR_WRITEOFFRECORD | 核销记录表 | 核销事务记录 | FWriteOffRecordID | IX_AR_WRITEOFF_SOURCE, IX_AR_WRITEOFF_TARGET |
| AR_VERIFICATION | 钩稽关系表 | 暂收与财务单据关联 | FVerificationID | IX_AR_VERIFICATION_SOURCE, IX_AR_VERIFICATION_TARGET |

### 1.2 内部核销表（2张）

| 表名 | 表类型 | 用途 | 主键 | 关键索引 |
|---|---|---|---|---|
| AR_InnerIVRecord | 内部应收表 | 组织间内部应收单 | FInnerIVRecordID | IX_AR_InnerIV_ORG |
| AR_InnerAPRecord | 内部应付表 | 组织间内部应付单（AR侧） | FInnerAPRecordID | IX_AR_InnerAP_ORG |

### 1.3 映射与配置表（2张）

| 表名 | 表类型 | 用途 | 主键 | 关键索引 |
|---|---|---|---|---|
| BAS_BusinessVoucher | 业务凭证映射表 | 业务单据与GL凭证关联 | FMappingID | IX_BusinessVoucher_Source, IX_BusinessVoucher_Voucher |
| AR_ReceivableMatchRule | 匹配规则表 | 核销匹配规则配置 | FMatchRuleID | IX_AR_ReceivableMatchRule_ORG |

---

## 二、表结构详情

### 2.1 AR_RECEIVABLE（应收单据主表）

| 字段 | 数据类型 | 说明 | 约束 |
|---|---|---|---|
| FBillID | BIGINT | 单据ID | PK |
| FBillNo | VARCHAR(50) | 单据编号 | NOT NULL, UNIQUE |
| FBillType | VARCHAR(20) | 单据类型(SA/QT/YS/HT) | NOT NULL |
| FSetAccountType | INT | 核算类型(1=其他,2=暂收,3=财务) | NOT NULL |
| FWriteOffStatus | INT | 核销状态(0=未核,1=部分核,2=已核销) | NOT NULL |
| FCustomerID | BIGINT | 客户ID | FK→BD_Customer |
| FOrgID | BIGINT | 组织ID | FK→BD_Org |
| FCurrencyID | BIGINT | 币别ID | FK→BD_Currency |
| FReceivableAmt | DECIMAL(18,6) | 应收金额 | NOT NULL |
| FUnWriteOffAmt | DECIMAL(18,6) | 未核销金额 | NOT NULL |
| FRelateHadReceiveAmount | DECIMAL(18,6) | 已关联收款金额 | NOT NULL |
| FDueDate | DATETIME | 到期日期 | NULL |
| FDocumentStatus | INT | 单据状态(0=草稿,1=已审核,2=已关闭) | NOT NULL |
| FCreatorID | BIGINT | 创建人ID | NOT NULL |
| FCreateTime | DATETIME | 创建时间 | NOT NULL |
| FModifierID | BIGINT | 修改人ID | NULL |
| FModifyTime | DATETIME | 修改时间 | NULL |
| FPeriodID | BIGINT | 会计期间ID | FK→BD_FiscalPeriod |
| FVerificationID | BIGINT | 钩稽关系ID | FK→AR_VERIFICATION, NULL |

### 2.2 AR_RECEIVABLEENTRY（应收单据分录表）

| 字段 | 数据类型 | 说明 | 约束 |
|---|---|---|---|
| FEntryID | BIGINT | 分录ID | PK |
| FBillID | BIGINT | 单据ID | FK→AR_RECEIVABLE, NOT NULL |
| FSeq | INT | 序号 | NOT NULL |
| FMaterialID | BIGINT | 物料ID | NULL |
| FQty | DECIMAL(18,6) | 数量 | NULL |
| FPrice | DECIMAL(18,6) | 单价 | NULL |
| FAmount | DECIMAL(18,6) | 金额 | NOT NULL |
| FTaxAmount | DECIMAL(18,6) | 税额 | NULL |
| FEntryWriteOffAmt | DECIMAL(18,6) | 分录已核销金额 | NOT NULL |
| FDimension1ID | BIGINT | 核算维度1 | NULL |
| FDimension2ID | BIGINT | 核算维度2 | NULL |
| FDimension3ID | BIGINT | 核算维度3 | NULL |
| FProjectID | BIGINT | 项目ID | NULL |
| FDepartmentID | BIGINT | 部门ID | NULL |

### 2.3 AR_WRITEOFFRECORD（核销记录表）

| 字段 | 数据类型 | 说明 | 约束 |
|---|---|---|---|
| FWriteOffRecordID | BIGINT | 核销记录ID | PK |
| FWriteOffType | INT | 核销类型(1=普通,2=特殊,3=内部) | NOT NULL |
| FWriteOffDate | DATETIME | 核销日期 | NOT NULL |
| FSourceBillType | VARCHAR(20) | 来源单据类型 | NOT NULL |
| FSourceBillID | BIGINT | 来源单据ID | NOT NULL |
| FTargetBillType | VARCHAR(20) | 目标单据类型 | NOT NULL |
| FTargetBillID | BIGINT | 目标单据ID | NOT NULL |
| FWriteOffAmt | DECIMAL(18,6) | 核销金额 | NOT NULL |
| FOrgID | BIGINT | 组织ID | FK→BD_Org |
| FVoucherID | BIGINT | 关联凭证ID | FK→GL_VOUCHER, NULL |
| FVoucherEntryID | BIGINT | 关联凭证分录ID | FK→GL_VOUCHERENTRY, NULL |
| FStatus | INT | 状态(0=有效,1=已反核销) | NOT NULL |
| FReversalRecordID | BIGINT | 反核销对应记录ID | FK→AR_WRITEOFFRECORD, NULL |

### 2.4 AR_VERIFICATION（钩稽关系表）

| 字段 | 数据类型 | 说明 | 约束 |
|---|---|---|---|
| FVerificationID | BIGINT | 钩稽ID | PK |
| FSourceBillID | BIGINT | 暂收单据ID | NOT NULL |
| FSourceBillType | VARCHAR(20) | 暂收单据类型 | NOT NULL |
| FTargetBillID | BIGINT | 财务单据ID | NOT NULL |
| FTargetBillType | VARCHAR(20) | 财务单据类型 | NOT NULL |
| FVerificationAmt | DECIMAL(18,6) | 钩稽金额 | NOT NULL |
| FVerificationDate | DATETIME | 钩稽日期 | NOT NULL |
| FVerificationStatus | INT | 钩稽状态(0=待确认,1=已确认,2=已反钩稽) | NOT NULL |
| FOrgID | BIGINT | 组织ID | FK→BD_Org |

### 2.5 BAS_BusinessVoucher（业务凭证映射表）

| 字段 | 数据类型 | 说明 | 约束 |
|---|---|---|---|
| FMappingID | BIGINT | 映射ID | PK |
| FSourceBillType | VARCHAR(20) | 业务单据类型 | NOT NULL |
| FSourceBillID | BIGINT | 业务单据ID | NOT NULL |
| FVoucherID | BIGINT | GL凭证ID | FK→GL_VOUCHER, NOT NULL |
| FVoucherEntryID | BIGINT | GL凭证分录ID | FK→GL_VOUCHERENTRY, NULL |
| FMappingType | INT | 映射类型(1=单据→凭证,2=凭证→单据) | NOT NULL |
| FOrgID | BIGINT | 组织ID | FK→BD_Org |
| FCreateTime | DATETIME | 创建时间 | NOT NULL |

---

## 三、领域事件清单（7个）

### 3.1 核心业务事件（5个）

| 事件ID | 事件名称 | 触发时机 | 事件数据 | 下游影响 |
|---|---|---|---|---|
| EVT-AR-01 | 应收单保存 | 应收单保存操作 | {BillID, BillType, OrgID} | 触发SetAccountType |
| EVT-AR-02 | 应收单审核 | 应收单审核通过 | {BillID, BillType, SetAccountType} | 触发凭证生成 |
| EVT-AR-03 | 钩稽确认 | Verify操作完成 | {VerificationID, SourceBillID, TargetBillID} | 更新核算类型 |
| EVT-AR-04 | 核销完成 | FinMatchProcess成功 | {WriteOffRecordID, SourceBillID, TargetBillID} | 更新未核销金额，触发凭证 |
| EVT-AR-05 | 核销反操作 | UnVerify操作完成 | {WriteOffRecordID, ReversalRecordID} | 补偿凭证，恢复状态 |

### 3.2 内部核销事件（2个）

| 事件ID | 事件名称 | 触发时机 | 事件数据 | 下游影响 |
|---|---|---|---|---|
| EVT-AR-06 | 内部核销完成 | InnerClear成功 | {InnerClearID, SourceRecordID, TargetRecordID} | 更新内部往来余额 |
| EVT-AR-07 | 内部核销反操作 | InnerUnClear成功 | {InnerClearID, ReversalRecordID} | 补偿凭证，恢复余额 |

---

## 四、事件时序图

```
┌──────────────────────────────────────────────────────────────────────┐
│                     AR领域事件时序图                                    │
└──────────────────────────────────────────────────────────────────────┘

时间线 ──────────────────────────────────────────────────────────────────▶

         EVT-AR-01                 EVT-AR-02               EVT-AR-03
    ┌─────────────┐           ┌─────────────┐        ┌─────────────┐
    │  应收单保存  │           │  应收单审核  │        │  钩稽确认   │
    └──────┬──────┘           └──────┬──────┘        └──────┬──────┘
           │                         │                        │
           ▼                         ▼                        ▼
    ┌─────────────────────────────────────────────────────────────────┐
    │  AR_RECEIVABLE写   AR_RECEIVABLE写  AR_VERIFICATION写  凭证生成 │
    │  FSetAccountType   FDocumentStatus FVerificationID     服务调用 │
    └─────────────────────────────────────────────────────────────────┘

                         EVT-AR-04                                    EVT-AR-05
                    ┌─────────────┐                              ┌─────────────┐
                    │   核销完成   │                              │  核销反操作  │
                    └──────┬──────┘                              └──────┬──────┘
                           │                                           │
                           ▼                                           ▼
              ┌────────────────────────────────────────────────────────┐
              │ AR_WRITEOFFRECORD写  AR_RECEIVABLE更新  GL_VOUCHER生成 │
              │ FWriteOffRecordID   FUnWriteOffAmt    核销凭证        │
              └────────────────────────────────────────────────────────┘
                                       ▲
                                       │
                              ┌────────┴────────┐
                              │  补偿凭证生成   │
                              └─────────────────┘
```

---

## 五、数据一致性约束

### 5.1 字段级约束

| 约束 | 表 | 规则 | 校验时机 |
|---|---|---|---|
| 未核销金额≥0 | AR_RECEIVABLE | FUnWriteOffAmt >= 0 | 核销后校验 |
| 已收款金额≤应收金额 | AR_RECEIVABLE | FRelateHadReceiveAmount <= FReceivableAmt | 收款时校验 |
| 核销金额≤双方未核销 | AR_WRITEOFFRECORD | FWriteOffAmt <= MIN(Source.FUnWriteOffAmt, Target.FUnWriteOffAmt) | 核销时校验 |
| 钩稽金额≤暂收未核 | AR_VERIFICATION | FVerificationAmt <= Source.FUnWriteOffAmt | 钩稽时校验 |

### 5.2 表间一致性约束

| 约束ID | 描述 | SQL表达 |
|---|---|---|
| IC-01 | 应收单未核销金额 = 应收金额 - 核销记录汇总 | AR_RECEIVABLE.FUnWriteOffAmt = FReceivableAmt - SUM(AR_WRITEOFFRECORD.FWriteOffAmt) WHERE FStatus=0 |
| IC-02 | 钩稽关系双方存在且状态匹配 | AR_VERIFICATION.FVerificationStatus ∈ {1} ↔ AR_RECEIVABLE.FVerificationID IS NOT NULL |
| IC-03 | 凭证映射必有一一对应 | BAS_BusinessVoucher.FSourceBillID IS NOT NULL AND BAS_BusinessVoucher.FVoucherID IS NOT NULL |

### 5.3 索引设计说明

| 索引名 | 表 | 字段 | 用途 |
|---|---|---|---|
| IX_AR_RECEIVABLE_NO | AR_RECEIVABLE | FBillNo | 单据编号唯一查询 |
| IX_AR_RECEIVABLE_CUSTOMER | AR_RECEIVABLE | FCustomerID, FOrgID | 客户维度查询 |
| IX_AR_WRITEOFF_SOURCE | AR_WRITEOFFRECORD | FSourceBillID | 核销来源追溯 |
| IX_AR_WRITEOFF_TARGET | AR_WRITEOFFRECORD | FTargetBillID | 核销目标追溯 |
| IX_BusinessVoucher_Source | BAS_BusinessVoucher | FSourceBillType, FSourceBillID | 单据追溯凭证 |
| IX_BusinessVoucher_Voucher | BAS_BusinessVoucher | FVoucherID | 凭证追溯业务 |

---

## 六、AR vs AP 数据模型对比

| 对比维度 | AR应收管理 | AP应付管理 |
|---|---|---|
| 核心单据表 | AR_RECEIVABLE | AP_PAYABLE |
| 债务方字段 | FCustomerID（客户） | FSupplierID（供应商） |
| 应收/应付金额 | FReceivableAmt | FPayableAmt |
| 未核销金额 | FUnWriteOffAmt | FUnWriteOffAmt |
| 已关联收款/付款 | FRelateHadReceiveAmount | FRelateHadPayAmount |
| 内部应收表 | AR_InnerIVRecord | AP_InnerIVRecord |
| 内部应付表(AR侧) | AR_InnerAPRecord | AP_InnerPayRecord |

---

## 七、数据模型-源码映射

| 表名 | 源码操作类 | 核心方法 |
|---|---|---|
| AR_RECEIVABLE | ARReceivableEdit.cs | Save(), Audit(), SetAccountType() |
| AR_RECEIVABLEENTRY | ARReceivableEdit.cs | LoadEntry(), SaveEntry() |
| AR_WRITEOFFRECORD | MatchServiceHelper.cs | Match(), CreateWriteOffRecord() |
| AR_VERIFICATION | VerificationServiceHelper.cs | Verify(), UnVerify() |
| BAS_BusinessVoucher | VoucherGenerateServiceHelper.cs | Generate(), CreateMapping() |
| AR_InnerIVRecord | ARInnerIVSpecialMatchEdit.cs | InnerIVProcess() |
| AR_InnerAPRecord | ARInnerIVSpecialMatchEdit.cs | InnerAPProcess() |
| AR_ReceivableMatchRule | ARFinMatch.cs | LoadMatchRule() |
