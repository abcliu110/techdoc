# 微信点餐链路中 Netty、RocketMQ、WebSocket 使用分析

## 1. 分析目标

本文基于以下 4 个仓库的只读源码分析：

- `D:\mywork\taro-mall`
- `D:\mywork\nms4pos-ui`
- `D:\mywork\nms4cloud`
- `D:\mywork\nms4pos`

目标是回答 4 个问题：

1. 微信点餐主链路是怎样的
2. 这套链路里 `Netty` 是怎么用的
3. 这套链路里 `RocketMQ` 是怎么用的
4. 这套链路里 `WebSocket` 是怎么用的

同时整理整条链路涉及到的核心技术组件。

## 2. 结论摘要

先给结论：

1. **微信点餐主链路本身不是通过 Netty 或 WebSocket 完成的，而是通过 HTTP API 完成的**
2. **Netty 主要用于门店设备长连接通信，比如打印端、设备端、POS 端的 topic 推送**
3. **WebSocket 主要用于门店本地前端实时刷新，比如收银前端、KDS 厨显前端**
4. **RocketMQ 主要用于异步解耦、延迟关单、消息补偿、MQTT 投递等后台任务**

换句话说：

- **微信小程序 / H5 点餐页面** 主要通过 `HTTP` 调后端
- **点餐后的前端界面刷新** 主要通过 `WebSocket`
- **点餐后的设备联动、打印联动** 主要通过 `Netty`
- **支付超时关单、支付后异步处理、MQTT 补偿** 主要通过 `RocketMQ`

---

## 3. 微信点餐主链路

## 3.1 微信登录

### 前端证据

`nms4pos-ui` 中：

- `components/taro/src/utils/getSessionKey.ts`

关键逻辑：

- 小程序模式下先调用 `Taro.login()`
- 拿到 `code`
- 再调用 `wxMaLogin(code, miniProgram.appId)`

这说明微信登录是标准的小程序登录流程，不涉及 Netty/WebSocket。

### 后端证据

`nms4cloud` 中：

- `nms4cloud-app/2_business/nms4cloud-crm/nms4cloud-crm-app/src/main/java/com/nms4cloud/crm/app/controller/biz/CrmAuthController.java`

关键接口：

- `POST /wxMaLogin`

控制器直接把请求交给 `wxLoginService.maLogin(request)`。

### 结论

微信登录链路是：

`微信小程序/H5 -> HTTP -> CRM 登录接口`

不是 Netty，也不是 WebSocket。

---

## 3.2 扫码进入点餐

### 前端证据

`taro-mall` 中：

- `src/common/service/pt/code.ts`
- `src/pagesIndex/pageIndex/index.tsx`

关键点：

1. 前端调用 `/pt_qr_bind/get`
2. 请求参数里带 `bizId(mid)` 和 `qrcodeKey(code)`
3. 后端返回二维码绑定信息后，前端按 `businesstype` 分流

`index.tsx` 中的 `handlePage()` 明确按以下业务类型跳转：

- `order`
- `takeout`
- `self_lifting`
- `book_mgr`
- `pay`
- `evaluate`
- `recharge`
- `shop_mall`

其中：

- `order` 是扫码点餐
- `takeout` 是外卖
- `self_lifting` 是自提

### 后端证据

`nms4cloud` 中：

- `nms4cloud-app/2_business/nms4cloud-product/nms4cloud-product-app/src/main/java/com/nms4cloud/product/app/controller/PtQrBindController.java`
- `nms4cloud-app/2_business/nms4cloud-product/nms4cloud-product-service/src/main/java/com/nms4cloud/product/service/PtQrBindServicePlus.java`

关键点：

1. `PtQrBindController` 提供 `/pt_qr_bind/get`
2. `PtQrBindServicePlus` 根据二维码绑定记录构造 `PtQrBindVO`
3. 对于 `order` / `dynamic_code` 场景，会进一步查桌台、门店、支付方式、是否允许点餐等信息

### 二维码生成证据

`PtQrBindServicePlus.add()` 中：

- 生成 `qrcodekey`
- 生成 H5 地址
- 生成小程序码地址

说明点餐码的本质是后端生成一个二维码业务 key，再把它与业务类型、门店、桌台绑定。

### 结论

扫码点餐主链路是：

1. 用户扫码
2. 前端拿到 `mid + code`
3. HTTP 调 `/pt_qr_bind/get`
4. 后端返回 `businesstype + sid + 桌台上下文`
5. 前端进入点餐页

这个过程依旧是 **HTTP 主导**。

---

## 4. Netty 是怎么用的

## 4.1 云端 Netty 服务

`nms4cloud` 中：

- `nms4cloud-app/1_platform/nms4cloud-netty/nms4cloud-netty-service/src/main/java/com/nms4cloud/netty/service/netty/services/NettyServer.java`

可见：

- 使用 `ServerBootstrap`
- 使用 `NioEventLoopGroup`
- 使用 `NioServerSocketChannel`
- 使用 `IdleStateHandler`
- 使用 `LengthFieldBasedFrameDecoder`
- 真实业务逻辑交给 `ServerHandler`

这说明它是一个标准的 Netty 长连接服务。

## 4.2 Netty 的核心工作模式：topic 订阅与推送

`ServerHandler.java` 中：

1. 连接端先发送订阅消息
2. 服务端把连接加入 `topic -> context` 映射
3. 后续按 `topic` 找连接并推送消息

也就是说，Netty 在这里承担的是：

- 设备注册
- topic 订阅
- 按 topic 推送
- 同步消息、异步消息、回包关联

这是一个典型的“设备消息总线”模式。

## 4.3 订阅消息还会同步到 RocketMQ

`ServerHandler.handleSubscribeMsg()` 中，会把订阅主题发送到：

- `RocketMqTopicConstants.NETTY_SUBSCRIBE`

说明 Netty 设备订阅不是完全局限在单机内存中，系统还会把订阅行为广播出去，方便别的模块感知订阅关系。

## 4.4 POS 业务如何使用 Netty

`nms4pos` 中：

- `OrderServiceUtil.java`
- `OtherPcHandler.java`

### 证据 1：打印推送

`OrderServiceUtil` 在打印相关逻辑里会构造：

- `Cmd`
- `Topic`
- `mqtt_content`
- `MsgID`

然后调用：

- `PushNettyService.sendMessage(req)`

说明业务系统会把打印任务封装成 Netty 消息发出。

### 证据 2：门店设备发送优先级

`OtherPcHandler.java` 里：

1. 优先通过 `devId + "_server"` topic 发送
2. 其次按 IP 通过 Netty 发送
3. 如果没有 Netty 或发送失败，再退回 HTTP

这说明：

- **Netty 是设备推送首选通道**
- HTTP 是兜底方案

## 4.5 本地 POS 也有自己的 Netty 服务

`nms4pos` 中：

- `nms4cloud-pos3boot/.../NettyServer.java`

它实现了：

- `PushNettyServerService`

并支持：

- 按 topic 发送
- 按 IP 发送
- 判断 topic 在线

说明门店本地也运行着自己的 Netty 服务，用来接设备、打印端、本地客户端。

## 4.6 打印端/客户端如何接入 Netty

`nms4cloud-pos10printer` 中：

- `app/netty/NettyClient.java`

关键逻辑：

1. 读取本地配置中的 `apiServerIp`
2. 连接本地 `9986`
3. 建立成功后自动发送 `subscribe`
4. 把本地 topics 订阅给服务端

这说明打印端或客户端本质上是：

- 一个 Netty client
- 连接 POS 本地服务
- 订阅属于自己的 topic
- 等待接收打印或业务指令

## 4.7 Netty 在微信点餐中的角色

### 结论

Netty 在微信点餐中的位置不是：

- 小程序和后端之间的请求协议

而是：

- 点餐成功后通知设备
- 推送打印任务
- 推送到设备客户端
- 承担门店设备长连接通道

可以把它理解成：

**“微信点餐后的设备联动层”**

---

## 5. WebSocket 是怎么用的

## 5.1 云端也有 WebSocket 服务

`nms4cloud-netty` 中：

- `nms4cloud-app/1_platform/nms4cloud-netty/nms4cloud-netty-app/src/main/java/com/nms4cloud/netty/app/websocket/WebSocketServer.java`

暴露：

- `@ServerEndpoint("/ws/")`

关键行为：

1. 前端连接后加入 `sessionMap`
2. 收到消息时解析 `Topic`
3. 把 WebSocket 消息桥接到 `serverHandler.sendMessageAsync(topic, json)`

说明这个 WebSocket 不是孤立存在，而是：

**把浏览器会话桥接进 Netty topic 总线**

## 5.2 POS 本地 WebSocket 才是门店前端刷新核心

`nms4pos` 中：

- `nms4cloud-pos3boot/.../WebSocketServer.java`

这个类非常关键：

- `@ServerEndpoint("/api/ws/{devId}")`
- `implements PushMessageService`

它正是 `MessageUtil` 使用的那套消息推送能力的落地实现。

实现了：

- `broadcastInfo(String message)`
- `sendSyncMessage(String devId, String message)`
- `sendAsyncMessage(String devId, String message)`

### 结论

在门店本地运行时：

- `MessageUtil.broadcastInfo()` 最终就是通过这个 WebSocket 服务广播给在线前端

这不是推测，是实现层已经对上了。

## 5.3 前端如何使用 WebSocket

`nms4pos-ui` 中：

- `app/pos4desktop/src/models/useWebSocket.ts`

关键逻辑：

- 前端连接 `ws://${serverIp}:9180/api/ws/${uuid}`
- 监听消息
- JSON 解析消息体
- 分发给页面监听器

说明桌面端前端确实直接使用 WebSocket。

## 5.4 WebSocket 刷新哪些页面

### 收银桌台页

`app/pos4desktop/src/pages/Home/component/Mode/Saas/index.tsx`

收到：

- `RefreshTable`

就刷新桌台数据。

### KDS 厨显页

`app/pos4desktop/src/pages/Home/component/Mode/KDS/index.tsx`

收到：

- `RefreshKds`

就刷新厨房显示数据。

## 5.5 POS 业务里谁发这些消息

`MessageUtil.java` 支持：

- `RefreshTable`
- `RefreshNetwork`
- `RefreshOrder`
- `RefreshKds`

业务代码中常见调用：

- `OrderServiceUtil` 在订单变化后广播 `RefreshOrder`
- `DwdFoodMakingController` 在出菜、撤菜、隐藏菜时广播 `RefreshKds`

### 结论

WebSocket 在微信点餐中的作用是：

- 刷新收银前端
- 刷新 KDS 厨显
- 刷新桌台状态
- 刷新网络状态

可以把它理解成：

**“微信点餐后的前端实时刷新层”**

---

## 6. RocketMQ 是怎么用的

## 6.1 统一 RocketMQ 封装

`nms4cloud-starter-rocketmq` 中：

- `RocketMQTemplatePlus.java`

提供了：

- `syncSend`
- `asyncSend`
- `syncSendDelay`
- `asyncSendDelay`

说明项目里 RocketMQ 的使用是做了统一封装的。

## 6.2 微信点餐支付中的延迟关单

`nms4cloud-order` 中：

- `PayOrderServiceImpl.java`
- `PTOrderCloseQueueConsumer.java`

### 支付提交后

`PayOrderServiceImpl` 会发送：

- `PT_ORDER_CLOSE_QUEUE`

而且是：

- `syncSendDelay(..., THIRTY_MINUTE)`

表示支付发起后，立即放一个 30 分钟后的延迟关单任务。

### 延迟消息消费后

`PTOrderCloseQueueConsumer` 会：

1. 查询支付状态
2. 如果未支付且还在短时间窗口内，继续延迟重试
3. 如果最终还是未支付，则自动取消订单
4. 如果已支付，则走后续订单处理

### 结论

这是微信点餐场景里 RocketMQ 最明确、最核心的使用点：

- **支付后的延迟关单**

## 6.3 支付后的异步业务处理

`PayOrderServiceImpl` 中还能看到：

- `CRM_CONSUMER_COUPON_QUEUE`
- `PAY_ORDER_SHARE_QUEUE`

对应的是：

- 消费券、会员券等异步处理
- 分享分佣等异步处理

也就是说，支付成功后的非核心同步逻辑，被拆到了 RocketMQ 异步消费。

## 6.4 MQTT/设备消息也借助 RocketMQ 做补偿

`nms4cloud-mq` 中：

- `MqMqttMsgServicePlus.java`
- `SendMqttMsgConsumer.java`

关键点：

1. 发 MQTT 消息时，系统会把任务投递到 `MQ_SEND_MQTT_MSG`
2. 对需要确认的消息，还会投递延迟补偿消息到 `MQTT_SEND_LOG`
3. 消费者 `SendMqttMsgConsumer` 再实际执行消息发送

说明 RocketMQ 在设备消息体系里负责：

- 异步投递
- 延迟补偿
- 失败重发

## 6.5 Netty 订阅关系也会借助 RocketMQ 广播

前面已经提到：

- `NETTY_SUBSCRIBE`

说明 Netty 设备订阅变化也通过 RocketMQ 做系统内同步。

## 6.6 RocketMQ 在微信点餐中的角色

### 结论

RocketMQ 在微信点餐中不是前端实时通道，而是后台异步通道，主要承担：

- 延迟关单
- 支付后异步处理
- 券、分佣等解耦
- MQTT/设备消息补偿
- Netty 订阅广播

可以把它理解成：

**“微信点餐后的异步任务与补偿层”**

---

## 7. 三者分工对比

| 技术 | 主要对象 | 使用时机 | 在微信点餐中的职责 |
|---|---|---|---|
| HTTP | 小程序 / H5 前端 | 登录、扫码、点餐、支付、查单 | 主业务请求链路 |
| WebSocket | 门店本地前端、KDS、收银页面 | 订单状态变化后 | 页面实时刷新 |
| Netty | 打印端、设备端、POS 客户端 | 打印、设备通知、topic 推送 | 设备长连接通信 |
| RocketMQ | 后台服务之间 | 延迟、异步、补偿、重试 | 后台任务与解耦 |

---

## 8. 端到端时序图

下面给一个简化版时序：

### 8.1 扫码点餐主链路

1. 用户微信扫码
2. 小程序/H5 获取 `mid + code`
3. 前端调用 `/pt_qr_bind/get`
4. 后端根据 `qrcodeKey` 查 `pt_qr_bind`
5. 返回 `businesstype + sid + 桌台/门店上下文`
6. 前端进入点餐页
7. 前端 HTTP 调用下单接口
8. 后端保存订单、菜品、金额

### 8.2 下单后的实时联动

1. 后端生成厨房打印任务
2. 后端通过 `Netty` 向打印设备/客户端推送
3. 后端通过 `MessageUtil.broadcastInfo()` 向本地前端广播
4. 收银前端收到 `RefreshOrder/RefreshTable`
5. KDS 前端收到 `RefreshKds`
6. 页面刷新显示最新状态

### 8.3 支付后的异步联动

1. 用户发起微信支付
2. 系统发送 `PT_ORDER_CLOSE_QUEUE` 延迟消息
3. 到时查询支付状态
4. 未支付则继续重试或自动关单
5. 已支付则异步处理券、分佣、后续任务

---

## 9. 整体技术清单

围绕微信点餐整条链路，实际使用的主要技术有：

### 前端层

- Taro
- 微信小程序 API
- H5 微信授权
- WebSocket
- 本地状态管理 `billStore`

### 后端业务层

- Spring Boot
- Spring WebFlux / Reactor
- Sa-Token
- MyBatis-Plus
- Redis
- Redisson
- Nacos

### 通信层

- HTTP/JSON
- WebSocket
- Netty
- RocketMQ

### 设备与集成层

- 打印任务系统
- MQTT 桥接能力
- topic 订阅机制
- 二维码绑定体系 `pt_qr_bind`

---

## 10. 最终结论

最核心的一句话是：

**微信点餐本身走 HTTP，点餐后的实时刷新走 WebSocket，点餐后的设备联动走 Netty，支付延迟与异步解耦走 RocketMQ。**

如果从架构上看，这 4 个仓库共同形成了一个分层体系：

1. `taro-mall / nms4pos-ui` 负责用户端与桌面前端
2. `nms4cloud` 负责微信登录、二维码绑定、订单支付、Netty/MQ 平台能力
3. `nms4pos` 负责门店 POS、本地 WS、本地 Netty、打印、KDS、收银联动
4. 最终实现“扫码点餐 -> 门店协同 -> 设备输出 -> 支付闭环”

---

## 11. 关键源码索引

### 微信登录

- `D:\mywork\nms4pos-ui\components\taro\src\utils\getSessionKey.ts`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\biz\CrmAuthController.java`

### 二维码绑定与分流

- `D:\mywork\taro-mall\src\common\service\pt\code.ts`
- `D:\mywork\taro-mall\src\pagesIndex\pageIndex\index.tsx`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-app\src\main\java\com\nms4cloud\product\app\controller\PtQrBindController.java`
- `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-product\nms4cloud-product-service\src\main\java\com\nms4cloud\product\service\PtQrBindServicePlus.java`

### 云端 Netty

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-service\src\main\java\com\nms4cloud\netty\service\netty\services\NettyServer.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-service\src\main\java\com\nms4cloud\netty\service\netty\component\ServerHandler.java`

### 云端 WebSocket

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-app\src\main\java\com\nms4cloud\netty\app\websocket\WebSocketServer.java`

### 本地 POS WebSocket

- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\server\services\WebSocketServer.java`
- `D:\mywork\nms4pos-ui\app\pos4desktop\src\models\useWebSocket.ts`

### 本地 POS Netty

- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\server\services\NettyServer.java`
- `D:\mywork\nms4pos\nms4cloud-pos10printer\nms4cloud-pos10printer-app\src\main\java\com\nms4cloud\pos10printer\app\netty\NettyClient.java`

### POS 消息广播与 KDS/订单刷新

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\sync\MessageUtil.java`
- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\controller\admin\DwdFoodMakingController.java`
- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\util\OrderServiceUtil.java`

### RocketMQ

- `D:\mywork\nms4cloud\nms4cloud-starter\nms4cloud-starter-rocketmq\src\main\java\com\nms4cloud\rocketmq\config\RocketMQTemplatePlus.java`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\c\order\PayOrderServiceImpl.java`
- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-app\src\main\java\com\nms4cloud\order\app\task\PTOrderCloseQueueConsumer.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-service\src\main\java\com\nms4cloud\mq\service\MqMqttMsgServicePlus.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-app\src\main\java\com\nms4cloud\mq\app\netty\consumer\SendMqttMsgConsumer.java`
