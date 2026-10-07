# DA6 交互流程 — 全来店 KACI POS 系统

> 版本：v1.0
> 分析基线：2026-08-30 反编译代码
> 状态：in_progress

---

## 一、核心业务切片交互

### IX-01：加菜落单交互

```
参与者：收银员 → POS前端 → Netty HTTP → PlaceOrderHandler → PlaceOrderService
              → LocalServerTransactionManager（事务）
              → PrintService（厨房小票）
              → KDS（制作单）
              → WebSocket（tp_order_refresh）

触发事件：收银员点击"落单"
完成事件：KDS 屏幕显示制作单 + 厨房小票打印

步骤账本：
| 步骤 | 执行者 | 输入 | 规则/决策 | 状态变化 | 数据读写 | 副作用 | 失败恢复 |
| 1 | 收银员 | 选中菜品 | BR-ORDER-001估清检查 | — | 读订单 | — | 提示换菜 |
| 2 | 系统 | billNo | BR-ORDER-002禁止重复 | — | 读tbl_order_detail | — | 拒绝 |
| 3 | 系统 | — | BR-PROMO-001促销重算 | — | 读/写tbl_order_master | — | 降级本地 |
| 4 | 系统 | — | — | ORDER_DJZ | 写多个表 | — | 事务回滚 |
| 5 | 系统 | — | — | ldStatus=1 | 写tbl_order_detail | KDS+小票 | 重打 |
```

### IX-02：支付结账交互

```
参与者：收银员 → POS前端 → Netty HTTP → PayCashHandler → BasePayService
              → LockUtil.lock(order_lock_{billNo})
              → OrderPay（写）
              → autoCheckout（自动结账检查）
              → PrintService（结账单）
              → WebSocket（tp_pay_complete）

触发事件：收银员选择支付方式
完成事件：OrderPay 记录创建，订单状态变为 ORDER_YJZ

步骤账本：
| 步骤 | 执行者 | 输入 | 规则/决策 | 状态变化 | 数据读写 | 副作用 | 失败恢复 |
| 1 | 收银员 | 支付方式 | BR-PAY-001未付金额检查 | — | 读订单 | — | 拒绝 |
| 2 | 系统 | — | 分布式加锁 | — | — | 锁billNo | 超时退出 |
| 3 | 系统 | — | BR-PAY-002自动结账条件 | — | 读多表 | — | 继续等待 |
| 4 | 系统 | — | — | ORDER_YJZ | 写OrderPay | — | 事务回滚 |
| 5 | 系统 | — | — | — | — | 打印+推送 | 重打 |
```

### IX-03：小程序点餐交互

```
参与者：微信小程序 → WebSocket → LocalServerClientMsgDataListener
              → AppletOrderHandleService
              → PlaceOrderService（复用）
              → WebSocket（tp_order_refresh → 小程序）

触发事件：顾客在小程序点击"提交订单"
完成事件：POS 显示新订单，KDS 出现制作单

步骤账本：
| 步骤 | 执行者 | 输入 | 规则/决策 | 状态变化 | 数据读写 | 副作用 | 失败恢复 |
| 1 | 顾客 | 选中菜品 | — | — | — | — | — |
| 2 | 小程序 | — | — | — | — | WebSocket消息 | — |
| 3 | 系统 | WebSocket消息 | BR-ORDER-001 | — | 读tbl_order | — | 拒绝 |
| 4 | 系统 | — | — | ORDER_DJZ | 写tbl_order | KDS | — |
| 5 | 系统 | — | — | — | — | WebSocket推送小程序 | — |
```

---

## 二、WebSocket 消息清单

| 消息类型 | 方向 | 处理逻辑 | 证据 |
|---|---|---|---|
| `GET_BEGIN_TABLE` | 小程序→POS | 获取开台信息 | E-SRC: `LocalServerClientMsgDataListener.java:54` |
| `SELECT_PEOPLE` | 小程序→POS | 选择人数/确认开台 | E-SRC: `LocalServerClientMsgDataListener.java:58` |
| `SUBMIT_ORDER` | 小程序→POS | 提交订单 | E-SRC: `LocalServerClientMsgDataListener.java:66` |
| `CALL_WAITING` | 小程序→POS | 叫起 | E-SRC: `LocalServerClientMsgDataListener.java:70` |
| `SYNC_PROMOTION` | 小程序→POS | 同步促销 | E-SRC: `LocalServerClientMsgDataListener.java:74` |
| `PAY_ORDER` | 小程序→POS | 发起支付 | E-SRC: `LocalServerClientMsgDataListener.java:78` |
| `tp_order_refresh` | POS→小程序 | 订单刷新通知 | E-SRC: `WebSocketPushService.java` |
| `tp_pay_complete` | POS→前端 | 支付完成通知 | E-SRC: `PaySuccessSocketPushService.java` |

---

## 三、MQTT 消息清单

| 消息类型 | 来源 | 目标 | 处理逻辑 | 证据 |
|---|---|---|---|---|
| 新外卖订单 | 美团/饿了么 | POS | NewTakeoutOrderService.handleOrder | E-SRC: `takeout/mqtt/NewTakeoutOrderService.java` |
| 外卖退款 | 美团/饿了么 | POS | NewRefundTakeoutOrderService | E-SRC: `takeout/mqtt/NewRefundTakeoutOrderService.java` |
| 订单状态变更 | POS | 美团/饿了么 | UpdateTakeoutOrderService | E-SRC: `takeout/mqtt/UpdateTakeoutOrderService.java` |
| 价格变更 | 美团/饿了么 | POS | ChangePriceTakeoutOrderService | E-SRC: `takeout/mqtt/ChangePriceTakeoutOrderService.java` |

---

## 四、失败恢复矩阵

| 失败场景 | 检测方式 | 自动恢复 | 人工介入 | 升级路径 |
|---|---|---|---|---|
| 估清检查失败 | 运行时校验 | 拒绝加菜 | 换菜/取消估清 | 店长授权 |
| 支付超时 | 轮询 | 重试10次 | 手动确认 | 联系店长 |
| 打印机离线 | PrintService 异常 | 跳过/记录 | 修复后重打 | 运维处理 |
| KDS 无响应 | ScreenMake 创建失败 | 重试 | 手动重发 | 运维处理 |
| 云端促销失败 | SDK 超时 | 降级本地促销 | — | 日志排查 |
| 订单上传失败 | fail_task_records | 日结前重试 | 人工重传 | 运维处理 |

---

## 五、已知未知项

| ID | 描述 | 影响 |
|---|---|---|
| U-03 | WebSocket tp_order_refresh 的消费者是否只有小程序？前端是否也监听？ | 影响前端实时性 |
| U-04 | MQTT 消息的 QoS 级别和失败重试机制 | 影响外卖订单可靠性 |
