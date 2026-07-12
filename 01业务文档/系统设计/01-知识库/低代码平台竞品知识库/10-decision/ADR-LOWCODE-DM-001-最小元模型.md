---
id: ADR-LOWCODE-DM-001
type: adr
domain_object: LowCodeMetaModel
module: platform-core
decision_status: proposed
basis: [DM-LOWCODE-001, BR-LOWCODE-001, PM-LOWCODE-001]
evidence: [E-KINGDEE-COSMIC-001, E-NOCOBASE-001, E-FRAPPE-001, E-DIRECTUS-001]
rejected_options: [ADR-LOWCODE-DM-001-A]
risk: high
review_at: 2026-10-05
valid_until: 2027-01-05
links: []
owner: 产品负责人
ai_generated: true
---

# ADR：首版最小元模型

评审状态说明：依据知识库成熟度为 L0，按方法论 §10.1 不足以支撑高风险决策，待相关模块达到 L1 后提交人工评审。

## 决策

首版元模型至少包含：

```text
Tenant
Workspace
App
BusinessObject
Field
Relation
State
Action
Rule
Workflow
Page
View
Component
Role
Permission
DataSource
Connector
Version
Plugin
```

## 理由

这些对象覆盖了业务建模、页面生成、规则流程、权限治理、外部连接和版本演进的最低闭环。

## 风险

这是单向门决策。若元模型过窄，后续会迫使业务逻辑散落在页面脚本和查询里；若过宽，首版会过度设计。

## 验证方式

用一个真实业务对象验证：能完成字段建模、关联关系、列表/表单生成、状态动作、权限校验和版本升级。
