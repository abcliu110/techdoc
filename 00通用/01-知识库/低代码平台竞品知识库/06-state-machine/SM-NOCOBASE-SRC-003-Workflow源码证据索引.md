---
id: SM-NOCOBASE-SRC-003
type: state-machine
domain_object: NocoBaseWorkflowSourceIndex
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-071, E-NOCOBASE-SRC-072, E-NOCOBASE-SRC-073, E-NOCOBASE-SRC-074, E-NOCOBASE-SRC-075, E-NOCOBASE-SRC-076, E-NOCOBASE-SRC-077, E-NOCOBASE-SRC-078, E-NOCOBASE-SRC-079, E-NOCOBASE-SRC-080, E-NOCOBASE-SRC-081, E-NOCOBASE-SRC-082, E-NOCOBASE-SRC-083, E-NOCOBASE-SRC-084, E-NOCOBASE-SRC-085, E-NOCOBASE-SRC-086, E-NOCOBASE-SRC-087, E-NOCOBASE-SRC-088, E-NOCOBASE-SRC-089, E-NOCOBASE-SRC-090]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-NOCOBASE-SRC-001]
owner: AI
ai_generated: true
---

# NocoBase Workflow 源码证据索引

## 结论

NocoBase Workflow 集合包含 key、title、enabled、type、triggerTitle、config、nodes、executions、executed、current、sync、revisions、options、stats、categories 等字段，说明其工作流是版本化、可同步/异步执行、带节点与执行记录的模型。

## 源码证据范围

```text
E-NOCOBASE-SRC-071..090
workflows.ts: workflows collection / WorkflowRepository / nodes / executions / revisions / sync / current / stats
```

## 对自研平台的启发

工作流模型应把定义、版本、节点、执行、统计分离，至少包含：

```text
WorkflowDefinition
WorkflowVersion
Trigger
Node
Execution
ExecutionStats
SyncMode
Category
```
