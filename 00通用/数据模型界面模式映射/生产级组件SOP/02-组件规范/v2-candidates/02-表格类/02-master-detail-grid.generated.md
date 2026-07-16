<!-- GENERATED FILE: 请勿手工编辑 -->

# Master Detail Grid v2 候选规范

- 源：`02-master-detail-grid.spec.json`
- 版本：`0.2.0`
- Digest：`sha256:c3ef6690cf067d49a724588e06b0e0ea7c2787ceea459c50e8a544e9aaf74b15`
- 状态：`ReviewReady`，`implementationAllowed=false`

## 范围

以两个独立命名的 DataGrid 呈现单一活动主记录及其明细，并在主记录切换、明细查询、失败恢复和双区域导航时保持归属、选择与焦点隔离。

包含：两个独立 DataGrid、单一活动主记录、主选择与主激活分离、异步明细查询、主记录命名空间隔离、刷新失败保留明细、可调分隔器、宽屏分栏与窄屏堆叠、F6 区域导航

不包含：行内展开详情、多主明细同时展示、树形层级、明细编辑事务、跨主批量操作、未保存离开阻断、离线缓存、透视与电子表格内核

## API

| Pointer | 类型/事件 | 契约 |
|---|---|---|
| `/api/props/activeMaster` | `MasterDetailGridActiveMaster` | 使用 value/defaultValue 互斥合同；活动主记录是导航上下文而非行选择。 |
| `/api/props/ariaLabel` | `string` | 为主从组合 region 提供可访问名称。 |
| `/api/props/detail` | `MasterDetailGridDetail<TMaster, TDetail>` | 提供明细标题、列、getRowId、查询能力和 load；每个结果必须携带 masterId/queryId，明细完整身份为 masterId 与 detailRowId 的组合。 |
| `/api/props/layout` | `MasterDetailGridLayout` | 支持 horizontal、vertical、responsive 与受控/非受控 masterSize；分隔器指针和键盘共享状态合同。 |
| `/api/props/localeText` | `Partial<MasterDetailGridLocaleText>` | 覆盖无主记录、加载、空、错误、重试、主上下文失效和分隔器标签。 |
| `/api/props/master` | `MasterDetailGridMaster<TMaster>` | 完整复用 DataGridProps<TMaster> 并可提供主区标题；getRowId 是主记录唯一身份源。 |
| `/api/events/activeMasterChange` | `activeMaster.onChange` | `MasterDetailGridActiveMasterChange` |
| `/api/events/activeMasterInvalid` | `activeMaster.onInvalid` | `MasterDetailGridInvalidMaster` |
| `/api/events/detailRequest` | `detail.load` | `MasterDetailGridDetailRequest<TMaster>` |
| `/api/events/layoutChange` | `layout.onChange` | `MasterDetailGridLayoutChange` |

## 状态机

状态：idle、noMaster、detailLoadingInitial、detailReady、detailEmpty、detailRefreshing、detailErrorInitial、detailErrorRefresh、invalidMaster、invalidDetailIdentity

| 转换 | From | To |
|---|---|---|
| activate-master | noMaster / detailReady / detailEmpty / detailErrorInitial / detailErrorRefresh | detailLoadingInitial |
| query-detail | detailReady / detailEmpty / detailErrorRefresh | detailRefreshing |
| resolve-detail | detailLoadingInitial / detailRefreshing | detailReady / detailEmpty |
| ignore-stale-detail | detailLoadingInitial / detailRefreshing / detailErrorRefresh | detailLoadingInitial / detailRefreshing / detailErrorRefresh |
| reject-detail | detailLoadingInitial / detailRefreshing | detailErrorInitial / detailErrorRefresh |
| remove-master | detailLoadingInitial / detailReady / detailEmpty / detailRefreshing / detailErrorInitial / detailErrorRefresh | noMaster / detailLoadingInitial / invalidMaster |
| reject-detail-identity | detailReady / detailRefreshing | invalidDetailIdentity |

## 界面结构

| 区域 | 用途 |
|---|---|
| `/view/regions/detailGrid` | 承载独立命名的明细 DataGrid。 |
| `/view/regions/detailHeader` | 标识当前活动主记录对应的明细上下文。 |
| `/view/regions/detailStatus` | 承载明细加载、空、错误、重试和 live region。 |
| `/view/regions/masterGrid` | 承载独立命名的主 DataGrid 和活动主上下文。 |
| `/view/regions/masterHeader` | 承载主区标题。 |
| `/view/regions/separator` | 承载可指针与键盘调整的主从分隔器。 |

## 状态视图

| 状态 | 区域 | 呈现 |
|---|---|---|
| `detailEmpty` | detailHeader、detailStatus、detailGrid | 保留明细表头并显示当前主记录无明细。 |
| `detailErrorInitial` | detailStatus、detailGrid | 显示安全初始错误与重试，不显示其他主记录旧明细。 |
| `detailErrorRefresh` | detailStatus、detailGrid | 保留旧明细并显示刷新失败和可能过期提示。 |
| `detailLoadingInitial` | detailHeader、detailStatus、detailGrid | 显示目标主上下文和初始加载，不复用上一主的明细。 |
| `detailReady` | masterGrid、detailHeader、detailGrid | 显示与当前 masterId/queryId 匹配的明细。 |
| `detailRefreshing` | detailStatus、detailGrid | 保留同一主记录的已接受明细并标记刷新中。 |
| `invalidDetailIdentity` | detailStatus、detailGrid | 阻断当前主记录下重复明细行的交互。 |
| `invalidMaster` | masterGrid、detailStatus | 受控活动主 ID 无效时显示安全状态，不猜测替代主记录。 |
| `noMaster` | masterGrid、detailStatus | 没有可见主记录时隐藏旧明细并显示无主上下文。 |

## 无障碍

主 Grid 与明细 Grid 各自保留 DataGrid 键盘模型和单一 roving tabindex；Enter 或指针仅激活主行非交互区域；F6 在主区、可见分隔器和明细区循环；separator 支持方向键与 Home/End。；主切换与加载完成不抢焦点；活动主被移除时非受控模式按可见邻接规则恢复，受控模式保留主区并发 invalid；明细刷新失败保留现有活动单元格。

## 质量预算

| Pointer | Operator | Value | Unit | Fixture |
|---|---|---:|---|---|
| `/quality/performanceBudgets/interaction` | <= | 100 | ms-p95 | activate-f6-resize |
| `/quality/performanceBudgets/longTask` | <= | 50 | ms | rapid-master-switching |
| `/quality/performanceBudgets/runtimeBundleIncrement` | <= | 12 | gzip-kb | increment-over-data-grid |

## 行为 Oracle

### `/quality/oracles/activationIsIndependentFromSelection`

Given 主表启用行选择且另一行是当前活动主

When 激活主行或操作主行复选框、按钮、链接和菜单

Then 激活只改变 aria-current 和活动主意图；选择只改变 aria-selected，嵌套控件只执行自身效果。
### `/quality/oracles/activeMasterControlledStateDoesNotSpeculate`

Given activeMaster 处于受控模式

When 用户激活另一主记录但消费方未回传新值

Then 当前主上下文、明细 DOM、请求和播报均保持，组件只发一次不可变变更意图。
### `/quality/oracles/detailIdentityIsMasterScoped`

Given 主 A 与主 B 均有 detailRowId=ROW-01，或同一主内出现重复 ID

When 进行 A/B/A 切换和明细交互

Then 不同主的行、选择和焦点互不串用；同一主内重复 ID 阻断明细交互但主区保持可操作。
### `/quality/oracles/detailQueryProducesSingleRequest`

Given 当前活动主记录和明细查询已接受

When 改变明细排序、筛选、分页或执行重试

Then 每个命令只生成一个包含完整 masterId/query/queryId/signal 的请求；排序筛选与分页重置为原子意图。
### `/quality/oracles/detailRefreshFailureRetainsContext`

Given 同一主记录已有成功明细、查询、选择和焦点

When 刷新请求失败并重试

Then 旧上下文保留并标记可能过期；重试使用同一 masterId/query 与新 queryId，只发一次请求。
### `/quality/oracles/f6NavigationKeepsGridContextsSeparate`

Given 主 Grid、分隔器和明细 Grid 均可见

When 连续使用 F6 和 Shift+F6

Then 焦点只在可见区域循环；两个 Grid 各自保持一个活动单元格且不共享 row/column 身份。
### `/quality/oracles/invalidActiveMasterDoesNotGuess`

Given 受控 activeMasterId 不存在、重复或被筛选隐藏

When 主表提交新可见结果

Then 只发一次 invalid 意图并停止展示旧明细，不猜测替代主记录、不请求或播报猜测明细。
### `/quality/oracles/separatorControlledStateDoesNotSpeculate`

Given 分隔器分别以受控和非受控布局挂载

When 使用指针、方向键和 Home/End 调整

Then 受控模式只发一次尺寸意图并等待 prop，非受控模式持久化一次；清理所有全局监听器。
### `/quality/oracles/staleDetailResultDoesNotOverwrite`

Given A/q1 后切换到 B/q2，或同一主记录从 q1 变为 q2

When 旧 masterId/queryId 结果或错误迟到

Then 迟到结果不改变 DOM、live region、选择、焦点、布局或回调计数，只有双重匹配结果应用一次。

## 视觉 Oracle

### `/quality/visualOracles/detailStateRetention`

Given 同一主记录已有成功明细和活动单元格

When 明细刷新失败

Then 旧明细、选择、焦点和分割布局保持，错误状态不遮挡数据。
### `/quality/visualOracles/focusVisibility`

Given 默认、暗色、紧凑、减少动态和 forced-colors

When 使用 F6 和区域内键盘遍历

Then 主 Grid、分隔器、明细 Grid 与重试的焦点持续可见且不被裁切。
### `/quality/visualOracles/separatorGeometry`

Given 可调分隔器处于最小、中间和最大值

When 分别使用指针与键盘调整

Then 视觉边界、命中区和 aria-valuenow 与同一状态一致，无残留监听器或跳动。
### `/quality/visualOracles/splitAndStackReachability`

Given 主从两表均有水平溢出

When 在 390px 堆叠和 1280px 分栏中遍历键盘、鼠标和触控

Then 两表末列、标题、状态、重试和分隔器均可达且互不遮挡。

## 风险与审批

风险：`R2`；所需角色：`component-maintainer`、`ux-a11y-reviewer`、`test-reviewer`；当前审批：`pending`。
