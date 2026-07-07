# 10-Java编码细则

> 版本：v0.1（初稿）
> 地位：Java 21 + Spring Boot 3.4 后端编码细则，优先服务元模型、动态 DDL、多租户、表达式沙箱。

## 陷阱覆盖表

| 07 条目 | 本文覆盖点 | 强制/检测方式 |
|---|---|---|
| B1 租户上下文丢失 | TenantContext fail-fast 与异步传播模板 | 单测 + ArchUnit |
| B3 权限判定漂移 | 权限门面唯一入口 | ArchUnit |
| B4 沙箱逃逸 | 禁止直接 import Aviator | ArchUnit |
| C3 请求级版本固定 | MetaGraph 引用入口固定 | 集成测试 |
| F1 动作幂等并发 | revision/CAS 与幂等键 | 并发测试 |
| H1 SQL 白名单绕过 | 统一 QueryBuilder | ArchUnit + 注入测试 |
| H2 catch Exception | 禁止吞异常 | Checkstyle + 扫描 |
| H4 抽象膨胀 | 抽象准入标准 | 人工评审 |

## 1. 结构与复杂度

规则 10-001：单方法有效代码不超过 80 行，嵌套深度不超过 3 层，参数不超过 5 个；超过时优先引入局部值对象或拆分私有方法。
强制方式：Checkstyle。

规则 10-002：Service 公开方法必须表达业务用例，不得暴露 CRUD 拼装细节。
正例：`publishAppVersion(PublishVersionCommand command)`。
反例：`executeSql(String sql)`。
强制方式：人工评审。

规则 10-003：工具类必须 `final` + 私有构造，禁止 static 可变状态。
强制方式：Checkstyle。

规则 10-004：新增抽象必须至少满足：两个真实调用方、隔离明确变化点、能减少重复；否则保持局部实现。
强制方式：PR checklist，对应 H4。

## 2. Java 21 使用边界

规则 10-010：record 可用于不可变 DTO、Command、Query、值对象；Entity 不使用 record。

规则 10-011：Lombok 允许 `@Getter/@Builder/@RequiredArgsConstructor/@Slf4j`；Entity 可用 `@Data`，领域对象禁 `@Data` 暴露 setter。

规则 10-012：Optional 只用于返回值，禁止作为字段、DTO 属性、方法参数。

规则 10-013：Stream 链超过 3 个中间操作或包含复杂分支时改用 for 循环。

规则 10-014：`var` 只用于右侧类型明显的局部变量，禁止在业务核心转换中降低可读性。

## 3. 事务与并发

规则 10-020：`@Transactional` 只允许放在 service 层 public 方法；禁止 controller/dao 层事务。
强制方式：ArchUnit。

规则 10-021：禁止同类自调用事务方法；需要事务边界时拆到独立 service。
强制方式：ArchUnit + 人工评审。

规则 10-022：状态流转、action、publish、import 必须带幂等键或 revision/CAS 条件。
强制方式：并发测试。

规则 10-023：线程池禁止使用 `Executors.newFixedThreadPool/newCachedThreadPool`，必须显式命名线程、队列长度、拒绝策略、TenantContext 传播。
强制方式：代码扫描。

规则 10-024：Schema Sync DDL 必须串行化，同一租户/应用发布使用分布式锁。
强制方式：集成测试。

## 4. 异常与错误码

规则 10-030：业务错误统一抛 `BizException(ErrorCode, args)`，禁止返回 `false/null` 表示失败。

规则 10-031：禁止空 catch；禁止 `catch Exception` 后只 log 不落状态、不 rethrow、不转业务异常。
强制方式：Checkstyle/扫描，对应 H2。

规则 10-032：发布、DDL、规则、异步任务失败必须落库失败状态，并带 traceId、错误码、可恢复建议。

规则 10-033：字段级错误必须包含 field path，如 `fields[3].options.precision`。

## 5. 多租户与安全编码

规则 10-040：动态数据访问层发现 tenantId 为空必须 fail-fast，禁止查全量。

规则 10-041：TenantContext 不得在插件或表达式函数里直接读取；必须由调用上下文显式传入。

规则 10-042：所有动态 SQL 只能通过统一 `QueryBuilder/SqlAssembler`，禁止 Mapper XML 拼接动态表名/列名。

规则 10-043：业务代码禁止直接 import `com.googlecode.aviator.*`，必须走 `lowcode-expression` 门面。

规则 10-044：`$user/$record/$env` 上下文使用显式 DTO，禁止传 Entity。

## 6. 元模型与运行时特有规则

规则 10-050：MetaGraph 内对象不可变，加载完成后不得 setter 修改；发布新版本以整体引用替换。

规则 10-051：请求入口固定 MetaGraph 引用，整个请求生命周期不得重新获取版本。

规则 10-052：FieldDef 等 JSON DTO 必须保留 `_v`，反序列化未知字段按 21 细则处理。

规则 10-053：fetch_from、depends_on、data_scope 等引用必须通过 lc_meta_ref 或元模型引用检查器验证。

规则 10-054：引用完整性只有两个控制器：设计时由发布全图校验维护 `lc_meta_ref`，运行时由统一写入口校验 link/user/org 目标存在、同租户且有权限。其他模块不得重复实现引用检查或绕过这两个入口。
强制方式：ArchUnit 禁止散落 `existsByLid` 式引用检查 + 发布/写入集成测试，对应 B12/G1。

## 7. 验收清单

- [ ] Checkstyle 覆盖复杂度、catch、线程池、Optional。
- [ ] ArchUnit 覆盖事务层级、Aviator 门面、SQL 组装入口、权限入口。
- [ ] 双租户、并发 action、发布失败测试存在。
- [ ] 无未证明的通用抽象。

## 8. 典型代码模板

### 8.1 Service 公开方法模板

```java
/**
 * 发布应用版本。
 *
 * <p>事务边界：只覆盖元数据状态更新和 DDL Plan 记录；MySQL DDL 本身不可事务回滚。
 * 幂等性：同一 tenant/app/idempotencyKey 重复提交返回首次发布结果。
 * 租户语义：只能发布当前 TenantContext 下的应用。
 */
@Transactional
public PublishResult publishVersion(PublishVersionCommand command) {
  TenantSnapshot tenant = TenantContext.captureRequired();
  IdempotencyRecord idem = idempotencyService.begin(command.idempotencyKey(), tenant.tenantId());
  if (idem.isReplay()) {
    return idem.replayAs(PublishResult.class);
  }

  PublishState state = publishStateMachine.start(command, tenant);
  try {
    PublishResult result = publishExecutor.execute(state);
    idempotencyService.succeed(idem, result);
    return result;
  } catch (BizException ex) {
    publishStateMachine.markFailed(state.id(), ex);
    throw ex;
  }
}
```

反例：无 Javadoc、无幂等、catch 后只 log。

```java
public boolean publish(PublishDTO dto) {
  try {
    ddlService.run(dto);
    return true;
  } catch (Exception e) {
    log.error("publish error", e);
    return false;
  }
}
```

### 8.2 类型转换器模板

```java
public interface FieldValueConverter {
  FieldTypeEnum supports();

  ConvertedValue convert(FieldDef field, Object apiValue, ConvertContext context);
}

public final class DecimalFieldValueConverter implements FieldValueConverter {
  @Override
  public FieldTypeEnum supports() {
    return FieldTypeEnum.DECIMAL;
  }

  @Override
  public ConvertedValue convert(FieldDef field, Object apiValue, ConvertContext context) {
    if (apiValue == null || "".equals(apiValue)) {
      return ConvertedValue.nullValueIfAllowed(field);
    }
    BigDecimal value = DecimalParser.parseStrictString(apiValue);
    DecimalOptions options = field.requireOptions(DecimalOptions.class);
    if (value.precision() > options.precision() || value.scale() > options.scale()) {
      throw BizException.field(ErrorCode.DATA_DECIMAL_PRECISION_EXCEEDED, field.code());
    }
    return ConvertedValue.of(value);
  }
}
```

规则 10-080：转换器必须拒绝不明确输入，不得猜测。

### 8.3 权限判定入口模板

```java
public interface FieldAccessPolicy {
  FieldAccessDecision decide(UserContext user, ObjectDef object, FieldDef field, AccessType accessType);
}
```

规则 10-081：/meta 裁剪、list/get 返回裁剪、update 写校验必须依赖同一个 `FieldAccessPolicy`。

### 8.4 请求级 MetaGraph 固定模板

```java
public DataResult list(DataListCommand command) {
  MetaGraph graph = metaGraphProvider.requirePublished(command.appCode(), command.metaVersion());
  RequestRuntimeContext runtime = RequestRuntimeContext.of(graph, TenantContext.captureRequired(), UserContext.current());
  return dataQueryPipeline.execute(runtime, command);
}
```

反例：pipeline 中途再次 `metaGraphProvider.latest()`。

## 9. 禁止清单

规则 10-090：禁止在业务代码中出现以下模式：

| 模式 | 原因 |
|---|---|
| `Map<String, Object>` 贯穿多层 | 类型语义丢失，字段转换不可控 |
| `catch (Exception e) { return null; }` | 破坏状态机与恢复 |
| `new Thread(...)` | 丢失 TenantContext、traceId |
| `CompletableFuture.runAsync(...)` 无 executor | 使用 commonPool 丢上下文 |
| `LocalDateTime.now()` 直接散落 | 时区与测试不可控，应走 Clock |
| `objectCode.equals("order")` | 架构腐蚀，应用特判 |
| `BeanUtils.copyProperties` 跨 API/Entity | 字段泄露与兼容风险 |
| `@SneakyThrows` | 异常语义不清 |
