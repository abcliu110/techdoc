# PT-025 工具栏：12-Verifier-自动化门禁报告

版本：v1.3  
日期：2026-07-10  
验证对象：`http://127.0.0.1:8101/T-207-表单设计器-09原型.html?<cache-bust>#pt-025`  
原型文件：`D:\mywork\techdoc\00业务文档\系统设计\新方案\02-产品方案\低代码平台\05-详细设计\T-207-全新表单设计器\09-交互原型与视觉规范\T-207-表单设计器-09原型.html`

## 1. 验证结论

结论：通过 PT-025 工具栏区域自动化门禁。

证据边界：本报告只证明 PT-025 工具栏区域合格；不证明整个表单设计器完成，不证明已超过金蝶、DevExpress 或 Visual Studio。

## 2. 自动化检查结果

| 检查项 | 结果 |
|---|---|
| 六入口点击切换 | 通过 |
| 每次仅一个 panel 可见 | 通过 |
| inactive panel `hidden + aria-hidden=true` | 通过 |
| 三列组件卡 | 通过 |
| 组件明细栏宽度 | 264px |
| 固定 / 取消固定命令 | 通过 |
| 收起 / 展开命令 | 通过 |
| 提示开关 | 通过 |
| 组件卡数量 | 57 |
| 可投放组件源数量 | 56 |
| 禁用组件源数量 | 1 |
| 可投放字段源数量 | 4 |
| 分组数量与卡片数量一致 | 通过 |
| 搜索命中态 | 通过 |
| 搜索空态 | 通过 |
| 搜索清除恢复 | 通过 |
| 分组折叠 / 展开 | 通过 |
| PT-025 关键抓手全局唯一 | 通过 |
| 合法组件投放 | 通过 |
| 合法字段投放 | 通过 |
| 非法投放拒绝 | 通过 |
| 非法投放 Schema 变化 | `false` |
| 页面控制台 warn/error | 0 |

## 3. 关键断言

```text
structure:
- pt025-activity-item-components/fields/outline/issues/versions/data count = 1
- toolbox-panel-components/fields/outline/issues/versions/data role=tabpanel
- active panel: hidden=false, aria-hidden=false, data-state=active
- inactive panel: hidden=true, aria-hidden=true, data-state=hidden
- toolbox detail panel width = 264px
- .toolbox-cards grid columns = 3, computed columns ~= 73.664px * 3
- preview width = 571px expanded / 835px collapsed
- component groups = 7
- component cards = 57
- draggable component cards = 56
- unavailable component cards = 1
- group count mismatch = []
- group counts: layout=8, input=12, display=8, action=8, bill=8, table=7, template=6

unique hooks:
- pt025-palette-item-grid-layout count = 1
- pt025-drag-source-palette-item-grid-layout count = 1
- pt025-binding-asset-field-salesOrder-customerId count = 1
- pt025-toolbox-preview-dropzone-section-main count = 1
- pt025-toolbox-preview-dropzone-field-customer count = 1
- pt025-toolbox-drop-result count = 1
- pt025-toolbox-drop-reject count = 1

component legal click-to-drop:
- pick: pt025-palette-item-grid-layout
- target: pt025-toolbox-preview-dropzone-section-main
- result: created
- data-created-kind: component
- data-schema-mutated: true

field legal click-to-drop:
- pick: pt025-binding-asset-field-salesOrder-customerId
- target: pt025-toolbox-preview-dropzone-field-customer
- result: created
- data-created-kind: field
- data-schema-mutated: true

illegal click-to-drop:
- pick: pt025-palette-item-grid-layout
- target: pt025-toolbox-preview-dropzone-field-customer
- reject: rejected
- target data-schema-mutated: false
- result hidden: true
- result created attributes: null

top command state machine:
- initial: data-command-state=pinned-expanded-compact
- pin first click: data-dock-pinned=false, aria-pressed=false, text=未固定
- pin second click: data-dock-pinned=true, aria-pressed=true, text=固定
- collapse first click: data-dock-state=collapsed, left panel width=0, text=展开
- collapse second click: data-dock-state=expanded, left panel width=264, text=收起
- help first click: data-help-state=on, text=关闭提示
- help second click: data-help-state=off, text=提示

search and group replay:
- search query 表格: data-palette-search-state=matched, visibleGroups=3, emptyHidden=true
- search query 不存在组件: data-palette-search-state=empty, visibleGroups=0, emptyHidden=false
- click pt025-palette-search-clear: data-palette-search-state=idle, visibleGroups=7, emptyHidden=true
- click pt025-palette-group-layout-toggle: groupState=collapsed, aria-expanded=false, group height=33
- second click pt025-palette-group-layout-toggle: groupState=expanded, aria-expanded=true, group height=255
```

## 4. 本轮验证中发现并修复的问题

| 问题 | 修复 |
|---|---|
| HTTP 验证地址曾指向错误文件名 / 错误服务根目录 | 改为从原型目录启动 `127.0.0.1:8101`，使用真实文件名 `T-207-表单设计器-09原型.html` |
| `palette-item-grid-layout` 等抓手在多个 PT 章节重复 | PT-025 专项抓手全部增加 `pt025-*` 唯一前缀 |
| 自动化全局选择器可能拖到旧章节同名组件 | 门禁改为断言 PT-025 关键抓手全局唯一 |
| 纯坐标拖拽受页面滚动、落点覆盖和浏览器事件差异影响 | 增加可访问替代路径：点选源组件/字段，再点击目标落点完成投放 |
| 切换 panel 后内部滚动可能污染下一次拖拽 | `setupModeTabs` 激活 panel 时重置 `.toolbox-scroll` / `.pane-body` 滚动位置 |
| 非法投放后 result 仍可能残留 created 状态 | 清除 created 属性，写入 `data-schema-mutated=false` |
| 顶部 `固定 / 收起 / 提示` 像按钮但缺少稳定状态机 | 增加 `syncToolboxCommandState()`，统一维护 `data-dock-pinned`、`data-dock-state`、`data-help-state`、`data-command-state`、按钮 `aria-pressed/title/text` |
| 工具栏占用宽度偏大 | 将组件明细栏从 288px 收敛到 264px，仍保持三列组件卡，扩大画布预览宽度 |
| 提示模式若直接展开说明会挤占组件栏 | 说明文字仍以 hover/focus tooltip 展示，提示开关只强化卡片提示状态，不常驻占用空间 |
| 分组数量 8/12/7 与实际卡片数量不一致 | 补齐组件库到 57 个卡片，使 7 个分组计数全部与实际 DOM 一致 |
| 搜索框能进入空态但自动化清空路径不稳定 | 增加 `pt025-palette-search-clear` 清除按钮，作为人和自动化共同可用的恢复路径 |
| 分组标题看起来可点但没有回放门禁 | 增加分组 toggle 合同：`role=button`、`aria-expanded`、`aria-controls`、唯一 `data-testid`，并完成折叠/展开回放 |

## 5. 证据说明

本轮通过的自动化路径是“点击抓起 / 点击投放”，这是稳定的人机等价路径，适合自动化测试平台回放，也满足键盘可访问性方向。鼠标坐标拖拽仍保留为用户交互方式，但不作为唯一门禁路径；后续若要验收原生坐标拖拽，应单独增加视口滚动、遮挡检测和路径稳定性门禁。

## 6. 未覆盖项

以下不阻断 PT-025 本轮合格，但进入后续增强或工作台全局门禁：

- Dock 自动隐藏 / hover reveal 完整回放。
- 鼠标坐标拖拽在多滚动容器和复杂落点上的专项稳定性。
- 竞品截图级密度对比和人工终审。

## 7. 门禁判定

PT-025 工具栏区域：通过。  
下一步：进入下一个设计器核心区域，建议优先处理右侧 Inspector，并沿用“唯一抓手 + 可点击回放 + 自动化断言 + 专业 UI 评审”的门禁要求。
