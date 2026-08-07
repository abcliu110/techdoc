# DA2 概念建模
# 打印系统核心数据模型

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA2-PRINT-001 |
| 建模时间 | 2026/08/03 |
| 状态 | 初稿 |
| 参考文档 | DA1-侦察报告 |

---

## 1. 核心实体清单

### 1.1 实体概览

| 实体名 | 中文名 | 表名 | 职责 | 关键属性 |
|--------|--------|------|------|----------|
| PosPrnPrinter | 打印机 | pos_prn_printer | 管理物理打印设备 | type, model, extraInfo |
| PosPrnQueue | 打印队列 | pos_prn_queue | 路由分发中心 | primaryPrinter, standbyPrinter |
| PosPrnStyleRow | 打印样式行 | pos_prn_style_row | 定义票据内容 | styleType, showIndex, condition |
| PosPrnStyleCol | 打印样式列 | pos_prn_style_col | 单个打印项配置 | contentType, printContent |
| PosDept | 出品部门 | pos_dept | 厨房分单依据 | type, prnQueue, profitDept |
| PosDeptDish | 部门菜品关联 | pos_dept_dish | 菜品→部门映射 | deptLid, dishLid |
| PrintJobTypeSwitch | 打印开关 | print_job_type_switch | 控制联票生成 | disabledX, numOfX |
| Prn_PrintJob | 打印任务 | (运行时) | 打印任务数据模型 | type, items, status |
| DispatchJobDTO | 任务分发DTO | (运行时) | 任务分发传输对象 | jobLid, queueLid, printerLid |

---

## 2. 核心实体详细定义

### 2.1 PosPrnPrinter（打印机）

```
┌─────────────────────────────────────────────────────────────────┐
│                        PosPrnPrinter                            │
│                        打印机实体                                │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号（主键，自动生成）                  │
│   lid: Long          # 逻辑编号（业务标识）                        │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   pcLid: Long        # 所属计算机编号                             │
│                                                                 │
│ 【配置属性】                                                      │
│   name: String       # 打印机名称                                │
│   type: PrinterTypeEnum   # 连接方式                             │
│       - DRIVER       # Windows驱动                              │
│       - NET          # 网口指令                                 │
│       - COM          # 串口指令                                 │
│       - USB          # USB指令                                  │
│       - LPT          # 并口指令                                 │
│       - XY_CLOUD     # 芯烨云                                   │
│       - JB_CLOUD     # 佳博云                                   │
│       - DRIVER_CMD   # 驱动+指令混合                            │
│   model: PrinterModelEnum  # 打印机型号                          │
│       - EPSON_TM_88IV, XP_80X, HY80, GP_3150TFN...              │
│   extraInfo: String  # 附加信息（JSON，根据type不同格式不同）      │
│                                                                 │
│ 【审计属性】                                                      │
│   revision: Integer  # 乐观锁                                    │
│   createdBy/Time:    # 创建信息                                  │
│   updatedBy/Time:    # 更新信息                                  │
└─────────────────────────────────────────────────────────────────┘
```

**extraInfo 按类型差异：**

| type | extraInfo 字段 | 示例 |
|------|----------------|------|
| DRIVER | driver: "Microsoft XPS Document Writer" | 驱动名称 |
| NET | ip: "192.168.1.100", port: 9100 | IP地址和端口 |
| COM | com: "COM1", baudRate: 9600 | 串口和波特率 |
| USB | usbId: "USB001" | USB设备ID |
| LPT | lptPort: "LPT1" | 并口地址 |
| XY_CLOUD | deviceNo: "xxx", secretKey: "xxx" | 芯烨设备凭证 |
| JB_CLOUD | deviceNo: "xxx", apiKey: "xxx" | 佳博设备凭证 |
| DRIVER_CMD | driver: "xxx", standardFontLineLength: 48 | 驱动+字体宽度 |

---

### 2.2 PosPrnQueue（打印队列）

```
┌─────────────────────────────────────────────────────────────────┐
│                        PosPrnQueue                              │
│                        打印队列实体                              │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号                                  │
│   lid: Long          # 逻辑编号                                  │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   pcLid: Long        # 所属计算机（绑定该队列的终端）              │
│                                                                 │
│ 【路由属性】                                                      │
│   name: String       # 队列名称（业务标识，如"厨房1号打印机"）      │
│   primaryPrinter: String  # 主打印机（JSON，包含lid等信息）        │
│   standbyPrinter: String  # 备用打印机（JSON）                    │
│                                                                 │
│ 【审计属性】                                                      │
│   revision: Integer  # 乐观锁                                    │
│   createdBy/Time:    # 创建信息                                  │
│   updatedBy/Time:    # 更新信息                                  │
└─────────────────────────────────────────────────────────────────┘
```

**关联关系：**
```
PosPrnQueue ←→ PosPrnPrinter: N:1
  - 一个队列绑定一台主打印机 + 一台备用打印机
  - 主打印机故障时自动切换到备用打印机
```

---

### 2.3 PosDept（出品部门）

```
┌─────────────────────────────────────────────────────────────────┐
│                        PosDept                                  │
│                        出品部门实体                              │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号                                  │
│   lid: Long          # 逻辑编号                                  │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│                                                                 │
│ 【业务属性】                                                      │
│   name: String       # 部门名称（如"炒菜间"、"凉菜间"）            │
│   type: DeptTypeEnum # 部门类型                                  │
│       - FOR_PRN      # 打印部门（一菜一单）                       │
│       - FOR_SERVE    # 传菜部门（多菜一单）                       │
│       - FOR_PROFIT   # 利润部门                                  │
│       - FOR_PREPARATION # 配菜部门                               │
│       - FOR_COOK     # 制作部门                                  │
│   profitDept: Long   # 所属利润中心                              │
│                                                                 │
│ 【打印关联】                                                      │
│   prnQueue: String   # 关联的打印队列（JSON，包含lid）             │
│                                                                 │
│ 【WMS关联】                                                       │
│   wmsDeptLids: String # 关联的WMS部门列表                        │
│                                                                 │
│ 【审计属性】                                                      │
│   revision: Integer  # 乐观锁                                    │
└─────────────────────────────────────────────────────────────────┘
```

**核心作用：**
- 关联菜品和打印队列，实现**厨房自动分单**
- 一个菜品属于一个出品部门
- 出品部门关联一个打印队列
- 打印队列关联一台打印机
- 最终实现：**菜品 → 出品部门 → 打印队列 → 打印机**

---

### 2.4 PrintJobTypeSwitch（打印开关）

```
┌─────────────────────────────────────────────────────────────────┐
│                    PrintJobTypeSwitch                           │
│                    打印任务开关实体                              │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号                                  │
│   lid: Long          # 逻辑编号（唯一，业务标识）                  │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   type: PrnStyleTypeEnum # 票据类型                              │
│       - CheckOut     # 结账单                                    │
│       - OrderMenu    # 点菜单                                    │
│       - ...          # 共73种票据类型                            │
│                                                                 │
│ 【开关控制】                                                      │
│   disabledKitchen: Boolean  # 禁用厨房联                         │
│   disabledWaiter: Boolean   # 禁用传菜联                         │
│   disabledCustomer: Boolean # 禁用顾客联                         │
│                                                                 │
│ 【份数控制】                                                      │
│   numOfKitchen: Integer  # 厨房联打印份数                         │
│   numOfWaiter: Integer   # 传菜联打印份数                         │
│   numOfCustomer: Integer # 顾客联打印份数                         │
│                                                                 │
│ 【审计属性】                                                      │
│   deleted: Integer    # 逻辑删除标记                             │
└─────────────────────────────────────────────────────────────────┘
```

**控制逻辑示例：**
```
type=CheckOut 时：
  - disabledCustomer = false → 生成顾客联 × 1份
  - disabledKitchen = true → 不生成厨房联
  - disabledWaiter = true → 不生成传菜联

type=OrderMenu 时：
  - disabledKitchen = false → 生成厨房联 × 1份
  - disabledWaiter = false → 生成传菜联 × 1份
  - disabledCustomer = true → 不生成顾客联
```

---

### 2.5 PosPrnStyleRow（打印样式行）

```
┌─────────────────────────────────────────────────────────────────┐
│                      PosPrnStyleRow                             │
│                      打印样式行实体                              │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号                                  │
│   lid: Long          # 逻辑编号                                  │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   dsId: String       # 数据源ID                                  │
│   styleType: PrnStyleTypeEnum # 票据类型                         │
│                                                                 │
│ 【位置控制】                                                      │
│   showIndex: Integer # 显示顺序                                  │
│                                                                 │
│ 【条件控制】                                                      │
│   displayCondition: String  # 显示条件（格式：param op value）    │
│   conditionDsId: String     # 条件数据源ID                       │
│   conditionOperator: ConditionOperatorEnum  # 条件操作符          │
│   conditionValue: String    # 条件值                             │
│                                                                 │
│ 【汇总控制】                                                      │
│   summarize: Boolean        # 是否汇总                           │
│   summarizeColName: String  # 汇总列名                           │
│                                                                 │
│ 【审计属性】                                                      │
│   revision: Integer  # 乐观锁                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

### 2.6 PosPrnStyleCol（打印样式列/打印项）

```
┌─────────────────────────────────────────────────────────────────┐
│                      PosPrnStyleCol                             │
│                      打印样式列实体                              │
├─────────────────────────────────────────────────────────────────┤
│ 【标识属性】                                                      │
│   pid: Long          # 物理编号                                  │
│   lid: Long          # 逻辑编号                                  │
│                                                                 │
│ 【关联属性】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   rowLid: Long       # 所属行ID                                  │
│                                                                 │
│ 【内容配置】                                                      │
│   contentType: ContentTypeEnum  # 内容类型                       │
│       - TEXT        # 文本                                      │
│       - SQL         # SQL查询                                   │
│       - LINE        # 分隔线                                    │
│       - IMG         # 图片                                      │
│       - BARCODE     # 条码                                      │
│       - QRCODE      # 二维码                                    │
│       - CUT         # 切纸                                      │
│       - BLANK       # 空白行                                    │
│   printContent: String  # 打印内容（TEXT时为文本，SQL时为SQL）    │
│                                                                 │
│ 【布局配置】                                                      │
│   width: Integer     # 宽度                                     │
│   align: AlignEnum   # 对齐方式 LEFT/CENTER/RIGHT                │
│   fontName: String   # 字体名称                                  │
│   fontSize: Integer  # 字号                                     │
│   bold: Boolean      # 加粗                                      │
│   italic: Boolean    # 斜体                                      │
│   underline: Boolean # 下划线                                    │
│   strikethrough: Boolean # 删除线                                │
│                                                                 │
│ 【审计属性】                                                      │
│   revision: Integer  # 乐观锁                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

### 2.7 Prn_PrintJob（打印任务 - 运行时模型）

```
┌─────────────────────────────────────────────────────────────────┐
│                      Prn_PrintJob                               │
│                      打印任务实体（运行时）                       │
├─────────────────────────────────────────────────────────────────┤
│ 【任务标识】                                                      │
│   lid: Long          # 任务逻辑编号                              │
│   pid: Long          # 任务物理编号                              │
│   pID: Long          # 打印机物理ID                              │
│   qID: Long          # 队列ID                                   │
│   type: PrnStyleTypeEnum  # 票据类型                             │
│                                                                 │
│ 【任务属性】                                                      │
│   name: String       # 任务名称                                  │
│   status: PrnJobStatusEnum  # 任务状态                           │
│       - PENDING      # 待处理                                   │
│       - PRINTING     # 打印中                                   │
│       - COMPLETED    # 已完成                                   │
│       - FAILED       # 失败                                     │
│       - CANCELLED    # 已取消                                   │
│                                                                 │
│ 【任务数据】                                                      │
│   items: List<Prn_PrintJobItem>  # 打印项列表                    │
│       Prn_PrintJobItem {                                         │
│           contentType: ContentTypeEnum                          │
│           printContent: String                                  │
│           condition: String  # 显示条件                          │
│           width, align, fontSize, bold...                       │
│       }                                                          │
│                                                                 │
│ 【任务参数】                                                      │
│   allParas: Map<String, Object>  # 全局参数（票据级）             │
│   tmpParas: Map<String, Object>  # 临时参数（行级，覆盖全局）      │
│                                                                 │
│ 【打印样式】                                                      │
│   styleType: PrnStyleTypeEnum  # 样式类型                        │
│   printStyle: Prn_PrintStyle    # 打印样式对象                   │
│   printContents: List<Prn_StyleContent>  # 样式内容列表           │
└─────────────────────────────────────────────────────────────────┘
```

---

### 2.8 DispatchJobDTO（任务分发DTO）

```
┌─────────────────────────────────────────────────────────────────┐
│                      DispatchJobDTO                             │
│                      任务分发数据传输对象                        │
├─────────────────────────────────────────────────────────────────┤
│ 【分发信息】                                                      │
│   mid: Long          # 商户号                                    │
│   sid: Long          # 门店号                                    │
│   jobLid: Long       # 任务ID                                   │
│   queueLid: Long     # 队列ID                                   │
│   printerLid: Long   # 打印机ID                                 │
│                                                                 │
│ 【时间戳】                                                        │
│   startTime: long    # 任务开始时间（SystemClock.now()）         │
│   printerQueueAt: long # 任务进入打印机队列的时间                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. 实体关系图

### 3.1 ER图（简化版）

```
                    ┌─────────────────┐
                    │  PosDept        │
                    │  出品部门        │
                    │─────────────────│
                    │ lid (PK)        │
                    │ name            │
                    │ type            │
                    │ prnQueue (JSON) │
                    └────────┬────────┘
                             │ 1:N
                             │ 通过prnQueue关联
                             ▼
┌───────────────┐     ┌─────────────────┐     ┌─────────────────┐
│ PrintJobType  │     │  PosPrnQueue    │     │ PosPrnPrinter   │
│ Switch        │     │  打印队列        │     │ 打印机          │
│───────────────│     │─────────────────│     │─────────────────│
│ lid (PK)      │     │ lid (PK)        │     │ lid (PK)        │
│ type          │     │ name            │     │ name            │
│ disabledX     │     │ primaryPrinter  │     │ type            │
│ numOfX        │     │ standbyPrinter  │     │ model           │
└───────────────┘     └────────┬────────┘     │ extraInfo       │
                               │              └─────────────────┘
                               │ 1:1
                               │ primaryPrinter
                               ▼
                    ┌─────────────────┐
                    │  Prn_PrintJob   │
                    │  打印任务        │
                    │─────────────────│
                    │ lid (PK)        │
                    │ type            │
                    │ status          │
                    │ items[]         │
                    │ allParas        │
                    └─────────────────┘
                               │
                               │ 1:N
                               ▼
                    ┌─────────────────┐
                    │Prn_PrintJobItem │
                    │ 打印项          │
                    │─────────────────│
                    │ contentType     │
                    │ printContent    │
                    │ condition       │
                    │ width, align... │
                    └─────────────────┘
```

### 3.2 完整业务关系链

```
商户/品牌 (mid)
    │
    └── 门店 (sid)
         │
         ├── 计算机 (PosDev)
         │    │
         │    └── 打印机 (PosPrnPrinter)
         │         │
         │         └── 打印队列 (PosPrnQueue)
         │              │
         │              ├── 主打印机 ← primaryPrinter
         │              └── 备用打印机 ← standbyPrinter
         │
         ├── 出品部门 (PosDept)
         │    │
         │    ├── type: FOR_PRN → prnQueue → 打印队列 → 打印机
         │    ├── type: FOR_SERVE → 传菜间
         │    ├── type: FOR_PROFIT → 利润中心
         │    ├── type: FOR_PREPARATION → 配菜间
         │    └── type: FOR_COOK → 制作间
         │
         ├── 部门菜品关联 (PosDeptDish)
         │    │
         │    └── 菜品 (BizDish) ←→ 出品部门 (PosDept)
         │
         ├── 打印开关 (PrintJobTypeSwitch)
         │    │
         │    └── type → 控制 Customer/Kitchen/Waiter 联
         │
         └── 打印样式 (PosPrnStyleRow + PosPrnStyleCol)
              │
              ├── styleType → 票据类型
              └── row → cols → 打印内容
```

---

## 4. 枚举定义汇总

### 4.1 PrinterTypeEnum（连接方式）

```java
public enum PrinterTypeEnum {
    DRIVER(1),      // Windows驱动
    NET(2),         // 网口TCP/IP
    COM(3),         // 串口RS232
    USB(4),         // USB
    LPT(5),         // 并口
    XY_CLOUD(6),    // 芯烨云
    JB_CLOUD(7),    // 佳博云
    DRIVER_CMD(8);  // 驱动+指令
}
```

### 4.2 PrinterModelEnum（型号）

```java
public enum PrinterModelEnum {
    GP_R320C(1),         // GP热敏
    EPSON_TM_220B(2),    // EPSON热敏
    EPSON_T_T81(3),      // EPSON热敏
    BTP_98NP(4),         // BTP针式
    STAR_TSP700(5),      // STAR热敏
    STAR_SP700(6),       // STAR热敏
    STAR_TCP400(7),      // STAR热敏
    XP_80X(8),           // XP热敏
    XP_76X(9),           // XP热敏
    XP_58X(10),          // XP热敏
    EPSON_TM_88IV(11),   // EPSON热敏
    EPSON_T_T58(12),     // EPSON热敏
    HS_80(13),           // HS热敏
    GP_3150TFN(14),      // GP标签打印机
    XP_T202UA(15),       // XP标签打印机
    HY58(16),            // 汉印58
    HY80(17);            // 汉印80
}
```

### 4.3 PrnStyleTypeEnum（票据类型）

见 DA1-侦察报告 3.1 节

### 4.4 ContentTypeEnum（打印内容类型）

```java
public enum ContentTypeEnum {
    TEXT,       // 文本
    SQL,        // SQL查询
    LINE,       // 分隔线
    IMG,        // 图片
    BARCODE,    // 条码
    QRCODE,     // 二维码
    CUT,        // 切纸
    BLANK       // 空白行
}
```

### 4.5 PrinterStatus（打印机状态）

```java
public enum PrinterStatus {
    NORMAL,  // 正常
    FAULT,   // 故障
    BUSY     // 忙碌
}
```

### 4.6 PrnJobStatusEnum（任务状态）

```java
public enum PrnJobStatusEnum {
    PENDING,    // 待处理
    PRINTING,   // 打印中
    COMPLETED,  // 已完成
    FAILED,     // 失败
    CANCELLED   // 已取消
}
```

---

## 5. 关键概念澄清

### 5.1 pid vs lid vs dsId

| 标识 | 含义 | 特点 | 用途 |
|------|------|------|------|
| pid | 物理ID | 数据库自增主键 | 全局唯一，跨环境迁移时不保留 |
| lid | 逻辑ID | 业务主键 | 同sid内唯一，保留业务含义 |
| dsId | 数据源ID | 外部数据源标识 | 关联外部系统数据 |

### 5.2 extraInfo 的缓存机制

PosPrnPrinterVO 实现了 extraInfo 的懒缓存：

```java
// 当 extraInfo 变化时自动清除缓存
public void setExtraInfo(String extraInfo) {
    if (!StringUtils.equals(this.extraInfo, extraInfo)) {
        this.extraInfo = extraInfo;
        clearCache();  // 清除所有缓存
    }
}

// Getter 时自动解析并缓存
public PosPrnPrinterExtraInfoNetVO getExtraInfoNet() {
    if (isCacheValid() && cachedExtraInfoNet != null) {
        return cachedExtraInfoNet;  // 命中缓存
    }
    cachedExtraInfoNet = JSON.to(PosPrnPrinterExtraInfoNetVO.class, extraInfo);
    return cachedExtraInfoNet;
}
```

### 5.3 条件判断表达式

```java
// 格式：paramName operator value
// 示例：
// "isVip = true"      // VIP会员
// "amt > 1000"        // 大额订单
// "dishCount <> 0"    // 有菜品

// 操作符支持：=, <>, >, <
// 参数来源：先查tmpParas，再查allParas
```

---

**DA2 状态：✅ 概念建模完成，可进入DA3关系建模阶段**
