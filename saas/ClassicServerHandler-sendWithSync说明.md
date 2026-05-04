# ClassicServerHandler sendWithSync 说明

本文专门解释 `com.example.replica.classic.ClassicServerHandler` 里的同步回执链路：

- `sendWithSync()`
- `SYNC_CALLBACKS`
- `sync_result`

核心结论先说：

> `ACK` 解决的是“消息有没有送到设备”。  
> `sync_result` 解决的是“设备处理后的业务结果是什么”。  
> `sendWithSync()` 做的事情，就是把这条“请求 -> 设备处理 -> 同步返回结果”的链路串起来。

---

## 1. 先区分两个概念

很多人第一次看这里会把 `ACK` 和同步回执混在一起。

实际上它们不是一回事。

---

### 1.1 ACK 是什么

ACK 的意思是：

```text
我收到了这条消息
```

它只回答“送达”问题，不回答“处理结果”问题。

例如：

- 服务端给设备发一条消息
- 设备收到后立刻回：

```text
ack
```

这说明：

- 网络送达成功
- 服务端可以把 pending 删掉
- retry 不需要继续了

但是这并不代表：

- 设备已经完成了业务处理
- 也不代表处理结果是什么

---

### 1.2 sync_result 是什么

`sync_result` 的意思是：

```text
这条业务消息我不只是收到了，而且已经处理完了，这里是处理结果
```

例如：

- 业务侧发了一条同步请求
- 设备执行完后返回：

```text
sync_result
```

这个结果才是同步调用真正要等的东西。

所以你要把两者分开记：

```text
ACK = 已送达
sync_result = 已处理并返回结果
```

---

## 2. `sendWithSync()` 解决什么问题

普通异步发送时，流程是：

```text
业务服务 -> 发消息 -> 设备收到 -> ACK -> 结束
```

业务侧只知道：

- 这条消息大概率送到了

但它不知道：

- 设备处理结果是什么

而同步调用需要的是：

```text
业务服务发完以后，要在当前线程里拿到设备返回值
```

所以就需要一条额外链路：

```text
业务服务 -> 发消息 -> 设备处理 -> 设备返回 sync_result -> 服务端唤醒等待线程 -> 业务侧拿到结果
```

这就是 `sendWithSync()` 存在的原因。

---

## 3. 先看入口是谁在调它

在 `ClassicBusinessService.sendWithSync()` 里：

```java
return serverHandler.sendWithSync(topic, message);
```

说明：

- 业务层已经组好一条同步消息
- 并且设置了 `responseTopic=http_sync_topic`
- 然后让 `ClassicServerHandler` 去执行同步发送

这里你可以理解成：

> 业务层发起一次“我要等结果回来”的请求

---

## 4. `sendWithSync()` 方法本身做了什么

对应代码逻辑是：

```java
public ClassicReplicaMessage sendWithSync(String topic, ClassicReplicaMessage message) {
    CompletableFuture<ClassicReplicaMessage> callback = new CompletableFuture<>();
    ClassicReplicaStores.SYNC_CALLBACKS.put(message.getMsgId(), callback);
    sendMessage(topic, message);
    try {
        return callback.get(...);
    } finally {
        ClassicReplicaStores.SYNC_CALLBACKS.remove(message.getMsgId());
    }
}
```

它分四步。

---

## 5. 第一步：创建一个等待结果的“占位符”

代码：

```java
CompletableFuture<ClassicReplicaMessage> callback = new CompletableFuture<>();
```

这句的意思是：

- 先创建一个“未来某一时刻会被填上结果”的对象

你可以把它理解成：

```text
我先准备一个空盒子，等设备回结果时，再把结果放进去
```

这个空盒子此时还没有值。

---

## 6. 第二步：用 `msgId` 把这个等待对象注册起来

代码：

```java
ClassicReplicaStores.SYNC_CALLBACKS.put(message.getMsgId(), callback);
```

这句非常关键。

意思是：

- 用当前消息的 `msgId` 做 key
- 把这个等待对象存进共享表里

结果会变成类似这样：

```text
SYNC_CALLBACKS:
msg-123 -> futureA
```

这一步的意义是：

> 后面当设备回来了 `sync_result`，服务端就知道应该把结果交给谁

因为 `msgId` 是这条请求和响应的唯一关联键。

---

## 7. 第三步：真正发送消息给设备

代码：

```java
sendMessage(topic, message);
```

这一步和普通异步发送一样：

- 根据 `topic`
- 找到在线设备连接
- 把消息发出去

区别只在于：

- 这次发出去的消息里带了 `responseTopic=http_sync_topic`

所以设备端收到后会知道：

```text
这不是单纯异步消息
这是需要回同步结果的消息
```

---

## 8. 第四步：当前线程阻塞等待设备回结果

代码：

```java
return callback.get(Duration.ofSeconds(5).toMillis(), TimeUnit.MILLISECONDS);
```

意思是：

- 当前线程现在停下来等
- 最多等 5 秒
- 等那个 `CompletableFuture` 被别人填上值

这里的“别人”是谁？

答案是：

> 后面收到 `sync_result` 的那段 handler 逻辑

所以这一步本质上是：

```text
我先发出请求，然后原地等设备回来结果
```

---

## 9. 设备端是怎么配合这条链路的

在 `ClassicDeviceClient.ClientHandler.channelRead0()` 里：

设备收到消息后会先做两件事：

1. 回 ACK
2. 如果 `responseTopic` 不为空，再回 `sync_result`

也就是说，同步消息的设备侧流程其实是：

```text
收到消息
-> 回 ACK
-> 构造业务结果
-> 回 sync_result
```

所以这里就能解释为什么：

```text
ACK 和 sync_result 不是一回事
```

因为：

- ACK 是送达确认
- sync_result 是业务返回值

---

## 10. `sync_result` 回来后谁来处理

处理位置在 `ClassicServerHandler.handleMessage()`：

```java
if ("sync_result".equalsIgnoreCase(message.getCmd())
    && message.getTopics().contains("http_sync_topic")) {
    CompletableFuture<ClassicReplicaMessage> callback =
        ClassicReplicaStores.SYNC_CALLBACKS.remove(message.getMsgId());
    if (callback != null) {
        callback.complete(message);
    }
    return;
}
```

这段逻辑的意思是：

1. 收到一条 `sync_result`
2. 根据 `msgId` 去 `SYNC_CALLBACKS` 里找等待对象
3. 找到以后把这条响应消息塞进去
4. `callback.get()` 那边立刻被唤醒

---

## 11. 为什么 `callback.complete(message)` 会让业务线程继续往下走

因为：

- 业务线程之前卡在：

```java
callback.get(...)
```

- 现在 handler 线程执行了：

```java
callback.complete(message)
```

这就相当于把前面那个“空盒子”填满了。

于是等待中的线程会立刻拿到这个值：

```java
ClassicReplicaMessage
```

然后 `sendWithSync()` 返回给 `ClassicBusinessService`

再一路返回给调用方。

---

## 12. 最后为什么还要 `finally remove`

代码：

```java
finally {
    ClassicReplicaStores.SYNC_CALLBACKS.remove(message.getMsgId());
}
```

这句的意义是：

- 不管成功还是超时失败
- 都要把这条 `msgId -> future` 的映射清掉

否则会有两个问题：

1. 内存泄漏
2. 下次万一又碰到同样的 `msgId`，可能产生脏数据关联

所以这里是在做同步等待链的收尾。

---

## 13. 一条完整的同步链

下面按时间顺序看整条链路。

---

### 第 1 步：业务侧发起同步请求

`ClassicBusinessService.sendWithSync()`

构造消息：

```text
Cmd = nms4sync
Topic = 1001_server
ResponseTopic = http_sync_topic
MsgID = msg-123
```

然后调用：

```java
serverHandler.sendWithSync(...)
```

---

### 第 2 步：服务端注册等待对象

`ClassicServerHandler.sendWithSync()`

执行：

```text
SYNC_CALLBACKS:
msg-123 -> futureA
```

---

### 第 3 步：服务端把消息发给设备

调用：

```java
sendMessage(topic, message)
```

设备收到消息。

---

### 第 4 步：设备先回 ACK

服务端收到 ACK 后：

- 删除 pending
- 停止 retry 链

但此时同步调用还没有结束。

---

### 第 5 步：设备再回 sync_result

设备构造：

```text
Cmd = sync_result
Topic = http_sync_topic
MsgID = msg-123
mqtt_content = processed-by-classic-device
```

发回服务端。

---

### 第 6 步：服务端根据 `msgId` 找到等待对象

`handleMessage()` 里：

```java
callback = SYNC_CALLBACKS.remove("msg-123");
callback.complete(message);
```

---

### 第 7 步：业务线程被唤醒并拿到返回值

之前阻塞在：

```java
callback.get(...)
```

现在拿到结果，`sendWithSync()` 返回：

```text
ClassicReplicaMessage
```

调用链结束。

---

## 14. 你可以把 `SYNC_CALLBACKS` 理解成什么

最简单的理解：

```text
它是一张“谁在等哪条同步结果”的登记表
```

例如：

```text
msg-123 -> 业务线程A在等
msg-456 -> 业务线程B在等
```

当设备返回：

```text
msg-123 的结果
```

系统就知道：

```text
应该去唤醒业务线程A
```

---

## 15. 为什么这像教学版 `sendWithMono`

原始项目里常见做法是：

- 先注册一个等待对象
- 发送消息
- 等回调回来再继续

只是原始项目里常用：

- `Mono`
- `MonoSink`
- callback manager

这里为了降低理解门槛，用的是：

- `CompletableFuture`
- `Map<msgId, future>`

本质是一样的：

```text
请求发出去
-> 用 msgId 挂一个等待器
-> 响应回来时按 msgId 唤醒等待器
```

所以你可以把它理解成：

> 教学版同步回执管理器

---

## 16. 一句话总结 `sendWithSync()`

一句话理解：

> 先用 `msgId` 注册一个等待结果的 future，再把消息发出去，等设备回 `sync_result` 时按 `msgId` 把 future 填满。

再简化成最短一句：

> 发请求，挂等待，按 `msgId` 收结果。

---

## 17. 建议你接下来连着看

如果你已经理解这份文档，建议按下面顺序连着看：

1. `ClassicBusinessService.sendWithSync()`
2. `ClassicServerHandler.sendWithSync()`
3. `ClassicDeviceClient.ClientHandler.channelRead0()`
4. `ClassicServerHandler.handleMessage()` 里的 `sync_result` 分支

你会一次看清楚：

- 业务侧怎么发同步请求
- 服务端怎么挂等待对象
- 设备怎么回 ACK 和 sync_result
- 服务端怎么按 `msgId` 唤醒等待线程

