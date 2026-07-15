# 18 业务领域复合组件生产级组件类别 SOP

> 组件数：30
>
> 关注域：跨对象业务不变量、职责边界、事件时间线与补偿
>
> 风险初始分布：R1 0 / R2 15 / R3 15

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：跨对象业务不变量、职责边界、事件时间线与补偿。
- 类别状态模型：核心对象、关联对象、规则快照、审批、提交、下游状态、审计与补偿状态。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 关联对象版本变化或跨模块规则冲突
- 部分提交、重复提交或下游超时
- 权限、金额、库存、排期、SLA 或审计不一致

## 3. 强制验证

- 验证至少三个业务对象和双职责边界
- 验证重复、并发、部分成功、下游失败与补偿
- 验证金额/库存/排期/权限/SLA 影响和完整事件时间线

## 4. 性能与规模基线

按组件契约登记真实数据规模和下游延迟；本地反馈 p95 不高于 100ms，长事务必须显示阶段、允许安全取消或进入可恢复后台状态。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

命中权限、多租户、金额、库存、订单、支付、医疗隐私、安全告警或不可逆动作即 R3；其余跨系统流程至少 R2。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [商品规格 SKU 编辑器](../02-组件SOP/18-业务领域复合组件/18-sku-editor.md) | `18:sku-editor` | C | R3 | Draft / 未认证 |
| [购物车](../02-组件SOP/18-业务领域复合组件/18-shopping-cart.md) | `18:shopping-cart` | C | R2 | Draft / 未认证 |
| [结算台](../02-组件SOP/18-业务领域复合组件/18-checkout.md) | `18:checkout` | C | R3 | Draft / 未认证 |
| [订单状态跟踪器](../02-组件SOP/18-业务领域复合组件/18-order-tracker.md) | `18:order-tracker` | C | R2 | Draft / 未认证 |
| [库存分配器](../02-组件SOP/18-业务领域复合组件/18-stock-allocation.md) | `18:stock-allocation` | C | R3 | Draft / 未认证 |
| [仓库库位图](../02-组件SOP/18-业务领域复合组件/18-warehouse-map.md) | `18:warehouse-map` | C | R3 | Draft / 未认证 |
| [价格规则编辑器](../02-组件SOP/18-业务领域复合组件/18-price-rule.md) | `18:price-rule` | C | R3 | Draft / 未认证 |
| [优惠规则编辑器](../02-组件SOP/18-业务领域复合组件/18-promotion-rule.md) | `18:promotion-rule` | C | R3 | Draft / 未认证 |
| [合同编辑器](../02-组件SOP/18-业务领域复合组件/18-contract-editor.md) | `18:contract-editor` | C | R3 | Draft / 未认证 |
| [发票编辑器](../02-组件SOP/18-业务领域复合组件/18-invoice-editor.md) | `18:invoice-editor` | C | R3 | Draft / 未认证 |
| [会计凭证录入器](../02-组件SOP/18-业务领域复合组件/18-voucher-entry.md) | `18:voucher-entry` | C | R3 | Draft / 未认证 |
| [财务科目树](../02-组件SOP/18-业务领域复合组件/18-account-tree.md) | `18:account-tree` | C | R3 | Draft / 未认证 |
| [排班与考勤组件](../02-组件SOP/18-业务领域复合组件/18-shift-attendance.md) | `18:shift-attendance` | C | R2 | Draft / 未认证 |
| [薪资计算表](../02-组件SOP/18-业务领域复合组件/18-payroll-sheet.md) | `18:payroll-sheet` | C | R3 | Draft / 未认证 |
| [CRM 客户关系视图](../02-组件SOP/18-业务领域复合组件/18-crm-relationship.md) | `18:crm-relationship` | C | R2 | Draft / 未认证 |
| [销售漏斗](../02-组件SOP/18-业务领域复合组件/18-sales-funnel.md) | `18:sales-funnel` | C | R2 | Draft / 未认证 |
| [客户画像面板](../02-组件SOP/18-业务领域复合组件/18-customer-profile.md) | `18:customer-profile` | C | R2 | Draft / 未认证 |
| [工单处理台](../02-组件SOP/18-业务领域复合组件/18-ticket-workbench.md) | `18:ticket-workbench` | C | R2 | Draft / 未认证 |
| [呼叫中心工作台](../02-组件SOP/18-业务领域复合组件/18-call-center.md) | `18:call-center` | C | R2 | Draft / 未认证 |
| [物流轨迹组件](../02-组件SOP/18-业务领域复合组件/18-logistics-tracker.md) | `18:logistics-tracker` | C | R2 | Draft / 未认证 |
| [医疗病历编辑器](../02-组件SOP/18-业务领域复合组件/18-medical-record.md) | `18:medical-record` | C | R3 | Draft / 未认证 |
| [考试试卷编辑器](../02-组件SOP/18-业务领域复合组件/18-exam-editor.md) | `18:exam-editor` | C | R2 | Draft / 未认证 |
| [题库管理器](../02-组件SOP/18-业务领域复合组件/18-question-bank.md) | `18:question-bank` | C | R2 | Draft / 未认证 |
| [课程编排器](../02-组件SOP/18-业务领域复合组件/18-course-planner.md) | `18:course-planner` | C | R2 | Draft / 未认证 |
| [座位选择器](../02-组件SOP/18-业务领域复合组件/18-seat-picker.md) | `18:seat-picker` | C | R2 | Draft / 未认证 |
| [房间 / 资源预订器](../02-组件SOP/18-业务领域复合组件/18-resource-booking.md) | `18:resource-booking` | C | R2 | Draft / 未认证 |
| [配置器 Configurator](../02-组件SOP/18-业务领域复合组件/18-configurator.md) | `18:configurator` | C | R2 | Draft / 未认证 |
| [产品 BOM 编辑器](../02-组件SOP/18-业务领域复合组件/18-bom-editor.md) | `18:bom-editor` | C | R3 | Draft / 未认证 |
| [设备监控台](../02-组件SOP/18-业务领域复合组件/18-device-monitor.md) | `18:device-monitor` | C | R3 | Draft / 未认证 |
| [告警规则编辑器](../02-组件SOP/18-业务领域复合组件/18-alarm-rule.md) | `18:alarm-rule` | C | R3 | Draft / 未认证 |
