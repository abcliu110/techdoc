---
id: PM-FRAPPE-SRC-003
type: permission
domain_object: FrappePermissionSourceIndex
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-034, E-FRAPPE-SRC-035, E-FRAPPE-SRC-036, E-FRAPPE-SRC-037, E-FRAPPE-SRC-038, E-FRAPPE-SRC-039, E-FRAPPE-SRC-040, E-FRAPPE-SRC-041, E-FRAPPE-SRC-042, E-FRAPPE-SRC-043, E-FRAPPE-SRC-044, E-FRAPPE-SRC-045, E-FRAPPE-SRC-046, E-FRAPPE-SRC-047, E-FRAPPE-SRC-048, E-FRAPPE-SRC-049, E-FRAPPE-SRC-050, E-FRAPPE-SRC-051, E-FRAPPE-SRC-052, E-FRAPPE-SRC-053]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-FRAPPE-SRC-001, PM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe 权限源码证据索引

## 结论

Frappe 权限体系由 `has_permission`、`get_doc_permissions`、`get_role_permissions`、`has_user_permission`、DocPerm、User Permission 共同构成。权限动作覆盖 select/read/write/create/delete/submit/cancel/export/share 等，并支持 owner、permlevel、用户权限限制与自定义权限。

## 源码证据范围

```text
E-FRAPPE-SRC-034..053
permissions.py: runtime permission checks
docperm.json: role action matrix
user_permission.json: user data scope
```

## 对自研平台的启发

权限模型应区分：

```text
RolePermission
DocumentPermission
UserPermission
OwnerPermission
PermLevel
SharePermission
ControllerHookPermission
```
