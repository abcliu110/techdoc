# K8s 端口暴露方式与 NodePort、hostPort 区别说明

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、先说结论

Kubernetes 里最容易混淆的几个端口字段是：

- `containerPort`
- `targetPort`
- `port`
- `nodePort`
- `hostPort`

它们不在同一层，含义也不同。

最短结论如下：

- `containerPort`：容器内部应用监听端口
- `targetPort`：Service 转发到 Pod 容器的端口
- `port`：Service 自己对外提供的逻辑端口
- `nodePort`：Node 对外暴露给集群外访问的端口，**在整个集群范围内唯一**
- `hostPort`：Pod 直接绑定宿主机端口，**在同一台节点机器上必须独占**

---

## 二、整体分层图

```text
集群外部请求
    |
    | 方式一：NodePort
    v
NodeIP:30080
    |
    v
Service
  port: 80
  targetPort: 8080
    |
    v
Pod
  containerPort: 8080
```

如果使用 `hostPort`，路径会变成：

```text
集群外部请求
    |
    v
NodeIP:8080
    |
    v
某个 Pod
  hostPort: 8080
  containerPort: 8080
```

---

## 三、每个字段分别属于哪一层

### 3.1 containerPort

`containerPort` 属于 **Pod / 容器层**。

它表示：

```text
容器里的应用监听哪个端口
```

例如 Spring Boot：

```yaml
server:
  port: 8080
```

那么 Deployment / Pod 里通常会写：

```yaml
containerPort: 8080
```

注意：

- 它不是宿主机端口
- 它不是 Service 端口
- 它只是容器内部应用监听端口

---

### 3.2 targetPort

`targetPort` 属于 **Service 到 Pod 的转发层**。

它表示：

```text
Service 收到请求后，最终打到 Pod 的哪个端口
```

例如：

```yaml
ports:
  - port: 80
    targetPort: 8080
```

意思就是：

```text
访问 Service:80
转发到 Pod:8080
```

---

### 3.3 port

`port` 属于 **Service 层**。

它表示：

```text
Service 自己提供给访问方的端口
```

例如：

```yaml
ports:
  - port: 80
    targetPort: 8080
```

说明：

- 调用方访问的是 `Service:80`
- Service 再转发到 Pod 的 `8080`

注意：

- `port` 不是宿主机进程真实独占端口
- 它是 Service 的逻辑入口端口

---

### 3.4 nodePort

`nodePort` 属于 **节点对外暴露层**。

只有 `Service type=NodePort` 时才会出现。

例如：

```yaml
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 8080
      nodePort: 30080
```

它表示：

```text
集群外部可以访问 任意一个 NodeIP:30080
```

然后流量再进入：

```text
NodeIP:30080 -> Service:80 -> Pod:8080
```

---

### 3.5 hostPort

`hostPort` 属于 **Pod 直接绑定宿主机端口层**。

例如：

```yaml
ports:
  - containerPort: 8080
    hostPort: 8080
```

它表示：

```text
宿主机 8080 直接绑定到这个 Pod 的容器 8080
```

所以它不是通过 Service 做转发，而是：

```text
NodeIP:8080 -> 某个 Pod:8080
```

---

## 四、NodePort 和 hostPort 的核心区别

### 4.1 NodePort 是全集群统一入口

`NodePort` 的核心特点是：

```text
同一个 nodePort 会在所有 Node 上统一生效
```

例如：

```yaml
nodePort: 30080
```

那么实际效果是：

```text
Node1:30080 -> Service A
Node2:30080 -> Service A
Node3:30080 -> Service A
```

因此：

**`nodePort` 必须在整个集群范围内唯一。**

不是“某个节点唯一”，而是“整个集群唯一”。

---

### 4.2 hostPort 是单节点直接占用端口

`hostPort` 的核心特点是：

```text
Pod 直接占用所在节点机器上的真实端口
```

因此：

**同一台节点机器上，`hostPort` 必须独占。**

例如：

- Node1 上一个 Pod 占用了 `hostPort: 8080`
- 那么同一个 Node1 上，另一个 Pod 不能再占 `hostPort: 8080`

但：

- Node2 上是否还能占 `8080`
- 是另一回事

所以：

**`hostPort` 是单节点独占。**

---

## 五、图解：NodePort 和 hostPort 对比

### 5.1 NodePort

```text
外部请求
   |
   v
Node1:30080
   |
   v
Service
   |
   +------> Pod1:8080
   +------> Pod2:8080
   +------> Pod3:8080
```

或者：

```text
外部请求
   |
   v
Node2:30080
   |
   v
Service
   |
   +------> Pod1:8080
   +------> Pod2:8080
   +------> Pod3:8080
```

说明：

- 任意 Node 的同一个 `nodePort` 都指向同一个 Service
- 所以 `nodePort` 是集群级统一入口

---

### 5.2 hostPort

```text
外部请求
   |
   v
Node1:8080
   |
   v
PodA:8080
```

说明：

- 流量直接进入某个 Pod
- 没有 Service 统一负载转发
- 宿主机端口会被这个 Pod 直接占住

---

## 六、为什么 Service port 不是“宿主机独占端口”

很多人看到：

```yaml
port: 80
```

会误以为：

```text
Service 在每台节点上真实占用了 80 端口
```

这个理解不准确。

更准确的说法是：

```text
Service 定义了一个逻辑访问入口端口
```

它的作用是告诉调用方：

```text
这个 Service 对外提供哪个服务端口
```

因此：

- `ClusterIP Service` 的 `port`
- 不是宿主机进程意义上的独占端口
- 而是 Kubernetes 网络规则里的服务入口定义

---

## 七、一个 Service 有多个端口时，NodePort 怎么对应

一个 Service 完全可以暴露多个端口。

如果 `type=NodePort`，那么：

- Service 下面的每一个 `port`
- 都可以各自对应一个独立的 `nodePort`

示例：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  type: NodePort
  selector:
    app: order-service
  ports:
    - name: http
      port: 80
      targetPort: 8080
      nodePort: 30080
    - name: metrics
      port: 9090
      targetPort: 9090
      nodePort: 30090
```

这表示：

- `NodeIP:30080` -> `Service:80` -> `Pod:8080`
- `NodeIP:30090` -> `Service:9090` -> `Pod:9090`

图示如下：

```text
外部请求
   |
   +--> NodeIP:30080
   |        |
   |        v
   |   Service: order-service:80
   |        |
   |        v
   |   Pod:8080
   |
   +--> NodeIP:30090
            |
            v
       Service: order-service:9090
            |
            v
       Pod:9090
```

这里要注意：

- `NodePort` 的“集群唯一”不是说“一个 Service 只能有一个 NodePort”
- 而是说“每一个 `nodePort` 端口号在全集群范围内不能重复”

也就是说：

- 同一个 Service 可以拥有多个 `nodePort`
- 但这些 `nodePort` 每一个都必须是全集群唯一

---

## 八、常见暴露方式怎么选

### 7.1 ClusterIP

适合：

- 集群内部服务之间互相调用

特点：

- 默认类型
- 只能集群内访问

---

### 7.2 NodePort

适合：

- 测试环境临时对外暴露服务
- 简单的集群外访问

特点：

- 外部通过 `NodeIP:nodePort` 访问
- `nodePort` 在集群范围内唯一

---

### 7.3 hostPort

适合：

- 少数需要直接绑定宿主机端口的特殊场景
- 网络代理类组件
- 某些 DaemonSet 部署场景

不适合：

- 普通可横向扩容的业务服务

原因：

- 容易端口冲突
- 不适合多个副本灵活调度

---

### 7.4 Ingress

适合：

- HTTP / HTTPS 生产环境对外流量入口
- 需要域名和路径路由的场景

特点：

- 通过域名统一管理多个服务
- 比 NodePort 更适合生产环境

---

## 九、一句话总结

你可以这样记：

- `containerPort`：容器里程序真正监听的端口
- `targetPort`：Service 最终转发到容器的端口
- `port`：Service 的逻辑访问入口端口
- `nodePort`：Node 对外统一暴露的端口，**集群范围唯一**
- `hostPort`：Pod 直接占用宿主机端口，**同一节点必须独占**

最终最重要的区分是：

```text
NodePort = 集群统一入口
hostPort = 节点直接占口
```
