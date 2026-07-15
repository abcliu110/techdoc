# 04 表单与数据录入类生产级组件类别 SOP

> 组件数：30
>
> 关注域：字段值、校验、草稿、提交与版本冲突
>
> 风险初始分布：R1 0 / R2 28 / R3 2

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：字段值、校验、草稿、提交与版本冲突。
- 类别状态模型：初始值、当前值、脏字段、校验结果、提交状态、草稿版本与服务端版本。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 同步或异步校验失败且定位不准确
- 提交失败、离开页面或切换步骤造成草稿丢失
- 服务端版本变化导致静默覆盖

## 3. 强制验证

- 验证标签、说明、错误关联、首错定位和读屏播报
- 验证脏数据保护、草稿恢复、异步乱序与版本冲突
- 验证提交中重复触发、取消、服务失败和服务端错误映射

## 4. 性能与规模基线

包含 200 字段、20 个条件字段和 10 个异步校验的基准场景；单字段输入反馈 p95 不高于 100ms，非当前字段不得触发无界重渲染。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

若提交签名、审批、金额、订单、权限或法律效力数据，升级为 R3。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [标准表单](../02-组件SOP/04-表单与数据录入类/04-standard-form.md) | `04:standard-form` | B | R2 | Draft / 未认证 |
| [高密度表单](../02-组件SOP/04-表单与数据录入类/04-dense-form.md) | `04:dense-form` | B | R2 | Draft / 未认证 |
| [动态表单](../02-组件SOP/04-表单与数据录入类/04-dynamic-form.md) | `04:dynamic-form` | B | R2 | Draft / 未认证 |
| [Schema 驱动表单](../02-组件SOP/04-表单与数据录入类/04-schema-form.md) | `04:schema-form` | B | R2 | Draft / 未认证 |
| [嵌套对象表单](../02-组件SOP/04-表单与数据录入类/04-nested-form.md) | `04:nested-form` | B | R2 | Draft / 未认证 |
| [可重复区块表单](../02-组件SOP/04-表单与数据录入类/04-repeatable-form.md) | `04:repeatable-form` | B | R2 | Draft / 未认证 |
| [主从表单](../02-组件SOP/04-表单与数据录入类/04-master-detail-form.md) | `04:master-detail-form` | B | R2 | Draft / 未认证 |
| [向导表单](../02-组件SOP/04-表单与数据录入类/04-wizard-form.md) | `04:wizard-form` | B | R2 | Draft / 未认证 |
| [分步表单](../02-组件SOP/04-表单与数据录入类/04-step-form.md) | `04:step-form` | B | R2 | Draft / 未认证 |
| [页签表单](../02-组件SOP/04-表单与数据录入类/04-tab-form.md) | `04:tab-form` | B | R2 | Draft / 未认证 |
| [折叠分组表单](../02-组件SOP/04-表单与数据录入类/04-accordion-form.md) | `04:accordion-form` | B | R2 | Draft / 未认证 |
| [条件显示表单](../02-组件SOP/04-表单与数据录入类/04-conditional-form.md) | `04:conditional-form` | B | R2 | Draft / 未认证 |
| [字段联动表单](../02-组件SOP/04-表单与数据录入类/04-linked-form.md) | `04:linked-form` | B | R2 | Draft / 未认证 |
| [计算字段表单](../02-组件SOP/04-表单与数据录入类/04-calculated-form.md) | `04:calculated-form` | B | R2 | Draft / 未认证 |
| [综合校验表单](../02-组件SOP/04-表单与数据录入类/04-validation-form.md) | `04:validation-form` | B | R2 | Draft / 未认证 |
| [异步校验表单](../02-组件SOP/04-表单与数据录入类/04-async-validation-form.md) | `04:async-validation-form` | B | R2 | Draft / 未认证 |
| [实时校验表单](../02-组件SOP/04-表单与数据录入类/04-realtime-validation-form.md) | `04:realtime-validation-form` | B | R2 | Draft / 未认证 |
| [草稿自动保存表单](../02-组件SOP/04-表单与数据录入类/04-draft-form.md) | `04:draft-form` | B | R2 | Draft / 未认证 |
| [多页长表单](../02-组件SOP/04-表单与数据录入类/04-multi-page-form.md) | `04:multi-page-form` | B | R2 | Draft / 未认证 |
| [问卷表单](../02-组件SOP/04-表单与数据录入类/04-survey-form.md) | `04:survey-form` | B | R2 | Draft / 未认证 |
| [单题对话式表单](../02-组件SOP/04-表单与数据录入类/04-conversational-form.md) | `04:conversational-form` | B | R2 | Draft / 未认证 |
| [矩阵题表单](../02-组件SOP/04-表单与数据录入类/04-matrix-question-form.md) | `04:matrix-question-form` | B | R2 | Draft / 未认证 |
| [文件上传表单](../02-组件SOP/04-表单与数据录入类/04-upload-form.md) | `04:upload-form` | B | R2 | Draft / 未认证 |
| [签名表单](../02-组件SOP/04-表单与数据录入类/04-signature-form.md) | `04:signature-form` | B | R3 | Draft / 未认证 |
| [日期范围表单](../02-组件SOP/04-表单与数据录入类/04-date-range-form.md) | `04:date-range-form` | B | R2 | Draft / 未认证 |
| [级联地址表单](../02-组件SOP/04-表单与数据录入类/04-address-form.md) | `04:address-form` | B | R2 | Draft / 未认证 |
| [审批提交表单](../02-组件SOP/04-表单与数据录入类/04-approval-form.md) | `04:approval-form` | B | R3 | Draft / 未认证 |
| [版本差异表单](../02-组件SOP/04-表单与数据录入类/04-version-form.md) | `04:version-form` | B | R2 | Draft / 未认证 |
| [表单设计器](../02-组件SOP/04-表单与数据录入类/04-form-designer.md) | `04:form-designer` | B | R2 | Draft / 未认证 |
| [表单运行态预览](../02-组件SOP/04-表单与数据录入类/04-runtime-form.md) | `04:runtime-form` | B | R2 | Draft / 未认证 |
