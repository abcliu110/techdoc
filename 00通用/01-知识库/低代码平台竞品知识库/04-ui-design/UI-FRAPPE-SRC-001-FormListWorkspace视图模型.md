---
id: UI-FRAPPE-SRC-001
type: ui
domain_object: FrappeViewMetadata
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-011, E-FRAPPE-SRC-012, E-FRAPPE-SRC-013]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-LOWCODE-001, DM-FRAPPE-SRC-001, DM-FRAPPE-SRC-002, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# Frappe Form/List/Workspace 视图模型

## 源码依据

- `frappe/public/js/frappe/form/layout.js`：`Layout` 组织 tabs、sections、fields_list、fields_dict，并负责 render、make_field、refresh_dependency。
- `frappe/public/js/frappe/list/list_view.js`：`ListView` 组织 filters、fields、columns、render_list、setup_events。
- `frappe/desk/doctype/workspace/workspace.json`：Workspace 以 DocType JSON 定义 title、content、charts、shortcuts、links、public 等页面入口字段。

## 抽象

Frappe 的 UI 不是单独的一套页面配置模型，而是围绕 DocType/DocField 元数据展开：

```text
DocType / DocField
-> Form Layout
-> ListView Columns / Filters
-> Workspace Entry Metadata
```

表单视图强调字段运行时布局和依赖刷新，列表视图强调字段列构建、筛选和事件绑定，Workspace 则负责工作台级页面入口和聚合内容。

## 对自研平台的启发

自研低代码平台不能只设计“页面 JSON”，还需要把 UI 元数据和业务对象元数据的关系明确化：

```text
BusinessObject
Field
FormLayout
ListView
Workspace
ViewDependency
ViewPermission
```

其中 Form/List 应优先由对象字段元数据派生，再允许做视图级覆盖；Workspace 应作为导航和业务入口聚合层，避免和对象表单配置混为一谈。

## 边界

本卡只覆盖 Frappe 表单、列表和工作台元数据的源码初证，不覆盖 Form Builder、DocType Layout、页面设计器交互和真实运行截图。
