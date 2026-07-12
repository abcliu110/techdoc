---
id: E-OSS-FORM-DESIGNABLE-001
type: evidence
competitor: Formily-Designable
module: form-builder
source_channel: github
source_type: repo
source_url: https://github.com/formilyjs/designable-vue
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Designable / Formily 可视化设计器生态

## 原始观察

designable-vue README 说明 Designable 可用于低成本快速开发表单 Builder；其特点包括字段独立管理而不是整树重渲染、集成组件库、后端使用 JSON Schema、前端使用 JSchema，且两种范式可互转，副作用独立管理以简化表单联动。

## 证据强度

直接事实：GitHub README 明确描述 Designable 的 Builder、schema 转换、字段管理和副作用管理能力。

## 可抽取知识

- 可视化表单设计器需要“设计态 schema”和“运行态 schema”之间的转换边界。
- 联动副作用应独立管理，否则设计器中的字段依赖会散落在控件配置里。
- 对自研平台而言，Designable 值得研究 designer tree、schema transform、组件物料协议和 effect 模型。

