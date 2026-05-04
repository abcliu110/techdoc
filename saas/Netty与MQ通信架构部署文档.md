# Netty 与 MQ 通信架构部署文档

## 一、架构概述

本项目采用 Netty TCP 长连接 + RocketMQ 消息队列的双通道通信架构，实现 POS 终端、服务端、MQ 消息中转之间的实时消息推送与业务解耦。

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    192.168.1.192 服务器 (nms4cloud-mq)                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        HTTP Server :18120                             │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐  ┌────────────────┐  ┌──────────────────────┐ │   │
│  │  │ Netty Server    │  │ Netty Client  │  │ RocketMQ Consumer    │ │   │
│  │  │ :9999 (TCP)     │  │ ──────────────│──│ MQTT_SEND_MSG        │ │   │
│  │  │ (接收POS连接)    │  │ 连接nms4cloud │  │                      │ │   │
│  │  └─────────────────┘  │ -netty :9999  │  └──────────────────────┘ │   │
│  │         │            └────────────────┘            │              │   │
│  │         │                   │                      │              │   │
│  │         ▼                   ▼                      ▼              │   │
│  │  ┌────────────────────────────────────────────────────────────┐    │   │
│  │  │                    ServerHandler                           │    │   │
│  │  │               topic_to_context 订阅路由表                   │    │   │
│  │  └────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
                                      │ TCP :9999
                                      ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                 另一台服务器 (nms4cloud-netty)                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        HTTP Server :18190                             │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐  ┌────────────────┐  ┌──────────────────────┐ │   │
│  │  │ Netty Server    │  │ WebSocket      │  │ ServerHandler         │ │   │
│  │  │ :9999 (TCP)     │  │ /ws/ :18190    │  │ topic_to_context      │ │   │
│  │  │ (中继转发)       │  │ (浏览器连接)     │  │ 订阅路由表             │ │   │
│  │  └─────────────────┘  └────────────────┘  └──────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
             │
    ┌────────┴────────┐
    │ POS终端 / APP    │
    │ (Netty Client)  │
    │ 连接到 192.168.1│
    │ 192:9999        │
    │                 │
    │ 订阅:           │
    │  - sid_server   │
    │  - uuid_server  │
    └─────────────────┘

    ┌──────────────────────────────────────┐
    │        172.16.0.14 - 日志服务器       │
    │  Logstash :35044                      │
    │  (接收各服务日志)                      │
    └──────────────────────────────────────┘

    ┌──────────────────────────────────────┐
    │     192.168.1.216:3306 - MySQL        │
    │     数据库: a_mq                      │
    │     (nms4cloud-mq + nms4cloud-netty) │
    └──────────────────────────────────────┘
```

> ⚠️ **重要提示**：nms4cloud-mq 和 nms4cloud-netty 都运行 Netty Server on :9999，因此**必须部署在不同的服务器上**！如果部署在同一台机器，会出现端口冲突。

---

## 二、端口分配表

| 服务 | HTTP 端口 | Netty TCP 端口 | 说明 | 部署要求 |
|------|----------|----------------|------|----------|
| nms4cloud-mq | 18120 | 9999 (Server) | MQ 消息中转、Netty 路由中枢、接收 POS 连接 | 独立服务器 |
| nms4cloud-netty | 18190 | 9999 (Server) | Netty 中继、WebSocket 服务 | 独立服务器 |
| POS 终端 / APP | - | 9999 (Client) | 业务终端，TCP 长连接 | 连接 192.168.1.192:9999 |
| nms4cloud-pos3boot | - | 9999 (Client) | 后台服务，打印任务连接 | 连接 192.168.1.192:9999 |

---

## 三、核心组件说明

### 3.1 Netty Server (9999) - 配置位置

**代码位置**：
```java
// nms4cloud-mq 和 nms4cloud-netty 通用
// NettyServer.java
@Value("${netty.port:9999}")
private String port;
```

**配置文件**：`nms4cloud-shared.yaml`
```yaml
netty:
  server:
    host: 192.168.1.192
    port: 9999  # ← 修改此值可改变端口
```

**修改方式**：登录 Nacos 控制台 → 找到 `nms4cloud-shared.yaml` → 修改 `netty.server.port` → 重启服务

---

## 三、核心组件说明

### 3.2 Netty Server 启动方式

**nms4cloud-mq** (`ListenerForNetty.java`):
```java
@PostConstruct
public void contextInitialized() {
    new Thread(nettyServer::start).start();  // 启动 Netty Server on :9999
    new Thread(nettyClient::start).start();  // 启动 Netty Client 连接到 nms4cloud-netty
}
```

**nms4cloud-netty** (`ListenerForNetty.java`):
```java
@PostConstruct
public void contextInitialized() {
    new Thread(nettyServer::start).start();  // 启动 Netty Server on :9999
}
```

### 3.3 通信架构说明

```
POS终端 ──TCP :9999──► nms4cloud-mq Netty Server ──► topic_to_context 路由
                                      │
                                      │ nms4cloud-mq Netty Client
                                      │ (连接到 nms4cloud-netty :9999)
                                      ▼
                            nms4cloud-netty Netty Server
                                      │
                            ┌─────────┴─────────┐
                            ▼                   ▼
                     WebSocket 浏览器    消息中继转发
```

### 3.4 RocketMQ Topic

| Topic 名称 | 用途 |
|-----------|------|
| MQTT_SEND_MSG | MQTT 消息发送队列 |
| NETTY_SUBSCRIBE | Netty 订阅消息 |
| MQTT_SEND_LOG | MQTT 日志记录 |
| MQ_SEND_MQTT_MSG | MQ 模块发送 MQTT 消息 |

---

## 四、通信流程

### 4.1 POS 终端消息发送流程

```
POS终端 ──TCP──> nms4cloud-mq:9999 ──> ServerHandler ──> topic_to_context
                                              │
                                              ▼
                                    RocketMQ: MQTT_SEND_MSG
```

### 4.2 MQ 消息推送至 POS 流程

```
RocketMQ: MQTT_SEND_MSG ──> SendMqttMsgConsumer
                                      │
                                      ▼
                              MqMqttMsgServicePlus
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              sendNettyMsg()    sendMqtt()       sendConfirmMsg()
                    │                 │                 │
                    ▼                 ▼                 ▼
            写入 topic_to    转发至 MQTT    Redis 确认消息缓存
            context 路由表     服务商
```

### 4.3 POS 终端订阅流程

```
POS终端 ──TCP 连接 9999──> 发送订阅消息
{
  "Cmd": "subscribe",
  "Topic": ["sid_server", "uuid_server"]
}

nms4cloud-mq ServerHandler ──> 写入 topic_to_context Map
```

---

## 五、关键代码片段

### 5.1 Netty Server 端口配置

```java
// NettyServer.java - 所有 Netty Server 共用
@Value("${netty.port:9999}")
private String port;

// 绑定端口
.localAddress(new InetSocketAddress(Integer.parseInt(port)))
```

### 5.2 消息发送 (nms4cloud-mq)

```java
// MqMqttMsgServicePlus.java
public void sendNettyMsg(String topic, String msg) {
    // 根据 topic 查找对应的 channel，发送消息
    ChannelContext ctx = topic_to_context.get(topic);
    if (ctx != null) {
        ctx.getChannel().writeAndFlush(msg);
    }
}
```

### 5.3 消息订阅 (nms4cloud-pos3boot)

```java
// NettyClient.java
public void subscribe() {
    JSONObject msg = new JSONObject();
    msg.put("Cmd", "subscribe");
    msg.put("Topic", getTopicList());
    sendMessage(msg);
}

private JSONArray getTopicList() {
    JSONArray topics = new JSONArray();
    topics.add(systemInfoUtil.uuid() + "_server");
    Long sid = sysConfigDataServiceLocal.getSid();
    if (sid != null) {
        topics.add(sid + "_server");
    }
    return topics;
}
```

---

## 六、Nacos 配置

### 6.1 nms4cloud-mq.yaml

```yaml
server:
  port: 18120
spring:
  datasource:
    url: jdbc:mysql://192.168.1.216:3306/a_mq
```

### 6.2 nms4cloud-netty.yaml

```yaml
server:
  port: 18190
cloud:
  nacos:
    config:
      shared-configs:
        - data-id: nms4cloud-shared.yaml
```

### 6.3 nms4cloud-shared.yaml (Netty 端口配置)

```yaml
netty:
  server:
    host: 192.168.1.192
    port: 9999  # ← Netty Server 监听端口，可在此修改
```

---

## 七、部署注意事项

1. **端口冲突**: nms4cloud-mq 和 nms4cloud-netty 都运行 Netty Server on :9999，**必须部署在不同服务器上**
2. **网络连通性**: POS 终端需能访问 nms4cloud-mq 服务器的 9999 端口
3. **数据库共享**: 两个服务共用 192.168.1.216:3306/a_mq 数据库
4. **双跳中继**: nms4cloud-mq 通过其内置的 Netty Client 连接到 nms4cloud-netty，实现跨服务消息转发
5. **修改端口**: 在 Nacos 的 `nms4cloud-shared.yaml` 中修改 `netty.server.port`，重启服务生效

---

## 八、常见问题

### Q1: 两个 9999 端口会冲突吗？
A: 不会，因为 nms4cloud-mq 和 nms4cloud-netty 部署在**不同的服务器上**。如果需要部署在同一台服务器，需要修改其中一个服务的 `netty.port` 配置。

### Q2: 端口在哪里修改？
A: 在 Nacos 控制台修改 `nms4cloud-shared.yaml` 配置文件中的 `netty.server.port` 值。

### Q3: 为什么 POS 终端连接到 nms4cloud-mq 而不是 nms4cloud-netty？
A: nms4cloud-mq 是消息中转枢纽，集成了 RocketMQ Consumer，可以直接处理来自 MQ 的消息并推送给 POS 终端。nms4cloud-netty 主要用于 WebSocket 浏览器连接和中继转发。

---

*文档生成时间: 2026-04-27*
*最后更新时间: 2026-04-27 (修正部署架构说明)*

