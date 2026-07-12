---
id: E-NOCOBASE-001
type: evidence
competitor: NocoBase
module: data-model
source_channel: official-doc
source_type: doc
source_url: https://docs.nocobase.com/guide/
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase

## 原始观察

NocoBase 官方 guide 展示了 users & permissions、workflow、notification、multi-app and multi-workspace、AI employees 等能力。其 association field 文档说明关联字段组件用于展示和处理关联数据，并支持不同关系类型的配置。

Workflow 教程说明 workflow 是内置插件，可使用 collection event 和 custom action event 触发。

## 证据强度

直接事实：官方文档明确说明 collection、association field、workflow、permissions、multi-app/workspace。

## 可抽取知识

- NocoBase 的核心模型是 collection + field + association + block/UI schema + workflow + plugin。
- 它比 Appsmith/ToolJet 更接近数据模型驱动业务应用。

