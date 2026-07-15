<!-- GENERATED FILE: 请勿手工编辑 -->

# Data Grid v2 候选规范

- 源：`02-data-grid.spec.json`
- 版本：`0.3.1`
- Digest：`sha256:60f3d24e656ea072affeb82c12a8a1824b545219a4749a81984bb03a3c5235da`
- 状态：`Draft`，`implementationAllowed=false`

## 范围

以稳定行身份展示和操作二维业务数据，并在排序、筛选、选择和异步刷新时保持状态一致。

包含：二维数据展示、本地与远程分页、排序与筛选、行选择、固定表头与列、列宽调整、加载、空、刷新和错误恢复

不包含：单元格编辑事务、批量编辑、区域复制粘贴、虚拟滚动、无限加载、树形层级、公式计算、透视与 OLAP、服务端查询实现

## API

| Pointer | 类型/事件 | 契约 |
|---|---|---|
| `/api/props/ariaLabel` | `string` | 为无可见标题的 grid 提供可访问名称。 |
| `/api/props/columns` | `readonly DataGridColumn<TRow>[]` | 每列必须有稳定 id；消费方通过 defineDataGridColumn<TRow>() 返回的泛型构造器分别推断 TValue，再擦除为 DataGridColumn<TRow> 进入异构只读数组；擦除只发生在包边界且不得要求消费方使用 any、双重断言或 TanStack ColumnDef。 |
| `/api/props/data` | `DataGridDataSource<TRow>` | local 提供 rows。remote-page 使用判别联合：loading=true 时 error 必须缺省；loading=false 时为成功或携带 DataGridError 的失败。首次消费方自有结果允许省略 resultQueryId；组件发出查询后，rows、rowCount 和 error 只有在 resultQueryId 匹配当前 queryId 时才可改变已接受快照或状态，缺失或迟到 ID 一律忽略。 |
| `/api/props/getRowId` | `(row: TRow) => string` | 必须返回当前数据集内唯一且跨排序、筛选、分页和刷新稳定的业务行 ID。 |
| `/api/props/localeText` | `Partial<DataGridLocaleText>` | 覆盖加载、空、错误、重试、选择计数、分页、排序、筛选、列宽和无障碍标签；动态文案使用类型化格式化函数，缺省键回退到内置简体中文。 |
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

ARIA Grid with roving tabindex；导航模式只有一个表头或正文单元格进入 tab 序列；Enter/F2 进入当前单元格或表头的交互后代，Escape 返回所属单元格，交互模式内 Tab 在后代间移动并从末项离开 Grid。嵌套按钮、复选框、筛选器和 separator 的键盘事件不得冒泡触发行选择或激活。异步结果后优先恢复仍存在的稳定 rowId/columnId；不存在时移动到最近可用单元格。

## 质量预算

| Pointer | Operator | Value | Unit | Fixture |
|---|---|---:|---|---|
| `/quality/performanceBudgets/interaction` | <= | 100 | ms-p95 | local-and-remote-page |
| `/quality/performanceBudgets/longTask` | <= | 50 | ms | continuous-keyboard-and-resize |
| `/quality/performanceBudgets/runtimeBundle` | <= | 35 | gzip-kb | data-grid-subpath-excluding-react-peers |

## 行为 Oracle

### `/quality/oracles/controlledCapabilitiesDoNotSpeculate`

Given 六类能力分别以受控和非受控模式挂载

When 执行会改变切片的用户命令、重复无变化命令和运行期模式切换

Then 受控切片只发一次新不可变 payload 且等待 prop 更新后渲染；非受控切片持久化一次；无变化不发事件；模式切换被诊断且不改变初始模式。
### `/quality/oracles/duplicateRowIdBlocksInteraction`

Given 两行由 getRowId 返回相同值

When 渲染表格

Then 选择和行操作被阻断，错误不展示敏感行对象。
### `/quality/oracles/filterPreservesSelection`

Given 已选择当前将被隐藏的业务行

When 应用筛选

Then 隐藏不删除选择，已选总数与可见已选数分开表达。
### `/quality/oracles/keyboardResizeIsEquivalent`

Given 列宽调整已启用且当前列允许 80 至 640px

When 在 separator 上使用方向键、Home 和 End

Then aria-valuemin/max/now 正确，每次命令只更新一次并与指针路径使用同一状态合同。
### `/quality/oracles/localeTextCoversStructuralLabels`

Given 消费方覆盖全部 localeText 静态键与动态计数格式化函数

When 遍历加载、空、错误、选择、分页、排序、筛选、列宽和重试状态

Then 所有可见文案和无障碍标签使用覆盖值，错误数据结构不承载本地化展示文本。
### `/quality/oracles/nestedControlsHaveSingleEffect`

Given 可排序筛选表头、选择单元格和行激活均启用

When 使用 Enter/F2 进入后代、操作后按 Escape 返回导航模式

Then 每个按键只触发所属控件一次，嵌套事件不触发行选择或行激活，导航模式始终只有一个 tab stop。
### `/quality/oracles/pagedGridExposesAbsolutePosition`

Given remote-page 第 3 页、pageSize=100、rowCount=100000 且包含选择列

When 渲染表头、当前页首行并进入 refreshing

Then 表头和单元格具有一致绝对 row/column index，逻辑 counts、busy、sort 和 multiselectable 与状态一致。
### `/quality/oracles/refreshErrorPreservesFocus`

Given 活动正文单元格仍存在且后台刷新失败

When 进入 errorRefresh 并出现重试命令

Then 焦点仍在原活动单元格或查询触发控件，失败只播报一次，重试可由正常导航到达。
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
### `/quality/oracles/sortFilterResetPageAtomically`

Given remote-page 当前 pageIndex 大于 0

When 排序或筛选发生实际变化

Then 能力回调看到同一完整下一状态且 pageIndex=0，只产生一次对应 queryId 的完整 query intent，不出现中间页查询。
### `/quality/oracles/sortProducesSingleIntent`

Given remote-page 数据源

When 改变排序

Then 产生一次携带新 queryId 的查询意图且不执行客户端重排。
### `/quality/oracles/staleResultDoesNotOverwrite`

Given 查询 A 后发出查询 B

When A 的 resultQueryId 在 B 之后返回

Then A 不覆盖数据、选择或焦点，只有 B 的匹配结果应用一次。
### `/quality/oracles/visiblePageBulkSelection`

Given remote-page 当前页部分行已选且其他页存在已选 ID

When 激活表头当前页选择复选框

Then 只切换当前可见页 ID，mixed/checked 只按可见页计算，同时总选择数与可见选择数分开表达。

## 视觉 Oracle

### `/quality/visualOracles/fixedColumnBoundary`

Given 左固定列和横向滚动列同时存在

When 滚动到中部和末端

Then 固定区边界清晰且不产生双边框、透明穿透或内容重叠。
### `/quality/visualOracles/focusVisibility`

Given 默认、暗色、紧凑和减少动态效果主题

When 键盘遍历表头、单元格、重试和分页

Then 任何活动控件均有连续可见的 2px 焦点环且不被 sticky 区域裁切。
### `/quality/visualOracles/forcedColorsVisibility`

Given forced-colors 模式且存在选择、错误、固定列、排序筛选状态和列宽手柄

When 键盘遍历并滚动到固定区边界

Then 焦点、选择、错误、固定边界和手柄均使用系统颜色可辨，不依赖背景色或阴影单独表达。
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
