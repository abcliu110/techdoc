# DA2 概念字典 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 AP应付管理 SOP-00-DA2-概念字典.md，门禁检查 5 项全部通过（AR镜像）。

---

## 一、核心概念全景卡（GC-01 至 GC-10）

### GC-01：应收单据

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录企业向客户或内部组织应收未收款项的业务单据，是AR模块的核心业务实体 |
| **业务语义** | 应收单据代表企业对外部主体的债权承诺，可分为销售应收、其他应收、预收账款、合同应收四种来源 |
| **数据结构** | AR_RECEIVABLE（表头）+ AR_RECEIVABLEENTRY（分录行） |
| **关键字段** | FBillNo（单据编号）、FBillType（单据类型）、FSetAccountType（核算类型）、FWriteOffStatus（核销状态）、FCustomerID（客户）、FReceivableAmt（应收金额）、FUnWriteOffAmt（未核销金额） |
| **生命周期** | 新增→保存→审核→钩稽确认→核销→收款→关闭 |
| **状态枚举** | 保存/已审核/已核销/已收款/已关闭 |
| **核心操作** | SetAccountType（判断核算类型）、Verify（钩稽确认）、WriteOff（核销）、Receive（收款） |
| **业务规则** | 必须审核后才能核销；SA和其他业务类型采用不同核算逻辑 |
| **相关概念** | 核销记录（GC-05）、钩稽关系（GC-03）、凭证（GL模块） |
| **证据** | ARReceivableEdit.cs:OnLoad/SetAccountType；AR_RECEIVABLE表结构 |

---

### GC-02：核销

| 维度 | 内容 |
|---|---|
| **概念定义** | 将应收单据与收款记录或其他单据进行匹配，抵消双方债权债务关系的过程 |
| **业务语义** | 核销是AR模块的核心结算机制，通过核销确认"这笔钱已经收了"或"这笔债权已经清了"，核销后双方未核销金额相应减少 |
| **核销方式** | 普通核销（FinMatch method=72，自动按金额匹配）、特殊核销（method=73，限制行数组合）、内部核销（InnerClear，组织间往来） |
| **关键字段** | FWriteOffAmt（核销金额）、FWriteOffDate（核销日期）、FWriteOffStatus（核销状态）、FWriteOffType（核销类型） |
| **行数限制（特殊核销）** | 1:1（1行对1行）、1:0（1行对0行，即全额核销）、2:0（2行对0行，但需一正一负） |
| **生命周期** | 选择单据→校验行数→计算金额→确认核销→生成凭证→更新状态 |
| **反核销** | UnVerify返回UnVerifyResultAction，需"反清理"权限，可能产生补偿凭证 |
| **业务规则** | 核销金额不得超过双方未核销金额；核销后更新FWRITTENOFFSTATUS |
| **相关概念** | 核销记录（GC-05）、匹配参数（GC-06）、凭证生成（GC-08） |
| **证据** | ARFinMatch.cs:171-196（行数限制）、MatchServiceHelper.cs（匹配计算）、AR_WRITEOFFRECORD表 |

---

### GC-03：钩稽关系

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录暂收应收单与财务应收单之间对应关系的关联结构，是核销的前置依赖 |
| **业务语义** | 钩稽关系建立了"出库时的暂收"与"发票到达后的财务"之间的对应链路，钩稽确认后两方建立明确的关联，核销才能进行 |
| **数据结构** | Verification表记录钩稽关系，AR_WRITEOFFRECORD记录核销关系，两者构成"确认→核销"的递进链条 |
| **钩稽操作** | Verify（钩稽确认：暂收→财务）、HookReturn（钩稽返回：财务→暂收退回） |
| **关键字段** | FSourceBillID（来源单据ID）、FTargetBillID（目标单据ID）、FVerificationStatus（钩稽状态）、FVerificationAmt（钩稽金额） |
| **生命周期** | 销售出库单审核→暂收凭证→发票审核→钩稽确认→建立关系→核销→关系闭合 |
| **与核销的关系** | 钩稽是核销的前置条件（BR-AR-008），钩稽确认后才能进行核销；核销后钩稽关系变为"已核销"状态 |
| **相关概念** | 核算类型（GC-04）、核销记录（GC-05） |
| **证据** | VerificationServiceHelper.cs:Verify/UnVerify；Verification表结构 |

---

### GC-04：核算类型

| 维度 | 内容 |
|---|---|
| **概念定义** | 应收单据的财务核算阶段标识，决定单据如何参与账务处理 |
| **业务语义** | 核算类型反映了销售业务的两个阶段：暂收阶段（货物出库但发票未开）和财务阶段（发票已开校验完成）。两种类型驱动完全不同的核算逻辑（SA vs 其他业务类型各有嵌套判断） |
| **枚举值** | 暂收=2（出库时生成暂收凭证）、财务=3（发票校验后生成发票凭证）、其他=1 |
| **状态机** | 暂收→财务单向转换（通过钩稽确认触发）；财务→暂收通过钩稽返回 |
| **驱动逻辑** | SetAccountType()根据业务类型（SA销售/其他）判断：SA逻辑与其他业务类型完全不同（ARReceivableEdit.cs核算判断） |
| **触发时机** | 应收单保存时判断；销售出库单审核时生成暂收凭证；销售发票审核时判断为财务 |
| **相关概念** | 应收单据（GC-01）、钩稽关系（GC-03）、凭证生成（GC-08） |
| **证据** | ARReceivableEdit.cs SetAccountType；ARReceivableEdit.cs 业务类型判断 |

---

### GC-05：核销记录

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录一次核销操作详细信息的持久化实体，保存核销双方的单据行对应关系和金额 |
| **业务语义** | AR_WRITEOFFRECORD是核销操作的"账本"，每条记录代表一次核销事务，包含核销双方、金额、日期、凭证关联等信息，支持追溯和反核销 |
| **表结构** | AR_WRITEOFFRECORD（主表）+ AR_WRITEOFFRECORDENTRY（分录行） |
| **关键字段** | FWriteOffRecordID、FSourceBillID（来源单据）、FTargetBillID（目标单据）、FWriteOffAmt（核销金额）、FVoucherID（关联凭证ID）、FWriteOffDate（核销日期）、FWriteOffType（核销类型） |
| **行级粒度** | 核销记录以单据行为单位，一条记录对应一对一行；特殊核销（method=73）支持多行对一行的复杂组合 |
| **生命周期** | 核销操作创建→凭证生成关联→查询追溯→反核销撤销 |
| **反核销关联** | 反核销时返回UnVerifyResultAction，包含补偿凭证生成指令和状态恢复指令 |
| **相关概念** | 核销（GC-02）、凭证生成（GC-08）、内部核销（GC-07） |
| **证据** | ARFinMatch.cs:FinMatchProcess；MatchServiceHelper.cs；AR_WRITEOFFRECORD表结构 |

---

### GC-06：匹配参数

| 维度 | 内容 |
|---|---|
| **概念定义** | 控制核销匹配行为的配置参数，决定如何选择、排序和组合待核销单据 |
| **业务语义** | 不同的匹配参数组合决定了核销的范围（哪些单据可以互相核销）、方式（自动还是手动）、精度（允许的金额容差） |
| **核销方法** | iFinMatchMethod=72（普通核销，按金额自动匹配）、iFinMatchMethod=73（特殊核销，限制行数组合） |
| **关键参数** | FMatchMethod（匹配方法）、FOrgID（组织）、FBillType（单据类型）、FCustomerID（客户）、FDateRange（日期范围）、FRowLimit（行数限制） |
| **金额计算** | 未核销金额=应收金额-已核销金额-预收款核销金额；MatchServiceHelper计算双方金额 |
| **行数组合规则（method=73）** | 1行对1行、1行对0行、2行对0行（正负配对）；不允许3行以上对0行 |
| **过滤条件** | 仅相同客户、相同组织、相同币别、相同业务类型的单据可核销 |
| **相关概念** | 核销（GC-02）、核销记录（GC-05） |
| **证据** | ARFinMatch.cs:171-196 FinMatchProcess；MatchServiceHelper.cs Calculate方法 |

---

### GC-07：内部应收核销

| 维度 | 内容 |
|---|---|
| **概念定义** | 处理同一企业不同组织（责任中心）之间应收应付往来抵消的特殊核销机制 |
| **业务语义** | 内部核销解决了集团内部组织间的往来清零问题，不同于普通核销（企业与外部客户），内部核销在组织维度上执行抵消，生成内部抵消凭证 |
| **适用范围** | 仅限于同一账套内同体系（上下级）组织间的往来；不允许跨账套或不同体系组织 |
| **表结构** | AR_InnerIVRecord（内部应收记录）、AR_InnerAPRecord（内部应付记录）、AR_InnerClearRecord（内部核销记录） |
| **关键字段** | FInnerOrgID（内部组织ID）、FClearAmt（核销金额）、FClearType（核销类型） |
| **业务流程** | 1.录入内部应收单（向内部组织销售）；2.录入内部应付单（向内部组织采购）；3.执行内部核销；4.生成内部抵消凭证 |
| **权限要求** | InnerClearRecordEdit.cs:54-67，需要"反清理"权限进行反核销 |
| **与普通核销的区别** | 内部核销处理组织间往来，普通核销处理外部往来；内部核销生成内部抵消凭证，普通核销生成标准核销凭证 |
| **相关概念** | 核销（GC-02）、核销记录（GC-05） |
| **证据** | ARInnerIVSpecialMatchEdit.cs；AR_InnerIVRecord/AR_InnerAPRecord表结构 |

---

### GC-08：凭证生成方案

| 维度 | 内容 |
|---|---|
| **概念定义** | 将业务单据自动转换为财务凭证的配置模板，采用"方案+映射"双轨模式 |
| **业务语义** | 凭证生成方案定义了业务事件（如发票审核、核销完成）如何转换为记账凭证，方案决定分录模板，映射决定具体科目，业务单据的字段值通过映射规则填充分录 |
| **数据结构** | BizVchMakeScheme（方案模板）+ BAS_BusinessVoucher（单据-凭证映射） |
| **双轨模式** | Scheme层：定义分录结构（借方/贷方科目、数额来源、核算维度）；Mapping层：将Scheme应用到具体单据时，确定具体科目代码 |
| **触发时机** | 暂收凭证（销售出库审核时）、发票校验凭证（发票审核时）、核销凭证（核销完成时）、收款凭证（收款完成时） |
| **关键字段** | FSchemeID（方案ID）、FVchTemplateID（凭证模板ID）、FACCOUNTID（科目）、FBillType（单据类型）、FBizEvent（业务事件） |
| **BAS_BusinessVoucher映射** | 多对多映射：一个业务单据可生成多张凭证；一张凭证可来自多个业务单据 |
| **凭证生成服务** | VoucherGenerateServiceHelper.cs提供Generate方法，支持Floating窗口异步生成 |
| **相关概念** | 应收单据（GC-01）、核算类型（GC-04）、GL模块凭证 |
| **证据** | VoucherGenerateServiceHelper.cs；BizVchMakeScheme表结构；BAS_BusinessVoucher表 |

---

### GC-09：账龄分析

| 维度 | 内容 |
|---|---|
| **概念定义** | 基于应收单据的未核销金额和到期日期，按账龄区间统计逾期账款的分析方法 |
| **业务语义** | 账龄分析是AR模块的风险管控工具，帮助财务人员了解"哪些客户的款项逾期了、逾期多久了"，为收款优先级和资金安排提供依据 |
| **分析维度** | 客户维度（哪个客户）、组织维度（哪个责任中心）、业务类型维度（销售/其他）、到期日期维度 |
| **账龄区间** | 0-30天、31-60天、61-90天、90天以上四级（或自定义区间） |
| **计算逻辑** | ReceivableBillReport.cs按"到期日期"分组，按"未核销金额"求和，逾期天数=当前日期-到期日期 |
| **数据来源** | AR_RECEIVABLE.FUnWriteOffAmt（未核销金额）、AR_RECEIVABLE.FDueDate（到期日期）、AR_RECEIVABLE.FCustomerID（客户） |
| **核心报表** | ReceivableBillBalRpt（应收余额明细）、ReceivableBillReport（应收账龄）、ReceivableAgingReport（到期债权分析）、ReceivableSumReport（客户汇总） |
| **相关概念** | 应收单据（GC-01）、核销（GC-02） |
| **证据** | ReceivableBillReport.cs；ReceivableBillBalRpt.cs；AR_RECEIVABLE表FUnWriteOffAmt字段 |

---

### GC-10：客户

| 维度 | 内容 |
|---|---|
| **概念定义** | 与企业发生销售业务或服务往来的外部主体，是AR模块的核心业务主数据 |
| **业务语义** | 客户是应收单据的债务主体，核销、收款、账龄分析均以客户为关键维度组织数据 |
| **在AR中的角色** | 应收单据的债务方；账龄分析的第一维度；核销匹配的过滤条件（仅同客户可核销）；收款指令的来源方 |
| **关键属性** | FCustomerID（客户ID）、FCustomerName（名称）、FCustomerCode（编码）、FAccountID（应收科目）、FCreditTerm（信用条件）、FCreditLimit（信用额度） |
| **客户档案** | 客户主数据（BD_Customer）与AR_RECEIVABLE通过FCustomerID关联 |
| **在核销中的约束** | BR-AR-004：核销匹配时，仅允许相同客户的单据互相核销 |
| **相关概念** | 应收单据（GC-01）、核销（GC-02）、账龄分析（GC-09） |
| **证据** | BD_Customer表；AR_RECEIVABLE.FCustomerID字段；ARReceivableEdit.cs客户关联逻辑 |

---

## 二、概念关系索引

```
应收单据(GC-01) ──持有──▶ 核算类型(GC-04)
    │                        │
    │                        └─触发──▶ 凭证生成方案(GC-08)
    │
    ├─通过──▶ 钩稽关系(GC-03) ──前置──▶ 核销(GC-02)
    │
    ├─生成──▶ 核销记录(GC-05)
    │               │
    │               ├─依赖──▶ 匹配参数(GC-06)
    │               │
    │               └─触发──▶ 凭证生成方案(GC-08)
    │
    ├─收款──▶ 客户(GC-10)
    │
    ├─独有──▶ 收付款认领(GC-11)
    │
    └─分析──▶ 账龄分析(GC-09)
                    │
                    └─依赖──▶ 客户(GC-10)

内部应收核销(GC-07) ──特殊──▶ 核销(GC-02)
     │
     └─涉及──▶ 客户(GC-10)（内部组织作为特殊客户）
```

---

## 三、概念稳定性矩阵

| 概念 | 稳定性等级 | 变化驱动因素 | 估算变化频率 |
|---|---|---|---|
| GC-01 应收单据 | ★★★★★ 极高 | 业务实体不变化 | 极低 |
| GC-02 核销 | ★★★★★ 极高 | 结算机制不变化 | 极低 |
| GC-03 钩稽关系 | ★★★★☆ 高 | 业务流程固化 | 低 |
| GC-04 核算类型 | ★★★★☆ 高 | 会计准则不变化 | 低 |
| GC-05 核销记录 | ★★★★☆ 高 | 记录机制不变化 | 低 |
| GC-06 匹配参数 | ★★★☆☆ 中 | 业务策略可调 | 中 |
| GC-07 内部应收核销 | ★★★☆☆ 中 | 组织架构变化 | 中 |
| GC-08 凭证生成方案 | ★★☆☆☆ 低 | 配置灵活可变 | 高 |
| GC-09 账龄分析 | ★★★☆☆ 中 | 报表需求变化 | 中 |
| GC-10 客户 | ★★★★☆ 高 | 主数据稳定 | 低 |

---

## 四、概念-源码映射

| 概念 | 源码类/文件 | 核心方法 |
|---|---|---|
| GC-01 应收单据 | ARReceivableEdit.cs | SetAccountType(), OnLoad() |
| GC-02 核销 | ARFinMatch.cs | FinMatchProcess() |
| GC-03 钩稽关系 | VerificationServiceHelper.cs | Verify(), UnVerify() |
| GC-04 核算类型 | ARReceivableEdit.cs | SetAccountType() SA/其他判断 |
| GC-05 核销记录 | MatchServiceHelper.cs | Match(), Calculate() |
| GC-06 匹配参数 | ARFinMatch.cs:171-196 | 行数限制校验 |
| GC-07 内部应收核销 | ARInnerIVSpecialMatchEdit.cs | InnerMatchProcess() |
| GC-08 凭证生成方案 | VoucherGenerateServiceHelper.cs | Generate() |
| GC-09 账龄分析 | ReceivableBillReport.cs | AgingCalculate() |
| GC-10 客户 | ARReceivableEdit.cs | FCustomerID关联 |

---

## 五、AR独有概念补充

### GC-11：收付款认领（AR独有）

| 维度 | 内容 |
|---|---|
| **概念定义** | AR模块独有的客户对账与自动匹配机制，允许按客户维度自动匹配应收单据和收款记录 |
| **业务语义** | 当客户付款后，出纳在收付款认领界面选择客户和收款，系统自动匹配该客户名下的应收单据，确认认领后更新未核销金额 |
| **触发方式** | 收款单审核后可选；BillRecReport.cs处理认领逻辑 |
| **与核销的关系** | 收付款认领是核销的前置操作，认领后执行正式核销 |
| **核心报表** | ReceivableBillBalRpt（应收余额）、BillRecReport（认领报表） |
| **相关概念** | 核销（GC-02）、收款（GC-10） |
| **证据** | BillRecReport.cs；ReceivableBillBalRpt.cs |
