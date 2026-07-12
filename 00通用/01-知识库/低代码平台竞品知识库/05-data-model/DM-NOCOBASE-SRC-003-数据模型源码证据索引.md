---
id: DM-NOCOBASE-SRC-003
type: data-model
domain_object: NocoBaseDataModelSourceIndex
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-011, E-NOCOBASE-SRC-012, E-NOCOBASE-SRC-013, E-NOCOBASE-SRC-014, E-NOCOBASE-SRC-015, E-NOCOBASE-SRC-016, E-NOCOBASE-SRC-017, E-NOCOBASE-SRC-018, E-NOCOBASE-SRC-019, E-NOCOBASE-SRC-020, E-NOCOBASE-SRC-021, E-NOCOBASE-SRC-022, E-NOCOBASE-SRC-023, E-NOCOBASE-SRC-024, E-NOCOBASE-SRC-025, E-NOCOBASE-SRC-026, E-NOCOBASE-SRC-027, E-NOCOBASE-SRC-028, E-NOCOBASE-SRC-029, E-NOCOBASE-SRC-030]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-NOCOBASE-SRC-001, DM-NOCOBASE-SRC-002]
owner: AI
ai_generated: true
---

# NocoBase 数据模型源码证据索引

## 结论

NocoBase 数据模型以 `CollectionOptions`、`Collection`、`Field` 为核心：Collection 负责集合级元数据、字段列表、模型绑定、Repository、排序、树结构、同步和更新；Field 负责字段级类型、列名映射、校验和 Sequelize 属性转换。

## 源码证据范围

```text
E-NOCOBASE-SRC-011..030
collection.ts: CollectionOptions / Collection / setField / sync / repository / tree / sortable
field.ts: BaseFieldOptions / ValidationOptions / Field / name / type / columnName / toSequelize
```

## 对自研平台的启发

自研平台的数据模型应至少拆成：

```text
ObjectMeta
FieldMeta
RepositoryBinding
RelationMeta
ValidationMeta
IndexMeta
TreeMeta
SortMeta
RuntimeModelBinding
```

字段配置不能只服务页面展示，必须能落到运行时模型、校验、查询、索引和迁移。
