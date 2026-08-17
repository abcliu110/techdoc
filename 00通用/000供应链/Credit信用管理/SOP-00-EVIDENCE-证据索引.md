# 证据索引 — K3Cloud Credit信用管理

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Credit信用管理 |
| 分析时间 | 2026-08-07 |
| 证据类型 | 源码分析、业务规则、数据模型、服务架构 |

---

## 一、CF候选事实证据

### 1.1 已实证CF证据

| CF编号 | 候选事实 | 证据类型 | 证据位置 |
|---|---|---|---|
| CF-01 | 信用额度是信用管理的核心实体 | 源码分析 | CreditLimit实体存在 |
| CF-02 | 信用检查嵌入销售流程 | 集成分析 | Sal→Credit集成 |
| CF-03 | 额度占用基于AR应收 | 关系分析 | 占用逻辑关联AR |
| CF-04 | 信用评级影响额度计算 | 规则分析 | 评级→额度公式 |
| CF-05 | 信用额度可动态调整 | 服务分析 | 调整申请与审批 |

### 1.2 待验证CF证据

| CF编号 | 候选事实 | 验证方式 | 状态 |
|---|---|---|---|
| CF-06 | 信用预警触发催收流程 | 业务规则验证 | ⏳ 待验证 |
| CF-07 | 跨组织信用共享机制 | 配置验证 | ⏳ 待验证 |

---

## 二、业务规则证据

### 2.1 BR-Cred系列规则

| 规则ID | 规则名称 | 证据来源 | 证据类型 |
|---|---|---|---|
| BR-Cred-101 | 额度唯一性 | 业务规则 | 同一客户同一币种唯一 |
| BR-Cred-102 | 额度计算 | 业务规则 | 可用=总额度-已占用-已冻结 |
| BR-Cred-103 | 额度类型 | 业务规则 | 临时/永久类型约束 |
| BR-Cred-104 | 额度调整审批 | 审批流 | 阈值触发审批 |
| BR-Cred-201 | 检查时机 | 服务分析 | 订单创建/修改触发 |
| BR-Cred-202 | 检查通过条件 | 服务分析 | 可用>=订单含税金额 |
| BR-Cred-203 | 检查缓存 | 服务分析 | 缓存机制 |
| BR-Cred-204 | 冻结客户检查 | 服务分析 | 直接拒绝 |
| BR-Cred-301 | 占用时机 | 服务分析 | 出库审核触发 |
| BR-Cred-302 | 占用金额 | 服务分析 | 出库含税金额 |
| BR-Cred-303 | 占用原子性 | 服务分析 | 事务保证 |
| BR-Cred-304 | 部分占用 | 服务分析 | 分次出库支持 |
| BR-Cred-401 | 释放时机 | 服务分析 | 收款/核销触发 |
| BR-Cred-402 | 释放金额 | 服务分析 | 核销金额 |
| BR-Cred-403 | 释放上限 | 服务分析 | 不超过未释放 |
| BR-Cred-404 | 释放顺序 | 服务分析 | FIFO |
| BR-Cred-501 | 逾期预警 | 预警规则 | N天阈值 |
| BR-Cred-502 | 额度预警 | 预警规则 | 使用率阈值 |
| BR-Cred-503 | 评级预警 | 预警规则 | 下调触发 |
| BR-Cred-504 | 预警升级 | 预警规则 | 超时自动升级 |

---

## 三、数据模型证据

### 3.1 核心表证据

| 表名 | 中文名 | 主键 | 证据来源 |
|---|---|---|---|
| T_CR_CREDITLIMIT | 信用额度表头 | FID | 数据库DDL |
| T_CR_CREDITLIMITENTRY | 信用额度明细 | FENTRYID | 数据库DDL |
| T_CR_CREDITLIMITUSAGE | 额度使用记录 | FID | 数据库DDL |
| T_CR_CREDITLIMITFREEZE | 额度冻结记录 | FID | 数据库DDL |
| T_CR_CREDITRATING | 信用评级 | FID | 数据库DDL |
| T_CR_CREDITWARNING | 信用预警 | FID | 数据库DDL |
| T_CR_CREDITWARNINGRULE | 预警规则 | FID | 数据库DDL |

### 3.2 关键字段证据

| 表名 | 关键字段 | 字段类型 | 证据说明 |
|---|---|---|---|
| T_CR_CREDITLIMIT | FCREDITLIMIT | DECIMAL(18,6) | 信用额度金额 |
| T_CR_CREDITLIMIT | FAAVAILABLELIMIT | DECIMAL(18,6) | 可用额度 |
| T_CR_CREDITLIMIT | FOCCUPIEDLIMIT | DECIMAL(18,6) | 已占用额度 |
| T_CR_CREDITLIMIT | FFROZENLIMIT | DECIMAL(18,6) | 已冻结额度 |
| T_CR_CREDITLIMIT | FSTATUS | VARCHAR(20) | 状态枚举 |
| T_CR_CREDITLIMITUSAGE | FOCCUPYAMOUNT | DECIMAL(18,6) | 占用金额 |
| T_CR_CREDITLIMITUSAGE | FRELEASEDAMOUNT | DECIMAL(18,6) | 已释放金额 |
| T_CR_CREDITLIMITUSAGE | FSTATUS | VARCHAR(20) | 占用状态 |
| T_CR_CREDITRATING | FRATINGLEVEL | VARCHAR(10) | 评级等级 |
| T_CR_CREDITWARNING | FWARNINGLEVEL | VARCHAR(20) | 预警级别 |

---

## 四、服务类证据

### 4.1 核心服务

| 服务名 | 类名 | 行数 | 证据来源 |
|---|---|---|---|
| CreditService | CreditService.cs | ~2,800 | 源码扫描 ⚠️ |
| CreditLimitService | CreditLimitEdit.cs | - | 插件代码 |
| CreditCheckService | CreditCheckPlugIn.cs | ~1,200 | 插件代码 |
| CreditOccupancyService | CreditOccupyPlugIn.cs | - | 插件代码 |
| CreditWarningService | CreditWarningPlugIn.cs | - | 插件代码 |

### 4.2 关键方法

| 服务 | 方法 | 功能 | 证据说明 |
|---|---|---|---|
| CreditService | GetAvailableLimit | 计算可用额度 | BR-Cred-102 |
| CreditService | CheckCredit | 信用检查入口 | BR-Cred-201/202 |
| CreditService | OccupyLimit | 额度占用入口 | BR-Cred-301/302 |
| CreditService | ReleaseLimit | 额度释放入口 | BR-Cred-401/402 |
| CreditLimitEdit | OnSave | 保存校验 | BR-Cred-101 |
| CreditLimitEdit | OnAudit | 审批确认 | 状态机流转 |
| CreditCheckPlugIn | Check | 实时信用检查 | BR-Cred-202 |
| CreditCheckPlugIn | CheckAsync | 异步信用检查 | 队列处理 |

---

## 五、集成关系证据

### 5.1 Sal销售→Credit信用

| 集成点 | 说明 | 证据类型 |
|---|---|---|
| SalOrderEdit | 订单创建时触发信用检查 | 插件集成 |
| SalDeliverySvc | 出库审核时触发额度占用 | 插件集成 |
| OnAudit事件 | 审核事件触发后续操作 | 事件驱动 |

### 5.2 Credit信用→AR应收

| 集成点 | 说明 | 证据类型 |
|---|---|---|
| ARService | 应收触发额度占用 | 服务调用 |
| ARReceiptSvc | 收款触发额度释放 | 服务调用 |
| 占用记录 | FSOURCEBILLID关联AR | 数据关联 |

### 5.3 Credit信用↔CB收款

| 集成点 | 说明 | 证据类型 |
|---|---|---|
| CBReceiptSvc | 收款审核触发释放 | 服务调用 |
| 释放记录 | 关联收款单据 | 数据关联 |

---

## 六、决策证据

| 决策ID | 决策点 | 决策规则 | 证据来源 |
|---|---|---|---|
| DEC-Cred-01 | 检查策略 | 实时 vs 异步 | 配置可切换 |
| DEC-Cred-02 | 占用时机 | 出库审核 vs AR记账 | 出库审核时 |
| DEC-Cred-03 | 释放时机 | 收款 vs 核销 | 收款+核销 |
| DEC-Cred-04 | 额度不足处理 | 拒绝 vs 审批 | 审批流程 |
| DEC-Cred-05 | 冻结策略 | 手动 vs 自动 | 手动+自动 |

---

## 七、反证案例证据

### 7.1 反证#1：信用检查性能瓶颈

| 证据类型 | 证据内容 | 证据说明 |
|---|---|---|
| 性能分析 | 实时检查影响订单响应时间 | 每单同步查询 |
| 根因 | 计算可用额度需要聚合查询 | 占用记录多时慢 |
| 优化方向 | 异步检查或缓存优化 | 预计算可用额度 |

### 7.2 反证#2：跨模块数据一致性

| 证据类型 | 证据内容 | 证据说明 |
|---|---|---|
| 一致性分析 | AR模块异常导致额度占用失败 | 跨模块事务难 |
| 根因 | 占用/释放依赖AR事件 | 缺乏原子性保证 |
| 优化方向 | 消息队列或分布式事务 | 最终一致性 |

---

## 八、风险证据

| 风险ID | 风险描述 | 证据来源 | 风险级别 |
|---|---|---|---|
| R-Cred-01 | 额度计算逻辑复杂 | 多表聚合计算 | 中 |
| R-Cred-02 | 信用检查性能影响 | 实时同步查询 | 中 |
| R-Cred-03 | 额度占用与释放时序 | AR事件依赖 | 高 ⚠️ |
| R-Cred-04 | 跨模块数据同步 | Sal/AR/Credit | 中 |
| R-Cred-05 | 信用评级主观性 | 缺乏量化标准 | 低 |
| R-Cred-06 | 预警处理延迟 | 人工处理慢 | 中 |

---

## 九、分析文档清单

| 文档 | 分析阶段 | 关键结论 |
|---|---|---|
| SOP-00-DA0-侦察报告 | 侦察阶段 | ~45文件/~12,500行 |
| SOP-00-DA1-业务切面分析 | 切面分析 | 5角色、14用例 |
| SOP-00-DA2-概念字典 | 概念分析 | 6核心概念 |
| SOP-00-DA3-关系分析 | 关系分析 | 11关系、4路径 |
| SOP-00-DA4-规则分析 | 规则分析 | 17规则、3状态机 |
| SOP-00-DA5-数据模型 | 数据分析 | 9表、索引设计 |
| SOP-00-DA6-交互流程 | 交互分析 | 5服务、12API |
| SOP-00-DA7-实现映射 | 实现映射 | 6报表、5决策卡 |
| SOP-00-DA8-收敛分析 | 收敛分析 | 5CF、3U、6风险、2反证 |
| SOP-00-V0-V7-验证记录 | 验证阶段 | 48/48验证通过 |
| SOP-00-00-十分钟读懂 | 快速理解 | 核心发现 |
| SOP-00-01-业务全景 | 业务理解 | 业务架构 |
| SOP-00-02-典型业务故事 | 业务理解 | 5个业务场景 |
| SOP-00-03-失败恢复手册 | 运维支持 | 7个异常场景 |

---

## 十、分析结论

**证据完整性**：高
- CF候选事实：7个（5已实证、2待验证）
- 业务规则：17条（全部分析）
- 数据表：7张（结构完整）
- 服务类：5个（核心服务已定位）
- 决策点：5个（全部分析）

**证据可信度**：高
- 源码证据：可直接定位到代码
- 业务规则：与规则分析一致
- 数据模型：DDL结构清晰
- 服务架构：与交互流程一致

**待补充证据**：
- 信用预警触发催收流程的具体实现
- 跨组织信用共享机制的配置
- CreditService巨型类拆分验证
- 异步检查队列的具体实现
