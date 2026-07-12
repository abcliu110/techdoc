# lowcode-app

Spring Boot 应用装配与 HTTP 契约模块。

## 当前真实范围

- 运行态最小 HTTP 闭环：
  - `/api/data/{appCode}/{objectCode}/add|list|get|update|del|action|transition|suggest|export|importPreview|importCommit`
  - `/api/permission/explain`
- 设计态最小 HTTP 闭环：
  - `/api/designer/object/add|update|get|list|del|validate|publish|preview`
- 工作流最小 HTTP 诊断与人工操作入口：
  - `/api/workflow/{tenantId}/instances/{instanceLid}/timeline`
  - `/api/workflow/{tenantId}/instances/{instanceLid}/compatibility`
  - `/api/workflow/{tenantId}/instances/{instanceLid}/nodes/{nodeCode}/timeout`
  - `/api/workflow/{tenantId}/instances/{instanceLid}/nodes/{nodeCode}/manual-intervention`
- 应用包 / 插件最小市场安装门面：
  - `POST /api/packages/precheck|install`
  - `GET /api/packages|audit`
  - `POST /api/packages/{packageCode}/disable|enable|upgrade|rollback|uninstall-dry-run|uninstall`
- 统一 `Result` 响应、`traceId` 透传和安全错误映射。
- 受控请求头上下文解析：
  - `X-Tenant-Id`
  - `X-Workspace-Id`
  - `X-User-Lid`
  - `X-Role-Codes`
  - `X-Trace-Id`

## 未上线边界

- 当前运行态与设计态默认使用内存实现，只用于最小可用闭环和测试验证，不代表正式持久化方案。
- 当前未接入 Spring Security、数据库持久化、真实权限中心、发布流程审计、运行态动态 SQL 与正式 MetaGraph。
- 当前设计态只覆盖 `object` 资源，不包含页面设计器 UI；运行态 `export` / `importPreview` / `importCommit` 与 `/api/packages/*` 只提供最小受控演练门面，不代表正式应用包导入导出、正式插件市场、正式持久化安装记录或完整商业交付链路。
- 当前工作流 HTTP 入口仍只覆盖内存状态上的诊断、人工操作和最小任务推进，不代表正式持久化、调度和在途实例迁移。

## 模块职责

- 负责 Spring Boot 启动、Controller、请求上下文解析、统一错误响应和模块装配。
- 业务规则应优先沉淀在各自归属模块；只有为了本模块独立 HTTP 契约测试所需的最小胶水代码允许保留在这里。
