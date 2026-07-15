# 01 布局类生产级组件类别 SOP

> 组件数：25
>
> 关注域：空间、阅读顺序与工作上下文
>
> 风险初始分布：R1 22 / R2 3 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：空间、阅读顺序与工作上下文。
- 类别状态模型：容器尺寸、断点、区域可见性、活动区域、用户布局偏好。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 窄屏或缩放后关键操作不可达
- 折叠、停靠或切换时未保存上下文丢失
- 视觉顺序与 DOM 阅读顺序不一致

## 3. 强制验证

- 验证所有断点的内容可达、滚动可达与操作目标尺寸
- 验证 DOM 阅读顺序、Tab 顺序和视觉顺序一致
- 验证折叠、切换、恢复后上下文与焦点不丢失

## 4. 性能与规模基线

在 1440x900、1024x768、390x844 及相邻断点执行布局切换；可见反馈 p95 不高于 100ms，组件自身不得产生持续超过 50ms 的长任务。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若持久化个人布局、跨窗口同步、承载未保存业务编辑或影响权限可见性，至少升级为 R2。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [栅格布局](../02-组件SOP/01-布局类/01-grid-layout.md) | `01:grid-layout` | B | R1 | Draft / 未认证 |
| [行列布局](../02-组件SOP/01-布局类/01-row-column.md) | `01:row-column` | B | R1 | Draft / 未认证 |
| [Flex 弹性布局](../02-组件SOP/01-布局类/01-flex-layout.md) | `01:flex-layout` | B | R1 | Draft / 未认证 |
| [分栏布局](../02-组件SOP/01-布局类/01-multi-column.md) | `01:multi-column` | B | R1 | Draft / 未认证 |
| [分割面板](../02-组件SOP/01-布局类/01-split-pane.md) | `01:split-pane` | B | R1 | Draft / 未认证 |
| [可调整尺寸面板](../02-组件SOP/01-布局类/01-resizable-panel.md) | `01:resizable-panel` | B | R1 | Draft / 未认证 |
| [停靠布局](../02-组件SOP/01-布局类/01-dock-layout.md) | `01:dock-layout` | B | R1 | Draft / 未认证 |
| [标签页布局](../02-组件SOP/01-布局类/01-tabs-layout.md) | `01:tabs-layout` | B | R1 | Draft / 未认证 |
| [折叠面板](../02-组件SOP/01-布局类/01-accordion.md) | `01:accordion` | B | R1 | Draft / 未认证 |
| [卡片布局](../02-组件SOP/01-布局类/01-card-layout.md) | `01:card-layout` | B | R1 | Draft / 未认证 |
| [瀑布流布局](../02-组件SOP/01-布局类/01-masonry.md) | `01:masonry` | B | R1 | Draft / 未认证 |
| [仪表盘布局](../02-组件SOP/01-布局类/01-dashboard.md) | `01:dashboard` | B | R1 | Draft / 未认证 |
| [拖拽网格布局](../02-组件SOP/01-布局类/01-drag-grid.md) | `01:drag-grid` | B | R1 | Draft / 未认证 |
| [自由画布布局](../02-组件SOP/01-布局类/01-free-canvas.md) | `01:free-canvas` | B | R1 | Draft / 未认证 |
| [响应式布局](../02-组件SOP/01-布局类/01-responsive-layout.md) | `01:responsive-layout` | B | R1 | Draft / 未认证 |
| [自适应断点布局](../02-组件SOP/01-布局类/01-adaptive-breakpoint.md) | `01:adaptive-breakpoint` | B | R1 | Draft / 未认证 |
| [嵌套容器布局](../02-组件SOP/01-布局类/01-nested-container.md) | `01:nested-container` | B | R1 | Draft / 未认证 |
| [可配置页面布局](../02-组件SOP/01-布局类/01-configurable-page.md) | `01:configurable-page` | B | R2 | Draft / 未认证 |
| [多栏编辑器布局](../02-组件SOP/01-布局类/01-multi-column-editor.md) | `01:multi-column-editor` | B | R1 | Draft / 未认证 |
| [全屏 / 沉浸式布局](../02-组件SOP/01-布局类/01-immersive.md) | `01:immersive` | B | R1 | Draft / 未认证 |
| [主从分屏布局](../02-组件SOP/01-布局类/01-master-detail.md) | `01:master-detail` | B | R1 | Draft / 未认证 |
| [侧边栏布局](../02-组件SOP/01-布局类/01-sidebar.md) | `01:sidebar` | B | R1 | Draft / 未认证 |
| [抽屉工作区布局](../02-组件SOP/01-布局类/01-drawer-workspace.md) | `01:drawer-workspace` | B | R1 | Draft / 未认证 |
| [多窗口工作区](../02-组件SOP/01-布局类/01-multi-window.md) | `01:multi-window` | B | R2 | Draft / 未认证 |
| [可保存工作区布局](../02-组件SOP/01-布局类/01-saved-workspace.md) | `01:saved-workspace` | B | R2 | Draft / 未认证 |
