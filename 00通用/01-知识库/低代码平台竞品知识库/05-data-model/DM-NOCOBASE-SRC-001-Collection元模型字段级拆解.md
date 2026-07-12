---
id: DM-NOCOBASE-SRC-001
type: data-model
domain_object: NocoBaseCollection
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-001]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-LOWCODE-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# NocoBase Collection 元模型字段级拆解

## 源码依据

- 仓库：`nocobase/nocobase`
- 分支与 commit：`main` / `1c41defe6c458771dd3449cb8b4557a49e584737`
- 文件：`packages/core/database/src/collection.ts`
- 可复核行号：`CollectionOptions` 从 L104 开始，`fields` 在 L117，`Collection` 类从 L154 开始，`setFields()` 在 L598，`sync()` 在 L941。

## 字段级观察

NocoBase 将业务集合抽象为 `CollectionOptions`，核心字段覆盖：

```text
name
title
namespace
dataCategory
tableName / viewName / writableView
inherits
fields
fieldSort
model
repository
sortable
autoGenId
magicAttribute
tree
template
simplePaginate
origin
asStrategyResource
migrationRules
dumpRules
```

## 抽象结论

NocoBase 的 Collection 不只是数据库表名包装，而是同时承担：

```text
业务对象标识
物理存储映射
字段集合
运行时模型绑定
Repository 绑定
迁移/导出规则
树形、排序、继承等业务结构能力
```

## 对自研平台的启发

自研低代码平台的 `BusinessObject` 不能只包含 `name`、`tableName` 和字段列表。至少应预留：

```text
对象分类
存储映射
字段定义
关系定义
Repository / Service 绑定
迁移与导出策略
扩展属性
运行时同步能力
```

## 边界

本卡只证明 NocoBase 源码中 Collection 元模型字段存在，不证明这些字段在 UI 中全部开放，也不证明运行时行为已经实测。
