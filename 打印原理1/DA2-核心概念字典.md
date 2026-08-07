# DA2 - 核心概念字典

> **SOP-00 §DA2 执行记录**
> 定义打印系统所有核心概念，建立统一术语

---

## 一、基础概念

### 1.1 打印任务 (PrintJob)

**定义**：一次打印操作的原子单位，包含打印所需的完整数据（样式、打印机、内容）。

**生命周期**：

```
PENDING(待打印) → PRINTING(打印中) → COMPLETED(已完成)
                      ↓
                   FAILED(失败) → [重试] → PRINTING
                      ↓
                   ARCHIVED(归档)
```

**关键属性**：
- `prnStyleLid`：关联的样式 ID
- `printerLid`：目标打印机 ID
- `queueLid`：所属队列 ID
- `orderBillLid`：关联订单 ID
- `printData`：打印数据（JSON）
- `retryCount`：已重试次数
- `maxRetries`：最大重试次数

### 1.2 打印队列 (PrintQueue)

**定义**：一组打印任务的逻辑分组，通常对应一个业务场景（客单厨打、报表打印等）。

**队列类型**（按 POS 业务场景）：
- 客单队列：结账小票
- 厨打队列：厨房点菜单
- 报表队列：交班/日结报告
- 会员队列：储值/积分小票
- WMS 队列：仓储单据

**队列特性**：
- 队列内任务按创建时间 FIFO
- 同一队列可绑定多台打印机（负载均衡）
- 队列可设置开关（启用/禁用）

### 1.3 打印样式 (PrintStyle)

**定义**：控制票据外观格式的配置模板，定义了打印内容的布局、对齐、字体等属性。

**样式组成**：
- 样式类型（styleType）：票据分类（CheckOut、OrderMenu 等）
- 样式项列表（prnStyleItems）：具体的行配置
- 份数（copies）：打印份数
- 打印机关联（printerLid）：默认打印机

### 1.4 打印样式项 (PrintStyleItem)

**定义**：样式中的一行配置，控制一个元素的渲染方式。

**样式项类型**（PrnStyleItemTypeEnum）：

| 类型 | 说明 | 示例 |
|------|------|------|
| `TEXT` | 文本 | "桌号：03" |
| `IMAGE` | 图片 | Logo、宣传图 |
| `BARCODE` | 一维码 | 商品条码 |
| `QRCODE` | 二维码 | 支付码、跳转链接 |
| `DIVIDER` | 分割线 | "-----------" |
| `TABLE` | 表格 | 菜品明细表 |
| `DYNAMIC_TEXT` | 动态文本 | 金额、时间等变量 |
| `CONDITIONAL` | 条件块 | 满足条件才打印 |

---

## 二、打印机概念

### 2.1 打印机 (Printer)

**定义**：物理或虚拟的打印输出设备。

**打印机属性**：
- 设备 ID（devId）：关联 PosDev 实体
- 型号（printerModel）：决定协议类型
- 连接方式：网络(TCP)、USB、串口、OPOS
- 纸宽（paperWidth）：mm 为单位

### 2.2 打印机型号 (PrinterModelEnum)

| 型号 | 协议 | 典型品牌 | 适用场景 |
|------|------|----------|----------|
| `TSPL_TSC` | TSPL | 芯烨、TSC | 标签、票据 |
| `ZPL_HIPPO` | ZPL | 斑马、Zebra | 标签 |
| `ESC` | ESC/POS | 佳博、爱普生、爱宝 | 票据、热敏 |
| `OPOS_HIOPOS` | OPOS | 汉印 | 票据、热敏 |
| `HP_PCL` | PCL | HP | 文档 |
| `PDF` | PDF | 虚拟 | 测试/存档 |
| `DEFAULT` | ESC/POS | 通用 | 默认fallback |

### 2.3 协议概念

**TSPL**（Thermal Printer Language）
- 文本命令语言
- 支持 `SIZE`、`GAP`、`DIRECTION`、`TEXT`、`BARCODE`、`QRCODE`
- 示例：`SIZE 60,40\nGAP 2,0\nTEXT 50,0,"3",0,1,1,"HELLO"`

**ZPL**（Zebra Printer Language）
- 斑马专用语言
- 支持 `^XA`、`^FO`、`^A0`、`^BQN`、`^XZ`
- 示例：`^XA^FO50,50^BQN,2,5^FDHello^FS^XZ`

**ESC/POS**（Enhanced Command Standard for Point Of Sale）
- 字节流协议
- 控制序列：`ESC @` 初始化，`ESC ! n` 设置字符，`GS v 0` 打印位图
- 示例：`0x1B 0x40 0x1B 0x61 0x01 "Text"`

**OPOS**（OLE for Retail POS）
- 微软 COM 规范
- `POSPrinter` 对象
- 方法：`PrintNormal()`、`CutPaper()`、`OpenDrawer()`

---

## 三、业务概念

### 3.1 票据类型 (PrnStyleTypeEnum)

**分类层级**：
1. 大类：收银票据、后厨票据、报表票据、会员票据、其他票据、WMS票据
2. 类型：具体的票据样式
3. 变体：部分票据有 `Ex`（扩展）、`Local`（本地）变体

**关键票据类型**：

| 类型 | 触发时机 | 打印份数 | 特殊要求 |
|------|----------|----------|----------|
| `CheckOut` | 结账完成 | 1-2 | 必须 |
| `OrderMenu` | 落单 | 按部门 | 必须 |
| `HurryMenu` | 催菜 | 1 | 优先级高 |
| `ShiftReport` | 交班 | 1 | 需签名 |
| `MemberSavingBill` | 储值 | 1 | 需盖章 |

### 3.2 厨房区域 (Kitchen Area)

| 区域 | 英文 | 说明 | 对应票据 |
|------|------|------|----------|
| 出品部门 | FOR_PRN | 一菜一单 | OrderMenu |
| 传菜间 | FOR_SERVE | 多菜一单 | TotalBill |
| 配菜间 | FOR_PREPARATION | KDS 配菜 | OrderMenuEx |
| 制作间 | FOR_COOK | KDS 制作 | OrderMenuEx |
| 利润部门 | FOR_PROFIT | 利润中心统计 | 报表类 |

### 3.3 打印开关 (PrintJobTypeSwitch)

**定义**：按任务类型控制打印是否执行。

**开关维度**：
- 门店级别：当前门店是否启用
- 打印机级别：打印机是否可用
- 样式级别：样式是否启用
- 类型级别：票据类型是否启用

---

## 四、技术概念

### 4.1 Handler 工厂模式

```
PrintHandlerFactory
    │
    ├── TsplPrinterHandler     → TSPL 协议
    ├── ZplPrinterHandler      → ZPL 协议
    ├── EscPrinterHandler      → ESC/POS 协议
    ├── OposPrinterHandler     → OPOS SDK
    ├── PclPrinterHandler      → PCL 协议
    ├── PdfPrinterHandler      → PDF 虚拟打印
    └── DefaultPrinterHandler  → 默认 ESC/POS
```

**选择策略**：根据 `PrinterModelEnum` 路由到对应 Handler。

### 4.2 Virtual Thread 调度

**背景**：Java 21 虚拟线程，解决高并发打印任务的线程开销问题。

**调度策略**：
- 任务提交到虚拟线程池
- 每个任务一个虚拟线程
- 阻塞 I/O 不占用平台线程

### 4.3 文件存储 + Redis 计数

**存储架构**：
- 打印数据：JSON 文件（`/print_jobs/{lid}.json`）
- 计数缓存：Redis（`prn:count:{queueLid}`，TTL=15分钟）
- 任务索引：内存 Map + 文件备份

**一致性策略**：
- 先写文件，后写 Redis
- 启动时从文件恢复索引
- 异常时保留文件，支持手工恢复

---

## 五、概念关系图

```
┌──────────────────────────────────────────────────────────────────┐
│                        打印系统概念关系                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PrinterModelEnum ──────▶ PrinterHandler                        │
│        │                       ▲                                 │
│        │                       │                                 │
│        ▼                       │                                 │
│  Printer ─────────────────────┤                                 │
│        │                       │                                 │
│        │                       │                                 │
│  PrintQueue ◀─────────────────┤                                 │
│        │                       │                                 │
│        │                       │                                 │
│  PrintJob ────────────────────┤                                 │
│        │                       │                                 │
│        │                       │                                 │
│  PrintStyle ──────────────────┤                                 │
│        │                       │                                 │
│        │                       │                                 │
│  PrintStyleItem               │                                 │
│                                                                  │
│  PrnStyleTypeEnum ──────────▶ PrintStyle                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 六、概念与代码映射

| 概念 | 代码位置 | 关键类/方法 |
|------|----------|-------------|
| 打印任务 | nms4pos | `PosPrnJobServicePlus.create()` |
| 打印队列 | nms4pos | `PrintQueue` 实体 |
| 打印样式 | nms4pos | `PrintStyle`、`PrintStyleItem` |
| Handler工厂 | nms4pos | `PrintHandlerFactory.getHandler()` |
| 虚拟线程调度 | nms4pos | `PrintScheduler.submit()` |
| REST API | nms4cloud | `PosPrnJobController` |
| 前台展示 | nms4pos-ui | `PrintTaskMonitor` |
| 后台管理 | nms4cloud-biz-ui | `PrintMgr` |
