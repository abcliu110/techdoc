---
id: PM-NOCOBASE-SRC-002
type: permission
domain_object: NocoBaseACLSourceIndex
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-031, E-NOCOBASE-SRC-032, E-NOCOBASE-SRC-033, E-NOCOBASE-SRC-034, E-NOCOBASE-SRC-035, E-NOCOBASE-SRC-036, E-NOCOBASE-SRC-037, E-NOCOBASE-SRC-038, E-NOCOBASE-SRC-039, E-NOCOBASE-SRC-040, E-NOCOBASE-SRC-041, E-NOCOBASE-SRC-042, E-NOCOBASE-SRC-043, E-NOCOBASE-SRC-044, E-NOCOBASE-SRC-045, E-NOCOBASE-SRC-046, E-NOCOBASE-SRC-047, E-NOCOBASE-SRC-048, E-NOCOBASE-SRC-049, E-NOCOBASE-SRC-050]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-NOCOBASE-SRC-001]
owner: AI
ai_generated: true
---

# NocoBase ACL 源码证据索引

## 结论

NocoBase ACL 以角色、资源、动作、策略、snippet、allow manager 和 middleware 组合实现。权限不是单一布尔值，而是会把 action params、filter、fields、appends 等参数合并进资源动作。

## 源码证据范围

```text
E-NOCOBASE-SRC-031..050
acl.ts: DefineOptions / role map / available actions / strategies / can / middleware / parseJsonTemplate
apply-data-permissions.ts: applyDataPermissions
```

## 对自研平台的启发

权限模型应支持：

```text
Role
Resource
Action
ActionParams
DataScope
FieldScope
PermissionMiddleware
PolicyMerge
TemplateFilter
```

仅做菜单权限或接口权限不足以支撑正式商用低代码平台。
