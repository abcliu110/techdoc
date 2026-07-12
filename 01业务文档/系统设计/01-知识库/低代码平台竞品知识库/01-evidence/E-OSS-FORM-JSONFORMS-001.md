---
id: E-OSS-FORM-JSONFORMS-001
type: evidence
competitor: JSON-Forms
module: form-renderer
source_channel: github
source_type: repo
source_url: https://github.com/eclipsesource/jsonforms
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：JSON Forms 的 schema / uischema 分离

## 原始观察

JSON Forms 官方资料说明其基于 JSON Schema 高效开发表单 UI，并用声明式 JSON 语言描述 UI，独立于具体 UI 技术。React seed 示例说明渲染时把 schema、uischema、data、renderer、cell 传给 JsonForms 组件，并通过 onChange 监听表单变化。

## 证据强度

直接事实：官方仓库和示例说明 schema、uischema、data、renderer、cell 的核心渲染模型。

## 可抽取知识

- data schema 和 ui schema 分离是低代码表单设计器的重要架构模式。
- renderer/cell 注册机制适合解决不同组件库、不同端、不同主题的渲染扩展。
- 自研平台应避免把数据字段、布局、渲染器和控件样式压进一个 JSON 对象。

