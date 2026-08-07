# DA5 数据模型 — 打印系统

> **定位**：SOP-00 DA5 阶段产出物，分析打印系统的数据模型结构、约束和关系
> **版本**：v1.0 | **日期**：2026-08-05
> **执行人**：AI
> **依赖**：DA0-侦察报告、DA1-业务切面分析、DA2-概念字典、DA3-关系分析、DA4-规则分析

---

## 模板加载记录

```
**模板加载记录**：
- 模板文件：SOP-00-DA5-模板.md
- 加载时间：2026-08-05
- 版本：v1.0
- 门禁检查：4/4 项通过
```

---

## 一、核心表结构

### 1.1 pos_prn_job（打印任务表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| lid | BIGINT | 任务ID | 全局唯一标识，时间有序 | PK, NOT NULL | E-002 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL, INDEX | E-002 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL, INDEX | E-002 |
| name | VARCHAR | 任务名称 | 便于识别的显示名称 | | E-002 |
| prnDeptName | VARCHAR | 打印部门 | 业务分组标识 | | E-002 |
| bizBillId | VARCHAR | 业务单据ID | 关联业务单据，可追溯来源 | INDEX | E-002 |
| type | INT | 打印样式类型 | 决定渲染模板和格式 | NOT NULL | E-002, E-007 |
| purpose | INT | 打印用途 | 区分打印场景 | | E-002 |
| prnCount | INT | 已打印次数 | 统计打印次数 | DEFAULT 0 | E-002 |
| prnQueueLid | BIGINT | 打印队列ID | 目标队列，决定路由 | INDEX | E-002, E-001:805 |
| prnPrinterLid | BIGINT | 指定打印机ID | 可选直接指定打印机 | INDEX | E-002 |
| print | TINYINT(1) | 是否已打印 | 状态辅助字段 | DEFAULT 0 | E-002, E-001:993 |
| printAt | DATETIME | 打印时间 | 打印完成时间戳 | | E-002 |
| status | TINYINT | 任务状态 | PENDING/SUCCESS/FAILED | NOT NULL | E-002, E-005 |
| failureReason | VARCHAR | 失败原因 | 失败时记录原因 | | E-002 |
| gmtCreate | DATETIME | 创建时间 | 记录创建时间 | | E-002 |
| gmtModified | DATETIME | 修改时间 | 记录更新时间 | | E-002 |

**聚合根分析**：
- pos_prn_job 是打印任务的聚合根
- 唯一标识：lid（IdWorkerPlus生成）
- 边界内：任务元数据、状态、计数
- 边界外：通过bizBillId关联业务单据，通过prnQueueLid关联队列

---

### 1.2 pos_prn_queue（打印队列表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| lid | BIGINT | 队列ID | 全局唯一标识 | PK, NOT NULL | E-004 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL, INDEX | E-004 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL, INDEX | E-004 |
| name | VARCHAR | 队列名称 | 便于识别的显示名称 | NOT NULL | E-004 |
| pcLid | BIGINT | PC终端ID | 本地打印关联 | | E-004 |
| primaryPrinter | VARCHAR | 主打印机 | 逗号分隔的打印机ID列表 | | E-004, E-001:54 |
| standbyPrinter | VARCHAR | 备用打印机 | 逗号分隔的打印机ID列表 | | E-004, E-001:54 |

**值对象分析**：
- primaryPrinter 和 standbyPrinter 是逗号分隔的字符串，不是标准外键
- 需要解析后才能与 pos_prn_printer 建立关联
- 这种设计支持多主打印机配置（逗号分隔多ID）

**聚合根分析**：
- pos_prn_queue 是打印队列的聚合根
- 边界内：队列名称、主备打印机配置
- 边界外：通过 pcLid 关联 PC 终端

---

### 1.3 pos_prn_printer（打印机表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| lid | BIGINT | 打印机ID | 全局唯一标识 | PK, NOT NULL | E-003 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL, INDEX | E-003 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL, INDEX | E-003 |
| name | VARCHAR | 打印机名称 | 便于识别的显示名称 | NOT NULL | E-003 |
| pcLid | BIGINT | PC终端ID | 本地打印关联 | INDEX | E-003 |
| type | VARCHAR | 连接类型 | DRIVER/NET/COM/USB/LPT/CLOUD | NOT NULL | E-003, E-007 |
| model | VARCHAR | 打印机型号 | 决定品牌和协议适配 | | E-003, E-011:36 |
| extraInfo | TEXT | 扩展信息 | 类型相关的配置参数（JSON） | | E-003, E-012 |
| gmtCreate | DATETIME | 创建时间 | 记录创建时间 | | E-003 |
| gmtModified | DATETIME | 修改时间 | 记录更新时间 | | E-003 |

**值对象分析**：
- extraInfo 是 JSON 格式的扩展信息
- 结构根据 type 不同而不同：
  - DRIVER: extraInfoDriver（驱动名称）
  - NET: extraInfoNet（IP、端口、切纸声音）
  - COM: extraInfoCom（串口、BaudRate）
  - 通用: feedLines（进纸行数）

**聚合根分析**：
- pos_prn_printer 是打印机的聚合根
- 边界内：打印机配置、连接参数
- 边界外：通过 type 关联不同的 Handler 实现

---

### 1.4 pos_prn_printer_transfer（打印机转移表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| id | BIGINT | 转移ID | 全局唯一标识 | PK, NOT NULL | E-001:1042 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL, INDEX | E-001:1042 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL, INDEX | E-001:1042 |
| sourcePrinterLid | BIGINT | 源打印机ID | 被重定向的打印机 | NOT NULL | E-001:1042 |
| targetPrinterLid | BIGINT | 目标打印机ID | 重定向目标 | NOT NULL | E-001:1042 |

**领域服务分析**：
- 打印机转移规则由 PosPrnPrinterTransfer 表存储
- 运行时通过查询该表实现动态路由
- 转移规则优先于队列静态配置

---

### 1.5 pos_prn_style_row（打印样式行表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| id | BIGINT | 行ID | 全局唯一标识 | PK | E-010:49 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL | E-010:49 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL | E-010:49 |
| styleType | INT | 样式类型 | 对应 PrnStyleTypeEnum | NOT NULL | E-010:49, E-007 |
| rowIndex | INT | 行号 | 打印行顺序 | NOT NULL | E-010 |
| colIndex | INT | 列号 | 打印列位置 | NOT NULL | E-010 |
| content | TEXT | 内容模板 | 支持{@fieldName}参数替换 | | E-010, E-012 |
| style | VARCHAR | 字体样式 | 加粗/斜体等 | | E-010 |

**值对象分析**：
- content 字段支持参数替换语法：{@fieldName} 和 ${fieldName}
- 由 DriverHandler 在打印时执行参数替换

---

### 1.6 pos_prn_style_col（打印样式列表）

| 字段 | 类型 | 说明 | 业务含义 | 约束 | 证据 |
|------|------|------|---------|------|------|
| id | BIGINT | 列ID | 全局唯一标识 | PK | E-010 |
| mid | BIGINT | 商户ID | 数据隔离边界 | NOT NULL | E-010 |
| sid | BIGINT | 门店ID | 数据隔离边界 | NOT NULL | E-010 |
| styleType | INT | 样式类型 | 对应 PrnStyleTypeEnum | NOT NULL | E-010 |
| colIndex | INT | 列号 | 列位置 | NOT NULL | E-010 |
| width | INT | 列宽 | 字符宽度 | NOT NULL | E-010 |

---

## 二、关键索引

| 索引 | 字段 | 用途 | 证据 |
|------|------|------|------|
| idx_job_mid_sid | mid, sid | 按商户+门店查询任务 | E-002 |
| idx_job_status | status | 按状态查询任务 | E-002 |
| idx_job_queue | prnQueueLid | 按队列查询任务 | E-002 |
| idx_job_biz | bizBillId | 按业务单据查询打印记录 | E-002 |
| idx_job_date | gmtCreate | 按时间范围查询 | E-002 |
| idx_queue_mid_sid | mid, sid | 按商户+门店查询队列 | E-004 |
| idx_printer_mid_sid | mid, sid | 按商户+门店查询打印机 | E-003 |
| idx_printer_pc | pcLid | 按PC终端查询打印机 | E-003 |
| idx_transfer_mid_sid | mid, sid | 按商户+门店查询转移规则 | E-001:1042 |
| idx_transfer_source | sourcePrinterLid | 按源打印机查询转移规则 | E-001:1042 |

---

## 三、数据关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              打印系统数据模型                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐         ┌─────────────────┐                           │
│  │  pos_prn_job    │         │  pos_prn_queue  │                           │
│  ├─────────────────┤         ├─────────────────┤                           │
│  │ PK lid          │         │ PK lid          │                           │
│  │    mid (FK)     │─────────│    mid (FK)     │                           │
│  │    sid (FK)     │         │    sid (FK)     │                           │
│  │    bizBillId    │         │    pcLid        │                           │
│  │    type         │         │    primaryPrint │──┐                        │
│  │    prnQueueLid ──┼─────────│    standbyPrint │──┤ 逗号分隔                │
│  │    prnPrinterLid │         └─────────────────┘  │                        │
│  │    status       │                               │                        │
│  │    print        │                               ▼                        │
│  │    printAt      │                    ┌─────────────────┐                │
│  │    failureReason│                    │  pos_prn_printer │                │
│  └─────────────────┘                    ├─────────────────┤                │
│        │                                │ PK lid          │                │
│        │                                │    mid (FK)     │                │
│        │                                │    sid (FK)     │                │
│        │                                │    name         │                │
│        │                                │    pcLid (FK)   │                │
│        │                                │    type         │                │
│        │                                │    model        │                │
│        │                                │    extraInfo    │                │
│        │                                └─────────────────┘                │
│        │                                       ▲                           │
│        │                                       │                           │
│        ▼                                       │                           │
│  ┌─────────────────┐                           │                           │
│  │pos_prn_printer  │                           │                           │
│  │_transfer        │                           │                           │
│  ├─────────────────┤                           │                           │
│  │ PK id           │                           │                           │
│  │    mid (FK)     │───────────────────────────┘                           │
│  │    sid (FK)     │  sourcePrinterLid ──┐                                │
│  │    sourcePrinter│                      │                                │
│  │    targetPrinter│◄─────────────────────┘                                │
│  └─────────────────┘  targetPrinterLid                                     │
│                                                                             │
│  ┌─────────────────┐         ┌─────────────────┐                           │
│  │pos_prn_style_row│         │pos_prn_style_col│                           │
│  ├─────────────────┤         ├─────────────────┤                           │
│  │ PK id           │         │ PK id           │                           │
│  │    mid (FK)     │         │    mid (FK)     │                           │
│  │    sid (FK)     │         │    sid (FK)     │                           │
│  │    styleType(FK)│◄────────│    styleType(FK)│                           │
│  │    rowIndex     │         │    colIndex     │                           │
│  │    colIndex     │         │    width        │                           │
│  │    content      │         └─────────────────┘                           │
│  │    style        │                                                       │
│  └─────────────────┘                                                       │
│         │                                                                  │
│         │                                                                  │
│         ▼                                                                  │
│  ┌─────────────────┐                                                       │
│  │PrnStyleTypeEnum │ (枚举，非数据库表)                                     │
│  ├─────────────────┤                                                       │
│  │ 业务打印: 10-73 │                                                       │
│  │ WMS打印: 1000+  │                                                       │
│  └─────────────────┘                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 四、数据权威源分析

| 数据类型 | 权威源 | 副本/缓存 | 说明 |
|---------|--------|---------|------|
| 打印任务元数据 | pos_prn_job | 无 | 任务状态、计数、时间 |
| 打印任务内容 | .job文件 | 无 | JSON格式，15分钟过期 |
| 打印次数 | Redis | pos_prn_job.prnCount | Redis失效时回读DB |
| 打印机配置 | pos_prn_printer | 无 | 名称、类型、型号、参数 |
| 队列配置 | pos_prn_queue | 无 | 主备打印机列表 |
| 转移规则 | pos_prn_printer_transfer | 无 | 动态路由映射 |
| 打印样式 | pos_prn_style_row/col | 无 | 按商户+门店+类型加载 |

---

## 五、数据生命周期

### 5.1 打印任务数据流

```
创建
  │
  ├─→ pos_prn_job (INSERT)
  │
  ├─→ {appDir}/jobs/{date}/{lid}.job (WRITE)
  │
  └─→ Redis: count:{lid}=0 (SET with TTL 15min)

分发
  │
  └─→ ActiveMQ (Publish)

执行
  │
  ├─→ PrinterWorkerService (Read .job file)
  │
  └─→ Update pos_prn_job.status + print + printAt

清理（15分钟后）
  │
  └─→ {lid}.job → {lid}.del (RENAME)

清理（30天后）
  │
  └─→ {lid}.del (DELETE)
```

### 5.2 数据保留策略

| 数据类型 | 保留时间 | 清理方式 |
|---------|---------|---------|
| 打印任务记录 | 30天 | 查询时过滤 |
| 打印任务文件(.job) | 15分钟 | 改名为.del |
| 打印任务文件(.del) | 30天 | 物理删除 |
| 打印次数(Redis) | 15分钟 | TTL过期 |
| 打印机配置 | 永久 | 手动删除 |
| 队列配置 | 永久 | 手动删除 |
| 转移规则 | 永久 | 手动删除 |
| 打印样式 | 永久 | 手动删除 |

---

## 六、DA3关系一致性校验

| DA3 REL | 对应表关系 | 一致性 |
|---------|-----------|--------|
| REL-01 打印任务→打印队列 | pos_prn_job.prnQueueLid → pos_prn_queue.lid | ✅ |
| REL-02 打印任务→打印机 | pos_prn_job.prnPrinterLid → pos_prn_printer.lid | ✅ |
| REL-03 打印任务→文件 | lid → {date}/{lid}.job | ✅ |
| REL-04 打印任务→业务单据 | pos_prn_job.bizBillId → 业务单据 | ✅ |
| REL-05 打印队列→打印机 | pos_prn_queue.primary/standby → 逗号分隔lid | ⚠️ 逗号分隔，非标准FK |
| REL-06 转移规则→打印机 | pos_prn_printer_transfer.source/target → lid | ✅ |
| REL-07 样式类型→模板 | pos_prn_style_row.col.styleType → PrnStyleTypeEnum | ✅ |
| REL-09 任务→打印机（3跳） | job→queue→printer 组合路径 | ✅ |

---

## 七、未知项（U-*）

| 编号 | 描述 | 影响 | 关闭条件 |
|------|------|------|---------|
| U-001 | .job文件内容的JSON Schema未详细分析 | 重打功能 | 读取实际文件内容 |
| U-002 | extraInfo各type的完整Schema未详细分析 | 打印机配置 | 读取extraInfo样本 |
| U-003 | 逗号分隔打印ID的解析逻辑和选择策略未详细分析 | 路由选择 | 分析源码 |

---

## 八、模板字段对照表

| 模板要求字段 | 实际输出位置 | 状态 |
|-------------|-------------|------|
| 核心表结构 | §1 | ✅ |
| pos_prn_job | §1.1 | ✅ |
| pos_prn_queue | §1.2 | ✅ |
| pos_prn_printer | §1.3 | ✅ |
| pos_prn_printer_transfer | §1.4 | ✅ |
| pos_prn_style_row | §1.5 | ✅ |
| pos_prn_style_col | §1.6 | ✅ |
| 聚合根/值对象分析 | §1 每表 | ✅ |
| 关键索引 | §2 | ✅ |
| 数据关系图 | §3 | ✅ |
| 数据权威源 | §4 | ✅ |
| 数据生命周期 | §5 | ✅ |
| DA3关系一致性 | §6 | ✅ |
| 未知项（U-*） | §7 | ✅ |
| E-* 证据 | 每表每字段 | ✅ |

**全面性检查**：
- [x] 覆盖全部核心表（6张）
- [x] 每个字段标注业务含义与约束
- [x] 数据关系图与DA3的REL关系一致
- [x] 包含聚合根/值对象/领域服务分析
- [x] 关键索引覆盖查询场景
- [x] 数据权威源分析完整

---

**DA5数据模型完成时间**：2026-08-05
**分析人**：AI
**状态**：✅ 完成，进入DA6阶段
