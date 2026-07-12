---
id: E-FRAPPE-SRC-009
type: evidence
competitor: Frappe
module: extension
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/hooks.py
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe hooks.py 扩展点

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/hooks.py`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`app_name` 在 L5，`doctype_js` 在 L42，`permission_query_conditions` 在 L105，`has_permission` 在 L128，`doc_events` 在 L163，`scheduler_events` 在 L214，`override_whitelisted_methods` 在 L398。

## 原始观察

Frappe 通过 hooks.py 暴露 DocType 前端脚本、权限查询条件、自定义权限函数、文档事件、定时任务和 whitelisted 方法覆盖等扩展点。

## 证据强度

直接事实。源码明确给出 Frappe 应用级 hooks 扩展表面。
