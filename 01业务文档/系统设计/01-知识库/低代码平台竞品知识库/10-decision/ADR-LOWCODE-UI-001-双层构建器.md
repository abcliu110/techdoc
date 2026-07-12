---
id: ADR-LOWCODE-UI-001
type: adr
domain_object: AppBuilder
module: builder-ui
decision_status: proposed
basis: [UI-LOWCODE-001, FLOW-LOWCODE-001]
evidence: [E-APPSMITH-001, E-TOOLJET-001, E-BUDIBASE-001, E-NOCOBASE-001, E-KINGDEE-COSMIC-001]
rejected_options: [ADR-LOWCODE-UI-001-A]
risk: medium
review_at: 2026-10-05
valid_until: 2027-01-05
links: []
owner: 产品负责人
ai_generated: true
---

# ADR：采用双层构建器

评审状态说明：依据知识库成熟度为 L0，按方法论 §10.1 不足以支撑高风险决策，待相关模块达到 L1 后提交人工评审。

## 决策

平台采用双层构建器：

```text
业务建模构建器：对象、字段、关系、状态、动作、规则、流程、权限
页面编排构建器：列表、表单、详情、看板、报表、组件、布局
```

## 理由

内部工具平台证明了页面构建器的效率，但企业业务平台不能让页面配置覆盖业务模型。业务建模构建器负责语义，页面编排构建器负责表达。

## 验证方式

同一个 BusinessObject 应能自动生成默认列表/表单/详情，并允许页面层覆盖布局但不能绕过模型权限和规则。
