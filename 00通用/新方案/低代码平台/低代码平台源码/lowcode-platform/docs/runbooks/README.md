# Runbook 目录

本目录存放 M5 上线门禁要求的运维、发布和恢复手册。

当前包含：

- `release.md`：标准发布流程与上线门禁使用方法。
- `rollback.md`：版本回滚与元数据回退边界。
- `ddl-partial-apply-repair.md`：DDL 半应用状态修复。
- `release-observability.md`：发布窗口的观测项、止血和回滚触发条件。
- `dependency-license-compliance.md`：依赖、License、SBOM 与离线交付合规检查。
- `docker-testcontainers.md`：本地 Docker 与 Testcontainers 排障。
- `import-export.md`：导入导出、应用包与数据边界。
- `permission-exception.md`：权限异常与租户上下文排查。
- `plugin-upgrade-failed.md`：插件升级失败、降级与回滚。

每份 runbook 都按统一结构编写：症状、影响、确认命令、止血动作、恢复步骤、回滚、验证、升级联系人。

配套评审模板：

- `../review/manual-checklist.md`：无法完全机器化的人工评审清单。
- `../review/release-checklist.md`：发布前逐项签署的 release checklist 模板。
