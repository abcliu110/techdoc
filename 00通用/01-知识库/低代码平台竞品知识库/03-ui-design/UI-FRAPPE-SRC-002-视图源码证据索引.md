---
id: UI-FRAPPE-SRC-002
type: ui
domain_object: FrappeViewSourceIndex
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-054, E-FRAPPE-SRC-055, E-FRAPPE-SRC-056, E-FRAPPE-SRC-057, E-FRAPPE-SRC-058, E-FRAPPE-SRC-059, E-FRAPPE-SRC-060, E-FRAPPE-SRC-061, E-FRAPPE-SRC-062, E-FRAPPE-SRC-063, E-FRAPPE-SRC-064, E-FRAPPE-SRC-065, E-FRAPPE-SRC-066, E-FRAPPE-SRC-067, E-FRAPPE-SRC-068, E-FRAPPE-SRC-069, E-FRAPPE-SRC-070, E-FRAPPE-SRC-071, E-FRAPPE-SRC-072, E-FRAPPE-SRC-073]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-SRC-001]
owner: AI
ai_generated: true
---

# Frappe 视图源码证据索引

## 结论

Frappe 视图层由 Form Layout、ListView、Workspace 三类元数据/运行时结构构成。Form Layout 管理 tabs、sections、fields_list、fields_dict；ListView 管理字段、筛选、列和事件；Workspace 管理 charts、shortcuts 等入口聚合。

## 源码证据范围

```text
E-FRAPPE-SRC-054..073
layout.js: form runtime layout
list_view.js: list runtime view
workspace.json: workspace metadata
```

## 对自研平台的启发

视图体系应拆分为：

```text
FormLayout
ListView
Workspace
FieldRuntime
FilterRuntime
ColumnRuntime
NavigationEntry
```
