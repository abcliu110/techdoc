---
id: UI-FRAPPE-VIS-007
type: ui
domain_object: WorkspaceAccess
competitors: [Frappe]
evidence: [E-FRAPPE-UI-007, E-FRAPPE-SRC-013]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-VIS-003, PM-FRAPPE-SRC-001]
owner: AI
ai_generated: true
---

# Frappe Workspace Access 拆解

## 页面目标

按角色限制 workspace 可见性，确保不同岗位只看到对应工作台。

## 页面分区

```text
Workspace 设置
Role Access
角色选择
侧边栏可见性
用户视角差异
```

## 设计启发

自研平台需要把工作台权限和菜单权限分离：菜单是导航项，工作台是任务聚合页，二者都需要角色可见性控制。

## 边界

尚未实测角色切换后工作台可见性、缓存刷新和直接 URL 访问拦截。
