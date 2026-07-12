---
id: E-FRAPPE-SRC-013
type: evidence
competitor: Frappe
module: ui-view
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/desk/doctype/workspace/workspace.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Workspace 工作台页面元数据

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/desk/doctype/workspace/workspace.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`label` 在 L51；`charts` 在 L66；`shortcuts` 在 L72；`links` 在 L131；`public` 在 L138；`title` 在 L147；`content` 在 L160。

## 原始观察

Frappe Workspace 以 DocType JSON 定义工作台页面元数据，包含标题、可见性、内容、图表、快捷入口、链接等字段。该文件说明 Frappe 的页面入口也纳入元数据模型管理，而不是完全由硬编码页面承载。

## 证据强度

直接事实。源码中的 DocType JSON 明确列出 Workspace 页面元数据字段。
