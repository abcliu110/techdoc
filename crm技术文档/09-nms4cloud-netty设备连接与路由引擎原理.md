# nms4cloud-netty 设备连接与路由引擎原理

> 适用范围：`D:\mywork\nms4cloud`
>
> 重点模块：`nms4cloud-netty`、`nms4cloud-mq`
>
> 目标：说明 `nms4cloud-netty` 为什么可以被称为“设备连接与路由引擎”，以及它具体是如何建立连接、如何按 `Topic` 做消息路由的

## 1. 一句话结论

`nms4cloud-netty` 本质上不是业务模块，而是一层 **设备长连接管理 + Topic 路由 + 同步回包桥接** 的基础设施。

它主要解决 3 件事：

1. 让线下设备先通过 Netty 长连接连到云端
2. 让设备主动声明“自己能接收哪些 Topic”
3. 让云端业务以后只按 `Topic` 找设备，而不用关心设备 IP、端口、连接对象

因此它可以被理解成：

```text
TCP 连接层 + Topic 注册表 + Topic -> Channel 路由表 + MsgID 回包关联器
```

## 2. 模块定位

从模块结构上看，`nms4cloud-netty` 是 `1_platform` 下的独立平台服务：

- 模块目录：`D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty`
- 服务名：`nms4cloud-netty`
- 模块描述：`netty服务器`

对应文件：

- `nms4cloud-netty/pom.xml`
- `nms4cloud-netty-app/src/main/resources/bootstrap.yml`

这说明它不是某个业务域的附属实现，而是被设计成一个可独立部署的设备通信基础服务。

## 3. 设备是如何连上来的

### 3.1 云端先启动 Netty TCP 服务端

`nms4cloud-netty` 启动后，会在 Spring 容器初始化完成时启动 `NettyServer`：

- `ListenerForNetty.contextInitialized()`
- `new Thread(nettyServer::start).start()`

`NettyServer.start()` 的核心逻辑是：

1. 读取 `netty.port`
2. 创建 `ServerBootstrap`
3. 绑定 TCP 端口
4. 给每条连接挂上统一的 `serverHandler`

对应代码位置：

- `nms4cloud-netty-app/.../listener/ListenerForNetty.java`
- `nms4cloud-netty-service/.../services/NettyServer.java`

### 3.2 每个设备作为 Netty Client 主动连接

真正的 POS、打印机或其他线下程序，并不是等云端反连，而是自己启动一个 NettyClient 去连接云端 `nms4cloud-netty`。

例如 `nms4cloud-pos3boot` 中的 `NettyClient`：

1. 读取 `netty.host` 和 `netty.port`
2. 调用 `bootstrap.connect(host, port)`
3. 连接成功后立即执行 `subscribe()`

这意味着：

- 云端是被动接入方
- 设备是主动建链方
- 只要设备在线，云端就持有一个长连接 `Channel`

## 4. 路由能力是怎么建立的

### 4.1 设备连上后不会自动可路由

仅仅建立 TCP 连接还不够。

因为一台设备连上来之后，云端只知道“有一条连接”，但并不知道：

- 这是哪台设备
- 属于哪家门店
- 应该接收哪些业务命令

所以还需要第二步：设备主动发送 `subscribe` 消息。

### 4.2 设备会发送 subscribe 消息声明自己的 Topic

以 `pos3boot` 为例，连接成功后会构造：

```json
{
  "Cmd": "subscribe",
  "Topic": [
    "设备uuid_server",
    "门店sid_server"
  ]
}
```

常见的 Topic 维度有两类：

1. `uuid_server`
2. `sid_server`

这两个维度的含义分别是：

- `uuid_server`：精确到某一台设备
- `sid_server`：精确到某一家门店

因此设备一旦完成订阅，云端就不再靠 IP 找设备，而是靠 Topic 找设备。

## 5. 服务端如何把连接变成“路由表”

### 5.1 ServerHandler 是整个路由引擎核心

`nms4cloud-netty` 中真正承担“路由引擎”职责的是：

- `nms4cloud-netty-service/.../component/ServerHandler.java`

它收到每一帧自定义 Netty 消息后，会：

1. 解码消息体
2. 解析 JSON
3. 读取 `Cmd`
4. 读取 `Topic`
5. 决定是“注册订阅”还是“路由投递”还是“同步回包”

### 5.2 核心数据结构

`ServerHandler` 内部最重要的两个 Map 是：

```java
Map<String, Set<ChannelHandlerContext>> topicToContext
Map<Integer, List<String>> contextToTopic
```

含义分别是：

- `topicToContext`
  - 某个 Topic 当前有哪些在线连接
- `contextToTopic`
  - 某条连接当前订阅了哪些 Topic

还有一个辅助结构：

```java
Map<Integer, Integer> contextForbiddenCount
```

它用于记录某条连接命中了多少个被禁用 Topic，属于路由过滤优化，不是主路由逻辑的核心。

### 5.3 收到 subscribe 后如何登记

当 `ServerHandler` 发现：

```text
Cmd = subscribe
```

就会进入 `handleSubscribeMsg()`。

这一步会做 4 件事：

1. 先清理该连接历史上已订阅的 Topic
2. 把新的 Topic 集合写入 `topicToContext`
3. 把这条连接对应的 Topic 列表写入 `contextToTopic`
4. 通过 RocketMQ 发送一条 `NETTY_SUBSCRIBE` 事件给其他模块感知

因此，所谓“路由引擎”，本质上就是维护了一个：

```text
Topic -> 在线连接集合
```

的内存索引。

## 6. 路由时到底怎么发消息

### 6.1 上层业务只需要给 Topic

上层业务如果想给线下某台设备发消息，不需要知道：

- 设备当前 IP
- 设备连入哪个 socket
- 连接对象是哪一个 `ChannelHandlerContext`

它只需要给出：

- `Topic`
- 消息体

例如：

```json
{
  "Cmd": "CheckTblStatus",
  "Topic": "1684817396849500161_server",
  "TblId": "A01"
}
```

### 6.2 服务端按 Topic 查连接

`sendMessage(topic, msg)` 的实际过程是：

1. 调 `getContextsByTopic(topic)`
2. 从 `topicToContext` 里取出该 Topic 对应的连接集合
3. 过滤被禁用的连接
4. 把 JSON 编码成二进制帧
5. 对每个连接执行 `writeAndFlush`

也就是说，路由不是“if else 找设备”，而是直接查一张运行时内存路由表。

### 6.3 为什么这叫路由引擎

因为它抽象掉了设备物理连接细节，把“往哪台设备发”统一转换成：

```text
按 Topic 查找连接并投递
```

这就是典型的逻辑路由，而不是物理地址路由。

## 7. 为什么一个 Topic 可以对应多个连接

`topicToContext` 的 value 是 `Set<ChannelHandlerContext>`，不是单个连接。

这表示一个 Topic 可以被多个设备同时订阅。

这会带来两个能力：

1. 单播
   - 某个 Topic 只有一个在线设备
2. 广播
   - 同一个 Topic 有多台在线设备
   - 下发时遍历整个集合全部发送

所以从数据结构上，`nms4cloud-netty` 天然支持“按 Topic 组播/广播”。

## 8. 同步调用为什么还能拿回结果

### 8.1 问题本质

Netty 长连接本身是异步的，但很多云端业务场景需要同步结果，例如：

- 查询台位状态
- 请求线下执行动作后立刻拿到返回值

这就需要一个“异步投递 + 同步结果桥接”机制。

### 8.2 sendWithMono 的实现方式

`ServerHandler.sendWithMono()` 的逻辑是：

1. 为本次请求生成唯一 `MsgID`
2. 把这个 `MsgID` 注册到 `MonoMgr`
3. 给下发消息补上：
   - `MsgID`
   - `ResponseTopic = topic_for_http_sync`
4. 把消息发给目标设备
5. 当前线程返回一个 `Mono`，等待未来回包唤醒

因此：

- `Topic` 负责决定“发给谁”
- `MsgID` 负责决定“回给谁”

### 8.3 回包怎么回来

设备处理完后，会把结果回发给云端，并带上原始 `MsgID`。

当 `ServerHandler` 发现消息的 `Topic` 命中了内置主题：

```text
topic_for_http_sync
```

就不会再把它继续转发给设备，而是直接进入 `handleHttpSyncMsg()`：

1. 读取 `MsgID`
2. 调用 `monoMgr.call(msgId, msg)`
3. 唤醒原来挂起的 `Mono`
4. 把结果返回给最初发起的业务请求

所以它不仅是路由引擎，还是一个“同步 HTTP / 异步设备回包”的桥接器。

## 9. 断线和路由表清理怎么做

如果某条设备连接断开，`channelInactive()` 最终会调用 `close(ctx)`。

这里会：

1. 从 `contextToTopic` 删除该连接记录
2. 反向删除它在 `topicToContext` 中的所有挂载
3. 如果某个 Topic 已没有任何连接，则删除该 Topic

这保证了：

- 路由表只反映当前在线设备
- 不会把消息发到失效连接

## 10. 为什么说它是“设备连接与路由引擎”

因为它完整覆盖了设备通信里的 4 个核心步骤：

### 10.1 连接接入

通过 NettyServer 监听端口，接收海量设备长连接。

### 10.2 身份声明

通过 `subscribe` 协议，让设备告诉服务端自己能接收哪些 Topic。

### 10.3 路由投递

通过 `topicToContext` 内存索引，把云端业务消息快速投递到正确设备。

### 10.4 回包桥接

通过 `MsgID + MonoMgr`，把设备异步响应再桥接回同步业务调用。

所以“引擎”这个词的重点在于：

- 它不是只保存连接
- 也不是只发 socket
- 而是把“连接、注册、查表、转发、回包”整成了一套运行机制

## 11. 它和 nms4cloud-mq 的关系

这两个模块不是互斥关系，而是两层职责：

### 11.1 nms4cloud-netty

偏底层通信基础设施，解决：

- 设备在线连接
- Topic 路由
- 同步回包

### 11.2 nms4cloud-mq

偏上层消息编排，解决：

- MQTT 下发
- Redis 留痕
- RocketMQ 延迟重试
- 消息确认和补偿
- 业务接口封装

可以简单理解为：

```text
nms4cloud-netty = 设备连接与路由层
nms4cloud-mq    = 消息编排与业务桥接层
```

在当前代码里，`mq` 还保留了一套兼容模式，既可以直接用自己内嵌的 NettyServer，也可以通过 `useNettyService` 转调独立的 `nms4cloud-netty` 服务。

这说明当前架构是兼容演进态，而不是绝对单一路径。

## 12. 关键代码文件

### 12.1 nms4cloud-netty

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-app\src\main\java\com\nms4cloud\netty\app\listener\ListenerForNetty.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-service\src\main\java\com\nms4cloud\netty\service\netty\services\NettyServer.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-service\src\main\java\com\nms4cloud\netty\service\netty\component\ServerHandler.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-service\src\main\java\com\nms4cloud\netty\service\netty\component\MonoMgr.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-netty\nms4cloud-netty-api\src\main\java\com\nms4cloud\netty\api\NettyReactiveFeign.java`

### 12.2 设备侧示例

- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\NettyClient.java`
- `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\netty\client\ClientHandler.java`

### 12.3 nms4cloud-mq 相关

- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-service\src\main\java\com\nms4cloud\mq\service\netty\component\ServerHandler.java`
- `D:\mywork\nms4cloud\nms4cloud-app\1_platform\nms4cloud-mq\nms4cloud-mq-service\src\main\java\com\nms4cloud\mq\service\MqMqttMsgServicePlus.java`

## 13. 总结

`nms4cloud-netty` 之所以能被称为“设备连接与路由引擎”，不是因为它用了 Netty，而是因为它实现了下面这套完整机制：

```text
设备主动连接
-> 设备主动 subscribe Topic
-> 服务端建立 Topic -> Channel 路由表
-> 云端业务按 Topic 下发
-> 服务端按 Topic 找连接投递
-> 设备带 MsgID 回包
-> 服务端按 MsgID 唤醒原请求
```

如果只看表面，它像一个 TCP 服务端。

如果看内部机制，它其实是一套：

```text
连接管理 + 设备寻址 + 消息路由 + 同步回包桥接
```

的运行时引擎。

## 14. 补充问答

### 14.1 Topic 的作用是什么

`Topic` 本质上是设备路由键，不是业务数据字段。

它解决的是：

1. 这条消息应该发给哪台设备
2. 或这条消息应该发给哪一组设备

因此云端并不是按：

- 设备 IP
- 设备端口
- 某个固定 socket

来找设备，而是按 `Topic` 查路由表。

在当前实现里：

```java
Map<String, Set<ChannelHandlerContext>> topicToContext
```

其含义就是：

```text
Topic -> 在线连接集合
```

所以 `Topic` 在整套机制里的定位可以概括成：

```text
逻辑收件地址
```

### 14.2 Topic 是如何传递的

`Topic` 不是 Netty 框架自带概念，而是业务协议中的 JSON 字段。

#### 14.2.1 设备上报订阅时传递

设备连上云端后，会主动发送：

```json
{
  "Cmd": "subscribe",
  "Topic": ["uuid_server", "sid_server"]
}
```

这一步是在告诉服务端：

```text
“这些 Topic 以后都由我这条连接负责接收。”
```

#### 14.2.2 云端下发业务消息时传递

上层业务调用 Netty 时，也会带上 `Topic`，例如：

```json
{
  "Cmd": "CheckTblStatus",
  "Topic": "1684817396849500161_server",
  "TblId": "A01"
}
```

服务端收到后，不会去做复杂业务判断，而是：

1. 用 `Topic` 查 `topicToContext`
2. 找到对应连接集合
3. 逐个 `writeAndFlush`

所以 `Topic` 的完整传递链路是：

```text
设备 subscribe 上报 Topic
-> 服务端建立 Topic -> Channel 路由表
-> 云端业务下发消息时再次携带 Topic
-> 服务端按 Topic 找连接并投递
```

### 14.3 为什么需要同时订阅 `uuid_server` 和 `sid_server`

这两个 Topic 解决的是不同粒度的寻址问题。

#### 14.3.1 `uuid_server`

用于精确到某一台具体设备。

适合的场景：

- 给某一台 POS 发命令
- 给某一台打印机发命令
- 只对某个终端做设备级控制

#### 14.3.2 `sid_server`

用于精确到某一家门店。

适合的场景：

- 给门店当前在线设备下发命令
- 业务天然只知道 `sid`，不知道具体 `uuid`
- 以门店为默认寻址单位

#### 14.3.3 为什么两个都不能省

如果只保留 `uuid_server`：

- 门店级业务会很难做
- 云端很多场景只有 `sid`，没有 `uuid`

如果只保留 `sid_server`：

- 无法精确打到某一台设备
- 一个门店有多台设备时，设备粒度控制会变差

所以同时订阅这两个，是为了同时支持：

1. 门店粒度寻址
2. 设备粒度寻址

可以理解为：

```text
uuid_server = 房间号
sid_server  = 楼层号
```

### 14.4 netty 目前支持哪些消息

这个问题要分两层看。

#### 14.4.1 协议层内置消息

`nms4cloud-netty` 服务端自己真正识别的内置消息不多，主要是：

1. `subscribe`
   - 建立订阅关系
2. `topic_for_http_sync`
   - 作为同步调用回包通道
3. `str_topic_for_web_socket`
   - 作为 WebSocket 回包通道

也就是说，服务端自己更像一个协议路由器，而不是一个大而全的业务命令解释器。

#### 14.4.2 业务层命令

业务命令主要由设备侧决定是否支持。

例如 `pos3boot` 里可以看到：

- `GenQrcodeForBill`
- `nms4cloud`
- `posTakeOut`

以及一种更通用的方式：

- 如果消息里直接给了 `url`
- 设备侧就直接调用本机对应 HTTP 接口

所以当前系统里的“消息支持范围”本质上是：

```text
云端可以发什么
与
设备端能识别什么 Cmd 或 url
```

### 14.5 netty 只是转发消息的吗

不只是，但核心职责确实偏“转发与桥接”。

更准确地说，`nms4cloud-netty` 主要做 5 件事：

1. 维护设备长连接
2. 维护 `Topic -> Channel` 路由表
3. 按 `Topic` 转发消息
4. 用 `MsgID + MonoMgr` 桥接同步回包
5. 处理少量协议级内置消息

它通常不负责实际业务执行，例如：

- 生成支付二维码
- 开台
- 打印
- CRM 业务动作

这些大多在 POS 本地业务服务中处理。

因此更准确的描述是：

```text
nms4cloud-netty = 设备连接层 + 路由层 + 回包桥接层
```

而不是：

```text
nms4cloud-netty = 业务执行层
```

### 14.6 为什么叫 Mono，回包回给谁

这里的 `Mono` 不是业务术语，而是 Reactor 的概念。

它表示：

```text
未来只会返回 0 个或 1 个结果的异步对象
```

所以 `sendWithMono()` 的真实含义是：

1. 先把消息发给设备
2. 当前调用先返回一个 `Mono`
3. 等设备未来回包
4. 再把这一份结果填回 `Mono`

#### 14.6.1 回包最终回给谁

最终回给：

```text
最初发起这次 sendWithMono() 的那个云端调用方
```

靠两样东西实现：

1. `ResponseTopic`
2. `MsgID`

发送时会自动补：

- `MsgID = netty_xxx`
- `ResponseTopic = ["topic_for_http_sync"]`

设备回包时需要原样带回 `MsgID`，并把回包 Topic 设成 `topic_for_http_sync`。

服务端收到后会：

1. 先按 `Topic` 判断这是同步回包
2. 再按 `MsgID` 去 `MonoMgr` 里找到原来等待的回调
3. 唤醒原请求

所以这三者关系是：

```text
Topic = 发给谁
ResponseTopic = 结果走哪条通道回来
MsgID = 结果最终交给谁
Mono = 等这个结果的人
```

### 14.7 为什么还需要 ResponseTopic，只靠 MsgID 不行吗

不行。

因为：

- `MsgID` 只解决“这条结果属于谁”
- `ResponseTopic` 解决“这条结果走哪条回程通道”

服务端收到一条消息后，第一步并不是先按 `MsgID` 判断，而是先按 `Topic` 做分流。

它需要先知道这条消息到底是：

1. 普通业务消息
2. 同步回包
3. WebSocket 回包

如果没有 `ResponseTopic`，设备回一条只带 `MsgID` 的消息，服务端并不知道应该：

- 继续转发给设备
- 还是唤醒 `Mono`
- 还是投递给 WebSocket

因此：

```text
ResponseTopic 决定回程通道
MsgID 决定回程终点
```

两者缺一不可。

### 14.8 `contextToTopic` 为什么是 `Map<Integer, List<String>>`

从语义上说，它确实对应某个 `ChannelHandlerContext`。

但实现上，作者没有直接用 `ChannelHandlerContext` 当 key，而是用了：

```java
channelHandlerContext.hashCode()
```

因此类型写成了：

```java
Map<Integer, List<String>> contextToTopic
```

这里的 `Integer` 实际上代表：

```text
某条连接的 hashCode 标识
```

#### 14.8.1 为什么不用完整的 `ChannelHandlerContext`

因为 `contextToTopic` 不是用来发消息的，只是做反向索引。

它的用途是：

1. 连接重新订阅时
2. 连接断开时
3. 需要快速找到“这条连接之前挂过哪些 topic”时

所以它只需要一个轻量连接标识，不需要完整连接对象。

#### 14.8.2 为什么 `topicToContext` 却必须保存 `ChannelHandlerContext`

因为 `topicToContext` 后面真的要拿这个对象去：

```java
context.writeAndFlush(...)
```

所以不能只存一个整数 id。

#### 14.8.3 两张表如何配合

可以理解为：

- `topicToContext`
  - 正向路由：按 Topic 找连接
- `contextToTopic`
  - 反向清理：按连接找 Topic

配合流程是：

```text
连接重新 subscribe 或断开
-> 用 ctx.hashCode() 去 contextToTopic 找旧 topics
-> 再逐个到 topicToContext 里删除这个 ctx
```

这是一个典型的双向索引设计。

### 14.9 新增一个消息类型时，POS 和云端都需要修改吗

不一定，要看新增的是哪一层。

#### 14.9.1 如果新增的是业务命令

例如新增一个新的 `Cmd`：

```json
{
  "Cmd": "CheckMemberStatus",
  "Topic": "xxx_server"
}
```

通常需要：

1. 云端发送方增加这条消息
2. POS 侧增加对这个 `Cmd` 的处理逻辑

但 `nms4cloud-netty` 服务端一般不需要改，因为它只是按 Topic 路由转发。

#### 14.9.2 如果不新增 Cmd，而是直接传 url

例如：

```json
{
  "Topic": "xxx_server",
  "url": "/merchant/member/checkStatus",
  "data": {...}
}
```

这时 POS Netty 层可能都不用改。

因为设备侧本来就支持：

1. 如果消息里有 `url`
2. 就直接调用本机这个 HTTP 接口

所以可能只需要：

1. 云端发送方改
2. POS 本地业务接口存在或新增

#### 14.9.3 如果改的是协议级消息

例如：

- 新的内置回包 Topic
- 新的同步/异步协议规则
- 新的 subscribe 格式
- 新的系统级控制消息

这种就不再是普通业务命令，而是在改通信协议本身。

通常需要同时改：

1. 云端发送方
2. `nms4cloud-netty` 服务端
3. 设备侧 NettyClient / ClientHandler

所以更准确的判断是：

```text
新增业务能力 -> 云端和 POS 视情况修改
新增协议规则 -> 云端、POS、netty 服务端通常都要改
```

### 14.10 常见字段职责表

下面这几个字段是当前 Netty 消息协议里最容易混淆的字段。

| 字段 | 谁来设置 | 主要作用 | 是否参与路由 | 常见取值或示例 |
|------|----------|----------|--------------|----------------|
| `Cmd` | 云端发送方或设备回包方 | 表示这条消息是什么命令/什么类型 | 否 | `subscribe`、`GenQrcodeForBill`、`CheckTblStatus`、`nms4cloud` |
| `Topic` | 设备订阅时设置；云端下发时设置；设备回包时也会设置 | 表示消息当前要走到哪条逻辑通道 | 是 | `uuid_server`、`sid_server`、`topic_for_http_sync` |
| `ResponseTopic` | 发起方设置 | 告诉接收方处理完成后应该把结果发回哪条通道 | 间接参与 | `["topic_for_http_sync"]`、`["str_topic_for_web_socket"]` |
| `MsgID` | 发起同步调用的一方设置 | 标识“这次请求”和“这次回包”是一对 | 否 | `netty_123456789` |
| `url` | 云端发送方设置 | 告诉设备侧最终调用哪个本机 HTTP 接口 | 否 | `/merchant/dwd_bill_ops/createQrcode` |
| `data` | 云端发送方或设备回包方设置 | 放具体业务参数或回包结果 | 否 | 业务 JSON 数据 |
| `mqtt_content` | 某些业务发送方设置 | 放经过包装后的消息体，通常是 Base64 或内部消息内容 | 否 | 编码后的业务报文 |

#### 14.10.1 一条典型下发消息

```json
{
  "Cmd": "CheckTblStatus",
  "Topic": "1684817396849500161_server",
  "TblId": "A01",
  "MsgID": "netty_123456789",
  "ResponseTopic": ["topic_for_http_sync"]
}
```

这条消息里各字段分工是：

- `Cmd`
  - 设备应该执行什么动作
- `Topic`
  - 先发给哪台设备或哪家门店
- `MsgID`
  - 回包回来后该归属哪次请求
- `ResponseTopic`
  - 回包时走哪条逻辑通道

#### 14.10.2 一条典型同步回包

```json
{
  "Topic": ["topic_for_http_sync"],
  "MsgID": "netty_123456789",
  "busy": true
}
```

这条回包的关键点是：

- `Topic` 已不再是设备订阅 Topic
- 它已经变成了同步回包通道
- 服务端看到 `topic_for_http_sync` 后，就不会继续做普通设备路由
- 然后再按 `MsgID` 去 `MonoMgr` 找原请求

#### 14.10.3 这几个字段最容易记错的点

可以压缩成下面这组口诀：

```text
Cmd = 做什么
Topic = 发给谁
ResponseTopic = 从哪条通道回来
MsgID = 最终回给谁
url = 在设备本机调哪个接口
data = 具体业务内容
```
