# MasterDetailGrid 组件实施 SOP

> SOP 版本：0.1.0
>
> 对应组件：`02:master-detail-grid`
>
> 对应规范：[`02-master-detail-grid.spec.json`](../../02-组件规范/02-表格类/02-master-detail-grid.spec.json)
>
> 上位总流程：[`React组件生产交付SOP.md`](../React组件生产交付SOP.md)
>
> 架构输入：[`02-表格组件族实施设计.md`](../../02-组件规范/02-表格类/02-表格组件族实施设计.md)
>
> 执行状态来源：机器索引；本文编写时规范为 `ReviewReady`，每次执行必须在 M0 重新核对

## 1. 目的与边界

本 SOP 只规定 `MasterDetailGrid` 特有的实现顺序、失败停止点和证据收集方法。它不定义正确结果；主记录激活、明细归属、状态机、键盘、无障碍、性能和验收 oracle 均以对应组件规范为准。

首批实施：

- 复用两个 DataGrid 的主从协调外壳
- 单一活动主记录上下文，与主行选择独立
- 按 `masterId + queryId` 匹配的明细异步加载
- 按 `masterId` 隔离的明细查询、选择和焦点上下文
- 主从分隔器、宽屏分栏和狭屏堆叠
- 初始加载、刷新、空、初始错误、刷新错误和重试
- 完整键盘、焦点恢复、无障碍、视觉、响应式和性能验证

以下需求不得在本 SOP 内顺手实现：树形层级、行内展开、多主明细同时展示、明细编辑事务、未保存离开阻断、跨主批量操作、离线缓存、透视或电子表格内核。出现这些需求时，先修订规范、风险等级和本 SOP，不允许实现代码超前。

## 2. 执行输入

进入 Gate M0 前建立本次执行清单：

```text
executionId = 02:master-detail-grid@<component-version>
componentRepository = <absolute-or-repository-relative-path>
sourceRevision = <git-revision>
dataGridVersion = <approved-compatible-version>
dataGridArtifactDigest = <sha256>
packageManager = <locked-package-manager-and-version>
generalSopVersion = 1.0.0
implementationSopVersion = 0.1.0
specificationVersion = <approved-specification-version>
targetPackage = @company/ui/master-detail-grid
testCommands = <actual-repository-commands>
buildCommand = <actual-repository-command>
evidenceRoot = quality/evidence/02-master-detail-grid/<component-version>/
owner = <named-owner>
backupOwner = <named-backup-owner>
```

任何尖括号字段未绑定时不得用猜测值继续。目标仓库路径、命令、DataGrid 版本和发布流程都必须从实际 React 仓库获取。

## 3. 全程不变量

1. `activeMasterId` 是导航上下文，不是 `master.rowSelection`；两者不共享事件或 ARIA 状态。
2. 可见明细必须同时匹配当前 `masterId` 和当前 `queryId`。
3. AbortSignal 只是资源优化；乱序结果拒绝必须依赖身份匹配，不得依赖取消时序。
4. 明细行的完整身份是 `(masterId, detailRowId)`，不是页内索引或单独 `detailRowId`。
5. 明细查询、选择、活动单元格和焦点恢复目标必须按 `masterId` 命名空间隔离。
6. 切换主记录后，不得将旧主明细短暂标记或播报为新主明细。
7. 同一主记录的明细刷新失败时，上一份成功明细、查询、主从选择和焦点上下文必须保留。
8. 受控活动主 ID 失效时不猜测替代值；非受控模式只能使用规范冻结的就近可见行规则。
9. TanStack 类型、实例、RowModel 和内部 DataGrid adapter 不得从 `@company/ui/master-detail-grid` 公开导出。
10. 按钮、链接、复选框和菜单等主行嵌套控件每次交互只产生本身效果，不隐式激活主行。
11. 前端主从可见性不构成服务端租户、数据范围、归属或操作权限校验。
12. 每个能力先出现与规范 oracle 对应的 RED，再写最小生产代码；一次只增加一个可回归切片。

任一不变量失败时立即停止当前 Gate，保留失败证据，不得以“已知限制”或“后续优化”继续晋级。

## 4. Gate M0：准入与依赖绑定

### 操作

1. 运行组件规范验证与规范/SOP 分离校验。
2. 从机器索引读取 `02:master-detail-grid`，确认为 `ImplementationReady` 且 `implementationAllowed=true`。
3. 核对公开 API 已冻结、开放决策为空、全部规定角色已审批当前规范修订，且作者不是审批人。
4. 读取目标 React 仓库规则、工作区状态、包结构、令牌、测试、打包和发布流程。
5. 证明所绑定 DataGrid 候选版本已通过它自身的规范、实施 SOP、打包隔离和候选证据；记录产物摘要。
6. 绑定第 2 节的全部真实输入，保存规范、总 SOP、本 SOP、DataGrid 产物与源码修订的完整性摘要。

### 通过证据

- 规范和分离校验原始输出
- 机器索引条目和审批记录
- DataGrid 候选版本、公开类型与产物摘要
- 目标仓库工作区状态和真实命令
- 完整执行清单

### 停止条件

索引未允许实现、审批未齐、DataGrid 候选不稳定、类型契约不兼容或任一真实输入未绑定时停止，不得进入 M1。

## 5. Gate M1：锁定公开类型与 DataGrid 边界

### RED

先写类型契约测试，至少证明下列期望尚未实现：

- `MasterDetailGrid<TMaster,TDetail>` 能从 `master`、`detail.columns`、两个 `getRowId` 和 `detail.load` 正确推断两个泛型。
- `activeMaster` 和 `layout` 遵守 `value/defaultValue` 互斥与受控回调契约。
- `detail.load` 的请求和结果必须包含 `masterId/queryId`，且查询类型与 DataGrid 自有查询类型兼容。
- 主区和明细区只复用 DataGrid 公开类型，不重新声明或修改 DataGrid 契约。
- `@company/ui/master-detail-grid` 子路径可独立解析 ESM 和类型。
- 公开 `.d.ts` 不包含 `@tanstack/`、`ColumnDef`、`Table`、TanStack Row/Cell/RowModel 或内部 adapter 名称。

运行目标仓库的类型测试，保存因公开 API 未实现而失败的原始输出。语法错误、错误路径、缺包或坏夹具不算 RED。

### GREEN

1. 定义规范已冻结的自有公开类型与子路径导出。
2. 建立只依赖 DataGrid 公开 API 的内部协调层；禁止跨包导入 DataGrid 私有 adapter、hook 或 DOM 结构。
3. 不实现主从行为，只让类型契约、子路径和泄漏扫描通过。
4. 运行类型测试与受影响回归。

### 通过证据

- RED/GREEN 原始输出
- 公开 `.d.ts` 快照
- 子路径隔离消费结果
- TanStack 和 DataGrid 私有实现泄漏扫描为零

## 6. Gate M2：主区复用与活动上下文

以下切片严格逐项完成 RED、确认失败原因、最小 GREEN 和组合回归。

### M2.1 复用 DataGrid，不复制内核

RED oracle：

- 主表的排序、筛选、选择、分页、固定列和列宽只由 DataGrid 公开契约驱动。
- DataGrid 的重复 `rowId`、远程乱序结果和刷新失败语义未被外壳绕过。
- 外壳没有复制主表行模型或用 DOM 查询猜测 DataGrid 内部状态。

GREEN 操作：使用 DataGrid 的公开 Props、events 和 ref 构建主区；仅在组合边界注入活动主记录交互。

### M2.2 激活与选择分离

RED oracle：

- 点击主行非交互单元格或按 Enter 只触发一次激活回调。
- 激活主行不改变 `rowSelection`，勾选复选框不激活主行。
- 主行按钮、链接和菜单不因事件冒泡额外激活主行。
- `aria-current` 只反映主上下文，`aria-selected` 只反映 DataGrid 行选择。

GREEN 操作：实现显式的行激活命令，对嵌套交互控件使用结构化事件边界，不用不稳定的标签名白名单。

### M2.3 受控、非受控和主行移除

RED oracle：

- 首次有可见行时，非受控模式按规范激活第一可见行且不重复发初始事件。
- 受控模式只发变更意图，消费方未回传新值时不擅自切换明细。
- 当前主行被移除或筛选隐藏时，非受控模式按规范的就近可见行规则恢复；受控模式只发 `onInvalid`。
- 无可见主行时进入 `noMaster`，不展示旧明细或悬空标题。

GREEN 操作：实现最小活动上下文 reducer，使用稳定主 ID 和可见行位置快照恢复，不使用数组索引作业务身份。

### 通过证据

- MDG-01、MDG-04、MDG-07 的 RED/GREEN 原始输出
- 主行激活、选择和嵌套控件事件计数
- 受控/非受控状态轨迹
- DataGrid 完整回归和新增组合回归

## 7. Gate M3：明细请求、乱序拒绝与错误恢复

### M3.1 请求快照与新 queryId

RED：主记录变更、明细排序/筛选/分页和重试各只产生一个包含完整 `masterId/query/queryId/signal` 的请求；排序或筛选与分页重置是一个原子查询意图，不发两次请求。

GREEN：实现单一查询命令入口，在 reducer 边界一次生成快照和 queryId；只把结构化元数据交给可观测回调。

### M3.2 主 ID 与查询 ID 双重匹配

RED：使用可控 Promise 构造 `A/q1 -> B/q2 -> A/q1 resolve -> B/q2 resolve` 和同一主记录 `q1 -> q2 -> q1 resolve -> q2 resolve` 两类乱序；两类迟到结果均不改变 DOM、live region、选择、焦点或回调计数。

GREEN：在进入 reducer 前和提交可见状态时都检查 `masterId/queryId`；使用 AbortController 清理旧请求，但保留迟到结果拒绝作为独立正确性屏障。

### M3.3 初始错误、刷新错误与重试

RED：

- 无成功明细的失败进入 `detailErrorInitial`，有成功明细的失败进入 `detailErrorRefresh`。
- 刷新失败保留同一主记录的旧行、查询、选择和焦点上下文，并明确标记可能过期。
- 重试使用同一 `masterId/query` 和新 queryId，仅发一次请求，不追加重复行。
- 错误展示仅使用安全 `errorCode` 和 localeText，不输出异常对象或响应体。

GREEN：实现区分初始/刷新错误的状态容器、结果保留和单一重试命令。

### 通过证据

- MDG-02、MDG-03 的可控乱序与失败注入 RED/GREEN 输出
- 请求快照、queryId、解决顺序和应用/拒绝决策记录
- 迟到结果的 DOM、live region、回调和焦点零副作用断言
- 初始错误、刷新错误和重试的组合回归

## 8. Gate M4：明细 DataGrid 与命名空间隔离

### M4.1 明细身份和重复 ID

RED：

- A/ROW-01 与 B/ROW-01 是两个不同的复合身份，切换时不串用选择、焦点或行操作。
- 同一 masterId 内出现重复 detailRowId 时阻断明细行交互，不影响主表导航和查询恢复。
- 错误摘要不序列化主行或明细行对象。

GREEN：在内部统一使用结构化复合键，只在 DOM id 边界进行无冲突编码；复用 DataGrid 的重复 ID 阻断语义。

### M4.2 查询、选择和焦点命名空间

RED：

- 切换主记录时新明细查询从规范定义的初始快照启动，不沿用旧主的非受控排序、筛选或分页。
- 非受控明细选择和活动单元格不跨主保留；受控状态只消费当前 masterId 的值。
- 用户未显式进入明细区时，明细加载完成不抢占主区焦点。

GREEN：以 masterId 为明细状态容器 key；首版在切换时丢弃上一主的非受控明细状态，不引入跨主 LRU 缓存。

### M4.3 明细 DataGrid 组合

RED：明细本地/远程查询不二次变换；排序、筛选和分页只产生一次完整 detail request；明细刷新、空和错误语义不被外壳重复或冲突渲染。

GREEN：用规范的 detail config 将匹配结果适配到 DataGrid 公开数据源；外壳只协调 master scope 和加载生命周期。

### 通过证据

- MDG-08 和重复 detailRowId 的 RED/GREEN 输出
- 主 A/B/A 切换下的查询、选择、活动单元格和焦点轨迹
- DataGrid 主/明细组合回归
- 无新增 React warning、未处理 Promise rejection 或控制台错误

## 9. Gate M5：分割布局、键盘与无障碍

### M5.1 受控与非受控分隔器

RED：指针拖动和键盘方向键都遵守 min/max；Home/End 到达两端；受控模式只发 `layout.onChange`，非受控模式才改变内部尺寸；指针监听器在结束、取消和卸载时全部清理。

GREEN：实现单一分割尺寸命令和 `role=separator` 语义；尺寸只通过令牌/CSS 变量流向布局。

### M5.2 两个 Grid 与区域导航

RED：

- 外层 region、主 Grid 和明细 Grid 各有稳定且可读名称。
- 两个 Grid 各自只有一个 roving tabindex，不共享活动单元格。
- F6 可在主区、分隔器和明细区循环，不含不可见或禁用区域。
- 明细标题和 `aria-describedby`能识别当前主记录，不暴露敏感字段。
- 主记录切换不抢焦点；错误重试和成功后按规范恢复。

GREEN：建立显式区域注册表和焦点恢复标记，不用全局 querySelector 或 DOM 顺序猜测目标。

### M5.3 播报和自动/人工无障碍验证

RED：主上下文变更、结果数、加载失败和主上下文失效只播报一次；受控消费方未接受新主 ID 时不播报猜测明细；迟到结果不播报。

GREEN：在已提交可见状态后生成 localeText 播报，不在请求意图或 Promise 回调内直接播报。

### 通过证据

- MDG-05 的指针/键盘等价 RED/GREEN 输出
- 分隔器 ARIA 属性与可见几何值对照
- 主区/分隔器/明细区焦点轨迹
- 自动无障碍严重和高危问题为零
- 人工键盘和读屏的执行人、环境、步骤和结论

## 10. Gate M6：响应式、几何、性能与资源清理

### 响应式与几何

使用稳定业务夹具验证 default、dark、compact、reduced-motion 和 forced-colors，以及 `390`、`768`、`1280`、`1440` 像素和每个断点相邻宽度：

- 宽屏分栏与狭屏堆叠的主、从区都可达，没有隐式抽屉或只能指针打开的区域。
- 两个水平滚动容器各自可达最后列，不被分隔器、滚动条或固定列遮挡。
- 主从标题、加载、空、刷新、错误和重试无裁切、重叠、意外换行或焦点环遮挡。
- 状态切换不改变分割边界或导致页面不可预期跳动。
- 指针拖动在 `pointerup`、`pointercancel`、窗口失焦、组件卸载和异常中断后不残留全局监听器。

必须运行自动几何扫描，覆盖裁切、重叠、滚动可达、固定区对齐、焦点可见、分隔器命中区和浮层出界。MDG-06 任一发现都阻断晋级。

### 性能

记录设备、浏览器、数据、运行次数、预热和统计方法：

- 主表 local 1,000 行 x 20 列，当前明细 500 行 x 12 列。
- 远程主表 100,000 逻辑行，明细当前页 100 行。
- 主记录激活视觉反馈、F6 区域切换和分隔器键盘反馈 p95 不高于 100ms。
- 可控 A/B/A 快速切换期间不持续产生超过 50ms 的长任务。
- `@company/ui/master-detail-grid` 相对已存在 DataGrid 的运行时 gzip 增量不超过 12KB，排除 React/React DOM peer dependency。
- 快速切换 500 次后无未清理 AbortController、全局事件监听器、计时器或对已卸载组件的状态写入。

任何超预算都必须停止；优化、拆分或按总 SOP 申请适用偏差后重新验证，不能修改阈值掩盖结果。

## 11. Gate M7：打包、演示、候选与回滚

### 打包与隔离消费

1. 从锁定源码、DataGrid 候选产物和锁文件生成候选包，记录完整性摘要。
2. 在隔离消费项目仅从 `@company/ui/master-detail-grid` 导入 ESM、类型和样式。
3. 验证 SSR 导入不访问浏览器专属对象，客户端水合无未解释差异。
4. 证明导入 MasterDetailGrid 不包含 TreeGrid、PivotGrid、SpreadsheetGrid 或演示站代码，不暴露 DataGrid/TanStack 私有实现。
5. 执行包导出声明、gzip 预算、样式副作用和双包实例检查。

### 规范演示

演示必须只使用候选包公开 API，并可重复执行：

- 主行激活与主行选择互不影响
- 主表排序、筛选、分页后主上下文恢复
- A/B/A 快速切换与两种乱序明细结果
- 明细排序、筛选、分页和行选择
- 初始加载、刷新、空、初始错误、刷新错误和重试
- 活动主记录被移除的受控/非受控分支
- 重复主 ID 与同一主内重复明细 ID
- 指针/键盘分隔器、F6 区域导航和焦点恢复
- 宽屏分栏与 390px 堆叠的双表格滚动可达

乱序、失败、重复 ID 和主行移除必须由可控夹具真实触发，不得只改说明文案或直接设置最终 DOM。

### R2 候选、消费项目与回滚

1. 在至少一个代表性消费项目使用同一候选产物完成主路径、失败路径、恢复路径和 390px 键盘路径。
2. 记录从上一稳定版本到候选版本、再回到上一版本的真实安装命令和产物摘要。
3. 回滚后验证消费项目的 DataGrid 依赖、主表状态、路由和旧页面恢复；不删除仍被锁定的包版本。
4. 候选生成后任一源码、DataGrid 产物、锁文件、构建环境或候选产物变化，候选立即作废并重跑受影响 Gate。

### 完成条件

只有总 SOP 的全部适用门禁、M0-M7、MDG-01 至 MDG-08、R2 候选证据、独立评审和发布批准均通过，才能晋级 Stable。代码、单测或演示任一项单独通过都不代表组件完成。

## 12. 执行记录最低结构

每个 Gate 追加记录，不覆盖 RED、失败或旧候选历史：

```text
gateId
status = blocked | red-observed | passed | failed
startedAt
completedAt
executor
sourceRevision
dataGridArtifactIntegrity
artifactIntegrity
commands[]
expectedResult
actualResult
evidencePaths[]
acceptanceOracleIds[]
reviewer
blockers[]
```

`manifest.json` 必须绑定总 SOP 版本、MasterDetailGrid 实施 SOP 版本、规范版本、DataGrid 候选摘要、源码修订和 MasterDetailGrid 候选产物摘要。规范、任一 SOP 或 DataGrid 候选版本变化后，必须先做影响分析；旧证据不得自动沿用。
