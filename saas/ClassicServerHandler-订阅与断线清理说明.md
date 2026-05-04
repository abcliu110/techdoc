# ClassicServerHandler 订阅与断线清理说明

本文专门解释 `com.example.replica.classic.ClassicServerHandler` 里最容易混淆的两段代码：

- `handleSubscribe()`
- `closeMappings()`

核心结论先说：

> `handleSubscribe()` 负责建立订阅路由关系。  
> `closeMappings()` 负责在连接断开或重订阅前，把旧的路由关系清理干净。

---

## 1. 两张核心表

在 `ClassicReplicaStores` 里有两张表：

### 1.1 `TOPIC_TO_CONTEXT`

含义：

```text
topic -> 哪些连接订阅了这个 topic
```

例如：

```text
1001_server -> [ctxA]
device_a_server -> [ctxA]
```

这张表的用途是：

- 当业务系统要给 `1001_server` 发消息时
- 服务端可以立刻找到应该发给哪个 Netty 连接

也就是说，它是：

> 正向路由表

---

### 1.2 `CONTEXT_TO_TOPICS`

含义：

```text
某个连接 -> 这个连接订阅了哪些 topic
```

例如：

```text
ctxA -> [1001_server, device_a_server]
```

这张表的用途是：

- 当某个连接断开时
- 服务端可以快速知道它之前挂了哪些 topic

也就是说，它是：

> 反向索引表

---

## 2. 为什么要维护两张表

如果只有 `TOPIC_TO_CONTEXT`，没有 `CONTEXT_TO_TOPICS`，那连接断开时会很麻烦。

因为你只知道：

- 某个连接 `ctxA` 断了

但你不知道：

- 它到底订阅过哪些 topic

那就只能：

1. 遍历整个 `TOPIC_TO_CONTEXT`
2. 一个 topic 一个 topic 地找
3. 看每个集合里有没有 `ctxA`

这样效率很差。

所以系统多维护一张反向表：

```text
ctxA -> [1001_server, device_a_server]
```

这样断线清理时就可以直接定位到它相关的 topic。

---

## 3. 三个状态来看整个过程

下面用同一个例子看三种状态：

- 订阅前
- 订阅后
- 断线后

假设当前有一个设备连接叫 `ctxA`，它要订阅：

- `1001_server`
- `device_a_server`

---

## 4. 状态一：订阅前

此时这个设备还没发 `subscribe`，所以两张表都是空的：

```text
TOPIC_TO_CONTEXT:
空

CONTEXT_TO_TOPICS:
空
```

也就是说：

- 服务端还不知道这个设备能接什么消息
- 业务侧即使发消息，也无法路由到它

---

## 5. 状态二：订阅后

设备发来：

```json
{
  "Cmd": "subscribe",
  "Topic": ["1001_server", "device_a_server"]
}
```

这时会进入：

```java
handleSubscribe(context, topics)
```

### 5.1 `handleSubscribe()` 做了什么

它主要做三件事：

1. 先清理这个连接过去可能存在的旧订阅
2. 建立 `topic -> context` 正向映射
3. 建立 `context -> topics` 反向映射

对应代码逻辑：

```java
closeMappings(context);
```

这句的意思是：

- 如果这个连接之前订阅过别的 topic
- 先把旧关系清理掉
- 再写入新的订阅关系

这样可以避免一个连接重复订阅、残留旧 topic 的问题。

然后是：

```java
for (String topic : topics) {
    Set<ChannelHandlerContext> contexts =
        ClassicReplicaStores.TOPIC_TO_CONTEXT.computeIfAbsent(
            topic,
            ignored -> ConcurrentHashMap.newKeySet()
        );
    contexts.add(context);
}
```

这段的意思是：

- 遍历每个 topic
- 如果这个 topic 还没有对应的连接集合，就先创建一个
- 再把当前连接放进去

执行完后，正向表会变成：

```text
TOPIC_TO_CONTEXT:
1001_server -> [ctxA]
device_a_server -> [ctxA]
```

然后这句：

```java
ClassicReplicaStores.CONTEXT_TO_TOPICS.put(
    context.hashCode(),
    ClassicReplicaStores.copyTopics(topics)
);
```

意思是：

- 把当前连接订阅了哪些 topic 也记录下来

执行完后，反向表会变成：

```text
CONTEXT_TO_TOPICS:
ctxA -> [1001_server, device_a_server]
```

---

## 6. 订阅后的整体状态

此时两张表内容如下：

```text
TOPIC_TO_CONTEXT:
1001_server -> [ctxA]
device_a_server -> [ctxA]

CONTEXT_TO_TOPICS:
ctxA -> [1001_server, device_a_server]
```

现在如果业务系统要发送：

```text
topic = 1001_server
```

服务端就可以通过：

```java
ClassicReplicaStores.TOPIC_TO_CONTEXT.get(topic)
```

直接找到：

```text
[ctxA]
```

然后把消息写给这个连接。

---

## 7. 状态三：断线后

假设设备掉线，Netty 触发：

```java
channelInactive(context)
```

然后会调用：

```java
closeMappings(context)
```

---

## 8. `closeMappings()` 到底做了什么

### 第一步：先删反向表记录

代码：

```java
List<String> topics = ClassicReplicaStores.CONTEXT_TO_TOPICS.remove(context.hashCode());
```

它的意思是：

- 先从反向表里找到这个连接订阅过哪些 topic
- 同时把这条反向记录删掉

假设原来有：

```text
CONTEXT_TO_TOPICS:
ctxA -> [1001_server, device_a_server]
```

执行后先变成：

```text
CONTEXT_TO_TOPICS:
空
```

同时 `topics` 变量里拿到了：

```text
[1001_server, device_a_server]
```

---

### 第二步：遍历这个连接订阅过的所有 topic

代码：

```java
for (String topic : topics)
```

意思是：

- 现在开始一个一个处理这个连接曾经订阅的 topic

---

### 第三步：从正向表中删掉当前连接

代码：

```java
Set<ChannelHandlerContext> contexts = ClassicReplicaStores.TOPIC_TO_CONTEXT.get(topic);
```

这是先拿到某个 topic 当前对应的连接集合。

比如：

```text
1001_server -> [ctxA]
```

然后：

```java
contexts.remove(context);
```

这句的意思是：

- 把当前失效连接从这个 topic 的连接集合里删掉

例如：

```text
1001_server -> [ctxA]
```

删完后变成：

```text
1001_server -> []
```

---

### 第四步：如果这个 topic 已经没人订阅了，就把整个 topic 删掉

代码：

```java
if (contexts.isEmpty()) {
    ClassicReplicaStores.TOPIC_TO_CONTEXT.remove(topic);
}
```

意思是：

- 如果删掉 `ctxA` 后，这个 topic 已经没有任何在线连接
- 那么这个 topic 在路由表里也没必要保留了

例如：

```text
1001_server -> []
```

最终会被删成：

```text
1001_server 不存在
```

---

## 9. 断线后的整体状态

最终两张表会都被清理干净：

```text
TOPIC_TO_CONTEXT:
空

CONTEXT_TO_TOPICS:
空
```

这时服务端就不会再误以为这个设备在线。

---

## 10. 一句话总结 `closeMappings()`

一句话理解：

> 根据“连接订阅了哪些 topic”这张反向表，快速把这个连接从所有 topic 路由里摘掉。

再简化一点：

> 断线时做彻底摘链。

---

## 11. 为什么 `handleSubscribe()` 开头也要调用 `closeMappings()`

这个地方很重要。

不是只有断线时才会调用 `closeMappings()`。

在重新订阅时也会先调用：

```java
closeMappings(context);
```

原因是：

- 同一个连接可能第一次订阅了 A、B
- 后来又发来新的 `subscribe`，只想订阅 C、D

如果不先清理旧订阅：

那路由表里就会残留：

```text
A、B、C、D
```

而不是最新的一组：

```text
C、D
```

所以这里的含义是：

> 新订阅不是“叠加”，而是“替换旧订阅”。

---

## 12. 最终心智模型

你可以把这两个方法这样记：

### `handleSubscribe()`

作用：

```text
建立路由
```

动作：

```text
topic -> context
context -> topics
```

---

### `closeMappings()`

作用：

```text
拆除路由
```

动作：

```text
先删 context -> topics
再删 topic -> context
```

---

## 13. 建议你接下来连着看

如果你已经理解了这份文档，建议下一步直接连着看：

1. `ClassicServerHandler.handleSubscribe()`
2. `ClassicServerHandler.closeMappings()`
3. `ClassicServerHandler.sendMessage()`

这三个方法一起看，你就能彻底明白：

- 订阅是怎么注册的
- 断线是怎么清理的
- 业务消息是怎么命中在线连接的

