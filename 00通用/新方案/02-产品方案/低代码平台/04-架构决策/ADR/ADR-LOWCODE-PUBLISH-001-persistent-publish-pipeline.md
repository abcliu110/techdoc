# ADR-LOWCODE-PUBLISH-001: 持久化发布管线与 DDL Plan

> 状态：accepted for M0
> 日期：2026-07-05
> 适用范围：M0 发布、Schema Sync、Reconciler、物理结构登记表

## 背景

低代码平台发布不是普通配置切换。一次发布至少包含全图校验、DDL Plan、动态 DDL、物理结构登记、Version.snapshot、MetaGraph 版本切换。MySQL DDL 不可回滚且会隐式提交，如果只用内存流程串起来，中途失败会留下“元数据说有列、物理表没有”或反向的半应用状态。

## 决策

1. 发布必须是一条持久化状态机，不允许只靠请求线程推进。
2. DDL Plan 是一等对象，执行前必须持久化，供预检报告、人工确认、失败恢复和测试断言读取。
3. 物理结构登记表 `lc_rt_physical_schema` 是日常 diff 的唯一热路径来源；`information_schema` 只用于 Reconciler 对账和登记表重建。
4. 发布互斥首选 DB 行锁 + fencing token。Redis 可用于版本通知和缓存，但不作为发布正确性的唯一锁。
5. 任一步失败后状态停留在可恢复节点，提供 `resume` / `abandon` 管理入口；`resume` 前必须运行 Reconciler。

## 状态机

```text
VALIDATING
  -> PLANNING
  -> LOCKED
  -> EXECUTING(step_n)
  -> SNAPSHOTTING
  -> ACTIVATING
  -> DONE
  -> FAILED_AT(step_n)
  -> ABANDONED
```

每个状态必须落库：operator、traceId、sourceVersion、targetVersion、planId、fencingToken、当前 step、错误码、脱敏错误消息、可恢复建议。

## Reconciler 差异分类

| 差异 | 判定来源 | 处置 |
|---|---|---|
| `REGISTRY_DRIFT` | 登记表与 information_schema 不一致 | 以 information_schema 为准重建登记表，写审计 |
| `MISSING_TABLE` | 元数据有对象，物理表不存在 | 未发布阻断；失败恢复可补建 |
| `MISSING_COLUMN` | 元数据有字段，物理列不存在 | 阻断运行，恢复流程可补列 |
| `EXTRA_COLUMN` | 物理列存在，元数据无字段 | 保留并标记 orphan，不自动删除 |
| `TYPE_WIDENED` | 长度/精度扩大 | 可执行 |
| `TYPE_NARROWED` | 长度/精度缩小 | 阻断，人工工单 |
| `TYPE_CHANGED` | 类型族变化 | 阻断，人工工单 |
| `COLLATION_CHANGED` | collation 不一致 | 告警并生成工单 |

## 后果

- 发布实现更重，但每个故障点可诊断、可恢复、可测试。
- 需要新增发布任务表和更完整的 DDL 日志。
- M0 可先实现状态机、Plan、日志、Reconciler detect/resume 接口骨架，不要求完整自动修复所有差异。

## 验证

- 发布中断于任一步，状态、DDL 日志、登记表和 Reconciler 报告可解释当前状态。
- 两个发布者并发时，旧 fencing token 不能继续推进状态或执行后续 DDL。
- 长事务持有 MDL 时，发布被预检阻断或在 lock_wait_timeout 后进入失败状态。
