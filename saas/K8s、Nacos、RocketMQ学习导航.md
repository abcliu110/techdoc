# K8s、Nacos、RocketMQ 学习导航

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、文档用途

这份索引文档用于把最近补充的几篇：

- K8s 端口
- Ingress / Service / Deployment / Pod
- ConfigMap / Secret / Nacos
- K8s + Spring Boot + Nacos + RocketMQ
- RocketMQ 消息基础

串成一条连续学习路径，方便后续查阅。

---

## 二、推荐阅读顺序

### 第一步：先理解 K8s 里的流量怎么进应用

先看：

- [K8s端口暴露方式与NodePort、hostPort区别说明.md](D:/mywork/techdoc/saas/K8s端口暴露方式与NodePort、hostPort区别说明.md)

这篇解决的问题：

- `containerPort`
- `targetPort`
- `port`
- `nodePort`
- `hostPort`

重点结论：

- `NodePort` 是集群范围唯一
- `hostPort` 是单节点独占
- 普通 `Service port` 只是逻辑入口端口

---

### 第二步：再理解 Deployment、Service、Ingress 的关系

继续看：

- [K8s中Ingress、Service、Deployment、Pod关系图解.md](D:/mywork/techdoc/saas/K8s中Ingress、Service、Deployment、Pod关系图解.md)

这篇解决的问题：

- `Deployment` 做什么
- `Pod` 做什么
- `Service` 做什么
- `Ingress` 做什么
- `labels / selector` 怎么关联

重点结论：

- Deployment 负责造实例
- Service 负责转流量
- Ingress 负责外部入口

---

### 第三步：理解 K8s 配置和 Nacos 配置中心的分工

然后看：

- [K8s中ConfigMap、Secret、Nacos配置中心关系说明.md](D:/mywork/techdoc/saas/K8s中ConfigMap、Secret、Nacos配置中心关系说明.md)

这篇解决的问题：

- `ConfigMap` 和 `Secret` 是什么
- `Nacos Config` 是什么
- 它们各自适合放什么配置
- 为什么 Nacos 更适合动态刷新

重点结论：

- `ConfigMap` = 普通配置
- `Secret` = 敏感配置
- `Nacos` = 应用配置中心 + 动态刷新

---

### 第四步：理解组合架构

再看总览：

- [K8s、SpringBoot、Nacos、RocketMQ推荐组合架构图.md](D:/mywork/techdoc/saas/K8s、SpringBoot、Nacos、RocketMQ推荐组合架构图.md)

这篇解决的问题：

- K8s、Spring Boot、Nacos、RocketMQ 各自做什么
- K8s 服务发现和 Nacos 服务发现的区别
- 请求链路、配置链路、消息链路总图

重点结论：

- K8s 管运行与入口
- Nacos 管配置
- RocketMQ 管异步消息
- Spring Boot 管业务

---

### 第五步：最后看 RocketMQ 细节

最后看：

- [RocketMQ消息中间件.md](D:/mywork/techdoc/saas/RocketMQ消息中间件.md)

这篇解决的问题：

- RocketMQ 核心角色
- Topic、Tag、Consumer Group
- 同步、异步、单向、延时、事务消息
- `msgId`、`msgKey`、`QueueOffset`
- Dashboard 字段说明
- 本地 Docker 部署常见坑

重点结论：

- `msgKey` 不是 RocketMQ 自动去重键
- `CONSUMED` 展示要结合 Consumer Group 理解
- Windows + Docker 下 `brokerIP1` 配置很关键

---

## 三、按问题查文档

### 如果你在问“为什么访问不到服务”

先看：

- [K8s端口暴露方式与NodePort、hostPort区别说明.md](D:/mywork/techdoc/saas/K8s端口暴露方式与NodePort、hostPort区别说明.md)
- [K8s中Ingress、Service、Deployment、Pod关系图解.md](D:/mywork/techdoc/saas/K8s中Ingress、Service、Deployment、Pod关系图解.md)

---

### 如果你在问“服务之间怎么互相找到”

先看：

- [K8s、SpringBoot、Nacos、RocketMQ推荐组合架构图.md](D:/mywork/techdoc/saas/K8s、SpringBoot、Nacos、RocketMQ推荐组合架构图.md)

重点关注：

- K8s 服务发现
- Nacos 服务发现
- 两者实现区别

---

### 如果你在问“配置到底放哪里”

先看：

- [K8s中ConfigMap、Secret、Nacos配置中心关系说明.md](D:/mywork/techdoc/saas/K8s中ConfigMap、Secret、Nacos配置中心关系说明.md)

---

### 如果你在问“消息为什么显示已消费”

先看：

- [RocketMQ消息中间件.md](D:/mywork/techdoc/saas/RocketMQ消息中间件.md)

重点关注：

- `msgId`、`msgKey`、`QueueOffset`
- Dashboard 为什么显示 `CONSUMED`

---

### 如果你在问“为什么 Topic 没路由 / Broker 连不上”

先看：

- [RocketMQ消息中间件.md](D:/mywork/techdoc/saas/RocketMQ消息中间件.md)

重点关注：

- `brokerIP1`
- `No route info of this topic`
- Docker 本地部署常见坑

---

## 四、推荐记忆版

你可以把整套东西缩成下面这几句：

```text
K8s 管运行和流量入口
Service / Ingress 管访问路径
ConfigMap / Secret 管启动配置
Nacos 管应用配置和动态刷新
RocketMQ 管异步消息
Spring Boot 负责具体业务逻辑
```

---

## 五、建议的下一步

如果继续补文档，最适合的方向是：

1. Spring Boot + K8s + Nacos Config 最小实践
2. Spring Boot + RocketMQ 消息发送和消费完整示例
3. Nacos 配置刷新和 `@RefreshScope` 专题说明
4. RocketMQ 延时消息、事务消息的业务案例图解
