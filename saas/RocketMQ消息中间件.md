# RocketMQ 消息中间件

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 引入方式：`nms4cloud-starter-rocketmq`（nms4cloud 主平台提供）
> 最后更新：2026-04-30

---

## 一、组件概述

RocketMQ 是阿里开源的分布式消息中间件，在 nms4pos 中承担**云端上传**的职责。pos4cloud 接收本地 POS 推送的订单消息，经 RocketMQ 异步上传到 nms4cloud 主平台，实现本地收银与云端数据同步的解耦。

> 对比：Kafka 负责本地高速事件流（局域网低延迟），RocketMQ 负责跨网络云端上传（可靠性优先）。

RocketMQ 通过 `nms4cloud-starter-rocketmq`（主平台 starter）引入，版本由 Spring Boot 管理。

---

## 二、Maven 依赖

**pos4cloud-biz**（通过父模块继承，非直接声明）：

```xml
<!-- 由 nms4cloud-starter-rocketmq 提供 -->
<dependency>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud-starter-rocketmq</artifactId>
    <!-- 版本由 nms4cloud parent 管理 -->
</dependency>
```

---

## 三、核心使用方式

### 3.1 发送消息（同步/异步）

```java
import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.springframework.messaging.support.MessageBuilder;

@Service
public class OrderCloudSyncService {

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    /**
     * 订单完成后，异步上传到云端
     */
    public void syncOrderToCloud(Order order) {
        String topic = "pos-order-sync";  // Topic
        String tags = "order|completed";  // Tags（用于消费过滤）
        String keys = order.getOrderNo(); // 消息 key（业务检索键，可用于幂等辅助，不是 MQ 自动去重键）

        rocketMQTemplate.asyncSend(topic + ":" + tags,
            MessageBuilder.withPayload(order).build(),
            new SendCallback() {
                @Override
                public void onSuccess(SendResult result) {
                    log.info("订单上传成功: orderNo={}, msgId={}",
                        order.getOrderNo(), result.getMsgId());
                }

                @Override
                public void onException(Throwable e) {
                    log.error("订单上传失败: orderNo={}", order.getOrderNo(), e);
                    // 触发重试或告警
                }
            }
        );
    }

    /**
     * 同步发送（需要确认消息到达）
     */
    public boolean syncDishUpdate(Dish dish) {
        SendResult result = rocketMQTemplate.syncSend(
            "pos-dish-sync:dish|update",
            dish,
            3000  // 超时 3 秒
        );
        return "SEND_OK".equals(result.getSendStatus());
    }
}
```

### 3.2 事务消息（订单上传）

RocketMQ 支持事务消息，确保本地事务与消息发送的原子性：

```java
import org.apache.rocketmq.spring.annotation.RocketMQTransactionListener;

@RocketMQTransactionListener
public class OrderTransactionListener implements RocketMQLocalTransactionListener {

    @Autowired
    private OrderMapper orderMapper;

    @Override
    public RocketMQLocalTransactionState executeLocalTransaction(Message msg, Object arg) {
        // 执行本地事务（更新本地订单状态）
        try {
            Order order = (Order) arg;
            orderMapper.updateStatus(order.getOrderNo(), "syncing");
            return RocketMQLocalTransactionState.COMMIT; // 本地成功，提交消息
        } catch (Exception e) {
            return RocketMQLocalTransactionState.ROLLBACK; // 本地失败，回滚
        }
    }

    @Override
    public RocketMQLocalTransactionState checkLocalTransaction(Message msg) {
        // 检查本地事务状态（MQ Server 回调，用于补偿）
        String orderNo = (String) msg.getKeys();
        Order order = orderMapper.selectByOrderNo(orderNo);
        if ("syncing".equals(order.getStatus())) {
            return RocketMQLocalTransactionState.UNKNOWN; // 不确定，MQ 会重试
        }
        return RocketMQLocalTransactionState.COMMIT;
    }
}
```

### 3.3 消费消息（云端服务）

```java
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;

@RocketMQMessageListener(
    topic = "pos-order-sync",
    consumerGroup = "nms4cloud-order-consumer",
    selectorExpression = "order|completed"  // 只消费 tag=completed 的消息
)
public class CloudOrderConsumer implements RocketMQListener<Order> {

    @Override
    public void onMessage(Order order) {
        log.info("云端收到订单: orderNo={}", order.getOrderNo());

        // 上报到主平台
        nms4cloudPlatformService.reportOrder(order);
    }
}
```

---

## 四、在 nms4pos 中的数据流

```
pos2plugin（本地收银）
  ↓ 支付完成
pos4cloud-biz（云端通信）
  ↓ RocketMQ 事务消息（确保本地+消息原子性）
nms4cloud 主平台（RocketMQ Broker）
  ↓ Consumer Group
nms4cloud-platform（主平台消费，存储订单）
```

---

## 五、Topic 和 Tag 设计

| Topic | Tag | 用途 |
|-------|-----|------|
| `pos-order-sync` | `order|completed` | 订单完成上传 |
| `pos-order-sync` | `order|canceled` | 订单取消 |
| `pos-order-sync` | `order|refund` | 订单退款 |
| `pos-dish-sync` | `dish|update` | 菜品信息变更 |
| `pos-dish-sync` | `dish|create` | 菜品新增 |
| `pos-dish-sync` | `dish|delete` | 菜品删除 |

---

## 六、注意事项

1. **事务消息**：订单同步使用事务消息，确保本地状态更新与消息发送的原子性
2. **消费幂等**：消费者必须实现幂等（同一条消息可能被投递多次），可依赖 `orderNo` 去重
3. **消息积压**：本地网络抖动时消息可能在 Broker 堆积，pos4cloud 需要有告警机制
4. **Tag 过滤**：合理使用 Tag 避免不必要的消息消费

---

## 七、RocketMQ 知识补充

### 7.1 核心角色

#### Producer

消息生产者，负责把业务消息发送到 RocketMQ。

例如：

- POS 订单完成后发送订单同步消息
- 菜品信息变更后发送菜品同步消息

#### Consumer

消息消费者，负责订阅 Topic 并处理消息。

例如：

- 云端消费门店上传的订单消息
- 主平台消费菜品更新消息

#### NameServer

RocketMQ 的路由中心。

作用：

- 保存 Topic 和 Broker 的路由关系
- Producer 发送前先查路由
- Consumer 拉取前也先查路由

#### Broker

RocketMQ 的核心消息节点。

作用：

- 接收 Producer 消息
- 持久化存储消息
- 把消息投递给 Consumer
- 维护消费进度、重试、死信等能力

### 7.2 Topic、Tag、Consumer Group

#### Topic

Topic 是消息的大分类，表示业务主题。

例如：

- `pos-order-sync`
- `pos-dish-sync`

#### Tag

Tag 是 Topic 下的二级分类，用于消息过滤。

例如：

- `order|completed`
- `order|refund`
- `dish|update`

#### Consumer Group

Consumer Group 表示一组消费者实例的逻辑名称。

作用：

- 同组消费者共享消费进度
- 集群消费模式下，同组实例分摊消息
- Dashboard 里的“是否已消费”本质上也是基于 Consumer Group 来判断

### 7.3 消息类型

#### 同步消息

Producer 发送后等待 Broker 返回结果。

适合：

- 核心业务消息
- 需要明确知道发送是否成功的场景

#### 异步消息

Producer 发送后通过回调拿结果，不阻塞主线程。

适合：

- 大量异步上传
- 吞吐量要求较高的场景

#### 单向消息

Producer 只负责发送，不等待 Broker 返回结果。

特点：

- 更快
- 更轻量
- 不适合必须确认送达的核心业务

适合：

- 日志上报
- 埋点
- 非核心通知

#### 延时消息

延时消息发送后不会立刻给消费者，而是在延迟时间到达后才进入正常投递流程。

特点：

- 消息会先写入 Broker
- Dashboard 可以先查到消息
- 消费者只能在延迟时间到达后真正消费到消息

#### 事务消息

事务消息用于保证“本地事务”和“消息发送”的最终一致性。

核心流程：

1. Producer 先发送半消息
2. Producer 执行本地事务
3. 本地事务成功则提交消息，失败则回滚消息
4. 如果 Broker 没收到明确结果，会回查 Producer

注意：

- Broker 回查的是发送该事务消息的 Producer 客户端
- 不是回查数据库，也不是回查 Consumer

### 7.4 msgId、msgKey、Queue Offset 的区别

#### msgId

RocketMQ 为每条消息生成的技术标识。

特点：

- 一般唯一
- 用于技术定位和排查问题

#### msgKey

业务方主动设置的消息检索键，对应消息属性中的 `KEYS`。

特点：

- 可以重复
- 用于按业务号、订单号、流水号检索消息
- RocketMQ 不会因为 `msgKey` 相同就自动去重

#### Queue Offset

消息在某个具体队列里的顺序位置。

特点：

- 每个队列单独递增
- 用于表示消息在该队列中的顺序
- Consumer 的消费进度也是围绕 offset 来维护

### 7.5 为什么“同一个 key 的消息会显示已消费”

RocketMQ 默认不会按 `KEYS` 去重，也不会因为 key 相同就自动把新消息标记为已消费。

Dashboard 上看到 `CONSUMED`，通常是以下原因：

1. 同一个 Consumer Group 以前已经消费过该 Topic 的历史消息
2. Dashboard 展示的是消费组状态，不是单独按 key 判断
3. 同一个 `KEYS` 发多次，RocketMQ 仍然会存成多条不同消息
4. 按同一个 `KEYS` 查询时，会把历史消息和新消息一起查出来

实践结论：

- `KEYS` 相同不代表是同一条消息
- 判断是不是新消息，要看 `msgId`、`StoreTime`、`QueueOffset`
- 判断是不是已消费，要看具体 Consumer Group 的消费跟踪

### 7.6 Dashboard 里常见字段说明

#### StoreHost

消息最终存储在哪个 Broker 上。

#### BornHost

生产者发送该消息时的来源地址。

#### StoreTime

消息写入 Broker 存储的时间。

#### BornTime

消息在生产端创建并发送的时间。

#### Queue ID

消息落入 Topic 下的哪个队列。

#### Queue Offset

消息在该队列里的顺序位置。

#### ReconsumeTimes

消息被重新消费的次数。

#### DELAY

延时级别。

如果该字段大于 0，说明这是一条延时消息。

#### REAL_TOPIC / REAL_QID

消息底层真实存储所使用的 Topic 和 Queue 标识。

### 7.7 Dashboard 里为什么会显示消息已消费

在本地测试中发现，Dashboard 查看消息跟踪时，不只是简单读取状态，还可能触发一次消费探测。

因此：

- 页面显示 `CONSUMED`
- 不一定代表“当前这一刻手动启动了消费者”
- 也可能是这个 Consumer Group 以前消费过
- 或者 Dashboard 查询时对在线 Consumer 做了直接探测

测试建议：

1. 使用新的 Topic
2. 使用新的 Consumer Group
3. 排查本机是否有残留消费者 Java 进程
4. 再观察消息是否真的被消费

### 7.8 Docker 本地部署常见坑

#### brokerIP1 配置错误

如果 `brokerIP1` 配置不对，常见现象有：

- Producer 能连 NameServer
- 但发送消息时报 `connect failed`、`send timeout`
- Dashboard 能打开，但 Broker 无法正常访问

在 Windows + Docker Desktop 环境中：

- `127.0.0.1` 只适合宿主机本地自己访问
- Dashboard 容器内部访问 `127.0.0.1` 实际指向容器自己
- 如果希望宿主机 Java 程序和 Docker 内 Dashboard 都能访问 Broker，`brokerIP1` 应配置为宿主机真实 IPv4 地址

例如：

```properties
brokerIP1=192.168.0.100
```

#### Topic 没有路由

如果报错：

```text
No route info of this topic
```

通常说明：

- Topic 还没创建
- 或 Broker 尚未正确注册路由

可以通过 `mqadmin updateTopic` 手动创建 Topic。

#### 只改 broker.conf 没重启容器

修改 `broker.conf` 后必须重建或重启 Broker 容器，否则新配置不会真正生效。

### 7.9 测试建议

为了避免历史消息和历史消费组干扰，建议测试时：

1. Topic 名带测试后缀或时间戳
2. Consumer Group 使用新的测试组名
3. 用 Dashboard 同时查看 `StoreTime`、`QueueOffset`、`KEYS`
4. 排查“是否被消费”时先确认本机没有残留消费者进程

---

## 八、相关文档

- [Kafka消息队列使用](./Kafka消息队列使用.md)
- [Canal-CDC数据同步](./Canal-CDC数据同步.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)
