# POS 本地数据库自动建表与结构升级机制详解

## 一、结论先行

`nms4pos` 项目中确实存在 POS 本地数据库自动建表和结构升级机制，核心实现是：

```text
nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/local/VerMgrServer.java
```

这个机制不是扫描 `sql/` 目录、`data/` 目录或某个脚本目录来执行 SQL 文件，也不是 Flyway/Liquibase 这类版本化迁移框架。

它的本质是一个自研的“实体反射式数据库结构同步器”：

1. 启动或手动触发升级。
2. 读取当前代码中的实体类。
3. 查询本地 MySQL 当前已有表、列、索引。
4. 用实体类注解和数据库元数据做差异对比。
5. 自动拼接并执行 `CREATE TABLE`、`ALTER TABLE`、`CREATE INDEX` / `ADD INDEX`。

因此，准确说法是：

> POS 会根据 Java 实体类自动创建和升级本地 MySQL 表结构；它不会自动执行某个目录下的 SQL 脚本文件。

---

## 二、核心类与触发入口

### 2.1 核心升级器

核心类：

```text
VerMgrServer
```

源码位置：

```text
nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/local/VerMgrServer.java
```

类注释直接说明其职责：

```java
/** 版本管理工具，负责数据库自动升级 */
public class VerMgrServer {
}
```

它负责：

- 判断是否需要升级。
- 扫描实体类。
- 查询数据库当前结构。
- 创建缺失表。
- 补充缺失字段。
- 在安全范围内扩大字段类型。
- 补充索引。
- 更新数据库版本号。

### 2.2 启动时自动触发

POS 启动阶段检测 MySQL 可连接后，会手动初始化 MyBatisFlex，并调用普通升级：

```java
MybatisFlexBootstrap instance = MybatisFlexBootstrap.getInstance();
instance.setDataSource(dataSource).start();
new VerMgrServer().upgrade(false);
```

源码位置：

```text
nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/java/com/nms4cloud/pos3boot/Pos3BootApplication.java
```

这里的 `upgrade(false)` 表示普通升级：只有版本号不一致时才真正执行结构升级。

### 2.3 手动强制触发

系统还提供了一个接口用于强制升级：

```java
@PostMapping("/upgrade")
public NmsResult<Boolean> upgrade() {
  verMgrServer.upgrade(true);
  return NmsResult.ok();
}
```

源码位置：

```text
nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/controller/sync/SystemSettingController.java
```

这里的 `upgrade(true)` 会跳过版本号一致性判断，强制执行一次结构检查和升级。

---

## 三、版本判断机制

### 3.1 文件版本来源

`VerMgrServer.getCompileTime()` 从运行目录读取 `verInfo.ini`：

```java
String userDir = System.getProperty("user.dir");
String iniPath;
if (userDir.contains("nms4pos")) {
  iniPath = userDir + "/verInfo.ini";
} else {
  iniPath = userDir + "/../verInfo.ini";
}
JSONObject versionFile = JSON.parseObject(FileUtil.readUtf8String(iniPath));
return versionFile.getString(PosConfigKey.POS_VERSION);
```

也就是说，部署包中的 `verInfo.ini` 记录了当前程序版本。

### 3.2 数据库版本来源

数据库版本保存在本地 MySQL 的 `sys_config_data` 表中：

```sql
select str_val
from sys_config_data
where company_id = -1 and name = 'POS_VERSION'
```

如果查不到，代码使用默认版本：

```text
2023-11-22 13:50:31
```

### 3.3 是否需要升级

普通升级 `upgrade(false)` 的判断逻辑是：

```java
String versionInFile = getCompileTime();
nextVersion = versionInFile;
String versionInDb = getDBVersion();
if (versionInDb.equals(versionInFile)) {
  return true;
}
return false;
```

含义：

- `verInfo.ini` 版本等于数据库版本：不升级。
- 两者不一致：执行升级。
- `upgrade(true)`：强制升级，不做版本相等跳过。

升级完成后，`setDBVersion(nextVersion)` 会把新版本写回 `sys_config_data`。

---

## 四、整体执行流程

`VerMgrServer.upgrade(boolean force)` 的主流程如下：

```java
public void upgrade(boolean force) {
  if (needNotUpgrade(force)) {
    return;
  }

  Map<String, Map<String, String>> columnsMap = getColumns();
  Map<String, Set<String>> indexesMap = getIndexes();
  Set<Class<? extends BaseEntity>> entities = getEntities();

  Map<String, List<String>> pendingAlters = new LinkedHashMap<>();

  for (Class<? extends BaseEntity> clazz : entities) {
    upgradeColumn(clazz, columnsMap, indexesMap, pendingAlters);
  }

  executePendingAlters(pendingAlters);
  setDBVersion(nextVersion);
}
```

可以理解成 6 步：

1. 版本判断。
2. 查询数据库已有字段。
3. 查询数据库已有索引。
4. 反射扫描实体类。
5. 逐表对比差异并收集 DDL。
6. 执行 DDL 并更新版本号。

---

## 五、数据库元数据读取

### 5.1 查询当前库所有字段

`getColumns()` 查询 `information_schema.columns`：

```sql
SELECT table_name, column_name, column_type
FROM information_schema.columns
where TABLE_SCHEMA = database();
```

返回结构相当于：

```text
Map<表名, Map<列名, 列类型>>
```

例如：

```text
crm_points_rule -> {
  mid -> bigint,
  sid -> bigint,
  lid -> bigint,
  plan_lid -> bigint
}
```

这个结果用于判断：

- 表是否存在。
- 列是否存在。
- 列类型是否需要扩大。

### 5.2 查询当前库所有索引

`getIndexes()` 查询 `information_schema.statistics`：

```sql
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME
FROM information_schema.statistics
where TABLE_SCHEMA = database();
```

返回结构相当于：

```text
Map<表名, Set<索引名>>
```

这个结果用于判断索引是否已经存在，避免重复创建。

---

## 六、实体类扫描机制

### 6.1 扫描范围

实体类扫描逻辑：

```java
Reflections reflections = new Reflections("com.nms4cloud.pos2plugin.dal.entity");
return reflections.getSubTypesOf(BaseEntity.class);
```

也就是说，只有满足以下条件的类会参与自动建表/升级：

- 位于 `com.nms4cloud.pos2plugin.dal.entity` 包及其扫描范围内。
- 是 `BaseEntity` 的子类。
- 类上有 MyBatisFlex 的 `@Table` 注解。

### 6.2 表名来源

表名来自实体类上的 `@Table` 注解：

```java
@Table(value = "crm_points_rule", onInsert = YdInsertListener.class)
public class CrmPointsRule extends BaseEntity {
}
```

### 6.3 字段名来源

字段名来自字段上的 `@Column` 注解：

```java
@Column("plan_lid")
private Long planLid;
```

`VerMgrServer` 只处理带 `@Column` 的字段。没有 `@Column` 的字段不会被拼进建表 SQL。

如果字段配置了：

```java
@Column(ignore = true)
```

则在已有表补列逻辑中会跳过。

---

## 七、表不存在时的 CREATE TABLE 逻辑

### 7.1 判断表是否存在

`upgradeColumn()` 先取实体类上的 `@Table`：

```java
Table table = clazz.getAnnotation(Table.class);
String tableName = table.value();
```

然后判断数据库字段元数据中是否有这个表：

```java
if (columnsMap.containsKey(tableName)) {
  updateColumn(tableName, clazz, columnsMap.get(tableName), pendingAlters);
} else {
  createTable(tableName, clazz);
}
```

只要 `information_schema.columns` 中没有这个表，就会直接创建整张表。

### 7.2 建表 SQL 生成

`createTable()` 遍历实体字段：

```java
for (Field field : clazz.getDeclaredFields()) {
  Column column = field.getAnnotation(Column.class);
  if (column == null) {
    continue;
  }
  var columnPlus = field.getAnnotation(ColumnPlus.class);
  content.append(getColumnSql(field, column, columnPlus)).append(",\n");
}
```

每个字段通过 `getColumnSql()` 生成列定义：

```java
return "  " + name + " " + getDbType(field, column, columnPlus) + " COMMENT '" + comment + "'";
```

最后拼成：

```sql
CREATE TABLE 表名(
    pid BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号;' ,
    字段1 类型 COMMENT '注释',
    字段2 类型 COMMENT '注释',
    PRIMARY KEY (pid)
) COMMENT = '';
```

然后执行：

```java
Db.updateBySql(sql);
```

### 7.3 自动创建 lid 索引

如果实体类中有字段名为 `lid` 的字段，则建表后自动创建索引：

```java
CREATE INDEX idx_{table}_lid ON {table}({lidColumnName});
```

例如：

```sql
CREATE INDEX idx_crm_points_rule_lid ON crm_points_rule(lid);
```

---

## 八、表已存在时的 ALTER TABLE 逻辑

### 8.1 缺失列：ADD COLUMN

如果表存在，但某个实体字段对应的列不存在，则收集：

```java
String clause = String.format("ADD COLUMN %s", getColumnSql(field, column, columnPlus));
pendingAlters.computeIfAbsent(tableName, k -> new ArrayList<>()).add(clause);
```

最终会合并成：

```sql
ALTER TABLE crm_points_rule
  ADD COLUMN plan_lid bigint COMMENT '';
```

### 8.2 已有列：检查类型是否需要扩大

如果列已经存在，进入：

```java
checkAndUpdateColumnType(tableName, field, column, columns, pendingAlters);
```

它会比较：

- 数据库当前类型 `currentType`
- Java 实体推导出的期望类型 `expectedType`

如果需要升级，会收集：

```sql
MODIFY COLUMN column_name expected_type COMMENT '...'
```

最终执行：

```sql
ALTER TABLE 表名 MODIFY COLUMN 字段 新类型 COMMENT '注释';
```

### 8.3 类型升级只允许安全方向

代码里有安全判断：

```java
if (!isTypeCastSafe(currentType, expectedType)) {
  return;
}
```

它的思想是：

- 允许小范围类型向大范围类型升级。
- 不允许容易丢数据的反向缩小。
- `varchar` 长度只允许变长，不允许变短。
- `numeric/decimal` 精度和小数位只允许扩大，不允许缩小。
- `tinyint` 之间不考虑显示长度差异。

类型优先级大致如下：

```text
tinyint < smallint < int < bigint < float < double < decimal/numeric < char < varchar < text < longtext
```

这说明该机制是保守的结构补齐工具，不是任意 DDL 迁移器。

---

## 九、索引创建机制

### 9.1 ColumnPlus 动态索引

项目定义了自定义注解：

```java
public @interface ColumnPlus {
  boolean needToCreateIndex() default false;
  String indexName() default "";
  JdbcType jdbcType() default JdbcType.UNDEFINED;
}
```

如果字段上标注：

```java
@Column("plan_lid")
@ColumnPlus(needToCreateIndex = true)
private Long planLid;
```

则 `createIndex()` 会检查索引是否存在。

如果不存在，生成：

```sql
ADD INDEX idx_{table}_{column} ({column})
```

如果 `ColumnPlus.indexName()` 配了自定义索引名，则使用自定义索引名。

### 9.2 静态索引映射

`VerMgrServer` 还维护了一个静态索引补丁表：

```java
public static Map<String, Pair<String, String>> indexUpgMap = new HashMap<>(16);
```

里面记录若干历史表索引，例如：

```java
indexUpgMap.put(
    "dwd_food",
    Pair.of("idx_dwd_bill_lid", "create index idx_dwd_bill_lid on dwd_food(saas_order_no)"));
```

升级时会把这些历史索引也转为 `ADD INDEX ...` 子句，纳入合并执行。

---

## 十、字段类型推导规则

字段类型由 `getDbType()` 决定：

```java
JdbcType jdbcType =
    Optional.ofNullable(columnPlus).map(ColumnPlus::jdbcType).orElse(column.jdbcType());
```

优先级：

1. `@ColumnPlus(jdbcType = ...)`
2. `@Column(jdbcType = ...)`
3. Java 字段类型默认映射
4. 未识别类型默认 `varchar(128)`

主要映射关系：

| Java 类型 | MySQL 类型 |
| --- | --- |
| `String` | `varchar(128)` |
| `Integer` | `int` |
| `Long` | `bigint` |
| `Boolean` | `tinyint(1)` |
| `Short` | `tinyint` |
| `BigDecimal` | `numeric(19,10)` |
| `LocalDateTime` | `datetime` |
| `LocalDate` | `datetime` |
| `Date` | `datetime` |
| `enum` | `INT` |
| 未识别类型 | `varchar(128)` |

`JdbcType` 覆盖规则示例：

| JdbcType | MySQL 类型 |
| --- | --- |
| `INTEGER` | `INT` |
| `LONGVARCHAR` / `LONGNVARCHAR` | `varchar(256)` |
| `BLOB` | `TEXT` |
| `CLOB` | `longtext` |

例如：

```java
@Column("rule_description")
@ColumnPlus(jdbcType = JdbcType.CLOB)
private String ruleDescription;
```

会生成或升级为：

```sql
rule_description longtext COMMENT '...'
```

---

## 十一、合并 ALTER 的执行方式

升级过程中不会每发现一个字段就立即执行一条 SQL，而是先收集：

```java
Map<String, List<String>> pendingAlters = new LinkedHashMap<>();
```

每张表的变更会合并成一条：

```java
String sql = "ALTER TABLE " + tableName + " " + String.join(", ", clauses);
Db.updateBySql(sql);
```

例如：

```sql
ALTER TABLE crm_points_rule
  ADD COLUMN plan_lid bigint COMMENT '',
  ADD INDEX idx_crm_points_rule_plan_lid (plan_lid);
```

如果合并执行失败，代码会降级为逐条执行：

```java
Db.updateBySql("ALTER TABLE " + tableName + " " + clause);
```

这样做的目的：

- 减少 ALTER 次数。
- 同一张表的变更集中处理。
- 合并失败时仍尽量推进可执行的单条变更。

---

## 十二、和 SQL 脚本目录执行的区别

这个机制容易被误解为“自动执行某个目录脚本”，但源码证据显示不是。

| 项目 | VerMgrServer 自动建表机制 | SQL 脚本迁移机制 |
| --- | --- | --- |
| 输入来源 | Java 实体类和注解 | `.sql` 文件 |
| 结构来源 | `@Table`、`@Column`、`@ColumnPlus` | 脚本文本 |
| 执行触发 | 启动、手动升级接口 | 扫描目录或迁移框架 |
| DDL 生成 | 运行时拼接 | 预先写好 |
| 是否有版本化脚本 | 没有 | 通常有 |
| 是否能表达复杂迁移 | 弱 | 强 |
| 是否自动删除列 | 不做 | 脚本可做 |
| 是否自动迁移数据 | 不做 | 脚本可做 |

因此，这套机制适合：

- 新增实体表。
- 新增字段。
- 扩大字段类型。
- 补充简单索引。

不适合：

- 删除字段。
- 重命名字段。
- 拆表/合表。
- 数据搬迁。
- 复杂约束变更。
- 需要精确顺序控制的多步骤迁移。

---

## 十三、和 FullSyncDataService 的关系

`FullSyncDataService` 是云端到 POS 的全量数据同步服务，它会使用：

```text
data/sync_temp/{timestamp}/...
```

作为临时 JSON 文件目录。

例如：

```java
Path syncTempBase = Paths.get("data", "sync_temp");
Path syncTempRoot = syncTempBase.resolve(String.valueOf(System.currentTimeMillis()));
Path tableDir = syncTempRoot.resolve(tableKey);
Files.createDirectories(tableDir);
```

这个目录用于：

- 分页下载云端数据。
- 暂存 JSON。
- 校验页面文件大小。
- 提交到本地数据库。
- finally 中清理临时目录。

它不是建表脚本目录。

两者关系是：

1. `VerMgrServer` 负责让本地库具备表结构。
2. `FullSyncDataService` 负责把云端数据下载并插入这些表。

如果表不存在，数据同步时可能报：

```text
Table 'xxx' doesn't exist
```

此时根因通常是：

- `VerMgrServer` 没有执行。
- `verInfo.ini` 和数据库版本一致导致普通升级被跳过。
- 实体类没有被扫描到。
- 实体缺少 `@Table` 或字段缺少 `@Column`。
- 建表 SQL 执行失败。

---

## 十四、典型例子：crm_points_rule

实体类：

```text
nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmPointsRule.java
```

表名来自：

```java
@Table(value = "crm_points_rule", onInsert = YdInsertListener.class)
```

字段来自：

```java
@Column("mid")
private Long mid;

@Column("sid")
private Long sid;

@Column("lid")
private Long lid;
```

索引来自：

```java
@Column("plan_lid")
@ColumnPlus(needToCreateIndex = true)
private Long planLid;
```

长文本字段来自：

```java
@Column("level_rates")
@ColumnPlus(jdbcType = JdbcType.CLOB)
private String levelRates;
```

如果 `crm_points_rule` 表不存在，启动升级会创建表。

如果表存在但缺少 `level_rates`，升级会补列。

如果表存在但缺少 `plan_lid` 索引，升级会补索引。

---

## 十五、边界和风险

### 15.1 不会自动删除历史字段

如果实体类删除了某个字段，数据库中旧字段不会自动删除。

这是保守行为，符合既有系统安全修改原则：历史字段可能被老数据、老接口、报表、同步任务或外部工具依赖。

### 15.2 不会自动重命名字段

如果 Java 字段从：

```java
@Column("old_name")
```

改成：

```java
@Column("new_name")
```

系统通常会认为 `new_name` 是缺失列并新增，不会把 `old_name` 重命名成 `new_name`。

历史列仍会保留。

### 15.3 不适合复杂数据迁移

例如：

- 把字符串枚举值迁移成数字枚举 code。
- 把逗号分隔字段迁移成 JSON 数组。
- 拆分金额字段。
- 合并多张表。

这些都不能只依赖 `VerMgrServer`，需要明确的数据迁移方案、回滚方案和验证方案。

### 15.4 版本一致可能导致升级跳过

普通启动升级依赖 `verInfo.ini` 和 `sys_config_data.POS_VERSION` 的比较。

如果代码变了，但 `verInfo.ini` 没变，或者数据库版本已经被提前更新，`upgrade(false)` 可能直接跳过。

这种场景可以使用：

```text
POST /upgrade
```

触发 `upgrade(true)` 强制检查。

### 15.5 DDL 失败不会等于业务安全

合并 ALTER 失败后，代码会降级逐条执行。逐条执行也可能出现部分成功、部分失败。

排查时不能只看接口是否返回成功，还要看：

- 应用日志中的 `VerMgrServer` 输出。
- 实际表结构。
- 缺失列报错是否消失。
- 数据同步是否正常插入。

---

## 十六、排查方法

### 16.1 查启动日志

搜索：

```text
VerMgrServer
升级数据库
版本号不一致
CREATE TABLE
ALTER TABLE
合并执行
升级完成
```

### 16.2 查版本号

查看运行目录：

```text
verInfo.ini
```

查看数据库：

```sql
select str_val
from sys_config_data
where company_id = -1 and name = 'POS_VERSION';
```

### 16.3 查表是否存在

```sql
show tables like 'crm_points_rule';
```

### 16.4 查字段是否存在

```sql
show columns from crm_points_rule;
```

或：

```sql
select column_name, column_type
from information_schema.columns
where table_schema = database()
  and table_name = 'crm_points_rule';
```

### 16.5 查索引是否存在

```sql
show index from crm_points_rule;
```

或：

```sql
select index_name, column_name
from information_schema.statistics
where table_schema = database()
  and table_name = 'crm_points_rule';
```

### 16.6 强制升级

如果确认需要重新执行结构检查，可以调用系统升级接口：

```text
POST /upgrade
```

对应代码：

```java
verMgrServer.upgrade(true);
```

---

## 十七、新增表或字段时的注意事项

### 17.1 新增实体表

要让表自动创建，至少需要：

1. 实体类位于 `com.nms4cloud.pos2plugin.dal.entity` 扫描范围。
2. 实体继承 `BaseEntity`。
3. 实体类有 `@Table(value = "...")`。
4. 需要落库的字段有 `@Column("...")`。
5. 字段 Java 类型能被 `getDbType()` 正确映射，或用 `@ColumnPlus(jdbcType = ...)` 显式覆盖。

### 17.2 新增长文本字段

如果字段可能超过 `varchar(128)`，不能只写：

```java
@Column("xxx")
private String xxx;
```

否则默认是 `varchar(128)`。

应根据业务选择：

```java
@ColumnPlus(jdbcType = JdbcType.BLOB) // TEXT
```

或：

```java
@ColumnPlus(jdbcType = JdbcType.CLOB) // longtext
```

### 17.3 新增枚举字段

枚举类型会映射为：

```text
INT
```

这符合项目中“数据库存枚举 code，不存枚举名称或标签”的规则。

### 17.4 新增索引

简单单列索引用：

```java
@ColumnPlus(needToCreateIndex = true)
```

如需自定义索引名：

```java
@ColumnPlus(needToCreateIndex = true, indexName = "idx_xxx")
```

复杂联合索引不适合靠当前 `ColumnPlus` 表达，应按既有系统安全修改规范单独设计和验证。

---

## 十八、总结

`VerMgrServer` 的自动建表机制可以概括为：

```text
verInfo.ini 版本变化
  -> 启动调用 upgrade(false)
  -> 查询 information_schema
  -> Reflections 扫描实体类
  -> @Table 得到表名
  -> @Column 得到列名
  -> Java 类型 / JdbcType 得到 MySQL 类型
  -> 表不存在：CREATE TABLE
  -> 表存在：ADD COLUMN / MODIFY COLUMN / ADD INDEX
  -> Db.updateBySql() 执行
  -> sys_config_data 写入新 POS_VERSION
```

它解决的是 POS 本地库在部署新版本后“表结构跟随实体类补齐”的问题。

它不解决完整数据库迁移问题。遇到删除字段、重命名字段、复杂数据转换、历史数据清洗、联合索引、唯一约束、外键约束等场景时，必须单独设计迁移方案，不能误以为 `VerMgrServer` 会自动处理。
