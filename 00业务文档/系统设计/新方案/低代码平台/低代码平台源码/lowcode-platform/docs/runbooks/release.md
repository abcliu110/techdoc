# 发布 Runbook

## 症状

- 需要执行一次标准的本地发布前门禁检查。
- 需要确认当前仓库是否具备可演示、可验证、可回滚的发布材料。

## 影响

- 发布前门禁未执行，可能把未验证的 DDL、未清理的调试标记、未补齐的运维材料带入主分支。
- 当前仓库仍有“内存实现 / 演示内核 / 占位门禁”的边界，若不提前说明，容易把演示能力误判为正式上线能力。

## 确认命令

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1
```

仅做快速自检时：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -SelfCheck
```

本地依赖准备：

```powershell
docker compose up -d mysql redis
```

## 止血动作

1. 如果 `verify-release.ps1` 在轻量门禁阶段失败，先修复脚本、文档、占位门禁或扫描命中项，不要直接跳过。
2. 如果后端 `mvn -B clean verify` 失败，先判断是否为既有失败；本次任务范围只允许修外围材料，不修改业务源码。
3. 如果前端 `pnpm lint/typecheck/test/build` 失败，先记录失败模块、失败命令和日志位置，再决定是否需要单独任务卡处理。

## 恢复步骤

1. 执行 `verify-release.ps1 -SelfCheck`，确认门禁脚本、文档和 CI workflow 文件齐全。
2. 执行 `verify-release.ps1 -Light`，确认占位门禁、regex、mojibake 和现有扫描全部通过。
3. 本地准备 MySQL/Redis。
4. 执行完整 `verify-release.ps1`。
5. 如果完整门禁通过，再进入人工检查：
   - `docs/review/manual-checklist.md`
   - `docs/review/release-checklist.md`
   - `docs/compliance/license-sbom.md`
   - `docs/compliance/release-gap-register.md`
   - `docs/compliance/formal-toolchain-migration.md`
   - `docs/compliance/saas-private-boundary.md`
   - `docs/runbooks/release-observability.md`
   - `docs/runbooks/dependency-license-compliance.md`
6. 在发布说明中明确当前版本属于：
   - 可运行正式能力
   - 内存 / 演示能力
   - 未上线边界

## 回滚

- 门禁脚本或文档异常时，直接回退本次外围文件变更即可。
- 已进入业务版本发布时，回滚流程按 [rollback.md](./rollback.md) 执行。

## 验证

- `verify-release.ps1` 汇总表全部为 `PASS`。
- `README.md` 已明确 M0-M5 当前能力边界。
- `docs/runbooks`、`docs/review`、`docs/compliance` 和 `.github/workflows/release-gate.yml` 全部存在且可读。
- `docs/review/release-checklist.md` 已写明观测项、回滚阈值和依赖合规结论。

## 升级联系人

- 发布流程 owner：平台发布负责人。
- 运维值守：容器 / CI 维护人。
- 设计与产品边界：低代码平台方案 owner。
