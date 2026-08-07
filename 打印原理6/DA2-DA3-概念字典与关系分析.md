# DA2-DA3 概念字典与关系分析

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | 打印相关模块 |
| 分析时间 | 2026-08-04 |

---

## 一、核心概念字典

### 1.1 打印机（PosPrnPrinter）

| 字段 | 类型 | 说明 |
|---|---|---|
| `lid` | Long | 唯一标识 |
| `mid/sid` | Long | 商户/门店ID |
| `name` | String | 打印机名称 |
| `type` | PrinterType | 连接类型（NET/COM/USB/Driver/Cloud） |
| `model` | PrinterModelEnum | 型号 |
| `extraInfo` | String | 连接参数（IP/端口/串口配置） |
| `pcLid` | Long | 绑定的PC终端ID（-1表示通用） |
| `status` | PrinterStatus | 当前状态 |

**概念定义：** 代表一个物理打印机或云打印服务，是打印任务执行的最终载体。

### 1.2 打印队列（PosPrnQueue）

| 字段 | 类型 | 说明 |
|---|---|---|
| `lid` | Long | 唯一标识 |
| `mid/sid` | Long | 商户/门店ID |
| `name` | String | 队列名称（如"后厨队列"、"前台队列"） |
| `primaryPrinter` | String | 主打印机LID列表（逗号分隔） |
| `standbyPrinter` | String | 备用打印机LID列表（逗号分隔） |
| `pcLid` | Long | 绑定的PC终端ID |

**概念定义：** 打印任务的路由配置单元，定义了哪些打印机可以处理特定类型的打印任务。

### 1.3 打印任务（PosPrnJob）

| 字段 | 类型 | 说明 |
|---|---|---|
| `lid` | Long | 唯一标识 |
| `bizBillId` | String | 关联的业务单据ID |
| `type` | PrnStyleTypeEnum | 打印类型（点菜单/结账单等） |
| `purpose` | PrnJobPurposeEnum | 用途（厨房联/划菜联/楼面联） |
| `prnQueueLid` | Long | 所属打印队列 |
| `prnPrinterLid` | Long | 分发的目标打印机 |
| `prnCount` | Integer | 已打印次数（>0表示补打） |
| `print` | Boolean | 是否已完成打印 |
| `status` | PrnJobStatusEnum | 任务状态 |
| `failureReason` | String | 失败原因 |

**概念定义：** 一次具体的打印操作请求，包含打印内容和关联的业务上下文。

### 1.4 打印样式（PosPrnStyleRow / PosPrnStyleCol）

**PosPrnStyleRow（行配置）**
| 字段 | 类型 | 说明 |
|---|---|---|
| `styleType` | PrnStyleTypeEnum | 适用的打印类型 |
| `showIndex` | Integer | 显示顺序 |
| `displayCondition` | String | 显示条件表达式 |
| `summarize` | Boolean | 是否汇总 |
| `summarizeColName` | String | 汇总列名 |

**PosPrnStyleCol（列配置）**
| 字段 | 类型 | 说明 |
|---|---|---|
| `width80` | Integer | 宽度占比（80mm纸） |
| `align` | PrnStypeAlignEnum | 对齐方式 |
| `bold` | Boolean | 是否加粗 |
| `fontSize` | PrnStyleFontSizeEnum | 字号 |
| `color` | String | 颜色（RED/BLACK） |
| `type` | PrnStyleColTypeEnum | 内容类型（TEXT/BAR_CODE/QR_CODE/IMG） |
| `customizedContent` | String | 格式化内容（JSON数组） |

**概念定义：** 打印样式定义了在特定纸张宽度下的内容布局规则，支持条件显示和样式控制。

### 1.5 转发规则（PosPrnPrinterTransfer）

| 字段 | 类型 | 说明 |
|---|---|---|
| `sourcePrinterLid` | Long | 源打印机 |
| `targetPrinterLid` | Long | 目标打印机 |

**概念定义：** 当源打印机故障时，Pending任务自动重定向到目标打印机。

---

## 二、关系类型分析

### 2.1 结构关系（Composition）

```
PosPrnStyleRow
    └── PosPrnStyleCol[]（1:N）

PosPrnQueue
    └── PosPrnPrinter[]（1:N，主+备）
```

### 2.2 轨迹关系（Trajectory）

```
业务单据创建
    ↓ submit
PosPrnJob.create() → PENDING
    ↓ init
PosPrnQueue.initJob() → 加载打印样式
    ↓ dispatch
PosPrnQueue.dispatchJob() → 分发到打印机
    ↓ handle
PrinterWorker.run() → SUCCESS/FAILED
    ↓ remove
PosPrnJob.archive → 归档
```

### 2.3 归属关系（Attribution）

```
PosPrnJob → PosPrnQueue（通过prnQueueLid）
PosPrnJob → PosPrnPrinter（通过prnPrinterLid）
PosPrnQueue → PosPrnPrinter（通过primaryPrinter/standbyPrinter）
PosPrnPrinterTransfer → PosPrnPrinter × 2（source + target）
```

---

## 三、关键关联图

### 3.1 打印任务生命周期关联

```
┌─────────────┐    creates    ┌─────────────┐
│  业务单据    │─────────────→│ PosPrnJob   │
└─────────────┘              └──────┬──────┘
                                   │ belongs to
                                   ↓
┌─────────────┐    routes    ┌─────────────┐
│ PosPrnQueue │←────────────│             │
└──────┬──────┘              │             │
       │ selects              │             │
       ├────────────────────→│ PosPrnPrinter│
       │（primary/standby）   │ (Printer)   │
       │                      └─────────────┘
       │ references
       ↓
┌─────────────┐    applies    ┌─────────────┐
│PosPrnStyle  │─────────────→│ PrnJob.rows │
│(Template)   │              │ (Rendered)  │
└─────────────┘              └─────────────┘
```

### 3.2 故障重定向关联

```
PrinterWorker (Printer=FAULT)
       │
       │ detects
       ↓
PosPrnPrinterTransfer.resolveTargets()
       │
       │ maps
       ↓
PrinterWorker (targetPrinter) ← receives redirected job
```

---

## 四、概念同名异义识别

| 概念 | 在本模块 | 潜在混淆 |
|---|---|---|
| `PrinterBrand` | 枚举值定义（废弃） | 与 PrinterModelEnum 重复 |
| `PrinterType` | 连接类型（NET/COM/USB/Driver/Cloud） | 前端可能有不同定义 |
| `prnCount` | 已打印次数 | 非打印份数 |

---

## 五、关系完整性约束

### 5.1 必须存在的关联
- `PosPrnJob.prnQueueLid` 必须指向存在的 `PosPrnQueue`
- `PosPrnQueue.primaryPrinter` 列表中的每个LID必须指向存在的 `PosPrnPrinter`

### 5.2 可选存在的关联
- `PosPrnQueue.standbyPrinter` 可以为空（无备用）
- `PosPrnPrinterTransfer.sourcePrinter` 可以没有对应的转发规则

### 5.3 业务约束
- `PosPrnQueue.primaryPrinter` 和 `standbyPrinter` 中不能有重复的打印机LID
- `PosPrnPrinterTransfer.source` 和 `target` 不能相同
- 目标打印机必须是 `NORMAL` 状态才能接收转发任务

---

## DA2-DA3 结论

**核心概念：5个**（Printer/Queue/Job/Style/Transfer）
**关系类型：3种**（结构/轨迹/归属）
**关键约束：3条**（关联完整性/业务约束）

---

## G0-C 门禁结论：通过

概念字典和关系分析已完成，关键约束已识别，可进入 DA4 规则分析。
