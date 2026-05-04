# Netty 中的入站 Handler 和出站 Handler 区别说明

## 一、为什么这个点必须单独学

很多人刚学 Netty 时，最容易混淆的不是：

- `Channel`
- `Pipeline`
- `Handler`

而是：

```text
什么叫入站
什么叫出站
为什么 channelRead() 是入站
为什么 writeAndFlush() 是出站
```

这篇文档只解决这一个问题。

---

## 二、先记结论

一句话先记住：

```text
从网络到业务，叫入站
从业务到网络，叫出站
```

也就是：

```text
客户端 -> 服务端处理代码    = 入站
服务端处理代码 -> 客户端    = 出站
```

---

## 三、先用图看方向

### 1. 入站方向

```text
客户端
  |
  v
SocketChannel
  |
  v
Pipeline
  |
  v
Inbound Handler
  |
  v
业务逻辑
```

含义：

- 消息从外面进来
- 进入当前连接
- 经过处理链
- 最后被业务代码消费

所以叫：

```text
入站 = 进入服务端内部
```

---

### 2. 出站方向

```text
业务逻辑
  |
  v
Outbound Handler
  |
  v
Pipeline
  |
  v
SocketChannel
  |
  v
客户端
```

含义：

- 业务代码要回写消息
- 消息从服务端内部往外发
- 最后发回客户端

所以叫：

```text
出站 = 从服务端内部发出去
```

---

## 四、为什么 `channelRead()` 是入站

你在 Netty 代码里最常见的方法之一就是：

```java
channelRead(ChannelHandlerContext ctx, Object msg)
```

这个方法的触发条件是：

```text
网络上有数据进来了
```

流向图：

```text
客户端发消息
  ↓
SocketChannel 收到字节
  ↓
Pipeline 分发
  ↓
Inbound Handler 的 channelRead() 被调用
```

所以它属于：

```text
入站事件
```

因为消息是“进来”的，不是“出去”的。

---

## 五、为什么 `writeAndFlush()` 是出站

当业务代码要回消息时，通常会写：

```java
ctx.writeAndFlush(msg)
```

这时含义是：

```text
把当前这条消息写出去
```

流向图：

```text
业务代码
  ↓
writeAndFlush()
  ↓
Pipeline
  ↓
Outbound Handler
  ↓
SocketChannel
  ↓
客户端
```

所以它属于：

```text
出站事件
```

---

## 六、把入站和出站放到一张图里

```text
                入站方向
client  ---------------------------->  server
         Channel -> Pipeline -> Inbound Handler -> business logic

                出站方向
client  <----------------------------  server
         Channel <- Pipeline <- Outbound Handler <- writeAndFlush()
```

这张图要重点看箭头方向。

入站和出站不是看“谁写代码”，而是看：

```text
消息的流动方向
```

---

## 七、入站 Handler 和出站 Handler 的职责差异

### 1. 入站 Handler 典型职责

入站 Handler 常做这些事：

- 收包
- 拆包
- 解码
- 认证
- 权限检查
- 业务消息处理
- 心跳处理

图示：

```text
网络消息进来
→ 先解码
→ 再鉴权
→ 再进入业务逻辑
```

所以入站 Handler 更像：

```text
接收和处理输入
```

---

### 2. 出站 Handler 典型职责

出站 Handler 常做这些事：

- 编码
- 压缩
- 加密
- 出站日志
- 写回前封装协议

图示：

```text
业务结果出来
→ 先编码
→ 再封装协议
→ 再发送出去
```

所以出站 Handler 更像：

```text
加工和发送输出
```

---

## 八、常见理解误区

### 1. 误区：谁先写代码谁就是入站

错误理解：

```text
我先写的 handler 就是入站
```

正确理解：

```text
是否入站，看消息是进来还是出去
```

---

### 2. 误区：`channelRead()` 和 `writeAndFlush()` 是同一类事件

错误理解：

```text
反正都在 handler 里调用，所以差不多
```

正确理解：

```text
channelRead() 是网络数据进入后的入站回调
writeAndFlush() 是业务数据发送出去时的出站动作
```

---

### 3. 误区：一个 Handler 同时就是入站和出站

不一定。

Netty 里很多 Handler 是有明确方向性的：

- 有些只处理入站
- 有些只处理出站
- 有些同时支持两边

所以不要把所有 Handler 都当成“万能处理器”。

---

## 九、在 Demo2 里怎么理解

在 `Demo2NettyEcho` 里，核心代码是：

```java
public void channelRead(ChannelHandlerContext ctx, Object msg) {
  ByteBuf buf = (ByteBuf) msg;
  String text = buf.toString(CharsetUtil.UTF_8);
  System.out.println("[server] received: " + text);
  ctx.writeAndFlush(Unpooled.copiedBuffer("echo: " + text, CharsetUtil.UTF_8));
  buf.release();
}
```

这段代码里同时出现了入站和出站。

### 入站部分

```text
客户端发来消息
→ channelRead() 被触发
```

也就是：

```text
收到消息 = 入站
```

### 出站部分

```text
ctx.writeAndFlush(...)
→ 把响应发回客户端
```

也就是：

```text
发送响应 = 出站
```

所以这一个方法里，逻辑上其实发生了两件事：

```text
先处理入站消息
再发起出站响应
```

---

## 十、从“请求-响应”视角看更容易懂

如果把一次通信看成 HTTP 风格的“请求-响应”，就更好理解：

```text
客户端请求  = 入站
服务端响应  = 出站
```

Netty 只是底层网络框架，不是 HTTP 框架，但这个理解方式对初学者非常有效。

图示：

```text
请求:
client -> server
      = 入站

响应:
server -> client
      = 出站
```

---

## 十一、最终总图

```text
客户端发送请求
    ↓
SocketChannel 收到数据
    ↓
Pipeline
    ↓
Inbound Handler
    ↓
业务处理
    ↓
writeAndFlush()
    ↓
Outbound Handler
    ↓
SocketChannel 写出数据
    ↓
客户端收到响应
```

这里可以压缩成一句：

```text
进来的是入站，出去的是出站
```

---

## 十二、一句话总结

记这一句最实用：

```text
channelRead() 处理的是“收到的消息”，所以是入站；
writeAndFlush() 处理的是“发出的消息”，所以是出站。
```

把这个方向感建立起来后，后面看编解码器、心跳处理器、协议处理器时就不会混乱。
