# PT-028 强表格/分录：02-Evidence-证据台账

版本：v1.0  
日期：2026-07-10  
对象：`T-207-表单设计器-09原型.html#pt-028`

## 1. 证据边界

本台账证明 PT-028 强表格/分录专项原型已覆盖本轮 P0 设计器能力：列设计、列宽抓手、字段投放、冻结线、行操作、汇总、虚拟滚动、一层明细、二层嵌套阻断、Inspector 同步和 Analyzer 反馈。

本台账不证明整个表单设计器完成，也不证明整体超过金蝶、DevExpress、Visual Studio、AG Grid 或其他商业软件。超过竞品必须在完整工作台闭环、截图级对标和人工终审后判定。

## 2. 标杆输入

| source_id | 标杆 | 吸收点 | PT-028 转化 |
|---|---|---|---|
| B-AGGRID-001 | AG Grid Enterprise | Master-Detail、虚拟滚动、列固定、列状态 | `virtualScroll=on`、Level 1 Detail、冻结线、列宽状态 |
| B-DEVEXPRESS-001 | DevExpress / DevExtreme DataGrid | 主从表、列属性、设计器式 Inspector | 右侧表格/列 Inspector，Analyzer 问题定位 |
| B-KINGDEE-001 | 金蝶 BOS / 云苍穹 | 单据体、分录、业务字段绑定 | EntryTable 从分录字段投放生成列 |
| B-KENDO-001 | Kendo / Telerik Grid | Hierarchy Grid、列菜单 | P0 列菜单入口，P1 深化 |
| B-SYNCFUSION-001 | Syncfusion Grid | childGrid、列选择器、虚拟滚动 | 一层 DetailTable 与性能状态 |
| B-VS-001 | Visual Studio Form Designer | 选中框、属性窗、错误列表 | 列头选择、抓手、Inspector、Analyzer |

## 3. 本轮直接证据

| evidence_id | 类型 | 观察 | 结论 |
|---|---|---|---|
| E-PT028-001 | DOM | `pt-028-table-prototype` 可见 | PT-028 专项图件已落入原型 |
| E-PT028-002 | DOM | 表格资产源数量 9，字段源数量 4 | 左侧不是空工具栏，具备字段、明细、列模板入口 |
| E-PT028-003 | DOM | 列头数量 7，列宽抓手 5 | 支持列选择和列宽设计抓手 |
| E-PT028-004 | DOM | 投放目标数量 3 | 覆盖列投放、一层明细投放、二层非法目标 |
| E-PT028-005 | DOM | Inspector 页签 5 | 表格、列、编辑、明细、性能分区存在 |
| E-PT028-006 | DOM | Analyzer issue 数量 3 | 包含正常状态、性能状态、明细层级错误 |
| E-PT028-007 | 浏览器点击 | 点击数量列头后 `data-selected-column=qty`，Inspector 切到列页 | 列选择与 Inspector 同步 |
| E-PT028-008 | 浏览器点击 | 点击数量列宽抓手后列宽从 96px 变为 120px，`data-schema-mutated=true` | 列宽抓手真实生效 |
| E-PT028-009 | 浏览器点击 | 字段 `deliveryDate` 投放到列落点后 `data-column-added=deliveryDate` | 分录字段可生成 TableColumn |
| E-PT028-010 | 浏览器点击 | 点击行明细展开后 Level 1 明细区显示 | 一层主子明细可设计 |
| E-PT028-011 | 浏览器点击 | 一层明细表格投放到明细区后合法 | DetailPanel / DetailTable Level 1 可发布 |
| E-PT028-012 | 浏览器点击 | 二层明细投放到 Level 2 目标后 `data-drop-state=illegal`，`data-schema-mutated=false` | P0 二层嵌套被阻断且不误写 Schema |
| E-PT028-013 | 浏览器点击 | Quick Fix 后 `data-last-quickfix=TABLE_DETAIL_DEPTH_EXCEEDED`，拒绝提示隐藏 | Analyzer 修复路径存在 |
| E-PT028-014 | 控制台 | warn/error 日志为 0 | 本轮验证无浏览器控制台异常 |

## 4. 任务价值映射

| 任务 | 用户价值 | 证据 |
|---|---|---|
| 设计销售分录表格 | 实施顾问能从 BO 分录字段组织企业单据体 | E-PT028-002 / E-PT028-009 |
| 调整列宽和列属性 | 能处理字段长短、冻结、密度和录入效率 | E-PT028-003 / E-PT028-008 |
| 配置主子明细 | 能表达批次、序列号、交付计划等 Level 1 明细 | E-PT028-010 / E-PT028-011 |
| 阻断过深嵌套 | 防止 P0 阶段误做不可治理的多层表格 | E-PT028-012 / E-PT028-013 |
| 自动化测试模拟人操作 | 测试平台可点列、抓手、投放点、明细 toggle 和 Quick Fix | E-PT028-007 至 E-PT028-013 |

## 5. 已知证据缺口

- 仍未做 AG Grid / DevExpress / 金蝶的截图级逐像素对比。
- 坐标拖拽稳定性未作为唯一门禁路径；本轮使用“点击抓起 / 点击落点”的人机等价路径。
- 复杂表头、列组、Excel-like 复制粘贴属于 P1/P2，本轮只显示禁用或入口，不声明完成。
