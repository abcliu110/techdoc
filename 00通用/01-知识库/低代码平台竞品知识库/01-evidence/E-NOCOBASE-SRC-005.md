---
id: E-NOCOBASE-SRC-005
type: evidence
competitor: NocoBase
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/acl/src/acl.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase ACL 核心

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/acl/src/acl.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`ACL` 类在 L75，middlewares 在 L105/L112，`define()` 在 L160，`can()` 在 L219，`getCanByRole()` 在 L252，`allow()` 在 L348，`middleware()` 在 L369，核心 middleware 在 L457。

## 原始观察

`ACL` 维护角色、策略资源、allowManager、snippetManager 和中间件链。权限判断入口为 `can(options)`，并通过角色、资源、动作和中间件组合进行判断。`allow(resourceName, actionNames, condition)` 可直接注册资源动作允许规则。`middleware()` 将 ACL 判断接入请求上下文。

## 证据强度

直接事实。源码明确给出 NocoBase ACL 的角色定义、权限判断、allow 规则和中间件机制。
