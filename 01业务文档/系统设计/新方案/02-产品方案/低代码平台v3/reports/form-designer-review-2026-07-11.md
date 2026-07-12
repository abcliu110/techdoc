# V3 表单设计器独立评审

评审时间：2026-07-11  
评审范围：`prototype/`、`tests/`、组件与成熟度协议、本地浏览器交互、现有截图与递归 UI 质量门禁。  
结论置信度：已确认。结论均有代码证据；布局属性问题另有浏览器复现和截图差异证据。

## 结论

当前产物已经是可操作的企业表单设计器原型，不再只是静态效果图：组件搜索和拖入、Schema 事务、嵌套约束、撤销/重做、本地快照、运行预览、递归几何检查均有真实实现。

但它还不能宣称“整个企业级表单设计器完成”。当前仍有 1 个 P0、4 个 P1。根因不是视觉溢出，而是质量门禁只证明渲染几何完整，尚未证明 Schema 权威性、属性渲染真实性、组件成熟度和发布检查真实性。

建议终态：`NOT_READY`。P0 未关闭前不得把“生成候选版本”描述为真实发布准备通过。

## P0

### F-REVIEW-001 发布检查可以基于硬编码证据通过

- 事实：`validateForPublish()` 只检查内存中的开放 P0/P1 finding；关闭唯一的示例 P0 后立即返回 `ready`。
- 事实：发布面板中的“18 个字段，0 个断裂引用”“4 条规则，无循环”“Renderer 2.4 兼容”均为硬编码 `true` 和固定文本。
- 影响：即使 Schema 缺字段、复杂容器不可用、Renderer 只是占位，界面仍可显示“发布前校验通过”并启用候选版本按钮。这属于门禁假通过。
- 证据：`prototype/designer-state.mjs:138`、`prototype/app.js:782`、`prototype/app.js:789`。
- 修复：发布结果必须由 `validateSchema()`、规则依赖校验、权限覆盖和 Renderer 成熟度共同派生；未接入的检查显示 `BLOCKED/NOT_RUN`，不能显示绿色通过。

## P1

### F-REVIEW-002 样例主表字段不在权威 Schema 节点树中

- 事实：初始 Schema 只有 `page` 和 `entries` 两个节点；订单编码、客户、订单日期、销售组织、含税金额是 `index.html` 中的静态 DOM，并由 `BASE_FIELD_DETAILS` 维护旁路元数据。
- 事实：大纲和节点计数只遍历 `state.schema.nodes`，因此看不到这五个主表字段。属性修改写入 `schema.fieldProperties`，但字段本身仍不是可移动、可删除、可校验的 Schema 节点。
- 影响：画布、大纲、Schema 和发布校验并非同一事实源；复杂基础资料和单据布局无法可靠序列化和重放。
- 证据：`prototype/app.js:22`、`prototype/app.js:65`、`prototype/app.js:168`、`prototype/app.js:378`、`prototype/index.html:111`。
- 修复：把样例头字段迁入 `FormPage -> Section -> FieldLayout -> Field` 节点树，画布完全从 Schema 渲染；删除 `BASE_FIELD_DETAILS` 旁路。

### F-REVIEW-003 部分属性仍是“可保存但不产生设计效果”

- 已修复：标题、必填、只读、显示标签、帮助信息会写入 Schema，并支持撤销、重做和快照恢复。
- 未修复：`width` 只写入 `data-width`，CSS 没有消费该值；`minWidth`、`labelPosition`、`align`、`margin`、`padding` 没有投影到画布；`controlType` 只改变检查器类型文案，没有切换 Renderer。
- 浏览器复现：客户字段“占用列宽”从 `1/3` 改为“整行”后，前后截图仅 208 / 707256 像素不同（0.03%），变化来自属性下拉框文本，画布字段位置和尺寸不变。
- 证据：`prototype/app.js:243`、`prototype/app.js:671`、`reports/screenshots/review-before-width.png`、`reports/screenshots/review-after-width.png`。
- 修复：为可见布局属性提供纯投影函数和 Renderer 行为测试；尚未实现的控件必须禁用并标记“未接入”，不能允许假编辑。

### F-REVIEW-004 复杂布局容器可拖入但无法形成可用结构

- 事实：`Columns`、`Tabs`、`Wizard`、`SplitPane`、`DashboardGrid` 只允许特定内部结构节点；但新增组件统一创建 `children: []`，组件面板也不提供 `Column/TabPane/WizardStep/SplitRegion/DashboardCard`。
- 影响：这些复杂容器拖入后是永久空壳，普通组件不能合法放入，与“拖入兼容组件”提示冲突。这直接影响复杂基础资料和单据布局目标。
- 证据：`prototype/component-registry.mjs:205`、`prototype/schema-engine.mjs:94`、`prototype/app.js:700`。
- 修复：物料创建事务自动生成默认结构子节点，例如 Columns 两列、Tabs 一个 TabPane、SplitPane 两个 SplitRegion；同时增加结构增删和最小数量约束测试。

### F-REVIEW-005 组件成熟度默认值与协议冲突

- 事实：注册表默认将组件标为 `ready` 并允许拖入；设计协议定义的是 `catalogued/designable/previewable/production-ready`，并明确未达到 `designable` 的组件不能伪装成可用物料。
- 事实：README 已承认 106 个组件多数只是协议驱动占位 Renderer。
- 影响：组件面板数量真实，但“可用性”被放大；用户会把目录覆盖误解为 106 个可完成设计和预览的组件。
- 证据：`prototype/component-registry.mjs:42`、`design/component-protocols.md:235`、`README.md:62`。
- 修复：默认成熟度改为 `catalogued`；只有通过拖入、配置、序列化、反显和撤销测试的组件升为 `designable`，通过专用 Renderer/状态测试后再升为 `previewable`。

## P2 与边界

- 组件协议要求复制和删除，但当前只实现添加、移动、撤销和重做。
- “新建规则”、规则启停、权限矩阵、数据绑定指标和变更记录仍主要是演示内容，不是端到端设计能力。
- 列表和详情设计器已正确禁用，不再是假切换；这属于诚实边界，不是缺陷伪装。
- 运行预览已清理拖拽、移动、选择和占位标记；该问题已关闭。
- 106 个组件是协议目录，不是 106 个生产 Renderer；README 的边界说明应继续保留。

## 视觉评审

现有桌面截图具备企业设计器类别特征：左侧物料、中间画布、右侧检查器、底部问题区的信息架构清晰，高密度但可扫描；与金蝶参考的工作台类别一致，且视觉代码为本项目独立实现。

递归门禁的 22 个视口/状态样本为 22 PASS、0 finding，说明当前已覆盖的 DOM 不存在已知 P0/P1 裁剪、命中或未声明滚动问题。这个结果只证明几何完整，不覆盖本报告中的假编辑、假检查、Schema 分裂和空壳组件。

## 验证证据

- `node --test tests/*.test.mjs`：90 / 90 PASS。
- 对 `prototype/` 和 `tests/` 全部 `.js/.mjs` 执行 `node --check`：PASS。
- 浏览器复现：列表/详情禁用；预览不再暴露编辑器移动控件；布局宽度修改未改变画布。
- 结构化代码图谱未用于结论：V3 目录尚未作为独立 Git/图谱项目根注册，评审降级为源码、测试和浏览器证据交叉验证。

## 验收顺序

1. 先关闭 F-REVIEW-001，消除发布门禁假通过。
2. 将样例头字段并入 Schema 节点树，建立唯一事实源。
3. 完成或禁用布局属性，补视觉行为测试。
4. 为复杂容器生成内部结构节点。
5. 重新分级 106 个组件成熟度，再运行递归几何矩阵和核心浏览器任务。

回滚方案：本报告不修改运行逻辑；若后续修复产生回归，可逐项回退属性投影、结构模板或发布校验，不需要回退已通过的递归几何门禁。
