# DA0 - KACI POS 系统 Handler 入口清单侦察报告

## 1. 概述

**侦察目标**: KACI POS 系统 Handler 入口清单分析
**数据来源**: `call_function_kdyu4t3kdm00_1.txt` (394 条 Handler 记录)
**侦察时间**: 2026-08-31
**分析结论**: 系统采用 Netty + HTTP/WebSocket 双通道架构，HTTP Handler 注册到 `HttpRequestHandlerRegistry`

---

## 2. Handler 模块分布统计

| 模块分组 | Handler 数量 | 占比 | 核心功能 |
|----------|-------------|------|----------|
| **order** (订单) | 38 | 9.6% | 点餐/加菜/退菜/反结账 |
| **pay** (支付) | 22 | 5.6% | 支付/退款/撤销 |
| **member** (会员) | 35 | 8.9% | 会员卡/充值/消费 |
| **kds** (KDS厨房) | 18 | 4.6% | 厨房显示/叫号/完成 |
| **goods** (商品) | 15 | 3.8% | 菜品查询/分类/做法 |
| **table** (桌台) | 13 | 3.3% | 开台/并台/转台 |
| **report** (报表) | 17 | 4.3% | 营业报表/销售统计 |
| **shiftdaily** (日结) | 12 | 3.0% | 班次/日结/交班 |
| **cloudPrint** (云打印) | 22 | 5.6% | 打印设置/厨房打印方案 |
| **print** (打印) | 16 | 4.1% | 票据打印/打印队列 |
| **cashPledge** (押金) | 19 | 4.8% | 押金收取/退还 |
| **takeout** (外卖) | 11 | 2.8% | 外卖订单/配送 |
| **delivery** (配送) | 10 | 2.5% | 第三方配送 |
| **book** (预订) | 13 | 3.3% | 预订/排号 |
| **wine** (酒水寄存) | 10 | 2.5% | 酒水寄存/提取 |
| **basic** (基础) | 20 | 5.1% | 初始化/字典/班次 |
| **login** (登录) | 4 | 1.0% | 登录/登出/KDS快速登录 |
| **soldout** (沽清) | 7 | 1.8% | 沽清设置 |
| **promotion** (促销) | 7 | 1.8% | 优惠/优惠券 |
| **invoice** (发票) | 6 | 1.5% | 发票开具 |
| **groupBuying** (团购) | 4 | 1.0% | 券核销 |
| **device** (设备) | 3 | 0.8% | 设备注册/授权 |
| **org** (机构) | 3 | 0.8% | 机构注册/解绑 |
| **coupon** (优惠券) | 4 | 1.0% | 优惠券查询/核销 |
| **tripartite** (第三方) | 6 | 1.5% | 标签/RFID绑定 |
| **reserveFund** (备用金) | 3 | 0.8% | 备用金管理 |
| **nonTable** (非桌台) | 2 | 0.5% | 挂账/空单 |
| **log** (日志) | 3 | 0.8% | 操作日志 |
| **posui** (POSUI) | 2 | 0.5% | 界面模板 |
| **test** (测试) | 2 | 0.5% | 测试接口 |
| **kds/swim** (KDS泳道) | 5 | 1.3% | KDS泳道配置 |
| **kds/screen** (KDS屏幕) | 4 | 1.0% | 屏幕配置 |
| **other** | 8 | 2.0% | 其他杂项 |

**总计**: 394 个 Handler

---

## 3. 核心业务链路 E-SRC 证据

### 3.1 结账支付核心链路

| 序号 | Handler | URI | E-SRC 证据 |
|------|---------|-----|------------|
| 1 | `PayCashHandler` | `/pay/cash` | `PayCashHandler.java:18` |
| 2 | `PayCardHandler` | `/pay/card` | `PayCardHandler.java:18` |
| 3 | `PayCompleteHandler` | `/pay/payComplete` | `PayCompleteHandler.java:17` |
| 4 | `PayCancelHandler` | `/pay/cancel` | `PayCancelHandler.java:21` |
| 5 | `PayQueryHandler` | `/pay/query` | `PayQueryHandler.java:17` |
| 6 | `CashPledgeHandler` | `/pay/cashPledge` | `CashPledgeHandler.java:20` |
| 7 | `PartialRefundHandler` | `/pay/partialRefund` | `PartialRefundHandler.java:21` |

### 3.2 订单核心链路

| 序号 | Handler | URI | E-SRC 证据 |
|------|---------|-----|------------|
| 1 | `OrderLdHandler` | `/order/create` | `OrderLdHandler.java:24` |
| 2 | `PlaceOrderHandler` | `/order/placeOrder` | `PlaceOrderHandler.java:19` |
| 3 | `GetOrderDetailHandler` | `/orderDetail/getList` | `GetOrderDetailHandler.java:28` |
| 4 | `ModifyOrderDetailHandler` | `/orderDetail/modify` | `ModifyOrderDetailHandler.java:20` |
| 5 | `RevCheckoutHandler` | `/order/revCheckout` | `RevCheckoutHandler.java:19` |
| 6 | `WholeOrderRefundHandler` | `/order/wholeOrderRefund` | `WholeOrderRefundHandler.java:18` |
| 7 | `DownOrderHandler` | `/order/down` | `DownOrderHandler.java:25` |

### 3.3 会员核心链路

| 序号 | Handler | URI | E-SRC 证据 |
|------|---------|-----|------------|
| 1 | `OpenCardHandler` | `/member/openCard` | `OpenCardHandler.java:21` |
| 2 | `RechargeHandler` | `/member/recharge` | `RechargeHandler.java:21` |
| 3 | `CardConsumeHandler` | `/member/cardConsume` | `CardConsumeHandler.java:20` |
| 4 | `ConsumeResultHandler` | `/member/consumeResult` | `ConsumeResultHandler.java:18` |
| 5 | `BalanceRefundHandler` | `/member/balanceRefund` | `BalanceRefundHandler.java:21` |

### 3.4 登录认证链路

| 序号 | Handler | URI | E-SRC 证据 |
|------|---------|-----|------------|
| 1 | `LoginHandler` | `/login` | `LoginHandler.java:26` |
| 2 | `LogoutHandler` | `/logout` | `LogoutHandler.java:17` |
| 3 | `KdsLoginHandler` | `/pos/passport/posShortLogin` | `KdsLoginHandler.java:24` |
| 4 | `KdsQuickLoginHandler` | `/pos/passport/kdsQuickLogin` | `KdsQuickLoginHandler.java:23` |
| 5 | `DeviceRegisterHandler` | `/device/register` | `DeviceRegisterHandler.java:21` |

---

## 4. WebSocket 消息入口分析

### 4.1 入口架构

```
HTTP/WebSocket 请求入口
    │
    └── PosServerChannelHandler (Netty ChannelHandler)
            │
            ├── TextWebSocketFrame → WebSocket 消息处理 (当前版本仅关闭连接)
            │
            └── FullHttpRequest → HTTP 请求处理
                    │
                    └── HttpRequestHandlerRegistry.getRegistryMap()
```

**E-SRC 证据**:
- `PosServerChannelHandler.java:42` - Netty 消息入口类
- `PosServerChannelHandler.java:48` - WebSocket/Http 分支判断
- `PosServerChannelHandler.java:90` - Handler 路由查找

### 4.2 关键路径白名单 (无需机构验证)

以下路径在机构未注册时仍可访问:

| URI | 用途 | E-SRC 证据 |
|-----|------|------------|
| `/org/orgRegCheck` | 机构注册检查 | `PosServerChannelHandler.java:81` |
| `/org/orgReg` | 机构注册 | `PosServerChannelHandler.java:81` |
| `/device/register` | 设备注册 | `PosServerChannelHandler.java:81` |
| `/device/clearSiteInfo` | 清除站点信息 | `PosServerChannelHandler.java:81` |
| `/org/orgUnBindDevice` | 设备解绑 | `PosServerChannelHandler.java:81` |
| `/ping` | 健康检查 | `PosServerChannelHandler.java:69` |

### 4.3 请求处理线程池

- **线程池**: `ThreadPoolConfig.asyncProcessThreadPool`
- **E-SRC 证据**: `PosServerChannelHandler.java:106`

---

## 5. 定时任务入口分析

### 5.1 搜索结论

通过对源码的全面搜索:
- 未发现 Spring `@Scheduled` 注解
- 未发现 `SchedulingConfigurer` 配置
- 未发现 `ScheduledExecutorService` 业务任务调度

### 5.2 内部定时器

| 组件 | 用途 | E-SRC 证据 |
|------|------|------------|
| `HashedWheelTimer` (Netty) | Netty 内部超时管理 | `HashedWheelTimer.java:28` |
| `Timer/TimerTask` (io.socket) | Socket.IO 心跳超时 | `Manager.java:250` |
| `ScheduledExecutorService` (io.socket) | Socket.IO 心跳调度 | `Socket.java:88` |

**结论**: 定时任务通过 Netty 内部机制和业务 Handler 按需触发，未发现独立的定时任务入口。

---

## 6. Handler 注册机制

### 6.1 懒加载注册流程

```
首次请求 → HttpRequestHandlerRegistry.getRegistryMap().get(requestInfo)
                │
                ├── 命中 → 直接处理
                │
                └── 未命中 → PosServerRunner.initRequestHandler(requestInfo)
                                │
                                └── InterceptorRegistry.registryInterceptor(requestInfo)
                                        │
                                        └── 再次查找并处理
```

**E-SRC 证据**: `PosServerChannelHandler.java:91-94`

### 6.2 Handler 基类继承

所有 Handler 继承自 `BaseRequestHandler<T>`:

```
BaseRequestHandler<T>
    ├── order/*.java (38个)
    ├── pay/*.java (22个)
    ├── member/*.java (35个)
    ├── kds/*.java (18个)
    └── ... (其他模块)
```

---

## 7. URI 路由模式归纳

| 路由模式 | 示例 | Handler 数量 |
|----------|------|-------------|
| `/order/*` | `/order/create`, `/order/down` | 12 |
| `/orderDetail/*` | `/orderDetail/getList`, `/orderDetail/modify` | 9 |
| `/pay/*` | `/pay/cash`, `/pay/card` | 13 |
| `/member/*` | `/member/openCard`, `/member/recharge` | 20 |
| `/table/*` | `/table/getTableList`, `/table/tableOperate` | 10 |
| `/print/*` | `/print/billTicket`, `/print/cloudPrint` | 14 |
| `/report/*` | `/report/business`, `/report/goodsSale` | 13 |
| `/shiftDaily/*` | `/shiftDaily/shiftConfirm`, `/shiftDaily/dailySettlement` | 10 |
| `/cloud/*` | `/cloud/kitchenPrintSolution/*` | 15 |
| `/pos/screen/kds/*` | `/pos/screen/kds/complete` | 8 |

---

## 8. U-未知项 (待进一步侦察)

### U-1: WebSocket 实际消息处理
- **问题**: 当前代码 `PosServerChannelHandler.java:48` 对 WebSocket 帧仅执行关闭连接，未实现实际消息处理
- **可能**: WebSocket 功能可能未启用或通过其他通道实现
- **建议**: 搜索 `TextWebSocketFrame` 的实际消费逻辑

### U-2: 订单状态同步机制
- **问题**: `OrderLdHandler` 创建订单后，未发现状态同步到 KDS 的显式调用
- **可能**: 通过消息队列或轮询实现
- **建议**: 追踪 `DownOrderHandler` 后续调用链

### U-3: 日结自动触发机制
- **问题**: `DailySettlementHandler` 为手动触发，未发现自动日结调度
- **可能**: 日结由外部系统(如云端)触发
- **建议**: 搜索 `shiftDaily/executeDailySettlement` 的调用来源

### U-4: 操作日志持久化
- **问题**: `OperateRecordProcessorRegistry` 注册处理器，但未发现日志持久化入口
- **可能**: 日志通过异步队列批量写入
- **建议**: 追踪 `OperateRecordProcessor` 实现类

### U-5: 打印任务调度
- **问题**: `PrintBillTicketHandler` 生成打印任务，但未发现打印队列调度器
- **可能**: 打印任务由独立打印服务消费
- **建议**: 搜索 `GetPrintTicketJobHandler` 的消费逻辑

---

## 9. 侦察结论

### 9.1 入口复杂度
- **HTTP Handler**: 394 个
- **WebSocket 入口**: 1 个 (当前未启用消息处理)
- **定时任务**: 0 个 (未发现)

### 9.2 架构特征
1. **Netty 单端口多协议**: HTTP + WebSocket 共用 8848 端口
2. **懒加载 Handler**: Handler 按需注册，首请求时初始化
3. **异步处理**: 请求通过 `asyncProcessThreadPool` 异步执行
4. **无独立定时任务**: 业务时序依赖外部触发或 Handler 调用链

### 9.3 安全入口点
- **认证白名单**: 5 个路径支持未认证访问
- **机构绑定**: 除白名单外，均需机构已注册

---

**报告生成**: DA0 侦察分析
**文档版本**: v1.0
**下一步**: DA1 - 核心业务链路深度追踪
