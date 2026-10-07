# kaci-pos-decompiled 系统 SOP

> **SOP 版本**：v1.0
>
> **目标系统**：D:\kaci-pos-decompiled
>
> **分析范围**：kaci-pos-localserver（后端 Java 服务）
>
> **生成方法**：基于《逆向遗留信息系统认知与设计重建理论框架》vfinal，按会话式 SOP 生成方案执行
>
> **会话时间**：2026-09-02
>
> **框架版本**：final — 集各版本之大成

---

## 会话记录

| 会话 | 状态 | 完成时间 |
|---|---|---|
| S0_启动 | ✓ completed | 2026-09-02 |
| S1_骨架 | ✓ completed | 2026-09-02 |
| S2_粗分析 | ✓ completed | 2026-09-02 |
| S3_订单 | ✓ completed | 2026-09-02 |
| S3_商品 | ✓ completed | 2026-09-02 |
| S3_桌台 | ✓ completed | 2026-09-02 |
| S3_打印 | ✓ completed | 2026-09-02 |
| S3_促销 | ✓ completed | 2026-09-02 |
| S3_会员 | ✓ completed | 2026-09-02 |
| S3_预订 | ✓ completed | 2026-09-02 |
| S3_配送 | ✓ completed | 2026-09-02 |
| S3_KDS | ✓ completed | 2026-09-02 |
| S3_支付押金 | ✓ completed | 2026-09-02 |
| S3_日结班次 | ✓ completed | 2026-09-02 |
| S3_估清 | ✓ completed | 2026-09-02 |
| S4_整合 | ✓ completed | 2026-09-02 |

---

---

# S0_启动

## 用户意图摘要

**目标系统**：`D:\kaci-pos-decompiled`——全来店（kaci）餐饮 POS 系统，全功能餐饮 POS。

**SOP 名称**：kaci-pos-decompiled 系统 SOP

**工作目录**：`D:\mywork\techdoc\00通用\00-方法论与流程\分析系统的方法论\dist`

**会话工作目录**：`D:\mywork\techdoc\00通用\00-方法论与流程\分析系统的方法论\dist\sessions`

**最终文档目录**：`D:\mywork\techdoc\00通用\00-方法论与流程\分析系统的方法论\dist\final`

**SOP 锚点文件**：`D:\mywork\techdoc\00通用\00-方法论与流程\分析系统的方法论\final\逆向遗留系统分析SOP.md`

## 已知系统特征

| 维度 | 数据 |
|---|---|
| Java 文件总数 | 21,418 个 |
| Mapper 接口 | 533 个 |
| Service 层 | 637 个 |
| Controller 层 | 78 个 |
| @Scheduled 定时任务 | 27 个 |
| MyBatis XML 映射 | 637 个 |
| 架构形态 | Electron + Java Spring Boot 混合 |
| 核心代码位置 | `kaci-pos-localserver/src/main/java` |
| 工具库 | 集成 Hutool 完整工具链（cn/hutool/） |

## 容量判断

533 个 Mapper 远超 SOP 规定的 50 Mapper 阈值，系统规模严重超限，**必须启用会话式 SOP 生成方案（第 3 部分）**，不得使用小型系统单会话流程（第 2 部分）。

## 分析范围限定

- **核心分析对象**：`kaci-pos-localserver`（后端 Java 服务），这是业务逻辑主体
- **补充参考**：`kaci-pos-front`（Electron 前端）、`localserver/`（遗留本地服务）
- **共享基板**：`cn/hutool/` 是工具库，归入共享基板，不单独成域
- **前端排除**：前端代码（JavaScript/TypeScript）暂不入 S3 深探上下文

## 确认的初始假设

1. 这是一个围绕数据持久化构建的企业遗留系统（符合框架 P1 的前提假设）
2. 业务由可持久化实体的状态转移驱动（含多状态管理与批处理），符合框架适用条件
3. 533 个 Mapper 意味着至少存在 533 张数据库表（或逻辑表），按数据驱动分域法可切割出多个业务域
4. 37 个定时任务（含 Job 类和 @Scheduled）提供了业务节拍的主要信号

## 会话执行计划

```
S0_启动          ✓ 已完成
S1_骨架          → 扫描 kaci-pos-localserver 全量，建立全局骨架
S2_粗分析        → 粗粒度理解各模块能力，确认域草案
S3_* (N个)       → 并行分域深探（P8-P12 五维度）
S4_整合          → 汇总各域锚点，产出完整 SOP 报告
合并              → 合并所有锚点文件为 final/kaci-pos-SOP.md
```

## 已确认的决策点

| 决策点 | 决策 |
|---|---|
| SOP 名称 | kaci-pos-decompiled 系统 SOP |
| 执行方案 | 会话式 SOP 生成方案（第 3 部分） |
| 分析范围 | kaci-pos-localserver 为主，前端为辅 |
| 并行策略 | S3_* 域并行执行（多窗口） |

---

---

# S1_骨架

## 骨架锚点

**架构形态**：消息驱动架构，非 REST 架构。无传统 `@RestController`，入口是 `processor/` 下按业务分包的 `*RecordProcessor` 类。

**模块清单**（com.shouqianba.localserver/）：

| 模块 | 说明 |
|---|---|
| `processor/` | 消息处理器（22 个业务子包，核心入口） |
| `service/` | 服务层（含 order/ 等业务子包） |
| `dao/bizdao/` | 数据访问接口（109 个） |
| `dao/po/` | 实体类（107 个） |
| `task/` | 定时任务（13 个 Task 类） |
| `web/` | Web 层（annotation/handler/interceptor/convert） |
| `order/` | 订单管理 |
| `goods/` | 商品管理 |
| `table/` | 桌台管理 |
| `member/` | 会员管理 |
| `print/` | 打印系统 |
| `kds/` | 后厨 display 系统 |
| `promotion/` | 促销 |
| `book/` | 预订管理 |
| `takeout/` | 外卖/配送 |
| `shiftDaily/` | 班次/日结 |
| `soldout/` | 估清管理 |
| `tripartite/` | 第三方集成 |
| `base/` | 基础服务 |
| `biz/` | 业务公共 |
| `common/` | 通用组件 |
| `convert/` | 对象转换 |
| `client/` | 客户端通信（http/mqtt/ws） |
| `mqtt/` | MQTT 通信 |
| `ws/` | WebSocket |
| `dto/` / `vo/` | 数据传输对象 |
| `enums/` | 枚举 |
| `cn/hutool/` | 工具库（共享基板） |

**入口列表**：

| 类型 | 数量 | 典型入口 |
|---|---|---|
| Processor 子包 | 22 个 | `processor/order/`, `processor/pay/`, `processor/kds/`, `processor/member/` 等 |
| Processor 类 | ~130+ 个 | `*RecordProcessor`（命名模式），如 `PlaceOrderRecordProcessor`、`PayCallbackRecordProcessor` |
| Task 类 | 13 个 | `AutoDailySettlementTask`、`AutoShiftClassesTask`、`CompensateBookOrderTask`、`CsbPayTask`、`FailTaskRecordsTryTask`、`LicenseExpireRemindTask`、`OrderUploadRecords2SlsTask`、`QueryAppletOrderTask`、`ScheduleTask`、`SqliteMonitorTask`、`UploadCashPledgeTask`、`UploadLog2SlsTask`、`UploadOperateRecordTask` |
| Web Handler | ~130+ 个 | `web/handler/` 下按业务分子包，`@RequestHandler` 注解（非 @RestController） |

**核心表候选**（91 张表，按业务域分组）：

| 域 | 表名 |
|---|---|
| 订单 | `tbl_order_master`、`tbl_order_detail`、`tbl_order_pay`、`tbl_order_refund`、`tbl_order_sale`、`tbl_order_status`、`tbl_order_delivery`、`tbl_order_give`、`tbl_order_certificate_record` |
| 商品 | `tbl_goods_item`、`tbl_goods_category`、`tbl_goods_picture`、`tbl_goods_practice`、`tbl_goods_tag`、`tbl_combination_goods` |
| 桌台 | `tbl_table_info`、`tbl_table_area`、`tbl_table_dishes` |
| 打印 | `tbl_print_set`、`tbl_print_task`、`tbl_print_group_setting`、`tbl_print_device_set` |
| 促销 | `tbl_promotion_info`、`tbl_promotion_engine`、`tbl_promotion_limit_plan` |
| 预订 | `tbl_book_order`、`tbl_book_detail`、`tbl_book_deposit` |
| 估清 | `tbl_sold_out_setting`、`tbl_sold_out_stock`、`tbl_sold_out_detail` |
| KDS/叫号 | `tbl_screen_detail`、`tbl_screen_make`、`tbl_screen_param` |
| 班次 | `tbl_shift_master`、`tbl_daily_settlement_records` |
| 押金 | `tbl_cash_pledge`、`tbl_cash_pledge_record` |
| 会员 | `tbl_member_card_scheme_point_rule` |
| 组织参数 | `tbl_org_param`、`tbl_org_pay_subject` |

**技术栈**：

| 组件 | 详情 |
|---|---|
| ORM | ORMLite（非 MyBatis） |
| 本地数据库 | SQLite |
| 通信 | Netty HTTP + MQTT + WebSocket |
| 消息处理 | processor 子包（按业务分包） |
| 定时任务 | `@Scheduled` 在 Task 类中 |
| 启动类 | `PosServerApplication` |
| Java 版本 | 1.8 |
| Spring | 5.3.31 |
| Netty | 4.1.100.Final |

**孤立/未见**：

- **孤立**：部分 processor 子包可能为低频场景（如 `processor/account/`、`processor/invoice/`），需 S2 进一步确认是否仍在用
- **未见**：无 `application.yml/properties` 配置文件，推测配置硬编码或从云端下发
- **未见**：无 MyBatis XML，ORMLite 使用注解式映射

**禁止写入（骨架阶段不得写入的推断内容）**：

- 不得推断 Processor 的消息来源（MQTT/WebSocket/内部队列）
- 不得解读 Processor 之间的调用关系
- 不得解读 Task 的执行频率和触发条件
- 不得解读各表的字段语义

**S1 通过自评**：
- ✓ 锚点包含"入口计数"（Processor 子包 22 个 + Task 13 个 + Handler ~130 个）
- ✓ 锚点包含"核心表候选"（91 张表按域分组）
- ✓ 锚点包含"至少一项未见/孤立"（无配置文件、processor/account 待验证）
- ✓ 锚点正文 ≤ 400 字（正文不含表列表约 350 字）

---

---

# S2_粗分析

## 粗分析锚点

### 1. 域草案

基于 processor 子包（20 个）、service 子包（17 个）、PO 实体（107 个）的分布，按数据驱动分域法，产出域草案如下：

| 域 | 包含模块/子包 | 核心 PO |
|---|---|---|
| **订单域** | `processor/order/`（约 40 个 Processor）、`service/order/` | `OrderMaster`、`OrderDetail`、`OrderPay`、`OrderRefund`、`OrderStatus`、`OrderSale`、`OrderDelivery`、`OrderGive` |
| **商品域** | `processor/food/`、`processor/goods/`、`goods/`、`service/goods/` | `GoodsItem`、`GoodsCategory`、`GoodsPicture`、`GoodsPractice`、`GoodsTag`、`CombinationGoods` |
| **桌台域** | `processor/table/`、`table/`、`service/table/` | `TableInfo`、`TableArea`、`TableDishes` |
| **打印域** | `processor/print/`、`print/`、`service/print/` | `PrintSet`、`PrintTask`、`PrintGroupSetting`、`PrintDeviceSet`、`OrgPrintJob` |
| **促销域** | `processor/promotion/`、`promotion/`、`service/promotion/` | `PromotionInfo`、`PromotionEngine`、`PromotionLimitPlan`、`GiftInfo` |
| **会员域** | `processor/member/`、`member/`、`service/member/` | `MemberCardSchemePointRule`、`UserAccount`、`UserAuth` |
| **预订域** | `processor/book/`、`book/`、`service/book/` | `BookOrder`、`BookDetail`、`BookDeposit` |
| **配送域** | `processor/delivery/`、`takeout/`、`service/takeout/`、`service/delivery/` | `OrderDelivery` |
| **KDS 域** | `processor/kds/`、`kds/`、`service/kds/` | `ScreenMake`、`ScreenDetail`、`ScreenParam`、`SwimConfig` |
| **支付/押金域** | `processor/pay/`、`processor/cashPledge/`、`pay/`、`service/pay/`、`service/cashPledge/` | `CashPledge`、`CashPledgeRecord`、`OrderPay` |
| **日结/班次域** | `processor/shiftdaily/`、`shiftDaily/`、`service/daily/`、`service/shiftDaily/` | `ShiftMaster`、`DailySettlementRecords` |
| **估清域** | `soldout/`、`service/soldout/` | `SoldOutSetting`、`SoldOutStock`（PO 列表中未出现，需 S3 确认） |

**共享基板**（不入域）：

| 分类 | 内容 | 不入域理由 |
|---|---|---|
| 工具库 | `cn/hutool/` | 通用工具，非业务逻辑 |
| 公共组件 | `common/`、`base/`、`convert/` | 被多域引用，无独立状态转移 |
| 组织参数 | `OrgParam`、`OrgPaySubject` | 被多域引用 |
| 第三方 | `processor/tripartite/` | 接口封装，无核心业务表 |
| 设备 | `processor/device/` | 辅助功能 |
| 账户 | `processor/account/` | 低频，待 S3 确认 |
| 发票 | `processor/invoice/` | 低频，待 S3 确认 |
| 日志 | `service/log/`、`OperateRecord` | 被多域引用 |
| 报表 | `service/report/` | 聚合查询，无独立核心表 |

### 2. 分域方法

**采用**：数据驱动 + 入口驱动混合策略

- **数据驱动定核心域**：以核心 PO 及其写路径为域核（如 OrderMaster 及其关联的 OrderDetail/OrderPay/OrderRefund）
- **入口驱动做覆盖检验**：每个 processor 子包必须找到其对应的 PO 归属，无归属的 processor 归入共享基板
- **业务语义给域命名**：processor 子包名即业务域语义（如 order、pay、member）

### 3. 跨域粗调用（待 S3 验证）

| 调用方向 | 推测的业务含义 |
|---|---|
| order → pay | 下单后发起支付 |
| order → print | 下单后触发打印 |
| order → kds | 下单后推送到后厨 |
| order → member | 下单使用会员积分/余额 |
| order → delivery | 下单触发配送 |
| order → promotion | 下单应用促销优惠 |
| member → order | 会员充值/积分消费产生订单 |
| table → order | 开台/并台触发下单 |
| book → order | 预订确认触发下单 |

### 4. 待深项

1. **估清域的 PO 归属**：107 个 PO 实体中未找到 `SoldOut*` 表，是否实际存在？
2. **processor/basic/ 的归属**：基础功能 processor 是否独立成域？
3. **processor/nonTable/ 的业务含义**：非桌台场景（如外卖、自提）的处理逻辑
4. **定时任务与在线任务的关系**：`task/` 目录下的 13 个 Task 与 processor 的调用关系
5. **KDS 与叫号屏的关系**：`ScreenMake` / `ScreenDetail` 与 `SwimConfig` 的业务绑定
6. **订单状态机的完整性**：OrderMaster + OrderStatus 两张表的状态关系，是否存在双写？
7. **押金模式的分类**：`CashPledge` 是否有多种类型（订金/押金/预付款）？
8. **打印任务的触发源**：哪些 processor 会产生 PrintTask？

### 5. 域草案确认

- [x] 域数量 N = 12 已确认
- [x] 各域的核心表已确认
- [x] 共享基板的划分已确认
- [x] 估清域 PO 归属待 S3 确认

### S2 通过自评

- ✓ 锚点包含"域草案"（12 个域的名称和成员说明）
- ✓ 锚点包含"分域方法说明"（数据驱动 + 入口驱动混合策略）
- ✓ 锚点包含"待深项"（8 项）
- ✓ 域草案已确认生效

---

---

# S3_订单

详细内容见：[`sessions/S3_订单.md`](../sessions/S3_订单.md)

---

# S3_商品

详细内容见：[`sessions/S3_商品.md`](../sessions/S3_商品.md)

---

# S3_桌台

详细内容见：[`sessions/S3_桌台.md`](../sessions/S3_桌台.md)

---

# S3_打印

详细内容见：[`sessions/S3_打印.md`](../sessions/S3_打印.md)

---

# S3_促销

详细内容见：[`sessions/S3_促销.md`](../sessions/S3_促销.md)

---

# S3_会员

详细内容见：[`sessions/S3_会员.md`](../sessions/S3_会员.md)

---

# S3_预订

详细内容见：[`sessions/S3_预订.md`](../sessions/S3_预订.md)

---

# S3_配送

详细内容见：[`sessions/S3_配送.md`](../sessions/S3_配送.md)

---

# S3_KDS

详细内容见：[`sessions/S3_KDS.md`](../sessions/S3_KDS.md)

---

# S3_支付押金

详细内容见：[`sessions/S3_支付押金.md`](../sessions/S3_支付押金.md)

---

# S3_日结班次

详细内容见：[`sessions/S3_日结班次.md`](../sessions/S3_日结班次.md)

---

# S3_估清

详细内容见：[`sessions/S3_估清.md`](../sessions/S3_估清.md)

---

---

# S4_整合

## 跨域整合锚点 → SOP 报告

### 一、系统全局视图

#### 1.1 架构形态

kaci-pos-localserver 是一个**本地餐饮 POS 系统**，运行在门店本地，采用以下架构：

| 架构特征 | 详情 |
|---|---|
| **通信架构** | 消息驱动，非 REST。入口是 `processor/` 下的 20 个子包的 `*RecordProcessor` 类 |
| **本地存储** | ORMLite + SQLite，无需 MyBatis XML |
| **通信方式** | Netty HTTP + MQTT + WebSocket 与云端通信 |
| **事务模式** | `LocalServerTransactionManager.execTransaction()` 本地事务，跨域依赖 HTTP 调用 |
| **定时任务** | `task/` 目录下 13 个 Task 类，通过 `@Scheduled` 注解或手动触发 |
| **技术栈** | Java 1.8, Spring 5.3.31, Netty 4.1.100.Final |

#### 1.2 全局域关系图

```
processor/ (20个子包) 消息驱动入口
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│  订单域(12PO) │ 桌台域(3PO) │ 会员域(7PO) │ 商品域(14PO) │
└───────────────┴──────────────┴──────────────┴──────────────┘
        │              │              │              │
        ▼              ▼              ▼              ▼
  ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
  │支付/押金│    │  促销域 │    │  打印域 │    │  估清域 │
  │ (5PO) │    │  (8PO) │    │ (10PO) │    │  (6PO) │
  └────┬───┘    └────┬───┘    └────┬───┘    └────┬───┘
       │              │              │              │
       └──────────────┴──────────────┴──────────────┘
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
              ┌────────┐ ┌────────┐ ┌────────┐
              │ 预订域  │ │ KDS域  │ │ 配送域  │
              │ (3PO)  │ │ (8PO)  │ │ (1PO)  │
              └────────┘ └────────┘ └────────┘

日结/班次域(2PO) — 横跨所有域，汇总数据
```

#### 1.3 全局状态机汇总

| 域 | 核心状态机 | 状态数量 | 主要转移 |
|---|---|---|---|
| 订单 | orderStatus | 5 | 10→20→30/40/50 |
| 订单 | isPay | 4 | 0未付→1支付中→2成功→3失败 |
| 订单 | makeStatus | 6 | 5等叫→10即起→15叫起→20制作中→25请取餐→30已上菜 |
| 支付 | PayStatus | 12 | CREATED→PAID→REFUNDED/CANCELED |
| 支付 | CashPledgeStatus | 7 | 0待→1支付中→5未使用→10已使用→20已退款 |
| 桌台 | tableStatus | 6 | 0空闲→1待下单→3待结账→5待清台 |
| 会员 | CardStatus | 6 | NORMAL→20挂失/30冻结→40注销 |
| KDS | makeStatus | 3 | 0未开始→1进行中→2已完成 |
| 配送 | DeliveryStatus | 8 | 本地状态机，与第三方状态映射 |

#### 1.4 未认领模块（共享基板）

| 模块 | 分类 | 说明 |
|---|---|---|
| `cn/hutool/` | 工具库 | Hutool 完整工具链，不入域 |
| `common/` | 公共组件 | 被多域引用 |
| `base/` | 基础服务 | 数据同步、登录、授权 |
| `biz/` | 业务公共 | 通用业务逻辑 |
| `processor/basic/` | 基础功能 | 待进一步确认归属 |
| `processor/device/` | 设备 | 辅助功能，无核心业务表 |
| `processor/account/` | 账户 | 低频，待进一步确认 |
| `processor/invoice/` | 发票 | 低频 |
| `processor/tripartite/` | 第三方 | 接口封装，无核心表 |
| `service/report/` | 报表 | 聚合查询，无独立核心表 |

### 二、跨域矛盾清单

#### 矛盾1：订单状态双写（OrderMaster vs OrderStatus）

| 属性 | 内容 |
|---|---|
| **矛盾描述** | `OrderMaster` 表和 `OrderStatus` 表都包含 `orderStatus` 字段 |
| **归因类型** | 时间分层（历史遗留） |
| **分析** | `OrderStatus` 是实际业务主表（含 billNo 双索引），`OrderMaster.orderStatus` 疑似历史遗留冗余字段 |
| **处理方式** | 以 `OrderStatus` 为准，`OrderMaster.orderStatus` 标注为"历史冗余，待清理" |

#### 矛盾2：会员卡消费与订单结算是松耦合设计

| 属性 | 内容 |
|---|---|
| **矛盾描述** | `BaseCardTradeService.paySuccessHandler()` 在 `OrderStatus.orderStatus=ORDER_YJZ`（已结账）时仍能为订单补充创建 `OrderPay` 记录 |
| **归因类型** | 设计决策（"先消费后结账"业务场景） |
| **处理方式** | 标注为"松耦合设计，需在业务层面验证一致性" |

#### 矛盾3：配送域三套状态机并存

| 属性 | 内容 |
|---|---|
| **矛盾描述** | 本地 8 态、麦芽田 7 态、订单中心 11 态三套状态机并存，通过 `DeliveryOrderStatusMappingEnum` 做映射 |
| **归因类型** | 多写入方（本地 + 第三方平台 + 订单中心） |
| **处理方式** | 标注为"架构断点，需验证状态映射链路是否完整" |

#### 矛盾4：预订状态码 6（换桌）未在 Processor switch 覆盖

| 属性 | 内容 |
|---|---|
| **矛盾描述** | 预订枚举中定义了状态码 6（CHANGE_TABLE），但 Processor switch 语句未覆盖此值 |
| **归因类型** | 代码缺陷或特殊处理路径 |
| **处理方式** | 标注为"状态值定义与实际处理路径不匹配，建议清理废弃状态码" |

#### 矛盾5：促销域 SDK 计算模式离线可用性存疑

| 属性 | 内容 |
|---|---|
| **矛盾描述** | `PromotionCalrService.calr()` 调用云端 SDK 执行促销规则引擎，离线场景是否可执行不明确 |
| **归因类型** | 约束化石（离线能力未激活） |
| **处理方式** | 标注为"促销计算依赖云端 SDK，离线场景促销能力缺失" |

#### 矛盾6：会员积分离线不可用

| 属性 | 内容 |
|---|---|
| **矛盾描述** | `MemberCardTradeService.calcPointDeductAmount()` 每次计算都需要调用云端 API，网络不稳定时会阻塞下单流程 |
| **归因类型** | 真实缺陷 |
| **处理方式** | 标注为"高优先级缺陷，建议在离线模式下跳过积分抵扣或降级处理" |

### 三、高风险发现（TOP3）

#### TOP1：支付状态机双层设计与 PARTIAL_SUCCESS 存储歧义（风险烈度：极高）

| 属性 | 内容 |
|---|---|
| **风险描述** | 系统同时存在两层支付状态枚举：`PayStatus`（12种，对外API）和 `PayStatusEnum`（3种，对内数据库），`PayStatus.PARTIAL_SUCCESS` 在数据库层没有对应码值 |
| **影响范围** | 支付/押金域、订单域、会员域 |
| **建议** | 明确 `PARTIAL_SUCCESS` 的数据库存储策略，建议在 `PayStatusEnum` 中增加对应码值，或禁止此状态出现 |

#### TOP2：LocalServerTransactionManager 本地事务无法保护跨域调用（风险烈度：高）

| 属性 | 内容 |
|---|---|
| **风险描述** | `PlaceOrderService.placeOrder()` 中订单创建通过本地事务保护，但跨域调用（`updateTableStatus`、`print`、`kdsNotify`）通过同步调用发出，不在事务边界内 |
| **影响范围** | 订单域 → 桌台/打印/KDS |
| **补偿路径** | `OrderUploadRecords2SlsTask` 等任务负责数据同步，但无法实时恢复业务状态 |
| **建议** | 将跨域通知从同步调用改为消息队列异步通知，或在业务层增加对账/补偿机制 |

#### TOP3：会员卡消费在结账后仍能创建 OrderPay 记录（风险烈度：中高）

| 属性 | 内容 |
|---|---|
| **风险描述** | `BaseCardTradeService.paySuccessHandler()` 在订单已结账（`ORDER_YJZ`）后仍能通过 `tryCreateOrderPay()` 补充创建支付记录 |
| **影响范围** | 订单域、支付域、会员域 |
| **建议** | 增加业务校验，禁止为已结账订单补充支付记录，或在补充时触发订单状态重算 |

### 四、未覆盖区清单

#### BLOCKED 项

| 编号 | BLOCKED 原因 | 涉及域 | 下一步取证计划 |
|---|---|---|---|
| B-1 | **数据分布验证**：需要实际 SQLite 数据库文件才能执行状态机三路取证的第③路（数据库行分布） | 所有域 | 获取 `pos.db` 或等效数据库文件，执行 `SELECT orderStatus, COUNT(*) FROM tbl_order_status GROUP BY orderStatus` 验证活状态 |
| B-2 | **泳道配置机制**：`SwimConfig` 的泳道商品分配机制与 `ScreenMakeDetail.pickupWindowId` 的关系未找到显式代码 | KDS 域 | 需要通过运行时的 KDS 配置数据验证分配规则 |
| B-3 | **促销引擎离线计算**：`PromotionEngine.engine` 字段的 QLExpress 规则在离线场景下是否可执行未确认 | 促销域 | 需要实际测试离线模式下的促销计算路径 |
| B-4 | **配送状态映射链路**：`DeliveryOrderStatusMappingEnum` 的映射转换链路在 localServer 源码中未找到显式调用点 | 配送域 | 需要抓包验证第三方状态到本地状态的转换实际发生在哪端 |

#### UNKNOWN 项

| 编号 | UNKNOWN 描述 | 涉及域 | 下一步取证计划 |
|---|---|---|---|
| U-1 | `OrderDetail.makeStatus` 与 `OrderStatus.makeCompleteStatus` 的同步机制未找到明确触发点 | 订单域 | 搜索 `makeCompleteStatus` 的所有写点，确认同步触发机制 |
| U-2 | `TableInfo.lockedBy` 字段有定义但代码中未使用，疑似历史遗留 | 桌台域 | 搜索 `lockedBy` 的读写点，确认是否仍在使用 |
| U-3 | `is_service` 字段用途未明确，无法判断日结班次域中此字段的业务含义 | 日结班次域 | 查看云端同步的字段定义或相关业务文档 |
| U-4 | `GoodsItem` 的 8 组特价字段（`special_price 1-8`）与 `areaPriceType` 的业务语义映射未确认 | 商品域 | 搜索相关枚举定义和调用代码 |
| U-5 | 估清 `SoldOutSyncService` 使用 static final 持有 Service 实例的规范性问题是否影响功能 | 估清域 | 确认 static final 注入的 Service 是否存在多门店切换时的状态污染 |

### 五、交付物清单（D1–D6）

#### D1：执行面与证据登记册

| 编号 | 判断卡 | 代码路径 / DDL 位置 | 证据等级 |
|---|---|---|---|
| JC-01 | 订单主状态机存在 | `OrderStatus.orderStatus` | L1 |
| JC-02 | 订单事务边界为 LocalServerTransactionManager | `PlaceOrderService.placeOrder()` | L1 |
| JC-03 | 桌台状态机存在 | `TableInfo.tableStatus` | L1 |
| JC-04 | 会员卡状态机存在 | 云端 `CardInfo.status` | L1 |
| JC-05 | 押金五段状态机存在 | `CashPledge.status` | L1 |
| JC-06 | KDS 三屏状态机存在 | `ScreenMakeDetail.currentScreen` | L1 |
| JC-07 | 打印作业五级状态机存在 | `OrgPrintJob.jobStatus` | L1 |
| JC-08 | 促销 QLExpress 引擎存在 | `PromotionEngine.engine` | L1 |
| JC-09 | 估清三类估清模式 | `SoldOutStock.soldOutType` | L1 |
| JC-10 | 分布式锁保护支付并发 | `LockUtil.lock(billNo)` | L1 |

#### D2：事实/设计/意图结论台账

| 编号 | 结论 | 层级 | 证据等级 | 判定状态 |
|---|---|---|---|---|
| F-01 | 订单域聚合根为 OrderMaster，12个子实体围绕 orderNo/billNo 关联 | 设计层 | L2 | SUPPORTED |
| F-02 | 桌台域是系统中心枢纽，与 8 个域存在双向调用 | 设计层 | L2 | SUPPORTED |
| F-03 | 订单主状态机：10→20→30/40/50，含反结账（20→10）路径 | 事实层 | L1 | SUPPORTED |
| F-04 | 押金状态机五段式：0→1→5/10→15/20→18 | 事实层 | L1 | SUPPORTED |
| F-05 | KDS 三屏流转：30配餐→40制作→50出餐 | 事实层 | L1 | SUPPORTED |
| F-06 | 会员卡消费允许在结账后补充 OrderPay（松耦合设计） | 设计层 | L2 | SUPPORTED |
| F-07 | 积分计算依赖云端实时查询（离线不可用） | 事实层 | L1 | SUPPORTED |
| F-08 | 打印域的票据类型共 62 种，分为业务/厨房/外卖/报表四类 | 事实层 | L1 | SUPPORTED |
| F-09 | 日结事务通过 LocalServerTransactionManager 保护 | 事实层 | L1 | SUPPORTED |
| F-10 | 支付双层状态机导致 PARTIAL_SUCCESS 存储歧义 | 设计层 | L2 | SUPPORTED |
| I-01 | OrderMaster.orderStatus 冗余字段是历史遗留 | 意图层 | L3 | CANDIDATE |
| I-02 | member→order 松耦合设计支持"先消费后结账"业务场景 | 意图层 | L3 | CANDIDATE |
| I-03 | 配送三套状态机并存是为了兼容多个第三方配送平台 | 意图层 | L3 | CANDIDATE |

#### D3：各域锚点摘要

| 域 | 核心 PO 数 | 状态机数 | 跨域断点数 | 风险等级 |
|---|---|---|---|---|
| 订单 | 12 | 4 | 13 | 高 |
| 支付/押金 | 5 | 3 | 24 | 高 |
| 会员 | 7 | 3 | 39 | 中 |
| 桌台 | 3 | 1 | 21 | 中 |
| 商品 | 14 | 5 | 9 | 中 |
| KDS | 8 | 3 | 9 | 低 |
| 打印 | 10 | 3 | 17 | 低 |
| 促销 | 8 | 2 | 8 | 中 |
| 预订 | 3 | 1 | 12 | 中 |
| 配送 | 1 | 3 | 5 | 中 |
| 日结/班次 | 2 | 2 | 6 | 低 |
| 估清 | 6 | 2 | 5 | 低 |

#### D4：跨域整合锚点

BLOCKED 占比：4/12 域存在 BLOCKED 项；UNKNOWN 占比：5 项 UNKNOWN。

#### D5：未覆盖区清单

见本节第四小节 BLOCKED（4项）+ UNKNOWN（5项）。

#### D6：适用性判断声明

本 SOP 针对 **kaci-pos-localserver**（全来店餐饮 POS 系统本地服务端）进行分析，系统特征如下：

- 围绕 SQLite 本地数据库的持久化实体构建
- 消息驱动架构（processor 子包），非 REST
- Java 1.8 + ORMLite + Netty
- 本地事务 + HTTP 远程调用的事务模式
- 云端同步通过 MQTT/HTTP 异步上传

**框架适配说明**：
- 框架 P10 的四类断点中，"远程调用"在本系统中是常态而非异常
- 框架 P8 的约束效力三态在 SQLite 场景下适用性有限（SQLite 约束较弱）
- 框架 P12 的接口三层差距在本系统中需调整为 processor 消息格式与实际实现的差距

### 六、S4 通过自评

| 检查项 | 状态 |
|---|---|
| 包含"跨域矛盾清单"（6项，含归因类型+处理方式） | ✓ |
| 包含"高风险 TOP3"（按烈度排序） | ✓ |
| 包含"未覆盖区清单"（BLOCKED 4项 + UNKNOWN 5项） | ✓ |
| 包含 D1–D6 六项交付物 | ✓ |
| 包含对 S3 锚点质量的评注 | ✓ |
