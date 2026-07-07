---
id: UI-FRAPPE-VIS-002
type: ui
domain_object: FrappeListView
competitors: [Frappe]
evidence: [E-FRAPPE-UI-002, E-FRAPPE-SRC-012]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-SRC-001, DM-FRAPPE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# Frappe List View 拆解

## 页面目标

为每个常规 DocType 自动提供对象列表、检索、过滤、排序、分页和视图切换能力。

## 可见界面证据

官方 List 文档说明 List View 为多数 DocType 自动生成，并展示 List View 截图；文档列出 filters、sorting、paging、tag filter，以及切换到 Report、Calendar、Gantt、Kanban 等视图。

## 页面分区

```text
顶部：DocType 列表页标题与操作
筛选：字段过滤、标签过滤
主体：记录列表
分页：分页浏览
视图切换：Report / Calendar / Gantt / Kanban 等
```

## UI 模式

Frappe 的列表不是一个孤立页面，而是 DocType 的默认视图。列表页同时承担数据浏览、筛选检索和进入其他视图形态的入口。

## 对自研平台的启发

自研平台应为每个业务对象默认生成列表视图，并把视图切换设计成统一模型：

```text
Object List
-> Table/List
-> Report
-> Calendar/Gantt/Kanban
```

列表配置应从对象字段派生，但允许按视图覆盖默认字段、默认过滤条件和操作按钮。

## 边界

本卡未验证不同 DocType 的默认列、用户自定义列表配置和大数据量列表性能。
