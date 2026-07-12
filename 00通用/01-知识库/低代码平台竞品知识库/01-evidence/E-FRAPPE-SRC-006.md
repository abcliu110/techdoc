---
id: E-FRAPPE-SRC-006
type: evidence
competitor: Frappe
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/core/doctype/user_permission/user_permission.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe User Permission 元模型

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/core/doctype/user_permission/user_permission.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`user` 在 L22，`allow` 在 L32，`for_value` 在 L41，`is_default` 在 L51，`applicable_for` 在 L68，`hide_descendants` 在 L81。

## 原始观察

User Permission 将用户、允许的 DocType、允许值、默认值、适用对象和是否隐藏后代建模为元数据字段。

## 证据强度

直接事实。源码 JSON 明确给出 Frappe 用户级数据范围权限字段。
