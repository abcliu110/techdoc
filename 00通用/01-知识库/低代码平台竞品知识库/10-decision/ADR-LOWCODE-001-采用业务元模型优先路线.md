---
id: ADR-LOWCODE-001
type: adr
domain_object: LowCodePlatform
module: platform-core
decision_status: proposed
basis: [BIZ-LOWCODE-001, DM-LOWCODE-001, OPP-LOWCODE-001]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-FRAPPE-001, E-NOCOBASE-001, E-APPSMITH-001, E-TOOLJET-001]
rejected_options: [ADR-LOWCODE-001-A, ADR-LOWCODE-001-B]
risk: medium
review_at: 2026-10-05
valid_until: 2027-01-05
links: [ADR-LOWCODE-DM-001, ADR-LOWCODE-UI-001, ADR-LOWCODE-PERM-001]
owner: 产品负责人
ai_generated: true
---

# ADR：采用业务元模型优先路线

## 背景

竞品拆解显示，金蝶和 Frappe 类路线以业务模型和元数据为核心，适合支撑企业级业务系统；Appsmith、ToolJet、Budibase、Lowcoder 类路线以 UI 和数据源为核心，更适合内部工具。

评审状态说明：依据知识库成熟度为 L0，按方法论 §10.1 不足以支撑高风险决策，待相关模块达到 L1 后提交人工评审。

## 备选方案

方案 A：先做 UI Builder，后续逐步补业务模型。

方案 B：先做通用数据表/CRUD，再补流程和页面。

方案 C：先做业务元模型，再围绕模型生成页面、规则、流程和权限。

## 决策

采用方案 C。

## 理由

- 目标是企业业务低代码，不是只搭内部工具。
- 业务对象、关系、状态、规则、权限是平台长期资产。
- 页面可以由模型生成和配置；反过来从页面推业务模型代价很高。

## 代价

- 首版建设成本高于普通 UI Builder。
- 需要先定义元模型和运行时规则。
- 对产品、研发、测试的领域建模能力要求更高。

## 不采用原因

不采用方案 A：容易变成组件平台，后续补业务语义会破坏已有应用。

不采用方案 B：通用 CRUD 能快速启动，但难以表达复杂业务对象生命周期和流程。

## 验证方式

首版必须能用同一套元模型生成列表、表单、详情、状态动作、权限校验和基础 API。
