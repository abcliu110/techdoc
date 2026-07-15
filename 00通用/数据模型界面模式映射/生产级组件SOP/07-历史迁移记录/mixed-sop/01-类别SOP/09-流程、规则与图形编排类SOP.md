# 09 流程、规则与图形编排类生产级组件类别 SOP

> 组件数：25
>
> 关注域：图节点身份、连线语义、执行顺序、合法状态与发布版本
>
> 风险初始分布：R1 0 / R2 16 / R3 9

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：图节点身份、连线语义、执行顺序、合法状态与发布版本。
- 类别状态模型：节点、边、端口、选择、视口、校验、模拟结果、执行版本与发布状态。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 非法连线、循环或不可达节点
- 并发编辑导致节点/边丢失或引用悬空
- 模拟与生产执行不一致、发布失败或无法补偿

## 3. 强制验证

- 验证稳定节点/边 ID、连线约束、循环和拓扑规则
- 验证键盘创建、选择、移动、连接及非画布等价编辑入口
- 验证模拟、发布版本、并发冲突、执行失败和补偿路径

## 4. 性能与规模基线

以 1,000 节点、2,000 条边为图编辑基准；平移缩放与选择保持可操作，节点操作反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

可驱动审批、状态、规则、作业、流水线或生产执行的编辑器为 R3；纯说明图可为 R1/R2。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [工作流设计器](../02-组件SOP/09-流程、规则与图形编排类/09-workflow-designer.md) | `09:workflow-designer` | B | R3 | Draft / 未认证 |
| [BPMN 流程设计器](../02-组件SOP/09-流程、规则与图形编排类/09-bpmn-designer.md) | `09:bpmn-designer` | B | R3 | Draft / 未认证 |
| [审批流设计器](../02-组件SOP/09-流程、规则与图形编排类/09-approval-flow.md) | `09:approval-flow` | B | R3 | Draft / 未认证 |
| [状态机设计器](../02-组件SOP/09-流程、规则与图形编排类/09-state-machine.md) | `09:state-machine` | B | R3 | Draft / 未认证 |
| [业务规则设计器](../02-组件SOP/09-流程、规则与图形编排类/09-rule-designer.md) | `09:rule-designer` | B | R3 | Draft / 未认证 |
| [决策表编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-decision-table.md) | `09:decision-table` | B | R3 | Draft / 未认证 |
| [决策树设计器](../02-组件SOP/09-流程、规则与图形编排类/09-decision-tree.md) | `09:decision-tree` | B | R3 | Draft / 未认证 |
| [表达式图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-expression-graph.md) | `09:expression-graph` | B | R2 | Draft / 未认证 |
| [DAG 任务编排器](../02-组件SOP/09-流程、规则与图形编排类/09-dag-designer.md) | `09:dag-designer` | B | R2 | Draft / 未认证 |
| [数据管道设计器](../02-组件SOP/09-流程、规则与图形编排类/09-pipeline-designer.md) | `09:pipeline-designer` | B | R3 | Draft / 未认证 |
| [任务调度编排器](../02-组件SOP/09-流程、规则与图形编排类/09-job-orchestrator.md) | `09:job-orchestrator` | B | R3 | Draft / 未认证 |
| [依赖关系图](../02-组件SOP/09-流程、规则与图形编排类/09-dependency-graph.md) | `09:dependency-graph` | B | R2 | Draft / 未认证 |
| [服务拓扑图](../02-组件SOP/09-流程、规则与图形编排类/09-service-topology.md) | `09:service-topology` | B | R2 | Draft / 未认证 |
| [网络拓扑编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-network-topology.md) | `09:network-topology` | B | R2 | Draft / 未认证 |
| [数据血缘图](../02-组件SOP/09-流程、规则与图形编排类/09-data-lineage.md) | `09:data-lineage` | B | R2 | Draft / 未认证 |
| [ER 图设计器](../02-组件SOP/09-流程、规则与图形编排类/09-er-designer.md) | `09:er-designer` | B | R2 | Draft / 未认证 |
| [类图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-class-diagram.md) | `09:class-diagram` | B | R2 | Draft / 未认证 |
| [时序图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-sequence-diagram.md) | `09:sequence-diagram` | B | R2 | Draft / 未认证 |
| [用例图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-use-case-diagram.md) | `09:use-case-diagram` | B | R2 | Draft / 未认证 |
| [活动图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-activity-diagram.md) | `09:activity-diagram` | B | R2 | Draft / 未认证 |
| [流程图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-flowchart-editor.md) | `09:flowchart-editor` | B | R2 | Draft / 未认证 |
| [思维导图编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-mind-map.md) | `09:mind-map` | B | R2 | Draft / 未认证 |
| [概念关系图](../02-组件SOP/09-流程、规则与图形编排类/09-concept-map.md) | `09:concept-map` | B | R2 | Draft / 未认证 |
| [通用节点编辑器](../02-组件SOP/09-流程、规则与图形编排类/09-node-editor.md) | `09:node-editor` | B | R2 | Draft / 未认证 |
| [无限画布工作区](../02-组件SOP/09-流程、规则与图形编排类/09-infinite-canvas.md) | `09:infinite-canvas` | B | R2 | Draft / 未认证 |
