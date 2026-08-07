# DA7 - 实现映射

> 阶段：DA7 实现映射
> 目标系统：打印系统
> 日期：2026-08-04
> 状态：✅ 分析完成

---

## 1. 概述

本文档建立从业务概念到代码实现的映射关系，便于定位具体实现位置。

---

## 2. 核心模块分布

### 2.1 模块归属

| 模块 | 职责 | 代码路径 |
|------|------|----------|
| nms4cloud-pos-dal | 数据访问层、Entity、Mapper | `nms4pos/nms4cloud-pos-dal/` |
| nms4cloud-pos2plugin-dal | 插件数据访问层 | `nms4pos/nms4cloud-pos2plugin-dal/` |
| nms4cloud-pos2plugin-api | 枚举、接口定义 | `nms4pos/nms4cloud-pos2plugin-api/` |
| nms4cloud-pos2plugin-biz | 业务逻辑层 | `nms4pos/nms4cloud-pos2plugin-biz/` |
| nms4cloud-pos3boot | 启动服务、PrinterWorker | `nms4pos/nms4cloud-pos3boot/` |
| nms4cloud-pos4cloud | 云端接口 | `nms4pos/nms4cloud-pos4cloud/` |

### 2.2 包结构

```
com.nms4cloud.pos
├── dal/
│   ├── mapper/pos/         # pos_prn_job, pos_prn_style
│   └── mapper/plugin/      # pos_prn_printer, pos_prn_queue
├── entity/
│   ├── pos/                # PosPrnJob, PosPrnStyle
│   └── plugin/             # PosPrnPrinter, PosPrnQueue, PosPrnStyleRow
├── service/
│   └── pos/                # PrintJobGenerator, PosPrnJobService
└── service/plugin/
    └── printer/            # PrinterWorker, HandlerFactory

com.nms4cloud.pos4cloud
├── controller/
│   └── PosPrnJobController.java
└── service/
    └── PosPrnJobServicePlus.java
```

---

## 3. 实体与表映射

### 3.1 打印任务

| 概念 | 实现 | 代码位置 |
|------|------|----------|
| 实体类 | `PosPrnJob` | `nms4cloud-pos-dal/.../entity/pos/` |
| Mapper | `PosPrnJobMapper` | `nms4cloud-pos-dal/.../mapper/pos/` |
| Service | `PosPrnJobService` | `nms4cloud-pos-dal/.../service/pos/` |
| 云端Service | `PosPrnJobServicePlus` | `nms4cloud-pos4cloud-biz/` |

### 3.2 打印机

| 概念 | 实现 | 代码位置 |
|------|------|----------|
| 实体类 | `PosPrnPrinter` | `nms4cloud-pos2plugin-dal/.../entity/` |
| Mapper | `PosPrnPrinterMapper` | `nms4cloud-pos2plugin-dal/.../mapper/` |

### 3.3 打印队列

| 概念 | 实现 | 代码位置 |
|------|------|----------|
| 实体类 | `PosPrnQueue` | `nms4cloud-pos2plugin-dal/.../entity/` |
| Mapper | `PosPrnQueueMapper` | `nms4cloud-pos2plugin-dal/.../mapper/` |

### 3.4 打印样式

| 概念 | 实现 | 代码位置 |
|------|------|----------|
| 实体类 | `PosPrnStyle` | `nms4cloud-pos-dal/.../entity/pos/` |
| 实体类 | `PosPrnStyleRow` | `nms4cloud-pos2plugin-dal/.../entity/` |
| Mapper | `PosPrnStyleMapper` | `nms4cloud-pos-dal/.../mapper/pos/` |
| Mapper | `PosPrnStyleRowMapper` | `nms4cloud-pos2plugin-dal/.../mapper/` |

---

## 4. 枚举映射

### 4.1 打印机类型

| 枚举 | 实现 | Code | 说明 |
|------|------|------|------|
| PrinterTypeEnum.DRIVER | `DriverHandler` | 1 | Windows 驱动 |
| PrinterTypeEnum.NET | `PortHandler` | 2 | 网口 |
| PrinterTypeEnum.COM | `PortHandler` | 3 | 串口 |
| PrinterTypeEnum.USB | `UsbLptHandler` | 4 | USB |
| PrinterTypeEnum.LPT | `UsbLptHandler` | 5 | 并口 |
| PrinterTypeEnum.XY_CLOUD | `XpCloudPrinter` | 6 | 芯烨云 |
| PrinterTypeEnum.JB_CLOUD | `JBCloudPrinter` | 7 | 佳博云 |
| PrinterTypeEnum.DRIVER_CMD | 混合模式 | 8 | 驱动+指令 |

### 4.2 打印样式类型

| 枚举 | Code | 说明 | 典型场景 |
|------|------|------|----------|
| PrnStyleTypeEnum.OrderMenu | 10 | 点菜单 | 厨房接单 |
| PrnStyleTypeEnum.CheckOut | 26 | 结账单 | 收银小票 |
| PrnStyleTypeEnum.FoodLabel | 52 | 标签单 | 菜品标签 |
| PrnStyleTypeEnum.ShiftReport | 29 | 交班单 | 账务汇总 |
| PrnStyleTypeEnum.MemberSavingBill | 39 | 会员充值单 | 充值凭证 |

---

## 5. 核心类实现

### 5.1 打印任务生成

| 类 | 行数 | 职责 | 关键方法 |
|---|------|------|----------|
| `PrintJobGenerator` | 1127 | 生成各类打印任务 | `generateCustomerJob()`, `generateKitchenJob()`, `generateWaiterJob()` |
| `PosPrnJobService` | - | 打印任务服务 | `generateJob()` |

### 5.2 打印任务执行

| 类 | 行数 | 职责 | 关键方法 |
|---|------|------|----------|
| `BlockQueueHandler` | ~100 | 队列抽象基类 | `put()`, `take()`, `run()` |
| `PrinterWorker` | ~250 | 打印执行器 | `runInner()`, 状态检查, 超时处理 |
| `HandlerFactory` | - | Handler工厂 | `getHandler()` |

### 5.3 Handler 实现

| 类 | 对应类型 | 说明 |
|---|---------|------|
| `DriverHandler` | DRIVER (1) | Windows 驱动打印 |
| `PortHandler` | NET (2), COM (3) | 端口打印 |
| `UsbLptHandler` | USB (4), LPT (5) | USB/LPT打印 |
| `JBCloudPrinter` | JB_CLOUD (7) | 佳博云打印 |
| `XpCloudPrinter` | XY_CLOUD (6) | 芯烨云打印 |
| `HanYinPrinter` | 汉印 | 汉印打印机 |

---

## 6. API 接口映射

### 6.1 云端接口

| 接口 | 方法 | Controller | Service | 说明 |
|------|------|------------|---------|------|
| `/api/pos4cloud/pos_prn_job/reprint` | POST | PosPrnJobController | PosPrnJobServicePlus | 重打 |
| `/api/pos4cloud/pos_prn_job/list` | POST | PosPrnJobController | PosPrnJobServicePlus | 任务列表 |
| `/api/pos4cloud/pos_prn_job/xxx` | ... | PosPrnJobController | PosPrnJobServicePlus | 其他操作 |

### 6.2 网关路由

```
/api/pos4cloud/** → nms4cloud-pos4cloud 服务
                    → nms4pos/nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/
```

---

## 7. 关键代码位置速查

### 7.1 按功能查找

| 功能 | 文件 | 关键行 |
|------|------|--------|
| 打印任务生成入口 | `PrintJobGenerator.java` | 全文 1127 行 |
| 任务状态枚举 | `PrnJobStatusEnum.java` | 全文 |
| 队列阻塞模式 | `BlockQueueHandler.java` | `take()` 调用 |
| 超时判断 | `PrinterWorker.java` | 约 180 行 |
| 重试延迟 | `PrinterWorker.java` | 约 196-197 行 |
| 打印机状态检查 | `PrinterWorker.java` | `getPrinterStatus()` |
| 重打接口 | `PosPrnJobController.java` | `@PostMapping("/reprint")` |
| Handler工厂 | `HandlerFactory.java` | `getHandler()` |

### 7.2 按文件类型查找

| 类型 | 路径模式 | 示例 |
|------|---------|------|
| Entity | `**/entity/**/*.java` | `PosPrnJob.java` |
| Mapper | `**/mapper/**/*.java` | `PosPrnJobMapper.java` |
| Service | `**/service/**/*.java` | `PrintJobGenerator.java` |
| Controller | `**/controller/**/*.java` | `PosPrnJobController.java` |
| Handler | `**/handler/**/*.java` | `DriverHandler.java` |

---

## 8. 代码行数统计

| 文件 | 行数 | 复杂度 |
|------|------|--------|
| PrintJobGenerator.java | 1127 | 高 |
| PrinterWorker.java | ~250 | 中 |
| BlockQueueHandler.java | ~100 | 低 |
| HandlerFactory.java | - | 低 |
| PosPrnJobController.java | ~200 | 低 |

---

## 9. 依赖关系

```
┌─────────────────────────────────────────────────────────────────┐
│                        代码依赖关系                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PosPrnJobController (云端接口)                                │
│        │                                                        │
│        ▼                                                        │
│   PosPrnJobServicePlus (云端服务)                               │
│        │                                                        │
│        ├──────────────────┐                                     │
│        ▼                  ▼                                     │
│   PosPrnJobService   BlockQueueHandler                          │
│        │                  │                                     │
│        ▼                  │                                     │
│   PrintJobGenerator       │                                     │
│        │                  │                                     │
│        ▼                  ▼                                     │
│   PosPrnJobMapper    PrinterWorker                              │
│        │                  │                                     │
│        ▼                  ▼                                     │
│   PosPrnJob (Entity)  HandlerFactory                            │
│                              │                                  │
│         ┌────────────────────┼────────────────────┐            │
│         ▼                    ▼                    ▼            │
│    DriverHandler       PortHandler        JBCloudPrinter       │
│         │                    │                    │            │
│         └────────────────────┼────────────────────┘            │
│                              ▼                                  │
│                         底层打印实现                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

**DA7 实现映射分析完成。**
