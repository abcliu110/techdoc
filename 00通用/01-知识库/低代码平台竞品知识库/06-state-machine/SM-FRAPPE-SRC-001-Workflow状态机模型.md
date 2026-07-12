---
id: SM-FRAPPE-SRC-001
type: state-machine
domain_object: FrappeWorkflow
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-004]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-LOWCODE-001]
owner: AI
ai_generated: true
---

# Frappe Workflow 状态机模型

## 源码依据

- 仓库：`frappe/frappe`
- 分支与 commit：`develop` / `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`
- 文件：`frappe/workflow/doctype/workflow/workflow.json`
- 可复核行号：
  - `states`：L79
  - `states.options = Workflow Document State`：L82
  - `transitions`：L92
  - `transitions.options = Workflow Transition`：L95
  - `workflow_state_field`：L100
  - `workflow_data`：L106

## 字段级观察

Frappe 将 Workflow 拆为：

```text
states: Table(Workflow Document State)
transitions: Table(Workflow Transition)
workflow_state_field
workflow_data
```

`workflow_state_field` 默认承担业务文档上的状态字段语义，`states` 与 `transitions` 则分别表达状态集合和状态转移规则。

## 抽象结论

Frappe 的工作流是典型“状态集合 + 转移表 + 文档状态字段”的元数据状态机。它不是把审批流程写死在代码里，而是让业务文档通过元数据绑定状态机。

## 对自研平台的启发

自研平台工作流内核建议至少包含：

```text
Workflow
WorkflowState
WorkflowTransition
StateFieldBinding
TransitionAction
Role / Permission Binding
WorkflowRuntimeData
```

这样同一个业务对象可以通过状态字段绑定工作流，状态变化也能被权限、动作、通知和审计复用。

## 边界

本卡证明 Workflow 元模型字段存在，不覆盖 Workflow Transition 的全部字段，也未验证审批动作运行时行为。
