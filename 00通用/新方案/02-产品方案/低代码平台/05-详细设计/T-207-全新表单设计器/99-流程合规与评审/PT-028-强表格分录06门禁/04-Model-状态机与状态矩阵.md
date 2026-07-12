# PT-028 强表格/分录：04-Model-状态机与状态矩阵

版本：v1.0  
日期：2026-07-10  
对象：`T-207-表单设计器-09原型.html#pt-028`

## 1. 状态机

```text
S0 table-selected
  -> click column header
S1 column-selected
  -> click resize handle
S2 column-resized
  -> pick field source + click column drop target
S3 column-created
  -> click detail toggle
S4 detail-open
  -> pick Level 1 detail + click detail zone
S5 detail-level1-created
  -> pick Level 2 detail + click level2 target
S6 level2-rejected
  -> click analyzer quick fix
S7 detail-depth-fixed
```

回退规则：

```text
非法投放 -> S6，不允许进入 S3/S5，不允许写 Schema
Quick Fix -> S7，保持 detailDepth=1
列宽抓手 -> S2，允许写 column.layout.width
字段投放 -> S3，允许写 columns[]
```

## 2. 状态矩阵

| 状态 | 触发 | DOM 断言 | Inspector | Schema |
|---|---|---|---|---|
| S0 table-selected | 初始加载 | `data-selected-node=table` | 表格页 | `data-schema-mutated=false` |
| S1 column-selected | 点击列头 | `data-selected-column=qty` | 列页，`dataIndex=qty` | 不改 Schema |
| S2 column-resized | 点击列宽抓手 | `data-last-resize-handle=...qty` | 列宽变为 120px | `data-schema-mutated=true` |
| S3 column-created | 字段投放到列落点 | `data-column-added=deliveryDate` | 列页 | `data-schema-mutated=true` |
| S4 detail-open | 点击行明细展开 | `data-detail-open=true` | 明细页 | 不改 Schema |
| S5 detail-level1-created | Level 1 明细投放 | `data-detail-depth=1` | 明细页 | `data-schema-mutated=true` |
| S6 level2-rejected | Level 2 明细投放 | `data-drop-state=illegal` | 明细页 | `data-schema-mutated=false` |
| S7 detail-depth-fixed | Quick Fix | `data-last-quickfix=TABLE_DETAIL_DEPTH_EXCEEDED` | 明细页 | 保持 `detailDepth=1` |

## 3. 交互合同

| 合同 | 抓手 |
|---|---|
| 表格根节点 | `pt028-node-entry-table` |
| 列头 | `pt028-table-column-header-entry_sales_items-{columnId}` |
| 列宽抓手 | `pt028-table-column-resize-entry_sales_items-{columnId}` |
| 列投放点 | `pt028-column-drop-entry_sales_items-after-deliveryDate` |
| 冻结线 | `pt028-freeze-line-entry_sales_items-left/right` |
| 行明细展开 | `pt028-table-detail-toggle-entry_sales_items-row_001` |
| 一层明细设计区 | `pt028-detail-design-entry_sales_items` |
| 一层明细投放点 | `pt028-detail-drop-entry_sales_items-level1` |
| 二层非法目标 | `pt028-drop-entry_sales_items-level2` |
| Analyzer Quick Fix | `pt028-analyzer-quickfix-detail-depth` |

## 4. 阻断规则

| 规则 | 阶段 | 判定 |
|---|---|---|
| TABLE_DETAIL_DEPTH_EXCEEDED | P0 | Level 2 投放必须 rejected |
| TABLE_COLUMN_BINDING_MISSING | P0 | 字段列必须有 `dataIndex` / `fieldCode` |
| TABLE_ROWKEY_MISSING | P0 | EntryTable 必须显示 `rowKey=entryId` |
| TABLE_FREEZE_WIDTH_EXCEEDED | P0/P1 | 冻结宽度超过阈值进入 Analyzer |
| TABLE_VIRTUAL_SCROLL_REQUIRED | P0/P1 | 大数据态必须显示虚拟窗口 |

## 5. 自动化测试路径

```text
1. 打开 #pt-028
2. 点击 pt028-table-column-header-entry_sales_items-qty
3. 点击 pt028-table-column-resize-entry_sales_items-qty
4. 点击 pt028-source-field-delivery-date
5. 点击 pt028-column-drop-entry_sales_items-after-deliveryDate
6. 点击 pt028-table-detail-toggle-entry_sales_items-row_001
7. 点击 pt028-source-detail-table
8. 点击 pt028-detail-drop-entry_sales_items-level1
9. 点击 pt028-source-level2-table
10. 点击 pt028-drop-entry_sales_items-level2
11. 点击 pt028-analyzer-quickfix-detail-depth
```
