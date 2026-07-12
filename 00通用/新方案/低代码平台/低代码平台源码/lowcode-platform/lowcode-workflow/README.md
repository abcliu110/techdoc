# lowcode-workflow

工作流扩展边界模块。

## 当前真实范围

- 最小工作流运行时内核：
  - 定义发布与实例启动
  - 在途实例钉住定义版本和定义快照
  - 审批任务创建、认领、完成
  - 节点失败、超时、重试、人工介入和死信状态
  - 实例时间线与指标事件
  - 兼容性影响报告
  - 面向未来 JDBC 持久化的只读 `WorkflowPersistenceSnapshot` 导出
  - 基于 `WorkflowPersistenceSnapshot` 的 `InMemoryWorkflowRepository` 恢复准备

## 未上线边界

- 当前仓储仍是内存实现，不代表正式 JDBC 持久化。
- 当前没有真实 scheduler、错过补跑、租户时区、分布式锁或 fencing token。
- 当前快照恢复只支持回填内存仓储，不包含正式 JDBC schema、迁移升级器或生产级恢复编排。
- 当前 HTTP 入口由 `lowcode-app` 提供诊断和人工操作闭环，不代表完整生产工作流 API。
