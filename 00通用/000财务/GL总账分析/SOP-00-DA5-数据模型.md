# DA5 数据模型 — K3Cloud GL总账模块

## 模板加载记录
已读取 SOP-00-DA5-模板.md，门禁检查 5 项全部通过。

---

## 核心表结构

### GL_VOUCHER（凭证表头）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | NVARCHAR(36) | 主键 | 凭证唯一标识 | PK, NOT NULL | E-SRC: 快速参考卡.md |
| FVoucherNo | NVARCHAR(50) | 凭证号 | 凭证的业务标识，格式：{凭证字}-{年份}-{序号} | NOT NULL, UNIQUE | E-SRC: 业务规则 |
| FAccountBookID | NVARCHAR(36) | 账簿ID | 凭证归属的财务边界 | FK → BD_AccountBook, NOT NULL | E-SRC: 快速参考卡.md |
| FDate | DATETIME | 凭证日期 | 业务发生日期，也是会计期间归属依据 | NOT NULL | E-SRC: 快速参考卡.md |
| FVoucherGroupID | NVARCHAR(36) | 凭证字ID | 凭证分类前缀 | FK → VoucherGroup | E-SRC: 快速参考卡.md |
| FDocumentStatus | INT | 单据状态 | 0=保存, 1=已审核, 2=已过账 | NOT NULL | E-SRC: 业务规则 |
| FApproverID | NVARCHAR(36) | 审核人ID | 审核该凭证的用户 | NULLABLE | E-SRC: 快速参考卡.md |
| FApproveDate | DATETIME | 审核日期 | 审核时间 | NULLABLE | E-SRC: 快速参考卡.md |
| FPosterID | NVARCHAR(36) | 过账人ID | 过账该凭证的用户 | NULLABLE | E-SRC: 快速参考卡.md |
| FPostDate | DATETIME | 过账日期 | 过账时间 | NULLABLE | E-SRC: 快速参考卡.md |
| FAttachments | INT | 附件张数 | 凭证附带的原始单据数量 | NOT NULL, DEFAULT 0 | E-SRC: 业务规则 |
| FExplanation | NVARCHAR(500) | 凭证摘要 | 凭证的整体说明 | NULLABLE | E-SRC: 快速参考卡.md |
| FCreatorID | NVARCHAR(36) | 制单人ID | 创建凭证的用户 | NOT NULL | E-SRC: 快速参考卡.md |
| FCreateDate | DATETIME | 制单日期 | 创建时间 | NOT NULL | E-SRC: 快速参考卡.md |
| FUpdaterID | NVARCHAR(36) | 更新人ID | 最后修改凭证的用户 | NULLABLE | E-SRC: 快速参考卡.md |
| FUpdateDate | DATETIME | 更新日期 | 最后修改时间 | NULLABLE | E-SRC: 快速参考卡.md |
| FIsVoid | BIT | 是否作废 | 凭证是否已作废 | NOT NULL, DEFAULT 0 | E-SRC: 业务规则 |

---

### GL_VOUCHERENTRY（凭证分录）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | BIGINT | 主键 | 分录唯一标识 | PK, IDENTITY | E-SRC: 快速参考卡.md |
| FVoucherID | NVARCHAR(36) | 凭证ID | 所属凭证的外键 | FK → GL_VOUCHER, NOT NULL | E-SRC: 快速参考卡.md |
| FEntryID | INT | 分录行号 | 凭证内的行顺序号 | NOT NULL | E-SRC: 快速参考卡.md |
| FAccountID | NVARCHAR(36) | 科目ID | 核算分类外键 | FK → BD_Account, NOT NULL | E-SRC: 快速参考卡.md |
| FDebit | DECIMAL(18,6) | 借方金额 | 借方发生额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FCredit | DECIMAL(18,6) | 贷方金额 | 贷方发生额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FExplanation | NVARCHAR(200) | 摘要 | 本行分录的说明 | NOT NULL | E-SRC: 业务规则 |
| FQuantity | DECIMAL(18,4) | 数量 | 辅助计量数量 | NULLABLE | E-SRC: 快速参考卡.md |
| FUnitPrice | DECIMAL(18,6) | 单价 | 辅助计量单价 | NULLABLE | E-SRC: 快速参考卡.md |
| FExchangeRate | DECIMAL(18,8) | 汇率 | 外币折算汇率 | NULLABLE | E-SRC: 快速参考卡.md |
| FOriginalAmount | DECIMAL(18,6) | 原币金额 | 外币原币金额 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel1 | NVARCHAR(36) | 核算维度1 | 如：部门 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel2 | NVARCHAR(36) | 核算维度2 | 如：项目 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel3 | NVARCHAR(36) | 核算维度3 | 如：供应商 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel4 | NVARCHAR(36) | 核算维度4 | 如：客户 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel5 | NVARCHAR(36) | 核算维度5 | 如：员工 | NULLABLE | E-SRC: 快速参考卡.md |

---

### BAS_BusinessVoucher（业务凭证映射）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | BIGINT | 主键 | 映射记录唯一标识 | PK, IDENTITY | E-SRC: ViewGlVoucher.cs |
| FSourceBillID | NVARCHAR(36) | 业务单据ID | 源业务单据的ID | NOT NULL | E-SRC: ViewGlVoucher.cs |
| FSourceFormID | NVARCHAR(50) | 业务单据类型 | 源业务单据的表单类型 | NOT NULL | E-SRC: ViewGlVoucher.cs |
| FSourceBillKey | NVARCHAR(50) | 业务单据行标识 | 源单据的行ID（如分录号） | NULLABLE | E-SRC: 快速参考卡.md |
| FVoucherID | NVARCHAR(36) | GL凭证ID | 关联的GL凭证ID | FK → GL_VOUCHER, NOT NULL | E-SRC: ViewGlVoucher.cs |
| FVoucherEntryID | BIGINT | 凭证分录ID | 关联的凭证分录ID（可选） | FK → GL_VOUCHERENTRY, NULLABLE | E-SRC: 快速参考卡.md |
| FAccountID | NVARCHAR(36) | 科目ID | 关联的会计科目（冗余存储） | FK → BD_Account, NULLABLE | E-SRC: 快速参考卡.md |
| FAmount | DECIMAL(18,6) | 钩稽金额 | 钩稽的金额（冗余存储） | NULLABLE | E-SRC: 快速参考卡.md |
| FIsActive | BIT | 是否有效 | 映射是否有效（作废后为false） | NOT NULL, DEFAULT 1 | E-SRC: 业务规则 |
| FHookStatus | INT | 钩稽状态 | 0=待确认, 1=已确认, 2=已拒绝, 3=已解除（EVO-E-GL-002A扩展） | NOT NULL, DEFAULT 0 | E-SRC: GL总账进化实施规格.md §2 |
| FConfirmedBy | NVARCHAR(100) | 确认人 | 钩稽确认人（EVO-E-GL-002A扩展） | NULLABLE | E-SRC: GL总账进化实施规格.md §2 |
| FConfirmedAt | DATETIME | 确认时间 | 钩稽确认时间（EVO-E-GL-002A扩展） | NULLABLE | E-SRC: GL总账进化实施规格.md §2 |
| FRejectReason | NVARCHAR(500) | 拒绝/解除原因 | 拒绝或解除钩稽的原因（EVO-E-GL-002A扩展） | NULLABLE | E-SRC: GL总账进化实施规格.md §2 |
| FLockVersion | BIGINT | 乐观锁版本 | 乐观锁版本号 | NOT NULL, DEFAULT 0 | E-SRC: GL总账进化实施规格.md §2 |
| FCreatedAt | DATETIME | 创建时间 | 映射记录创建时间 | NOT NULL | E-SRC: 业务规则 |
| FUpdatedAt | DATETIME | 更新时间 | 映射记录最后更新时间 | NOT NULL | E-SRC: 业务规则 |

---

### BD_AccountBook（账簿）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | NVARCHAR(36) | 主键 | 账簿唯一标识 | PK, NOT NULL | E-SRC: 快速参考卡.md |
| FName | NVARCHAR(200) | 账簿名称 | 账簿的显示名称 | NOT NULL | E-SRC: 快速参考卡.md |
| FNumber | NVARCHAR(50) | 账簿编码 | 账簿的业务编码 | NOT NULL, UNIQUE | E-SRC: 快速参考卡.md |
| FCreateOrgId | NVARCHAR(36) | 创建组织ID | 账簿所属的组织 | NOT NULL | E-SRC: 快速参考卡.md |
| FAccountSystemID | NVARCHAR(36) | 科目体系ID | 账簿关联的科目体系 | FK → BD_AccountSystem, NOT NULL | E-SRC: 快速参考卡.md |
| FCurrencyID | NVARCHAR(36) | 本位币ID | 账簿的计量货币 | FK → BD_Currency, NOT NULL | E-SRC: 快速参考卡.md |
| FIsActive | BIT | 是否启用 | 账簿是否启用 | NOT NULL, DEFAULT 1 | E-SRC: 业务规则 |

---

### BD_Account（会计科目）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | NVARCHAR(36) | 主键 | 科目唯一标识 | PK, NOT NULL | E-SRC: 快速参考卡.md |
| FNumber | NVARCHAR(50) | 科目编码 | 按级次规则的编码，如1001、100201 | NOT NULL | E-SRC: 快速参考卡.md |
| FName | NVARCHAR(200) | 科目名称 | 科目的显示名称 | NOT NULL | E-SRC: 快速参考卡.md |
| FAccountGroupID | INT | 科目类别 | 资产/负债/权益/收入/费用 | NOT NULL | E-SRC: 快速参考卡.md |
| FIsDetail | BIT | 是否明细科目 | 末级科目才能被引用 | NOT NULL | E-SRC: 业务规则 |
| FParentID | NVARCHAR(36) | 父级科目ID | 上级科目的ID，用于构建科目树 | NULLABLE | E-SRC: 快速参考卡.md |
| FBalanceDirection | INT | 余额方向 | 0=借方余额, 1=贷方余额 | NOT NULL | E-SRC: 快速参考卡.md |
| FIsAllowUsed | BIT | 是否可用 | 科目是否允许被引用 | NOT NULL, DEFAULT 1 | E-SRC: 业务规则 |
| FAccountSystemID | NVARCHAR(36) | 科目体系ID | 科目所属的科目体系 | FK → BD_AccountSystem, NOT NULL | E-SRC: 快速参考卡.md |

---

### BD_FiscalPeriod（会计期间）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | NVARCHAR(36) | 主键 | 期间唯一标识 | PK, NOT NULL | E-SRC: 快速参考卡.md |
| FAccountBookID | NVARCHAR(36) | 账簿ID | 期间所属的账簿 | FK → BD_AccountBook, NOT NULL | E-SRC: 快速参考卡.md |
| FYear | INT | 年度 | 会计年度 | NOT NULL | E-SRC: 快速参考卡.md |
| FPeriod | INT | 月份 | 会计月份（1-12） | NOT NULL | E-SRC: 快速参考卡.md |
| FBeginDate | DATE | 开始日期 | 期间的起始日期 | NOT NULL | E-SRC: 快速参考卡.md |
| FEndDate | DATE | 结束日期 | 期间的结束日期 | NOT NULL | E-SRC: 快速参考卡.md |
| FStatus | INT | 期间状态 | 0=打开, 1=已结账, 2=已年结 | NOT NULL | E-SRC: 快速参考卡.md |
| FClosedBy | NVARCHAR(36) | 结账人 | 执行结账操作的用户 | NULLABLE | E-SRC: 快速参考卡.md |
| FClosedDate | DATETIME | 结账日期 | 结账操作的时间 | NULLABLE | E-SRC: 快速参考卡.md |

---

### AccountBalance（科目余额表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | BIGINT | 主键 | 余额记录唯一标识 | PK, IDENTITY | E-SRC: 快速参考卡.md |
| FACCOUNTID | NVARCHAR(36) | 科目ID | 所属会计科目 | FK → BD_Account, NOT NULL | E-SRC: 快速参考卡.md |
| FPeriodID | NVARCHAR(36) | 期间ID | 所属会计期间 | FK → BD_FiscalPeriod, NOT NULL | E-SRC: 快速参考卡.md |
| FAccountBookID | NVARCHAR(36) | 账簿ID | 所属账簿 | FK → BD_AccountBook, NOT NULL | E-SRC: 快速参考卡.md |
| FOpeningDebit | DECIMAL(18,6) | 期初借方余额 | 期间开始时的借方余额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FOpeningCredit | DECIMAL(18,6) | 期初贷方余额 | 期间开始时的贷方余额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FPeriodDebit | DECIMAL(18,6) | 本期借方发生额 | 期间内的借方累计发生额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FPeriodCredit | DECIMAL(18,6) | 本期贷方发生额 | 期间内的贷方累计发生额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FClosingDebit | DECIMAL(18,6) | 期末借方余额 | 期末计算的借方余额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FClosingCredit | DECIMAL(18,6) | 期末贷方余额 | 期末计算的贷方余额 | NOT NULL, DEFAULT 0 | E-SRC: 快速参考卡.md |
| FDimensionLevel1 | NVARCHAR(36) | 核算维度1 | 按维度细分余额 | NULLABLE | E-SRC: 快速参考卡.md |
| FDimensionLevel2 | NVARCHAR(36) | 核算维度2 | 按维度细分余额 | NULLABLE | E-SRC: 快速参考卡.md |
| FYearEndBalance | BIT | 是否年结余额 | 是否已完成年结 | NOT NULL, DEFAULT 0 | E-SRC: 业务规则 |

---

### GL_ConfirmationContract（确认契约表）— EVO-E-GL-001B 新增

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|---|---|---|---|---|---|
| FID | NVARCHAR(36) | 主键 | 契约唯一标识 | PK, NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FSourceBillID | NVARCHAR(36) | 业务单据ID | 契约对应的业务单据 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FSourceFormID | NVARCHAR(50) | 业务单据类型 | 业务单据的表单类型 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FVoucherID | NVARCHAR(36) | GL凭证ID | 契约确认后关联的凭证 | NULLABLE | E-SRC: GL总账进化实施规格.md §1 |
| FStatus | INT | 契约状态 | 0=Proposed, 1=Confirmed, 2=Failed, 3=Cancelled | NOT NULL, DEFAULT 0 | E-SRC: GL总账进化实施规格.md §1 |
| FProposedAt | DATETIME | 提议时间 | 契约创建时间 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FConfirmedAt | DATETIME | 确认时间 | 契约确认时间 | NULLABLE | E-SRC: GL总账进化实施规格.md §1 |
| FExpiresAt | DATETIME | 过期时间 | 契约自动取消的时间点 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FTimeoutPolicy | INT | 超时策略 | 0=Cancel, 1=Notify, 2=Escalate | NOT NULL, DEFAULT 0 | E-SRC: GL总账进化实施规格.md §1 |
| FProposedBy | NVARCHAR(100) | 提议方 | 提议创建契约的系统/用户 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FConfirmedBy | NVARCHAR(100) | 确认方 | 确认契约的系统/用户 | NULLABLE | E-SRC: GL总账进化实施规格.md §1 |
| FLockVersion | BIGINT | 乐观锁版本 | 并发控制版本号 | NOT NULL, DEFAULT 0 | E-SRC: GL总账进化实施规格.md §1 |
| FCreatedBy | NVARCHAR(100) | 创建人 | 记录创建人 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FCreatedAt | DATETIME | 创建时间 | 记录创建时间 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |
| FUpdatedAt | DATETIME | 更新时间 | 记录最后更新时间 | NOT NULL | E-SRC: GL总账进化实施规格.md §1 |

---

## 关键索引

| 索引 | 字段 | 用途 | 类型 |
|---|---|---|---|
| IX_Voucher_AccountBook | FAccountBookID | 按账簿查询凭证 | 普通索引 |
| IX_Voucher_Date | FDate | 按日期范围查询凭证 | 普通索引 |
| IX_Voucher_No | FVoucherNo | 按凭证号精确查询 | 唯一索引 |
| IX_VoucherEntry_Voucher | FVoucherID | 查询凭证的所有分录 | 普通索引 |
| IX_VoucherEntry_Account | FAccountID | 按科目查询分录 | 普通索引 |
| IX_BV_SourceBill | FSourceBillID, FSourceFormID | 从业务单据联查凭证 | 普通索引 |
| IX_BV_Voucher | FVoucherID | 从凭证查询业务来源 | 普通索引 |
| IX_Contract_SourceBill | FSourceBillID, FStatus | 查询业务单据的契约 | 唯一索引（仅对活跃契约） |
| IX_Balance_AccountPeriod | FACCOUNTID, FPeriodID | 查询科目的期间余额 | 唯一索引 |
| IX_Balance_BookPeriod | FAccountBookID, FPeriodID | 按账簿和期间查询余额 | 普通索引 |
| IX_Period_Book | FAccountBookID, FYear, FPeriod | 按账簿年度月份查询期间 | 普通索引 |

---

## 数据关系

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           GL总账数据关系图                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────┐                                                  │
│  │  BD_AccountBook   │  账簿                                          │
│  │  (FAccountBookID) │                                                  │
│  └───────┬──────────┘                                                  │
│          │                                                              │
│    ┌─────┼─────┬─────────────────────┐                                │
│    ▼     ▼     ▼                     ▼                                │
│ ┌──────┐ ┌──────────┐ ┌──────────────────┐                           │
│ │ 期间  │ │  凭证    │ │ 科目余额          │                           │
│ │  N   │ │  N       │ │ N                 │                           │
│ └──────┘ └────┬─────┘ └──────┬───────────┘                           │
│              │               │                                         │
│              │        ┌──────┴───────┐                                │
│              │        │  凭证分录     │                                │
│              │        │  N           │                                │
│              │        └──────┬───────┘                                │
│              │               │                                         │
│              │        ┌──────┴───────┐                                │
│              │        │  业务凭证映射 │                                │
│              │        │  N           │                                │
│              │        └──────┬───────┘                                │
│              │               │                                         │
│              │        ┌──────┴───────┐                                │
│              │        │  确认契约     │                                │
│              │        │  (EVO-E新增) │                                │
│              │        └──────────────┘                                │
│              │                                                           │
│  ┌───────────┴───────────┐                                             │
│  │   BD_AccountSystem    │  科目体系                                    │
│  └───────────┬───────────┘                                             │
│              │                                                          │
│              ▼                                                          │
│  ┌──────────────────┐                                                  │
│  │   BD_Account      │  会计科目                                       │
│  │  (FAccountID)    │                                                  │
│  └──────────────────┘                                                  │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 领域模型分析

### 聚合根识别

| 聚合根 | 聚合内实体 | 说明 |
|---|---|---|
| **凭证聚合** | GL_VOUCHER（根）、GL_VOUCHERENTRY（成员） | 凭证及其分录是不可分割的整体，删除凭证必须级联删除分录 |
| **账簿聚合** | BD_AccountBook（根） | 账簿是财务边界的聚合根，科目余额、凭证都引用账簿 |
| **科目聚合** | BD_Account（根） | 科目树的根，科目之间的关系通过FParentID自关联 |
| **期间聚合** | BD_FiscalPeriod（根） | 期间的打开/关闭状态由账簿控制 |

### 值对象识别

| 值对象 | 字段 | 说明 |
|---|---|---|
| 凭证号 | FVoucherNo | 不可变，凭证创建后永不修改 |
| 凭证日期 | FDate | 决定凭证属于哪个期间 |
| 借贷金额 | FDebit, FCredit | 分录的金额属性 |

### 领域事件

| 事件 | 触发时机 | 处理逻辑 |
|---|---|---|
| VoucherCreatedEvent | 凭证保存成功 | 触发凭证号生成、业务单据状态更新 |
| VoucherAuditedEvent | 凭证审核成功 | 允许过账、发送通知 |
| VoucherPostedEvent | 凭证过账成功 | 更新AccountBalance、更新业务单据钩稽状态 |
| VoucherVoidedEvent | 凭证作废 | 回滚AccountBalance、更新映射表状态 |
| ContractProposedEvent | 业务单据审核 | 创建确认契约 |
| ContractConfirmedEvent | 凭证生成成功 | 确认契约、更新业务单据状态 |
| ContractExpiredEvent | 契约超时 | 发送通知、取消契约 |

---

## 模板字段对照表

| 模板要求字段 | 实际输出 | 状态 |
|---|---|---|
| 核心表结构 | ✅ 8张表，含字段/类型/约束 | 完整 |
| 业务含义标注 | ✅ 每字段均有业务含义说明 | 完整 |
| 主键/外键约束 | ✅ 每字段均标注约束类型 | 完整 |
| 关键索引 | ✅ 11个索引，含用途说明 | 完整 |
| 数据关系图 | ✅ ASCII关系图 | 完整 |
| 聚合根/值对象 | ✅ 4个聚合根+3个值对象 | 完整 |
| 领域事件 | ✅ 7个领域事件 | 完整 |
| 与DA3 REL一致 | ✅ 数据关系与DA3 REL保持一致 | 完整 |
| 全面性检查清单 | ✅ 5项全部通过 | 完整 |
| 模板加载记录 | ✅ 本文档 | 已执行 |
