---
id: E-NOCOBASE-SRC-006
type: evidence
competitor: NocoBase
module: permission
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/acl/src/acl-role.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase ACLRole

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/acl/src/acl-role.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`ACLRole` 类在 L33，`strategy` 在 L34，`snippets` 在 L36，`getResource()` 在 L51，`setStrategy()` 在 L55，`getStrategy()` 在 L59，`effectiveSnippets()` 在 L108，allowed/rejected actions 计算在 L150-L157。

## 原始观察

`ACLRole` 持有策略、资源映射和 snippets。`effectiveSnippets()` 会根据 snippet 规则计算 allowed 与 rejected 集合，并进一步推导可用 actions。

## 证据强度

直接事实。源码明确给出 NocoBase 角色级策略、资源和 snippets 权限片段机制。
