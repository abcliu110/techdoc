# Netty 的 Channel、Pipeline、Handler 三层关系说明

## 一、先看一句最重要的话

在 Netty 里可以先这样理解：

```text
Channel 是连接
Pipeline 是连接上的处理链
Handler 是处理链上的处理器
```

也就是：

```text
一个连接
└── 挂一条处理链
    └── 链上挂多个处理器
```

---

## 二、三层结构图

先看最简单的层级图：

```text
SocketChannel
└── ChannelPipeline
    ├── Handler-1
    ├── Handler-2
    └── Handler-3
```

这就是最核心的三层关系：

1. 最外层是 `Channel`
2. 中间层是 `Pipeline`
3. 最里层是 `Handler`

---

## 三、每一层分别是什么

### 1. Channel 是什么

`Channel` 可以理解成“一条网络连接”或者“一个通信通道”。

例如：

- 服务端监听端口：`NioServerSocketChannel`
- 客户端具体连接：`SocketChannel`

在大多数业务处理里，你最常见的是：

```text
SocketChannel
```

它表示：

- 某个客户端和服务端之间已经建立好的连接

所以可以先把 `Channel` 理解成：

```text
谁在通信
```

---

### 2. Pipeline 是什么

`Pipeline` 是挂在 `Channel` 上的一条处理链。

可以理解成：

```text
消息进来以后，要经过哪些处理步骤
```

例如：

```text
SocketChannel
└── Pipeline
    ├── 解码
    ├── 鉴权
    ├── 业务处理
    └── 编码
```

所以 `Pipeline` 关注的是：

```text
消息怎么一步步被处理
```

---

### 3. Handler 是什么

`Handler` 就是 `Pipeline` 上的一个具体处理器节点。

一个 `Handler` 通常只做一件事，比如：

- 打印日志
- 粘包拆包
- 字节转字符串
- 字符串转对象
- 业务消息处理
- 异常处理

所以可以把 `Handler` 理解成：

```text
处理链上的一个具体步骤
```

---

## 四、用快递分拣来理解三层关系

可以这样类比：

```text
Channel   = 一条快递传送带
Pipeline  = 这条传送带上的分拣流程
Handler   = 每一个分拣工位
```

层级图：

```text
传送带
└── 分拣流程
    ├── 工位1：拆包
    ├── 工位2：识别类型
    ├── 工位3：分配路线
    └── 工位4：出库
```

Netty 只是把这个思想用在了网络消息处理上。

---

## 五、多个连接时的整体层级

如果服务端同时有多个客户端连接，结构是：

```text
NioServerSocketChannel
├── SocketChannel(client-1)
│   └── Pipeline
│       ├── Handler-1
│       ├── Handler-2
│       └── Handler-3
├── SocketChannel(client-2)
│   └── Pipeline
│       ├── Handler-1
│       ├── Handler-2
│       └── Handler-3
└── SocketChannel(client-3)
    └── Pipeline
        ├── Handler-1
        ├── Handler-2
        └── Handler-3
```

这里有两个关键点：

1. 每个客户端连接都有自己的 `Channel`
2. 每个 `Channel` 都有自己的 `Pipeline`

也就是说，`Pipeline` 不是全局共用一条，而是“每个连接一条”。

---

## 六、消息是怎么流动的

### 1. 入站消息流

客户端发消息给服务端时，消息流可以理解成：

```text
客户端消息
    ↓
SocketChannel
    ↓
Pipeline
    ↓
Handler-1
    ↓
Handler-2
    ↓
Handler-3
    ↓
业务处理结果
```

图示：

```text
client
  |
  v
SocketChannel
  |
  v
Pipeline
  |
  +--> Handler-1
  |
  +--> Handler-2
  |
  +--> Handler-3
  |
  v
business logic
```

这就是“入站事件”。

常见入站事件包括：

- `channelActive`
- `channelRead`
- `exceptionCaught`

---

### 2. 出站消息流

服务端要回消息给客户端时，流程可以理解成：

```text
业务代码 writeAndFlush()
    ↓
Pipeline
    ↓
编码 Handler
    ↓
SocketChannel
    ↓
客户端
```

图示：

```text
business logic
  |
  v
Pipeline
  |
  +--> outbound handler
  |
  v
SocketChannel
  |
  v
client
```

所以：

- 入站：从网络到业务
- 出站：从业务到网络

---

## 七、为什么要有 Pipeline，而不是直接一个 Handler

因为真实网络处理不是一步完成的，而是很多步骤串起来。

例如一条消息可能要经历：

```text
接收字节
→ 拆包
→ 解码
→ 鉴权
→ 业务处理
→ 编码
→ 回写
```

如果都写在一个 `Handler` 里，会有几个问题：

1. 职责混乱
2. 难维护
3. 难复用
4. 改一个步骤容易影响全部逻辑

所以 Netty 用 `Pipeline` 把处理拆成多个 `Handler`，每个 `Handler` 只负责一小步。

---

## 八、你在 Demo2 里看到的三层关系

在 `Demo2NettyEcho` 里：

```java
channel.pipeline().addLast(new ChannelInboundHandlerAdapter() {
  @Override
  public void channelRead(ChannelHandlerContext ctx, Object msg) {
    ...
  }
});
```

可以拆成三层理解：

```text
channel
└── pipeline()
    └── addLast(handler)
```

也就是：

```text
当前连接
└── 拿到这条连接的处理链
    └── 往处理链末尾加一个处理器
```

层级图：

```text
SocketChannel
└── Pipeline
    └── ChannelInboundHandlerAdapter
        └── channelRead(...)
```

所以你写的不是：

- 往服务端全局加逻辑

而是：

- 给“每个新连接的处理链”加逻辑

这点非常关键。

---

## 九、Channel、Pipeline、Handler 的关系总结图

```text
一个客户端连接
└── 一个 Channel
    └── 一条 Pipeline
        ├── 一个 Handler
        ├── 一个 Handler
        └── 一个 Handler
```

如果多个连接：

```text
服务端
└── 多个 Channel
    ├── Channel-1
    │   └── Pipeline
    │       └── Handlers
    ├── Channel-2
    │   └── Pipeline
    │       └── Handlers
    └── Channel-N
        └── Pipeline
            └── Handlers
```

---

## 十、一句话记忆

记这一句就够了：

```text
Channel 负责承载连接
Pipeline 负责组织处理流程
Handler 负责执行具体处理步骤
```

如果把这句和上一份“父子 Channel 层级说明”连起来，你对 Netty 服务端的主框架就已经搭起来了。
