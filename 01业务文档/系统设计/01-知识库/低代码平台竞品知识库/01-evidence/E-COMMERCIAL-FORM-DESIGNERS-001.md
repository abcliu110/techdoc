---
id: E-COMMERCIAL-FORM-DESIGNERS-001
type: evidence
competitors: [Mendix, OutSystems, Microsoft-Power-Apps, Retool]
module: form-designer-layout-tree-and-visual-system
source_channel: official-public-documentation
source_type: first-party-docs
captured_at: 2026-07-11
valid_until: 2026-10-11
status: active
owner: AI
ai_generated: true
---

# 商业表单设计器：布局、树控件与视觉系统证据

## 证据边界

本卡来自各厂商官方公开文档，不是登录态逐项产品实测。以下将官方文档可确认的产品能力、设计推导和未知项分开记录。设计期组件树与运行时业务树不是同一控件，不能混写。

## Mendix Studio Pro

### 已确认

- 页面编辑器、领域模型和微流程处于同一开发环境；页面组件可绑定实体、关联和动作。
- Layout Grid 使用 Bootstrap 式 12 列模型，可分别配置桌面、平板和手机的列宽、偏移、显示及排列策略。
- Tree Node 以递归节点模板显示层级数据，支持自关联数据、展开状态、按需加载、节点动作、键盘访问和样式配置。
- Tree Node 的末端节点判断和子项加载是独立问题；大树需要限制初始数据量、递归深度和缓存范围。
- 设计器属性按通用、数据、事件、外观等语义组织，组件视觉由 Design System、Atlas UI 和页面布局共同约束。

### 视觉事实

- Studio Pro 是高密度桌面 IDE：项目/页面结构、中央编辑区和属性区协同，视觉层级主要服务定位与配置，而非营销展示。
- 响应式布局通过明确断点配置表达，不把手机界面视为桌面画布等比缩小。
- 树节点需要清晰的缩进、展开控件、焦点和选中反馈；键盘状态属于可访问性交互的一部分。

### 待验证

- 目标版本 Tree Node 的全部属性、超大树虚拟化边界、拖拽编辑和复杂权限裁剪。
- 登录态 Studio Pro 中深层嵌套选择、属性搜索和错误定位的实际效率。

### 官方来源

- Studio Pro 页面：`https://docs.mendix.com/refguide/pages/`
- Layout Grid：`https://docs.mendix.com/refguide/layout-grid/`
- Tree Node：`https://docs.mendix.com/appstore/widgets/tree-node/`
- Atlas UI：`https://docs.mendix.com/refguide/atlas-ui/`

## OutSystems Service Studio

### 已确认

- Service Studio 将界面、数据、逻辑、依赖和发布组织在统一 IDE 中；Widget Tree 是设计期界面结构导航，不是运行时业务树。
- Widget Tree 用于定位嵌套组件、容器和屏幕结构；属性区支持组件配置，样式编辑与主题共同控制视觉。
- Columns 等响应式组件用于桌面和移动布局；响应式行为由组件规则表达，不依赖自由像素定位。
- Table 适合常规列表；Data Grid 面向高密度数据编辑，支持选择、排序、过滤、批量编辑和服务端验证反馈。
- Data Grid 的单元格错误反馈、编辑态和数据查询状态需要分别表达。

### 视觉事实

- Service Studio 采用典型 IDE 分区：模块树、中央画布/逻辑编辑区、属性与样式配置区；结构定位优先于装饰。
- OutSystems UI 以主题和模式库保持运行时一致性，设计态允许预览响应式结构。
- 数据网格强调列边界、编辑反馈、错误定位和工具操作的稳定位置。

### 关键边界

- 暂无本轮官方证据证明 OutSystems 11 核心组件中存在与 Mendix Tree Node 等价的原生运行时业务树。需要业务树时应单独验证 Forge 组件或自定义实现。

### 官方来源

- Service Studio：`https://www.outsystems.com/low-code-platform/service-studio/`
- OutSystems UI：`https://outsystemsui.outsystems.com/`
- Data Grid：`https://www.outsystems.com/forge/component-overview/9764/outsystems-data-grid/`
- 官方文档入口：`https://success.outsystems.com/documentation/`

## Microsoft Power Apps Studio

### 已确认

- Power Apps Studio 的 Tree view 是设计期控件层级大纲，用于选择、重命名、重排和理解嵌套关系，不等于运行时业务树控件。
- Canvas App 的核心设计面包括控件树、画布、属性、公式栏、数据和变量；组件属性与 Power Fx 公式共同定义行为。
- Container 提供水平/垂直自动布局、对齐、间距、溢出和响应式尺寸；传统坐标布局与自动布局需要明确区分。
- Gallery 用模板重复呈现数据，可通过嵌套和公式构造层级界面，但复杂树的展开、懒加载、键盘和递归选择不是 Gallery 自动提供的完整协议。
- 运行时复杂业务树需要进一步验证 PCF 控件或受支持的自定义组件方案。

### 视觉事实

- Studio 以左侧结构/插入区、中央画布、顶部公式栏和右侧属性区组成；公式与可视属性同时可见是其突出特征。
- 设计期选中框、层级树和公式引用共同表达当前编辑上下文。
- 自动布局容器通过间距、对齐和伸缩形成响应式结构；桌面与移动需要设计断点和内容优先级，而非只调整画布宽度。

### 官方来源

- Power Apps Studio：`https://learn.microsoft.com/power-apps/maker/canvas-apps/power-apps-studio`
- Tree view：`https://learn.microsoft.com/power-apps/maker/canvas-apps/controls/control-tree-view`
- 响应式布局：`https://learn.microsoft.com/power-apps/maker/canvas-apps/create-responsive-layout`
- Container 控件：`https://learn.microsoft.com/power-apps/maker/canvas-apps/controls/control-container`
- PCF：`https://learn.microsoft.com/power-apps/developer/component-framework/overview`

## Retool

### 已确认

- Retool 的 Component Tree 是设计期结构导航，可定位隐藏组件及 Tabs、Steps 等多视图容器中的子组件，并切换到相应视图。
- Checkbox Tree 接受父子层级数据，支持多选、展开路径、父子选择联动或独立、节点禁用和动态属性；它不是可编辑 TreeGrid。
- Container 可分 Header、Body、Footer 并支持多视图；Tabs/Steps 可驱动视图切换。父容器禁用状态可影响子控件。
- Stack 提供类似 Flexbox 的方向、对齐、间距和伸缩布局。桌面与移动共享组件逻辑，但位置、尺寸及是否显示可以独立维护。
- Debugger 覆盖 Console、Timeline、State、Linting 和 Performance，并展示组件与查询的依赖关系。

### 视觉事实

- Retool 以高密度内部工具工作台为目标：组件树、画布、查询/状态调试和属性配置之间切换成本低。
- 组件状态、查询状态和调试信息具有明确入口，适合频繁排查数据绑定与事件链路。
- 移动布局不是桌面布局的简单缩放；需要单独处理尺寸、顺序、可见性和触控密度。

### 关键边界

- Checkbox Tree 适合选择型层级字段；节点行内编辑、二维列、汇总、跨层拖拽和服务端树表查询需要 TreeGrid 或组合方案。

### 官方来源

- Apps 概览：`https://docs.retool.com/apps/guides`
- Components：`https://docs.retool.com/apps/guides/components`
- Checkbox Tree：`https://docs.retool.com/apps/reference/components/checkbox-tree`
- Container：`https://docs.retool.com/apps/reference/components/container`
- Stack：`https://docs.retool.com/apps/reference/components/stack`
- Debug apps：`https://docs.retool.com/apps/guides/debug`

## 跨产品已确认结论

1. 设计期组件树、大纲树与运行时业务树必须使用不同元模型和名称。
2. 企业表单布局以语义容器、约束网格和响应式规则为主，不以自由像素定位作为主模型。
3. 树控件至少拆分焦点、选中、勾选、展开、加载和业务值；树表还需编辑、列、查询和汇总状态。
4. 桌面和移动应共享业务绑定与规则，但允许独立布局、顺序、尺寸和可见性。
5. 成熟设计器都需要结构定位、属性组织、状态反馈和调试入口；只提供拖拽画布不足以支撑复杂企业应用。

## 第二轮网络交叉核验（2026-07-11）

### 多方证据结果

| 证据线 | 结果 | 可用于何种结论 |
|---|---|---|
| 厂商官方文档/API | 六款产品均取得稳定入口；Appian 25.2、DevExpress 26.1 取得更细组件/API 证据 | 产品模型、组件类型、属性和能力边界 |
| 厂商官方截图/演示 | Power Apps 当前官方视觉证据较完整；DevExpress demo 可用于 TreeList 状态分析 | 可见工作台结构、控件状态和信息密度 |
| 旧官方页面/旧截图 | Retool、Appian 部分页面已迁移；Mendix、OutSystems 当前视觉证据不足 | 只能作为历史线索，不作为当前视觉事实 |
| 第三方评测与用户反馈 | 本轮未获得覆盖六款且可交叉验证的同口径材料 | 不形成“用户共识”或产品排名 |

### 新增确认

- Appian 25.2 官方组件目录明确区分 Form、Section、Columns、Side By Side、Wizard、Editable Grid、Read-Only Grid、Hierarchy Browser (Tree)、Hierarchy Browser (Columns) 及其子元素。
- DevExpress DevExtreme TreeList 26.1 明确支持嵌套和 `keyExpr + parentIdExpr + rootValue` 两种层级数据模型，以及多入口过滤、编辑校验、选择、列管理、分页和 `rowDragging`。
- Power Apps 当前官方视觉资料可确认左侧结构/数据入口、中央画布、顶部命令与公式区域、右侧属性配置形成多区工作台；具体像素和配色仍随版本变化。
- 复杂层级控件至少应区分 Tree Picker、Tree Browser、Column Browser 和 TreeGrid，不能用一个“树控件”覆盖选择、浏览和编辑任务。

### 仍然未知

- Mendix、OutSystems 当前版本的像素级工作台视觉、深层嵌套选择效率和复杂树产品内实测。
- Retool 当前版本全部视觉细节及 Checkbox Tree 在超大远程树上的性能边界。
- 六款产品在同一复杂单据样本、同一设备和同一数据规模下的可比性能与任务完成效率。
- 第三方用户反馈是否能在具体场景、版本和用户角色下形成稳定共识。

更细的 Appian 与 DevExpress 第二轮证据见 `E-APPIAN-DEVEXPRESS-DEEP-002`。

Mendix Studio Pro 11 与 OutSystems 11 的当前官方文档、截图证据、复用层次和视觉边界深化见 `E-MENDIX-OUTSYSTEMS-DEEP-002`。
