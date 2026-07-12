# T-102 动态数据 API 详细设计

> 版本：v0.1
> 里程碑：M1
> 适用任务：T-102a、T-102b
> 依据：`../03-需求/PRD-产品需求规格说明书.md` REQ-020~023、REQ-030~034、REQ-040~053、REQ-082~084；`../04-架构决策/02-运行时引擎设计.md` §1；`../../../../工程规范/通用规范/02-数据与API规范.md`、`../../../../工程规范/通用规范/04-安全与供应链规范.md`、`../../../../工程规范/通用规范/07-配置错误恢复与可观测性规范.md`、`../../../../工程规范/低代码平台规范/02-运行时数据与API契约.md`

---

## 1. 目标

T-102 提供模型驱动的统一动态数据 API。T-102a 先完成 tenant/deleted 强制注入、类型转换、动态 SQL 白名单和审计骨架；T-102b 在 T-103 权限完成后接入 AccessView、字段裁剪、数据范围和幂等。

## 2. API 表面

全部接口使用 POST：

```text
POST /api/data/{appCode}/{objectCode}/meta
POST /api/data/{appCode}/{objectCode}/list
POST /api/data/{appCode}/{objectCode}/get
POST /api/data/{appCode}/{objectCode}/add
POST /api/data/{appCode}/{objectCode}/update
POST /api/data/{appCode}/{objectCode}/del
POST /api/data/{appCode}/{objectCode}/action
POST /api/data/{appCode}/{objectCode}/suggest
POST /api/data/{appCode}/{objectCode}/export
POST /api/data/{appCode}/{objectCode}/importPreview
POST /api/data/{appCode}/{objectCode}/importCommit
```

T-102a 只实现 add/list/get/update/del/meta 的无权限骨架；export/import 在 T-102b 接入 AccessView 后实现。

## 3. 请求上下文

所有入口必须构造不可变 `ExecutionContext`：

```text
tenantId
workspaceId
userLid
roleCodes
appCode
objectCode
metaHash
requestMetaHash
traceId
idempotencyKey
requestTime
```

规则：

1. `tenantId` 缺失直接 fail-fast。
2. 写接口必须带 `requestMetaHash`，过旧返回 `META_VERSION_STALE`。
3. 任何 service 不得重新读取 latest MetaGraph。
4. 异步任务必须持久化 context 摘要。

## 4. 查询模型

`list` 请求：

```json
{
  "fields": ["order_no", "customer", "amount"],
  "filters": {"and": [{"field": "amount", "op": "gte", "value": 1000}]},
  "sorts": [{"field": "create_time", "order": "desc"}],
  "page": {"pageNo": 1, "pageSize": 20},
  "expand": [{"field": "customer", "fields": ["name", "level"]}]
}
```

规则：

1. 字段名必须来自 MetaGraph 白名单。
2. op 必须来自 FieldTypeHandler 的 queryCapability。
3. 首版只允许一层 link 展开。
4. pageSize 默认 20，最大 200；导出走异步任务。
5. SQL 根条件固定为 `tenant_id = ? and deleted = 0`。

## 5. 写入管线

所有写路径只允许进入 `DataWriteService`：

```text
1. 定位对象和字段
2. AccessView 判定
3. 未知字段拒绝
4. FieldTypeHandler 转换
5. before_save validate
6. before_save assign/fetch_from
7. 状态机编辑性检查
8. revision 乐观锁
9. 参数化 SQL
10. 审计日志
11. outbox 落库
```

导入、级联、系统修复任务不得绕过该服务。

## 6. 动态 SQL 白名单

动态 SQL 只允许由以下来源生成：

```text
tableName: MetaGraph 已发布 ObjectSnapshot.tableName
columns: FieldSnapshot.storageColumn + 系统列白名单
whereFields: AccessView 可读字段 + dataScope AST
sortFields: FieldTypeHandler 声明 sortable 的字段
```

用户输入只能作为参数值。禁止把请求中的 table、column、orderBy 原样拼入 SQL。

## 7. 幂等与并发

| 场景 | 策略 |
|---|---|
| add/action/importCommit | 必须带 idempotencyKey，落 `lc_rt_idempotency` |
| update | revision 乐观锁 + 可选 idempotencyKey |
| transition | idempotencyKey + 当前状态检查 |
| importCommit | importTaskId + idempotencyKey |

重复请求返回第一次执行结果摘要，不重复执行副作用。

## 8. 审计与事件

每次写入记录：

```text
eventType
tenantId/appId/objectCode/recordLid
actor
operation
fieldDiff
metaHash
permVersion
traceId
idempotencyKey
```

敏感字段、附件、密钥、token 只记录脱敏摘要。

## 9. 导入导出边界

T-102b 只实现对象级 CSV/JSON 导入导出的安全骨架：

1. 导出字段必须按 AccessView 裁剪。
2. 导入先 `importPreview`，生成字段映射、错误列表和影响报告。
3. `importCommit` 必须复用 DataWriteService。
4. 导出不得包含密钥、不可见字段和跨租户引用。

完整应用包导入导出由 T-304 设计承接。

## 10. 错误码

```text
TENANT_REQUIRED
OBJECT_NOT_FOUND
META_VERSION_STALE
FIELD_UNKNOWN
FIELD_TYPE_INVALID
FILTER_FORBIDDEN
SORT_FORBIDDEN
PERMISSION_DENIED
REVISION_CONFLICT
IDEMPOTENCY_CONFLICT
STATE_NOT_EDITABLE
SQL_WHITELIST_VIOLATION
```

## 11. 验收

1. 双租户下任何 list/get/update 都不能跨租户。
2. 恶意 field/op/sort/table 注入均被拒绝。
3. 未知字段写入被拒绝。
4. 字段类型非法值被拒绝且错误定位到字段。
5. 重复 add/action 不重复执行审计和 outbox 副作用。
6. revision 冲突返回明确错误。
7. 万级数据 list P95 达到 PRD 基线或输出硬件/索引/数据量报告。
