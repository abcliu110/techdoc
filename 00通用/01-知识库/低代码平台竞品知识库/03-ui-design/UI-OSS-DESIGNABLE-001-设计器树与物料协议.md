---
id: UI-OSS-DESIGNABLE-001
type: ui
domain_object: DesignableDesigner
competitors: [Designable, Formily-Designable]
evidence: [E-OSS-FORM-DESIGNABLE-001, E-OSS-FORM-DESIGNABLE-SRC-001, E-OSS-FORM-DESIGNABLE-SRC-002, E-OSS-FORM-DESIGNABLE-SRC-003]
strength: 源码初证
confidence: 0.6
status: active
collected_at: 2026-07-07
valid_until: 2026-10-07
links: [UI-LOWCODE-FORM-OSS-001, DM-OSS-FORMILY-001, NFR-OSS-FORMILY-001]
owner: AI
ai_generated: true
---

# UI 设计：Designable 设计器树与物料协议

## 证据边界

本卡基于 Designable README、Formily Designable README、transformer 源码线索和 GitHub discussion。由于 GitHub clone 失败，当前为源码初证，不是完整源码审计。

## 核心模型

Designable 可抽象为通用设计器引擎：

```text
Workspace
  -> Operation
  -> TreeNode
  -> Material / Component
  -> Property Panel
  -> Transformer
  -> Runtime Schema
```

## 设计器关键能力

| 能力 | 作用 | 证据 |
|---|---|---|
| TreeNode | 设计态节点树，用于承载拖拽和层级结构 | transformToTreeNode discussion |
| Workspace / operation.tree | 当前设计空间和可编辑树入口 | transformToTreeNode discussion |
| Transformer | schema 与 TreeNode 之间转换 | transformer 源码线索 |
| Material / Component | 组件物料与渲染目标 | Designable builder 平台定位 |
| Property Panel | 编辑节点属性并反写 schema | 由设计器模式推断，待源码补证 |

## 对自研平台的设计启发

1. 表单设计器内部应有设计态节点树，不应直接编辑发布态 schema。
2. 设计器必须支持 schema 反显：历史版本、导入表单、复制模板都依赖反向转换。
3. 物料协议要和运行时组件协议分开：物料包含拖拽、图标、分类、属性面板；运行时组件只负责渲染和交互。
4. Transformer 是单向门风险点：它决定设计态信息哪些保留、哪些剥离、哪些转成运行时。
5. Designable 的价值在通用 builder 引擎，表单只是其中一个场景。

## 自研平台最小协议

```text
DesignerNode {
  id
  type
  props
  children
  materialId
  bindings
  rules
  designState
}

Material {
  id
  title
  category
  icon
  defaultProps
  propertySchema
  runtimeComponent
  allowedChildren
}

Transformer {
  toRuntimeSchema(designerTree)
  toDesignerTree(runtimeSchema)
}
```

## 待补源码

- `@designable/core` TreeNode / Workspace / Operation。
- `@designable/react` 画布、拖拽、选择、属性面板。
- `@designable/formily` transformToTreeNode / transformToSchema。
- Ant Design / Fusion 物料注册方式。

