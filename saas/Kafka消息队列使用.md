# Kafka 消息队列使用

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos1starter（间接）、pos2plugin-biz、pos4cloud-biz、pos5sync-biz
> 引入方式：Spring Boot 管理（`spring-kafka`）
> 最后更新：2026-04-30

---

## 一、组件概述

Kafka（`spring-kafka`）在 nms4pos 中承担本地事件流和跨服务数据传输的职责。相比 RocketMQ（云端），Kafka 主要用于**本地局域网内**的高速事件分发。

**主要使用场景**：
- `pos2plugin`：本地扫码事件、支付完成事件等业务事件流
- `pos5sync`：数据同步流水线，将 Canal 变更事件转为 Kafka 消息
- `pos4cloud`：消费 Kafka 消息，上传至 RocketMQ 最终达云端

---

## 二、Maven 依赖

```xml
<!-- Spring Boot 管理的 Kafka 客户端 -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

---

## 三、核心使用方式

### 3.1 生产者（发送消息）

```java
import org.springframework.kafka.core.KafkaTemplate;

// 注入 KafkaTemplate
@Autowired
private KafkaTemplate<String, String> kafkaTemplate;

// 发送消息（异步）
public void sendScanEvent(String orderNo, String action) {
    String topic = "pos-scan-event";
    String key = orderNo;
    String value = JSON.toJSONString(
        Map.of("orderNo", orderNo, "action", action, "time", LocalDateTime.now())
    );

    kafkaTemplate.send(topic, key, value)
        .whenComplete((result, ex) -> {
            if (ex != null) {
                log.error("发送 Kafka 消息失败 topic={}, key={}", topic, key, ex);
            } else {
                log.debug("发送成功 topic={}, partition={}, offset={}",
                    topic,
                    result.getRecordMetadata().partition(),
                    result.getRecordMetadata().offset());
            }
        });
}
```

### 3.2 消费者（接收消息）

```java
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;

public class PosEventConsumer {

    @KafkaListener(
        topics = "pos-scan-event",
        groupId = "pos-plugin-consumer",
        containerFactory = "kafkaListenerContainerFactory"
    )
    public void onScanEvent(ConsumerRecord<String, String> record) {
        String value = record.value();
        log.info("接收到扫描事件: topic={}, partition={}, offset={}",
            record.topic(), record.recordMetadata().partition(), record.offset());

        try {
            ScanEvent event = JSON.parseObject(value, ScanEvent.class);
            processScanEvent(event);
        } catch (Exception e) {
            log.error("处理扫描事件失败: {}", value, e);
        }
    }

    @KafkaListener(
        topics = {"pos-order-event", "pos-pay-event"},
        groupId = "pos-cloud-consumer"
    )
    public void onOrderEvent(ConsumerRecord<String, String> record) {
        // 支持多 Topic 订阅
        log.info("接收到订单事件: topic={}, value={}", record.topic(), record.value());
    }
}
```

### 3.3 在 pos5sync 中的使用

pos5sync 充当 Canal → Kafka → RocketMQ 的中间桥梁：

```java
// pos5sync — Canal 事件转发为 Kafka 消息
@Service
public class CanalToKafkaService {

    @Autowired
    private KafkaTemplate<String, byte[]> kafkaTemplate;

    public void forwardToKafka(String tableName, EventType type, List<Map<String, String>> rows) {
        String topic = "pos-canal-" + tableName;

        for (Map<String, String> row : rows) {
            kafkaTemplate.send(topic,
                row.get("id"),  // 使用主键作为 key，保证同一行数据顺序
                JSON.toJSONString(row).getBytes()
            );
        }
    }
}
```

---

## 四、Topic 设计

| Topic | 生产者 | 消费者 | 用途 |
|-------|--------|--------|------|
| `pos-scan-event` | pos2plugin | pos4cloud | 扫码事件（订单号/支付状态） |
| `pos-order-event` | pos2plugin | pos4cloud | 订单状态变更事件 |
| `pos-pay-event` | pos2plugin | pos4cloud | 支付完成事件 |
| `pos-canal-*` | pos5sync | pos4cloud | 数据库变更事件（Canal 转发） |

---

## 五、注意事项

1. **本地部署**：Kafka 部署在餐饮门店本地局域网，适合低延迟场景
2. **与 RocketMQ 的分工**：Kafka 承担本地高速事件流，RocketMQ 承担跨网络云端上传
3. **分区策略**：使用业务主键（如 `orderNo`）作为 key，保证同一订单的事件有序
4. **消费者组**：不同消费者组互不影响，适合多服务订阅同一 Topic

---

## 六、相关文档

- [RocketMQ消息中间件](./RocketMQ消息中间件.md)
- [Canal-CDC数据同步](./Canal-CDC数据同步.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)