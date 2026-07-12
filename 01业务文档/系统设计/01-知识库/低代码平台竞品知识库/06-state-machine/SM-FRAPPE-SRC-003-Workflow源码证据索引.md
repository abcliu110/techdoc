---
id: SM-FRAPPE-SRC-003
type: state-machine
domain_object: FrappeWorkflowSourceIndex
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-074, E-FRAPPE-SRC-075, E-FRAPPE-SRC-076, E-FRAPPE-SRC-077, E-FRAPPE-SRC-078, E-FRAPPE-SRC-079, E-FRAPPE-SRC-080, E-FRAPPE-SRC-081, E-FRAPPE-SRC-082, E-FRAPPE-SRC-083, E-FRAPPE-SRC-084, E-FRAPPE-SRC-085, E-FRAPPE-SRC-086, E-FRAPPE-SRC-087, E-FRAPPE-SRC-088, E-FRAPPE-SRC-089, E-FRAPPE-SRC-090, E-FRAPPE-SRC-091, E-FRAPPE-SRC-092, E-FRAPPE-SRC-093]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-FRAPPE-SRC-001, SM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe Workflow 源码证据索引

## 结论

Frappe Workflow 由 Workflow、Workflow Transition、Workflow Document State 三类元数据组成。核心字段包括 document_type、states、transitions、workflow_state_field、state、action、next_state、allowed、condition、doc_status、allow_edit、update_field/update_value。

## 源码证据范围

```text
E-FRAPPE-SRC-074..093
workflow.json
workflow_transition.json
workflow_document_state.json
```

## 对自研平台的启发

审批/状态机模型应明确区分：

```text
WorkflowDefinition
WorkflowState
WorkflowTransition
AllowedRole
TransitionCondition
DocumentStatus
StateUpdate
EditableRole
```
