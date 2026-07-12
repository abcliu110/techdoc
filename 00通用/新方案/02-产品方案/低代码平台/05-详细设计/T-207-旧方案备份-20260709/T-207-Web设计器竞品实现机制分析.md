# T-207 Web 设计器竞品实现机制分析

> 范围：AG Grid、DevExpress、Kendo/Telerik、Syncfusion、Sencha Ext JS、Wijmo、Handsontable  
> 日期：2026-07-08  
> 用途：分析成熟商业 Web UI/Grid 产品如何支撑“设计器化”，并沉淀为 T-207 Web 表单设计器、布局容器设计器、强表格控件的设计依据。

---

## 1. 核心结论

这些产品可以分成两类：

| 类型 | 产品 | 本质 |
|---|---|---|
| 真正有 Web 设计器形态 | DevExpress Web Report Designer、Telerik Web Report Designer、Syncfusion Report Designer、Sencha Architect/Rapid Ext JS | 有设计画布、工具箱、字段/组件树、属性面板、结构大纲、预览/发布机制 |
| 强运行组件，可被设计器驱动 | AG Grid、DevExtreme DataGrid、Kendo Grid、Syncfusion Grid、Sencha Grid、Wijmo FlexGrid、Handsontable | 本身不是表单设计器，但通过配置模型、插件、列定义、数据源、模板和状态 API 支撑设计器生成 |

T-207 应采用混合路线：

1. **设计器壳层学习 DevExpress/Telerik/Syncfusion/Sencha**：Toolbox、Field List、Explorer、Property Grid、Design Surface、Preview、Analyzer。
2. **表格运行内核学习 DevExpress + AG Grid**：Master-Detail、Nested Grid、Detail Template、独立 Detail Grid、列模型、虚拟滚动、状态保存。
3. **布局容器学习 Sencha + Syncfusion Dashboard Layout**：组件树、layout manager、dock/grid/flex、拖放、resize、响应式。
4. **单元格编辑学习 Handsontable/Wijmo**：Excel-like 键盘录入、复制粘贴、自定义 editor、公式和数据映射。
5. **属性和状态持久化统一到 T-207 Schema**：PageSchema、LayoutSchema、ComponentRegistry、TableSchema、ColumnSchema、PermissionOverlay、RuleSet。

---

## 2. 产品逐项分析

### 2.1 DevExpress

DevExpress 是 T-207 设计器形态的首选参考。

证据：

- Web Report Designer 明确是可集成到 Web 应用中的客户端设计工具，支持创建和编辑报表，并内置预览、打印、导出。
- Web Report Designer 的界面元素包括 Design Surface、Field List、Main Menu、Main Toolbar、Properties Panel、Query Builder、Report Explorer、Toolbox、Report Design Analyzer。
- Toolbox 允许拖控件到设计面；Field List 支持从数据源拖字段到设计面形成绑定控件；Properties Panel 支持按分类/字母显示属性、属性说明、嵌套属性、表达式编辑。
- DevExtreme DataGrid 支持 masterDetail.enabled 和 template，detail section 可放另一个 DataGrid。

实现机制：

| 机制 | DevExpress 做法 | T-207 吸收 |
|---|---|---|
| 设计器壳层 | Design Surface + Toolbox + Field List + Report Explorer + Properties Panel | FormDesignerShell 五区工作台 |
| 数据绑定 | 字段从 Field List 拖到设计面生成绑定控件 | BO 字段树拖入生成 FieldNode/TableColumn |
| 属性系统 | 属性面板支持分类、说明、嵌套属性、表达式 | PropertyInspector 支持业务/布局/表格/规则/权限 |
| 结构树 | Report Explorer 显示层级结构并可定位控件 | 页面大纲显示 LayoutNode/TableNode/FieldNode |
| 分析器 | Report Design Analyzer 发现设计问题 | Layout/Table/Permission/Publish Analyzer |
| Master-Detail | DataGrid detail template 中放子 DataGrid | TableEngine 支持 detailGrid/detailTabs |

结论：T-207 的设计器 UI 应以 DevExpress Web Report Designer 的结构为主参考，但对象从“报表控件”换成“PC Web 业务页面组件”。

### 2.2 AG Grid

AG Grid 不是 Web 表单设计器，但它是强表格运行内核的重要参考。

证据：

- AG Grid 用 `columnDefs` 定义列，用 Grid Options 配置表格能力。
- Side Bar 是 Tool Panels 容器，可配置 Columns/Filters 或自定义 Tool Panel。
- Master/Detail 中，顶层 Master Grid 展开后显示 Detail Grid。
- Nested Master/Detail 支持把 Detail Grid 继续配置成 Master Grid。
- Grid API 提供 `getState()` / `setState()` 用于保存和恢复状态。

实现机制：

| 机制 | AG Grid 做法 | T-207 吸收 |
|---|---|---|
| 配置模型 | columnDefs + gridOptions | TableSchema + ColumnSchema + tableOptions |
| 工具面板 | Side Bar + Tool Panels | Table Designer 的列面板、过滤面板、分组面板 |
| 嵌套表格 | Detail Grid 是完整 grid instance | detailTable 也是完整 TableNode |
| 状态保存 | Grid State 保存列、过滤、排序等状态 | TableState 保存列宽、顺序、冻结、过滤、展开状态 |
| 扩展点 | custom cell renderer/editor、detail renderer | CellRenderer/CellEditor/DetailRenderer 注册表 |

结论：AG Grid 的价值在于“配置驱动的企业级表格引擎”，不是设计器壳。T-207 应借鉴其 TableEngine 抽象。

### 2.3 Kendo / Telerik

Kendo Grid 是强运行组件，Telerik Reporting 提供真实 Web 设计器。

证据：

- Kendo Grid 支持分页、排序、过滤、编辑、分组、层级、导出、搜索、冻结列、列菜单等。
- Kendo Hierarchy Grid 通过 `detailTemplate` 为每行创建子 grid。
- Telerik Web Report Designer 提供 Components、Explorer、属性配置和 Web 设计环境；在线 demo 描述其具备拖放布局和 re-parent 能力。

实现机制：

| 机制 | Kendo/Telerik 做法 | T-207 吸收 |
|---|---|---|
| Grid 配置 | DataSource + Grid options + templates | 表格数据源和列模板配置 |
| 层级表格 | detailTemplate 生成子 grid | detailTemplate 支持表格/表单/页签 |
| 列菜单 | show/hide/filter/sort 列菜单 | 表格列右键菜单 |
| 设计器 | Web Report Designer 的 Components/Explorer/Property | 组件库、大纲树、属性面板 |
| 报表生命周期 | 设计、预览、导出 | 设计、预览、发布、运行 |

结论：Telerik 的设计器结构很适合做 T-207 的“设计器体验参考”，Kendo Grid 则适合补充列菜单、过滤、导出、层级模板。

### 2.4 Syncfusion

Syncfusion 的特点是产品面很全：Grid、Report Designer、Dashboard Layout 都有可吸收点。

证据：

- EJ2 Grid 支持 Hierarchy Grid、Column Chooser、虚拟滚动和列虚拟化。
- Syncfusion JavaScript DataGrid 提供数据绑定、编辑、过滤、排序、聚合、选择、Excel/CSV/PDF 导出。
- Dashboard Layout 支持面板拖拽、重排、resize，并把面板放入 grid arrangement。
- HTML5 JavaScript Report Designer 是基于 Web 的 RDL 报表设计器，支持参数、表达式、排序、分组、过滤、报表链接等。

实现机制：

| 机制 | Syncfusion 做法 | T-207 吸收 |
|---|---|---|
| 层级表格 | childGrid / Hierarchy Grid | TableNode.children/detailTables |
| 性能 | row/column virtualization | 表格行列虚拟化 |
| 列管理 | Column Chooser | 列显隐与列属性面板 |
| Dashboard Layout | grid 结构内拖拽和 resize | Web 布局容器设计器的 panel/grid 容器 |
| Report Designer | Web 报表设计、表达式、分组、过滤 | 规则/表达式/数据源设计面板 |

结论：Syncfusion 的 Dashboard Layout 对 T-207 的 Web 布局容器设计尤其有启发：它把拖拽、resize、grid 排列、面板持久化统一成布局组件。

### 2.5 Sencha Ext JS

Sencha 是“企业 Web 应用框架 + 视觉构建器”的重要参考，尤其适合布局容器和组件元数据。

证据：

- Sencha Architect 是 Ext JS 的可视化应用构建器，提供拖放环境，并能看到用户最终看到的界面。
- Ext JS Grid 由 Store 和 Columns 两部分组成，适合大量数据的显示、排序、过滤。
- Ext JS RowWidget 插件可在展开行中放置 widget，并将该 widget 绑定到当前记录。
- Ext.grid.property.Grid 模仿传统 IDE 属性窗，每一行代表一个属性。
- Ext JS 有布局、容器、组件、数据包、拖放、主题等完整体系。

实现机制：

| 机制 | Sencha 做法 | T-207 吸收 |
|---|---|---|
| 组件模型 | xtype/config/class system | componentKey/propsSchema/registry |
| 设计器 | Architect/Rapid drag-and-drop | 可视化拖放工作台 |
| 布局系统 | Containers + Layout Managers | Grid/Flex/Dock/Split/Scroll 容器 |
| 数据层 | Store 解耦 UI 和数据 | DataSource/BO/ViewModel 分离 |
| 属性窗 | Property Grid 模仿 IDE | 企业属性面板 |
| 行展开 | RowWidget 可放任意 widget | detail row 可放子表、表单、卡片 |

结论：Sencha 对 T-207 最重要的不是 Grid，而是“组件体系 + 布局管理器 + 属性窗 + 可视化构建器”的组合。

### 2.6 Wijmo

Wijmo 的价值在于轻量、灵活、Excel-like 的 FlexGrid 和 OLAP/Pivot 模型。

证据：

- FlexGrid 支持 TreeGrid，通过 `childItemsPath` 显示层级数据。
- FlexGrid 支持 Master/Detail 和 RowDetail，可以在行内嵌套明细。
- Column Picker 可用 grid.columns、ListBox、showPopup/hidePopup 实现。
- FlexGrid 支持 Excel-like 单元格编辑；输入、F2、双击进入不同编辑模式。
- PivotGrid 基于 PivotEngine，支持层级行列头、折叠分组、钻取单元格、字段属性上下文菜单。

实现机制：

| 机制 | Wijmo 做法 | T-207 吸收 |
|---|---|---|
| 轻量列模型 | Column 对象含宽度、最小宽度、必填、可见等属性 | ColumnSchema 细粒度属性 |
| TreeGrid | childItemsPath | 同构层级数据表格 |
| Master/Detail | 选择主项后显示明细或 RowDetail | 行展开 detail panel |
| Column Picker | Popup + ListBox 管理列显隐 | 列选择器 |
| OLAP | PivotEngine + PivotGrid | P2 报表/透视能力预留 |

结论：Wijmo 适合吸收“轻量配置 + Excel-like 编辑 + TreeGrid + Column Picker”，但不作为 T-207 主设计器参考。

### 2.7 Handsontable

Handsontable 更像可嵌入的电子表格控件，不是 Web 表单设计器。

证据：

- 官方定位强调 Excel-like、公式、键盘快捷键、复制粘贴、撤销重做、快速编辑、行列操作、自定义 renderer/editor。
- Nested Rows 插件通过行头 +/- 展开折叠父子行，子行缩进显示。
- Nested Headers 支持多级列头和 collapsible columns。
- Cell Editor 允许自定义 editor，EditorManager 管理打开、保存等生命周期。
- Handsontable cell type 可在弹出编辑器中嵌入第二个 Handsontable 实例，即 HOT-in-HOT。
- 官方文档曾提示 Nested Rows 的父子结构下排序和过滤不工作，说明其嵌套能力不适合作为复杂企业 Master-Detail 的主参考。

实现机制：

| 机制 | Handsontable 做法 | T-207 吸收 |
|---|---|---|
| 单元格编辑 | EditorManager + BaseEditor | CellEditor 生命周期 |
| 电子表格体验 | 快速编辑、复制粘贴、撤销重做、公式 | 分录高效录入体验 |
| 嵌套行 | NestedRows 插件 | 简单树形行，不作为复杂子表主方案 |
| 多级表头 | NestedHeaders + CollapsibleColumns | 列组和折叠列 |
| HOT-in-HOT | 单元格编辑器里嵌套表格 | 参照选择/大数据选择弹窗 |

结论：Handsontable 适合吸收“录入体验”，不适合主导 T-207 的业务页面设计器和复杂母子表架构。

---

## 3. 共性实现模式

### 3.1 设计器壳层

成熟设计器通常包含：

| UI 区域 | 作用 | T-207 对应 |
|---|---|---|
| Toolbox / Components | 可拖入的控件或组件 | 左侧控件库、布局容器、表格组件 |
| Field List / Data Source | 可绑定的数据字段 | BO 字段树、子表、关系字段 |
| Design Surface | 可视化编辑画布 | RuntimeRenderer + DesignerOverlay |
| Explorer / Outline | 结构树 | PageSchema 大纲、Table Level 树 |
| Properties Panel | 当前选中对象属性 | PropertyInspector |
| Preview | 运行态预览 | Runtime Preview |
| Analyzer | 设计问题诊断 | 保存/发布校验、影响分析 |

### 3.2 运行组件配置化

成熟 Grid 产品几乎都不是靠“拖出 DOM”，而是靠配置模型驱动：

| 配置对象 | 典型产品 | T-207 对应 |
|---|---|---|
| gridOptions / columnDefs | AG Grid | TableSchema / ColumnSchema |
| masterDetail / detailTemplate | DevExtreme / Kendo | DetailSchema |
| childGrid / childItemsPath | Syncfusion / Wijmo | childTables / treeBinding |
| plugins / modules | AG Grid / Handsontable / Ext JS | feature modules |
| state APIs | AG Grid / Kendo / Wijmo | DesignState / RuntimeState |

### 3.3 元数据驱动属性面板

属性面板不是硬编码表单，而是由组件元数据生成：

```text
ComponentRegistry
  -> propsSchema
  -> property editors
  -> validation rules
  -> serialization
  -> runtime renderer
```

T-207 必须让布局容器、字段控件、表格列、单元格编辑器、detail panel 都进入同一套元数据系统。

---

## 4. T-207 目标架构吸收

### 4.1 设计器 Shell

采用 DevExpress/Telerik/Sencha 的结构：

```text
Top Command Bar
Left: Layout Containers / BO Fields / Components / Table Widgets / Outline
Center: RuntimeRenderer Design Surface + Overlay
Right: Properties / Layout / Table / Rules / Permission / Performance
Bottom: Breadcrumb / selected node / validation / zoom
```

### 4.2 LayoutEngine

吸收 Sencha + Syncfusion Dashboard Layout：

| 能力 | 设计 |
|---|---|
| container registry | Grid、Flex、Dock、Split、Scroll、Sticky、Tabs、Portal |
| drop rules | 每个容器声明可接受子节点 |
| layout-to-css | Schema 编译为 CSS Grid/Flex/Dock |
| overlay coordinate | 从真实 DOM 读坐标绘制选中框 |
| responsive | 1280/1440/1600/1920 断点 |
| persistence | 保存布局 schema 和用户运行态布局状态 |

### 4.3 TableEngine

以 DevExpress + AG Grid 为主，补充 Kendo/Syncfusion/Wijmo/Handsontable：

| 能力 | 参考 | T-207 设计 |
|---|---|---|
| Master-Detail | DevExpress、AG Grid、Kendo、Syncfusion | detailTable/detailTabs/detailForm |
| 多层嵌套 | AG Grid nesting、DevExpress master-detail | 默认 2 层，最多 3 层需风险确认 |
| 列定义 | AG Grid/Wijmo | ColumnSchema |
| 列菜单/列选择 | Kendo/Syncfusion/Wijmo | Column Chooser + Column Property |
| 虚拟滚动 | AG Grid/Syncfusion/Wijmo | row/column virtualization |
| 单元格编辑 | Handsontable/Wijmo | CellEditor 生命周期、键盘录入、复制粘贴 |
| 行内 widget | Sencha RowWidget | detail row 可放 widget/table/form/card |
| 状态持久化 | AG Grid | TableState |

### 4.4 ComponentRegistry

吸收 Sencha xtype/config 和 DevExpress Toolbox：

```json
{
  "componentKey": "SplitPane",
  "category": "layout",
  "propsSchema": {
    "layout": ["direction", "primarySize", "minSize", "maxSize"],
    "behavior": ["resizable", "collapsible"],
    "permission": ["visiblePolicy"]
  },
  "allowedChildren": ["Section", "FormGrid", "EditableTable", "Tabs"]
}
```

---

## 5. 对 T-207 的明确取舍

| 取舍 | 决策 |
|---|---|
| 主设计器形态 | 参考 DevExpress Web Report Designer + Visual Studio Form Designer |
| 主表格架构 | 参考 DevExpress master-detail + AG Grid nested detail grid |
| 布局容器 | 参考 Sencha Layout/Container + Syncfusion Dashboard Layout |
| 单元格录入 | 参考 Handsontable/Wijmo 的 Excel-like 编辑 |
| 列管理 | 参考 AG Grid/Kendo/Syncfusion/Wijmo |
| 设计器持久化 | 不存 DOM，存 PageSchema/LayoutSchema/TableSchema |
| 嵌套深度 | 默认 2 层，最多 3 层，禁止无限嵌套 |
| 绝对定位 | 只用于 overlay、浮层、套打，不用于页面主体 |
| 第三方依赖 | 可参考设计，不直接绑定某个商业控件作为核心架构 |

---

## 6. 参考来源

| 产品 | 关键资料 |
|---|---|
| DevExpress Web Report Designer | https://docs.devexpress.com/XtraReports/119176/web-reporting/web-end-user-report-designer |
| DevExpress Interface Elements | https://docs.devexpress.com/XtraReports/17545/web-reporting/end-user-report-designer-for-web/interface-elements |
| DevExpress Properties Panel | https://docs.devexpress.com/XtraReports/17563/web-reporting/end-user-report-designer-for-web/interface-elements/properties-panel |
| DevExpress Field List | https://docs.devexpress.com/XtraReports/17567/web-reporting/end-user-report-designer-for-web/interface-elements/field-list |
| DevExpress Toolbox | https://docs.devexpress.com/XtraReports/17559/web-reporting/end-user-report-designer-for-web/interface-elements/toolbox |
| AG Grid Master/Detail | https://www.ag-grid.com/javascript-data-grid/master-detail/ |
| AG Grid Nesting | https://www.ag-grid.com/javascript-data-grid/master-detail-nesting/ |
| AG Grid Side Bar | https://www.ag-grid.com/javascript-data-grid/side-bar/ |
| AG Grid Column Definitions | https://www.ag-grid.com/javascript-data-grid/column-definitions/ |
| Kendo Grid Overview | https://demos.telerik.com/kendo-ui/grid/index |
| Kendo Hierarchy Grid | https://demos.telerik.com/kendo-ui/grid/hierarchy |
| Telerik Web Report Designer | https://www.telerik.com/products/reporting/documentation/designing-reports/report-designer-tools/web-report-designer/overview |
| Syncfusion Hierarchy Grid | https://ej2.syncfusion.com/javascript/documentation/grid/hierarchy-grid |
| Syncfusion Virtual Scrolling | https://ej2.syncfusion.com/javascript/documentation/grid/scrolling/virtual-scrolling |
| Syncfusion Dashboard Layout Drag | https://blazor.syncfusion.com/documentation/dashboard-layout/interaction-with-panels/dragging-moving-of-panels |
| Syncfusion Dashboard Layout Resize | https://blazor.syncfusion.com/documentation/dashboard-layout/interaction-with-panels/resizing-of-panels |
| Sencha Architect | https://www.sencha.com/products/architect/ |
| Sencha Ext JS RowWidget | https://docs.sencha.com/extjs/6.2.0/classic/Ext.grid.plugin.RowWidget.html |
| Sencha Widget Column | https://docs.sencha.com/extjs/6.0.2/guides/components/widgets_widgets_columns.html |
| Sencha Property Grid | https://docs.sencha.com/extjs/4.2.4/extjs-build/docs/index.html#!/api/Ext.grid.property.Grid |
| Wijmo TreeGrid | https://developer.mescius.com/wijmo/docs/Topics/Grid/TreeGrid/TreeGrid-Using-ChildItemsPath |
| Wijmo Master Detail | https://developer.mescius.com/wijmo/flexgrid-javascript-data-grid/master-detail |
| Wijmo Editing | https://developer.mescius.com/wijmo/demos/Grid/Editing/Overview/purejs |
| Handsontable Nested Rows | https://handsontable.com/docs/javascript-data-grid/row-parent-child/ |
| Handsontable Nested Headers | https://handsontable.com/docs/javascript-data-grid/column-groups/ |
| Handsontable Cell Editor | https://handsontable.com/docs/javascript-data-grid/cell-editor/ |
| Handsontable HOT-in-HOT | https://handsontable.com/docs/javascript-data-grid/handsontable-cell-type/ |

