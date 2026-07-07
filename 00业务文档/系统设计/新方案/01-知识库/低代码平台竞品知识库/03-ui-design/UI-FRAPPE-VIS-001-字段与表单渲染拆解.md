---
id: UI-FRAPPE-VIS-001
type: ui
domain_object: FrappeFormUI
competitors: [Frappe]
evidence: [E-FRAPPE-UI-001, E-FRAPPE-SRC-001, E-FRAPPE-SRC-002]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-SRC-001, DM-FRAPPE-SRC-001, DM-FRAPPE-SRC-002, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# Frappe 字段与表单渲染拆解

## 页面目标

通过 DocType/DocField 字段定义自动生成表单输入界面，并让字段类型、布局元字段和校验选项共同决定最终 UI。

## 可见界面证据

- 官方 Field Types 文档展示字段类型下拉、Data/Check/Select/Table/Code/Color 等字段截图。
- 官方文档展示 Select 字段在 DocType/Customize Form 中定义，以及在新表单中的渲染效果。
- 官方文档展示 Section Break、Column Break、Tab Break 等布局字段对表单结构的影响。

## 页面分区

```text
字段定义区：field type / options / default / validation
表单渲染区：按字段类型生成输入组件
布局控制：section / column / tab break
子表：Table 字段渲染 child table
```

## UI 模式

Frappe 把“字段定义”和“表单控件渲染”强绑定：字段类型既是数据模型属性，也是 UI 控件选择器。布局也通过元字段进入 DocField 列表，而不是独立页面 JSON。

## 对自研平台的启发

自研低代码平台需要区分三类字段：

```text
数据字段：持久化业务属性
控件字段：决定输入组件和校验
布局字段：section、column、tab 等不持久化结构控制
```

这样可以让默认表单从对象字段自动生成，同时允许业务人员通过布局字段调整页面结构。

## 边界

本卡基于官方截图和源码初证，尚未覆盖 Form Builder 拖拽体验、复杂字段联动和权限控制后的表单差异。
