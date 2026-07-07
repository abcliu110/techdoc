---
id: E-NOCOBASE-SRC-010
type: evidence
competitor: NocoBase
module: migration
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/server/src/migration.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase Migration 基类

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/server/src/migration.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`Migration` 继承数据库迁移基类在 L17，`appVersion` 在 L18，`app` 上下文访问器在 L22，`pm` 访问器在 L27，`plugin` 访问器在 L31。

## 原始观察

NocoBase 服务端 Migration 继承 `@nocobase/database` 的 Migration，并通过 context 暴露 app、plugin manager 和当前 plugin。

## 证据强度

直接事实。源码明确给出迁移执行时可以访问应用、插件管理器和插件上下文。
