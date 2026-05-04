# K8s、Spring Boot、Nacos、RocketMQ 推荐组合架构图

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、先说结论

如果系统是：

- Java / Spring Boot 技术栈
- 部署在 Kubernetes 上
- 需要配置中心
- 需要异步消息能力

那么一个很实用、也很常见的组合是：

```text
K8s 负责运行和服务入口
Spring Boot 负责业务实现
Nacos 负责配置中心
RocketMQ 负责异步消息
```

如果只从“推荐组合”角度看，可以先这样记：

```text
K8s 管运行
Nacos 管配置
RocketMQ 管消息
Spring Boot 写业务
```

---

## 二、推荐总体架构图

```text
浏览器 / 小程序 / POS / 第三方系统
               |
               v
        +------------------+
        | Ingress / Gateway|
        +---------+--------+
                  |
                  v
        +------------------+
        | K8s Service      |
        | ClusterIP/NodePort|
        +---------+--------+
                  |
                  v
        +-------------------------------+
        | Spring Boot 应用 Pod          |
        |-------------------------------|
        | Controller / Service / MQ     |
        +---------+----------+----------+
                  |          |
                  |          | 发送消息
                  |          v
                  |    +------------------+
                  |    | RocketMQ Broker  |
                  |    +------------------+
                  |
                  | 启动后拉取配置
                  v
        +------------------+
        | Nacos Config     |
        +------------------+
```

---

## 三、各组件职责

### 3.1 Kubernetes

K8s 主要负责：

- 部署应用
- 管理 Pod 副本
- 管理服务入口
- 管理基础配置注入
- 健康检查与重启

K8s 擅长的是：

```text
应用怎么跑起来
应用跑几个实例
外部流量怎么进来
```

它更偏“运行平台”。

---

### 3.2 Spring Boot

Spring Boot 主要负责：

- 业务接口
- 业务逻辑
- 数据处理
- 调用 RocketMQ
- 读取 Nacos 配置

它更偏：

```text
业务代码本身
```

---

### 3.3 Nacos

Nacos 在这个组合里建议主要负责：

- 配置中心
- 业务参数集中管理
- 动态刷新配置

如果已经使用 K8s Service Discovery，那么：

**不一定必须再用 Nacos Discovery 做服务发现。**

推荐理解：

```text
K8s 负责服务发现
Nacos 负责配置中心
```

---

### 3.4 RocketMQ

RocketMQ 主要负责：

- 异步解耦
- 削峰
- 可靠消息投递
- 延时消息
- 事务消息

它更偏：

```text
应用之间的异步消息通信
```

---

## 四、为什么这套组合合理

### K8s 负责运行

因为 K8s 更擅长：

- Deployment
- Pod 调度
- Service
- Ingress
- HPA
- 自愈

### Nacos 负责配置

因为 Nacos 更擅长：

- 配置集中管理
- namespace / group / dataId
- Spring Boot 动态刷新

### RocketMQ 负责消息

因为 RocketMQ 更擅长：

- 业务异步化
- 延时消息
- 事务消息
- 可靠投递

所以这套组合的边界比较清晰。

---

## 五、推荐分工图

```text
K8s
├─ Deployment：应用副本管理
├─ Service：服务入口
├─ Ingress：外部访问入口
├─ ConfigMap：普通启动配置
└─ Secret：敏感启动配置

Spring Boot
├─ Controller：HTTP 接口
├─ Service：业务逻辑
├─ Feign / WebClient：服务调用
└─ RocketMQTemplate / Listener：消息发送消费

Nacos
├─ Data ID：配置文件
├─ Group：配置分组
└─ Namespace：环境隔离

RocketMQ
├─ NameServer：路由中心
├─ Broker：消息存储与投递
├─ Producer：消息发送
└─ Consumer：消息消费
```

---

## 六、推荐调用链路

### 6.1 同步 HTTP 请求链路

```text
外部请求
  -> Ingress
  -> Service
  -> Spring Boot Pod
  -> Controller
  -> Service
  -> 数据库 / 其他服务
```

### 6.2 配置加载链路

```text
Spring Boot 启动
  -> 先读取本地 application.yml
  -> 再通过 spring.config.import 连接 Nacos
  -> 拉取 Data ID 配置
  -> 注入 Spring 环境
```

### 6.3 消息发送链路

```text
Spring Boot Service
  -> RocketMQ Producer
  -> NameServer 查路由
  -> Broker 接收并存储消息
```

### 6.4 消息消费链路

```text
RocketMQ Broker
  -> Consumer Group
  -> Spring Boot Consumer
  -> 业务处理逻辑
```

---

## 七、推荐的配置分工

### 7.1 放到 ConfigMap 的配置

适合：

- Nacos 地址
- 环境名
- JVM 参数
- 固定基础参数
- 其他不常变化的启动配置

### 7.2 放到 Secret 的配置

适合：

- 数据库密码
- Token
- AccessKey
- RocketMQ 凭证
- Redis 密码

### 7.3 放到 Nacos 的配置

适合：

- 业务开关
- 超时设置
- 路由参数
- 动态刷新配置
- 业务模板配置

### 7.4 放到 RocketMQ 的内容

RocketMQ 里不存“配置”，而是存：

- 业务消息
- 异步任务消息
- 延时任务消息
- 事务一致性消息

---

## 八、推荐实践：K8s 用服务发现，Nacos 用配置中心

推荐做法是：

```text
Spring Boot 调其他服务 -> 通过 K8s Service 名称
Spring Boot 读业务配置 -> 通过 Nacos Config
Spring Boot 做异步解耦 -> 通过 RocketMQ
```

这样做的好处是：

- 避免 K8s 和 Nacos 两套服务发现职责重叠
- 保留 Nacos 动态配置优势
- 利用 RocketMQ 做异步业务解耦

---

## 九、图示：推荐组合关系

```text
                   +----------------------+
                   |      Kubernetes      |
                   |----------------------|
                   | Deployment / Service |
                   | Ingress / ConfigMap  |
                   | Secret               |
                   +----------+-----------+
                              |
                              v
                   +----------------------+
                   |   Spring Boot Pod    |
                   |----------------------|
                   | Controller / Service |
                   | MQ Producer/Consumer |
                   +----+------------+----+
                        |            |
                        |            |
                        v            v
               +----------------+  +----------------+
               | Nacos Config   |  | RocketMQ       |
               | 配置中心        |  | 异步消息平台    |
               +----------------+  +----------------+
```

---

## 十、什么时候不建议这样组合

### 场景一：系统很小

如果只是单体应用或小项目：

- 不一定需要 Nacos
- 不一定需要 RocketMQ
- K8s 也可能过重

### 场景二：配置几乎不变

如果配置很稳定，也不要求动态刷新：

- ConfigMap + Secret 可能就够

### 场景三：没有异步需求

如果没有明显的削峰、解耦、延时、事务消息需求：

- RocketMQ 未必必须

---

## 十一、K8s 服务发现和 Nacos 服务发现的实现区别

它们表面上都在解决“按服务名找到服务”，但实现机制不是同一套。

### 11.1 K8s 服务发现

K8s 的服务发现核心依赖：

- `Service`
- `selector`
- `Endpoint / EndpointSlice`
- `CoreDNS`

实现图如下：

```text
Spring Boot Pod A
    |
    | 请求 http://order-service:8080
    v
CoreDNS
    |
    | 把 order-service 解析成 Service
    v
Service
    |
    | 再由 K8s 网络层转发
    v
后端 Pod 列表
```

特点：

- 应用本身不用主动注册
- K8s 平台根据 Pod 和 Service 自动维护实例关系
- 请求先到 Service，再由平台网络层转发到后端 Pod

### 11.2 Nacos 服务发现

Nacos 的服务发现核心依赖：

- 应用启动后主动注册
- 注册中心维护实例列表
- 调用方查询实例列表
- 客户端或框架自己选实例

实现图如下：

```text
order-service 启动
    |
    | 主动注册自己
    v
Nacos
    ^
    |
    | 查询 order-service
    |
Spring Boot App B
    |
    | 获取实例列表 [ip1, ip2, ip3]
    v
客户端自己选一个实例发请求
```

特点：

- 应用需要主动接入 Nacos 注册
- 调用方先向 Nacos 查实例列表
- 客户端侧自己选一个实例
- 更偏应用层服务治理

### 11.3 核心区别总结

```text
K8s 服务发现
= 平台层发现
= Service + DNS + Endpoint
= 请求先到 Service，再到 Pod

Nacos 服务发现
= 应用层发现
= 客户端注册 + 注册中心查询
= 客户端先拿实例列表，再自己选目标实例
```

推荐实践：

- 已经在 K8s 内部运行的 Spring Boot 服务
- 优先考虑 `K8s 做服务发现`
- `Nacos 做配置中心`

这样职责边界更清晰。

---

## 十二、请求链路、配置链路、消息链路总图

### 12.1 请求链路

这是最典型的同步 HTTP 请求路径：

```text
浏览器 / 小程序 / POS / 第三方系统
        |
        v
Ingress / Gateway
        |
        v
K8s Service
        |
        v
Spring Boot Pod
        |
        v
Controller -> Service -> Repository / 其他服务
```

解释：

- `Ingress / Gateway` 负责接外部流量
- `Service` 负责把流量转发给正确的 Pod
- `Spring Boot` 负责真正处理业务逻辑

---

### 12.2 配置链路

这是 Spring Boot 使用 Nacos 配置中心的常见路径：

```text
Spring Boot Pod 启动
      |
      | 先读取本地 application.yml / ConfigMap / Secret
      v
拿到 Nacos 地址、账号等基础配置
      |
      v
连接 Nacos Config
      |
      v
按 Data ID / Group / Namespace 拉取业务配置
      |
      v
注入 Spring Environment
      |
      v
@Value / @ConfigurationProperties / @RefreshScope 生效
```

解释：

- `ConfigMap / Secret` 更偏启动前置配置
- `Nacos` 更偏应用运行期业务配置
- 修改 Nacos 配置后，可通过刷新机制把新值更新到应用中

---

### 12.3 消息链路

这是 Spring Boot 使用 RocketMQ 的典型异步链路：

```text
Spring Boot Service
      |
      | 发送消息
      v
RocketMQ Producer
      |
      | 查 NameServer 路由
      v
RocketMQ Broker
      |
      | 持久化消息并等待投递
      v
Consumer Group
      |
      v
Spring Boot Consumer
      |
      v
业务处理逻辑
```

解释：

- Producer 负责发送消息
- Broker 负责存储和投递消息
- Consumer 负责消费消息并执行业务逻辑

---

### 12.4 三条链路合成总图

```text
外部请求
   |
   v
Ingress / Gateway
   |
   v
K8s Service
   |
   v
Spring Boot Pod
   | \
   |  \
   |   \----> RocketMQ Producer -> NameServer -> Broker -> Consumer Group -> Spring Boot Consumer
   |
   \-------> 启动时 / 刷新时 -> Nacos Config
```

可以把这张图理解成：

- 请求入口靠 `K8s`
- 配置来源靠 `Nacos`
- 异步链路靠 `RocketMQ`
- 业务逻辑落在 `Spring Boot`

---

## 十三、一句话总结

推荐组合可以概括为：

```text
K8s 管运行与入口
Spring Boot 管业务
Nacos 管配置
RocketMQ 管异步消息
```

再缩成一条链：

```text
请求走 K8s
配置走 Nacos
异步走 RocketMQ
业务跑在 Spring Boot
```
