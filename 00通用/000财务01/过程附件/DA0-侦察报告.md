# DA0 侦察报告 — 金蝶 K3Cloud 财务领域

> **模板加载记录**：已读取 `SOP-00-DA0-模板.md`（独立模板，SOP-00 §0 执行前置第 1/5/6 条）。生成前门禁检查：全部 4 项通过（覆盖了服务/报表/操作各入口、候选事实标注验证状态、未验证项登记 U-*）。
> 侦察路径基线：反编译快照 `C:\Users\16555\Downloads\01.K3Cloud源码`（无 git 提交标识，以快照现状为基线）；`Business\FIN\` + `BOS\Core\`。

## 版本信息

| 属性 | 值 |
|---|---|
| 侦察范围 | `01.K3Cloud源码/Business/FIN`（执行域）+ `01.K3Cloud源码/BOS`（平台操作框架/元数据引擎） |
| 版本基线 | 反编译快照当前状态（无 commit） |
| 侦察时间 | 2026-08-07 |

## 一、入口痕迹清单（R1 输出，候选线索，非业务结论）

### 1.1 服务/业务门面入口（FIN/01.Core，E-SRC: `Business/FIN/01.Core/Kingdee.K3.FIN.ServiceHelper/Kingdee.K3.FIN.ServiceHelper/*ServiceHelper.cs`（共 26 个，经源码核验））

| 入口 | 职责（候选） | 方法/用途 | 证据 |
|---|---|---|---|
| `AdjustPeriodServiceHelper` | 期间状态**查询门面**（只读） | `GetBookMaxPeriod`/`IsExistAdjustPeriod`/`IsAdjustPeriod`/`GetOpenAdjustPeriodByBook`——查期间与调整期间的开放状态，全类无"结账/反结/改期"写方法 | E-SRC: AdjustPeriodServiceHelper.cs（方法签名实测） |
| `CheckAccountBisServiceHelper` | 对账 | 往来/银行对账业务服务 | E-SRC: 同目录 CheckAccountBisServiceHelper.cs |
| `MatchServiceHelper` | 核销 | 应收/应付核销服务（`Match` 等） | E-SRC: 同目录 MatchServiceHelper.cs |
| `VoucherGenerateService`/`BuildBusinessVoucher`/`ViewGlVoucher` | 凭证生成/查看 | 业务单据→总账凭证（均为 `AbstractBillOperation` 子类） | E-SRC: 同目录 |
| `BillOperateServiceHelper` | 单据操作 | 财务单据的操作编排 | E-SRC: 同目录 BillOperateServiceHelper.cs |
| `StatementServiceHelper` | 对账单 | 往来对账单 | E-SRC: 同目录 StatementServiceHelper.cs |
| `NetControlServiceHelper` | 网控/额度 | 费用/预算网控 | E-SRC: 同目录 NetControlServiceHelper.cs |
| `EInvoiceServiceHelper` | 电子发票 | 发票服务面 | E-SRC: 同目录 EInvoiceServiceHelper.cs |
| `AccountFilterServiceHelper` | 科目过滤 | 辅助核算过滤 | E-SRC: 同目录 |
| 关账相关插件 | 期间/往来关账（发现） | `ClosingAccountEdit`/`AP-、AR-CloseAccountRobotPlugIn`（AP/AR 关账机器人） | E-SRC: BusinessPlugIn/…/AP.Business.PlugIn/Robot·ClosingAccountEdit |

> ⚠️ 证据实况（经独立复查）：**总账(GL)期末"结账/反结"写入口在 FIN 快照未定位**（`AdjustPeriodServiceHelper` 只是查询门面；AP/AR 的关账属往来域）。→ 登记 **U-DA0-5**：GL 结账写入口在快照外（服务端），S2 结账机制以"平台操作框架推断 + 期间查询门面"支撑，运行证据无。

### 1.2 报表入口（FIN/BusinessPlugIn，E-SRC）

| 域 | 报表类 | 业务面（候选） |
|---|---|---|
| GL | `GeneralLedgerFilter`/`CashflowReport`/`FlexAccountPlugIn`/`AccountingItemsBalanceFilter` | 总账/现金流量/多账簿分科目 |
| AP | `AgingAnalysisService`(实际位于 `AP.App.Report`)/`APSumReportService`/`APDetailReportService` | 应付账龄/汇总/明细 |
| CB | `AbstractCBBillReportService`/`BillCalCostRptBase` | 现金/银行报表、结转成本品类 |
| CN | `BankDailyReport`/`BankJournal`/`BalAdjustmentReport` | 银行日记账/余额调节表 |

> 证据位置：E-SRC: `FIN/BusinessPlugIn/{域}*.{域}*/*.cs`（`AgingAnalysisService` 在 `AP.App.Report`，`ServicePlugIn` 亦有同名门面）

### 1.3 平台操作框架（候选事实的承载机制，E-SRC: `BOS/Core/Kingdee.BOS.Core/DynamicForm/Operation*` 与 `Business.Bill/OperationController*`）

| 痕迹 | 说明 |
|---|---|
| 操作号（OperationNumber）+ 阶段（timingPoint） | 保存/审核/反审核/过账/结账统一走操作框架（历史分析已实证：`OperationController` 策略、`IOperationOperation`/`IOperationService`、`BillDataOperation` 等） |
| 元数据驱动单据 | 财务单据=元数据(BusinessInfo/FormMetadata)+少量插件；分录表格=Entry 实体 |

### 1.4 数据/配置痕迹（E-DAT 候选，命名推断，需服务端 DB 才可实证）

| 痕迹 | 候选 |
|---|---|
| T_VOUCHER 系（凭证/分录）、T_BALANCE 系（余额）、期结/期间表（T_*_CLOSED、期间状态 T_PRDINFO 类） | 账簿事实、期间状态 |
| T_AR/AP 系（应收/应付）、对账/核销关联表 | 往来与核销 |
| T_CN 票据系、T_CB 现金银行系 | 票据/资金 |

> 警告：以上表名是**命名推断**（E-DAT 候选），不构成 E-DAT 实证；Schema 在服务端 DB，快照不可直接定位，登记 U-DA0-1。

## 二、候选事实清单（R2 输出）

| 候选事实 | 痕迹位置 | 推断链 | 置信度 | 验证状态 |
|---|---|---|---|---|
| F1 业务单据生成会计凭证并把分录写入账簿 | FIN/01.Core VoucherGenerateService/BuildBusinessVoucher + 平台过账 | 写入口服务面 exists | 推断 | 待验证（机制级"具备该能力"，运行未证） |
| F2 期末结账把期间封闭、账簿固化 | AdjustPeriodServiceHelper + 操作框架"结账"动作 | 期间调整=补偿通道，暗示正通道=结账锁期 | 推断 | 待验证 |
| F3 往来被核销/分摊，形成已核销记录 | MatchServiceHelper | 核销服务面 | 推断 | 待验证 |
| F4 对账产生差异并可调整 | CheckAccountBisServiceHelper | 对账服务面 | 推断 | 待验证 |
| F5 银行日记账与余额调节 | BankJournal/BalAdjustmentReport | 报表读入口 | 推断 | 待验证 |
| F6 凭证/余额被期间状态约束（已结期间禁改） | 期间查询门面(`AdjustPeriodServiceHelper` 的 Period/IsAdjustPeriod)+ AP/AR 关账插件 | 推断：若无锁/关账概念，无需期间状态查询与关账插件 | 推断 | 待验证（GL 结账写入口未定位，U-DA0-5） |

> 全部候选事实当前为"**系统支持该能力**"(E-SRC 范围) 级；"实际发生/实际如何运行"因无运行证据一律登记 U-*（R7 受限级）。

## 三、候选 DQ（DA0-C，按 DQ-BIZ→DQ-MECHANISM 派生顺序）

| DQ | 来源证据 | 为什么重要 | 状态 |
|---|---|---|---|
| DQ-BIZ-01 财务域的业务本质是什么（"把经营事实按科目在时间轴(期间)上归集为账簿事实，并用期间封闭锁定历史"？） | F1/F2/F6 | 决定整个域的解释框架 | 保留 |
| DQ-FACT-01 凭证如何生成/过账、成功判据是什么（平衡校验/期间可写） | F1/F6 | 结转核心机制 | 保留 |
| DQ-FACT-02 期末结账如何把期间封闭、哪些数据被锁定 | F2 | 记账与时间轴关键 | 保留 |
| DQ-OBLIGATION-01 在哪些点系统确认"成功/失败/结果未知"（过账成功、核销足额、结账锁期 vs 期间冲突） | F2/F3/F6 | 完成线 | 保留 |
| DQ-RISK-01 结账后改期（可在结账后重开期间）是刻意通道还是缺口；反复改账风险 | F2 + AdjustPeriodServiceHelper | 治理关键 | 保留 |
| DQ-ACTOR-01 会计/出纳/复核/审核分别在哪些环节操作 | F1-F6 | 角色责任边界 | 保留 |
| DQ-OWNERSHIP-01 科目/账簿/期间的权威源与副本投影 | 元数据 + 分账簿 | 数据所有权 | 保留 |
| DQ-MECHANISM-01 平台操作框架如何用一个 Operation 承载过账/结账（timingPoint 编排） | BOS OperationController | 理解"平台即财务运行时" | 保留 |

## 四、候选业务切片（DA0-D）与分级

评估（候选分 = 不可替代 + 资金/合规冲击 + 频率/变更 + 跨边界）：详见下表与 DA1。

| 候选切片 | 评分要素 | 分 | 级别 |
|---|---|---|---|
| S1 凭证生成与过账（单据→凭证→分录入账） | 5+5+3+2 | 15 | **SC-P0** |
| S2 期末结账与期间锁闭（含改期补偿通道） | 5+5+2+3 | 15 | **SC-P0** |
| S3 往来核销与对账（核销/暂估/差异调整） | 4+4+3+3 | 14 | **SC-P0** |
| S4 现金/银行/票据（日记账/对账/票据收付） | 4+4+2+2 | 12 | SC-P1 |
| S5 财务分析/报表/账龄 | 3+2+3+1 | 9 | SC-P1 |
| S6 多账簿与折算（多账套/币别折算） | 3+2+1+3 | 9 | SC-P1 |

> 破例说明：候选 6 个（中系统默认 P0=2~3），取 3 个 P0（财务是核心域、影响面大，S1/S2/S3 相互纠缠不宜削项），已在主文档 §0 说明。

## 五、未知项（U-*）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-DA0-1 | 凭证/余额/期间表的具体 Schema（T_*）无法在快照实证 | 数据层结论限定为候选 |
| U-DA0-2 | 无运行证据：过账/结账/核销"实际发生/实际表现"不可证 | 一律 "系统具备能力" 级 |
| U-DA0-3 | 财务单据大量由元数据驱动，单据元数据（DB T_META_*）不在快照 | 切片叙事以平台机制+插件证据支撑 |
| U-DA0-4 | 未找到 AR 应收独立服务面（快照以 AP/GL/CB/CN 为主） | 应收部分机制参照 AP/往来同构推断 |
| U-DA0-5 | GL 期末"结账/反结"写入口在 FIN 快照未定位（AdjustPeriodServiceHelper 仅查询门面） | **威胁 S2（结账期间）机制证据** → S2 降级为"条件成立/待补证"，结账写入口待服务端证实 |

## 六、当前停止条件

- 继续侦察的预期信息增益：**中**（快照边界内主要入口/服务面已识别；继续逐行意义有限，转入 DA1 建模）
- 下一轮最小取证动作：DA1 对 S1/S2/S3 深挖服务面实现（VoucherGenerateService/AdjustPeriodServiceHelper/MatchServiceHelper 内部），并核对 BOS 操作框架的过账/结账支撑点

## 模板字段对照表

| 模板字段 | 状态 |
|---|---|
| 版本信息 / 1.1-1.5 入口痕迹（Controller/消息/定时/数据/配置） | 已覆盖：服务门面/报表/平台框架/数据痕迹（快照无 HTTP Controller、消息/定时入口，注明"不适用"） |
| 二、候选事实清单（痕迹/推断链/置信度/验证状态） | 已覆盖（F1-F6） |
| 三、未知项 U-* | 已覆盖（U-DA0-1~4） |
| 四、停止条件 | 已覆盖 |
| 全面性检查清单：HTTP/消息/定时/表/配置/候选事实状态 | 快照无独立 HTTP/MQ/Job 入口（FIN 服务端以 ServiceHelper+K3 平台通道承载），已逐一注明"不适用/无"/覆盖；逐项落实于上 |
