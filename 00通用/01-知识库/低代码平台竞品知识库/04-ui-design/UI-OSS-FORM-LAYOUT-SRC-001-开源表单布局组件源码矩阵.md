---
id: UI-OSS-FORM-LAYOUT-SRC-001
type: ui-source-research
domain_object: FormDesignerLayout
competitors: [Form.io, SurveyJS, Designable, Formily, JSON Forms, Vueform Builder]
strength: 源码直接证据
confidence: 0.88
status: active
collected_at: 2026-07-20
valid_until: 2026-10-20
links: [UI-LOWCODE-FORM-OSS-001, DM-LOWCODE-FORM-001, UI-OSS-DESIGNABLE-001]
owner: AI
ai_generated: true
---

# 开源表单布局组件源码矩阵

## 1. 研究范围与结论

本轮将上游仓库浅克隆到固定只读参考目录 `D:\opensource-reference\form-designers`，未安装依赖、未运行第三方脚本。结论来自指定提交的源码或发布类型定义，不以产品宣传页代替源码事实。

核心结论：成熟表单设计器的布局能力并不是无限制 CSS 编辑，而是由一组可组合、可嵌套、带明确子节点约束的布局原语构成。值得自研吸收的共同能力是：普通容器、响应式栅格、行内排列、页签、折叠、分步、展示分组、结构树和可视化尺寸调整。绝对定位、自由画布和任意 CSS 不应成为业务表单的默认模型。

## 2. 版本与许可边界

| 项目 | 本地目录 | 分支 / 提交 | 许可直接事实 | 证据等级 |
|---|---|---|---|---|
| Form.io | `formio.js` | `main` / `1664a223494674fef70a26e53927aadc8746307a` | 根 `LICENSE.txt` 为 MIT | A：源码 |
| SurveyJS Creator | `survey-creator` | `master` / `fc713c07c4c7118ce918eb06733af3e7111d9650` | 根 `LICENSE` 明示 Creator 商业开发许可 | A：源码；不可按 MIT 复制 Creator 实现 |
| SurveyJS Library | `survey-library` | `master` / `91f62e5cdbffb779f810bdd8e6d8ba289314b958` | 根 `LICENSE` 为 MIT | A：源码 |
| Designable | `designable` | `main` / `3e961de947011df6ac5cd092c1084140494f5fc2` | 根 `LICENSE` 为 MIT | A：源码 |
| Formily | `formily` | `formily_next` / `d9a46442a575aa5f0fc1bd945e34d9a85d191d0e` | 根 `LICENSE.md` 为 MIT | A：源码 |
| JSON Forms | `jsonforms` | `master` / `6db5bc87e763922c6853d76b166885978e280c74` | 根 `LICENSE` 为 MIT | A：源码 |
| Vueform Builder | `vueform-builder` | `main` / `30d3e4e955b234f80a21f4c2ca67ef334acdd507` | `LICENSE.txt` 只链接 Vueform 商业协议 | B：发布类型定义；不是完整可读源码 |

许可说明：源码可研究不等于可以直接复制。尤其是 SurveyJS Creator 和 Vueform Builder，吸收设计思想前应由法务或负责人复核商业许可。本文不构成法律意见。

## 3. 总体能力矩阵

| 能力 | Form.io | SurveyJS | Designable + Formily | JSON Forms | Vueform Builder |
|---|---|---|---|---|---|
| 普通嵌套容器 | Panel、Fieldset、Well | Panel、Page | FormLayout、Card、Space | Group、VerticalLayout | 类型声明不足以确认 |
| 响应式列 | Columns：12 栅格、断点尺寸 | 同行宽度或可选 Grid + `colSpan` | FormGrid：容器宽度驱动自动列数 | 依 renderer；Vuetify 支持断点折行和列权重 | 声明有设备断点与 columns 配置 |
| 行内 / 流式 | Columns | `startWithNewLine=false` | Space 横/竖、wrap | HorizontalLayout | 有 Columns/Grid 配置字段 |
| 页签 | Tabs | Page 是分页，不等同页签 | FormTab + TabPane | Categorization 可渲染 Tabs | 有 tab 配置字段 |
| 折叠 | Panel 可折叠 | Panel state | FormCollapse + CollapsePanel | 非核心 UI Schema 类型 | 未确认 |
| 分步 / 向导 | Wizard 显示模式，Panel 为页 | Page 导航 | 可由 FormTab/扩展实现，当前物料未见独立 Step | Categorization `variant=stepper` | 有 step 配置字段 |
| 固定单元格布局 | Table | 无独立 Table 布局节点 | ArrayTable 属数据数组，不等同静态布局表 | 无核心 Table 布局节点 | 有 GridField 名称，细节未确认 |
| 任意递归布局 | 多数 NestedComponent 可嵌套 | Panel 可嵌套，深度可限制 | 通用容器可嵌套；Grid 禁止直接嵌 Grid | Layout.elements 可递归；Categorization 限 Category 树 | 未确认 |
| 设计态尺寸调整 | 属性表改列宽 | 左/右拖放生成同行；属性控制宽度 | GridColumn 设计态 1..12 步进 resize | 本仓库重点是 renderer，不是可视化 designer | 发布包可见设备预览配置，交互实现不可审计 |

## 4. Form.io 源码矩阵

### 4.1 Layout 分组完整清单

从各组件 `builderInfo.group === 'layout'` 直接确认 8 项：`HTML Element`、`Content`、`Columns`、`Fieldset`、`Panel`、`Table`、`Tabs`、`Well`。`Wizard` 是表单显示/构建模式，不是普通 layout 调色板组件。

| 组件 | Schema 结构与合法子节点 | 可配置布局属性 | 响应式 / 运行时 | 设计态 |
|---|---|---|---|---|
| HTML Element | `{type:'htmlelement', tag, attrs, content}`；非容器 | `tag、className、attrs、content、refreshOnChange` | 内容可插值并经过 sanitize；属性提示只允许安全属性 | 属性编辑，不承载子控件 |
| Content | `{type:'content', html}`；非容器 | `html、refreshOnChange` | 表单数据变化时可重渲染插值内容 | 属性编辑，不承载子控件 |
| Columns | `{type:'columns', columns:[{components,width,offset,push,pull,size}], autoAdjust}` | 编辑器暴露 `size(xs..xl)、width、列增删/排序、autoAdjust`；运行 Schema 仍保留 offset/push/pull | 12 列网格；列宽累计超过 12 时分行；`autoAdjust` 可在嵌套组件隐藏时将列宽归零并重排 | 每列是独立 drop zone；列定义可增删、排序 |
| Fieldset | `{type:'fieldset', legend, components}` | `legend` | 语义化 fieldset/legend；无独立响应式算法 | NestedComponent，可承载嵌套组件 |
| Panel | `{type:'panel', title, theme, breadcrumb, components}` | `title、tooltip、theme、collapsible、collapsed`；Wizard 页额外有 breadcrumb、按钮、Enter 导航、滚动 | 可折叠；在 Wizard 中承担页面容器 | NestedComponent，可承载嵌套组件 |
| Table | `{type:'table', numRows, numCols, rows:[[{components}]], header, ...}` | 行列数、表头、cloneRows、cellAlignment、striped、bordered、hover、condensed | 每个单元格为 drop zone；外层 `table-responsive`，列显示宽度约为 `floor(12/numCols)` | 固定二维单元格；调整行列会修整 `rows`，可克隆首个非空行组件 |
| Tabs | `{type:'tabs', components:[{label,key,components}], verticalLayout}` | 页签增删/排序、label/key、verticalLayout | 独立 `currentTab`；子字段聚焦自动切 Tab；错误传播到 Tab 标题 | 每个 Tab 是 drop zone；编辑器数据网格管理页签 |
| Well | `{type:'well', components}` | 主要是 label | 视觉容器，无独立响应式算法 | NestedComponent，可承载嵌套组件 |
| Wizard 模式 | Form 的顶层 `components` 是 Panel 页数组 | breadcrumb、按钮、前后翻、Enter、scrollToTop 等主要落在 Panel 页属性 | 维护当前页及导航状态 | `WizardBuilder` 管理页，不作为任意子节点使用 |

父子约束：`Columns.columns[*].components`、`Table.rows[*][*].components`、`Tabs.components[*].components` 是专用槽位；Panel/Fieldset/Well 使用通用 `components`。HTML 与 Content 不是容器。Form.io 的灵活性来自这些槽位递归组合，而不是所有节点都能拥有 children。

关键证据：

- `formio.js/src/components/*/*Component.js` 对应的 schema 与 `builderInfo`
- `formio.js/src/components/columns/editForm/Columns.edit.display.js`
- `formio.js/src/components/table/editForm/Table.edit.display.js`
- `formio.js/src/components/tabs/editForm/Tabs.edit.display.js`
- `formio.js/src/components/panel/editForm/Panel.edit.display.js`
- `formio.js/src/components/_classes/nested/NestedComponent.js`
- `formio.js/src/Wizard.js`、`src/WizardBuilder.js`

## 5. SurveyJS 源码矩阵

SurveyJS 的重点不是很多显式布局组件，而是让 `Page`、`Panel` 和 Question 共享布局属性。`PageModel extends PanelModel`，因此 Page 与 Panel 都是元素容器；Dynamic Panel 用 `templateElements` 保存可重复的 Panel 模板。

| 模型 | Schema / 子节点 | 关键属性 | 响应式规则 | 设计态交互 |
|---|---|---|---|---|
| Survey | `{pages:[...]}` | `widthMode:auto/static/responsive`、`width`、`gridLayoutEnabled` | responsive 占满可用宽度；auto 按问题类型判断 static 或 responsive | Creator 管理页及设备/预览 |
| Page | `{name,title,elements:[Question|Panel...]}` | 页面标题、可见/启用/必填规则、`gridLayoutColumns` | 继承 Panel 的行、列与题目标题宽度行为；自身 width 等属性被隐藏 | Page 可排序；题目/Panel 可拖入 |
| Panel | `{type:'panel', name, elements:[Question|Panel...]}` | `startWithNewLine、width、minWidth、maxWidth、colSpan、state、questionTitleWidth、gridLayoutColumns` | 默认按 `startWithNewLine` 从顺序元素派生 rows；同一行可用 CSS width。启用 grid 后按最大同行跨度生成列，`colSpan` 决定跨列数，未设宽列均分剩余百分比 | 支持 top/bottom/left/right/inside；inside 进入 Panel；可限制最大嵌套深度 |
| Question | Question 子类型 | `startWithNewLine、width、minWidth、maxWidth、colSpan` | 与 Panel 使用同一行/列算法 | 左右拖放形成同行，上下拖放形成新行 |
| Dynamic Panel | `{type:'paneldynamic', templateElements:[...]}` | `panelCount、min/maxPanelCount、allowAddPanel、allowRemovePanel、templateTitle...` | 每个实例基于同一 Panel 模板；模板内部继续使用 Panel 行布局 | 设计态编辑 `templateElements`，运行态允许用户增删实例 |
| Grid column | `gridLayoutColumns:[{width,questionTitleWidth}]` | `width` 为百分比；`questionTitleWidth` 为 CSS 宽度 | 可自动生成，也可序列化人工配置；`effectiveWidth` 仅运行时 | Property Grid 有专用矩阵编辑器 |

设计态直接证据：Creator 的 `dragdrop-survey-elements.ts` 将命中位置计算为 `top/bottom/left/right/inside`；drop 时调用 `PanelModelBase.insertElement(src,dest,location)`。核心库 `panel.ts` 将 left/right 改为同行关系，将 top/bottom 改为新行，并维护 `startWithNewLine`。

边界：Creator 源码虽可读，但其根许可为商业许可。可吸收“顺序 + 换行标记 + 同行拖放”这一抽象，不直接复制 Creator 代码。

## 6. Designable + Formily 源码矩阵

Designable 负责设计态节点、行为、投放规则和属性 Schema；Formily 负责运行时布局。节点通常保存为 `type:'void'` 与 `x-component/x-component-props`，children 保存嵌套 Schema。

| 组件 | 合法子节点 / Schema | 属性 | 响应式与状态 | 设计态 |
|---|---|---|---|---|
| FormLayout | 通用可投放容器 | `layout(vertical/horizontal/inline)、labelCol、wrapperCol、labelWidth、wrapperWidth、label/wrapperAlign、wrap、size、feedbackLayout、tooltipLayout、fullness、inset、shallow、bordered` | 运行时另支持 `breakpoints` 以及 layout/labelCol/wrapperCol/alignment 数组；按容器 `clientWidth` 选断点值 | `droppable:true`；属性向浅层还是深层后代传播由 shallow 控制 |
| FormGrid | 直接子节点必须是 `FormGrid.GridColumn`；Grid 禁止直接投放另一个 Grid | `min/maxWidth、min/maxColumns、breakpoints、columnGap、rowGap、colWrap` | ResizeObserver 驱动；根据容器宽、子节点数、min/max 宽和断点计算列数；CSS Grid `repeat/minmax` | 可添加 GridColumn；GridColumn 宽度以 `gridSpan` 1..12 步进 resize |
| GridColumn | 只能直接投放进 FormGrid；自身可承载任意字段/容器 | `gridSpan` | span 大于当前列数时截断；可自动换行 | `resizable.width` 加减 1，范围 1..12 |
| Space | 通用可投放容器 | `align、direction、size、split、wrap` | Ant Design Space；gap 可继承 FormLayout | `inlineChildrenLayout:true`，适合按钮/短字段行 |
| FormTab | 直接 children 限 `FormTab.TabPane` | `animated、centered、size、type` | 独立 activeKey；运行态扫描 `x-component` 含 TabPane 的子 Schema，错误数显示 Badge | 任意节点直接丢到空 Tab 容器时会被包装成 TabPane；支持新增 Pane 和原位编辑标题 |
| TabPane | 只能直接投放进 FormTab；内部可承载任意节点 | `tab` | `RecursionField` 渲染内部 Schema | Pane 自身是 drop zone |
| FormCollapse | 直接 children 限 `FormCollapse.CollapsePanel` | `accordion、collapsible、ghost、bordered` | 运行时折叠状态；设计态为便于编辑会展开各 Panel | 投放普通节点时自动包装为 CollapsePanel；支持新增 Panel 和原位编辑标题 |
| CollapsePanel | 只能直接投放进 FormCollapse；内部可承载任意节点 | `collapsible、header、extra` | 面板内容递归渲染 | Panel 自身是 drop zone |
| Card | 通用可投放容器 | `title、extra、type、bordered` | 无独立响应式算法 | `droppable:true`，标题原位编辑 |

值得吸收：Designable 最有价值的不是组件数量，而是每个容器显式声明 `droppable、allowDrop/allowAppend、resizable、propsSchema`。这可以避免“所有节点随便嵌套”造成无效 Schema。

## 7. JSON Forms 源码矩阵

JSON Forms 将数据 JSON Schema 与 UI Schema 分离。核心只定义布局语义，实际外观和响应式由 renderer 集决定，因此不能把某个 Material 或 Vuetify renderer 的行为误写成核心协议保证。

| UI Schema 类型 | Schema / 合法子节点 | 核心语义 | Renderer 差异 |
|---|---|---|---|
| VerticalLayout | `{type:'VerticalLayout', elements:UISchemaElement[]}` | 子元素从上到下，可递归 | Material 用 column Grid；Vuetify 用纵向容器 |
| HorizontalLayout | `{type:'HorizontalLayout', elements:UISchemaElement[]}` | 子元素从左到右，可递归 | Material 子项均为 grow；Vuetify 可按 `v-col[index].cols` 配权重，并用 `breakHorizontal:xs..xl` 折为 12 列全宽 |
| Group | `{type:'Group', label?, i18n?, elements:[...]}` | 类似 VerticalLayout，但具有分组标题 | 各 renderer 用 fieldset/card 等呈现 |
| Category | `{type:'Category', label, elements:[...]}` | Categorization 的有标签内容页 | 不是独立任意顶层导航状态容器 |
| Categorization | `{type:'Categorization', label, elements:(Category|Categorization)[]}` | 可递归表示分类树 | Material 单层默认为 scrollable Tabs；`options.variant='stepper'` 为 Stepper，`showNavButtons` 控制前后按钮。Vuetify 还支持 `options.vertical` 的纵向 Tabs/Stepper |

所有 UI Schema 元素可带 `rule`，effect 支持 `HIDE、SHOW、ENABLE、DISABLE、READONLY、WRITABLE`。这意味着布局节点本身也能条件显隐/禁用，而不是只有字段支持规则。

边界：JSON Forms 仓库主要提供运行时和 renderer，不是完整可视化设计器；它能证明 Schema 的可组合性，不能证明成熟设计态拖拽体验。

## 8. Vueform Builder 证据限制

当前仓库只包含 `index.mjs` 构建产物、`index.d.mts` 类型声明和样式，不足以审计布局算法与拖放约束。类型定义可直接确认：

- Builder 有 `views: editor/preview/code`、`devices: tablet/desktop`。
- `breakpoints.tablet/desktop` 各含 `breakpoint` 与 `size`。
- Builder 的 `columns` 包含 `container、label、wrapper`。
- 导出了 `ColumnsField、FormColumnsField、GridField、ColWrapField` 等配置字段。
- 存在 `tab` 与 `step` 面板配置入口。

不能仅凭名称断言 Grid 的 Schema、合法子节点、断点合并策略或拖拽 resize 行为。此项目在矩阵中只作为 B 级“发布类型定义证据”，且根许可证指向商业协议。

## 9. 对自研表单设计器的吸收决策

### 9.1 应吸收的布局原语

| 优先级 | 自研原语 | 对标依据 | 建议 Schema 约束 |
|---|---|---|---|
| P0 | `section/card/container` | Form.io Panel、Designable Card/FormLayout、JSON Forms Group | 通用 children；标题、边框、折叠、条件规则分层配置 |
| P0 | `grid + gridItem` | Formily FormGrid、Form.io Columns | 容器只直收 gridItem；item span 1..12；内部可递归；禁止 Grid 直接作为 Grid 的裸子节点 |
| P0 | 响应式配置 | Formily 容器宽断点、JSON Forms Vuetify 折行、Form.io size | 保存明确设备覆盖值；运行时按容器宽解析；缺省继承上一断点，不复制三份树 |
| P0 | `stack/space` | Formily Space、JSON Forms Vertical/Horizontal | direction、gap、align、justify、wrap；作为轻量行内布局 |
| P1 | `tabs + tabPane` | Form.io Tabs、Formily FormTab、JSON Forms Categorization | tabs 只能直收 tabPane；pane 可收任意节点；activeKey 是设计/运行状态，不写入业务数据 |
| P1 | `collapse + collapsePanel` | Designable FormCollapse、Form.io collapsible Panel | collapse 只能直收 panel；支持 accordion、defaultExpanded、标题 |
| P1 | `steps + step` | Form.io Wizard、JSON Forms Stepper、SurveyJS Page | step 只能直收步骤页；导航、校验、跳转策略独立于普通 Tabs |
| P1 | 同行快捷编排 | SurveyJS left/right drop | 左右命中可自动创建/复用 row/grid，不要求用户先理解容器 |
| P2 | `fieldset/well/content/html` | Form.io 展示布局 | Fieldset 与说明内容可做；HTML 必须白名单和 sanitize，默认不开放任意脚本/样式 |
| P2 | 静态布局表 | Form.io Table | 与数据表格/分录严格区分；只用于固定二维排版 |

### 9.2 不应追求“所有布局”

“所有布局”没有可验收边界。生产表单应定义为：所有常见业务表单布局可由有限原语组合，并能稳定序列化、响应式降级、键盘访问、校验聚焦和版本迁移。以下能力不建议作为第一阶段默认开放：

- 任意绝对定位、自由画布和像素坐标；移动端与内容变化下不可预测。
- 任意 CSS/HTML/JavaScript；会破坏主题、可访问性并引入 XSS。
- 任意父子嵌套；应由容器声明合法直接子节点。
- 为桌面/平板/手机复制三棵独立组件树；应保存一棵树和断点覆盖。
- 将 Tabs、Steps、Collapse 统一成没有语义的 generic container；它们的状态、校验和导航契约不同。

### 9.3 推荐的统一节点协议

```json
{
  "id": "node-id",
  "type": "grid | gridItem | stack | section | tabs | tabPane | collapse | collapsePanel | steps | step | field",
  "props": {},
  "responsive": {
    "desktop": {},
    "tablet": {},
    "mobile": {}
  },
  "children": []
}
```

必须另设组件注册表约束：`allowedParents、allowedChildren、maxChildren、droppable、resizable、canDelete、defaultChildren、propertySchema`。布局算法与设计器节点树共享协议，但 hover、selected、activeTab、dragging、dropIndicator 等设计态瞬时状态不得持久化进发布 Schema。

## 10. 第一轮未验证项

- 未安装或运行第三方仓库，尚未用真实页面对比窄屏、嵌套三层、隐藏字段重排和校验聚焦的视觉结果。
- 未对 Form.io 所有模板包逐主题验证 Columns 的 Bootstrap 类输出差异。
- SurveyJS grid 布局与传统 width 布局同时配置时的所有边界组合尚未穷举。
- JSON Forms 不同 renderer 集的 option 名称不完全一致；统一协议应只吸收语义，不直接暴露 renderer 私有 option。
- Vueform Builder 因缺少完整源码和商业许可边界，不能进入源码级实现对照。

下一轮若要继续，应在隔离目录安装 MIT 项目的锁定依赖，制作同一份测试表单并运行桌面/平板/手机截图与 Schema round-trip；SurveyJS Creator 和 Vueform Builder 先完成许可确认。
