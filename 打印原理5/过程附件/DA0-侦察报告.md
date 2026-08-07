# DA0 - 侦察报告

> 阶段：DA0 侦察报告
> 目标系统：打印系统
> 日期：2026-08-04
> 状态：✅ 侦察完成

---

## 1. 侦察目标

对打印系统进行初步侦察，建立证据基线，为后续 DA1-DA8 阶段分析提供结构化输入。

---

## 2. 侦察范围

### 2.1 涉及的代码仓库

| 仓库 | 主要贡献 |
|------|---------|
| `D:\mywork\nms4pos` | 打印核心业务（PosPrnJobServicePlus、PrintJobGenerator）、打印处理器（DriverHandler、PortHandler、云打印机）、PrinterWorker |
| `D:\mywork\nms4cloud` | POS 公共模块、枚举定义（PrnJobStatusEnum、PrinterTypeEnum 等） |
| `D:\mywork\nms4cloud-biz-ui` | 打印管理后台（PrintMgr 页面） |
| `D:\mywork\nms4pos-ui` | POS 前端打印监控 |

### 2.2 侦察的代码层级

```
[前端层] PrintMgr 页面 / PrintTaskMonitor 页面
    ↓ API 调用
[服务层] PosPrnJobServicePlus (打印任务服务)
    ↓ 任务生成
[业务层] PrintJobGenerator (任务生成器)
    ↓ 样式渲染
[处理器层] PrintJobHandlerBase / DriverHandler / PortHandler / 云打印机
    ↓ 硬件交互
[设备层] 打印机硬件
```

---

## 3. 核心发现

### 3.1 系统架构

**关键发现：打印系统采用三层架构**

```
┌─────────────────────────────────────────────────────────────┐
│                     打印任务生成层                            │
│  PrintJobGenerator: 根据订单类型生成顾客联/厨房联/传菜联        │
│  - generateCustomerJob()    顾客联                           │
│  - generateKitchenJob()     厨房联                           │
│  - generateWaiterJob()      传菜联                           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     打印任务管理层                             │
│  PosPrnJobServicePlus: 任务持久化与状态管理                    │
│  - create()         创建任务，DB + 文件双存储                   │
│  - markFailed()     标记失败                                 │
│  - reprint()        重打逻辑                                 │
│  - keepToFile()     文件缓存                                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     打印执行层                               │
│  PrinterWorker: 按打印机类型选择 Handler                       │
│  BlockQueueHandler: 阻塞队列，任务堆积时等待                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Handler 工厂（按 PrinterTypeEnum 选择）                   │ │
│  │ - DRIVER     → GraphicsHandler (Windows图形)            │ │
│  │ - DRIVER_CMD → PortHandlerWithDriver                    │ │
│  │ - NET/COM/USB/LPT → PortHandler (ESC/POS)              │ │
│  │ - GP_3150TFN → JBTagPrinter (标签机)                    │ │
│  │ - XP_T202UA  → XYTagPrinter (标签机)                    │ │
│  │ - XY_CLOUD   → XpCloudPrinter (芯烨云)                  │ │
│  │ - JB_CLOUD   → JBCloudPrinter (佳博云)                  │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**证据：**
- `PrinterWorker.java:28-51` - Handler 工厂逻辑
- `PrintJobHandlerBase.java:335-355` - PrinterType → PrinterType 映射

### 3.2 核心实体

**BR-001：打印任务（PosPrnJob）**

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 雪花算法逻辑编号 |
| bizBillId | BIGINT | 关联业务单据 ID |
| type_ | PrnStyleTypeEnum | 样式类型（点菜单/结账单/厨房联...） |
| purpose | PrnJobPurposeEnum | 用途（厨房联/划菜联/楼面联） |
| prnCount | INT | 打印份数 |
| prnQueueLid | BIGINT | 打印队列 LID |
| prnPrinterLid | BIGINT | 指定打印机 LID |
| status | PrnJobStatusEnum | 状态（待打印/成功/失败） |
| print | TEXT | 打印内容（JSON） |
| printAt | DATETIME | 打印时间 |
| failureReason | VARCHAR | 失败原因 |

**证据：**
- 源码位置：`PosPrnJob.java`（待补充完整路径）
- 表结构：E-DAT 待补充

**BC-001：打印机（PosPrnPrinter）**

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 逻辑编号 |
| name | VARCHAR | 打印机名称 |
| pcLid | BIGINT | 关联 PC LID |
| type | PrinterTypeEnum | 连接类型 |
| model | PrinterModelEnum | 打印机型号 |
| extraInfo | JSON | 连接参数（Driver名/端口/IP等） |

**证据：**
- `PrinterWorker.java:21-52` - 使用 printer.exInfo* 获取连接参数
- `PrintJobHandlerBase.java:372-395` - getPhysicsName/getComName/getBaudRate

**BC-002：打印队列（PosPrnQueue）**

| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 逻辑编号 |
| name | VARCHAR | 队列名称 |
| pcLid | BIGINT | 关联 PC LID |
| primaryPrinter | VARCHAR | 主打印机 LID（逗号分隔） |
| standbyPrinter | VARCHAR | 备用打印机 LID（逗号分隔） |

**关键发现：主备打印机以逗号分隔字符串存储**

### 3.3 打印样式系统

**BC-003：打印样式行（PosPrnStyleRow）**

| 字段 | 说明 |
|------|------|
| dsId | 数据源 ID |
| styleType | 样式类型 |
| showIndex | 显示顺序 |
| displayCondition | 显示条件 |
| conditionDsId | 条件数据源 ID |
| conditionOperator | 条件操作符（>/=/</<>） |
| conditionValue | 条件值 |
| summarize | 是否汇总 |
| summarizeColName | 汇总列名 |

**关键发现：条件打印使用 DSL 语法**
```
格式：{@fieldName} operator value
示例：{@totalAmount} > 100
```

**证据：**
- `PrintJobHandlerBase.java:193-297` - isConditionOk 条件判断
- 支持操作符：`>`, `=`, `<>`, `<`
- 支持类型：BigDecimal、Integer、Boolean、String

### 3.4 打印联分类

**PrnJobPurposeEnum（三联打印体系）：**

| 枚举值 | 说明 | 代码路径 |
|--------|------|---------|
| FOR_KITCHEN | 厨房联 | generateKitchenJob() |
| FOR_DISH_DELIVERER | 划菜联（传菜联） | generateWaiterJob() |
| FOR_CUSTOMER | 楼面联（顾客联） | generateCustomerJob() |

**证据：**
- `PrintJobGenerator.java` - 三个核心方法
- `PrnJobPurposeEnum.java` - 枚举定义

### 3.5 打印样式类型

**PrnStyleTypeEnum（130+ 种样式）：**

| 分类 | 示例 | 用途 |
|------|------|------|
| 订单类 | OrderMenu, CheckOut, TotalBill | 点餐、结账 |
| 厨房类 | FoodLabel, HurryMenu, BackMenu | 厨房制作 |
| 报表类 | ShiftReport, YingYeReport | 交班、营业 |
| WMS类 | WMS_ST_BILL_* (50+ 种) | 仓储单据 |
| 短信类 | SMS_* (20+ 种) | 短信凭证 |

**证据：**
- `PrnStyleTypeEnum.java:19-131` - 完整枚举定义

---

## 4. 关键交互路径

### 4.1 打印任务生命周期

```
[订单创建/结账] → PrintJobGenerator.generate*()
    ↓
[PosPrnJobServicePlus.create()]
    ├→ [DB: pos_prn_job INSERT]
    └→ [File: keepToFile()]
    ↓
[PrinterWorker.put(jobLid)] → [BlockQueueHandler.offer()]
    ↓
[PrinterWorker.run()] ← [阻塞等待]
    ↓
[PrinterWorker.runInner(jobLid)]
    ├→ [PrinterWorkerService.get(jobLid)] → 获取打印数据
    ├→ [handler.handle(job)] → 执行打印
    └→ [printerWorkerService.rmv(jobLid)] → 删除任务
    ↓
[失败重试] → [sleep(10s)] → [put(jobLid)] 循环
```

**证据：**
- `PrinterWorker.java:55-76` - runInner 完整逻辑

### 4.2 任务状态流转

```
PENDING(1) ────打印成功────→ SUCCESS(2)
    │                          ↑
    │                          │ reprint()
    │                          │
    └──────打印失败──────→ FAILED(3)
              │
              └──────重试──────┘
```

**证据：**
- `PrnJobStatusEnum.java` - 状态枚举
- `PrinterWorker.java:55-76` - 状态驱动逻辑

### 4.3 打印机状态监控

```
PrinterStatus:
  - NORMAL  正常
  - FAULT   故障
  - BUSY    忙碌
```

**证据：**
- `PrintJobHandlerBase.java:300-304` - 枚举定义
- `PrinterWorker.java:56-62` - 状态检查

---

## 5. 侦察结论

### 5.1 系统规模评估

| 维度 | 评估 |
|------|------|
| 核心服务类 | 10+ 个 |
| 打印 Handler | 8 种（Driver/Port/USB/LPT/云打印/标签机） |
| 样式类型 | 130+ 种 |
| 代码行数 | 估计 5000+ 行（不含前端） |
| 数据库表 | 6+ 张（job/printer/queue/style等） |

### 5.2 架构特征

| 特征 | 评估 |
|------|------|
| 分层清晰度 | ⭐⭐⭐⭐ 业务层/服务层/处理器层分离 |
| 扩展性 | ⭐⭐ 主备机硬编码，新型号需改代码 |
| 可维护性 | ⭐⭐⭐ Handler 过长，部分代码重复 |
| 可靠性 | ⭐⭐⭐ 文件+DB 双存储，但一致性机制待验证 |

### 5.3 侦察产物

| 产物 | 数量 |
|------|------|
| 核心实体 | 4 个 |
| 核心枚举 | 5 个 |
| Handler 类型 | 8 种 |
| 业务流程 | 3 个（生成/管理/执行） |

---

## 6. 下一步行动

### 6.1 DA1 业务切面分析

**切面清单：**
1. 任务生成切面（PrintJobGenerator）
2. 任务管理切面（PosPrnJobServicePlus）
3. 任务执行切面（PrinterWorker + Handlers）
4. 样式渲染切面（PrintJobHandlerBase）
5. 状态监控切面（PrintJobMonitor）

### 6.2 待补充证据

| 证据 | 优先级 | 说明 |
|------|--------|------|
| 数据库表结构 | P1 | pos_prn_job 等表 DDL |
| 前端代码 | P2 | PrintMgr 页面逻辑 |
| 枚举值映射 | P2 | PrinterModelEnum 完整定义 |
| 配置文件 | P3 | 打印相关配置 |

---

**DA0 侦察阶段完成。**
