# DA1 业务切面分析 — 全来店 KACI POS 系统

> 版本：v1.0
> 分析基线：2026-08-30 反编译代码
> 状态：in_progress

---

## 一、业务域定位

### 1.1 系统位置

```
┌─────────────────────────────────────────────────────┐
│                    微信小程序                          │ ← 顾客自助点餐
└──────────────────────────┬──────────────────────────┘
                           │ WebSocket
                           ▼
┌─────────────────────────────────────────────────────┐
│             Electron 前端 (kaci-pos-front)            │ ← 收银员 UI
└──────────────────────────┬──────────────────────────┘
                           │ Netty HTTP/WebSocket
                           ▼
┌─────────────────────────────────────────────────────┐
│        Java 后端 (kaci-pos-localserver)              │
│  ┌──────────┬──────────┬──────────┬──────────┐    │
│  │  订单    │  支付    │ 促销    │  会员   │    │ ← 业务域
│  ├──────────┼──────────┼──────────┼──────────┤    │
│  │  桌台    │  打印    │  KDS    │  外卖   │    │
│  ├──────────┼──────────┼──────────┼──────────┤    │
│  │  预订    │  估清    │  押金    │  班结   │    │
│  └──────────┴──────────┴──────────┴──────────┘    │
│                                                      │
│  ┌──────────┬──────────┬──────────┐              │
│  │ Netty HTTP│ WebSocket │  MQTT   │              │ ← 通信层
│  └──────────┴──────────┴──────────┘              │
│  ┌──────────────────────────────────────┐        │
│  │      MySQL / SQLite / 云端 SDK         │        │ ← 数据层
│  └──────────────────────────────────────┘        │
└─────────────────────────────────────────────────────┘
```

### 1.2 业务价值

| 价值维度 | 说明 |
|---|---|
| 营收核心 | 所有业务操作最终汇聚到 OrderMasterDO，billNo 是全局唯一键 |
| 履约核心 | 订单→落单→KDS→制作→上菜，完整餐饮履约链路 |
| 资金核心 | 支付、退款、押金均围绕订单金额闭环 |
| 配置核心 | 促销、估清、会员规则均通过订单触发执行 |

---

## 二、核心角色

| 角色 | 操作集合 | 说明 |
|---|---|---|
| 收银员 | 开台/加菜/落单/结账/退款/撤单 | 日常运营核心角色 |
| 厨师 | 查看 KDS/完成制作/叫号 | KDS 交互 |
| 顾客 | 小程序点餐/支付/取餐 | 自助数字化 |
| 店长 | 日结/班结/反结账/权限管理 | 管理角色 |
| 系统 | 自动估清/促销计算/发票开具 | 后台自动 |

---

## 三、业务分类

### 3.1 收银/订单类

| 业务项 | 触发时机 | 说明 |
|---|---|---|
| 开台 | 顾客入座 | 创建订单 |
| 加菜 | 点菜 | PlaceOrderService |
| 落单 | 确认菜品 | DownOrderService → KDS |
| 叫起 | 通知厨房开始做 | WakeUpService |
| 催菜 | 顾客催促 | UrgeService |
| 换菜 | 修改菜品 | ReplaceOrderGoodsService |
| 结账 | 收款 | BasePayService |
| 反结账 | 修正错误 | RevCheckoutService |
| 撤单 | 取消整单 | RevokeOrderService |
| 退款 | 部分退款 | PartialRefundService |

### 3.2 厨房/履约类

| 业务项 | 触发时机 | 说明 |
|---|---|---|
| KDS 分单 | 落单 | ScreenMakeDo 创建 |
| 制作完成 | 厨房点击 | KDSMakeCompleteManager |
| 叫号 | 出餐 | KDSMakeCompleteAndCallHandler |
| 泳道管理 | 配餐 | SwimConfigDo |

### 3.3 资金/会员类

| 业务项 | 触发时机 | 说明 |
|---|---|---|
| 押金收取 | 开台时 | CashPledgePayHandler |
| 押金核销 | 结账时 | RefundOrderPledgeHandler |
| 会员开卡 | 新会员 | OpenCardHandler |
| 会员充值 | 充值 | RechargeHandler |
| 会员消费 | 刷卡 | MemberPayHandler |
| 积分累计 | 支付完成 | PaymentFollowUpService |

### 3.4 外卖/预订类

| 业务项 | 触发时机 | 说明 |
|---|---|---|
| 外卖接单 | MQTT 新订单 | NewTakeoutOrderService |
| 商家接单 | 后厨完成 | MakeCompleteTakeoutOrderHandler |
| 配送创建 | 发起配送 | CreateDeliveryOrderHandler |
| 预订 | 顾客预约 | BookOrderHandler |
| 订金 | 预订时收取 | BookDepositService |

### 3.5 运营/管理类

| 业务项 | 触发时机 | 说明 |
|---|---|---|
| 估清设置 | 商品管理 | SoldOutSetHandler |
| 班结 | 交班 | ShiftConfirmHandler |
| 日结 | 营业结束 | DailySettlementHandler |
| 发票开具 | 结账后 | InvoicingHandler |
| 发票红冲 | 反结账/退款 | CancelInvoiceHandler |

---

## 四、核心用例

### UC-ORDER-001：加菜落单

```
用例编号：UC-ORDER-001
参与者：收银员
前置条件：桌台已开台，存在有效订单
基本流程：
  1. 收银员选择菜品加入订单
  2. 收银员点击"落单"
  3. 系统执行校验（估清/重复/做法/标签）
  4. 系统执行促销重算
  5. 数据库事务更新订单/桌台/估清
  6. 系统创建 KDS 制作单
  7. 打印机打印厨房小票
后置条件：菜品已落单，KDS 显示制作单
异常处理：
  - 估清检查失败 → 提示换菜
  - 重复加单 → 拒绝或合并
```

### UC-PAY-001：支付结账

```
用例编号：UC-PAY-001
参与者：收银员、顾客
前置条件：订单有待结金额
基本流程：
  1. 收银员选择支付方式
  2. 系统执行分布式加锁
  3. 系统记录支付流水
  4. 系统检查自动结账条件
  5. 结账后自动打印小票
  6. 推送 WebSocket 通知
后置条件：订单状态变为已结账
异常处理：
  - 未付金额 > 0 → 继续等待支付
  - 堂食有未落单 → 拒绝结账
```

### UC-REFUND-001：部分退款

```
用例编号：UC-REFUND-001
参与者：收银员
前置条件：订单已结账，无进行中退款
基本流程：
  1. 收银员选择要退的商品
  2. 系统计算退款金额（含优惠分摊）
  3. 事务更新订单金额
  4. 系统执行促销重算
  5. 退款原路返回
后置条件：退款记录创建，订单金额更新
异常处理：
  - 退款金额超限 → 拒绝
  - 进行中退款存在 → 拒绝
```

---

## 五、触发时机图

```
开台 ──────────────────▶ 订单创建
                                │
落单 ──────────────────▶ KDS 制作单 ──▶ 制作完成 ──▶ 叫号
                                │
加菜 ──────────────────▶ 促销重算 ──▶ 估清预占
                                │
结账 ──────────────────▶ 支付流水 ──▶ 自动结账 ──▶ 发票开具
                                │
退款 ──────────────────▶ 优惠重算 ──▶ 退款原路返回
                                │
反结账 ───────────────▶ 发票红冲 ──▶ 积分退还
                                │
日结 ──────────────────▶ 估清同步 ──▶ 营业报表
```

---

## 六、已验证事实

| 事实 | 证据 |
|---|---|
| 订单是唯一核心实体，所有模块围绕 billNo 交互 | E-SRC: `OrderMasterDO.java` |
| Handler 通过 @RequestHandler 注解路由 | E-SRC: `web/handler/order/PlaceOrderHandler.java:19` |
| Service 继承层次清晰：OrderService 和 OrderGoodsOptService 两个分支 | E-SRC: `service/order/` 扫描结果 |
| WebSocket 统一入口为 LocalServerClientMsgDataListener | E-SRC: `service/order/wxApplet/LocalServerClientMsgDataListener.java:50` |
| 估清通过 occupy_num 与 usable_num 分离实现超售保护 | E-SRC: `service/soldout/SoldOutStockBizService.java` |
| 事务边界统一由 LocalServerTransactionManager 管理 | E-SRC: `common/LocalServerTransactionManager.java` |
