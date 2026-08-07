# DA3 - 关系分析

> 阶段：DA3 关系分析
> 目标系统：打印系统
> 日期：2026-08-04
> 状态：✅ 分析完成

---

## 1. 概述

本文档分析打印系统内部实体间的关系，以及与外部系统的交互关系。

---

## 2. 核心关系矩阵

### 2.1 实体关系

| 关系 ID | 关系 | 源实体 | 目标实体 | 基数 | 说明 |
|---------|------|--------|---------|------|------|
| REL-001 | 关联队列 | PosPrnJob | PosPrnQueue | N:1 | 任务属于哪个队列 |
| REL-002 | 指定打印机 | PosPrnJob | PosPrnPrinter | N:1 | 可指定具体打印机 |
| REL-003 | 关联样式 | PosPrnJob | PosPrnStyle | N:1 | 任务使用哪种样式 |
| REL-004 | 主备关系 | PosPrnQueue | PosPrnPrinter | 1:N | 队列包含多台打印机 |
| REL-005 | 样式行关联 | PosPrnStyle | PosPrnStyleRow | 1:N | 样式包含多行 |
| REL-006 | 数据源关联 | PosPrnStyleRow | 数据源 | N:1 | 行从哪个数据源取数 |

---

## 3. 实体关系详解

### 3.1 任务-队列关系

**REL-001：打印任务与打印队列**

```
PosPrnJob ──prnQueueLid──→ PosPrnQueue
```

| 字段 | 类型 | 说明 |
|------|------|------|
| prnQueueLid | BIGINT | 外键指向队列 |

**关键发现：**
- 任务通过队列间接关联打印机
- 一个队列可包含多台打印机（主+备）

### 3.2 任务-打印机关系

**REL-002：打印任务与打印机**

```
PosPrnJob ──prnPrinterLid──→ PosPrnPrinter
```

| 字段 | 类型 | 说明 |
|------|------|------|
| prnPrinterLid | BIGINT | 可选，直接指定打印机 |

**关键发现：**
- `prnPrinterLid` 为可选字段
- 为空时按队列选择打印机

### 3.3 队列-打印机关系

**REL-003：打印队列与打印机**

```
PosPrnQueue ──主备打印机列表──→ PosPrnPrinter[]
```

**存储方式：**
```java
primaryPrinter: "lid1,lid2,lid3"  // 逗号分隔字符串
standbyPrinter: "lid4"            // 逗号分隔字符串
```

**关键发现：**
- 主备打印机以逗号分隔 LID 字符串存储
- 实现一对多关系

### 3.4 任务-样式关系

**REL-004：打印任务与打印样式**

```
PosPrnJob ──type_──→ PrnStyleTypeEnum ──样式定义──→ PosPrnStyle
```

**关键发现：**
- 任务通过 `type_` 字段关联样式
- 样式在打印时动态加载

---

## 4. 外部系统关系

### 4.1 上游依赖

```
┌─────────────────────────────────────────────────────────────────┐
│                         上游业务系统                               │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ↓                    ↓                    ↓
    ┌─────────┐         ┌─────────┐         ┌─────────┐
    │ POS订单  │         │ KDS厨房  │         │ WMS仓储  │
    └────┬────┘         └────┬────┘         └────┬────┘
         │                   │                   │
         └───────────────────┼───────────────────┘
                             ↓
                    [打印任务生成]
                    PrintJobGenerator
```

| 上游系统 | 触发事件 | 打印联 | 代码位置 |
|---------|---------|--------|---------|
| POS 点餐 | 加菜 | 厨房联 | PrintJobGenerator.generateKitchenJob() |
| POS 结账 | 支付成功 | 顾客联 | PrintJobGenerator.generateCustomerJob() |
| KDS 划菜 | 菜品完成 | 传菜联 | PrintJobGenerator.generateWaiterJob() |
| WMS | 入库/出库 | WMS单据 | WMS_ST_BILL_* 样式 |

### 4.2 下游依赖

```
[打印执行]
PrinterWorker
       │
       ├─→ Windows 驱动 (GraphicsHandler)
       ├─→ 串口协议 (PortHandler)
       ├─→ USB 协议 (UsbLptHandler)
       ├─→ 芯烨云 API (XpCloudPrinter)
       ├─→ 佳博云 API (JBCloudPrinter)
       └─→ 标签打印机 (JBTagPrinter/XYTagPrinter)
```

| 下游组件 | 协议/接口 | 说明 |
|---------|----------|------|
| Windows 驱动 | GDI | 通过 Java AWT 绘图 |
| 串口打印机 | ESC/POS | RS232 串口通信 |
| USB 打印机 | ESC/POS | USB 直连 |
| 芯烨云 | HTTP REST API | 云端打印 |
| 佳博云 | HTTP REST API | 云端打印 |

---

## 5. 数据流关系

### 5.1 任务生命周期数据流

```
[业务事件]
    ↓ 触发
[PrintJobGenerator] ──生成任务──→ [PosPrnJobServicePlus]
    ↓                                       ↓
  业务数据                           ┌─────┴─────┐
                                    ↓           ↓
                              [数据库]      [文件]
                           pos_prn_job   print_jobs/
                                    ↓           ↓
                              [PrinterWorker]
                                    ↓
                              [PrintJobHandler]
                                    ↓
                              [打印机硬件]
```

### 5.2 样式渲染数据流

```
[打印样式定义]
  PosPrnStyle
      │
      ↓
[样式行列表]
  PosPrnStyleRow[]
      │
      ↓
[数据源参数]
  Map<String, Object> allParas
      │
      ├→ {@tableName}  → "A01"
      ├→ {@totalAmount} → 158.00
      └→ {@foodList}    → [...]
      │
      ↓
[条件判断] ──不满足──→ [跳过该行]
      │
      ↓
[参数替换]
  "桌号: {@tableName}" → "桌号: A01"
      │
      ↓
[最终内容]
  Prn_PrintJobItem
```

---

## 6. 索引关系

### 6.1 核心查询索引

| 表 | 索引 | 用途 |
|---|------|------|
| pos_prn_job | idx_mid_sid | 商户门店查询 |
| pos_prn_job | idx_bizBillId | 按业务单据查询 |
| pos_prn_job | idx_status | 按状态查询待打印任务 |
| pos_prn_job | idx_prnQueueLid | 按队列查询任务 |
| pos_prn_queue | idx_mid_sid | 商户门店查询队列 |
| pos_prn_printer | idx_mid_sid | 商户门店查询打印机 |

---

## 7. 关系图

```
┌──────────────────────────────────────────────────────────────────┐
│                         打印系统全景                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ POS订单   │    │ KDS厨房   │    │ WMS仓储   │    │ CRM会员   │  │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘  │
│       │               │               │               │         │
│       └───────────────┼───────────────┼───────────────┘         │
│                       ↓                                       │
│              ┌────────────────┐                               │
│              │ PrintJobGenerator │ ← 任务生成                   │
│              └────────┬───────┘                               │
│                       ↓                                       │
│              ┌────────────────┐                               │
│              │PosPrnJobService│ ← 任务管理（DB+File）          │
│              └────────┬───────┘                               │
│                       ↓                                       │
│              ┌────────────────┐                               │
│              │ PrinterWorker   │ ← 任务分发                     │
│              └────────┬───────┘                               │
│                       ↓                                       │
│    ┌──────────────────┼──────────────────┐                     │
│    ↓                  ↓                  ↓                     │
│ ┌──────┐         ┌──────┐         ┌──────┐                   │
│ │Driver│         │ Port │         │ Cloud │                   │
│ │Handler│         │Handler│        │Printer│                   │
│ └──┬───┘         └──┬───┘         └──┬───┘                   │
│    └───────┬─────────┘                │                       │
│            ↓                           ↓                       │
│      ┌─────────┐               ┌─────────┐                  │
│      │打印机硬件│               │云服务商API│                  │
│      └─────────┘               └─────────┘                  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

**DA3 关系分析完成。**
