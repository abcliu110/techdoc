# T-005 MetaGraph 缓存详细设计

> 版本：v0.1
> 所属里程碑：M0 元模型内核
> 依赖：T-003
> 输入：`../03-需求/PRD-产品需求规格说明书.md`、`../04-架构决策/00-总体架构与技术选型.md`、`../04-架构决策/01-元模型设计.md`、`../04-架构决策/02-运行时引擎设计.md`、`../07-知识库同步/07-低代码平台级架构陷阱与高难度问题清单.md`、`08-详细设计总纲.md`、公共工程规范 00/10/12/19/21/24/27、`../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md`、`../04-架构决策/ADR/ADR-LOWCODE-ID-001-snowflake-ulid-code.md`、`../04-架构决策/ADR/ADR-LOWCODE-STORE-001-json-relational-hybrid.md`

---

## 1. 目标

实现应用级元数据不可变内存图 MetaGraph：

- 从 `lc_meta_version.snapshot` 加载已发布元数据。
- 构建对象、字段、关系、状态、动作、规则、权限索引。
- 本地缓存按版本整体替换。
- Redis 保存应用当前 metaVersion。
- 提供请求级版本固定接口。

T-005 不实现完整权限判定、动态数据 CRUD、表达式执行。

## 2. 核心模型

```java
public final class MetaGraph {
  private final Long tenantId;
  private final Long appId;
  private final String appCode;
  private final String metaVersion;
  private final Map<String, ObjectNode> objectsByCode;
  private final Map<String, PageNode> pagesByCode;
  private final Map<String, RoleNode> rolesByCode;
  private final Map<String, Set<RefEdge>> refsBySource;
  private final Map<String, Set<RefEdge>> refsByTarget;
}
```

规则：

- `MetaGraph` 构建完成后不可变。
- 内部集合使用不可变集合。
- 不暴露可变 DTO。
- 刷新版本时整体替换引用，不原地修改。

## 3. Node 设计

```text
ObjectNode
  code
  name
  tableName
  fieldsByCode
  relationsByCode
  statesByCode
  actionsByCode
  rulesByCode

FieldNode
  code
  name
  fieldType
  columnName
  required
  options

RelationNode
  relationType
  sourceObjectCode
  targetObjectCode
  sourceKey
  targetKey

RoleNode
  code
  permissions
```

## 4. 加载流程

```text
1. 根据 tenantId/appCode/metaVersion 读取 lc_meta_version
2. 解析 snapshot 为 AppSnapshotDef
3. JsonUpgrader 升级到当前 DTO 版本
4. 执行快照结构校验
5. 构建 ObjectNode/PageNode/RoleNode
6. 构建 refsBySource/refsByTarget
7. 构建权限预索引
8. 发布不可变 MetaGraph
```

## 5. Provider 接口

```java
public interface MetaGraphProvider {
  MetaGraph requirePublished(String appCode, String metaVersion);
  MetaGraph requireLatestPublished(String appCode);
  Optional<MetaGraph> findCached(String appCode, String metaVersion);
  void evict(String appCode);
}
```

规则：

- 运行时请求入口必须调用一次 Provider，并把 MetaGraph 放入 RequestRuntimeContext。
- 请求处理中不得再次调用 latest。
- `requirePublished(appCode, metaVersion)` 用于前端带 metaVersion 的写请求。

## 6. Redis 版本键

Key：

```text
lc:{env}:tenant:{tenantId}:app:{appCode}:meta:current
```

Value：

```json
{
  "metaVersion": "v12",
  "publishedAt": "2026-07-05T10:00:00.000Z"
}
```

规则：

- Redis 只存版本指针，不存完整 MetaGraph。
- 本地缓存存 MetaGraph。
- 多实例通过轮询或订阅发现版本变化。

M0 选择：先实现版本号轮询接口，不强制 Redis pub/sub。轮询间隔默认 5 秒，可配置。

DEC-REQ-005 承接：发布状态已落库但 Redis 版本键未更新或不可用时，健康实例必须通过 DB 当前版本轮询在 60 秒内收敛到新 `metaVersion`；窗口期请求继续使用进入请求时固定的 `metaHash`。

## 7. 请求级版本固定

`RequestRuntimeContext`：

```java
public record RequestRuntimeContext(
    TenantSnapshot tenant,
    UserSnapshot user,
    MetaGraph metaGraph,
    String metaHash,
    String traceId
) {}
```

规则：

- pipeline 后续只能从 context 取 metaGraph。
- 不允许下游 service 重新获取 latest graph。
- ArchUnit 可限制 runtime pipeline 内依赖 `MetaGraphProvider` 的包范围。
- 写接口必须校验请求 metaVersion/metaHash 与 context.metaGraph 一致；过旧返回 `LC-META-4091`。
- 异步任务只保存 ctx 摘要，不序列化完整 MetaGraph；消费侧按 metaHash/metaVersion 重建。

## 8. 缓存策略

本地缓存 key：

```text
tenantId + ":" + appCode + ":" + metaVersion
```

策略：

- 最大缓存最近 N 个版本，默认 3。
- 当前版本常驻。
- 旧版本用于窗口期请求和回滚。
- 冷加载超过 2s 记录 WARN 指标。

## 9. 快照结构

`AppSnapshotDef` 必须包含：

```json
{
  "_v": 1,
  "tenantId": 1,
  "appCode": "sales",
  "versionNo": "v12",
  "objects": [],
  "pages": [],
  "roles": [],
  "datasources": [],
  "plugins": []
}
```

规则：

- snapshot 是运行态唯一元数据来源。
- 设计态草稿不能影响已发布 snapshot。
- 历史 snapshot 必须能被当前代码读取或通过 JsonUpgrader 升级。

## 10. 观测指标

必须输出：

| 指标 | 说明 |
|---|---|
| `lowcode_metagraph_load_duration_ms` | 加载耗时 |
| `lowcode_metagraph_cache_hit_count` | 缓存命中 |
| `lowcode_metagraph_cache_miss_count` | 缓存未命中 |
| `lowcode_metagraph_version_lag` | 当前实例落后版本 |
| `lowcode_metagraph_load_failure_count` | 加载失败 |

## 11. 失败处理

| 场景 | 处理 |
|---|---|
| 当前版本加载失败，旧版本存在 | 保持旧版本服务，告警 |
| 当前版本加载失败，无旧版本 | 对该 app 请求返回 LC-META-5001 |
| 请求指定 metaVersion 不存在 | 返回 LC-META-4091 要求刷新 |
| snapshot 结构不兼容 | 阻断加载，记录兼容错误 |
| Redis 不可用 | 进入只读降级：本地缓存可继续服务读请求，写接口/发布/导入拒绝；DB 版本号轮询用于恢复收敛 |
| DB 已提交但 Redis 未更新 | DB 版本号轮询在 60 秒内收敛，写接口按 metaHash 校验防旧视图提交 |
| JsonUpgrader 缺失 | 阻断加载并告警，不得跳过升级器 |
| snapshot 未来版本 | 阻断加载，返回兼容错误 |

## 12. 测试

测试类：

```text
MetaGraphBuilderTest
MetaGraphProviderTest
MetaGraphVersionFixedTest
MetaGraphSnapshotCompatibilityTest
MetaGraphCacheIntegrationTest
MetaGraphRedisDegradeTest
MetaGraphUpgraderStrictModeTest
```

必测：

- 从 snapshot 构建对象/字段/关系索引。
- MetaGraph 不可变。
- 设计态修改不影响已加载已发布版本。
- 请求 context 中途不变。
- 旧版本和新版本并存。
- Redis 版本变化后本地缓存可刷新。
- 发布状态已落库但 Redis 版本键未更新时，健康实例通过 DB 轮询在 60 秒内收敛到新 metaVersion。
- snapshot 未知字段不导致失败。
- Redis 不可用时读请求可使用本地缓存，写接口和发布被拒绝。
- DB 当前版本变化但 Redis 未更新时，轮询能收敛。
- 缺失升级器和未来版本 snapshot 被阻断。

## 13. 验收标准

- [ ] MetaGraph 从 `lc_meta_version.snapshot` 加载。
- [ ] 对象/字段/关系/状态/动作/规则可 O(1) 按 code 查找。
- [ ] MetaGraph 不可变。
- [ ] 本地缓存按版本隔离。
- [ ] Redis 当前版本键可读写。
- [ ] 请求级版本固定测试通过。
- [ ] metaHash 写接口校验通过。
- [ ] Redis 降级行为与 24/27 细则一致。
- [ ] 加载失败有明确错误和日志。
