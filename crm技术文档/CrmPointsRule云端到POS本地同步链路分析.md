# CrmPointsRule 云端到 POS 本地同步链路分析

更新时间：2026-04-29

## 结论

当前源码里的主同步设计方向是正确的：`CrmPointsRule` 已经作为 POS 同步表注册到 `SyncBaseDataService`，POS 本地全量同步会请求云端 `pos4cloud` 的 `/sync/list`，`pos4cloud` 对 `CrmPointsRule` 做特例处理，再转调 CRM 的 `/crm_points_rule/listSync` 读取云端 CRM 表数据，最后由 POS 本地写入 `crm_points_rule`。

但这条链路还不是完全闭环，存在两个重点问题：

1. 日志中的 `未找到对应的类:CrmPointsRule` 说明运行中的 `pos4cloud` 服务没有识别 `CrmPointsRule`。源码已注册，不代表部署环境已经加载新包；优先检查 POS 配置的 `pos4cloudBaseUrl` 是否指向旧环境，或云端 `pos4cloud` 是否仍是旧版本。
2. CRM 端同步 VO 有 `memberDayDaysOfWeek`、`memberDayDaysOfMonth`，但 POS 侧同步 VO 和本地实体没有这两个字段。本地同步不会报错，但会员日按周/按月配置会丢失，后续积分规则计算如果依赖这两个字段会出现业务缺口。

## 这份代码是否正确

### 已经正确的部分

#### 1. POS 本地会把 CrmPointsRule 纳入全量同步

文件：

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\sync\SyncBaseDataService.java`

关键代码：

```java
classMapper.put(CrmPointsRule.class, crmPointsRuleMapper);
```

`SyncBaseDataService.init()` 会遍历 `classMapper.keySet()`，把类名注册进 `classNameMap`：

```java
for (Class<?> aClass : classMapper.keySet()) {
  classNameMap.put(aClass.getSimpleName(), aClass);
}
```

所以源码层面 `CrmPointsRule` 对应的同步名就是：

```text
CrmPointsRule
```

这与日志中的请求一致：

```json
"tableName":"CrmPointsRule"
```

#### 2. pos4cloud 的 /sync/list 会复用同一个 SyncBaseDataService

文件：

`D:\mywork\nms4pos\nms4cloud-pos4cloud\nms4cloud-pos4cloud-biz\src\main\java\com\nms4cloud\pos4cloud\controller\sync\SyncDataCloudController.java`

关键代码：

```java
@RequestMapping("/sync")
public class SyncDataCloudController {
  @RequireSignatureCheck
  @PostMapping(value = "/list")
  public <T extends Serializable> NmsResult<List<T>> list(
      @Valid @RequestBody RequireSignatureCheckRequest<SyncQueryRequest> request) {
    Page<T> page = syncBaseDataService.list(request);
    return toResult(page);
  }
}
```

这说明 POS 本地请求的 `pos4cloudBaseUrl + "/sync/list"` 最终进入 `SyncBaseDataService.list()`。

#### 3. CrmPointsRule 有专用云端查询分支

文件：

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\sync\SyncBaseDataService.java`

关键代码：

```java
if (CrmPointsRule.class.equals(clazz)) {
  CrmPointsRuleListDTO crmRequest =
      new CrmPointsRuleListDTO()
          .setMid(mid)
          .setSid(sid)
          .setCurrent(requestBody.getCurrent())
          .setPageSize(requestBody.getPageSize());
  NmsResult<List<CrmPointsRuleSyncVO>> result = nms4CloudCrmService.listPointsRule(crmRequest);
  ...
}
```

普通同步表直接查 `pos4cloud` 本地库；`CrmPointsRule` 不是这样，它会转调 CRM 服务读取 `crm_points_rule`。

#### 4. CRM 端同步接口存在

文件：

`D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\pointsrule\CrmPointsRuleController.java`

关键代码：

```java
@Inner
@PostMapping("/listSync")
public NmsResult<List<CrmPointsRuleSyncVO>> listCrmPointsRuleSync(
    @Valid @RequestBody CrmPointsRuleListSyncDTO request) {
  return crmPointsRuleServicePlus.listSync(request);
}
```

POS 云端 `Nms4CloudCrmService` 调用路径：

```java
@Post(value = "/crm_points_rule/listSync")
NmsResult<List<CrmPointsRuleSyncVO>> listPointsRule(@JSONBody CrmPointsRuleListDTO request);
```

两边路径和字段名可以对上。

#### 5. CRM listSync 查询逻辑基本正确

文件：

`D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\pointsrule\CrmPointsRuleServicePlus.java`

关键代码：

```java
query.eq(CrmPointsRule::getMid, request.getMid());
query.eq(request.getSid() != null, CrmPointsRule::getSid, request.getSid());
query.eq(request.getPlanLid() != null, CrmPointsRule::getPlanLid, request.getPlanLid());
query.orderByAsc(CrmPointsRule::getLid);
final Page<CrmPointsRule> page = new Page<>(request.getCurrent(), request.getPageSize());
```

它按 `mid/sid/planLid` 分页查询，并返回分页元信息。POS 请求 `pageSize=100`，CRM DTO 最大允许 `200`，这一点匹配。

### 不完整或有风险的部分

#### 风险 1：运行环境没有加载 CrmPointsRule 注册代码

日志返回：

```text
未找到对应的类:CrmPointsRule
```

这个错误发生在：

```java
final var clazz = classNameMap.get(requestBody.getTableName());
Assert.notNull(clazz, "未找到对应的类:" + requestBody.getTableName());
```

源码现在有注册代码，但运行环境返回找不到类，说明更可能是：

- POS 配置的 `nms.common.api-server` 或 `pos4cloudModule` 指向旧 `pos4cloud`。
- 云端 `pos4cloud` 没有重新部署。
- `pos4cloud` 打包时依赖了旧的 `nms4cloud-pos2plugin-biz`。
- 云端 JVM 没重启，仍运行旧类。

这不是 CRM 数据库表缺失导致的，因为流程还没走到 CRM `/crm_points_rule/listSync`。

#### 风险 2：会员日按周/按月字段没有同步到 POS 本地

CRM 端实体和同步 VO 有：

```java
private List<Integer> memberDayDaysOfWeek;
private List<Integer> memberDayDaysOfMonth;
```

CRM 同步转换也输出：

```java
.setMemberDayDaysOfWeek(jsonString(entity.getMemberDayDaysOfWeek()))
.setMemberDayDaysOfMonth(jsonString(entity.getMemberDayDaysOfMonth()))
```

但 POS 侧：

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\vo\member\CrmPointsRuleSyncVO.java`

没有这两个字段。

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmPointsRule.java`

也没有对应列：

```text
member_day_days_of_week
member_day_days_of_month
```

结果是：JSON 反序列化时这两个字段会被忽略，本地 `crm_points_rule` 表也不会建这两列。同步可以成功，但业务数据不完整。

如果 POS 本地积分计算需要判断会员日按周/按月生效日期，则必须补齐：

- POS `CrmPointsRuleSyncVO`
- POS `CrmPointsRule` 本地实体
- `SyncBaseDataService.toCrmPointsRule()` 字段映射
- 本地建表/升级后产生两个 `longtext` 或等价 JSON 字符串列

## 云端表结构如何创建到 POS 本地数据库

这里要区分两个概念：

- CRM 云端数据库的 `crm_points_rule` 表结构不会直接复制到 POS 本地。
- POS 本地表结构由 POS 代码里的本地实体 `com.nms4cloud.pos2plugin.dal.entity.CrmPointsRule` 生成。

### 1. 本地实体定义本地表结构

文件：

`D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmPointsRule.java`

关键代码：

```java
@Table(value = "crm_points_rule", onInsert = YdInsertListener.class)
public class CrmPointsRule extends BaseEntity {
  @Id(value = "pid", keyType = KeyType.Auto)
  private Long pid;

  @Column("mid")
  private Long mid;

  @Column("sid")
  private Long sid;

  @Column("lid")
  private Long lid;

  @Column("plan_lid")
  @ColumnPlus(needToCreateIndex = true)
  private Long planLid;
}
```

`@Table` 决定表名，`@Column` 决定列名，`@ColumnPlus(jdbcType = JdbcType.CLOB)` 会让建表逻辑生成 `longtext`。

### 2. POS 启动时执行数据库升级

文件：

`D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\src\main\java\com\nms4cloud\pos3boot\Pos3BootApplication.java`

关键代码：

```java
MybatisFlexBootstrap instance = MybatisFlexBootstrap.getInstance();
instance.setDataSource(dataSource).start();
new VerMgrServer().upgrade(false);
```

这段发生在 POS 启动并确认 MySQL 可连接时。

### 3. 升级器扫描所有 POS 本地实体

文件：

`D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\service\local\VerMgrServer.java`

关键代码：

```java
private Set<Class<? extends BaseEntity>> getEntities() {
  Reflections reflections = new Reflections("com.nms4cloud.pos2plugin.dal.entity");
  return reflections.getSubTypesOf(BaseEntity.class);
}
```

只要 `CrmPointsRule` 在 `com.nms4cloud.pos2plugin.dal.entity` 包下，并继承 `BaseEntity`，它就会被扫描到。

### 4. 表不存在时自动 CREATE TABLE

关键代码：

```java
if (columnsMap.containsKey(tableName)) {
  updateColumn(tableName, clazz, columnsMap.get(tableName), pendingAlters);
} else {
  createTable(tableName, clazz);
}
```

如果本地数据库没有 `crm_points_rule`，升级器会调用：

```java
createTable("crm_points_rule", CrmPointsRule.class);
```

建表逻辑会遍历实体字段上的 `@Column`：

```java
for (Field field : clazz.getDeclaredFields()) {
  Column column = field.getAnnotation(Column.class);
  if (column == null) {
    continue;
  }
  content.append(getColumnSql(field, column, columnPlus)).append(",\n");
}
```

最终生成类似：

```sql
CREATE TABLE crm_points_rule(
    pid BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号;',
    mid BIGINT COMMENT '',
    sid BIGINT COMMENT '',
    lid BIGINT COMMENT '',
    name varchar(128) COMMENT '',
    plan_lid BIGINT COMMENT '',
    ...
    PRIMARY KEY (pid)
) COMMENT = '';
```

同时如果实体里有 `lid` 字段，会创建 `idx_crm_points_rule_lid`：

```java
CREATE INDEX idx_crm_points_rule_lid ON crm_points_rule(lid);
```

`plan_lid` 上有 `@ColumnPlus(needToCreateIndex = true)`，升级器也会收集并执行索引：

```java
ADD INDEX idx_crm_points_rule_plan_lid (plan_lid)
```

### 5. 版本一致时不会自动升级

升级器不是每次启动都强制扫表。它先比较本地 DB 版本与 `verInfo.ini` 版本：

```java
String versionInFile = getCompileTime();
nextVersion = versionInFile;
String versionInDb = getDBVersion();
if (versionInDb.equals(versionInFile)) {
  return true;
}
```

因此如果你只是改了实体，但没有提升 `verInfo.ini` 版本，本地启动可能不会创建新表。

处理方式：

1. 提升 POS 包的 `verInfo.ini` 版本并重启。
2. 或调用本地接口强制升级：

```text
POST /systemSetting/upgrade
```

对应代码：

```java
@PostMapping("/upgrade")
public NmsResult<Boolean> upgrade() {
  verMgrServer.upgrade(true);
  return NmsResult.ok();
}
```

## 云端数据如何同步到 POS 本地表

### 1. POS 触发全量同步

入口：

```text
POST /sync/all
```

文件：

`D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\controller\sync\SyncDataController.java`

关键逻辑：

```java
CompletableFuture.runAsync(() -> fullSyncDataService.handleAllTable(KEY_IN_REDIS));
```

### 2. FullSyncDataService 遍历所有同步表

文件：

`D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\service\sync\FullSyncDataService.java`

关键代码：

```java
Map<Class<?>, BaseMapper<?>> classMapper = syncBaseDataService.getClassMapper();
for (Map.Entry<Class<?>, BaseMapper<?>> entry : classMapper.entrySet()) {
  Class<?> k = entry.getKey();
  downloadTableToFile(k, false, syncTempRoot);
}
```

对于 `CrmPointsRule.class`：

```java
String tableName = clazz.getSimpleName(); // CrmPointsRule
```

### 3. POS 请求 pos4cloud /sync/list

请求体核心字段：

```json
{
  "body": {
    "current": "1",
    "pageSize": "100",
    "tableName": "CrmPointsRule",
    "isPlatform": false
  }
}
```

请求地址：

```java
properties.getPos4cloudBaseUrl() + "/sync/list"
```

`pos4cloudBaseUrl` 的生成方式：

```java
return apiServer + "/api/" + pos4cloudModule;
```

所以最终形态通常是：

```text
{nms.common.api-server}/api/pos4cloud/sync/list
```

### 4. pos4cloud 根据 tableName 找同步类

`SyncBaseDataService.list()` 中：

```java
final var clazz = classNameMap.get(requestBody.getTableName());
Assert.notNull(clazz, "未找到对应的类:" + requestBody.getTableName());
```

如果运行环境没有注册 `CrmPointsRule`，就会得到当前日志：

```text
未找到对应的类:CrmPointsRule
```

### 5. CrmPointsRule 特例转调 CRM

命中 `CrmPointsRule.class` 后：

```java
NmsResult<List<CrmPointsRuleSyncVO>> result = nms4CloudCrmService.listPointsRule(crmRequest);
```

Forest 客户端路径：

```text
{baseUrl}/api/scrm/crm_points_rule/listSync
```

CRM 端根据 `mid/sid/current/pageSize` 查 `crm_points_rule`。

### 6. pos4cloud 把 CRM VO 转成本地 POS 实体结构

代码：

```java
List<CrmPointsRule> data =
    Optional.ofNullable(result.getData()).orElse(Collections.emptyList()).stream()
        .map(this::toCrmPointsRule)
        .toList();
```

然后返回给 POS 本地。

### 7. POS 本地先下载到临时文件

POS 本地不会边下边写库，而是先分页下载到：

```text
data/sync_temp/{timestamp}/CrmPointsRule_merchant/page_0000.json
data/sync_temp/{timestamp}/CrmPointsRule_merchant/metadata.json
```

这样做的目的是先保证下载阶段完整，避免下载到一半就清空本地数据。

### 8. 下载全部成功后统一提交数据库

提交阶段：

```java
commitTableFromFile(k, mapper, false, midColName, syncTempRoot);
```

对于商户数据，会先删旧数据：

```java
where mid in (-2, 当前mid)
```

然后读取临时文件：

```java
List<?> data = JSON.parseArray(jsonData, clazz);
mapper.insertBatch((Collection<Object>) data);
```

最终写入 POS 本地 `crm_points_rule` 表。

## 当前日志的准确解释

日志：

```text
云端返回错误：未找到对应的类:CrmPointsRule
```

说明：

1. POS 本地已经把 `CrmPointsRule` 纳入同步表清单。
2. POS 本地已经成功发起 `/sync/list` 请求。
3. 请求到达了某个 `pos4cloud` 服务。
4. 这个运行中的 `pos4cloud` 服务没有在 `classNameMap` 中注册 `CrmPointsRule`。
5. 流程还没有进入 CRM `/crm_points_rule/listSync`。
6. 流程也还没有进入 POS 本地数据库插入阶段。

因此当前第一优先级不是查本地表，也不是查 CRM 表，而是查运行中的 `pos4cloud` 服务版本和请求指向。

## 推荐排查顺序

### 1. 确认 POS 实际请求地址

查 POS 配置：

```text
nms.common.api-server
nms.common.pos4cloud-module
```

代码生成规则：

```java
apiServer + "/api/" + pos4cloudModule
```

确认日志里的请求到底打到了哪台 `pos4cloud`。

### 2. 确认 pos4cloud 运行包包含 CrmPointsRule

在云端运行包或源码版本中确认：

```java
classMapper.put(CrmPointsRule.class, crmPointsRuleMapper);
```

并确认：

```java
@MapperScan("com.nms4cloud.pos2plugin.dal.mapper")
@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})
```

当前源码里 `Pos4cloudApplication` 已有这两个配置，运行环境也必须是这份代码。

### 3. 确认 POS 本地表是否创建

云端类映射修复后，再查本地 POS 数据库：

```sql
show tables like 'crm_points_rule';
```

如果不存在：

```text
POST /systemSetting/upgrade
```

或提升 `verInfo.ini` 版本后重启 POS。

### 4. 确认同步结果

全量同步：

```text
POST /sync/all
```

查询进度：

```text
POST /sync/progress
```

查询本地数据：

```sql
select count(*) from crm_points_rule;
select lid, mid, sid, plan_lid, points_rule_enabled from crm_points_rule limit 10;
```

### 5. 补齐会员日字段

如果业务需要会员日配置在 POS 生效，需要补齐以下 POS 侧字段：

POS 同步 VO：

```java
private String memberDayDaysOfWeek;
private String memberDayDaysOfMonth;
```

POS 本地实体：

```java
@Column("member_day_days_of_week")
@ColumnPlus(jdbcType = JdbcType.CLOB)
private String memberDayDaysOfWeek;

@Column("member_day_days_of_month")
@ColumnPlus(jdbcType = JdbcType.CLOB)
private String memberDayDaysOfMonth;
```

映射：

```java
.setMemberDayDaysOfWeek(source.getMemberDayDaysOfWeek())
.setMemberDayDaysOfMonth(source.getMemberDayDaysOfMonth())
```

然后执行 POS 数据库升级，让本地表新增两列。

## 最小闭环标准

这条链路算真正完成，需要同时满足：

1. POS 本地 `SyncBaseDataService.classMapper` 有 `CrmPointsRule`。
2. 云端 `pos4cloud` 运行版本也有 `CrmPointsRule`。
3. `pos4cloud` 能访问 CRM `/crm_points_rule/listSync`。
4. POS 本地数据库有 `crm_points_rule` 表。
5. POS 本地表字段覆盖 CRM 同步 VO 中所有 POS 需要的字段。
6. `/sync/all` 不再报 `未找到对应的类:CrmPointsRule`。
7. 本地 `crm_points_rule` 有数据，并且关键字段与云端一致。

