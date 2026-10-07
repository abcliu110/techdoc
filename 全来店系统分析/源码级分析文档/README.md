# 全来店 KACI POS 系统技术文档

> **源码路径**: `D:\kaci-pos-decompiled`
> **生成日期**: 2026-08-30
> **分析深度**: 基于 3505 个 Java 文件 + Electron 前端的源码级分析

---

## 文档导航

| 文档 | 描述 |
|------|------|
| 📋 **本总览文档** | 系统整体架构、各模块概览、模块关系图 |
| [📐 01_总体技术架构](./01_总体技术架构.md) | 技术栈、部署架构、通信协议 |
| [📦 02_数据模型总览](./02_数据模型总览.md) | 核心实体、各模块数据模型、枚举汇总 |
| [🔄 03_业务模块总览](./03_业务模块总览.md) | 订单/支付/促销/会员/桌台等模块概览 |

### 关键流程文档 (`关键流程文档/`)

| 文档 | 描述 | 源码入口 |
|------|------|---------|
| [🔄 01_加菜流程](./关键流程文档/关键流程01_加菜流程.md) | 商品加单、促销重算、打印 | `service/order/PlaceOrderService.java:62` |
| [🔄 02_反结账流程](./关键流程文档/关键流程02_反结账流程.md) | 已结账订单恢复、退积分礼品 | `service/order/RevCheckoutService.java:100` |
| [🔄 03_支付流程](./关键流程文档/关键流程03_支付流程.md) | 支付处理、自动结账、组合支付 | `service/pay/extension/BasePayService.java:100` |
| [🔄 04_退款流程](./关键流程文档/关键流程04_退款流程.md) | 撤单、全额退款、部分退款 | `service/order/RevokeOrderService.java` |
| [🔄 05_促销执行流程](./关键流程文档/关键流程05_促销执行流程.md) | 本地+云端双层促销计算 | `service/promotion/ExecutePromotionService.java` |
| [🔄 06_落单与叫起流程](./关键流程文档/关键流程06_落单与叫起流程.md) | 菜品提交厨房、KDS分单 | `service/order/DownOrderService.java` |
| [🔄 07_桌台操作流程](./关键流程文档/关键流程07_桌台操作流程.md) | 开台/并台/联台/拆台/清台 | `service/table/` |
| [🔄 08_打印系统流程](./关键流程文档/关键流程08_打印系统流程.md) | 票据策略模式、KDS打印 | `print/` |
| [🔄 09_会员流程](./关键流程文档/关键流程09_会员流程.md) | 开卡/充值/消费/积分/礼品卡 | `service/member/` |
| [🔄 10_小程序点餐流程](./关键流程文档/关键流程10_小程序点餐流程.md) | WebSocket异步通信、多人点餐 | `LocalServerClientMsgDataListener.java:50` |
| [🔄 11_估清系统流程](./关键流程文档/关键流程11_估清系统流程.md) | 每日估清、餐段估清、库存占用 | `service/soldout/` |
| [🔄 12_押金系统流程](./关键流程文档/关键流程12_押金系统流程.md) | 餐位押金、自助餐押金 | `service/cashPledge/` |
| [🔄 13_班结日结流程](./关键流程文档/关键流程13_班结日结流程.md) | 班次交接、日终结算 | `service/shiftDaily/` |
| [🔄 14_KDS后厨流程](./关键流程文档/关键流程14_KDS后厨流程.md) | 制作单、泳道、叫号 | `service/kds/` |
| [🔄 15_外卖配送流程](./关键流程文档/关键流程15_外卖配送流程.md) | 美团/饿了么/自配送 | `service/takeout/` + `service/delivery/` |
| [🔄 16_预订系统流程](./关键流程文档/关键流程16_预订系统流程.md) | 预约订座、订金管理 | `service/book/` |
| [🔄 17_发票流程](./关键流程文档/关键流程17_发票流程.md) | 开票、红冲、作废 | `service/order/InvoiceBizService.java` |

### 模块详细文档 (`模块详细文档/`)

| 文档 | 描述 | 源码路径 |
|------|------|---------|
| [01_订单模块详细](./模块详细文档/01_订单模块详细.md) | 域模型、38个服务、refund子包 | `service/order/` |
| [02_支付模块详细](./模块详细文档/02_支付模块详细.md) | 12种支付方式、PaySelector、取消分发 | `service/pay/` |
| [03_促销模块详细](./模块详细文档/03_促销模块详细.md) | 双层促销架构、组合优惠、25种促销类型 | `service/promotion/` |
| [04_会员模块详细](./模块详细文档/04_会员模块详细.md) | 3种卡类型、BaseCardTradeService、积分/储值 | `service/member/` |
| [05_桌台模块详细](./模块详细文档/05_桌台模块详细.md) | 6种状态、9种操作、策略选择器 | `service/table/` |
| [06_打印KDS模块详细](./模块详细文档/06_打印KDS模块详细.md) | 超级枚举PrintTicketTypeEnum、3屏联动 | `print/` + `kds/` |
| [07_通信层详细](./模块详细文档/07_通信层详细.md) | Netty管道、Handler注册、Bean容器、8线程池 | `web/server/` |
| [08_前端详细](./模块详细文档/08_前端详细.md) | Electron硬件驱动、IPC、副屏支持 | `kaci-pos-front/` |
| [09_押金酒水估清班结详细](./模块详细文档/09_押金酒水估清班结详细.md) | 押金状态机、沽清占用机制、团购降级 | `service/cashPledge/` 等 |
| [10_外卖配送预订详细](./模块详细文档/10_外卖配送预订详细.md) | MQTT接收、预订订金、两种配送模式 | `takeout/` + `book/` |

---

## 1. 项目定位

全来店 KACI POS 是一个**餐饮行业销售点系统**，支持：

- **堂食正餐** — 桌台管理、加减菜、反结账、KDS 后厨分单
- **快餐** — 无桌台、快速结账、自助点餐
- **外卖** — 小程序点餐、第三方配送集成（美团/饿了么）
- **预订** — 预约订座、订金管理
- **自助点餐** — 小程序扫码点餐
- **会员体系** — 开卡、储值、积分、礼品兑换
- **促销系统** — 折扣、满减、买赠、优惠券、组合优惠
- **押金管理** — 餐位押金、自助餐押金
- **酒水寄存** — 酒水暂存、提取
- **发票管理** — 发票开具，红冲

---

## 2. 技术架构

### 2.1 系统架构图

```
┌─────────────────────────────────────────────────────────┐
│                    Electron 前端 (kaci-pos-front)           │
│         Preact + Ant Design UI + Node.js 主进程          │
│         硬件驱动: SerialPort | NFC-PCSC | Koffi FFI      │
└────────────────────┬────────────────────────────────────┘
                      │ TCP (Netty) / HTTP
                      ↓
┌─────────────────────────────────────────────────────────┐
│           Java 后端 (kaci-pos-localserver)                 │
│                  Netty HTTP Server (8090)                  │
│         ~400 个 Handler (无 Spring Boot)                  │
│              150 个 Service (手动 Bean 管理)               │
│                 MySQL (Windows) / SQLite (Android)        │
└─────────────────────────────────────────────────────────┘
```

### 2.2 源码统计

```
Java 文件: 3505 个
├── service/:  150 个（业务服务）
├── web/handler/: ~400 个（HTTP Handler）
├── dao/po/:   138 个（实体）
└── 其他:       基础设施、工具类、DTO、VO、Converter
```

---

## 3. 模块一览

| 模块 | 路径 | Handler 数量 |
|------|------|-------------|
| 订单 | `service/order/` | ~15 |
| 支付 | `service/pay/` | ~15 |
| 促销 | `service/promotion/` | ~5 |
| 会员 | `service/member/` | ~20 |
| 桌台 | `service/table/` | ~10 |
| 打印 | `print/` | ~20 |
| KDS | `kds/` | ~15 |
| 外卖 | `takeout/` | ~10 |
| 配送 | `delivery/` | ~15 |
| 预订 | `book/` | ~15 |
| 押金 | `cashPledge/` | ~10 |
| 酒水 | `wine/` | ~8 |
| 估清 | `soldout/` | ~6 |
| 团购 | `groupBuying/` | ~6 |
| 班结日结 | `shiftDaily/` | ~10 |
| 小程序 | `service/order/wxApplet/` | ~6 |
| 发票 | `service/order/InvoiceBiz/` | ~6 |
| 基础数据 | `service/basic/` | ~15 |
| 运营报表 | `report/` | ~20 |

---

## 4. 关键设计特点

1. **无 Spring Boot**: 手动 Bean 管理 (`PosContext.getBean()`)
2. **无标准 REST**: 每个接口一个 `*Handler` 类，硬编码注册 ~400 个 Handler
3. **事务管理**: `LocalServerTransactionManager.execTransaction()` 手动事务
4. **并发控制**: `LockUtil.lock(billNo)` 分布式锁
5. **异步处理**: 多线程池 (`taskThreadPool`/`orderUploadTaskThreadPool`)
6. **主备数据源**: `OrderMasterDao` / `OrderMasterBakDao`
7. **WebSocket**: `tp_order_refresh`/`tp_pay_complete` 实时推送
8. **双层促销**: POS 本地计算 + 云端 SDK 计算

---

## 5. 文档说明

本目录下所有新文档均为**源码级分析**，每个文档包含：
- ✅ 实际文件路径和行号引用
- ✅ 真实的类名、方法名、字段名
- ✅ 实际的业务规则和判断条件
- ✅ 源码级别的流程描述

⚠️ 目录中部分旧文档（2026-08-30 21:18 之前创建）是由 LLM 生成的伪代码示例，**未基于真实源码分析**，价值有限。

---

## 6. 文档生成说明

所有分析基于 `D:\kaci-pos-decompiled` 源码目录，由 Claude Code 自动分析源码生成。
