---
id: E-DIRECTUS-DOC-003
type: evidence
competitor: Directus
module: access-control
source_channel: official-doc
source_type: doc
source_url: https://directus.com/docs/guides/auth/access-control
source_owner: competitor-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Directus Access Control

## 原始观察

Directus 官方访问控制文档将访问控制定位为管理不同用户和角色可创建、读取、更新、删除、共享哪些数据的能力，并在模型上关联 users、roles、policies 和 permissions。

## 证据强度

直接事实：官方文档明确说明访问控制对象和 CRUD 边界。

## 可抽取知识

- Directus 权限模型的关键不是单一角色表，而是用户、角色、策略和权限的组合。
- 自研平台应把权限拆成身份、角色、策略、对象、字段、动作、条件，而不是只做菜单权限。
- 策略权限需要和 API、UI、服务层一致执行。
