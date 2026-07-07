# MQTT 深度技术文档

资料基准日期：2026-06-26  
适用读者：后端工程师、IoT 平台工程师、设备接入工程师、架构师、运维/SRE  
文档目标：不仅说明 MQTT 是什么，还说明它为什么这样设计、关键语义边界在哪里、工程落地时如何设计 Topic、会话、QoS、安全、集群和可观测性。

---

## 1. 一句话定位

MQTT 是一种面向低带宽、不稳定网络和大量长连接设备的轻量级发布/订阅消息传输协议。它把通信双方从「直接调用」解耦为「客户端连接 Broker，发布者向 Topic 发布消息，订阅者按 Topic Filter 接收消息」。

它适合的核心场景不是传统服务之间的强事务 RPC，而是：

- 设备遥测：传感器、门店设备、车辆、工业控制器持续上报状态。
- 命令下发：云端向设备发送配置、控制命令、重启、升级通知。
- 事件分发：边缘节点、业务系统、告警系统之间做轻量事件路由。
- 弱网通信：移动网络、蜂窝网络、卫星链路、园区网络、跨公网连接。
- 大连接数：大量在线但低频发送的客户端连接同一消息基础设施。

### 1.1 IoT 是什么

IoT 是 Internet of Things 的缩写，中文通常叫物联网。

拆开看：

- Internet：互联网。
- Things：物、设备、终端、传感器、机器。
- Internet of Things：把各种现实世界中的「物」接入网络，让它们能采集数据、上报状态、接收指令，并与软件系统联动。

所以 IoT 不是某一种具体设备，而是一类联网设备体系。常见 IoT 设备包括智能冰箱、空调、摄像头、POS 机、扫码设备、打印机、温湿度传感器、工业机器、生产线设备、车辆、充电桩、门禁设备等。

放到 MQTT 场景里，IoT 通常可以理解成：

```text
设备 / 传感器  ── MQTT / HTTP / 蜂窝网络 ──▶ 云平台
云平台        ── 命令 / 配置 / 升级任务 ──▶ 设备
```

简单说，IoT 就是让现实世界里的设备联网，并让软件系统能管理、观察和控制这些设备。

### 1.2 多租户 IoT 平台是什么

多租户 IoT 平台，是一套物联网平台同时服务多个客户、商户、组织或业务主体，但每个租户的设备、数据、权限、消息、规则和配置互相隔离。

可以这样理解：

```text
同一个 IoT 平台
├── 租户 A：设备、用户、MQTT Topic、数据、告警规则
├── 租户 B：设备、用户、MQTT Topic、数据、告警规则
└── 租户 C：设备、用户、MQTT Topic、数据、告警规则
```

例如一个设备接入平台可以同时服务不同品牌、门店或公司：

- A 公司有 10,000 台温控设备。
- B 公司有 5,000 台 POS 设备。
- C 公司有 2,000 台传感器。

这些设备都连接到同一套 MQTT Broker 和 IoT 后台，但 A 公司不能看到 B 公司的设备、消息、告警、配置和数据。

在 MQTT 里，多租户通常体现在 Topic 设计和 ACL 权限控制上：

```text
prod/tenant-a/device/d001/telemetry
prod/tenant-b/device/d999/telemetry
```

对应的权限规则应限制：

```text
tenant-a 的设备只能发布或订阅 tenant-a 下的 Topic
tenant-b 的设备只能发布或订阅 tenant-b 下的 Topic
```

所以，多租户 IoT 平台的核心不是简单把 tenantId 写进 Topic，而是做到：

1. 一套平台服务多个租户。
2. 每个租户拥有独立的设备、用户、数据、规则和配置。
3. MQTT Topic、认证主体、ACL、存储数据和运营后台都必须按租户隔离。
4. 平台计算、网络和 Broker 资源可以共享，但业务边界不能混。

MQTT 的优势来自四个设计选择：

1. 客户端和 Broker 之间保持长连接，避免频繁握手。
2. 协议头很小，报文结构简单。
3. 使用 Topic 和订阅过滤器做空间解耦。
4. 协议层提供 QoS、保留消息、遗嘱消息、会话恢复等弱网能力。

---

## 2. 标准版本与选型

### 2.1 当前主线标准

截至本文基准日期，MQTT 主线正式标准主要是：

| 版本 | 标准状态 | 协议级别 | 工程定位 |
|---|---:|---:|---|
| MQTT 3.1.1 | OASIS / ISO 广泛采用标准 | 4 | 兼容性最好，历史设备和大量 SDK 的共同基线 |
| MQTT 5.0 | OASIS Standard | 5 | 新项目优先选择，诊断、流控、元数据和会话语义更完整 |

MQTT 5.0 不是「更快的 3.1.1」，而是把很多原来由 Broker 私有扩展解决的问题标准化，例如 Reason Code、属性、会话过期、消息过期、Topic Alias、Response Topic、Correlation Data、Receive Maximum、Maximum Packet Size、User Properties、Enhanced Authentication 等。

### 2.2 什么时候选择 MQTT 3.1.1

选择 MQTT 3.1.1 的常见理由：

- 设备固件或模组 SDK 只支持 3.1.1。
- 已有 Broker、网关、云平台、测试工具链以 3.1.1 为基线。
- 项目更看重广泛兼容，而不是协议级诊断和细粒度流控。
- 终端能力弱，协议栈越简单越好。

但要接受几个代价：

- 错误诊断弱，很多失败只能通过连接断开或少量返回码判断。
- 会话生命周期只有 Clean Session 这一类粗粒度开关。
- 缺少标准化请求/响应元数据。
- 流控能力主要依赖 Broker 和客户端实现参数。

### 2.3 什么时候选择 MQTT 5.0

新系统通常优先选择 MQTT 5.0，尤其是这些场景：

- 多租户 IoT 平台，需要强诊断、强隔离和可观测性，概念见 1.2 节。
- 需要设备命令请求/响应、异步 ACK、链路追踪。
- 有消息过期、会话过期、最大报文、接收窗口等治理要求。
- 需要灰度迁移、能力协商、用户属性、内容类型、Payload 格式标识。
- Broker 集群需要更可控的资源上限和拒绝原因。

选择 5.0 的前提是端到端确认：设备 SDK、网关、Broker、云端 SDK、测试工具都支持并正确暴露 5.0 语义。不要只看 Broker 支持 5.0。

---

## 3. 基本架构模型

MQTT 的网络实体只有两类：Client 和 Server。工程里通常把 MQTT Server 称为 Broker。

```text
┌─────────────┐       CONNECT/PUBLISH/SUBSCRIBE       ┌─────────────┐
│ Device A    │  ───────────────────────────────────▶ │             │
│ publisher   │                                       │             │
└─────────────┘                                       │             │
                                                      │   Broker    │
┌─────────────┐       SUBSCRIBE + message delivery    │             │
│ Service B   │  ◀─────────────────────────────────── │             │
│ subscriber  │                                       │             │
└─────────────┘                                       └─────────────┘
```

发布者不需要知道订阅者是谁，订阅者也不需要知道发布者是谁。双方只共享 Topic 命名契约和 Payload 契约。

### 3.1 发布/订阅解耦维度

| 解耦维度 | MQTT 的做法 | 工程收益 | 风险 |
|---|---|---|---|
| 空间解耦 | 通过 Topic 路由 | 发布者不关心订阅者地址 | Topic 命名失控会导致权限和治理困难 |
| 时间解耦 | 持久会话和离线队列 | 订阅者短暂离线仍可接收部分消息 | 队列堆积会拖垮 Broker |
| 同步解耦 | PUBLISH 不等价于业务处理完成 | 弱网下吞吐更稳定 | 需要业务 ACK 或状态回执 |
| 交付语义解耦 | QoS 由协议处理传输确认 | 可以按消息重要性选择成本 | QoS 不等价于业务幂等 |

### 3.2 MQTT 与消息队列的关系

MQTT 名字里有 MQ，但不要把它简单理解成 RabbitMQ、Kafka、Pulsar 这类通用消息队列的替代品。

MQTT Broker 的主要职责是设备接入、连接管理、Topic 订阅匹配、协议级交付、会话和弱网语义。Kafka 更像后端事件日志和流处理底座，RabbitMQ 更偏企业消息队列和复杂路由。常见架构是：

```text
Device / App
     │ MQTT
     ▼
MQTT Broker / IoT Gateway
     │ rule engine / bridge
     ├────────▶ Kafka / Pulsar     数据流、分析、审计、回放
     ├────────▶ Redis / Cache      最新状态、在线状态
     ├────────▶ DB / TSDB          业务存储、时序数据
     └────────▶ HTTP / gRPC        业务服务回调
```

MQTT 负责「接入和实时路由」，后端 MQ/流系统负责「持久日志、回放、复杂消费和数据处理」。把全部历史数据、审计、重放都压在 MQTT Broker 上，通常会让 Broker 失去它最擅长的长连接和低延迟路由能力。

---

## 4. 传输层与连接方式

### 4.1 TCP

标准 MQTT 运行在有序、可靠、双向的字节流之上，最常见是 TCP。TCP 提供顺序和重传，MQTT 在其上定义应用层控制报文、QoS 状态机、心跳和会话语义。

默认端口习惯：

| 连接方式 | 常见端口 | 说明 |
|---|---:|---|
| MQTT over TCP | 1883 | 明文，不建议公网生产使用 |
| MQTT over TLS | 8883 | 生产公网首选 |
| MQTT over WebSocket | 80 / 443 或自定义 | 浏览器、小程序、受限网络常用 |

端口不是协议语义的一部分，生产以实际 Broker 配置为准。

### 4.2 TLS

生产环境应优先使用 MQTT over TLS：

- 服务端证书：客户端校验 Broker 身份，防止中间人攻击。
- 双向 TLS：Broker 同时校验客户端证书，适合高安全设备接入。
- SNI：多租户或多域名 Broker 常用。
- ALPN：部分云平台用来在同一端口区分协议或服务。

TLS 不是完整安全方案，只解决链路加密和身份认证的一部分。客户端身份、Topic 授权、限流、审计、证书轮换仍要单独设计。

### 4.3 WebSocket

MQTT 可以跑在 WebSocket 上，典型场景：

- 浏览器无法直接发起原生 TCP。
- 企业网络只允许 80/443。
- 小程序或 Web 前端需要订阅实时消息。

WebSocket 的代价是额外握手、额外帧头和代理链路复杂度。对于设备固件，如果能稳定使用 TCP/TLS，通常不应为了「看起来统一」强行上 WebSocket。

---

## 5. 报文结构与控制包

MQTT 报文称为 Control Packet。一个报文由固定头、可变头和 Payload 组成。

```text
┌────────────────────┐
│ Fixed Header        │  所有控制包都有，包含报文类型、标志位、剩余长度
├────────────────────┤
│ Variable Header     │  部分控制包有，例如 Packet Identifier、属性
├────────────────────┤
│ Payload             │  部分控制包有，例如 CONNECT 参数、PUBLISH 消息体
└────────────────────┘
```

### 5.1 Fixed Header

Fixed Header 至少 2 字节：

- 第 1 字节高 4 位：Control Packet Type。
- 第 1 字节低 4 位：类型相关标志位。
- Remaining Length：使用变长编码表示后续 Variable Header + Payload 的长度。

Remaining Length 的变长编码是 MQTT 轻量化的一部分，小报文只需要 1 字节表示长度，大报文才扩展更多字节。

### 5.2 MQTT 5.0 控制包类型

| 类型值 | 名称 | 方向 | 作用 |
|---:|---|---|---|
| 1 | CONNECT | Client -> Server | 建立连接并声明能力、身份、会话参数 |
| 2 | CONNACK | Server -> Client | 连接确认，返回原因码和连接属性 |
| 3 | PUBLISH | 双向 | 发布应用消息 |
| 4 | PUBACK | 双向 | QoS 1 发布确认 |
| 5 | PUBREC | 双向 | QoS 2 第一阶段确认 |
| 6 | PUBREL | 双向 | QoS 2 第二阶段释放 |
| 7 | PUBCOMP | 双向 | QoS 2 完成确认 |
| 8 | SUBSCRIBE | Client -> Server | 创建订阅 |
| 9 | SUBACK | Server -> Client | 订阅结果确认 |
| 10 | UNSUBSCRIBE | Client -> Server | 取消订阅 |
| 11 | UNSUBACK | Server -> Client | 取消订阅确认 |
| 12 | PINGREQ | Client -> Server | 心跳请求 |
| 13 | PINGRESP | Server -> Client | 心跳响应 |
| 14 | DISCONNECT | 双向 | 主动断开并可携带原因 |
| 15 | AUTH | 双向 | MQTT 5.0 增强认证流程 |

MQTT 3.1.1 没有 AUTH 控制包，诊断信息也明显少于 5.0。

---

## 6. 连接生命周期

### 6.1 CONNECT 阶段

客户端连接 Broker 后，必须先发送 CONNECT。典型信息包括：

- Protocol Name / Version：协议名称和版本级别。
- Client Identifier：客户端唯一身份。
- Clean Start / Clean Session：是否从干净会话开始。
- Session Expiry：MQTT 5.0 会话过期时间。
- Keep Alive：心跳间隔。
- Authentication：用户名、密码、证书、Token 或增强认证。
- Will Message：异常掉线时由 Broker 代发的遗嘱消息。
- Properties：MQTT 5.0 属性，例如 Receive Maximum、Maximum Packet Size。

Broker 返回 CONNACK。MQTT 5.0 的 CONNACK 可以携带更详细原因码和服务端能力，例如最大 QoS、最大报文、Server Keep Alive、Assigned Client Identifier 等。

### 6.2 ClientId 的工程含义

ClientId 不是随便生成的字符串，它是 MQTT 会话身份的核心。

常见规则：

- 同一 Broker 命名空间内 ClientId 必须唯一。
- 两个连接使用同一个 ClientId 时，Broker 通常会踢掉旧连接或拒绝新连接，具体行为依实现和配置而定。
- 持久会话、离线消息、订阅状态都与 ClientId 绑定。
- ClientId 不应包含可伪造的租户或权限语义，权限必须由认证授权系统决定。

推荐命名：

```text
device/{tenantId}/{productKey}/{deviceId}
gateway/{tenantId}/{gatewayId}
service/{serviceName}/{instanceId}
web/{tenantId}/{userId}/{sessionId}
```

注意：ClientId 是协议身份，不等于业务主体的全部身份。业务身份应来自证书、Token、设备密钥或认证服务，并在 Broker ACL 中绑定。

### 6.3 Keep Alive 与半开连接

Keep Alive 用来发现半开连接。客户端在没有其他控制包发送时，应在 Keep Alive 时间内发送 PINGREQ，Broker 返回 PINGRESP。如果 Broker 在合理时间内没有收到客户端数据，可以关闭连接。

工程注意点：

- Keep Alive 太短会增加心跳压力和移动网络耗电。
- Keep Alive 太长会导致离线发现慢，命令下发延迟变大。
- 移动网络和 NAT 设备可能有自己的空闲连接超时。
- 设备端应实现随机退避重连，避免 Broker 故障恢复时发生重连风暴。

经验起点：

| 场景 | Keep Alive 起点 |
|---|---:|
| 局域网设备 | 30s - 60s |
| 蜂窝网络设备 | 60s - 300s |
| 低功耗设备 | 300s 或更长，结合休眠策略 |
| Web 前端 | 30s - 90s |

这些不是协议要求，必须结合 NAT、运营商链路、Broker 配置和业务离线判定调优。

---

## 7. Topic 与 Topic Filter

### 7.1 Topic Name

Topic Name 是发布消息时使用的路径式字符串，例如：

```text
prod/tenant-1001/device/d-9001/telemetry
prod/tenant-1001/device/d-9001/event/alarm
prod/tenant-1001/device/d-9001/command/reboot
```

Topic 本身没有固定层级语义，斜杠只是约定分隔符。语义来自团队设计。

Topic 设计原则：

- 从高维到低维：环境 -> 租户 -> 产品 -> 设备 -> 消息类型。
- 避免开头和结尾斜杠，减少空层级。
- 不把敏感信息放进 Topic，例如手机号、身份证、明文密钥。
- 不把高基数字段随意放在靠前层级，避免订阅树和 ACL 复杂化。
- Topic 负责路由，Payload 负责业务内容；不要把完整业务对象塞进 Topic。

### 7.2 Topic Filter

订阅使用 Topic Filter，可以包含通配符：

| 通配符 | 含义 | 示例 | 匹配 |
|---|---|---|---|
| `+` | 单层通配 | `prod/tenant-1001/device/+/telemetry` | 单个设备的遥测层级 |
| `#` | 多层通配，只能在最后 | `prod/tenant-1001/device/#` | 某租户所有设备相关消息 |

危险订阅：

```text
#
+/+/+/#
prod/+/device/#
```

这些订阅在多租户系统中可能造成越权、流量放大和 Broker 负载异常。生产系统应通过 ACL 限制通配订阅范围。

### 7.3 `$SYS` 与系统 Topic

很多 Broker 使用 `$SYS/` 暴露系统状态，例如连接数、消息吞吐、版本、运行时指标。`$SYS` 是常见约定，但具体内容由 Broker 实现决定。

不要把业务 Topic 放在 `$SYS` 下。也不要默认允许普通设备订阅 `$SYS/#`。

### 7.4 共享订阅

共享订阅用于多个消费者实例分摊同一个 Topic Filter 的消息，常见格式：

```text
$share/{groupName}/{topicFilter}
```

示例：

```text
$share/order-workers/prod/tenant-1001/device/+/event/order
```

它适合服务端消费者扩容，但要理解代价：

- 同一条消息通常只会投递给共享组内一个成员。
- 组内负载均衡策略由 Broker 决定。
- 跨消费者实例后，严格顺序通常更难保证。
- QoS 只解决 Broker 和消费者之间的协议交付，不解决业务处理幂等。

---

## 8. QoS 交付语义

MQTT 定义 3 个 QoS 等级。QoS 是协议层传输确认语义，不是业务成功语义。

| QoS | 名称 | 协议承诺 | 成本 | 适合场景 |
|---:|---|---|---|---|
| 0 | At most once | 最多投递一次，不确认，可能丢 | 最低 | 高频遥测、可被下一次状态覆盖的数据 |
| 1 | At least once | 至少投递一次，可能重复 | 中 | 告警、事件、命令 ACK、重要状态 |
| 2 | Exactly once | 协议链路上恰好一次处理 | 最高 | 极少数不能重复且能承受高开销的消息 |

### 8.1 QoS 0

流程：

```text
Publisher ── PUBLISH(QoS0) ──▶ Broker ── PUBLISH(QoS0) ──▶ Subscriber
```

没有 PUBACK。连接断开、网络丢包、Broker 失败都可能造成消息丢失。

适合：

- 温度、位置、在线心跳等高频最新状态。
- 可以被下一条消息覆盖的数据。
- 前端实时展示但不作为审计依据的数据。

不适合：

- 支付、扣库存、工单状态、权限变更。
- 需要完整审计和重放的事件。

### 8.2 QoS 1

发布端到 Broker 的典型流程：

```text
Publisher ── PUBLISH(QoS1, PacketId=10) ──▶ Broker
Publisher ◀──────────── PUBACK(10) ─────── Broker
```

如果发布端没有收到 PUBACK，可能重发 PUBLISH，并设置 DUP 标志。Broker 或订阅者可能看到重复消息。

QoS 1 的正确业务姿势：

- Payload 中包含业务消息 ID 或幂等键。
- 消费端按业务 ID 去重。
- 状态更新使用版本号、时间戳、序列号或 CAS。
- 命令下发要有 commandId 和独立 ACK Topic。

错误姿势：

- 认为 QoS 1 不会重复。
- 认为收到 PUBACK 等于业务服务已经处理完成。
- 用数据库自增主键作为唯一幂等依据但不传给消费者。

### 8.3 QoS 2

QoS 2 使用四步握手：

```text
Publisher ── PUBLISH(QoS2, PacketId=20) ──▶ Broker
Publisher ◀──────────── PUBREC(20) ─────── Broker
Publisher ───────────── PUBREL(20) ──────▶ Broker
Publisher ◀──────────── PUBCOMP(20) ───── Broker
```

QoS 2 的「Exactly once」只在 MQTT 协议状态机范围内成立，不能扩展为端到端业务系统绝对一次。例如：

- Broker 写入业务数据库失败后重试，业务仍可能重复。
- Broker 到后端 Kafka 桥接失败后恢复，仍需要幂等。
- 订阅端处理成功但 ACK 丢失，客户端库和业务层之间仍可能出现重复处理风险。

因此，真正关键业务仍应设计业务幂等，而不是只依赖 QoS 2。

### 8.4 QoS 降级

订阅者请求的最大 QoS 和发布消息 QoS 会共同影响最终投递 QoS。实际投递 QoS 通常不会高于订阅时授予的 QoS。工程上要把 QoS 当作端到端契约的一部分，在 Topic 设计和 SDK 封装里固定下来，不要让调用方随意传数字。

---

## 9. 会话、离线队列与消息持久化

### 9.1 Clean Session 与 Clean Start

MQTT 3.1.1 使用 Clean Session：

- `CleanSession=true`：连接时创建干净会话，断开后会话状态删除。
- `CleanSession=false`：Broker 保留会话状态，客户端重连后恢复订阅和未完成 QoS 流程。

MQTT 5.0 拆成更清晰的两个概念：

- Clean Start：本次连接是否从干净状态开始。
- Session Expiry Interval：连接断开后会话保留多久。

这比 3.1.1 更适合生产治理。比如设备断线 10 分钟内保留命令队列，超过后释放资源。

### 9.2 会话中通常保存什么

Broker 的持久会话通常包含：

- 订阅关系。
- 未完成 QoS 1 / QoS 2 状态。
- 客户端离线期间排队的 QoS 1 / QoS 2 消息。
- MQTT 5.0 下的部分会话属性。

不应假设所有 Broker 都以同样方式持久化，也不应把 Broker 会话当作无限可靠的数据库。

### 9.3 离线队列风险

离线队列是 MQTT 的强能力，也是常见事故源。

风险：

- 大量离线设备堆积消息，Broker 磁盘或内存耗尽。
- 设备恢复后集中拉取，造成下游流量尖峰。
- 旧命令过期后仍投递，导致设备执行过时动作。
- 客户端长期不消费但会话不过期，形成资源泄漏。

治理手段：

- MQTT 5.0 使用 Message Expiry Interval。
- 设置 Session Expiry 上限。
- Broker 配置每客户端队列长度、总队列长度、最大报文大小。
- 命令类消息携带业务过期时间。
- 设备重连后先同步云端状态，再处理旧队列。
- 对低价值遥测使用 QoS 0 或只保存最后状态。

---

## 10. Retained Message、Last Will 与在线状态

### 10.1 Retained Message

发布消息时设置 Retain 标志，Broker 会保留该 Topic 的最后一条 Retained Message。新的订阅者订阅匹配 Topic 后，会立即收到这条保留消息。

适合：

- 设备最新配置版本。
- 最新在线状态快照。
- 系统公告或低频状态。
- 前端进入页面时需要立刻拿到当前状态。

不适合：

- 高频遥测全量历史。
- 订单、支付、库存等需要严格审计的事件。
- 用户隐私数据。
- 大 Payload 数据。

Retained Message 是「每个 Topic 的最后值缓存」，不是时间序列数据库。

清除 Retained Message 的常见方式是向同一 Topic 发布空 Payload 且 Retain=true，具体行为要按 Broker 和客户端库验证。

### 10.2 Last Will and Testament

Will Message 是客户端 CONNECT 时声明的一条遗嘱消息。如果客户端异常断开，Broker 按约定发布该消息。

典型用途：

```text
prod/{tenant}/device/{deviceId}/status
payload: {"online":false,"reason":"connection_lost","ts":...}
retain: true
```

上线时客户端主动发布：

```text
prod/{tenant}/device/{deviceId}/status
payload: {"online":true,"ts":...}
retain: true
```

### 10.3 在线状态不能只靠 Will

Will 很有用，但不要把它当成唯一在线判定：

- 正常 DISCONNECT 不会触发 Will。
- 网络抖动可能导致短暂离线误判。
- Broker 集群故障、负载均衡切换会影响状态事件。
- 设备应用进程活着不等于业务能力正常。

更可靠的在线状态通常组合：

- MQTT 连接状态。
- 设备心跳时间。
- 业务健康上报。
- Broker 连接事件。
- 设备最近一次遥测或 ACK。

---

## 11. MQTT 5.0 深度能力

MQTT 5.0 的最大价值是把生产系统需要的很多「边界语义」协议化。

### 11.1 Reason Code 与 Reason String

MQTT 3.1.1 失败信息有限，排查经常依赖 Broker 日志。MQTT 5.0 在 CONNACK、PUBACK、SUBACK、DISCONNECT 等报文中引入更丰富的 Reason Code，并可携带 Reason String。

工程收益：

- 客户端能区分认证失败、授权失败、报文过大、Topic 不合法、配额超限等问题。
- SDK 可以做分类重试，而不是所有断开都盲目重连。
- SRE 可以按原因码统计失败率。

注意：Reason String 面向诊断，不应承载业务逻辑，也不应泄露敏感信息。

### 11.2 Session Expiry Interval

Session Expiry 让会话保留时间可控。常见策略：

| 客户端类型 | Session Expiry 建议 |
|---|---|
| 临时 Web 页面 | 0 或很短 |
| 移动 App | 数分钟到数小时 |
| 设备命令通道 | 结合命令有效期，常见数分钟到数天 |
| 服务端消费者 | 根据部署和重启窗口设置 |

不要对所有设备无限保留会话。无限会话在大规模设备系统里很容易变成资源炸弹。

### 11.3 Message Expiry Interval

消息过期解决「迟到消息是否还有意义」的问题。

例如：

- 设备重启命令：5 分钟后无意义。
- 价格变更通知：过期后应拉取最新配置。
- 门店排队叫号：过期后不能再播报。

过期时间应由业务定义，不应只由 Broker 默认值决定。

### 11.4 Receive Maximum

Receive Maximum 限制对端允许同时未确认的 QoS 1 / QoS 2 PUBLISH 数量。它是 MQTT 5.0 的重要流控能力。

工程意义：

- 防止慢消费者被大量 QoS 消息压垮。
- 让 Broker 对不同设备能力做分层限流。
- 让服务端消费者通过窗口控制吞吐。

### 11.5 Maximum Packet Size

Maximum Packet Size 让客户端和 Broker 声明自己能接收的最大报文。它对防止大消息拖垮内存非常重要。

实践建议：

- MQTT 只传控制和事件数据，不传大文件。
- OTA 固件、图片、日志大包应通过对象存储或 HTTP 下载，MQTT 只传 URL、版本、哈希和任务 ID。
- Broker、SDK、网关、业务服务要统一最大包限制。

### 11.6 Topic Alias

Topic Alias 用短数字替代重复 Topic，减少长 Topic 高频发布的带宽开销。

适合：

- 同一连接频繁向少数长 Topic 发布。
- 蜂窝网络或卫星链路等带宽昂贵场景。

不适合：

- Topic 高度分散。
- 调试工具链不完善，团队容易误解别名状态。

### 11.7 User Properties

User Properties 是 MQTT 5.0 的用户自定义键值元数据。可用于：

- traceId / requestId。
- schemaVersion。
- sourceSystem。
- tenant hints。
- 调试标签。

不要用于：

- 传递密钥。
- 替代认证授权。
- 放置大量业务字段。
- 依赖 Broker 一定持久化或索引这些属性。

### 11.8 Response Topic 与 Correlation Data

MQTT 5.0 支持更标准的请求/响应模式：

```text
请求：
topic: prod/{tenant}/device/{deviceId}/command/get-status
properties:
  responseTopic: prod/{tenant}/service/{requester}/reply
  correlationData: <request-id-bytes>
payload:
  {"commandId":"cmd-001"}

响应：
topic: prod/{tenant}/service/{requester}/reply
properties:
  correlationData: <same-request-id-bytes>
payload:
  {"commandId":"cmd-001","status":"ok","battery":78}
```

注意：这只是消息模式，不是同步 RPC。仍要处理超时、重复、乱序、设备离线和权限。

### 11.9 Subscription Identifier

Subscription Identifier 让客户端知道收到的消息匹配了哪个订阅。对于一个客户端订阅多个重叠 Topic Filter 的场景很有用。

典型用途：

- 统一消费者连接订阅多个业务流。
- 统计不同订阅命中的消息量。
- 调试重叠订阅导致的重复投递。

---

## 12. 安全设计

MQTT 安全必须同时覆盖认证、授权、链路、资源、审计和运维。

### 12.1 认证

常见认证方式：

| 方式 | 优点 | 风险 |
|---|---|---|
| username/password | 简单，兼容性好 | 容易泄露，轮换困难 |
| Token/JWT | 便于接入 IAM，支持过期 | 设备时间不准会影响校验 |
| 设备密钥签名 | 适合 IoT 设备 | 密钥烧录和轮换复杂 |
| mTLS 客户端证书 | 安全强，身份明确 | 证书生命周期管理成本高 |
| Enhanced Auth | MQTT 5.0 标准能力 | SDK 和 Broker 支持度要验证 |

生产建议：

- 公网不使用匿名连接。
- 每台设备有独立身份，不共享一个账号。
- 设备密钥支持吊销和轮换。
- 认证失败要有速率限制，防止暴力尝试。
- 服务端消费者和设备账号分开。

### 12.2 授权

授权核心是 Topic ACL：

```text
device d-9001:
  publish:
    prod/tenant-1001/device/d-9001/telemetry
    prod/tenant-1001/device/d-9001/event/+
    prod/tenant-1001/device/d-9001/status
  subscribe:
    prod/tenant-1001/device/d-9001/command/+
    prod/tenant-1001/device/d-9001/config

service order-worker:
  subscribe:
    prod/tenant-1001/device/+/event/order
  publish:
    prod/tenant-1001/service/order-worker/ack/+
```

授权要点：

- Publish 和 Subscribe 分开授权。
- 通配符订阅必须单独评估。
- Retained Message 的读取和写入要纳入授权。
- Shared Subscription 的 `$share` 前缀不能绕过 Topic ACL。
- 不允许设备发布到其他设备命令 Topic。
- 不允许普通设备订阅租户级 `#`。

### 12.3 常见攻击与防护

| 风险 | 表现 | 防护 |
|---|---|---|
| ClientId 抢占 | 恶意连接踢掉合法设备 | 绑定 ClientId 与认证主体，异常告警 |
| Topic 越权 | 订阅或发布其他租户 Topic | 严格 ACL，租户隔离测试 |
| Retained 污染 | 写入虚假最新状态 | 限制 retain 权限，审计保留消息 |
| Will 滥用 | 异常状态伪造 | 限制 Will Topic 和 Payload |
| 大包攻击 | 大 Payload 占用内存 | Maximum Packet Size，网关限制 |
| 连接洪泛 | 大量连接耗尽资源 | 连接速率限制，IP/账号限额 |
| 订阅爆炸 | 大量通配订阅拖慢匹配 | 订阅数量上限，禁止危险通配 |
| 离线队列堆积 | 持久会话积压 | Session Expiry、队列上限、消息过期 |

### 12.4 多租户隔离

多租户 Topic 推荐把 tenantId 放在靠前层级：

```text
{env}/{tenantId}/{domain}/{entityId}/{messageType}
```

例如：

```text
prod/t1001/device/d9001/telemetry
prod/t1001/device/d9001/command/reboot
prod/t1001/store/s3001/pos/p9001/status
```

ACL 必须从认证主体推导租户，不能相信客户端自己在 Topic 中写的 tenantId。

---

## 13. 可靠性、顺序与幂等

### 13.1 MQTT 能保证什么

在单条网络连接上，底层 TCP 提供有序字节流，MQTT 在此基础上处理控制包。协议可以提供 QoS 级别的传输确认、重传和会话恢复。

但工程上不能过度推导：

- QoS 1 允许重复。
- QoS 2 不等于业务全链路绝对一次。
- 共享订阅后，多消费者之间顺序更难保证。
- Broker 集群、桥接、规则引擎、后端 MQ 都可能引入新的重试和乱序。
- 设备离线重连后，旧消息和新状态可能交错到达。

### 13.2 业务幂等设计

关键消息应包含：

```json
{
  "messageId": "01J...",
  "deviceId": "d-9001",
  "eventType": "order_paid",
  "eventTime": "2026-06-26T10:12:33Z",
  "sequence": 1024,
  "schemaVersion": 3,
  "payload": {}
}
```

幂等策略：

- messageId 去重：适合事件处理。
- commandId 去重：适合命令执行。
- sequence 单调递增：适合设备状态流。
- version/CAS：适合配置下发。
- 业务唯一键：适合订单、支付、库存等领域事件。

### 13.3 乱序处理

状态类消息应支持乱序丢弃：

```text
if incoming.version <= current.version:
    ignore
else:
    apply
```

事件类消息不应简单丢弃旧时间戳，而应根据业务规则处理。例如支付事件晚到不能因为时间早于当前状态就丢弃，必须走状态机校验。

---

## 14. Topic 与 Payload 设计范式

### 14.1 推荐 Topic 分层

通用模板：

```text
{env}/{tenant}/{product}/{deviceId}/{channel}/{action}
```

示例：

```text
prod/t1001/fridge/d9001/telemetry/up
prod/t1001/fridge/d9001/event/alarm
prod/t1001/fridge/d9001/command/down
prod/t1001/fridge/d9001/command/ack
prod/t1001/fridge/d9001/config/update
prod/t1001/fridge/d9001/status/online
```

### 14.2 命令下发模式

```text
云端发布：
topic: prod/t1001/device/d9001/command/down
payload:
{
  "commandId": "cmd-20260626-0001",
  "type": "reboot",
  "expiresAt": "2026-06-26T10:20:00Z",
  "params": {}
}

设备确认：
topic: prod/t1001/device/d9001/command/ack
payload:
{
  "commandId": "cmd-20260626-0001",
  "status": "accepted",
  "reason": null,
  "ts": "2026-06-26T10:12:40Z"
}

设备执行结果：
topic: prod/t1001/device/d9001/command/result
payload:
{
  "commandId": "cmd-20260626-0001",
  "status": "success",
  "ts": "2026-06-26T10:13:12Z"
}
```

命令系统不要只依赖 MQTT PUBACK。PUBACK 只表示协议层收到，不表示设备业务执行成功。

### 14.3 遥测上报模式

```text
topic: prod/t1001/device/d9001/telemetry/up
qos: 0 或 1
payload:
{
  "messageId": "m-001",
  "ts": "2026-06-26T10:12:33Z",
  "metrics": {
    "temperature": 4.2,
    "humidity": 62,
    "battery": 78
  }
}
```

高频遥测通常不要每条都 QoS 1，除非确实不能丢。更常见做法是：

- 高频最新值 QoS 0。
- 关键告警 QoS 1。
- 周期性摘要或状态变更 QoS 1。

### 14.4 Payload 格式

常见选择：

| 格式 | 优点 | 风险 |
|---|---|---|
| JSON | 易调试，跨语言简单 | 体积大，类型约束弱 |
| Protobuf | 小、强 schema、适合多语言 | 调试和网关处理更复杂 |
| CBOR/MessagePack | 二进制紧凑 | 工具链和规范治理要求更高 |
| 纯二进制 | 极致压缩 | 可维护性差，需严格文档 |

实践建议：

- 先明确 schemaVersion。
- 数值字段写清单位。
- 时间统一 UTC 或明确时区。
- 不在 Payload 中传输明文密钥。
- 大文件只传引用、哈希、长度和签名 URL。

---

## 15. Broker 架构与集群

### 15.1 Broker 的核心职责

一个生产 MQTT Broker 通常需要处理：

- 长连接管理。
- CONNECT 认证。
- Topic ACL 授权。
- 订阅树维护和匹配。
- PUBLISH 路由。
- QoS 状态机。
- Retained Message 存储。
- 会话与离线队列。
- 规则引擎、桥接、Webhook 或插件。
- 指标、日志、审计。

这些职责决定了 Broker 不是一个普通 HTTP 服务。它对连接数、内存、文件描述符、网络缓冲、磁盘持久化和集群状态同步非常敏感。

### 15.2 单机容量关注点

容量估算至少看：

```text
连接数内存 = 在线连接数 * 单连接基础内存
订阅内存 = 订阅数量 * Topic Filter 状态
离线队列 = 离线客户端数 * 平均积压消息数 * 平均消息大小
转发量 = 发布速率 * 平均 Fan-out
出站带宽 = 转发量 * 平均消息大小
```

最容易被低估的是 Fan-out：

```text
1 条 PUBLISH 匹配 1000 个订阅者 = 1000 次下行投递
```

Topic 设计、通配订阅、共享订阅、租户隔离都会影响订阅匹配成本。

### 15.3 集群与负载均衡

MQTT 集群比 HTTP 集群复杂，原因是连接是长连接，会话和订阅是有状态的。

负载均衡关注：

- TCP 长连接保持。
- TLS 终止位置。
- WebSocket Upgrade 支持。
- 连接空闲超时。
- ClientId 重连是否能恢复到有会话状态的节点。
- Broker 集群是否复制会话、订阅和 Retained Message。

常见策略：

1. Broker 自身集群同步会话和订阅状态。
2. 负载均衡使用一致性哈希或粘性会话。
3. 设备重连后允许任意节点接入，但 Broker 集群负责状态恢复。
4. 对服务端消费者使用共享订阅扩容。

具体选择依 Broker 产品能力而定，不能假设所有 Broker 集群语义一致。

### 15.4 桥接与规则引擎

Broker 通常会把 MQTT 消息转发到后端系统：

- Kafka/Pulsar：事件流、日志、离线分析。
- HTTP/gRPC：业务服务回调。
- Redis：状态缓存。
- Time-series DB：遥测指标。
- Object Storage：大文件元数据。

桥接要处理：

- 重试和死信。
- 幂等键传递。
- Topic 到业务类型映射。
- 失败隔离，不能让后端慢服务拖垮 Broker 主链路。
- 回压策略，不能无限堆积。

---

## 16. 可观测性与运维

### 16.1 Broker 指标

关键指标：

- 在线连接数、连接建立速率、断开速率。
- CONNACK 失败原因分布。
- 认证失败、授权失败次数。
- 入站/出站 PUBLISH 速率。
- 入站/出站字节数。
- QoS 1/2 未确认消息数。
- 会话数量、持久会话数量。
- 离线队列长度、丢弃消息数、过期消息数。
- Retained Message 数量和大小。
- 订阅数量、通配订阅数量。
- Broker CPU、内存、磁盘、FD、网络。
- 集群节点状态、复制延迟、规则引擎失败。

### 16.2 客户端指标

设备或 SDK 应记录：

- 连接成功/失败次数。
- 断开原因。
- 重连次数和退避时间。
- PING 往返时间。
- 发布成功/失败/超时。
- QoS 1/2 in-flight 数量。
- 收到重复消息数量。
- 命令 ACK 延迟。
- 本地待发送队列长度。

### 16.3 日志与追踪

建议统一字段：

```text
traceId
messageId
commandId
clientId
tenantId
deviceId
topic
qos
packetId
reasonCode
brokerNode
sessionPresent
```

MQTT 5.0 User Properties 可以携带 traceId，但不要假设所有中间链路都会保留它。桥接到 HTTP/Kafka 时要显式映射追踪字段。

---

## 17. 性能设计

### 17.1 影响性能的因素

| 因素 | 影响 |
|---|---|
| QoS 等级 | QoS 越高，确认报文和状态越多 |
| Payload 大小 | 影响带宽、内存、序列化成本 |
| Topic 长度 | 高频场景下影响带宽，可用 Topic Alias 优化 |
| 订阅数量 | 影响订阅匹配和内存 |
| 通配订阅 | 影响匹配复杂度和流量放大 |
| Retained 数量 | 影响存储和新订阅时投递 |
| 离线队列 | 影响磁盘、内存和恢复尖峰 |
| TLS | 增加握手和加解密成本，但生产通常必须接受 |
| WebSocket | 增加帧和代理层开销 |

### 17.2 降本策略

- 高频遥测使用 QoS 0。
- 关键事件单独 Topic，使用 QoS 1。
- 只保留必要 Retained Message。
- 控制 Topic 层级和长度。
- 使用批量 Payload，但不要做过大批量。
- 设备端压缩前要评估 CPU 和耗电。
- 使用共享订阅扩展后端消费者。
- MQTT 5.0 下使用 Topic Alias、Receive Maximum、Maximum Packet Size。
- 对离线队列设置 TTL 和上限。

---

## 18. 测试策略

### 18.1 协议兼容测试

需要覆盖：

- MQTT 3.1.1 / 5.0 连接。
- TLS/mTLS。
- username/password 或 Token。
- ClientId 重复连接。
- Clean Session / Clean Start / Session Expiry。
- QoS 0/1/2 发布和订阅。
- Retained Message。
- Will Message。
- Topic 通配符。
- Shared Subscription。
- Maximum Packet Size。
- 非法 Topic、非法 QoS、非法报文。

### 18.2 弱网与故障测试

必须模拟：

- 网络断开。
- Broker 重启。
- Broker 集群节点下线。
- 客户端进程崩溃。
- ACK 丢失或超时。
- 慢消费者。
- 离线队列堆积。
- 设备批量重连。
- NAT 空闲超时。

### 18.3 安全测试

至少覆盖：

- 未认证连接拒绝。
- 错误密码/过期 Token。
- 设备发布到其他租户 Topic。
- 设备订阅 `#`。
- 设备写 Retained 到非法 Topic。
- 共享订阅绕过 ACL。
- 大包、超长 Topic、过多订阅。
- ClientId 抢占。

---

## 19. 常见误区

### 19.1 把 QoS 当成业务事务

QoS 只处理 MQTT 链路的交付确认，不处理数据库事务、业务状态机、后端消费成功或跨系统一致性。

正确做法：重要消息必须有业务 ID、幂等、状态机和业务 ACK。

### 19.2 把 Retained Message 当数据库

Retained 只是每个 Topic 的最后值缓存。它没有查询能力、历史能力、复杂事务能力，也不适合存储大量业务数据。

正确做法：Retained 用于最新状态；历史、审计和查询进入数据库或流系统。

### 19.3 所有消息都上 QoS 2

QoS 2 成本高，吞吐低，状态复杂，还不能替代业务幂等。大多数生产系统用 QoS 0 + QoS 1 的组合就足够。

### 19.4 允许设备订阅大范围通配符

这会造成越权和流量放大。尤其在多租户环境中，`#` 和租户级 `+/+/...` 必须严格禁止或只允许受控服务端消费者使用。

### 19.5 无限持久会话

无限会话加离线队列会让离线设备变成资源黑洞。应设置 Session Expiry、队列上限和消息过期。

### 19.6 大文件通过 MQTT 传

MQTT 适合控制消息和事件，不适合传固件、图片、视频、批量日志。大文件应走对象存储/HTTP，MQTT 传任务元数据。

---

## 20. 与其他协议的对比

| 协议/系统 | 主要模型 | 更适合 | 不适合 |
|---|---|---|---|
| MQTT | 发布/订阅，长连接，轻量控制包 | 设备接入、弱网遥测、命令下发 | 强同步 RPC、大文件传输 |
| HTTP REST | 请求/响应，无状态 | 管理 API、查询、配置、普通业务接口 | 大量设备实时双向通信 |
| WebSocket | 双向字节/消息通道 | 浏览器实时通信、自定义协议 | 自带 Topic、QoS、会话语义的 IoT 接入 |
| AMQP | 企业消息协议 | 复杂路由、队列、事务型消息 | 极弱设备和超轻量协议栈 |
| Kafka | 分布式日志 | 高吞吐事件流、回放、分析 | 海量设备长连接接入 |
| CoAP | REST-like，UDP，轻量 | 低功耗受限设备、局域网 | 复杂发布订阅和云端长连接 |

实践中 MQTT 经常和 HTTP、Kafka 一起使用，而不是互相替代。

### 20.1 几种相似架构的控制台图

站在架构师视角，MQTT 的结构结果可以概括为：

```text
基于 Topic 的发布订阅消息代理架构

Publisher / Device / Service
        │
        │ publish(topic, payload)
        ▼
┌──────────────────────────────┐
│ MQTT Broker                  │
│ - 管连接                     │
│ - 管 Topic 订阅匹配          │
│ - 管 QoS / Session / Will    │
│ - 管 Retained Message        │
└──────────────────────────────┘
        │
        │ deliver by topic filter
        ▼
Subscriber / Service / Page / Device
```

它和几种常见架构的关系如下：

```text
                  ┌──────────────────────────┐
                  │ 发布/订阅思想 Pub/Sub     │
                  └─────────────┬────────────┘
                                │
      ┌─────────────────────────┼─────────────────────────┐
      │                         │                         │
      ▼                         ▼                         ▼
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ MQTT Broker  │          │ Event Bus    │          │ MQ Broker    │
│ Topic 路由   │          │ 领域事件分发 │          │ 队列/交换机  │
│ 长连接/弱网  │          │ 服务内/系统内│          │ 后端异步消息 │
└──────┬───────┘          └──────┬───────┘          └──────┬───────┘
       │                         │                         │
       │                         │                         │
       ▼                         ▼                         ▼
  IoT 设备接入              业务事件解耦              任务削峰/异步处理

      ┌─────────────────────────┼─────────────────────────┐
      │                         │                         │
      ▼                         ▼                         ▼
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ Observer     │          │ Kafka/Pulsar │          │ WebSocket GW │
│ 进程内观察者 │          │ 持久化事件日志│          │ 双向连接网关 │
│ 设计模式     │          │ 流处理/回放   │          │ 自定义路由   │
└──────────────┘          └──────────────┘          └──────────────┘
```

### 20.2 联系：它们都在解决什么问题

这些结构都在解决同一类问题：不要让发送方直接绑定所有接收方。

传统直接调用是：

```text
A ──直接调用──▶ B
A ──直接调用──▶ C
A ──直接调用──▶ D
```

发送方必须知道 B、C、D 的地址、接口和可用性。系统变大后，调用关系会变成网状结构。

发布/订阅或消息代理结构改成：

```text
A ──发布事件/消息──▶ 中间层 ──分发──▶ B
                              ├──────▶ C
                              └──────▶ D
```

中间层可以是 MQTT Broker、事件总线、消息队列、Kafka Topic、WebSocket 网关里的订阅管理模块，也可以是进程内观察者模式里的 Subject。

共同点：

- 发送方不直接知道所有接收方。
- 接收方可以后续增加或减少。
- 一条消息可以被多个处理方感知。
- 系统从直接调用转为事件驱动或消息驱动。

### 20.3 区别：每种结构的核心抽象不同

```text
┌────────────────┬────────────────────┬────────────────────┬────────────────────┐
│ 结构            │ 核心抽象             │ 最擅长               │ 不擅长               │
├────────────────┼────────────────────┼────────────────────┼────────────────────┤
│ MQTT            │ Topic + Broker      │ 设备长连接、弱网通信 │ 后端历史回放、大文件 │
│ Event Bus       │ Domain Event        │ 业务事实异步传播     │ 设备接入、弱网会话   │
│ MQ Broker       │ Queue / Exchange    │ 异步任务、削峰       │ 海量设备长连接       │
│ Observer        │ Subject / Observer  │ 进程内对象通知       │ 跨网络可靠传输       │
│ Kafka / Pulsar  │ Append-only Log     │ 高吞吐、回放、流处理 │ 直接管理设备长连接   │
│ WebSocket GW    │ Connection Channel  │ 浏览器实时双向通信   │ 标准 QoS/Retain/Will │
└────────────────┴────────────────────┴────────────────────┴────────────────────┘
```

更具体地看：

```text
MQTT:
Device ──PUBLISH topic──▶ Broker ──Topic Filter──▶ Subscriber
重点：长连接、Topic 路由、QoS、会话、Retained、Will、弱网。

事件总线:
Order Service ──OrderCreated──▶ Event Bus ──▶ Inventory Service
Payment Service ──PaymentSucceeded──▶ Event Bus ──▶ Order Service
Order Service ──OrderPaid──▶ Event Bus ──▶ Points / Notify / Inventory
重点：谁拥有业务事实，谁发布领域事件；其他系统订阅后执行自己的后续动作。

消息队列:
Producer ──Task Message──▶ Queue ──▶ Consumer Group
重点：异步处理、削峰、失败重试、任务消费。

观察者模式:
Subject.stateChanged() ──notify──▶ ObserverA / ObserverB / ObserverC
重点：进程内对象关系，不负责网络、认证、持久化和重试。

Kafka / Pulsar:
Producer ──Event──▶ Topic Partition Log ──offset──▶ Consumer Group
重点：消息是可持久化、可按 offset 回放的日志。

WebSocket 网关:
Browser/App ◀──────── WebSocket Gateway ────────▶ Backend
重点：提供双向实时通道；Topic、权限、离线消息、QoS 通常要自己实现。
```

### 20.4 架构师视角的判断

可以先用一句话快速判断：

```text
如果关心「设备把消息发到哪里，谁能收到」：
看 MQTT Topic。

如果关心「发生了什么业务事实，哪些系统要响应」：
看事件总线 eventType。
```

如果问题是「大量设备如何稳定接入云端，弱网下还能上报状态、接收命令」，优先看 MQTT。

如果问题是「一个业务事实发生后，多个业务系统如何异步响应」，看事件总线。

如果问题是「后端任务如何排队、削峰、失败重试」，看 RabbitMQ、RocketMQ、ActiveMQ、SQS 这类消息队列。

如果问题是「服务内部对象状态变化后，通知多个对象」，看观察者模式。

如果问题是「事件要长期保存、可回放、可流处理」，看 Kafka 或 Pulsar。

如果问题是「浏览器或 App 需要实时双向通信」，看 WebSocket；如果还需要 Topic、QoS、会话和离线语义，就要在 WebSocket 之上再设计一层类似 MQTT 的能力，或者直接使用 MQTT over WebSocket。

### 20.5 哪些场景需要状态机

状态机不是为了把代码写复杂，而是为了保护有生命周期的业务对象。只要一个事件能不能处理取决于对象当前状态，就应该考虑状态机。

核心判断：

```text
如果事件是否能处理，取决于当前状态：
需要状态机。

如果事件可能重复、乱序、晚到，并且会改变业务状态：
需要状态机。

如果业务对象有「创建、处理中、成功、失败、取消、超时、关闭」这类生命周期：
需要状态机。
```

#### 20.5.1 典型适用场景

```text
1. 订单

CREATED -> PAID -> FINISHED
CREATED -> CANCELLED
PAID -> REFUNDING -> REFUNDED

原因：
支付成功、取消、退款、完成履约都不能无条件执行。
例如 CANCELLED 状态下收到 PaymentSucceeded，不能直接改成 PAID，
通常要进入退款、补偿、告警或人工核查流程。
```

```text
2. 支付单

INIT -> PAYING -> SUCCESS
INIT -> PAYING -> FAILED
PAYING -> CLOSED
SUCCESS -> REFUNDING -> REFUNDED

原因：
支付回调可能重复、乱序、晚到。
消费者不能因为收到一条新回调就直接覆盖支付状态。
```

```text
3. 库存锁定与扣减

LOCKED -> DEDUCTED
LOCKED -> RELEASED

原因：
订单创建后锁库存，支付成功后确认扣减，订单取消后释放库存。
如果库存已经 DEDUCTED，再收到 OrderCancelled，不能再释放库存。
```

```text
4. 退款 / 售后

APPLIED -> APPROVED -> REFUNDING -> REFUNDED
APPLIED -> REJECTED
APPROVED -> RETURNED

原因：
售后流程包含申请、审核、退货、退款等阶段。
不同阶段允许的操作不同，不能任意跳转。
```

```text
5. 设备命令 / IoT 指令

CREATED -> SENT -> ACCEPTED -> RUNNING -> SUCCEEDED
CREATED -> SENT -> REJECTED
CREATED -> SENT -> TIMEOUT
RUNNING -> FAILED

原因：
设备 ACK、执行结果、超时事件可能重复或乱序。
如果命令已经 SUCCEEDED，后续再收到旧的 ACCEPTED，应视为旧事件并跳过。
```

```text
6. 审批流

DRAFT -> SUBMITTED -> APPROVED -> DONE
SUBMITTED -> REJECTED
SUBMITTED -> WITHDRAWN

原因：
提交、审批、驳回、撤回都有明确状态限制。
已经 APPROVED 的审批单不能再被普通驳回事件改回 REJECTED。
```

```text
7. 工单流

CREATED -> ASSIGNED -> PROCESSING -> RESOLVED -> CLOSED
CREATED -> CANCELLED

原因：
派单、接单、处理中、解决、关闭都有明确先后关系。
重复派单、处理后取消、关闭后继续处理都需要状态约束。
```

```text
8. 物流 / 履约

CREATED -> PICKED_UP -> IN_TRANSIT -> DELIVERED
IN_TRANSIT -> EXCEPTION

原因：
物流事件可能乱序到达。
如果 DELIVERED 已经生效，后到的 IN_TRANSIT 不能让状态倒退。
```

```text
9. 优惠券 / 权益

CREATED -> ISSUED -> USED
ISSUED -> EXPIRED
ISSUED -> REVOKED

原因：
已使用的券不能再过期、撤销或重复使用。
权益类业务通常还要结合业务唯一键，防止重复发放和重复核销。
```

```text
10. 账号 / 会员状态

NORMAL -> FROZEN -> NORMAL
NORMAL -> DISABLED
NORMAL -> CLOSED

原因：
冻结、解冻、禁用、注销都有明确业务含义。
已经注销的账号通常不能再被普通解冻事件恢复。
```

#### 20.5.2 通常不需要完整状态机的场景

不是所有消费者都需要状态机。如果事件处理只是追加记录或创建一次性副作用，通常用幂等键和唯一约束就够了。

```text
1. 追加审计日志
收到事件就写 audit_log，但仍建议用 eventId 去重。

2. 指标统计
收到事件就计数或聚合，重点是 eventId 去重和窗口统计口径。

3. 发积分 / 发优惠券记录
通常靠业务唯一键防重复，例如 unique(orderId, pointsType)。

4. 简单通知任务
通常靠 unique(bizId, notifyType, channel) 防重复。

5. 最新状态同步
如果只是覆盖最新状态，通常用 version 或 sequence 判断新旧。
```

#### 20.5.3 消费者判断顺序

消费者处理事件时，可以按下面顺序判断：

```text
收到事件
  │
  ▼
1. eventId + consumerName 是否已经处理过
  │
  ▼
2. tenantId / source / schemaVersion 是否可信
  │
  ▼
3. 业务对象是否存在，并且是否属于当前租户
  │
  ▼
4. 当前状态是否允许这个事件生效
  │
  ├── 不允许，但属于重复事件：跳过并 ACK
  ├── 不允许，且属于业务冲突：补偿 / 告警 / 死信
  └── 允许：继续
  │
  ▼
5. 是否已经通过业务唯一键生效过
  │
  ▼
6. 事件是否过期、乱序或版本过旧
  │
  ▼
7. 执行业务变更
  │
  ▼
8. 本地事务提交成功后 ACK
```

一句话总结：

```text
有生命周期、有合法流转、有重复/乱序/晚到风险的状态型业务，
就应该使用状态机。
```

---

## 21. 工程落地参考架构

### 21.1 设备接入平台

```text
Device
  │ MQTT/TLS
  ▼
Load Balancer
  │ TCP passthrough 或 TLS termination
  ▼
MQTT Broker Cluster
  ├── AuthN/AuthZ Service
  ├── Rule Engine
  ├── Retained / Session Store
  ├── Metrics / Audit
  │
  ├──▶ Kafka: event stream
  ├──▶ Redis: latest device state
  ├──▶ TSDB: telemetry metrics
  ├──▶ Business Service: command orchestration
  └──▶ Object Storage: OTA metadata
```

### 21.2 命令闭环

```text
业务系统创建命令
  │
  ▼
Command Service 写入命令表，状态=pending
  │
  ▼
MQTT publish command/down，QoS 1，Message Expiry=命令有效期
  │
  ▼
设备收到命令，校验 commandId/expiresAt
  │
  ├── publish command/ack，状态=accepted/rejected
  │
  └── 执行业务动作
        │
        └── publish command/result，状态=success/failed
```

关键点：

- 命令入库早于 MQTT 发布。
- commandId 全链路传递。
- 设备 ACK 和执行结果分开。
- 命令有过期时间。
- 云端状态机处理重复 ACK、重复 result 和超时。

### 21.3 设备状态模型

建议拆分：

- 连接状态：Broker 连接事件 + Will。
- 心跳状态：设备周期上报。
- 业务状态：设备业务模块健康。
- 最新遥测：可覆盖状态。
- 历史遥测：写入 TSDB 或数据湖。

不要用一个 `online=true/false` 解释所有状态。

---

## 22. MQTT 3.1.1 到 5.0 迁移

### 22.1 迁移收益排序

优先迁移这些能力：

1. Reason Code：先提升诊断。
2. Session Expiry：治理会话资源。
3. Message Expiry：避免旧命令迟到执行。
4. Maximum Packet Size：防止大包。
5. Receive Maximum：保护慢消费者。
6. Response Topic + Correlation Data：标准化请求/响应。
7. User Properties：补齐追踪和元数据。
8. Topic Alias：在明确带宽瓶颈后再使用。

### 22.2 迁移原则

- Broker 先支持双协议。
- 新设备优先使用 5.0，旧设备保留 3.1.1。
- SDK 封装暴露统一业务 API，隐藏协议版本差异。
- 不要一次性把所有消息改成依赖 MQTT 5.0 属性。
- 迁移前后 Topic 和 Payload 契约保持兼容。
- 指标中区分协议版本。

### 22.3 兼容策略

```text
if client supports MQTT 5.0:
    use session expiry, message expiry, reason codes, response topic
else:
    use MQTT 3.1.1 clean session + payload-level expiry + business ack
```

对于必须兼容 3.1.1 的业务，不要把核心业务字段只放在 MQTT 5.0 Properties 中。可以把关键字段放在 Payload，同时用 Properties 做增强。

---

## 23. 生产设计清单

### 23.1 协议与连接

- [ ] 明确 MQTT 版本：3.1.1、5.0 或双栈。
- [ ] 公网启用 TLS。
- [ ] 认证方式支持吊销和轮换。
- [ ] ClientId 命名规则唯一且可审计。
- [ ] Keep Alive 与 NAT/网络环境匹配。
- [ ] 重连使用指数退避和随机抖动。

### 23.2 Topic 与权限

- [ ] Topic 分层包含环境和租户。
- [ ] Publish/Subscribe ACL 分开。
- [ ] 禁止普通设备订阅 `#`。
- [ ] Retained 写权限单独控制。
- [ ] Shared Subscription 不绕过 ACL。
- [ ] Topic 不包含敏感信息。

### 23.3 消息与语义

- [ ] 每类消息定义 QoS。
- [ ] 重要消息有 messageId/commandId。
- [ ] 消费端幂等。
- [ ] 命令有过期时间。
- [ ] 设备 ACK 与执行结果分离。
- [ ] Payload 有 schemaVersion。
- [ ] 大文件不走 MQTT Payload。

### 23.4 会话与资源

- [ ] Session Expiry 或 Clean Session 策略明确。
- [ ] 离线队列有上限。
- [ ] Retained Message 有治理策略。
- [ ] Maximum Packet Size 有限制。
- [ ] 慢消费者有流控。
- [ ] Broker 指标接入监控。

### 23.5 测试与运维

- [ ] 覆盖断网、重连、Broker 重启。
- [ ] 覆盖重复消息和乱序。
- [ ] 覆盖认证失败和越权 Topic。
- [ ] 覆盖重连风暴。
- [ ] 有连接数、吞吐、队列、失败原因告警。
- [ ] 有 Broker 日志和业务 traceId 关联。

---

## 24. 最小实践样例

### 24.1 Topic 约定

```text
prod/{tenant}/device/{deviceId}/telemetry/up
prod/{tenant}/device/{deviceId}/event/up
prod/{tenant}/device/{deviceId}/command/down
prod/{tenant}/device/{deviceId}/command/ack
prod/{tenant}/device/{deviceId}/command/result
prod/{tenant}/device/{deviceId}/status
prod/{tenant}/service/{serviceName}/reply
```

### 24.2 QoS 约定

| 消息 | QoS | Retain | 说明 |
|---|---:|---:|---|
| 高频遥测 | 0 | false | 可丢，下一次覆盖 |
| 告警事件 | 1 | false | 需要幂等 |
| 命令下发 | 1 | false | 必须 commandId + expiresAt |
| 命令 ACK | 1 | false | 云端幂等处理 |
| 在线状态 | 1 | true | 最新状态缓存 |
| 配置版本 | 1 | true | 新订阅者立即获取 |

### 24.3 Payload 基线

```json
{
  "schemaVersion": 1,
  "messageId": "m-20260626-000001",
  "tenantId": "t1001",
  "deviceId": "d9001",
  "eventTime": "2026-06-26T10:12:33Z",
  "sequence": 1024,
  "data": {}
}
```

---

## 25. 总结

MQTT 的本质不是「更轻的 HTTP」，也不是「万能消息队列」。它是一套面向大量长连接设备、弱网和发布/订阅路由的协议语义。真正用好 MQTT，关键不在于会调用 `publish()` 和 `subscribe()`，而在于理解以下边界：

- QoS 是协议交付语义，不是业务事务语义。
- Retained Message 是最后值缓存，不是数据库。
- Will 是异常断线信号，不是完整在线状态系统。
- Topic 是路由契约，不是权限本身。
- ClientId 是会话身份，必须和认证主体绑定。
- 持久会话和离线队列必须设置资源边界。
- MQTT 5.0 的价值主要在诊断、治理、流控和元数据，而不是简单性能提升。

生产级 MQTT 系统的质量取决于 Topic 设计、ACL、安全、幂等、资源上限、Broker 集群和可观测性。协议很轻，但工程治理不能轻。

---

## 参考资料

1. MQTT 官方网站：https://mqtt.org/
2. MQTT 官方规范入口：https://mqtt.org/mqtt-specification/
3. OASIS MQTT Version 5.0 标准：https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html
4. OASIS MQTT Version 3.1.1 标准：https://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html
5. OASIS MQTT 5.0 标准发布页：https://www.oasis-open.org/standard/mqtt-v5-0-os/
6. OASIS MQTT 3.1.1 标准发布页：https://www.oasis-open.org/standard/mqttv3-1-1/
7. OASIS MQTT-SN Subcommittee：https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=mqtt-sn
