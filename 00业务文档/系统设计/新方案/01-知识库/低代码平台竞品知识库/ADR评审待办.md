# ADR 评审待办

日期：2026-07-05

## 状态说明

所有 ADR 已按升级指导书要求由 `accepted` 回退为 `proposed`。

原因：当前知识库整体成熟度为 L0，尚未完成 S 级竞品 NocoBase、Frappe 的实测和字段级拆解，不足以支撑高风险架构决策进入 accepted。

## 待评审 ADR

### ADR-LOWCODE-001：采用业务元模型优先路线

文件：`10-decision/ADR-LOWCODE-001-采用业务元模型优先路线.md`

当前依据：

- BIZ-LOWCODE-001
- DM-LOWCODE-001
- OPP-LOWCODE-001
- 金蝶、Frappe、NocoBase、Appsmith、ToolJet 等公开资料证据

当前风险：

- 未完成 NocoBase/Frappe 实测。
- 未验证业务元模型是否能覆盖真实“客户-订单-审批”闭环。
- 未验证实现成本和首版范围。

人工评审需确认：

1. 目标平台是否明确面向企业业务系统，而非内部工具平台。
2. 是否接受首版先做业务模型、牺牲自由画布丰富度。
3. 是否有真实业务对象作为样例验证。

### ADR-LOWCODE-DM-001：首版最小元模型

文件：`10-decision/ADR-LOWCODE-DM-001-最小元模型.md`

当前依据：

- DM-LOWCODE-001
- BR-LOWCODE-001
- PM-LOWCODE-001
- 金蝶、NocoBase、Frappe、Directus 公开资料证据

当前风险：

- 19 个对象可能过宽，存在首版过度设计风险。
- 未通过字段级拆解确认 NocoBase/Frappe 必要最小对象集合。
- 未验证 JSON 动态存储、物理表生成、元数据版本化的边界。

人工评审需确认：

1. 哪些元模型对象必须首版做，哪些可后置。
2. 是否要求支持子表/明细行、引用字段、状态动作。
3. 首版数据存储策略：JSON 动态存储、物理表生成，或混合方案。

### ADR-LOWCODE-UI-001：采用双层构建器

文件：`10-decision/ADR-LOWCODE-UI-001-双层构建器.md`

当前依据：

- UI-LOWCODE-001
- FLOW-LOWCODE-001
- Appsmith、ToolJet、Budibase、NocoBase、金蝶公开资料证据

当前风险：

- 未实测 NocoBase 的模型驱动页面配置。
- 未实测 Appsmith/ToolJet 的页面构建复杂度。
- 双层构建器会增加产品学习成本。

人工评审需确认：

1. 首版是否只做模型驱动页面，不做自由画布。
2. 页面编排允许覆盖哪些布局，不允许绕过哪些模型规则。
3. 目标用户是开发者、实施顾问，还是业务管理员。

### ADR-LOWCODE-PERM-001：采用多层权限模型

文件：`10-decision/ADR-LOWCODE-PERM-001-多层权限.md`

当前依据：

- PM-LOWCODE-001
- BR-LOWCODE-001
- 金蝶、ToolJet、NocoDB、Directus、NocoBase 公开资料证据

当前风险：

- 多层权限实现复杂。
- 未实测字段级、行级、动作级、数据源权限。
- 权限模型如果过简会影响商用安全；过复杂会拖慢首版。

人工评审需确认：

1. 首版权限最低边界是什么。
2. 是否必须支持字段级权限和数据范围权限。
3. 数据源连接权限和页面运行权限如何隔离。

## 进入 accepted 的前置条件

任一 ADR 进入 accepted 前，至少满足：

```text
1. 相关 S 级竞品模块达到 L1。
2. 至少完成一个“客户-订单-审批”样例实测。
3. 证据卡包含文档、实测、截图/命令/API 输出三类中的至少两类。
4. 人工评审明确通过，并记录评审人、日期和保留意见。
```

