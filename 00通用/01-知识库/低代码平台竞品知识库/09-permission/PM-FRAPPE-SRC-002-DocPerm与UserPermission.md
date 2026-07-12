---
id: PM-FRAPPE-SRC-002
type: permission
domain_object: FrappePermissionModel
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-005, E-FRAPPE-SRC-006]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-FRAPPE-SRC-001, PM-LOWCODE-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# Frappe DocPerm 与 User Permission

## 源码依据

- `frappe/core/doctype/docperm/docperm.json`
- `frappe/core/doctype/user_permission/user_permission.json`

## 字段级模型

DocPerm 覆盖：

```text
role
if_owner
permlevel
read
write
create
delete
submit
cancel
export
share
```

User Permission 覆盖：

```text
user
allow
for_value
is_default
applicable_for
hide_descendants
```

## 抽象

Frappe 权限分两类元数据：

```text
DocPerm：角色在某 DocType / permlevel 上拥有哪些动作权限
User Permission：用户对某类对象值的数据范围限制
```

这与 `permissions.py` 的运行时判断链路互相支撑。

## 对自研平台的启发

自研平台权限模型建议拆成：

```text
RolePermission
FieldPermLevel
ActionPermission
OwnerOnlyFlag
UserDataScope
ApplicableObject
HierarchyScope
```

这样既能表达角色动作权限，也能表达具体用户的数据范围。

## 边界

本卡未实测 Frappe 权限 UI，也未覆盖 permission manager 页面逻辑。
