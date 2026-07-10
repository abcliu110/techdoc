# PT-026 Inspector：04-Model-状态机与状态矩阵

版本：v1.0  
日期：2026-07-10

## 1. 对象模型

```text
InspectorRoot
- state: expanded | collapsed
- selectedNode: field_customer
- schemaPath: components.field_customer
- fieldPath: salesOrder.customerId
- activeTab: business | layout | style | rule | permission | event
- patchState: clean | dirty | saved
- searchQuery: string
```

## 2. 页签状态

| 状态 | 触发 | 结果 |
|---|---|---|
| business active | 点击 `pt026-tab-business` | `pt026-panel-business` active，其他 panel hidden |
| layout active | 点击 `pt026-tab-layout` | `pt026-panel-layout` active |
| style active | 点击 `pt026-tab-style` | `pt026-panel-style` active |
| rule active | 点击 `pt026-tab-rule` | `pt026-panel-rule` active |
| permission active | 点击 `pt026-tab-permission` | `pt026-panel-permission` active |
| event active | 点击 `pt026-tab-event` | `pt026-panel-event` active |

## 3. 属性编辑状态

| 事件 | 前置 | 输出 |
|---|---|---|
| 修改标题 | business tab active | `SchemaPatch: title = <value>`，patch dirty，保存按钮可用 |
| 点击 span + | layout tab active | `layout.span` +1，画布选中节点同步 `data-layout-span` |
| 搜索属性 | 任意 tab | 匹配行 `data-search-hidden=false`，计数写入 hit count |
| 保存属性 | patch dirty | patch clean，summary saved，保存按钮禁用 |

## 4. 折叠状态

| 状态 | root | shell | rail |
|---|---|---|---|
| expanded | `data-inspector-state=expanded` | `data-state=expanded` | `data-state=expanded` |
| collapsed | `data-inspector-state=collapsed` | `data-state=collapsed` | `data-state=collapsed` |

## 5. 阻断矩阵

| 门禁 | 通过条件 |
|---|---|
| 六页签真实 panel | 6 个 `role=tabpanel`，inactive 使用 `hidden + aria-hidden=true` |
| 属性可编辑 | 至少 12 个可编辑控件，本轮实际 15 个 |
| 属性行覆盖 | 至少 18 行，本轮实际 18 行 |
| SchemaPatch | 任一可编辑属性变化后 patch dirty |
| 画布同步 | layout span 修改同步到选中节点 |
| 搜索过滤 | query 后 hit count 与可见行一致 |
| 折叠恢复 | root/shell/rail 三处状态一致 |
| 自动化抓手 | 关键 `pt026-*` testid 全局唯一 |