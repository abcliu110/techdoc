# DA7 实现映射 — 全来店 KACI POS 系统

> 版本：v1.0
> 分析基线：2026-08-30 反编译代码
> 状态：in_progress

---

## 一、代码结构总览

```
kaci-pos-localserver/src/com/shouqianba/localserver/
├── biz/                    业务逻辑
│   ├── common/           公共枚举和工具
│   └── order/            订单业务（含 POJO/Request/Response）
├── common/               公共基础设施
│   ├── PosContext.java              ← 手动 Bean 容器
│   ├── LocalServerTransactionManager.java ← 事务管理器
│   ├── LockUtil.java               ← 分布式锁
│   └── ThreadPoolConfig.java       ← 线程池配置
├── dao/                  数据访问层
│   └── (138个 DAO 接口)
├── kds/                   KDS 后厨系统
│   ├── enums/
│   └── manager/
├── order/                订单核心
│   ├── domain/entity/   ← 核心域对象
│   ├── enums/           ← 状态枚举
│   ├── operator/        ← 菜品操作（叫起/催菜/上菜）
│   ├── refund/          ← 退款
│   └── wxApplet/        ← 小程序
├── pay/                  支付
│   ├── extension/       ← BasePayService（支付基类）
│   ├── enums/
│   └── strategy/        ← 支付策略
├── print/                打印
│   ├── enums/           ← PrintTicketTypeEnum（超级枚举）
│   └── strategy/
├── service/             Service 层（按域分组）
│   ├── member/
│   ├── promotion/
│   ├── soldout/
│   ├── shiftDaily/
│   └── table/
├── takeout/             外卖
│   └── mqtt/           ← MQTT 消息处理
└── web/                 Web 层
    ├── handler/        ← Handler 层（395个）
    └── server/         ← Netty Server
        ├── PosServer.java      ← Netty Server 启动
        └── PosServerRunner.java ← Handler 注册
```

---

## 二、Handler→Service→DAO 映射表

### 订单核心链路

| Handler | URI | Service | 核心方法 | DAO |
|---|---|---|---|---|
| `PlaceOrderHandler` | `/order/placeOrder` | `PlaceOrderService` | `placeOrder()` | `OrderMasterDAO`, `OrderDetailDAO` |
| `RevCheckoutHandler` | `/order/revCheckout` | `RevCheckoutService` | `revCheckout()` | `OrderMasterDAO`, `OrderStatusDAO` |
| `RevokeOrderHandler` | `/order/revokeOrder` | `RevokeOrderService` | `revokeOrder()` | `OrderMasterDAO`, `OrderDetailDAO` |
| `DownOrderHandler` | `/order/down` | `DownOrderService` | `downOrder()` | `OrderDetailDAO`, `ScreenMakeDAO` |
| `OrderLdHandler` | `/order/create` | `OrderService` | `createOrder()` | `OrderMasterDAO`, `TableDAO` |
| `WakeUpHandler` | `/order/wakeUp` | `WakeUpService` | `wakeUp()` | `ScreenMakeDAO` |

### 支付链路

| Handler | URI | Service | 核心方法 | DAO |
|---|---|---|---|---|
| `PayCashHandler` | `/pay/cashPay` | `OfflinePayService` | `pay()` | `OrderPayDAO` |
| `PayCancelHandler` | `/pay/cancel` | `PayCancelService` | `cancel()` | `OrderPayDAO` |
| `PartialRefundHandler` | `/pay/partialRefund` | `PartialRefundService` | `refund()` | `OrderPayDAO`, `OrderDetailDAO` |

### 小程序链路

| Handler | URI | Service | 核心方法 |
|---|---|---|---|
| WebSocket入口 | ws:// | `LocalServerClientMsgDataListener` | `recvData()` |
| — | — | `AppletOrderHandleService` | `handleOrder()` |
| — | — | `PollingPayResultService` | `reCallPayResult()` |

---

## 三、静态/部署/运行差异

| 维度 | 静态（源码） | 部署 | 运行（实际行为） |
|---|---|---|---|
| Handler 注册 | 懒加载，首次请求时注册到 ConcurrentHashMap | — | — |
| 数据库事务 | LocalServerTransactionManager.execTransaction() | MySQL/SQLite 自动切换 | Android 用 synchronized，Windows 用 ORM |
| 分布式锁 | LockUtil.lock() | Zookeeper/Redisson | Windows 用本地文件锁 |
| 促销计算 | ExecutePromotionService | 云端 SDK(QlExpress) 降级本地 | 云端不可用时降级 type 1-4 |
| 打印 | PrintTicketTypeEnum 硬编码 | — | 枚举实例决定策略 |

---

## 四、核心实现锚点

| 业务能力 | 实现类 | 方法 | 证据 |
|---|---|---|---|
| 加菜 | `PlaceOrderService` | `placeOrder()` | E-SRC: `service/order/PlaceOrderService.java:51` |
| 估清检查 | `SoldOutStockBizService` | `checkSoldOut()` | E-SRC: `service/soldout/SoldOutStockBizService.java` |
| 支付 | `BasePayService` | `payComplete()` | E-SRC: `service/pay/extension/BasePayService.java` |
| 自动结账 | `BasePayService` | `autoCheckout()` | E-SRC: `service/pay/extension/BasePayService.java:296` |
| 反结账 | `RevCheckoutService` | `revCheckout()` | E-SRC: `service/order/RevCheckoutService.java:65` |
| 撤单 | `RevokeOrderService` | `revokeOrder()` | E-SRC: `service/order/RevokeOrderService.java:67` |
| 小程序消息 | `LocalServerClientMsgDataListener` | `recvData()` | E-SRC: `service/order/wxApplet/LocalServerClientMsgDataListener.java:50` |
| WebSocket推送 | `WebSocketPushService` | `push()` | E-SRC: `common/websocket/WebSocketPushService.java` |
| Bean管理 | `PosContext` | `getBean()` | E-SRC: `common/PosContext.java` |
| 事务管理 | `LocalServerTransactionManager` | `execTransaction()` | E-SRC: `common/LocalServerTransactionManager.java` |
| 分布式锁 | `LockUtil` | `lock()` | E-SRC: `common/LockUtil.java` |
| 打印路由 | `PrintTicketTypeEnum` | `getPrinterStrategy()` | E-SRC: `print/enums/PrintTicketTypeEnum.java` |
| 支付选择 | `PaySelector` | `select()` | E-SRC: `service/pay/PaySelector.java` |
| KDS分单 | `KdsMakeCreateManager` | `create()` | E-SRC: `kds/manager/KdsMakeCreateManager.java` |

---

## 五、跨层字段映射

| 业务层字段 | Handler Request | Service | DAO/ORM | DB字段 |
|---|---|---|---|---|
| 订单号 | `billNo` | `OrderMasterDO.billNo` | `OrderMasterDAO.billNo` | `bill_no` |
| 订单状态 | `orderStatus` | `OrderStatusDO.orderStatus` | `OrderStatusDAO.orderStatus` | `order_status` |
| 实收金额 | `actualReceiptAmount` | `OrderMasterDO.actualReceiptAmount` | `OrderMasterDAO.actualReceiptAmount` | `actual_receipt_amount` |
| 已落单 | `ldStatus=1` | `OrderDetailDO.ldStatus` | `OrderDetailDAO.ldStatus` | `ld_status` |
| 支付状态 | `isPay` | `OrderStatusDO.isPay` | `OrderStatusDAO.isPay` | `is_pay` |
| 发票状态 | `invoiceStatus` | `OrderInvoiceDO.status` | `OrderInvoiceDAO.status` | `invoice_status` |

---

## 六、已知未知项

| ID | 描述 | 影响 |
|---|---|---|
| U-06 | Android 平台本地锁的具体实现（synchronized vs 文件锁） | 影响并发安全 |
| U-07 | 云端 SDK QlExpress 表达式的具体管理方式 | 影响促销规则变更速度 |
| U-08 | WebSocket 心跳间隔和超时配置 | 影响连接稳定性 |
