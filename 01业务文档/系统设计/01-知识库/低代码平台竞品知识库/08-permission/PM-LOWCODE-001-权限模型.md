---
id: PM-LOWCODE-001
type: permission
domain_object: LowCodePermission
competitors: [Kingdee-Cosmic, ToolJet, NocoDB, Directus, NocoBase, Appsmith, Frappe]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-004, E-TOOLJET-001, E-NOCODB-001, E-DIRECTUS-001, E-DIRECTUS-DOC-003, E-DIRECTUS-SRC-001, E-DIRECTUS-SRC-002, E-NOCOBASE-001, E-APPSMITH-001, E-APPSMITH-SRC-002, E-FRAPPE-001, E-FRAPPE-SRC-001, E-FRAPPE-SRC-003]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-FRAPPE-SRC-001, PM-DIRECTUS-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# 权限模型：低代码平台多层权限

成熟度说明：本卡基于公开文档、Frappe 权限源码初证和 Directus 初始源码证据抽象权限层级；尚未完成角色、字段级、行级、数据源权限的实际配置验证；当前只作为 L0+ 方向级权限判断。

## 权限层级

```text
Tenant / Organization
→ Workspace
→ Application
→ BusinessObject / Collection
→ Page / View
→ Action / Query / Workflow
→ Field / Row / Data Scope
```

## 竞品观察

- 金蝶强调组织、人员、客商、权限等企业基础架构能力。
- ToolJet 文档明确提到 RBAC、SSO 和 workspace 级数据源共享。
- NocoDB 明确存在 Organization、Workspace、Base 层级角色。
- Directus 明确以 roles、permissions、policies 控制数据 CRUD。
- Directus 源码初证显示 role、policy、access 可以分层组合，ItemsService 执行依赖 schema 与 accountability。
- NocoBase 公开文档包含 users & permissions。
- Frappe `DocType` 源码显示权限是 `permissions: Table(DocPerm)`；`permissions.py` 源码显示权限判定组合了 doctype、ptype、doc、user、owner、controller、role、user permission 等因素。

## 设计启发

低代码平台权限不能只做“谁能打开应用”。最低要求是：

```text
谁能设计应用
谁能发布应用
谁能连接数据源
谁能运行查询
谁能看某个对象/字段/行
谁能触发某个动作/流程
谁能管理版本和回滚
```

源码初证补充的设计启发：

```text
权限不能只有 RBAC。
权限判定入口应支持“类型级”和“实例级”两种上下文。
业务对象控制器或规则引擎需要有追加权限判断的逃逸通道。
导出、迁移、模板化等工具能力必须继承应用、页面、动作、数据源和 workspace 的归属校验。
```
