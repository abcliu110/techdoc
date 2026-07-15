# 06 选择器类生产级组件类别 SOP

> 组件数：25
>
> 关注域：候选身份、选择约束、远程加载与结果回填
>
> 风险初始分布：R1 16 / R2 9 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：候选身份、选择约束、远程加载与结果回填。
- 类别状态模型：查询、候选集、选中集、顺序、加载游标、已失效项与确认状态。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 远程加载失败、结果过期或已选项失效
- 多选上限、级联约束或互斥规则冲突
- 关闭弹层后焦点、查询或临时选择丢失

## 3. 强制验证

- 验证稳定候选 ID，不以显示文本作为业务身份
- 验证请求乱序、失效项、分页去重、上限和取消
- 验证组合框/列表框/树选择器语义、键盘选择与焦点返回

## 4. 性能与规模基线

以 10,000 个远程候选、200 个已选项为逻辑基准；输入反馈 p95 不高于 100ms，搜索请求必须防抖、可取消并防乱序。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若选择结果直接授予角色、资源权限、主数据关系或不可逆业务对象，至少 R2；跨租户或权限授予为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [远程搜索选择器](../02-组件SOP/06-选择器类/06-remote-selector.md) | `06:remote-selector` | B | R1 | Draft / 未认证 |
| [异步懒加载选择器](../02-组件SOP/06-选择器类/06-async-selector.md) | `06:async-selector` | B | R1 | Draft / 未认证 |
| [多选标签选择器](../02-组件SOP/06-选择器类/06-multi-select.md) | `06:multi-select` | B | R1 | Draft / 未认证 |
| [树形选择器](../02-组件SOP/06-选择器类/06-tree-selector.md) | `06:tree-selector` | B | R1 | Draft / 未认证 |
| [级联选择器](../02-组件SOP/06-选择器类/06-cascader.md) | `06:cascader` | B | R1 | Draft / 未认证 |
| [表格选择器](../02-组件SOP/06-选择器类/06-table-selector.md) | `06:table-selector` | B | R1 | Draft / 未认证 |
| [弹窗对象选择器](../02-组件SOP/06-选择器类/06-dialog-selector.md) | `06:dialog-selector` | B | R1 | Draft / 未认证 |
| [穿梭选择器](../02-组件SOP/06-选择器类/06-transfer-selector.md) | `06:transfer-selector` | B | R1 | Draft / 未认证 |
| [可排序双列选择器](../02-组件SOP/06-选择器类/06-ordered-transfer.md) | `06:ordered-transfer` | B | R1 | Draft / 未认证 |
| [人员选择器](../02-组件SOP/06-选择器类/06-person-selector.md) | `06:person-selector` | B | R2 | Draft / 未认证 |
| [组织选择器](../02-组件SOP/06-选择器类/06-organization-selector.md) | `06:organization-selector` | B | R2 | Draft / 未认证 |
| [部门选择器](../02-组件SOP/06-选择器类/06-department-selector.md) | `06:department-selector` | B | R2 | Draft / 未认证 |
| [角色选择器](../02-组件SOP/06-选择器类/06-role-selector.md) | `06:role-selector` | B | R2 | Draft / 未认证 |
| [资源选择器](../02-组件SOP/06-选择器类/06-resource-selector.md) | `06:resource-selector` | B | R2 | Draft / 未认证 |
| [关联记录选择器](../02-组件SOP/06-选择器类/06-relation-selector.md) | `06:relation-selector` | B | R2 | Draft / 未认证 |
| [主数据选择器](../02-组件SOP/06-选择器类/06-master-data-selector.md) | `06:master-data-selector` | B | R2 | Draft / 未认证 |
| [地址级联选择器](../02-组件SOP/06-选择器类/06-address-selector.md) | `06:address-selector` | B | R1 | Draft / 未认证 |
| [地图位置选择器](../02-组件SOP/06-选择器类/06-map-selector.md) | `06:map-selector` | B | R1 | Draft / 未认证 |
| [日期选择器](../02-组件SOP/06-选择器类/06-date-selector.md) | `06:date-selector` | B | R1 | Draft / 未认证 |
| [日期范围选择器](../02-组件SOP/06-选择器类/06-date-range-selector.md) | `06:date-range-selector` | B | R1 | Draft / 未认证 |
| [时段选择器](../02-组件SOP/06-选择器类/06-time-slot-selector.md) | `06:time-slot-selector` | B | R1 | Draft / 未认证 |
| [颜色选择器](../02-组件SOP/06-选择器类/06-color-selector.md) | `06:color-selector` | B | R1 | Draft / 未认证 |
| [图标选择器](../02-组件SOP/06-选择器类/06-icon-selector.md) | `06:icon-selector` | B | R1 | Draft / 未认证 |
| [文件选择器](../02-组件SOP/06-选择器类/06-file-selector.md) | `06:file-selector` | B | R2 | Draft / 未认证 |
| [复合对象选择器](../02-组件SOP/06-选择器类/06-composite-selector.md) | `06:composite-selector` | B | R2 | Draft / 未认证 |
