# kubectl 详解：工作原理与常用操作

## 一、kubectl 是什么？

kubectl 是 Kubernetes 的命令行工具，用于与 Kubernetes 集群进行交互。它通过 Kubernetes API Server 来管理集群资源。

### 架构图

```
┌─────────────┐
│   kubectl   │  (命令行工具)
└──────┬──────┘
       │ HTTPS/REST API
       ↓
┌─────────────────────┐
│   API Server        │  (集群入口)
└──────┬──────────────┘
       │
       ├─→ etcd (存储集群状态)
       ├─→ Scheduler (调度 Pod)
       ├─→ Controller Manager (管理控制器)
       └─→ kubelet (节点代理，管理容器)
```

### kubectl 工作流程

1. **读取配置**：kubectl 从 `~/.kube/config` 读取集群连接信息
2. **构建请求**：将命令转换为 REST API 请求
3. **发送请求**：通过 HTTPS 发送到 API Server
4. **认证授权**：API Server 验证身份和权限
5. **执行操作**：API Server 调用相应的控制器执行操作
6. **返回结果**：将结果返回给 kubectl 并显示

## 二、kubectl 配置文件

### kubeconfig 文件结构

```yaml
# ~/.kube/config
apiVersion: v1
kind: Config

# 集群列表
clusters:
- cluster:
    certificate-authority-data: <base64-encoded-ca-cert>
    server: https://192.168.80.100:6443  # API Server 地址
  name: my-cluster

# 用户列表（认证信息）
users:
- name: admin
  user:
    client-certificate-data: <base64-encoded-cert>
    client-key-data: <base64-encoded-key>

# 上下文列表（集群+用户+命名空间）
contexts:
- context:
    cluster: my-cluster
    user: admin
    namespace: default
  name: my-context

# 当前使用的上下文
current-context: my-context
```

### 常用配置命令

```bash
# 查看当前配置
kubectl config view

# 查看当前上下文
kubectl config current-context

# 切换上下文
kubectl config use-context my-context

# 设置默认命名空间
kubectl config set-context --current --namespace=my-namespace
```

## 三、kubectl 核心概念

### 1. 资源（Resources）

Kubernetes 中的一切都是资源对象：


- **Pod**：最小部署单元，包含一个或多个容器
- **Deployment**：管理 Pod 的副本和更新
- **Service**：为 Pod 提供稳定的网络访问
- **ConfigMap**：存储配置数据
- **Secret**：存储敏感数据
- **Namespace**：资源隔离和组织

### 2. API 资源分组

```bash
# 查看所有 API 资源
kubectl api-resources

# 常见资源简写
po  = pods
svc = services
deploy = deployments
cm = configmaps
ns = namespaces
pv = persistentvolumes
pvc = persistentvolumeclaims
```

## 四、kubectl 命令结构

### 基本语法

```bash
kubectl [command] [TYPE] [NAME] [flags]
```

- **command**：操作类型（get, create, delete, apply 等）
- **TYPE**：资源类型（pod, service, deployment 等）
- **NAME**：资源名称
- **flags**：选项参数（-n, -o, --all 等）

### 示例

```bash
# 获取 default 命名空间的所有 Pod
kubectl get pods -n default

# 详细输出
kubectl get pods -o wide

# YAML 格式输出
kubectl get pod my-pod -o yaml
```

## 五、常用操作详解

### 1. 查看资源（get）


**工作原理**：
1. kubectl 向 API Server 发送 GET 请求
2. API Server 从 etcd 读取资源状态
3. 返回资源列表或详细信息

```bash
# 查看所有 Pod
kubectl get pods

# 查看所有命名空间的 Pod
kubectl get pods --all-namespaces
kubectl get pods -A

# 查看特定 Pod
kubectl get pod my-pod

# 持续监控（watch）
kubectl get pods -w

# 查看 Pod 详细信息
kubectl get pod my-pod -o wide
kubectl get pod my-pod -o yaml
kubectl get pod my-pod -o json

# 使用标签选择器
kubectl get pods -l app=nginx
kubectl get pods -l 'environment in (production,staging)'
```

### 2. 查看详细信息（describe）

**工作原理**：
1. 获取资源的完整定义
2. 获取相关的事件（Events）
3. 格式化输出人类可读的信息

```bash
# 查看 Pod 详细信息（包括事件）
kubectl describe pod my-pod

# 查看 Deployment 详细信息
kubectl describe deployment my-deployment

# 查看 Service 详细信息
kubectl describe service my-service
```

**describe 输出包含**：
- 基本信息（名称、命名空间、标签等）
- 状态信息（运行状态、重启次数等）
- 容器信息（镜像、端口、环境变量等）
- 事件列表（创建、调度、拉取镜像、启动等）

### 3. 创建资源（create）


**工作原理**：
1. kubectl 读取 YAML/JSON 文件或命令行参数
2. 验证资源定义的语法
3. 向 API Server 发送 POST 请求
4. API Server 验证资源定义
5. 存储到 etcd
6. 相关控制器开始工作（如 Deployment Controller 创建 ReplicaSet）

```bash
# 从文件创建
kubectl create -f deployment.yaml

# 从多个文件创建
kubectl create -f ./configs/

# 从 URL 创建
kubectl create -f https://example.com/deployment.yaml

# 命令行创建 Deployment
kubectl create deployment nginx --image=nginx:latest

# 命令行创建 Service
kubectl create service clusterip my-service --tcp=80:8080

# 创建 Namespace
kubectl create namespace my-namespace

# 创建 Secret
kubectl create secret generic my-secret --from-literal=password=123456
```

### 4. 应用配置（apply）

**工作原理**（声明式管理）：
1. kubectl 读取 YAML 文件
2. 计算当前状态与期望状态的差异
3. 向 API Server 发送 PATCH 请求
4. API Server 更新资源
5. 控制器确保实际状态与期望状态一致

**apply vs create**：
- `create`：资源不存在时创建，存在时报错（命令式）
- `apply`：资源不存在时创建，存在时更新（声明式）

```bash
# 应用配置（推荐方式）
kubectl apply -f deployment.yaml

# 应用目录下所有配置
kubectl apply -f ./configs/

# 递归应用
kubectl apply -R -f ./configs/

# 查看将要应用的变更（dry-run）
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server
```


### 5. 删除资源（delete）

**工作原理**：
1. kubectl 向 API Server 发送 DELETE 请求
2. API Server 标记资源为删除状态
3. 相关控制器开始清理工作
4. 删除依赖资源（如 Deployment 删除会级联删除 ReplicaSet 和 Pod）
5. 从 etcd 中移除资源

```bash
# 删除 Pod
kubectl delete pod my-pod

# 删除 Deployment
kubectl delete deployment my-deployment

# 从文件删除
kubectl delete -f deployment.yaml

# 删除所有 Pod
kubectl delete pods --all

# 使用标签选择器删除
kubectl delete pods -l app=nginx

# 强制删除（不等待优雅终止）
kubectl delete pod my-pod --force --grace-period=0

# 级联删除（默认行为）
kubectl delete deployment my-deployment
# 等同于
kubectl delete deployment my-deployment --cascade=foreground

# 不级联删除（保留子资源）
kubectl delete deployment my-deployment --cascade=orphan
```

### 6. 编辑资源（edit）

**工作原理**：
1. kubectl 获取资源的 YAML 定义
2. 在默认编辑器中打开（通常是 vi/vim）
3. 用户编辑并保存
4. kubectl 验证修改
5. 向 API Server 发送 PUT 请求更新资源

```bash
# 编辑 Deployment
kubectl edit deployment my-deployment

# 使用指定编辑器
KUBE_EDITOR="nano" kubectl edit deployment my-deployment

# 编辑 Service
kubectl edit service my-service
```

### 7. 更新资源（set, patch）


**set 命令**（快速更新特定字段）：

```bash
# 更新镜像
kubectl set image deployment/my-deployment nginx=nginx:1.21

# 更新多个容器的镜像
kubectl set image deployment/my-deployment \
  nginx=nginx:1.21 \
  sidecar=sidecar:2.0

# 设置资源限制
kubectl set resources deployment my-deployment \
  --limits=cpu=200m,memory=512Mi \
  --requests=cpu=100m,memory=256Mi

# 设置环境变量
kubectl set env deployment/my-deployment \
  ENV=production \
  DEBUG=false
```

**patch 命令**（部分更新）：

```bash
# JSON patch
kubectl patch deployment my-deployment -p \
  '{"spec":{"replicas":3}}'

# YAML patch
kubectl patch deployment my-deployment --type merge -p '
spec:
  replicas: 3
'

# Strategic merge patch（默认）
kubectl patch deployment my-deployment --patch-file patch.yaml
```

### 8. 扩缩容（scale）

**工作原理**：
1. kubectl 向 API Server 发送 PATCH 请求
2. 更新 Deployment/ReplicaSet 的 replicas 字段
3. ReplicaSet Controller 检测到变化
4. 创建或删除 Pod 以达到目标副本数
5. Scheduler 调度新 Pod 到节点
6. kubelet 启动或停止容器

```bash
# 扩容到 5 个副本
kubectl scale deployment my-deployment --replicas=5

# 缩容到 1 个副本
kubectl scale deployment my-deployment --replicas=1

# 根据条件扩容
kubectl scale deployment my-deployment --replicas=3 \
  --current-replicas=2

# 自动扩缩容（HPA）
kubectl autoscale deployment my-deployment \
  --min=2 --max=10 --cpu-percent=80
```


### 9. 滚动更新（rollout）

**工作原理**：
1. Deployment Controller 创建新的 ReplicaSet
2. 逐步增加新 ReplicaSet 的副本数
3. 同时减少旧 ReplicaSet 的副本数
4. 确保在更新过程中始终有足够的 Pod 运行
5. 如果新 Pod 启动失败，自动停止更新

```bash
# 查看更新状态
kubectl rollout status deployment/my-deployment

# 查看更新历史
kubectl rollout history deployment/my-deployment

# 查看特定版本的详细信息
kubectl rollout history deployment/my-deployment --revision=2

# 回滚到上一个版本
kubectl rollout undo deployment/my-deployment

# 回滚到特定版本
kubectl rollout undo deployment/my-deployment --to-revision=2

# 暂停更新
kubectl rollout pause deployment/my-deployment

# 恢复更新
kubectl rollout resume deployment/my-deployment

# 重启 Deployment（重新创建所有 Pod）
kubectl rollout restart deployment/my-deployment
```

**滚动更新策略**：

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 最多可以超出期望副本数的 Pod 数量
      maxUnavailable: 0  # 最多可以不可用的 Pod 数量
```

### 10. 查看日志（logs）

**工作原理**：
1. kubectl 向 API Server 请求日志
2. API Server 转发请求到 kubelet
3. kubelet 从容器运行时获取日志
4. 日志通过 API Server 返回给 kubectl

```bash
# 查看 Pod 日志
kubectl logs my-pod

# 查看特定容器的日志（多容器 Pod）
kubectl logs my-pod -c container-name

# 实时查看日志（follow）
kubectl logs -f my-pod

# 查看最近 100 行日志
kubectl logs my-pod --tail=100

# 查看最近 1 小时的日志
kubectl logs my-pod --since=1h

# 查看上一个容器的日志（容器重启后）
kubectl logs my-pod --previous

# 查看 Deployment 的日志
kubectl logs deployment/my-deployment

# 查看所有匹配标签的 Pod 日志
kubectl logs -l app=nginx
```


### 11. 执行命令（exec）

**工作原理**：
1. kubectl 向 API Server 发送 exec 请求
2. API Server 建立到 kubelet 的连接
3. kubelet 通过容器运行时在容器中执行命令
4. 输出通过 WebSocket 流式传输回 kubectl

```bash
# 在 Pod 中执行命令
kubectl exec my-pod -- ls /app

# 交互式 shell
kubectl exec -it my-pod -- /bin/bash
kubectl exec -it my-pod -- sh

# 在多容器 Pod 的特定容器中执行
kubectl exec -it my-pod -c container-name -- /bin/bash

# 执行多个命令
kubectl exec my-pod -- sh -c "cd /app && ls -la"

# 在 Deployment 的 Pod 中执行
kubectl exec -it deployment/my-deployment -- /bin/bash
```

### 12. 端口转发（port-forward）

**工作原理**：
1. kubectl 在本地监听指定端口
2. 建立到 API Server 的连接
3. API Server 转发到 kubelet
4. kubelet 转发到 Pod 的端口
5. 形成本地端口 → API Server → kubelet → Pod 的隧道

```bash
# 转发本地 8080 到 Pod 的 80 端口
kubectl port-forward pod/my-pod 8080:80

# 转发到 Service
kubectl port-forward service/my-service 8080:80

# 转发到 Deployment
kubectl port-forward deployment/my-deployment 8080:80

# 监听所有网络接口（默认只监听 localhost）
kubectl port-forward --address 0.0.0.0 pod/my-pod 8080:80

# 转发多个端口
kubectl port-forward pod/my-pod 8080:80 8443:443
```

**使用场景**：
- 本地调试远程 Pod
- 访问集群内部服务
- 临时测试服务连接

### 13. 复制文件（cp）

**工作原理**：
1. kubectl 使用 tar 命令打包文件
2. 通过 exec 接口传输数据
3. 在目标位置解包文件

```bash
# 从 Pod 复制文件到本地
kubectl cp my-pod:/app/config.yaml ./config.yaml

# 从本地复制文件到 Pod
kubectl cp ./config.yaml my-pod:/app/config.yaml

# 指定容器（多容器 Pod）
kubectl cp my-pod:/app/config.yaml ./config.yaml -c container-name

# 复制目录
kubectl cp my-pod:/app/logs ./logs
```


### 14. 运行临时 Pod（run）

**工作原理**：
1. kubectl 创建一个 Pod 定义
2. 向 API Server 发送创建请求
3. Scheduler 选择节点
4. kubelet 拉取镜像并启动容器

```bash
# 运行一个 nginx Pod
kubectl run nginx --image=nginx

# 运行并暴露端口
kubectl run nginx --image=nginx --port=80

# 运行临时 Pod（退出后自动删除）
kubectl run test --image=busybox --rm -it --restart=Never -- sh

# 运行并执行命令
kubectl run test --image=busybox --restart=Never -- echo "Hello"

# 设置环境变量
kubectl run nginx --image=nginx --env="ENV=production"

# 设置资源限制
kubectl run nginx --image=nginx \
  --requests='cpu=100m,memory=256Mi' \
  --limits='cpu=200m,memory=512Mi'

# 使用特定的 ServiceAccount
kubectl run nginx --image=nginx --serviceaccount=my-sa
```

## 六、高级操作

### 1. 标签和选择器

**标签（Labels）**：键值对，用于组织和选择资源

```bash
# 添加标签
kubectl label pod my-pod env=production

# 修改标签（覆盖）
kubectl label pod my-pod env=staging --overwrite

# 删除标签
kubectl label pod my-pod env-

# 查看标签
kubectl get pods --show-labels

# 使用标签选择器
kubectl get pods -l env=production
kubectl get pods -l 'env in (production,staging)'
kubectl get pods -l env!=development
kubectl get pods -l env,tier=frontend
```

### 2. 注解（Annotations）

**注解**：存储非标识性元数据

```bash
# 添加注解
kubectl annotate pod my-pod description="This is my pod"

# 删除注解
kubectl annotate pod my-pod description-

# 查看注解
kubectl describe pod my-pod | grep Annotations
```


### 3. 资源配额和限制

```bash
# 查看节点资源使用情况
kubectl top nodes

# 查看 Pod 资源使用情况
kubectl top pods

# 查看特定命名空间的 Pod 资源使用
kubectl top pods -n my-namespace

# 查看容器资源使用
kubectl top pod my-pod --containers
```

### 4. 调试和故障排查

```bash
# 查看集群信息
kubectl cluster-info

# 查看节点状态
kubectl get nodes
kubectl describe node node-name

# 查看事件
kubectl get events
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector involvedObject.name=my-pod

# 查看 API 资源
kubectl api-resources
kubectl api-versions

# 解释资源字段
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers

# 验证 YAML 文件
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml --dry-run=server --validate=true

# 查看资源的 YAML 定义
kubectl get pod my-pod -o yaml

# 比较本地文件和集群中的资源
kubectl diff -f deployment.yaml
```

### 5. 插件和扩展

```bash
# 查看可用插件
kubectl plugin list

# 使用 kubectl-debug 插件调试
kubectl debug my-pod -it --image=busybox

# 使用 kubectl-tree 查看资源树
kubectl tree deployment my-deployment
```

## 七、实战场景

### 场景 1：部署应用

```bash
# 1. 创建 Deployment
kubectl create deployment my-app --image=my-image:v1.0

# 2. 暴露服务
kubectl expose deployment my-app --port=80 --target-port=8080 --type=NodePort

# 3. 查看状态
kubectl get deployments
kubectl get pods
kubectl get services

# 4. 扩容
kubectl scale deployment my-app --replicas=3

# 5. 更新镜像
kubectl set image deployment/my-app my-app=my-image:v2.0

# 6. 查看更新状态
kubectl rollout status deployment/my-app
```


### 场景 2：故障排查

```bash
# 1. 查看 Pod 状态
kubectl get pods
# 状态可能是：Pending, Running, CrashLoopBackOff, Error, ImagePullBackOff

# 2. 查看 Pod 详细信息
kubectl describe pod my-pod
# 重点查看：Events 部分

# 3. 查看日志
kubectl logs my-pod
kubectl logs my-pod --previous  # 查看崩溃前的日志

# 4. 进入容器调试
kubectl exec -it my-pod -- /bin/bash

# 5. 查看资源使用
kubectl top pod my-pod

# 6. 检查网络连接
kubectl exec my-pod -- ping other-service
kubectl exec my-pod -- curl http://other-service
```

### 场景 3：配置管理

```bash
# 1. 创建 ConfigMap
kubectl create configmap my-config \
  --from-literal=key1=value1 \
  --from-literal=key2=value2

# 或从文件创建
kubectl create configmap my-config --from-file=config.yaml

# 2. 创建 Secret
kubectl create secret generic my-secret \
  --from-literal=password=123456

# 3. 在 Deployment 中使用
kubectl set env deployment/my-app --from=configmap/my-config
kubectl set env deployment/my-app --from=secret/my-secret

# 4. 查看配置
kubectl get configmap my-config -o yaml
kubectl get secret my-secret -o yaml
```

### 场景 4：网络调试

```bash
# 1. 创建测试 Pod
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh

# 2. 在测试 Pod 中测试连接
nslookup my-service
wget -O- http://my-service
ping my-service

# 3. 查看 Service 端点
kubectl get endpoints my-service

# 4. 端口转发测试
kubectl port-forward service/my-service 8080:80
# 然后在本地访问 http://localhost:8080
```

## 八、kubectl 工作原理深入

### 1. API 请求流程

```
kubectl 命令
    ↓
解析命令行参数
    ↓
读取 kubeconfig
    ↓
构建 HTTP 请求
    ↓
TLS 认证
    ↓
发送到 API Server
    ↓
API Server 认证（Authentication）
    ↓
API Server 授权（Authorization）
    ↓
准入控制（Admission Control）
    ↓
验证（Validation）
    ↓
持久化到 etcd
    ↓
返回响应
    ↓
kubectl 格式化输出
```


### 2. 创建 Pod 的完整流程

```
kubectl create -f pod.yaml
    ↓
API Server 接收请求
    ↓
验证 Pod 定义
    ↓
存储到 etcd
    ↓
Scheduler 监听到新 Pod
    ↓
Scheduler 选择合适的节点
    ↓
更新 Pod 的 nodeName 字段
    ↓
kubelet 监听到分配给自己的 Pod
    ↓
kubelet 调用容器运行时（containerd/CRI-O）
    ↓
拉取镜像
    ↓
创建容器
    ↓
启动容器
    ↓
kubelet 更新 Pod 状态
    ↓
API Server 更新 etcd
    ↓
kubectl get pods 显示 Running 状态
```

### 3. Service 访问原理

```
客户端请求 Service IP
    ↓
iptables/IPVS 规则拦截
    ↓
负载均衡选择后端 Pod
    ↓
DNAT 转换为 Pod IP
    ↓
请求到达 Pod
    ↓
Pod 处理请求
    ↓
响应返回
```

**Service 类型**：

1. **ClusterIP**（默认）：
   - 只能在集群内部访问
   - 分配一个虚拟 IP
   - kube-proxy 维护 iptables/IPVS 规则

2. **NodePort**：
   - 在每个节点上开放一个端口（30000-32767）
   - 外部可以通过 `<NodeIP>:<NodePort>` 访问
   - 自动创建 ClusterIP

3. **LoadBalancer**：
   - 云厂商提供的负载均衡器
   - 自动创建 NodePort 和 ClusterIP
   - 分配外部 IP

4. **ExternalName**：
   - 返回 CNAME 记录
   - 用于访问外部服务

### 4. 存储原理

**PV（PersistentVolume）和 PVC（PersistentVolumeClaim）**：

```
开发者创建 PVC
    ↓
PV Controller 寻找匹配的 PV
    ↓
绑定 PVC 和 PV
    ↓
Pod 引用 PVC
    ↓
kubelet 挂载存储到容器
```

```bash
# 查看 PV
kubectl get pv

# 查看 PVC
kubectl get pvc

# 查看 StorageClass
kubectl get storageclass
```

## 九、最佳实践

### 1. 使用声明式配置

```bash
# ✓ 推荐：使用 apply（声明式）
kubectl apply -f deployment.yaml

# ✗ 不推荐：使用 create（命令式）
kubectl create -f deployment.yaml
```

### 2. 使用命名空间隔离

```bash
# 创建命名空间
kubectl create namespace dev
kubectl create namespace prod

# 在特定命名空间操作
kubectl apply -f deployment.yaml -n dev

# 设置默认命名空间
kubectl config set-context --current --namespace=dev
```

### 3. 使用标签组织资源

```yaml
metadata:
  labels:
    app: my-app
    version: v1.0
    environment: production
    tier: frontend
```

### 4. 资源限制

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 5. 健康检查

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```


### 6. 使用 Kustomize

```bash
# 使用 kustomization.yaml
kubectl apply -k ./overlays/production/

# 查看生成的配置
kubectl kustomize ./overlays/production/
```

### 7. 使用 Helm

```bash
# 安装 Chart
helm install my-release stable/nginx

# 升级
helm upgrade my-release stable/nginx

# 回滚
helm rollback my-release 1
```

## 十、常见问题和解决方案

### 1. ImagePullBackOff

**原因**：
- 镜像不存在
- 镜像仓库认证失败
- 网络问题

**解决**：
```bash
# 查看详细错误
kubectl describe pod my-pod

# 检查镜像名称
kubectl get pod my-pod -o jsonpath='{.spec.containers[*].image}'

# 创建镜像拉取 Secret
kubectl create secret docker-registry my-secret \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass

# 在 Pod 中使用
spec:
  imagePullSecrets:
  - name: my-secret
```

### 2. CrashLoopBackOff

**原因**：
- 应用启动失败
- 配置错误
- 资源不足

**解决**：
```bash
# 查看日志
kubectl logs my-pod
kubectl logs my-pod --previous

# 查看事件
kubectl describe pod my-pod

# 进入容器调试
kubectl exec -it my-pod -- sh
```

### 3. Pending 状态

**原因**：
- 资源不足（CPU/内存）
- 节点选择器不匹配
- PVC 未绑定

**解决**：
```bash
# 查看调度失败原因
kubectl describe pod my-pod

# 查看节点资源
kubectl top nodes
kubectl describe nodes

# 查看 PVC 状态
kubectl get pvc
```

### 4. Service 无法访问

**原因**：
- 端口配置错误
- 标签选择器不匹配
- 网络策略阻止

**解决**：
```bash
# 检查 Service 配置
kubectl describe service my-service

# 检查端点
kubectl get endpoints my-service

# 检查标签匹配
kubectl get pods -l app=my-app

# 测试连接
kubectl run test --image=busybox --rm -it --restart=Never -- \
  wget -O- http://my-service
```

## 十一、kubectl 速查表

### 基础命令

```bash
kubectl version                    # 查看版本
kubectl cluster-info              # 查看集群信息
kubectl get nodes                 # 查看节点
kubectl get pods                  # 查看 Pod
kubectl get services              # 查看服务
kubectl get deployments           # 查看 Deployment
```

### 创建和删除

```bash
kubectl create -f file.yaml       # 创建资源
kubectl apply -f file.yaml        # 应用配置
kubectl delete -f file.yaml       # 删除资源
kubectl delete pod my-pod         # 删除 Pod
```

### 查看详情

```bash
kubectl describe pod my-pod       # 查看详细信息
kubectl logs my-pod               # 查看日志
kubectl logs -f my-pod            # 实时查看日志
kubectl get pod my-pod -o yaml    # YAML 格式输出
```

### 交互操作

```bash
kubectl exec -it my-pod -- bash   # 进入容器
kubectl port-forward my-pod 8080:80  # 端口转发
kubectl cp my-pod:/path ./path    # 复制文件
```

### 更新和回滚

```bash
kubectl set image deployment/my-app app=image:v2  # 更新镜像
kubectl rollout status deployment/my-app          # 查看更新状态
kubectl rollout undo deployment/my-app            # 回滚
kubectl scale deployment my-app --replicas=3      # 扩缩容
```

### 调试

```bash
kubectl top nodes                 # 节点资源使用
kubectl top pods                  # Pod 资源使用
kubectl get events                # 查看事件
kubectl describe node node-name   # 查看节点详情
```

## 十二、总结

kubectl 是 Kubernetes 的核心工具，理解其工作原理对于有效管理集群至关重要：

1. **声明式管理**：使用 `apply` 而不是 `create`
2. **资源组织**：使用命名空间和标签
3. **故障排查**：善用 `describe`、`logs`、`events`
4. **自动化**：使用 YAML 文件管理配置
5. **监控**：定期检查资源使用情况

掌握 kubectl 的各种操作和原理，能够帮助你更好地管理和维护 Kubernetes 集群。
