# 02 表格类生产级组件类别 SOP

> 组件数：34
>
> 关注域：数据身份、版本、选择、编辑与汇总口径
>
> 风险初始分布：R1 0 / R2 34 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：数据身份、版本、选择、编辑与汇总口径。
- 类别状态模型：查询条件、加载窗口、行主键、选择集、编辑草稿、版本、排序与汇总。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 加载失败、空结果或分页游标失效
- 排序过滤后选择集错位或行身份漂移
- 并发版本冲突、部分提交或批量操作重复执行

## 3. 强制验证

- 以稳定业务主键验证排序、过滤、分页和虚拟窗口后的行身份
- 验证批量选择、部分成功、重复提交和版本冲突
- 验证网格键盘导航、编辑模式、焦点保持和屏幕阅读语义

## 4. 性能与规模基线

普通表格以 1,000 行基准，虚拟/无限/服务端表格以 100,000 行逻辑数据和当前可视窗口基准；滚动、选择和编辑反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若提交金额、库存、订单、权限或不可逆批量操作，升级为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [数据表格](../02-组件SOP/02-表格类/02-data-grid.md) | `02:data-grid` | B | R2 | Draft / 未认证 |
| [可编辑表格](../02-组件SOP/02-表格类/02-editable-grid.md) | `02:editable-grid` | B | R2 | Draft / 未认证 |
| [批量编辑表格](../02-组件SOP/02-表格类/02-batch-edit-grid.md) | `02:batch-edit-grid` | B | R2 | Draft / 未认证 |
| [树形表格](../02-组件SOP/02-表格类/02-tree-grid.md) | `02:tree-grid` | B | R2 | Draft / 未认证 |
| [主从表格](../02-组件SOP/02-表格类/02-master-detail-grid.md) | `02:master-detail-grid` | B | R2 | Draft / 未认证 |
| [分组表格](../02-组件SOP/02-表格类/02-grouped-grid.md) | `02:grouped-grid` | B | R2 | Draft / 未认证 |
| [透视表](../02-组件SOP/02-表格类/02-pivot-grid.md) | `02:pivot-grid` | B | R2 | Draft / 未认证 |
| [交叉表](../02-组件SOP/02-表格类/02-cross-tab.md) | `02:cross-tab` | B | R2 | Draft / 未认证 |
| [多维分析表](../02-组件SOP/02-表格类/02-olap-grid.md) | `02:olap-grid` | B | R2 | Draft / 未认证 |
| [虚拟滚动表格](../02-组件SOP/02-表格类/02-virtual-grid.md) | `02:virtual-grid` | B | R2 | Draft / 未认证 |
| [无限加载表格](../02-组件SOP/02-表格类/02-infinite-grid.md) | `02:infinite-grid` | B | R2 | Draft / 未认证 |
| [服务端分页表格](../02-组件SOP/02-表格类/02-server-grid.md) | `02:server-grid` | B | R2 | Draft / 未认证 |
| [固定表头与列](../02-组件SOP/02-表格类/02-fixed-grid.md) | `02:fixed-grid` | B | R2 | Draft / 未认证 |
| [多级表头表格](../02-组件SOP/02-表格类/02-multi-header-grid.md) | `02:multi-header-grid` | B | R2 | Draft / 未认证 |
| [列分组表格](../02-组件SOP/02-表格类/02-column-group-grid.md) | `02:column-group-grid` | B | R2 | Draft / 未认证 |
| [列显示管理器](../02-组件SOP/02-表格类/02-column-manager.md) | `02:column-manager` | B | R2 | Draft / 未认证 |
| [列宽调整表格](../02-组件SOP/02-表格类/02-resizable-grid.md) | `02:resizable-grid` | B | R2 | Draft / 未认证 |
| [列拖拽排序表格](../02-组件SOP/02-表格类/02-reorderable-grid.md) | `02:reorderable-grid` | B | R2 | Draft / 未认证 |
| [行拖拽排序表格](../02-组件SOP/02-表格类/02-row-sort-grid.md) | `02:row-sort-grid` | B | R2 | Draft / 未认证 |
| [可展开行表格](../02-组件SOP/02-表格类/02-expandable-grid.md) | `02:expandable-grid` | B | R2 | Draft / 未认证 |
| [行内详情表格](../02-组件SOP/02-表格类/02-inline-detail-grid.md) | `02:inline-detail-grid` | B | R2 | Draft / 未认证 |
| [行选择表格](../02-组件SOP/02-表格类/02-selection-grid.md) | `02:selection-grid` | B | R2 | Draft / 未认证 |
| [单元格选择表格](../02-组件SOP/02-表格类/02-cell-selection-grid.md) | `02:cell-selection-grid` | B | R2 | Draft / 未认证 |
| [区域复制粘贴表格](../02-组件SOP/02-表格类/02-clipboard-grid.md) | `02:clipboard-grid` | B | R2 | Draft / 未认证 |
| [表头筛选表格](../02-组件SOP/02-表格类/02-filter-grid.md) | `02:filter-grid` | B | R2 | Draft / 未认证 |
| [多列排序表格](../02-组件SOP/02-表格类/02-sort-grid.md) | `02:sort-grid` | B | R2 | Draft / 未认证 |
| [汇总与小计表格](../02-组件SOP/02-表格类/02-summary-grid.md) | `02:summary-grid` | B | R2 | Draft / 未认证 |
| [冻结窗格表格](../02-组件SOP/02-表格类/02-frozen-grid.md) | `02:frozen-grid` | B | R2 | Draft / 未认证 |
| [电子表格式表格](../02-组件SOP/02-表格类/02-spreadsheet-grid.md) | `02:spreadsheet-grid` | B | R2 | Draft / 未认证 |
| [属性表格](../02-组件SOP/02-表格类/02-property-grid.md) | `02:property-grid` | B | R2 | Draft / 未认证 |
| [键值表格](../02-组件SOP/02-表格类/02-key-value-grid.md) | `02:key-value-grid` | B | R2 | Draft / 未认证 |
| [对比表格](../02-组件SOP/02-表格类/02-comparison-grid.md) | `02:comparison-grid` | B | R2 | Draft / 未认证 |
| [矩阵表格](../02-组件SOP/02-表格类/02-matrix-grid.md) | `02:matrix-grid` | B | R2 | Draft / 未认证 |
| [数据差异表格](../02-组件SOP/02-表格类/02-diff-grid.md) | `02:diff-grid` | B | R2 | Draft / 未认证 |
