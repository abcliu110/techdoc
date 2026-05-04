# Netty 父子 Channel 层级说明

## 一、为什么用父子命名

在 Netty 服务端模型里，存在两类不同的 Channel：

1. 监听端口的服务端 Channel
2. 每个客户端接入后产生的连接 Channel

所以这里不是随便起名为 `A/B` 或 `主/从`，而是明确表达一种层级关系：

- `parent`：父 Channel，负责监听端口
- `child`：子 Channel，负责具体连接通信

这套命名来自最原始的 Socket 编程模型。

---

## 二、原生 Socket 的层级关系

先看原生 Java Socket：

```java
ServerSocket serverSocket = new ServerSocket(18082);
Socket socket = serverSocket.accept();
```

这里天然就有两层：

```text
ServerSocket :18082
└── Socket(client-1)
```

如果多个客户端连接：

```text
ServerSocket :18082
├── Socket(client-1)
├── Socket(client-2)
├── Socket(client-3)
└── Socket(client-n)
```

含义很直接：

- `ServerSocket` 只负责监听端口
- 每次 `accept()` 都会返回一个新的 `Socket`
- 所以监听者在上层，连接者在下层

这就是 Netty 里“父子命名”的现实来源。

---

## 三、Netty 中的父子层级

对应到 Netty：

```text
NioServerSocketChannel
├── SocketChannel(client-1)
├── SocketChannel(client-2)
├── SocketChannel(client-3)
└── SocketChannel(client-n)
```

这里的含义是：

- `NioServerSocketChannel`：父 Channel
- `SocketChannel`：子 Channel

父 Channel 负责：

- 绑定端口
- 接收新连接
- 产生子连接

子 Channel 负责：

- 与某个具体客户端通信
- 接收数据
- 发送数据
- 走 `pipeline`
- 触发 `handler`

所以 `child` 的本质不是“子类”，而是“父监听端接出来的具体连接”。

---

## 四、ServerBootstrap 的层级图

```text
ServerBootstrap
├── parentGroup / bossGroup
└── childGroup / workerGroup
```

继续展开：

```text
ServerBootstrap
├── parentGroup / bossGroup
│   └── NioServerSocketChannel
│       └── 负责监听端口、accept 新连接
└── childGroup / workerGroup
    ├── SocketChannel(client-1)
    ├── SocketChannel(client-2)
    ├── SocketChannel(client-3)
    └── SocketChannel(client-n)
        └── 负责读写、编解码、业务处理
```

这就是下面这行代码的真实含义：

```java
bootstrap.group(bossGroup, workerGroup)
```

不是简单地传两个线程池，而是在说：

- 第一个线程组服务父 Channel
- 第二个线程组服务子 Channel

---

## 五、为什么参数名叫 parentGroup / childGroup

`ServerBootstrap.group(...)` 方法的定义是：

```java
group(EventLoopGroup parentGroup, EventLoopGroup childGroup)
```

参数名直接表达了它服务的对象：

```text
parentGroup
└── 服务于 parent channel

childGroup
└── 服务于 child channel
```

也就是：

```text
parentGroup -> 管监听者
childGroup  -> 管监听者接入进来的每个连接
```

这比单纯命名为：

- `listenerGroup`
- `ioGroup`

更准确，因为它强调的是层级归属，而不仅仅是职责分工。

---

## 六、bossGroup 和 workerGroup 的层级含义

在实际代码里，通常写成：

```java
EventLoopGroup bossGroup = new NioEventLoopGroup(1);
EventLoopGroup workerGroup = new NioEventLoopGroup();

bootstrap.group(bossGroup, workerGroup);
```

对应层级图：

```text
bossGroup
└── NioServerSocketChannel
    └── 负责 accept

workerGroup
├── SocketChannel(client-1)
├── SocketChannel(client-2)
└── SocketChannel(client-n)
    └── 负责每条连接上的读写事件
```

所以：

- `boss` 不是业务处理线程
- `boss` 只是“接连接”
- `worker` 才是“处理连接上的数据”

---

## 七、handler 和 childHandler 的层级关系

`ServerBootstrap` 里还有两个特别容易混淆的方法：

```java
.handler(...)
.childHandler(...)
```

层级关系如下：

```text
ServerBootstrap
├── handler(...)
│   └── 作用于 parent channel
│       └── NioServerSocketChannel
└── childHandler(...)
    └── 作用于 child channel
        ├── SocketChannel(client-1)
        ├── SocketChannel(client-2)
        └── SocketChannel(client-n)
```

图示理解：

```text
NioServerSocketChannel
├── handler(...)
├── SocketChannel(client-1)
│   └── childHandler(...)
├── SocketChannel(client-2)
│   └── childHandler(...)
└── SocketChannel(client-n)
    └── childHandler(...)
```

这再次证明 Netty 的整个服务端设计都围绕“父子结构”展开。

---

## 八、子 Channel 内部还有自己的层级

每个子连接内部还有一层结构：

```text
SocketChannel(client-1)
└── Pipeline
    ├── Handler-1
    ├── Handler-2
    └── Handler-3
```

多个连接展开后：

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
└── SocketChannel(client-n)
    └── Pipeline
        ├── Handler-1
        ├── Handler-2
        └── Handler-3
```

所以整体是一棵树：

```text
ServerBootstrap
└── NioServerSocketChannel
    ├── SocketChannel-1
    │   └── Pipeline
    │       └── Handlers
    ├── SocketChannel-2
    │   └── Pipeline
    │       └── Handlers
    └── SocketChannel-N
        └── Pipeline
            └── Handlers
```

---

## 九、一句话总结

之所以用 `parent / child` 命名，是因为 Netty 服务端里：

- 有一个监听端口的父 Channel
- 它会接入出多个具体连接的子 Channel
- 每个子 Channel 再维护自己的 `pipeline` 和 `handler`

所以这是天然的树状层级关系，不是并列关系。

---

## 十、学习时怎么记

记这一句就够了：

```text
一个父监听 Channel
下面挂很多子连接 Channel
每个子连接下面再挂自己的 Pipeline 和 Handler
```

把这句话记住，`group()`、`handler()`、`childHandler()` 的命名就都顺了。
