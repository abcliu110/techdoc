---
id: ADR-LOWCODE-PERM-001
type: adr
domain_object: LowCodePermission
module: security
decision_status: proposed
basis: [PM-LOWCODE-001, BR-LOWCODE-001]
evidence: [E-KINGDEE-COSMIC-001, E-TOOLJET-001, E-NOCODB-001, E-DIRECTUS-001, E-NOCOBASE-001]
rejected_options: [ADR-LOWCODE-PERM-001-A]
risk: high
review_at: 2026-10-05
valid_until: 2027-01-05
links: []
owner: 产品负责人
ai_generated: true
---

# ADR：采用多层权限模型

评审状态说明：依据知识库成熟度为 L0，按方法论 §10.1 不足以支撑高风险决策，待相关模块达到 L1 后提交人工评审。

## 决策

首版必须覆盖：

```text
租户/组织权限
工作区权限
应用设计权限
应用运行权限
对象权限
字段权限
动作权限
数据范围权限
数据源连接权限
发布与回滚权限
```

## 理由

低代码平台同时暴露业务数据、页面、查询、数据源和流程。只做菜单权限会留下严重越权风险。

## 验证方式

同一应用内，普通用户只能运行授权页面和动作；设计者可以配置页面但不能读取未授权数据源密钥；管理员可发布和回滚版本。
