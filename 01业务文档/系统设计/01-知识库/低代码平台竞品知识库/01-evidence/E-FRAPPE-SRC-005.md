---
id: E-FRAPPE-SRC-005
type: evidence
competitor: Frappe
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/core/doctype/docperm/docperm.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe DocPerm 元模型

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/core/doctype/docperm/docperm.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`role` 在 L42，`if_owner` 在 L56，`permlevel` 在 L66，`read` 在 L82，`write` 在 L93，`create` 在 L104，`delete` 在 L115，`submit` 在 L126，`cancel` 在 L137，`export` 在 L171，`share` 在 L187。

## 原始观察

DocPerm 使用 role、permlevel 和一组操作权限字段表达文档类型权限。权限动作覆盖 read/write/create/delete/submit/cancel/export/share，并支持 `if_owner`。

## 证据强度

直接事实。源码 JSON 明确给出 Frappe DocPerm 的角色、权限级别、owner 条件和动作权限字段。
