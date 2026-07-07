---
id: E-DIRECTUS-DOC-002
type: evidence
competitor: Directus
module: data-model
source_channel: official-doc
source_type: doc
source_url: https://directus.com/docs/guides/data-model/fields
source_owner: competitor-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Directus Fields 数据模型

## 原始观察

Directus 官方字段文档说明 fields 是数据库列加上 Directus 元数据和配置，用于定义数据如何存储与展示，并覆盖数据类型、界面、校验和关系等方面。

## 证据强度

直接事实：官方文档明确说明字段的存储和展示双重语义。

## 可抽取知识

- Directus 字段不是单纯数据库列，而是“存储列 + 展示元数据 + 校验 + 关系”的组合。
- 自研低代码平台的 Field 元模型必须同时服务数据层、页面层和校验层。
- 数据模型驱动平台的优势是让 API、权限和 UI 都围绕字段元数据展开。
