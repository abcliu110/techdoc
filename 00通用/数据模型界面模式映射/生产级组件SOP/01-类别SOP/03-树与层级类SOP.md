# 03 树与层级类生产级组件类别 SOP

> 组件数：20
>
> 关注域：层级路径、父子关系、继承范围与循环约束
>
> 风险初始分布：R1 13 / R2 7 / R3 0

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：层级路径、父子关系、继承范围与循环约束。
- 类别状态模型：展开集、选中节点、焦点节点、加载状态、父子路径、继承与拖拽目标。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 懒加载失败或目标父节点不可访问
- 移动后形成自身或间接循环
- 过滤、虚拟化或重载后焦点和路径丢失

## 3. 强制验证

- 验证 aria tree 模式、方向键、Home/End、展开和焦点语义
- 验证循环、无权父节点、懒加载失败与撤销
- 验证过滤、移动和重载前后的稳定节点身份与路径

## 4. 性能与规模基线

以 10,000 节点、10 层深度和 200 个展开节点为基准；展开、定位和键盘移动的可见反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若树结构直接修改组织、菜单权限、资源继承或生产依赖，至少 R2；越权或跨租户影响时为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [树视图](../02-组件SOP/03-树与层级类/03-tree-view.md) | `03:tree-view` | B | R1 | Draft / 未认证 |
| [复选树](../02-组件SOP/03-树与层级类/03-checkbox-tree.md) | `03:checkbox-tree` | B | R1 | Draft / 未认证 |
| [单选树](../02-组件SOP/03-树与层级类/03-radio-tree.md) | `03:radio-tree` | B | R1 | Draft / 未认证 |
| [懒加载树](../02-组件SOP/03-树与层级类/03-lazy-tree.md) | `03:lazy-tree` | B | R1 | Draft / 未认证 |
| [虚拟滚动树](../02-组件SOP/03-树与层级类/03-virtual-tree.md) | `03:virtual-tree` | B | R1 | Draft / 未认证 |
| [可搜索树](../02-组件SOP/03-树与层级类/03-search-tree.md) | `03:search-tree` | B | R1 | Draft / 未认证 |
| [可拖拽树](../02-组件SOP/03-树与层级类/03-draggable-tree.md) | `03:draggable-tree` | B | R2 | Draft / 未认证 |
| [可编辑树](../02-组件SOP/03-树与层级类/03-editable-tree.md) | `03:editable-tree` | B | R2 | Draft / 未认证 |
| [带上下文菜单的树](../02-组件SOP/03-树与层级类/03-context-tree.md) | `03:context-tree` | B | R1 | Draft / 未认证 |
| [文件目录树](../02-组件SOP/03-树与层级类/03-file-tree.md) | `03:file-tree` | B | R2 | Draft / 未认证 |
| [组织架构树](../02-组件SOP/03-树与层级类/03-org-tree.md) | `03:org-tree` | B | R2 | Draft / 未认证 |
| [分类树](../02-组件SOP/03-树与层级类/03-category-tree.md) | `03:category-tree` | B | R1 | Draft / 未认证 |
| [地区层级树](../02-组件SOP/03-树与层级类/03-region-tree.md) | `03:region-tree` | B | R1 | Draft / 未认证 |
| [菜单树](../02-组件SOP/03-树与层级类/03-menu-tree.md) | `03:menu-tree` | B | R2 | Draft / 未认证 |
| [权限树](../02-组件SOP/03-树与层级类/03-permission-tree.md) | `03:permission-tree` | B | R2 | Draft / 未认证 |
| [依赖树](../02-组件SOP/03-树与层级类/03-dependency-tree.md) | `03:dependency-tree` | B | R2 | Draft / 未认证 |
| [关系层级浏览器](../02-组件SOP/03-树与层级类/03-relationship-tree.md) | `03:relationship-tree` | B | R1 | Draft / 未认证 |
| [文档大纲树](../02-组件SOP/03-树与层级类/03-outline-tree.md) | `03:outline-tree` | B | R1 | Draft / 未认证 |
| [思维导图树](../02-组件SOP/03-树与层级类/03-mindmap-tree.md) | `03:mindmap-tree` | B | R1 | Draft / 未认证 |
| [谱系树](../02-组件SOP/03-树与层级类/03-genealogy-tree.md) | `03:genealogy-tree` | B | R1 | Draft / 未认证 |
