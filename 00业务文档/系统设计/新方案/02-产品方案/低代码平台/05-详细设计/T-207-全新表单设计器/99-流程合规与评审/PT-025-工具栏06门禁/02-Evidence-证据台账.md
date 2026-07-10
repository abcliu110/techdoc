# PT-025 工具栏：02-Evidence-证据台账

版本：v1.2  
日期：2026-07-10  
范围：T-207 全新表单设计器左侧工具栏 PT-025。  
依据：`06-流程-AI商业软件UI标杆证据驱动设计门禁.md`

## 1. 结论

PT-025 工具栏已经达到本轮“工具栏区域合格”门槛：六入口真实切换、三列高密度组件库、中文分组、tooltip 说明层、稳定测试抓手、组件/字段/非法投放鼠标回放均已具备。

本结论不等同于“超过金蝶 / DevExpress / Visual Studio”。超过竞品必须补齐竞品截图级证据、人工终审和全量 S7 验收。

## 2. 证据台账

| source_id | 证据类型 | 证据位置 | 原始观察 | 推断结论 | 置信度 |
|---|---|---|---|---|---|
| PT025-SRC-001 | 可运行原型 | `09-交互原型与视觉规范/T-207-表单设计器-09原型.html#pt-025` | 左侧为 48px Activity Bar + 264px Dock Panel + 中央画布 + 折叠 Inspector | 工作台结构接近 DevExpress / VS 工具窗心智，并保留企业软件密度 | 高 |
| PT025-SRC-002 | DOM 合同 | 入口 `data-testid="pt025-activity-item-*"`，`id="pt025-activity-item-*"` | 六个入口均有唯一 `data-testid`、`role=tab`、`aria-controls`，对应 components / fields / outline / issues / versions / data | 自动测试平台可唯一点击和键盘切换 | 高 |
| PT025-SRC-003 | 面板合同 | 面板 `data-testid="toolbox-panel-*"`，`id="toolbox-panel-*"` | 激活面板 `data-state=active`，未激活面板 `hidden + aria-hidden=true`，对应 components / fields / outline / issues / versions / data | 不再只依赖视觉隐藏，满足无障碍和自动化判断 | 高 |
| PT025-SRC-004 | 组件密度 | `.toolbox-cards` | 可见分组为三列网格，验证值约 `73.6641px * 3` | 工具栏每行至少 3 个组件，满足用户确认的密度要求 | 高 |
| PT025-SRC-005 | 拖拽源 | `.toolbox-card[draggable=true][data-drag-kind=component]` | 27 个可拖拽组件卡、1 个禁用卡、4 个字段拖拽源 | 工具栏具备组件入口和字段入口分离后的真实拖拽资产 | 高 |
| PT025-SRC-006 | 合法组件投放 | `palette-item-grid-layout -> toolbox-preview-dropzone-section-main` | 鼠标路径回放后 `toolbox-drop-result` 为 `created`，`data-created-kind=component`，`data-created-type=GridLayout` | 组件拖入画布可生成可验证结果 | 高 |
| PT025-SRC-007 | 合法字段投放 | `binding-asset-field-salesOrder-customerId -> toolbox-preview-dropzone-field-customer` | 鼠标路径回放后 `data-created-kind=field`，`data-created-type=binding-asset-field-salesOrder-customerId` | 字段入口与组件入口分离后仍可完成字段投放 | 高 |
| PT025-SRC-008 | 非法投放 | `palette-item-grid-layout -> toolbox-preview-dropzone-field-customer` | 拒绝节点显示 `rejected`，`data-schema-mutated=false`，结果节点隐藏且无 created 属性 | 非法投放不会误写 Schema，满足自动化测试断言 | 高 |
| PT025-SRC-009 | 控制台 | in-app browser dev logs | 页面控制台 warn/error 为空；外部 Statsig 网络超时为浏览器宿主噪声，不来自原型页面 | 原型自身无前端运行错误 | 中 |
| PT025-SRC-010 | 顶部命令状态机 | `pt025-toolbox-command-pin/collapse/help` | 首次点击即可改变 `data-dock-pinned` / `data-dock-state` / `data-help-state`，并同步 `aria-pressed`、按钮文案和 `data-command-state` | 顶部命令不是假按钮，可被自动化平台稳定回放 | 高 |
| PT025-SRC-011 | 组件库完整性 | `#toolbox-panel-components .toolbox-group` | 7 个分组、57 个卡片、56 个可投放卡片、1 个禁用卡片；分组计数与实际卡片数量一致 | 不再用数字暗示未画出的能力，组件库厚度达到本轮工具栏门槛 | 高 |
| PT025-SRC-012 | 搜索与空态 | `pt025-palette-search` / `pt025-palette-search-clear` / `pt025-palette-empty-state` | 搜索“表格”进入 matched，搜索“不存在组件”进入 empty，点击清除恢复 idle | 搜索不是静态输入框，具备真实过滤、空态和恢复路径 | 高 |
| PT025-SRC-013 | 分组折叠 | `pt025-palette-group-layout-toggle` | 第一次点击 `collapsed + aria-expanded=false`，第二次点击 `expanded + aria-expanded=true` | 分组标题不是假控件，测试平台可回放折叠/展开 | 高 |

## 3. 竞品吸收点

| 竞品 | 吸收点 | PT-025 落点 | 证据 |
|---|---|---|---|
| 金蝶表单设计器 | 企业后台密度、中文控件名、三列控件库 | 三列工具卡、中文分组、说明进入 tooltip | PT025-SRC-004 |
| DevExpress | Field List / Explorer / Properties 分离 | 组件、字段、大纲、问题、版本、数据六入口 | PT025-SRC-002 / 003 |
| Visual Studio Form Designer | Toolbox + Document Outline + Properties 工具窗心智 | Activity Bar + Dock Panel + 折叠 Inspector | PT025-SRC-001 |
| Power Apps / Retool / Appsmith | Insert / Data / Tree / Issues 分离 | 组件入口与字段入口分离，问题列表独立 | PT025-SRC-002 |

## 4. 证据边界

- 当前证据证明 PT-025 工具栏区域合格。
- 当前证据不能证明整体表单设计器完成。
- 当前证据不能证明已超过金蝶、DevExpress 或 Visual Studio。
- 竞品截图级对比、任务效率计量、人工终审仍属于后续 S7 条件。
