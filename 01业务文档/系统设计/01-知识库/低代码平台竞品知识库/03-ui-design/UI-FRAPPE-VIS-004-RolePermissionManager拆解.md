---
id: UI-FRAPPE-VIS-004
type: ui
domain_object: RolePermissionManager
competitors: [Frappe]
evidence: [E-FRAPPE-UI-004, E-FRAPPE-SRC-021, E-FRAPPE-SRC-022]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-FRAPPE-SRC-001, PM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe Role Permission Manager 拆解

## 页面目标

按 DocType、Role 和 Action 配置对象权限，控制用户能对业务对象执行哪些操作。

## 页面分区

```text
DocType 选择
Role 权限矩阵
Action 权限：read/write/create/delete 等
User Permission 进一步限制记录范围
```

## 设计启发

自研平台权限 UI 应以对象为中心，同时允许角色矩阵配置。对象级动作权限应与字段权限、数据范围权限分层。

## 边界

尚未实测 permlevel、User Permission 和不同角色登录后的 UI 差异。
