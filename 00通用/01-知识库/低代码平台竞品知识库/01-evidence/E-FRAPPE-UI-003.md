---
id: E-FRAPPE-UI-003
type: evidence
competitor: Frappe
module: workspace
source_channel: official-doc
source_type: screenshot
source_url: https://docs.frappe.io/framework/user/en/desk/workspace
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Workspace 可见界面

## 原始观察

Frappe 官方 Workspace 文档说明 Workspace 是登录后首先看到的页面，并有专用侧边栏；标准 workspace 位于 PUBLIC 区域，私有 workspace 位于 MY WORKSPACES 区域。文档包含 Create Workspace、Create Child Workspace、Workspace Blocks、Workspace Sidebar 等截图，并说明 Workspace Manager 角色才能创建、编辑或删除 public workspaces。

## 证据强度

直接事实：官方文档页面展示 workspace 创建、块、侧边栏和 public/private 工作区规则。

## 可抽取知识

- Frappe 把 Workspace 作为业务入口和导航聚合页，而不是简单菜单。
- Workspace 有 public/private 两种可见性层级，并受 Workspace Manager 角色约束。
- 自研平台需要把“工作台/门户页”从对象表单和列表视图中独立出来建模。
