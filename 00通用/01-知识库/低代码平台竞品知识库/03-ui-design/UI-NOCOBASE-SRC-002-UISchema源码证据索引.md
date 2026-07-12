---
id: UI-NOCOBASE-SRC-002
type: ui
domain_object: NocoBaseUISchemaSourceIndex
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-051, E-NOCOBASE-SRC-052, E-NOCOBASE-SRC-053, E-NOCOBASE-SRC-054, E-NOCOBASE-SRC-055, E-NOCOBASE-SRC-056, E-NOCOBASE-SRC-057, E-NOCOBASE-SRC-058, E-NOCOBASE-SRC-059, E-NOCOBASE-SRC-060, E-NOCOBASE-SRC-061, E-NOCOBASE-SRC-062, E-NOCOBASE-SRC-063, E-NOCOBASE-SRC-064, E-NOCOBASE-SRC-065, E-NOCOBASE-SRC-066, E-NOCOBASE-SRC-067, E-NOCOBASE-SRC-068, E-NOCOBASE-SRC-069, E-NOCOBASE-SRC-070]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-NOCOBASE-SRC-001]
owner: AI
ai_generated: true
---

# NocoBase UI Schema 源码证据索引

## 结论

NocoBase 页面元数据以 `UiSchemaRepository` 管理，核心机制是把 JSON schema 拆成带 `x-uid` 的节点，并用 tree path 支撑重建、插入、复制、删除、批量更新和缓存失效。

## 源码证据范围

```text
E-NOCOBASE-SRC-051..070
repository.ts: UiSchemaRepository / schemaToSingleNodes / nodesToSchema / patch / remove / insertAdjacent / duplicate / insert
```

## 对自研平台的启发

页面模型应避免“整页 JSON 黑盒”，而应支持：

```text
SchemaNode
NodeUid
TreePath
Patch
InsertAdjacent
Duplicate
Remove
CacheInvalidation
ServerHook
```
