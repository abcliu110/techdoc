# 微信点餐订单数据传递格式与DTO对照表

## 1. 目的

这份文档只回答两个问题：

1. 微信点餐订单在云端到门店之间，数据是怎么传的
2. 每一步的数据格式和 DTO 长什么样

---

## 2. 总览

微信点餐订单不是直接同步数据库表，而是不断切换“数据载体”：

```text
前端 JSON
  ->
CashPostOrderDTO
  ->
云端 Redis / 云端订单对象
  ->
OrderMsgDTO + OrderDataDTO
  ->
门店本地 DwdBillCreateDTO
  ->
本地 dwd_bill / dwd_food / dwd_pay
  ->
ConfirmOrderDTO
  ->
回告云端
```

---

## 3. 第 1 步：前端提交到云端

### 3.1 载体

- HTTP POST Body
- `CashPostOrderDTO`

定义：

- [CashPostOrderDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/order/CashPostOrderDTO.java)

### 3.2 核心字段

| 字段 | 含义 |
| --- | --- |
| `msgId` | 本次请求/回调关联号 |
| `orderId` | 订单号 |
| `order` | 订单主信息，类型是 `OrderBillAddDTO` |
| `foodList` | 菜品列表，压缩结构 `CompressedVO` |
| `payList` | 支付列表，压缩结构 `CompressedVO` |
| `locked` | 是否锁定 |
| `viewMode` | 页面显示模式 |
| `desc` | 错误或提示信息 |
| `tableNo` | 桌号 |
| `tblTypeLid` | 桌台类型 ID |

### 3.3 数据格式示例

```json
{
  "msgId": "1900000000000000001",
  "orderId": "E202605030001",
  "tableNo": "A01",
  "tblTypeLid": 10001,
  "viewMode": 1,
  "order": {
    "mid": 1001,
    "sid": 2001,
    "orgBillId": "WX202605030001",
    "saasOrderKey": "E202605030001",
    "personNum": 2,
    "tableNo": "A01",
    "openId": "oAbc123",
    "payType": 1,
    "remark": "少辣"
  },
  "foodList": {
    "data": "..."
  },
  "payList": {
    "data": "..."
  }
}
```

---

## 4. 第 2 步：订单主信息 `OrderBillAddDTO`

### 4.1 定义

- [OrderBillAddDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/order/OrderBillAddDTO.java)

### 4.2 关键字段

| 字段 | 含义 |
| --- | --- |
| `mid` | 商户 ID |
| `sid` | 门店 ID |
| `orgBillId` | 外部/原始账单号 |
| `saasOrderKey` | SaaS 订单号 |
| `personNum` | 就餐人数 |
| `foodAmount` | 菜品金额 |
| `discountAmount` | 折扣金额 |
| `serviceChargeAmount` | 服务费 |
| `orgAmount` | 原始金额 |
| `paidAmount` | 应付/实付相关金额 |
| `channelName` | 渠道 |
| `areaName` | 区域 |
| `tableNo` | 桌号 |
| `tableName` | 桌台名称 |
| `openId` | 微信用户标识 |
| `remark` | 备注 |
| `saasOrderRemark` | 线上订单备注 |
| `orderType` | 线上订单类型 |
| `orderStatus` | 线上订单状态 |
| `payType` | 支付模式 |

### 4.3 作用

它是“云端订单主单”的数据格式，不是门店本地 `dwd_bill` 本身。  
门店收到后，会从它映射成本地 `DwdBillCreateDTO`。

---

## 5. 第 3 步：菜品明细 `OrderFoodAddDTO`

### 5.1 定义

- [OrderFoodAddDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/order/OrderFoodAddDTO.java)

### 5.2 关键字段

| 字段 | 含义 |
| --- | --- |
| `mid` | 商户 ID |
| `sid` | 门店 ID |
| `lid` | 菜品记录 ID |
| `saasOrderKey` | 订单号 |
| `saasOrderNo` | 订单流水 ID |
| `foodNo` | 菜品编号 |
| `foodCode` | 菜品编码 |
| `foodName` | 菜名 |
| `foodUnit` | 单位 |
| `foodProPrice` | 售价 |
| `foodOrgPrice` | 原价 |
| `foodNumber` | 数量 |
| `sendNumber` | 赠送数量 |
| `foodAmount` | 菜品金额 |
| `discountAmount` | 折扣金额 |
| `serviceChargeAmount` | 服务费 |
| `paidAmount` | 应付金额 |
| `foodTaste` | 口味 |
| `foodPractice` | 做法 |
| `remark` | 备注 |
| `foodRemark` | 菜品备注 |
| `cancelNumber` | 退菜数量 |
| `enableGiveBalance` | 是否可赠余额 |

### 5.3 作用

它表示云端订单中的菜品列表。  
门店本地接单后，后续会把这些信息转换成本地 `dwd_food` 记录。

---

## 6. 第 4 步：支付信息 `OrderPayAddDTO`

### 6.1 定义

- [OrderPayAddDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/order/OrderPayAddDTO.java)

### 6.2 关键字段

| 字段 | 含义 |
| --- | --- |
| `mid` | 商户 ID |
| `sid` | 门店 ID |
| `saasOrderKey` | 订单号 |
| `saasOrderNo` | 订单流水 ID |
| `id` | 支付方式/支付记录 ID |
| `name` | 支付名称 |
| `type` | 支付类型 |
| `payAmount` | 支付金额 |
| `exchangeAmount` | 兑换金额 |
| `amount` | 金额 |
| `isRealIncome` | 是否实收 |
| `shiftName` | 班次 |
| `checkoutBy` | 收银员 |
| `couponNo` | 券号 |
| `taskLid` | 任务 ID |
| `giveAmount` | 赠送金额 |

---

## 7. 第 5 步：云端发给门店的订单消息

### 7.1 载体

- `OrderMsgDTO`
- `OrderDataDTO`

定义：

- [OrderMsgDTO.java](D:/mywork/nms4cloud/nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-api/src/main/java/com/nms4cloud/order/api/dto/OrderMsgDTO.java)
- [OrderDataDTO.java](D:/mywork/nms4cloud/nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-api/src/main/java/com/nms4cloud/order/api/dto/OrderDataDTO.java)

### 7.2 `OrderMsgDTO` 核心字段

| 字段 | 含义 |
| --- | --- |
| `mid` | 商户 ID |
| `sid` | 门店 ID |
| `type` | 消息类型字符串，如 `cash-request` |
| `msgId` | 消息 ID |
| `msgType` | 枚举消息类型，如 `CASH_REQUEST` |
| `timeout` | 超时时间 |
| `time` | 发送时间 |
| `source` | 来源，默认 `nms4cloud` |
| `data` | 业务数据，类型是 `OrderDataDTO` |

### 7.3 `OrderDataDTO` 核心字段

| 字段 | 含义 |
| --- | --- |
| `sid` | 门店 ID |
| `id` | 请求 ID / 关联 ID |
| `tblId` | 桌台号 |
| `billId` | 账单号 |
| `billName` | 账单名称 |
| `cardId` | 会员卡号 |
| `openId` | 微信 openId |
| `pull` | 是否拉单/结账模式区分 |
| `mustOfflineOpenTbl` | 是否必须线下开台 |

### 7.4 消息 JSON 示例

```json
{
  "mid": 1001,
  "sid": 2001,
  "type": "cash-request",
  "msgId": "1900000000000000001",
  "msgType": "CASH_REQUEST",
  "timeout": "2026-05-03 22:10:00",
  "time": "2026-05-03 21:10:00",
  "source": "nms4cloud",
  "data": {
    "sid": 2001,
    "id": "1900000000000000001",
    "tblId": "A01",
    "billId": "E202605030001",
    "billName": "A01-01",
    "cardId": "VIP001",
    "openId": "oAbc123",
    "pull": true,
    "mustOfflineOpenTbl": false
  }
}
```

### 7.5 实际发送封装

`OrderUtil.sendMessageToShop(...)` 会把它再封装到 `MqMqttMsgAddDTO.msg` 里发给门店：

- [OrderUtil.java](D:/mywork/nms4cloud/nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-service/src/main/java/com/nms4cloud/order/util/OrderUtil.java:33)

也就是说门店通道里真正传输的是：

```text
MqMqttMsgAddDTO
  msg = JSON.toJSONString(OrderMsgDTO)
```

---

## 8. 第 6 步：门店本地建单 DTO

### 8.1 载体

- `DwdBillCreateDTO`

定义：

- [DwdBillCreateDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/admin/dwd_bill/dto/DwdBillCreateDTO.java)

### 8.2 关键字段

| 字段 | 含义 |
| --- | --- |
| `mid` | 商户 ID |
| `sid` | 门店 ID |
| `saasOrderKey` | 账单号/订单号 |
| `saasOrderNo` | 账单流水 ID |
| `billName` | 本地账单名 |
| `reportDate` | 营业日期 |
| `personNum` | 人数 |
| `foodAmount` | 菜品金额 |
| `paidAmount` | 支付金额 |
| `orderSubType` | 订单子类型 |
| `areaLid` | 区域 ID |
| `tableLid` | 桌台 ID |
| `tableId` | 桌台号 |
| `openId` | 微信用户 |
| `tableName` | 桌台名 |
| `createBy` | 开台人 |
| `cardNo` | 会员卡号 |

### 8.3 作用

这是门店本地真正用于创建 `dwd_bill` 的 DTO。  
云端消息进来后，不是直接写数据库，而是先转成这个 DTO，再调用：

- `dwdBillServicePlus.create(dwdBillCreateDTO, user)`

---

## 9. 第 7 步：门店回告云端

### 9.1 载体

- `ConfirmOrderDTO`

定义：

- [ConfirmOrderDTO.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/order/ConfirmOrderDTO.java)

### 9.2 字段

| 字段 | 含义 |
| --- | --- |
| `msgId` | 消息 ID |
| `orderId` | 订单号 |
| `orgBillId` | 原始账单号 |
| `billName` | 本地账单名 |
| `confirmStatus` | 接单状态 |
| `desc` | 说明信息 |

### 9.3 JSON 示例

```json
{
  "msgId": "1900000000000000001",
  "orderId": "E202605030001",
  "orgBillId": "WX202605030001",
  "billName": "A01-01",
  "confirmStatus": "CONFIRMED",
  "desc": "接单成功"
}
```

---

## 10. 一张表看完

| 阶段 | 主要 DTO / 格式 | 作用 |
| --- | --- | --- |
| 前端 -> 云端 | `CashPostOrderDTO` | 提交微信点餐订单 |
| 订单主信息 | `OrderBillAddDTO` | 表示云端订单主单 |
| 菜品明细 | `OrderFoodAddDTO` | 表示云端订单菜品 |
| 支付信息 | `OrderPayAddDTO` | 表示云端订单支付 |
| 云端 -> 门店 | `OrderMsgDTO + OrderDataDTO` | 通知门店处理订单 |
| 门店本地建单 | `DwdBillCreateDTO` | 创建本地 `dwd_bill` |
| 门店 -> 云端回告 | `ConfirmOrderDTO` | 回传接单结果 |

---

## 11. 最稳的说法

微信点餐订单的数据传递，本质上是：

- 前端用 JSON 提交订单
- 云端用 `CashPostOrderDTO` 管理订单态
- 云端再用 `OrderMsgDTO` 把“订单请求”发到门店
- 门店把消息映射成 `DwdBillCreateDTO`
- 最后才落成门店本地 `dwd_bill / dwd_food`

也就是说：

**传的是 DTO 和 JSON，不是数据库表直接复制。**
