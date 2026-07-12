---
id: E-NOCOBASE-SRC-007
type: evidence
competitor: NocoBase
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/plugins/%40nocobase/plugin-acl/src/server/actions/apply-data-permissions.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase 数据权限应用逻辑

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/plugins/@nocobase/plugin-acl/src/server/actions/apply-data-permissions.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`ApplyActionInput` 在 L13，`dataSourceKey` 在 L66，scope 查询在 L70-L79，`normalizeAction()` 在 L85，fields 在 L121，`applyDataPermissions()` 在 L140，role 查询在 L150，roles.resources repository 在 L158，事务在 L161，保存 action 字段/范围在 L224-L230。

## 原始观察

数据权限应用逻辑按 roleName 和 dataSourceKey 处理资源权限。每个 action 可携带 fields、scopeId/scopeKey，权限保存到 `roles.resources` 及其 actions 关联中，并在事务内创建或更新。

## 证据强度

直接事实。源码明确给出 NocoBase 数据源、资源、动作、字段和 scope 级权限配置保存逻辑。
