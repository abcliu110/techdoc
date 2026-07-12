# T-004 Schema Sync 动态 DDL 详细设计

> 版本：v0.1
> 所属里程碑：M0 元模型内核
> 依赖：T-003
> 输入：`../03-需求/PRD-产品需求规格说明书.md`、`../04-架构决策/00-总体架构与技术选型.md`、`../04-架构决策/01-元模型设计.md`、`../07-知识库同步/07-低代码平台级架构陷阱与高难度问题清单.md`、`08-详细设计总纲.md`、`../../../../工程规范/低代码平台规范/06-陷阱覆盖矩阵.md`、`../../../../工程规范/通用规范/02-数据与API规范.md`、`../../../../工程规范/通用规范/06-模块兼容与发布规范.md`、`../../../../工程规范/通用规范/07-配置错误恢复与可观测性规范.md`、`../../../../工程规范/低代码平台规范/01-元模型与物理存储契约.md`、`../../../../工程规范/低代码平台规范/05-发布安全运维与测试契约.md`、`../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md`、`../04-架构决策/ADR/ADR-LOWCODE-ID-001-id-strategy.md`、`../04-架构决策/ADR/ADR-LOWCODE-STORE-001-metadata-json-aggregate.md`、`../04-架构决策/ADR/ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md`、`../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md`

---

## 1. 目标

实现元数据对象到 MySQL 动态物理表的 Schema Sync 初版：

- 生成 DDL Plan。
- 执行安全 DDL。
- 写 DDL 日志。
- 维护物理结构登记表。
- 提供 Reconciler 差异检测。

T-004 实现 M0 可用的发布状态机骨架、DDL Plan、Schema Sync 能力和 Reconciler detect/resume 接口。完整设计器发布 UI 放到 T-206，但 M0 必须能通过服务层执行可恢复发布。

## 2. 核心原则

1. 只做加法：建表、加列、加索引、扩大长度/精度。
2. 不自动删列、缩列、改类型。
3. DDL 执行前必须先生成 DDL Plan。
4. DDL 不包事务，失败必须可追踪。
5. diff 优先使用 `lc_rt_physical_schema`，information_schema 只用于对账和登记表重建。

## 3. 核心接口

```java
public interface SchemaSyncService {
  DdlPlan plan(SchemaSyncCommand command);
  DdlExecutionReport execute(DdlPlan plan);
  ReconcileReport reconcile(ReconcileCommand command);
}
```

```java
public record SchemaSyncCommand(
    Long tenantId,
    Long appId,
    String appCode,
    List<ObjectDef> objects,
    String targetVersion
) {}
```

## 4. DDL Plan 模型

```java
public record DdlPlan(
    String planId,
    Long tenantId,
    Long appId,
    String targetVersion,
    List<DdlStep> steps,
    List<DdlRisk> risks
) {}

public record DdlStep(
    int stepNo,
    DdlType type,
    String objectCode,
    String tableName,
    String columnName,
    String sql,
    DdlRiskLevel riskLevel,
    boolean executable
) {}
```

`DdlType`：

```text
CREATE_TABLE
ADD_COLUMN
WIDEN_COLUMN
ADD_INDEX
REGISTER_ONLY
BLOCKED_DROP_COLUMN
BLOCKED_NARROW_COLUMN
BLOCKED_CHANGE_TYPE
BLOCKED_UNSUPPORTED_FIELD_TYPE
```

## 5. FieldTypeHandler DDL 映射

T-004 必须按 ADR-LOWCODE-FIELDTYPE-SPI-001 实现字段类型处理器注册表。Schema Sync 只消费 `FieldTypeHandler.ddlMapping`、`comparePhysicalColumn`、`capabilities` 与 DDL 契约向量，不得自行散落 `switch(field_type)`。`../../../../工程规范/低代码平台规范/01-元模型与物理存储契约.md` 的字段类型表格是人工可读索引，不能成为第二套事实源。

```java
public interface FieldTypeHandler {
  String typeCode();
  ColumnDefinition ddlMapping(FieldDef field);
  ColumnCompatibility comparePhysicalColumn(FieldDef field, PhysicalColumn column);
  FieldTypeCapabilities capabilities();
  ContractVectors contractVectors();
}
```

人工索引对齐 `../../../../工程规范/低代码平台规范/01-元模型与物理存储契约.md`；可执行事实源是 `FieldTypeHandler` 实现和 `contractVectors`，不得维护第二套隐藏映射。

重点：

- `link` 默认 `{field_code}_lid varchar(26)`。
- `table` 不在父表加 JSON 列。
- `multilink` M0 不执行 through 表 DDL，只生成字段级阻断项和后续能力提示；阻断粒度来自 `capabilities().m0PublishSupported=false`。
- `formula` 首版默认不落库。
- M0 不支持能力由 `capabilities().m0PublishSupported=false` 表达，DDL Plan 生成字段级阻断项。

M0 决策：`multilink` 字段生成 `BLOCKED_UNSUPPORTED_FIELD_TYPE` 计划项，`executable=false`；同一对象的其他字段仍可生成可执行 DDL step。发布激活阶段看到任一阻断项必须失败并返回能力缺口报告，不能跳过该字段后宣称对象已完整发布。真实 through 表能力在后续任务补齐。

### 5.1 M0 字段类型 DDL 策略

| field_type | M0 DDL 策略 |
|---|---|
| text | 生成 `varchar(n)`，默认 255，最大 1024 |
| textarea | 生成 `text` |
| richtext | 生成 `mediumtext` |
| code | 生成 `mediumtext`，表示代码文本，不是元模型 code |
| integer | 生成 `bigint` |
| decimal | 生成 `decimal(p,s)`，默认 `decimal(18,4)` |
| percent | 生成 `decimal(9,4)` |
| currency | 生成 `{field_code} decimal(18,4)`，币种列 `{field_code}_currency varchar(8)` 按 options 决定 |
| date | 生成 `date` |
| datetime | 生成 `datetime(3)` |
| time | 生成 `time(3)` |
| select | 生成 `varchar(64)` |
| multiselect | M0 生成 `json`，但 in_filter=true 时必须阻断发布，后续倒排/关联表能力补齐前不得承诺高性能筛选 |
| checkbox | 生成 `tinyint` |
| link | 生成 `{field_code}_lid varchar(26)` + 普通索引 |
| table | 不在父表生成 JSON 列；要求子表对象存在，子表通过父记录 lid 建关联列 |
| multilink | 阻断，生成 `BLOCKED_UNSUPPORTED_FIELD_TYPE` |
| autonumber | 生成 `varchar(64)`，按业务唯一键追加 `delete_token` |
| user | 生成 `{field_code}_lid varchar(26)` |
| org | 生成 `{field_code}_lid varchar(26)` |
| attachment | M0 生成 `json`，后续附件关联表/生命周期能力补齐前不得承诺高性能筛选 |
| formula | 默认不落库；若 options 声明 persisted=true，M0 阻断并提示后续能力 |

## 6. 建表模板

动态实体对象建表必须包含：

```text
id bigint primary key
tenant_id bigint not null
app_id bigint not null
object_id bigint not null
lid varchar(26) not null
state_code varchar(64) null
owner_user_lid varchar(26) null
owner_dept_lid varchar(26) null
owner_org_path varchar(512) null
业务字段...
revision bigint not null default 0
deleted tinyint not null default 0
deleted_at datetime(3) null
delete_token bigint not null default 0
create_time datetime(3) not null
create_by bigint not null
update_time datetime(3) not null
update_by bigint not null
```

默认索引：

```text
uk_{table}_tenant_lid_alive (tenant_id, lid, delete_token)
idx_{table}_tenant_deleted_create_time (tenant_id, deleted, create_time)
idx_{table}_tenant_deleted_state (tenant_id, deleted, state_code) -- 启用状态机时
idx_{table}_tenant_owner_user_lid (tenant_id, owner_user_lid)
idx_{table}_tenant_owner_dept_lid (tenant_id, owner_dept_lid)
```

说明：唯一索引禁止使用 nullable `deleted_at`；MySQL 允许多个 NULL，会绕过未删除记录唯一性。业务唯一键也必须追加 `delete_token`。

说明：`owner_user_lid`、`owner_dept_lid`、`owner_org_path` 是 DEC-REQ-002 的 M0 承载字段，M1 权限链按对象级 `CURRENT_ORG` / `OWNER_SNAPSHOT` 策略消费。M0 只负责动态表结构包含这些字段，不实现完整数据范围运行时。

## 7. diff 流程

```text
1. 读取 ObjectDef
2. 计算期望 PhysicalTable
3. 从 lc_rt_physical_schema 读取当前登记结构
4. 登记缺失时按需读取 information_schema
5. 生成差异
6. 分类为可执行/阻断/登记修复
7. 输出 DDL Plan
```

## 8. 执行流程

```text
1. 创建/加载 lc_meta_publish_task，状态 VALIDATING
2. 全图校验通过后进入 PLANNING，持久化 DDL Plan
3. 获取 DB 行锁并生成 fencing_token，状态 LOCKED
4. MDL 预检：长事务/慢查询/目标表锁等待风险，命中则阻断
5. 按 stepNo 进入 EXECUTING(step_n)，写 lc_rt_ddl_log STARTED
6. DDL 会话设置 lock_wait_timeout=10
7. 执行 SQL
8. 成功后更新 lc_rt_ddl_log SUCCESS，并更新 lc_rt_physical_schema
9. 任一步失败：更新 lc_rt_ddl_log FAILED，任务进入 FAILED_AT(step_n)
10. 全部成功：写 Version.snapshot，状态 SNAPSHOTTING -> ACTIVATING -> DONE
```

发布互斥：

- M0 使用 DB 行锁 + fencing token，不依赖 Redis 锁正确性。
- 发布命令必须带稳定 `task_no` 或幂等键；同一 `tenant_id/app_id/task_no` 重复提交时返回已有任务和当前状态，不得创建第二个发布任务或重复执行已成功 DDL step。
- 每个 step 执行前必须校验 task 的 fencing_token 仍为当前持有者。
- 旧 token 的执行者恢复后不得继续推进状态或执行 DDL。

恢复入口：

```text
resume(taskId): Reconciler 三方对账 -> 从 FAILED_AT(step_n) 之后继续或生成工单
abandon(taskId): 标记 ABANDONED，仅允许在无执行中 step 时操作
```

## 9. DDL 日志

使用 `../../../../工程规范/低代码平台规范/05-发布安全运维与测试契约.md` §1.1 的 `lc_rt_ddl_log` 契约。该表由 T-002 创建；T-004 启动时必须检查日志表存在，不存在直接失败并提示先执行 T-002 迁移。

错误信息必须脱敏，不记录业务数据值。

## 10. Reconciler 初版

差异类型：

```text
MISSING_TABLE
MISSING_COLUMN
EXTRA_COLUMN
TYPE_NARROWED
TYPE_WIDENED
TYPE_CHANGED
COLLATION_CHANGED
INDEX_MISSING
REGISTRY_DRIFT
```

接口：

```java
public interface SchemaReconciler {
  ReconcileReport detect(Long tenantId, Long appId);
  ReconcileFixPlan planFix(ReconcileReport report);
}
```

M0 只要求 detect 和 planFix，不要求自动修复全部差异。

### 10.1 列类型对比决策表

| 对比项 | 示例 | 结论 |
|---|---|---|
| 类型、长度、精度、scale、字符集、nullable、默认值完全一致 | varchar(64) vs varchar(64) | `IDENTICAL` |
| varchar 长度扩大、decimal 精度扩大且 scale 不降低 | varchar(64) -> varchar(128) | `TYPE_WIDENED`，可执行 |
| varchar 长度缩小、decimal 精度或 scale 降低 | decimal(18,4) -> decimal(10,2) | `TYPE_NARROWED`，阻断 |
| 类型族变化 | text -> varchar、json -> varchar | `TYPE_CHANGED`，阻断 |
| collation 改变 | utf8mb4_0900_ai_ci -> utf8mb4_bin | `COLLATION_CHANGED`，告警工单，默认不自动执行 |
| nullable 从 true 变 false | null -> not null | 如无数据证明则阻断 |
| 默认值改变 | default null -> default 'x' | 生成工单，默认不自动执行 |

## 11. 物理结构登记

每次成功执行建表/加列/加索引后，必须更新 `lc_rt_physical_schema`。

规则：

- 登记表是 Schema Sync 热路径来源。
- information_schema 用于校验登记表是否漂移。
- 登记表可重建，但重建必须审计。

## 12. 安全约束

- 表名、列名必须来自元数据 code 经过命名生成器。
- code 必须先过 09 命名规范。
- SQL 不允许用户自由输入片段。
- DDL SQL 日志不包含业务数据。
- 禁止 DROP COLUMN、DROP TABLE、ALTER COLUMN NARROW。

## 13. 测试

测试类：

```text
SchemaSyncPlanTest
SchemaSyncExecuteIntegrationTest
FieldTypeHandlerDdlMappingTest
DdlSafetyTest
PhysicalSchemaRegistryTest
SchemaReconcilerTest
PublishStateMachineTest
DdlMdlLockPrecheckTest
PublishFencingTokenTest
PublishIdempotencyTest
```

必测：

- 新对象生成 CREATE TABLE。
- 22 种 `FieldTypeHandler.ddlMapping` 输出与 `contractVectors` 中 DDL 期望一致。
- 加 text/decimal/date/link 字段生成 ADD COLUMN。
- link 字段生成 `{field_code}_lid varchar(26)`。
- user/org 字段生成 `{field_code}_lid varchar(26)`。
- 动态表系统列包含 `owner_user_lid`、`owner_dept_lid`、`owner_org_path`。
- multiselect 在 `in_filter=true` 时生成阻断项。
- formula 在 `persisted=true` 时生成阻断项。
- multilink 字段生成 `BLOCKED_UNSUPPORTED_FIELD_TYPE`；同对象其他字段可继续生成 DDL step，但发布激活必须因阻断项失败，不得宣称对象完整发布。
- 动态表唯一索引使用 `delete_token`，不得使用 nullable `deleted_at`。
- 删字段不生成 DROP COLUMN，只生成 BLOCKED 或 orphan 报告。
- 缩短 varchar、降低 decimal 精度被阻断。
- 重复执行 plan 幂等。
- DDL 第三步失败后日志记录前两步成功、第三步失败。
- Reconciler 能发现登记表缺列。
- 发布中断于每个状态时，`lc_meta_publish_task` 保留当前 step、错误码、traceId 和恢复建议。
- 同一 task_no 重复提交发布时返回已有任务，不重复创建任务、不重复执行已成功 DDL step。
- 长事务持有 MDL 时，发布预检阻断或在 lock_wait_timeout 后进入 FAILED_AT。
- 两个发布者并发时，旧 fencing token 无法继续执行 DDL 或推进状态。
- decimal scale 降低、text->varchar、collation 改变分别按 §10.1 输出正确差异分类。

## 14. 验收标准

- [ ] 22 种 field_type 有映射或明确阻断策略。
- [ ] DDL Plan 先生成后执行。
- [ ] DDL 日志可追踪每一步。
- [ ] 物理结构登记表更新正确。
- [ ] Reconciler detect 可用。
- [ ] 发布任务状态机、resume/abandon 接口骨架可用。
- [ ] DB fencing token 防并发发布。
- [ ] MDL 预检与 lock_wait_timeout 覆盖。
- [ ] 危险变更不执行。
- [ ] MySQL Testcontainers 集成测试通过。
