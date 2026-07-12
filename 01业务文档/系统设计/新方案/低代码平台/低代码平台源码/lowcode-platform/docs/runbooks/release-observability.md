# 发布观测 Runbook

## 症状

- 发布前需要确认上线后的首轮观测项、告警阈值和回滚触发条件。
- 发布后出现 DDL 锁等待、MetaGraph 版本滞后、导入导出积压、权限拒绝突增或错误泄露告警。

## 影响

- 如果没有统一观测口径，值班人无法判断是继续观察、止血还是回滚。
- 当前仓库的发布门禁以静态材料和最小真实清单为主，发布后的运行态风险仍依赖人工观测与 runbook 协同执行。

## 确认命令

先确认发布材料和轻量门禁：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

发布前至少收集以下观测证据：

- 本次变更涉及的 trap IDs。
- 值班窗口、负责人和升级联系人。
- 需要重点观察的指标、日志和 traceId 检索入口。

## 止血动作

1. 发现 `PARTIAL_APPLIED`、DDL 锁等待超时或 Reconciler 差异时，先停止继续发布。
2. 发现权限拒绝、错误泄露或导入导出失败突增时，先冻结对应高风险操作。
3. 任何 break-glass、只读降级或人工放行都必须记录 traceId、时间窗和负责人。

## 恢复步骤

1. 发布前在 [docs/review/release-checklist.md](../review/release-checklist.md) 填写本次观察计划。
2. 发布后按优先级观察以下指标与事件：
   - `lowcode_schema_sync_lock_wait_ms`
   - `lowcode_reconciler_diff_count`
   - `lowcode_metagraph_version_lag`
   - `lowcode_permission_denied_count`
   - `lowcode_import_export_job_count`
   - `lowcode_notification_send_count`
3. 如果是 DDL / 发布状态问题，联动 [ddl-partial-apply-repair.md](./ddl-partial-apply-repair.md)。
4. 如果是权限链路问题，联动 [permission-exception.md](./permission-exception.md)。
5. 如果是导入导出或通知相关问题，先按业务链路止血，再补充对应审计和错误报告。

## 回滚

- 达到预设回滚阈值时，按 [rollback.md](./rollback.md) 执行。
- 不允许在没有记录观测证据的情况下仅凭“感觉不稳”口头回滚。
- 已执行的 DDL 和已写入的新格式数据仍按回滚边界处理，不承诺自动物理回退。

## 验证

- `verify-release.ps1 -Light` 通过。
- `docs/review/release-checklist.md` 已写明观测指标、回滚阈值和联系人。
- 本次发布说明能明确回答“看哪些指标、多久内看、什么条件下回滚”。

## 升级联系人

- 发布流程 owner。
- 运维值班人。
- 安全 / 权限 / 数据链路 owner。
