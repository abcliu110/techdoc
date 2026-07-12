---
id: SM-LOWCODE-001
type: state-machine
domain_object: LowCodeApp
competitors: [Kingdee-Cosmic, Appsmith, ToolJet, Budibase, NocoBase, Frappe]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-APPSMITH-001, E-TOOLJET-001, E-BUDIBASE-001, E-NOCOBASE-001, E-NOCOBASE-SRC-004, E-FRAPPE-SRC-004]
strength: 高可信推断
confidence: 0.5
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-NOCOBASE-SRC-001, SM-FRAPPE-SRC-001, ADR-LOWCODE-SM-001]
owner: AI
ai_generated: true
---

# 状态机：低代码应用生命周期

成熟度说明：状态名称和应用生命周期转移是本知识库抽象，不代表任一竞品真实内部状态机；但 Frappe Workflow 与 NocoBase workflow collection 已有源码初证，可支撑“低代码平台需要状态机/工作流元模型”的方向判断。

## 状态

```text
Draft
Configured
Validating
Published
Running
Deprecated
Archived
```

## 状态转移

```text
Draft → Configured：完成对象、页面、数据源或流程配置
Configured → Validating：执行规则校验、权限校验、依赖校验
Validating → Published：校验通过并发布
Published → Running：有用户访问或业务数据产生
Published/Running → Deprecated：被新版本替代
Deprecated → Archived：停止使用并归档
```

## 不变量

- 未通过校验的模型不能发布。
- 已发布版本不能被无审计地直接修改。
- 运行中应用的元数据变更必须有版本记录和回滚路径。
- 权限、数据源密钥、外部 API 配置不得随页面导出泄漏。

## 证据边界

开源内部工具平台普遍支持保存、发布、版本控制或应用生命周期概念；金蝶类企业平台强调模型资产和扩展。具体状态名称为本知识库抽象，不代表竞品内部实现。

源码初证补充：

- Frappe Workflow 源码将状态机拆为 `states`、`transitions`、`workflow_state_field`、`workflow_data`。
- NocoBase workflow collection 源码显示 workflow 关联 `config`、`nodes`、`executions`、`sync`、`revisions`。
- 因此自研平台需要区分“文档状态机”和“自动化流程编排”，两者不能完全混成一个大而全模型。
