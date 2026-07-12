# T-207 全新表单设计器：Web布局引擎设计

> 状态：v0.3
> 日期：2026-07-09
> 上游依据：
> - `../00-参考产品拆解/T-207-全新表单设计器-商业产品参考研究.md`
> - `../01-产品定位与范围/T-207-全新表单设计器-产品定位与范围.md`
> - `../02-信息架构与工作台/T-207-全新表单设计器-工作台信息架构.md`

---

## 1. 设计目标

Web 布局引擎要回答一个核心问题：

```text
设计器如何用可配置、可分析、可发布的 Schema，
表达真实 PC Web 企业页面的复杂布局能力。
```

T-207 的布局引擎不是"常用布局模板库"，也不是报表式绝对坐标画布。它必须支撑实施顾问在可见即可得画布上设计复杂单据、主数据维护页、审批页和业务工作台。

布局引擎必须做到：

1. 能表达真实 Web 页面结构，而不是静态示意图。
2. 能被 RuntimeRenderer 同源渲染，设计态、预览态、运行态一致。
3. 能被 DesignerOverlay 测量、选中、拖放、吸附、调整。
4. 能被 Analyzer 检查溢出、遮挡、断点问题和非法嵌套。
5. 能把布局能力封装成布局控件，而不是让用户直接编辑任意 CSS。
6. 能提供稳定抓手和测试契约，让自动测试平台可以模拟人点击、拖拽和调整布局。

---

## 2. 核心定位

### 2.1 布局引擎是什么

| 定义 | 说明 |
|---|---|
| Schema 驱动布局引擎 | 布局由 LayoutSchema 描述，运行时解释渲染 |
| PC Web 企业布局系统 | 第一阶段聚焦 1280 / 1440 / 1600 / 1920 桌面断点 |
| 布局控件体系 | PageRoot、GridLayout、FlexLayout、Section、Tabs、SplitPane、ScrollContainer、StickyBar |
| 设计态测量系统 | 从真实 DOM 读取尺寸，Overlay 只画辅助层 |
| 自动化可操作系统 | 每个可选中、可拖拽、可调整对象都有稳定抓手 |
| 发布前治理能力 | Analyzer 在设计期发现布局风险 |

### 2.2 布局引擎不是什么

| 非目标 | 原因 |
|---|---|
| 报表设计器 | 不使用毫米、纸张、Band、绝对坐标作为页面主体 |
| 营销网站编辑器 | 不追求 Webflow 式完全视觉自由度和动画 |
| 任意 CSS 编辑器 | 企业实施需要受控属性、可分析 Schema 和统一视觉 |
| 移动端布局设计器 | P0 聚焦 PC Web，移动端放 P2 |
| 自由绝对定位画布 | 容易造成遮挡、错位、不可响应、不可治理 |

---

## 3. 设计原则

### 3.1 真实 Web 优先

中央画布渲染真实 DOM，布局使用浏览器原生能力：

| Web 能力 | T-207 映射 |
|---|---|
| CSS Grid | GridLayout |
| CSS Flexbox | FlexLayout |
| Block / Flow | Section、PageRoot |
| Overflow / Scroll | ScrollContainer |
| Position Sticky | StickyBar |
| Resizable Pane | SplitPane |
| Tab Region | Tabs |

#### CSS 属性映射表

| T-207 属性 | CSS 属性 | 说明 |
|------------|---------|------|
| GridLayout.columns | grid-template-columns | 固定列数 |
| Field.layout.span | grid-column | 字段占列数 |
| FlexLayout.direction | flex-direction | row / column |
| FlexLayout.wrap | flex-wrap | wrap / nowrap |
| FlexLayout.gap | gap | 间距 Token |
| FlexLayout.align | align-items | 交叉轴对齐 |
| FlexLayout.justify | justify-content | 主轴对齐 |
| ScrollContainer.overflowY | overflow-y | auto / hidden |
| StickyBar.position | position: sticky | top / bottom |

### 3.2 Schema 优先

用户编辑的是 Schema，不是 DOM 和 CSS 字符串。

```text
LayoutSchema
  -> LayoutEngine normalize / validate
  -> RuntimeRenderer render
  -> DOM measurement
  -> DesignerOverlay draw
```

### 3.3 容器优先

复杂页面不是由字段平铺而成，而是由容器嵌套形成稳定结构：

```text
PageRoot
  -> StickyBar
  -> SplitPane
    -> MainContent
      -> Section
        -> GridLayout
          -> Field
      -> EntryTable
    -> RightAssistPanel
  -> StickyBar
```

### 3.4 企业约束优先

布局能力必须足够强，但不能失控：

| 约束 | 说明 |
|---|---|
| 不开放任意 CSS | 只开放可治理属性 |
| 不开放主体绝对定位 | 防止页面失去响应和可维护性 |
| 不允许非法嵌套 | 例如 StickyBar 不能随意放在字段内 |
| 不允许无限层级 | 嵌套深度由 Analyzer 控制 |
| 不允许断点漂移 | 断点差异必须可解释 |

### 3.5 设计态和运行态同源

设计态不使用一套"假布局"。DesignerOverlay 只负责辅助层：

| 层 | 职责 |
|---|---|
| RuntimeRenderer | 渲染真实页面 |
| LayoutEngine | 解释 LayoutSchema 并生成布局属性 |
| MeasurementService | 读取真实 DOM rect |
| DesignerOverlay | 绘制选中框、投放点、吸附线、尺寸提示 |

### 3.6 自动化测试优先

设计器必须从 P0 开始内建可测试性。自动测试平台应能像人一样完成以下操作：

1. 点击画布节点并验证选中状态。
2. 从左侧资源区拖入字段、容器和表格。
3. 拖动字段 span 抓手调整 Grid 宽度。
4. 拖动 SplitPane 分隔线调整左右区域。
5. 拖动 StickyBar 高度抓手调整固定区高度。
6. 点击 Analyzer 问题并定位到画布节点。
7. 校验每次交互后的 Schema diff 和视觉状态。

这要求设计器的所有关键交互点都具备稳定的 DOM 标识、明确的命中区域和可回放的命令结果。

---

## 4. P0 / P1 / P2 边界

### 4.1 P0 布局能力

P0 必须覆盖企业 PC Web 单据的主要布局能力。

| 能力 | P0 |
|---|---|
| PageRoot | 是 |
| GridLayout | 是 |
| FlexLayout | 是 |
| Section | 是 |
| Tabs | 是 |
| SplitPane | 是 |
| ScrollContainer | 是 |
| StickyBar | 是 |
| 企业断点 | 1280 / 1440 / 1600 / 1920 |
| 设计态拖放 | 单节点拖入合法容器；同父容器内重排 |
| 字段 span 调整 | 是 |
| 容器尺寸调整 | SplitPane、ScrollContainer、StickyBar 支持 |
| 表格列宽调整 | 由 TableEngine 承担，Overlay 复用测量能力 |
| Analyzer 布局校验 | 溢出、非法嵌套、Sticky 冲突、Scroll 冲突 |

### 4.2 P1 布局能力

| 能力 | P1 |
|---|---|
| DockLayout | 停靠式布局，适合复杂工作台 |
| Portal / Drawer / Modal 容器 | 弹层、抽屉、浮层承载 |
| 拖拽跨容器移动 | 大纲和画布跨容器重排 |
| 多选和批量布局操作 | 批量设置 span、gap、padding |
| 断点差异配置 | 不同断点下独立调整列数、显示策略 |
| Layout Template | 保存容器组合为模板 |
| 复杂自适应策略 | 容器查询、条件显示、密度切换 |

### 4.3 P2 布局能力

| 能力 | P2 |
|---|---|
| 移动端布局 | 手机 / 平板专用布局 |
| 打印 / 套打布局 | 纸张、分页、打印区域 |
| 高级动画布局 | 展开动画、过渡动画、微交互编排 |
| AI 自动布局 | 根据业务对象和样例页面生成布局 |

### 4.4 明确禁止

| 禁止 | 阶段 | 原因 |
|---|---|---|
| 主体自由绝对定位 | P0/P1/P2 均禁止作为默认能力 | 不可维护、不可分析、不可响应 |
| 任意 CSS 文本输入 | P0 禁止 | 无法做 Analyzer 和视觉统一 |
| 用户直接改 DOM | P0/P1/P2 禁止 | 破坏 Schema 驱动 |
| 无限嵌套容器 | P0/P1/P2 禁止 | 性能和理解成本失控 |

---

## 5. 总体架构

### 5.1 引擎结构

```text
PageSchema
  └─ LayoutSchema
      ↓
SchemaNormalizer
  └─ LayoutNormalizer
      ↓
LayoutEngine
  ├─ LayoutRegistry
  ├─ BreakpointResolver
  ├─ DropRuleEngine
  ├─ SnaplineEngine
  ├─ ResizeCommandFactory
  ├─ InteractionHandleRegistry
  ├─ AutomationContract
  └─ LayoutAnalyzer
      ↓
RuntimeRenderer
      ↓
DOM
      ↓
MeasurementService
      ↓
DesignerOverlay
```

### 5.2 模块职责

| 模块 | 职责 | P0 |
|---|---|---|
| LayoutRegistry | 注册布局容器类型、默认属性、Inspector 配置 | 是 |
| LayoutNormalizer | 作为 SchemaNormalizer 的布局子模块，补齐布局默认值、清理非法属性、生成稳定结构 | 是 |
| BreakpointResolver | 根据当前断点计算有效布局属性 | 是 |
| DropRuleEngine | 判断拖入目标是否合法，生成投放位置 | 是 |
| SnaplineEngine | 计算吸附线、间距线、列线 | 是 |
| ResizeCommandFactory | 将拖拽尺寸变化转成 Schema 命令 | 是 |
| MeasurementService | 基于 DOMRect 测量真实位置和尺寸 | 是 |
| LayoutAnalyzer | 发现布局错误、警告和建议 | 是 |
| InteractionHandleRegistry | 注册可点击、可拖拽、可调整的设计态抓手 | 是 |
| AutomationContract | 暴露稳定测试标识、事件语义和 Schema 断言点 | 是 |

### 5.3 渲染链路

```text
用户修改属性
  -> CommandStack.execute(UpdateProp)
  -> SchemaStore 更新 LayoutSchema
  -> 增量 SchemaNormalizer 调用 LayoutNormalizer
  -> LayoutEngine validate + resolve breakpoint
  -> RuntimeRenderer 重渲染
  -> MeasurementService 读取 DOMRect
  -> DesignerOverlay 重新绘制选中框和吸附线
  -> Analyzer 增量检查
```

---

## 6. LayoutSchema 基础模型

### 6.1 通用节点结构

```json
{
  "id": "section_basic_info",
  "type": "Section",
  "name": "basicInfo",
  "title": "基本信息",
  "layout": {
    "padding": "md",
    "gap": "sm"
  },
  "constraints": {
    "minWidth": 480,
    "maxChildren": 80
  },
  "design": {
    "locked": false,
    "collapsedInOutline": false
  },
  "children": []
}
```

### 6.2 通用属性

| 属性 | 说明 | P0 |
|---|---|---|
| id | Schema 节点唯一 ID | 是 |
| type | 布局容器类型 | 是 |
| name | 技术名称 | 是 |
| title | 展示名称 | 是 |
| layout | 布局属性 | 是 |
| constraints | 约束属性 | 是 |
| design | 设计态属性 | 是 |
| children | 子节点 | 是 |

### 6.3 children 格式约定

Schema 的 `children` 字段有两种使用方式，含义不同：

| 形式 | 示例 | 含义 |
|------|------|------|
| 字符串 ID 引用 | `"children": ["field_customer", "field_bill_date"]` | 子节点已存在于 Schema 树顶层或作为独立节点，通过 ID 引用引用 |
| 内联对象 | `"children": [{ "id": "field_customer", "type": "Field", ... }]` | 子节点直接内联定义，未提升到顶层 |
| 混合 | `"children": ["field_customer", { "id": "field_new", "type": "Field", ... }]` | 混合引用和内联 |

**约定**：P0 允许内联对象和 ID 引用两种形式，但保存和发布前必须经过 SchemaNormalizer 归一化，其中 LayoutNormalizer 负责布局子树。运行时拿到的 PageSchema 必须以 `components.{nodeId}` 为权威节点命名空间，所有 ID 引用都能在同一 PageSchema 的 `components` 中解析。本文局部示例为突出布局结构，会混用 ID 引用和内联对象；实际持久化结构不得依赖 `layoutNodes` 或 `layout.children` 顶层路径。

### 6.4 设计态抓手元数据

每个可设计节点都必须声明设计态可操作能力，供 DesignerOverlay 和自动化测试平台共同使用。

```json
{
  "id": "field_customer",
  "type": "Field",
  "design": {
    "selectable": true,
    "draggable": true,
    "resizable": true,
    "handles": ["select", "drag", "resize-east", "parent"],
    "testId": "field-node-field_customer",
    "locked": false,
    "automationRole": "form-field"
  }
}
```

| 属性 | 说明 | P0 |
|---|---|---|
| selectable | 是否可选中 | 是 |
| draggable | 是否可拖拽 | 是 |
| resizable | 是否可调整尺寸 | 是 |
| handles | 节点可用抓手 | 是 |
| testId | 稳定测试 ID | 是 |
| locked | 锁定后不可拖拽和调整 | 是 |
| automationRole | 测试语义角色 | 是 |

### 6.5 受控样式 Token

布局不直接写任意 CSS，而使用受控 Token：

| Token | 示例 | 说明 |
|---|---|---|
| spacing | none / xs / sm / md / lg / xl | margin、padding、gap |
| size | auto / content / fill / fixed | 宽高语义 |
| density | compact / standard / relaxed | 企业页面密度 |
| border | none / subtle / strong | 区块边界 |
| background | page / section / muted / transparent | 背景语义 |
| zIndex | base / sticky / overlay | 层级语义 |

P0 不开放十六进制颜色、任意 box-shadow、任意 CSS class。视觉细节由设计系统统一提供。

#### Spacing Token 映射

| Token | 像素值 |
|-------|--------|
| none | 0px |
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |

### 6.6 通用约束

| 约束 | 默认 | 说明 |
|---|---|---|
| maxDepth | 8 | 页面布局容器最大嵌套深度 |
| maxChildren | 80 | 单容器最大子节点数 |
| minWidth | 0 | 容器最小宽度 |
| minHeight | 0 | 容器最小高度 |
| overflowX | hidden / auto | 横向溢出策略，由 ScrollContainer 统一控制 |
| overflowY | visible / auto / hidden | 纵向溢出策略，由 ScrollContainer 统一控制 |
| allowDrop | true | 是否允许拖入 |
| allowResize | false | 是否允许设计态调整尺寸 |

> **说明**：`overflowPolicy` 不作为独立约束存在。溢出行为由 ScrollContainer 的 `overflowX` / `overflowY` 属性统一建模；GridLayout 和 FlexLayout 自身的溢出由字段 span 和 wrap 属性控制，不单独暴露 overflow 属性。

### 6.7 性能约束

| 约束 | 值 | 说明 |
|------|---|------|
| 最大容器数量/页 | 100 | 仅统计布局容器，不含 Field、Button、TableColumn；超过需拆分页面 |
| 最大嵌套深度 | 8 | 超过 Analyzer 报错 |
| 单容器最大子节点 | 80 | 超过 Analyzer 警告 |

> **口径说明**：本文的“容器数量”是布局结构复杂度约束；《产品定位与范围》中的“单页最大组件数 200”是总节点约束。一个页面必须同时满足容器数 ≤ 100、总组件数 ≤ 200、单容器子节点 ≤ 80。

---

## 7. P0 布局控件设计

### 7.1 PageRoot

PageRoot 是页面根容器。每个页面只能有一个 PageRoot。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 单据页面 | 顶部标题、主体内容、底部操作 |
| 主数据页面 | 左右分栏、多页签、关联列表 |
| 审批页面 | 主表单、流程轨迹、审批动作 |
| 业务工作台 | 顶部筛选、主体看板、侧边辅助 |

#### Schema

```json
{
  "id": "page_sales_order",
  "type": "PageRoot",
  "layout": {
    "direction": "vertical",
    "width": "100%",
    "minWidth": 1280,
    "maxWidth": "none",
    "padding": "none",
    "background": "page"
  },
  "children": [
    "sticky_top_actions",
    "main_split",
    "sticky_bottom_actions"
  ]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| minWidth | 是 | 页面最小工作宽度，默认 1280 |
| maxWidth | 是 | 可选最大宽度，默认 none（不限） |
| density | 是 | compact / standard / relaxed |
| background | 是 | 页面背景 |
| defaultBreakpoint | 是 | 默认设计断点 |
| scrollMode | 是 | 页面滚动 / 局部滚动 |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| PAGE_ROOT_REQUIRED | Error | 页面必须有且只有一个 PageRoot |
| PAGE_MIN_WIDTH_INVALID | Error | P0 页面最小宽度不能低于 1280 |
| PAGE_CHILD_OVER_LIMIT | Warning | 直接子节点过多，建议用 Section 分组 |

---

### 7.2 GridLayout

GridLayout 是字段和表单区的核心布局控件，用于多列字段排布。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 单据头字段 | 客户、组织、日期、币别等多列字段 |
| 主数据基本信息 | 名称、编码、分类、状态等 |
| 查询条件区 | 多条件横向排列 |
| 审批信息区 | 只读字段多列展示 |

#### P0 能力

| 能力 | 说明 |
|---|---|
| 固定列数 | 2 / 3 / 4 / 6 / 8 / 12 |
| 字段 span | 字段可占 1 到 columns 列，跨行自动换行 |
| 自动换行 | 超过一行自动流到下一行 |
| 行列间距 | rowGap / columnGap |
| label 策略 | labelWidth、labelPosition |
| 最小宽度 | 字段不足宽时 Analyzer 提示 |

#### GridLayout 与 EntryTable 的区别

| 特性 | GridLayout | EntryTable |
|------|-----------|------------|
| 定位 | 表单字段多列排布 | 分录数据录入 |
| 子节点 / 列定义 | `children` 承载 Field | `columns` 承载 TableColumn |
| 数据绑定 | 绑定单条数据字段 | 绑定数据列表 |
| 编辑模式 | 单行编辑 | 多行编辑 |
| 行操作 | 无 | 新增、删除、复制行 |
| 汇总行 | 无 | 支持 |

#### Schema

```json
{
  "id": "grid_basic_info",
  "type": "GridLayout",
  "layout": {
    "columns": 4,
    "rowGap": "sm",
    "columnGap": "md",
    "autoFlow": "row",
    "labelWidth": 96,
    "labelPosition": "left"
  },
  "children": [
    {
      "id": "field_customer",
      "type": "Field",
      "layout": {
        "span": 2,
        "minWidth": 320
      }
    }
  ]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| columns | 是 | 网格列数，固定枚举：2 / 3 / 4 / 6 / 8 / 12 |
| rowGap | 是 | 行间距，使用 Spacing Token |
| columnGap | 是 | 列间距，使用 Spacing Token |
| autoFlow | 是 | row（只支持按行流） |
| labelWidth | 是 | 统一标签宽度，单位 px |
| labelPosition | 是 | left / top |

#### 字段 Span 规则

| 规则 | 说明 |
|------|------|
| span 范围 | 1 ≤ span ≤ columns |
| 跨行 | span 字段自动从下一行开始 |
| 超列报错 | span > columns 时 Analyzer Error |
| 默认 span | 根据字段类型：引用字段默认 span=2，日期字段默认 span=1 |

#### 拖放规则

| 拖入对象 | 结果 |
|---|---|
| BO 字段 | 生成 FieldNode，并按字段类型选择编辑器 |
| Field | 移动字段位置 |
| Section | 不允许直接拖入，需放在父级容器 |
| EntryTable | 不允许，EntryTable 有独立的列编辑能力 |

#### Resize 规则

| 操作 | Schema 变化 |
|---|---|
| 拖字段右边缘 | 修改 Field.layout.span |
| 拖 Grid 列线 | P0 不直接改列宽，只改 columns / gap |
| 拖字段底部 | P0 不改字段高度，由组件自身决定 |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| GRID_FIELD_SPAN_OVERFLOW | Error | 字段 span 大于列数 |
| GRID_FIELD_SPAN_ZERO | Error | span 必须 ≥ 1 |
| GRID_FIELD_MIN_WIDTH_RISK | Warning | 字段最小宽度在当前断点下不足 |
| GRID_TOO_MANY_COLUMNS | Warning | 低断点列数过多 |
| GRID_LABEL_OVERFLOW | Warning | labelWidth 过小导致标签截断 |

### 7.2.1 EntryTable 基础定义（布局层）

EntryTable 属于强表格组件，其布局层 Schema 在本文档定义，详细字段列设计归「强表格与分录设计」文档。

#### Schema（布局层）

```json
{
  "id": "entry_table_sales_order",
  "type": "EntryTable",
  "name": "salesOrderEntry",
  "title": "订单明细",
  "layout": {
    "heightMode": "auto",
    "minHeight": 200,
    "showHeader": true,
    "showSummary": true,
    "showToolbar": true
  },
  "dataSource": "salesOrder.entries",
  "columns": []
}
```

#### 布局层属性

| 属性 | P0 | 说明 |
|---|---|---|
| heightMode | 是 | auto / fixed / fill |
| minHeight | 是 | 最小高度 |
| showHeader | 是 | 是否显示表头行 |
| showSummary | 是 | 是否显示汇总行 |
| showToolbar | 是 | 是否显示工具栏（新增行等） |
| dataSource | 是 | 数据绑定路径（由数据绑定引擎解释） |

#### columns / detail 约束

EntryTable 是强表格根节点，不是通用布局容器。P0 阶段列定义统一放在 `columns`，一层明细统一放在 `detail`，不使用 `children` 表达表格列或明细。

| 结构 | P0 | 说明 |
|---|---|---|
| columns[] | 是 | TableColumn 数组，详细结构归强表格文档 |
| detail | 是 | Level 1 DetailPanel 或 DetailTable 配置 |
| ColumnGroup / ComplexHeader | 否 | P1 复杂表头能力 |
| children | 否 | P0 不使用 children，避免与布局容器混淆 |
| Section / Tabs / SplitPane / ScrollContainer | 否 | 不允许作为 EntryTable 的直接子结构 |
| Field | 否 | 单元格编辑器通过 TableColumn.editor 定义，不直接作为 children |

旧 Schema 或导入数据中如果出现 `EntryTable.children`，SchemaNormalizer 必须委托 TableNormalizer 在保存/发布前迁移为 `columns` 或 `detail`；无法迁移时由 Analyzer 阻断。

#### 布局层 Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| TABLE_HEIGHT_INVALID | Error | heightMode 为 fixed 但 height 缺失 |
| TABLE_CHILDREN_DEPRECATED | Error | EntryTable 使用 children 表达列或明细，必须迁移为 columns/detail |

---

### 7.3 FlexLayout

FlexLayout 用于工具栏、按钮组、状态条和轻量水平/垂直堆叠。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 顶部命令组 | 保存、提交、审核、更多 |
| 按钮组 | 行操作、审批动作 |
| 状态区 | 单据编号、状态、创建人 |
| 轻量内容堆叠 | 标签、说明、辅助信息 |

#### FlexLayout 与 GridLayout 的区别

| 特性 | FlexLayout | GridLayout |
|------|-----------|------------|
| 定位 | 工具栏、按钮组、状态区 | 表单字段多列排布 |
| 排列方式 | 水平或垂直 | 按列网格排列 |
| 子节点分布 | 自由分布 | 规则网格 |
| span 概念 | 无 | 字段占列数 |
| 换行 | 支持 wrap | 自动换行 |

#### Schema

```json
{
  "id": "actions_primary",
  "type": "FlexLayout",
  "layout": {
    "direction": "row",
    "wrap": false,
    "gap": "sm",
    "align": "center",
    "justify": "end"
  },
  "children": ["btn_save", "btn_submit", "btn_more"]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| direction | 是 | row / column |
| wrap | 是 | true / false，true=换行 |
| gap | 是 | 子项间距，使用 Spacing Token |
| align | 是 | start / center / end / stretch |
| justify | 是 | start / center / end / space-between |
| itemGrow | 是 | true / false，是否填充 |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| FLEX_NOWRAP_OVERFLOW | Warning | 不换行导致横向溢出 |
| FLEX_BUTTON_GROUP_TOO_LONG | Warning | 操作按钮过多，建议 MoreMenu |
| FLEX_DIRECTION_MISMATCH | Suggestion | 垂直堆叠内按钮过多，建议 Section |

---

### 7.4 Section

Section 是企业页面的业务分组容器，不只是视觉卡片。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 基本信息 | 单据头字段分组 |
| 财务信息 | 金额、税率、币别 |
| 审批信息 | 流程、意见、状态 |
| 附件区域 | 附件和备注 |
| 关联信息 | 关联订单、关联客户 |

#### Section 可包含的子节点类型

| 子节点类型 | 是否允许 | 说明 |
|-----------|---------|------|
| GridLayout | 是 | 表单字段区 |
| FlexLayout | 是 | 工具栏、按钮组 |
| EntryTable | 是 | 分录表格 |
| Tabs | 是 | 多页签区域 |
| ScrollContainer | 是 | 滚动区 |
| SplitPane | 是 | 分栏 |
| Section | 是 | 嵌套分组 |

#### P0 能力

| 能力 | 说明 |
|---|---|
| 标题 | 显示业务分组名称 |
| 折叠 | 可配置默认展开/折叠 |
| 内部布局 | 可嵌套 GridLayout / FlexLayout / EntryTable / Tabs / SplitPane / ScrollContainer / Section |
| 权限入口 | Section 可见性 |
| 校验入口 | Section 内问题聚合 |

#### Schema

```json
{
  "id": "section_basic",
  "type": "Section",
  "title": "基本信息",
  "layout": {
    "padding": "md",
    "border": "subtle",
    "collapsible": true,
    "defaultCollapsed": false
  },
  "children": ["grid_basic_info"]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| title | 是 | 分组标题 |
| titleVisible | 是 | 是否显示标题 |
| collapsible | 是 | 是否允许折叠 |
| defaultCollapsed | 是 | 默认折叠 |
| padding | 是 | 内边距 |
| border | 是 | 边界强度 |
| toolbarSlot | 是 | 标题右侧操作区 |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| SECTION_EMPTY | Suggestion | 空 Section 建议删除 |
| SECTION_TOO_DEEP | Warning | Section 嵌套过深（超过 4 层） |
| SECTION_TITLE_MISSING | Suggestion | 业务分组建议有标题 |

---

### 7.5 Tabs

Tabs 用于承载多组同级信息，避免页面过长。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 主数据扩展信息 | 基本信息、财务信息、联系人 |
| 单据附加信息 | 附件、审批、关联单据 |
| 表格明细区域 | 分录、费用、批次 |

#### Tabs 与 Section 的结构差异

| 特性 | Tabs | Section |
|------|------|---------|
| children 结构 | `tabs: [{ id, title, children }]` | `children: [nodeId, ...]` |
| TabItem 管理 | 通过 Inspector 添加/删除 Tab | 直接拖入子节点 |
| 可见性 | Tab 级别可见性 | Section 级别可见性 |
| 懒加载 | 支持 lazyRender | 不支持 |

#### Schema

```json
{
  "id": "tabs_related",
  "type": "Tabs",
  "layout": {
    "tabPosition": "top",
    "activationMode": "click",
    "lazyRender": true
  },
  "tabs": [
    {
      "id": "tab_attachment",
      "title": "附件",
      "children": ["attachment_panel"]
    },
    {
      "id": "tab_approval",
      "title": "审批",
      "children": ["approval_panel"]
    }
  ]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| tabPosition | 是 | top |
| activationMode | 是 | click |
| lazyRender | 是 | 未激活页是否延迟渲染 |
| defaultActiveTab | 是 | 默认激活页签 |

#### TabItem 属性（通过 Inspector 编辑）

| 属性 | P0 | 说明 |
|---|---|---|
| tabTitle | 是 | 页签标题 |
| tabVisible | 是 | 页签可见性入口 |

#### 拖放规则

| 拖入对象 | 结果 |
|---|---|
| LayoutContainer | 拖入当前激活 Tab |
| Field | 拖入当前 Tab 内默认 Grid |
| EntryTable | 拖入当前 Tab，生成表格区 |
| TabItem | P0 不从画布拖入，通过 Inspector 新增页签 |

Tabs 的拖放目标必须是当前激活 Tab 的 `tabContent`。P0 不允许把节点直接追加到 Tabs 根节点，也不允许通过拖放创建 TabItem。

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| TABS_EMPTY | Error | Tabs 至少有一个 Tab |
| TAB_TITLE_MISSING | Warning | 页签标题不能为空 |
| TAB_TOO_MANY | Warning | 页签过多（建议 ≤ 7），建议拆分页面 |
| TAB_LAZY_REQUIRED | Suggestion | 大表格页签建议 lazyRender |

---

### 7.6 SplitPane

SplitPane 用于构建左右或上下分栏，是复杂 PC Web 页面关键容器。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 主内容 + 右侧辅助 | 单据主表单 + 审批/附件/关联单据 |
| 左树 + 右表单 | 主数据分类树 + 详情编辑 |
| 上下区 | 查询条件 + 结果区 |
| 工作台 | 主列表 + 详情面板 |

#### Schema

```json
{
  "id": "split_main",
  "type": "SplitPane",
  "layout": {
    "direction": "horizontal",
    "primary": "first",
    "primarySize": "flex",
    "secondarySize": 360,
    "minPrimarySize": 720,
    "minSecondarySize": 280,
    "resizable": true
  },
  "children": ["main_content", "right_assist"]
}
```

#### Size 计算规则

| primarySize 值 | 含义 |
|----------------|------|
| "flex" | 填满剩余空间，secondarySize 为固定值 |
| "50%" | 固定比例 |
| 像素值（如 760） | 固定像素宽度 |

**计算逻辑**：
- `primarySize = "flex"` 时：`primaryWidth = viewportWidth - secondarySize`
- `primarySize = "50%"` 时：`primaryWidth = viewportWidth * 0.5`
- `primarySize = 760` 时：`primaryWidth = 760px`

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| direction | 是 | horizontal / vertical |
| primary | 是 | first / second |
| primarySize | 是 | flex / 百分比 / 像素值 |
| secondarySize | 是 | 固定像素值 |
| minPrimarySize | 是 | 主区最小尺寸（像素） |
| minSecondarySize | 是 | 次区最小尺寸（像素） |
| resizable | 是 | 运行态是否可拖动分隔线 |

#### Resize 规则

| 操作 | Schema 变化 |
|---|---|
| 拖动分隔线 | 更新 secondarySize，primarySize 变为 "flex" |
| 双击分隔线 | P1：恢复默认尺寸 |
| 折叠侧栏 | P1：collapseState |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| SPLIT_CHILD_COUNT_INVALID | Error | SplitPane 必须有两个子容器 |
| SPLIT_MIN_SIZE_CONFLICT | Error | 两侧最小宽度之和超过当前断点宽度 |
| SPLIT_SECONDARY_TOO_NARROW | Warning | 右侧辅助区低于建议宽度（280px） |

---

### 7.7 ScrollContainer

ScrollContainer 用于局部滚动，解决复杂页面主体、右侧面板和表格区域的高度管理。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 主内容滚动 | 顶部和底部固定，中间滚动 |
| 右侧辅助面板 | 审批、附件、关联信息独立滚动 |
| 表格外层区域 | 表格与筛选/汇总配合 |
| 长表单区域 | 局部滚动避免整页失控 |

#### HeightMode 说明

| HeightMode | 说明 | 适用场景 |
|------------|------|---------|
| auto | 由内容撑开高度 | Section 内的内容区 |
| fixed | 使用固定的 height 值 | 固定高度卡片 |
| fill | 填满父级剩余空间 | SplitPane 的子区 |

**fill 模式的计算逻辑**：
```
availableHeight = parentHeight - siblingHeight - padding
containerHeight = min(maxHeight, availableHeight)
overflowY = auto → 超出时滚动
```

#### 与 StickyBar 的配合

| 场景 | 布局结构 | 说明 |
|------|---------|------|
| 顶部固定，主体滚动 | StickyBar + ScrollContainer | 顶部固定，内容滚动 |
| 底部固定，主体滚动 | ScrollContainer + StickyBar | 主体滚动，底部固定 |
| 左侧固定，右侧滚动 | SplitPane(固定 + 滚动) | 分栏布局 |

#### Schema

```json
{
  "id": "scroll_main_content",
  "type": "ScrollContainer",
  "layout": {
    "heightMode": "fill",
    "maxHeight": "viewport",
    "overflowY": "auto",
    "overflowX": "hidden",
    "scrollbar": "standard"
  },
  "children": ["section_basic", "entry_table", "summary_bar"]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| heightMode | 是 | auto / fixed / fill |
| height | 是 | fixed 时使用，单位 px |
| maxHeight | 是 | viewport / 固定值 |
| overflowY | 是 | auto / hidden |
| overflowX | 是 | hidden / auto，默认 hidden |
| scrollbar | 是 | standard / thin |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| SCROLL_NESTED_RISK | Warning | 局部滚动嵌套超过 2 层 |
| SCROLL_HEIGHT_MISSING | Error | fill 模式缺少可计算父高度 |
| SCROLL_X_ENABLED_RISK | Warning | 横向滚动会影响单据录入体验，建议 overflowX=hidden |
| SCROLL_STICKY_CONFLICT | Warning | StickyBar 所属滚动容器不明确 |

StickyBar 位于 ScrollContainer 内时，`container=nearestScroll` 表示向上查找最近的 `overflowY=auto` 的 ScrollContainer 作为 sticky 参考容器；如果上级存在多层 ScrollContainer，Analyzer 必须同时检查 `SCROLL_NESTED_RISK` 和 `SCROLL_STICKY_CONFLICT`，要求设计者明确 sticky 所属滚动区。

---

### 7.8 StickyBar

StickyBar 用于固定操作区、状态区和关键摘要区。

#### 适用场景

| 场景 | 说明 |
|---|---|
| 顶部命令栏 | 保存、提交、审核 |
| 底部操作栏 | 保存、取消、提交 |
| 汇总栏 | 金额、税额、数量汇总 |
| 表格工具栏 | 新增行、删除行；批量入口归 P1 |

#### 适用场景与 PageRoot 的关系

StickyBar 必须放在 PageRoot 直接子级，或 ScrollContainer 内：

```text
正确：
PageRoot
  ├─ StickyBar (顶部固定)
  ├─ SplitPane
  └─ StickyBar (底部固定)

正确：
PageRoot
  ├─ SplitPane
      ├─ ScrollContainer
      │   └─ StickyBar (在滚动区内固定)
      └─ ScrollContainer

错误：
PageRoot
  └─ GridLayout
      └─ StickyBar (不能放在 Grid 内)
```

#### Schema

```json
{
  "id": "sticky_bottom_actions",
  "type": "StickyBar",
  "layout": {
    "position": "bottom",
    "offset": 0,
    "zIndex": "sticky",
    "container": "page",
    "height": 56
  },
  "children": ["actions_footer"]
}
```

#### Inspector 属性

| 属性 | P0 | 说明 |
|---|---|---|
| position | 是 | top / bottom |
| offset | 是 | 距离边缘，px |
| container | 是 | page / nearestScroll |
| height | 是 | 固定高度，px |
| zIndex | 是 | sticky 层级 |
| shadow | 是 | subtle / none |

#### 可包含子节点

StickyBar 是固定区容器，但不是任意布局区。P0 只允许放入轻量工具栏或摘要内容：

| 子节点类型 | 是否允许 | 说明 |
|------|---------|------|
| FlexLayout | 是 | 承载按钮组、状态组、摘要组 |
| Field | 否 | 表单字段应放入 GridLayout |
| EntryTable | 否 | 表格不能放入固定操作区 |
| GridLayout | 否 | 避免固定区变成复杂表单区 |
| Section / Tabs / SplitPane / ScrollContainer | 否 | 固定区只承载轻量内容 |

#### 合法位置

| 父级 | 是否允许 | Analyzer 级别 |
|------|---------|--------------|
| PageRoot | 是 | - |
| ScrollContainer | 是 | - |
| SplitPane | 否 | Error |
| Section | 否 | Error |
| GridLayout | 否 | Error |
| FlexLayout | 否 | Error |
| Field | 否 | Error |
| EntryTable Cell | 否 | Error |

#### Analyzer 规则

| 规则 | 级别 | 说明 |
|---|---|---|
| STICKY_PARENT_INVALID | Error | StickyBar 只能放在 PageRoot 或 ScrollContainer 下 |
| STICKY_OVERLAP | Error | 多个 StickyBar 在同一位置重叠（top+top 或 bottom+bottom） |
| STICKY_HEIGHT_TOO_LARGE | Warning | StickyBar 占用超过视口 20% 高度 |
| STICKY_SCROLL_CONFLICT | Warning | 所在 ScrollContainer overflowY=hidden 时 sticky 不生效 |

---

## 8. CSS 能力映射边界

T-207 要支持 Web 主要布局能力，但必须通过受控属性暴露。

| CSS 能力 | T-207 P0 映射 | P0 状态 |
|---|---|---|
| display: grid | GridLayout | 支持 |
| grid-template-columns | columns | 支持受控列数（2/3/4/6/8/12） |
| grid-column | Field span | 支持，1到columns |
| display: flex | FlexLayout | 支持 |
| flex-direction | direction | 支持，row/column |
| flex-wrap | wrap | 支持，true/false |
| gap | gap Token | 支持 |
| overflow | ScrollContainer | 支持 |
| position: sticky | StickyBar | 支持 |
| min/max width | constraints | 支持 |
| z-index | zIndex Token | 受控支持 |
| position: absolute | 无 | 禁止用于页面主体 |
| custom CSS | 无 | P0 禁止 |
| media query | BreakpointResolver | 受控支持 |
| container query | 无 | P1/P2 |

---

## 9. 断点策略

### 9.1 P0 企业断点

P0 只支持 PC Web 断点：

| 断点 | 宽度 | 用途 |
|---|---|---|
| desktop-sm | 1280 | 笔记本和低宽度企业屏 |
| desktop-md | 1440 | 默认设计断点 |
| desktop-lg | 1600 | 常见办公显示器 |
| desktop-xl | 1920 | 大屏和高密度录入 |

### 9.2 断点属性继承

P0 采用"基础值 + 受控覆盖"：

```json
{
  "layout": {
    "columns": 4,
    "gap": "md"
  },
  "breakpoints": {
    "desktop-sm": {
      "columns": 3
    },
    "desktop-xl": {
      "columns": 6
    }
  }
}
```

P0 中断点覆盖只允许少量属性：

| 属性 | P0 |
|---|---|
| GridLayout.columns | 是 |
| GridLayout.gap | 是 |
| Field.span | 是 |
| SplitPane.secondarySize | 是 |
| ScrollContainer.heightMode | 是 |
| visible / hidden | P1 |
| reorder | P1 |
| 完全不同布局树 | P2 |

### 9.3 Analyzer 断点检查

| 规则 | 级别 | 说明 |
|---|---|---|
| BREAKPOINT_OVERFLOW | Error | 某断点下出现不可接受横向溢出 |
| BREAKPOINT_SPAN_INVALID | Error | 某断点下字段 span 超过列数 |
| BREAKPOINT_SPLIT_CONFLICT | Error | 分栏最小尺寸超过断点宽度 |
| BREAKPOINT_DENSITY_RISK | Warning | 低断点字段密度过高 |

---

## 10. DesignerOverlay 设计

### 10.1 Overlay 不参与布局

DesignerOverlay 是覆盖层，不改变 RuntimeRenderer 的 DOM 结构和布局。

```text
Runtime DOM
  -> data-node-id
  -> getBoundingClientRect()
  -> Overlay 坐标换算
  -> 绘制辅助元素
```

### 10.2 Overlay 元素

| 元素 | 用途 | P0 |
|---|---|---|
| SelectionBox | 当前选中节点边框 | 是 |
| ParentSelector | 快速选中父容器 | 是 |
| DropIndicator | 投放位置 | 是 |
| Snapline | 对齐线、列线、边距线 | 是 |
| SizeHint | 尺寸、span、px 提示 | 是 |
| ResizeHandle | 调整 span、Split 尺寸、Sticky 高度 | 是 |
| GhostPreview | 拖放预览 | 是 |

### 10.3 设计态抓手

抓手是设计器可操作性的最小单元。它既要服务人工操作，也要服务自动测试平台。

| 抓手 | DOM 标识 | 用途 | P0 |
|---|---|---|---|
| select-handle | data-handle="select" | 点击选中节点 | 是 |
| drag-handle | data-handle="drag" | 拖动节点位置 | 是 |
| resize-east | data-handle="resize-east" | Grid 字段横向调整 span | 是 |
| resize-split | data-handle="resize-split" | 调整 SplitPane 分隔线 | 是 |
| resize-sticky | data-handle="resize-sticky" | 调整 StickyBar 高度 | 是 |
| parent-handle | data-handle="parent" | 选中父容器 | 是 |
| drop-target | data-drop-target="true" | 显示投放区域 | 是 |
| quick-fix | data-handle="quick-fix" | Analyzer 单条修复 | 是 |

#### 抓手视觉规则

| 规则 | 说明 |
|---|---|
| 可发现 | 选中节点时必须显示可操作抓手 |
| 不遮挡 | 抓手不能遮挡字段输入文字和表格关键内容 |
| 命中区足够 | 鼠标命中区域不小于 8px，Split 分隔线不小于 6px |
| 状态明确 | hover / active / disabled 状态必须可见 |
| 可解释 | 禁用抓手时 tooltip 显示原因 |
| 可测试 | 抓手必须有稳定 data-testid |

#### 抓手与 Command 映射

| 抓手 | 用户动作 | Command | Schema 变化 |
|---|---|---|---|
| drag-handle | 拖动节点 | MoveNode | P0：同父容器内顺序变化；跨容器移动为 P1 |
| resize-east | 横向拖动 | UpdateProp | Field.layout.span |
| resize-split | 拖动分隔线 | UpdateProp | SplitPane.layout.secondarySize |
| resize-sticky | 上下拖动 | UpdateProp | StickyBar.layout.height |
| parent-handle | 点击 | SelectNode | selectedNodeId |
| drop-target | 松开鼠标 | AddNode / MoveNode | 新增或移动节点 |
| quick-fix | 点击 | QuickFix | 单条受控修复 |

### 10.4 DOM 标识要求

RuntimeRenderer 每个可设计节点必须带稳定标识：

```html
<section
  data-testid="designer-node-section_basic"
  data-node-id="section_basic"
  data-node-type="Section"
  data-drop-scope="layout-container"
  data-layout-kind="section">
  ...
</section>
```

| 标识 | 说明 |
|---|---|
| data-node-id | Schema 节点 ID |
| data-node-type | 节点类型 |
| data-drop-scope | 可投放范围 |
| data-layout-kind | grid / flex / split / scroll / sticky |
| data-testid | 自动化测试稳定定位 |
| data-selected | 当前是否选中 |
| data-drop-state | idle / valid / invalid |

DesignerOverlay 生成的抓手也必须有稳定标识：

```html
<div
  data-testid="designer-handle-field_customer-resize-east"
  data-node-id="field_customer"
  data-handle="resize-east"
  role="slider"
  aria-label="调整客户字段宽度">
</div>
```

### 10.5 自动化测试契约

自动测试平台不应依赖视觉文本和脆弱 CSS 选择器，而应依赖测试契约。

| 对象 | 测试定位 |
|---|---|
| 布局/表格画布节点 | `data-testid="designer-node-{nodeId}"` |
| 字段根节点 | `data-testid="field-node-{fieldId}"` |
| 组件资产项 | `data-testid="palette-item-{assetId}"` |
| 组件拖拽源 | `data-testid="drag-source-palette-item-{assetId}"` |
| 字段资产拖拽源 | `data-testid="binding-asset-field-{fieldPath}"` |
| 选中框 | `data-testid="designer-selection-{nodeId}"` |
| 拖拽抓手 | `data-testid="designer-handle-{nodeId}-drag"` |
| Resize 抓手 | `data-testid="designer-handle-{nodeId}-resize-east"` |
| Split 抓手 | `data-testid="designer-handle-{nodeId}-resize-split"` |
| Grid 单元投放点 | `data-testid="designer-grid-cell-{gridId}-{row}-{column}"` |
| 投放区 | `data-testid="designer-dropzone-{containerId}-{slot}"` |
| 目标级合法投放 | `data-testid="dropzone-state-{containerId}-{slot}-legal"` |
| 目标级非法投放 | `data-testid="dropzone-state-{containerId}-{slot}-illegal"` |
| 目标级非法原因 | `data-testid="drop-reject-reason-{containerId}-{slot}-{reasonCode}"` |
| Analyzer 问题 | `data-testid="analyzer-issue-{issueId}"` |
| Inspector 属性 | `data-testid="inspector-prop-{nodeId}-{propName}"` |

#### 自动化动作语义

| 自动化动作 | 模拟用户行为 | 预期断言 |
|---|---|---|
| clickNode(nodeId) | 点击节点 | selectedNodeId 变更，Inspector 切换 |
| dragFromPalette(assetId, targetId) | 从 Component Palette 拖入组件资产 | Schema 新增节点，画布出现节点 |
| dragBindingAsset(fieldPath, targetId) | 从 BO Field Tree 拖入字段资产 | 新建字段节点、重绑定已有节点或新增表格列 |
| dragHandle(nodeId, dx, dy) | 拖动节点抓手 | P0 同父容器顺序变化；跨容器变化为 P1 |
| resizeField(nodeId, dx) | 拖字段右侧抓手 | Field.layout.span 改变 |
| resizeSplit(nodeId, dx) | 拖分栏抓手 | SplitPane secondarySize 改变 |
| clickAnalyzerIssue(issueId) | 点击 Analyzer 问题 | 画布定位并选中节点 |
| applyQuickFix(issueId) | 点击单条修复 | Schema diff 符合修复预期 |

#### Playwright 示例

```ts
await page.getByTestId('field-node-field_customer').click();
await expect(page.getByTestId('designer-selection-field_customer')).toBeVisible();

await page.getByTestId('designer-handle-field_customer-resize-east')
  .dragTo(page.getByTestId('designer-grid-cell-grid_basic-0-2'));

await expectSchemaDiff(page, {
  nodeId: 'field_customer',
  path: 'layout.span',
  value: 2
});
```

#### 契约约束

| 约束 | 说明 |
|---|---|
| testId 稳定 | 不随标题、语言、排序变化 |
| nodeId 稳定 | 同一 Schema 节点保存后不改变 |
| 动作可回放 | 拖拽动作转成 CommandStack 记录 |
| 结果可断言 | 每次操作可检查 Schema diff |
| 视觉可断言 | 选中框、投放区、抓手状态可定位 |
| 禁止仅靠坐标 | 测试可用坐标拖拽，但起点和目标必须来自稳定抓手 |

### 10.6 坐标换算

Overlay 坐标必须考虑：

1. 画布缩放比例。
2. RuntimeFrame 滚动偏移。
3. ScrollContainer 局部滚动。
4. StickyBar 的 fixed/sticky 位置。
5. 浏览器 devicePixelRatio。

### 10.7 性能约束

| 操作 | 约束 |
|---|---|
| 鼠标移动测量 | 节流到 requestAnimationFrame |
| 拖放高亮 | 只测量候选容器 |
| 大页面测量 | 使用缓存 + dirty 标记 |
| 滚动同步 | 滚动事件节流 |

---

## 11. 拖放与投放规则

### 11.0 Asset -> Schema Translation Contract

从阶段 2 起，`ComponentAsset / FieldAsset / EntryAsset` 是设计态资产，不直接进入运行态 `PageSchema`。所有拖放必须先通过资产翻译层生成受控命令，再由命令修改 `PageSchema / ComponentSchema / LayoutSchema / TableColumn / detail`。

| 资产类型 | 来源 | 翻译动作 | Schema 输出 | 规则真源 |
|---|---|---|---|---|
| ComponentAsset(kind=layout) | Component Palette | create-new-node | GridLayout、FlexLayout、Section、Tabs、SplitPane、ScrollContainer、StickyBar | asset.allowedTargets + DropRuleEngine |
| ComponentAsset(kind=basic) | Component Palette | create-new-node | FieldNode 或 ActionButton | asset.allowedTargets + editor defaults |
| ComponentAsset(kind=business) | Component Palette | create-new-node | BillHeader、HeaderForm、SummaryBar、ActionBar、ApprovalPanel 等业务组件 | asset.allowedTargets + business defaults |
| ComponentAsset(kind=table) | Component Palette | create-new-node | EntryTable、RowAction、SummaryRow、DetailPanel、DetailTable | asset.allowedTargets + table rules |
| ComponentAsset(kind=template) | Component Palette | create-template-fragment | 受控 PageSchema fragment | template policy + DropRuleEngine |
| FieldAsset | BO Field Tree | create-new-node | FieldNode + binding + editor | field type mapping + DropRuleEngine |
| FieldAsset | BO Field Tree | rebind-existing-component | 更新已有 ComponentSchema.binding | binding compatibility |
| EntryFieldAsset | BO Field Tree | bind-table-column | TableColumn.binding + editor | table column rules |

`allowedTargets / blockedTargets` 只在设计态资产注册表中定义，`DropRuleEngine` 必须消费它们，不得在运行态 Schema 中重复持久化。运行态只允许保存投放后的结构、绑定和必要 provenance，例如 `sourceAssetId`、`sourceFieldPath`，不得保存完整 `ComponentAsset`、`PaletteGroup` 或 `ComponentCard`。

| 翻译失败 | 目标级反馈 |
|---|---|
| 目标容器不在 allowedTargets | `drop-reject-reason-{containerId}-{slot}-target-not-allowed` |
| 命中 blockedTargets | `drop-reject-reason-{containerId}-{slot}-target-blocked` |
| FieldAsset 与目标组件 binding 类型不兼容 | `drop-reject-reason-{containerId}-{slot}-binding-incompatible` |
| EntryFieldAsset 不是当前 EntryTable 所属分录字段 | `drop-reject-reason-{containerId}-{slot}-entry-field-mismatch` |
| DetailPanel/DetailTable 造成 Level 2+ | `drop-reject-reason-{containerId}-{slot}-detail-depth-exceeded` |

### 11.1 投放模型

拖放不直接修改 DOM，而是生成 Command：

```text
dragStart(source)
  -> hitTest(pointer)
  -> DropRuleEngine.resolve(target)
  -> show DropIndicator
  -> drop()
  -> CommandStack.execute(AddNode / MoveNode)
  -> SchemaStore update
```

自动化测试平台执行拖放时，也必须走同一条链路，不能调用内部接口绕过鼠标事件。这样才能验证真实用户路径和设计器抓手质量。

### 11.2 投放位置

| 投放位置 | 适用容器 |
|---|---|
| inside | Section、ScrollContainer、PageRoot |
| before / after | Section、Field、EntryTable、LayoutContainer |
| gridCell | GridLayout |
| flexIndex | FlexLayout |
| splitFirst / splitSecond | SplitPane |
| tabContent | Tabs |
| stickyContent | StickyBar |
| tableColumns | EntryTable columns |
| tableDetail | EntryTable detail |

### 11.3 合法投放矩阵

| 拖入对象 | PageRoot | Section | GridLayout | FlexLayout | Tabs | SplitPane | ScrollContainer | StickyBar | EntryTable.columns | EntryTable.detail |
|---|---|---|---|---|---|---|---|---|---|---|
| GridLayout | 是 | 是 | 否 | 否 | 条件 | 条件 | 是 | 否 | 否 | 否 |
| FlexLayout | 是 | 是 | 否 | 否 | 条件 | 条件 | 是 | 是 | 否 | 否 |
| Section | 是 | 是 | 否 | 否 | 条件 | 条件 | 是 | 否 | 否 | 否 |
| Tabs | 是 | 是 | 否 | 否 | 否 | 条件 | 是 | 否 | 否 | 否 |
| SplitPane | 是 | 是 | 否 | 否 | 条件 | 否 | 是 | 否 | 否 | 否 |
| ScrollContainer | 是 | 是 | 否 | 否 | 条件 | 条件 | 否 | 否 | 否 | 否 |
| StickyBar | 是 | 否 | 否 | 否 | 否 | 否 | 是 | 否 | 否 | 否 |
| FieldAsset | 否 | 条件 | 是 | 否 | 条件 | 否 | 条件 | 否 | 否 | 否 |
| ComponentAsset(kind=basic) | 否 | 条件 | 是 | 条件 | 条件 | 否 | 条件 | 否 | 否 | 否 |
| EntryTable | 是 | 是 | 否 | 否 | 条件 | 否 | 是 | 否 | 否 | 否 |
| EntryFieldAsset | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 是 | 否 |
| DetailPanel/DetailTable | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 是 |

**说明**：
- "是"：合法投放
- "条件"：不能作为目标容器的直接子节点追加，必须投放到明确子区或由 DropRuleEngine 生成受控包装结构
- "否"：非法投放，Analyzer Error
- "警告"：合法但建议改为更好位置，Analyzer Warning

条件投放规则：

| 场景 | 规则 |
|---|---|
| Tabs | 投入当前激活 Tab 的 `tabContent`，不是直接追加到 Tabs 根节点 |
| SplitPane | 只能投到 `splitFirst` / `splitSecond` 空子区或替换子区容器；P0 不支持把节点追加为第 3 个子节点 |
| LayoutContainer -> Tabs | 投入当前激活 Tab 的 `tabContent`；如目标 Tab 为空，直接作为该 Tab 内容根节点；如不为空，按当前 Tab 内容器规则投放 |
| Field -> Tabs | 进入当前激活 Tab 的默认 GridLayout；没有默认 Grid 时，DropRuleEngine 自动创建 Section + GridLayout 包装 |
| EntryTable -> Tabs | 进入当前激活 Tab 的 `tabContent`；如 Tab 内已有内容，DropRuleEngine 自动创建或复用 Section 承载表格 |
| Field -> Section | DropRuleEngine 自动找到或创建默认 GridLayout，再把字段放入 Grid |
| Field -> ScrollContainer | DropRuleEngine 自动定位滚动区内的默认 Section / Grid；没有默认区时提示先创建 Section |
| FlexLayout -> StickyBar | 仅作为按钮组、状态组、摘要组容器使用 |
| EntryFieldAsset -> EntryTable.columns | 新建或更新 TableColumn，列结构写入 `columns[]`，不得写入 `children` |
| DetailPanel/DetailTable -> EntryTable.detail | 仅允许 Level 1；若目标表格已经处于 detailDepth=1 且新明细会产生 Level 2+，必须拒绝 |
| FieldAsset -> Existing FieldNode | 执行 rebind-existing-component，更新 binding 和 editor 默认值，不新增兄弟节点 |

### 11.4 非法投放提示

非法投放必须给出业务化原因：

```text
不能将字段直接投放到 PageRoot，请先放入 Section 或 GridLayout。
不能将字段直接投放到 SplitPane 或 FlexLayout；SplitPane 只能承载两个子区，表单字段应进入 GridLayout。
不能将 StickyBar 放入 GridLayout、Section 或 SplitPane，StickyBar 只能放在 PageRoot 或 ScrollContainer 下。
不能将 SplitPane 放入 SplitPane 的子区中形成递归分栏，请改用 Section 或 Tabs。
不能将 EntryTable 放入 GridLayout，EntryTable 有独立的列编辑能力，请放在 Section 或 SplitPane 子区。
```

---

## 12. 吸附线与尺寸调整

### 12.1 吸附线类型

| 类型 | 用途 |
|---|---|
| Container Edge | 容器边界对齐 |
| Grid Column | 网格列线 |
| Field Baseline | 字段标签和输入框基线 |
| Gap Hint | 间距提示 |
| Split Guide | 分栏尺寸提示 |
| Sticky Boundary | 固定区域边界 |

### 12.2 Snapline 规则

| 场景 | 规则 |
|---|---|
| Grid 内拖字段 | 吸附到列线和可用 span |
| Flex 内拖按钮 | 吸附到子项前后位置 |
| Split 调整尺寸 | 吸附到 280 / 320 / 360 / 400 / 480 常用宽度 |
| Sticky 调整高度 | 吸附到 48 / 56 / 64 |
| Section 间距 | 吸附到 spacing Token |

### 12.3 Resize 到 Schema

| 操作 | Command | Schema 变化 |
|---|---|---|
| 字段横向拉伸 | UpdateProp | Field.layout.span |
| Split 分隔线拖动 | UpdateProp | SplitPane.layout.secondarySize |
| Sticky 高度调整 | UpdateProp | StickyBar.layout.height |
| Scroll 高度调整 | UpdateProp | ScrollContainer.layout.height |
| 表格列宽调整 | ResizeColumn | TableColumn.width |

P0 不允许通过 resize 修改任意 left / top 坐标。

### 12.4 可测试的尺寸调整

尺寸调整必须具备可自动化验证的中间状态和最终状态。

| 阶段 | UI 状态 | 测试断言 |
|---|---|---|
| hover 抓手 | 抓手高亮，显示 cursor | `data-handle-state="hover"` |
| drag start | 显示 SizeHint 和 Snapline | SizeHint 可见 |
| dragging | Schema 暂不提交或进入 transient 状态 | Ghost / hint 更新 |
| drop | 生成 Command | CommandStack 增加一条记录 |
| commit | Schema 更新 | Schema diff 可断言 |
| analyzer | 重新校验 | 无新增 Error 或显示对应 Error |

---

## 13. Layout Inspector

### 13.1 Inspector 分组

选中布局容器时，右侧 Inspector 的布局 Tab 统一按以下结构展示：

```text
布局类型
尺寸
间距
对齐
滚动
断点
约束
设计态
```

### 13.2 容器属性矩阵

| 属性 | PageRoot | Grid | Flex | Section | Tabs | Split | Scroll | Sticky |
|---|---|---|---|---|---|---|---|---|
| width / height | 是 | 是 | 是 | 是 | 是 | 是 | 是 | 是 |
| padding | 是 | 是 | 是 | 是 | 否 | 否 | 是 | 是 |
| gap | 否 | 是 | 是 | 是 | 否 | 否 | 是 | 是 |
| columns | 否 | 是 | 否 | 否 | 否 | 否 | 否 | 否 |
| direction | 是 | 否 | 是 | 否 | 否 | 是 | 否 | 否 |
| align / justify | 否 | 是 | 是 | 否 | 否 | 否 | 否 | 是 |
| overflow | 否 | 否 | 否 | 否 | 否 | 否 | 是 | 否 |
| sticky position | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 是 |
| tab config | 否 | 否 | 否 | 否 | 是 | 否 | 否 | 否 |
| split size | 否 | 否 | 否 | 否 | 否 | 是 | 否 | 否 |

### 13.3 属性编辑原则

| 原则 | 说明 |
|---|---|
| 只显示相关属性 | Grid 不显示 Split 属性 |
| 使用枚举和 Token | 避免任意字符串输入 |
| 即时预览 | 改属性后 RuntimeRenderer 立即刷新 |
| Analyzer 同步 | 改属性后重新计算布局风险 |
| 可撤销 | 每次属性变更进入 CommandStack |

---

## 14. LayoutAnalyzer

### 14.1 Analyzer 输出结构

```json
{
  "severity": "warning",
  "code": "GRID_FIELD_MIN_WIDTH_RISK",
  "message": "客户字段在 1280 断点下宽度不足，可能导致内容截断。",
  "schemaPath": "components.grid_basic.children[0]",
  "nodeId": "field_customer",
  "breakpoint": "desktop-sm",
  "quickFix": "将字段 span 从 1 调整为 2"
}
```

### 14.2 P0 布局规则清单

| 规则 | 级别 | 说明 |
|---|---|---|
| LAYOUT_NODE_UNKNOWN | Error | 未注册布局类型 |
| LAYOUT_CHILD_INVALID | Error | 子节点类型不允许 |
| LAYOUT_DEPTH_EXCEEDED | Error | 容器嵌套深度超过 8 层 |
| PAGE_ROOT_REQUIRED | Error | 缺少 PageRoot |
| GRID_FIELD_SPAN_OVERFLOW | Error | 字段 span 超出列数 |
| GRID_FIELD_SPAN_ZERO | Error | span 必须 ≥ 1 |
| SPLIT_CHILD_COUNT_INVALID | Error | SplitPane 子节点数不为 2 |
| SPLIT_MIN_SIZE_CONFLICT | Error | 分栏最小尺寸冲突 |
| STICKY_PARENT_INVALID | Error | StickyBar 父级非法 |
| STICKY_OVERLAP | Error | StickyBar 重叠 |
| SCROLL_HEIGHT_MISSING | Error | 局部滚动高度不可计算 |
| BREAKPOINT_OVERFLOW | Error | 某断点横向溢出 |
| GRID_LABEL_OVERFLOW | Warning | 标签可能截断 |
| SECTION_TOO_DEEP | Warning | 业务分组嵌套过深（超过 4 层） |
| SCROLL_NESTED_RISK | Warning | 局部滚动嵌套超过 2 层 |
| FLEX_NOWRAP_OVERFLOW | Warning | Flex 不换行导致溢出 |
| TAB_TOO_MANY | Warning | 页签过多（超过 7 个） |
| SCROLL_X_ENABLED_RISK | Warning | 横向滚动影响单据录入 |
| SECTION_EMPTY | Suggestion | 空分组建议删除 |

### 14.3 Quick Fix 边界

P0 Quick Fix 只允许单条受控修复：

| 问题 | Quick Fix |
|---|---|
| Field span 超出 | 调整到最大合法 span |
| Section 空 | 删除空 Section |
| Tab 标题缺失 | 聚焦标题属性 |
| Split 子节点不足 | 新增空 Section 作为占位 |
| Sticky 父级非法 | 移动到最近 PageRoot 或 ScrollContainer |

批量修复、批量忽略和导出问题列表归 P1。

---

## 15. 示例：销售订单页面布局 Schema

```json
{
  "id": "page_sales_order",
  "type": "PageRoot",
  "layout": {
    "direction": "vertical",
    "minWidth": 1280,
    "density": "standard"
  },
  "children": [
    {
      "id": "sticky_top",
      "type": "StickyBar",
      "layout": {
        "position": "top",
        "height": 56,
        "container": "page"
      },
      "children": [
        {
          "id": "action_bar_top",
          "type": "FlexLayout",
          "layout": {
            "direction": "row",
            "justify": "space-between",
            "align": "center",
            "gap": "sm"
          },
          "children": ["bill_title", "primary_actions"]
        }
      ]
    },
    {
      "id": "split_main",
      "type": "SplitPane",
      "layout": {
        "direction": "horizontal",
        "primary": "first",
        "secondarySize": 360,
        "minPrimarySize": 760,
        "minSecondarySize": 300,
        "resizable": true
      },
      "children": [
        {
          "id": "scroll_main",
          "type": "ScrollContainer",
          "layout": {
            "heightMode": "fill",
            "overflowY": "auto",
            "overflowX": "hidden"
          },
          "children": [
            {
              "id": "section_basic",
              "type": "Section",
              "title": "基本信息",
              "layout": {
                "padding": "md",
                "border": "subtle"
              },
              "children": [
                {
                  "id": "grid_basic",
                  "type": "GridLayout",
                  "layout": {
                    "columns": 4,
                    "rowGap": "sm",
                    "columnGap": "md",
                    "labelWidth": 96,
                    "labelPosition": "left"
                  },
                  "children": [
                    {
                      "id": "field_customer",
                      "type": "Field",
                      "layout": {
                        "span": 2,
                        "minWidth": 320
                      }
                    },
                    {
                      "id": "field_bill_date",
                      "type": "Field",
                      "layout": {
                        "span": 1,
                        "minWidth": 180
                      }
                    }
                  ]
                }
              ]
            },
            {
              "id": "entry_table_sales_order",
              "type": "EntryTable"
            },
            {
              "id": "summary_bar",
              "type": "FlexLayout",
              "layout": {
                "direction": "row",
                "justify": "end",
                "gap": "md"
              },
              "children": ["summary_amount", "summary_tax", "summary_total"]
            }
          ]
        },
        {
          "id": "right_assist",
          "type": "ScrollContainer",
          "layout": {
            "heightMode": "fill",
            "overflowY": "auto"
          },
          "children": [
            {
              "id": "tabs_assist",
              "type": "Tabs",
              "tabs": [
                {
                  "id": "tab_approval",
                  "title": "审批",
                  "children": ["approval_panel"]
                },
                {
                  "id": "tab_attachment",
                  "title": "附件",
                  "children": ["attachment_panel"]
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "id": "sticky_bottom",
      "type": "StickyBar",
      "layout": {
        "position": "bottom",
        "height": 56,
        "container": "page"
      },
      "children": ["footer_actions"]
    }
  ]
}
```

---

## 16. 典型工作流

### 16.1 从业务对象生成默认布局

```text
1. 用户选择销售订单 BO
2. 系统生成 PageRoot
3. 系统生成 StickyBar 顶部命令区
4. 系统生成 SplitPane 主内容 + 右侧辅助
5. 主内容生成 ScrollContainer
6. 基本信息生成 Section + GridLayout
7. 分录生成 EntryTable
8. 汇总生成 FlexLayout
9. 右侧辅助生成 Tabs
10. 底部生成 StickyBar 操作区
```

### 16.2 拖入字段

```text
1. 用户从 BO 字段树拖入 customerId
2. DropRuleEngine 判断目标 GridLayout 合法
3. DesignerOverlay 显示 gridCell 投放位置
4. 投放后生成 FieldNode
5. FieldNode.layout.span 根据字段类型默认生成
6. Analyzer 检查当前断点字段宽度
```

### 16.3 调整分栏

```text
1. 用户拖动 SplitPane 分隔线
2. MeasurementService 计算左右宽度
3. ResizeCommandFactory 生成 UpdateProp
4. SchemaStore 更新 secondarySize
5. RuntimeRenderer 重新渲染
6. Analyzer 检查 minPrimarySize 和 minSecondarySize
```

---

## 17. 参考产品吸收映射

| 参考产品 | 吸收点 | T-207 转化 |
|---|---|---|
| 金蝶 BOS / 云苍穹 | 单据头体、业务分组、固定操作区 | Section、EntryTable、StickyBar |
| DevExpress Web Designer | 设计器画布、吸附线、属性面板 | Runtime Design Surface、DesignerOverlay、Layout Inspector |
| Visual Studio Form Designer | 选中框、父级选择、Snaplines | SelectionBox、ParentSelector、SnaplineEngine |
| Oracle APEX Page Designer | Page Tree、Region 概念 | PageRoot、Section、Outline |
| ServiceNow UI Builder | Container、Component、Client State | LayoutContainer、ComponentRegistry、GlobalState |
| Webflow | Grid/Flex 可视化属性面板 | GridLayout、FlexLayout、Layout Inspector |
| Plasmic / Builder.io | 组件注册和受控设计系统 | LayoutRegistry、Token 化布局属性 |

---

## 18. P0 验收标准

| 标准 | 验收方式 |
|---|---|
| 能搭建销售订单页面 | PageRoot + StickyBar + SplitPane + Section + Grid + EntryTable + Summary |
| 能表达主数据维护页 | Section + Tabs + SplitPane + ScrollContainer |
| 能表达审批页 | 表单区 + 审批面板 + 固定操作区 |
| 真实 Web 画布 | RuntimeRenderer 生成真实 DOM，Overlay 只做辅助 |
| 拖放合法性清晰 | 合法投放高亮，非法投放显示原因 |
| Grid 字段布局可调 | 字段 span 可调整，并进入 CommandStack |
| Split 分栏可调 | 分隔线拖动能更新 Schema |
| Sticky 固定区有效 | 顶部/底部操作区固定且不遮挡主体内容 |
| Scroll 局部滚动有效 | 主体和右侧辅助可独立滚动 |
| Analyzer 能阻断发布 | Error 级布局问题必须修复 |
| P0/P1 边界清晰 | 不把多选、批量布局、移动端、Portal 当作 P0 已完成 |
| 设计器抓手完整 | 选中、拖拽、Resize、投放、Quick Fix 都有可见抓手 |
| 自动化测试可操作 | Playwright 可通过 data-testid 模拟点击、拖拽、调整尺寸 |
| Schema diff 可断言 | 每次布局操作后能验证对应 Schema 变化 |

---

## 19. 与后续文档的边界

| 后续文档 | 本文不展开 |
|---|---|
| 表单元素与字段体系 | TextInput、NumberInput、ReferencePicker 等字段控件细节 |
| 强表格与分录设计 | TableSchema、ColumnSchema、DetailTable、复杂表头 |
| 规则权限流程集成 | visibleWhen、readonlyWhen、流程状态规则 |
| Schema 与运行时架构 | Schema 存储、发布、热更新、版本差异 |
| 数据绑定引擎设计 | DataSource、DataPath、级联刷新、多数据源 |
| 交互原型 | HTML/Figma 可视化原型实现 |

---

## 20. 下一步

下一篇文档建议输出：

```text
../04-表单元素与字段体系/T-207-全新表单设计器-表单元素与字段体系.md
```

它应定义字段控件、业务字段绑定、编辑器选择、校验状态、权限状态和字段在 GridLayout / EntryTable 中的表现差异。
