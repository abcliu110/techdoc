# DA5 - 数据模型：打印功能数据库设计

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 核心数据表

### 1.1 pos_prn_printer - 打印机表

```sql
CREATE TABLE pos_prn_printer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) NOT NULL COMMENT '打印机名称',
  pc_lid BIGINT COMMENT '关联PC设备ID',

  type_ TINYINT NOT NULL COMMENT '打印机类型:1-DRIVER,2-DRIVER_CMD,3-NET,4-COM,5-USB,6-LPT,7-XY_CLOUD,8-JB_CLOUD',
  model VARCHAR(50) COMMENT '打印机型号',
  extra_info TEXT COMMENT '扩展信息(JSON)',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印机表';
```

**extra_info 结构示例**：

```json
// 网络打印机
{
  "ip": "192.168.1.100",
  "port": 9100
}

// 串口打印机
{
  "port": "COM1",
  "baudRate": 115200,
  "dataBits": 8,
  "stopBits": 1,
  "parity": 0
}

// USB打印机
{
  "vendorId": "0x0471",
  "productId": "0x0620",
  "printerName": "HP LaserJet P1102"
}

// 芯烨云打印机
{
  "sn": "SN123456789",
  "key": "abcdef123456"
}

// 佳博云打印机
{
  "machineCode": "MACHINE123",
  "msign": "SIGN456"
}
```

### 1.2 pos_prn_queue - 打印队列表

```sql
CREATE TABLE pos_prn_queue (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  name VARCHAR(100) NOT NULL COMMENT '队列名称',
  primary_printer VARCHAR(500) COMMENT '主打印机ID列表(逗号分隔)',
  standby_printer VARCHAR(500) COMMENT '备打印机ID列表(逗号分隔)',
  pc_lid BIGINT COMMENT '关联PC设备ID(可选)',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid (mid),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印队列表';
```

### 1.3 pos_prn_style_row - 打印样式行表

```sql
CREATE TABLE pos_prn_style_row (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  ds_id VARCHAR(50) NOT NULL COMMENT '数据源ID',
  style_type INT NOT NULL COMMENT '打印样式类型',

  show_index INT NOT NULL DEFAULT 0 COMMENT '显示顺序',
  display_condition TEXT COMMENT '显示条件JSON',

  -- 条件过滤配置
  condition_ds_id VARCHAR(50) COMMENT '条件数据源ID',
  condition_operator VARCHAR(20) COMMENT '条件运算符:EQ,NE,GT,GTE,LT,LTE,IN,NOT_IN,LIKE,NOT_LIKE',
  condition_value VARCHAR(200) COMMENT '条件值',

  -- 汇总配置
  summarize TINYINT DEFAULT 0 COMMENT '是否汇总:0-否,1-是',
  summarize_col_name VARCHAR(50) COMMENT '汇总列名',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  INDEX idx_mid_sid_type (mid, sid, style_type),
  INDEX idx_sid (sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印样式行表';
```

**display_condition 结构示例**：

```json
{
  "columns": [
    {
      "dsId": "storeInfo",
      "fieldId": "name",
      "customizedContent": "门店名称：${storeInfo,name}",
      "align": "CENTER",
      "bold": true,
      "fontSize": 16,
      "width": 32,
      "printCount": 1
    },
    {
      "dsId": "billInfo",
      "fieldId": "orderNo",
      "customizedContent": "订单号：${billInfo,orderNo}",
      "align": "LEFT",
      "bold": false,
      "fontSize": 12,
      "width": 32
    }
  ]
}
```

### 1.4 pos_prn_job - 打印任务表

```sql
CREATE TABLE pos_prn_job (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法,任务ID)',

  biz_bill_id VARCHAR(100) COMMENT '业务单号(关联业务表)',
  type_ INT NOT NULL COMMENT '打印类型(PrnStyleTypeEnum.code)',
  purpose VARCHAR(20) NOT NULL COMMENT '打印用途:FOR_CUSTOMER/FOR_KITCHEN/FOR_WAITER/FOR_DEVICE',

  prn_count INT NOT NULL DEFAULT 0 COMMENT '打印次数',
  prn_queue_lid BIGINT COMMENT '目标打印队列ID',
  prn_printer_lid BIGINT COMMENT '目标打印机ID',

  print_at DATETIME COMMENT '打印时间',
  status_ VARCHAR(20) DEFAULT 'PENDING' COMMENT '任务状态:PENDING/PRINTING/SUCCESS/FAILED',
  failure_reason TEXT COMMENT '失败原因',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid_sid (mid, sid),
  INDEX idx_biz_bill_id (biz_bill_id),
  INDEX idx_status (status_),
  INDEX idx_created_time (created_time),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印任务表';
```

### 1.5 pos_prn_printer_transfer - 打印机转移记录表

```sql
CREATE TABLE pos_prn_printer_transfer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  from_printer_lid BIGINT NOT NULL COMMENT '原打印机ID',
  to_printer_lid BIGINT NOT NULL COMMENT '目标打印机ID',
  transfer_type VARCHAR(20) NOT NULL COMMENT '转移类型',
  reason VARCHAR(500) COMMENT '转移原因',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid_sid (mid, sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='打印机转移记录表';
```

### 1.6 pos_customer_bill_setting - 顾客联队列设置表

```sql
CREATE TABLE pos_customer_bill_setting (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  for_checkout TINYINT NOT NULL DEFAULT 1 COMMENT '是否结账场景:0-否,1-是',
  source VARCHAR(20) COMMENT '来源:CUSTOMER/WAITER',

  -- 匹配维度(互斥)
  table_lid BIGINT COMMENT '桌台ID',
  area_lid BIGINT COMMENT '区域ID',
  table_type_lid BIGINT COMMENT '桌型ID',
  pc_lid BIGINT COMMENT 'PC设备ID',

  prn_queue VARCHAR(500) NOT NULL COMMENT '目标打印队列ID列表(逗号分隔)',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid_sid (mid, sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='顾客联队列设置表';
```

### 1.7 pos_waiter_bill_setting - 传菜联队列设置表

```sql
CREATE TABLE pos_waiter_bill_setting (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  lid BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',

  name VARCHAR(100) NOT NULL COMMENT '传菜间名称',
  prn_dept VARCHAR(500) NOT NULL COMMENT '出品部门ID列表(逗号分隔)',
  prn_queue VARCHAR(500) NOT NULL COMMENT '目标打印队列ID列表(逗号分隔)',

  revision INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  deleted TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除:0-否,1-是',

  INDEX idx_mid_sid (mid, sid),
  UNIQUE INDEX uk_lid (lid)
) COMMENT='传菜联队列设置表';
```

### 1.8 print_job_type_switch - 打印类型开关表

```sql
CREATE TABLE print_job_type_switch (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',

  style_type INT NOT NULL COMMENT '打印类型(PrnStyleTypeEnum.code)',

  disabled_customer TINYINT DEFAULT 0 COMMENT '禁用顾客联:0-否,1-是',
  disabled_kitchen TINYINT DEFAULT 0 COMMENT '禁用厨房联:0-否,1-是',
  disabled_waiter TINYINT DEFAULT 0 COMMENT '禁用传菜联:0-否,1-是',

  num_of_customer INT DEFAULT 1 COMMENT '顾客联张数',
  num_of_kitchen INT DEFAULT 1 COMMENT '厨房联张数',
  num_of_waiter INT DEFAULT 1 COMMENT '传菜联张数',

  created_by VARCHAR(100) COMMENT '创建人',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_by VARCHAR(100) COMMENT '更新人',
  updated_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

  INDEX idx_mid_sid_type (mid, sid, style_type),
  UNIQUE INDEX uk_mid_sid_type (mid, sid, style_type)
) COMMENT='打印类型开关配置表';
```

---

## 2. 数据关系图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          打印机管理层                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  pos_prn_printer ──────────────────────────────────────────────→ pos_prn_queue │
│       │                                                        │         │
│       │ primary/standby                                         │ uses    │
│       │ printer                                                │         │
│       │                                                        │         │
│       ▼                                                        ▼         │
│  pos_prn_printer ────→ pos_prn_printer_transfer                           │
│       │                                    (打印机转移记录)              │
│       │                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          打印配置层                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  pos_prn_queue ────────────────────────────────→ pos_prn_style_row     │
│       │                                                    │            │
│       │                                                    │ template   │
│       │                                                    │ for type   │
│       │                                                    │            │
│       ▼                                                    ▼            │
│  pos_customer ──────────────── pos_waiter                       │            │
│  _bill_setting              _bill_setting                       │            │
│       │                            │                            │            │
│       │ forCheckout/table          │ prnDept                     │            │
│       │ /area/type/pc              │                            │            │
│       │                            │                            │            │
│       └────────────────────────────┴────────────────────────────┘            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          打印任务层                                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  pos_prn_job                                                         │
│       │                                                             │
│       ├─ bizBillId ──────────→ 业务单据(DwdBill)                       │
│       │                                                             │
│       ├─ prnQueueLid ──────────→ pos_prn_queue                         │
│       │                                                             │
│       └─ type ─────────────────→ pos_prn_style_row (by style_type)     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. 枚举字段映射

### 3.1 打印机类型（PrinterTypeEnum）

| code | 枚举名 | 存储值 | 说明 |
|------|--------|--------|------|
| 1 | DRIVER | 1 | Windows驱动打印 |
| 2 | DRIVER_CMD | 2 | 驱动命令打印 |
| 3 | NET | 3 | 网络打印机 |
| 4 | COM | 4 | 串口打印机 |
| 5 | USB | 5 | USB打印机 |
| 6 | LPT | 6 | 并口打印机 |
| 7 | XY_CLOUD | 7 | 芯烨云打印 |
| 8 | JB_CLOUD | 8 | 佳博云打印 |

### 3.2 打印任务状态（PrnJobStatusEnum）

| code | 枚举名 | 存储值 | 说明 |
|------|--------|--------|------|
| PENDING | 待打印 | PENDING | 等待分发 |
| PRINTING | 打印中 | PRINTING | 正在打印 |
| SUCCESS | 成功 | SUCCESS | 打印成功 |
| FAILED | 失败 | FAILED | 打印失败 |

### 3.3 打印用途（PrnJobPurposeEnum）

| code | 枚举名 | 存储值 | 说明 |
|------|--------|--------|------|
| FOR_CUSTOMER | 顾客联 | FOR_CUSTOMER | 结账单等 |
| FOR_KITCHEN | 厨房联 | FOR_KITCHEN | 厨房单等 |
| FOR_WAITER | 传菜联 | FOR_WAITER | 传菜单等 |
| FOR_DEVICE | 设备指令 | FOR_DEVICE | 弹钱箱等 |

---

## 4. 索引设计

### 4.1 核心查询索引

| 索引名 | 字段 | 类型 | 说明 |
|--------|------|------|------|
| uk_lid | lid | UNIQUE | 全局唯一查询 |
| idx_mid_sid | mid, sid | 普通 | 商户门店组合查询 |
| idx_biz_bill_id | biz_bill_id | 普通 | 业务单据关联查询 |
| idx_status | status_ | 普通 | 状态批量查询 |
| idx_created_time | created_time | 普通 | 时间范围查询 |

### 4.2 打印样式查询索引

| 索引名 | 字段 | 类型 | 说明 |
|--------|------|------|------|
| idx_mid_sid_type | mid, sid, style_type | 普通 | 样式配置查询 |

---

## 5. Redis 数据

### 5.1 打印计数

```
Key: pos_service:pos_prn_job:count:{lid}
Type: String (Integer)
Value: 打印次数
TTL: 永久
```

### 5.2 打印机状态

```
Key: pos_printer:status:{printerLid}
Type: String
Value: HEALTHY | FAULT
TTL: 动态
```

---

*文档版本：v1.0 | 生成时间：2026-08-03*
