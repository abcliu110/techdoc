# Harbor HTTPS Helm 部署完整指南

## 重要提示

> 本文档中使用的 `YOUR_NODE_IP` 是占位符，请根据你的实际环境替换为：
> - 节点 IP 地址（例如：`192.168.80.101`）
> - 或者域名（例如：`harbor.example.com`）
>
> **端口配置：**
> - HTTP 端口：`30008`
> - HTTPS 端口：`30009`
>
> **访问地址示例：**
> - HTTP: `http://YOUR_NODE_IP:30008`
> - HTTPS: `https://YOUR_NODE_IP:30009`
>
> **关于 crictl 的重要说明：**
> - `crictl` 不能用于登录 Harbor（没有 `crictl login` 命令）
> - 在 RKE2 环境中，使用 `docker`、`nerdctl` 或 Kubernetes Secret 进行认证
> - `crictl` 仅用于查看和管理容器运行时的镜像、Pod 等

---

## 环境要求

- Kubernetes 集群（RKE2）
- kubectl 已配置
- 节点 IP: 根据实际环境填写 YOUR_NODE_IP
- StorageClass: local-path

---

## 一、安装 Helm

```bash
# 下载并安装 Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 验证安装
helm version
```

---

## 二、准备工作

### 1. 检查 StorageClass

```bash
# 查看可用的 StorageClass
kubectl get storageclass

# 应该看到 local-path
# NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
# local-path   rancher.io/local-path   Delete          WaitForFirstConsumer
```

### 2. 删除之前的部署（如果有）

> **重要**：如果 RKE2 集群中已经部署了 Harbor（HTTP 或 HTTPS 版本），必须先完全卸载，否则会导致端口冲突和 PVC 绑定问题。
>
> **说明**：`helm uninstall` 会自动删除 Harbor 的所有服务发现资源（Service、Endpoint、Pod 等），无需手动清理。

```bash
# 1. 检查是否已安装 Harbor
helm list -n harbor
kubectl get namespace harbor

# 2. 卸载 Helm Release（会自动删除所有 Service、Pod、ConfigMap 等资源）
helm uninstall harbor -n harbor 2>/dev/null || echo "Harbor Release 不存在，跳过"

# 3. 删除旧的 PVC（重要！避免 spec immutable 错误）
kubectl delete pvc -n harbor --all 2>/dev/null || echo "PVC 不存在，跳过"

# 4. 删除 TLS Secret（如果之前是 HTTPS 部署）
kubectl delete secret harbor-tls -n harbor 2>/dev/null || echo "Secret 不存在，跳过"

# 5. 删除命名空间
kubectl delete namespace harbor 2>/dev/null || true

# 6. 删除证书文件（可选）
rm -rf /tmp/harbor-cert 2>/dev/null || true

# 7. 清理其他命名空间中的 Harbor Secret（如果存在）
kubectl get secret --all-namespaces | grep harbor-registry || echo "✓ 无其他 Harbor Secret"
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
  kubectl delete secret harbor-registry-secret -n $ns 2>/dev/null || true
done

# 8. 删除 Docker 证书（如果使用 Docker 客户端，替换为你的实际地址）
sudo rm -rf /etc/docker/certs.d/YOUR_NODE_IP:30009 2>/dev/null || echo "Docker 证书目录不存在"

# 9. 删除 RKE2 中的 Harbor 配置（所有节点，如果之前配置过）
# 编辑 /etc/rancher/rke2/registries.yaml，删除 Harbor 相关配置
# 然后重启 RKE2
sudo systemctl restart rke2-server 2>/dev/null || true

# 等待清理完成
sleep 10

# 验证清理
echo "=== 验证清理结果 ==="

# 检查命名空间
kubectl get namespace harbor 2>/dev/null && echo "⚠️ Harbor 命名空间还存在" || echo "✓ Harbor 命名空间已删除"

# 检查 PVC（显示详细列表）
if kubectl get pvc -n harbor &>/dev/null; then
  echo "⚠️ 以下 PVC 还存在:"
  kubectl get pvc -n harbor
else
  echo "✓ PVC 已清理"
fi

# 检查 Secret
if kubectl get secret harbor-tls -n harbor &>/dev/null; then
  echo "⚠️ TLS Secret 还存在"
else
  echo "✓ TLS Secret 已清理"
fi
```

### 3. 添加 Harbor Helm 仓库

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```

---

## 三、生成自签名 TLS 证书

```bash
# 创建临时目录
mkdir -p /tmp/harbor-cert
cd /tmp/harbor-cert

# 生成私钥
openssl genrsa -out harbor-core.harbor.key 2048

# 生成证书签名请求
openssl req -new -key harbor-core.harbor.key -out harbor-core.harbor.csr -subj "/CN=harbor-core.harbor/O=harbor"

# 生成自签名证书（有效期 10 年）
openssl x509 -req -days 3650 -in harbor-core.harbor.csr -signkey harbor-core.harbor.key -out harbor-core.harbor.crt

# 验证证书
openssl x509 -in harbor-core.harbor.crt -text -noout
```

---

## 四、创建 TLS Secret

```bash
# 1. 创建 Harbor 命名空间（如果不存在）
kubectl create namespace harbor

# 2. 在 Harbor 命名空间创建 TLS Secret
kubectl create secret tls harbor-tls \
  --cert=harbor-core.harbor.crt \
  --key=harbor-core.harbor.key \
  -n harbor

# 3. 验证 Secret 创建成功
kubectl get secret harbor-tls -n harbor
kubectl describe secret harbor-tls -n harbor
```

---

## 五、创建 HTTPS 配置文件

### 方法1: 使用 cat 命令创建

```bash
cat > harbor-helm-values-https.yaml <<'EOF'
# Harbor Helm Chart 配置文件 - HTTPS 版本
# 适用于 RKE2 Kubernetes 集群

# ==================== 暴露配置 ====================
expose:
  type: nodePort
  tls:
    enabled: true  # ✅ 启用 HTTPS
    certSource: secret  # ✅ 使用 K8s Secret
    secret:
      secretName: "harbor-tls"  # TLS Secret 名称
      notarySecretName: "notary-tls"
  nodePort:
    name: harbor
    ports:
      http:
        nodePort: 30008  # HTTP 端口
      https:
        nodePort: 30009  # ✅ HTTPS 端口

# 外部访问地址（必须配置为外网可访问的地址）
# 根据实际情况选择以下方式：
# - 方式1: 使用节点IP + NodePort: https://192.168.80.101:30009
# - 方式2: 使用域名（需配置DNS解析）: https://harbor.example.com
externalURL: https://YOUR_NODE_IP:30009

# ==================== 持久化存储 ====================
persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "local-path"
      size: 200Gi
    database:
      storageClass: "local-path"
      size: 10Gi
    redis:
      storageClass: "local-path"
      size: 5Gi
    jobservice:
      jobLog:
        storageClass: "local-path"
        size: 1Gi
      scanDataExports:
        storageClass: "local-path"
        size: 1Gi

# ==================== 管理配置 ====================
harborAdminPassword: "Harbor12345"

# ==================== 数据库配置 ====================
database:
  type: internal  # 使用内置 PostgreSQL
  internal:
    password: "changeit"

# ==================== Redis 配置 ====================
redis:
  type: internal  # 使用内置 Redis

# ==================== 组件配置 ====================
trivy:
  enabled: false  # 漏洞扫描（可选）
notary:
  enabled: false  # 镜像签名（可选）
chartmuseum:
  enabled: false  # Helm Chart 仓库（可选）

# ==================== 资源限制 ====================
portal:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

core:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

jobservice:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

registry:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
EOF
```

### 方法2: 修改 externalURL 地址

```bash
# 使用 sed 替换地址（将 YOUR_NODE_IP 替换为实际 IP 或域名）
sed -i 's/YOUR_NODE_IP/YOUR_ACTUAL_IP_OR_DOMAIN/g' harbor-helm-values-https.yaml

# 或者手动编辑
vim harbor-helm-values-https.yaml
# 修改 externalURL 为你的实际访问地址，例如：
# externalURL: https://192.168.80.101:30009
# externalURL: https://harbor.example.com
```

### 验证配置文件

```bash
cat harbor-helm-values-https.yaml | grep -E "nodePort|externalURL"
# 确认端口和访问地址配置正确
```

**注意：** 最终的访问端口以 `harbor-helm-values-https.yaml` 文件中的配置为准。

---

## 六、部署 Harbor（HTTPS）

### 重要提示

**如果之前部署过 Harbor，必须先删除旧的 PVC：**

```bash
# 删除旧的 PVC（避免 "spec is immutable" 错误）
kubectl delete pvc harbor-jobservice harbor-registry harbor-database harbor-redis -n harbor 2>/dev/null || true

# 验证 PVC 已删除
kubectl get pvc -n harbor
# 应该显示: No resources found in harbor namespace.
```

### 部署命令

```bash
# 1. 检查端口是否被占用
netstat -tlnp | grep -E "30008|30009"
# 如果端口被占用，需要先清理或修改配置文件中的端口号

# 2. 一键部署
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-helm-values-https.yaml \
  --version 1.14.0
```

**预期输出：**
```
NAME: harbor
LAST DEPLOYED: ...
NAMESPACE: harbor
STATUS: deployed
REVISION: 1
```

---

## 七、查看部署状态

### 1. 查看 Pod 状态（等待 3-5 分钟）

```bash
kubectl get pods -n harbor -w
```

**预期输出（所有 Pod 都是 Running）：**
```
NAME                                    READY   STATUS    RESTARTS   AGE
harbor-core-xxx                         1/1     Running   0          3m
harbor-database-0                       1/1     Running   0          3m
harbor-jobservice-xxx                   1/1     Running   0          3m
harbor-nginx-xxx                        1/1     Running   0          3m
harbor-portal-xxx                       1/1     Running   0          3m
harbor-redis-0                          1/1     Running   0          3m
harbor-registry-xxx                     1/1     Running   0          3m
```

### 2. 查看所有资源

```bash
kubectl get all -n harbor
```

### 3. 查看 PVC 状态

```bash
kubectl get pvc -n harbor
```

### 4. 查看服务

```bash
kubectl get svc -n harbor
```

---

## 八、访问 Harbor

### 1. 访问 Web UI（HTTPS）

打开浏览器访问：`https://<你的节点IP或域名>:30009`

- **用户名**: `admin`
- **密码**: `Harbor12345`

### 2. 浏览器安全提示（自签名证书）

由于使用自签名证书，浏览器会显示安全警告：

- **Chrome/Edge**: 点击 "高级" → "继续前往"
- **Firefox**: 点击 "高级" → "接受风险并继续"

### 3. 首次登录

1. 输入用户名和密码登录
2. 建议修改默认密码
3. 创建项目（如：library）

---

## 九、配置 Docker 使用 Harbor

### 1. 复制 CA 证书到 Docker

```bash
# 创建证书目录（替换为你的实际IP或域名）
sudo mkdir -p /etc/docker/certs.d/YOUR_NODE_IP:30009

# 复制证书（替换为你的实际IP或域名）
sudo cp /tmp/harbor-cert/harbor-core.harbor.crt /etc/docker/certs.d/YOUR_NODE_IP:30009/ca.crt
```

### 2. 登录 Harbor

```bash
# 替换为你的实际IP或域名
docker login YOUR_NODE_IP:30009
# 用户名: admin
# 密码: Harbor12345
```

### 3. 测试推送镜像

**Docker 客户端测试：**

```bash
# 标记镜像（替换为你的实际IP或域名）
docker tag nginx:latest YOUR_NODE_IP:30009/library/nginx:latest

# 推送镜像
docker push YOUR_NODE_IP:30009/library/nginx:latest
```

**RKE2 集群测试：**

> **注意：** `crictl` 不能用于登录 Harbor 仓库。在 RKE2 环境中，有以下几种测试方法：

```bash
# 方法1: 使用 docker 或 nerdctl 登录（如果有安装）
docker login YOUR_NODE_IP:30009 --username admin --password Harbor12345

# 方法2: 使用 nerdctl（containerd 的 CLI）
sudo nerdctl login YOUR_NODE_IP:30009 --username admin --password Harbor12345

# 方法3: 创建 Kubernetes Secret（推荐，无需登录）
# Secret 是命名空间隔离的，每个需要拉取镜像的命名空间都要创建独立的密钥
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@example.com \
  -n default

# 如果需要在多个命名空间使用 Harbor，可以使用脚本批量创建
for ns in default jenkins demo test prod; do
  kubectl create secret docker-registry harbor-registry-secret \
    --docker-server=YOUR_NODE_IP:30009 \
    --docker-username=admin \
    --docker-password=Harbor12345 \
    --docker-email=admin@example.com \
    -n $ns
  echo "✓ Secret created in namespace: $ns"
done

# 或者从现有命名空间复制密钥
kubectl get secret harbor-registry-secret -n jenkins -o yaml | \
  sed 's/namespace: jenkins/namespace: demo/g' | \
  kubectl apply -n demo -f -


# 创建测试 Pod 来验证拉取镜像
# 注意：Pod 的命名空间必须与 Secret 的命名空间一致
cat > test-harbor-pull.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-harbor-pull
  namespace: default
spec:
  containers:
  - name: test
    image: YOUR_NODE_IP:30009/library/nginx:latest
    command: ["sleep", "3600"]
  imagePullSecrets:
  - name: harbor-registry-secret
EOF

# 应用 Pod
kubectl apply -f test-harbor-pull.yaml

# 查看 Pod 状态（成功拉取镜像会显示 Running）
kubectl get pod test-harbor-pull

# 查看 Pod 日志（验证镜像运行正常）
kubectl logs test-harbor-pull

# 测试完成后清理
kubectl delete pod test-harbor-pull

# 查看所有命名空间中的 harbor-registry-secret
kubectl get secret harbor-registry-secret --all-namespaces
```

> **重要说明：** RKE2 的 `crictl` 命令不支持 `tag` 和 `push` 操作。
> 如果需要推送镜像到 Harbor，请使用：
> - `docker tag` + `docker push`（在安装了 Docker 的机器上）
> - `nerdctl tag` + `nerdctl push`（containerd CLI）
> - 或者在 CI/CD 工具中完成镜像构建和推送

**RKE2 拉取镜像方法：**

```bash
# 方法1: 直接在 Pod 中拉取（推荐）
# 创建 Deployment
cat > test-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: test
        image: YOUR_NODE_IP:30009/library/nginx:latest
        imagePullPolicy: Always
      imagePullSecrets:
      - name: harbor-registry-secret
EOF

kubectl apply -f test-deployment.yaml

# 查看 Deployment 状态
kubectl get deployment test-deployment
kubectl get pods -l app=test

# 方法2: 使用 crictl 拉取（需要先配置 /etc/rancher/rke2/registries.yaml）
# 注意：crictl 只能查看和管理已存在的镜像，不能直接登录私有仓库
# 需要配置 registries.yaml 才能拉取私有镜像，或使用 imagePullSecrets

# 配置 /etc/rancher/rke2/registries.yaml（需要重启 RKE2）
cat > /tmp/registries.yaml <<EOF
mirrors:
  YOUR_NODE_IP:30009:
    endpoint:
      - "https://YOUR_NODE_IP:30009"
configs:
  YOUR_NODE_IP:30009:
    tls:
      insecure_skip_verify: true
EOF

sudo cp /tmp/registries.yaml /etc/rancher/rke2/registries.yaml
sudo systemctl restart rke2-server

# 拉取镜像（需要配置好 registries.yaml）
sudo crictl pull YOUR_NODE_IP:30009/library/nginx:latest

# 查看本地镜像列表
sudo crictl images | grep nginx

# 删除测试资源
kubectl delete deployment test-deployment
```

**验证 RKE2 能否访问 Harbor：**

```bash
# 1. 测试 Harbor API 可访问
curl -k https://YOUR_NODE_IP:30009/v2/

# 2. 测试项目可访问
curl -k -u admin:Harbor12345 https://YOUR_NODE_IP:30009/api/v2.0/projects/library

# 3. 检查 RKE2 配置
sudo crictl info | grep -A 10 registry
# 应该能看到 Harbor 的配置
```

---

## 十、配置 Jenkins/Kaniko 使用 Harbor

### 1. 创建 Harbor Registry Secret

Jenkins 使用 Kaniko 构建镜像时需要 Harbor 认证 Secret：

```bash
# 创建 harbor-registry-secret（使用 HTTPS，server 改为你的实际地址）

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n demo

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default

# 验证 Secret 创建成功
kubectl get secret harbor-registry-secret -n default
kubectl get secret harbor-registry-secret -n jenkins
kubectl get secret harbor-registry-secret -n demo

# 查看 Secret 内容
kubectl get secret harbor-registry-secret -n default -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

**预期输出：**
```json
{
  "auths": {
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

### 2. 在 Harbor 中创建项目

登录 Harbor Web UI (https://YOUR_NODE_IP:30009)：

1. 使用 admin / Harbor12345 登录
2. 点击"项目" → "新建项目"
3. 项目名称：`library`（或其他名称）
4. 访问级别：公开或私有
5. 点击"确定"

### 3. 配置 Jenkinsfile

在 Jenkinsfile 中配置 Harbor HTTPS 地址（替换为你的实际地址）：

```groovy
// Harbor HTTPS 本地镜像仓库配置
HARBOR_REGISTRY = 'YOUR_NODE_IP:30009'  // 替换为实际IP或域名
HARBOR_PROJECT = 'library'
HARBOR_REPOSITORY_NAME = 'demo-springboot'
HARBOR_IMAGE_NAME = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPOSITORY_NAME}"
```

### 4. Kaniko 推送到 Harbor（HTTPS）

由于 Harbor 使用 HTTPS，Kaniko 不需要 insecure registry 参数：

```groovy
// Kaniko executor 命令（HTTPS 不需要 --insecure-registry，替换为你的实际地址）
/kaniko/executor \
  --context=${WORKSPACE} \
  --dockerfile=${WORKSPACE}/Dockerfile \
  --destination=YOUR_NODE_IP:30009/library/demo-springboot:latest \
  --compressed-caching=true \
  --compression=gzip \
  --compression-level=9
```

### 5. 验证镜像推送

```bash
# 方法 1：使用 Harbor Web UI（替换为你的实际地址）
# 访问 https://YOUR_NODE_IP:30009
# 进入 library 项目，查看仓库列表

# 方法 2：使用 Harbor API（替换为你的实际地址）
curl -k -u admin:Harbor12345 \
  https://YOUR_NODE_IP:30009/api/v2.0/projects/library/repositories

# 方法 3：使用 Docker CLI（替换为你的实际地址）
docker login YOUR_NODE_IP:30009
docker pull YOUR_NODE_IP:30009/library/demo-springboot:latest
```

### 6. 常见问题排查

#### 问题 1：TLS 证书错误

**错误信息：**
```
x509: certificate signed by unknown authority
```

**原因：** 自签名证书不被信任

**解决：**
```bash
# 将证书复制到所有 RKE2 节点
sudo cp harbor-core.harbor.crt /etc/rancher/rke2/harbor-ca.crt
```

#### 问题 2：unauthorized: authentication required

**错误信息：**
```
unauthorized: authentication required
```

**原因：** harbor-registry-secret 不存在或配置错误

**解决：**
```bash
# 重新创建 Secret
kubectl delete secret harbor-registry-secret -n default
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

#### 问题 3：project library not found

**错误信息：**
```
project library not found
```

**原因：** Harbor 项目不存在

**解决：**
```bash
# 使用 Harbor API 创建项目（替换为你的实际IP或域名）
curl -X POST "https://YOUR_NODE_IP:30009/api/v2.0/projects" \
  -H "Content-Type: application/json" \
  -u admin:Harbor12345 \
  -d '{
    "project_name": "library",
    "public": true
  }'
```

### 7. 测试完整流程

```bash
# 1. 确认 Harbor 可访问（使用 -k 忽略证书验证，替换为你的实际地址）
curl -k https://YOUR_NODE_IP:30009/v2/
# 预期输出: {}

# 2. 确认 Secret 存在
kubectl get secret harbor-registry-secret -n default

# 3. 确认项目存在（替换为你的实际地址）
curl -k -u admin:Harbor12345 \
  https://YOUR_NODE_IP:30009/api/v2.0/projects/library
# 预期输出: {"project_id":x,"name":"library",...}
# 如果返回 404 Not Found，说明项目不存在，需要先在 Web UI 创建

# 4. 在 Jenkins 中触发构建
# 选择 PUSH_TO_HARBOR = true

# 5. 验证镜像已推送（替换为你的实际地址）
curl -k -u admin:Harbor12345 \
  https://YOUR_NODE_IP:3009/api/v2.0/projects/library/repositories/demo-springboot/artifacts
# 预期输出: 镜像的 artifacts 列表
```

---

## 十一、配置 RKE2 使用 HTTPS Harbor

在每个 RKE2 节点上执行：

```bash
# 创建 registries.yaml（替换为你的实际IP或域名）
sudo mkdir -p /etc/rancher/rke2
sudo tee /etc/rancher/rke2/registries.yaml > /dev/null <<EOF
mirrors:
  "YOUR_NODE_IP:30009":
    endpoint:
      - "https://YOUR_NODE_IP:30009"

configs:
  "YOUR_NODE_IP:30009":
    tls:
      ca_file: /etc/rancher/rke2/harbor-ca.crt
      insecure_skip_verify: false
EOF

# 复制证书
sudo cp /tmp/harbor-cert/harbor-core.harbor.crt /etc/rancher/rke2/harbor-ca.crt

# 重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent

# 验证配置
sudo crictl info | grep -A 10 registry
```

---

## 十二、常用管理命令

### Helm 命令

```bash
# 查看 Harbor 状态
helm status harbor -n harbor

# 查看 Harbor 配置
helm get values harbor -n harbor

# 导出当前配置
helm get values harbor -n harbor > current-values-https.yaml

# 升级 Harbor
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml

# 回滚 Harbor
helm rollback harbor -n harbor

# 卸载 Harbor
helm uninstall harbor -n harbor
```

### Kubernetes 命令

```bash
# 查看 Pod 日志
kubectl logs -n harbor -l app=harbor-core --tail=50
kubectl logs -n harbor -l app=harbor-registry --tail=50

# 查看 Pod 详情
kubectl describe pod -n harbor <pod-name>

# 查看事件
kubectl get events -n harbor --sort-by='.lastTimestamp'

# 重启 Pod
kubectl rollout restart deployment/harbor-core -n harbor
kubectl rollout restart deployment/harbor-registry -n harbor

# 查看资源使用
kubectl top pods -n harbor
```

---

## 十三、故障排查

### 1. Pod 无法启动

```bash
# 查看 Pod 状态
kubectl get pods -n harbor

# 查看 Pod 详情
kubectl describe pod -n harbor <pod-name>

# 查看日志
kubectl logs -n harbor <pod-name> --tail=100
```

### 2. 无法访问 Web UI

**检查项：**
- [ ] 所有 Pod 是否 Running
- [ ] NodePort 30009 是否被占用
- [ ] 防火墙是否开放 30009 端口
- [ ] externalURL 配置是否正确

```bash
# 检查服务
kubectl get svc -n harbor

# 检查端口
netstat -tlnp | grep 30009
```

### 3. HTTPS 证书错误

**错误信息：**
```
x509: certificate signed by unknown authority
```

**原因：** 自签名证书不被信任

**解决：**
```bash
# 将证书复制到所有节点
sudo cp harbor-core.harbor.crt /etc/rancher/rke2/harbor-ca.crt

# 重启 RKE2
sudo systemctl restart rke2-server
```

### 4. 镜像推送失败

**检查项：**
- [ ] Docker 证书是否已配置
- [ ] 是否已登录 Harbor
- [ ] 项目是否已创建
- [ ] Registry Pod 是否正常

```bash
# 检查 Docker 证书（替换为你的实际地址）
ls -la /etc/docker/certs.d/YOUR_NODE_IP:30009/

# 重新登录（替换为你的实际地址）
docker logout YOUR_NODE_IP:30009
docker login YOUR_NODE_IP:30009

# 检查 Registry Pod
kubectl logs -n harbor -l app=harbor-registry
```

### 5. PVC 无法绑定（Unbound PersistentVolumeClaims）

**错误信息：**
```
pod has unbound immediate PersistentVolumeClaims
```

**原因：**
- StorageClass 不存在或名称错误
- local-path provisioner 未运行

**解决方法：**

```bash
# 1. 检查 StorageClass
kubectl get storageclass

# 2. 如果 StorageClass 名称不是 local-path，修改配置文件
# 假设实际名称是 local-storage
sed -i 's/local-path/local-storage/g' harbor-helm-values-https.yaml

# 3. 重新部署
helm uninstall harbor -n harbor
kubectl delete pvc -n harbor --all
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

### 6. NodePort 端口已被占用

**错误信息：**
```
Service "harbor" is invalid: spec.ports[1].nodePort: Invalid value: 30009: provided port is already allocated
```

**原因：**
- 端口 30009 或 30008 已被其他服务占用
- 之前的 Harbor 没有完全卸载

**解决方法：**

```bash
# 1. 检查端口占用情况
netstat -tlnp | grep -E "30008|30009"

# 2. 查找占用端口的 Service
kubectl get svc --all-namespaces | grep -E "30008|30009"

# 3. 如果是旧的 Harbor Service，卸载 Harbor
helm uninstall harbor -n harbor

# 4. 如果是其他服务占用端口，修改 Harbor 配置文件中的端口
sed -i 's/30009/30004/g' harbor-helm-values-https.yaml
sed -i 's/30008/30001/g' harbor-helm-values-https.yaml

# 5. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

### 7. PVC Spec 不可变错误

**错误信息：**
```
PersistentVolumeClaim "harbor-registry" is invalid: spec: Forbidden: spec is immutable after creation
```

**原因：**
- 旧的 PVC 还存在，但 StorageClass 名称不匹配
- Helm 尝试修改已存在的 PVC

**解决方法：**

```bash
# 1. 删除所有旧的 PVC
kubectl delete pvc -n harbor --all

# 2. 确保配置文件使用正确的 StorageClass
grep storageClass harbor-helm-values-https.yaml
# 应该显示: storageClass: "local-path"

# 3. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

### 7. 端口已被占用

**错误信息：**
```
spec.ports[0].nodePort: Invalid value: 30009: provided port is already allocated
```

**解决方法：**

```bash
# 1. 查看哪个服务占用了端口
kubectl get svc --all-namespaces | grep 30009

# 2. 修改 Harbor 使用其他端口
sed -i 's/30009/30004/g' harbor-helm-values-https.yaml

# 3. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

### 8. Helm Release 名称已存在

**错误信息：**
```
cannot re-use a name that is still in use
```

**解决方法：**

```bash
# 1. 卸载已存在的 Release
helm uninstall harbor -n harbor

# 2. 等待清理完成
sleep 10

# 3. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

---

## 十四、备份和恢复

### 备份

```bash
# 1. 备份 Helm 配置
helm get values harbor -n harbor > harbor-backup-values-https.yaml

# 2. 备份 PVC 数据（使用存储系统快照）
kubectl get pvc -n harbor

# 3. 备份 Harbor 数据库
kubectl exec -n harbor harbor-database-0 -- \
  pg_dumpall -U postgres > harbor-db-backup.sql
```

### 恢复

```bash
# 使用备份的配置重新部署
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-backup-values-https.yaml \
  --version 1.14.0
```

---

## 十五、升级 Harbor

```bash
# 1. 备份当前配置
helm get values harbor -n harbor > harbor-backup-values-https.yaml

# 2. 更新 Helm 仓库
helm repo update

# 3. 查看可用版本
helm search repo harbor/harbor --versions

# 4. 升级到新版本
helm upgrade harbor harbor/harbor \
  -n harbor \
  -f harbor-helm-values-https.yaml \
  --version 1.15.0

# 5. 查看升级状态
kubectl get pods -n harbor -w
```

---

## 十六、卸载 Harbor

### 说明

Helm 卸载会**自动删除**以下资源（无需手动清理）：
- ✅ 所有 Deployment、StatefulSet（Pod）
- ✅ 所有 Service（服务发现）
- ✅ 所有 ConfigMap
- ✅ 所有 Secret（harbor 命名空间内的，**不包括跨命名空间的 Secret**）
- ✅ 所有 Ingress（如果配置了）
- ✅ 所有 ServiceAccount、Role、RoleBinding

**需要手动清理的资源：**
- ❌ PVC（持久化数据，默认不删除）
- ❌ 跨命名空间的 Secret（如其他 ns 中的 harbor-registry-secret）
- ❌ RKE2 配置文件
- ❌ Docker 客户端证书
- ❌ 本地证书文件

### 卸载步骤

```bash
# 1. 卸载 Helm Release（会自动删除所有 Service、Pod 等资源）
helm uninstall harbor -n harbor

# 2. 删除跨命名空间的 Harbor Registry Secret（Jenkins/Kaniko 使用的认证）
kubectl delete secret harbor-registry-secret -n jenkins 2>/dev/null || true
kubectl delete secret harbor-registry-secret -n demo 2>/dev/null || true
kubectl delete secret harbor-registry-secret -n default 2>/dev/null || true

# 3. 删除 TLS Secret（harbor 命名空间内的）
kubectl delete secret harbor-tls -n harbor 2>/dev/null || true

# 4. 删除 PVC（可选，会删除所有数据）
kubectl delete pvc -n harbor --all

# 5. 删除命名空间
kubectl delete namespace harbor

# 6. 删除 RKE2 中的 Harbor 配置（所有节点）
# 删除或注释 /etc/rancher/rke2/registries.yaml 中的 Harbor 配置
# 然后重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent

# 7. 删除证书文件（可选）
rm -rf /tmp/harbor-cert

# 8. 删除 Docker 证书（如果使用 Docker 客户端）
sudo rm -rf /etc/docker/certs.d/YOUR_NODE_IP:30009
```

### 清理后验证

```bash
echo "=== 验证清理结果 ==="

# 验证命名空间
kubectl get namespace harbor 2>/dev/null && echo "⚠️ Harbor 命名空间还存在" || echo "✓ Harbor 命名空间已删除"

# 验证 Secret（显示详细信息）
echo "检查 Registry Secret..."
if kubectl get secret harbor-registry-secret --all-namespaces &>/dev/null; then
  echo "⚠️ 以下 Registry Secret 还存在:"
  kubectl get secret harbor-registry-secret --all-namespaces
else
  echo "✓ Registry Secret 已清理"
fi

# 验证端口已释放
netstat -tlnp | grep 30009 && echo "⚠️ 端口 30009 仍被占用" || echo "✓ 端口 30009 已释放"

# 验证 Service（如果命名空间还存在）
if kubectl get namespace harbor &>/dev/null; then
  echo "检查 Harbor Service..."
  kubectl get svc -n harbor
fi
```

---

## 十七、性能优化建议

### 1. 增加资源限制

编辑 `harbor-helm-values-https.yaml`，增加资源：

```yaml
core:
  resources:
    requests:
      cpu: 1000m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 2Gi

registry:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

然后升级：
```bash
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml
```

### 2. 启用镜像缓存

```yaml
redis:
  type: internal
  internal:
    resources:
      requests:
        memory: 512Mi
      limits:
        memory: 1Gi
```

### 3. 增加存储空间

```bash
# 如果 StorageClass 支持扩容
kubectl patch pvc harbor-registry -n harbor \
  -p '{"spec":{"resources":{"requests":{"storage":"500Gi"}}}}'
```

---

## 十八、常见问题（FAQ）

### Q1: Helm 安装失败？
**A**: 检查 Helm 版本，需要 v3.x：
```bash
helm version
```

### Q2: Pod 一直 Pending？
**A**: 检查 PVC 是否绑定：
```bash
kubectl get pvc -n harbor
kubectl describe pvc -n harbor
```

如果 PVC 状态是 Pending，检查 StorageClass：
```bash
kubectl get storageclass
# 确保 local-path 存在
```

### Q3: 忘记管理员密码？
**A**: 通过 Helm 重新设置：
```bash
# 修改配置文件中的密码
vim harbor-helm-values-https.yaml
# 修改: harborAdminPassword: "NewPassword123"

# 升级 Harbor
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml
```

### Q4: 镜像推送速度慢？
**A**:
- 检查网络带宽
- 增加 Registry 资源
- 使用 SSD 存储

### Q5: 如何完全卸载 Harbor？
**A**:
```bash
# 1. 卸载 Helm Release
helm uninstall harbor -n harbor

# 2. 删除 PVC（会删除所有数据）
kubectl delete pvc -n harbor --all

# 3. 删除命名空间
kubectl delete namespace harbor
```

### Q6: 部署时提示 PVC spec 不可变？
**A**: 删除旧的 PVC：
```bash
kubectl delete pvc -n harbor --all
helm install harbor harbor/harbor -n harbor -f harbor-helm-values-https.yaml --version 1.14.0
```

### Q7: 端口 30009 被占用？
**A**: 修改 Harbor 端口：
```bash
# 查看占用情况
kubectl get svc --all-namespaces | grep 30009

# 或修改 Harbor 端口为 30004
sed -i 's/30009/30004/g' harbor-helm-values-https.yaml
```

### Q8: 浏览器显示证书不受信任？
**A**: 自签名证书需要手动信任：
- **Chrome/Edge**: 点击 "高级" → "继续前往"
- **Firefox**: 点击 "高级" → "接受风险并继续"
- 或者将证书导入系统信任存储

### Q9: 如何使用正式的 TLS 证书？
**A**: 
对于生产环境，建议使用正式证书：

```bash
# 使用你的正式证书替换自签名证书
kubectl create secret tls harbor-tls \
  --cert=/path/to/your/certificate.crt \
  --key=/path/to/your/private.key \
  -n harbor --dry-run=client -o yaml | kubectl apply -f -

# 重启 Harbor
kubectl rollout restart deployment/harbor-core -n harbor
kubectl rollout restart deployment/harbor-nginx -n harbor
```

### Q10: HTTPS 部署后如何从 HTTP 升级？
**A**: 参考"十五、升级 Harbor"章节：
```bash
# 1. 备份当前配置
helm get values harbor -n harbor > harbor-backup.yaml

# 2. 生成 TLS 证书并创建 Secret

# 3. 使用 HTTPS 配置升级
helm upgrade harbor harbor/harbor \
  -n harbor \
  -f harbor-helm-values-https.yaml \
  --version 1.14.0
```

---

## 附录：完整部署脚本

```bash
#!/bin/bash
# Harbor HTTPS 一键部署脚本

set -e

# 请修改为你的实际节点IP或域名
NODE_IP="YOUR_NODE_IP"  # 例如: 192.168.80.101 或 harbor.example.com
DOMAIN="harbor-core.harbor"

echo "=== Harbor HTTPS 部署脚本 ==="

# 1. 安装 Helm
if ! command -v helm &> /dev/null; then
    echo ">>> 安装 Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 2. 添加 Harbor 仓库
echo ">>> 添加 Harbor Helm 仓库..."
helm repo add harbor https://helm.goharbor.io
helm repo update

# 3. 生成 TLS 证书
echo ">>> 生成 TLS 证书..."
mkdir -p /tmp/harbor-cert
cd /tmp/harbor-cert

openssl genrsa -out ${DOMAIN}.key 2048
openssl req -new -key ${DOMAIN}.key -out ${DOMAIN}.csr -subj "/CN=${DOMAIN}/O=harbor"
openssl x509 -req -days 3650 -in ${DOMAIN}.csr -signkey ${DOMAIN}.key -out ${DOMAIN}.crt

echo "✓ TLS 证书生成完成"

# 4. 创建 TLS Secret
echo ">>> 创建 TLS Secret..."
kubectl create secret tls harbor-tls \
  --cert=${DOMAIN}.crt \
  --key=${DOMAIN}.key \
  -n harbor --dry-run=client -o yaml | kubectl apply -f -

echo "✓ TLS Secret 创建完成"

# 5. 创建配置文件
echo ">>> 创建配置文件..."
cat > harbor-helm-values-https.yaml <<EOF
expose:
  type: nodePort
  tls:
    enabled: true
    certSource: secret
    secret:
      secretName: "harbor-tls"
  nodePort:
    ports:
      http:
        nodePort: 30008
      https:
        nodePort: 30009

externalURL: https://${NODE_IP}:30009

persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "local-path"
      size: 200Gi
    database:
      storageClass: "local-path"
      size: 10Gi
    redis:
      storageClass: "local-path"
      size: 5Gi

harborAdminPassword: "Harbor12345"

database:
  type: internal
  internal:
    password: "changeit"

redis:
  type: internal

trivy:
  enabled: false
notary:
  enabled: false
chartmuseum:
  enabled: false
EOF

# 6. 部署 Harbor
echo ">>> 部署 Harbor（HTTPS）..."
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-helm-values-https.yaml \
  --version 1.14.0

echo "✓ Harbor 部署完成"

# 7. 等待 Pod 就绪
echo ">>> 等待 Pod 就绪..."
kubectl wait --for=condition=ready pod \
  -l app=harbor \
  -n harbor \
  --timeout=600s || true

# 8. 显示访问信息
echo ""
echo "=== Harbor HTTPS 部署完成 ==="
echo "HTTPS 访问地址: https://${NODE_IP}:30009"
echo "HTTP 访问地址: http://${NODE_IP}:30008"
echo "内部域名: https://${DOMAIN}"
echo "用户名: admin"
echo "密码: Harbor12345"
echo ""
echo "注意：由于使用自签名证书，首次访问时浏览器会显示安全警告"
echo "请点击 '高级' → '继续前往' 继续访问"
echo ""
echo "查看状态: kubectl get pods -n harbor"
echo ""
```

保存为 `deploy-harbor-https.sh`，然后执行：

```bash
chmod +x deploy-harbor-https.sh
./deploy-harbor-https.sh
```

---

**部署完成后，Harbor 就支持 HTTPS 了！** 🎉
