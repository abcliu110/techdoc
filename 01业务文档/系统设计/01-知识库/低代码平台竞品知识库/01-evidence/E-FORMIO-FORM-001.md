---
id: E-FORMIO-FORM-001
type: evidence
competitor: Form.io
module: form-builder
source_channel: official-doc
source_type: doc
source_url: https://help.form.io/form-building/form-builder
source_owner: competitor-official
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Form.io Form Builder 与组件 JSON

## 原始观察

Form.io 官方文档说明 Form Builder 用于创建 Form 或 Resource。Builder UI 包含 Display As、Search Field、Component Grouping、Drop Zone、Copy Form、Save Form 等能力。Display As 可在 Wizard、PDF、传统 Web Form 之间切换。

文档说明组件按 Basic、Advanced、Layout、Data、Premium、Existing Resource Fields 分组，组件可拖入 drop zone。每个组件有 inline settings，可 Edit、Move、Edit JSON、Copy、Paste、Delete。Edit JSON 可直接配置组件 JSON，完整 schema 可查看。

## 证据强度

直接事实：官方文档明确说明 Builder UI、组件分组、展示类型和 JSON 编辑入口。

## 可抽取知识

- 开发者型表单设计器需要可视化配置与 JSON/schema 编辑双通道。
- 表单展示形态应从表单定义中抽象出来，支持 Wizard、Web Form、PDF 等不同运行时。
- 组件 JSON 是跨环境复制、版本化和高级扩展的关键载体。

