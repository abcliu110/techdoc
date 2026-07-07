# 12-API设计细则

> 版本：v0.1（初稿）
> 地位：统一设计态、运行态、平台管理 API 契约，保证前后端、插件、导入导出长期兼容。

## 陷阱覆盖表

| 07 条目 | 本文覆盖点 | 强制/检测方式 |
|---|---|---|
| B2 AST 权限合并 | filters JSON Schema 固定 | 安全契约测试 |
| B3 meta/执行一致性 | /meta 与 list/get/update 共享权限判定 | 契约测试 |
| B7 link 选项查询权限 | suggest 接口复用 AccessView | 契约测试 |
| C1 展开爆炸 | fields/expand 参数上限 | 性能测试 |
| C4 深分页 | 分页上限与游标分页 | API 测试 |
| E1 API 兼容 | Result/PageResult/OpenAPI diff | CI |
| F1 幂等并发 | action/transition/import/publish 幂等键 | 并发测试 |
| G2 表达式漂移 | 表达式子集 API 与错误语义 | 契约测试 |

## 1. 通用响应

规则 12-001：统一响应：

```json
{ "code": "0", "message": "success", "data": {}, "traceId": "..." }
```

规则 12-002：分页响应：

```json
{ "records": [], "page": 1, "size": 20, "total": 100, "hasNext": true }
```

规则 12-003：错误响应不得包含 SQL、堆栈、内部路径、密钥、token。

规则 12-004：字段级错误：

```json
{
  "code": "LC-DATA-2001",
  "message": "字段校验失败",
  "fieldErrors": [{"field": "amount", "code": "LC-DATA-2002", "message": "金额超出范围"}],
  "traceId": "..."
}
```

## 2. API 命名与方法

规则 12-010：全部业务 API 使用 POST；查询也使用 POST，避免复杂 filters 暴露在 URL。

规则 12-011：运行态固定：
`/api/data/{appCode}/{objectCode}/list|get|add|update|del|action|meta|suggest`。

规则 12-012：设计态固定：
`/api/designer/{resource}/add|update|get|list|del|publish|preview|validate`。

规则 12-013：请求/响应字段 camelCase，日期 ISO-8601 字符串，金额/decimal 字符串传输。

## 3. 动态查询 Schema

规则 12-020：filters 必须是 AST，不接受 SQL 片段。

```json
{
  "and": [
    {"field": "amount", "op": "gte", "value": "1000.00"},
    {"or": [{"field": "stateCode", "op": "eq", "value": "draft"}]}
  ]
}
```

规则 12-021：op 白名单：`eq/ne/gt/gte/lt/lte/in/nin/like/isNull/notNull/between`。

规则 12-022：sorts 只接受 `{ "field": "createTime", "order": "desc" }`，字段必须过白名单。

规则 12-023：expand 默认关闭；最多一层，必须声明对象种类和总行数上限。

规则 12-024：page/size 有最大值；深分页超过阈值返回错误并提示使用 cursor。

## 4. 幂等与并发

规则 12-030：`action/transition/batchAction/import/publish` 必须携带 `idempotencyKey`。

规则 12-031：update/del/action 必须携带 `revision` 或当前状态条件；冲突返回 `LC-DATA-4090`。

规则 12-032：重复幂等请求返回第一次执行结果，不重复执行副作用。

规则 12-033：幂等与并发分层固定为：先按 `tenantId + userId + api + idempotencyKey` 做 API 层去重，再执行 revision CAS，状态流转再追加 from_state 条件。revision 不能替代 idempotencyKey，idempotencyKey 也不能替代 revision。
强制方式：重复提交 + 并发 revision 冲突组合测试，对应 F1。

## 5. 元数据版本

规则 12-040：`/meta` 响应必须带 `metaVersion`。

规则 12-041：写接口可携带 `metaVersion`，服务端发现过旧时返回要求刷新错误码。

规则 12-042：请求入口固定权限视图和 MetaGraph 版本，响应 trace 可定位版本。

## 6. 兼容性

规则 12-050：OpenAPI diff 阻断删除字段、改类型、改必填、错误码语义改变。

规则 12-051：新增响应字段必须可忽略，新增请求字段必须有默认行为。

规则 12-052：废弃字段保留至少两个小版本，并在 OpenAPI 标记 deprecated。

规则 12-053：OpenAPI diff 只约束平台固定 DTO、Result/PageResult、设计态 API、插件公开 API 和动态 record 容器结构；`record` 内部业务字段不承诺静态 OpenAPI 字段兼容，兼容边界由 `metaVersion`、runtime schema 和 field_type 契约承担。
强制方式：OpenAPI diff + 旧 meta/新前端契约测试，对应 B11/G5。

## 7. 请求体标准结构

### 7.1 list

```json
{
  "filters": {
    "and": [
      {"field": "amount", "op": "gte", "value": "1000.00"}
    ]
  },
  "sorts": [
    {"field": "createTime", "order": "desc"}
  ],
  "fields": ["orderNo", "customer.level", "amount"],
  "expand": {
    "linkDepth": 1,
    "includeDeletedTombstone": true
  },
  "page": 1,
  "size": 20,
  "metaVersion": "app-sales-v12"
}
```

规则 12-070：`fields` 为空表示返回默认列表字段，不表示返回全部字段。

规则 12-071：`expand.linkDepth` 首版最大为 1；超过直接拒绝。

### 7.2 get

```json
{
  "id": "record-lid-or-id",
  "fields": ["orderNo", "customer.level", "items"],
  "metaVersion": "app-sales-v12"
}
```

规则 12-072：get 可以按需加载 table 子表；list 默认不加载 table 子表。

### 7.3 add/update

```json
{
  "idempotencyKey": "client-generated-key",
  "metaVersion": "app-sales-v12",
  "revision": 3,
  "record": {
    "customer": "cust-001",
    "amount": "1200.00"
  }
}
```

规则 12-073：add 可不传 revision；update 必须传 revision。

规则 12-074：formula/autonumber 字段出现在 record 中必须拒绝。

### 7.4 action/transition

```json
{
  "idempotencyKey": "submit-order-001",
  "metaVersion": "app-sales-v12",
  "ids": ["order-001"],
  "actionCode": "submit",
  "revision": 5,
  "params": {
    "comment": "提交审批"
  }
}
```

规则 12-075：action 对多条记录执行时必须返回逐条结果；首版默认同一事务内全成功或全失败，不支持部分成功。后续若开放部分成功，必须先补 ADR、错误报告格式、幂等重放语义和回滚边界。

### 7.5 suggest

link/user/org 选项查询统一走 suggest 接口，不允许前端缓存全量目标对象。

```json
{
  "field": "customer",
  "keyword": "abc",
  "filters": {
    "and": [
      {"field": "level", "op": "eq", "value": "vip"}
    ]
  },
  "size": 20,
  "metaVersion": "app-sales-v12"
}
```

规则 12-076：suggest 必须复用目标对象 AccessView，强制注入目标对象 data_scope，返回字段只包含目标对象 title_field 和允许展示的摘要字段。
强制方式：无目标对象 read 权限、无 title_field 读权限、跨租户目标 lid 三类契约测试，对应 B3/B7。

规则 12-077：list/get 展开 link 指向已软删记录时，响应只允许返回 tombstone 摘要：

```json
{"lid":"01H...", "deleted":true, "deletedAt":"2026-07-05T10:00:00.000Z", "title":""}
```

`title` 只有在当前用户对目标对象和 title_field 均有 read 权限时才能填充。
强制方式：软删目标、无目标对象 read、无 title_field read 三类契约测试，对应 B10。

## 8. 错误码与 HTTP 状态

规则 12-080：业务错误 HTTP 状态不全部使用 200。建议映射：

| 场景 | HTTP | code |
|---|---|---|
| 参数格式错误 | 400 | LC-COMM-4000 |
| 未认证 | 401 | LC-COMM-4010 |
| 无权限 | 403 | LC-PERM-4030 |
| 资源不存在 | 404 | LC-COMM-4040 |
| revision 冲突 | 409 | LC-DATA-4090 |
| metaVersion 过旧 | 409 | LC-META-4091 |
| 规则校验失败 | 422 | LC-DATA-4220 |
| 限流 | 429 | LC-COMM-4290 |
| 系统错误 | 500 | LC-COMM-5000 |

规则 12-081：前端必须显示 traceId；用户可把 traceId 提交给运维排查。

## 9. 幂等响应语义

规则 12-090：同一用户、同一租户、同一接口、同一 idempotencyKey 的重复请求：

| 第一次结果 | 重复请求返回 |
|---|---|
| 成功 | 返回第一次成功结果，`idempotentReplay=true` |
| 业务失败且无副作用 | 可重新执行或返回第一次失败，必须一致 |
| 执行中 | 返回 202 或业务错误“处理中”，不得并发执行 |
| 系统失败且状态未知 | 返回“状态未知需查询”，不得盲目重试副作用 |

响应示例：

```json
{
  "code": "0",
  "message": "success",
  "data": {
    "idempotentReplay": true,
    "result": {"stateCode": "submitted"}
  },
  "traceId": "..."
}
```

## 10. OpenAPI 门禁

规则 12-100：每个接口必须在 OpenAPI 中声明：
- operationId
- 请求 DTO
- 响应 DTO
- 错误码列表
- 是否需要 idempotencyKey
- 是否需要 metaVersion
- 权限要求

规则 12-101：OpenAPI diff 中以下变化直接阻断：
- 删除字段
- 字段从可选变必填
- 字段类型改变
- enum code 删除或复用
- Result/PageResult 结构改变
- 错误码含义改变
