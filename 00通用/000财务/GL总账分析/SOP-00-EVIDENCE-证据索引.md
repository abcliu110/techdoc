# 证据索引 — K3Cloud GL总账模块

---

## 一、证据来源汇总

| 证据ID | 类型 | 来源文件 | 关键内容 |
|---|---|---|---|
| E-SRC-001 | SRC | VoucherGenerateService.cs:88 | Floating窗口异步模式 |
| E-SRC-002 | SRC | ViewGlVoucher.cs:37-50 | 两级权限降级逻辑 |
| E-SRC-003 | SRC | ReportFilterCommonFunction.cs:1023 | GetNextEntrySchemeId方法 |
| E-SRC-004 | SRC | ViewGlVoucher.cs | BAS_BusinessVoucher多对多映射 |
| E-SRC-005 | SRC | VoucherController | Save/Audit/UnAudit/Post方法 |
| E-SRC-006 | SRC | GeneralLedger.cs:30 | 方案ID耗尽值为-1 |
| E-DOC-001 | DOC | GL总账进化实施规格.md §1 | 确认契约模式设计 |
| E-DOC-002 | DOC | GL总账进化实施规格.md §2 | 钩稽关系状态机设计 |
| E-DOC-003 | DOC | GL总账进化实施规格.md §3 | 会话状态显式化设计 |
| E-DOC-004 | DOC | GL总账进化实施规格.md §4 | 财务责任边界显式化 |
| E-DOC-005 | DOC | 快速参考卡.md | 核心类映射和配置 |
| E-SCHEMA | CFG | GL_VOUCHER/GL_VOUCHERENTRY表结构 | 凭证表头分录分离设计 |

---

## 二、源码位置索引

### 2.1 业务逻辑层

| 类/文件名 | 路径 | 职责 |
|---|---|---|
| VoucherController | Business\FIN\GL\ | 凭证管理主控制器 |
| VoucherService | Business\FIN\GL\ | 凭证业务服务 |
| VoucherGenerateService | Business\FIN\GL\ | 凭证生成服务（Floating窗口） |
| ViewGlVoucher | Business\FIN\GL\ | 凭证联查视图 |
| GeneralLedger | GL.Report.PlugIn.BillReport | 总账报表 |
| SubLedger | GL.Report.PlugIn.BillReport | 明细账报表 |
| AccountBalance | GL.Report.PlugIn.BillReport | 余额表报表 |
| VoucherSummary | GL.Report.PlugIn.BillReport | 凭证汇总表 |
| ReportFilterCommonFunction | GL.Report.PlugIn | 报表过滤与钻取 |

### 2.2 数据模型

| 表名 | 用途 | 关键字段 |
|---|---|---|
| GL_VOUCHER | 凭证表头 | FVoucherID, FVoucherNo, FBookID, FDocumentStatus |
| GL_VOUCHERENTRY | 凭证分录 | FVoucherEntryID, FVoucherID, FAccountID, FDebit, FCredit |
| BAS_BusinessVoucher | 业务凭证映射 | FMappingID, FSourceBillType, FSourceBillID, FVoucherID, FVoucherEntryID |
| BD_AccountBook | 账簿 | FBookID, FName, FOrgID, FAccountSystemID |
| BD_Account | 会计科目 | FAccountID, FAccountCode, FAccountName, FBalanceDirection |
| BD_FiscalPeriod | 会计期间 | FPeriodID, FYear, FMonth, FStatus |
| AccountBalance | 科目余额 | FBalanceID, FBookID, FAccountID, FPeriodID, FDimension... |
| GL_ConfirmationContract | 确认契约（EVO-E） | FContractID, FSourceBillID, FVoucherID, FStatus |

### 2.3 关键索引

| 索引 | 表 | 用途 |
|---|---|---|
| PK_GL_VOUCHER | GL_VOUCHER | 凭证主键 |
| IX_GL_VOUCHER_NO | GL_VOUCHER | 凭证号唯一约束 |
| IX_GL_VOUCHERENTRY_VOUCHER | GL_VOUCHERENTRY | 分录→凭证外键 |
| PK_BAS_BusinessVoucher | BAS_BusinessVoucher | 映射主键 |
| IX_BusinessVoucher_Source | BAS_BusinessVoucher | 业务单据→映射索引 |
| IX_BusinessVoucher_Voucher | BAS_BusinessVoucher | 凭证→映射索引 |
| PK_AccountBalance | AccountBalance | 余额主键 |
| IX_AccountBalance_Query | AccountBalance | 余额查询索引 |

---

## 三、配置索引

| 配置项 | 配置位置 | 默认值 | 用途 |
|---|---|---|---|
| GL子系统ID | 系统配置 | "GL" | GL子系统标识 |
| GL_VOUCHER权限项ID | 权限配置 | 6e44119a58cb4a8e86f6c385e14a17ad | 凭证查看权限 |
| 凭证号格式 | 账簿配置 | {凭证字}-{年份}-{序号} | 凭证号生成规则 |
| 凭证状态枚举 | 枚举配置 | 0=保存,1=已审核,2=已过账 | 凭证状态流转 |
| 科目编码规则 | 科目体系 | 4-2-2-2-... | 科目级次编码 |
| 汇率精度 | 系统配置 | 6位小数 | 外币折算精度 |
| 金额精度 | 系统配置 | 6位小数 | 金额字段精度 |
| 方案ID初始值 | 用户参数表 | 0 | 钻取方案ID起点 |
| 方案ID耗尽值 | 用户参数表 | -1 | 钻取终止标志 |
| 异步窗口超时 | 表单配置 | 30分钟 | 凭证生成契约超时 |

---

## 四、证据强度说明

| 强度等级 | 定义 | 本次分析中的证据 |
|---|---|---|
| **直接事实** | 源码直接观察 | VoucherGenerateService.cs、ViewGlVoucher.cs、ReportFilterCommonFunction.cs |
| **交叉验证结论** | 多类证据相互印证 | 表头分录分离设计（源码+表结构）、多对多映射（源码+业务规则） |
| **推断** | 推理链明确但有缺口 | AccountBalance计算时机（U-03）、凭证审核完整事件链（U-05） |
| **假设** | 尚未充分验证 | EVO-E-GL-001B/002A/003/004为设计态方案，需源码验证 |

---

## 五、证据与结论追溯

| 结论/DQ | 关键证据 | 证据类型 | 强度 |
|---|---|---|---|
| DQ-01：异步Floating窗口导致双向盲区 | VoucherGenerateService.cs:88 | E-SRC | 直接事实 |
| DQ-02：两级权限降级 | ViewGlVoucher.cs:37-50 | E-SRC | 直接事实 |
| DQ-03：方案ID状态机 | ReportFilterCommonFunction.cs:1023 | E-SRC | 直接事实 |
| DQ-04：多对多映射设计 | ViewGlVoucher.cs | E-SRC | 直接事实 |
| DQ-05：钩稽状态管理 | GL总账进化实施规格.md §2 | E-DOC | 推断（设计态） |
| DQ-06：责任边界不重合 | ViewGlVoucher.cs | E-SRC | 直接事实 |
| DQ-07：表头分录分离 | GL_VOUCHER+ENTRY表结构 | E-SCHEMA | 交叉验证 |
| DQ-08：余额预计算 | AccountBalance表设计 | E-SCHEMA | 交叉验证 |
| DQ-09：确认契约 | GL总账进化实施规格.md §1 | E-DOC | 推断（设计态） |
| DQ-10：会话状态显式化 | GL总账进化实施规格.md §3 | E-DOC | 推断（设计态） |
