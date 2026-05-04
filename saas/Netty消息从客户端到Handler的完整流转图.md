# Netty 消息从客户端到 Handler 的完整流转图

## 一、为什么要看“完整流转”

前两篇文档解决了两个问题：

1. Netty 服务端为什么有 `parent / child`
2. `Channel / Pipeline / Handler` 三层之间是什么关系

但真正学习 Netty 时，最容易卡住的问题不是“结构是什么”，而是：

```text
一条消息到底是怎么流动的
```

这篇文档就只解决这一件事。

---

## 二、先看一句总路线

一条消息从客户端到服务端，大致流向是：

```text
客户端
→ SocketChannel
→ Pipeline
→ Handler
→ 业务处理
→ writeAndFlush
→ Pipeline
→ SocketChannel
→ 客户端
```

也就是：

```text
入站：网络到业务
出站：业务到网络
```

---

## 三、客户端连接建立时发生什么

先看“连接建立”这一步。

### 1. 客户端发起连接

```text
client
└── connect(server:port)
```

### 2. 服务端父 Channel 接收到连接

```text
NioServerSocketChannel
└── accept 新连接
    └── 创建一个新的 SocketChannel
```

### 3. 子 Channel 初始化 Pipeline

```text
SocketChannel
└── Pipeline
    ├── Handler-1
    ├── Handler-2
    └── Handler-3
```

### 4. 触发连接激活事件

当连接建立完成后，会触发：

```text
channelActive()
```

层级图：

```text
客户端 connect
    ↓
服务端 accept
    ↓
创建 SocketChannel
    ↓
初始化 Pipeline
    ↓
触发 channelActive()
```

---

## 四、客户端发送消息后的入站流

这是最核心的部分。

假设客户端发送一条消息：

```text
"hello netty"
```

完整入站流如下：

```text
客户端发送数据
    ↓
服务端 SocketChannel 收到字节
    ↓
进入该 Channel 对应的 Pipeline
    ↓
依次流过各个入站 Handler
    ↓
某个 Handler 的 channelRead() 被调用
    ↓
业务代码处理消息
```

图示：

```text
client
  |
  | send "hello netty"
  v
SocketChannel
  |
  v
Pipeline
  |
  +--> Inbound Handler-1
  |
  +--> Inbound Handler-2
  |
  +--> Inbound Handler-3
  |
  v
channelRead(...)
  |
  v
business logic
```

---

## 五、把入站流拆成层级看

用树状结构看会更清楚：

```text
客户端消息
└── 到达 SocketChannel
    └── 进入 Pipeline
        └── 依次经过多个 Handler
            └── 最终进入业务处理代码
```

这句话可以直接背下来：

```text
消息不是直接到 Handler，
而是先到 Channel，再进入 Pipeline，再交给 Handler。
```

---

## 六、在 Demo2 里对应什么代码

你在 `Demo2NettyEcho` 里看到的是：

```java
channel.pipeline().addLast(new ChannelInboundHandlerAdapter() {
  @Override
  public void channelRead(ChannelHandlerContext ctx, Object msg) {
    ByteBuf buf = (ByteBuf) msg;
    String text = buf.toString(CharsetUtil.UTF_8);
    System.out.println("[server] received: " + text);
    ctx.writeAndFlush(Unpooled.copiedBuffer("echo: " + text, CharsetUtil.UTF_8));
    buf.release();
  }
});
```

这段代码对应的流转图是：

```text
客户端发消息
    ↓
SocketChannel 收到数据
    ↓
Pipeline 把数据传给这个 Handler
    ↓
channelRead(ctx, msg) 被调用
    ↓
把 ByteBuf 转成字符串
    ↓
业务逻辑打印消息
    ↓
writeAndFlush() 回写响应
```

---

## 七、什么是 channelRead()

`channelRead()` 可以理解成：

```text
当前这个 Handler 收到了入站消息
```

注意它不是：

- 客户端主动调用的
- 你手动触发的

而是 Netty 在检测到网络数据到达之后，沿着 `Pipeline` 自动调到这里。

所以触发顺序是：

```text
网络数据到了
→ Channel 接住
→ Pipeline 分发
→ Handler 的 channelRead() 被调用
```

---

## 八、服务端回消息时的出站流

服务端处理完消息后，通常会回写：

```java
ctx.writeAndFlush(...)
```

这时消息流反过来：

```text
业务代码 writeAndFlush()
    ↓
进入 Pipeline
    ↓
经过出站 Handler
    ↓
写回 SocketChannel
    ↓
网络发送给客户端
```

图示：

```text
business logic
  |
  | writeAndFlush()
  v
Pipeline
  |
  +--> Outbound Handler-1
  |
  +--> Outbound Handler-2
  |
  v
SocketChannel
  |
  v
client
```

所以完整闭环是：

```text
客户端发消息
→ 服务端入站处理
→ 业务逻辑处理
→ 服务端出站回写
→ 客户端收到响应
```

---

## 九、完整闭环总图

把连接建立、入站、出站三段合起来：

```text
1. 客户端 connect
   ↓
2. 服务端 parent channel accept
   ↓
3. 创建 child SocketChannel
   ↓
4. 初始化该 SocketChannel 的 Pipeline
   ↓
5. 触发 channelActive()
   ↓
6. 客户端发送消息
   ↓
7. SocketChannel 收到字节流
   ↓
8. Pipeline 把消息交给入站 Handler
   ↓
9. Handler 的 channelRead() 执行业务逻辑
   ↓
10. ctx.writeAndFlush() 回写消息
    ↓
11. 出站消息经过 Pipeline
    ↓
12. SocketChannel 把数据发回客户端
```

---

## 十、把它压缩成两条主线

你只要记住两条主线就够了。

### 1. 连接主线

```text
connect
→ accept
→ 创建 SocketChannel
→ 初始化 Pipeline
→ channelActive
```

### 2. 消息主线

```text
客户端 send
→ Channel 收到
→ Pipeline 分发
→ Handler 处理
→ writeAndFlush
→ 客户端收到响应
```

---

## 十一、最容易混淆的点

### 1. 消息不是直接到 Handler

错误理解：

```text
客户端消息 → Handler
```

正确理解：

```text
客户端消息
→ Channel
→ Pipeline
→ Handler
```

### 2. Pipeline 不是全局只有一条

错误理解：

```text
整个服务端共用一条 Pipeline
```

正确理解：

```text
每个 SocketChannel 都有自己的 Pipeline
```

### 3. channelRead() 不是手动调的

错误理解：

```text
我要主动执行 channelRead()
```

正确理解：

```text
网络事件到了，Netty 自动沿 Pipeline 调用它
```

---

## 十二、一句话总结

记这一句：

```text
客户端消息先进入 Channel，
再进入这条连接自己的 Pipeline，
最后由 Handler 一步步处理，
处理完再通过 writeAndFlush 沿出站路径写回客户端。
```

把这条主线记住，你看大多数 Netty 示例代码就不会再觉得“消息像是凭空跑到 Handler 里”的了。
