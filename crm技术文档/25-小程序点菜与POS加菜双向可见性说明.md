# 小程序点菜与 POS 加菜双向可见性说明

日期：2026-06-06

## 1. 一句话结论

小程序开台点菜后，线下 POS 可以看到小程序点的菜；线下 POS 后续加的菜，小程序也可以看到，但前提是小程序重新拉取线下账单。

需要注意两个不同场景：

| 场景 | 小程序是否能看到 POS 后加菜 | 说明 |
| --- | --- | --- |
| 用户进入拉单页、订单状态页，或继续加菜前重新拉单 | 可以看到 | 小程序调用 `/order_bill/getOfflineOrderInfo`，云端向 POS 发起 `CASH_REQUEST`，POS 返回当前线下账单菜品。 |
| 用户一直停留在点菜页，只刷新购物车 | 通常不能自动看到 | 点菜页刷新的是 `/shopping_cart/get` 的云端 Redis 购物车，不是 POS 当前线下账单。 |
| POS 加菜后希望小程序页面立即自动变更 | 当前链路不保证 | 未看到 POS 加菜后主动推送小程序刷新账单的稳定链路。 |
| 云端后台或数据库直接查 `order_bill/order_food` | 默认不能按已落库订单理解 | `CASH_REQUEST` 拉单只是临时回传和缓存 POS 当前账单，不等于 POS 线下点菜自动写入云端订单表。 |

因此准确表述是：

> POS 后加的菜不是自动混入小程序购物车，而是通过小程序重新拉线下账单时展示。

另一个容易混淆的点是：

> 小程序重新拉单能看到 POS 当前账单，不代表 POS 纯线下点菜已经沉淀到云端 `order_bill/order_food`。云端真正保存线下后付账单，通常发生在小程序付款链路读取 `cash_post_order` 临时缓存并执行 `saveCashPostOrder()` 时。

## 2. 涉及系统与数据源

| 系统 | 仓库 | 主要职责 |
| --- | --- | --- |
| 小程序前端 | `D:\mywork\taro-mall` | 点菜页、购物车、拉单页、订单状态页。 |
| 云端订单服务 | `D:\mywork\nms4cloud` | 提供 `/shopping_cart/*`、`/order_bill/*` 接口，保存购物车和订单中间态。 |
| 门店 POS | `D:\mywork\nms4pos` | 保存线下 `dwd_bill`、`dwd_food`，处理开台、加菜、结账和回传账单。 |

本问题的核心有两层：

1. 小程序页面当前读的是购物车，还是 POS 线下账单。
2. POS 线下账单只是被临时拉回展示，还是已经真正落到云端订单表。

## 3. 小程序点菜页读取的是购物车

小程序点菜页刷新菜品数量时，调用的是购物车接口：

| 前端文件 | 方法 | 接口 |
| --- | --- | --- |
| `D:\mywork\taro-mall\src\common\service\order\cart.ts` | `getCartDish` | `/shopping_cart/get` |
| `D:\mywork\taro-mall\src\pagePop\orderfoods\index.tsx` | `queryCart` | 调用 `getCartDish` 后写入 `orderStore` |

关键代码位置：

- `D:\mywork\taro-mall\src\common\service\order\cart.ts:29`
- `D:\mywork\taro-mall\src\pagePop\orderfoods\index.tsx:920`
- `D:\mywork\taro-mall\src\pagePop\orderfoods\index.tsx:936`

点菜页 `queryCart` 只把 `/shopping_cart/get` 返回的数据写入：

```ts
orderStore.setState(data)
```

这意味着点菜页的购物车角标、购物车明细、已选数量，主要来自云端 Redis 购物车。

云端购物车服务入口：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-app\src\main\java\com\nms4cloud\order\app\controller\ShoppingCartController.java`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\c\cart\ShoppingCartServicePlus.java`

`ShoppingCartServicePlus.get()` 会按 `sid/tblId/openId` 等 key 从 Redis 取 `ShoppingCartVO`：

- `ShoppingCartServicePlus.java:94`
- `ShoppingCartServicePlus.java:101`
- `ShoppingCartServicePlus.java:146`

所以，如果 POS 在本地账单里加菜，但没有把这些菜反写到云端购物车，小程序点菜页单纯刷新购物车时，不会天然看到 POS 后加的菜。

## 4. 小程序拉单读取的是 POS 当前线下账单

小程序拉单、订单状态、继续加菜前重新拉单，调用的是线下账单接口：

| 前端文件 | 方法 | 接口 |
| --- | --- | --- |
| `D:\mywork\taro-mall\src\common\service\order\bill.ts` | `getOfflineOrderInfo` | `/order_bill/getOfflineOrderInfo` |
| `D:\mywork\taro-mall\src\pages\Order\components\PullSingle\index.tsx` | 拉单查询 | 调用 `getOfflineOrderInfo` 后写入 `billStore.foodList` |
| `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx` | 订单状态查询 | 调用 `getOfflineOrderInfo` 后写入 `billStore.foodList` |

关键代码位置：

- `D:\mywork\taro-mall\src\common\service\order\bill.ts:13`
- `D:\mywork\taro-mall\src\pages\Order\components\PullSingle\index.tsx:302`
- `D:\mywork\taro-mall\src\pages\Order\components\PullSingle\index.tsx:317`
- `D:\mywork\taro-mall\src\pages\Order\components\PullSingle\index.tsx:320`
- `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx:97`
- `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx:111`
- `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx:114`

拉单返回后，小程序会解析 `data.foodList` 并写入 `billStore`：

```ts
const foodList = !_.isEmpty(data?.foodList) ? initResData(data?.foodList)?.data : []

billStore.addState({
  foodList,
  payList,
  order: data?.order || {},
  viewMode: data?.viewMode,
  desc: data?.desc || ''
})
```

这部分 `foodList` 表示 POS 当前线下账单菜品，而不是小程序购物车菜品。

## 5. 云端如何向 POS 拉取线下账单

云端入口：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-app\src\main\java\com\nms4cloud\order\app\controller\OrderBillController.java`
- 接口：`POST /order_bill/getOfflineOrderInfo`

服务实现：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java`
- 方法：`getOfflineOrderInfo`

关键代码位置：

- `OrderBillController.java:201`
- `OrderBillServicePlus.java:1366`
- `OrderBillServicePlus.java:1373`
- `OrderBillServicePlus.java:1376`

核心逻辑是：

1. 云端生成一次请求 `msgId`。
2. 云端通过 `orderUtil.sendMessageToShop()` 向门店 POS 发送 `CASH_REQUEST`。
3. POS 收到请求后读取本地当前账单。
4. POS 通过 `/order_bill/cash_post_order` 把 `CashPostOrderDTO` 回传云端。
5. 云端确认回传 `msgId` 仍然匹配本次等待中的拉单请求后，把回传内容临时写入 Redis，并返回给小程序。

## 6. POS 如何回传线下账单

POS 侧回传云端接口定义：

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\Nms4cloudOrderService.java`
- 方法：`cashPostOrder`
- 接口：`/order_bill/cash_post_order`

关键代码位置：

- `Nms4cloudOrderService.java:21`
- `Nms4cloudOrderService.java:22`

POS 侧生成线下账单回传数据的位置包括：

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\handler\CashRequestHandler.java`
- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\controller\biz\DwdBillOpsForBizController.java`

关键代码位置：

- `CashRequestHandler.java:93`
- `CashRequestHandler.java:221`
- `CashRequestHandler.java:332`
- `CashRequestHandler.java:334`
- `DwdBillOpsForBizController.java:495`
- `DwdBillOpsForBizController.java:630`

这些位置会构造 `CashPostOrderDTO`，其中 `foodList` 来自 POS 当前线下账单。只要 POS 本地账单已经包含后加菜，再次拉线下账单时，小程序就能拿到这些菜。

## 7. 云端收到 POS 回传后如何处理

云端接收 POS 回传：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-app\src\main\java\com\nms4cloud\order\app\controller\OrderBillController.java`
- 接口：`POST /order_bill/cash_post_order`

服务实现：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java`
- 方法：`cashPostOrder`

关键代码位置：

- `OrderBillController.java:383`
- `OrderBillServicePlus.java:1205`
- `OrderBillServicePlus.java:1317`
- `OrderBillServicePlus.java:1320`
- `OrderBillServicePlus.java:1326`
- `OrderBillServicePlus.java:1355`

云端收到 POS 的 `CashPostOrderDTO` 后，会先校验 `msgId` 是否仍在 `monoResponsive` 等待队列中：

1. 如果 `monoResponsive.hasMonoKey(msgId)` 为 `false`，说明这不是当前有效拉单请求的回包，或拉单请求已经过期；云端直接返回 `OK`，不会写入 Redis，也不会返回给前端。
2. 如果 `msgId` 仍有效，云端把回传内容转成 JSON。
3. 按 `OrderRedisConstants.getCashPostOderKey(saasOrderKey)` 写入 Redis，过期时间约 10 到 15 分钟。
4. 通过 `monoResponsive.set(msgId, cashPostMsg)` 返回给正在等待的前端拉单请求。
5. 同时调用 `shoppingCartServicePlus.setPersonNum()`，把人数、桌台类型、支付类型、原线下单号等单头上下文写入购物车。

因此，这个 Redis 缓存是一次成功拉单后的临时结果，不是 POS 后加菜自动后台同步出来的长期缓存。

需要注意：这里会同步单头上下文到购物车，但不是把 POS 全部 `foodList` 当作小程序购物车明细直接合并进去。

也需要注意：这里写入的是 `OrderRedisConstants.getCashPostOderKey(saasOrderKey)` 对应的 Redis 临时缓存，不是写入云端 `order_bill/order_food` 数据表。云端真正保存线下后付账单的代码在付款链路中：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java:239`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java:272`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java:310`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java:331`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\OrderBillServicePlus.java:350`

这条付款链路先读取 `getCashPostOderKey(orderId)` 的临时拉单缓存；如果存在 `CashPostOrderDTO`，才调用 `saveCashPostOrder()`，然后保存 `OrderBill` 和 `OrderFood`。

## 8. 为什么容易误解成“看不见”

这个问题容易混淆，是因为小程序里同时存在两份菜品列表：

| 前端状态 | 来源 | 含义 |
| --- | --- | --- |
| `orderStore.cartDishs.foodList` | `/shopping_cart/get` | 小程序购物车里还没正式提交的新点菜品。 |
| `billStore.bill.foodList` | `/order_bill/getOfflineOrderInfo` | POS 当前线下账单里已经存在的菜品。 |

小程序点菜页里有一些逻辑会同时参考这两份数据，例如计算已点数量时会看 `bill.foodList` 和 `cartDishs.foodList`：

- `D:\mywork\taro-mall\src\pagePop\orderfoods\index.tsx:1219`
- `D:\mywork\taro-mall\src\pagePop\orderfoods\components\TypesAndGoods\index.tsx:272`
- `D:\mywork\taro-mall\src\pagePop\orderfoods\components\DishsDetail\index.tsx:204`

但前提是 `billStore.bill.foodList` 已经通过重新拉单刷新过。如果用户一直停留在点菜页，并且没有触发重新拉线下账单，那么 `billStore` 里的线下菜品可能仍然是旧数据。

## 9. 实际业务判断

### 9.1 小程序点的菜，POS 是否能看见

可以。

小程序创建订单后，云端通过 `DO_ORDER` 或相关订单消息通知 POS，POS 再调用云端接口反查完整订单并落本地 `dwd_bill/dwd_food`。

关联文档：

- `D:\mywork\techdoc\crm技术文档\24-微信点菜到门店接单链路说明.md`
- `D:\mywork\techdoc\crm技术文档\小程序点菜\小程序点菜云端订单与门店本地表对应关系.md`

### 9.2 POS 后加的菜，小程序是否能看见

可以，但依赖重新拉线下账单。

小程序重新调用 `/order_bill/getOfflineOrderInfo` 后，POS 会返回当前本地账单的 `foodList`。如果 POS 加菜已经落入本地 `dwd_food` 并能被 `CashPostOrderDTO.foodList` 带出，小程序就可以显示。

### 9.3 POS 后加的菜，是否会自动进入小程序购物车

不应该按这个理解。

小程序购物车是云端 Redis 临时态，主要保存小程序用户准备提交的新菜。POS 后加的菜属于线下账单已有菜品，应该通过 `billStore.bill.foodList` 展示和参与数量判断，而不是混入 `orderStore.cartDishs.foodList`。

### 9.4 是否实时刷新

当前代码证据只能支持“重新拉单可见”，不能支持“POS 加菜后小程序当前页面自动实时可见”。

如果产品要求实时可见，需要新增或确认以下机制之一：

1. POS 加菜后主动通知云端和小程序刷新线下账单。
2. 小程序点菜页定时或在进入页面、返回前台时调用 `/order_bill/getOfflineOrderInfo`。
3. 小程序收到某种订阅消息或 websocket/mqtt 事件后重新拉单。

这些都属于新增行为，不是当前结论默认包含的能力。

### 9.5 POS 纯线下下单后，云端订单表是否马上有菜

默认不能按“马上有”理解。

`CASH_REQUEST -> CashPostOrderDTO` 是拉单展示链路，主要结果是返回给正在等待的小程序请求，并写入 10 到 15 分钟左右的 Redis 临时缓存。它不是 POS 线下点菜后主动把 `dwd_bill/dwd_food` 同步为云端 `order_bill/order_food` 的持久化链路。

只有后续进入小程序付款链路时，云端 `OrderBillServicePlus.pay()` 会读取这份 `cash_post_order` 临时缓存；如果读到有效的 `CashPostOrderDTO`，才调用 `saveCashPostOrder()` 把线下账单保存为云端 `OrderBill`，并把回传的 `foodList` 保存为 `OrderFood`。

所以现场说“门店下单，云端看不到菜品”时，要先确认“云端看不到”指的是哪一种：

| 现象 | 判断 |
| --- | --- |
| 小程序拉单页看不到 POS 已点菜 | 这是 `CASH_REQUEST` 拉单链路故障，需要查 POS 是否收到请求、是否查到本地 `dwd_bill/dwd_food`、是否回传 `foodList`。 |
| 云端后台或数据库 `order_bill/order_food` 查不到 POS 纯线下菜品 | 这通常是当前架构预期：未经过小程序付款保存前，线下菜品只在 POS 本地和拉单临时缓存中。 |

## 10. 建议验证用例

### 用例一：重新拉单可见

1. 小程序扫码进入桌台。
2. 小程序拉单或进入点菜。
3. POS 给同一桌台加一个菜，例如“青菜”。
4. 小程序返回拉单页，或订单状态页触发重新拉单。
5. 预期：小程序 `billStore.foodList` 中出现 POS 后加的“青菜”。

观察点：

- 小程序请求 `/order_bill/getOfflineOrderInfo`。
- 云端发送 `CASH_REQUEST`。
- POS 回传 `/order_bill/cash_post_order`。
- 回传 `CashPostOrderDTO.foodList` 中包含 POS 后加菜。

### 用例二：停留点菜页不实时可见

1. 小程序进入点菜页并保持不退出。
2. POS 给同一桌台加一个菜。
3. 小程序只触发 `/shopping_cart/get`，不触发 `/order_bill/getOfflineOrderInfo`。
4. 预期：小程序购物车 `orderStore.cartDishs.foodList` 不应自动多出 POS 后加菜。

观察点：

- 只有 `/shopping_cart/get` 请求时，返回的是 Redis 购物车。
- 没有重新拉线下账单时，`billStore.foodList` 不会被最新 POS 账单刷新。

### 用例三：继续加菜前刷新线下账单

1. 小程序已有线下账单。
2. POS 后加菜。
3. 小程序从订单状态页点击继续加菜。
4. 如果页面逻辑先调用 `get_offline_order_info()`，再进入点菜页。
5. 预期：点菜页的已点数量判断能包含最新 `bill.foodList`。

代码证据：

- `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx:124`
- `D:\mywork\taro-mall\src\pagePop\orderstatus\index.tsx:128`

## 11. 排查清单

如果现场反馈“小程序看不到 POS 加的菜”，按下面顺序查：

1. 小程序是否触发了 `/order_bill/getOfflineOrderInfo`，还是只触发了 `/shopping_cart/get`。
2. 云端 `OrderBillServicePlus.getOfflineOrderInfo()` 是否成功向门店发送 `CASH_REQUEST`。
3. POS 是否收到 `CASH_REQUEST`。
4. POS 回传的 `CashPostOrderDTO.foodList` 是否包含后加菜。
5. 云端 `/order_bill/cash_post_order` 的 `msgId` 是否仍在 `monoResponsive` 等待队列中；如果请求已过期，云端会直接返回 `OK`，不会写入 Redis。
6. 小程序是否把返回的 `data.foodList` 解压后写入 `billStore.foodList`。
7. 点菜页是否使用的是刷新后的 `billStore.bill.foodList`。

如果现场反馈“门店下单后云端后台或数据库看不到菜”，按下面顺序查：

1. 是否只是 POS 纯线下点菜，还没有小程序拉单付款；如果是，云端 `order_bill/order_food` 默认不应立即有完整菜品。
2. 小程序是否触发过 `/order_bill/getOfflineOrderInfo`，并成功生成 `cash_post_order` Redis 临时缓存。
3. 小程序是否继续走到付款接口，使 `OrderBillServicePlus.pay()` 读取到 `getCashPostOderKey(orderId)`。
4. `pay()` 中 `cashPostOrderVal` 是否为空；如果为空，`saveCashPostOrder()` 不会执行。
5. `saveCashPostOrder()` 是否成功保存 `OrderBill` 和 `OrderFood`。

## 12. 真正测试场景与真因定位

这次现场要测试的不是“购物车是否刷新”，而是：

> 门店 POS 先开台点菜，小程序随后调用 `/order_bill/getOfflineOrderInfo` 拉这张线下账单时，POS 是否把本地 `dwd_bill/dwd_food` 带回云端。

只要按下面顺序查，就能定位断在 POS 查单、POS 回传、云端接收缓存，还是后续付款落库。

### 12.1 现场先固定这些变量

| 变量 | 含义 | 来源 |
| --- | --- | --- |
| `mid` | 商户号 | 小程序用户上下文或云端日志。 |
| `sid` | 门店号 | 小程序请求体或云端日志。 |
| `tblId` | 小程序传给 `/getOfflineOrderInfo` 的桌台编号 | 前端请求体字段 `tblId`。 |
| `billId` | 小程序请求体里的线下单号，可为空 | 前端请求体字段 `billId`。 |
| `openId` | 云端 `setOrderInfo()` 写入的小程序用户 openId | 云端 `OrderBillController.setOrderInfo()`。 |
| `msgId` | 本次 `CASH_REQUEST` 请求号 | 云端日志“开始请求订单:{msgId}”。 |
| `saasOrderKey` | POS 本地线下账单号 | POS 本地 `dwd_bill.saas_order_key`，也是云端 `org_bill_id`。 |

### 12.2 第一优先级假设：按 openId 查单导致 POS 查不到线下账单

当前最值得先验证的真因是：

> 门店 POS 纯线下开台点菜时，`dwd_bill.open_id` 为空或不是当前小程序用户的 `openId`；但 POS 配置 `g_WXMCDDARSCXDDH` 开启后，`CashRequestHandler` 按桌台查单会追加 `open_id = 小程序 openId` 条件，导致 POS 本地明明有账单和菜，却没有查到这张单。

代码证据：

- `CashRequestHandler.java:71-77`：如果 `g_WXMCDDARSCXDDH=true`，优先走 `getOrderByTblId(mid, sid, tbl, openId)`。
- `CashRequestHandler.java:320-329`：`getOrderByTblId()` 会按 `mid/sid/table_lid/order_op_type/order_status` 查单，并且在 `openId` 非空时追加 `DwdBill::getOpenId = openId`。
- `OrderBillController.java:717-729`：云端会把当前登录小程序用户的 `openid` 写入请求。
- `DwdBillCreateDTO.java:157-158`：POS 创建账单 DTO 有 `openId` 字段，但它是可选上下文；纯线下开台通常不会天然带小程序 `openId`。

这条假设成立时，现场表现通常是：

1. POS 本地 `dwd_bill` 有同桌台未结账账单。
2. POS 本地 `dwd_food` 有菜品。
3. 小程序拉单后仍显示无菜或无账单。
4. POS 回传日志里 `CashPostOrderDTO.order` 为空，或者 `desc` 类似“此桌台无账单”。

### 12.3 POS 本地数据库检查

先确认小程序传入的 `tblId` 能映射到 POS 本地桌台：

```sql
select lid, id, name, type_code
from pt_tbl
where mid = :mid
  and sid = :sid
  and id = :tblId;
```

再查同桌台当前未结账账单。这里的 `table_lid` 用上一步查出的 `pt_tbl.lid`：

```sql
select lid,
       saas_order_key,
       saas_order_no,
       table_lid,
       table_id,
       table_name,
       open_id,
       order_op_type,
       order_status,
       start_time
from dwd_bill
where mid = :mid
  and sid = :sid
  and table_lid = :tableLid
  and order_op_type = 'N'
  and order_status in (:unCloseStatusList)
order by start_time desc;
```

判断标准：

| 检查结果 | 结论 |
| --- | --- |
| 有账单，`open_id` 为空或不等于小程序 `openId`，并且 `g_WXMCDDARSCXDDH=true` | 高概率就是 openId 过滤导致 POS 查不到单。 |
| 没有账单 | 不是云端问题，POS 本地当前桌台没有可被拉取的未结账普通账单，继续查桌台号、账单状态、订单类型。 |
| 有多张账单 | `onlyOne()` 可能异常或取不到明确结果，需要查是否同桌重复开台。 |

再确认菜品是否已经落到 POS 本地 `dwd_food`：

```sql
select lid,
       saas_order_key,
       saas_order_no,
       food_code,
       food_name,
       food_number,
       paid_number,
       food_amount,
       ordering_time
from dwd_food
where mid = :mid
  and sid = :sid
  and saas_order_key = :saasOrderKey
order by ordering_time, lid;
```

如果现场 `dwd_food` 不是按 `saas_order_key` 关联，也可以用上面 `dwd_bill.saas_order_no` 改查：

```sql
select lid,
       saas_order_key,
       saas_order_no,
       food_code,
       food_name,
       food_number,
       paid_number,
       food_amount,
       ordering_time
from dwd_food
where mid = :mid
  and sid = :sid
  and saas_order_no = :saasOrderNo
order by ordering_time, lid;
```

判断标准：

| 检查结果 | 结论 |
| --- | --- |
| `dwd_bill` 有账单且 `dwd_food` 有菜 | POS 本地数据具备回传条件，继续查 `CashRequestHandler` 是否查到了这张单。 |
| `dwd_bill` 有账单但 `dwd_food` 无菜 | POS 加菜没有真正落到该账单，问题在 POS 本地下单/加菜链路。 |
| `dwd_food` 有菜但关联到另一张 `saas_order_key/saas_order_no` | 账单号关联错，需要查 POS 本地账单拆并、转台、换台或加菜目标账单。 |

### 12.4 小程序拉单请求检查

抓小程序请求：

```text
POST /order_bill/getOfflineOrderInfo
```

重点看请求体：

```json
{
  "sid": "...",
  "tblId": "...",
  "billId": "可为空",
  "pull": true
}
```

云端进入接口后会覆盖用户上下文：

- `mid` 来自当前登录用户。
- `openId` 来自当前登录小程序用户。
- `sid < 0` 时会转成绝对值。

所以现场排查不能只看前端传参，还要在云端日志或调试中确认最终进入 `OrderBillServicePlus.getOfflineOrderInfo()` 的 `mid/sid/tblId/billId/openId`。

### 12.5 云端发送 CASH_REQUEST 检查

云端日志应出现：

```text
开始请求订单:{msgId}
```

并且 `OrderBillServicePlus.getOfflineOrderInfo()` 会发送：

```text
OrderMsgTypeEnum.CASH_REQUEST
data.billId = 请求 billId
data.tblId = 请求 tblId
data.openId = 当前小程序 openId
data.id = msgId
```

判断标准：

| 检查结果 | 结论 |
| --- | --- |
| 没有“开始请求订单”日志 | 请求没有进云端订单服务，先查网关、登录态或前端是否真的调用拉单接口。 |
| 有日志但 POS 没收到 | 查云端到门店的消息通道、门店在线状态、MQTT/Netty 路由。 |
| POS 收到但 `tblId` 对不上 `pt_tbl.id` | 桌台编号映射错误，POS 会回“不存在编号为 xx 的桌台”。 |

### 12.6 POS 收到 CASH_REQUEST 后检查

POS 日志重点找：

```text
upload order to nms4cloud:{...}
```

这个 JSON 就是 POS 回传给云端的 `CashPostOrderDTO`。重点看：

| 字段 | 期望 |
| --- | --- |
| `msgId` | 等于云端“开始请求订单”的 `msgId`。 |
| `order.orgBillId` | 等于 POS 本地 `dwd_bill.saas_order_key`。 |
| `order.openId` | POS 本地 `dwd_bill.open_id`，纯线下账单可能为空。 |
| `foodList` | 解压前也应看到非空压缩数据；为空就说明 POS 没把 `calc.getDwdFoods()` 带出。 |
| `desc` | 如果有错误提示，说明 POS 查单或业务校验失败。 |

对应代码：

- `CashRequestHandler.java:91-92`：`OrderServiceUtil.calc(mid, dwdBill.getLid())` 计算账单。
- `CashRequestHandler.java:146`：菜品来自 `calc.getDwdFoods()`。
- `CashRequestHandler.java:221`：菜品压缩写入 `CashPostOrderDTO.foodList`。
- `CashRequestHandler.java:332-334`：调用云端 `/order_bill/cash_post_order`。

判断标准：

| POS 回传情况 | 结论 |
| --- | --- |
| 没有 `upload order to nms4cloud` | POS 没收到消息，或处理器没执行到上传。 |
| 有回传但 `desc=此桌台无账单` | 优先查 `g_WXMCDDARSCXDDH/openId/table_lid/billId/order_status/order_op_type`。 |
| 有回传且 `foodList` 非空 | POS 已正确带出菜品，继续查云端是否接收并写 Redis。 |
| 有回传但 `foodList` 为空 | POS 查到了账单，但 `calc.getDwdFoods()` 没拿到菜，查 POS 本地 `dwd_food` 关联和账单计算链路。 |

### 12.7 云端接收 POS 回传检查

云端收到 POS 回传后应进入：

```text
POST /order_bill/cash_post_order
```

关键日志：

```text
上传订单:
{msgId}=>{CashPostOrderDTO JSON}
收到cash_post_bill消息：{CashPostOrderDTO JSON}
cash-request订单已经过期：{orderId}
```

判断标准：

| 云端接收情况 | 结论 |
| --- | --- |
| 没有“上传订单”日志 | POS 没成功调到云端，查门店到云端 HTTP、签名、网关、网络。 |
| 有“上传订单”，随后“cash-request订单已经过期” | `msgId` 不在 `monoResponsive` 等待队列，通常是回包超时、重复回包、服务实例不一致或请求已经结束；云端不会写 Redis，也不会返回给当前前端请求。 |
| 有“收到cash_post_bill消息” | 云端已接收有效回包并写入临时缓存。 |

临时缓存 key：

```text
CASH_POST_ORDER:{saasOrderKey}
```

其中 `{saasOrderKey}` 是云端本次小程序后付订单 key，也就是 `CashPostOrderDTO.order.saasOrderKey`。这份缓存过期时间约 10 到 15 分钟。

Redis 检查示例：

```text
GET CASH_POST_ORDER:{saasOrderKey}
TTL CASH_POST_ORDER:{saasOrderKey}
```

注意：这一步只是证明“拉单临时缓存存在”，仍不代表云端 `order_bill/order_food` 已经落库。

### 12.8 云端 order 表持久化检查

如果现场说的是“云端后台或数据库看不到菜品”，要把付款前和付款后分开查。

这里必须明确两个 API 的分工：

| 目的 | 小程序 API | 后端入口 | 作用 |
| --- | --- | --- | --- |
| 拉取 POS 当前账单用于展示和生成临时缓存 | `POST /order_bill/getOfflineOrderInfo` | `OrderBillController.getOfflineOrderInfo()` -> `OrderBillServicePlus.getOfflineOrderInfo()` | 发送 `CASH_REQUEST`，等待 POS 回传 `CashPostOrderDTO`，写入 `CASH_POST_ORDER:{orderId}` 临时 Redis。 |
| 小程序结账，让云端订单表真正有菜品 | `POST /order_bill/pay_order` | `OrderBillController.payOrder()` -> `OrderBillServicePlus.pay()` | 读取 `CASH_POST_ORDER:{orderId}`，调用 `saveCashPostOrder()`，保存 `order_bill/order_food`。 |
| 支付完成通知 | `POST /order_bill/pay_success` | `OrderBillController.paySuccess()` | 支付成功后的后续通知/收尾，不是保存 POS `foodList` 的主入口。 |

所以，如果目标是验证“云端数据库能看到 POS 菜品”，只调用 `/order_bill/getOfflineOrderInfo` 不够；必须在测试门店、测试账单、测试支付方式下继续触发 `/order_bill/pay_order`。如果不调用这个结账 API，云端最多只有 Redis 临时缓存，`order_food` 不落库是预期结果。

付款前，POS 纯线下点菜通常不应该已经写入云端订单表：

```sql
select lid,
       saas_order_key,
       org_bill_id,
       mid,
       sid,
       table_no,
       open_id,
       order_status,
       start_time
from order_bill
where mid = :mid
  and sid = :sid
  and (org_bill_id = :posSaasOrderKey or saas_order_key = :cloudSaasOrderKey)
order by start_time desc;
```

```sql
select lid,
       saas_order_key,
       saas_order_no,
       food_code,
       food_name,
       food_number,
       food_amount
from order_food
where saas_order_key = :cloudSaasOrderKey
order by lid;
```

付款后，如果小程序走了 `pay_order` 并且 `OrderBillServicePlus.pay()` 读到了 `CASH_POST_ORDER:{orderId}`，才会执行：

- `D:\mywork\taro-mall\src\common\service\order\bill.ts:141-145`：前端 `payOrder()` 调用 `/order_bill/pay_order`。
- `D:\mywork\taro-mall\src\pagePop\paycenter\index.tsx:702-705`：支付页传 `sid/orderId/orderPayList/h5`。
- `D:\mywork\taro-mall\src\pagePop\paymentcenter\index.tsx:468-471`：另一个支付页同样调用 `payOrder()`。
- `OrderBillController.java:432-447`：后端 `/pay_order` 入口，先 `setOrderInfo()`，再调用 `orderBillServicePlus.pay(request)`。
- `OrderBillServicePlus.java:239-260`：`pay()` 用 `request.orderId` 读取并删除 `CASH_POST_ORDER:{orderId}`。
- `OrderBillServicePlus.java:272`：调用 `saveCashPostOrder()`。
- `OrderBillServicePlus.java:310`：开始保存线下后付订单。
- `OrderBillServicePlus.java:315-331`：保存 `OrderBill`。
- `OrderBillServicePlus.java:333-350`：解压 `foodList` 并保存 `OrderFood`。

`/order_bill/pay_order` 请求体最小形态：

```json
{
  "sid": "...",
  "orderId": "必须等于 getOfflineOrderInfo 返回的 order.saasOrderKey",
  "orderPayList": [
    {
      "type": "WECHAT"
    }
  ],
  "h5": false
}
```

注意事项：

1. `orderId` 必须和 Redis key `CASH_POST_ORDER:{orderId}` 里的 `{orderId}` 一致；前端支付页里的变量通常叫 `saasOrderKey`。
2. `orderPayList` 不能为空，后端 `PayOrderDTO.orderPayList` 有 `@NotEmpty` 校验。
3. 如果使用微信支付，`pay_order` 可能只返回支付参数，真正支付成功后前端还会调 `/order_bill/pay_success`；但 POS 菜品落 `order_bill/order_food` 的关键读取和 `saveCashPostOrder()` 在 `pay_order` 里。
4. 现场排查不要直接对生产账单手工打支付接口；应在测试桌台、测试门店或可回滚的测试支付方式中触发小程序结账。

判断标准：

| 检查结果 | 结论 |
| --- | --- |
| 付款前 `order_bill/order_food` 没有 POS 菜品 | 架构预期，不是 `CASH_REQUEST` 故障。 |
| 拉单成功且 Redis 有 `CASH_POST_ORDER:{orderId}`，但付款后仍没落库 | 查 `pay_order` 是否传了同一个 `orderId`，以及 `saveCashPostOrder()` 是否执行/报错。 |
| 拉单失败或 Redis 无缓存，付款时自然不会保存 POS 菜品 | 回到 12.3 到 12.7 定位拉单链路。 |

### 12.9 最小现场复现步骤

建议现场只做这一组测试，不要混入其他桌台或其他用户：

1. POS 线下用指定桌台开台，点 1 个明显菜品，例如“测试青菜”。
2. 在 POS 本地查 `pt_tbl/dwd_bill/dwd_food`，记录 `table_lid/open_id/saas_order_key/saas_order_no`。
3. 同一个桌台用小程序调用 `/order_bill/getOfflineOrderInfo`。
4. 记录云端 `msgId` 和请求最终 `openId`。
5. 查 POS 日志 `upload order to nms4cloud`。
6. 查云端 `/cash_post_order` 日志和 Redis `CASH_POST_ORDER:{saasOrderKey}`。
7. 如果小程序继续付款，再查云端 `order_bill/order_food`。

预期能直接得出下面之一：

| 定位结果 | 真因 |
| --- | --- |
| POS 本地有账单有菜，但 `open_id` 与小程序 `openId` 不同，且 POS 回“此桌台无账单” | `g_WXMCDDARSCXDDH` 按人点餐配置导致 openId 过滤掉纯线下账单。 |
| POS 本地有账单有菜，POS 回传 `foodList` 非空，但云端报 `cash-request订单已经过期` | 云端等待回包超时、`msgId` 不匹配或多实例等待队列不共享。 |
| POS 回传 `foodList` 非空，云端也写了 Redis，但小程序页面不显示 | 前端没有使用本次 `getOfflineOrderInfo` 返回的 `data.foodList`，或页面还在看 `/shopping_cart/get`。 |
| 拉单页能看到，但云端 `order_food` 查不到 | 正常；还没有走付款保存，`CASH_REQUEST` 不是自动落库链路。 |
| 付款后仍查不到 `order_food` | 查 `pay_order` 的 `orderId` 是否等于 Redis 缓存 key，及 `saveCashPostOrder()` 是否执行。 |

## 13. 结论归档

最终结论：

1. 小程序点的菜，POS 可以看见，这是云端订单推门店接单链路。
2. POS 后加的菜，小程序可以看见，但通常需要重新拉取线下账单。
3. POS 后加的菜不会天然自动进入小程序购物车。
4. POS 纯线下点菜不会因为 `CASH_REQUEST` 自动持久化到云端 `order_bill/order_food`；`CASH_REQUEST` 只是拉单展示和临时缓存。
5. 云端真正保存线下后付账单，通常发生在小程序付款时读取 `cash_post_order` 缓存并执行 `saveCashPostOrder()`。
6. 如果要求“POS 一加菜，小程序点菜页立即实时刷新”或“POS 线下点菜立即沉淀云端订单表”，需要单独设计实时通知、前端拉单刷新或 POS 到云端的持久化同步机制。
