---
id: E-DIRECTUS-SRC-002
type: evidence
competitor: Directus
module: role-policy-access
source_channel: github
source_type: source
source_url: https://github.com/directus/directus/blob/main/api/src/cli/commands/roles/create.ts
source_owner: project-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-repository
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Directus 角色创建中的 Policy 与 Access 关联

## 原始观察

Directus GitHub 源码中的 roles create CLI 命令使用 RolesService、PoliciesService 和 AccessService：先创建 policy，再创建 role，最后创建 role 与 policy 的 access 关联。

## 证据强度

源码初证：已阅读公开源码页面，但未本地运行验证。

## 可抽取知识

- Directus 11 的访问控制不是“角色直接拥有所有权限”的单层模型，而是 role、policy、access 组合。
- 自研平台可借鉴 role-policy-access 分层：角色是身份分组，策略是访问规则集合，access 是绑定关系。
- 这类分层会增加配置复杂度，需要 UI 引导、默认策略和审计视图，否则业务管理员难以理解。
