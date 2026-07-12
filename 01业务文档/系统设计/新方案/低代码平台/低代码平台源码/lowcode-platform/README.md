# 低代码平台

本仓库已经不只是最初的 M0 工程骨架。当前状态是：

- 有一批已经实现并可验证的最小闭环能力。
- 有一批只到“内存实现 / 演示内核 / 模块级服务”的能力。
- 还有一批生产上线必须具备的 OpenAPI、License、SBOM、私有化交付动作，目前只补到了最小真实门禁和文档材料。

当前补齐范围同时包含可验证的服务端最小能力、HTTP 入口和发布门禁材料；未接入正式生产链路的部分在下方边界中单独列明。

## 当前真实能力边界

| 里程碑 | 当前状态 | 当前真实范围 | 不能误判为 |
|---|---|---|---|
| M0 元模型 | 已实现 | 元模型定义、发布快照、MetaGraph、Schema Sync 计划、DDL 风险阻断、Flyway 基线、发布状态机与回滚预检内核 | 完整生产发布编排 |
| M1 运行态 | 部分实现 | `lowcode-app` 已暴露运行态最小 HTTP 闭环；`lowcode-runtime` 有内存实现、JDBC 仓储、幂等/审计/状态流转最小模型 | 已接入正式持久化、正式权限中心、正式安全体系 |
| M2 设计器 / 前端 | 部分实现 | `lowcode-web` 已有 builder / renderer / shared / app 契约与预览 demo，支持发布快照和运行态预览演示 | 完整页面设计器 UI、正式 OpenAPI 类型生成链路 |
| M3 工作流 | 模块内核 + 最小 HTTP 诊断入口 | `lowcode-workflow` 已有最小工作流运行时、任务推进、指标事件、实例时间线、兼容性诊断和人工干预 / 超时记录入口 | 已接入正式持久化、调度和在途实例迁移 |
| M4 商业 / 发布 | 部分实现 | 设计态发布、DDL 日志实体、发布状态、插件依赖 / 升级 / 降级 / 应用包扫描等最小内核已存在；`lowcode-app` 另有最小 package marketplace facade（`/api/packages/precheck|install|list|audit|upgrade|rollback|uninstall-dry-run`） | 已完成真实商业交付链路、正式市场安装能力 |
| M5 上线材料 | 本次补齐（仍是 light release gate） | 统一门禁脚本、CI workflow、runbook、人工 checklist、依赖合规、SaaS/私有化边界、OpenAPI 路由基线、License 清单、最小 SBOM、drift remediation 与 gap register | 正式 OpenAPI diff、正式 License 扫描、正式 SBOM 产物 |

## 当前仍属于内存 / 演示 / 未上线边界的部分

- `lowcode-app` 当前运行态与设计态默认仍以内存实现为主，用于最小闭环和测试验证。
- 当前未接入 Spring Security、真实权限中心、正式发布审计链路和正式 MetaGraph 多实例收敛治理。
- 工作流、插件、应用包、License、私有化验收仍大量停留在模块服务、内存状态与测试层；虽然 `lowcode-app` 已暴露 `export` / `importPreview` / `importCommit` 和 `/api/packages/*` 最小门面，但它们仍不等于正式持久化、正式市场安装或完整商业交付链路。
- OpenAPI diff、License 扫描、SBOM 生成当前还不是正式工具链；现阶段只有“基线路由 + 提交入库清单 + 静态比对”。

## 发布前门禁

统一入口：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1
```

轻量模式：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -Light
```

脚本自检：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-release.ps1 -SelfCheck
```

门禁脚本会串起：

- Docker / Testcontainers 预检：完整模式会先确认 Docker daemon，并优先复用本地 `mysql:8.0.37` 镜像；本地缺失时才拉取镜像，再启用真实 MySQL 集成测试。
- 后端 `mvn -B clean verify`
- 前端 `pnpm install --frozen-lockfile`、`lint`、`typecheck`、`test`、`build`
- 现有 `scan-todo.ps1`、`scan-sql-risk.ps1`、`scan-sensitive-log.ps1`
- 新增 P0/P1 regex 门禁
- mojibake 扫描
- OpenAPI / License / SBOM 最小真实门禁

OpenAPI / License / SBOM 当前由以下真实产物承接：

- `docs/compliance/openapi-http-baseline.txt`：`lowcode-app` HTTP 路由基线
- `docs/compliance/license-inventory.json`：Maven / pnpm / Docker License 清单
- `docs/compliance/sbom-minimal.json`：最小 SBOM 清单
- `docs/compliance/release-gap-register.md`：Light gate 未覆盖风险登记
- `docs/compliance/formal-toolchain-migration.md`：迁移到正式工具链的步骤

## 本地运行

### 前置环境

- Java 21
- Maven 3.9+
- Node 20
- corepack / pnpm 9
- Docker Desktop
- ripgrep

### 本地依赖

```powershell
docker compose up -d mysql redis
docker compose ps
```

### 后端验证

```powershell
mvn -B clean verify
```

默认 `mvn -B clean verify` 会运行确定性的单元测试、结构测试和构建校验；真实 MySQL 的 Testcontainers 集成测试需要显式启用：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-docker-testcontainers.ps1
mvn -B clean verify -Dlowcode.it=true
```

如果 Docker 预检在 `mysql:8.0.37` 拉取阶段失败，原因是 Docker Desktop 无法访问 Docker Hub 或镜像代理，不是本机缺少 MySQL；可以先配置代理、镜像加速，或预加载同名镜像后重跑预检。

### 前端验证

```powershell
cd lowcode-web
pnpm install --frozen-lockfile
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

## 文档入口

- 发布与恢复手册：`docs/runbooks/`
- 人工评审清单：`docs/review/manual-checklist.md`
- 合规与部署边界：`docs/compliance/`
- CI workflow：`.github/workflows/release-gate.yml`

## 重要说明

- 本仓库当前最容易被误判的风险，不是“代码跑不起来”，而是“把演示能力说成正式上线能力”。
- 所以发布说明必须同时写清：
  - 哪些能力已实现
  - 哪些能力仍是内存 / 演示
  - 哪些能力只是门禁和材料占位
