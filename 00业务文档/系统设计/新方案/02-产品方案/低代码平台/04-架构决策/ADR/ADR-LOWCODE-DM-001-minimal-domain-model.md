# ADR-LOWCODE-DM-001: 最小业务元模型

> 状态：accepted for M0
> 日期：2026-07-05

## 背景

平台定位为业务对象元模型驱动的企业低代码平台。M0 必须先冻结最小元模型边界，否则后续元数据表、MetaGraph、Schema Sync、设计器和运行时权限都会各自发明对象结构。

竞品知识库给出的稳定证据是：Frappe 以 DocType 聚合字段和权限，NocoBase 以 Collection/Field/Relation 表达数据模型。两者都说明“业务对象 + 字段 + 关系 + 版本发布”是低代码平台内核，不是页面构建器的附属物。

## 决策

M0 采用 19 个元模型对象作为平台骨架：

- Tenant
- Workspace
- App
- BusinessObject
- Field
- Relation
- State
- StateTransition
- Action
- Rule
- ObjectPermission
- Workflow
- Page
- View
- Component
- Role
- DataSource
- Connector
- Version
- Plugin

其中 M0 只实现元模型内核必须用到的对象、字段、关系、状态、动作、规则、页面/角色/插件配置承载和版本快照承载；不实现完整运行时权限、页面设计器、插件系统、工作流和 Connector。

## 理由

- BusinessObject 是聚合根，字段、关系、状态、动作、规则围绕业务对象内聚，避免页面配置反向定义业务模型。
- Version 作为运行态快照边界，保证设计态变更不会直接影响已发布应用。
- Page/View/Role/Plugin/DataSource 等对象在 M0 先作为元数据承载，避免后续 M1/M2/M3 再破坏表结构和快照格式。
- 19 对象覆盖 PRD 的 M0-M3 演进路线，但 M0 通过能力阻断清单限制实现范围，避免首版大而全。

## 否决方案

- 只建对象和字段两类元数据：M0 简单，但 M1/M2 增加权限、页面、版本时会重做快照结构和引用索引。
- 完全照搬 Frappe DocType/DocField/DocPerm：证据充分但会引入 Python/Frappe 历史包袱，不适合 Java/Spring/MySQL 技术栈。
- 完全照搬 NocoBase Collection/Field/Plugin：插件生态强，但权限、组织、企业单据语义不足以覆盖本平台目标。
- 首版实现全部 19 对象的完整运行时：范围过大，违反 M0 元模型内核优先原则。

## 后果

- T-002 必须创建 9 张 `lc_meta_*` 表和 JSON DTO，能承载上述 19 对象的 M0 子集。
- T-003 必须实现 BusinessObject/Field/Relation/State/Action/Rule 的草稿 CRUD、引用索引和全图校验。
- M0 必须阻断尚未实现的运行时能力，例如 multilink DDL、插件启用、表达式语义执行。
- M1 前必须终审权限 ADR，M2 前必须终审 UI ADR，M3 前必须终审插件、工作流、Connector 的扩展边界。

## 验证

- T-002：DDL、JSON DTO、枚举、`lc_meta_ref` 和版本快照结构能表达 19 对象的 M0 子集。
- T-003：对象、字段、关系、状态、动作、规则可保存、校验、重建引用索引。
- T-004：实体对象发布可生成动态表，M0 不支持能力生成阻断计划。
- T-005：发布快照可加载为 MetaGraph，并保持设计态/运行态隔离。
- M0 测试规格中的“客户-订单-审批”元数据样例可建模，但不要求完整运行时 CRUD。
