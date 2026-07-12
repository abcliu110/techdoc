---
id: UI-NOCOBASE-SRC-001
type: ui
domain_object: NocoBaseUISchema
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-008]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-LOWCODE-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase UI Schema 节点化存储

## 源码依据

- `packages/plugins/@nocobase/plugin-ui-schema-storage/src/server/repository.ts`
- `UiSchemaRepository`：L81
- `schemaToSingleNodes()`：L93
- `x-uid` 自动生成：L103-L107
- `getJsonSchema()`：L221
- `nodesToSchema()`：L230
- `patch()`：L326
- `insertAdjacent()`：L474
- `duplicate()`：L528
- `insert()`：L538
- `remove()`：L436

## 抽象

NocoBase 没有把页面视图简单保存成一整块 JSON，而是拆成带 `x-uid` 的 schema 节点，并用 tree path 维护层级关系。

核心操作包括：

```text
schema -> nodes
nodes -> schema
patch
insertAdjacent
duplicate
remove
cache clear
server hooks
```

## 对自研平台的启发

页面构建器应避免只保存“整页大 JSON”。更可维护的结构是：

```text
PageSchema
SchemaNode
TreePath
NodePatch
NodeInsert
NodeMove
NodeDuplicate
ServerHook
```

这样才能支持局部更新、权限绑定、插件插槽、复制区块和后续迁移。

## 边界

本卡只证明 UI schema 存储机制，不覆盖前端拖拽交互和组件属性面板。
