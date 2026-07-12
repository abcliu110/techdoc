# PT-027 画布工作区：04-Model-状态机与状态矩阵

版本：v1.0  
日期：2026-07-10  
范围：中央画布工作区、画布资产、设计表面、选择抓手、投放目标。

## 1. 状态机

```text
idle
  -> select-node
  -> pick-asset
  -> toggle-grid
  -> toggle-rulers
  -> toggle-snap
  -> change-zoom
  -> change-breakpoint

select-node
  -> selected
  -> inspector-synced

pick-asset
  -> drop-legal
  -> drop-illegal

drop-legal
  -> schema-mutated=true
  -> result=created

drop-illegal
  -> schema-mutated=false
  -> reject=visible

resize-handle
  -> handle-state=used
  -> schema-mutated=true
```

## 2. 状态矩阵

| 状态 | 触发 | DOM 合同 | 视觉反馈 | 恢复路径 |
|---|---|---|---|---|
| idle | 初始加载 | `data-zoom=100`、`data-breakpoint=desktop-1440`、`data-schema-mutated=false` | 画布、标尺、网格、选中框可见 | 任意操作进入对应状态 |
| grid-off | 点击网格 | `data-grid=off` | 背景网格隐藏 | 再次点击网格 |
| rulers-off | 点击标尺 | `data-rulers=off` | 标尺隐藏 | 再次点击标尺 |
| snap-off | 点击吸附 | `data-snap=off`、Inspector 吸附字段同步 | 吸附状态显示 off | 再次点击吸附 |
| zoom-change | 点击 `pt027-zoom-in/out` | `data-zoom` 与 `pt027-zoom-label` 同步 | 页面缩放 | 反向点击 |
| breakpoint-change | 点击断点 | `data-breakpoint` 与 page `data-breakpoint` 同步 | 设计面宽度变化 | 点击其他断点 |
| node-selected | 点击画布节点 | 节点 `data-selected=true`，Inspector 当前节点同步 | 蓝色选中框 | 点击其他节点 |
| handle-used | 点击移动或 resize 抓手 | `data-last-handle=<handle>`、抓手 `data-handle-state=used` | 底部结果显示抓手操作 | 下一次操作覆盖 |
| drop-legal | 字段投放到 Grid 单元 | 目标 `data-drop-state=legal`、`data-schema-mutated=true` | 合法投放反馈 | 继续编辑 |
| drop-illegal | 布局组件投放到表格列 | 目标 `data-drop-state=illegal`、`data-schema-mutated=false`、reject 可见 | 拒绝投放反馈 | 选择合法目标 |

## 3. P0 覆盖要求

| P0 要求 | 覆盖 |
|---|---|
| 画布主体可见 | `pt027-design-surface-page` |
| 关键布局容器可见 | Grid / Tabs / Split / Sticky / EntryTable |
| 选择态可见且可测 | `pt027-selection-box-section-header` |
| 抓手可见且可测 | `pt027-handle-section-header-*` |
| 合法投放可测 | `pt027-dropzone-header-grid-1-2` |
| 非法投放不误写 Schema | `pt027-table-column-dropzone` |
| 断点和缩放可测 | `pt027-breakpoint-*` / `pt027-zoom-*` |
| 与 Inspector 同步 | `pt027-inspector-*` |
