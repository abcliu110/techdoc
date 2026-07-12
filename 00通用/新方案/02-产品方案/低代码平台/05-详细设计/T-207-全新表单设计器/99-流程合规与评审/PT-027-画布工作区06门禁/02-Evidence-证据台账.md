# PT-027 画布工作区：02-Evidence-证据台账

版本：v1.0  
日期：2026-07-10  
范围：T-207 全新表单设计器中央画布工作区 PT-027。  
依据：`06-流程-AI商业软件UI标杆证据驱动设计门禁.md`

## 1. 结论

PT-027 画布工作区达到本轮“画布区域合格”门槛：具备真实设计表面、标尺、网格、断点、缩放、吸附线、选中框、移动抓手、九宫格 resize 抓手、合法投放、非法投放拒绝和 Schema 变化断言。

本结论不等同于“超过金蝶 / DevExpress / Visual Studio”。超过竞品必须补齐竞品截图级证据、任务效率计量和人工终审。

## 2. 证据台账

| source_id | 证据类型 | 证据位置 | 原始观察 | 推断结论 | 置信度 |
|---|---|---|---|---|---|
| PT027-SRC-001 | 可运行原型 | `09-交互原型与视觉规范/T-207-表单设计器-09原型.html#pt-027` | PT-027 为独立画布工作区专项原型，左侧资产、中央设计面、右侧画布 Inspector、底部状态条完整可见 | 画布不再只是静态截图，而是独立可检查区域 | 高 |
| PT027-SRC-002 | 画布骨架 | `pt-027-canvas-prototype` | 四区结构：模式栏、资产栏、设计表面、画布 Inspector | 吸收 DevExpress / VS 的设计表面与工具窗范式 | 高 |
| PT027-SRC-003 | Web 布局能力 | `pt027-node-section-header` / `pt027-node-compound-layout` | 画布同时展示 Grid、Tabs、Split、Sticky、EntryTable | 覆盖复杂 PC Web 单据页面的关键布局容器 | 高 |
| PT027-SRC-004 | 设计辅助 | `pt027-ruler-top` / `pt027-ruler-left` / `pt027-snapline-*` | 标尺、网格线、吸附线在设计面可见，网格和标尺可开关 | 具备专业设计器的定位、对齐和测量反馈 | 高 |
| PT027-SRC-005 | 断点与缩放 | `pt027-breakpoint-*` / `pt027-zoom-*` / `pt027-sticky-*` | 顶部缩放入口初始可见；底部镜像命令常驻可见；点击 `pt027-sticky-zoom-in` 后 `data-zoom=110`；点击 `pt027-sticky-breakpoint-1280` 后 `data-breakpoint=desktop-1280` | 画布支持 PC 断点切换和缩放回放，长画布操作后仍有稳定命令入口 | 高 |
| PT027-SRC-006 | 选择模型 | `pt027-node-field-customer` / `pt027-inspector-current-node` | 点击节点后节点 selected 状态与 Inspector 当前节点同步 | 支持画布与属性面板同步 | 高 |
| PT027-SRC-007 | 抓手设计 | `pt027-handle-section-header-*` / `pt027-handle-split-main-resize` | 选区提供移动抓手、N/E/S/W/NW/NE/SW/SE 八个 resize 抓手和 Split 抓手 | 自动测试平台可以模拟点击抓手，后续可扩展拖拽测试 | 高 |
| PT027-SRC-008 | 合法投放 | `pt027-source-field-date -> pt027-dropzone-header-grid-1-2` | 投放后 `gridDropState=legal`，`gridLastDropKind=field` | 字段可投放到 Grid 单元 | 高 |
| PT027-SRC-009 | 非法投放 | `pt027-source-grid-layout -> pt027-table-column-dropzone` | 投放后 `tableDropState=illegal`，`tableSchemaMutated=false`，拒绝消息可见 | 非法投放不会误写 Schema | 高 |
| PT027-SRC-010 | 布局可检查性修复 | PT-027 原型 CSS | 侧栏和画布宽度收敛，按钮与抓手全部落入可视区域 | 人工检查和自动化点击都不依赖不可见溢出区域 | 高 |
| PT027-SRC-011 | 长画布命令可达性 | `pt027-sticky-zoom-in` / `pt027-sticky-breakpoint-1280` | 深层投放回放后底部镜像命令仍可见，且复用同一画布状态机 | 长画布设计器不会因为滚动导致核心命令不可达 | 高 |

## 3. 竞品吸收点

| 竞品 | 吸收点 | PT-027 落点 | 证据 |
|---|---|---|---|
| 金蝶表单设计器 | 企业单据页面、单据头、分录表格、中文业务语义 | 销售订单、基础信息、分录表格、字段资产均为中文业务对象 | PT027-SRC-001 / 003 |
| DevExpress Web Designer | Design Surface、缩放、工具窗、属性同步 | 中央设计面 + 右侧画布 Inspector + 缩放断点 | PT027-SRC-002 / 005 / 006 |
| Visual Studio Form Designer | Selection Adorner、resize handles、snaplines | 选中框、九宫格抓手、吸附线 | PT027-SRC-004 / 007 |
| Webflow / Plasmic | Grid / Flex / Split / Tabs 等 Web 布局可视化 | Grid、Tabs、Split、Sticky 同屏表达 | PT027-SRC-003 |
| AG Grid / DevExtreme | 强表格作为画布一级节点 | EntryTable 节点与表格列投放目标 | PT027-SRC-003 / 009 |

## 4. 证据边界

- 当前证据证明 PT-027 画布工作区区域合格。
- 当前证据不能证明整个表单设计器完成。
- 当前证据不能证明已超过金蝶、DevExpress 或 Visual Studio。
- 鼠标坐标拖拽、复杂滚动容器原生拖拽、真实大表性能仍需后续专项门禁。
