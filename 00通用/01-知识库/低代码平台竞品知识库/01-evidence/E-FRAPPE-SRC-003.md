---
id: E-FRAPPE-SRC-003
type: evidence
competitor: Frappe
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/permissions.py
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe permissions.py

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/permissions.py`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：raw 文件可复核；`has_permission()` 在 L80，`get_doc_permissions()` 在 L227，controller 权限检查在 L237 和 L481，user permission 检查在 L264 和 L351。

## 原始观察

`has_permission()` 接收 `doctype`、`ptype`、`doc`、`user`、`parent_doctype` 等参数，并说明当传入 `doc` 时会检查 user、share、owner permissions。

`get_doc_permissions()` 返回文档的权限字典，例如 `{"read":1, "write":1}`。源码显示其流程包括：

- 获取当前用户。
- 获取文档 meta。
- 判断 owner。
- 调用 controller permission check。
- 基于角色权限系统获取权限。
- 对非 submittable 文档关闭 submit 权限。

## 证据强度

直接事实。源码明确给出 Frappe 文档权限判断入口和角色/owner/controller/share 组合判断思路。
