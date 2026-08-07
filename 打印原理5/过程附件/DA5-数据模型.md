# DA5 - 数据模型

> 阶段：DA5 数据模型
> 目标系统：打印系统
> 日期：2026-08-04
> 状态：✅ 分析完成

---

## 1. 概述

本文档定义打印系统的数据模型，包括核心实体的字段定义、表结构和枚举映射。

---

## 2. 核心实体总览

| 实体 | 表名 | 说明 | 所在模块 |
|------|------|------|---------|
| PosPrnJob | pos_prn_job | 打印任务 | nms4cloud-pos-dal |
| PosPrnPrinter | pos_prn_printer | 打印机 | nms4cloud-pos2plugin-dal |
| PosPrnQueue | pos_prn_queue | 打印队列 | nms4cloud-pos2plugin-dal |
| PosPrnStyle | pos_prn_style | 打印样式 | nms4cloud-pos-dal |
| PosPrnStyleRow | pos_prn_style_row | 样式行 | nms4cloud-pos2plugin-dal |

---

## 3. 打印任务（PosPrnJob）

### 3.1 表结构

```sql
CREATE TABLE pos_prn_job (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  bill_id VARCHAR(100) COMMENT '业务单据ID',
  printer BIGINT COMMENT '指定打印机LID',
  extra_info TEXT COMMENT '扩展信息(JSON)',
  type_ INT COMMENT '样式类型枚举',
  content TEXT COMMENT '打印内容(JSON)',
  finish_time DATETIME COMMENT '打印完成时间',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid_sid (mid, sid),
  INDEX idx_lid (lid),
  INDEX idx_deleted (deleted)
) COMMENT='打印任务表';
```

### 3.2 字段说明

| 字段 | 类型 | 说明 | 枚举 |
|------|------|------|------|
| pid | BIGINT | 物理编号，自增主键 | - |
| mid | BIGINT | 商户ID，多商户隔离 | - |
| sid | BIGINT | 门店ID，门店数据隔离 | - |
| lid | BIGINT | 逻辑编号，雪花算法生成 | - |
| bill_id | VARCHAR(100) | 关联业务单据ID（如订单号） | - |
| printer | BIGINT | 指定打印机LID（可选） | - |
| extra_info | TEXT | 扩展信息，JSON格式存储打印参数 | - |
| type_ | INT | 样式类型 | PrnStyleTypeEnum |
| content | TEXT | 打印内容，JSON格式存储渲染后的数据 | - |
| finish_time | DATETIME | 打印完成时间 | - |
| deleted | TINYINT | 逻辑删除标志 | - |
| revision | INT | 乐观锁版本号 | - |

### 3.3 与早期分析差异说明

**重要发现：**
- 早期分析中提到的 `print` 字段（存储在文件中）在实际代码中为 `content` 字段
- `content` 直接存储在数据库中，是 JSON 格式的打印内容
- 文件存储机制可能用于备份或日志，但核心数据在 DB

---

## 4. 打印机（PosPrnPrinter）

### 4.1 表结构

```sql
CREATE TABLE pos_prn_printer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) COMMENT '打印机名称',
  pc_lid BIGINT COMMENT '关联PC LID',
  type INT COMMENT '连接类型',
  model INT COMMENT '打印机型号',
  extra_info BLOB COMMENT '连接参数(JSON)',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid_sid (mid, sid),
  INDEX idx_lid (lid)
) COMMENT='打印机表';
```

### 4.2 字段说明

| 字段 | 类型 | 说明 | 枚举 |
|------|------|------|------|
| pid | BIGINT | 物理编号 | - |
| mid | BIGINT | 商户ID | - |
| sid | BIGINT | 门店ID | - |
| lid | BIGINT | 逻辑编号 | - |
| name | VARCHAR(100) | 打印机名称 | - |
| pc_lid | BIGINT | 关联PC LID | - |
| type | INT | 连接类型 | PrinterTypeEnum |
| model | INT | 打印机型号 | PrinterModelEnum |
| extra_info | BLOB | 连接参数（JSON） | - |

### 4.3 extra_info 结构

根据 `PrinterWorker.java` 中的使用方式，`extra_info` 结构如下：

```json
{
  "driver": "打印机驱动名称",      // DRIVER 类型
  "ip": "192.168.1.100",          // NET 类型
  "port": 9100,                   // NET 类型
  "comName": "COM1",              // COM 类型
  "baudRate": 9600,               // COM 类型
  "cloudSn": "设备序列号",          // 云打印类型
  "cloudKey": "API密钥"           // 云打印类型
}
```

---

## 5. 打印队列（PosPrnQueue）

### 5.1 表结构

```sql
CREATE TABLE pos_prn_queue (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) COMMENT '队列名称',
  pc_lid BIGINT COMMENT '关联PC LID',
  primary_printer BLOB COMMENT '主打印机LID列表(逗号分隔)',
  standby_printer BLOB COMMENT '备用打印机LID列表(逗号分隔)',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid_sid (mid, sid),
  INDEX idx_lid (lid)
) COMMENT='打印队列表';
```

### 5.2 字段说明

| 字段 | 类型 | 说明 | 存储格式 |
|------|------|------|---------|
| pid | BIGINT | 物理编号 | - |
| mid | BIGINT | 商户ID | - |
| sid | BIGINT | 门店ID | - |
| lid | BIGINT | 逻辑编号 | - |
| name | VARCHAR(100) | 队列名称 | - |
| pc_lid | BIGINT | 关联PC LID | - |
| primary_printer | BLOB | 主打印机LID列表 | `"lid1,lid2,lid3"` |
| standby_printer | BLOB | 备用打印机LID列表 | `"lid4,lid5"` |

### 5.3 主备打印机存储格式

```java
// 存储格式示例
primaryPrinter = "1234567890123456789,9876543210987654321"
standbyPrinter = "1111111111111111111"

// 解析方式
List<Long> primaryList = Arrays.stream(primaryPrinter.split(","))
    .map(Long::parseLong)
    .collect(Collectors.toList());
```

---

## 6. 打印样式（PosPrnStyle）

### 6.1 表结构

```sql
CREATE TABLE pos_prn_style (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  type_ INT NOT NULL COMMENT '样式类型',
  extra_info TEXT COMMENT '扩展配置(JSON)',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_mid_sid_type (mid, sid, type_),
  INDEX idx_lid (lid)
) COMMENT='打印样式表';
```

### 6.2 字段说明

| 字段 | 类型 | 说明 | 枚举 |
|------|------|------|------|
| pid | BIGINT | 物理编号 | - |
| mid | BIGINT | 商户ID | - |
| sid | BIGINT | 门店ID | - |
| lid | BIGINT | 逻辑编号 | - |
| type_ | INT | 样式类型 | PrnStyleTypeEnum |
| extra_info | TEXT | 扩展配置（JSON） | - |
| deleted | TINYINT | 逻辑删除 | - |

---

## 7. 样式行（PosPrnStyleRow）

### 7.1 表结构

```sql
CREATE TABLE pos_prn_style_row (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  ds_id VARCHAR(100) COMMENT '数据源ID',
  style_type INT COMMENT '样式类型',
  show_index INT COMMENT '显示顺序',
  display_condition TEXT COMMENT '显示条件',
  condition_ds_id VARCHAR(100) COMMENT '条件数据源ID',
  condition_operator VARCHAR(10) COMMENT '条件操作符',
  condition_value VARCHAR(100) COMMENT '条件值',
  summarize TINYINT COMMENT '是否汇总(0-否,1-是)',
  summarize_col_name VARCHAR(100) COMMENT '汇总列名',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',

  INDEX idx_style_type (style_type),
  INDEX idx_lid (lid)
) COMMENT='打印样式行表';
```

### 7.2 字段说明

| 字段 | 类型 | 说明 | 枚举/取值 |
|------|------|------|-----------|
| pid | BIGINT | 物理编号 | - |
| mid | BIGINT | 商户ID | - |
| sid | BIGINT | 门店ID | - |
| lid | BIGINT | 逻辑编号 | - |
| ds_id | VARCHAR(100) | 数据源ID | - |
| style_type | INT | 样式类型 | PrnStyleTypeEnum |
| show_index | INT | 显示顺序 | - |
| display_condition | TEXT | 显示条件（DSL表达式） | - |
| condition_ds_id | VARCHAR(100) | 条件判断使用的数据源 | - |
| condition_operator | VARCHAR(10) | 条件操作符 | `>`, `=`, `<`, `<>` |
| condition_value | VARCHAR(100) | 条件比较值 | - |
| summarize | TINYINT | 是否汇总行 | 0-否, 1-是 |
| summarize_col_name | VARCHAR(100) | 汇总列名 | - |

---

## 8. 枚举映射

### 8.1 打印机类型（PrinterTypeEnum）

| 枚举常量 | Code | 说明 | 存储值 |
|---------|------|------|--------|
| DRIVER | 1 | Windows 驱动打印 | 1 |
| NET | 2 | 网口打印 | 2 |
| COM | 3 | 串口打印 | 3 |
| USB | 4 | USB 打印 | 4 |
| LPT | 5 | 并口打印 | 5 |
| XY_CLOUD | 6 | 芯烨云打印 | 6 |
| JB_CLOUD | 7 | 佳博云打印 | 7 |
| DRIVER_CMD | 8 | 驱动+指令混合 | 8 |

**代码位置：** `nms4cloud-pos2plugin-api/.../PrinterTypeEnum.java`

### 8.2 打印机型号（PrinterModelEnum）

| 枚举常量 | Code | 说明 |
|---------|------|------|
| GP_3150TFN | 1 | 佳博标签打印机 |
| XP_T202UA | 2 | 芯烨标签打印机 |
| 其他型号... | ... | 待补充 |

**代码位置：** `nms4cloud-pos2plugin-api/.../PrinterModelEnum.java`

### 8.3 样式类型（PrnStyleTypeEnum 节选）

| 枚举常量 | Code | 说明 | 分类 |
|---------|------|------|------|
| OrderMenu | 10 | 点菜单 | 订单 |
| CheckOut | 26 | 结账单 | 订单 |
| FoodLabel | 52 | 标签单 | 厨房 |
| ShiftReport | 29 | 交班单 | 报表 |
| MemberSavingBill | 39 | 会员充值单 | 会员 |
| SMS_CRM_RECHARGE | 72 | 充值短信 | 会员 |
| WMS_ST_BILL_* | 1000+ | 仓储单据（50+种） | WMS |

**完整枚举：** 130+ 种样式类型

**代码位置：** `nms4cloud-pos-dal/.../PrnStyleTypeEnum.java`

### 8.4 条件操作符（ConditionOperatorEnum）

| 枚举常量 | Code | 说明 |
|---------|------|------|
| GT | 1 | 大于（>） |
| EQ | 2 | 等于（=） |
| LT | 3 | 小于（<） |
| NE | 4 | 不等于（<>） |

**代码位置：** `nms4cloud-pos2plugin-api/.../ConditionOperatorEnum.java`

---

## 9. 数据模型关系图

```
┌──────────────────────────────────────────────────────────────────┐
│                        数据模型关系                                │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐       1:N        ┌──────────────┐            │
│  │ 打印队列      │◄────────────────│ 打印机        │            │
│  │ PosPrnQueue  │   primaryPrinter │ PosPrnPrinter│            │
│  ├──────────────┤   standbyPrinter ├──────────────┤            │
│  │ lid (PK)     │                 │ lid (PK)     │            │
│  │ name         │                 │ type         │            │
│  │ primaryPrinter│                │ model        │            │
│  │ standbyPrinter│                │ extra_info   │            │
│  └──────────────┘                 └──────────────┘            │
│          │                                                        │
│          │ N:1                                                    │
│          ▼                                                        │
│  ┌──────────────┐       N:1       ┌──────────────┐            │
│  │ 打印任务      │─────────────────│ 打印样式      │            │
│  │ PosPrnJob    │    type_        │ PosPrnStyle  │            │
│  ├──────────────┤                 ├──────────────┤            │
│  │ lid (PK)     │                 │ lid (PK)     │            │
│  │ bill_id      │                 │ type_ (PK)   │            │
│  │ printer      │                 │ extra_info   │            │
│  │ type_        │                 └──────────────┘            │
│  │ content      │                         │                    │
│  │ finish_time  │                         │ 1:N                │
│  └──────────────┘                         ▼                    │
│                                   ┌──────────────┐            │
│                                   │ 样式行        │            │
│                                   │PosPrnStyleRow│            │
│                                   ├──────────────┤            │
│                                   │ lid (PK)     │            │
│                                   │ ds_id        │            │
│                                   │ show_index   │            │
│                                   │displayCondition│           │
│                                   │ condition_*  │            │
│                                   │ summarize    │            │
│                                   └──────────────┘            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 10. 索引设计

### 10.1 核心索引

| 表 | 索引名 | 索引字段 | 类型 | 用途 |
|---|--------|---------|------|------|
| pos_prn_job | idx_mid_sid | mid, sid | 普通 | 商户门店查询 |
| pos_prn_job | uk_lid | lid | 唯一 | 主键查询 |
| pos_prn_job | idx_deleted | deleted | 普通 | 软删除过滤 |
| pos_prn_printer | idx_mid_sid | mid, sid | 普通 | 商户门店查询 |
| pos_prn_printer | uk_lid | lid | 唯一 | 主键查询 |
| pos_prn_queue | idx_mid_sid | mid, sid | 普通 | 商户门店查询 |
| pos_prn_queue | uk_lid | lid | 唯一 | 主键查询 |
| pos_prn_style | idx_mid_sid_type | mid, sid, type_ | 普通 | 按类型查询样式 |
| pos_prn_style | uk_lid | lid | 唯一 | 主键查询 |
| pos_prn_style_row | idx_style_type | style_type | 普通 | 按样式类型查询行 |
| pos_prn_style_row | uk_lid | lid | 唯一 | 主键查询 |

---

## 11. 字段类型规范

### 11.1 标准字段约定

所有打印系统表均遵循以下标准字段约定：

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| pid | BIGINT | 物理编号 | 自增主键 |
| mid | BIGINT | 商户ID | 非空，多租户隔离 |
| sid | BIGINT | 门店ID | 非空，门店隔离 |
| lid | BIGINT | 逻辑编号 | 全局唯一，雪花算法 |
| created_by | VARCHAR(100) | 创建人 | - |
| created_time | DATETIME | 创建时间 | 非空，默认当前时间 |
| updated_by | VARCHAR(100) | 更新人 | - |
| updated_time | DATETIME | 更新时间 | 非空，自动更新 |
| deleted | TINYINT | 逻辑删除 | 非空，默认0 |
| revision | INT | 乐观锁 | 非空，默认0 |

### 11.2 业务字段规范

| 字段类型 | 存储格式 | 说明 |
|---------|---------|------|
| 多值字段 | BLOB，逗号分隔 | primaryPrinter、standbyPrinter |
| JSON 配置 | TEXT/BLOB | extra_info、content |
| 枚举值 | INT | 数据库存 code 值 |
| 时间字段 | DATETIME | finish_time 等 |
| 金额字段 | DECIMAL | 如有金额相关字段 |

---

**DA5 数据模型分析完成。**
