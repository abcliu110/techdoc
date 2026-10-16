# Cosmic 使用权资产全量源码分析

> 分析对象：`D:\cosmic-src` 反编译源码快照。本文描述代码当前可见实现，不代替准则解释或业务验收。
> 代码主模块：`biz/fi-fa`（固定资产）；相关业务实体主要为 `fa_lease_contract`、`fa_lease_contract_init`、`fa_lease_change_bill`、`fa_interest_detail`、`fa_lease_debit_balance`。
> 检索口径：Java 源码中的 `leaseassets`、`fa_lease*`、`leasecontract`、`RIGHT_OF_USE_ASSET` 等标识。附录完整列出命中文件；命中 `leasecontract` 的外围文件不一定直接计算使用权资产，需结合职责分类理解。

## 1. 结论与边界

使用权资产不是独立的一套资产账簿。它以租赁合同为测算和生命周期主对象，先根据合同租赁期、免租期、付款规则、付款计划、折现率和过渡方案计算合同财务字段，再将合同推送为固定资产实物卡片/财务卡片，随后复用固定资产卡片的折旧、账簿期间、变更及清理体系。租赁负债及利息另由利息明细、租金结算和负债余额对象承接。

源码最明确的“使用权资产”类别映射见 `AssetCatApplyTypeEnum.RIGHT_OF_USE_ASSET`。合同金额字段是 `leaseassets`；该字段进入财务卡片的 `originalval`。合同另存 `leaseliabori`（负债原值）、`leaseliab`（负债现值）、`assetsaccumdepre`（累计折旧）等字段。

仓库未包含可确认的完整元数据定义/页面模型资源：`fi-fa/src/main/resources` 当前只见 `package.properties`。因此，单据字段、表单布局、操作与插件的绑定关系只能根据 Java 中的实体标识和插件行为说明，不能从本仓库证明每一个插件在运行环境中实际绑定到哪个元数据版本。

代码导航图谱工具无法用于本目录：`D:\cosmic-src` 没有 Git/SVN 或 `.code-graph` 项目标记。以下结论来自源码文本、调用点和对象标识检索；反编译代码也可能丢失注释、泛型和局部变量信息。

## 2. 功能架构与对象关系

```text
租赁合同 / 初始化合同
  ├─ 付款规则、付款计划、租赁期、折现率、过渡方案
  ├─ LeaseContractCal：派生合同日期、豁免、折现率、折旧期间
  └─ LeaseUtil：按付款计划计算现值及合同财务金额
       ├─ leaseassets       使用权资产原值
       ├─ leaseliab         租赁负债现值
       ├─ leaseliabori      租赁负债原值
       └─ assetsaccumdepre  过渡/初始化累计折旧
             │
             ├─ 推送/生成实物卡片与财务卡片
             │    LeaseContractToFinCardGenerate
             │    └─ originalval、leasedebtorigin、leasedebtpresent、折旧余额
             │
             └─ 后续计量
                  InterestDetailGenerator（日粒度利息/付款轨迹）
                  ├─ RentSettleGenerator（按期间形成租金结算）
                  └─ FaLeaseDebitBalanceGenerator（期间负债余额）

变更单 ─ LeaseChangeHandler ─ 重算付款计划/资产负债/利息/结算
终止单 ─ LeaseTerminationHandler ─ 清理单/反结算/续租合同/终止记录
部分终止 ─ LeasePartTerCalculator ─ 按比例结清卡片和负债项目
```

重要实体标识（常量集中在 `business/constants`）：

| 实体/字段 | 代码意义 |
|---|---|
| `fa_lease_contract` | 当前租赁合同，是计算、变更、结算、终止的主要关联对象 |
| `fa_lease_contract_init` | 存量租赁初始化单，承载切换日前合同及既有累计数 |
| `fa_lease_change_bill` | 租赁变更单 |
| `fa_interest_detail` | 租赁利息/负债明细及逐日轨迹 |
| `fa_lease_debit_balance` | 租赁负债按摊销期间归集的余额信息 |
| `leaseassets` | 使用权资产计量金额；推卡时映射到财务卡片 `originalval` |
| `leaseliab` / `leaseliabori` | 租赁负债现值 / 原值；推卡时映射为负债现值 / 原值 |

## 3. 使用权资产计量逻辑

### 3.1 合同日期和计算参数

`LeaseContractCal` 是合同字段派生计算器，`LeaseContractGenerator.handleAutoCalFields` 在转换/生成合同过程中调用这些方法；合同编辑插件亦在字段变化和保存链路维护同一组字段。主要派生过程如下：

1. `setLeaseMonths` 按开始、结束日期和组织系统参数计算租赁月数。
2. `setLeaseTermStartDate` 优先取免租期开始日，否则取租赁开始日。
3. `setInitConfirmDate` 在首次执行日与免租期开始日（有免租期）或租赁开始日之间取较晚日期。
4. `setIsExempt` 按初始确认日到租赁结束日的月数是否不超过 12 判断豁免；月数进位受系统参数影响。
5. `setTransitionPlan` 根据合同是否属于存量合同、组织参数决定是否使用过渡方案；新合同会清空存量过渡方案。
6. `setDepreMonths` 根据来源类型、过渡方案、开始日、结束日和折旧方式计算折旧期间；按日折旧时改按天数。
7. `setDiscountRate` 按组织、币种、生效日期、期限查询 `fa_discount_rate`；方案 C 使用租赁期开始日，其他场景取初始确认日。查询可回溯到上级组织有效利率。
8. `setDailyDiscountRate` 把年折现率转为日折现率，按组织参数选复利或单利；默认复利。

这些字段属于合同计算输入和派生值。是否豁免不是简单从“合同总长度”判断，而是代码基于 `initconfirmdate`、`leaseenddate` 和租赁月数计算。

### 3.2 付款计划折现与合同金额

提交时的入口是 `LeaseUtil.calLeaseContractAmount4Submit`，依次补充付款计划折现字段和合同财务字段。`fillPayPlan` 逐条处理计划：

- 只有付款项目 `accountingclass = A` 进入租赁负债现值计算；费用类 `C` 不计入。
- 负债侧折现天数从初始确认日到付款日计算；计划记录 `discountdays`、`discountfactor`、`presentvalue`。
- 资产侧只在过渡方案 A 或 C 时产生 `discountdays2`、`discountfactor2`、`presentvalue2`；起算日为租赁期开始日。
- 日折现率在进入幂运算前按百分数换算；折现因子为 `(1 + 日利率)^天数`，金额按币种精度和系统舍入规则取值。
- 可抵扣属性、租金不含税金额和 `is_deduct_vat_discount` 参数会影响资产侧付款金额基数。

`calFinInfoFields` 汇总付款计划，最终回写合同字段：

- `leaseliabori` 汇总纳入核算计划的未付租金；`leaseliab` 汇总负债现值 `presentvalue`。
- 方案 A/C：`leaseassets` 汇总资产侧现值；类别 B 的符合条件付款项另按租金金额加计。
- 其他转换方案：使用负债现值作为资产计算基础，并按付款项类别、税额与抵扣税额设置调整项。
- 方案 A 还计算切换/执行期相关的 `assetsaccumdepre`；该字段不是新合同的通用累计折旧算法。
- 豁免合同时，代码把 `leaseliabori`、`leaseliab`、`leaseassets`、`assetsaccumdepre` 统一置零。

因此，不能把 `leaseassets` 简化成“所有未来租金的现值”或“总租金”。具体金额取决于付款项目核算类别、付款日、租赁期起算日、方案 A/B/C、增值税抵扣配置、豁免状态及存量合同来源。

### 3.3 免租期与付款计划生成

`LeaseUtil.generatePayPlan` 根据付款规则和租赁期间展开付款计划；`generatePayPlan4Chg` 为变更合同复制/调整付款计划，并比较新旧规则；`calPlanPayDate` 负责付款日推导。合同编辑、付款规则校验和支付计划插件负责页面联动、字段控制、导入与列表交互。生成后计划行才进入上述现值计算。

免租期影响 `leasetermstartdate`、`initconfirmdate` 和付款计划日期，但免租租金优惠是否减少资产入账，最终由计划金额字段以及 `is_deduct_vat_discount` / 抵扣标识决定。应以实际付款计划金额为审计入口。

## 4. 后续计量与资产卡片

### 4.1 合同推送为固定资产卡片

`LeaseContractToFinCardGenerate.generate` 基于合同关联的实物卡片创建财务卡片，补齐租赁金额和计划项映射。`setLeaseAmount` 将 `leaseliabori`、`leaseliab` 写入卡片的负债原值、现值字段，并以差额计算未确认融资费用；`leaseassets` 进入 `originalval`。它还回填折旧月数、会计日期、净值、净额、残值和按日折旧方式。

存量初始化合同走 `InitLeaseContractToFinCardGenerate`：保留合同已有累计折旧、已折旧期间、本年累计折旧，并按初始化/切换日期选择卡片入账日期；折旧方法及残值还结合资产账簿、资产类别政策。

`FaRealCardSaveOp`、卡片生成公共类和推卡校验器连接租赁合同与实物卡片/财务卡片。固定资产卡片进入通用折旧流程后，租赁模块中的 `assetsaccumdepre` 是初始化/过渡数据，不意味着租赁模块自身逐期计算所有卡片折旧。

### 4.2 利息、结算和负债余额

`InterestDetailGenerator` 从合同、初始化信息和付款计划生成 `fa_interest_detail`。非豁免合同沿租赁期间生成日粒度记录，维护期初余额、付款、利息、期末余额和摊销期间；并区分原始/变更来源及最新有效明细。豁免合同走单独分支。变更和终止场景可重算或反向冲回已有明细。

在利息明细基础上：

- `RentSettleGenerator.generate` 生成/保存租金结算单；按会计期间归集付款和利息，也提供 `reverse` 处理终止等场景的反向结算。
- `FaLeaseDebitBalanceGenerator.genLeaseDebitBalance` 汇总利息明细为摊销期间负债余额数据，支持升级、排除终止数据等模式。
- `LeaseUtil.saveRentSettle` / `deleteRentSettle` 处理结算保存、删除及与 IEP 等外部流程的同步联动。
- 月结检查插件阻止未完成的推卡、租金结算或资产变更业务影响期间关闭。

### 4.3 变更

租赁变更由表单插件和操作插件维护变更单；审核/推送操作进入 `LeaseChangeHandler.handle`。处理器根据变更生效日和变更字段：构造变更前后合同快照，复制/重建付款计划，比较付款规则，计算生效日负债余额，重新计算资产与负债金额，更新利息明细和租金结算，并批量回写合同。`BackupMode`、历史明细有效期间和变更类型决定历史数据的保留/重算方式。

变更单可能向下游生成资产变更单；推送校验比较合同变更前后的租赁资产金额及负债相关值。`FaLeaseChangeBillAuditOp`、`FaLeaseChangeBillPushOp`、撤销审核/删除操作和对应 validator 一起控制状态迁移。

### 4.4 终止、续租与部分终止

完全终止由 `LeaseTerminationHandler.handle` 编排。源码可见步骤包括准备合同日期、生成清理单、按需要生成续租合同、生成反向租金结算、更新合同基本信息、修正清理分录余额以及写入终止记录。`LeaseContract2ClearBillConvertor` 把合同转成固定资产清理单；撤销终止由 `LeaseUndoTerminationHandler` 及相应插件恢复合同状态和关联数据。

部分终止使用 `LeasePartTerCalculator`：按终止比例计算清理卡片金额、租赁负债/未确认融资费用等租赁信息；对应表单、生成清理/删除清理操作和未来业务校验在 `partter`、`parttermination` 子包。

### 4.5 查询、报告及期间控制

摊余成本报告由 `FaAmortisedCostReportServiceImpl`、`FaAmortisedCostRptHelper`、`FaAmortisedCostQingDataProvider`、`FaAmortisedCostPlugin` 等查询服务、数据提供器和页面插件组成。报告读取合同、利息/付款结算、折旧和资产余额，展示租赁负债及资产变化。租赁初始化、租赁负债余额、利息明细也各有列表/页面插件。

期间关账和反关账通过 `MonthCloseCenter*` 以及 `LeaseContractPushCardCheck`、`LeaseContractRentSettleCheck`、`LeaseChangeBillPushAssetChangeCheck` 检查尚未推卡、未结算或尚未完成的资产变更。

## 5. 关键文件逐项说明

以下列出主链中最重要的实现文件。完整检索命中文件（含升级、权限、API、外围业务引用）见第 7 节自动生成附录。

| 文件（相对 `biz/fi-fa/src/main/java/kd/fi/fa/`） | 职责 |
|---|---|
| `business/lease/LeaseContractCal.java` | 派生租赁月数、初始确认日、租赁期开始日、豁免、过渡方案、折现率、日折现率、折旧期间。 |
| `business/lease/LeaseContractGenerator.java` | 由合同转换器生成租赁合同，设置单据头/关联关系并执行自动字段计算。 |
| `business/lease/utils/LeaseUtil.java` | 生成和调整付款计划；提交前折现；汇总 `leaseassets` / `leaseliab`；租金结算保存删除及期间工具。 |
| `business/constants/FaLeaseContract.java` | 租赁合同实体名和业务字段常量，包括 `leaseassets`。 |
| `business/constants/FaLeaseInit.java` | 租赁初始化单据字段/实体常量。 |
| `business/constants/FaInterestDetail.java` | 利息明细实体及字段常量。 |
| `business/constants/FaLeaseDebitBalance.java` | 租赁负债余额实体及字段常量。 |
| `business/enums/AssetCatApplyTypeEnum.java` | 资产类别应用类型枚举，含“使用权资产”标识。 |
| `business/lease/InterestDetailGenerator.java` | 生成/反向生成租赁利息明细；按合同、付款计划、期间和有效日期计算余额轨迹。 |
| `business/lease/FaLeaseDebitBalanceGenerator.java` | 将利息明细归集到摊销期间负债余额。 |
| `business/lease/RentSettleGenerator.java` | 基于利息明细生成、冲回租金结算单。 |
| `business/cardgenerate/impl/LeaseContractToFinCardGenerate.java` | 新合同推卡：将合同原值、负债和折旧相关数据写入固定资产财务卡片。 |
| `business/cardgenerate/impl/InitLeaseContractToFinCardGenerate.java` | 初始化合同推卡：保留既有累计折旧、已折旧期数及切换期间信息。 |
| `business/lease/LeaseTerminationHandler.java` | 完全终止编排：清理、续租、结算冲回、合同更新、终止记录。 |
| `business/lease/partter/LeasePartTerCalculator.java` | 部分终止金额计算并组装清理单数据。 |
| `business/clear/convertor/LeaseContract2ClearBillConvertor.java` | 租赁合同转固定资产清理单。 |
| `opplugin/lease/LeaseChangeHandler.java` | 变更审核后更新合同、付款计划、资产负债金额、利息明细和租金结算。 |
| `business/validator/lease/LeaseContractValidator.java` | 租赁合同字段和财务金额校验。 |
| `business/validator/lease/LeaseChangeBillValidator.java` | 租赁变更单业务规则校验。 |
| `formplugin/lease/LeaseContractEditPlugin.java` | 合同编辑界面交互、字段联动及租赁资产字段组显示控制。 |
| `formplugin/lease/LeaseChangeEditPlugin.java` | 变更编辑界面及变更项目/快照关联处理。 |
| `opplugin/lease/FaLeaseContractSubmitOp.java` | 合同提交操作；与提交 validator、公共提交逻辑配合。 |
| `opplugin/lease/FaLeaseContractAuditOp.java` | 合同审核操作。 |
| `opplugin/lease/FaLeaseChangeBillAuditOp.java` | 变更单审核操作和变更业务处理入口。 |
| `opplugin/lease/FaLeaseChangeBillPushOp.java` | 变更单向固定资产变更链路推送。 |
| `api/controller/LeaseContractController.java` | 租赁合同 API 控制入口。 |
| `api/controller/LeaseChangeBillController.java` | 租赁变更单 API 控制入口。 |
| `mservice/lease/FaAmortisedCostReportServiceImpl.java` | 摊余成本/租赁资产负债报告服务实现。 |

## 6. 文件职责分类规则

全量命中文件有三种相关程度：

1. **直接计量/生命周期代码**：包含 `leaseassets`、租赁合同实体、初始化/变更/终止处理，或直接读写资产卡片字段。这是追踪数值变化的优先入口。
2. **租赁业务支撑代码**：表单、操作、校验、API、报表、权限、期间控制、数据升级、备份恢复。它们使功能可操作、可迁移、可查询，但通常不定义核心计量公式。
3. **外围引用命中**：文件只出现 `leasecontract` 或一般“lease”字样，可能是费用、税务、融资或其他业务对象。附录会保留这些命中以满足全量检索，但不会将其误称为使用权资产计量逻辑。

附录的“代码线索”是从包路径、类名和关键字命中推导的快速索引；源码没有明确实现的语义不应单凭类名当成已验证业务结论。

## 7. 全量检索文件索引

以下索引由源码检索结果生成，检索目录为 `biz` 和 `bos`，文件类型为 Java，排除 `target`。每一项包含路径、职责区域和可见类名；核心算法在第 3、4 节结合源码详细说明。外围命中仅用于扩大排查范围。

命中 Java 文件数：**395**。区域按源码包路径归类；语义线索由文件名切词得到，入口方法来自源码声明。它们用于逐文件导航，具体行为以实现体为准。

| 文件路径（相对 `D:\cosmic-src`） | 区域 | 类型/类名 | 文件名语义线索 | 可见公有/保护入口 |
|---|---|---|---|---|
| `biz\biz-bos-ext\src\main\java\kd\fi\fa\formplugin\dap\AccDateValidateUtil.java` | 跨模块租赁关联引用 | `AccDateValidateUtil` | 校验工具 | `validateAccDateDelete()`, `validateAccDateCreate()` |
| `biz\fi-ai\src\main\java\kd\fi\ai\util\AiCommonFieldUtils.java` | 跨模块租赁关联引用 | `AiCommonFieldUtils` | 工具 | `returnComboItem()`, `returnComboItemWithVoucher()`, `getNotEntityBillId()`, `checkNeedBuildVoucherBillStatus()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\bean\leasechangebill\LeaseChangeBillSaveParamModel.java` | API接口 | `LeaseChangeBillSaveParamModel` | 租赁变更保存 | `getBillNo()`, `setBillNo()`, `getOrgNumber()`, `setOrgNumber()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\bean\LeaseContract.java` | API接口 | `LeaseContract` | 租赁合同 | `getSelect()`, `setSelect()`, `getFilter()`, `setFilter()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\controller\LeaseChangeBillController.java` | API接口 | `LeaseChangeBillController` | 租赁变更控制器 | `save()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\controller\LeaseContractController.java` | API接口 | `LeaseContractController` | 租赁合同控制器 | `undoTermination()`, `termination()`, `renewalQuery()`, `terminationQuery()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\lease\AbstractContractQueryPlugin.java` | API接口 | `AbstractContractQueryPlugin` | 合同查询插件 | `doCustomService()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\lease\LeaseTerminationApiPlugin.java` | API接口 | `LeaseTerminationApiPlugin` | 租赁终止接口插件 | `doCustomService()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\lease\TerminatedContractQueryPlugin.java` | API接口 | `TerminatedContractQueryPlugin` | 已终止合同查询插件 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\request\LeaseContractTerminationRequest.java` | API接口 | `LeaseContractTerminationRequest` | 租赁合同终止 | `getContractId()`, `setContractId()`, `getChangeModeId()`, `setChangeModeId()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\api\utils\LeaseChangeBillApiHelper.java` | API接口 | `LeaseChangeBillApiHelper` | 租赁变更接口辅助 | `validateParamModel()`, `getLeaseContract()`, `buildAndSaveBakContract()`, `buildChangeBill()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\booksync\init\InitBookCardSyncService.java` | 固定资产租赁外围支撑 | `InitBookCardSyncService` | 初始化账簿卡片服务 | `getEntityKey()`, `queryNeedSyncCards()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\cardgenerate\CardGenerateHelper.java` | 资产卡片生成 | `CardGenerateHelper` | 卡片生成辅助 | `generateRealCard()`, `generateFinCard()`, `generateFinCardForAssetCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\cardgenerate\impl\InitLeaseContractToFinCardGenerate.java` | 资产卡片生成 | `InitLeaseContractToFinCardGenerate` | 初始化租赁合同财务卡片生成 | `generate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\cardgenerate\impl\LeaseContractToFinCardGenerate.java` | 资产卡片生成 | `LeaseContractToFinCardGenerate` | 租赁合同财务卡片生成 | `generate()`, `setPaymentItemAmountToFinCards()`, `getOriginalVal()`, `setLeaseAmount()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\checker\AssetBookBusyChecker.java` | 固定资产租赁外围支撑 | `AssetBookBusyChecker` | 资产账簿 | `bookStatusCheck()`, `bookExistsFinBusy()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\clear\ClearBillGenerateFacade.java` | 资产清理 | `ClearBillGenerateFacade` | 清理生成 | `generateClearBillByApply()`, `generateClearBillByDispt()`, `generateClearBillByLease()`, `generateClearBillByPartTermination()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\clear\ClearBillGeneratorHelper.java` | 资产清理 | `ClearBillGeneratorHelper` | 清理生成器辅助 | `getAssetBookEntriesByAssetOrg()`, `getClearBillHDByClearBillDataAndBookEntries()`, `getCardDepReAdjust()`, `checkDepAdjustAfterFinCardClear()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\clear\ClearBillHDGenerator.java` | 资产清理 | `ClearBillHDGenerator` | 清理生成器 | `generate()`, `saveAssetBookEntries()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\clear\convertor\FaPartTermination2ClearBillConvertor.java` | 资产清理 | `FaPartTermination2ClearBillConvertor` | 部分终止清理转换器 | `setHeadData()`, `setDetailData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\clear\convertor\LeaseContract2ClearBillConvertor.java` | 资产清理 | `LeaseContract2ClearBillConvertor` | 租赁合同清理转换器 | `setHeadData()`, `setDetailData()`, `getDetailData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\closebook\BizChecker.java` | 固定资产租赁外围支撑 | `BizChecker` | 按类名和包路径定位，需结合源码确认 | `checkFCard()`, `checkAssetCard()`, `checkChange()`, `checkSplitCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\closebook\DefaultCheckTask.java` | 固定资产租赁外围支撑 | `DefaultCheckTask` | 检查 | `call()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaExemptRecords.java` | 实体与字段常量 | `FaExemptRecords` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaInterestDetail.java` | 实体与字段常量 | `FaInterestDetail` | 利息 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseChangeBill.java` | 实体与字段常量 | `FaLeaseChangeBill` | 租赁变更 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseContract.java` | 实体与字段常量 | `FaLeaseContract` | 租赁合同 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseDebitBalance.java` | 实体与字段常量 | `FaLeaseDebitBalance` | 租赁负债余额 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseInit.java` | 实体与字段常量 | `FaLeaseInit` | 租赁初始化 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeasePartTermination.java` | 实体与字段常量 | `FaLeasePartTermination` | 租赁部分终止 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseRentSettle.java` | 实体与字段常量 | `FaLeaseRentSettle` | 租赁租金结算 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseTermination.java` | 实体与字段常量 | `FaLeaseTermination` | 租赁终止 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseTermRecords.java` | 实体与字段常量 | `FaLeaseTermRecords` | 租赁 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\constants\FaLeaseUndoTermination.java` | 实体与字段常量 | `FaLeaseUndoTermination` | 租赁撤销终止 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\dao\impl\FaFinCardDaoOrmImpl.java` | 固定资产租赁外围支撑 | `FaFinCardDaoOrmImpl` | 财务卡片 | `copyFinCards()`, `restoreCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\depreciation\FaDepreCheckUtils.java` | 固定资产租赁外围支撑 | `FaDepreCheckUtils` | 折旧检查工具 | `needAddCheck()`, `needAddCheckFinCard()`, `needAddMergedCard()`, `needAdjustCheck()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\enums\AssetCatApplyTypeEnum.java` | 业务枚举 | `AssetCatApplyTypeEnum` | 资产 | `getValue()`, `getName()`, `getNameByValue()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\enums\lease\LeaseContractBizStatus.java` | 业务枚举 | `LeaseContractBizStatus` | 租赁合同 | `getPartTerErrorMsg()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\enums\lease\LeaseContractDepreTypeEnum.java` | 业务枚举 | `LeaseContractDepreTypeEnum` | 租赁合同折旧 | `getValue()`, `getByValue()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\enums\lease\LeaseContractRentSettleStatus.java` | 业务枚举 | `LeaseContractRentSettleStatus` | 租赁合同租金结算 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\enums\lease\LeaseContractSourceType.java` | 业务枚举 | `LeaseContractSourceType` | 租赁合同 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\AbstractLeaseContractCopy.java` | 租赁核心计算/生命周期 | `AbstractLeaseContractCopy` | 租赁合同 | `copy()`, `addBackupInfo()`, `deleteOldBackupVersion()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\inter\ILeaseContractCopy.java` | 租赁核心计算/生命周期 | `ILeaseContractCopy` | 租赁合同 | `copy()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\inter\ILeaseContractRestore.java` | 租赁核心计算/生命周期 | `ILeaseContractRestore` | 租赁合同恢复 | `restore()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractAllDataCopy.java` | 租赁核心计算/生命周期 | `LeaseContractAllDataCopy` | 租赁合同 | `addBackupInfo()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractBackupInnerUtils.java` | 租赁核心计算/生命周期 | `LeaseContractBackupInnerUtils` | 租赁合同备份工具 | `deleteBackupVersion()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractBackupUtils.java` | 租赁核心计算/生命周期 | `LeaseContractBackupUtils` | 租赁合同备份工具 | `backup()`, `restore()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractBaseDataCopy.java` | 租赁核心计算/生命周期 | `LeaseContractBaseDataCopy` | 租赁合同 | `addBackupInfo()`, `deleteOldBackupVersion()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractRestore.java` | 租赁核心计算/生命周期 | `LeaseContractRestore` | 租赁合同恢复 | `restore()`, `handleInsertContractFor2Code()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\LeaseContractRestore2Code.java` | 租赁核心计算/生命周期 | `LeaseContractRestore2Code` | 租赁合同恢复 | `handleInsertContractFor2Code()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\backup\RestoreLeaseContractInfo.java` | 租赁核心计算/生命周期 | `RestoreLeaseContractInfo` | 恢复租赁合同 | `getBeforeBackupedContrId()`, `setBeforeBackupedContrId()`, `getAfterBackupedContrId()`, `setAfterBackupedContrId()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\convert\AbstractLeaseContractConverter.java` | 租赁核心计算/生命周期 | `AbstractLeaseContractConverter` | 租赁合同转换器 | `convert()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\convert\LeaseContract2LeaseContractConverter.java` | 租赁核心计算/生命周期 | `LeaseContract2LeaseContractConverter` | 租赁合同租赁合同转换器 | `convert()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\convert\LeaseContractData.java` | 租赁核心计算/生命周期 | `LeaseContractData` | 租赁合同 | `getAssetUnit()`, `setAssetUnit()`, `getOrg()`, `setOrg()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\FaLeaseDebitBalanceGenerator.java` | 租赁核心计算/生命周期 | `FaLeaseDebitBalanceGenerator` | 租赁负债余额生成器 | `setUpgrade()`, `setExcludeTermData()`, `genLeaseDebitBalance()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\FaRentSettleWhitelistUpgradeHandler.java` | 租赁核心计算/生命周期 | `FaRentSettleWhitelistUpgradeHandler` | 租金结算升级 | `doHandler()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\InterestDetailGenerator.java` | 租赁核心计算/生命周期 | `InterestDetailGenerator` | 利息生成器 | `generate()`, `reverse()`, `generateByLeaseContract()`, `calcAmortizationPeriod()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\InterestDetailGenerator4LeaseChange.java` | 租赁核心计算/生命周期 | `InterestDetailGenerator4LeaseChange` | 利息生成器租赁变更 | `generate()`, `reverse()`, `generate4LeaseChange()`, `getLeaseLiabPayBeforeEffectDateForExempt()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseContractCal.java` | 租赁核心计算/生命周期 | `LeaseContractCal` | 租赁合同 | `setLeaseMonths()`, `setInitConfirmDate()`, `setLeaseTermStartDate()`, `setIsExempt()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseContractGenerator.java` | 租赁核心计算/生命周期 | `LeaseContractGenerator` | 租赁合同生成器 | `generate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseFutureBizChecker.java` | 租赁核心计算/生命周期 | `LeaseFutureBizChecker` | 租赁 | `existFutureLeaseChangeBill()`, `existFutureLeasePartTer()`, `getLeasePartTerContractIds()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseRentSettleDapListService.java` | 租赁核心计算/生命周期 | `LeaseRentSettleDapListService` | 租赁租金结算列表服务 | `addToBlacklist()`, `removeFromBlacklist()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseTerminationHandler.java` | 租赁核心计算/生命周期 | `LeaseTerminationHandler` | 租赁终止 | `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseTerminationPcLockServiceUtils.java` | 租赁核心计算/生命周期 | `LeaseTerminationPcLockServiceUtils` | 租赁终止服务工具 | `getPcLockTryLock()`, `getPcParentUnLockParameter()`, `getPcLockTryLockForNoTer()`, `getPcParentUnLockParameterForNoTer()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\LeaseUndoTerminationHandler.java` | 租赁核心计算/生命周期 | `LeaseUndoTerminationHandler` | 租赁撤销终止 | `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\partter\LeasePartTerCalculator.java` | 租赁核心计算/生命周期 | `LeasePartTerCalculator` | 租赁部分终止 | `getTerClearBaseInfo()`, `calcTerCardInfo()`, `transPrecisionProcessing()`, `calcTerLeaseInfo()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\RealDailyIntRateCalculator.java` | 租赁核心计算/生命周期 | `RealDailyIntRateCalculator` | 日利率 | `getDetailBeginBalance()`, `getNotConfirmFinCost()`, `calculate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\RealDailyIntRateCalculator4LeaseChange.java` | 租赁核心计算/生命周期 | `RealDailyIntRateCalculator4LeaseChange` | 日利率租赁变更 | `getDetailBeginBalance()`, `getNotConfirmFinCost()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\RentSettleGenerator.java` | 租赁核心计算/生命周期 | `RentSettleGenerator` | 租金结算生成器 | `generate()`, `generateByInterestDetail()`, `getBeginIndex4Generate()`, `isBeginGenerate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\RentSettleGenerator4LeaseChange.java` | 租赁核心计算/生命周期 | `RentSettleGenerator4LeaseChange` | 租金结算生成器租赁变更 | `reverse()`, `generate()`, `getBeginIndex4Generate()`, `isBeginGenerate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\rpt\FaAmortisedCostRptHelper.java` | 租赁核心计算/生命周期 | `FaAmortisedCostRptHelper` | 摊余成本报表辅助 | `checkParam()`, `queryLeaseContract()`, `filterLeaseContract()`, `queryCostListData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\utils\Change2ContrServiceHelper.java` | 租赁核心计算/生命周期 | `Change2ContrServiceHelper` | 变更服务辅助 | `operationValidate()`, `save()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\utils\FaLeaseDebitBalanceUtils.java` | 租赁核心计算/生命周期 | `FaLeaseDebitBalanceUtils` | 租赁负债余额工具 | `modifyDebitBalanceData4Term()`, `modifyDebitBalanceData()`, `modifyDebitBalanceDataByPeriodID()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\utils\LeaseChangeUtil.java` | 租赁核心计算/生命周期 | `LeaseChangeUtil` | 租赁变更工具 | `updateChangeBakContract()`, `getAftContractForValidate()`, `buildChangeBakContract()`, `batchUpdateContractBizStatus()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\lease\utils\LeaseUtil.java` | 租赁核心计算/生命周期 | `LeaseUtil` | 租赁工具 | `getSettleRent()`, `irr()`, `getFirstExecDateFromSysParam()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\pclock\EntityName2PcLockConfig.java` | 固定资产租赁外围支撑 | `EntityName2PcLockConfig` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\pclock\PcLockConfigBillNoConstants.java` | 固定资产租赁外围支撑 | `PcLockConfigBillNoConstants` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\periodclose\PeriodCloseCenterLogProcessor.java` | 固定资产租赁外围支撑 | `PeriodCloseCenterLogProcessor` | 期间 | `createOrUpdateCloseLog()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\periodclose\UnFinishedBizChecker.java` | 固定资产租赁外围支撑 | `UnFinishedBizChecker` | 按类名和包路径定位，需结合源码确认 | `checkFCard()`, `checkAssetCard()`, `checkChange()`, `checkSplitCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\service\FaLeaseRentSettleDapBlacklistUpgradeServiceImpl.java` | 固定资产租赁外围支撑 | `FaLeaseRentSettleDapBlacklistUpgradeServiceImpl` | 租赁租金结算升级服务 | `execute()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\SourceFlagEnum.java` | 固定资产租赁外围支撑 | `SourceFlagEnum` | 按类名和包路径定位，需结合源码确认 | `getEntityName()`, `getName()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\utils\FaUtils.java` | 固定资产租赁外围支撑 | `FaUtils` | 工具 | `isFieldEmpty()`, `removeString_id()`, `isZero()`, `parseDateByFormatString()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\utils\lease\FaLeasePartTerUtil.java` | 固定资产租赁外围支撑 | `FaLeasePartTerUtil` | 租赁部分终止工具 | `getLeasePartTer()`, `getNotPushedLeaseContractIdFromPartTerByLeaseContractId()`, `addErrorInfo()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\FinCardValidator.java` | 业务校验 | `FinCardValidator` | 财务卡片校验器 | `setValidateSave()`, `setSkipCapitDateValidate()`, `getInstanceForSeparateCard()`, `getInstanceForAssetCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\lease\LeaseChangeBillValidator.java` | 业务校验 | `LeaseChangeBillValidator` | 租赁变更校验器 | `validate4Save()`, `validate4Submit()`, `validate4Audit()`, `validate4Push()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\lease\LeaseContractValidator.java` | 业务校验 | `LeaseContractValidator` | 租赁合同校验器 | `validateContractForImport()`, `validateContractForSave()`, `validateContractForSubmit()`, `validateContractForAudit()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\lease\PaymentItemValidator.java` | 业务校验 | `PaymentItemValidator` | 校验器 | `validateReference()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\lease\TerminationValidator.java` | 业务校验 | `TerminationValidator` | 终止校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\lease\UndoTerminationValidator.java` | 业务校验 | `UndoTerminationValidator` | 撤销终止校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\business\validator\RealCardValidator.java` | 业务校验 | `RealCardValidator` | 卡片校验器 | `validateForAllOption()`, `validateForSave()`, `validateForSubmit()`, `validateForUnAudit()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\common\util\FaChangeItemUtil.java` | 固定资产租赁外围支撑 | `FaChangeItemUtil` | 变更工具 | `getAllInitFields()`, `getNormalFields()`, `leaseCardChangeItemHide()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\assetcard\FaAssetCardInitEditPlugin.java` | 表单/列表界面插件 | `FaAssetCardInitEditPlugin` | 资产卡片初始化编辑插件 | `afterBindData()`, `afterDoOperation()`, `registerListener()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaAssetBookEditPlugin.java` | 表单/列表界面插件 | `FaAssetBookEditPlugin` | 资产账簿编辑插件 | `registerListener()`, `afterCreateNewData()`, `propertyChanged()`, `pageRelease()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaChangeApplyEditPlugin.java` | 表单/列表界面插件 | `FaChangeApplyEditPlugin` | 变更编辑插件 | `preOpenForm()`, `registerListener()`, `beforeBindData()`, `afterCreateNewData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaChangeBillChangeTypeEditPlugin.java` | 表单/列表界面插件 | `FaChangeBillChangeTypeEditPlugin` | 变更变更编辑插件 | `registerListener()`, `initialize()`, `afterCreateNewData()`, `beforeBindData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaChangeBillEditPlugin.java` | 表单/列表界面插件 | `FaChangeBillEditPlugin` | 变更编辑插件 | `propertyChanged()`, `initImportData()`, `beforeImportData()`, `afterImportData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaCurCardFinEditPlugin.java` | 表单/列表界面插件 | `FaCurCardFinEditPlugin` | 卡片财务编辑插件 | `afterCreateNewData()`, `initImportData()`, `afterImportData()`, `registerListener()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaCurCardRealEditPlugin.java` | 表单/列表界面插件 | `FaCurCardRealEditPlugin` | 卡片编辑插件 | `registerListener()`, `afterCreateNewData()`, `afterImportData()`, `afterBindData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaInitFinCardEditPlugin.java` | 表单/列表界面插件 | `FaInitFinCardEditPlugin` | 初始化财务卡片编辑插件 | `beforeImportData()`, `afterDoOperation()`, `initImportData()`, `afterImportData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaInitRealCardEditPlugin.java` | 表单/列表界面插件 | `FaInitRealCardEditPlugin` | 初始化卡片编辑插件 | `afterImportData()`, `afterBindData()`, `propertyChanged()`, `afterDoOperation()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaMergeBillEditPlugin.java` | 表单/列表界面插件 | `FaMergeBillEditPlugin` | 编辑插件 | `afterCreateNewData()`, `afterBindData()`, `registerListener()`, `propertyChanged()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaParamEditPlugin.java` | 表单/列表界面插件 | `FaParamEditPlugin` | 编辑插件 | `beforeBindData()`, `propertyChanged()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FaRealCardF7Plugin.java` | 表单/列表界面插件 | `FaRealCardF7Plugin` | 卡片插件 | `registerListener()`, `beforeClick()`, `listRowDoubleClick()`, `checkFinCardByDepreAdjust()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\FetchDepreDataPlugin.java` | 表单/列表界面插件 | `FetchDepreDataPlugin` | 折旧插件 | `registerListener()`, `itemClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\AbstractLeaseContractImportPlugin.java` | 表单/列表界面插件 | `AbstractLeaseContractImportPlugin` | 租赁合同导入插件 | `afterImportData()`, `fillCustomFields()`, `fillSysSwitchDate()`, `fillAccountDate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\ExemptRecordsFormPlugin.java` | 表单/列表界面插件 | `ExemptRecordsFormPlugin` | 插件 | `beforeBindData()`, `beforeDoOperation()`, `afterDoOperation()`, `beforeClosed()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\FaLeaseDebitBalanceListPlugin.java` | 表单/列表界面插件 | `FaLeaseDebitBalanceListPlugin` | 租赁负债余额列表插件 | `setFilter()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\FaLeaseInitEditPlugin.java` | 表单/列表界面插件 | `FaLeaseInitEditPlugin` | 租赁初始化编辑插件 | `registerListener()`, `afterBindData()`, `propertyChanged()`, `afterCreateNewData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\FaLeaseInitListPlugin.java` | 表单/列表界面插件 | `FaLeaseInitListPlugin` | 租赁初始化列表插件 | `afterDoOperation()`, `afterBindData()`, `customEvent()`, `itemClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\ImportEntityMapping.java` | 表单/列表界面插件 | `ImportEntityMapping` | 导入 | `create()`, `push()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\InterestDetailFormPlugin.java` | 表单/列表界面插件 | `InterestDetailFormPlugin` | 利息插件 | `registerListener()`, `afterBindData()`, `itemClick()`, `closedCallBack()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseBizRecordTabHandler.java` | 表单/列表界面插件 | `LeaseBizRecordTabHandler` | 租赁 | `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseChangeEditPlugin.java` | 表单/列表界面插件 | `LeaseChangeEditPlugin` | 租赁变更编辑插件 | `registerListener()`, `beforeBindData()`, `beforeImportData()`, `afterImportData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseChangeImportPlugin.java` | 表单/列表界面插件 | `LeaseChangeImportPlugin` | 租赁变更导入插件 | `resolveExcel()`, `getDefaultLockUIs()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseChangeListPlugin.java` | 表单/列表界面插件 | `LeaseChangeListPlugin` | 租赁变更列表插件 | `filterContainerInit()`, `filterContainerSearchClick()`, `filterContainerBeforeF7Select()`, `itemClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseChgExportUtil.java` | 表单/列表界面插件 | `LeaseChgExportUtil` | 租赁导出工具 | `openUrl()`, `export()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractChangeLayoutEditPlugin.java` | 表单/列表界面插件 | `LeaseContractChangeLayoutEditPlugin` | 租赁合同变更编辑插件 | `createNewData()`, `beforeBindData()`, `destory()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractEditPlugin.java` | 表单/列表界面插件 | `LeaseContractEditPlugin` | 租赁合同编辑插件 | `registerListener()`, `afterCreateNewData()`, `afterLoadData()`, `beforeBindData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractHelpPlugin.java` | 表单/列表界面插件 | `LeaseContractHelpPlugin` | 租赁合同插件 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractImportPlugin.java` | 表单/列表界面插件 | `LeaseContractImportPlugin` | 租赁合同导入插件 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractInitEditPlugin.java` | 表单/列表界面插件 | `LeaseContractInitEditPlugin` | 租赁合同初始化编辑插件 | `afterCreateNewData()`, `afterDoOperation()`, `propertyChanged()`, `customEvent()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractInitImportPlugin.java` | 表单/列表界面插件 | `LeaseContractInitImportPlugin` | 租赁合同初始化导入插件 | `setIsExempt()`, `validate()`, `fillAccountDate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractInitListPlugin.java` | 表单/列表界面插件 | `LeaseContractInitListPlugin` | 租赁合同初始化列表插件 | `setFilter()`, `filterContainerInit()`, `filterContainerSearchClick()`, `filterContainerBeforeF7Select()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractInitOperaPlugin.java` | 表单/列表界面插件 | `LeaseContractInitOperaPlugin` | 租赁合同初始化插件 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractInitTrackDownEditPlugin.java` | 表单/列表界面插件 | `LeaseContractInitTrackDownEditPlugin` | 租赁合同初始化编辑插件 | `afterBindData()`, `closedCallBack()`, `queryMainTableIdMap()`, `createShowParameter()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractListPlugin.java` | 表单/列表界面插件 | `LeaseContractListPlugin` | 租赁合同列表插件 | `filterContainerInit()`, `filterContainerSearchClick()`, `filterContainerBeforeF7Select()`, `beforeDoOperation()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractNewListPlugin.java` | 表单/列表界面插件 | `LeaseContractNewListPlugin` | 租赁合同列表插件 | `setFilter()`, `beforeDoOperation()`, `afterDoOperation()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseContractOperPlugin.java` | 表单/列表界面插件 | `LeaseContractOperPlugin` | 租赁合同插件 | `beforeDoOperation()`, `afterDoOperation()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseRentSettleFilterList.java` | 表单/列表界面插件 | `LeaseRentSettleFilterList` | 租赁租金结算列表 | `filterContainerInit()`, `filterContainerBeforeF7Select()`, `setFilter()`, `billListHyperLinkClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseTerminationEditPlugin.java` | 表单/列表界面插件 | `LeaseTerminationEditPlugin` | 租赁终止编辑插件 | `registerListener()`, `afterCreateNewData()`, `hyperLinkClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\LeaseUndoTerminationEditPlugin.java` | 表单/列表界面插件 | `LeaseUndoTerminationEditPlugin` | 租赁撤销终止编辑插件 | `registerListener()`, `afterCreateNewData()`, `hyperLinkClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\partter\LeasePartTerminationEditPlugin.java` | 表单/列表界面插件 | `LeasePartTerminationEditPlugin` | 租赁部分终止编辑插件 | `registerListener()`, `afterBindData()`, `propertyChanged()`, `afterDoOperation()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\lease\PayPlanListPlugin.java` | 表单/列表界面插件 | `PayPlanListPlugin` | 付款计划列表插件 | `setFilter()`, `afterDoOperation()`, `filterContainerInit()`, `filterContainerBeforeF7Select()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\paymentitemamountfield\PaymentItemAmountFieldEdit.java` | 表单/列表界面插件 | `PaymentItemAmountFieldEdit` | 金额编辑 | `registerListener()`, `afterBindData()`, `click()`, `treeNodeDoubleClick()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\paymentitemamountmap\PaymentItemAmountMapEdit.java` | 表单/列表界面插件 | `PaymentItemAmountMapEdit` | 金额编辑 | `registerListener()`, `beforeBindData()`, `click()`, `closedCallBack()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\formplugin\paymentitemamountmap\PaymentItemAmountMapListPlugin.java` | 表单/列表界面插件 | `PaymentItemAmountMapListPlugin` | 金额列表插件 | `beforeCreateListDataProvider()`, `getData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\mservice\lease\FaAmortisedCostReportServiceImpl.java` | 查询与报表 | `FaAmortisedCostReportServiceImpl` | 摊余成本报表服务 | `queryFaAmortisedCostReport()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\mservice\operation\FaCloseInitOpService.java` | 固定资产租赁外围支撑 | `FaCloseInitOpService` | 初始化操作服务 | `preparePropertys()`, `executeOperate()`, `closeInitAssetBook()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\mservice\rptmediate\FaRptMediateQueryServiceImpl.java` | 固定资产租赁外围支撑 | `FaRptMediateQueryServiceImpl` | 报表查询服务 | `getDataSet()`, `getDataMap()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\assetcard\FaAssetCardInitOperationPlugin.java` | 单据操作/操作校验插件 | `FaAssetCardInitOperationPlugin` | 资产卡片初始化插件 | `onPreparePropertys()`, `beginOperationTransaction()`, `endOperationTransaction()`, `beforeExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\changebill\FaChangeBillLeaseCardValidator.java` | 单据操作/操作校验插件 | `FaChangeBillLeaseCardValidator` | 变更租赁卡片校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\changebill\FaChangeItemSaveOp.java` | 单据操作/操作校验插件 | `FaChangeItemSaveOp` | 变更保存操作 | `onPreparePropertys()`, `onAddValidators()`, `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\changebill\validator\FaSourceFlagValidator.java` | 单据操作/操作校验插件 | `FaSourceFlagValidator` | 校验器 | `getEntryName()`, `setEntryName()`, `getRealCardFieldName()`, `setRealCardFieldName()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaAssetBookSaveValidator.java` | 单据操作/操作校验插件 | `FaAssetBookSaveValidator` | 资产账簿保存校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaCardOperationPlugin.java` | 单据操作/操作校验插件 | `FaCardOperationPlugin` | 卡片插件 | `onPreparePropertys()`, `onAddValidators()`, `validate()`, `stripTime()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaFinCardOperationPlugin.java` | 单据操作/操作校验插件 | `FaFinCardOperationPlugin` | 财务卡片插件 | `onPreparePropertys()`, `onAddValidators()`, `validate()`, `endOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaInitFinCardSaveOp.java` | 单据操作/操作校验插件 | `FaInitFinCardSaveOp` | 初始化财务卡片保存操作 | `onPreparePropertys()`, `beginOperationTransaction()`, `endOperationTransaction()`, `afterExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaInitFinDeleteOpPlugin.java` | 单据操作/操作校验插件 | `FaInitFinDeleteOpPlugin` | 初始化财务删除操作插件 | `onAddValidators()`, `validate()`, `onPreparePropertys()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\FaInitRealDeleteOpPlugin.java` | 单据操作/操作校验插件 | `FaInitRealDeleteOpPlugin` | 初始化删除操作插件 | `onAddValidators()`, `afterExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaAbstractAmortizeAlgorithm.java` | 单据操作/操作校验插件 | `FaAbstractAmortizeAlgorithm` | 摊销 | `generateSettleDateRentList()`, `computerIrr()`, `pack()`, `afterPack()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaAbstractLeaseContractSubmitOp.java` | 单据操作/操作校验插件 | `FaAbstractLeaseContractSubmitOp` | 租赁合同提交操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `calLeaseContractAmount()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaAmortizeSchemeFactory.java` | 单据操作/操作校验插件 | `FaAmortizeSchemeFactory` | 摊销 | `getAmortizeScheme()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaAmortizeSchemeFirst.java` | 单据操作/操作校验插件 | `FaAmortizeSchemeFirst` | 摊销 | `generateSettleDateRentList()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaAmortizeSchemeThird.java` | 单据操作/操作校验插件 | `FaAmortizeSchemeThird` | 摊销 | `generateSettleDateRentList()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaExemptRecordsSaveOp.java` | 单据操作/操作校验插件 | `FaExemptRecordsSaveOp` | 保存操作 | `onAddValidators()`, `validate()`, `beforeExecuteOperationTransaction()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaGeneratePayPlanOp.java` | 单据操作/操作校验插件 | `FaGeneratePayPlanOp` | 生成付款计划操作 | `onPreparePropertys()`, `onAddValidators()`, `endOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaGeneratePayPlanValidator.java` | 单据操作/操作校验插件 | `FaGeneratePayPlanValidator` | 生成付款计划校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillAuditOp` | 租赁变更审核操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `setPcLockCofig()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillDeleteOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillDeleteOp` | 租赁变更删除操作 | `onPreparePropertys()`, `beginOperationTransaction()`, `setPcLockCofig()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillPushOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillPushOp` | 租赁变更推送操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `pushAssetChangeBill()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillSaveOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillSaveOp` | 租赁变更保存操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `setPcLockCofig()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillSubmitOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillSubmitOp` | 租赁变更提交操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `setPcLockCofig()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillSubmitValidator.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillSubmitValidator` | 租赁变更提交校验器 | `buildAftContract()`, `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeBillUnAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeBillUnAuditOp` | 租赁变更审核操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `setPcLockCofig()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseChangeDeleteAssetChangeOp.java` | 单据操作/操作校验插件 | `FaLeaseChangeDeleteAssetChangeOp` | 租赁变更删除资产变更操作 | `onPreparePropertys()`, `onAddValidators()`, `validate()`, `afterExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseContractAuditOp` | 租赁合同审核操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractAuditValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractAuditValidator` | 租赁合同审核校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractDeleteOp.java` | 单据操作/操作校验插件 | `FaLeaseContractDeleteOp` | 租赁合同删除操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractDeleteValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractDeleteValidator` | 租赁合同删除校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractExemptPropertyValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractExemptPropertyValidator` | 租赁合同校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractGenNumOp.java` | 单据操作/操作校验插件 | `FaLeaseContractGenNumOp` | 租赁合同操作 | `onPreparePropertys()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseContractInitAuditOp` | 租赁合同初始化审核操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitAuditValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractInitAuditValidator` | 租赁合同初始化审核校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitPushOp.java` | 单据操作/操作校验插件 | `FaLeaseContractInitPushOp` | 租赁合同初始化推送操作 | `onPreparePropertys()`, `onAddValidators()`, `beforeExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitPushValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractInitPushValidator` | 租赁合同初始化推送校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitSubmitOp.java` | 单据操作/操作校验插件 | `FaLeaseContractInitSubmitOp` | 租赁合同初始化提交操作 | `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitSubmitValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractInitSubmitValidator` | 租赁合同初始化提交校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitUnAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseContractInitUnAuditOp` | 租赁合同初始化审核操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractInitUnAuditValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractInitUnAuditValidator` | 租赁合同初始化审核校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractSaveOp.java` | 单据操作/操作校验插件 | `FaLeaseContractSaveOp` | 租赁合同保存操作 | `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractSaveValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractSaveValidator` | 租赁合同保存校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractSubmitOp.java` | 单据操作/操作校验插件 | `FaLeaseContractSubmitOp` | 租赁合同提交操作 | `onAddValidators()`, `calLeaseContractAmount()`, `beforeExecuteOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractSubmitValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractSubmitValidator` | 租赁合同提交校验器 | `preparePropertys()`, `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractUnAuditOp.java` | 单据操作/操作校验插件 | `FaLeaseContractUnAuditOp` | 租赁合同审核操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseContractUnAuditValidator.java` | 单据操作/操作校验插件 | `FaLeaseContractUnAuditValidator` | 租赁合同审核校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseInitDeleteOp.java` | 单据操作/操作校验插件 | `FaLeaseInitDeleteOp` | 租赁初始化删除操作 | `onPreparePropertys()`, `onAddValidators()`, `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseInitializationOp.java` | 单据操作/操作校验插件 | `FaLeaseInitializationOp` | 租赁操作 | `onPreparePropertys()`, `onAddValidators()`, `validate()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseInitSaveValidator.java` | 单据操作/操作校验插件 | `FaLeaseInitSaveValidator` | 租赁初始化保存校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseTerminationOp.java` | 单据操作/操作校验插件 | `FaLeaseTerminationOp` | 租赁终止操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseTerminationValidator.java` | 单据操作/操作校验插件 | `FaLeaseTerminationValidator` | 租赁终止校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseUndoTerminationOp.java` | 单据操作/操作校验插件 | `FaLeaseUndoTerminationOp` | 租赁撤销终止操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaLeaseUndoTerminationValidator.java` | 单据操作/操作校验插件 | `FaLeaseUndoTerminationValidator` | 租赁撤销终止校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaRentSettle.java` | 单据操作/操作校验插件 | `FaRentSettle` | 租金结算 | `beforeGenerate()`, `generateSettleData()`, `afterGenerate()`, `insertSettleData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaRentSettleOp.java` | 单据操作/操作校验插件 | `FaRentSettleOp` | 租金结算操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaRentSettleValidator.java` | 单据操作/操作校验插件 | `FaRentSettleValidator` | 租金结算校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaRentUnSettleOp.java` | 单据操作/操作校验插件 | `FaRentUnSettleOp` | 租金结算操作 | `onAddValidators()`, `onPreparePropertys()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\FaRentUnSettleValidator.java` | 单据操作/操作校验插件 | `FaRentUnSettleValidator` | 租金结算校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\LeaseChangeHandler.java` | 单据操作/操作校验插件 | `LeaseChangeHandler` | 租赁变更 | `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\parttermination\FaPartTerminationDelClearOp.java` | 单据操作/操作校验插件 | `FaPartTerminationDelClearOp` | 部分终止清理操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\parttermination\FaPartTerminationGenClearOp.java` | 单据操作/操作校验插件 | `FaPartTerminationGenClearOp` | 部分终止清理操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\parttermination\validator\FaPartTermFutureValidator.java` | 单据操作/操作校验插件 | `FaPartTermFutureValidator` | 部分校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\parttermination\validator\FaPartTerminationDelClearValidator.java` | 单据操作/操作校验插件 | `FaPartTerminationDelClearValidator` | 部分终止清理校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\lease\parttermination\validator\FaPartTerminationGenClearValidator.java` | 单据操作/操作校验插件 | `FaPartTerminationGenClearValidator` | 部分终止清理校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\LeasePushCardValidator.java` | 单据操作/操作校验插件 | `LeasePushCardValidator` | 租赁推送卡片校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\LeasePushSaveFinCardValidator.java` | 单据操作/操作校验插件 | `LeasePushSaveFinCardValidator` | 租赁推送保存财务卡片校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\LeasePushSubmitFinCardValidator.java` | 单据操作/操作校验插件 | `LeasePushSubmitFinCardValidator` | 租赁推送提交财务卡片校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\merge\FaMergeBillSaveValidator.java` | 单据操作/操作校验插件 | `FaMergeBillSaveValidator` | 保存校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\MonthClose\LeaseChangeBillPushAssetChangeCheck.java` | 单据操作/操作校验插件 | `LeaseChangeBillPushAssetChangeCheck` | 租赁变更推送资产变更检查 | `execute()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\MonthClose\LeaseContractPushCardCheck.java` | 单据操作/操作校验插件 | `LeaseContractPushCardCheck` | 租赁合同推送卡片检查 | `execute()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\MonthClose\LeaseContractRentSettleCheck.java` | 单据操作/操作校验插件 | `LeaseContractRentSettleCheck` | 租赁合同租金结算检查 | `execute()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\MonthClose\MonthCloseCenterBackOpPlugin.java` | 单据操作/操作校验插件 | `MonthCloseCenterBackOpPlugin` | 操作插件 | `onPreparePropertys()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\MonthClose\MonthCloseCenterOpPlugin.java` | 单据操作/操作校验插件 | `MonthCloseCenterOpPlugin` | 操作插件 | `onPreparePropertys()`, `beginOperationTransaction()`, `afterExecuteOperationTransaction()`, `onEnded()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\pclock\PcLockForLeasePayPlan.java` | 单据操作/操作校验插件 | `PcLockForLeasePayPlan` | 租赁付款计划 | `onPreparePropertys()`, `onAddValidators()`, `validate()`, `beginOperationTransaction()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\pclock\PcLockForLeaseRentSettle.java` | 单据操作/操作校验插件 | `PcLockForLeaseRentSettle` | 租赁租金结算 | `onPreparePropertys()`, `onAddValidators()`, `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\realcard\FaRealCardSaveOp.java` | 单据操作/操作校验插件 | `FaRealCardSaveOp` | 卡片保存操作 | `onAddValidators()`, `beginOperationTransaction()`, `beforeExecuteOperationTransaction()`, `addLeaseContractLinkRealCard()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\opplugin\validator\FaInitFinCardSaveValidator.java` | 单据操作/操作校验插件 | `FaInitFinCardSaveValidator` | 初始化财务卡片保存校验器 | `validate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\po\GenInterestDetailParamPo.java` | 固定资产租赁外围支撑 | `GenInterestDetailParamPo` | 利息 | `buildTerminationDate()`, `buildEffectiveDate()`, `getLeaseContractId()`, `getTerminationDate()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\report\constants\RptLeaseList.java` | 查询与报表 | `RptLeaseList` | 报表租赁列表 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\fi-fa\src\main\java\kd\fi\fa\report\formplugin\FaAmortisedCostPlugin.java` | 表单/列表界面插件 | `FaAmortisedCostPlugin` | 摊余成本插件 | `initialize()`, `processRowData()`, `registerListener()`, `afterCreateNewData()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\report\qing\AmortisedCostQingDataProvider.java` | 查询与报表 | `AmortisedCostQingDataProvider` | 摊余成本 | `getData()`, `getMeta()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\report\query\FaCostListQuery.java` | 查询与报表 | `FaCostListQuery` | 成本列表查询 | `query()`, `getColumns()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\servicehelper\ServiceFactory.java` | 固定资产租赁外围支撑 | `ServiceFactory` | 服务 | `getService()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaFixLeaseLiabBalanceService.java` | 版本升级/历史数据修复 | `FaFixLeaseLiabBalanceService` | 租赁余额服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaInitLeaseContractBotpUpgradeService.java` | 版本升级/历史数据修复 | `FaInitLeaseContractBotpUpgradeService` | 初始化租赁合同升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChangePermFromAddNewUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseChangePermFromAddNewUpgradeServiceImpl` | 租赁变更权限升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChangePermFromViewUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseChangePermFromViewUpgradeServiceImpl` | 租赁变更权限升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChangePermToDeleteAssetChgUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseChangePermToDeleteAssetChgUpgradeServiceImpl` | 租赁变更权限删除资产升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChangePermToGenAssetChgUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseChangePermToGenAssetChgUpgradeServiceImpl` | 租赁变更权限资产升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChangePushStatusUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseChangePushStatusUpgradeService` | 租赁变更推送升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseChgAmortPerdUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseChgAmortPerdUpgradeService` | 租赁升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseContractPermFromAddNewUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseContractPermFromAddNewUpgradeServiceImpl` | 租赁合同权限升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseContractPermFromRentSettleUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseContractPermFromRentSettleUpgradeServiceImpl` | 租赁合同权限租金结算升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseContractPermFromRentUnSettleUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseContractPermFromRentUnSettleUpgradeServiceImpl` | 租赁合同权限租金结算升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseContractPermFromViewUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaLeaseContractPermFromViewUpgradeServiceImpl` | 租赁合同权限升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseDebitBalanceUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseDebitBalanceUpgradeService` | 租赁负债余额升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseInit4AssetBookUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseInit4AssetBookUpgradeService` | 租赁初始化资产账簿升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeasePayPlanPermissionUpgradeService.java` | 版本升级/历史数据修复 | `FaLeasePayPlanPermissionUpgradeService` | 租赁付款计划升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeasePayRuleTaxUpgradeService.java` | 版本升级/历史数据修复 | `FaLeasePayRuleTaxUpgradeService` | 租赁付款升级服务 | `afterExecuteSqlWithResult()`, `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseRentSettlePermissionUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseRentSettlePermissionUpgradeService` | 租赁租金结算升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseRentSettleUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseRentSettleUpgradeService` | 租赁租金结算升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseTermRecordsUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseTermRecordsUpgradeService` | 租赁升级服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaLeaseTransitionPlanUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseTransitionPlanUpgradeService` | 租赁计划升级服务 | `afterExecuteSqlWithResult()`, `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaPayPlanCurrencyUpgradeService.java` | 版本升级/历史数据修复 | `FaPayPlanCurrencyUpgradeService` | 付款计划升级服务 | `afterExecuteSqlWithResult()`, `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaRentSettleBillNoUpgradeService.java` | 版本升级/历史数据修复 | `FaRentSettleBillNoUpgradeService` | 租金结算升级服务 | `afterExecuteSqlWithResult()`, `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaRentSettleUpdatePermUpgradeService.java` | 版本升级/历史数据修复 | `FaRentSettleUpdatePermUpgradeService` | 租金结算权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaSortTerminaLeaseInterestEntryServiceImpl.java` | 版本升级/历史数据修复 | `FaSortTerminaLeaseInterestEntryServiceImpl` | 租赁利息服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaUpdateLeaseInterestVersionServiceImpl.java` | 版本升级/历史数据修复 | `FaUpdateLeaseInterestVersionServiceImpl` | 租赁利息服务 | `afterExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaUpgradeRentSettleToIepService.java` | 版本升级/历史数据修复 | `FaUpgradeRentSettleToIepService` | 升级租金结算服务 | `afterExecuteSqlWithResult()`, `handle()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\FaUpImportExportPermItemUpgradeServiceImpl.java` | 版本升级/历史数据修复 | `FaUpImportExportPermItemUpgradeServiceImpl` | 导入导出权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\lease\FaLease2Frm4ChangeBillUpgradeService.java` | 版本升级/历史数据修复 | `FaLease2Frm4ChangeBillUpgradeService` | 租赁变更升级服务 | `beforeExecuteSqlWithResult()`, `getChgField2EntryMap()`, `setChgField2EntryMap()`, `getCard2FieldEntryMap()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\lease\FaLease2Frm4ClearBillUpgradeService.java` | 版本升级/历史数据修复 | `FaLease2Frm4ClearBillUpgradeService` | 租赁清理升级服务 | `beforeExecuteSqlWithResult()`, `getLeaseOriginalBalance()`, `getLeasePresentBalance()`, `getUnConfirmFinCostBalance()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\lease\FaLease2Frm4FinCardUpgradeService.java` | 版本升级/历史数据修复 | `FaLease2Frm4FinCardUpgradeService` | 租赁财务卡片升级服务 | `beforeExecuteSqlWithResult()`, `setLeaseDecimalInfo()`, `getContractId()`, `getLeaseDebtOrigin()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\lease\FaLeaseContractAccountDateUpgradeService.java` | 版本升级/历史数据修复 | `FaLeaseContractAccountDateUpgradeService` | 租赁合同升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\LeaseRentSettleStatusUpgradeService.java` | 版本升级/历史数据修复 | `LeaseRentSettleStatusUpgradeService` | 租赁租金结算升级服务 | `afterExecuteSqlWithResult()`, `getId()`, `getIsExempt()`, `getLeaseLiab()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\permitem\AttachPermUpgradeService1.java` | 版本升级/历史数据修复 | `AttachPermUpgradeService1` | 权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\permitem\leaserentsettle\LeaseRentSettlePermItemUpgradeService.java` | 版本升级/历史数据修复 | `LeaseRentSettlePermItemUpgradeService` | 租赁租金结算权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\permitem\PermItemUpgradeService6.java` | 版本升级/历史数据修复 | `PermItemUpgradeService6` | 权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\permitem\PermItemUpgradeService7.java` | 版本升级/历史数据修复 | `PermItemUpgradeService7` | 权限升级服务 | `beforeExecuteSqlWithResult()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\TermRecords.java` | 版本升级/历史数据修复 | `TermRecords` | 按类名和包路径定位，需结合源码确认 | `setChangeModeId()`, `setRenewalEndDate()`, `setAmortizationDate()`, `setAmortizationPeriodId()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\upgradeservice\util\FaHisLeaseContractUtils.java` | 版本升级/历史数据修复 | `FaHisLeaseContractUtils` | 租赁合同工具 | `upgradeHisContract4DebitBalance()`, `leaseChgAmortPerdUpgradeService()`, `isExpirationTermination()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\utils\FaFormPermissionUtil.java` | 固定资产租赁外围支撑 | `FaFormPermissionUtil` | 工具 | `setPageDisable()`, `filterContainerBeforeF7Select()`, `filterContainerBeforeF7SelectV2()`, `initFilterContainerBeforeF7Select()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\utils\FaQFilter.java` | 固定资产租赁外围支撑 | `FaQFilter` | 按类名和包路径定位，需结合源码确认 | `realCardQFilter()`, `realCardF7CommonFilter()`, `getRealCardBizStatusQFilter()` |
| `biz\fi-fa\src\main\java\kd\fi\fa\utils\MetaDataFieldDescUtils.java` | 固定资产租赁外围支撑 | `MetaDataFieldDescUtils` | 工具 | `getLeaseContractFieldKey2DescMap()`, `getFinCardFieldKey2DescMap()` |
| `biz\fi-frm\src\main\java\kd\fi\frm\servicehelper\ServiceFactory.java` | 跨模块租赁关联引用 | `ServiceFactory` | 服务 | `getService()` |
| `biz\fi-frm\src\main\java\kd\fi\frm\upgradeservice\FaLeaseContractRuleUpService.java` | 跨模块租赁关联引用 | `FaLeaseContractRuleUpService` | 租赁合同服务 | `afterExecuteSqlWithResult()` |
| `biz\hr-hlcmpro\src\main\java\kd\hr\hlcm\business\domian\utils\ContractSignUtils.java` | 跨模块租赁关联引用 | `ContractSignUtils` | 合同工具 | `getPersonInfoByAssignment()`, `setControlIsEmpty()`, `setControlListIsEmpty()`, `getDefaultValue()` |
| `biz\hr-hlcmpro\src\main\java\kd\hr\hlcm\opplugin\contract\ContractBaseSubmitOp.java` | 跨模块租赁关联引用 | `ContractBaseSubmitOp` | 合同提交操作 | `onPreparePropertys()`, `onAddValidators()`, `beginOperationTransaction()`, `afterExecuteOperationTransaction()` |
| `biz\taxc-bdtaxr\src\main\java\kd\taxc\bdtaxr\business\pay\impl\ccxws\FcsCztdsysDimensionPayService.java` | 跨模块租赁关联引用 | `FcsCztdsysDimensionPayService` | 付款服务 | `generateEntryEntity()` |
| `biz\taxc-bdtaxr\src\main\java\kd\taxc\bdtaxr\common\impt\ImportRulePlugin.java` | 跨模块租赁关联引用 | `ImportRulePlugin` | 导入插件 | `getDefaultKeyFields()`, `beforeSave()`, `save()` |
| `biz\taxc-bdtaxr\src\main\java\kd\taxc\bdtaxr\common\taxdeclare\ruleconfig\RuleTemplateNewPlugin.java` | 跨模块租赁关联引用 | `RuleTemplateNewPlugin` | 插件 | `initialize()`, `afterBindData()`, `afterCopyData()`, `afterCreateNewData()` |
| `biz\taxc-rdesd\src\main\java\kd\taxc\rdesd\formplugin\ruleconfig\RuleTemplateNewPlugin.java` | 跨模块租赁关联引用 | `RuleTemplateNewPlugin` | 插件 | `initialize()`, `afterCreateNewData()`, `beforeDoOperation()`, `closedCallBack()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\accrual\impl\FcsAccrualServiceImpl.java` | 跨模块租赁关联引用 | `FcsAccrualServiceImpl` | 服务 | `doCalAccrualInfo()`, `doCalcAccrualDetails()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\compare\impl\FcsTdsCompareCalcServiceImpl.java` | 跨模块租赁关联引用 | `FcsTdsCompareCalcServiceImpl` | 服务 | `doCalcCompareDetails()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\declare\engine\impl\FcsHireEngineServiceImpl.java` | 跨模块租赁关联引用 | `FcsHireEngineServiceImpl` | 服务 | `runEngine()`, `getCurrentPayable()`, `setOtherValue()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\draft\DraftDateService.java` | 跨模块租赁关联引用 | `DraftDateService` | 服务 | `getDraftDynamicObjectMap()`, `getNoDraftList()`, `getSkssq()`, `getDifferentDrafIsxxwlqy()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\taxsource\egine\HouseRentAutoCollectEngine.java` | 跨模块租赁关联引用 | `HouseRentAutoCollectEngine` | 租金 | `deleteData()`, `runEngine()`, `calSummaryAccountList()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\business\taxsource\HouseRentServiceHelper.java` | 跨模块租赁关联引用 | `HouseRentServiceHelper` | 租金服务辅助 | `fetchRules()`, `getGatherStatus()`, `gatherHouseRent()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\common\constant\TcretDraftConstant.java` | 跨模块租赁关联引用 | `TcretDraftConstant` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\formplugin\account\HouseRentAutoCollect.java` | 跨模块租赁关联引用 | `HouseRentAutoCollect` | 租金 | `registerListener()`, `afterCreateNewData()`, `propertyChanged()`, `afterDoOperation()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\formplugin\accrual\handler\FcsHireAccrualCalHandler.java` | 跨模块租赁关联引用 | `FcsHireAccrualCalHandler` | 按类名和包路径定位，需结合源码确认 | `getType()`, `setOtherValue()`, `getCurrentPayable()`, `getPeriodList()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\formplugin\draft\FcsczDraftPlugin.java` | 跨模块租赁关联引用 | `FcsczDraftPlugin` | 插件 | `getBaseTaxCategory()`, `calcDraftDetails()`, `setValue()`, `registerListener()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\formplugin\pbtdeclare\taxdetail\fcs\FcsHireFormPlugin.java` | 跨模块租赁关联引用 | `FcsHireFormPlugin` | 插件 | `registerListener()`, `afterCreateNewData()`, `hyperLinkClick()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\formplugin\pbtdeclare\taxdetail\fcs\FcsHireJsInfoDialogPlugin.java` | 跨模块租赁关联引用 | `FcsHireJsInfoDialogPlugin` | 插件 | `afterCreateNewData()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\mservice\upgrade\AccrualProjectNameUpgradeService.java` | 跨模块租赁关联引用 | `AccrualProjectNameUpgradeService` | 升级服务 | `getService()`, `getLogger()`, `beforeExecuteSqlWithResult()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\mservice\upgrade\FcsAccrualdetailUpgradeService.java` | 跨模块租赁关联引用 | `FcsAccrualdetailUpgradeService` | 升级服务 | `getService()`, `getLogger()`, `beforeExecuteSqlWithResult()` |
| `biz\taxc-tcret\src\main\java\kd\taxc\tcret\opplugin\RuleDataSynOp.java` | 跨模块租赁关联引用 | `RuleDataSynOp` | 操作 | `onPreparePropertys()`, `endOperationTransaction()` |
| `biz\taxc-tcvvt\src\main\java\kd\taxc\tcvvt\formplugin\taxdeclare\RuleTemplateNewPlugin.java` | 跨模块租赁关联引用 | `RuleTemplateNewPlugin` | 插件 | `initialize()`, `beforeDoOperation()`, `afterDoOperation()`, `openSettingPage()` |
| `biz\taxc-tdm\src\main\java\kd\taxc\tdm\formplugin\taxSourceInfo\FcsByHireSourceInfoEnableOp.java` | 跨模块租赁关联引用 | `FcsByHireSourceInfoEnableOp` | 操作 | `onPreparePropertys()`, `onAddValidators()` |
| `biz\taxc-tdm\src\main\java\kd\taxc\tdm\formplugin\taxSourceInfo\FcsRentalAccountListPlugin.java` | 跨模块租赁关联引用 | `FcsRentalAccountListPlugin` | 列表插件 | `registerListener()`, `filterContainerInit()`, `packageData()`, `billListHyperLinkClick()` |
| `biz\taxc-tsate\src\main\java\kd\taxc\tsate\business\taxsource\updata\FcczxxTaxsourceUpdate.java` | 跨模块租赁关联引用 | `FcczxxTaxsourceUpdate` | 按类名和包路径定位，需结合源码确认 | `initBeforeUpdate()`, `updateTaxsourceOriginBill()`, `afterUpdate()`, `generateTaxPeriodDescription()` |
| `biz\taxc-tsate\src\main\java\kd\taxc\tsate\common\constant\taxsource\TaxsourceMetaMapInfo.java` | 跨模块租赁关联引用 | `TaxsourceMetaMapInfo` | 按类名和包路径定位，需结合源码确认 | `getTaxSourceEnum()`, `getMapMeta()`, `getTaxsourceNumberKey()`, `valueOfTaxsourceType()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\opservice\loancontractbill\LoanContractBillUnAuditService.java` | 跨模块租赁关联引用 | `LoanContractBillUnAuditService` | 合同审核服务 | `getSelector()`, `process()`, `beforeCommit()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\opservice\repaymentbill\RepaymentBillSuretyRepayCancelService.java` | 跨模块租赁关联引用 | `RepaymentBillSuretyRepayCancelService` | 服务 | `getSelector()`, `process()`, `beforeCommit()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\service\repay\RepayServiceHelper.java` | 跨模块租赁关联引用 | `RepayServiceHelper` | 服务辅助 | `returnCreditLimit()`, `returnCreditLimitFromCfm()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\service\repay\SuretyRepayForSdkService.java` | 跨模块租赁关联引用 | `SuretyRepayForSdkService` | 服务 | `doProcess()`, `doBeforeCommit()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\validate\contractapply\ContractApplyUnAuditValidator.java` | 跨模块租赁关联引用 | `ContractApplyUnAuditValidator` | 合同审核校验器 | `getSelector()`, `validate()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\validate\loancontractbill\LoanContractBillSubmitValidator.java` | 跨模块租赁关联引用 | `LoanContractBillSubmitValidator` | 合同提交校验器 | `getSelector()`, `validate()`, `getOpVatidateName()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\business\validate\loancontractbill\LoanContractBillUnAuditValidator.java` | 跨模块租赁关联引用 | `LoanContractBillUnAuditValidator` | 合同审核校验器 | `getSelector()`, `validate()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\constant\CfmEntityConst.java` | 跨模块租赁关联引用 | `CfmEntityConst` | 按类名和包路径定位，需结合源码确认 | `isContractBill()`, `isLeaseContractBill()`, `isLoanBill()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\enums\CfmEntityEnum.java` | 跨模块租赁关联引用 | `CfmEntityEnum` | 按类名和包路径定位，需结合源码确认 | `getValue()`, `getName()`, `isInterestBill()`, `getEnumByValue()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\BusinessHelper.java` | 跨模块租赁关联引用 | `BusinessHelper` | 辅助 | `delPushRecPayBill()`, `fillConfirmInfo()`, `clearConfirmInfo()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\CfmContractBillHelper.java` | 跨模块租赁关联引用 | `CfmContractBillHelper` | 合同辅助 | `setLoanApplyBillConfirmStatus()`, `resetApplyBillConfirmStatus()`, `setDrawPlanOrder()`, `getTargetPriorityBillStautsApplyBill()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\ContractApplyHelper.java` | 跨模块租赁关联引用 | `ContractApplyHelper` | 合同辅助 | `queryLoanContractBill()`, `queryRepaymentBills()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\CreditLimitHelper.java` | 跨模块租赁关联引用 | `CreditLimitHelper` | 辅助 | `getCreditUseBill()`, `getCreditUseCollection()`, `getDynFormMultiple()`, `deleteCreditUse()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\FormParameterHelper.java` | 跨模块租赁关联引用 | `FormParameterHelper` | 辅助 | `getBizTypes()`, `containsKey()`, `getContractFormIdByBizType()`, `getLoanBillFormByBizType()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\common\helper\SyncDrawHelper.java` | 跨模块租赁关联引用 | `SyncDrawHelper` | 辅助 | `handleSyncDraw()`, `handleSyncDrawForBond()`, `unsubmitAndDeleteLoanBill()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\bill\FeeDetailTabEdit.java` | 跨模块租赁关联引用 | `FeeDetailTabEdit` | 编辑 | `getBizBillFeeAmtFieldProp()`, `getBizBillCurrencyFieldProp()`, `isLoanOrCreditOrPresentFee()`, `afterBindData()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\common\AttachmentViewList.java` | 跨模块租赁关联引用 | `AttachmentViewList` | 列表 | `afterDoOperation()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractapply\ContractApplyEdit.java` | 跨模块租赁关联引用 | `ContractApplyEdit` | 合同编辑 | `registerListener()`, `afterCreateNewData()`, `afterBindData()`, `beforeDoOperation()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractBaseEdit.java` | 跨模块租赁关联引用 | `ContractBaseEdit` | 合同编辑 | `preOpenForm()`, `afterBindData()`, `afterCreateNewData()`, `afterCopyData()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractBaseList.java` | 跨模块租赁关联引用 | `ContractBaseList` | 合同列表 | `preOpenForm()`, `setFilter()`, `beforeShowBill()`, `filterContainerBeforeF7Select()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractCreditLimitPlugin.java` | 跨模块租赁关联引用 | `ContractCreditLimitPlugin` | 合同插件 | `getBizPropertys()`, `getCreditTypeId()`, `setCreditRatio()`, `getCreditVariety()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractCreditorDebtorEdit.java` | 跨模块租赁关联引用 | `ContractCreditorDebtorEdit` | 合同编辑 | `registerListener()`, `beforeF7Select()`, `propertyChanged()`, `getTypePropName()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractDrawLoanApplyEdit.java` | 跨模块租赁关联引用 | `ContractDrawLoanApplyEdit` | 合同编辑 | `registerListener()`, `beforeClick()`, `click()`, `propertyChanged()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractListDataProvider.java` | 跨模块租赁关联引用 | `ContractListDataProvider` | 合同列表 | `getParentData()`, `getData()`, `addDynamicProp()`, `setNoFixedTerm()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractSuretyBizEntryEdit.java` | 跨模块租赁关联引用 | `ContractSuretyBizEntryEdit` | 合同编辑 | `afterBindData()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\ContractSuretyBizList.java` | 跨模块租赁关联引用 | `ContractSuretyBizList` | 合同列表 | `checkBeforeSurety()`, `afterBindData()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\contractbill\LoanContractHistoryPlugin.java` | 跨模块租赁关联引用 | `LoanContractHistoryPlugin` | 合同插件 | `getEntryNameAndEntryKey()`, `initModifyInfo()`, `getModifyTabName()`, `getModifyEntryName()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\home\DebtServiceWarnPlugin.java` | 跨模块租赁关联引用 | `DebtServiceWarnPlugin` | 服务插件 | `registerListener()`, `afterCreateNewData()`, `beforeF7Select()`, `propertyChanged()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\formplugin\repayapply\RepayApplyBillEdit.java` | 跨模块租赁关联引用 | `RepayApplyBillEdit` | 编辑 | `registerListener()`, `afterBindData()`, `afterCreateNewData()`, `propertyChanged()` |
| `biz\tmc-cfm\src\main\java\kd\tmc\cfm\report\helper\ReportCommonHelper.java` | 跨模块租赁关联引用 | `ReportCommonHelper` | 报表辅助 | `transQueryParam()`, `verifyQueryFilter()`, `rebuildColumn()`, `createEmptyDataSet()` |
| `biz\tmc-fbd\src\main\java\kd\tmc\fbd\common\enums\DebtBillTypeEnum.java` | 跨模块租赁关联引用 | `DebtBillTypeEnum` | 按类名和包路径定位，需结合源码确认 | `getValue()`, `getName()` |
| `biz\tmc-fbd\src\main\java\kd\tmc\fbd\formplugin\surety\SuretyBillEdit.java` | 跨模块租赁关联引用 | `SuretyBillEdit` | 编辑 | `registerListener()`, `click()`, `beforeFieldPostBack()`, `closedCallBack()` |
| `biz\tmc-fbd\src\main\java\kd\tmc\fbd\mservice\surety\SuretyService.java` | 跨模块租赁关联引用 | `SuretyService` | 服务 | `generate()`, `confirm()`, `unConfirmValidate()`, `validateBeforeConfirm()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\business\validate\guaranteeuse\GuaranteeUseSaveOrSubmitValidator.java` | 跨模块租赁关联引用 | `GuaranteeUseSaveOrSubmitValidator` | 保存提交校验器 | `getBizProp()`, `getSelector()`, `validate()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\constant\FeeInfoConstant.java` | 跨模块租赁关联引用 | `FeeInfoConstant` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\constant\TmcEntityConst.java` | 跨模块租赁关联引用 | `TmcEntityConst` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\enums\BillMainOrgEnum.java` | 跨模块租赁关联引用 | `BillMainOrgEnum` | 按类名和包路径定位，需结合源码确认 | `getMainOrg()`, `getEnumByEntity()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\enums\GuaDebtBillTypeEnum.java` | 跨模块租赁关联引用 | `GuaDebtBillTypeEnum` | 按类名和包路径定位，需结合源码确认 | `getLoanValues()`, `getFinanceValues()`, `getText()`, `getValue()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\enums\ProductTypeEnum.java` | 跨模块租赁关联引用 | `ProductTypeEnum` | 按类名和包路径定位，需结合源码确认 | `getId()`, `getName()`, `getValue()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\helper\CreditLimitServiceHelper.java` | 跨模块租赁关联引用 | `CreditLimitServiceHelper` | 服务辅助 | `getCreditLimitAvaAmt()`, `confirmCreditLimit()`, `cancelCreditLimit()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\helper\FinanceCostCommonHelper.java` | 跨模块租赁关联引用 | `FinanceCostCommonHelper` | 成本辅助 | `splitBankcateData()`, `getAllViewData()`, `map()`, `getResultRowMeta()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\helper\GuaranteeUseHelper.java` | 跨模块租赁关联引用 | `GuaranteeUseHelper` | 辅助 | `getBizPropName()`, `saveGuaranteeUse()`, `getMultiCreditorFlag()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\helper\SuretyHelper.java` | 跨模块租赁关联引用 | `SuretyHelper` | 辅助 | `getBizPropName()`, `alreadySuretyRepay()`, `setSuretyInfo()`, `setSuretyEntryInfo()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\helper\TmcBusinessBaseHelper.java` | 跨模块租赁关联引用 | `TmcBusinessBaseHelper` | 辅助 | `getBaseCurrency()`, `getCasBaseCurrency()`, `getStandardCurrency()`, `getSystemStatusCtrol()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\common\property\FeeDetailEntryProp.java` | 跨模块租赁关联引用 | `FeeDetailEntryProp` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\formplugin\common\guaranteeuse\CreditLimitLinkGuaranteePlugin.java` | 跨模块租赁关联引用 | `CreditLimitLinkGuaranteePlugin` | 插件 | `afterBindData()`, `propertyChanged()`, `afterImportData()`, `getOrgId()` |
| `biz\tmc-fbp\src\main\java\kd\tmc\fbp\formplugin\common\guaranteeuse\GuaranteeUseBizEntryPlugin.java` | 跨模块租赁关联引用 | `GuaranteeUseBizEntryPlugin` | 插件 | `registerListener()`, `beforeF7Select()`, `convertGuaranteeWay()`, `getBizPropName()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\helper\ContractTransformHelper.java` | 跨模块租赁关联引用 | `ContractTransformHelper` | 合同辅助 | `checkPayPlanChange()`, `checkLeashHoldChange()`, `loadContractDataMap()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\helper\PayPlanUpdateHelper.java` | 跨模块租赁关联引用 | `PayPlanUpdateHelper` | 付款计划辅助 | `updateContractRentPayPlan()`, `updateReceiptPayPlan()`, `loadContracts()`, `isFinLeaseTypeContract()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\contract\init\LeaseContractInitAuditSyncRentPayService.java` | 跨模块租赁关联引用 | `LeaseContractInitAuditSyncRentPayService` | 租赁合同初始化审核租金付款服务 | `getSelector()`, `process()`, `afterProcess()`, `afterProcessRollback()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\contract\init\LeaseContractInitUnAuditService.java` | 跨模块租赁关联引用 | `LeaseContractInitUnAuditService` | 租赁合同初始化审核服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\contract\LeaseContractBillSaveService.java` | 跨模块租赁关联引用 | `LeaseContractBillSaveService` | 租赁合同保存服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\contract\LeaseContractBillUnAuditService.java` | 跨模块租赁关联引用 | `LeaseContractBillUnAuditService` | 租赁合同审核服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\feeshare\LeaseFeeShareAuditService.java` | 跨模块租赁关联引用 | `LeaseFeeShareAuditService` | 租赁审核服务 | `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\feeshare\LeaseFeeShareCalculateService.java` | 跨模块租赁关联引用 | `LeaseFeeShareCalculateService` | 租赁服务 | `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\feeshare\LeaseFeeShareUnAuditService.java` | 跨模块租赁关联引用 | `LeaseFeeShareUnAuditService` | 租赁审核服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\rentplan\RentPlanPushRentPayService.java` | 跨模块租赁关联引用 | `RentPlanPushRentPayService` | 租金计划推送租金付款服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\opservice\transform\ContractTransformAuditService.java` | 跨模块租赁关联引用 | `ContractTransformAuditService` | 合同审核服务 | `getSelector()`, `process()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\resource\FlBusinessResourceEnum.java` | 跨模块租赁关联引用 | `FlBusinessResourceEnum` | 按类名和包路径定位，需结合源码确认 | `loadKDString()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\consistence\ConsistenceSaveValidator.java` | 跨模块租赁关联引用 | `ConsistenceSaveValidator` | 保存校验器 | `getSelector()`, `validate()`, `validateEndDate()`, `validateExpireDate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\consistence\LeaseContractConsistenceSaveValidator.java` | 跨模块租赁关联引用 | `LeaseContractConsistenceSaveValidator` | 租赁合同保存校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\contractbill\init\LeaseContractInitUnAuditValidator.java` | 跨模块租赁关联引用 | `LeaseContractInitUnAuditValidator` | 租赁合同初始化审核校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\contractbill\LeaseContractPayRentValidator.java` | 跨模块租赁关联引用 | `LeaseContractPayRentValidator` | 租赁合同付款租金校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\contractbill\LeaseContractPushRealCardValidator.java` | 跨模块租赁关联引用 | `LeaseContractPushRealCardValidator` | 租赁合同推送卡片校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\contractbill\LeaseContractSubmitValidator.java` | 跨模块租赁关联引用 | `LeaseContractSubmitValidator` | 租赁合同提交校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\feeshare\LeaseFeeShareSubmitValidator.java` | 跨模块租赁关联引用 | `LeaseFeeShareSubmitValidator` | 租赁提交校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\transform\ContractTransformSubmitValidator.java` | 跨模块租赁关联引用 | `ContractTransformSubmitValidator` | 合同提交校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\business\validate\transform\ContractTransformUnAuditValidator.java` | 跨模块租赁关联引用 | `ContractTransformUnAuditValidator` | 合同审核校验器 | `getSelector()`, `validate()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\common\constant\FlEntityConst.java` | 跨模块租赁关联引用 | `FlEntityConst` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\common\helper\LeaseFeeHelper.java` | 跨模块租赁关联引用 | `LeaseFeeHelper` | 租赁辅助 | `getFeeBills()`, `getFeeAmount()`, `getFeeAmountMap()`, `getPayPlans()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\common\helper\RepaymentbillHelper.java` | 跨模块租赁关联引用 | `RepaymentbillHelper` | 辅助 | `cancelReturnGuaranteeUse()`, `batchCancelReturnCreditLimit()`, `getNeedPayAmt()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\common\property\LeaseContractProp.java` | 跨模块租赁关联引用 | `LeaseContractProp` | 租赁合同 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\contractbill\LeaseContractEdit.java` | 跨模块租赁关联引用 | `LeaseContractEdit` | 租赁合同编辑 | `registerListener()`, `afterBindData()`, `propertyChanged()`, `beforeFieldPostBack()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\contractbill\LeaseContractInitEdit.java` | 跨模块租赁关联引用 | `LeaseContractInitEdit` | 租赁合同初始化编辑 | `propertyChanged()`, `afterBindData()`, `beforeDoOperation()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\contractbill\LeaseContractInitList.java` | 跨模块租赁关联引用 | `LeaseContractInitList` | 租赁合同初始化列表 | `setFilter()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\contractbill\LeaseContractList.java` | 跨模块租赁关联引用 | `LeaseContractList` | 租赁合同列表 | `setFilter()`, `filterContainerInit()`, `beforeDoOperation()`, `afterDoOperation()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\convert\LeaseContract2RealCardConvertPlugin.java` | 跨模块租赁关联引用 | `LeaseContract2RealCardConvertPlugin` | 租赁合同卡片插件 | `afterFieldMapping()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\rentpay\RentPayBillEdit.java` | 跨模块租赁关联引用 | `RentPayBillEdit` | 租金付款编辑 | `beforeBindData()`, `afterBindData()`, `afterDoOperation()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\rentplan\RentPlanBillEdit.java` | 跨模块租赁关联引用 | `RentPlanBillEdit` | 租金计划编辑 | `registerListener()`, `afterBindData()`, `beforeF7Select()`, `click()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\rentplan\RentPlanBillImportPlugin.java` | 跨模块租赁关联引用 | `RentPlanBillImportPlugin` | 租金计划导入插件 | `afterDoOperation()`, `confirmCallBack()`, `closedCallBack()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\resource\FlFormResourceEnum.java` | 跨模块租赁关联引用 | `FlFormResourceEnum` | 按类名和包路径定位，需结合源码确认 | `loadKDString()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\transform\ContractTransformApplyEdit.java` | 跨模块租赁关联引用 | `ContractTransformApplyEdit` | 合同编辑 | `registerListener()`, `afterCreateNewData()`, `afterBindData()`, `beforeFieldPostBack()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\formplugin\transform\ContractTransformApplyHighLightEdit.java` | 跨模块租赁关联引用 | `ContractTransformApplyHighLightEdit` | 合同编辑 | `afterBindData()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\mservice\upgrade\auth\OpAuthUpgradeService.java` | 跨模块租赁关联引用 | `OpAuthUpgradeService` | 操作升级服务 | `getAppIdEntNumMapObjList()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\consistence\LeaseContractConsistenceSaveOp.java` | 跨模块租赁关联引用 | `LeaseContractConsistenceSaveOp` | 租赁合同保存操作 | `getBizOppValidator()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\init\LeaseContractInitAuditSyncRentPayOp.java` | 跨模块租赁关联引用 | `LeaseContractInitAuditSyncRentPayOp` | 租赁合同初始化审核租金付款操作 | `getBizOppService()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\init\LeaseContractInitUnAuditOp.java` | 跨模块租赁关联引用 | `LeaseContractInitUnAuditOp` | 租赁合同初始化审核操作 | `getBizOppValidator()`, `getBizOppService()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\LeaseContractBillUnAuditOp.java` | 跨模块租赁关联引用 | `LeaseContractBillUnAuditOp` | 租赁合同审核操作 | `getBizOppService()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\LeaseContractPayRentOp.java` | 跨模块租赁关联引用 | `LeaseContractPayRentOp` | 租赁合同付款租金操作 | `getBizOppValidator()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\LeaseContractPushRealCardOp.java` | 跨模块租赁关联引用 | `LeaseContractPushRealCardOp` | 租赁合同推送卡片操作 | `getBizOppValidator()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\LeaseContractSaveOp.java` | 跨模块租赁关联引用 | `LeaseContractSaveOp` | 租赁合同保存操作 | `getBizOppService()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\contractbill\LeaseContractSubmitOp.java` | 跨模块租赁关联引用 | `LeaseContractSubmitOp` | 租赁合同提交操作 | `getBizOppValidators()`, `getBizOppService()` |
| `biz\tmc-fl\src\main\java\kd\tmc\fl\opplugin\rentplan\RentPlanPushRentPayOp.java` | 跨模块租赁关联引用 | `RentPlanPushRentPayOp` | 租金计划推送租金付款操作 | `getBizOppValidators()`, `getBizOppService()` |
| `biz\tmc-gm\src\main\java\kd\tmc\gm\data\GuaranteeContractDetailDataListPlugin.java` | 跨模块租赁关联引用 | `GuaranteeContractDetailDataListPlugin` | 合同列表插件 | `queryDataSet()`, `reDealResultDataSet()`, `sumNameField()`, `orinalAmountField()` |
| `biz\tmc-gm\src\main\java\kd\tmc\gm\data\GuaranteeContractRptDataListPlugin.java` | 跨模块租赁关联引用 | `GuaranteeContractRptDataListPlugin` | 合同报表列表插件 | `queryDataSet()`, `reDealResultDataSet()`, `orinalAmountField()`, `getResultRowMeta()` |
| `biz\tmc-mon\src\main\java\kd\tmc\mon\common\constans\MonEntityConst.java` | 跨模块租赁关联引用 | `MonEntityConst` | 按类名和包路径定位，需结合源码确认 | 未识别到公开入口（可能为数据/常量/内部实现类） |
| `biz\tmc-mon\src\main\java\kd\tmc\mon\report\form\ExpireBizWarnFormPlugin.java` | 跨模块租赁关联引用 | `ExpireBizWarnFormPlugin` | 插件 | `registerListener()`, `afterCreateNewData()`, `afterBindData()`, `propertyChanged()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\common\extpoint\FinanceLeaseSourceDefaultExt.java` | 跨模块租赁关联引用 | `FinanceLeaseSourceDefaultExt` | 租赁 | `getFormId()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\common\helper\FinanceBatchDataHelper.java` | 跨模块租赁关联引用 | `FinanceBatchDataHelper` | 辅助 | `getSelectfieldsLanguage()`, `getFinanceDataSet()`, `getAllViewData()`, `map()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\common\helper\FinanceDataHelper.java` | 跨模块租赁关联引用 | `FinanceDataHelper` | 辅助 | `getFinanceDataSet()`, `getAllViewData()`, `getLeaseFormId()`, `getQFilter()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\common\helper\RepayPlanHelper.java` | 跨模块租赁关联引用 | `RepayPlanHelper` | 计划辅助 | `handleRepayPlan()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\report\finance\data\FinanceCostDetailDataListPlugin.java` | 跨模块租赁关联引用 | `FinanceCostDetailDataListPlugin` | 成本列表插件 | `getColumnItems()`, `getDataSet()`, `map()`, `getResultRowMeta()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\report\finance\data\FinanceDetailDataListPlugin.java` | 跨模块租赁关联引用 | `FinanceDetailDataListPlugin` | 列表插件 | `getColumnItems()`, `getDataSet()`, `map()`, `getResultRowMeta()` |
| `biz\tmc-tda\src\main\java\kd\tmc\tda\report\gm\helper\GuaranteeReportHelper.java` | 跨模块租赁关联引用 | `GuaranteeReportHelper` | 报表辅助 | `getGuaranteeContractDataSet()`, `test()`, `getFinanceType()` |

## 8. 复核方法与限制

可在 PowerShell 7 复现检索：

```powershell
rg -l -i --glob '*.java' --glob '!**/target/**' 'leaseassets|lease_asset|leaseasset|fa_lease|leasecontract|right.of.use.asset|RIGHT_OF_USE_ASSET' D:\cosmic-src\biz D:\cosmic-src\bos
```

该口径用于发现引用，不等于 100% 的语义归属。尤其 `leasecontract` 可能命中其他产品线的合同对象。若要进一步确认生产环境按钮、页面字段、操作绑定和字段元数据，应把部署实例导出的对应 BOS 元数据、插件注册配置及版本信息与本文 Java 快照逐项对齐。

本文没有执行 Maven 构建或修改源码；验证仅针对源文件存在性、关键字段引用和检索清单完整性。反编译快照不提供完整运行时配置，故未验证真实部署行为。
