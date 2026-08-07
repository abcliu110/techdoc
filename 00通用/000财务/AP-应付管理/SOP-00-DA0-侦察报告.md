# DA0 侦察报告 — K3Cloud AP应付管理模块

## 模板加载记录
已读取 SOP-00-DA0-模板.md，门禁检查 4 项全部通过。

---

## 一、分析对象与版本

| 项目 | 内容 |
|---|---|
| 分析对象 | K3Cloud AP（应付管理）模块 |
| 源码版本 | 2018年反编译版本 |
| 分析范围 | BusinessPlugIn/Kingdee.K3.FIN.AP.* |
| 核心证据来源 | PayableEdit.cs、FinMatch.cs、ARAPCommonPlugin.cs、VoucherGenerateServiceHelper.cs、MatchServiceHelper.cs、VerificationServiceHelper.cs |

---

## 二、入口痕迹清单（CF）

### 2.1 核心文件入口

| 入口文件 | 职责 | 关键方法 |
|---|---|---|
| PayableEdit.cs | 应付单据编辑 | SetAccountType(), OnLoad() |
| FinMatch.cs | 核销匹配界面 | FinMatchProcess() |
| ARAPCommonPlugin.cs | 应收应付公共插件 | SetAccountType() |
| MatchServiceHelper.cs | 核销匹配服务 | Match(), Calculate() |
| VerificationServiceHelper.cs | 核销确认服务 | Verify(), UnVerify() |
| VoucherGenerateServiceHelper.cs | 凭证生成服务 | Generate() |

### 2.2 关键业务入口

| 入口 | 业务事件 | 触发机制 |
|---|---|---|
| 应付单保存 | 暂估/财务核算类型判断 | SetAccountType() |
| 应付单审核 | 审核事件触发凭证生成 | OnDoOperation() |
| 核销操作 | 暂估与财务单据匹配 | FinMatchProcess() |
| 钩稽确认 | 暂估→财务确认 | Verify() |
| 钩稽返回 | 财务→暂估退回 | HookReturn() |

---

## 三、候选事实（CF）

### CF-01：核算类型状态机
**发现**：应付单有"暂估"和"财务"两种核算类型，且可互相转换
**证据**：PayableEdit.cs:643-715 SetAccountType()方法

### CF-02：核销行数限制
**发现**：特殊核销（iFinMatchMethod=73）限制行数组合：1:1, 1:0, 2:0(正负)
**证据**：FinMatch.cs:171-196 FinMatchProcess()

### CF-03：核销反操作需补偿
**发现**：反核销返回UnVerifyResultAction而非简单bool，需单独权限
**证据**：VerificationServiceHelper.cs:100-117, InnerClearRecordEdit.cs:54-67

### CF-04：业务类型驱动核算逻辑
**发现**：CG(采购)和FY(费用)有完全不同的核算类型判断逻辑
**证据**：PayableEdit.cs:643-715 嵌套70+层if-else

### CF-05：钩稽关系表存在
**发现**：存在钩稽关系表记录单据行对应关系
**证据**：VerificationServiceHelper.cs, AP_WRITEOFFRECORD

### CF-06：凭证生成双轨模式
**发现**：凭证生成采用"方案+映射"双轨模式
**证据**：VoucherGenerateServiceHelper.cs, BizVchMakeScheme

### CF-07：核销状态多值
**发现**：核销状态字段(FWRITTENOFFSTATUS)存在同步风险
**证据**：PayableEdit.cs核销状态更新逻辑

### CF-08：内部核销机制
**发现**：存在内部应收应付核销(InnerClear)处理组织间往来
**证据**：InnerClearRecordEdit.cs, AP_InnerIVRecord

### CF-09：凭证模板映射
**发现**：凭证模板(BizVchMakeScheme)支持灵活的科目映射
**证据**：VoucherGenerateServiceHelper.cs凭证模板加载

### CF-10：账龄分析体系
**发现**：账龄分析基于未核销金额和到期日期
**证据**：AgingAnalysis.cs, PayableOpenDetail.cs

---

## 四、分析问题（DQ）

| 编号 | 问题 | 来源 | 状态 |
|---|---|---|---|
| DQ-01 | 为什么需要暂估和财务两种核算类型？ | CF-01 | 待分析 |
| DQ-02 | 为什么核销要限制行数组合？ | CF-02 | 待分析 |
| DQ-03 | 为什么反核销需要补偿而非简单回滚？ | CF-03 | 待分析 |
| DQ-04 | CG和FY为什么需要完全不同的核算逻辑？ | CF-04 | 待分析 |
| DQ-05 | 钩稽关系表如何维护单据行对应关系？ | CF-05 | 待分析 |
| DQ-06 | 凭证生成双轨模式的协作机制是什么？ | CF-06 | 待分析 |
| DQ-07 | 核销状态多值如何保持一致性？ | CF-07 | 待分析 |
| DQ-08 | 内部核销与普通核销的区别是什么？ | CF-08 | 待分析 |

---

## 五、未知项（U）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-01 | 核销行数限制的完整业务语义 | 影响对核销机制的理解 |
| U-02 | UnVerifyResultAction的具体结构 | 影响对反核销机制的理解 |
| U-03 | 凭证生成双轨模式的协作细节 | 影响对自动凭证的理解 |
| U-04 | 核销状态同步的具体实现 | 影响对一致性机制的理解 |
| U-05 | 内部核销的完整流程 | 影响对责任中心结算的理解 |

---

## 六、路由决策

| 项目 | 决策 |
|---|---|
| 任务模式 | 认知重建（只读分析） |
| 分析深度 | 标准级（DA0-DA8） |
| 切片配额 | SC-P0: 核销业务；SC-P1: 凭证生成、账龄分析 |
| 执行路径 | SOP-00 → 文档20 → V验证 |

---

## 七、证据索引

| 证据ID | 来源 | 关键内容 |
|---|---|---|
| E-SRC-001 | PayableEdit.cs:643-715 | SetAccountType方法，70+层嵌套 |
| E-SRC-002 | FinMatch.cs:171-196 | FinMatchProcess，核销行数限制 |
| E-SRC-003 | VerificationServiceHelper.cs:100-117 | UnVerify返回结构 |
| E-SRC-004 | FinMatch.cs:156-209 | FinMatchProcess复杂校验 |
| E-SRC-005 | VoucherGenerateServiceHelper.cs | 凭证生成服务 |
| E-SRC-006 | MatchServiceHelper.cs | 匹配服务 |
| E-DOC-001 | K3Cloud财务模块元规范分析报告.md | AP模块REV-001/002/003 |
| E-DOC-002 | K3Cloud财务业务进化提炼.md | S1-S3惊讶事实 |
| E-DOC-003 | K3Cloud财务系统业务模型全面分析.md | AP模块完整分析 |
