# 打印功能 DA5：数据模型分析

> **分析范围**：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui
> **分析时间**：2026-08-03
> **SOP 依据**：SOP-00 业务系统分析 v2.9
> **前置文档**：DA0-DA1-全景扫描与概念建模.md

---

## 1. 概述

本文档详细分析打印系统涉及的所有数据库表，包括字段定义、索引设计、外键关系和表间关联。

### 1.1 表清单总览

| 表名 | 中文名 | 实体类 | 核心功能 |
|------|--------|--------|----------|
| `pos_prn_printer` | 打印机表 | `PosPrnPrinter` | 存储打印机设备信息 |
| `pos_prn_queue` | 打印队列表 | `PosPrnQueue` | 配置打印队列与打印机映射 |
| `pos_prn_job` | 打印任务表 | `PosPrnJob` | 记录打印任务生命周期 |
| `pos_prn_style_row` | 打印样式行表 | `PosPrnStyleRow` | 定义打印模板行样式 |
| `pos_prn_style_col` | 打印样式列表 | `PosPrnStyleCol` | 定义打印模板列样式 |
| `print_job_type_switch` | 打印开关配置表 | `PrintJobTypeSwitch` | 控制各单据类型的打印开关 |
| `pos_customer_bill_setting` | 顾客联配置表 | `PosCustomerBillSetting` | 配置顾客联打印队列 |
| `pos_waiter_bill_setting` | 传菜联配置表 | `PosWaiterBillSetting` | 配置传菜联打印队列 |
| `pos_prn_printer_transfer` | 打印机转移规则表 | `PosPrnPrinterTransfer` | 定义打印机转移规则 |
| `pos_dish_to_prn_dept` | 菜品出品部门关联表 | `PosDishToPrnDept` | 菜品与出品部门多对多映射 |

---

## 2. 核心表详细设计

### 2.1 pos_prn_printer（打印机表）

**用途**：存储打印机设备的基本信息和连接配置。

```sql
CREATE TABLE pos_prn_printer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) NOT NULL COMMENT '打印机名称',
  pc_lid BIGINT COMMENT 'PC终端lid（关联sys_pc.lid）',

  -- 打印机类型与型号
  type_ TINYINT NOT NULL COMMENT '打印机类型：1-驱动打印机 2-网口打印机 3-串口打印机 4-USB打印机 5-并口打印机 6-芯烨云打印机 7-佳博云打印机 8-驱动指令打印机',
  model_ TINYINT COMMENT '打印机型号',
  extra_info TEXT COMMENT '扩展配置(JSON格式，存储连接参数如IP、端口、驱动路径等)',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印机表';
```

**实体字段映射**：

```java
@Table(value = "pos_prn_printer", onInsert = YdInsertListener.class)
public class PosPrnPrinter extends BaseEntity {
    private Long pid;                    // 物理编号
    private Long mid;                    // 商户ID
    private Long sid;                    // 门店ID
    private Long lid;                    // 逻辑编号
    private String name;                 // 打印机名称
    private Long pcLid;                  // PC终端lid

    private PrinterTypeEnum type;        // 打印机类型（枚举）
    private PrinterModelEnum model;       // 打印机型号（枚举）
    private String extraInfo;            // 扩展配置(JSON)

    // 标准审计字段从BaseEntity继承
}
```

**extra_info 字段结构示例**：

```json
// 网口打印机
{
  "ip": "192.168.1.100",
  "port": 9100
}

// 串口打印机
{
  "comPort": "COM1",
  "baudRate": 9600,
  "dataBits": 8,
  "stopBits": 1,
  "parity": "NONE"
}

// 驱动打印机
{
  "driverPath": "C:\\Windows\\System32\\spool\\drivers\\printer.dll",
  "printerName": "EPSON LQ-300K"
}

// 云打印机
{
  "apiKey": "xxxxx",
  "machineCode": "xxxxx",
  "deviceNo": "xxxxx"
}
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |

---

### 2.2 pos_prn_queue（打印队列表）

**用途**：配置打印队列，管理主/备打印机映射关系。

```sql
CREATE TABLE pos_prn_queue (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) NOT NULL COMMENT '打印队列名称',
  pc_lid BIGINT COMMENT 'PC终端lid',

  -- 打印机配置（逗号分隔的打印机lid列表）
  primary_printer TEXT COMMENT '主打印机lid列表(逗号分隔)',
  standby_printer TEXT COMMENT '备用打印机lid列表(逗号分隔)',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印队列表';
```

**实体字段映射**：

```java
@Table(value = "pos_prn_queue", onInsert = YdInsertListener.class)
public class PosPrnQueue extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;
    private String name;
    private Long pcLid;

    private String primaryPrinter;    // BLOB/TEXT，主打印机lid列表（逗号分隔）
    private String standbyPrinter;   // BLOB/TEXT，备用打印机lid列表（逗号分隔）

    // 标准审计字段从BaseEntity继承
}
```

**存储格式说明**：

```
primaryPrinter字段示例：
"123456789,234567890,345678901"  // 三个打印机lid，按顺序优先尝试

standbyPrinter字段示例：
"456789012"  // 一个备用打印机lid
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |

---

### 2.3 pos_prn_job（打印任务表）

**用途**：记录每次打印任务的完整生命周期。

```sql
CREATE TABLE pos_prn_job (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 业务单据关联
  biz_bill_id VARCHAR(100) COMMENT '业务单据ID（如订单号saasOrderNo）',

  -- 打印类型与用途
  type_ TINYINT NOT NULL COMMENT '打印样式类型(PrnStyleTypeEnum)：10-点菜单 26-结账单等',
  purpose TINYINT COMMENT '打印用途(PrnJobPurposeEnum)：1-厨房联 2-划菜联 3-顾客联',
  prn_count INT COMMENT '打印份数',

  -- 队列与打印机目标
  prn_queue_lid BIGINT COMMENT '打印队列lid',
  prn_printer_lid BIGINT COMMENT '实际打印的打印机lid',

  -- 打印状态
  print_ TINYINT COMMENT '是否已打印：0-否 1-是',
  print_at DATETIME COMMENT '打印时间',
  status_ TINYINT NOT NULL DEFAULT 1 COMMENT '打印任务状态：1-PENDING 2-SUCCESS 3-FAILED',
  failure_reason VARCHAR(500) COMMENT '失败原因',

  -- 终端设备
  dev_id BIGINT COMMENT '终端设备ID',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_biz_bill_id (biz_bill_id),
  INDEX idx_prn_queue_lid (prn_queue_lid),
  INDEX idx_prn_printer_lid (prn_printer_lid),
  INDEX idx_status (status_),
  INDEX idx_created_time (created_time),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印任务表';
```

**实体字段映射**：

```java
@Table(value = "pos_prn_job", onInsert = YdInsertListener.class)
public class PosPrnJob extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;

    private String bizBillId;              // 业务单据ID

    private PrnStyleTypeEnum type;         // 打印样式类型
    private PrnJobPurposeEnum purpose;      // 打印用途
    private Integer prnCount;               // 打印份数

    private Long prnQueueLid;               // 打印队列lid
    private Long prnPrinterLid;              // 实际打印机lid

    private Boolean print;                  // 是否已打印
    private LocalDateTime printAt;          // 打印时间
    private PrnJobStatusEnum status;        // 任务状态
    private String failureReason;           // 失败原因

    private Long devId;                     // 终端设备ID

    // 标准审计字段从BaseEntity继承
}
```

**任务状态流转**：

```
┌──────────┐
│ PENDING  │  ←── 任务创建
└────┬─────┘
     │
     ├─────────────────┐
     │                 │
     ▼                 ▼
┌─────────┐      ┌────────┐
│ SUCCESS │      │ FAILED │
└─────────┘      └────────┘
                      │
                      ▼
                 可重试 → PENDING
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_biz_bill_id | 普通 | biz_bill_id | 按业务单据查询 |
| idx_prn_queue_lid | 普通 | prn_queue_lid | 按队列查询 |
| idx_prn_printer_lid | 普通 | prn_printer_lid | 按打印机查询 |
| idx_status | 普通 | status_ | 按状态查询（重试扫描） |
| idx_created_time | 普通 | created_time | 按时间范围查询 |

---

### 2.4 pos_prn_style_row（打印样式行表）

**用途**：定义每种打印单据的行级样式模板。

```sql
CREATE TABLE pos_prn_style_row (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 样式关联
  style_type TINYINT NOT NULL COMMENT '打印样式类型(PrnStyleTypeEnum)',
  ds_id VARCHAR(100) COMMENT '数据源ID（如store_info、bill_info、food_info等）',

  -- 显示控制
  show_index INT COMMENT '显示顺序',

  -- 条件过滤
  display_condition TEXT COMMENT '行显示条件(JSON格式)',
  condition_ds_id VARCHAR(100) COMMENT '条件数据源ID',
  condition_value VARCHAR(100) COMMENT '条件值',
  condition_operator TINYINT COMMENT '条件算子(ConditionOperatorEnum)',

  -- 汇总控制
  summarize TINYINT DEFAULT 0 COMMENT '是否汇总：0-否 1-是',
  summarize_col_name VARCHAR(50) COMMENT '汇总列名',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_style_type (style_type),
  INDEX idx_ds_id (ds_id),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印样式行表';
```

**实体字段映射**：

```java
public class PosPrnStyleRow extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;

    private PrnStyleTypeEnum styleType;    // 打印样式类型
    private String dsId;                   // 数据源ID

    private Integer showIndex;             // 显示顺序

    // 条件过滤
    private String displayCondition;        // 行显示条件(JSON)
    private String conditionDsId;          // 条件数据源ID
    private String conditionValue;          // 条件值
    private ConditionOperatorEnum conditionOperator;  // 条件算子

    // 汇总控制
    private Boolean summarize;              // 是否汇总
    private String summarizeColName;       // 汇总列名

    // 标准审计字段从BaseEntity继承
}
```

**display_condition 字段结构示例**：

```json
// 简单条件
{
  "dsId": "food_info",
  "field": "foodNumber",
  "operator": "GT",
  "value": "0"
}

// 复合条件
{
  "dsId": "food_info",
  "conditions": [
    {"field": "foodNumber", "operator": "GT", "value": "0"},
    {"field": "foodStatus", "operator": "EQ", "value": "1"}
  ],
  "logic": "AND"
}
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_style_type | 普通 | style_type | 按样式类型查询 |
| idx_ds_id | 普通 | ds_id | 按数据源ID查询 |

---

### 2.5 pos_prn_style_col（打印样式列表）

**用途**：定义打印模板中每行的列级样式配置。

```sql
CREATE TABLE pos_prn_style_col (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 列归属
  style_type TINYINT NOT NULL COMMENT '打印样式类型(PrnStyleTypeEnum)',
  row_lid BIGINT NOT NULL COMMENT '所属行lid',

  -- 列类型与内容
  type_ TINYINT NOT NULL COMMENT '列类型(PrnStyleColTypeEnum)：1-条码 2-二维码 3-文本 4-图片 5-换行 6-切纸 7-弹钱箱 8-画线 9-注释 10-SQL查询',
  customized_content TEXT COMMENT '自定义内容(文本内容或SQL表达式)',

  -- 宽度配置（支持不同纸张宽度）
  width80 INT COMMENT '80mm纸宽度(字符数)',
  width76 INT COMMENT '76mm纸宽度(字符数)',
  width58 INT COMMENT '58mm纸宽度(字符数)',

  -- 样式配置
  align_ TINYINT COMMENT '对齐方式(PrnStypeAlignEnum)：1-居中 2-右对齐 3-左对齐',
  font_size TINYINT COMMENT '字体大小(PrnStyleFontSizeEnum)：1-标准 2-倍宽 3-倍高 4-双倍 5-9号 6-四倍',
  bold_ TINYINT DEFAULT 0 COMMENT '是否加粗：0-否 1-是',

  -- 汇总配置
  summarize TINYINT DEFAULT 0 COMMENT '是否汇总列：0-否 1-是',

  -- 序列号
  show_index INT COMMENT '显示顺序',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_style_type (style_type),
  INDEX idx_row_lid (row_lid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印样式列表';
```

**实体字段映射**：

```java
public class PosPrnStyleCol extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;

    private PrnStyleTypeEnum styleType;    // 打印样式类型
    private Long rowLid;                   // 所属行lid

    private PrnStyleColTypeEnum type;      // 列类型
    private String customizedContent;       // 自定义内容

    // 宽度配置
    private Integer width80;               // 80mm纸宽度
    private Integer width76;               // 76mm纸宽度
    private Integer width58;               // 58mm纸宽度

    // 样式配置
    private PrnStypeAlignEnum align;       // 对齐方式
    private PrnStyleFontSizeEnum fontSize;  // 字体大小
    private Boolean bold;                   // 是否加粗

    private Boolean summarize;              // 是否汇总列

    private Integer showIndex;              // 显示顺序

    // 标准审计字段从BaseEntity继承
}
```

**列类型枚举值**：

| code | 枚举常量 | 中文说明 | customized_content 示例 |
|------|----------|----------|------------------------|
| 1 | BAR_CODE | 条码 | 条码内容 |
| 2 | QR_CODE | 二维码 | 二维码内容 |
| 3 | TEXT | 文本 | 固定文本或字段名 |
| 4 | IMG | 图片 | 图片URL或Base64 |
| 5 | BR | 换行 | 空 |
| 6 | CUT | 切纸 | 空 |
| 7 | CASH_BOX | 弹钱箱 | 空 |
| 8 | LINE | 画直线 | 分隔符内容 |
| 9 | COMMENT | 注释 | 注释内容 |
| 10 | SQL_QUERY | SQL查询 | SELECT语句 |

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_style_type | 普通 | style_type | 按样式类型查询 |
| idx_row_lid | 普通 | row_lid | 按行查询（获取列列表） |

---

### 2.6 print_job_type_switch（打印开关配置表）

**用途**：按单据类型控制是否打印厨房联/传菜联/顾客联，以及各联的打印份数。

```sql
CREATE TABLE print_job_type_switch (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 打印类型
  type_ TINYINT NOT NULL COMMENT '打印样式类型(PrnStyleTypeEnum)',

  -- 厨房联配置
  disabled_kitchen TINYINT DEFAULT 0 COMMENT '禁用厨房联：0-否 1-是',
  num_of_kitchen INT DEFAULT 1 COMMENT '厨房联打印份数',

  -- 传菜联配置
  disabled_waiter TINYINT DEFAULT 0 COMMENT '禁用传菜联：0-否 1-是',
  num_of_waiter INT DEFAULT 1 COMMENT '传菜联打印份数',

  -- 顾客联配置
  disabled_customer TINYINT DEFAULT 0 COMMENT '禁用顾客联：0-否 1-是',
  num_of_customer INT DEFAULT 1 COMMENT '顾客联打印份数',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_type (type_),
  UNIQUE INDEX uk_lid (lid),
  UNIQUE INDEX uk_mid_sid_type (mid, sid, type_, deleted)
) COMMENT='打印开关配置表';
```

**实体字段映射**：

```java
public class PrintJobTypeSwitch extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;

    private PrnStyleTypeEnum type;         // 打印样式类型

    // 厨房联
    private Boolean disabledKitchen;         // 禁用厨房联
    private Integer numOfKitchen;           // 厨房联打印份数

    // 传菜联
    private Boolean disabledWaiter;         // 禁用传菜联
    private Integer numOfWaiter;            // 传菜联打印份数

    // 顾客联
    private Boolean disabledCustomer;        // 禁用顾客联
    private Integer numOfCustomer;          // 顾客联打印份数

    // 标准审计字段从BaseEntity继承
}
```

**默认值逻辑**：

| 字段 | 默认值 | 含义 |
|------|--------|------|
| disabled_kitchen | 0 | 默认可打印 |
| disabled_waiter | 0 | 默认可打印 |
| disabled_customer | 0 | 默认可打印 |
| num_of_kitchen | 1 | 默认打印1份 |
| num_of_waiter | 1 | 默认打印1份 |
| num_of_customer | 1 | 默认打印1份 |

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_type | 普通 | type_ | 按打印类型查询 |
| uk_mid_sid_type | 唯一 | mid+sid+type_+deleted | 商户级配置唯一约束 |

---

### 2.7 pos_customer_bill_setting（顾客联配置表）

**用途**：按桌台/区域/桌型/PC终端配置顾客联的打印队列。

```sql
CREATE TABLE pos_customer_bill_setting (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 队列配置（逗号分隔的队列lid列表）
  prn_queue TEXT COMMENT '打印队列lid列表(逗号分隔)',

  -- 打印模式
  by_mobile TINYINT DEFAULT 0 COMMENT '是否按移动支付方式打印：0-否 1-是',
  for_checkout TINYINT DEFAULT 1 COMMENT '是否用于结账打印：0-否 1-是',

  -- 关联条件（优先级从高到低）
  pc_lid BIGINT COMMENT 'PC终端lid',
  tbl_area_lid BIGINT COMMENT '桌台区域lid',
  tbl_type_lid BIGINT COMMENT '桌型lid',
  tbl_lid BIGINT COMMENT '桌台lid',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_tbl_lid (tbl_lid),
  INDEX idx_tbl_area_lid (tbl_area_lid),
  INDEX idx_tbl_type_lid (tbl_type_lid),
  INDEX idx_pc_lid (pc_lid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='顾客联配置表';
```

**实体字段映射**：

```java
public class PosCustomerBillSetting extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;

    private String prnQueue;               // 打印队列lid列表（逗号分隔）

    private Boolean byMobile;               // 按移动支付打印
    private Boolean forCheckout;            // 用于结账打印

    // 关联条件
    private Long pcLid;                    // PC终端lid
    private Long tblAreaLid;               // 桌台区域lid
    private Long tblTypeLid;               // 桌型lid
    private Long tblLid;                   // 桌台lid

    // 标准审计字段从BaseEntity继承
}
```

**优先级选择逻辑**：

```
配置查找优先级（从高到低）：
1. tbl_lid (桌台级)       → 最精确
2. tbl_area_lid (区域级)   → 次精确
3. tbl_type_lid (桌型级)   → 中等级别
4. pc_lid (PC终端级)       → 兜底配置
```

**典型配置场景**：

| 场景 | tbl_lid | tbl_area_lid | tbl_type_lid | pc_lid | prn_queue |
|------|---------|--------------|--------------|--------|-----------|
| 特定桌台 | 123 | null | null | null | 队列1 |
| 区域通用 | null | 456 | null | null | 队列2 |
| 桌型通用 | null | null | 789 | null | 队列3 |
| PC终端兜底 | null | null | null | 101 | 队列4 |

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_tbl_lid | 普通 | tbl_lid | 按桌台查询 |
| idx_tbl_area_lid | 普通 | tbl_area_lid | 按区域查询 |
| idx_tbl_type_lid | 普通 | tbl_type_lid | 按桌型查询 |
| idx_pc_lid | 普通 | pc_lid | 按PC终端查询 |

---

### 2.8 pos_waiter_bill_setting（传菜联配置表）

**用途**：按出品部门配置传菜联/划菜联的打印队列。

```sql
CREATE TABLE pos_waiter_bill_setting (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) NOT NULL COMMENT '配置名称',

  -- 部门配置（逗号分隔的出品部门lid列表）
  prn_dept TEXT COMMENT '出品部门lid列表(逗号分隔)',
  tbl_area VARCHAR(500) COMMENT '桌台区域(可配置特定区域)',

  -- 队列配置（逗号分隔的队列lid列表）
  prn_queue TEXT COMMENT '打印队列lid列表(逗号分隔)',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='传菜联配置表';
```

**实体字段映射**：

```java
public class PosWaiterBillSetting extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;
    private String name;

    private String prnDept;                // 出品部门lid列表（逗号分隔）
    private String tblArea;                // 桌台区域

    private String prnQueue;               // 打印队列lid列表（逗号分隔）

    // 标准审计字段从BaseEntity继承
}
```

**配置示例**：

```json
{
  "name": "中厨传菜配置",
  "prnDept": "101,102,103",
  "tblArea": "大厅区,包间区",
  "prnQueue": "201,202"
}
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |

---

### 2.9 pos_prn_printer_transfer（打印机转移规则表）

**用途**：定义打印任务的打印机转移规则。

```sql
CREATE TABLE pos_prn_printer_transfer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 规则名称
  name VARCHAR(100) NOT NULL COMMENT '规则名称',

  -- 触发条件
  style_type TINYINT COMMENT '打印样式类型(PrnStyleTypeEnum)，为空则匹配所有',
  from_printer_lid BIGINT COMMENT '源打印机lid',

  -- 转移目标
  to_printer_lid BIGINT NOT NULL COMMENT '目标打印机lid',

  -- 优先级
  priority INT DEFAULT 0 COMMENT '优先级，数字越大优先级越高',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_style_type (style_type),
  INDEX idx_from_printer_lid (from_printer_lid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印机转移规则表';
```

**实体字段映射**：

```java
public class PosPrnPrinterTransfer extends BaseEntity {
    private Long pid;
    private Long mid;
    private Long sid;
    private Long lid;
    private String name;

    private PrnStyleTypeEnum styleType;    // 打印样式类型
    private Long fromPrinterLid;           // 源打印机lid

    private Long toPrinterLid;             // 目标打印机lid

    private Integer priority;              // 优先级

    // 标准审计字段从BaseEntity继承
}
```

**使用场景**：

1. **打印机故障转移**：当指定打印机故障时，自动转移到备用打印机
2. **打印机负载均衡**：将特定类型的打印任务转移到专用打印机
3. **打印机分组**：按业务类型分配不同的打印机

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_style_type | 普通 | style_type | 按样式类型匹配 |
| idx_from_printer_lid | 普通 | from_printer_lid | 按源打印机查询 |

---

### 2.10 pos_dish_to_prn_dept（菜品出品部门关联表）

**用途**：建立菜品与出品部门的多对多映射关系。

```sql
CREATE TABLE pos_dish_to_prn_dept (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  -- 关联关系
  dish_lid BIGINT NOT NULL COMMENT '菜品lid',
  dept_lid BIGINT NOT NULL COMMENT '出品部门lid',

  -- 标准审计字段
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  INDEX idx_dish_lid (dish_lid),
  INDEX idx_dept_lid (dept_lid),
  UNIQUE INDEX uk_lid (lid),
  UNIQUE INDEX uk_dish_dept (dish_lid, dept_lid, deleted)
) COMMENT='菜品出品部门关联表';
```

**关联关系说明**：

```
菜品 ──────────────── 出品部门
  │                       │
  │  pos_dish_to_prn_dept │
  │  (多对多关联表)        │
  └───────────────────────┘

一个菜品可以关联多个出品部门
一个出品部门可以包含多个菜品
```

**索引设计**：

| 索引名 | 类型 | 字段 | 说明 |
|--------|------|------|------|
| PRIMARY | 主键 | pid | 物理主键 |
| uk_lid | 唯一 | lid | 逻辑编号唯一 |
| idx_mid | 普通 | mid | 按商户查询 |
| idx_sid | 普通 | sid | 按门店查询 |
| idx_dish_lid | 普通 | dish_lid | 按菜品查询 |
| idx_dept_lid | 普通 | dept_lid | 按部门查询 |
| uk_dish_dept | 唯一 | dish_lid+dept_lid+deleted | 菜品-部门唯一约束 |

---

## 3. 表间关系图

### 3.1 ER 图

```
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    打印系统数据模型 ER 图                                         │
├────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                │
│   ┌──────────────────┐         ┌──────────────────┐                                          │
│   │  pos_prn_printer  │         │   pos_prn_queue  │                                          │
│   ├──────────────────┤         ├──────────────────┤                                          │
│   │ pid (PK)         │         │ pid (PK)         │                                          │
│   │ lid (UK)         │         │ lid (UK)         │                                          │
│   │ name             │         │ name             │                                          │
│   │ type             │         │ primaryPrinter   │◄─────┐                                   │
│   │ model            │         │ standbyPrinter   │◄─────┤ 逗号分隔                           │
│   │ extraInfo        │         │ pcLid            │      │ lid列表                           │
│   │ pcLid            │         └──────────────────┘      │                                   │
│   └──────────────────┘                  │                │                                   │
│           │                             │                │                                   │
│           │                             │                │                                   │
│           │              ┌──────────────┴───────────────┘                                    │
│           │              │                                                                         │
│           │              ▼                           ▲                                        │
│           │     ┌──────────────────┐    ┌──────────────────┐                                │
│           │     │   pos_prn_job    │    │pos_prn_queue(复) │                                │
│           │     ├──────────────────┤    └──────────────────┘                                │
│           └──►  │ pid (PK)         │                                                         │
│           │     │ lid (UK)         │                                                         │
│           │     │ bizBillId        │                                                         │
│           │     │ type             │                                                         │
│           │     │ purpose          │                                                         │
│           │     │ prnQueueLid ─────┼─────────────────────────────────┐                        │
│           │     │ prnPrinterLid ◄───┘                                 │                        │
│           │     │ status          │                                   │                        │
│           │     └──────────────────┘                                   │                        │
│           │              │                                            │                        │
│           │              │ 解析                                        │                        │
│           │              ▼                                            │                        │
│           │     ┌──────────────────┐                                   │                        │
│           │     │pos_prn_style_row │                                   │                        │
│           │     ├──────────────────┤                                   │                        │
│           │     │ pid (PK)        │                                   │                        │
│           │     │ lid (UK)        │                                   │                        │
│           │     │ styleType       │◄──────────────────────────────────┘                        │
│           │     │ dsId            │    (关联样式类型)                                           │
│           │     │ showIndex       │                                                            │
│           │     └────────┬─────────┘                                                            │
│           │              │                                                                     │
│           │              │ 1:N                                                               │
│           │              ▼                                                                     │
│           │     ┌──────────────────┐                                                          │
│           │     │ pos_prn_style_col │                                                          │
│           │     ├──────────────────┤                                                          │
│           │     │ pid (PK)        │                                                          │
│           │     │ lid (UK)        │                                                          │
│           │     │ styleType       │                                                          │
│           │     │ rowLid ──────────┘ (所属行)                                                 │
│           │     │ type            │                                                          │
│           │     │ align           │                                                          │
│           │     │ width80/76/58  │                                                          │
│           │     └──────────────────┘                                                          │
│           │                                                                                    │
│           │                                                                                    │
│           │                                                                                    │
│           │     ┌──────────────────────────────┐                                              │
│           │     │  print_job_type_switch       │                                              │
│           │     ├──────────────────────────────┤                                              │
│           │     │ pid (PK)                   │                                              │
│           │     │ lid (UK)                   │                                              │
│           │     │ type                       │◄─────────────┐                                  │
│           │     │ disabledKitchen             │              │ (打印开关)                       │
│           │     │ numOfKitchen               │              │                                  │
│           │     │ disabledWaiter              │              │                                  │
│           │     │ numOfWaiter                 │              │                                  │
│           │     │ disabledCustomer            │              │                                  │
│           │     │ numOfCustomer              │              │                                  │
│           │     └──────────────────────────────┘              │                                  │
│           │                                                 │                                  │
│           │     ┌──────────────────────────────┐             │                                  │
│           │     │  pos_customer_bill_setting  │             │                                  │
│           │     ├──────────────────────────────┤             │                                  │
│           │     │ pid (PK)                   │             │                                  │
│           │     │ lid (UK)                   │             │                                  │
│           │     │ prnQueue                   │             │                                  │
│           │     │ tblLid ────────────────────┼──────────────┘                                  │
│           │     │ tblAreaLid                 │  (顾客联队列选择)                                 │
│           │     │ tblTypeLid                │                                               │
│           │     │ pcLid                     │                                               │
│           │     └──────────────────────────────┘                                               │
│           │                                                                                    │
│           │     ┌──────────────────────────────┐                                              │
│           │     │  pos_waiter_bill_setting   │                                              │
│           │     ├──────────────────────────────┤                                              │
│           │     │ pid (PK)                   │                                              │
│           │     │ lid (UK)                   │                                              │
│           │     │ name                       │                                              │
│           │     │ prnDept                    │                                              │
│           │     │ tblArea                    │                                              │
│           │     │ prnQueue                   │                                              │
│           │     └──────────────────────────────┘                                              │
│           │                                                                                    │
│           │     ┌──────────────────────────────┐                                              │
│           │     │ pos_prn_printer_transfer    │                                              │
│           │     ├──────────────────────────────┤                                              │
│           │     │ pid (PK)                   │                                              │
│           │     │ lid (UK)                   │                                              │
│           │     │ name                       │                                              │
│           │     │ styleType                  │                                              │
│           │     │ fromPrinterLid ─────────────┼────► (源打印机)                               │
│           │     │ toPrinterLid ───────────────┼────► (目标打印机)                             │
│           │     │ priority                   │                                              │
│           │     └──────────────────────────────┘                                              │
│           │                                                                                    │
│           │     ┌──────────────────────────────┐                                              │
│           │     │   pos_dish_to_prn_dept     │                                              │
│           │     ├──────────────────────────────┤                                              │
│           │     │ pid (PK)                   │                                              │
│           │     │ lid (UK)                   │                                              │
│           │     │ dishLid ───────────────────┬─┘  (菜品)                                     │
│           │     │ deptLid ──────────────────┘   (出品部门)                                    │
│           │     └──────────────────────────────┘                                              │
│           │                                                                                    │
└───────────┼────────────────────────────────────────────────────────────────────────────────────┘
            │
            │ pid/lid 关联到其他业务表
            │
            ▼
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   关联业务表（引用 lid）                                         │
├────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐                        │
│   │    sys_pc        │    │     pos_dept     │    │     pt_dish      │                        │
│   ├──────────────────┤    ├──────────────────┤    ├──────────────────┤                        │
│   │ pc_lid 关联       │    │ deptLid 关联     │    │ dishLid 关联      │                        │
│   │ 终端设备表        │    │ 出品部门表       │    │ 菜品表           │                        │
│   └──────────────────┘    └──────────────────┘    └──────────────────┘                        │
│                                                                                                │
│   ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐                        │
│   │     pt_tbl       │    │   pt_tbl_area   │    │   pt_tbl_type    │                        │
│   ├──────────────────┤    ├──────────────────┤    ├──────────────────┤                        │
│   │ tblLid 关联       │    │ tblAreaLid 关联  │    │ tblTypeLid 关联  │                        │
│   │ 桌台表           │    │ 桌台区域表       │    │ 桌型表           │                        │
│   └──────────────────┘    └──────────────────┘    └──────────────────┘                        │
│                                                                                                │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 关系说明表

| 关系 | 父表 | 子表 | 关联字段 | 说明 |
|------|------|------|----------|------|
| 队列→打印机 | pos_prn_queue | pos_prn_printer | primaryPrinter/standbyPrinter (逗号分隔lid) | 1:N，队列配置主/备打印机 |
| 任务→队列 | pos_prn_job | pos_prn_queue | prnQueueLid | N:1，任务指向目标队列 |
| 任务→打印机 | pos_prn_job | pos_prn_printer | prnPrinterLid | N:1，任务记录实际打印机 |
| 样式→行→列 | pos_prn_style_row | pos_prn_style_col | rowLid | 1:N，行下有多列 |
| 菜品→部门 | pt_dish | pos_dish_to_prn_dept | dishLid | N:1，菜品关联多个部门 |
| 部门→菜品 | pos_dept | pos_dish_to_prn_dept | deptLid | 1:N，部门关联多个菜品 |

---

## 4. 索引策略总结

### 4.1 索引设计原则

1. **唯一性约束**：`lid` 字段作为业务主键，必须唯一
2. **租户隔离**：`mid` + `sid` 作为查询前缀索引
3. **高频查询**：状态、时间、业务ID 等作为辅助索引
4. **复合索引**：`uk_mid_sid_type` 等满足多条件查询

### 4.2 索引清单

| 表名 | 索引名 | 类型 | 字段 | 用途 |
|------|--------|------|------|------|
| pos_prn_printer | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| pos_prn_queue | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| pos_prn_job | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_biz_bill_id | 普通 | biz_bill_id | 业务单据查询 |
| | idx_prn_queue_lid | 普通 | prn_queue_lid | 队列任务查询 |
| | idx_prn_printer_lid | 普通 | prn_printer_lid | 打印机任务查询 |
| | idx_status | 普通 | status_ | 状态扫描 |
| | idx_created_time | 普通 | created_time | 时间范围查询 |
| pos_prn_style_row | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_style_type | 普通 | style_type | 样式类型查询 |
| | idx_ds_id | 普通 | ds_id | 数据源查询 |
| pos_prn_style_col | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_style_type | 普通 | style_type | 样式类型查询 |
| | idx_row_lid | 普通 | row_lid | 行内列查询 |
| print_job_type_switch | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_type | 普通 | type_ | 类型查询 |
| | uk_mid_sid_type | 唯一 | mid+sid+type_+deleted | 配置唯一约束 |
| pos_customer_bill_setting | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_tbl_lid | 普通 | tbl_lid | 桌台查询 |
| | idx_tbl_area_lid | 普通 | tbl_area_lid | 区域查询 |
| | idx_tbl_type_lid | 普通 | tbl_type_lid | 桌型查询 |
| | idx_pc_lid | 普通 | pc_lid | PC终端查询 |
| pos_waiter_bill_setting | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| pos_prn_printer_transfer | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_style_type | 普通 | style_type | 样式类型查询 |
| | idx_from_printer_lid | 普通 | from_printer_lid | 源打印机查询 |
| pos_dish_to_prn_dept | PRIMARY | 主键 | pid | 物理主键 |
| | uk_lid | 唯一 | lid | 逻辑主键 |
| | idx_mid | 普通 | mid | 商户查询 |
| | idx_sid | 普通 | sid | 门店查询 |
| | idx_dish_lid | 普通 | dish_lid | 菜品查询 |
| | idx_dept_lid | 普通 | dept_lid | 部门查询 |
| | uk_dish_dept | 唯一 | dish_lid+dept_lid+deleted | 菜品-部门唯一约束 |

---

## 5. 字段类型规范

### 5.1 标准字段类型

| 字段类型 | Java 类型 | MySQL 类型 | 说明 |
|----------|-----------|------------|------|
| 物理编号 | Long | BIGINT | 自增主键 |
| 商户ID | Long | BIGINT | 多租户隔离 |
| 门店ID | Long | BIGINT | 门店隔离 |
| 逻辑编号 | Long | BIGINT | 雪花算法唯一ID |
| 枚举字段 | Enum (TINYINT) | TINYINT | 存储code值 |
| 布尔字段 | Boolean | TINYINT | 0-否，1-是 |
| 名称/文本 | String | VARCHAR(100) | 普通文本 |
| 长文本 | String | TEXT | 文本内容 |
| JSON配置 | String | TEXT | JSON格式配置 |
| 逗号分隔列表 | String | TEXT | 逗号分隔的lid列表 |
| 时间 | LocalDateTime | DATETIME | 时间类型 |
| 创建人 | String | VARCHAR(100) | 操作人 |

### 5.2 枚举存储规范

所有枚举字段在数据库中存储 **数字code值**，不在数据库中存储枚举名。

| 枚举类型 | 字段 | 存储值示例 |
|----------|------|------------|
| PrinterTypeEnum | type_ | 1, 2, 3... |
| PrinterModelEnum | model_ | 1, 2, 3... |
| PrnStyleTypeEnum | type_ | 10, 26, 54... |
| PrnJobPurposeEnum | purpose | 1, 2, 3 |
| PrnJobStatusEnum | status_ | 1, 2, 3 |
| PrnStyleColTypeEnum | type_ | 1, 2, 3... |
| PrnStypeAlignEnum | align_ | 1, 2, 3 |
| PrnStyleFontSizeEnum | font_size | 1, 2, 3... |
| ConditionOperatorEnum | condition_operator | 11, 12, 13... |

---

## 6. 多租户隔离策略

### 6.1 隔离模型

```
商户(mid)
  │
  └── 门店(sid)
        │
        ├── 打印机(pos_prn_printer)
        ├── 打印队列(pos_prn_queue)
        ├── 打印任务(pos_prn_job)
        ├── 打印样式(pos_prn_style_row / pos_prn_style_col)
        ├── 打印开关(print_job_type_switch)
        ├── 顾客联配置(pos_customer_bill_setting)
        ├── 传菜联配置(pos_waiter_bill_setting)
        └── 打印机转移规则(pos_prn_printer_transfer)
```

### 6.2 查询策略

```java
// 所有打印相关查询必须包含租户过滤
public List<PosPrnPrinter> getByMidSid(Long mid, Long sid) {
    return posPrnPrinterMapper.selectList(
        QueryWrapper.create()
            .eq(PosPrnPrinter::getMid, mid)
            .eq(PosPrnPrinter::getSid, sid)
            .eq(PosPrnPrinter::getDeleted, 0)
    );
}
```

---

## 7. 文档状态

**文档状态**：DA5 完成

**下一步**：DA6 功能深度分析（样式配置）
