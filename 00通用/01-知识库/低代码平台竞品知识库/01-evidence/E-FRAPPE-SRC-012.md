---
id: E-FRAPPE-SRC-012
type: evidence
competitor: Frappe
module: ui-view
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/public/js/frappe/list/list_view.js
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe ListView 列表视图字段与渲染链路

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/public/js/frappe/list/list_view.js`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`frappe.views.ListView` 在 L6；`max_number_of_fields` 在 L38；`validate_filters()` 在 L150；`get_fields()` 在 L207；`set_fields()` 在 L217；`setup_view()` 在 L365；`setup_columns()` 在 L422；`build_columns_from_fields()` 在 L514；`render()` 在 L877；`render_list()` 在 L882；`setup_events()` 在 L1600。

## 原始观察

Frappe 列表视图运行时以 `ListView` 类组织筛选、字段集合、列构建、渲染和事件绑定。列表列不是静态写死，而是从字段元数据与 list view 配置中构造，并受最大字段数约束。

## 证据强度

直接事实。源码明确给出 Frappe 列表视图从字段元数据到列构建、渲染和事件绑定的链路。
