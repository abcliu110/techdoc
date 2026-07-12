# OpenAPI / License / SBOM 最小真实门禁

## 目标

当前仓库仍未接入正式的：

- `openapi.json` 自动生成与 breaking change diff
- Maven / pnpm / Docker 三层自动 License 扫描
- CycloneDX / SPDX 形态的完整 SBOM 生成

本次在“不新增第三方依赖”的约束下，把原来的纯占位门禁升级为**可执行的最小真实产物 / 检查**：

1. OpenAPI：检查 `lowcode-app` 现有 HTTP 路由集合与提交入库的契约基线一致。
2. License：检查 Maven 直依赖、pnpm 直依赖、Docker 镜像都已登记到提交入库的 License 清单。
3. SBOM：检查最小 SBOM 清单覆盖当前 Java 模块、前端 workspace 包、外部直依赖和 Docker 镜像。

统一入口仍是：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

基线导出 / 回归对比入口：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1 -MatchCommitted
```

路由提取器自测入口：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-placeholder-gates.ps1 -SelfCheck
```

## Light gate coverage

The current release gate is a light gate with blocking drift checks for:

1. route-level OpenAPI baseline drift
2. reviewed direct-dependency / image License inventory drift
3. minimal release-composition SBOM drift
4. committed baseline reproducibility via `export-release-baselines.ps1 -MatchCommitted`

It also blocks unresolved review placeholders such as `UNREVIEWED` or other unfinished review markers inside `license-inventory.json`.

## 当前真实门禁产物

### OpenAPI 过渡基线

- 文件：`docs/compliance/openapi-http-baseline.txt`
- 来源：`lowcode-app/src/main/java/**/*.java` 中带 `@RestController` / `@Controller` 的 controller 文件
- 门禁含义：
  - 只要新增、删除或改名 HTTP 路由，就必须同步更新基线。
  - 当前脚本会自动发现新增 controller 文件，不再只检查固定两个控制器。
  - 当前脚本支持简单的 class-level `@RequestMapping("/prefix")` + method-level `@GetMapping("/path")` 拼接。
  - 如果只是修改请求体/响应体结构，当前门禁**不会**自动识别，仍需在发布说明里显式标注契约变更。

### OpenAPI 自测基线

- 文件：`docs/compliance/openapi-http-selfcheck-baseline.txt`
- 夹具目录：`lowcode-app/src/test/resources/http-route-selfcheck/controllers/`
- 门禁含义：
  - 用固定测试 controller 证明脚本真的会从源码提取路由。
  - 夹具同时覆盖“新增 controller 文件自动发现”和“class-level + method-level 简单拼接”两个场景。

### License 清单

- 文件：`docs/compliance/license-inventory.json`
- 覆盖范围：
  - Maven 直依赖和 dependencyManagement/import BOM
  - `lowcode-web/package.json` 与 `lowcode-web/packages/*/package.json` 的外部直依赖
  - `docker-compose.yml` 里的镜像
- 门禁含义：
  - 新增外部依赖或镜像后，若未补 License 条目会直接阻断。
  - 内部模块依赖 `com.lowcode:*` 不要求登记第三方 License。

### 最小 SBOM

- 文件：`docs/compliance/sbom-minimal.json`
- 覆盖范围：
  - 根 POM 的 Java 模块清单
  - `lowcode-web` workspace 包清单与 workspace 链接关系
  - Maven / pnpm workspace 外部直依赖
  - Docker 镜像
- 门禁含义：
  - 这是“可追溯发布组成清单”，不是完整传递依赖 SBOM。
  - 任何模块、workspace 包、直依赖、镜像变化，必须同步更新。

## 脚本检查内容

`scripts/verify-placeholder-gates.ps1` 现在会执行：

1. 基础发布材料存在性检查。
2. 关键文档 token 检查，防止 README / runbook / checklist 脱节。
3. `openapi-http-baseline.txt` 与控制器路由集合比对。
4. 传入 `-SelfCheck` 时，额外验证 `openapi-http-selfcheck-baseline.txt` 与自测夹具路由集合一致。
4. `license-inventory.json` 与 Maven / pnpm / Docker 当前清单比对。
5. `sbom-minimal.json` 与模块 / workspace / 直依赖 / 镜像当前清单比对。
6. `export-release-baselines.ps1 -MatchCommitted`，确认三份提交入库基线能被当前仓库重新生成。

## 更新流程

### 新增或修改 HTTP 路由

1. 修改控制器。
2. 运行 `powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1`。
3. 同步提交 `docs/compliance/openapi-http-baseline.txt`。
4. 如果涉及请求/响应语义变化，在发布说明中单列契约变更。

### 新增依赖或镜像

1. 先走 [dependency-admission.md](./dependency-admission.md)。
2. 运行 `powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1`。
3. 更新并复核 `docs/compliance/license-inventory.json`。
4. 更新并复核 `docs/compliance/sbom-minimal.json`。

### 新增模块或 workspace 包

1. 更新根 POM 或 `lowcode-web/packages/*`。
2. 运行 `powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1`。
3. 同步更新 `docs/compliance/sbom-minimal.json`。
4. 如引入外部依赖，再同步更新 License 清单。

## Drift remediation

When `verify-release.ps1 -Light` fails on OpenAPI / License / SBOM drift:

1. Read the mismatch line and identify whether it is OpenAPI, License inventory, or SBOM drift.
2. If the repository content intentionally changed, run `powershell -ExecutionPolicy Bypass -File .\scripts\export-release-baselines.ps1`.
3. Review the regenerated baseline files before committing:
   - `docs/compliance/openapi-http-baseline.txt`
   - `docs/compliance/license-inventory.json`
   - `docs/compliance/sbom-minimal.json`
4. Rerun `powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light`.
5. If the release still depends on manual review outside the light gate coverage, record that limitation in `docs/compliance/release-gap-register.md` and `docs/review/release-checklist.md`.

## Formal toolchain migration

The migration path to formal OpenAPI diff, formal License scanning, and standard SBOM artifacts is documented in:

- `docs/compliance/formal-toolchain-migration.md`
- `docs/compliance/release-gap-register.md`

## 当前边界

- 这不是正式 OpenAPI diff，也不会自动识别 DTO 字段级 breaking change。
- 这不是完整 License 扫描，也不覆盖 pnpm 锁文件里的全部传递依赖。
- 这不是标准 CycloneDX / SPDX SBOM，也不包含 sha256、supplier、purl 等更完整字段。
- 这套 light gate 只能证明“提交入库的最小基线与当前仓库一致”，不能替代法务、供应链或正式契约平台的最终签发。

但它已经从“仅检查文档存在”升级为“检查仓库真实发布组成是否与基线一致”，可以作为当前 M5 发布门禁的最小真实防线。
