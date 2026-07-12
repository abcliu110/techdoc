---
id: UI-NOCOBASE-VIS-004
type: ui
domain_object: WorkflowBuilder
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-004, E-NOCOBASE-SRC-061, E-NOCOBASE-SRC-062]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-NOCOBASE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase Workflow 管理界面拆解

## 页面目标

让管理员创建 workflow、选择触发器、配置节点，并将业务事件转成自动化流程。

## 页面分区

```text
Workflow management：流程列表与新建入口
New workflow：选择 workflow 类型与名称
Trigger drawer：配置 Collection event 等触发条件
Flow editor：节点编排区
Node config：节点参数抽屉
```

## 设计启发

自研平台 workflow UI 不应只是状态字段配置，而应有“触发器 -> 条件 -> 节点 -> 执行记录”的完整设计。首版至少支持对象事件触发和按钮动作触发。

## 边界

本卡基于官方截图和源码证据，尚未完成本地创建流程和执行日志验证。
