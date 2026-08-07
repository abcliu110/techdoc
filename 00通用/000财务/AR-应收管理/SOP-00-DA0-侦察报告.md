# DA0 侦察报告 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 SOP-00-DA0-模板.md，门禁检查 4 项全部通过。

---

## 一、分析对象与版本

| 项目 | 内容 |
|---|---|
| 分析对象 | K3Cloud AR（应收管理）模块 |
| 源码版本 | 2018年反编译版本 |
| 分析范围 | BusinessPlugIn/Kingdee.K3.FIN.AR.* |
| 核心证据来源 | ARReceivableEdit.cs、ARFinMatch.cs、ARAPCommonPlugin.cs、VoucherGenerateServiceHelper.cs、MatchServiceHelper.cs、VerificationServiceHelper.cs |
| 与AP的关系 | AR是AP的镜像模块，AR应收 vs AP应付 |

---

## 二、入口痕迹清单（CF）

### 2.1 核心文件入口

| 入口文件 | 职责 | 关键方法 |
|---|---|---|
| ARReceivableEdit.cs | 应收单据编辑 | SetAccountType(), OnLoad() |
| ARFinMatch.cs | 应收核销匹配界面 | FinMatchProcess() |
| ARAPCommonPlugin.cs | 应收应付公共插件 | SetAccountType() |
| MatchServiceHelper.cs | 核销匹配服务 | Match(), Calculate() |
| VerificationServiceHelper.cs | 核销确认服务 | Verify(), UnVerify() |
| VoucherGenerateServiceHelper.cs | 凭证生成服务 | Generate() |
| ARInnerIVSpecialMatchEdit.cs | AR内部特殊匹配 | InnerMatchProcess() |

### 2.2 关键业务入口

| 入口 | 业务事件 | 触发机制 |
|---|---|---|
| 应收单保存 | 暂收/财务核算类型判断 | SetAccountType() |
| 应收单审核 | 审核事件触发凭证生成 | OnDoOperation() |
| 核销操作 | 应收与收款匹配 | FinMatchProcess() |
| 钩稽确认 | 应收单据关联确认 | Verify() |
| 收付款认领 | 客户对账自动匹配 | BillRecReport处理 |

---

## 三、候选事实（CF）

### CF-01：应收核算类型状态机
**发现**：应收单有"暂收"和"财务"两种核算类型（与AP的暂估/财务对应）
**证据**：ARReceivableEdit.cs SetAccountType()方法

### CF-02：应收核销行数限制
**发现**：特殊核销（iFinMatchMethod=73）限制行数组合：1:1, 1:0, 2:0(正负)，与AP一致
**证据**：ARFinMatch.cs FinMatchProcess()

### CF-03：应收反核销需补偿
**发现**：反核销返回UnVerifyResultAction而非简单bool，需单独权限
**证据**：VerificationServiceHelper.cs，与AP共用

### CF-04：业务类型驱动核算逻辑
**发现**：SA(销售)和其他业务类型有完全不同的核算类型判断逻辑
**证据**：ARReceivableEdit.cs 嵌套判断逻辑

### CF-05：应收钩稽关系表存在
**发现**：存在钩稽关系表记录应收单据行对应关系
**证据**：VerificationServiceHelper.cs，与AP共用

### CF-06：凭证生成双轨模式
**发现**：凭证生成采用"方案+映射"双轨模式，与AP/GL一致
**证据**：VoucherGenerateServiceHelper.cs

### CF-07：核销状态多值
**发现**：核销状态字段(FWRITTENOFFSTATUS)存在同步风险
**证据**：ARReceivableEdit.cs核销状态更新逻辑

### CF-08：内部应收核销机制
**发现**：存在内部应收核销(InnerIV)处理组织间往来
**证据**：ARInnerIVSpecialMatchEdit.cs, AR_InnerIVRecord

### CF-09：收付款认领机制
**发现**：AR独有BillRecReport收付款认领机制，用于客户对账
**证据**：BillRecReport.cs, ReceivableBillBalRpt.cs

### CF-10：应收账龄分析
**发现**：账龄分析基于未核销金额和到期日期
**证据**：ReceivableBillReport相关报表

---

## 四、分析问题（DQ）

| 编号 | 问题 | 来源 | 状态 |
|---|---|---|---|
| DQ-01 | AR的暂收和财务与AP的暂估和财务有什么区别？ | CF-01 | 待分析 |
| DQ-02 | 应收核销与AP应付核销的核心差异是什么？ | CF-02 | 待分析 |
| DQ-03 | 收付款认领机制是什么？ | CF-09 | 待分析 |
| DQ-04 | SA销售应收的核算逻辑特点是什么？ | CF-04 | 待分析 |
| DQ-05 | 内部应收核销与内部应付核销如何协同？ | CF-08 | 待分析 |

---

## 五、未知项（U）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-01 | 应收单据的完整业务类型分类 | 影响对AR业务的理解 |
| U-02 | 收付款认领的完整流程 | 影响对AR特有功能的理解 |
| U-03 | 应收核销与AP核销的具体差异 | 影响对AR-AP对称性的理解 |
| U-04 | 内部应收核销的完整流程 | 影响对责任中心结算的理解 |
| U-05 | 客户信用管理机制 | 影响对AR风险控制的理解 |

---

## 六、路由决策

| 项目 | 决策 |
|---|---|
| 任务模式 | 认知重建（只读分析） |
| 分析深度 | 标准级（DA0-DA8） |
| 切片配额 | SC-P0: 应收核销；SC-P1: 收付款认领、账龄分析 |
| 执行路径 | SOP-00 → 文档20 → V验证 |

---

## 七、证据索引

| 证据ID | 来源 | 关键内容 |
|---|---|---|
| E-SRC-001 | ARReceivableEdit.cs | SetAccountType方法，应收核算类型 |
| E-SRC-002 | ARFinMatch.cs | FinMatchProcess，核销行数限制 |
| E-SRC-003 | VerificationServiceHelper.cs | UnVerify返回结构（与AP共用） |
| E-SRC-004 | MatchServiceHelper.cs | 匹配服务（与AP共用） |
| E-SRC-005 | VoucherGenerateServiceHelper.cs | 凭证生成服务（与AP共用） |
| E-SRC-006 | ARInnerIVSpecialMatchEdit.cs | 内部应收特殊匹配 |
| E-SRC-007 | ReceivableBillReport.cs | 应收单报表 |
| E-SRC-008 | BillRecReport.cs | 收付款认领报表 |
| E-DOC-001 | K3Cloud财务模块元规范分析报告.md | AR模块分析 |
| E-DOC-002 | K3Cloud财务业务进化提炼.md | S1-S3惊讶事实 |
| E-DOC-003 | K3Cloud财务系统业务模型全面分析.md | AR模块完整分析 |
