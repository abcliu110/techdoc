# 05 查询与筛选类生产级组件类别 SOP

> 组件数：20
>
> 关注域：条件语义、逻辑组合、数据范围与结果可解释性
>
> 风险初始分布：R1 15 / R2 5 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：条件语义、逻辑组合、数据范围与结果可解释性。
- 类别状态模型：条件树、操作符、值、逻辑组、保存版本、执行状态与结果摘要。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 无效操作符、空条件或类型不匹配
- 条件组合扩大数据范围或保存视图版本冲突
- 超时、结果为空或查询解释与实际执行不一致

## 3. 强制验证

- 验证条件树序列化、反序列化和逻辑优先级不变
- 验证空值、范围、时区、非法操作符和服务端拒绝
- 验证键盘重排、错误定位、保存版本和清除/撤销

## 4. 性能与规模基线

以 100 个条件、10 层嵌套和 100 个候选字段为设计基准；条件编辑反馈 p95 不高于 100ms，执行必须可取消。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若查询可绕过权限范围、执行原生 DSL/SQL、保存共享策略或导出敏感数据，升级为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [高级查询构建器](../02-组件SOP/05-查询与筛选类/05-advanced-query-builder.md) | `05:advanced-query-builder` | B | R1 | Draft / 未认证 |
| [条件组编辑器](../02-组件SOP/05-查询与筛选类/05-condition-group.md) | `05:condition-group` | B | R1 | Draft / 未认证 |
| [嵌套逻辑查询](../02-组件SOP/05-查询与筛选类/05-nested-logic-query.md) | `05:nested-logic-query` | B | R1 | Draft / 未认证 |
| [综合筛选面板](../02-组件SOP/05-查询与筛选类/05-filter-panel.md) | `05:filter-panel` | B | R1 | Draft / 未认证 |
| [快捷筛选条](../02-组件SOP/05-查询与筛选类/05-quick-filter-bar.md) | `05:quick-filter-bar` | B | R1 | Draft / 未认证 |
| [分面筛选器](../02-组件SOP/05-查询与筛选类/05-faceted-filter.md) | `05:faceted-filter` | B | R1 | Draft / 未认证 |
| [保存查询](../02-组件SOP/05-查询与筛选类/05-saved-query.md) | `05:saved-query` | B | R2 | Draft / 未认证 |
| [保存视图](../02-组件SOP/05-查询与筛选类/05-saved-view.md) | `05:saved-view` | B | R2 | Draft / 未认证 |
| [查询模板](../02-组件SOP/05-查询与筛选类/05-query-template.md) | `05:query-template` | B | R2 | Draft / 未认证 |
| [动态查询表单](../02-组件SOP/05-查询与筛选类/05-dynamic-query-form.md) | `05:dynamic-query-form` | B | R1 | Draft / 未认证 |
| [查询 DSL 编辑器](../02-组件SOP/05-查询与筛选类/05-query-dsl.md) | `05:query-dsl` | B | R2 | Draft / 未认证 |
| [全文搜索](../02-组件SOP/05-查询与筛选类/05-full-text-search.md) | `05:full-text-search` | B | R1 | Draft / 未认证 |
| [语义搜索](../02-组件SOP/05-查询与筛选类/05-semantic-search.md) | `05:semantic-search` | B | R1 | Draft / 未认证 |
| [自然语言查询](../02-组件SOP/05-查询与筛选类/05-natural-language-query.md) | `05:natural-language-query` | B | R1 | Draft / 未认证 |
| [日期范围筛选](../02-组件SOP/05-查询与筛选类/05-date-range-filter.md) | `05:date-range-filter` | B | R1 | Draft / 未认证 |
| [数值范围筛选](../02-组件SOP/05-查询与筛选类/05-numeric-range-filter.md) | `05:numeric-range-filter` | B | R1 | Draft / 未认证 |
| [标签筛选](../02-组件SOP/05-查询与筛选类/05-tag-filter.md) | `05:tag-filter` | B | R1 | Draft / 未认证 |
| [跨字段查询](../02-组件SOP/05-查询与筛选类/05-cross-field-query.md) | `05:cross-field-query` | B | R1 | Draft / 未认证 |
| [聚合条件查询](../02-组件SOP/05-查询与筛选类/05-aggregate-condition.md) | `05:aggregate-condition` | B | R1 | Draft / 未认证 |
| [查询历史](../02-组件SOP/05-查询与筛选类/05-query-history.md) | `05:query-history` | B | R2 | Draft / 未认证 |
