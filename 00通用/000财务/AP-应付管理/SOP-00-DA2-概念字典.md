# DA2 概念字典 — K3Cloud AP应付管理模块

## 模板加载记录
已读取 SOP-00-DA2-模板.md，门禁检查 5 项全部通过。

---

## 一、核心概念全景卡（GC-01 至 GC-10）

### GC-01：应付单据

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录企业对供应商或员工应付未付款项的业务单据，是AP模块的核心业务实体 |
| **业务语义** | 应付单据代表企业对外部主体的债务承诺，可分为采购应付、费用应付、其他应付、合同应付四种来源 |
| **数据结构** | AP_PAYABLE（表头）+ AP_PAYABLEENTRY（分录行） |
| **关键字段** | FBillNo（单据编号）、FBillType（单据类型）、FSetAccountType（核算类型）、FWriteOffStatus（核销状态）、FSupplierID（供应商）、FPayableAmt（应付金额）、FUnWriteOffAmt（未核销金额）、FRemainPayAmt（剩余付款金额） |
| **生命周期** | 新增→保存→审核→钩稽确认→核销→付款→关闭 |
| **状态枚举** | 保存/已审核/已核销/已付款/已关闭 |
| **核心操作** | SetAccountType（判断核算类型）、Verify（钩稽确认）、WriteOff（核销）、Pay（付款） |
| **业务规则** | 必须审核后才能核销；CG和FY采用不同核算逻辑 |
| **相关概念** | 核销记录（GC-05）、钩稽关系（GC-03）、凭证（GL模块） |
| **证据** | PayableEdit.cs:OnLoad/SetAccountType；AP_PAYABLE表结构 |

---

### GC-02：核销

| 维度 | 内容 |
|---|---|
| **概念定义** | 将应付单据与付款记录或其他单据进行匹配，抵消双方债权债务关系的过程 |
| **业务语义** | 核销是AP模块的核心结算机制，通过核销确认"这笔钱已经付了"或"这笔债已经清了"，核销后双方未核销金额相应减少 |
| **核销方式** | 普通核销（FinMatch method=72，自动按金额匹配）、特殊核销（method=73，限制行数组合）、内部核销（InnerClear，组织间往来） |
| **关键字段** | FWriteOffAmt（核销金额）、FWriteOffDate（核销日期）、FWriteOffStatus（核销状态）、FWriteOffType（核销类型） |
| **行数限制（特殊核销）** | 1:1（1行对1行）、1:0（1行对0行，即全额核销）、2:0（2行对0行，但需一正一负） |
| **生命周期** | 选择单据→校验行数→计算金额→确认核销→生成凭证→更新状态 |
| **反核销** | UnVerify返回UnVerifyResultAction，需"反清理"权限，可能产生补偿凭证 |
| **业务规则** | 核销金额不得超过双方未核销金额；核销后更新FWRITTENOFFSTATUS |
| **相关概念** | 核销记录（GC-05）、匹配参数（GC-06）、凭证生成（GC-08） |
| **证据** | FinMatch.cs:171-196（行数限制）、MatchServiceHelper.cs（匹配计算）、AP_WRITEOFFRECORD表 |

---

### GC-03：钩稽关系

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录暂估应付单与财务应付单之间对应关系的关联结构，是核销的前置依赖 |
| **业务语义** | 钩稽关系建立了"入库时的暂估"与"发票到达后的财务"之间的对应链路，钩稽确认后两方建立明确的关联，核销才能进行 |
| **数据结构** | Verification表记录钩稽关系，AP_WRITEOFFRECORD记录核销关系，两者构成"确认→核销"的递进链条 |
| **钩稽操作** | Verify（钩稽确认：暂估→财务）、HookReturn（钩稽返回：财务→暂估退回） |
| **关键字段** | FSourceBillID（来源单据ID）、FTargetBillID（目标单据ID）、FVerificationStatus（钩稽状态）、FVerificationAmt（钩稽金额） |
| **生命周期** | 发票审核→判断核算类型→自动或手动钩稽→建立关系→核销→关系闭合 |
| **与核销的关系** | 钩稽是核销的前置条件（BR-AP-008），钩稽确认后才能进行核销；核销后钩稽关系变为"已核销"状态 |
| **相关概念** | 核算类型（GC-04）、核销记录（GC-05） |
| **证据** | VerificationServiceHelper.cs:Verify/UnVerify；Verification表结构 |

---

### GC-04：核算类型

| 维度 | 内容 |
|---|---|
| **概念定义** | 应付单据的财务核算阶段标识，决定单据如何参与账务处理 |
| **业务语义** | 核算类型反映了采购业务的两个阶段：暂估阶段（货物入库但发票未到）和财务阶段（发票到达校验完成）。两种类型驱动完全不同的核算逻辑（CG vs FY各有70+层嵌套if-else） |
| **枚举值** | 暂估=2（入库时生成暂估凭证）、财务=3（发票校验后生成发票凭证）、其他=1 |
| **状态机** | 暂估→财务单向转换（通过钩稽确认触发）；财务→暂估通过钩稽返回 |
| **驱动逻辑** | SetAccountType()根据业务类型（CG采购/FY费用）判断：CG逻辑与FY逻辑完全不同（PayableEdit.cs:643-715） |
| **触发时机** | 应付单保存时判断；采购入库单审核时生成暂估凭证；采购发票审核时判断为财务 |
| **相关概念** | 应付单据（GC-01）、钩稽关系（GC-03）、凭证生成（GC-08） |
| **证据** | PayableEdit.cs:643-715 SetAccountType；PayableEdit.cs:业务类型判断 |

---

### GC-05：核销记录

| 维度 | 内容 |
|---|---|
| **概念定义** | 记录一次核销操作详细信息的持久化实体，保存核销双方的单据行对应关系和金额 |
| **业务语义** | AP_WRITEOFFRECORD是核销操作的"账本"，每条记录代表一次核销事务，包含核销双方、金额、日期、凭证关联等信息，支持追溯和反核销 |
| **表结构** | AP_WRITEOFFRECORD（主表）+ AP_WRITEOFFRECORDENTRY（分录行） |
| **关键字段** | FWriteOffRecordID、FSourceBillID（来源单据）、FTargetBillID（目标单据）、FWriteOffAmt（核销金额）、FVoucherID（关联凭证ID）、FWriteOffDate（核销日期）、FWriteOffType（核销类型） |
| **行级粒度** | 核销记录以单据行为单位，一条记录对应一对一行；特殊核销（method=73）支持多行对一行的复杂组合 |
| **生命周期** | 核销操作创建→凭证生成关联→查询追溯→反核销撤销 |
| **反核销关联** | 反核销时返回UnVerifyResultAction，包含补偿凭证生成指令和状态恢复指令 |
| **相关概念** | 核销（GC-02）、凭证生成（GC-08）、内部核销（GC-07） |
| **证据** | FinMatch.cs:FinMatchProcess；MatchServiceHelper.cs；AP_WRITEOFFRECORD表结构 |

---

### GC-06：匹配参数

| 维度 | 内容 |
|---|---|
| **概念定义** | 控制核销匹配行为的配置参数，决定如何选择、排序和组合待核销单据 |
| **业务语义** | 不同的匹配参数组合决定了核销的范围（哪些单据可以互相核销）、方式（自动还是手动）、精度（允许的金额容差） |
| **核销方法** | iFinMatchMethod=72（普通核销，按金额自动匹配）、iFinMatchMethod=73（特殊核销，限制行数组合） |
| **关键参数** | FMatchMethod（匹配方法）、FOrgID（组织）、FBillType（单据类型）、FSupplierID（供应商）、FDateRange（日期范围）、FRowLimit（行数限制） |
| **金额计算** | 未核销金额=应付金额-已核销金额-预付款核销金额；MatchServiceHelper计算双方金额 |
| **行数组合规则（method=73）** | 1行对1行、1行对0行、2行对0行（正负配对）；不允许3行以上对0行 |
| **过滤条件** | 仅相同供应商、相同组织、相同币别、相同业务类型的单据可核销 |
| **相关概念** | 核销（GC-02）、核销记录（GC-05） |
| **证据** | FinMatch.cs:171-196 FinMatchProcess；MatchServiceHelper.cs Calculate方法 |

---

### GC-07：内部核销

| 维度 | 内容 |
|---|---|
| **概念定义** | 处理同一企业不同组织（责任中心）之间应收应付往来抵消的特殊核销机制 |
| **业务语义** | 内部核销解决了集团内部组织间的往来清零问题，不同于普通核销（企业与外部供应商），内部核销在组织维度上执行抵消，生成内部抵消凭证 |
| **适用范围** | 仅限于同一账套内同体系（上下级）组织间的往来；不允许跨账套或不同体系组织 |
| **表结构** | AP_InnerIVRecord（内部应收记录）、AP_InnerPayRecord（内部应付记录）、AP_InnerClearRecord（内部核销记录） |
| **关键字段** | FInnerOrgID（内部组织ID）、FClearAmt（核销金额）、FClearType（核销类型） |
| **业务流程** | 1.录入内部应收单（向内部组织销售）；2.录入内部应付单（向内部组织采购）；3.执行内部核销；4.生成内部抵消凭证 |
| **权限要求** | InnerClearRecordEdit.cs:54-67，需要"反清理"权限进行反核销 |
| **与普通核销的区别** | 内部核销处理组织间往来，普通核销处理外部往来；内部核销生成内部抵消凭证，普通核销生成标准核销凭证 |
| **相关概念** | 核销（GC-02）、核销记录（GC-05） |
| **证据** | InnerClearRecordEdit.cs；AP_InnerIVRecord/AP_InnerPayRecord表结构 |

---

### GC-08：凭证生成方案

| 维度 | 内容 |
|---|---|
| **概念定义** | 将业务单据自动转换为财务凭证的配置模板，采用"方案+映射"双轨模式 |
| **业务语义** | 凭证生成方案定义了业务事件（如发票审核、核销完成）如何转换为记账凭证，方案决定分录模板，映射决定具体科目，业务单据的字段值通过映射规则填充分录 |
| **数据结构** | BizVchMakeScheme（方案模板）+ BAS_BusinessVoucher（单据-凭证映射） |
| **双轨模式** | Scheme层：定义分录结构（借方/贷方科目、数额来源、核算维度）；Mapping层：将Scheme应用到具体单据时，确定具体科目代码 |
| **触发时机** | 暂估凭证（采购入库审核时）、发票校验凭证（发票审核时）、核销凭证（核销完成时）、付款凭证（付款完成时） |
| **关键字段** | FSchemeID（方案ID）、FVchTemplateID（凭证模板ID）、FACCOUNTID（科目）、FBillType（单据类型）、FBizEvent（业务事件） |
| **BAS_BusinessVoucher映射** | 多对多映射：一个业务单据可生成多张凭证；一张凭证可来自多个业务单据（如合并开票场景） |
| **凭证生成服务** | VoucherGenerateServiceHelper.cs提供Generate方法，支持Floating窗口异步生成 |
| **相关概念** | 应付单据（GC-01）、核算类型（GC-04）、GL模块凭证 |
| **证据** | VoucherGenerateServiceHelper.cs；BizVchMakeScheme表结构；BAS_BusinessVoucher表 |

---

### GC-09：账龄分析

| 维度 | 内容 |
|---|---|
| **概念定义** | 基于应付单据的未核销金额和到期日期，按账龄区间统计逾期账款的分析方法 |
| **业务语义** | 账龄分析是AP模块的风险管控工具，帮助财务人员了解"哪些供应商的款项逾期了、逾期多久了"，为付款优先级和资金安排提供依据 |
| **分析维度** | 供应商维度（哪个供应商）、组织维度（哪个责任中心）、业务类型维度（采购/费用）、到期日期维度 |
| **账龄区间** | 0-30天、31-60天、61-90天、90天以上四级（或自定义区间） |
| **计算逻辑** | AgingAnalysis.cs按"到期日期"分组，按"未核销金额"求和，逾期天数=当前日期-到期日期 |
| **数据来源** | AP_PAYABLE.FUnWriteOffAmt（未核销金额）、AP_PAYABLE.FDueDate（到期日期）、AP_PAYABLE.FSupplierID（供应商） |
| **核心报表** | PayableOpenDetail（应付余额明细）、AgingAnalysis（账龄分析）、MaturedDebt（到期债务分析）、APSumReport（供应商汇总） |
| **相关概念** | 应付单据（GC-01）、核销（GC-02） |
| **证据** | AgingAnalysis.cs；PayableOpenDetail.cs；AP_PAYABLE表FUnWriteOffAmt字段 |

---

### GC-10：供应商

| 维度 | 内容 |
|---|---|
| **概念定义** | 与企业发生采购业务或费用往来的外部主体，是AP模块的核心业务主数据 |
| **业务语义** | 供应商是应付单据的债务主体，核销、付款、账龄分析均以供应商为关键维度组织数据 |
| **在AP中的角色** | 应付单据的债权方；账龄分析的第一维度；核销匹配的过滤条件（仅同供应商可核销）；付款指令的接收方 |
| **关键属性** | FSupplierID（供应商ID）、FSupplierName（名称）、FSupplierCode（编码）、FAccountID（应付科目）、FPaymentTerm（付款条件）、FCreditLimit（信用额度） |
| **供应商档案** | 供应商主数据（BD_Supplier）与AP_PAYABLE通过FSupplierID关联 |
| **在核销中的约束** | BR-AP-004：核销匹配时，仅允许相同供应商的单据互相核销 |
| **相关概念** | 应付单据（GC-01）、核销（GC-02）、账龄分析（GC-09） |
| **证据** | BD_Supplier表；AP_PAYABLE.FSupplierID字段；PayableEdit.cs供应商关联逻辑 |

---

## 二、概念关系索引

```
应付单据(GC-01) ──持有──▶ 核算类型(GC-04)
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
    ├─付款──▶ 供应商(GC-10)
    │
    └─分析──▶ 账龄分析(GC-09)
                    │
                    └─依赖──▶ 供应商(GC-10)

内部核销(GC-07) ──特殊──▶ 核销(GC-02)
     │
     └─涉及──▶ 供应商(GC-10)（内部组织作为特殊供应商）
```

---

## 三、概念稳定性矩阵

| 概念 | 稳定性等级 | 变化驱动因素 | 估算变化频率 |
|---|---|---|---|
| GC-01 应付单据 | ★★★★★ 极高 | 业务实体不变化 | 极低 |
| GC-02 核销 | ★★★★★ 极高 | 结算机制不变化 | 极低 |
| GC-03 钩稽关系 | ★★★★☆ 高 | 业务流程固化 | 低 |
| GC-04 核算类型 | ★★★★☆ 高 | 会计准则不变化 | 低 |
| GC-05 核销记录 | ★★★★☆ 高 | 记录机制不变化 | 低 |
| GC-06 匹配参数 | ★★★☆☆ 中 | 业务策略可调 | 中 |
| GC-07 内部核销 | ★★★☆☆ 中 | 组织架构变化 | 中 |
| GC-08 凭证生成方案 | ★★☆☆☆ 低 | 配置灵活可变 | 高 |
| GC-09 账龄分析 | ★★★☆☆ 中 | 报表需求变化 | 中 |
| GC-10 供应商 | ★★★★☆ 高 | 主数据稳定 | 低 |

---

## 四、概念-源码映射

| 概念 | 源码类/文件 | 核心方法 |
|---|---|---|
| GC-01 应付单据 | PayableEdit.cs | SetAccountType(), OnLoad() |
| GC-02 核销 | FinMatch.cs | FinMatchProcess() |
| GC-03 钩稽关系 | VerificationServiceHelper.cs | Verify(), UnVerify() |
| GC-04 核算类型 | PayableEdit.cs:643-715 | SetAccountType() CG/FY判断 |
| GC-05 核销记录 | MatchServiceHelper.cs | Match(), Calculate() |
| GC-06 匹配参数 | FinMatch.cs:171-196 | 行数限制校验 |
| GC-07 内部核销 | InnerClearRecordEdit.cs | InnerClearProcess() |
| GC-08 凭证生成方案 | VoucherGenerateServiceHelper.cs | Generate() |
| GC-09 账龄分析 | AgingAnalysis.cs | AgingCalculate() |
| GC-10 供应商 | PayableEdit.cs | FSupplierID关联 |
