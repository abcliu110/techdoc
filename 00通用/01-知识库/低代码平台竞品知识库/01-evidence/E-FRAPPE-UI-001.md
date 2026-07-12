---
id: E-FRAPPE-UI-001
type: evidence
competitor: Frappe
module: form-ui
source_channel: official-doc
source_type: screenshot
source_url: https://docs.frappe.io/framework/user/en/basics/doctypes/fieldtypes
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe 字段类型与表单渲染可见界面

## 原始观察

Frappe 官方 Field Types 文档说明字段类型用于在 Desk 和 Web Forms 中渲染组件。页面包含 Field Types Dropdown Menu、Data field、Check、Select、Table/child table、Code editor、Color、Section Break、Tab Break 等截图，并展示 Select 字段如何在 DocType/Customize Form 中定义以及如何在新表单中渲染。

## 证据强度

直接事实：官方文档页面包含字段定义和表单渲染截图。

## 可抽取知识

- Frappe 的 Form UI 由 DocType/DocField 字段类型驱动。
- 字段类型不仅决定存储语义，也决定 Desk 和 Web Form 上的输入控件。
- Section Break、Column Break、Tab Break 是表单布局的元字段，说明 Frappe 把布局控制也纳入字段模型。
