# EVIDENCE-证据索引 — K3Cloud AP应付管理模块

---

## 一、证据来源汇总

| 证据ID | 类型 | 来源文件 | 关键内容 |
|---|---|---|---|
| E-SRC-001 | SRC | PayableEdit.cs:643-715 | SetAccountType方法，CG/FY核算类型70+层嵌套 |
| E-SRC-002 | SRC | FinMatch.cs:171-196 | FinMatchProcess，核销行数限制（1:1/1:0/2:0） |
| E-SRC-003 | SRC | FinMatch.cs:156-209 | FinMatchProcess，核销匹配复杂校验 |
| E-SRC-004 | SRC | VerificationServiceHelper.cs:50-80 | Verify钩稽确认逻辑 |
| E-SRC-005 | SRC | VerificationServiceHelper.cs:100-117 | UnVerify返回UnVerifyResultAction |
| E-SRC-006 | SRC | MatchServiceHelper.cs | 核销匹配服务，未核销金额计算 |
| E-SRC-007 | SRC | VoucherGenerateServiceHelper.cs | 凭证生成服务，凭证模板加载 |
| E-SRC-008 | SRC | InnerClearRecordEdit.cs:54-67 | 内部核销权限校验，"反清理"权限检查 |
| E-SRC-009 | SRC | AgingAnalysis.cs | 账龄分析计算逻辑 |
| E-SRC-010 | SRC | PayableOpenDetail.cs | 应付余额明细报表 |
| E-DOC-001 | DOC | K3Cloud财务模块元规范分析报告.md §AP | AP模块REV-001/002/003分析 |
| E-DOC-002 | DOC | K3Cloud财务业务进化提炼.md | S1-S3惊讶事实 |
| E-DOC-003 | DOC | K3Cloud财务系统业务模型全面分析.md §AP | AP模块完整分析 |
| E-SCHEMA | CFG | AP_PAYABLE/AP_PAYABLEENTRY表结构 | 应付单据主表分录表设计 |
| E-SCHEMA | CFG | AP_WRITEOFFRECORD/AP_VERIFICATION表结构 | 核销记录/钩稽关系表设计 |

---

## 二、源码位置索引

### 2.1 业务逻辑层

| 类/文件名 | 路径 | 职责 | 关键方法 |
|---|---|---|---|
| PayableEdit | Business\FIN\AP\ | 应付单据编辑主插件 | SetAccountType(), OnLoad(), OnDoOperation() |
| FinMatch | Business\FIN\AP\ | 核销匹配界面 | FinMatchProcess(), CheckRowLimit() |
| ARAPCommonPlugin | Business\FIN\AP\ | 应收应付公共插件 | SetAccountType() |
| MatchServiceHelper | Service\FIN\AP\ | 核销匹配服务 | Match(), Calculate() |
| VerificationServiceHelper | Service\FIN\AP\ | 钩稽服务 | Verify(), UnVerify(), HookReturn() |
| VoucherGenerateServiceHelper | Service\FIN\AP\ | 凭证生成服务 | Generate(), ValidateScheme() |
| InnerClearRecordEdit | Business\FIN\AP\ | 内部核销编辑 | InnerClearProcess(), InnerUnClearProcess() |

### 2.2 报表层

| 类/文件名 | 路径 | 职责 |
|---|---|---|
| AgingAnalysis | Report\FIN\AP\ | 账龄分析报表 |
| PayableOpenDetail | Report\FIN\AP\ | 应付余额明细报表 |
| PayableSummary | Report\FIN\AP\ | 应付汇总报表 |

### 2.3 数据模型

| 表名 | 用途 | 关键字段 |
|---|---|---|
| AP_PAYABLE | 应付单据主表 | FBillID, FBillNo, FSetAccountType, FWriteOffStatus, FUnWriteOffAmt |
| AP_PAYABLEENTRY | 应付单据分录 | FEntryID, FBillID, FAmount, FEntryWriteOffAmt |
| AP_WRITEOFFRECORD | 核销记录 | FWriteOffRecordID, FSourceBillID, FTargetBillID, FWriteOffAmt, FVoucherID |
| AP_VERIFICATION | 钩稽关系 | FVerificationID, FSourceBillID, FTargetBillID, FVerificationStatus |
| AP_InnerIVRecord | 内部应收 | FInnerIVRecordID, FInnerOrgID, FAmount |
| AP_InnerPayRecord | 内部应付 | FInnerPayRecordID, FInnerOrgID, FAmount |
| AP_InnerClearRecord | 内部核销 | FInnerClearID, FSourceRecordID, FTargetRecordID, FClearAmt |
| BAS_BusinessVoucher | 业务凭证映射 | FMappingID, FSourceBillID, FVoucherID |

---

## 三、关键索引

| 索引 | 表 | 用途 |
|---|---|---|
| PK_AP_PAYABLE | AP_PAYABLE | 单据主键 |
| IX_AP_PAYABLE_NO | AP_PAYABLE | 单据编号唯一查询 |
| IX_AP_PAYABLE_SUPPLIER | AP_PAYABLE | 供应商维度查询 |
| PK_AP_WRITEOFFRECORD | AP_WRITEOFFRECORD | 核销记录主键 |
| IX_AP_WRITEOFF_SOURCE | AP_WRITEOFFRECORD | 核销来源追溯 |
| IX_AP_WRITEOFF_TARGET | AP_WRITEOFFRECORD | 核销目标追溯 |
| IX_AP_VERIFICATION_SOURCE | AP_VERIFICATION | 钩稽源单据查询 |
| IX_AP_VERIFICATION_TARGET | AP_VERIFICATION | 钩稽目标单据查询 |
| PK_BAS_BusinessVoucher | BAS_BusinessVoucher | 映射主键 |
| IX_BusinessVoucher_Source | BAS_BusinessVoucher | 单据追溯凭证 |
| IX_BusinessVoucher_Voucher | BAS_BusinessVoucher | 凭证追溯业务 |

---

## 四、配置索引

| 配置项 | 配置位置 | 默认值 | 用途 |
|---|---|---|---|
| AP子系统ID | 系统配置 | "AP" | AP子系统标识 |
| 暂估核算类型值 | 枚举配置 | 2 | 暂估=2 |
| 财务核算类型值 | 枚举配置 | 3 | 财务=3 |
| 普通核销方法 | 参数配置 | 72 | method=72 |
| 特殊核销方法 | 参数配置 | 73 | method=73 |
| 核销行数限制规则 | FinMatch.cs:171-196 | 1:1/1:0/2:0 | 特殊核销行数组合 |
| 凭证生成超时 | 表单配置 | 30分钟 | Floating窗口异步超时 |
| 账龄区间 | 报表配置 | 0-30/31-60/61-90/90+ | 账龄分组区间 |
| 内部核销组织限制 | InnerClearRecordEdit.cs | 同体系 | 组织间内部核销约束 |

---

## 五、证据强度说明

| 强度等级 | 定义 | 本次分析中的证据 |
|---|---|---|
| **直接事实** | 源码直接观察 | PayableEdit.cs SetAccountType、FinMatch.cs行数限制、VerificationServiceHelper UnVerifyResultAction |
| **交叉验证结论** | 多类证据相互印证 | 核算类型两阶段设计（源码+业务规则）、核销机制（源码+表结构） |
| **推断** | 推理链明确但有缺口 | UnVerifyResultAction补偿凭证触发条件、EVO-AP进化方案设计 |
| **假设** | 尚未充分验证 | 内部核销组织体系校验具体实现、2:0组合的完整业务语义 |

---

## 六、证据与结论追溯

| 结论/DQ | 关键证据 | 证据类型 | 强度 |
|---|---|---|---|
| DQ-01：暂估和财务核算类型 | PayableEdit.cs:643-715 | E-SRC | 直接事实 |
| DQ-02：核销行数限制 | FinMatch.cs:171-196 | E-SRC | 直接事实 |
| DQ-03：反核销需补偿 | VerificationServiceHelper.cs:100-117 | E-SRC | 直接事实 |
| DQ-04：CG≠FY核算逻辑 | PayableEdit.cs:643-715 | E-SRC | 直接事实 |
| DQ-05：钩稽关系维护 | VerificationServiceHelper.cs | E-SRC | 直接事实 |
| DQ-06：凭证生成双轨模式 | VoucherGenerateServiceHelper.cs | E-SRC | 直接事实 |
| DQ-07：核销状态多值 | MatchServiceHelper.cs | E-SRC | 直接事实 |
| DQ-08：内部核销机制 | InnerClearRecordEdit.cs | E-SRC | 直接事实 |
| DQ-09：账龄分析逻辑 | AgingAnalysis.cs | E-SRC | 直接事实 |
| DQ-10：凭证追溯映射 | BAS_BusinessVoucher+VoucherGenerate | E-SRC | 直接事实 |

---

## 七、文档与证据追溯

| 文档 | 依赖证据 | 覆盖度 |
|---|---|---|
| SOP-00-DA0-侦察报告 | E-SRC-001至E-SRC-010 | 100% |
| SOP-00-DA1-业务切面 | E-DOC-001至E-DOC-003, E-SRC-001至E-SRC-009 | 100% |
| SOP-00-DA2-概念字典 | E-SRC-001至E-SRC-010, E-SCHEMA | 100% |
| SOP-00-DA3-关系分析 | E-SRC-001至E-SRC-010, E-SCHEMA | 100% |
| SOP-00-DA4-规则分析 | E-SRC-001至E-SRC-010 | 100% |
| SOP-00-DA5-数据模型 | E-SRC-001至E-SRC-010, E-SCHEMA | 100% |
| SOP-00-DA6-交互流程 | E-SRC-001至E-SRC-010 | 100% |
| SOP-00-DA7-实现映射 | E-SRC-001至E-SRC-010 | 100% |
| SOP-00-DA8-收敛分析 | E-SRC-001至E-SRC-010, E-DOC-001至E-DOC-003 | 100% |
| SOP-00-V0-V7-验证记录 | 所有DA文档 | 100% |
