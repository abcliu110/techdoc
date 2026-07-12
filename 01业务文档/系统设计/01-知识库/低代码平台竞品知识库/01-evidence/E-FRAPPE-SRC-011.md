---
id: E-FRAPPE-SRC-011
type: evidence
competitor: Frappe
module: ui-view
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/public/js/frappe/form/layout.js
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Form Layout 表单布局运行模型

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/public/js/frappe/form/layout.js`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`frappe.ui.form.Layout` 在 L5；`tabs`、`sections`、`fields_list`、`fields_dict` 初始化在 L9-L14；`make()` 在 L21；`get_doctype_fields()` 在 L56；`render()` 在 L167；`make_field()` 在 L255；`refresh()` 在 L388；`refresh_dependency()` 在 L785。

## 原始观察

Frappe 表单布局运行时以 `Layout` 类组织 DocType 字段，维护 tabs、sections、fields_list、fields_dict，并在渲染时把字段元数据转成控件对象。刷新阶段会重新执行依赖刷新和分区/标签页刷新。

## 证据强度

直接事实。源码明确给出 Frappe 表单视图从 DocType 字段元数据到运行时布局对象的组织方式。
