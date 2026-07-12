---
id: UI-NOCOBASE-VIS-003
type: ui
domain_object: PermissionUI
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-003, E-NOCOBASE-SRC-023, E-NOCOBASE-SRC-024]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-NOCOBASE-SRC-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# NocoBase 角色权限界面拆解

## 页面目标

让管理员按角色配置用户可访问的菜单、页面和业务能力，将技术 ACL 规则映射成可操作的权限配置界面。

## 可见界面证据

- 官方教程展示从设置菜单进入 Users & Permissions -> Roles。
- 角色创建界面包含 Role Name、Role Key 等信息。
- Menu permissions tab 以勾选方式配置菜单访问权。

## 页面分区

```text
设置入口：Users & Permissions
角色列表：已有角色与新增角色
角色详情：基础信息 + 权限配置 tab
菜单权限：按菜单项勾选允许/隐藏
```

## UI 模式

权限 UI 采用“角色中心”的配置方式：先定义角色，再把菜单、页面、对象操作等能力挂到角色上。这比直接对每个用户授权更适合企业系统治理。

## 对自研平台的启发

自研平台权限设计至少要把以下层分开：

```text
角色
菜单/页面可见性
对象级操作权限
字段级可见/可编辑
数据范围/行级条件
```

UI 上应优先让管理员看见“某角色能看到什么、能做什么”，而不是让用户面对底层 ACL 表。

## 边界

本卡只补菜单与角色配置的可见界面拆解；行级、字段级权限的运行时差异仍需实测截图或 API 结果补证。
