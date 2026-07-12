---
id: E-AIRTABLE-FORM-001
type: evidence
competitor: Airtable
module: form-builder
source_channel: official-doc
source_type: doc
source_url: https://support.airtable.com/docs/building-and-sharing-forms-in-airtable
source_owner: competitor-official
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Airtable 表单与数据表绑定

## 原始观察

Airtable 官方支持文档说明表单字段可在画布中增删、重排、调整宽度，点击字段后右侧属性面板会展示该字段设置。文档说明表单组可用于把多个字段组织在一起。

文档说明表单字段可设置条件可见性，也可对表单组设置条件显示；同时明确提醒：不建议用条件可见性处理敏感字段，因为视觉隐藏不等于安全，底层记录或字段值仍可能暴露。

## 证据强度

直接事实：官方支持文档明确说明字段配置、表单组、条件可见性和安全边界提醒。

## 可抽取知识

- 数据库型表单设计器的核心优势是表单字段和底层表字段同源。
- 条件可见性属于体验规则，不是权限规则。
- 表单设计器需要明确区分 UI hidden、read-only、field permission、record permission 四类机制。

