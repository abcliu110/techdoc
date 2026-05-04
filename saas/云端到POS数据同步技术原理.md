# 云端到 POS 数据同步技术原理

> 状态：已完成
> 更新日期：2026-04-30
> 相关模块：pos2plugin-biz、pos3boot-biz、pos4cloud、pos4cloud-feign、pos2plugin-api

---

## 一、概述

### 1.1 什么是云端到 POS 数据同步

SaaS 架构下，POS（收银终端）运行在餐厅局域网中，通过本地 MySQL 数据库存储核心业务数据。部分业务数据（如菜品、会员规则、优惠券等）由云端（CRM、ERP 等微服务）统一管理，POS 需要定期从云端拉取最新数据到本地，这一过程称为**云端到 POS 数据同步**。

同步发生在以下场景：
- **新店开业**：全量同步，拉取所有表数据
- **日常运营**：增量同步，云端数据变更后实时/定时拉取
- **版本升级**：表结构变更后，自动创建缺失的列/索引

### 1.2 涉及的模块

```
nms4cloud-pos3boot          （部署在云端，pos3 餐饮版本）
nms4cloud-pos4cloud         （部署在云端，pos4 云版本）
nms4cloud-pos2plugin        （共享业务逻辑模块）
  ├── pos2plugin-api         （接口、DTO、VO 定义）
  ├── pos2plugin-biz         （核心业务：SyncBaseDataService 等）
  └── pos2plugin-dal        （MyBatisFlex Mapper + Entity 定义）
nms4cloud-pos4cloud-feign   （pos4cloud 专用 Feign 封装）
```

---

## 二、同步入口

### 2.1 全量同步入口

**HTTP 接口**：`POST /sync/all`

**调用链路**：

```
SyncDataController.syncAll()
  → FullSyncDataService.handleAllTable(KEY_IN_REDIS)
```

由前端触发，用于新店初始化或数据重建。同步结果通过 Redis 轮询进度（`GET /sync/progress?key=xxx`）。

### 2.2 增量同步入口

**HTTP 接口**：`POST /sync/list`

**请求体示例**：

```json
{
  "body": {
    "tableName": "CrmPointsRule",
    "current": 1,
    "pageSize": 100,
    "isPlatform": false
  }
}
```

**调用链路**（pos4cloud）：

```
SyncDataController.list()
  → SyncBaseDataService.list()
    → [特殊表分支] → CrmPointsRuleSyncRemoteService.listPointsRule()
      → CrmPointsRuleSyncRemoteServiceImpl (ReactiveFeign, @Primary)
        → reactiveFeign.post("nms4cloud-crm/crm_points_rule/listSync", ...)
    → [普通表分支] → mapper.paginate(current, pageSize, queryWrapper)
    → Page 返回
```

**调用链路**（pos3boot，增量同步路径相同，区别在于 CrmPointsRule 分支）：

```
SyncBaseDataService.list()
  → [特殊表分支] → CrmPointsRuleSyncRemoteService.listPointsRule()
    → CrmPointsRuleForestServiceImpl (Forest)
      → nms4CloudCrmService.listPointsRule()
        → Forest HTTP POST ${baseUrl}/api/scrm/crm_points_rule/listSync
```

---

## 三、全量同步（FullSyncDataService）

### 3.1 执行流程

`FullSyncDataService.handleAllTable()` 分两个阶段执行：

#### 阶段 1：下载所有表到磁盘文件

```java
Map<Class<?>, BaseMapper<?>> classMapper = syncBaseDataService.getClassMapper();
for (Map.Entry<Class<?>, BaseMapper<?>> entry : classMapper.entrySet()) {
    Class<?> k = entry.getKey();
    downloadTableToFile(k, false, syncTempRoot);  // 下载商户数据

    if (syncBaseDataService.getClassRequiringPlatformData().contains(k)) {
        downloadTableToFile(k, true, syncTempRoot);  // 下载平台数据
    }
}
```

- 遍历 `classMapper` 中的**所有实体类**（约 30+ 张表）
- 调用 `downloadTableToFile()` 将数据写入临时 JSON 文件（`data/sync_temp/{timestamp}/{ClassName}.json`）
- 平台数据（`isPlatform=true`）需单独下载一次，用于总部/平台维度

#### 阶段 2：从磁盘文件统一提交到数据库

```java
for (Map.Entry<Class<?>, BaseMapper<?>> entry : classMapper.entrySet()) {
    Class<?> k = entry.getValue().getKey();
    BaseMapper<?> v = entry.getValue();
    commitTableFromFile(k, (BaseMapper<Object>) v, false, midColName, syncTempRoot);

    if (syncBaseDataService.getClassRequiringPlatformData().contains(k)) {
        commitTableFromFile(k, (BaseMapper<Object>) v, true, midColName, syncTempRoot);
    }
}
```

`commitTableFromFile()` 内部执行：

```java
// 1. 读取临时 JSON 文件
List<Object> records = readJsonFromFile(tempFile);

// 2. DELETE 旧数据（按 mid 分批）
queryWrapper.where("mid in (" + mids + ")");
mapper.deleteByQuery(queryWrapper);

// 3. INSERT 新数据
mapper.insertBatch(records);
```

### 3.2 classMapper 的初始化

`SyncBaseDataService.initNeedStoreData()` 中注册了所有门店级数据表：

```java
classMapper.put(PtDish.class, ptDishMapper);           // 菜品
classMapper.put(BizDiscount.class, bizDiscountMapper);  // 折扣
classMapper.put(CrmPointsRule.class, crmPointsRuleMapper); // 积分权益规则
// ... 共约 30+ 张表
```

`SyncBaseDataService.initNeedHeadquartersData()` 中注册总部级数据表：

```java
classMapper.put(ScMerchant.class, scMerchantMapper);   // 商户
classMapper.put(ScStore.class, scStoreMapper);          // 门店
classMapper.put(SysRole.class, sysRoleMapper);          // 角色
// ...
```

### 3.3 全量同步的特点

| 特点 | 说明 |
|------|------|
| 事务粒度 | 单表一批（DELETE + INSERT 为一个批次），整体无大事务 |
| 数据范围 | 下载阶段按 mid 分页，写入前先清空再批量插入 |
| 异常处理 | 单表失败不影响其他表，错误信息累积后统一返回 |
| 临时文件 | 存于 `data/sync_temp/{timestamp}/`，finally 中清理 |
| 进度追踪 | 进度百分比存入 Redis，客户端轮询获取 |

---

## 四、增量同步（SyncBaseDataService.list）

### 4.1 入口参数解析

```java
public <T extends Serializable> Page<T> list(
        RequireSignatureCheckRequest<SyncQueryRequest> request) {

    SyncQueryRequest requestBody = request.getBody();
    Class<?> clazz = classNameMap.get(requestBody.getTableName());
    Assert.notNull(clazz, "未找到对应的类:" + requestBody.getTableName());

    BaseMapper<T> mapper = (BaseMapper<T>) classMapper.get(clazz);
    Assert.notNull(mapper, "未找到对应的Mapper");

    long sid = Long.parseLong(request.getSid());
    ScStoreVO store = scStoreServicePlus.get(sid);
    Long mid = store.getMid();

    if (Boolean.TRUE.equals(requestBody.getIsPlatform())) {
        mid = -2L;  // 平台维度使用固定 mid = -2
    }

    // ... 分支逻辑
}
```

- `tableName`：实体类简单名称（`CrmPointsRule`、`PtDish` 等），通过 `classNameMap` 反查实体类
- `sid`：门店 ID，用于过滤门店级数据
- `mid`：商户 ID
- `isPlatform`：是否平台数据（`true` 时 mid 固定为 -2）

### 4.2 普通表：本地数据库分页查询

大多数表走通用分支，直接从本地 MySQL 分页读取：

```java
// 第 175-184 行
String midColName = flexEntityUtil.getMidColName(clazz);
String sidColName = flexEntityUtil.getSidColName(clazz);

QueryWrapper queryWrapper = new QueryWrapper()
    .where(String.format("%s = %s", midColName, mid));

if (!classRequiringHeadquartersData.contains(clazz)) {
    // 门店级数据：再按 sid 过滤
    queryWrapper.and(String.format("%s in (%s)", sidColName, sid));
}

return mapper.paginate(
    new Page<>(requestBody.getCurrent(), requestBody.getPageSize()),
    queryWrapper);
```

- **总部数据表**（`classRequiringHeadquartersData`）：只按 `mid` 过滤，所有门店共享（如商户、门店、角色权限）
- **门店数据表**：按 `mid AND sid in (sid)` 过滤（如菜品、折扣）

### 4.3 特殊表：CrmPointsRule 远程拉取

`CrmPointsRule` 是唯一一个不走本地 mapper 的表，因为它存储在 **CRM 微服务** 的数据库中，而不是 POS 本地。

```java
if (CrmPointsRule.class.equals(clazz)) {
    CrmPointsRuleListDTO crmRequest = new CrmPointsRuleListDTO()
        .setMid(mid)
        .setSid(sid)
        .setCurrent(requestBody.getCurrent())
        .setPageSize(requestBody.getPageSize());

    NmsResult<List<CrmPointsRuleSyncVO>> result =
        crmPointsRuleSyncRemoteService.listPointsRule(crmRequest);

    Assert.notNull(result, "积分权益规则同步失败");
    Assert.isTrue(result.isSuccess(), result.getErrorMessage());

    List<CrmPointsRule> data =
        Optional.ofNullable(result.getData())
            .orElse(Collections.emptyList())
            .stream()
            .map(this::toCrmPointsRule)
            .toList();

    Page<T> page = new Page<>(requestBody.getCurrent(), requestBody.getPageSize());
    page.setRecords((List<T>) data);
    page.setTotalRow(NullSafeUtils.nullSafe(result.getTotal()));
    page.setTotalPage(NullSafeUtils.nullSafe(result.getPages()));
    return page;
}
```

**关键点**：
- 请求发送给 CRM 微服务，由 CRM 查询其数据库并返回分页数据
- 返回的是 `CrmPointsRuleSyncVO`（远程 VO），需转换为 `CrmPointsRule`（本地 Entity）再写入本地 DB
- 写入本地 DB 的操作在 `FullSyncDataService.commitTableFromFile()` 中完成（增量同步接口本身只返回数据，由调用方写入）

---

## 五、CrmPointsRule 的接口抽象方案

### 5.1 为什么需要接口抽象

`CrmPointsRule` 的远程调用在 **pos3boot** 和 **pos4cloud** 中使用完全不同的 HTTP 客户端：

| 应用 | HTTP 客户端 | 寻址方式 | 认证方式 |
|------|------------|---------|---------|
| pos3boot | Forest | 固定 baseUrl（`${baseUrl}/api/scrm`） | Forest 拦截器添加商户/终端签名 |
| pos4cloud | ReactiveFeign | Nacos 服务发现（`nms4cloud-crm`） | Redis same-token（`nms4token:var:same-token`） |

两端的差异导致不能共用同一个实现类，必须通过**接口 + 多实现**的方式解决。

### 5.2 依赖注入优先级机制

Spring 容器中发现同一个接口有多个实现类时的处理规则：

```
@Primary 的 Bean 优先级最高
```

因此：
- pos4cloud 的 `CrmPointsRuleSyncRemoteServiceImpl` 标注 `@Primary`，Spring 自动注入
- pos3boot 的 `CrmPointsRuleForestServiceImpl` 不标注 @Primary，pos3boot 中 @Primary 的实现不存在，Spring 自动注入 Forest 实现

### 5.3 完整类图

```
com.nms4cloud.pos2plugin.api.service
└── CrmPointsRuleSyncRemoteService（接口）
    ├── listPointsRule(CrmPointsRuleListDTO) → NmsResult<List<CrmPointsRuleSyncVO>>

实现1（pos2plugin-biz）：
└── CrmPointsRuleForestServiceImpl
    → Nms4CloudCrmService（Forest HTTP 客户端）
      → POST ${baseUrl}/api/scrm/crm_points_rule/listSync
      → 认证：Forest 拦截器（商户/终端 MD5 签名）

实现2（pos4cloud-feign，@Primary）：
└── CrmPointsRuleSyncRemoteServiceImpl
    → ReactiveFeign
      → POST nms4cloud-crm/crm_points_rule/listSync
      → 认证：Redis same-token
```

### 5.4 pos4cloud 中 Forest 组件仍然存在但不触发

`Pos4cloudApplication` 保留 `@ForestScan(basePackages = {"com.nms4cloud.pos2plugin.service.member.cloud"})`，因此：
- `Nms4CloudCrmService`（Forest 接口）**仍然被实例化**
- 但 `SyncBaseDataService` 注入的是 `CrmPointsRuleSyncRemoteService` 接口
- 接口的 `@Primary` 实现是 ReactiveFeign 版本，**不会调用** Forest 接口
- `CrmPointsRuleForestServiceImpl` 中的 `Nms4CloudCrmService` 字段从未被调用，`${baseUrl}` 变量解析不会触发

---

## 六、POS 本地数据库表自动创建与升级原理

### 6.1 概述

POS 本地数据库由 MyBatisFlex 框架管理。实体类通过 `@Table` 注解声明表名，但 MyBatisFlex 本身**不自动建表**，表结构由 `VerMgrServer` 组件在应用启动时根据实体类自动创建或升级。

**升级触发条件**：`verInfo.ini` 中记录的编译时间戳大于 `sys_config_data` 表中存储的版本号。

### 6.2 架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                       POS 本地数据库自动升级架构                  │
└─────────────────────────────────────────────────────────────────┘

┌───────────────────┐      ┌──────────────────────────────────────┐
│   verInfo.ini     │      │           MySQL 数据库               │
│ (部署时复制到运行目录)│      │      (127.0.0.1:8066/nms)           │
│                   │      │                                      │
│ POS_VERSION:      │      │  sys_config_data                    │
│ "2026-04-30 ..."  │      │  (存储数据库版本号)                   │
└────────┬──────────┘      └──────────────┬───────────────────────┘
         │ getCompileTime()               │
         ▼                                │ versionInFile vs versionInDb
┌────────────────────────────────────────────────────────────┐
│                    VerMgrServer.upgrade()                  │
│                                                        │
│  ┌─────────────────────────────────────────────────┐  │
│  │ needNotUpgrade(): 对比版本号                     │  │
│  │   versionInFile == versionInDb → 直接返回        │  │
│  │   versionInFile > versionInDb → 执行升级        │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 1. getColumns()                                 │  │
│  │    → information_schema.columns                │  │
│  │    返回: Map<表名, Map<列名, 列类型>>            │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 2. getIndexes()                                 │  │
│  │    → information_schema.statistics             │  │
│  │    返回: Map<表名, Set<索引名>>                 │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 3. getEntities()                                │  │
│  │    Reflections 扫描 com.nms4cloud...dal.entity  │  │
│  │    → 所有 BaseEntity 子类（共 40+ 个实体）        │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 4. upgradeColumn() 逐表处理                     │  │
│  │    ├─ 表不存在 → createTable()（整表建）         │  │
│  │    └─ 表已存在 → updateColumn()（ALTER）         │  │
│  │         ├─ 缺失列 → ADD COLUMN                 │  │
│  │         └─ 列类型变化 → MODIFY COLUMN          │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 5. createIndex() 收集索引变更                   │  │
│  │    扫描 @ColumnPlus(needToCreateIndex=true)      │  │
│  │    → 缺失索引 → ADD INDEX                       │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 6. 合并 ALTER TABLE（每表一条语句）              │  │
│  │    同一列多条 MODIFY/ADD → 保留最后一条           │  │
│  │    ADD INDEX 不去重                              │  │
│  │    → Db.updateBySql() 执行                      │  │
│  └─────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 7. setDBVersion(nextVersion)                    │  │
│  │    写入 sys_config_data                         │  │
│  │    name='POS_VERSION', str_val=版本号            │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 6.3 版本号机制

| 版本来源 | 说明 |
|---------|------|
| `verInfo.ini` | 部署时复制到运行目录，含编译时间戳（`POS_VERSION`），每次打包自动更新 |
| `sys_config_data` | POS 本地数据库表，存当前数据库版本号（`company_id=-1, name='POS_VERSION'`） |

**升级判断逻辑**：

```java
private boolean needNotUpgrade(boolean force) {
    if (force) {
        return false;  // 强制升级：直接执行
    }
    String versionInFile = getCompileTime();    // verInfo.ini 中的版本号
    String versionInDb = getDBVersion();          // sys_config_data 中的版本号
    if (versionInDb.equals(versionInFile)) {
        return true;   // 版本一致，无需升级
    }
    log.error("版本号不一致,需要升级,当前版本号:{},新版本号:{}", versionInDb, versionInFile);
    return false;      // 版本不一致，执行升级
}
```

**升级时机**：
- 应用启动时，由 Spring Bean 初始化自动触发
- 或运维人员手动调用 `VerMgrServer.upgrade(true)` 强制升级

### 6.4 列的升级逻辑

`upgradeColumn()` 方法遍历每个实体类的所有字段，对每张表进行差异对比：

#### 6.4.1 表不存在——CREATE TABLE

```java
private void createTable(String tableName, Class<? extends BaseEntity> clazz) {
    StringBuilder content = new StringBuilder();
    for (Field field : clazz.getDeclaredFields()) {
        Column column = field.getAnnotation(Column.class);
        if (column == null) continue;
        if (field.getName().equals("lid")) {
            lidColumnName = column.value();  // 找到 lid 字段名
        }
        var columnPlus = field.getAnnotation(ColumnPlus.class);
        content.append(getColumnSql(field, column, columnPlus)).append(",\n");
    }
    String sql = String.format(
        "CREATE TABLE %s("
            + "pid BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号',"
            + "%s"
            + "PRIMARY KEY (pid)"
            + ") COMMENT = ''", tableName, content);
    Db.updateBySql(sql);

    // 自动为 lid 字段创建索引 idx_{table}_lid
    if (StringUtils.isNotBlank(lidColumnName)) {
        Db.updateBySql(String.format(
            "CREATE INDEX idx_%s_lid ON %s(%s);", tableName, tableName, lidColumnName));
    }
}
```

生成类似以下 SQL：

```sql
CREATE TABLE crm_points_rule(
    pid BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号',
    mid BIGINT COMMENT '商户ID',
    sid BIGINT COMMENT '门店ID',
    lid BIGINT COMMENT '逻辑ID',
    name VARCHAR(128) COMMENT '规则名称',
    plan_lid BIGINT COMMENT '方案ID',
    -- ... 其他字段
    PRIMARY KEY (pid)
);
CREATE INDEX idx_crm_points_rule_lid ON crm_points_rule(lid);
```

#### 6.4.2 表已存在——ALTER TABLE

`updateColumn()` 对比实体类字段与数据库现有列，收集变更：

```java
private void updateColumn(String tableName, Class<? extends BaseEntity> clazz, ...) {
    for (Field field : clazz.getDeclaredFields()) {
        Column column = field.getAnnotation(Column.class);
        if (column == null || column.ignore()) continue;

        if (columns.containsKey(column.value())) {
            // 列已存在，检查类型是否需要变更
            checkAndUpdateColumnType(tableName, field, column, columns, pendingAlters);
        } else {
            // 列不存在，新增
            String clause = "ADD COLUMN " + getColumnSql(field, column, columnPlus);
            pendingAlters.computeIfAbsent(tableName, k -> new ArrayList<>()).add(clause);
        }
    }
}
```

**新增列示例**：实体类新增了 `member_day_days_of_week` 字段，数据库中没有该列，执行：

```sql
ALTER TABLE crm_points_rule
  ADD COLUMN member_day_days_of_week longtext COMMENT '会员日适用星期';
```

### 6.5 列类型变更逻辑

`checkAndUpdateColumnType()` 方法对比数据库当前列类型与实体类期望类型，只允许**从小范围向大范围**的转换：

```java
// 类型优先级（数值越小范围越小，不允许从大范围转小范围）
tinyint(1)  < smallint  < int  < bigint  < varchar/text
```

**允许的变更**：
- `varchar(64)` → `varchar(128)`（长度增加）
- `int` → `bigint`（范围扩大）
- `numeric(10,2)` → `numeric(19,10)`（精度提高）

**不允许的变更**：
- `bigint` → `int`（范围缩小，直接拒绝）
- `varchar(128)` → `varchar(64)`（长度缩小，直接拒绝）
- `decimal(19,10)` → `decimal(10,2)`（精度降低，直接拒绝）

**decimal 精度变更判断**：

```java
int[] expectedPrecision = extractDecimalPrecision(expectedType);  // [精度, 小数位数]
int[] currentPrecision = extractDecimalPrecision(currentType);
// 精度或小数位数只能扩大，不能缩小
if (expectedPrecision[0] < currentPrecision[0]
    || expectedPrecision[1] < currentPrecision[1]) {
    return;  // 拒绝降级
}
```

### 6.6 索引的升级逻辑

#### 6.6.1 @ColumnPlus 注解

MyBatisFlex 本身不支持在字段上声明索引，通过自定义注解 `@ColumnPlus` 扩展：

```java
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ColumnPlus {
    /** 是否需要创建索引 */
    boolean needToCreateIndex() default false;
    /** 索引名称，默认 idx_{表名}_{列名} */
    String indexName() default "";
    /** 配置的 jdbcType，覆盖 @Column.jdbcType */
    JdbcType jdbcType() default JdbcType.UNDEFINED;
}
```

使用示例（`CrmPointsRule.java` 第 48-50 行）：

```java
@Column("plan_lid")
@ColumnPlus(needToCreateIndex = true)
private Long planLid;
```

#### 6.6.2 索引创建流程

`createIndex()` 扫描所有带 `@ColumnPlus(needToCreateIndex=true)` 的字段：

```java
private void createIndex(String tableName, Class<? extends BaseEntity> clazz, ...) {
    for (Field field : clazz.getDeclaredFields()) {
        Column column = field.getAnnotation(Column.class);
        var columnPlus = field.getAnnotation(ColumnPlus.class);
        if (columnPlus == null || !columnPlus.needToCreateIndex()) {
            continue;
        }
        String indexName = Optional.ofNullable(columnPlus.indexName())
            .filter(StrUtil::isNotBlank)
            .orElse(String.format("idx_%s_%s", tableName, column.value()));

        if (indexes.contains(indexName)) {
            continue;  // 索引已存在，跳过
        }
        String clause = String.format("ADD INDEX %s (%s)", indexName, column.value());
        pendingAlters.computeIfAbsent(tableName, k -> new ArrayList<>()).add(clause);
    }
}
```

#### 6.6.3 静态索引映射（indexUpgMap）

`VerMgrServer` 中维护了一个静态 Map，专门用于为历史表追加特殊索引：

```java
public static Map<String, Pair<String, String>> indexUpgMap = new HashMap<>(16);

static {
    indexUpgMap.put("dwd_food",
        Pair.of("idx_dwd_bill_lid",
            "create index idx_dwd_bill_lid on dwd_food(saas_order_no)"));
    indexUpgMap.put("dwd_pay",
        Pair.of("idx_dwd_bill_lid",
            "create index idx_dwd_bill_lid on dwd_pay(saas_order_no)"));
    indexUpgMap.put("pos_dev",
        Pair.of("idx_pos_dev_id", "create index idx_pos_dev_id on pos_dev(id)"));
    // ...
}
```

这些索引不是通过 `@ColumnPlus` 声明的，而是通过 Map 硬编码，用于为已存在的老表追加特殊索引。

### 6.7 Java 类型到数据库类型的映射

`VerMgrServer` 维护了 Java 类型到 MySQL 类型的映射表：

| Java 类型 | MySQL 类型 |
|---------|-----------|
| `String` | `varchar(128)` |
| `Integer` | `int` |
| `Long` | `bigint` |
| `Boolean` | `tinyint(1)` |
| `Short` | `tinyint` |
| `BigDecimal` | `numeric(19,10)` |
| `LocalDateTime` / `LocalDate` / `Date` | `datetime` |
| 枚举类 | `int` |
| `@ColumnPlus(jdbcType=CLOB)` | `longtext` |
| `@ColumnPlus(jdbcType=BLOB)` | `TEXT` |
| `@ColumnPlus(jdbcType=LONGVARCHAR)` | `varchar(256)` |

### 6.8 合并 ALTER 的去重策略

为了减少数据库操作次数，同一张表的多个变更合并为一条 ALTER TABLE 语句：

```java
// 执行前：pendingAlters["crm_points_rule"] = [
//   "ADD COLUMN member_day_days_of_week longtext COMMENT '...'",
//   "ADD COLUMN member_day_days_of_month longtext COMMENT '...'",
//   "ADD INDEX idx_crm_points_rule_plan_lid (plan_lid)"
// ]

String sql = "ALTER TABLE crm_points_rule "
    + "ADD COLUMN member_day_days_of_week longtext COMMENT '...', "
    + "ADD COLUMN member_day_days_of_month longtext COMMENT '...', "
    + "ADD INDEX idx_crm_points_rule_plan_lid (plan_lid)";
Db.updateBySql(sql);
```

**去重规则**：
- 同一列的多条 `MODIFY COLUMN` 或 `ADD COLUMN`：保留最后一条（后者覆盖前者）
- `ADD INDEX`：不去重（不同索引名不会冲突）
- 合并失败时自动降级为逐条执行

### 6.9 升级失败排查

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `Table 'nms.crm_points_rule' doesn't exist` | 表从未创建，VerMgrServer 未执行或执行失败 | 检查 `log.error()` 输出，重启应用触发 VerMgrServer |
| `Unknown column 'xxx' in 'field list'` | 新代码引用了旧数据库不存在的列 | 重启 POS 应用，VerMgrServer 自动补列 |
| `Duplicate column name 'xxx'` | 上次 ALTER 执行不完整 | 手动检查数据库表结构，或强制升级 `upgrade(true)` |
| `Duplicate key name 'idx_xxx'` | 索引已存在 | 正常，日志中有 `continue` 跳过信息，不影响 |

**排查步骤**：

1. 查看应用启动日志，搜索 `VerMgrServer` 相关输出：
   ```
   升级完成，版本号为2026-04-30 12:01:00
   合并执行: ALTER TABLE crm_points_rule ADD COLUMN ...
   ```
2. 如果没有升级日志，检查 `sys_config_data` 表中版本号是否与 `verInfo.ini` 一致
3. 如果版本号一致但列仍缺失，可能是 `@Column.ignore()=true` 导致字段被忽略（该字段不参与建表）

---

## 七、数据同步安全机制

### 7.1 签名校验

增量同步接口 `POST /sync/list` 需要商户签名校验：

```java
public class RequireSignatureCheckRequest<T> {
    private String sid;
    private String sign;      // MD5(商户号 + 终端ID + 时间戳 + 密钥)
    private String timestamp;
    private T body;
}
```

签名校验在 `SyncDataController` 层统一处理，由 `Nms4cloudInterceptor`（POS 侧）生成，`SyncDataController` 校验。

### 7.2 Same-Token（pos4cloud 内部微服务调用）

pos4cloud 调用 CRM 时使用 same-token 模式：

```
Redis key: nms4token:var:same-token
         ↓
读取 token 值
         ↓
放入 HTTP Header: satoken=xxx
         ↓
CRM @Inner 注解拦截器校验
```

与 pos3boot 的商户签名机制不同，pos4cloud 内部微服务间通过 Sa-Token 的 same-token 机制互相认证。

### 7.3 Forest 拦截器（pos3boot）

pos3boot 的 Forest HTTP 客户端通过拦截器统一添加认证信息：

```java
Nms4cloudInterceptor.intercept(ForestRequest request) {
    // 1. 添加商户/终端签名
    forestRequest.add mottlsHeaders(request);

    // 2. 添加时间戳
    forestRequest.setDate(new Date());

    // 3. 添加 MD5 签名
    String sign = md5(merchantNo + terminalId + timestamp + secret);
    forestRequest.set("sign", sign);
}
```

此拦截器仅存在于 pos3boot，pos4cloud 不需要（使用 Nacos + same-token）。

---

## 八、同步相关的重要类清单

| 类 | 模块 | 职责 |
|---|------|------|
| `SyncBaseDataService` | pos2plugin-biz | 增量同步核心逻辑，classMapper 管理，VO→Entity 映射 |
| `FullSyncDataService` | pos3boot-biz | 全量同步两阶段逻辑（下载→提交），Redis 进度管理 |
| `CrmPointsRuleSyncRemoteService` | pos2plugin-api | 积分权益同步接口定义 |
| `CrmPointsRuleForestServiceImpl` | pos2plugin-biz | pos3boot Forest 实现，调用 Nms4CloudCrmService |
| `CrmPointsRuleSyncRemoteServiceImpl` | pos4cloud-feign | pos4cloud ReactiveFeign 实现（@Primary） |
| `Nms4CloudCrmService` | pos2plugin-biz | Forest 接口，含 40+ 个 CRM API 方法 |
| `CrmPointsRuleMapper` | pos2plugin-dal | MyBatisFlex Mapper，操作本地 crm_points_rule 表 |
| `VerMgrServer` | pos3boot-biz | 启动时自动创建/升级数据库表结构 |
| `ColumnPlus` | pos2plugin-api | 自定义注解，扩展字段索引声明和 jdbcType 覆盖 |
| `Nms4cloudInterceptor` | pos2plugin-biz | Forest 拦截器，pos3boot 添加签名，pos4cloud 中 required=false |

---

## 九、调试与排查

### 9.1 常见错误对照表

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `[Forest] Cannot resolve variable 'baseUrl'` | pos4cloud 启动了 Forest 但无 baseUrl 配置 | 接口抽象 + ReactiveFeign 替换（已完成） |
| `Table 'xxx' doesn't exist` | VerMgrServer 未创建该表 | 重启 POS 或手动执行建表 SQL |
| `积分权益规则同步失败` | CRM 服务不可达或返回错误 | 检查 Nacos 服务注册、网络连通性 |
| `Assert.isTrue result.isSuccess()` | CRM 接口返回业务错误 | 查看 CRM 日志，检查请求参数 |
| `Unknown column 'xxx'` | 数据库列缺失 | 重启应用，VerMgrServer 自动补列 |

### 9.2 关键日志位置

- 增量同步：`SyncBaseDataService.list()` → `log.info("同步 {}", tableName)`
- 全量同步：`FullSyncDataService.handleAllTable()` → 阶段 1 下载/阶段 2 提交
- 数据库升级：`VerMgrServer.upgrade()` → `log.error()` 输出版本号和 ALTER 语句
- Forest 请求：`Nms4CloudCrmService` → Forest 框架日志
- ReactiveFeign 请求：`CrmPointsRuleSyncRemoteServiceImpl` → `reactor.netty` 日志

### 9.3 验证同步接口是否正常

**pos4cloud**（增量同步）：

```bash
POST /api/pos4cloud/sync/list
Content-Type: application/json
Authorization: Bearer {token}

{
  "body": {
    "current": 1,
    "pageSize": 100,
    "tableName": "CrmPointsRule",
    "isPlatform": false
  }
}
```

预期：返回分页数据，不报 `[Forest] Cannot resolve variable 'baseUrl'`

**pos3boot**（全量同步）：

```bash
POST /sync/all
```

预期：进度轮询（`GET /sync/progress?key=xxx`）返回 100% 且 success=true，所有表同步完成。