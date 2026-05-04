# ClassicReplicaStores 状态模型说明

本文专门解释：

- `com.example.replica.classic.ClassicReplicaStores`

里几个核心状态之间的关系。

很多人第一次看这个类时，会把它理解成“放了几个 Map 和一个队列”。

但更准确的理解方式是：

> 它不是零散的几个集合，而是一个小型通信状态中心。  
> 这些状态共同服务于三件事：
>
> 1. 在线订阅路由  
> 2. ACK 确认与重试补偿  
> 3. 同步结果回传

---

## 1. 先看里面有哪些核心状态

在 `ClassicReplicaStores` 里，最关键的是这 5 个：

```java
TOPIC_TO_CONTEXT
CONTEXT_TO_TOPICS
PENDING_MESSAGES
RETRY_QUEUE
SYNC_CALLBACKS
```

虽然它们都放在一个类里，但实际上它们属于 **3 组不同的模型**。

---

## 2. 模型一：订阅路由模型

这组状态解决的问题是：

> 设备在线后，服务端怎么知道一条消息该发给谁

包含两个表：

- `TOPIC_TO_CONTEXT`
- `CONTEXT_TO_TOPICS`

这两张表是一组正反索引。

---

### 2.1 `TOPIC_TO_CONTEXT`

含义：

```text
topic -> 哪些连接订阅了这个 topic
```

例如：

```text
1001_server -> [ctxA]
device_a_server -> [ctxA]
```

它的用途是：

- 当业务系统准备给 `1001_server` 发消息时
- 服务端直接通过这张表找到在线连接

也就是说：

> 它是发送时使用的正向路由表

---

### 2.2 `CONTEXT_TO_TOPICS`

含义：

```text
某个连接 -> 这个连接订阅了哪些 topic
```

例如：

```text
ctxA -> [1001_server, device_a_server]
```

它的用途是：

- 当连接断开时
- 服务端可以快速知道这个连接曾经订阅过哪些 topic

也就是说：

> 它是断线清理时使用的反向索引表

---

### 2.3 这两张表为什么要同时存在

如果只有：

```text
TOPIC_TO_CONTEXT
```

那么发送消息时没问题，因为你知道：

```text
topic -> 连接
```

但是断线时就麻烦了。

因为这时你知道的是：

```text
连接断了
```

却不知道：

```text
它对应哪些 topic
```

如果没有反向表，你就只能：

1. 遍历整个 `TOPIC_TO_CONTEXT`
2. 一个 topic 一个 topic 找
3. 看每个连接集合里有没有这个 context

效率很差。

所以必须同时保留：

```text
TOPIC_TO_CONTEXT
CONTEXT_TO_TOPICS
```

你可以把它们记成：

```text
TOPIC_TO_CONTEXT  = 正向路由
CONTEXT_TO_TOPICS = 反向清理索引
```

---

## 3. 模型二：ACK 与重试补偿模型

这组状态解决的问题是：

> 消息发出后，怎么确认是否送达  
> 如果没确认，后面要不要重发

包含两个核心状态：

- `PENDING_MESSAGES`
- `RETRY_QUEUE`

---

### 3.1 `PENDING_MESSAGES`

含义：

```text
msgId -> 这条消息还在等待 ACK
```

里面存的不是一个简单字符串，而是一条待确认记录，通常包括：

- 发给哪个 `topic`
- 原始消息对象
- 最大重试次数
- 创建时间

例如：

```text
msg-123 -> PendingMessage(
  topic=1001_server,
  message=...,
  maxRetryTimes=4
)
```

它的用途是：

- 标记这条消息“账还没平”
- 只要它还在，说明 ACK 还没完成闭环

所以它更像：

> 待确认账本

---

### 3.2 `RETRY_QUEUE`

含义：

```text
后续某个时间点要不要再试一次
```

里面存的是重试任务，而不是原始消息本体。

例如：

```text
RetryTask(msg-123, 0)
RetryTask(msg-123, 1)
```

表示：

- 哪条消息需要重试
- 当前是第几次尝试

它的用途是：

- 模拟 RocketMQ 延迟消息
- 消费者线程从这里取出任务
- 再去看 `PENDING_MESSAGES`

如果：

- 这条消息还在 pending 里
  - 说明还没 ACK
  - 那就可以重发

如果：

- 这条消息已经不在 pending 里
  - 说明 ACK 已到
  - 那就不用再发了

所以它更像：

> 补偿调度队列

---

### 3.3 这两个状态之间的关系

你要把它们区分开：

#### `PENDING_MESSAGES`

回答的是：

```text
这条消息现在还欠不欠确认
```

#### `RETRY_QUEUE`

回答的是：

```text
我要不要在某个时间点再拿它出来检查一次
```

所以它们不是一个东西。

更准确的关系是：

```text
PENDING_MESSAGES = 状态账本
RETRY_QUEUE      = 补偿驱动器
```

---

## 4. 模型三：同步回执模型

这组状态解决的问题是：

> 如果业务不是只要 ACK，而是要等待设备真正处理完后的返回值，该怎么做

核心状态是：

- `SYNC_CALLBACKS`

---

### 4.1 `SYNC_CALLBACKS`

含义：

```text
msgId -> 谁在等这条同步结果
```

例如：

```text
msg-456 -> futureA
```

意思是：

- 有一条同步请求消息 `msg-456`
- 当前有一个等待对象 `futureA`
- 它在等设备返回 `sync_result`

它的用途是：

1. `sendWithSync()` 发送前先登记
2. 设备返回 `sync_result` 时
3. 服务端根据 `msgId` 找到对应等待者
4. 再把结果唤醒给原调用线程

所以它更像：

> 同步调用等待表

---

### 4.2 它和 ACK/重试模型的区别

这点特别重要。

#### ACK / retry 模型

解决的是：

```text
这条消息送达了吗
```

#### `SYNC_CALLBACKS`

解决的是：

```text
设备处理后的业务结果是什么
```

换句话说：

```text
ACK          = 已收到
sync_result  = 已处理并返回结果
```

所以：

- `PENDING_MESSAGES` 和 `RETRY_QUEUE` 关心送达确认
- `SYNC_CALLBACKS` 关心同步业务返回值

---

## 5. 这三组模型放在一起怎么看

现在把 5 个状态重新整理：

---

### 5.1 路由模型

决定：

```text
这条消息应该发给谁
```

包含：

- `TOPIC_TO_CONTEXT`
- `CONTEXT_TO_TOPICS`

---

### 5.2 补偿模型

决定：

```text
这条消息有没有被确认
没确认的话要不要补发
```

包含：

- `PENDING_MESSAGES`
- `RETRY_QUEUE`

---

### 5.3 同步模型

决定：

```text
谁在等这条同步调用的返回结果
```

包含：

- `SYNC_CALLBACKS`

---

## 6. 一条异步消息经过这些状态时的流转

下面用一条普通异步消息来串起来看。

假设：

- 设备先完成了订阅
- 业务系统要给 `1001_server` 发一条普通消息

---

### 第一步：设备订阅时，写入路由模型

写入：

```text
TOPIC_TO_CONTEXT
CONTEXT_TO_TOPICS
```

此时系统知道：

```text
1001_server -> ctxA
```

---

### 第二步：业务发送时，写入补偿模型

写入：

```text
PENDING_MESSAGES[msgId]
RETRY_QUEUE.offer(RetryTask)
```

此时系统知道：

- 这条消息已经发起
- 还在等待 ACK
- 后面如果需要，还可以再检查一次是否重发

---

### 第三步：按 topic 查路由表发送

服务端通过：

```text
TOPIC_TO_CONTEXT
```

找到：

```text
ctxA
```

然后把消息写给它。

---

### 第四步：设备回 ACK

服务端收到 ACK 后：

删除：

```text
PENDING_MESSAGES[msgId]
```

这表示：

> 这条消息账平了

---

### 第五步：retry 线程后面取到任务

retry 线程从：

```text
RETRY_QUEUE
```

取到这条任务后，再去查：

```text
PENDING_MESSAGES
```

如果发现已经没了：

那就说明 ACK 已经到了

于是：

```text
跳过，不重发
```

---

## 7. 一条同步消息经过这些状态时的流转

同步消息和异步消息相比，会多走一组：

```text
SYNC_CALLBACKS
```

---

### 第一步：路由模型照常存在

设备已经订阅：

- `TOPIC_TO_CONTEXT`
- `CONTEXT_TO_TOPICS`

---

### 第二步：发送前登记同步等待者

写入：

```text
SYNC_CALLBACKS[msgId] = future
```

这表示：

```text
有一个线程正在等 msgId 这条消息的业务结果
```

---

### 第三步：消息照常发给设备

这一步仍然会走：

```text
TOPIC_TO_CONTEXT
```

进行路由发送。

---

### 第四步：设备先回 ACK

服务端删除：

```text
PENDING_MESSAGES[msgId]
```

这说明：

```text
消息送达成功
```

但同步调用还没结束。

---

### 第五步：设备再回 sync_result

服务端收到：

```text
sync_result
```

之后，会按 `msgId` 去：

```text
SYNC_CALLBACKS
```

里找等待者。

找到后：

- 完成 future
- 唤醒业务线程

然后删除：

```text
SYNC_CALLBACKS[msgId]
```

这表示：

```text
同步结果已经交付完成
```

---

## 8. 你最容易混淆的地方

下面列几个最常见误区。

---

### 误区 1：`PENDING_MESSAGES` 和 `RETRY_QUEUE` 是一个东西

不是。

#### `PENDING_MESSAGES`

记录的是：

```text
消息状态还没确认
```

#### `RETRY_QUEUE`

记录的是：

```text
后面某个时机要再检查一次
```

所以：

- 一个是状态账本
- 一个是驱动重试的调度队列

---

### 误区 2：ACK 和 `sync_result` 是一个东西

不是。

#### ACK

表示：

```text
我收到了
```

#### `sync_result`

表示：

```text
我处理完了，结果是这个
```

所以：

- ACK 对应 `PENDING_MESSAGES`
- `sync_result` 对应 `SYNC_CALLBACKS`

---

### 误区 3：`CONTEXT_TO_TOPICS` 没什么用

其实它非常重要。

没有它的话：

- 连接断开时
- 你就不知道它曾经订阅过哪些 topic

只能全表扫描 `TOPIC_TO_CONTEXT`

所以它是：

> 断线清理性能和正确性的关键

---

## 9. 一句话总结这 5 个状态

你可以直接背成下面这组句子：

### 路由组

```text
TOPIC_TO_CONTEXT  = 发消息时查“谁在线”
CONTEXT_TO_TOPICS = 断线时查“它订阅了什么”
```

### 补偿组

```text
PENDING_MESSAGES = 记“这条消息还没被确认”
RETRY_QUEUE      = 驱动“后面要不要补发”
```

### 同步组

```text
SYNC_CALLBACKS   = 记“谁在等同步结果”
```

---

## 10. 最终心智模型

如果你想把 `ClassicReplicaStores` 用一句话记住，最推荐的说法是：

> 它是 classic 版的通信状态中心，内部同时维护了路由、补偿、同步回执三套模型。

再拆开就是：

1. 路由模型：解决“发给谁”
2. 补偿模型：解决“没确认怎么办”
3. 同步模型：解决“结果回给谁”

---

## 11. 建议你接下来连着看

如果你已经看懂了这份说明，建议下一步直接连着看下面几个类：

1. `ClassicReplicaStores`
2. `ClassicServerHandler`
3. `ClassicRetryConsumer`
4. `ClassicBusinessService`

你会很容易对上：

- 哪个类负责写路由模型
- 哪个类负责消费补偿模型
- 哪个类负责登记同步模型

