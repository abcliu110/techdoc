---
id: E-NOCOBASE-UI-003
type: evidence
competitor: NocoBase
module: permission-ui
source_channel: official-doc
source_type: screenshot
source_url: https://docs.nocobase.com/tutorials/v2/05-roles-and-permissions
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase 角色与菜单权限可见界面

## 原始观察

NocoBase 官方 2.0 教程第 5 章展示 Users & Permissions：从右上角设置菜单进入 Users & Permissions -> Roles，新增 HelpDesk Admin、Technician、Regular User 等角色，并在角色权限配置页的 Menu permissions tab 中勾选或取消菜单访问权限。

官方页面包含创建角色、角色列表、菜单权限配置等截图。

## 证据强度

直接事实：官方教程页面展示角色创建入口和菜单权限配置界面。

## 可抽取知识

- NocoBase 权限配置有明确的可见管理界面，不只是后端 ACL 代码。
- 菜单可见性可按角色配置，适合把“页面入口权限”作为低代码平台权限模型的一层。
- 角色配置界面同时暴露 Role Name 和 Role Key，说明权限 UI 需要兼顾业务可读名和系统标识。
