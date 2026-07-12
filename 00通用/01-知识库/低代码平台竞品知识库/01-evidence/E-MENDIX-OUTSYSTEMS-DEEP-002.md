---
id: E-MENDIX-OUTSYSTEMS-DEEP-002
type: evidence
competitors: [Mendix-Studio-Pro-11, OutSystems-11-Service-Studio]
module: enterprise-form-designer-information-architecture-and-visual-system
source_channel: official-public-documentation-and-official-screenshots
source_type: first-party-docs
captured_at: 2026-07-11
valid_until: 2026-10-11
status: active
owner: AI
ai_generated: true
---

# Mendix Studio Pro 11 与 OutSystems 11 设计器深化证据

## 研究边界

本卡基于 2026-07-11 可访问的官方文档、官方文档内嵌软件截图和官方产品结构说明。未安装桌面 IDE，也未进入登录态项目，因此不把逐属性操作效率、性能和未在官方材料中出现的交互写成事实。

证据等级：

- A：当前官方文档正文或官方文档中的真实产品截图直接确认。
- B：由多个 A 级事实共同支持的设计推导，不能当作产品原始实现事实。
- U：尚未验证。

## Mendix Studio Pro 11

### A 级：工作台信息架构

- Studio Pro 11 官方将界面明确拆成 Top Bar、App Explorer、Working Area、Document Tabs、Dockable Panes 和 Status Bar。
- App Explorer 以模块和文档组织应用；工作区用文档标签承载页面、微流程、领域模型等不同编辑器。
- Dockable Panes 可以围绕工作区停靠，官方截图可确认属性、工具箱、连接器等配置入口以窗格存在，而不是全部覆盖在画布弹窗中。
- 状态栏承载当前应用状态、版本控制分支和历史入口，说明协作与版本状态是主工作台的一等信息。
- 页面资源不是单一页面：官方目录区分 Layout、Page Template、Snippet、Building Block、Page、Menu 和 Image Collection。
- Layout 是跨页面框架，修改后其页面继承变化；Page Template 提供新页面初始结构；Snippet 是可复用界面片段；Building Block 是带预设样式、出现在页面工具箱中的组件组合。四者复用粒度不同。

### A 级：页面与布局模型

- 页面最终承载终端用户界面，并可基于布局；布局负责标题、徽标、菜单等跨页面结构的一致性。
- 官方明确区分响应式布局与移动布局，并以空间差异举例：移动布局可以使用更窄标题和更小徽标。
- 页面组件目录按 Data Containers、Text、Structure、Input Elements、Images/Videos/Files、Buttons、Menus/Navigation、Authentication、Charts 分类。
- 页面、领域模型和微流程都作为应用建模文档存在于同一 IDE，因此页面配置不是脱离数据和逻辑的单独画布。

### A 级：视觉观察

- 官方总览截图显示典型高密度桌面 IDE：顶部为菜单与运行/发布命令，左侧 App Explorer，中央工作区，右侧工具箱/属性类窗格，底部状态栏。
- 工作区占最大面积；左右窗格用稳定边界与标题区分，强调持续定位和配置，而非卡片化装饰。
- 属性窗格使用分组属性表：属性名和值对齐，分组可折叠，长列表采用紧凑行高。此模式适合高频扫描，但需要搜索、收藏或上下文过滤来控制复杂度。
- 多个文档通过标签并列，适合在页面、逻辑与模型间切换；标签数量过多时的管理方式仍待产品内验证。

### B 级：对自研设计器的启示

- 复用资产至少应拆为“应用壳布局、页面模板、可复用片段、带样式物料块”，不能只提供一个模糊的模板概念。
- 设计器主框架应让业务对象、页面、规则、流程处于统一导航空间，并以文档标签保持上下文，而不是让用户在多个独立后台间反复跳转。
- 属性面板适合紧凑分组表，但需同时提供搜索、只看已修改、数据/事件/外观筛选和恢复默认值。
- 状态栏应显示草稿/已保存、校验错误、当前设备、分支/版本和环境，减少把关键状态藏在发布弹窗中的做法。

### U：仍待验证

- 深层容器在画布、结构树与属性窗格之间的同步选择效率。
- Tree Node 在 Studio Pro 11 当前版本中的完整属性、远程大树性能、拖拽约束和权限裁剪。
- 多文档标签溢出、面板停靠持久化、属性搜索及错误跳转的实际交互。
- PC、平板、手机断点在同一复杂基础资料与单据样本上的编辑和预览闭环。

## OutSystems 11 Service Studio

### A 级：应用构建闭环

- 当前 O11 官方文档把 Building apps 分为 Data management、User Interface、Application Logic、Processes、异常处理、定时任务、复用/重构、合并/版本等主题。
- User Interface 进一步分为 Screens、Look and Feel、Accessibility、Screen Templates、Tables、Inputs、Forms、Images、Reuse UI、Patterns、Navigation 和多语言。
- 官方定义 Form 为对输入组件进行分组并收集、校验、提交数据的界面结构；表格编辑、输入组件与表单是不同专题。
- UI 复用通过 Blocks/Web Blocks；起步结构通过 Screen Templates；跨应用起点通过 Application Templates；视觉一致性由 UI Framework、Patterns、Theme/Style Guide 共同承担。
- 官方文档明确覆盖实时校验、可访问性焦点、skip-to-content、替代文本和表单标签，说明可访问性不是纯运行时附加项。
- O11 用户管理文档入口明确角色与权限可限制屏幕、界面元素和操作；具体设计器权限表达方式仍需产品内验证。

### A 级：视觉与交互结构

- 官方材料支持 Service Studio 是统一 IDE，而非只做页面拖拽：数据、UI、逻辑、流程、调试、部署与版本均属于同一开发生命周期。
- Screen Template、Pattern、Block 和 Theme 分别承担起始结构、重复交互模式、可复用界面和视觉规范，避免每个页面自由拼装造成漂移。
- 表单、表格和输入控件分别建模，适合把校验状态定位到具体字段/单元格，同时保留表单级提交状态。
- 当前公开文档页没有提供足够清晰的 Service Studio 11 全工作台大图，因此不记录像素级颜色、面板宽度和当前图标样式。

### B 级：对自研设计器的启示

- 页面设计器不能孤立：实体、查询、规则、流程、权限、调试和发布应共享同一应用上下文，并能从错误直接跳回设计元素。
- 复用体系应区分应用模板、页面模板、交互模式、可复用块和主题令牌；各层有独立升级与影响范围。
- 校验元模型至少拆分字段校验、行/单元格校验、表单提交校验和服务端业务校验，并在画布、结构树和问题面板同步定位。
- 可访问性检查应进入发布门禁，包括标签关联、键盘焦点顺序、跳转内容、图片替代文本和错误提示可感知性。

### U：仍待验证

- Service Studio 当前版本 Widget Tree、画布、属性、样式面板和错误列表的像素级结构。
- 深层 Widget Tree 选择、重命名、复制、合法嵌套提示和父子快速跳转。
- 官方核心组件是否存在完整运行时业务树；现有证据只能确认设计期结构树，不能确认与 Mendix Tree Node 等价的业务控件。
- Data Grid 的全部设计态属性、服务端分页/过滤、单元格编辑冲突和大数据性能边界。

## 两款产品的结构对照

| 维度 | Mendix Studio Pro 11 | OutSystems 11 | 可吸收原则 |
|---|---|---|---|
| 主组织对象 | 模块与多类建模文档 | 应用模块中的数据、UI、逻辑、流程 | 统一应用上下文，多编辑器协作 |
| 页面起点 | Layout + Page Template | Application/Screen Template | 应用壳与页面起始结构分层 |
| 局部复用 | Snippet + Building Block | Block/Web Block + Pattern | 数据绑定复用与纯视觉组合分层 |
| 视觉治理 | Atlas UI、布局和样式资产 | UI Framework、Theme、Style Guide | 令牌、主题、模式与页面职责分离 |
| 设计器形态 | 多文档、可停靠窗格、高密度 IDE | 统一生命周期 IDE | 主画布最大化，结构/属性/问题稳定停靠 |
| 移动策略 | 响应式与移动布局明确区分 | Reactive/Mobile 与响应式 UI 体系 | 共享业务模型，允许独立布局资产 |

## 截图证据

以下均为官方文档页面的本地归档。只有页面中实际嵌入的软件界面图，才可作为软件视觉事实。

| 文件 | 页面 | 证据用途 |
|---|---|---|
| `assets/commercial-designers/mendix/2026-07-11-studio-pro-overview.png` | Studio Pro Overview | 含官方标注的 IDE 全局分区及属性窗格截图，支持工作台视觉事实 |
| `assets/commercial-designers/mendix/2026-07-11-pages-studio-pro11.png` | Pages | 支持页面资源、组件分类和布局语义；页面网站本身不代表 IDE 视觉 |
| `assets/commercial-designers/mendix/2026-07-11-page-properties-studio-pro11.png` | Page | 支持页面级属性入口；需结合正文判断具体能力 |
| `assets/commercial-designers/outsystems/2026-07-11-o11-documentation-home.png` | O11 Documentation | 支持当前官方信息架构入口，不作为 Service Studio 截图 |
| `assets/commercial-designers/outsystems/2026-07-11-o11-user-interface.png` | O11 User Interface | 支持 UI 能力分类与复用层次，不作为像素级 IDE 视觉证据 |

## 当前官方来源

### Mendix

- Studio Pro 11 Overview：`https://docs.mendix.com/refguide/studio-pro-overview/`
- Pages：`https://docs.mendix.com/refguide/pages/`
- Page：`https://docs.mendix.com/refguide/page/`
- Layout Grid：`https://docs.mendix.com/refguide/layout-grid/`
- Atlas UI：`https://docs.mendix.com/refguide/atlas-ui/`

### OutSystems

- O11 Documentation：`https://success.outsystems.com/documentation/11/`
- Building apps：`https://success.outsystems.com/documentation/11/building_apps/`
- User Interface：`https://success.outsystems.com/documentation/11/building_apps/user_interface/`
- OutSystems UI：`https://outsystemsui.outsystems.com/`
- Data Grid：`https://www.outsystems.com/forge/component-overview/9764/outsystems-data-grid/`

## 链接维护记录

- `https://docs.mendix.com/refguide/page-editor/` 于 2026-07-11 返回 404，不再作为来源；使用 `pages/`、`page/` 和当前导航中的 `Properties Common in the Page Editor` 入口代替。
- `https://success.outsystems.com/documentation/11/developing_apps/` 于 2026-07-11 跳转 Not Found；当前入口为 `documentation/11/building_apps/`。

## 结论置信度

- 已确认（高）：两款产品都把表单页面置于数据、逻辑、复用资产和生命周期共同构成的 IDE 中；模板、复用块和视觉治理并非同一个抽象。
- 已确认（高）：Mendix Studio Pro 11 的全局工作台分区和高密度属性窗格有当前官方截图支持。
- 高度怀疑（中）：OutSystems 11 当前 Service Studio 仍采用模块树、中央编辑区、属性/问题区的典型 IDE 布局；本轮缺少足够清晰的当前官方全景图，不能写成像素级事实。
- 未知：两款产品在同一复杂基础资料、单据和动态表单样本上的任务效率及大规模树/表性能。
