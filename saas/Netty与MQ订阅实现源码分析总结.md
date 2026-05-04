# Netty 与 MQ 订阅实现源码分析总结

## 1. 结论概览

这套“订阅”机制的本质不是 RocketMQ 的 Broker 原生订阅，而是应用层基于 Netty 长连接自行维护的一张在线路由表：

- POS 终端启动后主动发送 `subscribe`
- 服务端把 `topic -> ChannelHandlerContext` 写入内存 Map
- 云端发送消息时，先根据 `sid` 或 `deviceId` 算出目标 `topic`
- Netty 服务端按 `topic` 查找在线连接，再把消息推送到对应 POS
- POS 收到后，再进入本地统一分发中心 `Nms4cloudUtil`
- `Nms4cloudUtil` 再把消息分发给本地 MQ 或业务 Handler

一句话总结：

> 订阅 = POS 主动注册 topic，服务端维护在线 topic 路由，消息下发时按 topic 命中在线终端。

---

## 2. 订阅是如何实现的

## 2.1 POS 侧主动发送订阅

POS 端代码在：

- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\NettyClient.java`

关键逻辑：

1. 建立 Netty 长连接
2. 连接成功后立即调用 `subscribe()`
3. `subscribe()` 发送 JSON：

```json
{
  "Cmd": "subscribe",
  "Topic": ["uuid_server", "sid_server"]
}
```

订阅主题来源：

- `uuid + "_server"`
- `sid + "_server"`，如果当前门店号存在

这意味着：

- `uuid_server` 是设备级订阅
- `sid_server` 是门店级订阅

如果 POS 初始化后门店号变化，还会重新调用一次 `subscribe()`。

---

## 2.2 服务端收到订阅后建立路由关系

云端 Netty 路由中心代码在：

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-service\src\main\java\com\nms4cloud\mq\service\netty\component\ServerHandler.java`

核心数据结构：

```java
private final Map<String, Map<ChannelHandlerContext, Integer>> topicToContext =
    new ConcurrentHashMap<>();

private final Map<Integer, List<String>> contextToTopic = new ConcurrentHashMap<>();
```

含义：

- `topicToContext`
  - 根据 topic 找到所有在线连接
- `contextToTopic`
  - 根据连接反查它订阅了哪些 topic
  - 用于断线清理

处理流程：

1. `parseAndHandleMsg()` 解析收到的 JSON
2. 如果 `Cmd == subscribe`
3. 调用 `handleSubscribeMsg(topics, ctx)`

`handleSubscribeMsg()` 做了三件事：

1. 先清理这个连接之前的旧订阅
2. 把新的 topic 全部绑定到当前 `ChannelHandlerContext`
3. 记录 `context -> topics` 反向映射

此外还会额外发送一条 RocketMQ 消息：

- Topic：`NETTY_SUBSCRIBE`

它的作用不是保存订阅关系，而是把“谁订阅了什么”这个事件广播给其他模块，例如用于注册模块绑定设备和门店关系。

---

## 2.3 断线后如何取消订阅

当 POS 连接断开时：

- `channelInactive()`
- 调用 `close(ctx)`

清理逻辑：

1. 从 `contextToTopic` 取出该连接订阅的所有 topic
2. 遍历 topic
3. 从 `topicToContext` 中删除当前连接
4. 如果某个 topic 已经没有任何连接，则删除该 topic

因此订阅关系是：

- 在线态
- 内存态
- 随连接生命周期动态变化

不是数据库持久化表。

---

## 3. 云端消息是如何命中订阅者的

## 3.1 云端发送入口

统一接口入口：

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-app\src\main\java\com\nms4cloud\mq\app\controller\MqMqttMsgController.java`

接口：

- `/mq_mqtt_msg/sendNettyMsg`

最终调用：

- `MqMqttMsgServicePlus.sendNettyMsg(request)`

请求 DTO：

- `MqMqttMsgAddDTO`

关键字段：

- `sid`
- `deviceId`
- `msg`
- `msgType`
- `url`

---

## 3.2 发送前如何计算 topic

核心代码：

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-service\src\main\java\com\nms4cloud\mq\service\MqMqttMsgServicePlus.java`

`sendNettyMsg(MqMqttMsg entity, String msg)` 的逻辑：

1. 如果有 `deviceId`
   - 优先发给 `deviceId + "_server"`
   - 如果本身已有 `_server` 后缀，则直接用
2. 如果没有 `deviceId`
   - 退化为 `sid + "_server"`

因此路由优先级是：

- 设备定向
- 门店广播

---

## 3.3 业务消息如何包装成 Netty 消息

封装后的消息结构大致如下：

```json
{
  "Cmd": "nms4cloud",
  "Topic": "目标topic",
  "ResponseTopic": "[\"\"]",
  "MsgID": "消息ID",
  "mqtt_content": "Base64后的业务消息"
}
```

其中：

- `Cmd`
  - 普通业务消息是 `nms4cloud`
  - 同步消息可能是 `nms4sync`
- `mqtt_content`
  - 保存真正业务包
- `Topic`
  - 决定推给哪个订阅者

---

## 3.4 服务端如何按 topic 找到在线 POS

仍然在 `ServerHandler.sendMessage(topic, msg)` 中。

逻辑：

1. `topicToContext.get(topic)`
2. 取出订阅此 topic 的所有连接
3. 组装 Netty 二进制帧
4. 遍历连接执行 `writeAndFlush`

也就是说：

> 云端并不是把消息“发给 POS 机器”，而是“发给某个 topic”，再由 Netty 服务端把 topic 映射到在线连接。

---

## 4. POS 收到消息后怎么处理

## 4.1 POS 收包入口

POS 端收包代码：

- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\ClientHandler.java`

收到消息后：

1. 从 Netty 帧中读取内容
2. 转成字符串
3. 调用 `proMsg(content)`

在 `proMsg()` 中：

- 如果 `Cmd == nms4cloud`
- 读取 `mqtt_content`
- Base64 解码
- 调用 `Nms4cloudUtil.proNms4cloud(msg)`

因此，`ClientHandler` 只是：

- 网络接收层
- 协议解析层

真正业务分发入口在 `Nms4cloudUtil`。

---

## 4.2 `Nms4cloudUtil` 是 POS 的统一分发中心

代码位置：

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\util\Nms4cloudUtil.java`

处理流程：

1. 把字符串解析成 `MqMqttMsg`
2. 再把 `MqMqttMsg.msg` 解析成 `OrderMsgDTO`
3. 根据 `OrderMsgTypeEnum` 决定怎么处理

这里分两类：

### 一类：实时直处理消息

当前代码里 `realTimeDeal` 映射只有：

- `CASH_REQUEST -> CashRequestHandler`

这类消息直接同步调用 Handler：

```java
orderHandler.handle(orderMsgDTO);
```

### 二类：普通业务消息

大多数消息不会直接处理，而是转发到本地 MQ：

```java
mqTemplate.asyncSend(
    Pos2pluginMqTopic.SCAN_ORDER_MSG + ":" + orderMsgType.name(),
    orderMsgDTO
);
```

也就是：

- Netty 只负责送达 POS
- POS 内部再通过本地消息队列异步落行业务

---

## 4.3 POS 本地为什么还要再转一次 MQ

目的是把：

- 网络接收
- 业务处理

彻底解耦。

好处：

1. Netty 收包线程不阻塞
2. 业务处理失败可独立补偿
3. 本地不同业务统一走既有 Handler / Listener
4. 更适合断线重连补发和幂等控制

因此这条链路实际上是：

```text
云端 -> Netty -> POS -> 本地MQ -> 本地业务Handler
```

而不是：

```text
云端 -> Netty -> 直接执行业务
```

---

## 5. 可靠性机制

## 5.1 消息确认

POS 在成功接收并分发后会调用：

- `nms4cloudMqService.confirm(lid)`

作用：

- 告诉云端这条消息已成功接收
- 云端可以删除待确认记录

---

## 5.2 去重幂等

`Nms4cloudUtil.isDuplicate()` 使用 Redis Set 做去重：

- key：`NMS4CLOUD_消息类型`
- value：`msgId`

如果消息已处理过，则直接确认并跳过，不再重复处理。

这保证了：

- 重发不会导致重复业务执行

---

## 5.3 超时丢弃

`OrderMsgDTO` 带有 `timeout` 字段。

如果处理时发现已超时：

- 不再执行业务
- 直接确认该消息

避免旧消息在断线恢复后误处理。

---

## 5.4 断线重连补拉

当 POS 重连成功后：

1. 重新 `subscribe()`
2. 调用 `Nms4cloudUtil.poll()`
3. 向云端拉取未确认消息列表
4. 再次执行 `proNms4cloud(mqttMsg, true)`

这样即使断线期间漏消息，也能补回来。

---

## 6. 时序图（ASCII）

```text
订阅阶段
========

POS NettyClient
  -> nms4cloud-mq
     建立 Netty 长连接

POS NettyClient
  -> nms4cloud-mq
     {"Cmd":"subscribe","Topic":["uuid_server","sid_server"]}

nms4cloud-mq / ServerHandler
  -> ServerHandler.handleSubscribeMsg()
  -> 写入 topicToContext / contextToTopic


消息下发阶段
============

云端业务服务
  -> nms4cloud-mq
     /mq_mqtt_msg/sendNettyMsg

nms4cloud-mq / MqMqttMsgServicePlus
  -> 计算目标 topic
     deviceId_server 或 sid_server
  -> 封装 Netty 消息
     Cmd=nms4cloud
     mqtt_content=Base64(业务消息)

nms4cloud-mq / ServerHandler
  -> topicToContext.get(topic)
  -> writeAndFlush(Netty消息)

POS ClientHandler
  -> 收到 Netty 消息
  -> Base64 解码 mqtt_content
  -> Nms4cloudUtil.proNms4cloud(msg)


POS 本地分发阶段
================

Nms4cloudUtil
  -> 解析 MqMqttMsg
  -> 解析 OrderMsgDTO
  -> 去重、超时校验

如果是实时消息：
  -> OrderHandler.handle()

如果是普通消息：
  -> asyncSend(SCAN_ORDER_MSG:MsgType)
  -> POS 本地 MQ / Handler
  -> 执行本地下单 / 支付 / 打印 / 同步


确认与补偿
==========

Nms4cloudUtil
  -> 云端 Confirm 接口
     confirm(lid)


断线恢复
========

POS 重连成功
  -> 重新 subscribe()
  -> Nms4cloudUtil.poll()
  -> 拉取未确认消息
  -> 逐条重新分发处理
```

---

## 7. 结构图（ASCII）

```text
+--------------------+
| NettyClient_POS    |
|--------------------|
| start()            |
| subscribe()        |
| sendMessage()      |
+---------+----------+
          |
          | uses
          v
+--------------------+
| ClientHandler_POS  |
|--------------------|
| handleData()       |
| proMsg()           |
| resMsg()           |
+---------+----------+
          |
          | dispatches to
          v
+--------------------+
| Nms4cloudUtil      |
|--------------------|
| proNms4cloud()     |
| poll()             |
| confirm()          |
| isDuplicate()      |
+----+-----------+---+
     |           |
     | parses    | async business dispatch
     v           v
+------------+  +------------------+
| MqMqttMsg  |  | LocalMQ_Handler  |
+------------+  |------------------|
                | asyncSend()      |
                | handle()         |
                +------------------+


+------------------------+
| MqMqttMsgServicePlus   |
|------------------------|
| sendNettyMsg()         |
| send()                 |
| confirm()              |
+-----------+------------+
            |
            | route by topic
            v
+------------------------+
| ServerHandler_MQ       |
|------------------------|
| handleData()           |
| sendMessage()          |
| sendWithMono()         |
| getContextByTopic()    |
| handleSubscribeMsg()   |
+-----+-------------+----+
      |             |
      | push over   | delegate if useNettyService=true
      | Netty       v
      |        +-------------------+
      |        | NettyReactiveFeign|
      |        +-------------------+
      v
+--------------------+
| NettyClient_POS    |
+--------------------+


外部依赖关系
------------

Nms4cloudUtil
  -> Redis
     去重 / 状态
  -> RocketMQ相关服务
     confirm / 补拉待确认消息

MqMqttMsgServicePlus
  -> RocketMQ
     异步 / 延迟 / MQTT相关 Topic

ServerHandler_MQ
  -> Redis
     同步响应缓存
  -> RocketMQ
     发布 NETTY_SUBSCRIBE 事件
```

## 8. 模块边界图（ASCII）

```text
+----------------------+
|   云端业务模块       |
| CRM / Payment / 等   |
+----------+-----------+
           |
           | 调用 sendNettyMsg / sendMqttMsg
           v
+-------------------------------+
|         nms4cloud-mq          |
|-------------------------------|
| 1. 统一消息入口               |
| 2. 计算 topic                 |
| 3. 封装 Netty 消息            |
| 4. RocketMQ补偿/确认/延迟     |
| 5. MQTT消息发送               |
| 6. 可直接做Netty路由          |
| 7. 也可转调 nms4cloud-netty   |
+-----+-------------------+-----+
      |                   |
      | 模式1：本地直推   | 模式2：委托独立Netty服务
      |                   v
      |         +---------------------------+
      |         |      nms4cloud-netty      |
      |         |---------------------------|
      |         | 1. 维护 topicToContext    |
      |         | 2. 管理在线长连接         |
      |         | 3. 按 topic 路由消息      |
      |         | 4. 提供在线查询/同步调用  |
      |         +-------------+-------------+
      |                       |
      +-----------------------+
                              |
                              | Netty长连接推送
                              v
                    +----------------------+
                    |      POS终端         |
                    | nms4cloud-pos3boot   |
                    |----------------------|
                    | 1. 连接Netty服务     |
                    | 2. subscribe订阅     |
                    | 3. 接收云端消息      |
                    | 4. 本地业务处理      |
                    +----------------------+

附属基础设施：

  nms4cloud-mq  <--> RocketMQ   : 补偿、延迟、确认、异步消息
  nms4cloud-mq  <--> MQTT       : MQTT消息投递
  nms4cloud-mq  <--> Redis      : 状态缓存、确认缓存
  nms4cloud-netty <-> Redis     : 可扩展在线状态/路由辅助
```

---

## 9. 两种部署形态（ASCII）

先强调一个关键点：

> POS 终端是直接连接 Netty Server 的，不是先连接 RocketMQ 再到 Netty。

RocketMQ 在这套架构里负责的是：

- 订阅事件广播
- 异步消息
- 延迟补偿
- 消息确认

它不参与 POS 与 Netty Server 的 TCP 长连接建立。

### 9.1 `useNettyService=false`

此时 `nms4cloud-mq` 自己承担主 Netty 路由能力。

```text
集群外 POS
   |
   | TCP 连接
   v
nms4cloud-mq :9999
   |
   | 本地 topicToContext
   | 本地 sendMessage(topic, msg)
   v
POS 在线连接

云端业务服务
   |
   | 调用 sendNettyMsg
   v
nms4cloud-mq
   |
   | 计算 topic / 封装 Netty 消息
   | 直接按本地路由表推送
   v
POS
```

这个模式下：

- POS 应该连接 `nms4cloud-mq` 暴露出来的 `9999`
- `nms4cloud-netty` 即使部署了，也不应承接主接入流量

### 9.2 `useNettyService=true`

此时 `nms4cloud-mq` 不再承担主 Netty 路由，改为委托独立 `nms4cloud-netty`。

```text
集群外 POS
   |
   | TCP 连接
   v
nms4cloud-netty :9999
   |
   | 维护 topicToContext
   | 维护在线连接
   v
POS 在线连接

云端业务服务
   |
   | 调用 sendNettyMsg
   v
nms4cloud-mq
   |
   | 计算 topic / 封装 Netty 消息
   | 通过 NettyReactiveFeign 转调
   v
nms4cloud-netty
   |
   | 按 topic 查路由表并推送
   v
POS
```

这个模式下：

- POS 应该连接 `nms4cloud-netty` 暴露出来的 `9999`
- `nms4cloud-mq` 负责消息编排，不负责主在线路由

### 9.3 如果 POS 在集群外，`useNettyService=true` 的要求

如果 POS 部署在集群外，而 `useNettyService=true`，那么：

- `nms4cloud-netty` 必须对集群外提供可访问的 TCP 地址
- 这个地址最终必须能转发到 `nms4cloud-netty` 的 `9999`

可以是：

- 宿主机端口映射
- NodePort
- LoadBalancer
- 四层 TCP 转发

本质要求只有一个：

```text
POS 终端 ---> 可访问地址:端口 ---> nms4cloud-netty:9999
```

注意：

- 不一定要求“容器直接暴露”
- 但一定要求“POS 能访问到最终落向 `nms4cloud-netty:9999` 的外部地址”

否则就会出现：

- `mq` 已经委托给 `netty`
- 但 `netty` 没有任何 POS 订阅
- 最终消息推送不到终端

### 9.4 当前环境如何判断 POS 连的是谁

不是看“两个模块都写了 9999”，而是看：

1. POS 实际拿到的 `netty.host`
2. POS 实际拿到的 `netty.port`
3. 这个 `host:port` 在集群里最终映射到哪个 Service / Pod / 监听进程

也就是说：

> POS 最终只会连接一个具体地址，真正生效的是这个地址背后的监听者，而不是模块名本身。

---

## 10. 最终总结

从源码看，这套系统把“消息订阅”和“消息消费”拆成了两层：

### 第一层：在线寻址层

由 Netty 完成：

- POS 主动订阅 topic
- 服务端维护 `topic -> 在线连接`
- 下发消息时按 topic 路由到在线终端

### 第二层：本地业务消费层

由 POS 本地 MQ 和 Handler 完成：

- POS 收到云端消息
- 统一进入 `Nms4cloudUtil`
- 进行去重、超时校验、确认控制
- 再按业务类型转发到本地 MQ / Handler 处理

因此：

> “订阅”解决的是“消息送到哪个在线 POS”  
> “本地 MQ / Handler”解决的是“POS 收到后如何执行业务”

这也是 Netty 与 MQ 在整套架构里各自真正承担的职责边界。
