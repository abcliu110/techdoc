# 08 页面与低代码设计类生产级组件类别 SOP

> 组件数：20
>
> 关注域：设计态模型、运行态预览、版本、依赖与发布
>
> 风险初始分布：R1 0 / R2 14 / R3 6

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：设计态模型、运行态预览、版本、依赖与发布。
- 类别状态模型：设计树、选中节点、属性、撤销栈、校验、预览版本、发布版本与依赖。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 设计模型无效、依赖缺失或循环引用
- 预览与运行时语义不一致
- 发布冲突、部分发布或回滚版本不可用

## 3. 强制验证

- 验证设计模型版本化、迁移、撤销/重做和循环约束
- 验证预览只读隔离、危险动作不真实执行
- 验证发布前校验、版本差异、并发发布与可执行回滚

## 4. 性能与规模基线

以 500 个设计节点、50 层嵌套和 100 次撤销记录为基准；选中、移动和属性修改反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

数据源凭证、事件/动作执行、代码组件、Schema 或生产发布能力为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [页面设计器](../02-组件SOP/08-页面与低代码设计类/08-page-designer.md) | `08:page-designer` | B | R2 | Draft / 未认证 |
| [表单设计器](../02-组件SOP/08-页面与低代码设计类/08-form-designer.md) | `08:form-designer` | B | R2 | Draft / 未认证 |
| [报表设计器](../02-组件SOP/08-页面与低代码设计类/08-report-designer.md) | `08:report-designer` | B | R2 | Draft / 未认证 |
| [仪表盘设计器](../02-组件SOP/08-页面与低代码设计类/08-dashboard-designer.md) | `08:dashboard-designer` | B | R2 | Draft / 未认证 |
| [移动端页面设计器](../02-组件SOP/08-页面与低代码设计类/08-mobile-page-designer.md) | `08:mobile-page-designer` | B | R2 | Draft / 未认证 |
| [数据源设计器](../02-组件SOP/08-页面与低代码设计类/08-data-source-designer.md) | `08:data-source-designer` | B | R3 | Draft / 未认证 |
| [事件编排器](../02-组件SOP/08-页面与低代码设计类/08-event-designer.md) | `08:event-designer` | B | R3 | Draft / 未认证 |
| [动作设计器](../02-组件SOP/08-页面与低代码设计类/08-action-designer.md) | `08:action-designer` | B | R3 | Draft / 未认证 |
| [表达式编辑器](../02-组件SOP/08-页面与低代码设计类/08-expression-designer.md) | `08:expression-designer` | B | R2 | Draft / 未认证 |
| [主题设计器](../02-组件SOP/08-页面与低代码设计类/08-theme-designer.md) | `08:theme-designer` | B | R2 | Draft / 未认证 |
| [组件构建器](../02-组件SOP/08-页面与低代码设计类/08-component-builder.md) | `08:component-builder` | B | R3 | Draft / 未认证 |
| [页面模板管理器](../02-组件SOP/08-页面与低代码设计类/08-template-manager.md) | `08:template-manager` | B | R2 | Draft / 未认证 |
| [页面结构树](../02-组件SOP/08-页面与低代码设计类/08-page-tree.md) | `08:page-tree` | B | R2 | Draft / 未认证 |
| [导航设计器](../02-组件SOP/08-页面与低代码设计类/08-navigation-designer.md) | `08:navigation-designer` | B | R2 | Draft / 未认证 |
| [响应式断点设计器](../02-组件SOP/08-页面与低代码设计类/08-responsive-designer.md) | `08:responsive-designer` | B | R2 | Draft / 未认证 |
| [多设备运行预览](../02-组件SOP/08-页面与低代码设计类/08-runtime-preview.md) | `08:runtime-preview` | B | R2 | Draft / 未认证 |
| [Schema 编辑器](../02-组件SOP/08-页面与低代码设计类/08-schema-editor.md) | `08:schema-editor` | B | R3 | Draft / 未认证 |
| [页面版本管理器](../02-组件SOP/08-页面与低代码设计类/08-version-manager.md) | `08:version-manager` | B | R2 | Draft / 未认证 |
| [发布控制台](../02-组件SOP/08-页面与低代码设计类/08-publish-console.md) | `08:publish-console` | B | R3 | Draft / 未认证 |
| [设计系统管理器](../02-组件SOP/08-页面与低代码设计类/08-design-system-manager.md) | `08:design-system-manager` | B | R2 | Draft / 未认证 |
