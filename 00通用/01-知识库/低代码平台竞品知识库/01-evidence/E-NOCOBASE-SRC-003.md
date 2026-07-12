---
id: E-NOCOBASE-SRC-003
type: evidence
competitor: NocoBase
module: data-model
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/database/src/fields/relation-field.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase RelationField 源码

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/database/src/fields/relation-field.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：raw 文件可复核；`RelationField` 在 L18，`target` 在 L22，`foreignKey` 在 L27，`sourceKey` 在 L31，`targetKey` 在 L35，`TargetModel` 在 L43，`keyPairsTypeMatched()` 在 L55。

## 原始观察

`RelationField` 继承 `Field`，其关键运行时属性包括：

- `target`：目标 relation 名称，默认使用字段名。
- `foreignKey`：外键。
- `sourceKey`：来源键，默认使用当前 collection 的 `filterTargetKey`。
- `targetKey`：目标键，默认使用目标模型主键。
- `TargetModel`：通过 database/sequelize models 获取目标模型。
- `targetCollection()`：获取目标 Collection。
- `isRelationField()`：返回 true。
- `keyPairsTypeMatched()`：检查关联键类型是否匹配，数值类型组、字符串类型组内部可匹配。

## 证据强度

直接事实。源码明确给出关系字段的目标、外键、源键、目标键和类型匹配规则。
