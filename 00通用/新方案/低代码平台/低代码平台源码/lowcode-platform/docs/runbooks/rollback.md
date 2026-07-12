# 回滚 Runbook

## 症状

- 发布后出现运行态、设计态、发布状态机或插件升级异常，需要回退到上一个稳定版本。
- 门禁通过，但上线后暴露出当前版本仍未覆盖的“内存实现 / 演示内核”边界。

## 影响

- 元数据快照、页面预览和发布状态可能可以回退。
- 已执行的物理 DDL、已写入的新格式数据、外部通知与插件副作用默认不承诺自动物理回滚。

## 确认命令

先确认当前发布材料：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

再收集应用状态：

```powershell
docker compose ps
```

## 止血动作

1. 停止继续发布新的版本或新的 DDL 计划。
2. 冻结导入、导出、插件升级、工作流推进等可能放大影响面的动作。
3. 记录当前版本号、回滚目标版本、traceId、发布任务号和异常时间。

## 恢复步骤

1. 先执行回滚预检：
   - 是否涉及字段类型收窄、删列、精度降低、插件数据迁移。
   - 是否存在已进入 `PARTIAL_APPLIED` 的 DDL。
2. 如果只是外围门禁或文档错误，回退本次材料提交即可。
3. 如果需要元数据回退，遵循“元数据先回、物理结构后确认”的顺序：
   - 回退发布快照。
   - 保留 DDL 日志与差异报告。
   - 重新跑结构对账。
4. 如果插件能力已升级失败，联动 [plugin-upgrade-failed.md](./plugin-upgrade-failed.md)。
5. 如果出现 DDL 半应用，联动 [ddl-partial-apply-repair.md](./ddl-partial-apply-repair.md)。
6. 如果回滚由发布后观测触发，联动 [release-observability.md](./release-observability.md) 复核阈值和证据。

## 回滚

- 代码层回滚：回退本次外围材料提交。
- 元数据层回滚：只承诺恢复元数据快照、页面、规则和权限配置。
- 物理结构层：新增表/列默认不自动删除，只做“保留并标记需人工清理”。

## 验证

- 回滚后再次执行 `verify-release.ps1 -Light`。
- 检查发布状态是否已退出失败状态。
- 检查 README 中声明的能力边界是否仍与实际状态一致。
- 检查 `docs/review/release-checklist.md` 中记录的回滚阈值和实际触发证据是否一致。

## 升级联系人

- 平台发布负责人。
- DBA / Schema Sync 维护人。
- 插件与商业能力负责人。
