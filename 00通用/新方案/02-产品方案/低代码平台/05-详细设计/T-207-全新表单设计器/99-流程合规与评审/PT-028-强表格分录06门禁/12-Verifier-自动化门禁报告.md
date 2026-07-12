# PT-028 强表格/分录：12-Verifier-自动化门禁报告

版本：v1.0  
日期：2026-07-10  
验证对象：`http://127.0.0.1:8101/T-207-表单设计器-09原型.html#pt-028`  
原型文件：`D:\mywork\techdoc\00业务文档\系统设计\新方案\02-产品方案\低代码平台\05-详细设计\T-207-全新表单设计器\09-交互原型与视觉规范\T-207-表单设计器-09原型.html`

## 1. 验证结论

结论：通过 PT-028 强表格/分录自动化门禁。

证据边界：本报告只证明 PT-028 强表格/分录区域合格；不证明整个表单设计器完成，不证明已超过金蝶、DevExpress、AG Grid 或 Visual Studio。

## 2. 静态检查

| 检查项 | 结果 |
|---|---|
| 内嵌脚本抽取 | 通过，`count=1` |
| `node --check` | 通过 |
| 乱码哨兵 | 通过，未命中 question-mark runs、replacement character 或常见 mojibake 样本 |
| 控制台 warn/error | 0 |

## 3. 结构检查结果

| 检查项 | 结果 |
|---|---|
| PT-028 导航入口 | 通过 |
| PT-028 根节点 | 通过 |
| 表格资产源数量 | 9 |
| 分录字段源数量 | 4 |
| 列头数量 | 7 |
| 列宽抓手数量 | 5 |
| 投放目标数量 | 3 |
| Inspector 页签数量 | 5 |
| Analyzer issue 数量 | 3 |
| 初始 detail 区 | hidden=true |
| 初始 Schema 变化 | false |

## 4. 自动化回放结果

```text
column select:
- click pt028-table-column-header-entry_sales_items-qty
- data-selected-column=qty
- activePanel=column
- columnDataIndex=qty
- columnEditor=NumberInput

column resize:
- click pt028-table-column-resize-entry_sales_items-qty
- data-schema-mutated=true
- data-last-resize-handle=pt028-table-column-resize-entry_sales_items-qty
- headerWidth=120px
- inspectorWidth=120px
- handleState=used

field to column:
- click pt028-source-field-delivery-date
- click pt028-column-drop-entry_sales_items-after-deliveryDate
- data-column-added=deliveryDate
- targetState=legal
- target schema mutated=true

detail:
- click pt028-table-detail-toggle-entry_sales_items-row_001
- detailHidden=false
- data-detail-open=true
- activePanel=detail

Level 1 detail:
- click pt028-source-detail-table
- click pt028-detail-drop-entry_sales_items-level1
- data-detail-depth=1

Level 2 rejection:
- click pt028-source-level2-table
- click pt028-drop-entry_sales_items-level2
- level2State=illegal
- level2Mutated=false
- rejectState=rejected
- rejectType=TABLE_DETAIL_DEPTH_EXCEEDED
- root schema mutated=false

Quick Fix:
- click pt028-analyzer-quickfix-detail-depth
- data-detail-depth=1
- data-last-quickfix=TABLE_DETAIL_DEPTH_EXCEEDED
- rejectHidden=true
- resultState=updated
```

## 5. 本轮发现并修复的问题

| 问题 | 修复 |
|---|---|
| PT-028 操作结果栏在原型根节点外，状态机无法写入结果提示 | 将结果栏查询作用域提升到 `#pt-028` section |
| 顶部命令在原型根外，初版状态机未接管 | 将命令按钮绑定作用域提升到 `#pt-028` section |
| PowerShell 使用 `&&` 触发解析失败 | 改为分步执行静态检查 |

## 6. 未覆盖项

- 未做真实坐标拖拽稳定性测试。
- 未做竞品截图级密度与布局对比。
- 未做复杂表头、Excel-like 复制粘贴、列菜单完整交互。
- 未做单元格真实输入编辑生命周期。

## 7. 门禁判定

PT-028 强表格/分录：通过。  
下一步：继续做下一个强表格子部件，建议优先处理“列菜单与列管理”或“单元格编辑器与键盘录入”，仍沿用本文门禁。
