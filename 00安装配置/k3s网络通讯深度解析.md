# K3s 网络通信原理与排障指南

> **文档边界：**本文说明当前 K3s 网络原理、服务暴露方式和排障方法。实际 namespace、端口和 Helm 参数以 `VMware+K8s安装配置.md`、各 `k3s-*-values.yaml` 以及部署后的 `kubectl get svc -A` 为准。

本文用于在安装和重装 Jenkins、Nexus、Harbor、Rancher、Nacos、MySQL 时统一判断流量经过的 Kubernetes 网络层，并提供可重复的逐层验证命令。

---

## 一、适用范围与当前基线

当前个人开发基线使用单节点 K3s，Jenkins、Nexus、Harbor、Rancher、Nacos 和 MySQL 通过固定 NodePort 暴露；Harbor 和 Rancher 使用 HTTPS 入口。Traefik、ServiceLB 和 Ingress 不在当前安装范围内。

网络配置和验收必须同时覆盖：

1. Service 的 `port`、`targetPort` 和 `nodePort` 映射；
2. Pod、Service、EndpointSlice 和 kube-proxy 的完整链路；
3. CoreDNS 的集群内解析边界；
4. HTTP 到 HTTPS 的重定向与证书行为；
5. 节点防火墙、浏览器代理和物理网络可达性。

**根本原因：对 K8s 网络分层理解模糊，不知道数据包从浏览器到 Pod 经历了什么。**

---

## 二、K8s 网络分层模型

```
浏览器
  ↓
节点网卡 (192.168.253.128)
  ↓
kube-proxy (iptables/ipvs)
  ↓
Service (ClusterIP / NodePort)
  ↓
Pod (容器端口)
  ↓
应用进程
```

每一层都有自己的端口概念，**搞混了就会出问题**。

---

## 三、三种 Service 类型

### 1. ClusterIP（默认）

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  type: ClusterIP
  ports:
  - port: 80          # Service 端口
    targetPort: 8080  # Pod 端口
  selector:
    app: my-app
```

**网络拓扑**：

```
集群外部 ──✗──> ClusterIP (10.x.x.x:80) ──> Pod (10.42.x.x:8080)
```

- ClusterIP 是虚拟 IP，**只有集群内部能访问**
- 外部无法直接访问
- 适合：后端服务间通信

### 2. NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-svc
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080   # 节点端口 (30000-32767)
  selector:
    app: my-app
```

**网络拓扑**：

```
浏览器 ──> 节点IP:30080 ──> kube-proxy ──> Service:80 ──> Pod:8080
```

- 在每个节点上开一个端口（30000-32767）
- 访问任意节点的这个端口都能到达 Pod
- **kube-proxy 负责把节点端口转发到 ClusterIP**
- 适合：开发测试、裸机暴露服务

### 3. Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: myapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-svc
            port:
              number: 80
  tls:
  - hosts:
    - myapp.local
    secretName: myapp-tls
```

**网络拓扑**：

```
浏览器 ──> 节点IP:443 ──> Traefik Pod ──> 匹配 host ──> Service:80 ──> Pod:8080
```

- Ingress Controller（Traefik/Nginx）终结 TLS
- 按 host 头路由到不同 Service
- **80 自动跳 443**
- 适合：生产环境、多服务共享 80/443

---

## 四、kube-proxy 的工作原理

kube-proxy 是 K8s 网络的**核心组件**，负责 Service 的实现。

### iptables 模式（K3s 默认）

```bash
# 查看 NodePort 规则
iptables -t nat -L -n | grep 30080
```

**数据包流程**：

```
1. 数据包到达节点 192.168.253.128:30080
2. iptables PREROUTING 链匹配 DNAT 规则
3. 目标地址改为 ClusterIP (10.43.x.x:80)
4. 负载均衡选一个 Pod IP (10.42.x.x:8080)
5. 目标地址改为 Pod IP
6. 转发到 Pod
```

**关键理解**：

- NodePort 不是某个进程监听，而是 iptables 规则
- 所有节点都有相同的 iptables 规则
- 访问任意节点的 30080 都能到达 Pod

### ipvs 模式

```bash
# 查看 ipvs 规则
ipvsadm -Ln
```

- 用 Linux IP Virtual Server 实现
- 性能更好，支持更多 Service
- K3s 默认用 iptables

---

## 五、Pod 网络（CNI）

K3s 默认用 **Flannel** 作为 CNI 插件。

### Flannel 网络拓扑

```
节点1 (192.168.253.128)
├── flannel.1 (10.42.0.0/24)
├── cni0 (10.42.0.1/24)
└── Pod1 (10.42.0.10)
    Pod2 (10.42.0.11)
    ...

节点2 (如果有)
├── flannel.1 (10.42.1.0/24)
├── cni0 (10.42.1.1/24)
└── Pod3 (10.42.1.10)
```

**关键概念**：

| 网络 | CIDR | 说明 |
|---|---|---|
| 服务网络 | 10.43.0.0/16 | ClusterIP 范围 |
| Pod 网络 | 10.42.0.0/16 | 每个节点 /24 |
| 节点网络 | 192.168.253.0/24 | 物理网络 |

**跨节点通信**：

```
Pod1 (节点1, 10.42.0.10)
  ↓
flannel.1 (VXLAN 隧道)
  ↓
节点2 (192.168.253.129)
  ↓
Pod3 (10.42.1.10)
```

Flannel 用 VXLAN 封装，把 Pod 包封装在 UDP 包里跨节点传输。

---

## 六、CoreDNS

K3s 内置 CoreDNS，负责集群内 DNS 解析。

### Service DNS 格式

```
<service>.<namespace>.svc.cluster.local
```

示例：

| Service | DNS 名称 |
|---|---|
| jenkins (namespace: jenkins) | jenkins.jenkins.svc.cluster.local |
| harbor-core (namespace: harbor) | harbor-core.harbor.svc.cluster.local |

### 集群内访问

```bash
# 在 Pod 内
curl http://harbor-core.harbor.svc.cluster.local
curl http://harbor-core.harbor  # 跨 namespace 可使用 service.namespace
```

### 集群外访问

**CoreDNS 只在集群内生效**，集群外（浏览器）无法解析这些域名。

这就是为什么需要：
- NodePort：直接用 IP:Port
- Ingress：用域名 + hosts 文件

---

## 七、Traefik Ingress Controller

K3s 默认安装 Traefik 作为 Ingress Controller。

### Traefik 的网络位置

```
                    ┌─────────────────────────────┐
                    │       Traefik Pod            │
                    │   (监听 80/443 内部端口)      │
                    └──────────┬──────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
     Service:web        Service:websecure    IngressRoute
     (port 80)          (port 443)          (CRD)
            │                  │
            └──────────┬───────┘
                       │
              NodePort 32630/31158
                       │
              节点网卡 192.168.253.128
                       │
                    浏览器
```

### Traefik Service 配置

```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik
  namespace: kube-system
spec:
  type: LoadBalancer
  ports:
  - name: web
    port: 80
    nodePort: 32630
  - name: websecure
    port: 443
    nodePort: 31158
  selector:
    app.kubernetes.io/name: traefik
```

**关键理解**：

- Traefik 本身也是 Pod，通过 Service 暴露
- K3s 用 `svc-controller` 把 LoadBalancer 的 ExternalIP 设为节点 IP
- 浏览器访问 `192.168.253.128:80` → Traefik → 匹配 Ingress → 转发到后端 Service

### Ingress 路由匹配

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: harbor-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: harbor.local          # 按 host 头匹配
    http:
      paths:
      - path: /                 # 按路径匹配
        pathType: Prefix
        backend:
          service:
            name: harbor-core   # 转发到 Service
            port:
              number: 80
```

**匹配优先级**：

1. 精确 host + 精确 path
2. 精确 host + 前缀 path
3. 通配 host + 精确 path
4. 通配 host + 前缀 path
5. 默认 backend（404）

---

## 八、Harbor 网络拓扑详解

### NodePort + TLS 链路

```
浏览器
  │
  ├─ http://192.168.253.128:30082
  │       │
  │       ↓
  │   kube-proxy (iptables DNAT)
  │       │
  │       ↓
  │   Service harbor (NodePort: 30082 -> Service 80)
  │       │
  │       ↓
  │   Pod harbor-nginx (target 8080)
  │       │
  │       ↓
  │   nginx 8080 server block:
  │   return 301 https://$host$request_uri
  │       │
  │       ↓
  │   跳到 https://192.168.253.128/  ← 问题：不带端口！
  │
  └─ https://192.168.253.128:30083
          │
          ↓
      kube-proxy
          │
          ↓
      Service harbor (NodePort: 30083 -> Service 443)
          │
          ↓
      Pod harbor-nginx (target 8443)
          │
          ↓
      nginx 8443 ssl server block:
      服务 Harbor UI ✅
```

### HTTP 到 HTTPS 重定向行为

nginx 配置：

```nginx
server {
    listen 8080;
    return 301 https://$host$request_uri;  # ← 硬编码，不带端口
}
```

`$host` 是请求里的 Host 头。当前 HTTP NodePort 是 30082，HTTPS NodePort 是 30083；通过 HTTP 30082 访问时，重定向地址可能继续携带 30082，而该端口只提供 HTTP，因此开发环境应直接访问 `https://192.168.253.128:30083`。

该重定向由 Harbor chart 模板生成，没有对应 values 字段时不得通过猜测参数修改。

---

## 九、Jenkins、Nexus 与 Harbor 暴露方式对比

### Jenkins

```
浏览器 ──> 192.168.253.128:30080 ──> Service jenkins:80 ──> Pod jenkins:8080
```

- Jenkins chart 的 Service 字段是 `controller.serviceType=NodePort`
- 单一端口，没有 http→https 跳转
- 直接服务，没有 nginx 重定向

### Nexus

```
浏览器 ──> 192.168.253.128:30081 ──> Service nexus:8081 ──> Pod nexus:8081
```

- Nexus chart 的 Service 字段是 `service.type=NodePort`
- 单一端口，没有 http→https 跳转
- 直接服务

### Harbor

```
浏览器 ──> 192.168.253.128:30083 ──> Service harbor:443 ──> Pod nginx:8443
                                                              │
                                                              ↓
                                                        Harbor HTTPS UI/API
```

- Harbor chart 的 Service 字段是 `expose.type=nodePort`
- **多了一层 nginx 反向代理**
- nginx 默认开启 http→https 跳转；HTTP 30082 仅作为跳转入口
- 开发环境固定使用 HTTPS 30083，避免 HTTP NodePort 重定向端口不一致

**根本差异**：Jenkins/Nexus 是单端口直连，Harbor 是 nginx 反向代理 + 双端口 + 强制跳转。

---

## 十、Ingress 模式下的 Harbor

```
浏览器
  │
  ├─ https://harbor.local
  │       │
  │       ↓
  │   物理机 hosts: 192.168.253.128 harbor.local
  │       │
  │       ↓
  │   节点 192.168.253.128:443
  │       │
  │       ↓
  │   Traefik Service (NodePort 31158)
  │       │
  │       ↓
  │   Traefik Pod
  │       │
  │       ↓
  │   匹配 Ingress: host=harbor.local
  │       │
  │       ↓
  │   Service harbor-core:80 (ClusterIP)
  │       │
  │       ↓
  │   Pod harbor-core (10.42.x.x:80)
  │       │
  │       ↓
  │   Harbor API 服务
  │
  └─ http://harbor.local (80)
          │
          ↓
      Traefik 自动 308 → 443 (ssl-redirect)
```

**Ingress 模式的优势**：

1. Traefik 终结 TLS，harbor nginx 不需要处理 HTTPS
2. 80→443 跳转由 Traefik 处理，它知道正确的端口
3. 多服务共享 80/443，按 host 路由
4. 证书统一管理

---

## 十一、网络排查方法论

### 从外到内逐层排查

```
第1层：浏览器能解析域名吗？
  → nslookup harbor.local
  → 检查 hosts / DNS

第2层：端口能连通吗？
  → curl -vk https://192.168.253.128:30083
  → 检查防火墙 / 安全组

第3层：节点上能访问吗？
  → 在节点上 curl -k https://127.0.0.1:30083
  → 检查 kube-proxy / iptables

第4层：Service 有 endpoints 吗？
  → kubectl get endpoints harbor -n harbor
  → 检查 Pod 标签 / Service selector

第5层：Pod 里应用正常吗？
  → kubectl exec -n harbor -it <harbor-nginx-pod> -- curl localhost:8080
  → 检查应用日志

第6层：Pod 网络通吗？
  → kubectl exec -n <namespace> -it <pod> -- ping <其他 Pod IP>
  → 检查 CNI / Flannel
```

### 常用排查命令

```bash
# 查看 Service
kubectl get svc -n <namespace>
kubectl describe svc <svc-name> -n <namespace>

# 查看 Endpoints
kubectl get endpoints -n <namespace>

# 查看 Pod
kubectl get pod -n <namespace> -o wide

# 查看 Ingress
kubectl get ingress -n <namespace>

# 查看 Pod 日志
kubectl logs -n <namespace> <pod-name>

# 进入 Pod 调试
kubectl exec -n <namespace> -it <pod-name> -- /bin/sh

# 查看 iptables 规则（节点上）
iptables -t nat -L -n | grep <node-port>

# 查看 Traefik 路由
kubectl get ingressroute -A
kubectl get ingress -A
```

---

## 十二、配置与排障规则

### 1. Helm 字段必须与 Chart 一致

```bash
--set expose.nodePort.ports.http.nodePort=30082 \
--set expose.nodePort.ports.https.nodePort=30083
```

Helm 可能忽略未知字段。安装前检查官方 values 和模板，安装后执行 `helm get values <release>` 确认实际生效值。

### 2. 先检查实际资源

排障第一步执行 `kubectl get svc -n <product-namespace>` 查看实际端口，不根据记忆猜测。

实际资源、当前 values 和本文档必须一致；不一致时停止安装并定位配置来源。

### 3. 识别 Chart 模板约束

Harbor chart 的 nginx 配置 `return 301 https://$host$request_uri` 是硬编码，没有 values 字段能改。

不是所有配置都能通过 values 修改。缺少受支持参数时必须检查 Chart 模板和版本，不得伪造 values 字段。

### 4. 不在 Helm 资源上保留手工补丁

手动 `kubectl patch cm` 改 nginx 配置，下次 `helm upgrade` 会被 chart 模板覆盖。

Helm 或 GitOps 管理的资源必须通过 values、Chart 或受控 Overlay 修改，不能依赖下一次发布会覆盖的手工状态。

### 5. 区分集群网络与客户端代理

节点和物理机的 curl 正常但浏览器结果不一致时，应检查浏览器代理、插件、VPN、缓存和证书信任。

必须分别从节点、物理机和浏览器验证，不能用单一客户端结果代替完整链路验收。

### 6. 明确 NodePort 适用边界

Harbor 官方推荐 `expose.type=ingress`，NodePort 是简化方案。

当前单节点个人环境使用 NodePort；生产环境应根据入口网关、域名、TLS、负载均衡和高可用要求单独设计。

---

## 十三、最佳实践

### 1. 服务暴露方式选择

| 场景 | 推荐方式 |
|---|---|
| 开发测试 | NodePort |
| 生产环境 | Ingress + 域名 |
| 单服务快速暴露 | NodePort |
| 多服务共享 80/443 | Ingress |

### 2. 端口规划

| 端口 | 用途 |
|---|---|
| 80/443 | Ingress Controller（Traefik） |
| 30080 | Jenkins |
| 30081 | Nexus |
| 30082 | Harbor HTTP（仅用于跳转） |
| 30083 | Harbor HTTPS（NodePort） |

### 3. 部署前检查清单

```bash
# 1. 节点资源
kubectl describe node | grep -A 5 "Capacity:"

# 2. 存储类
kubectl get sc

# 3. Ingress Class
kubectl get ingressclass

# 4. 已用端口
kubectl get svc -A | grep NodePort

# 5. 已用存储
kubectl get pvc -A
```

### 4. 部署后验证

```bash
# 1. Pod 状态
kubectl get pods -n <namespace>

# 2. Service 端口
kubectl get svc -n <namespace>

# 3. Endpoints
kubectl get endpoints -n <namespace>

# 4. 节点上 curl
curl http://127.0.0.1:<node-port>

# 5. 物理机 curl
curl http://<node-ip>:<node-port>

# 6. 浏览器访问
# 如果浏览器和 curl 结果不同，检查浏览器代理
```

---

## 十四、总结

K8s 网络的核心是**分层**：

```
应用层（nginx 301 跳转）
  ↓
Pod 层（容器端口）
  ↓
Service 层（ClusterIP / NodePort）
  ↓
kube-proxy 层（iptables/ipvs）
  ↓
CNI 层（Flannel VXLAN）
  ↓
物理网络（节点网卡）
```

每一层都可能出问题，**逐层排查**是根本方法。

排障时必须确认以下五个关键点：

1. NodePort 由 kube-proxy 规则实现，不等同于节点进程直接监听；
2. Service 的 `port`、`targetPort`、`nodePort` 含义和映射必须一致；
3. Ingress 按 host 和 path 路由，使用裸 IP 时必须确认是否存在匹配规则；
4. Chart 模板未暴露的配置不能通过虚构 values 字段修改；
5. 浏览器代理、插件和 VPN 可能改变内网访问结果。

执行顺序固定为：先查看实际资源，再沿 Pod、Service、kube-proxy、节点网络和客户端逐层验证。
