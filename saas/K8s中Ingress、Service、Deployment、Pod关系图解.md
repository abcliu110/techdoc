# K8s 中 Ingress、Service、Deployment、Pod 关系图解

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、先说结论

在 Kubernetes 中，这几个对象的职责可以一句话概括为：

- `Deployment`：负责创建和维护 Pod 副本
- `Pod`：真正运行应用容器
- `Service`：为一组 Pod 提供统一访问入口
- `Ingress`：为集群外部流量提供域名和路径路由入口

可以记成：

```text
Deployment 负责造实例
Pod 负责跑程序
Service 负责转流量
Ingress 负责接外部请求
```

---

## 二、整体关系图

```text
浏览器 / 外部系统
        |
        | 访问域名
        | https://api.xxx.com/order/query
        v
+---------------------------+
| Ingress                   |
|---------------------------|
| host: api.xxx.com         |
| path: /order              |
+-------------+-------------+
              |
              | 按规则转发
              v
+---------------------------+
| Service                   |
| name: order-service       |
| type: ClusterIP           |
| port: 80                  |
| targetPort: 8080          |
| selector:                 |
|   app: order-service      |
+-------------+-------------+
              |
              | 根据 selector 选中 Pod
              v
    +---------+---------+---------+
    |                   |         |
    v                   v         v
+-----------+     +-----------+   +-----------+
| Pod 1     |     | Pod 2     |   | Pod 3     |
|-----------|     |-----------|   |-----------|
| label:    |     | label:    |   | label:    |
| app=order |     | app=order |   | app=order |
|           |     |           |   |           |
| container |     | container |   | container |
| 8080      |     | 8080      |   | 8080      |
+-----------+     +-----------+   +-----------+
```

---

## 三、Deployment 做什么

`Deployment` 的核心职责是：

- 指定要跑多少个 Pod 副本
- 负责滚动更新
- Pod 挂了之后自动补起来

示例：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
        - name: order-service
          image: order-service:latest
          ports:
            - containerPort: 8080
```

这段配置可以翻译成：

```text
创建一个名为 order-service 的 Deployment，
始终保持 3 个 Pod 副本，
这些 Pod 都带 app=order-service 标签，
容器内部监听 8080 端口。
```

---

## 四、Pod 做什么

`Pod` 是 K8s 中最小的运行单元。

Pod 的职责是：

- 真正运行容器
- 承载你的 Spring Boot、Node.js、Go、Python 应用

在上面的例子里：

- `Pod 1`
- `Pod 2`
- `Pod 3`

这 3 个 Pod 都是由 Deployment 创建出来的实例。

---

## 五、Service 做什么

`Service` 的职责是：

- 给一组 Pod 提供统一访问入口
- 按标签选中后端 Pod
- 把请求转发到这些 Pod

示例：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
spec:
  selector:
    app: order-service
  ports:
    - port: 80
      targetPort: 8080
```

含义：

- 访问 `order-service:80`
- Service 会把流量转发到后端 Pod 的 `8080`

注意：

- Service 不创建 Pod
- Service 只负责“选 Pod”和“转流量”

---

## 六、Deployment 和 Service 是怎么关联的

它们不是靠名字直接关联，而是靠：

- Pod 的 `labels`
- Service 的 `selector`

### Deployment 给 Pod 打标签

```yaml
template:
  metadata:
    labels:
      app: order-service
```

### Service 用 selector 选 Pod

```yaml
selector:
  app: order-service
```

只要两边一致，Service 就能找到 Deployment 创建出来的 Pod。

图示如下：

```text
Deployment
   |
   | 创建 Pod
   v
Pod
labels:
  app: order-service

Service
selector:
  app: order-service
```

可以记成：

```text
Deployment 负责给 Pod 打标签
Service 负责按标签找 Pod
```

---

## 七、Ingress 做什么

`Ingress` 的职责是：

- 处理集群外部的 HTTP / HTTPS 请求
- 根据域名和路径把请求转发给对应的 Service

示例：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gateway
spec:
  rules:
    - host: api.xxx.com
      http:
        paths:
          - path: /order
            pathType: Prefix
            backend:
              service:
                name: order-service
                port:
                  number: 80
```

含义：

- 访问 `https://api.xxx.com/order`
- Ingress 会把请求转发给 `order-service:80`

再由 Service 转发给后端 Pod。

---

## 八、完整请求流转图

```text
浏览器请求
https://api.xxx.com/order/query
        |
        v
Ingress
  host = api.xxx.com
  path = /order
        |
        v
Service: order-service:80
        |
        v
Pod: order-service
        |
        v
Spring Boot Controller
```

如果不用 Ingress，只在集群内部调用，则路径会简化成：

```text
另一个 Pod
   |
   v
http://order-service:80
   |
   v
Service
   |
   v
Pod
```

---

## 九、四者的职责对比表

| 对象 | 核心职责 | 关注点 |
|------|----------|--------|
| Deployment | 管理副本、更新、恢复 | 跑几个 Pod、镜像是什么 |
| Pod | 真正运行应用 | 应用容器、端口、进程 |
| Service | 提供统一入口、负载转发 | 选中哪些 Pod、暴露哪个端口 |
| Ingress | 处理外部 HTTP/HTTPS 入口 | 域名、路径、转发规则 |

---

## 十、最常见误区

### 误区一：Service 会创建 Pod

错误。

正确理解：

- Deployment 创建 Pod
- Service 只选择 Pod

### 误区二：Deployment 和 Service 靠名字关联

错误。

正确理解：

- 它们靠 `labels / selector` 关联

### 误区三：Ingress 直接转发到 Pod

通常不是。

正确理解：

- Ingress 先转发到 Service
- 再由 Service 转发到 Pod

---

## 十一、一句话总结

你可以这样记：

```text
Ingress 负责入口
Service 负责转发
Deployment 负责副本
Pod 负责运行
应用负责业务
```

如果理解成一条链路，就是：

```text
外部请求 -> Ingress -> Service -> Pod -> Spring Boot 应用
```
