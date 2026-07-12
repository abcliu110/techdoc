# DDL 半应用修复 Runbook

## 症状

- 发布任务进入 `PARTIAL_APPLIED` 或 `FAILED_NEED_REPAIR`。
- 某些对象已执行部分 DDL，但元数据版本、登记表或运行态访问未完全收敛。

## 影响

- 继续发布可能扩大漂移范围。
- 直接重跑 DDL 可能造成重复执行、锁等待或更难恢复的结构差异。

## 确认命令

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

同时检查：

- 最新发布任务号。
- 失败 SQL 步骤号。
- 目标对象 code / 物理表名。
- 对账报告里是 `MISSING_COLUMN`、`EXTRA_COLUMN`、`TYPE_NARROWED` 还是 `REGISTRY_DRIFT`。

## 止血动作

1. 停止同一应用的后续发布。
2. 冻结人工 SQL 变更，避免“修一半又被门禁判漂移”。
3. 保留失败现场：DDL SQL、报错信息、traceId、发布任务号。

## 恢复步骤

1. 判断失败类型：
   - `MISSING_COLUMN`：可补列，但必须保留 DDL 日志。
   - `EXTRA_COLUMN`：先保留，不自动删除。
   - `TYPE_NARROWED`：阻断，必须人工工单确认。
   - `REGISTRY_DRIFT`：先修登记表，再重跑对账。
2. 先跑对账，再决定是否补执行，不允许盲目重试。
3. 若只是锁等待超时，确认长事务已结束后，重新执行单次受控补偿。
4. 若版本状态已漂移，先恢复发布状态机，再做结构补偿。

## 回滚

- 只回元数据，不承诺自动删除已新增列/表。
- 任何删列、收窄类型、重命名的物理回滚都必须人工确认。

## 验证

- 对账报告恢复为无阻断差异。
- `verify-release.ps1 -Light` 通过。
- 发布状态不再停留在 `PARTIAL_APPLIED`。

## 升级联系人

- DBA / Schema Sync 负责人。
- 发布状态机维护人。
- 业务 owner（确认是否接受保留型回滚）。
