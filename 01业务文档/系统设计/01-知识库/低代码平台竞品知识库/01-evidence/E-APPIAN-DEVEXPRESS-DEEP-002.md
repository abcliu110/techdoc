---
id: E-APPIAN-DEVEXPRESS-DEEP-002
type: evidence
competitors: [Appian, DevExpress]
module: enterprise-form-layout-hierarchy-tree-grid-visual
source_channel: official-public-documentation-and-live-demos
source_type: first-party-docs
captured_at: 2026-07-11
valid_until: 2026-10-11
status: active
owner: AI
ai_generated: true
---

# Appian 与 DevExpress 企业表单和层级控件深化证据

## 证据边界

本卡来自厂商官方公开文档页面的浏览器复核，不是登录态产品逐属性实测。文档列出的组件和属性记为已确认；视觉设计原则与自研建议记为推导；未在页面中直接核验的版本差异继续列为未知。

## Appian 25.2

### 已确认：组件体系

Appian 的 `Interface Components` 官方目录将组件明确分为布局、输入、选择、展示、动作、网格与列表、图表、Picker、Browser 和反馈。与企业表单设计直接相关的组件包括：

- 布局：Form、Section、Columns、Side By Side、Box、Card、Pane、Header Content、Wizard。
- 表单步骤：Wizard Layout 与 Wizard Step 分离，说明步骤容器与步骤节点属于不同结构层级。
- 高密度数据：Editable Grid、Read-Only Grid，以及独立的列配置、表头、行和列元素。
- 层级浏览：Hierarchy Browser (Tree) 与 Hierarchy Browser (Columns) 是两种独立呈现；各自有对应 Node 元素。
- 业务选择：Record、User、Group、Document/Folder 等 Picker 和 Browser 独立存在，不把所有关系字段压缩为普通下拉框。
- 反馈与可访问性：官方目录同时提供 Responsive Design、Asynchronous Loading、Performance、Accessibility 和 Keyboard Shortcuts 专题入口。

### 视觉和交互事实

- 组件分类采用业务语义而非 HTML 标签分类，设计者选择的是 Form、Section、Wizard、Record Picker、Hierarchy Browser 等任务型构件。
- `Hierarchy Browser (Tree)` 与 `Hierarchy Browser (Columns)` 并存，表明同一层级数据可以按空间和任务选择树式导航或逐级分栏浏览。
- 网格的列、行、表头被建模为子元素，复杂网格不是一个不可拆解的黑盒控件。
- Form/Wizard 支持不同标题栏模板，说明页面标题、步骤标题和正文结构由统一视觉模板约束，而不是每页自由拼装。

### 设计推导

- 自研设计器应在控件库中按“业务输入、业务选择、数据浏览、层级浏览、布局、反馈”分类，而不是只按基础控件/高级控件分类。
- 复杂关系字段至少需要 Picker、Tree Browser、Column Browser 三种呈现协议；Tree Grid 是第四种数据编辑协议，不能互相替代。
- Wizard 必须建模为 `Wizard -> Step`，Columns 必须建模为 `Columns -> Column`，以便设计期合法嵌套校验。

### 待验证

- 登录态 Design Mode 的组件拖放、深层节点定位、属性搜索和表达式编辑效率。
- Hierarchy Browser 的完整属性、节点懒加载、超大数据性能、拖拽能力和权限裁剪行为。
- 25.2 与最新版本之间的视觉和组件属性差异。

### 官方来源

- Interface Components：`https://docs.appian.com/suite/help/25.2/SAIL_Components.html`
- Design Mode：`https://docs.appian.com/suite/help/25.2/design_mode.html`
- Responsive Design：`https://docs.appian.com/suite/help/25.2/responsive_design.html`
- Building Accessible Applications：`https://docs.appian.com/suite/help/25.2/ux_accessibility.html`

## DevExpress DevExtreme TreeList 26.1

### 已确认：层级数据模型

- TreeList 同时支持嵌套层级数组和 `keyExpr + parentIdExpr + rootValue` 的扁平父子数据。
- 展开状态由 `expandedRowKeys` 表达，也可使用 `autoExpandAll`；展开状态因此可以被业务保存和恢复。
- 列支持数据类型、重排、调整宽度、自动宽度、固定列、隐藏和 Column Chooser。

### 已确认：查询、编辑与状态

- 排序支持模式、顺序和多列排序索引。
- 过滤和搜索不是单一输入框：官方列出 Filter Row、Header Filter、Filter Panel、Filter Builder 和 Search Panel。
- 编辑支持新增、修改、删除及多种编辑模式；校验规则包括 Email、Compare、Range、Required。
- 选择提供独立模式和 `onSelectionChanged` 事件，不应与当前焦点、展开状态或业务字段值混合。
- 工具栏可配置内置项和 Button 等自定义项。
- 分页由 enabled/pageSize 配置，属于显式数据规模策略。

### 已确认：拖拽

- `rowDragging` 支持行重排和拖入节点内部，关键配置包括 `allowReordering`、`allowDropInsideItem`、`onDragChange` 和 `onReorder`。
- 拖拽允许性检查与最终重排提交是两个事件阶段，适合分别执行客户端即时拒绝和服务端持久化。

### 视觉和交互事实

- TreeList 在树层级缩进之外保留标准二维表格列、表头、过滤、编辑、命令和分页，因此它是层级数据网格，不是树选择器。
- 固定列、列选择器和多入口过滤共同服务高密度宽表；状态入口固定，避免把所有操作堆入节点右键菜单。
- 编辑、选择、展开、加载和拖拽均有独立配置/事件，视觉上也应使用不同反馈，不能只用一层蓝色选中态表示。

### 设计推导

- 自研 TreeGrid 应采用 `key/parentKey/rootValue` 标准适配层，同时允许嵌套数据输入；运行前统一规范化为稳定节点索引。
- 列模型可以与普通 DataGrid 共享，但必须增加层级列、展开状态、父子查询、节点拖拽和循环校验协议。
- 过滤必须声明结果语义：仅命中节点平铺、保留祖先路径、或命中子孙时保留父节点，不能由组件隐式决定。
- 分页、虚拟滚动、懒加载是不同数据策略，设计器必须提示它们对展开、跨页选择和汇总的影响。

### 待验证

- Remote Operations、Virtual Scrolling、递归选择、无障碍键盘操作和超大树性能的具体边界。
- 不同前端技术栈封装在设计时属性和视觉默认值上的差异。
- 节点移动后的服务端并发冲突、失败回滚和乐观更新体验。

### 官方来源

- React TreeList Getting Started：`https://js.devexpress.com/React/Documentation/Guide/UI_Components/TreeList/Getting_Started_with_TreeList/`
- TreeList demos：`https://js.devexpress.com/React/Demos/WidgetsGallery/Demo/TreeList/Overview/`
- TreeList API：`https://js.devexpress.com/React/Documentation/ApiReference/UI_Components/dxTreeList/`

## 跨产品结论

### 已确认

1. Appian 的层级浏览更偏业务选择与任务引导；DevExpress TreeList 更偏高密度层级数据查询和编辑。
2. 企业平台不能用一个“树控件”覆盖所有场景，至少需要 Tree Picker、Tree Browser、Column Browser 和 TreeGrid 四类协议。
3. 语义布局节点、网格子元素、向导步骤和树节点都需要类型化父子约束。
4. 复杂企业控件的成熟度来自状态分离、错误恢复、查询策略和可访问性，不来自控件数量。

### 自研吸收原则

- 基础资料左树和组织选择优先采用 Tree Browser/Picker 模式。
- 单据分录和层级明细采用 TreeGrid，共享 DataGrid 列、编辑、校验、过滤和工具栏能力。
- 运行页面视觉分为任务引导型与高密度作业型；两者共享设计令牌和业务规则，但不强行使用同一信息密度。
- 设计态必须展示节点类型、合法落点、层级路径和拒绝原因，并提供键盘焦点与错误定位。
