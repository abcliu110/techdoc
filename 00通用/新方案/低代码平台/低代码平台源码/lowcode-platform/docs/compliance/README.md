# 合规模块说明

本目录承接 M5 发布前的依赖、License、SBOM 和部署模式边界材料。

当前文件：

- `dependency-admission.md`：依赖准入基线与准入表模板。
- `formal-toolchain-migration.md`：迁移到正式 OpenAPI / License / SBOM 工具链的步骤。
- `license-sbom.md`：OpenAPI / License / SBOM 最小真实门禁说明与更新流程。
- `license-inventory.json`：Maven / pnpm / Docker 直依赖 License 基线。
- `openapi-http-baseline.txt`：`lowcode-app` HTTP 路由契约基线。
- `openapi-http-selfcheck.md`：OpenAPI HTTP 门禁自测说明与夹具入口。
- `release-gap-register.md`：Light gate 仍未覆盖的发布合规缺口登记。
- `sbom-minimal.json`：Java 模块、workspace 包、外部直依赖和镜像的最小 SBOM。
- `saas-private-boundary.md`：SaaS 与私有化模式边界、离线授权与降级要求。
- `browser-session-csrf.md`：F9 浏览器会话与 CSRF 边界、剩余缺口和机器门禁说明。

当前仓库仍未引入正式 OpenAPI 生成器、自动 License 扫描器或标准 SBOM 生成器，因此本目录采用“可复用导出脚本 + 提交入库基线 + `scripts/verify-placeholder-gates.ps1` 比对”作为发布门禁。

为避免文档回退到“明明已有最小门面却写成完全没有”，`scripts/verify-placeholder-gates.ps1` 还会校验 README / 合规模块说明里是否继续披露 `importPreview`、`importCommit`、`/api/packages/install` 这一类最小真实切片。

这类文档门禁只用于阻断能力描述漂移，不替代以下正式能力：

- 正式 OpenAPI field-level / enum-level breaking-change diff
- 正式 License 扫描与 transitive 依赖审查
- 标准 SBOM 产物（CycloneDX / SPDX）
- 浏览器会话 / CSRF 正式测试与阻断

如果需要规划正式工具链替换，先读：

- `formal-toolchain-migration.md`
- `release-gap-register.md`

导出或对比当前基线：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1 -MatchCommitted
```

如果要验证 OpenAPI HTTP 门禁不是占位脚本，可执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-placeholder-gates.ps1 -SelfCheck
```

安全/合规结构门禁由 release light gate 自动执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-security-compliance.ps1
```
