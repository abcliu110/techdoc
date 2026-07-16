# TreeGrid 组件实施 SOP

> SOP 版本：0.1.0
>
> 对应组件：`02:tree-grid`
>
> 对应规范：[`02-tree-grid.spec.json`](../../02-组件规范/02-表格类/02-tree-grid.spec.json)
>
> 上位总流程：[`React组件生产交付SOP.md`](../React组件生产交付SOP.md)
>
> 架构输入：[`02-表格组件族实施设计.md`](../../02-组件规范/02-表格类/02-表格组件族实施设计.md)
>
> 执行状态来源：机器索引；本文编写时组件规范为 `ReviewReady`，每次执行必须在 T0 重新核对

## 1. 目的与边界

本 SOP 规定 `TreeGrid` 特有的实现顺序、RED/GREEN 切片和停止条件。它不重新定义正确结果；公开 API、状态机、异常恢复、键盘模型、性能预算和验收 oracle 只以对应单组件规范为准。

本 SOP 只实施规范列出的独立 TreeGrid 能力：

- 本地树与受控异步子节点树
- 全局稳定节点身份、单父关系和循环检测
- 展开/折叠、逐分支加载、失败和重试
- 同级排序、祖先保留筛选
- 节点选择和可覆盖未加载后代的子树选择表达式
- 固定列、列宽、响应式和 ARIA Treegrid 键盘/焦点模型

节点编辑、拖拽改父级、分页、虚拟滚动、无限加载、公式、透视和服务端业务写入不在本 SOP 范围。出现这些需求时停止当前 Gate，先建立或修订相应规范、风险和实施 SOP。

## 2. 执行输入

开始 T0 前建立本版本执行清单，至少绑定：

```text
executionId = 02:tree-grid@<component-version>
componentRepository = <absolute-or-repository-relative-path>
sourceRevision = <git-revision>
dataGridCandidate = <exact-tested-version-or-source-revision>
packageManager = <locked-package-manager-and-version>
generalSopVersion = 1.0.0
implementationSopVersion = 0.1.0
specificationVersion = <approved-or-authorized-specification-version>
targetPackage = @company/ui/tree-grid
testCommands = <actual repository commands>
buildCommand = <actual repository command>
evidenceRoot = quality/evidence/02-tree-grid/<component-version>/
owner = <named owner>
backupOwner = <named backup owner>
```

尖括号字段必须由目标 React 仓库、候选授权和真实工具链绑定，不得从本技术文档目录猜测。TreeGrid 复用 DataGrid 基础设施时必须锁定已验证的精确版本或源码修订，不能引用浮动分支。

## 3. 全程不变量

每个 Gate 都必须守住：

1. `nodeId` 只能来自 `getNodeId`，不得来自可见索引、递归位置或对象引用。
2. 每个 `nodeId` 在整棵树中最多出现一次且最多有一个父节点；重复、循环和多父必须阻断层级交互。
3. `treeColumnId`、列 ID 和节点 ID 在重排、筛选、固定列和宽度变化后保持稳定。
4. 折叠只改变可见性；不得删除已加载子节点、选择表达式或其他分支状态。
5. 异步子结果必须同时匹配 `parentId`、当前 `queryId` 和当前 `requestId`；迟到结果不得产生可见副作用或播报。
6. 选择完整子树时必须保留 `includedSubtreeIds` 语义；不得用当前已加载后代枚举替代未加载范围。
7. 同级排序不得把节点移到另一父节点；筛选保留匹配节点的完整祖先路径和真实 `aria-level`。
8. 活动节点被折叠、过滤或刷新移除后，焦点按层级关系恢复，不能按数组索引跳到另一业务节点。
9. TreeGrid 不向 DataGrid 增加层级公开开关；TanStack 类型、实例和 RowModel 不得进入 TreeGrid 公开导出或 `.d.ts`。
10. 每个能力先观察目标行为缺失导致的有效 RED，再写最小 GREEN；一次只增加一个可审查切片。

任一不变量失败时停止当前 Gate，保存失败证据。不得以“仅未加载节点”“后续虚拟化处理”或“服务端会校验”为理由继续晋级。

## 4. Gate T0：准入、依赖和执行边界

### 操作

1. 运行规范验证和规范/SOP 分离校验。
2. 从机器索引读取 `02:tree-grid`，记录生命周期、`implementationAllowed`、阻塞项和对应规范/SOP 路径。
3. 正式生产实现只允许在 `ImplementationReady`、`implementationAllowed=true` 且审批覆盖当前规范修订时进入 T1；私有预发布例外必须有显式授权记录，并保持正式发布阻塞状态。
4. 读取目标 React 仓库规则、工作区状态、DataGrid 公开边界与实际打包结构，确认不覆盖用户修改。
5. 验证锁定的 DataGrid 候选已通过其回归和回滚门禁；TreeGrid 不得建立在未验证的移动目标上。
6. 写入第 2 节全部真实输入，记录规范、SOP、DataGrid 候选、依赖锁和源码修订完整性摘要。

### 通过证据

- 规范验证与分离校验原始输出
- 机器索引 TreeGrid 条目及授权/审批记录
- DataGrid 精确候选身份和既有验证摘要
- 目标仓库状态、实际命令和执行清单

### 停止条件

缺少真实仓库、锁定 DataGrid 候选、执行命令、Owner、授权或审批时不得进入后续 Gate。若 TreeGrid 需求要求修改 DataGrid 公开 API，先停止并独立评审 DataGrid 兼容面。

## 5. Gate T1：公开类型、子路径和隔离 RED/GREEN

### RED

先写类型和打包契约测试，至少证明下列期望尚未实现：

- `TreeGrid<TNode>` 从 `data`、列访问器、`getNodeId` 和 `hasChildren` 正确推断节点类型。
- `local-tree` 与 `remote-tree` 是可穷尽判断的判别联合。
- `TreeGridSelectionExpression` 同时表达显式节点、完整子树和显式排除。
- `expansion`、排序、筛选和选择遵守 `value`/`defaultValue` 受控规则。
- `@company/ui/tree-grid` 可独立解析 ESM、类型和样式。
- 公开 `.d.ts` 不包含 `@tanstack/`、TanStack Table/RowModel，也不要求消费方从 DataGrid 内部路径导入。

运行真实类型测试并保存失败输出。缺包、错误路径、语法错误或坏夹具不算有效 RED。

### GREEN

1. 定义规范冻结或授权的自有公开类型与子路径导出。
2. 只复用 DataGrid 已公开或稳定内部基础设施；建立 TreeGrid 自己的层级适配边界。
3. 先不实现层级行为，只让类型、子路径和依赖隔离测试通过。
4. 运行类型、导出和受影响 DataGrid 回归。

### 通过证据

- RED/GREEN 原始输出
- 公开 `.d.ts` 快照和 TanStack 泄漏扫描为零
- 子路径独立消费结果
- DataGrid 公开 API 与包体未变化的差异证明

## 6. Gate T2：层级身份与可见树核心 RED/GREEN

按 T2.1、T2.2 顺序各自完成 RED、最小 GREEN 和回归。

### T2.1 身份、单父与循环

RED oracle：

- 根节点或兄弟节点重排后，展开、选择和活动节点仍关联相同 `nodeId`。
- 重复 ID、同一 ID 位于多个父节点、直接或间接循环均被检测并阻断。
- 错误摘要不序列化完整业务节点，合法旁支不会被静默合并。

GREEN 操作：建立一次遍历的节点注册表、父关系表和路径检测；只产出自有层级模型。避免在渲染期间对同一分支持续重复扫描。

### T2.2 可见扁平化与树列

RED oracle：

- 只把 expansion 中展开节点的已加载后代加入可见序列。
- 每个可见节点具有稳定 nodeId、parentId、depth、posInSet 和 setSize（已知时）。
- `treeColumnId` 不存在、隐藏或重复时出现明确契约错误。
- 折叠后代不在 DOM 方向键序列中，折叠不删除其状态。

GREEN 操作：实现纯函数可见树扁平化、树列缩进与 disclosure 渲染，复用二维单元格、固定列和列宽基础设施。

### 通过证据

- 身份与层级模型单元测试
- 深度 8、空子节点、重复/循环/多父失败夹具
- 展开前后 DOM、ARIA 和可见序列断言
- DataGrid 行列核心回归保持通过

## 7. Gate T3：展开、键盘与焦点 RED/GREEN

### RED

逐项观察失败：

1. 鼠标或树列 Right 展开折叠父节点，事件只触发一次。
2. 已展开父节点的 Right 进入第一个可见子节点；折叠节点的 Left 回到父节点。
3. 非树列 Left/Right 只移动相邻单元格，不意外展开层级。
4. Up/Down 只经过可见节点；Home/End 和 Ctrl+Home/End 到达规范边界。
5. 外部折叠活动节点祖先时，焦点返回最近可见祖先而非页面起点。
6. 受控 expansion 不预先改变 DOM、播报或焦点；只有消费方回传 value 后提交可见状态。

### GREEN

1. 在 TreeGrid 层实现层级键盘状态机，保留 DataGrid 单一 roving tabindex 基础。
2. 通过节点关系而不是可见索引计算父子和焦点后备目标。
3. 展开/折叠事件、受控状态提交和播报使用同一已提交状态源。
4. 完成鼠标、触摸、键盘和外部受控更新组合回归。

### 停止条件

若层级键盘必须改变 DataGrid 的公开键盘契约，或出现两个活动 tabindex、隐藏后代仍可聚焦、受控状态预先播报，停止并修复边界后重跑 T2/T3。

## 8. Gate T4：异步子节点与局部恢复 RED/GREEN

能力按下列顺序实施，每项均独立 RED/GREEN：

```text
请求去重 -> 匹配结果应用 -> 折叠期间返回 -> 局部失败 -> 重试 -> 根查询刷新
```

### RED

- 展开未加载节点只产生一次含 `parentId/queryId/requestId` 的请求。
- 同一父节点旧 requestId 或旧 queryId 的迟到成功/失败均不改变当前数据、错误和播报。
- 加载期间折叠后，匹配结果可缓存但节点保持折叠且不抢焦点。
- 单个分支失败保留其他分支、已有子节点、查询、展开和选择表达式。
- Enter 重新激活失败 disclosure 或分支重试按钮只发一次新 requestId。
- 根查询刷新失败保留上一份成功树；匹配新根结果后删除的活动节点按规范恢复焦点。

### GREEN

1. 为每个父节点建立独立请求身份和只读分支状态适配。
2. 在应用结果前校验三元身份，不依赖请求取消保证正确性。
3. 分支加载/错误作为与父节点关联的局部呈现，不用全表 loading 覆盖可用旁支。
4. 根查询与子请求共享 queryId，但各分支使用独立 requestId。
5. 记录一次性播报键，避免 React 重渲染重复播报同一结果。

### 通过证据

- 可控延迟、乱序、失败和重试夹具
- 请求次数、结果应用和播报次数断言
- 折叠期间返回、刷新删除活动节点和多分支并发的组件测试
- 无未清理监听器、定时器或卸载后状态更新警告

## 9. Gate T5：查询、选择与二维能力组合 RED/GREEN

### T5.1 同级排序

RED：排序只改变同一父节点下的兄弟顺序；节点不跨父级；remote-tree 只发一次查询意图并拒绝旧 queryId 结果。

GREEN：复用自有排序配置和内部行模型，对每个兄弟集合独立排序；不得对 remote-tree 服务端结果二次排序。

### T5.2 祖先保留筛选

RED：只有深层 LOT-01 匹配时保留完整祖先路径、隐藏无关旁支并保持真实 `aria-level`；清除筛选恢复此前 expansion；remote-tree 只发查询意图。

GREEN：区分用户 expansion 与筛选派生可见路径，筛选不得永久写回或丢失用户 expansion。

### T5.3 节点与子树选择

RED：

- 单节点选择只改变 `includedNodeIds`。
- 子树选择写入 `includedSubtreeIds`，未加载后代在加载后自动呈现继承状态。
- 子树内排除写入 `excludedNodeIds`；父节点呈现部分选择。
- 排序、筛选、折叠和刷新不把选择迁移到同索引节点。
- 组件事件不把语义表达式展开成当前已加载 ID 列表。

GREEN：实现选择表达式归一化和可见节点投影；检测互相覆盖的冗余项时输出确定的最小等价表达式。服务端是否有权执行该范围由消费方校验，不在组件内推断。

### T5.4 固定列与列宽

RED：固定树列、深层缩进、列宽调整和横向滚动组合下，表头、行高、焦点环和 disclosure 边界对齐；390px 可到达全部列。

GREEN：复用 DataGrid 经验证的固定列和列宽基础，TreeGrid 只增加树列内部布局令牌，不复制列状态引擎。

### 停止条件

出现分页、虚拟窗口、拖拽改父级或编辑语义时停止扩展本 Gate。子树选择若只能枚举已加载节点才能实现，视为设计失败，不得降低 oracle。

## 10. Gate T6：组合、无障碍、视觉和性能

### 组合矩阵

至少覆盖：

```text
展开 x 固定树列 x 列宽调整
异步加载 x 折叠 x 迟到结果
筛选 x 用户 expansion x 焦点恢复
同级排序 x 节点选择 x 子树选择排除
分支错误 x 其他分支可操作 x 重试
深层级 x 长文本 x 390px 横向滚动
```

### 无障碍和视觉

1. 自动检查 treegrid/row/columnheader/gridcell、aria-level、aria-expanded、aria-posinset/setsize 和名称关系。
2. 人工仅键盘完成主路径、三条异常路径和恢复路径。
3. 使用实际支持矩阵进行读屏复核，确认层级、展开状态、局部加载/失败和选择状态可理解。
4. 验证 390、768、1280、1440 px 及相邻断点，默认、暗色、紧凑、减少动态效果和深度 1/8。
5. 执行几何断言：无裁切、重叠、不可达横向内容、sticky 错位和焦点环遮挡。

### 性能

按规范固定数据规模、设备档位、预热、采样和 p95：

- local-tree 2,000 节点、深度 8、当前可见不超过 300 x 20 列。
- remote-tree 100,000 逻辑节点、已加载不超过 1,000、当前可见不超过 300 x 20 列。
- 测量展开/折叠、键盘移动、选择反馈和已加载树重新扁平化，p95 不高于 100ms。
- 连续交互无持续 >50ms 长任务。
- `@company/ui/tree-grid` gzip 总增量不超过 45KB，相对 DataGrid 层级增量不超过 15KB。

任何预算、几何或无障碍红线失败均停止；不能删除夹具、减少层级或提高阈值掩盖结果。

## 11. Gate T7：打包、演示、候选和回滚

### 打包与隔离消费

1. 从锁定源码和依赖生成不可变候选并记录摘要。
2. 隔离消费项目只从 `@company/ui/tree-grid` 导入 ESM、类型和样式。
3. 验证 SSR 导入不访问浏览器对象，客户端水合无未解释差异。
4. 验证导入 TreeGrid 不包含演示站、编辑、虚拟化、透视或其他独立内核。
5. 重新验证 DataGrid 子路径的声明、包体和行为未因 TreeGrid 改变。

### 规范演示

候选包必须真实演示：本地树、异步子节点、层级键盘、同级排序、祖先保留筛选、单节点选择、子树选择排除、固定树列、分支失败、迟到响应、重试、根刷新失败和焦点恢复。异常通过可重复夹具触发，不能只切换说明文字。

### R2 候选与回滚

1. 在代表性消费项目验证真实层级数据和主/异常/恢复路径。
2. 执行降级到上一稳定版本或移除 TreeGrid 子路径的真实命令。
3. 验证 DataGrid 和现有业务表格保持原行为，消费方的 expansion/selection 持久化不污染旧版本。
4. 候选后源码、依赖、DataGrid 基础版本、构建环境或产物变化时使候选作废，并重跑受影响 Gate。

只有总 SOP、T0-T7、全部 TreeGrid oracle、R2 证据和发布批准均通过，才能晋级 Stable。代码完成、单测通过或演示可点击均不等于生产完成。

## 12. 执行记录最低结构

每个 Gate 追加记录，不覆盖 RED、失败或重试历史：

```text
gateId
status = blocked | red-observed | passed | failed
startedAt
completedAt
executor
sourceRevision
dataGridCandidate
artifactIntegrity
commands[]
expectedResult
actualResult
evidencePaths[]
acceptanceOracleIds[]
reviewer
blockers[]
```

`manifest.json` 必须绑定总 SOP 版本、TreeGrid 实施 SOP 版本、规范版本、DataGrid 候选、源码修订和候选产物摘要。规范、SOP 或 DataGrid 基础版本变化后先做影响分析；旧证据不得自动沿用。
