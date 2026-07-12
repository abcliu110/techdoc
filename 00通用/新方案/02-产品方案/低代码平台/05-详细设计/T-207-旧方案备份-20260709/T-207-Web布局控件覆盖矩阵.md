# T-207 Web 布局控件覆盖矩阵

> 日期：2026-07-09  
> 范围：T-207 PC Web 可视化页面设计器 LayoutEngine  
> 目标：覆盖复杂企业 Web 单据、工作台、表格、门户、浮层、响应式和特殊固定画布场景。

## 1. 定位：布局控件，不是布局模板

本矩阵描述的是设计器中可拖拽、可配置、可保存为 schema 的**布局控件**，不是整页示例模板。

布局控件必须具备以下设计时协议：

| 协议 | 要求 |
|---|---|
| 工具箱元数据 | 控件名称、图标、分类、默认尺寸、拖拽创建策略 |
| 控件边界 | 画布中必须显示选中边框、尺寸手柄、层级路径 |
| 插槽和投放区 | 明确 slot、dropZone、allowedChildren、maxDepth |
| 属性 Schema | 基础、布局、约束、响应式、权限、事件、校验 |
| 设计态 Overlay | 网格线、吸附线、插槽提示、错误提示、不可投放提示 |
| 运行时渲染器 | 同一 schema 必须可渲染为真实 PC Web 页面 |
| 校验规则 | 溢出、循环嵌套、不可达插槽、性能风险、权限冲突 |

常用页面布局，例如“左树右表”“单据头 + 明细表”“查询条件 + 列表 + 详情”，都应由这些布局控件组合出来，而不是固化为单一模板。

## 2. 覆盖原则

T-207 的布局能力不能只覆盖表单字段排版，而要覆盖 PC Web 页面能出现的主要布局形态：

1. **主体页面布局**：Grid、Dock、Split、Scroll、Sticky、Responsive。
2. **业务字段布局**：FormGrid、Stack、Flex、Tabs、Accordion。
3. **复杂业务区域**：MasterDetail、CardGrid、DashboardGrid、Wizard、Timeline、Kanban。
4. **浮层和弹出布局**：Portal、Drawer、Dialog、Popover、ContextMenu。
5. **特殊边界场景**：AbsoluteCanvas、PrintFixedCanvas、MicroFrontendSlot、Masonry。

默认页面主体禁止自由绝对定位；绝对定位只允许在套打、图纸标注、浮层、Portal、特殊白名单场景中使用。

## 3. P0 必须实现

| 控件 | 用途 | 必须能力 |
|---|---|---|
| GridContainer | 页面主网格布局 | areas、columns、rows、gap、minmax、断点覆盖 |
| FormGridContainer | 业务字段排版 | 12/24 列、labelWidth、字段 span、必录和错误标记 |
| FlexContainer | 按钮/标签/工具条 | wrap、gap、justify、align、grow/shrink |
| DockContainer | 应用骨架 | top/left/right/bottom/fill、折叠、尺寸约束 |
| SplitContainer | 左右/上下分割 | 拖拽手柄、比例、min/max、折叠 |
| ScrollContainer | 局部滚动 | overflow、maxHeight、scrollShadow、焦点滚动 |
| StickyContainer | 固定区域 | top/bottom/thead/actionbar、zIndex、容器绑定 |
| TabsContainer | 页签区域 | lazy、权限隐藏、错误标记、内部滚动 |
| PortalContainer | 浮层根 | zIndex、anchor、boundary、focus trap |
| ResponsiveContainer | PC 断点预览 | 1280/1440/1600/1920、断点规则检查 |
| MasterDetailContainer | 主从页面 | masterKey、detailTemplate、lazyLoad、权限上下文 |

## 4. P1 应实现

| 控件 | 用途 | 说明 |
|---|---|---|
| StackContainer | 纵向分组 | 详情页、设置页、普通纵向区块 |
| AccordionContainer | 长表单分组 | 用于高级条件、折叠字段区 |
| CardGridContainer | 摘要卡片 | 指标、附件、审批摘要、客户画像 |
| DrawerContainer | 侧边详情 | 右侧抽屉、筛选、高级设置 |
| DialogContainer | 弹窗 | 编辑、选择、确认、批量操作 |
| WizardStepsContainer | 分步录入 | 用于审批发起、复杂向导 |
| DashboardGrid | 工作台面板 | 拖拽、resize、网格占位 |
| Popover / ContextMenu | 锚点浮层 | 字段帮助、列菜单、右键菜单 |
| Timeline | 时间轴 | 审批、物流、变更记录 |
| MicroFrontendSlot | 插件槽位 | BI、外部应用、第三方组件 |

## 5. P2 特殊场景

| 控件 | 用途 | 限制 |
|---|---|---|
| AbsoluteCanvas | 绝对定位画布 | 禁止用于主体 Web 页面，只能白名单使用 |
| PrintFixedCanvas | 套打/打印 | 使用 mm/px 固定坐标，服务打印模板 |
| Masonry / Waterfall | 瀑布流 | 适合附件/图片/知识卡，不适合严肃表单主体 |
| KanbanBoard | 看板 | 适合任务、商机、项目，不作为通用单据主体 |

## 6. 当前原型覆盖

`T-207-Web布局控件原型库.html` 当前已经按控件级方式展示 16 个布局控件：

| 序号 | 控件 | 优先级 | 原型表达 |
|---|---|---|---|
| 01 | GridContainer | P0 | 工具箱入口、命名区域插槽、主投放区、网格属性 |
| 02 | FormGridContainer | P0 | 业务字段网格、label/editor 结构、字段 span |
| 03 | FlexContainer | P0 | 工具条/按钮流、wrap、gap、grow/shrink |
| 04 | DockContainer | P0 | top/left/right/bottom/fill 五区停靠 |
| 05 | SplitContainer | P0 | 双面板分割、拖拽条、最小宽度 |
| 06 | ScrollContainer | P0 | 局部滚动、滚动体、滚动条设计态 |
| 07 | StickyContainer | P0 | 顶部/底部固定区域、滚动内容 |
| 08 | TabsContainer | P0 | TabPanel 插槽、权限隐藏、错误标记 |
| 09 | PortalContainer | P0 | 浮层根、锚点、zIndex、边界避让 |
| 10 | ResponsiveContainer | P0 | 1280/1440/1600 PC 断点规则 |
| 11 | StackContainer | P1 | 纵向 section 插槽、长表单分组 |
| 12 | AccordionContainer | P1 | 折叠项、展开状态、懒渲染 |
| 13 | CardGridContainer | P1 | 卡片项网格、卡片 header/body/action |
| 14 | DrawerContainer | P1 | 侧边抽屉、header/body/footer、尺寸约束 |
| 15 | DialogContainer | P1 | 模态弹窗、遮罩、焦点边界、底部动作 |
| 16 | MasterDetailContainer | P0 | master/detail 插槽、上下文传递、可嵌套主从 |

## 7. LayoutEngine 统一能力

所有布局控件应纳入同一套 LayoutEngine：

```text
LayoutControl
  -> toolbox metadata
  -> slots / allowedChildren
  -> design-time overlay
  -> runtime renderer
  -> property schema
  -> responsive rules
  -> validation rules
  -> permission visibility
  -> persistence
```

## 8. 设计器属性分组

每个布局控件右侧属性面板至少包含：

| 属性组 | 内容 |
|---|---|
| 基础 | id、name、caption、visible、disabled |
| 布局 | display、direction、columns、rows、gap、span、dock、overflow |
| 约束 | minWidth、maxWidth、height、maxHeight、resizable、collapsible |
| 响应式 | breakpoint overrides、collapse rules、column rules |
| 投放规则 | allowedChildren、dropZone、slot、maxDepth |
| 数据上下文 | dataScope、rowContext、parentContext |
| 权限 | visiblePolicy、editablePolicy、operationPolicy |
| 事件 | onMount、onResize、onDrop、onChange、onExpand |
| 校验 | layout warnings、overflow、required hidden、performance risk |

## 9. 常用布局由控件组合覆盖

| 场景 | 应由哪些控件覆盖 |
|---|---|
| 复杂单据页面 | GridContainer + FormGridContainer + EntryTable + StickyContainer |
| 单据头 + 分录 + 批次 + 序列号 | MasterDetailContainer + TabsContainer + TableEngine |
| 左导航 + 主内容 + 右摘要 | DockContainer / GridContainer |
| 查询条件 + 列表 + 详情 | SplitContainer + FormGridContainer + Table |
| 工作台/门户 | DashboardGrid + CardGrid + MicroFrontendSlot |
| 长表单 | StackContainer + AccordionContainer + ScrollContainer |
| 审批/物流轨迹 | Timeline |
| 弹窗编辑 | PortalContainer + DialogContainer + FormGridContainer |
| 侧边详情 | DrawerContainer |
| 表格列菜单 | Popover / ContextMenu |
| PC 多分辨率 | ResponsiveContainer |
| 打印套打 | PrintFixedCanvas |
| 图纸/标签标注 | AbsoluteCanvas |

## 10. 原型文件

布局控件原型库：

```text
D:\mywork\techdoc\00业务文档\系统设计\新方案\02-产品方案\低代码平台\05-详细设计\T-207-Web布局控件原型库.html
```
