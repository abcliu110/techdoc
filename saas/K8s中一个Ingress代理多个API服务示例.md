# K8s 中一个 Ingress 代理多个 API 服务示例

> 文档路径：`D:\mywork\techdoc\saas`
> 最后更新：2026-05-03

---

## 一、场景说明

假设现在有 3 个 Spring Boot API 服务：

- `order-service`
- `user-service`
- `pay-service`

希望对外统一使用一个域名：

```text
api.demo.com
```

并通过不同路径转发到不同服务：

- `/order/**` -> `order-service`
- `/user/**` -> `user-service`
- `/pay/**` -> `pay-service`

这就是“一个 Ingress 代理多个 API 服务”的典型场景。

---

## 二、整体流转图

```text
浏览器 / 小程序 / 前端
        |
        | http://api.demo.com/order/create
        | http://api.demo.com/user/get
        | http://api.demo.com/pay/refund
        v
+-----------------------------+
| Ingress                     |
| host: api.demo.com          |
|-----------------------------|
| /order -> order-service     |
| /user  -> user-service      |
| /pay   -> pay-service       |
+--------------+--------------+
               |
               v
      +--------+--------+--------+
      |                 |        |
      v                 v        v
 order-service     user-service  pay-service
      |                 |        |
      v                 v        v
     Pod               Pod      Pod
```

---

## 三、最基础的 Ingress 配置

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  namespace: default
spec:
  ingressClassName: nginx
  rules:
    - host: api.demo.com
      http:
        paths:
          - path: /order
            pathType: Prefix
            backend:
              service:
                name: order-service
                port:
                  number: 80
          - path: /user
            pathType: Prefix
            backend:
              service:
                name: user-service
                port:
                  number: 80
          - path: /pay
            pathType: Prefix
            backend:
              service:
                name: pay-service
                port:
                  number: 80
```

---

## 四、这段 Ingress 的含义

### `apiVersion: networking.k8s.io/v1`

表示这是 Kubernetes 中 Ingress 资源使用的 API 版本。

### `kind: Ingress`

表示要创建的是一个 Ingress 入口规则对象。

### `metadata.name: api-gateway-ingress`

表示这个 Ingress 资源自己的名字。

### `namespace: default`

表示这个 Ingress 所在命名空间是 `default`。

### `ingressClassName: nginx`

表示这条 Ingress 规则交给 `nginx ingress controller` 来执行。

### `host: api.demo.com`

表示只有请求域名是：

```text
api.demo.com
```

时才匹配这组规则。

### `path: /order`

表示路径以 `/order` 开头的请求，会进入这条规则。

### `backend.service.name: order-service`

表示匹配到 `/order` 之后，请求会转发给：

```text
Service: order-service
```

### `backend.service.port.number: 80`

表示转发给这个 Service 的 80 端口。

---

## 五、对应的 Service 配置

Ingress 不直接转发到 Pod，而是先转发到 Service。

所以后端至少要有对应 Service。

### 5.1 order-service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: default
spec:
  selector:
    app: order-service
  ports:
    - port: 80
      targetPort: 8080
```

### 5.2 user-service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: default
spec:
  selector:
    app: user-service
  ports:
    - port: 80
      targetPort: 8080
```

### 5.3 pay-service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: pay-service
  namespace: default
spec:
  selector:
    app: pay-service
  ports:
    - port: 80
      targetPort: 8080
```

---

## 六、请求最终怎么走

### 请求一

```text
http://api.demo.com/order/create
```

流转：

```text
Ingress -> order-service:80 -> Pod:8080
```

### 请求二

```text
http://api.demo.com/user/get
```

流转：

```text
Ingress -> user-service:80 -> Pod:8080
```

### 请求三

```text
http://api.demo.com/pay/refund
```

流转：

```text
Ingress -> pay-service:80 -> Pod:8080
```

---

## 七、如果 Spring Boot 应用有自己的 context-path

如果后端接口不是直接：

```text
/create
```

而是：

```text
/api/order/create
```

那单纯按 `/order` 转发可能不够，通常还需要路径重写。

例如 NGINX Ingress 常见写法：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
    - host: api.demo.com
      http:
        paths:
          - path: /order(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: order-service
                port:
                  number: 80
          - path: /user(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: user-service
                port:
                  number: 80
          - path: /pay(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: pay-service
                port:
                  number: 80
```

这类写法的意思是：

- `/order/create` 可以重写成 `/create`
- `/user/get` 可以重写成 `/get`

是否需要重写，要看你的后端接口路径设计。

---

## 八、HTTPS 示例

如果你希望通过 HTTPS 暴露：

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - api.demo.com
      secretName: api-demo-tls
  rules:
    - host: api.demo.com
      http:
        paths:
          - path: /order
            pathType: Prefix
            backend:
              service:
                name: order-service
                port:
                  number: 80
          - path: /user
            pathType: Prefix
            backend:
              service:
                name: user-service
                port:
                  number: 80
          - path: /pay
            pathType: Prefix
            backend:
              service:
                name: pay-service
                port:
                  number: 80
```

这里的：

```yaml
secretName: api-demo-tls
```

表示 HTTPS 证书所在的 Secret 名称。

---

## 九、想让这份 Ingress 生效，需要满足什么条件

必须满足以下前提：

1. 集群里已经安装了 Ingress Controller  
   例如：
   - `nginx ingress controller`
   - `traefik`
   - `kong ingress controller`

2. `ingressClassName` 要和控制器一致  
   例如：

```yaml
ingressClassName: nginx
```

3. 后端 `Service` 已经存在

4. `Service` 后面的 Pod 是健康的

5. 域名 `api.demo.com` 已经正确解析到 Ingress 暴露的入口地址

---

## 十、常见误区

### 误区一：Ingress 直接转发到 Pod

不准确。

更准确的说法是：

```text
Ingress -> Service -> Pod
```

### 误区二：Ingress 可以不用 Service 名

错误。

在 `backend` 中必须明确指定：

- `service.name`
- `service.port.number`

例如：

```yaml
backend:
  service:
    name: order-service
    port:
      number: 80
```

### 误区三：一个 Ingress 只能代理一个服务

错误。

一个 Ingress 完全可以代理多个服务，只要：

- host 不同
- 或 path 不同

就可以分流。

---

## 十一、一句话总结

一个 Ingress 代理多个 API 服务，本质上就是：

```text
同一个域名
按不同 path
转发给不同 Service
```

例如：

```text
/order -> order-service
/user  -> user-service
/pay   -> pay-service
```
