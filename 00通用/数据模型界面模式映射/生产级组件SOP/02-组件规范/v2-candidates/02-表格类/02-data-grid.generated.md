<!-- GENERATED FILE: 请勿手工编辑 -->

# Data Grid v2 候选规范

- 源：`02-data-grid.spec.json`
- 版本：`0.3.0`
- Digest：`sha256:12f5c61fdd777648af75b60ef8dc9f926976952725000fc7ae0ce55df1c358ea`
- 状态：`Draft`，`implementationAllowed=false`

## 范围

以稳定行身份展示和操作二维业务数据，并在排序、筛选、选择和异步刷新时保持状态一致。

包含：二维数据展示、本地与远程分页、排序与筛选、行选择、固定表头与列、列宽调整、加载、空、刷新和错误恢复

不包含：单元格编辑事务、批量编辑、区域复制粘贴、虚拟滚动、无限加载、树形层级、公式计算、透视与 OLAP、服务端查询实现

## API

| Pointer | 类型/事件 | 契约 |
|---|---|---|
| `/api/props/ariaLabel` | `string` | 为无可见标题的 grid 提供可访问名称。 |
| `/api/props/columns` | `readonly DataGridColumn<TRow, unknown>[]` | 每列必须有稳定 id；不得暴露 TanStack ColumnDef。 |
| `/api/props/data` | `DataGridDataSource<TRow>` | local 提供 rows；remote-page 提供 rows、rowCount、resultQueryId、loading、error 和查询回调。 |
| `/api/props/getRowId` | `(row: TRow) => string` | 必须返回当前数据集内唯一且跨排序、筛选、分页和刷新稳定的业务行 ID。 |
| `/api/events/filteringChange` | `filtering.onChange` | `readonly DataGridFilterRule[]` |
| `/api/events/paginationChange` | `pagination.onChange` | `DataGridPage` |
| `/api/events/queryChange` | `data.onQueryChange` | `DataGridQueryRequest` |
| `/api/events/retry` | `data.onRetry` | `DataGridQueryRequest` |
| `/api/events/rowSelectionChange` | `rowSelection.onChange` | `ReadonlySet<RowId>` |
| `/api/events/sortingChange` | `sorting.onChange` | `readonly DataGridSortRule[]` |

## 状态机

状态：idle、loadingInitial、ready、empty、refreshing、errorInitial、errorRefresh

| 转换 | From | To |
|---|---|---|
| query | ready / empty | refreshing |
| resolve-data | loadingInitial / refreshing | ready |
| resolve-empty | loadingInitial / refreshing | empty |
| ignore-stale | refreshing | refreshing |
| reject-initial | loadingInitial | errorInitial |
| reject-refresh | refreshing | errorRefresh |
| retry | errorInitial / errorRefresh | loadingInitial / refreshing |

## 界面结构

| 区域 | 用途 |
|---|---|
| `/view/regions/body` | 显示行、单元格、空态、初始加载或不可操作契约错误。 |
| `/view/regions/header` | 显示列标题、排序状态、筛选入口和调整列宽手柄。 |
| `/view/regions/pagination` | 显示页码、总量、每页数量和上一页/下一页命令。 |
| `/view/regions/status` | 显示刷新、错误和 polite live region；不遮挡已有数据。 |
| `/view/regions/toolbar` | 承载筛选摘要、已选数量和可选的表格级命令。 |

## 状态视图

| 状态 | 区域 | 呈现 |
|---|---|---|
| `empty` | header、body、status、pagination | 保留表头和查询上下文，body 显示空结果，不伪装错误。 |
| `errorInitial` | body、status | 没有成功数据时显示表格级错误摘要和重试命令。 |
| `errorRefresh` | header、body、status、pagination | 旧数据、选择和查询保留，status 标明数据可能过期并提供重试。 |
| `loadingInitial` | header、body、status | 保留列结构，body 显示不引发布局跳动的骨架行，status 播报加载中。 |
| `ready` | toolbar、header、body、status、pagination | 数据与全部已启用控制可操作；status 仅承载非干扰播报。 |
| `refreshing` | header、body、status、pagination | 旧数据保持可读，状态区显示非模态进度；不清空选择。 |

## 无障碍

ARIA Grid with roving tabindex；异步结果后优先恢复到仍存在的稳定 rowId/columnId；不存在时移动到最近可用单元格。

## 质量预算

| Pointer | Operator | Value | Unit | Fixture |
|---|---|---:|---|---|
| `/quality/performanceBudgets/interaction` | <= | 100 | ms-p95 | local-and-remote-page |
| `/quality/performanceBudgets/longTask` | <= | 50 | ms | continuous-keyboard-and-resize |
| `/quality/performanceBudgets/runtimeBundle` | <= | 35 | gzip-kb | data-grid-subpath-excluding-react-peers |

## 行为 Oracle

### `/quality/oracles/duplicateRowIdBlocksInteraction`

Given 两行由 getRowId 返回相同值

When 渲染表格

Then 选择和行操作被阻断，错误不展示敏感行对象。
### `/quality/oracles/filterPreservesSelection`

Given 已选择当前将被隐藏的业务行

When 应用筛选

Then 隐藏不删除选择，已选总数与可见已选数分开表达。
### `/quality/oracles/refreshFailureRetainsContext`

Given 已有成功数据、查询、选择和活动单元格

When 刷新失败

Then 上下文保留并出现可键盘到达的重试；重试使用同一 DataGridQuery 和新 queryId。
### `/quality/oracles/remoteQueryIsNotAppliedLocally`

Given remote-page 数据源

When 改变排序、筛选或分页

Then 只产生一次查询意图且不执行客户端二次变换。
### `/quality/oracles/selectionStableAfterSort`

Given 3 个唯一 rowId 且 LOT-02 已选中

When 对数据降序排序

Then LOT-02 仍选中且 rowSelection.onChange 不因排序额外触发。
### `/quality/oracles/sortProducesSingleIntent`

Given remote-page 数据源

When 改变排序

Then 产生一次携带新 queryId 的查询意图且不执行客户端重排。
### `/quality/oracles/staleResultDoesNotOverwrite`

Given 查询 A 后发出查询 B

When A 的 resultQueryId 在 B 之后返回

Then A 不覆盖数据、选择或焦点，只有 B 的匹配结果应用一次。

## 视觉 Oracle

### `/quality/visualOracles/fixedColumnBoundary`

Given 左固定列和横向滚动列同时存在

When 滚动到中部和末端

Then 固定区边界清晰且不产生双边框、透明穿透或内容重叠。
### `/quality/visualOracles/focusVisibility`

Given 默认、暗色、紧凑和减少动态效果主题

When 键盘遍历表头、单元格、重试和分页

Then 任何活动控件均有连续可见的 2px 焦点环且不被 sticky 区域裁切。
### `/quality/visualOracles/headerBodyAlignment`

Given 固定列和可调整列宽均启用

When 调整列宽并横向滚动

Then 表头与对应单元格边界保持在同一像素列，行高不跳变。
### `/quality/visualOracles/noClipping`

Given 最长标题、无空格长值和 200% 缩放

When 遍历断点及相邻宽度

Then 文本按列策略截断或换行，焦点环、命令和状态区不被裁切。
### `/quality/visualOracles/scrollReachability`

Given 390px 视口且列总宽超过视口

When 分别使用键盘、鼠标和触控导航到末列

Then 末列及其操作完整可见，滚动条和固定列不遮挡内容。
### `/quality/visualOracles/stateRetention`

Given 已有成功数据、选择和活动单元格

When 刷新失败

Then 旧数据、选择和活动上下文保持，错误状态不遮挡数据。

## 风险与审批

风险：`R2`；所需角色：`component-maintainer`、`ux-a11y-reviewer`、`test-reviewer`；当前审批：`pending`。
