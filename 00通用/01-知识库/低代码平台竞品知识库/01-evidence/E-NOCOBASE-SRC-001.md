---
id: E-NOCOBASE-SRC-001
type: evidence
competitor: NocoBase
module: data-model
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/database/src/collection.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase Collection 源码

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/database/src/collection.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：raw 文件可复核；`CollectionOptions` 从 L104 开始，`fields` 在 L117，`Collection` 类从 L154 开始，`setFields()` 在 L598，`sync()` 在 L941。

## 原始观察

`CollectionOptions` 定义了 NocoBase Collection 的核心元数据字段，包括 `name`、`title`、`namespace`、`dataCategory`、`migrationRules`、`dumpRules`、`tableName`、`inherits`、`viewName`、`writableView`、`isThrough`、`filterTargetKey`、`fields`、`fieldSort`、`model`、`repository`、`sortable`、`autoGenId`、`magicAttribute`、`tree`、`template`、`simplePaginate`、`origin`、`asStrategyResource` 等。

源码还显示 `Collection` 运行时持有 `options`、`fields: Map`、`model`、`repository`，并通过 `setFields()` / `addField()` / `setField()` 建立字段，`sync()` 负责同步 Sequelize 模型。

## 证据强度

直接事实。源码文件明确给出 CollectionOptions 和 Collection 运行时结构。
