# DA1 业务切面分析

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | 打印相关模块 |
| 分析时间 | 2026-08-04 |

---

## 一、业务维度识别

### 1.1 核心业务维度

| 维度 | 业务含义 | 关键特征 |
|---|---|---|
| **打印机** | 物理打印设备或虚拟打印服务 | 按连接类型(NET/COM/USB/Driver/Cloud)区分 |
| **打印队列** | 打印任务的路由配置 | 关联打印机、关联打印样式 |
| **打印任务** | 一次具体的打印操作 | 关联单据、状态、补打标识 |
| **打印样式** | 打印内容的布局模板 | 行级配置、列级配置、条件显示 |
| **转发规则** | 打印机故障时的备选路由 | 源→目标映射 |

### 1.2 业务维度关系图

```
业务单据（订单/结账/预订单）
    ↓ 创建打印任务
PosPrnJob（打印任务）
    ↓ 关联打印队列
PosPrnQueue（打印队列）
    ├── primaryPrinter → PosPrnPrinter（主打印机）
    ├── standbyPrinter → PosPrnPrinter（备用打印机）
    └── prnStyleLid → PosPrnStyle（打印样式）

PosPrnPrinterTransfer（转发规则）
    sourcePrinter → targetPrinter（故障重定向）

PosPrnStyle
    PosPrnStyleRow（行配置）
    └── PosPrnStyleCol（列配置）
```

---

## 二、打印类型全景

### 2.1 前台票据类（10-50）
| 类型 | 说明 |
|---|---|
| `OrderMenu` | 点菜单 |
| `OrderMenuEx` | 点菜单（多食） |
| `TotalBill/TotalBillLocal` | 总单 |
| `ReplaceItem` | 换品单 |
| `TransferTable/TransferMenu` | 转台单 |
| `HurryMenu/BackMenu/UpMenu` | 催/退/起菜单 |
| `ChangeMenuAmount` | 数量变更单 |
| `CheckOut/CheckOutFull` | 结账单 |
| `Nodiscount/Discount` | 结算单/撤销结算单 |
| `GQBill` | 沽清单 |
| `ShiftReport` | 交班单 |
| `BookSum` | 预订汇总 |
| `OrderBill` | 预定单 |
| `QueueBill` | 排队单 |
| `FoodLabel` | 标签单 |

### 2.2 会员类（51-71）
| 类型 | 说明 |
|---|---|
| `MemberSavingBill` | 会员充值 |
| `TuiKaDan` | 会员退卡 |
| `HYYXF MX/HYFPMX` | 会员消费/发票明细 |
| `MemberFaKaMingXi/TuiKaMingXi` | 发卡/退卡明细 |
| `MemberBirthday/Gift` | 生日查询/礼品兑换 |
| `SMS_*` | 各类短信通知 |

### 2.3 WMS仓储类（1000-1048）
| 类型 | 说明 |
|---|---|
| `WMS_ST_BILL_*` | 门店单据（采购/销售/盘点/调拨等） |
| `WMS_RDC_ORDER` | 配送中心订货单 |

---

## 三、打印连接类型

| 类型 | 协议 | 典型型号 | 处理器 |
|---|---|---|---|
| `OPOS_NET` | OPOS/网口 | EPSON TM系列 | PortHandler |
| `Com` | 串口RS232 | 各类串口打印机 | PortHandler |
| `OPOS_LPT` | OPOS/并口 | 老式打印机 | PortHandler |
| `OPOS_USB` | OPOS/USB | USB直连 | PortHandler |
| `Driver` | Windows驱动 | 通用 | GraphicsHandler |
| `Driver_CMD` | 驱动+指令 | 通用 | PortHandlerWithDriver |
| `XY_CLOUD` | 云打印API | 芯燚云 | XpCloudPrinter |
| `JB_CLOUD` | 云打印API | 精打云 | JBCloudPrinter |

---

## 四、打印任务状态机

```
PosPrnJob.status:
    PENDING(1) → SUCCESS(2)
              ↘ FAILED(3)

PosPrnJob.print:
    false → true（打印完成后标记）

打印机状态 PrinterStatus:
    DEFAULT(0) → NORMAL(2) → BUSY(3)
              ↘ FAULT(1)
```

---

## 五、关键业务规则

### 5.1 主备打印机策略
1. 优先分发到主打印机（随机负载均衡）
2. 主打印机全部故障时，分发到备用打印机
3. 所有打印机故障时，任务进入重试队列（2秒后重试）

### 5.2 故障重定向策略
- `PosPrnPrinterTransfer` 规则：源打印机故障时，自动将任务重定向到目标打印机
- 触发时机：PrinterWorker 检测到 FAULT 状态

### 5.3 打印超时规则
- 任务在队列中等待超过 **45分钟** 标记为超时
- 任务从创建超过 **30分钟** 不再处理

### 5.4 补打规则
- `prnCount > 0` 表示已打印过，当前为补打
- 补打时打印红色提示："注：此单为补打单"

---

## 六、打印处理器策略

```
PrinterWorker 根据 type 和 model 选择处理器:
├── Driver        → GraphicsHandler（图形渲染）
├── Driver_CMD    → PortHandlerWithDriver（驱动指令）
├── NET/COM/USB/LPT
│   ├── GP_3150TFN → JBTagPrinter（标签打印）
│   ├── XP_T202UA  → XYTagPrinter（标签打印）
│   ├── HY58/HY80  → HanYinPrinter（汉印）
│   └── 其他        → PortHandler（通用串口）
├── XY_CLOUD       → XpCloudPrinter（芯燚云）
└── JB_CLOUD       → JBCloudPrinter（精打云）
```

---

## DA1 结论

**识别维度：5个**（Printer/Queue/Job/Style/Transfer）
**打印类型：130+种**（票据/会员/WMS三大类）
**连接类型：8种**
**处理器类型：8种**
**核心策略：主备冗余 + 故障重定向 + 超时重试**

---

## G0-C 门禁结论：通过

业务切面已清晰，维度边界已明确，可进入 DA2 概念字典和 DA3 关系分析。
