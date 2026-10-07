# DA8-收敛分析：KACI POS 系统架构模式与关键设计决策

> 分析日期：2026-08-31
> 源码基准：`kaci-pos-localserver` 全量 Java 反编译源码

---

## 一、架构模式识别（Evidence-Based）

### 模式 1：Context Object（上下文对象）

**源码证据** — `PosContext.java`

```java
public class PosContext {
    private static final Map<String, Object> cache;           // ConcurrentHashMap
    private static final Map<Class<?>, Object> beanLocks;    // 双重检查锁定用锁

    public static <T> T getBean(final Class<T> objClass) {
        final String className = objClass.getName();
        if (null == PosContext.cache.get(className)) {
            final Object lock = PosContext.beanLocks.computeIfAbsent(objClass, k -> new Object());
            synchronized (lock) {
                if (null == PosContext.cache.get(className)) {  // 双重检查锁定
                    PosContext.cache.put(className, objClass.newInstance());
                }
            }
        }
        return objClass.cast(PosContext.cache.get(className));
    }

    // 共享对象：Class:Key -> Value，支持跨组件通信
    public static <T> Boolean setShareObject(final Class<T> objClass, final String key, final T value)
    public static <T> T getShareObject(final Class<T> objClass, final String key)
    public static void clearShareObjectsByClass(final Class<?> objClass)  // 按类清理
}
```

**为什么这样设计**：

| 设计动机 | 解释 |
|---------|------|
| 规避 Spring 容器 | 项目使用 Netty 自托管，无 IOC 容器，self-made DI |
| 线程安全 | `ConcurrentHashMap` + 细粒度锁，避免全表锁竞争 |
| 生命周期管理 | `clearShareObjectsByClass` 支持按类型清理，防止内存泄漏 |
| 共享状态传递 | WebSocket 长连接无 HTTP 请求上下文，上下文对象承载会话数据 |

---

### 模式 2：Reactor Pattern（反应器模式）

**源码证据** — `PosServer.java`

```java
public static void start() {
    ServerCacheBuild.build();       // Step1: 构建本地缓存
    registerPosService();           // Step2: 注册 mDNS 服务发现
    startNettyServer();             // Step3: 启动 Netty NIO 服务器
}

private static void startNettyServer() {
    EventLoopGroup bossGroup = new NioEventLoopGroup();   // 接受连接
    EventLoopGroup workerGroup = new NioEventLoopGroup(); // 处理 I/O

    ServerBootstrap serverBootstrap = new ServerBootstrap();
    serverBootstrap.group(bossGroup, workerGroup);
    serverBootstrap.channel(NioServerSocketChannel.class);

    serverBootstrap.childHandler(new ChannelInitializer<SocketChannel>() {
        @Override
        protected void initChannel(final SocketChannel ch) {
            ChannelPipeline pipeline = ch.pipeline();
            pipeline.addLast(new HttpServerCodec());                    // HTTP 编解码
            pipeline.addLast(new ChunkedWriteHandler());                // 大文件流式写
            pipeline.addLast(new HttpObjectAggregator(10485760));        // 聚合 HTTP 请求
            pipeline.addLast(new WebSocketServerCompressionHandler());   // WebSocket 压缩
            pipeline.addLast(new WebSocketServerProtocolHandler(..., 10000, true, false)); // WebSocket
            pipeline.addLast(new IdleStateHandler(60L, 0L, 0L, TimeUnit.SECONDS)); // 60秒心跳
            pipeline.addLast(new IdleStateEventHandler());              // 空闲处理
            pipeline.addLast(new PosServerChannelHandler());            // 业务处理
            pipeline.addLast(new PosServerExceptionHandler());          // 异常处理
        }
    });

    serverBootstrap.bind(Integer.parseInt(SaasIniProperties.getServerPort())).sync();
}
```

**为什么这样设计**：

| 设计决策 | 原因 |
|---------|------|
| NIO 而非阻塞 IO | 支持数千并发连接，避免每连接一线成瓶颈 |
| Pipeline 责任链 | HTTP 编解码 → WebSocket → 心跳 → 业务 → 异常，每层单一职责 |
| 60 秒空闲心跳 | POS 设备移动网络不稳定，检测断连触发重连 |
| mDNS 服务注册 | 门店局域网内 POS Client 自动发现 LocalServer |
| `SO_LINGER=0` | 服务重启时强制关闭 TIME_WAIT 连接 |

---

### 模式 3：Strategy + Abstract Factory（策略 + 抽象工厂）

**源码证据** — `PrintTicketTypeEnum.java`

```java
public enum PrintTicketTypeEnum {
    // 堂食票据
    PREPARE(8001, "预结单") {
        @Override public PrinterStrategy getPrinterStrategy() {
            return new EatInDevicePrinterStrategyImpl();
        }
        @Override public TicketPrintStrategy getPrintDataStrategy() {
            return new BillTicketPrintStrategyImpl();
        }
    },

    // 厨房票据（制作单）
    MAKE(10001, "制作单") {
        @Override public PrinterStrategy getPrinterStrategy() {
            return new MakeTicketPrinterStrategyImpl();
        }
        @Override public TicketPrintStrategy getPrintDataStrategy() {
            return new MakeTicketPrintStrategyImpl();
        }
    },

    // 报告票据（带模板生成器）
    REPORT_BUSINESS_SUMMERY_DATA(-1001, "综合汇总") {
        @Override public PrinterStrategy getPrinterStrategy() {
            return new EatInDevicePrinterStrategyImpl();
        }
        @Override public TicketPrintStrategy getPrintDataStrategy() {
            return new BusinessTicketPrintStrategyImpl();
        }
        @Override public TemplateTicketGenerator getTicketGenerator() {
            return new BusinessReportTicketGeneratorImpl();
        }
    };

    // 抽象方法强制每个枚举实现
    public abstract PrinterStrategy getPrinterStrategy();
    public abstract TicketPrintStrategy getPrintDataStrategy();

    // 可选方法，有默认实现
    public TemplateTicketGenerator getTicketGenerator() {
        return new DefaultTemplateTicketGenerator();
    }
}
```

**为什么这样设计**：

| 设计决策 | 解释 |
|---------|------|
| 枚举承载策略 | 替代 Spring `@Component` 扫描，消除启动时的反射开销 |
| 三层抽象 | `PrinterStrategy`(设备) → `TicketPrintStrategy`(数据构建) → `TemplateTicketGenerator`(模板) |
| 负数类型码 | `REPORT_*` 使用负数(-1001~-9999)，与正数票据(8001~11001)分类隔离 |
| `isKitchenTicket()` | 静态方法按 type 识别票据流向：厨房打印 vs 前台打印 |
| 扩展机制 | 新增票据类型 = 新增枚举值 + 两个策略类，无需修改已有代码 |

---

### 模式 4：Selector / Registry（选择器 / 注册表）

**源码证据** — `PaySelector.java`

```java
public class PaySelector implements Selector<String, PayInterface> {
    private final Map<String, PayInterface> map;  // key=支付类型编码，value=支付服务

    public PaySelector() {
        this.map = new HashMap<>();
        map.put(PaySubjectCategoryEnum.CASH.getCode(),         PosContext.getBean(CashPayService.class));
        map.put(PaySubjectCategoryEnum.BANK_CARD.getCode(),   PosContext.getBean(BankCardPayService.class));
        map.put(PaySubjectCategoryEnum.OTHER_WAY.getCode(),    PosContext.getBean(BankCardPayService.class)); // 复用
        map.put(PaySubjectCategoryEnum.BILL_DISCOUNT.getCode(),PosContext.getBean(BillDiscountService.class));
        map.put(PaySubjectCategoryEnum.SCAN_CARD_PAY.getCode(),PosContext.getBean(ScanCardService.class));
        map.put(PaySubjectCategoryEnum.VOUCHER_KEY.getCode(), PosContext.getBean(VoucherKeyPayService.class));
        map.put(PaySubjectCategoryEnum.POSTPONE_PAYMENT.getCode(), PosContext.getBean(HoldConsumeService.class));
        map.put(PaySubjectCategoryEnum.CASH_PLEDGE.getCode(), PosContext.getBean(CashPledgePayService.class));
        map.put(PaySubjectCategoryEnum.MANUAL_SUPPLEMENT.getCode(), PosContext.getBean(ManualSupplementPayService.class));
        map.put(PaySubjectCategoryEnum.MEMBERSHIP_CARD.getCode(), PosContext.getBean(MemberPayService.class));
    }

    @Override
    public PayInterface select(final String key) {
        final PayInterface payInterface = this.map.get(key);
        if (payInterface == null) throw new BusinessException("0101010904");
        return payInterface;
    }
}
```

**为什么这样设计**：

| 设计决策 | 解释 |
|---------|------|
| 构造函数注册 | 静态注册表，O(1) 查找，零反射开销 |
| 复用策略 | `OTHER_WAY`(其他方式) 复用银行卡服务，减少类数量 |
| 异常码 `0101010904` | 业务异常码体系，第9段=支付选择失败 |
| `PayInterface` 统一抽象 | 现金/银行卡/储值卡/券/挂账等10种支付统一接口 |
| `PosContext.getBean` | 支付服务也是通过 Context Object 获取单例 |

---

### 模式 5：Unit of Work（工作单元）+ 混合锁策略

**源码证据** — `LocalServerTransactionManager.java`

```java
public class LocalServerTransactionManager {
    private static final ThreadLocal<Integer> transactionDepth; // 嵌套事务深度

    public static <TT> TT execTransaction(final Callable<TT> callable) {
        final boolean isSQLite = DatabaseHelper.getInstance().getDatabaseType() == DatabaseType.SQLITE;

        if (isSQLite) {
            return executeWithSynchronizedLock(callable, startTime);  // SQLite: synchronized 锁
        }
        // MySQL/其他: ORM事务
        return TransactionManager.callInTransaction(connectionSource, callable);
    }

    private static <TT> TT executeWithSynchronizedLock(final Callable<TT> callable, ...) {
        final int depth = LocalServerTransactionManager.transactionDepth.get();
        transactionDepth.set(depth + 1);

        if (depth > 0) {  // 嵌套事务：跳过全局锁
            try {
                return callable.call();  // 直接执行，内部 SQL 复用外层连接
            } finally {
                if (newDepth <= 0) transactionDepth.remove();
            }
        }

        synchronized (CommonBaseDaoImpl.class) {  // 全局互斥锁
            try {
                return TransactionManager.callInTransaction(connectionSource, callable);
            } finally { ... }
        }
    }
}
```

**为什么这样设计**：

| 设计决策 | 原因 |
|---------|------|
| SQLite 无嵌套事务 | SQLite 事务不支持 SAVEPOINT，全局 synchronized 锁串行化 |
| 嵌套跳过锁 | `depth > 0` 时复用外层连接，避免同一线程重入锁开销 |
| `ThreadLocal` 深度 | 记录当前线程嵌套层数，支持多层 Service 调用链 |
| `isSQLite` 分支 | 开发环境 SQLite，生产环境 MySQL，两套事务语义 |
| 异常标准化 | 所有 SQL 异常统一包装为 `BusinessException("0101010001")` |

---

### 模式 6：Domain Object / Aggregate（领域对象 / 聚合根）

**源码证据** — `OrderMasterDO.java`（前80行）

```java
public class OrderMasterDO {
    // ========== 主档字段 ==========
    private Long id;
    private String billNo;           // 账单号
    private String orderNo;         // 订单号
    private Integer orderPass;      // 餐桌密码
    private String originalOrderNo; // 原订单号（反结账用）
    private Long workDate;          // 工作日期（账务归属日）

    // ========== 金额字段（BigDecimal） ==========
    private BigDecimal orderTotalAmount;       // 订单总金额
    private BigDecimal orderDiscountAmount;    // 订单折扣
    private BigDecimal payDiscountAmount;      // 支付优惠
    private BigDecimal actualReceiptAmount;    // 实收金额
    private BigDecimal pointAmount;           // 积分抵扣
    private BigDecimal depositUnpaidAmount;   // 未付定金
    private BigDecimal depositAmount;          // 已收定金

    // ========== 聚合内对象 ==========
    private List<OrderDetailDO> detailList;  // 订单明细（组合）
    private OrderStatusDO statusInfo;         // 状态快照
    private OrderSaleDO saleInfo;             // 促销信息
    private List<OrderPay> payList;           // 支付记录
    private List<OrderHoldConsume> holdConsumeList; // 挂账记录

    // ========== 业务方法 ==========
    public void pay(final OrderPay orderPay) { ... }
    public void cashPay(final OrderPay orderPay, final BigDecimal changeAmount) {
        this.actualReceiptAmount = this.actualReceiptAmount.add(orderPay.getActualReceiptAmount());
        this.payList.add(orderPay);
        this.saleInfo.pay(orderPay, changeAmount);
        if (orderPay.getPayAmount().compareTo(orderPay.getActualReceiptAmount()) != 0 ...) {
            this.payDiscount(orderPay);
        }
    }
}
```

**为什么这样设计**：

| 设计决策 | 解释 |
|---------|------|
| 聚合根模式 | `OrderMasterDO` 是订单聚合根，封装所有订单相关状态和行为 |
| 充血模型 | 支付计算 `cashPay()` 是对象方法，不是 service 层的过程代码 |
| BigDecimal 精确 | 金额字段全部使用 `BigDecimal`，避免浮点精度问题 |
| `orderPass` 口令 | 餐桌密码，支持取餐叫号场景 |
| `originalOrderNo` | 反结账关联原订单号，支持账务追溯 |
| `workDate` 长整型 | 毫秒时间戳，支持跨天营业场景 |

---

## 二、关键设计决策 DEC 卡

### DEC-1：Offline-First 本地优先架构

| 属性 | 内容 |
|------|------|
| **决策** | 所有业务操作优先访问本地 SQLite/MySQL，网络故障时仍可运营 |
| **证据** | `LocalServerTransactionManager.execTransaction()` 直接操作本地数据库 |
| **驱动因素** | 餐饮门店网络不稳定，不能因断网导致无法结账 |
| **权衡** | 牺牲数据实时一致性，换取可用性；通过定时同步补偿一致性 |

### DEC-2：枚举即工厂的策略注册

| 属性 | 内容 |
|------|------|
| **决策** | 打印票据类型用 `enum` 实现策略工厂，每个枚举值返回具体策略实例 |
| **证据** | `PrintTicketTypeEnum.PREPARE.getPrinterStrategy()` → `new EatInDevicePrinterStrategyImpl()` |
| **驱动因素** | 消除 Spring 容器依赖，编译期穷举所有票据类型，零遗漏 |
| **权衡** | 编译期固定，运行时新增票据需修改源码；换取了可预测性和零反射开销 |

### DEC-3：Netty Reactor + WebSocket 双通道

| 属性 | 内容 |
|------|------|
| **决策** | 使用 Netty NIO 处理 WebSocket 长连接，60 秒空闲心跳 |
| **证据** | `IdleStateHandler(60L, 0L, 0L)` + `PosServerChannelHandler` |
| **驱动因素** | POS Client 和 LocalServer 需双向实时通信（推送小票状态、叫号） |
| **权衡** | 连接管理复杂度增加；换取了低延迟和断线检测能力 |

### DEC-4：多数据库事务抽象

| 属性 | 内容 |
|------|------|
| **决策** | SQLite 用 `synchronized` 全局锁，MySQL 用 ORMLite `TransactionManager` |
| **证据** | `LocalServerTransactionManager` 中 `isSQLite` 分支逻辑 |
| **驱动因素** | 开发环境用 SQLite（零配置），生产环境用 MySQL（高并发） |
| **权衡** | 两套语义需分别维护；嵌套事务在 SQLite 下串行化，可能影响性能 |

### DEC-5：双层单例容器（Context + Bean）

| 属性 | 内容 |
|------|------|
| **决策** | `PosContext` 同时管理 POJO 单例 Bean 和会话级共享对象 |
| **证据** | `getBean(Class)` 懒加载单例，`getShareObject(Class, key)` 会话共享 |
| **驱动因素** | 无 Spring 容器但仍需 DI + WebSocket 无会话状态需上下文传递 |
| **权衡** | 手动管理生命周期，增加内存泄漏风险；`clearShareObjectsByClass` 作为补偿 |

### DEC-6：支付策略选择器路由

| 属性 | 内容 |
|------|------|
| **决策** | 10 种支付方式通过 `PaySelector` Map 注册，O(1) 路由 |
| **证据** | `PaySelector.select(key)` → 抛异常或返回 `PayInterface` |
| **驱动因素** | 支付方式频繁扩展（现金/银行卡/储值卡/外卖平台等） |
| **权衡** | 新支付方式需修改 `PaySelector` 构造函数；换取了无反射零开销查找 |

### DEC-7：聚合根内聚业务逻辑

| 属性 | 内容 |
|------|------|
| **决策** | `OrderMasterDO` 包含 `cashPay()`、`payDiscount()` 等业务方法 |
| **证据** | `OrderMasterDO.cashPay()` 直接操作 `actualReceiptAmount`、`payList` |
| **驱动因素** | 订单金额计算涉及多个字段的原子性更新，内聚更易维护 |
| **权衡** | 实体类承担了部分 Service 职责，可能导致领域模型膨胀 |

---

## 三、六格压榨精华

### 1. 核心架构图（文字版）

```
┌─────────────────────────────────────────────────────────┐
│                   POS Client (Electron)                  │
│                 WebSocket 长连接 (Netty)                  │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│              PosServer.startNettyServer()                 │
│  ┌────────────────────────────────────────────────────┐ │
│  │           ChannelPipeline（责任链）                   │ │
│  │  HttpCodec → ChunkedWrite → Aggregator              │ │
│  │  → WebSocket → IdleStateHandler(60s) →             │ │
│  │  ChannelHandler → ExceptionHandler                  │ │
│  └────────────────────────────────────────────────────┘ │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│           PosContext（上下文容器）                         │
│  ┌─────────────────┐  ┌──────────────────────────────┐ │
│  │  getBean()       │  │  getShareObject()            │ │
│  │  懒加载单例       │  │  会话级对象共享               │ │
│  │  双重检查锁定     │  │  Class:Key → Value           │ │
│  └─────────────────┘  └──────────────────────────────┘ │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│          LocalServerTransactionManager                    │
│  ┌──────────────────────┐  ┌────────────────────────┐   │
│  │  isSQLite?           │  │  SQLite → synchronized  │   │
│  │  ThreadLocal depth   │  │  MySQL → ORM TxManager  │   │
│  └──────────────────────┘  └────────────────────────┘   │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
┌─────────────────┐ ┌──────────────┐ ┌──────────────────┐
│ PrintTicketType │ │  PaySelector │ │  OrderMasterDO   │
│  Enum策略工厂   │ │  Map路由    │ │  聚合根         │
│ 80+票据类型     │ │  10种支付   │ │  充血模型        │
└─────────────────┘ └──────────────┘ └──────────────────┘
```

### 2. 关键技术栈

| 层级 | 技术选型 | 替代方案 | 选择原因 |
|------|---------|---------|---------|
| 网络通信 | Netty 4.x | Mina / 原生 NIO | 成熟稳定，Pipeline 生态完善 |
| WebSocket | Netty 内置 | Socket.IO | 减少依赖，与 Netty 一体化 |
| 数据库(开发) | SQLite + ORMLite | H2 / Derby | 零配置，文件级数据库 |
| 数据库(生产) | MySQL + ORMLite | JPA / MyBatis | ORMLite 轻量，无需 XML 配置 |
| 序列化 | FastJSON2 | Jackson / Gson | Alibaba 生态高性能 |
| 日志 | SLF4J + logback | Log4j2 | 无锁占位符，性能好 |

### 3. 核心权衡矩阵

| 权衡点 | 选择 | 代价 | 收益 |
|-------|------|------|------|
| 无 Spring 容器 | 手写 DI + Context | 生命周期管理负担 | 零启动开销，编译期穷举 |
| SQLite 本地存储 | 文件数据库 | 并发写入串行化 | 零配置，高可用离线运行 |
| 枚举策略工厂 | enum 替代注册中心 | 新增类型需改源码 | 编译期检查，零反射 |
| synchronized 全局锁 | SQLite 事务方案 | 高并发时吞吐量受限 | 实现简单，无死锁风险 |
| 聚合根充血模型 | 实体包含业务方法 | 实体类膨胀 | 状态变更内聚，易追踪 |

### 4. 可扩展性评估

| 维度 | 当前设计 | 扩展点 | 扩展成本 |
|------|---------|--------|---------|
| 新增票据类型 | `PrintTicketTypeEnum` | 新增枚举值 | 低（仅枚举+两个策略类） |
| 新增支付方式 | `PaySelector` | 构造函数注册 | 中（需改源码添加 map.put） |
| 新增打印机 | `PrinterStrategy` | 实现接口 | 中（需实现设备协议） |
| 新增业务域 | `PosContext` | getBean | 低（通用容器） |
| 数据库迁移 | ORMLite DAO | 实现 CommonBaseDaoImpl | 中（需写 SQL 迁移脚本） |

### 5. 性能特征

| 操作 | 路径 | 时间复杂度 | 瓶颈 |
|------|------|-----------|------|
| 获取支付服务 | `PaySelector.select()` | O(1) HashMap | 无 |
| 获取票据策略 | `PrintTicketTypeEnum.getXxx()` | O(1) 枚举 | 无 |
| 获取 Bean | `PosContext.getBean()` | 首次 O(n) 初始化，之后 O(1) | 首次反射调用 |
| 事务执行(SQLite) | `synchronized` | 串行化 | 全局锁竞争 |
| 事务执行(MySQL) | `TransactionManager` | 并发 | 数据库连接池 |
| WebSocket 消息 | Pipeline 责任链 | 每 Handler O(1) | 最长链路耗时 |

### 6. 架构风格归纳

```
┌──────────────────────────────────────────────────────────────────┐
│                       架构风格评分卡                              │
├──────────────────────────────────────────────────────────────────┤
│  分层架构     ████████████░░░░  6/10  （枚举与实体直接引用策略）    │
│  领域驱动     ██████████░░░░░░  7/10  （聚合根+充血模型清晰）      │
│  事件驱动     ████████░░░░░░░░  5/10  （缺乏领域事件机制）        │
│  响应式       ████████████████ 10/10  （Netty NIO 全异步）        │
│  可测试性     █████████░░░░░░░  6/10  （硬编码 PosContext 依赖）   │
│  可扩展性     ██████████░░░░░░  7/10  （策略模式扩展性好）        │
│  运维友好     ████████░░░░░░░░  5/10  （缺乏监控/链路追踪）       │
├──────────────────────────────────────────────────────────────────┤
│  主导范式：反应器(Reactor) + 策略(Strategy) + 上下文(Context)        │
│  次级范式：选择器(Selector) + 工作单元(Unit of Work) + 聚合根(Aggregate) │
└──────────────────────────────────────────────────────────────────┘
```

---

## 四、收敛结论

### 架构 DNA

1. **Reactor 网络层**：Netty 统治一切 I/O，无阻塞全异步
2. **策略路由层**：枚举即工厂，选择器替代 if-else
3. **事务边界层**：数据库类型决定锁策略，ThreadLocal 追踪深度
4. **上下文容器**：无 Spring 时代的自救式 DI + 会话状态共享
5. **聚合领域层**：订单即中心，金额计算内聚，支付记录追加

### 五大设计哲学

| 哲学 | 体现 | 反模式 |
|------|------|--------|
| 本地优先 | SQLite 离线可结账 | 过度依赖网络 |
| 零反射 | 枚举策略 + Map 选择器 | Spring 启动时扫描 |
| 简单锁 | SQLite synchronized 全局锁 | 分布式事务复杂度 |
| 编译期穷举 | 80+ 票据枚举 | 运行时动态发现 |
| 内聚优先 | OrderMasterDO 含业务方法 | 失血模型（纯数据结构） |

### 深度八关残留问题

| 层级 | 遗留问题 | 建议 |
|------|---------|------|
| L1 事件 | WebSocket 消息是否走统一领域事件？ | 待分析 PosServerChannelHandler |
| L2 幂等 | 支付重试是否防重？ | 待分析 PayInterface 幂等设计 |
| L3 补偿 | 网络中断时本地事务状态一致性 | 待分析 OrderHoldConsume 机制 |
| L4 扩展 | 枚举新增是否真的零成本？ | 新增枚举 + 策略类仍需改3个文件 |
| L5 观测 | 缺乏链路追踪和性能指标 | 待引入 Micrometer / SLF4J MDC |
| L6 事务 | 跨库（MySQL+SQLite）事务未覆盖 | 当前单库，设计如此 |
| L7 重构 | OrderMasterDO 膨胀趋势 | 可拆分 OrderPaymentService |
| L8 架构 | PosContext 是否应该被 Spring 替代 | 当前架构已稳定，重构成本高 |

---

*DA8 收敛完成 — 源码证据已固定，架构模式已归因，设计决策已归档。*
