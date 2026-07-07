---
id: PM-NOCOBASE-SRC-001
type: permission
domain_object: NocoBaseACL
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-005, E-NOCOBASE-SRC-006, E-NOCOBASE-SRC-007]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-LOWCODE-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# NocoBase ACL 权限判定链路

## 源码依据

- `packages/core/acl/src/acl.ts`：ACL 角色定义、资源动作判断、中间件接入。
- `packages/core/acl/src/acl-role.ts`：角色策略、资源映射、snippets 允许/拒绝规则。
- `packages/plugins/@nocobase/plugin-acl/src/server/actions/apply-data-permissions.ts`：dataSourceKey、resource、action、fields、scope 级权限保存。

## 字段和机制

NocoBase 权限模型覆盖：

```text
Role
Resource
Action
Strategy
Snippet
DataSourceKey
Fields
Scope
Middleware
```

`ACL.can()` 是权限判断入口，`ACL.middleware()` 将判断接入请求上下文。`applyDataPermissions()` 显示权限配置可以落到数据源、资源、动作、字段和 scope。

## 对自研平台的启发

企业低代码权限需要同时支持：

```text
角色策略
资源动作权限
字段级权限
数据范围权限
权限片段/快捷授权
请求中间件统一拦截
```

只做“菜单权限”或“页面权限”不足以承载业务对象平台。

## 边界

本卡基于源码结构，未实测 NocoBase UI 中每个权限配置项如何呈现。
