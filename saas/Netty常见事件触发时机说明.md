# Netty 常见事件触发时机说明

## 1. 先记一句总话

Netty 里的各种事件，本质上可以分成 4 类：

1. 连接状态事件
2. 数据收发事件
3. 用户自定义事件
4. 异常事件

如果用最简单的话说：

```text
连上了、收到数据了、超时了、断开了、出错了
```

这些就是 Netty Handler 最常见的触发场景。

---

## 2. `channelActive()` 什么时候触发

## 2.1 触发条件

```text
连接建立成功，并且已经可用了
```

常见场景：

- 客户端 connect 成功
- 服务端 accept 到一个新连接，并且连接已进入 active 状态

## 2.2 通俗理解

```text
这条连接已经连上了，可以开始通信了
```

## 2.3 在项目里通常干什么

常见用途：

- 打印连接建立日志
- 做连接初始化
- 客户端连上后立刻发送订阅消息

---

## 3. `channelRead()` 什么时候触发

## 3.1 触发条件

```text
当前连接收到了数据
```

也就是：

- 对端发来了 TCP 数据
- Netty 收到字节
- 经过前面的解码器/拆包器
- 当前 Handler 收到可处理消息

## 3.2 通俗理解

```text
对方发消息来了
```

## 3.3 在项目里通常干什么

常见用途：

- 从 `ByteBuf` 读出数据
- 转成字符串或对象
- 解析 JSON
- 进入业务处理逻辑

---

## 4. `channelReadComplete()` 什么时候触发

## 4.1 触发条件

```text
本轮读取结束
```

注意，这不是说：

```text
连接所有数据读完了
```

而是说：

- Netty 这一轮把当前可读的数据都读完了
- 于是发一个“这一轮读取完成”的通知

## 4.2 通俗理解

```text
这一批收到的数据处理完了
```

## 4.3 在项目里通常干什么

常见用途：

- 做一轮读取后的收尾
- flush
- 批量处理结束通知

---

## 5. `userEventTriggered()` 什么时候触发

## 5.1 触发条件

```text
Pipeline 中出现了“用户事件”
```

最常见来源：

- `IdleStateHandler`

比如：

- 长时间没收到数据
- 长时间没发数据
- 长时间没有任何收发

这类空闲检测事件通常都会走到：

- `userEventTriggered()`

## 5.2 通俗理解

```text
这不是普通收包事件，而是系统通知型事件
```

## 5.3 在项目里通常干什么

常见用途：

- 心跳检测
- 空闲超时检测
- 超时后关闭连接
- 长时间没写数据时发送 ping

---

## 6. `channelInactive()` 什么时候触发

## 6.1 触发条件

```text
连接从可用状态变成不可用状态
```

常见场景：

- 对端主动断开
- 本端主动 `close()`
- 网络断开
- 心跳超时后主动关闭
- 远端进程挂了

## 6.2 通俗理解

```text
这条连接断了，不能再用了
```

## 6.3 在项目里通常干什么

常见用途：

- 服务端清理订阅关系
- 从 `topicToContext` 删除该连接
- 客户端触发重连逻辑

---

## 7. `channelRegistered()` 什么时候触发

## 7.1 触发条件

```text
Channel 被注册到 EventLoop 上
```

## 7.2 通俗理解

```text
这条连接已经被 Netty 的线程模型正式接管了
```

## 7.3 常见用途

- 初始化一些跟 EventLoop 绑定的逻辑
- 做底层生命周期跟踪

这个事件在业务代码里通常没有 `channelRead()` 那么常用。

---

## 8. `channelUnregistered()` 什么时候触发

## 8.1 触发条件

```text
Channel 从 EventLoop 上解绑
```

## 8.2 通俗理解

```text
这条连接已经彻底退出 Netty 的调度体系
```

这个事件通常比 `channelInactive()` 更偏底层。

---

## 9. `exceptionCaught()` 什么时候触发

## 9.1 触发条件

```text
Handler 处理过程中出现异常
```

例如：

- 解码异常
- JSON 解析异常
- 写出异常
- 业务处理异常

## 9.2 通俗理解

```text
这条连接在处理消息时出错了
```

## 9.3 在项目里通常干什么

常见用途：

- 打错误日志
- 关闭连接
- 做降级处理

---

## 10. `write()`、`flush()`、`writeAndFlush()` 是什么

这几个不是“收到事件后的回调”，更像是你主动发起的出站动作。

## 10.1 `write()`

含义：

```text
把数据先写到发送缓冲区
```

## 10.2 `flush()`

含义：

```text
把缓冲区里的数据真正发出去
```

## 10.3 `writeAndFlush()`

含义：

```text
写入并立刻发出去
```

## 10.4 通俗理解

```text
writeAndFlush() = 我要主动给对方发消息
```

---

## 11. 在你们项目里怎么理解最清楚

你们这种 Netty 长连接项目里，最常见的事件生命周期通常是：

```text
1. channelActive
   连接建立

2. channelRead
   收到业务消息或心跳消息

3. userEventTriggered
   长时间没收发，IdleStateHandler 触发空闲事件

4. channelInactive
   因断网、超时或主动 close 导致连接失效
```

也可能在任意一步出现：

```text
exceptionCaught
```

---

## 12. 一张总图看生命周期

```text
客户端发起连接
    |
    v
channelRegistered
    |
    v
channelActive
    |
    | 收到数据
    v
channelRead
    |
    v
channelReadComplete
    |
    | 长时间无收发 / IdleStateHandler 触发
    v
userEventTriggered
    |
    | 超时后主动 close，或网络断开
    v
channelInactive
    |
    v
channelUnregistered

在整个过程中任何一步都可能出现：
exceptionCaught
```

---

## 13. 和你最关心的几个事件对照记忆

### `channelActive`

```text
连上了
```

### `channelRead`

```text
收到数据了
```

### `userEventTriggered`

```text
系统通知事件来了，常见是心跳超时
```

### `channelInactive`

```text
断开了
```

### `exceptionCaught`

```text
出错了
```

### `writeAndFlush`

```text
我要发消息了
```

---

## 14. 最后一句总结

把 Netty 常见事件压缩成一句最实用的话：

```text
channelActive 是连上，
channelRead 是收包，
userEventTriggered 是系统通知，
channelInactive 是断开，
exceptionCaught 是出错，
writeAndFlush 是主动发包。
```
