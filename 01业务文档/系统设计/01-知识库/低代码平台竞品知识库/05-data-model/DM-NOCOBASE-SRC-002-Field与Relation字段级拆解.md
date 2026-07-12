---
id: DM-NOCOBASE-SRC-002
type: data-model
domain_object: NocoBaseField
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-002, E-NOCOBASE-SRC-003]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-LOWCODE-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# NocoBase Field 与 Relation 字段级拆解

## 源码依据

- 仓库：`nocobase/nocobase`
- 分支与 commit：`main` / `1c41defe6c458771dd3449cb8b4557a49e584737`
- 文件 1：`packages/core/database/src/fields/field.ts`
  - `FieldContext`：L18
  - `BaseFieldOptions`：L48
  - `BaseColumnFieldOptions`：L57
  - `Field` 抽象类：L64
  - `isRelationField()`：L90
  - `sync()`：L94
- 文件 2：`packages/core/database/src/fields/relation-field.ts`
  - `RelationField`：L18
  - `target`：L22
  - `foreignKey`：L27
  - `sourceKey`：L31
  - `targetKey`：L35
  - `TargetModel`：L43
  - `keyPairsTypeMatched()`：L55

## 字段级观察

`Field` 的上下文包含 `database` 与 `collection`，说明字段定义不是孤立配置，而是绑定到数据库与集合运行时。

`BaseFieldOptions` 覆盖字段名、隐藏、翻译、校验等通用属性；`BaseColumnFieldOptions` 增加 `dataType`、`index` 等数据库列属性。

`RelationField` 明确把关系字段拆成：

```text
target
foreignKey
sourceKey
targetKey
TargetModel
targetCollection
keyPairsTypeMatched
```

## 抽象结论

NocoBase 的字段元模型至少分两层：

```text
Field：通用字段、列字段、校验、隐藏、翻译、同步
RelationField：目标对象、外键、源键、目标键、目标模型、类型匹配
```

这说明“字段”不是简单的表单控件属性，而是数据结构、数据库列、关系约束和运行时同步的交汇点。

## 对自研平台的启发

自研平台应区分：

```text
字段的业务层属性：名称、标题、是否隐藏、是否必填、校验、翻译
字段的存储层属性：数据类型、索引、默认值、长度
字段的关系层属性：目标对象、外键、源键、目标键、级联策略
字段的 UI 层属性：控件类型、展示规则、布局位置
```

否则后期会把 UI 字段、数据库字段和关系字段混在一起，导致模型迁移、权限控制和 API 生成都难以维护。

## 边界

本卡未覆盖 NocoBase 所有具体字段类型实现，只覆盖 `Field` 抽象和 `RelationField` 关系字段内核。
