# 打印/KDS模块详细文档

## 1. 模块概述

打印模块采用策略模式实现多类型票据打印，KDS模块管理后厨显示屏的制作单流转。

**源码路径**: `print/` + `kds/`

---

## 2. 打印模块 (print/)

### 文件统计

共 **578+ 个文件**，核心结构：

```
print/
├── selector/                          # 选择器
│   ├── PrinterSelector.java           # 打印机选择
│   ├── TicketPrintBuilderSelector.java # 票据构建选择
│   ├── TemplateTicketSelector.java   # 模板选择
│   ├── TemplateRowContextHandlerSelector.java
│   ├── TemplateProcessorSelector.java
│   └── receipt/                      # 小票模板选择
│       ├── ReceiptSettingContextHandlerSelector.java
│       ├── TypographyStrategySelector.java
│       └── ...
│
├── enums/                           # 枚举
│   ├── PrintTicketTypeEnum.java    # 票据类型 (核心!)
│   ├── PrintTypeEnum.java
│   ├── PrintStatusEnum.java
│   └── receipt/                   # 小票枚举
│
├── convert/                        # 转换器
│   ├── BillTicketPrintConvert.java
│   └── ...
│
└── response/                      # 响应
    └── 100+ 个响应类
```

### PrintTicketTypeEnum — 超级枚举

每个票据类型直接绑定打印机策略 + 构建策略：

```java
// PrintTicketTypeEnum.java
public enum PrintTicketTypeEnum {
    // 结账单
    PREPARE(8001, "预结单") {
        public PrinterStrategy getPrinterStrategy() {
            return new EatInDevicePrinterStrategyImpl();
        }
        public TicketPrintStrategy getPrintDataStrategy() {
            return new BillTicketPrintStrategyImpl();
        }
    },

    // 制作单
    MAKE(Integer.valueOf(10001), "制作单") {
        public PrinterStrategy getPrinterStrategy() {
            return new MakeTicketPrinterStrategyImpl();
        }
        public TicketPrintStrategy getPrintDataStrategy() {
            return new MakeTicketPrintStrategyImpl();
        }
    },

    // 押金单
    CASH_PLEDGE(Integer.valueOf(8014), "押金单") { ... },

    // 外卖商家联
    TAKE_OUT_MERCHANT(Integer.valueOf(9001), "外卖商家联") { ... },

    // 外卖顾客联
    TAKE_OUT_CUSTOMER(Integer.valueOf(9002), "外卖顾客联") { ... },
}
```

### 主要票据类型

| 类型 | 票据ID | 打印机策略 | 构建策略 |
|------|---------|-----------|---------|
| 预结单 | 8001 | EatInDevicePrinter | BillTicketPrintStrategyImpl |
| 结账单 | 8002 | EatInDevicePrinter | BillTicketPrintStrategyImpl |
| 消费明细单 | 8003 | EatInDevicePrinter | ConsumeDetailStrategyImpl |
| 存酒单 | 8009 | EatInDevicePrinter | WineTicketStrategyImpl |
| 押金单 | 8014 | EatInDevicePrinter | CashPledgeStrategyImpl |
| 估清单 | 8015 | EatInDevicePrinter | SoldOutStrategyImpl |
| 预订单 | 8024 | EatInDevicePrinter | BookTicketStrategyImpl |
| 外卖商家联 | 9001 | TakeOutMerchantPrinter | TakeoutTicketStrategyImpl |
| 外卖顾客联 | 9002 | TakeOutDevicePrinter | TakeoutTicketStrategyImpl |

---

## 3. KDS 模块 (kds/)

### 文件统计

共 **192+ 个文件**，核心结构：

```
kds/
├── po/                            # 数据对象
│   ├── ScreenMakeDo.java         # 制作单主表
│   ├── ScreenMakeDetailDo.java   # 制作单明细
│   ├── ScreenDetailDo.java      # 屏幕配置
│   ├── SwimConfigDo.java        # 泳道配置
│   └── wrapper/                 # 包装类
│
├── enums/                       # 枚举
│   ├── KdsCurrentScreenTypeEnum.java  # 屏幕类型
│   ├── DetailTagEnum.java        # 明细标签
│   └── KDSGoodsConfigEnum.java
│
├── manager/                      # Manager 层
│   ├── KdsMakeCreateManager.java   # 制作单创建
│   ├── KdsMakeCompleteManager.java # 制作单完成
│   ├── KdsMakeRevertManager.java   # 制作单回退
│   ├── KdsMakeInvalidManager.java  # 制作单作废
│   ├── KdsMakeUpdateManager.java   # 制作单更新
│   ├── KdsSwimManager.java        # 泳道管理
│   └── ScreenDetailManager.java
│
├── gateway/                      # 网关层
│   ├── ScreenMakeGateway.java
│   ├── ScreenDetailGateway.java
│   ├── OrderGateway.java
│   └── KDSOrgParamGateway.java
│
└── dto/                         # 数据传输对象
    ├── KdsMakeOperateDto.java
    └── KdsMakeDetailDto.java
```

### 屏幕类型 (KdsCurrentScreenTypeEnum)

| 枚举 | code | 说明 |
|------|------|------|
| ASSEMBLY | 2 | 配餐屏 |
| MAKE | 3 | 制作屏 |
| DISHES | 4 | 出餐屏 |

### 制作状态 (MakeStatusEnum)

| code | 名称 | 说明 |
|------|------|------|
| 0 | 未开始 | 刚创建 |
| 1 | 进行中 | 正在制作 |
| 2 | 已完成 | 制作完成 |
| 4 | 废弃 | 已取消 |
| 5 | 等叫 | 等叫中 |
| 10 | 即起 | 即刻制作 |
| 15 | 叫起 | 叫起 |
| 18 | 加急 | 催菜 |
| 29 | 挂起 | 挂起 |

### 标签 (DetailTagEnum)

| code | 名称 | 说明 |
|------|------|------|
| 15 | WAKE_UP | 叫起 |
| 18 | URGE | 催菜 |
| 19 | EMERGENCY | 加急 |

---

## 4. 关键发现

### 发现1: PrintTicketTypeEnum 是"超级枚举"

每个枚举实例同时持有三个策略对象，O(1) 复杂度路由：
```java
public PrinterStrategy getPrinterStrategy();
public TicketPrintStrategy getPrintDataStrategy();
public TemplateTicketGenerator getTicketGenerator();
```

### 发现2: KDS Manager 分层设计

```
ScreenMakeService (门面服务)
       │
       ├── KdsMakeCreateManager   # 创建制作单
       ├── KdsMakeCompleteManager  # 完成制作单
       ├── KdsMakeRevertManager   # 回退制作单
       ├── KdsMakeInvalidManager  # 作废制作单
       └── KdsSwimManager        # 泳道管理
```

### 发现3: KDS 三屏联动

每个制作单明细有三种屏幕状态：
```java
screenDetail.setCreateScreenStatus(ASSEMBLY);  // 创建时屏幕
screenDetail.setMakeScreenStatus(MAKE);       // 制作中屏幕
screenDetail.setOutScreenStatus(DISHES);       // 出餐屏幕
```
支持灵活配置：配餐屏 → 制作屏 → 出餐屏，或跳过某些屏幕。
