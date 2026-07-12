---
id: UI-FRAPPE-VIS-003
type: ui
domain_object: FrappeWorkspace
competitors: [Frappe]
evidence: [E-FRAPPE-UI-003, E-FRAPPE-SRC-013]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-SRC-001, ADR-LOWCODE-UI-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# Frappe Workspace 拆解

## 页面目标

作为用户登录后的业务入口页，将常用 DocType、报表、链接、图表和模块入口组织成可导航的工作台。

## 可见界面证据

官方 Workspace 文档展示 Create Workspace、Create Child Workspace、Workspace Blocks、Workspace Sidebar 等截图，并说明 PUBLIC 与 MY WORKSPACES 两类侧边栏区域。

## 页面分区

```text
侧边栏：PUBLIC / MY WORKSPACES
工作区主体：workspace blocks
创建入口：Create Workspace / Create Child Workspace
权限边界：Workspace Manager 控制 public workspace 的创建、编辑、删除
```

## UI 模式

Workspace 是 Frappe 的业务入口聚合层。它不是单个对象的表单或列表，而是面向用户角色和工作任务的首页/门户。

## 对自研平台的启发

自研低代码平台应将“工作台”作为独立模型：

```text
Workspace
WorkspaceBlock
Shortcut
Chart
ReportLink
VisibilityScope
ManagerRole
```

这能把业务入口、导航、常用操作和指标看板统一承载，而不是散落在菜单配置和页面配置中。

## 边界

本卡未验证 Workspace 的拖拽编辑、块类型细节、公共工作区发布流程和角色切换后的可见性。
