# 将 `CrmPointsRule` 同步改为 `pos4cloud -> crm` 非 Forest 调用

## Summary
保留现有统一同步入口 `pos4cloud /sync/list`，仅替换 `CrmPointsRule` 这条二跳调用方式：`pos4cloud` 不再加载 `pos2plugin` 里的 Forest CRM 客户端，也不再依赖 `${baseUrl}`，改为使用现有 `ReactiveFeign` 通过服务发现调用 `nms4cloud-crm/crm_points_rule/listSync`。`pos3boot` 侧保持现状，不改同步入口，不新增配置。

## Key Changes
- 在 `pos2plugin` 里抽出一个同步专用远程接口抽象，例如 `CrmPointsRuleSyncRemoteService`，仅包含 `listPointsRule(CrmPointsRuleListDTO)`。
- `SyncBaseDataService` 中 `CrmPointsRule` 特例分支不再直接依赖 `Nms4CloudCrmService`，改为依赖上述抽象；普通同步表查询逻辑保持不变。
- 在 `pos3boot` 侧提供该抽象的 Forest 实现，继续复用现有 `Nms4CloudCrmService`，避免影响 POS 本地其他会员相关调用。
- 在 `pos4cloud` 侧提供该抽象的 `ReactiveFeign` 实现：
  - 调用目标固定为服务发现名 `nms4cloud-crm/crm_points_rule/listSync`
  - 请求体使用 CRM 侧 DTO `CrmPointsRuleListSyncDTO`
  - 返回值解析为 `NmsResult<List<CrmPointsRuleSyncVO>>`
  - Same-Token 获取方式沿用 `pos4cloud` 现有 reactive wrapper 模式，从 Redis 读取 `nms4token:var:same-token`
- `pos4cloud-feign` 模块增加对 `nms4cloud-crm-api` 的依赖，用于直接引用 `CrmPointsRuleListSyncDTO` 和 `CrmPointsRuleSyncVO`。
- 从 `Pos4cloudApplication` 中移除对 `com.nms4cloud.pos2plugin.service.member.cloud` 的 `@ForestScan`，确保 `pos4cloud` 不再尝试创建 `Nms4CloudCrmService`。
- 不修改 `Nms4CloudCrmService`、`Nms4cloudInterceptor`、`forest.variables.baseUrl`，避免影响 `pos3boot` 现有会员功能。
- 不处理本轮的 POS 本地 `crm_points_rule` 缺列问题；该问题只在当前同步链恢复后再单独验证。

## Important Interface / Type Changes
- 新增同步专用抽象接口：只服务 `CrmPointsRule` 同步，不扩散到其他 CRM Forest 客户端。
- `pos4cloud` 新增一个内部 reactive wrapper 服务类，行为与现有 `*ReactiveFeign` 风格保持一致。
- `SyncBaseDataService` 的依赖由具体的 `Nms4CloudCrmService` 改为同步专用抽象，调用方行为不变。

## Test Plan
- 启动 `crm`、`pos4cloud`、`pos3boot`，其中 `pos4cloud` 不再依赖 Forest `baseUrl` 配置。
- 直接重放签名请求到 `POST http://127.0.0.1:9898/api/pos4cloud/sync/list`，参数为 `tableName=CrmPointsRule,current=1,pageSize=100,isPlatform=false`。
- 验证不再出现 `[Forest] Cannot resolve variable 'baseUrl'`。
- 验证 `pos4cloud` 能成功调用 `nms4cloud-crm/crm_points_rule/listSync`，并返回分页数据或进入下一层真实业务错误。
- 触发 `POST /sync/all`，验证 `CrmPointsRule` 下载阶段可以继续推进。
- 回归 1-2 张普通同步表，确认 `mapper.paginate(...)` 的 `/sync/list` 通用能力不受影响。
- 若同步推进到提交阶段失败，再单独处理 POS 本地 `crm_points_rule` 缺少 `member_day_days_of_week`、`member_day_days_of_month` 两列的问题。

## Assumptions
- 服务发现名为 `nms4cloud-crm`，`ReactiveFeign` 可直接用该服务名访问 `/crm_points_rule/listSync`。
- `pos4cloud` 运行环境中 Same-Token 可从 Redis key `nms4token:var:same-token` 读取，且该模式与现有 `pos4cloud-feign` wrapper 一致。
- 当前目标优先级是：不新增配置、不把地址写死、不让 `pos4cloud` 继续承载 `pos2plugin` 的 Forest CRM 客户端。
- 允许为 `CrmPointsRule` 建立同步专用远程抽象，但不要求本轮同时重构其他 CRM 调用。
