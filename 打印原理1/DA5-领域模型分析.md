# DA5 - 领域模型分析

> **SOP-00 §DA5 执行记录**
> 深入分析打印系统的领域模型设计

---

## 一、核心领域对象

### 1.1 聚合根

#### PosPrnJob (打印任务)

**表**：`pos_prn_job`

| 属性 | 类型 | 说明 | 关联关系 |
|------|------|------|----------|
| pid | Long | 物理编号（自增主键） | |
| mid | Long | 商户ID | |
| sid | Long | 门店ID | |
| lid | Long | 逻辑编号（雪花算法） | 主键 |
| name | String | 任务名称 | |
| prnDeptName | String | 打印部门名称 | |
| bizBillId | String | 业务单据ID | 关联原始订单 |
| type | PrnStyleTypeEnum | 票据类型 | |
| purpose | PrnJobPurposeEnum | 打印用途 | |
| prnCount | Integer | 打印份数 | |
| **prnQueueLid** | Long | 打印队列ID | → PosPrnQueue.lid |
| **prnPrinterLid** | Long | 打印机ID | → PosPrnPrinter.lid |
| print | Boolean | 是否打印 | |
| printAt | LocalDateTime | 打印时间 | |
| status | PrnJobStatusEnum | 任务状态 | |
| failureReason | String | 失败原因 | |
| failedAt | LocalDateTime | 失败时间 | |
| createdTime | LocalDateTime | 创建时间 | |
| updatedTime | LocalDateTime | 更新时间 | |

#### PosPrnPrinter (打印机)

**表**：`pos_prn_printer`

| 属性 | 类型 | 说明 | 关联关系 |
|------|------|------|----------|
| pid | Long | 物理编号（自增主键） | |
| mid | Long | 商户ID | |
| sid | Long | 门店ID | |
| lid | Long | 逻辑编号（雪花算法） | 主键 |
| name | String | 打印机名称 | |
| pcLid | Long | PC设备ID | |
| type | PrinterTypeEnum | 连接类型 | |
| model | PrinterModelEnum | 打印机型号 | |
| extraInfo | String | 扩展信息（JSON） | |
| createdTime | LocalDateTime | 创建时间 | |
| updatedTime | LocalDateTime | 更新时间 | |

#### PosPrnQueue (打印队列)

**表**：`pos_prn_queue`

| 属性 | 类型 | 说明 | 关联关系 |
|------|------|------|----------|
| pid | Long | 物理编号（自增主键） | |
| mid | Long | 商户ID | |
| sid | Long | 门店ID | |
| lid | Long | 逻辑编号（雪花算法） | 主键 |
| name | String | 队列名称 | |
| pcLid | Long | PC设备ID | |
| primaryPrinter | String | 主打印机（JSON数组） | |
| standbyPrinter | String | 备用打印机（JSON数组） | |
| createdTime | LocalDateTime | 创建时间 | |
| updatedTime | LocalDateTime | 更新时间 | |

#### PosPrnStyleRow (打印样式行)

**表**：`pos_prn_style_row`

| 属性 | 类型 | 说明 | 关联关系 |
|------|------|------|----------|
| pid | Long | 物理编号（自增主键） | |
| mid | Long | 商户ID | |
| sid | Long | 门店ID | |
| lid | Long | 逻辑编号（雪花算法） | 主键 |
| dsId | String | 数据源ID | |
| styleType | PrnStyleTypeEnum | 样式类型 | |
| showIndex | Integer | 显示顺序 | |
| displayCondition | String | 显示条件 | |
| conditionDsId | String | 条件数据源ID | |
| conditionOperator | ConditionOperatorEnum | 条件操作符 | |
| conditionValue | String | 条件值 | |
| summarize | Boolean | 是否汇总 | |
| summarizeColName | String | 汇总列名 | |
| createdTime | LocalDateTime | 创建时间 | |
| updatedTime | LocalDateTime | 更新时间 | |

#### PosPrnStyleCol (打印样式列)

**表**：`pos_prn_style_col`

| 属性 | 类型 | 说明 | 关联关系 |
|------|------|------|----------|
| pid | Long | 物理编号（自增主键） | |
| mid | Long | 商户ID | |
| sid | Long | 门店ID | |
| lid | Long | 逻辑编号（雪花算法） | 主键 |
| styleType | PrnStyleTypeEnum | 样式类型 | |
| **rowLid** | Long | 样式行ID | → PosPrnStyleRow.lid |
| type | PrnStyleColTypeEnum | 列类型 | |
| customizedContent | String | 自定义内容 | |
| color | String | 字体颜色 | |
| bg | String | 背景色 | |
| width80 | Integer | 80mm宽度 | |
| width76 | Integer | 76mm宽度 | |
| width58 | Integer | 58mm宽度 | |
| align | PrnStypeAlignEnum | 对齐方式 | |
| summarize | Boolean | 是否汇总 | |
| fontSize | PrnStyleFontSizeEnum | 字号 | |
| bold | Boolean | 是否加粗 | |
| showIndex | Integer | 显示顺序 | |
| insertSeparatorLine | Integer | 插入分隔线数 | |
| insertBlankLine | Integer | 插入空白行数 | |
| lineSpacing | Integer | 行间距 | |
| conditionDsId | String | 条件数据源ID | |
| conditionOperator | ConditionOperatorEnum | 条件操作符 | |
| conditionValue | String | 条件值 | |
| createdTime | LocalDateTime | 创建时间 | |
| updatedTime | LocalDateTime | 更新时间 | |

---

## 二、领域服务

### 2.1 PrintDispatchService (打印调度服务)

**职责**：将打印请求路由到正确的 Handler。

**领域逻辑**：
```
PrintDispatchService.dispatch(job, printer):
    1. 获取打印机型号 → PrinterModelEnum
    2. 根据型号选择 Handler
    3. 渲染样式模板
    4. 转换为协议数据
    5. 调用 Handler 执行
    6. 返回结果
```

### 2.2 PrintStyleEngine (样式引擎)

**职责**：解析样式配置，生成打印数据。

**领域逻辑**：
```
PrintStyleEngine.render(style, data):
    1. 遍历样式项列表
    2. 解析 itemType:
       - TEXT: 直接输出
       - DYNAMIC_TEXT: 替换变量
       - IMAGE: 加载图片
       - BARCODE: 生成条码
       - QRCODE: 生成二维码
       - TABLE: 格式化表格
    3. 应用布局 (left, top, width, height)
    4. 应用字体 (fontSize, fontWeight)
    5. 应用对齐 (align)
    6. 输出协议数据
```

---

## 三、领域事件

### 3.1 事件定义

| 事件 | 触发时机 | 数据内容 |
|------|----------|----------|
| `PrintTaskCreated` | 任务创建 | jobId, queueLid, printerLid |
| `PrintTaskStarted` | 开始打印 | jobId, startTime |
| `PrintTaskCompleted` | 打印完成 | jobId, endTime |
| `PrintTaskFailed` | 打印失败 | jobId, errorCode, errorMsg |
| `PrintTaskRetried` | 重试打印 | jobId, retryCount |
| `PrintTaskArchived` | 任务归档 | jobId, archiveTime |
| `PrinterStatusChanged` | 状态变更 | printerLid, oldStatus, newStatus |

### 3.2 事件流

```
PrintJob.create()
    │
    ├─▶ [事件] PrintTaskCreated
    │       ├─▶ 前台订阅 → 更新监控面板
    │       └─▶ 调度器订阅 → 触发打印
    │
    ▼
PrintJob.execute()
    │
    ├─▶ [事件] PrintTaskStarted
    │       └─▶ 更新任务状态
    │
    ├─▶ [事件] PrintTaskCompleted
    │       └─▶ 记录完成时间
    │
    └─▶ [事件] PrintTaskFailed
            ├─▶ 记录错误信息
            └─▶ 触发重试逻辑
```

---

## 四、值对象设计

### 4.1 PrinterModelEnum

```java
public enum PrinterModelEnum {
    TSPL_TSC("芯烨/TSC", "TSPL"),
    ZPL_HIPPO("斑马/Zebra", "ZPL"),
    ESC("佳博/爱普生", "ESC/POS"),
    OPOS_HIOPOS("汉印/OPOS", "OPOS"),
    HP_PCL("HP", "PCL"),
    PDF("PDF虚拟", "PDF"),
    DEFAULT("默认", "ESC/POS");

    private final String brand;
    private final String protocol;

    public String getProtocol() { return protocol; }
}
```

### 4.2 PrnStyleTypeEnum

```java
public enum PrnStyleTypeEnum {
    // 收银票据
    CheckOut("结账单", "cashier"),
    Nodiscount("不打折小票", "cashier"),
    Discount("折扣小票", "cashier"),
    CashboxPop("钱箱弹出", "cashier"),

    // 后厨票据
    OrderMenu("点菜单", "kitchen"),
    OrderMenuEx("点菜单(扩展)", "kitchen"),
    TotalBill("全部菜品", "kitchen"),
    HurryMenu("催菜单", "kitchen"),
    BackMenu("退菜单", "kitchen"),
    ReplaceItem("换品单", "kitchen"),
    GQBill("挂起单", "kitchen"),

    // 报表票据
    ShiftReport("交班报告", "report"),
    DateSalesReport("日销售报告", "report"),
    BuMenReport("部门报告", "report"),

    // 会员票据
    MemberSavingBill("储值小票", "member"),
    TuiKaDan("退卡单", "member"),

    // 其他票据
    OrderBill("订单票据", "other"),
    QueueBill("排队票据", "other"),
    FoodLabel("菜品标签", "other"),

    // WMS票据
    WMS_STORE_ORDER("门店订货单", "wms"),
    WMS_ST_CHECK_BILL("盘点单", "wms"),
    // ... 更多WMS票据类型
    ;
}
```

### 4.3 PrnStyleItemTypeEnum

```java
public enum PrnStyleItemTypeEnum {
    TEXT("文本"),
    IMAGE("图片"),
    BARCODE("一维码"),
    QRCODE("二维码"),
    DIVIDER("分割线"),
    TABLE("表格"),
    DYNAMIC_TEXT("动态文本"),
    CONDITIONAL("条件块"),
    SPACER("空白"),
    QRCODE_URL("二维码URL");
}
```

---

## 五、模型边界

### 5.1 聚合边界

```
┌─────────────────────────────────────────────────────────────┐
│  PrintJob 聚合边界                                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PrintJob (聚合根)                                          │
│      │                                                      │
│      ├── JobStatus (值对象)                                 │
│      ├── RetryPolicy (值对象)                               │
│      └── PrintData (值对象)                                 │
│                                                             │
│  跨聚合引用:                                                │
│      - queueLid: PrintQueue.lid (通过ID引用)                │
│      - printerLid: Printer.lid (通过ID引用)                │
│      - prnStyleLid: PrintStyle.lid (通过ID引用)            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 聚合间关系

```
┌─────────────────┐       ┌─────────────────┐
│  PosPrnQueue    │       │  PosPrnPrinter  │
│  打印队列        │       │  打印机          │
│  lid (PK)      │       │  lid (PK)      │
│  primaryPrinter │◀──────│                 │
│  standbyPrinter │ JSON关联 │                 │
└────────┬────────┘       └────────┬────────┘
         │                        │
         │ lid                    │ lid
         ▼                        ▼
┌─────────────────┐       ┌─────────────────┐
│  PosPrnJob      │       │  PosPrnStyleRow │
│  打印任务        │       │  打印样式行       │
│  lid (PK)      │       │  lid (PK)       │
│  prnQueueLid ───┼───────┤  styleType      │
│  prnPrinterLid──┼───────┤                 │
│  type          │       │                 │
│  bizBillId     │       └────────┬────────┘
│  status        │                │ lid
└─────────────────┘                ▼
                          ┌─────────────────┐
                          │  PosPrnStyleCol │
                          │  打印样式列       │
                          │  lid (PK)       │
                          │  rowLid         │
                          │  type           │
                          └─────────────────┘
```

### 5.3 实体关联属性说明

| 源实体 | 关联属性 | 目标实体 | 说明 |
|--------|----------|----------|------|
| PosPrnJob | prnQueueLid | PosPrnQueue | 通过 lid 关联，获取队列信息 |
| PosPrnJob | prnPrinterLid | PosPrnPrinter | 通过 lid 关联，获取打印机信息 |
| PosPrnStyleCol | rowLid | PosPrnStyleRow | 通过 lid 关联，获取所属行 |
| PosPrnQueue | primaryPrinter | PosPrnPrinter | JSON数组存储，打印机lid列表 |
| PosPrnQueue | standbyPrinter | PosPrnPrinter | JSON数组存储，备用打印机lid列表 |

---

## 六、模型演化

### 6.1 历史版本

| 版本 | 变化 | 影响 |
|------|------|------|
| v1 | 初始设计，文件存储 | 兼容 |
| v2 | Redis 计数 | 新增字段 |
| v3 | 虚拟线程调度 | 无结构变化 |
| v4 | WMS 票据扩展 | 新增票据类型 |

### 6.2 扩展点

| 扩展点 | 扩展方式 |
|--------|----------|
| 新增协议 | 实现新 Handler |
| 新增票据类型 | 添加枚举值 |
| 新增样式项类型 | 添加枚举值 |
| 新增打印机 | 实现对应 Handler |
