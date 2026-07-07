---
id: DM-FRAPPE-SRC-001
type: data-model
domain_object: FrappeDocType
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-001]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-LOWCODE-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# Frappe DocType 字段级拆解

## 源码依据

- 仓库：`frappe/frappe`
- 分支与 commit：`develop` / `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`
- 文件：`frappe/core/doctype/doctype/doctype.json`
- 可复核行号：
  - `is_submittable`：L128
  - `istable`：L135
  - `fields`：L211
  - `fields.options = DocField`：L216
  - `permissions`：L388
  - `permissions.options = DocPerm`：L393

## 字段级观察

Frappe 的 DocType 元模型将字段与权限都建模为子表：

```text
DocType
  -> fields: Table(DocField)
  -> permissions: Table(DocPerm)
```

同时，DocType 还显式包含 `is_submittable`、`istable` 这类控制业务行为和表结构语义的字段。

## 抽象结论

Frappe 的 DocType 不是单纯数据库表定义，而是业务对象元数据中心：

```text
字段定义
权限定义
是否可提交
是否子表
表单/列表等运行时行为的基础
```

`DocType -> DocField / DocPerm` 的结构给自研平台一个重要启发：字段、权限不是外围配置，而应作为业务对象的一部分进入元模型。

## 对自研平台的启发

`BusinessObject` 建议内聚以下子模型：

```text
FieldDefinition[]
PermissionDefinition[]
LifecycleFlag
StorageFlag
UIProjection
WorkflowBinding
```

这比“对象表 + 单独权限表 + 单独表单配置”更适合做一致性校验和版本化迁移。

## 边界

本卡只基于 DocType JSON 源码，不覆盖 Frappe 完整运行时表单渲染、迁移和数据库建表过程。
