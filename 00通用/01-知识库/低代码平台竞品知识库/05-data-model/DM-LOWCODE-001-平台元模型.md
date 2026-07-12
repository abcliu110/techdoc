---
id: DM-LOWCODE-001
type: data-model
domain_object: LowCodeMetaModel
competitors: [Kingdee-Cosmic, NocoBase, Frappe, Directus, NocoDB, Appsmith, ToolJet]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-KINGDEE-COSMIC-003, E-KINGDEE-COSMIC-005, E-NOCOBASE-001, E-NOCOBASE-SRC-001, E-NOCOBASE-SRC-002, E-NOCOBASE-SRC-003, E-FRAPPE-001, E-FRAPPE-SRC-001, E-FRAPPE-SRC-002, E-DIRECTUS-001, E-DIRECTUS-DOC-002, E-DIRECTUS-SRC-001, E-NOCODB-001, E-APPSMITH-001, E-APPSMITH-DOC-002, E-APPSMITH-SRC-001, E-TOOLJET-001]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-NOCOBASE-SRC-001, DM-NOCOBASE-SRC-002, DM-FRAPPE-SRC-001, DM-FRAPPE-SRC-002, DM-APPSMITH-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# 数据模型：低代码平台元模型

成熟度说明：本卡是跨竞品元模型抽象。NocoBase Collection/Field/Relation 与 Frappe DocType/DocField 已有源码级字段拆解；本轮补入 Directus Fields / ItemsService 和 Appsmith 应用构建元模型初证。但仍未完成 UI Schema、DocPerm、完整字段清单和运行时导出验证；当前仍只作为 L0+ 方向级模型判断。

## 核心对象

```text
Workspace / Tenant
Application
BusinessObject / Collection / DocType
Field
Relation / Association
View / Page / Screen
Component / Block
DataSource
Query / Action
Workflow
Permission / Role / Policy
Version / Release
Plugin / Extension
```

## 竞品映射

| 元模型对象 | 金蝶 | Appsmith/ToolJet/Lowcoder | NocoBase/NocoDB/Directus | Frappe |
|---|---|---|---|---|
| 业务对象 | 动态领域模型/业务对象 | 弱，通常是外部数据源表或 API | Collection/Table | DocType |
| 字段 | 元数据字段 | Widget 属性或查询字段 | Field/Column | DocField |
| 关系 | 业务对象关系 | 主要由查询处理 | Association/Relation | Link/Child Table |
| 页面 | 布局/表单 | Page/Canvas/Widget | Page/Block/View | Form/List |
| 动作 | 规则/流程/操作 | Query/Event/JS | Action/Workflow | Button/Server Script/Workflow |
| 权限 | 企业基础架构能力 | Role/RBAC | Role/Permission/Policy | Role/Permission |

## 关键判断

低代码平台的数据模型不能只做“组件树 JSON”。组件树只能描述 UI，不能描述业务对象生命周期、权限、流程和数据关系。

源码初证补充：

- NocoBase `CollectionOptions` 已显示业务对象元数据需要覆盖字段、表/视图、继承、Repository、迁移/导出、排序、树形等属性。
- NocoBase `RelationField` 已显示关系字段需要显式建模 target、foreignKey、sourceKey、targetKey 和类型匹配。
- Frappe `DocType` 已显示业务对象应内聚 `fields: Table(DocField)` 与 `permissions: Table(DocPerm)`。
- Frappe `DocField` 已显示字段模型同时覆盖数据类型、必填、选项、默认值、字段带出和依赖条件。
- Directus 官方文档和 ItemsService 源码初证显示字段模型同时服务存储、展示、校验、关系和服务层执行上下文。
- Appsmith 官方文档和 Widget Development Guide 显示其应用构建元模型围绕 Application、Page、Widget、Datasource、Query、JS Object 和 Binding 组织。

## 推荐最小元模型

```text
Tenant
Workspace
App
BusinessObject
Field
Relation
State
Action
Rule
Workflow
Page
View
Component
Role
Permission
DataSource
Connector
Version
Plugin
```
