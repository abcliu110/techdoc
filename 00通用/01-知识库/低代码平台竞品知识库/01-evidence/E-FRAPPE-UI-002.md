---
id: E-FRAPPE-UI-002
type: evidence
competitor: Frappe
module: list-view
source_channel: official-doc
source_type: screenshot
source_url: https://docs.frappe.io/framework/user/en/api/list
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe List View 可见界面

## 原始观察

Frappe 官方 List 文档说明 List View 会为除 Child Table 和 Single DocType 外的 DocType 自动生成。文档列出 List View 支持 Filters、Sorting、Paging、Filter by tags，以及切换到 Report、Calendar、Gantt、Kanban 等视图，并包含 List View 截图。

## 证据强度

直接事实：官方文档页面明确说明 List View 能力，并提供可见截图。

## 可抽取知识

- Frappe 的列表页是 DocType 的默认派生视图，不要求每个对象单独手写列表。
- 列表页天然承载过滤、排序、分页、标签过滤和视图切换。
- 自研低代码平台的列表视图应作为对象模型的默认视图生成，同时保留视图级配置入口。
