---
id: E-APPSMITH-DOC-003
type: evidence
competitor: Appsmith
module: binding
source_channel: official-doc
source_type: doc
source_url: https://docs.appsmith.com/core-concepts/building-ui/dynamic-ui
source_owner: competitor-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Appsmith 数据绑定机制

## 原始观察

Appsmith 官方文档说明 widget 属性可以通过 query、JS Objects、widgets、storeValue 和 setter methods 动态更新。文档示例展示了用 mustache 表达式把查询结果绑定到 Table widget。

## 证据强度

直接事实：官方文档明确描述绑定入口和使用方式。

## 可抽取知识

- Appsmith 将动态 UI 的核心放在属性绑定和 JS 表达式上。
- 这种模型灵活，但会把业务逻辑、数据转换和交互规则散落在页面属性中。
- 自研平台应区分“页面表达式”和“可治理业务规则”，避免所有规则都沉入 UI 层。
