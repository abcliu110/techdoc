# 依赖与 License 合规 Runbook

## 症状

- 发布前发现依赖清单、License 清单、SBOM 基线或 Docker 镜像登记与当前仓库不一致。
- PR 或发布评审无法回答“本次是否引入了新依赖、License 风险或供应链变更”。

## 影响

- 合规材料与实际依赖不一致时，发布结论不可追溯。
- 当前仓库采用“提交入库的最小真实清单 + 静态比对”策略，若清单失真，会直接削弱发布门禁可信度。

## 确认命令

先跑轻量门禁：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

如需单独核对最小真实门禁：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-placeholder-gates.ps1 -SelfCheck
powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1 -MatchCommitted
```

同时核对：

- `docs/compliance/dependency-admission.md`
- `docs/compliance/formal-toolchain-migration.md`
- `docs/compliance/license-sbom.md`
- `docs/compliance/license-inventory.json`
- `docs/compliance/release-gap-register.md`
- `docs/compliance/sbom-minimal.json`

## 止血动作

1. 合规清单不一致时，先阻断发布，不允许先上线再补文档。
2. 新依赖未经过准入表或 License 结论不清时，先冻结合并和打包。
3. 若发现来源不明的二进制、镜像或资产，立即停止继续扩散到 release 流程。

## 恢复步骤

1. 先判断本次是否真的存在依赖变更：
   - Maven direct dependencies / dependencyManagement
   - pnpm dependencies / devDependencies
   - Docker images
2. 若没有依赖变更，补齐发布说明中的“无依赖差异”结论即可。
3. 若存在依赖变更，按顺序处理：
   - 先补 `dependency-admission.md` 的准入记录。
   - 再运行 `powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1`。
   - 再复核 `license-inventory.json`。
   - 再复核 `sbom-minimal.json`。
   - 最后补充 PR 与 release checklist 中的风险和回滚说明。
4. 如果 `license-inventory.json` 中出现 `UNREVIEWED` 或其他未完成审查占位结果，视为未完成合规审查，不能放行。
5. 如果本次发布仍依赖 light gate 未覆盖的人工判断，把限制登记到 `docs/compliance/release-gap-register.md`，并参照 `docs/compliance/formal-toolchain-migration.md` 记录后续切换计划。
6. 若是私有化 / 离线授权相关差异，联动 `docs/compliance/saas-private-boundary.md` 复核边界。

## 回滚

- Rollback owner records the decision in the release checklist before any candidate is re-cut.
- 合规材料错误时，优先回退本次发布材料和依赖清单改动。
- 已经引入但未经批准的依赖，不允许靠“先保留、下次再说”视为通过。
- 若依赖已进入发布包但未完成审查，必须撤销该发布候选。

## 验证

- `verify-release.ps1 -Light` 通过。
- `verify-placeholder-gates.ps1 -SelfCheck` 通过。
- `docs/review/release-checklist.md` 已写明 Dependency / License / SBOM 结论。

## 升级联系人

- 发布负责人。
- 依赖与安全合规 owner。
- 私有化 / 交付负责人。
