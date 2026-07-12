---
id: E-APPSMITH-DOC-002
type: evidence
competitor: Appsmith
module: app-builder
source_channel: official-doc
source_type: doc
source_url: https://docs.appsmith.com/build-apps/overview
source_owner: competitor-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Appsmith 应用结构

## 原始观察

Appsmith 官方构建应用概览把平台描述为支持 reactive bindings 和 MVC-like separation 的低代码平台，并说明应用结构围绕 widgets、datasources、queries 和 JavaScript。

## 证据强度

直接事实：官方文档明确说明 Appsmith 的应用构成对象。

## 可抽取知识

- Appsmith 的核心抽象更接近“页面组件 + 数据连接 + 查询动作 + JS 绑定”。
- 它适合内部工具和数据驱动页面，但不天然提供企业业务对象生命周期。
- 自研业务低代码可借鉴其绑定体验，但不应把绑定脚本作为业务规则的唯一承载。
