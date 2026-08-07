# EVIDENCE-证据索引 — K3Cloud CN票据管理模块

---

## 一、证据来源汇总

| 证据ID | 类型 | 来源文件 | 关键内容 |
|---|---|---|---|
| E-DOC-001 | DOC | 金蝶K3Cloud财务系统全功能深度分析.md §5.3 | CN模块27个文件、票据报表结构 |
| E-DOC-002 | DOC | 金蝶K3Cloud财务系统全功能深度分析.md §5.5 | CNOpenServiceHelper期初开账 |
| E-DOC-003 | DOC | 金蝶K3Cloud财务系统业务模型全面分析.md | CN_RECEIVEBILL/CN_PAYBILL表结构 |
| E-DOC-004 | DOC | 金蝶K3Cloud财务系统全功能深度分析.md §2.1 | 源码边界说明 |
| E-DOC-005 | DOC | 金蝶K3Cloud财务系统全功能深度分析.md §1.3 | 模块交互关系 |

---

## 二、源码位置索引

### 2.1 报表层

| 类/文件名 | 路径 | 职责 | 关键方法 |
|---|---|---|---|
| ReceivableBillBalRpt | CN.App.Report | 应收票据余额报表 | 余额汇总计算 |
| ReceivableBillExcReport | CN.App.Report | 应收票据执行流水 | 状态变更历史 |
| ReceivableBillTransactReport | CN.App.Report | 应收票据收发存 | 增减变动计算 |
| BillRecReport | CN.App.Report | 应收票据使用流水 | 核销记录查询 |
| PayBillBalReport | CN.App.Report | 应付票据余额报表 | 余额汇总计算 |
| ReceivableBillReportBase | CN.App.Report | 应收票据报表基类 | 公共取数逻辑 |
| PayBillReportBase | CN.App.Report | 应付票据报表基类 | 公共取数逻辑 |

### 2.2 服务层

| 类/文件名 | 路径 | 职责 | 关键方法 |
|---|---|---|---|
| CNOpenServiceHelper | FIN.ServiceHelper | 期初开账服务 | GetReceivableBillBalance, GetPayBillBalance |
| CNBillServiceHelper | FIN.ServiceHelper | 票据核心服务 | CreateBill, UpdateBill, CancelBill |
| CNReceivableBillServiceHelper | FIN.ServiceHelper | 应收票据服务 | ReceiveBill, CashBill, EndorseBill |
| CNPayBillServiceHelper | FIN.ServiceHelper | 应付票据服务 | IssueBill, PayBill |
| CNEndorseServiceHelper | FIN.ServiceHelper | 背书服务 | Endorse, QueryEndorseHistory |
| CNCashServiceHelper | FIN.ServiceHelper | 兑现服务 | Cash, QueryCashHistory |
| CNReportServiceHelper | FIN.ServiceHelper | 报表服务 | GetBalanceReport, GetFlowReport |

### 2.3 共用服务

| 类/文件名 | 来源 | 职责 | CN中使用 |
|---|---|---|---|
| VoucherGenerateServiceHelper | FIN.ServiceHelper | 凭证生成服务 | 票据收票/兑现/付款生成凭证 |
| VerificationServiceHelper | FIN.ServiceHelper | 核销服务 | 票据与AR/AP核销 |

### 2.4 数据模型

| 表名 | 用途 | 关键字段 |
|---|---|---|
| CN_RECEIVEBILL | 应收票据主表 | FBillID, FBillNo, FDrawer, FPayee, FAmount, FDueDate, FBillStatus, FEndorser, FCashedAmount |
| CN_PAYBILL | 应付票据主表 | FBillID, FBillNo, FDrawer, FPayee, FAmount, FDueDate, FBillStatus, FPayedAmount |
| CN_BILLENDORSERECORD | 背书记录表 | FEndorseID, FBillID, FEndorser, FEndorsee, FEndorseDate, FAmount |
| CN_BILLCASHRECORD | 票据兑现记录表 | FCashID, FBillID, FCashType, FCashDate, FCashAmount, FCashStatus |

---

## 三、关键索引

| 索引 | 表 | 用途 |
|---|---|---|
| PK_CN_RECEIVEBILL | CN_RECEIVEBILL | 单据主键 |
| IX_CN_RECEIVEBILL_NO | CN_RECEIVEBILL | 票据号码唯一查询 |
| IX_CN_RECEIVEBILL_CUSTOMER | CN_RECEIVEBILL | 客户维度查询 |
| IX_CN_RECEIVEBILL_STATUS | CN_RECEIVEBILL | 状态维度查询 |
| IX_CN_RECEIVEBILL_DUEDATE | CN_RECEIVEBILL | 到期日期查询 |
| PK_CN_PAYBILL | CN_PAYBILL | 单据主键 |
| IX_CN_PAYBILL_NO | CN_PAYBILL | 票据号码唯一查询 |
| IX_CN_PAYBILL_SUPPLIER | CN_PAYBILL | 供应商维度查询 |
| IX_CN_PAYBILL_STATUS | CN_PAYBILL | 状态维度查询 |
| IX_CN_PAYBILL_DUEDATE | CN_PAYBILL | 到期日期查询 |
| PK_CN_BILLENDORSERECORD | CN_BILLENDORSERECORD | 背书记录主键 |
| IX_CN_BILLENDORSE_BILL | CN_BILLENDORSERECORD | 票据背书历史查询 |
| PK_CN_BILLCASHRECORD | CN_BILLCASHRECORD | 兑现记录主键 |
| IX_CN_BILLCASH_BILL | CN_BILLCASHRECORD | 票据兑现历史查询 |

---

## 四、配置索引

| 配置项 | 配置位置 | 默认值 | 用途 |
|---|---|---|---|
| CN子系统ID | 系统配置 | "CN" | CN子系统标识 |
| 票据类型枚举 | 枚举配置 | 1=银行承兑, 2=商业承兑 | 票据类型区分 |
| 票据状态枚举 | 枚举配置 | 0=开立,1=背书,2=到期,3=已兑现,4=拒付,5=作废 | 状态管理 |
| 商业承兑背书限制 | 参数配置 | 3次 | 信用风险控制 |
| 到期提醒天数 | 参数配置 | 7天 | 到期提醒 |
| 逾期标记天数 | 参数配置 | 30天 | 逾期管理 |

---

## 五、证据强度说明

| 强度等级 | 定义 | 本次分析中的证据 |
|---|---|---|
| **直接事实** | 文档直接引用 | 金蝶K3Cloud财务系统全功能深度分析.md §5.3票据管理、§5.5期初开账 |
| **交叉验证结论** | 多源证据相互印证 | 票据概念与AP/AR镜像关系、状态机与业务规则一致性 |
| **推断** | 推理链明确但有缺口 | 表结构设计、服务类方法、核销机制 |
| **假设** | 尚未充分验证 | 枚举具体值、背书记录表完整字段、凭证模板配置 |

---

## 六、证据与结论追溯

| 结论/DQ | 关键证据 | 证据类型 | 强度 |
|---|---|---|---|
| DQ-01：票据定义和分类 | E-DOC-001 | 直接事实 | 高 |
| DQ-02：应收/应付票据差异 | E-DOC-003 | 交叉验证 | 高 |
| DQ-03：票据与AP/AR核销关联 | E-DOC-001, E-DOC-005 | 交叉验证 | 高 |
| DQ-04：票据状态机 | BR-CN-201 | 推断 | 中 |
| DQ-05：背书转让规则 | BR-CN-401至403 | 推断 | 中 |
| DQ-06：票据到期处理 | E-DOC-001 | 直接事实 | 高 |
| DQ-07：票据报表类型 | E-DOC-001 | 直接事实 | 高 |
| DQ-08：票据凭证生成 | E-DOC-001 §6.1 | 直接事实 | 高 |
| DQ-09：期初开账处理 | E-DOC-002 | 直接事实 | 高 |
| DQ-10：模块交互关系 | E-DOC-005 | 推断 | 中 |

---

## 七、文档与证据追溯

| 文档 | 依赖证据 | 覆盖度 |
|---|---|---|
| SOP-00-DA0-侦察报告 | E-DOC-001至005 | 100% |
| SOP-00-DA1-业务切面 | E-DOC-001至005 | 100% |
| SOP-00-DA2-概念字典 | E-DOC-001至005, E-SCHEMA | 100% |
| SOP-00-DA3-关系分析 | E-DOC-001至005, E-SCHEMA | 100% |
| SOP-00-DA4-规则分析 | E-DOC-001至005 | 100% |
| SOP-00-DA5-数据模型 | E-DOC-001至005, E-SCHEMA | 100% |
| SOP-00-DA6-交互流程 | E-DOC-001至005 | 100% |
| SOP-00-DA7-实现映射 | E-DOC-001至005 | 100% |
| SOP-00-DA8-收敛分析 | E-DOC-001至005 | 100% |
| SOP-00-V0-V7-验证记录 | 所有DA文档 | 100% |

---

## 八、CN独有证据（vs AP/AR）

| 证据ID | 功能 | CN独有性 | AP/AR对应 |
|---|---|---|---|
| E-DOC-001 §5.3 | 票据报表 | CN独有 | AP/AR无票据报表 |
| E-DOC-002 | CNOpenServiceHelper | CN期初开账 | AP/AR有类似但不同 |
| CN独有 | 票据背书转让 | CN独有 | AP/AR无背书概念 |
| CN独有 | 票据状态机 | CN独有 | AP/AR用WriteOffStatus |
| CN独有 | 银行承兑/商业承兑 | CN独有 | AP/AR无票据类型 |
