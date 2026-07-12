---
id: SM-FRAPPE-SRC-002
type: state-machine
domain_object: FrappeWorkflowTransition
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-007, E-FRAPPE-SRC-008]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-FRAPPE-SRC-001, SM-LOWCODE-001]
owner: AI
ai_generated: true
---

# Frappe Workflow 状态与转移字段

## 源码依据

- `frappe/workflow/doctype/workflow_transition/workflow_transition.json`
- `frappe/workflow/doctype/workflow_document_state/workflow_document_state.json`

## 字段级模型

Workflow Transition：

```text
state
action
next_state
allowed
allow_self_approval
condition
```

Workflow Document State：

```text
state
doc_status
update_field
update_value
allow_edit
is_optional_state
```

## 抽象

Frappe 的工作流由状态节点和转移边组成：

```text
状态节点：状态名、文档状态、字段更新、允许编辑角色
转移边：来源状态、动作、目标状态、允许角色、自审批、条件表达式
```

## 对自研平台的启发

状态机模型不能只保存状态名，还要保存：

```text
状态绑定的文档状态
进入状态时的字段更新
该状态下的可编辑角色
转移动作
转移角色
转移条件
自审批策略
```

这些字段直接影响审批、权限和审计。

## 边界

本卡未覆盖 Workflow Action Permitted Role 和运行时执行函数。
