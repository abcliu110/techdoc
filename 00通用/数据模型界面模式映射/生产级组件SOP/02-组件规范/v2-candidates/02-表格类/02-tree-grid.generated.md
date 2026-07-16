<!-- GENERATED FILE: 请勿手工编辑 -->

# Tree Grid v2 候选规范

- 源：`02-tree-grid.spec.json`
- 版本：`0.2.0`
- Digest：`sha256:111ed9054c71c02062eaf18088235c7542eb6f826b223ef6bcd04e43ac5a687e`
- 状态：`ReviewReady`，`implementationAllowed=false`

## 范围

在二维列语义内浏览和选择单父层级节点，并在展开、异步分支加载、查询与刷新时保持节点身份、层级关系和焦点上下文准确。

包含：本地树、远程根查询、异步直接子节点、展开折叠、同级排序、祖先保留筛选、独立与级联选择、固定列与列宽、Treegrid 键盘模型

不包含：单元格编辑事务、拖拽改父级、分页、虚拟滚动、无限加载、多父图、透视与公式、服务端权限实现

## API

| Pointer | 类型/事件 | 契约 |
|---|---|---|
| `/api/props/ariaLabel` | `string` | 为 treegrid 提供可访问名称。 |
| `/api/props/columns` | `readonly TreeGridColumn<TNode>[]` | 每列具有稳定 id，重排、固定和调整列宽不得改变列身份。 |
| `/api/props/data` | `TreeGridDataSource<TNode>` | local-tree 提供 roots/getChildren；remote-tree 提供受控 roots、根状态、结果 queryId、分支状态和查询/子节点/重试意图。 |
| `/api/props/getNodeId` | `(node: TNode) => string` | 返回整棵树全局唯一且跨刷新稳定的节点 ID；每个 ID 只能有一个父节点。 |
| `/api/props/hasChildren` | `(node: TNode) => boolean` | 决定节点是否具有展开能力，不等价于当前是否已加载直接子节点。 |
| `/api/props/localeText` | `Partial<TreeGridLocaleText>` | 覆盖结构错误、根和分支加载、失败、重试、展开、折叠、选择与焦点恢复文案。 |
| `/api/props/treeColumnId` | `string` | 必须引用当前 columns 中唯一可见列；无效时阻断层级交互并呈现脱敏契约错误。 |
| `/api/events/childrenRequest` | `data.onChildrenRequest` | `TreeGridChildrenRequest` |
| `/api/events/expansionChange` | `expansion.onChange` | `ReadonlySet<NodeId>` |
| `/api/events/filteringChange` | `filtering.onChange` | `readonly TreeGridFilterRule[]` |
| `/api/events/nodeSelectionChange` | `nodeSelection.onChange` | `TreeGridSelectionExpression` |
| `/api/events/queryChange` | `data.onQueryChange` | `TreeGridQueryRequest` |
| `/api/events/retry` | `data.onRetry` | `TreeGridRetryRequest` |
| `/api/events/sortingChange` | `sorting.onChange` | `readonly TreeGridSortRule[]` |

## 状态机

状态：idle、loadingInitial、ready、empty、refreshing、errorInitial、errorRefresh、branchLoading、branchError、invalidHierarchy

| 转换 | From | To |
|---|---|---|
| query-root | ready / empty | refreshing |
| resolve-root | loadingInitial / refreshing | ready / empty |
| reject-root | loadingInitial / refreshing | errorInitial / errorRefresh |
| request-branch | ready / branchError | branchLoading |
| resolve-branch | branchLoading | ready |
| reject-branch | branchLoading | branchError |
| ignore-stale | refreshing / branchLoading / branchError | refreshing / branchLoading / branchError |
| reject-hierarchy | loadingInitial / ready / refreshing / branchLoading | invalidHierarchy |

## 界面结构

| 区域 | 用途 |
|---|---|
| `/view/regions/body` | 承载可见节点、层级控件和局部分支状态行。 |
| `/view/regions/header` | 承载稳定列头、排序、筛选和列宽控制。 |
| `/view/regions/status` | 承载根状态、结构错误、分支错误和 live region。 |
| `/view/regions/toolbar` | 承载筛选和选择摘要。 |

## 状态视图

| 状态 | 区域 | 呈现 |
|---|---|---|
| `branchError` | body、status | 在父节点后显示局部错误和重试。 |
| `branchLoading` | body、status | 在父节点后显示与其关联的分支加载状态。 |
| `empty` | status、body | 保留表头并显示无匹配节点。 |
| `errorInitial` | status、body | 显示安全根错误与重试。 |
| `errorRefresh` | status、body | 保留旧树并显示刷新失败。 |
| `invalidHierarchy` | status、body | 显示脱敏结构错误并阻断冲突节点操作。 |
| `loadingInitial` | status、body | 显示根级加载状态，保留表头。 |
| `ready` | header、body | 显示可见扁平节点与准确层级语义。 |
| `refreshing` | status、body | 保留上一份成功树并标记刷新中。 |

## 无障碍

ARIA treegrid：Up/Down 沿可见节点移动；树列 Right 展开或进入首子节点，Left 折叠或返回父节点；非树列 Left/Right 横向移动；Home/End 到首尾可见节点，Ctrl+Home/End 到首尾单元格；Space 选择。；折叠、过滤或刷新移除活动节点时按最近可见祖先、下一兄弟、前一兄弟、容器恢复；异步完成不抢焦点。

## 质量预算

| Pointer | Operator | Value | Unit | Fixture |
|---|---|---:|---|---|
| `/quality/performanceBudgets/interaction` | <= | 100 | ms-p95 | expand-keyboard-select |
| `/quality/performanceBudgets/longTask` | <= | 50 | ms | continuous-tree-navigation |
| `/quality/performanceBudgets/runtimeBundle` | <= | 45 | gzip-kb | tree-grid-subpath-excluding-react-peers |

## 行为 Oracle

### `/quality/oracles/activeNodeRecoveryUsesHierarchy`

Given 当前活动节点因折叠、过滤或刷新不可见

When 提交新可见树

Then 焦点按最近可见祖先等规定后备关系恢复，不按数组索引跳到其他业务节点且不触发额外选择或展开。
### `/quality/oracles/branchFailureRetainsOtherBranches`

Given 一个分支失败而其他分支已有成功节点

When 显示错误并重试

Then 其他分支、根查询、选择与焦点保持，重试只作用于失败父节点并使用新 requestId。
### `/quality/oracles/controlledCapabilitiesDoNotSpeculate`

Given 层级能力分别处于受控和非受控模式

When 执行会改变能力值的用户命令或重复命令

Then 受控模式只发一次意图并等待 prop，非受控模式持久化一次，无变化不发事件，模式切换被诊断。
### `/quality/oracles/filterPreservesSelection`

Given 已选择将被筛选隐藏的节点

When 应用筛选

Then 选择表达式保持；本地结果保留匹配节点祖先路径和真实 aria-level。
### `/quality/oracles/hierarchyKeyboardNavigation`

Given 折叠父节点及其可加载首子节点

When 依次使用 Right、Right、Left、Ctrl+End

Then 按层级语义展开、进入子节点、返回父节点和到达末单元格，始终只有一个活动单元格。
### `/quality/oracles/invalidHierarchyBlocksInteraction`

Given 重复节点 ID、多父、循环或无效 treeColumnId

When 渲染或加载冲突数据

Then 冲突层级交互被阻断并显示脱敏错误，不复制、合并、无限递归或执行错误节点操作。
### `/quality/oracles/remoteRootQueryUsesIdentity`

Given 远程根查询 A 后发出 B

When A 在 B 之后返回或失败

Then 只有 resultQueryId 匹配 B 的根结果可改变可见树、错误、焦点和播报。
### `/quality/oracles/sortProducesSingleIntent`

Given remote-tree 根查询

When 改变排序

Then 只发一次包含完整下一查询和新 queryId 的意图，不在客户端重排根或分支结果。
### `/quality/oracles/staleBranchResultDoesNotOverwrite`

Given 同一父节点已有新 requestId 或查询已变化

When 旧 parentId/queryId/requestId 结果迟到

Then 旧结果不改变 DOM、展开、选择、焦点或播报。
### `/quality/oracles/subtreeSelectionPreservesMeaning`

Given 父节点仍有未加载后代

When 选择完整子树并排除一个节点

Then 事件返回 includedSubtreeIds 与 excludedNodeIds，未来加载后代继承相同语义且父节点呈现正确 mixed 状态。

## 视觉 Oracle

### `/quality/visualOracles/fixedColumnBoundary`

Given 树列固定且存在深层节点

When 滚动到中部和末端

Then 固定边界不遮挡展开、选择、文本或焦点环。
### `/quality/visualOracles/forcedColorsVisibility`

Given forced-colors 且存在展开、选择、错误和固定边界

When 键盘遍历并滚动

Then 全部状态依靠系统颜色和结构可辨，不只依赖背景或阴影。
### `/quality/visualOracles/headerBodyAlignment`

Given 树列固定且列宽可调

When 调整列宽并横向滚动

Then 表头、树列、缩进、展开控件与正文边界逐像素对齐。
### `/quality/visualOracles/noHierarchyClipping`

Given 深度 8、长标签和 200% 缩放

When 遍历断点和主题

Then 缩进、展开、选择、文本、状态行和焦点环不重叠或裁切。
### `/quality/visualOracles/scrollReachability`

Given 390px 视口且列总宽超出视口

When 分别使用键盘、鼠标和触控导航到末列

Then 所有列和行内操作可达且层级上下文不丢失。

## 风险与审批

风险：`R2`；所需角色：`component-maintainer`、`ux-a11y-reviewer`、`test-reviewer`；当前审批：`pending`。
