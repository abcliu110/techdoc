# 16 权限与组织管理类生产级组件类别 SOP

> 组件数：20
>
> 关注域：租户、主体、资源、动作、数据范围、显式拒绝与审计
>
> 风险初始分布：R1 0 / R2 0 / R3 20

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：租户、主体、资源、动作、数据范围、显式拒绝与审计。
- 类别状态模型：租户、主体、角色、策略版本、资源范围、允许/拒绝、继承、审批和审计记录。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 跨租户或超组织范围操作
- 策略冲突、继承误判或显式拒绝失效
- 凭证泄露、审计缺失或并发覆盖策略

## 3. 强制验证

- 验证租户、组织、资源、动作和字段范围全部进入请求契约
- 验证显式拒绝、继承、冲突、版本、审批与审计
- 验证前端隐藏/禁用不被当作授权，服务端拒绝可解释且不泄密

## 4. 性能与规模基线

以 1,000 个主体、10,000 个资源和 500 条策略为设计基准；预览必须清晰显示数据范围，性能优化不得跳过服务端裁决。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

本类别统一按 R3 起步，不得降级；审计只读查看器仍涉及敏感数据范围。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [权限矩阵](../02-组件SOP/16-权限与组织管理类/16-permission-matrix.md) | `16:permission-matrix` | B | R3 | Draft / 未认证 |
| [角色权限编辑器](../02-组件SOP/16-权限与组织管理类/16-role-permission.md) | `16:role-permission` | B | R3 | Draft / 未认证 |
| [菜单权限树](../02-组件SOP/16-权限与组织管理类/16-menu-permission-tree.md) | `16:menu-permission-tree` | B | R3 | Draft / 未认证 |
| [数据权限配置器](../02-组件SOP/16-权限与组织管理类/16-data-permission.md) | `16:data-permission` | B | R3 | Draft / 未认证 |
| [字段权限配置器](../02-组件SOP/16-权限与组织管理类/16-field-permission.md) | `16:field-permission` | B | R3 | Draft / 未认证 |
| [行级权限规则编辑器](../02-组件SOP/16-权限与组织管理类/16-row-policy.md) | `16:row-policy` | B | R3 | Draft / 未认证 |
| [组织架构编辑器](../02-组件SOP/16-权限与组织管理类/16-org-editor.md) | `16:org-editor` | B | R3 | Draft / 未认证 |
| [用户角色分配器](../02-组件SOP/16-权限与组织管理类/16-user-role.md) | `16:user-role` | B | R3 | Draft / 未认证 |
| [部门人员分配器](../02-组件SOP/16-权限与组织管理类/16-department-user.md) | `16:department-user` | B | R3 | Draft / 未认证 |
| [资源授权面板](../02-组件SOP/16-权限与组织管理类/16-resource-grant.md) | `16:resource-grant` | B | R3 | Draft / 未认证 |
| [权限继承查看器](../02-组件SOP/16-权限与组织管理类/16-permission-inheritance.md) | `16:permission-inheritance` | B | R3 | Draft / 未认证 |
| [权限冲突检测器](../02-组件SOP/16-权限与组织管理类/16-permission-conflict.md) | `16:permission-conflict` | B | R3 | Draft / 未认证 |
| [审批人选择器](../02-组件SOP/16-权限与组织管理类/16-approver-picker.md) | `16:approver-picker` | B | R3 | Draft / 未认证 |
| [条件授权编辑器](../02-组件SOP/16-权限与组织管理类/16-conditional-grant.md) | `16:conditional-grant` | B | R3 | Draft / 未认证 |
| [租户配置面板](../02-组件SOP/16-权限与组织管理类/16-tenant-config.md) | `16:tenant-config` | B | R3 | Draft / 未认证 |
| [数据范围配置器](../02-组件SOP/16-权限与组织管理类/16-data-scope.md) | `16:data-scope` | B | R3 | Draft / 未认证 |
| [策略编辑器](../02-组件SOP/16-权限与组织管理类/16-policy-editor.md) | `16:policy-editor` | B | R3 | Draft / 未认证 |
| [访问控制列表 ACL 编辑器](../02-组件SOP/16-权限与组织管理类/16-acl-editor.md) | `16:acl-editor` | B | R3 | Draft / 未认证 |
| [密钥与凭证管理面板](../02-组件SOP/16-权限与组织管理类/16-credential-manager.md) | `16:credential-manager` | B | R3 | Draft / 未认证 |
| [操作审计查看器](../02-组件SOP/16-权限与组织管理类/16-audit-viewer.md) | `16:audit-viewer` | B | R3 | Draft / 未认证 |
