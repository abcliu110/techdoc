# POS 本地数据库表自动创建原理

## 一、概述

POS 系统采用 **本地优先** 的架构设计，核心业务表（如订单、菜品、支付等）均存储在本地 MySQL 数据库中，**不依赖云端同步**。系统通过 `VerMgrServer` 组件实现数据库表结构的**自动创建与升级**，确保每次部署新版本时表结构保持一致。

> **dwd_bill_error 表** 是本地 POS 表，**不是云端同步表**，由 VerMgrServer 自动创建。

---

## 二、架构设计

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        POS 本地数据库自动升级架构                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────┐      ┌───────────────────────────────┐
│          verInfo.ini                 │      │      MySQL 数据库             │
│  (手工维护，部署时复制到运行目录) │      │   (127.0.0.1:8066/nms)       │
│                                      │      │                               │
│  {"POS_VERSION":"2026-04-27 18:34:47"}│      │  ┌───────────────────────┐  │
└──────────────┬───────────────────────┘      │  │  sys_config_data      │  │
               │                              │  │  (存储数据库版本号)    │  │
               │ getCompileTime()             │  └───────────────────────┘  │
               ▼                              │  ┌───────────────────────┐  │
┌──────────────────────────────────────────┐  │  │  dwd_bill_error       │  │
│            VerMgrServer                  │  │  │  (由VerMgrServer创建)  │  │
│                                          │  │  └───────────────────────┘  │
│  ┌────────────────────────────────────┐  │  │  ┌───────────────────────┐  │
│  │  upgrade(boolean force)           │  │  │  │  dwd_bood            │  │
│  │  ┌────────────────────────────────┐ │  │  │  │  dwd_pay             │  │
│  │  │ needNotUpgrade()              │ │  │  │  │  ...                 │  │
│  │  │  ↓                            │ │  │  │  └───────────────────────┘  │
│  │  │ versionInFile vs versionInDb  │ │  │  └───────────────────────────┘  │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 1. getColumns()                │ │  │                               │
│  │  │    → information_schema.columns│ │  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 2. getIndexes()                │ │  │                               │
│  │  │    → information_schema.statistics││  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 3. getEntities()               │ │  │                               │
│  │  │    → Reflections扫描实体类      │ │  │                               │
│  │  │    包: com.nms4cloud.pos2plugin │ │  │                               │
│  │  │    .dal.entity                 │ │  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 4. upgradeColumn()             │ │  │                               │
│  │  │    对比实体类 vs 数据库表结构  │ │  │                               │
│  │  │    收集 ALTER 语句            │ │  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 5. executePendingAlters()     │ │  │                               │
│  │  │    合并执行 ALTER TABLE        │ │  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  │           │                         │  │                               │
│  │           ▼                         │  │                               │
│  │  ┌────────────────────────────────┐ │  │                               │
│  │  │ 6. setDBVersion()              │ │  │                               │
│  │  │    更新 sys_config_data        │ │  │                               │
│  │  └────────────────────────────────┘ │  │                               │
│  └──────────────────────────────────────┘  │                               │
└───────────────────────────────────────────┼───────────────────────────────┘
                                            │
                                            ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           触发时机                                          │
│                                                                             │
│   触发方式              调用位置                        参数                  │
│  ─────────           ──────────────────────────────  ───────────────       │
│   应用启动      Pos3BootApplication.java:283    upgrade(false)             │
│   HTTP请求      SystemSettingController.java:93 upgrade(true)             │
│   定时任务      Nms4PosPosHandlerProvider.java    loadPayNotify()           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 核心组件关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         实体类 (Entity Layer)                              │
│                                                                             │
│  com.nms4cloud.pos2plugin.dal.entity                                       │
│  ├── DwdBill.java         (订单表)                                        │
│  ├── DwdApplyPay.java     (支付申请表)                                     │
│  ├── DwdBillError.java    (账单错误记录) ← 本文档主角                       │
│  ├── DwdFood.java         (菜品明细)                                       │
│  └── ...                                                             ...   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ @Table("dwd_bill_error")                                            │  │
│  │ public class DwdBillError extends BaseEntity {                      │  │
│  │     @Column("pid") private Long pid;                               │  │
│  │     @Column("mid") private Long mid;                               │  │
│  │     @Column("lid") private Long lid;                               │  │
│  │     // ... 更多字段                                                │  │
│  │ }                                                                  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Reflections 扫描
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                       VerMgrServer (升级引擎)                               │
│                                                                             │
│  upgrade(false) ← 普通升级（启动时）                                        │
│  upgrade(true)  ← 强制升级（HTTP触发）                                       │
│                                                                             │
│  对比: 实体类字段  ↔  MySQL information_schema                               │
│  操作: CREATE TABLE / ALTER TABLE / CREATE INDEX                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ 写入/修改
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MySQL (本地数据库 127.0.0.1:8066)                        │
│                                                                             │
│  ┌─────────────────────┐  ┌─────────────────────────────────────────────┐ │
│  │  sys_config_data    │  │                   业务表                      │ │
│  │  ─────────────────  │  │  ┌─────────────────────────────────────┐   │ │
│  │  company_id = -1    │  │  │  dwd_bill_error                     │   │ │
│  │  name = 'POS_VERSION│  │  │  ─────────────────────────────────   │   │ │
│  │  str_val = '2026... │  │  │  pid BIGINT AUTO_INCREMENT PK       │   │ │
│  └─────────────────────┘  │  │  mid BIGINT                         │   │ │
│                           │  │  sid BIGINT                         │   │ │
│                           │  │  lid BIGINT                         │   │ │
│                           │  │  report_date DATETIME               │   │ │
│                           │  │  dwd_bill_lid BIGINT                │   │ │
│                           │  │  ...                                │   │ │
│                           │  │  deleted TINYINT (逻辑删除)          │   │ │
│                           │  └─────────────────────────────────────┘   │ │
│                           └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 三、升级流程详解

### 3.1 升级流程图

```
                          ┌─────────────────────┐
                          │    应用启动          │
                          │ Pos3BootApplication  │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  测试数据库连接      │
                          │ (DataSource 测试)   │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │ new VerMgrServer()  │
                          │ .upgrade(false)      │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │ needNotUpgrade()?   │◄── force = false
                          └──────────┬──────────┘
                                     │
                    ┌────────────────┴────────────────┐
                    │                                  │
               [版本相同]                         [版本不同]
                    │                                  │
                    ▼                                  ▼
          ┌─────────────────┐               ┌─────────────────────┐
          │ 不升级，直接启动  │               │ 进入升级流程          │
          │ return          │               └──────────┬──────────┘
          └─────────────────┘                          │
                                                          ▼
                                              ┌─────────────────────┐
                                              │ 1. getColumns()     │
                                              │ 查询数据库已有列信息  │
                                              │ information_schema  │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │ 2. getIndexes()     │
                                              │ 查询数据库已有索引    │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │ 3. getEntities()    │
                                              │ Reflections扫描实体类│
                                              │ 包: com.nms4cloud   │
                                              │ .pos2plugin.dal     │
                                              │ .entity             │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │ 4. upgradeColumn()  │
                                              │ 对比每个实体类        │
                                              │ ┌─────────────────┐ │
                                              │ │ 表存在?          │ │
                                              │ │  ├─ YES: 对比列  │ │
                                              │ │  └─ NO: 创建表   │ │
                                              │ └─────────────────┘ │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │ 5. executeAlters()  │
                                              │ 合并执行 ALTER TABLE│
                                              │ 每张表只执行一条    │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │ 6. setDBVersion()  │
                                              │ 更新版本号到         │
                                              │ sys_config_data    │
                                              └──────────┬──────────┘
                                                         │
                                                         ▼
                                              ┌─────────────────────┐
                                              │     升级完成         │
                                              │ 启动 POS 应用       │
                                              └─────────────────────┘
```

### 3.2 强制升级流程（HTTP 触发）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        强制升级触发流程                                       │
└─────────────────────────────────────────────────────────────────────────────┘

  POS管理员                      HTTP请求                        VerMgrServer
     │                              │                                  │
     │  POST /systemSetting/upgrade │                                  │
     │  (Content-Type: application/json)                             │
     │──────────────────────────────►                                  │
     │                              │                                  │
     │                              │ upgrade(true)                    │
     │                              │ (force = true)                   │
     │                              │─────────────────────────────────►
     │                              │                                  │
     │                              │  ┌────────────────────────────┐  │
     │                              │  │ needNotUpgrade(true)       │  │
     │                              │  │   ↓                       │  │
     │                              │  │ return false (跳过版本检查) │  │
     │                              │  │   ↓                       │  │
     │                              │  │ 执行完整升级流程            │  │
     │                              │  │   • 创建缺失的表           │  │
     │                              │  │   • 添加缺失的列           │  │
     │                              │  │   • 创建索引               │  │
     │                              │  │   • 更新版本号             │  │
     │                              │  └────────────────────────────┘  │
     │                              │                                  │
     │      HTTP 200 OK             │                                  │
     │  {"code": 0, "msg": "升级完成"}◄─────────────────────────────────│
     │◄──────────────────────────────│                                  │
```

---

## 四、核心代码分析

### 4.1 版本对比逻辑

```java
// VerMgrServer.java - needNotUpgrade() 方法
private boolean needNotUpgrade(boolean force) {
    if (force) {
        // force = true: 强制升级，跳过版本检查
        return false;
    }

    // 读取编译时版本（来自 verInfo.ini）
    String versionInFile = getCompileTime();  // 如: "2026-04-27 18:34:47"
    nextVersion = versionInFile;

    // 读取数据库版本（来自 sys_config_data）
    String versionInDb = getDBVersion();

    // 对比：相同则不升级，不同则升级
    if (versionInDb.equals(versionInFile)) {
        return true;  // 版本相同，不升级
    }

    log.error("版本号不一致,需要升级,当前版本号:{},新版本号:{}", versionInDb, versionInFile);
    return false;  // 版本不同，需要升级
}
```

### 4.2 实体类扫描

```java
// VerMgrServer.java - getEntities() 方法
private Set<Class<? extends BaseEntity>> getEntities() {
    // 使用 Reflections 库扫描指定包下的所有实体类
    Reflections reflections = new Reflections("com.nms4cloud.pos2plugin.dal.entity");

    // 返回所有继承自 BaseEntity 的类
    return reflections.getSubTypesOf(BaseEntity.class);
}
```

**扫描结果示例：**
```
com.nms4cloud.pos2plugin.dal.entity.DwdBill
com.nms4cloud.pos2plugin.dal.entity.DwdApplyPay
com.nms4cloud.pos2plugin.dal.entity.DwdBillError    ← 本文档主角
com.nms4cloud.pos2plugin.dal.entity.DwdFood
... (共约 50+ 个实体类)
```

### 4.3 表创建逻辑

```java
// VerMgrServer.java - createTable() 方法
private void createTable(String tableName, Class<? extends BaseEntity> clazz) {
    StringBuilder content = new StringBuilder();

    // 遍历实体类的所有字段
    for (Field field : clazz.getDeclaredFields()) {
        Column column = field.getAnnotation(Column.class);
        if (column == null) continue;

        // 处理 lid 字段（用于创建索引）
        if (field.getName().equals("lid")) {
            lidColumnName = column.value();
        }

        // 生成列定义
        ColumnPlus columnPlus = field.getAnnotation(ColumnPlus.class);
        content.append(getColumnSql(field, column, columnPlus)).append(",\n");
    }

    // 生成 CREATE TABLE SQL
    String sql = String.format("""
        CREATE TABLE %s(
            pid BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号',
            %s
            PRIMARY KEY (pid)
        ) COMMENT = '';
        """, tableName, content);

    Db.updateBySql(sql);

    // 如果有 lid 字段，创建索引
    if (StringUtils.isNotBlank(lidColumnName)) {
        String idxSql = String.format(
            "CREATE INDEX idx_%s_lid ON %s(%s);",
            tableName, tableName, lidColumnName
        );
        Db.updateBySql(idxSql);
    }
}
```

### 4.4 DwdBillError 实体类

```java
// DwdBillError.java - 账单错误记录表
@Table(value = "dwd_bill_error", onInsert = YdInsertListener.class)
public class DwdBillError extends BaseEntity {

    @Id(value = "pid", keyType = KeyType.Auto)
    private Long pid;

    @Column("mid") private Long mid;           // 商户编号
    @Column("sid") private Long sid;             // 门店编号
    @Column("lid") private Long lid;             // 账单本地编号
    @Column("report_date") private LocalDateTime reportDate;  // 营业日期
    @Column("dwd_bill_lid") private Long dwdBillLid;  // 账单关联编号

    @ColumnPlus(jdbcType = JdbcType.BLOB)
    @Column("remark") private String remark;     // 错误信息备注

    @Column("error_type") private ErrorTypeEnum errorType;  // 错误类型

    @Column(value = "deleted", isLogicDelete = true)
    private Integer deleted;                      // 逻辑删除标记
}
```

---

## 五、触发方式详解

### 5.1 应用启动时触发（普通升级）

**触发位置：** `Pos3BootApplication.java:283`

```java
@PostConstruct
public void init() {
    // ...
    // 在数据库连接测试后执行
    new VerMgrServer().upgrade(false);
}
```

**特点：**
- 参数 `force = false`
- 检查版本号，版本相同时跳过
- 新部署时版本不同，会自动升级

### 5.2 HTTP 接口触发（强制升级）

**触发位置：** `SystemSettingController.java:93`

```java
@PostMapping("/upgrade")
public Result<?> upgrade() {
    verMgrServer.upgrade(true);  // 强制升级
    return Result.ok();
}
```

**调用方式：**
```bash
curl -X POST http://localhost:9180/systemSetting/upgrade
```

**特点：**
- 参数 `force = true`
- **跳过版本检查**，无论版本是否一致都执行升级
- 用于修复表结构问题

### 5.3 定时任务触发

**触发位置：** `Nms4PosPosHandlerProvider.java:71`

```java
public void init() {
    // 先同步营业日期
    reportDateServicePlus.syncReportDate();
    // 加载未支付完成的订单
    OrderServiceUtil.schedule(this::loadPayNotify, 5, TimeUnit.SECONDS);
}
```

---

## 六、问题排查

### 6.1 dwd_bill_error 表缺失问题

**问题描述：**
```
ERROR [loadPayNotify] - 加载未支付订单上传失败:
org.springframework.jdbc.BadSqlGrammarException:
Table 'nms.dwd_bill_error' doesn't exist
```

**根本原因分析：**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         版本一致导致跳过升级                                  │
└─────────────────────────────────────────────────────────────────────────────┘

  场景：之前部署的版本与当前版本相同
        verInfo.ini: 2026-04-27 18:34:47
        sys_config_data: 2026-04-27 18:34:47

  触发 upgrade(false) 时：
    1. needNotUpgrade(false) 被调用
    2. 读取版本：versionInFile = "2026-04-27 18:34:47"
    3. 读取版本：versionInDb = "2026-04-27 18:34:47"
    4. 判断：versionInDb == versionInFile → true
    5. return true → 不执行升级！

  结果：dwd_bill_error 表未被创建
```

### 6.2 排查步骤

**Step 1: 检查数据库版本**

```sql
-- 查询当前数据库版本
SELECT company_id, name, str_val
FROM sys_config_data
WHERE company_id = -1 AND name = 'POS_VERSION';

-- 结果示例：
-- +------------+------+---------------------+
-- | company_id | name | str_val             |
-- +------------+------+---------------------+
-- |         -1 | POS_VERSION | 2026-04-27 18:34:47 |
-- +------------+------+---------------------+
```

**Step 2: 检查 verInfo.ini 版本**

```bash
# 查看 verInfo.ini 内容
cat /path/to/verInfo.ini

# 或在代码中
# VerMgrServer.getCompileTime() 返回的值
```

**Step 3: 检查表是否存在**

```sql
-- 方法1: 直接查询
SELECT COUNT(*) FROM dwd_bill_error;

-- 方法2: 查询元数据
SELECT TABLE_NAME
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'nms'
  AND TABLE_NAME = 'dwd_bill_error';
```

**Step 4: 检查所有业务表**

```sql
-- 查看所有应该存在的表
SELECT TABLE_NAME
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'nms'
  AND TABLE_NAME LIKE 'dwd_%'
ORDER BY TABLE_NAME;
```

---

## 七、解决方案

### 7.1 方案一：HTTP 强制升级（推荐）

**优点：** 简单快捷，无需重启服务

```bash
# 执行强制升级
curl -X POST http://localhost:9180/systemSetting/upgrade

# 验证结果
curl http://localhost:9180/systemSetting/upgrade
```

**效果：**
- 创建所有缺失的表
- 添加所有缺失的列
- 创建所有缺失的索引
- 更新 sys_config_data 版本号

### 7.2 方案二：手动执行 SQL

**优点：** 精确控制，不影响其他表

```sql
-- 创建 dwd_bill_error 表
CREATE TABLE IF NOT EXISTS `dwd_bill_error` (
    `pid` BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理编号',
    `mid` BIGINT COMMENT '商户编号',
    `sid` BIGINT COMMENT '门店编号',
    `lid` BIGINT COMMENT '账单本地编号',
    `report_date` DATETIME COMMENT '营业日期',
    `dwd_bill_lid` BIGINT COMMENT '账单关联编号',
    `dwd_bill_id` VARCHAR(128) COMMENT '账单编号',
    `dwd_bill_name` VARCHAR(128) COMMENT '账单名称',
    `remark` TEXT COMMENT '错误信息备注',
    `error_type` INT COMMENT '错误类型',
    `created_by` VARCHAR(128) COMMENT '创建人',
    `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`pid`),
    INDEX `idx_dwd_bill_error_dwd_bill_lid` (`dwd_bill_lid`),
    INDEX `idx_dwd_bill_error_lid` (`lid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账单错误记录';

-- 更新版本号（可选）
UPDATE sys_config_data
SET str_val = '2026-04-28 00:00:00'
WHERE company_id = -1 AND name = 'POS_VERSION';
```

### 7.3 方案三：修改数据库版本号

**注意：** 此方案需要谨慎使用，可能导致版本不一致

```sql
-- 将数据库版本设置为旧版本，强制触发升级
UPDATE sys_config_data
SET str_val = '2023-01-01 00:00:00'
WHERE company_id = -1 AND name = 'POS_VERSION';

-- 然后重启应用，会自动执行 upgrade(false)
```

---

## 八、最佳实践

### 8.1 部署前检查清单

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         部署前检查清单                                       │
└─────────────────────────────────────────────────────────────────────────────┘

 □ 1. 确认 verInfo.ini 版本已更新
 □ 2. 确认 sys_config_data 版本与 verInfo.ini 不同（首次部署）
 □ 3. 备份数据库
 □ 4. 准备回滚方案

 部署后验证：
 □ 5. 检查应用日志是否显示 "升级完成"
 □ 6. 验证关键表是否存在（dwd_bill_error 等）
 □ 7. 执行冒烟测试
```

### 8.2 常见错误处理

**错误 1: 表已存在但列缺失**
```
现象：应用启动正常，但特定功能报错 "Column 'xxx' doesn't exist"
原因：表已创建，但后续版本增加了新列
解决：调用 HTTP 强制升级接口
```

**错误 2: 索引缺失**
```
现象：查询慢，但表结构正确
原因：索引未创建
解决：
  1. 检查实体类 @ColumnPlus 注解的 indexName 属性
  2. 调用 HTTP 强制升级接口重建索引
```

**错误 3: 版本号不匹配**
```
现象：频繁触发升级，每次启动都执行 ALTER TABLE
原因：verInfo.ini 每次构建都不同，但实际表结构未变
解决：确保构建系统只在真正需要升级时才更新 verInfo.ini
```

### 8.3 监控建议

```sql
-- 监控表结构变更
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_TYPE,
    COLUMN_COMMENT
FROM information_schema.columns
WHERE TABLE_SCHEMA = 'nms'
  AND TABLE_NAME = 'dwd_bill_error'
ORDER BY ORDINAL_POSITION;
```

---

## 九、技术总结

### 9.1 核心设计思想

| 特性 | 实现方式 | 优点 |
|------|---------|------|
| 版本管理 | verInfo.ini + sys_config_data | 精确控制升级时机 |
| 表结构同步 | 实体类注解 + 运行时扫描 | 代码即表结构，无需维护 SQL |
| 增量升级 | 对比实体类 vs 数据库 | 只执行必要的 ALTER |
| 索引管理 | @ColumnPlus + indexUpgMap | 集中管理索引变更 |
| 逻辑删除 | MyBatis-Flex 拦截器 | 自动处理 deleted 字段 |

### 9.2 关键文件位置

```
项目根目录/
├── verInfo.ini                          # 版本信息文件
│
├── nms4cloud-pos3boot/
│   └── src/main/java/
│       └── com/nms4cloud/pos3boot/
│           ├── Pos3BootApplication.java  # 启动时触发
│           └── service/local/
│               └── VerMgrServer.java     # 升级引擎
│
└── nms4cloud-pos2plugin-dal/
    └── src/main/java/
        └── com/nms4cloud/pos2plugin/
            └── dal/entity/
                ├── DwdBill.java
                ├── DwdApplyPay.java
                ├── DwdBillError.java      # 本文档主角
                └── ...                    # 所有业务实体类
```

---

*文档生成时间: 2026-04-28*
*最后更新时间: 2026-04-28 (首次编写)*
