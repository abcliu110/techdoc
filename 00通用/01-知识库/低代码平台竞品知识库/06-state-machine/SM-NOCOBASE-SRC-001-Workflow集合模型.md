---
id: SM-NOCOBASE-SRC-001
type: state-machine
domain_object: NocoBaseWorkflow
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-004]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-LOWCODE-001]
owner: AI
ai_generated: true
---

# NocoBase Workflow 集合模型

## 源码依据

- 仓库：`nocobase/nocobase`
- 分支与 commit：`main` / `1c41defe6c458771dd3449cb8b4557a49e584737`
- 文件：`packages/plugins/@nocobase/plugin-workflow/src/common/collections/workflows.ts`
- 可复核行号：
  - `name: 'workflows'`：L15
  - `repository: 'WorkflowRepository'`：L18
  - `enabled`：L55
  - `config`：L98
  - `nodes`：L104
  - `executions`：L110
  - `sync`：L128
  - `revisions`：L152

## 字段级观察

NocoBase 的 workflow 作为系统级 collection 存在，并显式包含：

```text
enabled
config
nodes
executions
sync
revisions
```

这表明 workflow 不只是静态流程定义，还关联节点、执行记录、同步和版本修订。

## 抽象结论

NocoBase workflow 更接近“流程定义 + 节点图 + 执行记录 + 修订”的自动化模型。与 Frappe 的文档状态机相比，它更偏事件/自动化工作流。

## 对自研平台的启发

自研平台不宜把工作流只设计成审批状态机。应拆成两个可组合模型：

```text
状态机工作流：适合单据状态、审批、提交/驳回
自动化工作流：适合事件触发、节点编排、异步执行、外部集成
```

两者共享触发、条件、动作、权限和执行日志，但元模型不要完全混成一个大表。

## 边界

本卡只基于 `workflows.ts` 的 collection 配置，不覆盖 NocoBase workflow 节点类型、触发器类型和执行引擎源码。
