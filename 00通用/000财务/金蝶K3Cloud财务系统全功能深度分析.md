# 金蝶 K3Cloud 财务(FIN)系统 · 全功能与设计深度分析

> **文档类型**：源码逆向分析 / 财务领域知识总结
> **分析对象**：金蝶 K3Cloud（云星空）财务模块反编译源码（`Business/FIN/`，376 个 C# 文件，约 12.6 万行）
> **配套章节**：五张业务流程图（见文末附章）
> **配套理论文档**：[《财务系统高维抽象理论.md》](./财务系统高维抽象理论.md)（同目录，抽象理论层：事件溯源/守恒律/维度立方体/时间轴等）
> **版本**：v1.0 | 2026-08

---

## 目录

1. [财务系统全景](#1-财务系统全景)
2. [源码边界与功能地图](#2-源码边界与功能地图)
3. [基础配置域：账簿/期间/科目/参数/权限](#3-基础配置域账簿期间科目参数权限)
4. [往来管理域：应收应付(AP/AR)](#4-往来管理域应收应付apar)
5. [现金银行与资金域(CN)+网银](#5-现金银行与资金域cn网银)
6. [总账域(GL)](#6-总账域gl)
7. [成本核算域](#7-成本核算域)
8. [电子税务与发票域](#8-电子税务与发票域)
9. [财务服务中枢：26 个 ServiceHelper](#9-财务服务中枢26-个-servicehelper)
10. [跨域集成与机器人](#10-跨域集成与机器人)
11. [财务知识要点速查表](#11-财务知识要点速查表)
12. [边界、风险与二次开发启示](#12-边界风险与二次开发启示)
13. [附：五张业务流程图](#附五张业务流程图)

---

## 1. 财务系统全景

### 1.1 模块定位

K3Cloud 财务模块（FIN）是集团的**账务中枢**：承接供应链(SCM)/制造(MFG)的业务结果，经"凭证化 → 过账 → 账簿 → 结账"沉淀为会计信息，同时承载往来（应收应付）、资金（现金银行/网银）、成本核算、电子发票等专业财务职能。

### 1.2 源码构成（376 文件 / 12.6 万行）

| 工程 | 文件数 | 内容 |
|---|---|---|
| `01.Core/Kingdee.K3.FIN.ServiceHelper` | 31 | **财务服务中枢**：账簿/期间/核销/勾稽/凭证/成本/网银/发票 |
| `01.Core/Kingdee.K3.FIN.Business.DynamicForm` | 8 | 凭证生成操作(`BuildBusinessVoucher`)、成本取数 |
| `BusinessPlugIn/…AP.Business.PlugIn` | 54 | **应收应付业务插件**：单据/核销/勾稽/清账/结账/机器人 |
| `…GL.Report.PlugIn` | 61 | **总账报表**：总账/余额/明细/多栏/现金流量 |
| `…CB.App.Report` | 39 | **成本核算报表**（实为产品成本模块） |
| `…CN.App.Report` | 27 | **现金银行**：日记账/对账/资金/票据 |
| `…AP.App.Report` / `AP.Report.PlugIn` | 32 | **往来报表**：对账/账龄/到期债务/跟踪 |

### 1.3 三条主线定位

```
业务单据(SCM/MFG) ──凭证化(Voucher)──▶ 总账(GL) ──结账──▶ 报表
        │                                  ▲
        └── 往来(AP/AR 核销勾稽) ──┬───────┘
                                └── 现金银行/网银(CN) ── 资金
   成本核算(CB) 沿着 SCM 出入库/费用做产品归集与分配
```

---

## 2. 源码边界与功能地图

### 2.1 ⚠️ 三个源码边界（阅读前必知）

1. **AR 应收几乎为空**（仅 2 个文件）——应收与应付同构设计，复用 `ARAPComonPulgin.cs` 公共插件。
2. **核心单据部分缺失**：付款单、收款单、凭证的 Edit 插件大多运行在官方元数据配置；本源码只拿到**核销/勾稽/结账插件 + 全部报表**。
3. **结账/核销落库 SQL 不在本地**：`ClosingAccountServiceHelper.APConactBalCloseAccount`、`APComonServiceHelper.FinMatchProcess` 等在官方运行时，本地只有调用方；GL/CN 报表取数表名（`T_GL_BALANCE`/`T_GL_VOUCHERENTRY`）仅能按"下钻关系"推断。

### 2.2 功能地图（整体视图）

| 功能域 | 子系统 | 承载 |
|---|---|---|
| 基础配置 | 账簿/期间/科目分配/参数/权限/启用/初始化 | CommonServiceHelper、AccountFilterServiceHelper、AccessServiceHelper、StartDate、InitOnOff |
| 往来管理 | 应收/应付、发票、核销、勾稽、清账、结账、机器人、账龄 | AP.Business.PlugIn(54)、AP.App.Report |
| 资金管理 | 现金/银行日记账、对账、调节表、资金头寸、票据、网银 | CN.App.Report、WBOpenServiceHelper、CNOpenServiceHelper |
| 总账 | 凭证生成/过账/账簿、调汇、损益结转、报表 | BuildBusinessVoucher、GL.Report.PlugIn、AdjustPeriodServiceHelper |
| 成本核算 | 成本计算单、费用归集分配、投入产出、品种法、成本分析 | CB.App.Report、CostCalServiceHelper |
| 税务发票 | 电子发票、报销 | EInvoiceServiceHelper |
| 智能自动化 | 智能结账/自动核销/自动调账 | Robot 插件族 |

---

## 3. 基础配置域：账簿/期间/科目/参数/权限

### 3.1 账簿与会计期间（CommonServiceHelper）

- **多账簿**：`GetBookInfo(bookId)` 返回账簿日历（BookCalendarInfoObject），支持一套数据多本账簿（法定/管理/税务），多币别折算。
- **当前期间**：`GetStartEndDateOfCurPeriod(bookId)` 用 `GetAccountBookCurrentPeriod` + `GetDateByYearPeriod` 算出当前期间起止日。
- **期间↔日期**：`GetDateByPeriod(acctSystemID, finOrgID, systemKey="HS")` / `(acctPolicyId, year, period)`。
- **组织结账日**：`GetOrgAcctLastCloseDate`——全局控制"哪个组织结账到哪个月"。
- **启用/反启用**：`StartDate`/`UnStartDate`/`GetOrgsWithStartDate`/`JudgeIsStartDate`（按子系统维度记录启用日）。

### 3.2 会计科目分配（AccountFilterServiceHelper）

- 多组织多账簿下按"核算组织 → 账簿"分配可用科目集：
  - `GetAvaiableAccountByAcctOrgId` 取可用科目
  - `CheckBookAcctDistribute` / `CheckActResultAcctInfo` 校验账簿科目分配
  - `GetAccountOrgIdByLevel` 按层级取核算组织

### 3.3 财务参数（SystemParameterEdit）

- 是否"勾稽必有已审核单据"（`IsClsHvNtChckBill`）。
- 是否启用**计算已实现汇兑损益**（`FRealizedExchange`）——启用后不可取消，需重建调汇单 `T_AP_ADJUSTMENTEXCHANGE`。

### 3.4 财务权限（AccessServiceHelper）

- 全流程权限点：新增 `PermissionAuthNew` / 查看 `PermissionAuthView` / 修改 `PermissionAuthModify` / 删除 `PermissionAuthDelete` / 审核 `PermissionAuthAudi` / 反审核 `PermissionAuthUnAudi` / 提交 `PermissionAuthCommit`，及批量授权 `PermissionAuthEx/ExView`。

### 3.5 开账时序（启用 → 初始化 → 结账）

```
[1] 设启用日期 StartDate(APStartDate)
[2] 结束初始化 InitOnOff(期初数据入账, InitOpenClose)
[3] 日常业务单据 → 凭证
[4] 期末结账 ClosingAccount(锁定期间)
[5] 反结账/反初始化 (可逆窗口)
```
约束：未设启用日期的组织禁止新增单据（`APCommonBillEdit.PreOpenForm`）；结账表单与初始化表单**网控互斥**。

---

## 4. 往来管理域：应收应付(AP/AR)

### 4.1 单据体系（10 个单据插件）

| 单据 | 插件 | 要点 |
|---|---|---|
| 标准应付单 | `PayableEdit.cs`(1358行) | 三态核算类别（标准/暂估/费用 `FSetAccountType`）；暂估勾稽联动 `SetHookMatch`；费用类锁出入库 `LockInOut` |
| 月末暂估应付 | `HookPayableEdit.cs` | 只控可用物料 F7 |
| 其他应付 | `OtherPayableEdit.cs` | 往来币别汇率联动、下查付款单 |
| 快捷录入 | `QuickInputPayable.cs` | 树形导航 + 列表录入 |
| 个人借款付款 | `PrivatePayDynamicBill.cs` | 按可借余额控制上限 |
| 应付开票 | `BillingSpecialEdit.cs` | 开票特殊勾稽（数量/金额双规则，MatchType=2） |
| 应付付款 | `PaySpecialEdit.cs` | 处理往来不同/尾数注销（MatchType=1） |
| 影像扫码 | `*Scan.cs`(4个) | 单据/列表扫码归档 |

### 4.2 核销/勾稽/转销完整闭环

```
核销方案 MatchSchemeEdit(匹配类型+单据对+字段)
  → 核销配置 MatchConfigEdit(用户自定义过滤字段)
  → 普通核销(匹配条件撮合)
  → 暂估核销 FinMatch.cs(左暂估应付 ↔ 右财务应付, 核销量≤未核销量)
  → 特殊核销 PaySpecialEdit/BillingSpecialEdit(异常尾数)
  → 转销 WriteOffRecordEdit + AutoWriteOffWizardEdit(跨期保护)
  → 核销记录 Match*RecordEdit(反核销)
  → 自动核销 AutoMatchStencilEdit(模板) + 机器人
```

**核心服务**（VerificationServiceHelper）：
- 借方/贷方取数：`GetDebitDynamicObj` / `GetCreditDynamicObj`
- 核销/反核销/自动核销：`VerifyData` / `UnVerifyDataById` / `AutoVerifyData`
- 核销原理：同一往来的借项与贷项互相冲减，余额归零即结清。

**核销 vs 勾稽**：勾稽是"方案 + 撮合过程"，核销是"结果记录"；先有勾稽规则，执行后生成核销记录。

### 4.3 内部清账（集团关联往来抵销）

- `AP/ARInnerSpecialMatchEdit`、`AP/ARInnerIVSpecialMatchEdit`（应付/开票内部清理）。
- `InnerClearRecordEdit` / `IVInnerClearRecordEdit`（无需付款/开票的清理记录，含反清理权限控制）。

### 4.4 结账与机器人智能结账

- **结账/反结账**（`ClosingAccountEdit.cs` 673行）：按组织推算起止期间（最近结账日 + 启用日）；结账前检查**未审核单据**与**采购入库未完全下推**（`CheckInstock`），可"调整业务日期后结账"（把单据日期改到期末+1天）；执行体在 `ClosingAccountServiceHelper.APConactBalCloseAccount`。
- **财务机器人**（`CloseAccountRobotPlugInBase.cs` 352行）：云端**对话式三步**——①列出可选结算组织（>10 取前 10）→ ②`CheckCloseAccountConditions`（期间 + 未审单 + SCM 未全下推）→ ③`CloseAccountFromRobot`。AP/AR 各一个子类（`APCloseAccountRobotPlugIn`/`ARCloseAccountRobotPlugIn`）。
- 自动化配套：`SetAdjustBillDateFormPlugIn`（批量调整未审单日期）、`UnAuditBillInfoFormPlugIn`（未审单清单）、`AdjustBillDate`（自动调账日）。

### 4.5 往来报表（AP.App.Report / AP.Report.PlugIn）

| 报表 | 服务 | 说明 |
|---|---|---|
| 应付款明细/汇总 | `APDetailReportService`/`APSumReportService` | 往来发生明细/汇总 |
| 应付未开票明细 | `IVDetailReportService` | 货到票未到的暂估 |
| **账龄分析** | `AgingAnalysisService` | 0-30 / 31-60 / 61-90 / 90+ 天分段 |
| **到期债务表** | `MaturedDebtService` | 到期/未到期天数 |
| **往来对账表** | `GoAndComReportService`(5587行) | 与客户/供应商对账明细，支持邮件发送（`ReportSendEmailPlugIn`） |
| 应付跟踪表 | `TraceService` | 单据流转跟踪 |
| 电子发票收票 | `ElectronicIVFilter` | 电子发票收票过滤 |

---

## 5. 现金银行与资金域(CN)+网银

### 5.1 日记账/流水/日报体系

| 报表 | 文件 | 取数 |
|---|---|---|
| 现金日记账 | `CashJournal` | 现金账 + 收付款流水 |
| 银行日记账 | `BankJournal` | 银行账 |
| 流水账 | `CashDetailReport`/`BankDetailReport` + `DetailReportBase` | 逐笔收付流水 |
| 日报 | `CashDailyReport`/`BankDailyReport` + `DailyDataHelper` | 批量 INSERT 临时表汇总（FastReport 模式） |

### 5.2 银行对账 / 调节表 / 资金头寸

- **期末对账** `FinalReconReport`(1533行)：账面项目与银行对账单核对，差异列 `FCNAMOUNT/FGLAMOUNT/FBALAMOUNT`。
- **余额调节表** `BalAdjustmentReport`(1032行)：`CalculateAdjustAmount` 按收付单据 + 对账单计算调节金额（未达账项）。
- **资金头寸表** `FundPositionReport`(1184行)：按结算组织/付款组织筛选，INSERT 临时表 + 小计 + 本位币小计，预测未来资金收支。

### 5.3 票据管理

- 应收票据：`ReceivableBillBalRpt`(余额)/`ReceivableBillExcReport`(执行流水)/`ReceivableBillTransactReport`(收发存明细)/`BillRecReport`(使用流水)。
- 应付票据：`PayBillBalReport`(余额)。
- 基类：`ReceivableBillReportBase`/`PayBillReportBase`。

### 5.4 银企互联/网银（WBOpenServiceHelper）

- `SubmitToBankPay` 提交银行付款、`CancelSubmitToBankPay` 撤销。
- `QueryBalanceForBankAcct` 余额查询、`DownLoadCashFlow` 下载银行流水、`SynDataFromBankBeforeSubmit` 提交前同步。
- `GetEbankServiceURL` 网银地址、`GetSendSMSForSubmitBank` 提交短信提醒。

### 5.5 期初开账（CNOpenServiceHelper）

集中查询各账户期初：`GetBalanceAmount`、`GetBankAccountBalance`、`GetCashJournalBalance`、`GetBankJournalBalance`、`GetPayBillBalance`、`GetReceivableBillBalance`、`GetEndAmountForInnerAccount`(内部账户期末)。

---

## 6. 总账域(GL)

### 6.1 凭证生成链（业务 → 总账的唯一入口）

```
业务单据(采购入库/销售出库/收付款/费用...)
  → BuildBusinessVoucher:AbstractBillOperation.MakeVoucher(pk)   // "生成凭证"操作
  → VoucherGenerateServiceHelper.BuildVoucherByScheme            // 凭证模板方案
  → BuildVoucherInfo                                            // 解析借贷行
  → 校验: 借贷平衡/科目合法/期间可开账
  → 凭证表头+分录(编号/期间/制单人)
```
辅助：`VouProduceSearchServiceHelper`(凭证生产查询)、`GlVoucherForCNServiceHelper`(出纳↔总账凭证关联)、`RecordBillVchInfoServiceHelper`(凭证信息回写)。

### 6.2 调汇与损益结转

- `AdjustPeriodServiceHelper`：**调整期间**模型——`IsAdjustPeriod`/`GetBookPeriodList`/`GetBookAdjustPeriodList`/`GetOpenAdjustPeriodByBook`；用于期末调汇（未实现汇兑损益计入财务费用）与损益结转（损益科目 → 本年利润）。
- `AllocateExchangeHistory`(调汇历史记录，含方案节点关系)。

### 6.3 总账报表家族（GL.Report.PlugIn，61 文件）

| 家族 | 报表 | 取数/下钻 |
|---|---|---|
| 总账/余额 | `GeneralLedger`/`AccountBalance`/`TrialBalance`(试算平衡) | 科目余额 + 期间发生额；下钻明细账 → 凭证(GL_VOUCHER) |
| 明细账 | `SubLedger`/`QtySubLedger`(数量金额)/`MultiColumnLedger`(多栏账) | 凭证分录(GL_VOUCHERENTRY) |
| 凭证类 | `VoucherSummary`(凭证汇总)/`SumAcctByVchDesc`(凭证摘要汇总) | 按摘要分组汇总 |
| **辅助核算** | `AccountingItemsBalance`(核算项目余额)/`SubledgerForAcctItems`/`FlexAccount`(科目+核算维度组合) | 科目余额表 + 辅助核算维度 |
| **多账簿多币别** | `MutilAccountBook`(横向多账簿余额)/`MulAcctBookFlexSummary/Subledger/Detail` | `MultiAccountBookServiceHelper` + `GL_NodeLevel` 下钻 |
| **现金流量** | `CashflowReport`/`CashflowQuery`(复算)/`CashFlowCheckReport`(勾稽检查) | 现金流量项目归集 |
| 调汇历史 | `AllocateExchangeHistory` | 展示每次调汇方案与汇率 |
| 基类 | `AbstractGLReportBasePlugIn`/`ReportFilterCommonFunction`/`PagingReportCatelogGoto` | 分页目录/公共过滤(16k行) |

---

## 7. 成本核算域

> `Kingdee.K3.FIN.CB.App.Report` 实为**产品成本核算报表**模块（重要发现）。

### 7.1 报表家族（39 文件）

| 类别 | 报表 |
|---|---|
| 成本计算单 | `CostCalBillRpt`/`CostCalBillHorizontalRpt`(期初/本期/期末列)/`CostCalHorizontalRpt`(透视)/`SFCCostCalBillRpt`(车间) |
| 耗用/入库成本 | `MaterialCostRpt`(材料耗用)/`StockInCostDetailRpt`(入库成本明细)/`BillCalCostRptBase` |
| 费用归集分配 | `ExpenseCollectionRpt`(归集)/`ExpenseCollDetailRpt`(归集源单)/`MaterialAllocResultRpt`+`NonMatAllocResultRpt`(材料/非材料分配)/`AllocStandardDataRpt`(分配标准) |
| 投入产出 | `PutInOutPutRpt`/`SFCInOutPutRpt`/`CompletionQtyRpt`(完工入库)/`WorkHoursCollRpt`(工时归集)/`MainTainWorkRpt`(作业量) |
| 品种法设置 | `InitProduceCostRpt`(期初在产品)/`EquivalCoefficientRtp`(约当系数)/`ByProductCostRpt`(副产品定额)/`CCWARelationRpt`(成本中心-作业对应) |
| 成本分析 | `OrderCostTrackRpt`(订单成本跟踪)/`SalesProfitRpt`(订单利润)/`ProductRestoreCostDiffRpt`(成本还原)/`OutSrcExpenseRpt`(委外加工费) |

### 7.2 执行引擎

- 入口：`CostCalServiceHelper.CostCalExecute(CalOption)` → `ICostCalService.CostCalExecute`。
- 存货核算：`AcctgStencilServiceHelper`——`GetCost`(材料成本)、`OutStockAcctg`(出库核算)、`SumSchedule`/`GetScheduleProgress`(计算进度)、`OutAcctgCheck`(核算检查)。
- 实时成本：`TimelyCostConfig` / `GetCostService`(BOS.DynamicForm 下)。

---

## 8. 电子税务与发票域

`EInvoiceServiceHelper`：
- 令牌：`GetAccessToken`/`ByCloudPassGetToken`。
- 发票生命周期：`PostState`(推送状态)、`UpdateEInvoiceStatus`、`SubmitExpReimInfo`(报销提交)、`BuildHttpRequest`(报文构建)。
- 与业务关联：`GetEInvoiceForPayBill`(付款单关联发票)、`GetExsitEInvoiceList`/`GetFexpidList`、`SubmitInfo`。

---

## 9. 财务服务中枢：26 个 ServiceHelper

| 服务 | 职责 |
|---|---|
| `CommonServiceHelper` | 账簿/期间/启用/结账日（全局核心） |
| `VerificationServiceHelper` | 往来核销/反核销/自动核销 |
| `MatchServiceHelper` | 勾稽方案/特殊勾稽/上网控制 |
| `VoucherGenerateServiceHelper` | 凭证生成 |
| `GlVoucherForCNServiceHelper` | 出纳↔总账凭证关联 |
| `CalculateServiceHelper` | 财务计算器 |
| `StatementServiceHelper` | 往来对账单 + 账龄表(`GetAgingTable`) |
| `CNOpenServiceHelper` | 期初开账余额 |
| `WBOpenServiceHelper` | 网银/银企互联 |
| `AccountFilterServiceHelper` | 科目分配/核算组织 |
| `CostCalServiceHelper` / `AcctgStencilServiceHelper` | 成本计算/存货核算 |
| `AdjustPeriodServiceHelper` | 调整期间(调汇) |
| `AccessServiceHelper` | 财务权限 |
| `BillOperateServiceHelper` | 提交审核 |
| `EInvoiceServiceHelper` | 电子发票 |
| `RecordBillVchInfoServiceHelper`/`VouProduceSearchServiceHelper` | 凭证信息回写/生产查询 |
| `NetControlServiceHelper` | 网控(并发锁) |
| `CheckAccountBisServiceHelper`/`OutInStockIndexServiceHelper`/`PatServerHelper`/`HS_UserParamterServiceHelper`/`WorkHoursForSFCServiceHelper`/`ExcelCsvOperationHelper` | 对账/出入库指数/补丁/用户参数/工时/导入导出 |

---

## 10. 跨域集成与机器人

- **SCM → FIN**：`SCMServiceForFIN` 提供库存关账/期初/余额/内部结算数据。
- **FIN → 总账/出纳**：收付款单生成凭证，`GlVoucherForCNServiceHelper` 关联。
- **机器人(Robot)**：智能结账(AP/AR)、自动核销、自动调账——统一 `IRobotTaskWorker` 基类。
- **扫码/影像**：单据/列表影像扫码归档。

---

## 11. 财务知识要点速查表

| 会计概念 | 系统承载 | 源码证据 |
|---|---|---|
| 会计期间/账簿 | 账簿日历服务 | `CommonServiceHelper` |
| 科目分配 | 多组织账簿科目集 | `AccountFilterServiceHelper` |
| 应收应付往来 | 应付单 + AR/AP 公共 | `PayableEdit`/`ARAPComonPulgin` |
| 核销/反核销 | 往来对冲 | `VerificationServiceHelper` |
| 勾稽方案 | 匹配撮合 | `MatchServiceHelper`/`FinMatch` |
| 暂估核算 | 三态核算类别 | `PayableEdit.SetAccountType`/`HookPayableEdit` |
| 往来清账 | 内部抵消 | `InnerClear*` |
| 凭证生成 | 业务→总账 | `BuildBusinessVoucher` |
| 调汇/损益结转 | 调整期间 | `AdjustPeriodServiceHelper` |
| 出纳日记账 | 现金/银行逐笔 | `CashJournal`/`BankJournal` |
| 银行对账 | 未达账项调节 | `FinalReconReport`/`BalAdjustmentReport` |
| 资金头寸 | 未来收支预测 | `FundPositionReport` |
| 票据 | 应收/应付票据 | `ReceivableBill*`/`PayBillBalReport` |
| 成本核算 | 归集分配还原 | `CostCal*`/`*AllocResultRpt` |
| 电子发票 | 税务对接 | `EInvoiceServiceHelper` |
| 网银 | 银企互联 | `WBOpenServiceHelper` |
| 期末结账 | 期间锁定 | `ClosingAccountEdit`/Robot |
| 账龄分析 | 往来分段 | `AgingAnalysisService` |

---

## 12. 边界、风险与二次开发启示

### 12.1 风险与注意

1. **核心账务 SQL 不可见**：结账/核销引擎在官方运行时，改动要配合官方服务或元数据配置。
2. **暂估勾稽体系**：`CheckHookMode` 贯穿应付/结账/参数，参数定义在元数据 `AP_SystemParameter`。
3. **超大单文件**：`GoAndComReportService.cs` 5,587 行（往来对账巨型 SQL）。
4. **时序强约束**：启用日期 → 初始化 → 结账日期跨系统(AP/AR/HS核算/SCM)相互引用，一处延后影响全局。
5. **报表双份**：`BusinessPlugIn/` 与 `ServicePlugIn/` 同内容各一份，改一处可能漏改另一处。
6. **金额精度**：大量 `Convert.ToDecimal` 手工转换，反编译后类型安全弱、易出运行期错误。

### 12.2 二次开发启示

- **读三件套入门**：`VerificationServiceHelper.cs`(核销) → `BuildBusinessVoucher.cs`(凭证) → `CommonServiceHelper.cs`(期间/账簿)。
- **扩展点**：核销走"方案(MatchScheme) + 字段配置(MatchConfig)"，新增勾稽规则 = 加匹配字段，不改引擎；结账/调汇走"服务 + 机器人"，自动化 = 注册 `IRobotTaskWorker`。
- **模仿最小财务系统**：先做"往来台账 + 核销配对"，再做"凭证 + 科目余额表 + 期间结账/反结账"，最后做"出纳对账";成本核算与电子发票留接口、不并进核心。

---

## 附：五张业务流程图

### 图 1 · 财务系统总览（业务 → 账务 → 报表主链路）

```
┌─────────────────────────────────────────────────────────────┐
│                   业务域 (SCM/制造)                           │
│  销售出库 采购入库 生产领料 调拨 盘点 费用报销...              │
└───────────────┬──────────────────────────────┬──────────────┘
                │ 审核过账                     │
                ▼                             ▼
   ┌──────────────────────┐      ┌──────────────────────┐
   │  SCMServiceForFIN     │      │   应付AP/应收AR        │
   │  库存关账/期初/余额    │      │   应付单/收款付款       │
   │  内部结算  → 财务口径  │      └──────────┬───────────┘
   └──────────┬───────────┘                 │ 借贷记账
              │                             ▼
              ▼                 ┌──────────────────────────┐
   ┌──────────────────┐        │  往来勾稽 Match           │
   │  凭证生成 Voucher │        │  方案→撮合→核销Verify      │
   │  BuildBusiness   │        │  清账 InnerClear / 机器人  │
   │  Voucher + 方案   │        └──────────┬───────────────┘
   └──────────┬───────┘       对接凭证或现金        │
              │                   ▼               ▼
              ▼              ┌──────────────────────────┐
   ┌──────────────────┐     │  出纳 CB + 现金银行 CN     │
   │  总账 GL          │◄────│  收付款单→现金/银行日记账   │
   │  凭证过账→账簿     │     │  银行对账→调节表→资金头寸   │
   │  多账簿多币别      │     └──────────┬───────────────┘
   └───────┬──────────┘                 │
           │                            │
           ▼                            ▼
   ┌──────────────────┐        ┌──────────────────┐
   │ 报表输出           │        │ 期末结账           │
   │ 总账/余额表/多栏账  │        │ 调汇→损益结转→关账  │
   │ 现金流量/科目余额   │        │ (AdjustPeriod)     │
   └──────────────────┘        └──────────────────┘
```

### 图 2 · 凭证生成与总账流程

```
业务单据(采购入库/销售出库/收款付款/费用...)
      │  "生成凭证" 操作 (AbstractBillOperation.MakeVoucher)
      ▼
┌───────────────────────────────────────────────┐
│ 1. 权限校验 Auth()                            │
│ 2. 取凭证模板方案 BuildVoucherByScheme        │
│    └─ 模板定义:科目映射/借贷方向/辅助核算字段  │
│ 3. 解析业务分录 → 借贷行 BuildVoucherInfo      │
│ 4. 校验: 借贷平衡/科目合法/期间可开账           │
│ 5. 生成凭证表头+分录(编号/期间/制单人)         │
└───────────────────┬───────────────────────────┘
                    ▼
           凭证(总账 GL)
      ┌──────────────┼──────────────┐
      ▼              ▼              ▼
  过账/登账       多账簿登记      辅助核算登记
      │              │              │
      ▼              ▼              ▼
  科目余额       法定/管理/税务    往来/客户/部门/项目
  维护直接取数     各本账簿         明细汇总
      │
      ▼
┌───────────────────────────────────────────┐
│ 总账报表族 (GL.Report.PlugIn)              │
│  总账/余额表/多栏账/数量金额账              │
│  核算项目余额/现金流量/调汇历史             │
└───────────────────────────────────────────┘
```

### 图 3 · 往来管理流程（应收应付 → 勾稽 → 核销 → 清账）

```
      应付AP单      应收AR单
        │             │
        ▼             ▼
┌─────────────────────────────────────────┐
│ 建立往来借方/贷方凭据                     │
│  (AP→贷方欠款，收款→借方冲减；            │
│   AR→借方债权，付款→贷方冲减)            │
└───────────────┬─────────────────────────┘
                ▼
┌─────────────────────────────────────────┐
│ 勾稽 Match(方案驱动)                     │
│  ① MatchSchemeEdit 定义方案              │
│  ② MatchFieldConfig 定义勾稽字段          │
│  ③ 取借贷两侧 GetCredit/DebitDynamicObj  │
│  ④ 撮合配对 → 核销记录 WriteOffRecord     │
│     (全勾稽/部分勾稽/差额)               │
└───────────────┬─────────────────────────┘
                ▼
┌─────────────────────────────────────────┐
│ 核销 VerifyData / 反核销 UnVerifyData    │
│  借项 ↔ 贷项 互相冲减 → 余额归零结清      │
│  自动核销 AutoVerifyData(机器人定时)      │
└───────────────┬─────────────────────────┘
                ▼
      ┌────────────────────┐
      ▼                    ▼
  关联公司互抵         剩余往来挂账
  InnerClear清账        → 账龄分析/催收
```

### 图 4 · 出纳与资金流程

```
收款单/付款单(经合同/订单核销后确定)
      ▼
┌───────────────────────────────────────────┐
│ 出纳确认收付款                              │
│   └ 现金 / 银行账户 / 票据 分类登记          │
└──────────────┬────────────────────────────┘
               ▼
┌───────────────────────────────────────────┐
│ 日记账                                     │
│  现金日记账 CashJournal/银行日记账 BankJournal│
└──────┬────────────────────────┬───────────┘
       ▼                        ▼
┌──────────────────┐   ┌──────────────────────────┐
│ 日报              │   │ 银行对账                   │
│ Cash/BankDaily   │   │ 企业日记账 ↔ 银行对账单      │
│                  │   │ 勾对未达账项 → 调节表         │
└──────────────────┘   │ FinalRecon/BalAdjustment   │
                       └─────────────┬──────────────┘
                                     ▼
                          ┌──────────────────────────┐
                          │ 资金管理                   │
                          │ 资金头寸 FundPositionReport│
                          │ 预计收支/票据(BillRec)     │
                          └──────────────────────────┘
```

### 图 5 · 会计期间生命周期

```
[A日常]  业务单据 → 凭证 → 过账 → 各账簿/报表实时可查
              │
              ▼
[B月结前] 收入/成本/费用单据全部审核
         库存期末结账(SCM) → 锁定库存期间
         成本核算 → 结转存货成本
              │
              ▼
[C调汇]  汇兑损益调整(AdjustPeriod 调整期间)
         未实现汇兑损益 → 财务费用
              │
              ▼
[D损益结转] 损益类科目 → 本年利润(自动结转模板)
              │
              ▼
[E结账]  关账(结账日期锁定) → 期末余额 → 下期期初
              │
              ▼
[F反结账] 需改错时逆向: 反结账 → 反调汇 → 重开库存期间
```

---

*本文档由 K3Cloud 反编译源码逆向整理，供财务系统学习、设计参考与二次开发使用。*
