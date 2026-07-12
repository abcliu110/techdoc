# PT-026 Inspector：12-Verifier-自动化门禁报告

版本：v1.0  
日期：2026-07-10  
验证对象：`http://127.0.0.1:8101/T-207-表单设计器-09原型.html?<cache-bust>#pt-026`

## 1. 验证结论

结论：通过 PT-026 Inspector 区域自动化门禁。

证据边界：只证明 PT-026 Inspector 合格，不证明整个表单设计器完成，不证明超过竞品。

## 2. 自动化检查结果

| 检查项 | 结果 |
|---|---|
| 六页签点击切换 | 通过 |
| 每次仅一个 panel 可见 | 通过 |
| inactive panel `hidden + aria-hidden=true` | 通过 |
| `role=tab` 数量 | 6 |
| `role=tabpanel` 数量 | 6 |
| 属性行数量 | 18 |
| 可编辑控件数量 | 15 |
| 关键抓手全局唯一 | 通过 |
| 标题编辑写 patch | 通过 |
| 布局 span 步进 | 通过 |
| span 同步画布节点 | 通过 |
| 属性搜索 | `permission -> hits=3` |
| 搜索隐藏行 | 15 |
| Inspector 收起 | 通过 |
| Inspector 展开 | 通过 |
| 页面控制台 warn/error | 0 |

## 3. 关键断言

```text
tabs:
- business/layout/style/rule/permission/event selected=true 时，对应 panel active
- 每次 active panel count = 1

title patch:
- input pt026-prop-field-customer-title = 客户名称
- pt026-patch-bar[data-state=dirty]
- pt026-patch-summary = SchemaPatch: title = 客户名称
- pt026-save-patch disabled = false

layout patch:
- click pt026-action-span-inc
- pt026-prop-field-customer-layout-span = 3
- pt026-designer-node-field-customer[data-layout-span=3]
- pt026-patch-summary = SchemaPatch: layout.span = 3

search:
- query = permission
- pt026-inspector-search-hit-count = hits=3
- visible rows = 3
- hidden rows = 15

collapse/expand:
- collapse -> root/shell/rail = collapsed
- expand -> root/shell/rail = expanded
```

## 4. 未覆盖项

- 全控件类型属性模板矩阵。
- 真实 Undo/Redo 命令栈。
- 规则表达式编辑器和 Quick Fix。
- Inspector auto-hide / pin 的完整桌面级停靠行为。
- 竞品截图级属性面板对比与人工终审。

## 5. 门禁判定

PT-026 Inspector 区域：通过。  
下一步：进行外部评审；若无 P0/P1 阻断，进入画布工作台或表格设计器区域。