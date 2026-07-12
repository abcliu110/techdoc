---
id: E-NOCOBASE-SRC-002
type: evidence
competitor: NocoBase
module: data-model
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/database/src/fields/field.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase Field 源码

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/database/src/fields/field.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：raw 文件可复核；`FieldContext` 在 L18，`BaseFieldOptions` 在 L48，`BaseColumnFieldOptions` 在 L57，`Field` 抽象类在 L64，`isRelationField()` 在 L90，`sync()` 在 L94。

## 原始观察

源码定义 `FieldContext`，包含 `database` 和 `collection`。`BaseFieldOptions` 包含 `name`、`hidden`、`translation`、`validation` 等字段，并允许扩展属性。`BaseColumnFieldOptions` 继承基础字段选项，并包含 `dataType`、`index` 等数据库列相关属性。

`Field` 抽象类持有 `options`、`context`、`database`、`collection`，并提供 `name`、`type`、`dataType`、`isRelationField()`、`sync()` 等运行时能力。

## 证据强度

直接事实。源码明确给出 Field 及字段选项结构。
