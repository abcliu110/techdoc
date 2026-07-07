---
id: E-FRAPPE-SRC-001
type: evidence
competitor: Frappe
module: data-model
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/core/doctype/doctype/doctype.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe DocType 源码

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/core/doctype/doctype/doctype.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：raw 文件可复核；`is_submittable` 在 L128，`istable` 在 L135，`fields` 在 L211，`fields.options = DocField` 在 L216，`permissions` 在 L388，`permissions.options = DocPerm` 在 L393。

## 原始观察

`doctype.json` 中：

- `fields` 字段本身是 `Table`，`options` 指向 `DocField`。
- `permissions` 字段是 `Table`，`options` 指向 `DocPerm`。

这说明 Frappe 的 DocType 元模型把字段定义和权限定义都建模为子表。

## 证据强度

直接事实。源码 JSON 明确给出 DocType 的 `fields -> DocField` 和 `permissions -> DocPerm` 关系。
