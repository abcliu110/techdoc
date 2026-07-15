# 15 导航与工作区类生产级组件类别 SOP

> 组件数：20
>
> 关注域：路由身份、工作区上下文、未保存状态与返回路径
>
> 风险初始分布：R1 14 / R2 6 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：路由身份、工作区上下文、未保存状态与返回路径。
- 类别状态模型：当前位置、历史栈、活动工作区、打开项、脏状态、权限可见性与恢复位置。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 目标失效或无权访问
- 跳转造成未保存工作丢失
- 历史返回、深链接或多工作区上下文错误

## 3. 强制验证

- 验证深链接、前进后退、刷新和权限变化后的路由一致性
- 验证未保存拦截、关闭恢复和焦点返回
- 验证菜单、标签、命令面板和搜索的键盘语义

## 4. 性能与规模基线

以 500 个可发现入口和 20 个已打开工作项为基准；搜索、切换和返回反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若持久化工作区、执行命令、暴露权限入口或跨窗口同步状态，至少 R2。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [多级菜单](../02-组件SOP/15-导航与工作区类/15-multi-level-menu.md) | `15:multi-level-menu` | B | R1 | Draft / 未认证 |
| [动态路由菜单](../02-组件SOP/15-导航与工作区类/15-dynamic-route-menu.md) | `15:dynamic-route-menu` | B | R1 | Draft / 未认证 |
| [权限菜单](../02-组件SOP/15-导航与工作区类/15-permission-menu.md) | `15:permission-menu` | B | R2 | Draft / 未认证 |
| [Mega Menu](../02-组件SOP/15-导航与工作区类/15-mega-menu.md) | `15:mega-menu` | B | R1 | Draft / 未认证 |
| [面包屑导航](../02-组件SOP/15-导航与工作区类/15-breadcrumb.md) | `15:breadcrumb` | B | R1 | Draft / 未认证 |
| [多标签页工作区](../02-组件SOP/15-导航与工作区类/15-tab-workspace.md) | `15:tab-workspace` | B | R2 | Draft / 未认证 |
| [命令面板](../02-组件SOP/15-导航与工作区类/15-command-palette.md) | `15:command-palette` | B | R2 | Draft / 未认证 |
| [全局搜索](../02-组件SOP/15-导航与工作区类/15-global-search.md) | `15:global-search` | B | R1 | Draft / 未认证 |
| [最近访问记录](../02-组件SOP/15-导航与工作区类/15-recent-visits.md) | `15:recent-visits` | B | R1 | Draft / 未认证 |
| [收藏夹](../02-组件SOP/15-导航与工作区类/15-favorites.md) | `15:favorites` | B | R1 | Draft / 未认证 |
| [快捷启动器](../02-组件SOP/15-导航与工作区类/15-quick-launcher.md) | `15:quick-launcher` | B | R1 | Draft / 未认证 |
| [步骤导航](../02-组件SOP/15-导航与工作区类/15-stepper.md) | `15:stepper` | B | R1 | Draft / 未认证 |
| [引导向导](../02-组件SOP/15-导航与工作区类/15-guided-tour.md) | `15:guided-tour` | B | R1 | Draft / 未认证 |
| [锚点目录](../02-组件SOP/15-导航与工作区类/15-anchor-toc.md) | `15:anchor-toc` | B | R1 | Draft / 未认证 |
| [文档大纲](../02-组件SOP/15-导航与工作区类/15-document-outline.md) | `15:document-outline` | B | R1 | Draft / 未认证 |
| [上下文菜单](../02-组件SOP/15-导航与工作区类/15-context-menu.md) | `15:context-menu` | B | R1 | Draft / 未认证 |
| [可配置工具栏](../02-组件SOP/15-导航与工作区类/15-configurable-toolbar.md) | `15:configurable-toolbar` | B | R2 | Draft / 未认证 |
| [Ribbon 功能区](../02-组件SOP/15-导航与工作区类/15-ribbon.md) | `15:ribbon` | B | R1 | Draft / 未认证 |
| [快捷键管理器](../02-组件SOP/15-导航与工作区类/15-shortcut-manager.md) | `15:shortcut-manager` | B | R2 | Draft / 未认证 |
| [工作区切换器](../02-组件SOP/15-导航与工作区类/15-workspace-switcher.md) | `15:workspace-switcher` | B | R2 | Draft / 未认证 |
