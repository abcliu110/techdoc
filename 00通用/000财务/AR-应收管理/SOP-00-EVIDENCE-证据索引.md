# EVIDENCE-证据索引 — K3Cloud AR应收管理模块

---

## 一、证据来源汇总

| 证据ID | 类型 | 来源文件 | 关键内容 |
|---|---|---|---|
| E-SRC-001 | SRC | ARReceivableEdit.cs | SetAccountType方法，SA/其他核算类型70+层嵌套 |
| E-SRC-002 | SRC | ARFinMatch.cs:171-196 | FinMatchProcess，核销行数限制（1:1/1:0/2:0） |
| E-SRC-003 | SRC | ARFinMatch.cs:156-209 | FinMatchProcess，核销匹配复杂校验 |
| E-SRC-004 | SRC | VerificationServiceHelper.cs:50-80 | Verify钩稽确认逻辑（与AP共用） |
| E-SRC-005 | SRC | VerificationServiceHelper.cs:100-117 | UnVerify返回UnVerifyResultAction（与AP共用） |
| E-SRC-006 | SRC | MatchServiceHelper.cs | 核销匹配服务，未核销金额计算（与AP共用） |
| E-SRC-007 | SRC | VoucherGenerateServiceHelper.cs | 凭证生成服务，凭证模板加载（与AP共用） |
| E-SRC-008 | SRC | ARInnerIVSpecialMatchEdit.cs | 内部应收核销，InnerIVProcess() |
| E-SRC-009 | SRC | InnerClearServiceHelper.cs | 内部核销服务，Clear/UnClear（与AP共用） |
| E-SRC-010 | SRC | BillRecReport.cs | 收付款认领，自动匹配算法（AR独有） |
| E-SRC-011 | SRC | ReceivableBillReport.cs | 账龄分析，AgingCalculate() |
| E-SRC-012 | SRC | ReceivableBillBalRpt.cs | 应收余额明细报表 |
| E-SRC-013 | SRC | ARReceivableList.cs | 应收单列表，Filter() |
| E-SRC-014 | SRC | ARReceivableEdit.cs | 应收单编辑主插件，OnLoad() |
| E-DOC-001 | DOC | K3Cloud财务模块元规范分析报告.md §AR | AR模块REV-001/002/003分析 |
| E-DOC-002 | DOC | K3Cloud财务业务进化提炼.md | S1-S3惊讶事实 |
| E-DOC-003 | DOC | K3Cloud财务系统业务模型全面分析.md §AR | AR模块完整分析 |
| E-SCHEMA | CFG | AR_RECEIVABLE/AR_RECEIVABLEENTRY表结构 | 应收单据主表分录表设计 |
| E-SCHEMA | CFG | AR_WRITEOFFRECORD/AR_VERIFICATION表结构 | 核销记录/钩稽关系表设计 |
| E-SCHEMA | CFG | AR_InnerIVRecord/AR_InnerAPRecord表结构 | 内部核销表设计 |

---

## 二、源码位置索引

### 2.1 业务逻辑层

| 类/文件名 | 路径 | 职责 | 关键方法 |
|---|---|---|---|
| ARReceivableEdit | Business\FIN\AR\ | 应收单据编辑主插件 | SetAccountType(), OnLoad(), OnDoOperation() |
| ARReceivableList | Business\FIN\AR\ | 应收单列表插件 | PageLoad(), Filter() |
| ARFinMatch | Business\FIN\AR\ | 核销匹配界面 | FinMatchProcess(), CheckRowLimit() |
| ARInnerIVSpecialMatchEdit | Business\FIN\AR\ | AR内部特殊匹配编辑 | InnerMatchProcess(), InnerIVProcess() |
| MatchServiceHelper | Service\FIN\AR\（与AP共用） | 核销匹配服务 | Match(), Calculate() |
| VerificationServiceHelper | Service\FIN\AR\（与AP共用） | 钩稽服务 | Verify(), UnVerify(), HookReturn() |
| VoucherGenerateServiceHelper | Service\FIN\AR\（与AP共用） | 凭证生成服务 | Generate(), ValidateScheme() |
| InnerClearServiceHelper | Service\FIN\AR\（与AP共用） | 内部核销服务 | Clear(), UnClear() |

### 2.2 报表层

| 类/文件名 | 路径 | 职责 |
|---|---|---|
| BillRecReport | Report\FIN\AR\ | 收付款认领报表（AR独有） |
| ReceivableBillReport | Report\FIN\AR\ | 应收账龄分析报表 |
| ReceivableBillBalRpt | Report\FIN\AR\ | 应收余额明细报表 |
| ReceivableSumReport | Report\FIN\AR\ | 应收汇总报表 |

### 2.3 数据模型

| 表名 | 用途 | 关键字段 |
|---|---|---|
| AR_RECEIVABLE | 应收单据主表 | FBillID, FBillNo, FSetAccountType, FWriteOffStatus, FUnWriteOffAmt, FCustomerID |
| AR_RECEIVABLEENTRY | 应收单据分录 | FEntryID, FBillID, FAmount, FEntryWriteOffAmt |
| AR_WRITEOFFRECORD | 核销记录 | FWriteOffRecordID, FSourceBillID, FTargetBillID, FWriteOffAmt, FVoucherID |
| AR_VERIFICATION | 钩稽关系 | FVerificationID, FSourceBillID, FTargetBillID, FVerificationStatus |
| AR_InnerIVRecord | 内部应收 | FInnerIVRecordID, FInnerOrgID, FAmount |
| AR_InnerAPRecord | 内部应付（AR侧） | FInnerAPRecordID, FInnerOrgID, FAmount |
| BAS_BusinessVoucher | 业务凭证映射 | FMappingID, FSourceBillID, FVoucherID |

---

## 三、关键索引

| 索引 | 表 | 用途 |
|---|---|---|
| PK_AR_RECEIVABLE | AR_RECEIVABLE | 单据主键 |
| IX_AR_RECEIVABLE_NO | AR_RECEIVABLE | 单据编号唯一查询 |
| IX_AR_RECEIVABLE_CUSTOMER | AR_RECEIVABLE | 客户维度查询 |
| PK_AR_WRITEOFFRECORD | AR_WRITEOFFRECORD | 核销记录主键 |
| IX_AR_WRITEOFF_SOURCE | AR_WRITEOFFRECORD | 核销来源追溯 |
| IX_AR_WRITEOFF_TARGET | AR_WRITEOFFRECORD | 核销目标追溯 |
| IX_AR_VERIFICATION_SOURCE | AR_VERIFICATION | 钩稽源单据查询 |
| IX_AR_VERIFICATION_TARGET | AR_VERIFICATION | 钩稽目标单据查询 |
| PK_BAS_BusinessVoucher | BAS_BusinessVoucher | 映射主键 |
| IX_BusinessVoucher_Source | BAS_BusinessVoucher | 单据追溯凭证 |
| IX_BusinessVoucher_Voucher | BAS_BusinessVoucher | 凭证追溯业务 |

---

## 四、配置索引

| 配置项 | 配置位置 | 默认值 | 用途 |
|---|---|---|---|
| AR子系统ID | 系统配置 | "AR" | AR子系统标识 |
| 暂收核算类型值 | 枚举配置 | 2 | 暂收=2 |
| 财务核算类型值 | 枚举配置 | 3 | 财务=3 |
| 普通核销方法 | 参数配置 | 72 | method=72 |
| 特殊核销方法 | 参数配置 | 73 | method=73 |
| 核销行数限制规则 | ARFinMatch.cs:171-196 | 1:1/1:0/2:0 | 特殊核销行数组合 |
| 凭证生成超时 | 表单配置 | 30分钟 | Floating窗口异步超时 |
| 账龄区间 | 报表配置 | 0-30/31-60/61-90/90+ | 账龄分组区间 |
| 内部核销组织限制 | ARInnerIVSpecialMatchEdit.cs | 同体系 | 组织间内部核销约束 |

---

## 五、证据强度说明

| 强度等级 | 定义 | 本次分析中的证据 |
|---|---|---|
| **直接事实** | 源码直接观察 | ARReceivableEdit.cs SetAccountType、ARFinMatch.cs行数限制、VerificationServiceHelper UnVerifyResultAction |
| **交叉验证结论** | 多类证据相互印证 | 核算类型两阶段设计（源码+业务规则）、核销机制（源码+表结构）、AR-AP镜像验证 |
| **推断** | 推理链明确但有缺口 | UnVerifyResultAction补偿凭证触发条件、EVO-AR进化方案设计、BillRecReport自动匹配算法 |
| **假设** | 尚未充分验证 | 内部核销组织体系校验具体实现、2:0组合的完整业务语义、认领与核销转换边界 |

---

## 六、证据与结论追溯

| 结论/DQ | 关键证据 | 证据类型 | 强度 |
|---|---|---|---|
| DQ-01：暂收和财务核算类型 | ARReceivableEdit.cs SetAccountType | E-SRC | 直接事实 |
| DQ-02：核销行数限制 | ARFinMatch.cs:171-196 | E-SRC | 直接事实 |
| DQ-03：反核销需补偿 | VerificationServiceHelper.cs:100-117 | E-SRC | 直接事实 |
| DQ-04：SA≠其他核算逻辑 | ARReceivableEdit.cs SetAccountType | E-SRC | 直接事实 |
| DQ-05：钩稽关系维护 | VerificationServiceHelper.cs | E-SRC | 直接事实 |
| DQ-06：凭证生成双轨模式 | VoucherGenerateServiceHelper.cs | E-SRC | 直接事实 |
| DQ-07：核销状态多值 | MatchServiceHelper.cs | E-SRC | 直接事实 |
| DQ-08：内部核销机制 | ARInnerIVSpecialMatchEdit.cs | E-SRC | 直接事实 |
| DQ-09：收付款认领机制 | BillRecReport.cs | E-SRC | 推断 |
| DQ-10：账龄分析逻辑 | ReceivableBillReport.cs | E-SRC | 直接事实 |

---

## 七、文档与证据追溯

| 文档 | 依赖证据 | 覆盖度 |
|---|---|---|
| SOP-00-DA0-侦察报告 | E-SRC-001至E-SRC-014, E-DOC-001至E-DOC-003 | 100% |
| SOP-00-DA1-业务切面 | E-DOC-001至E-DOC-003, E-SRC-001至E-SRC-011 | 100% |
| SOP-00-DA2-概念字典 | E-SRC-001至E-SRC-014, E-SCHEMA | 100% |
| SOP-00-DA3-关系分析 | E-SRC-001至E-SRC-014, E-SCHEMA | 100% |
| SOP-00-DA4-规则分析 | E-SRC-001至E-SRC-014 | 100% |
| SOP-00-DA5-数据模型 | E-SRC-001至E-SRC-014, E-SCHEMA | 100% |
| SOP-00-DA6-交互流程 | E-SRC-001至E-SRC-014 | 100% |
| SOP-00-DA7-实现映射 | E-SRC-001至E-SRC-014 | 100% |
| SOP-00-DA8-收敛分析 | E-SRC-001至E-SRC-014, E-DOC-001至E-DOC-003 | 100% |
| SOP-00-V0-V7-验证记录 | 所有DA文档 | 100% |

---

## 八、AR独有证据（vs AP）

| 证据ID | 功能 | AR独有性 | AP对应 |
|---|---|---|---|
| E-SRC-008 | ARInnerIVSpecialMatchEdit.cs | AR内部应收核销 | AP有InnerClearRecordEdit |
| E-SRC-010 | BillRecReport.cs | 收付款认领报表 | 无对应 |
| E-SRC-011 | ReceivableBillReport.cs | 应收账龄分析 | AP有AgingAnalysis |
| E-SRC-012 | ReceivableBillBalRpt.cs | 应收余额明细 | AP有PayableOpenDetail |
| E-SRC-013 | ARReceivableList.cs | 应收单列表 | AP有PayableList |
| E-SRC-014 | ARReceivableEdit.cs | 应收单编辑 | AP有PayableEdit |
