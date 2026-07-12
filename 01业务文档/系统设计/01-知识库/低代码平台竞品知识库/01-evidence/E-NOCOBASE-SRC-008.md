---
id: E-NOCOBASE-SRC-008
type: evidence
competitor: NocoBase
module: ui-schema
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/plugins/%40nocobase/plugin-ui-schema-storage/src/server/repository.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase UI Schema Storage Repository

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/plugins/@nocobase/plugin-ui-schema-storage/src/server/repository.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`UiSchemaRepository` 在 L81，`schemaToSingleNodes()` 在 L93，自动生成 `x-uid` 在 L103-L107，`getJsonSchema()` 在 L221，`nodesToSchema()` 在 L230，`patch()` 在 L326，`insertAdjacent()` 在 L474，`duplicate()` 在 L528，`insert()` 在 L538，`insertNewSchema()` 在 L549，`remove()` 在 L436，`x-server-hooks` 处理在 L905。

## 原始观察

UI Schema 被拆成带 `x-uid` 的节点并持久化，另有 `uiSchemaTreePath` 维护祖先/后代路径。Repository 支持 JSON schema 还原、patch、insertAdjacent、duplicate、remove、缓存清理和 server hooks。

## 证据强度

直接事实。源码明确给出 NocoBase 页面/视图 schema 的节点化存储、树路径、补丁、插入、删除和复制机制。
