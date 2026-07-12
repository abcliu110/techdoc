---
id: PM-DIRECTUS-001
type: permission
domain_object: DirectusAccessControl
competitors: [Directus]
evidence: [E-DIRECTUS-001, E-DIRECTUS-DOC-003, E-DIRECTUS-SRC-001, E-DIRECTUS-SRC-002]
strength: 高可信推断
confidence: 0.75
status: active
collected_at: 2026-07-06
valid_until: 2026-10-06
links: [PM-LOWCODE-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# Directus 策略权限模型

## 证据边界

本卡基于 Directus 官方文档和公开源码页面，尚未完成本地创建 role/policy/permission 的运行验证。

## 权限对象抽象

Directus 权限模型可抽象为：

```text
User
Role
Policy
Access
Permission
Collection
Field
Action
Condition / Filter
Accountability
```

## 机制判断

官方文档确认 Directus 用 roles、policies、permissions 管理数据访问。源码线索显示角色创建时会创建 policy，并通过 access 关联 role 与 policy；ItemsService 执行 item 读写时依赖 schema 和 accountability。

## 对自研平台的启发

- 企业低代码权限应拆成角色、策略、对象、字段、动作、条件、执行身份。
- 服务层必须接收并校验 accountability / execution context。
- UI 配置的权限必须和 API / 服务层一致执行。

## 失败模式

- 只做菜单权限，API 层仍可越权访问对象。
- 流程或扩展以高权限执行，却没有触发人与执行身份的审计。
- 导出、模板、复制等工具功能绕过对象归属校验。

## 待验证

- Directus policy 与 permission 的完整字段。
- 字段级、行级或过滤条件权限的实际执行路径。
- Flow 在 elevated accountability 下的运行边界。
