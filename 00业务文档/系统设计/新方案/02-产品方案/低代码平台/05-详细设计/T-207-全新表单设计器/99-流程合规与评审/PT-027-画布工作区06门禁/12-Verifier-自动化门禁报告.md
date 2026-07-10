# PT-027 画布工作区：12-Verifier-自动化门禁报告

版本：v1.0  
日期：2026-07-10  
验证对象：`http://127.0.0.1:8101/T-207-表单设计器-09原型.html?<cache-bust>#pt-027`  
原型文件：`D:\mywork\techdoc\00业务文档\系统设计\新方案\02-产品方案\低代码平台\05-详细设计\T-207-全新表单设计器\09-交互原型与视觉规范\T-207-表单设计器-09原型.html`

## 1. 验证结论

结论：通过 PT-027 画布工作区自动化门禁。

证据边界：本报告只证明 PT-027 画布区域合格；不证明整个表单设计器完成，不证明已超过金蝶、DevExpress 或 Visual Studio。

## 2. 自动化检查结果

| 检查项 | 结果 |
|---|---|
| PT-027 导航入口 | 通过 |
| 画布根节点可见 | 通过 |
| 画布资产源数量 | 8 |
| 投放目标数量 | 2 |
| 抓手数量 | 10 |
| 缩放命令 | 通过，`data-zoom=110` |
| 断点命令 | 通过，`data-breakpoint=desktop-1280` |
| 长画布镜像命令 | 通过，`pt027-sticky-zoom-in` / `pt027-sticky-breakpoint-1280` 可见并接入同一状态机 |
| 字段合法投放 | 通过 |
| 表格列非法投放 | 通过 |
| 非法投放 Schema 变化 | `false` |
| 命令条溢出 | 已修复 |
| 非法投放结果被选中覆盖 | 已修复 |

## 3. 关键断言

```text
structure:
- pt-027 root visible = true
- pt027 sources = 8
- pt027 drop targets = 2
- pt027 handles = 10
- pt027 canvas inspector visible = true

visibility after fix:
- pt027-zoom-in visible = true
- pt027-breakpoint-1280 visible = true
- pt027-source-field-customer visible = true
- pt027-dropzone-header-grid-1-2 visible = true
- pt027-handle-section-header-resize-e visible = true
- pt027-handle-split-main-resize visible = true

commands:
- pt027-zoom-in initial visible=true
- pt027-sticky-zoom-in visible=true
- pt027-sticky-breakpoint-1280 visible=true
- click pt027-sticky-zoom-in -> data-zoom=110, zoomLabel=110%
- click pt027-sticky-breakpoint-1280 -> data-breakpoint=desktop-1280

legal drop:
- pick pt027-source-field-date
- target pt027-dropzone-header-grid-1-2
- gridDropState=legal
- gridLastDropKind=field

illegal drop:
- pick pt027-source-grid-layout
- target pt027-table-column-dropzone
- tableDropState=illegal
- tableSchemaMutated=false
- rootSchemaMutated=false
- rejectState=rejected
- resultState=idle
```

## 4. 本轮验证中发现并修复的问题

| 问题 | 修复 |
|---|---|
| PT-027 初版画布过宽，右侧 resize 抓手不可见 | 收敛画布缩尺宽度和左右栏宽度 |
| 命令条横向溢出，缩放按钮点击不稳定 | 命令条改为可换行紧凑布局 |
| 非法投放后事件继续冒泡，结果被节点选中覆盖 | 投放目标 click/drop/keydown 阶段阻止冒泡 |
| 深层画布操作后顶部命令离开视口 | 增加底部镜像命令并接入同一画布状态机 |

## 5. 未覆盖项

以下不阻断 PT-027 本轮合格，但进入后续增强或工作台全局门禁：

- 原生坐标拖拽在多滚动容器下的稳定性。
- 真实画布滚动、缩放、吸附线随动的像素级验证。
- 与 PT-025 工具栏和 PT-026 Inspector 的端到端联动。
- 竞品截图级对比和人工终审。

## 6. 门禁判定

PT-027 画布工作区：通过。  
下一步：进入下一个设计器核心区域，建议优先处理强表格 / 分录设计区域，并沿用“可见控件 + 唯一抓手 + 可点击回放 + 非法状态不误写 Schema”的门禁要求。
