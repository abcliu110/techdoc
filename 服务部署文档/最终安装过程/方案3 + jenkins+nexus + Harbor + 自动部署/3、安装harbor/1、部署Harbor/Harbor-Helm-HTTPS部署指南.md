# Harbor HTTPS Helm 部署完整指南

## 📋 部署流程概览

本文档提供 Harbor HTTPS 版本的完整部署指南，包含以下关键步骤：

1. **安装 Helm** - Kubernetes 包管理工具
2. **准备工作** - 清理旧部署、检查环境
3. **生成 TLS 证书** - 创建自签名证书（包含正确的 SAN）
4. **创建 TLS Secret** - 将证书导入 Kubernetes
5. **⚠️ 配置 RKE2 节点信任证书** - **关键步骤，必须执行**
6. **创建配置文件** - Harbor Helm Values
7. **部署 Harbor** - 使用 Helm 安装
8. **验证和测试** - 确认部署成功
9. **配置 Docker（可选）** - 仅集群外 Docker 客户端需要
10. **配置 Jenkins/Kaniko** - CI/CD 流水线集成

> **重要提示**：第 5 步"配置 RKE2 节点信任 Harbor 证书"是必须执行的关键步骤。
> 如果跳过此步骤，Kubernetes 将无法从 Harbor 拉取镜像，报错 `ImagePullBackOff`。

---

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

# 8. 删除 RKE2 中的 Harbor 配置（所有节点，如果之前配置过）
# 编辑 /etc/rancher/rke2/registries.yaml，删除 Harbor 相关配置
# 然后重启 RKE2
sudo systemctl restart rke2-server 2>/dev/null || true  # 仅在确认 Harbor 配置存在时才编辑并重启 RKE2

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

> **重要说明**：
> - 证书中的 **内部域名**（harbor-core.harbor, harbor.harbor, harbor）是必需的，用于 Harbor 内部服务间通信
> - 证书中的 **IP 地址** 是可选的，用于集群外部访问，可以根据实际需求添加或省略
> - 如果只需要集群内部访问，可以省略 IP；如果需要集群外部访问（NodePort 方式），需要添加节点 IP

### 前置准备
在生成证书前，先清理旧文件并进入工作目录，避免干扰：
```bash
rm -rf /tmp/harbor-cert
mkdir -p /tmp/harbor-cert
cd /tmp/harbor-cert
```

### 方式1：仅内部域名访问（推荐，证书更简洁）
```bash
# 生成私钥
openssl genrsa -out harbor-core.harbor.key 2048

# 生成自签名证书（有效期 10 年，仅包含内部域名，兼容 OpenSSL 1.0.x）
cat > san.cnf <<EOF
[san_section]
subjectAltName = DNS:harbor-core.harbor,DNS:harbor.harbor,DNS:harbor
EOF

openssl req -new -x509 -days 3650 \
  -key harbor-core.harbor.key \
  -out harbor-core.harbor.crt \
  -subj "/CN=harbor-core.harbor/O=harbor" \
  -config <(cat /etc/ssl/openssl.cnf <(printf "\n[san_section]\n%s" "$(cat san.cnf)")) \
  -extensions san_section

# 验证证书（一定能看到 SAN）
openssl x509 -in harbor-core.harbor.crt -noout -text | grep -A 5 "Subject Alternative Name"
# 预期输出包含：
# DNS:harbor-core.harbor, DNS:harbor.harbor, DNS:harbor
```

### 方式2：包含 IP 地址访问（如果需要集群外部访问）
```bash
# 确保已进入工作目录（前置准备已创建并进入，如未进入请执行）
cd /tmp/harbor-cert

# 生成私钥
openssl genrsa -out harbor-core.harbor.key 2048

# 替换为你的实际节点 IP 地址，例如: 192.168.80.101
NODE_IP="192.168.80.101"

# 生成自签名证书（有效期 10 年，包含内部域名和 IP，兼容 OpenSSL 1.0.x）
cat > san.cnf <<EOF
[san_section]
subjectAltName = DNS:harbor-core.harbor,DNS:harbor.harbor,DNS:harbor$([ "$NODE_IP" != "" ] && echo ",IP:$NODE_IP")
EOF

openssl req -new -x509 -days 3650 \
  -key harbor-core.harbor.key \
  -out harbor-core.harbor.crt \
  -subj "/CN=harbor-core.harbor/O=harbor" \
  -config <(cat /etc/ssl/openssl.cnf <(printf "\n[san_section]\n%s" "$(cat san.cnf)")) \
  -extensions san_section

# 验证证书（一定能看到 SAN）
openssl x509 -in harbor-core.harbor.crt -noout -text | grep -A 5 "Subject Alternative Name"
# 预期输出包含：
# DNS:harbor-core.harbor, DNS:harbor.harbor, DNS:harbor, IP Address:192.168.80.101
```

> **说明**：
> - 使用 `san.cnf` 配置文件方式，可在 OpenSSL 1.0.x 与 1.1.x 中均正确写入 SAN
> - **内部域名**是必需的：`harbor-core.harbor`、`harbor.harbor`、`harbor`
> - **IP 地址**根据需要添加，替换 `NODE_IP` 为实际节点 IP
> - 如果使用域名访问 Harbor，可以将 IP 替换为域名


> **说明**：
> - `-addext` 参数直接在命令行添加 Subject Alternative Names（SANs）
> - 不需要额外的配置文件，命令更简洁
> - **内部域名**是必需的：`harbor-core.harbor`、`harbor.harbor`、`harbor`
> - **IP 地址**根据需要添加，替换 `YOUR_NODE_IP` 为实际节点 IP
> - 如果使用域名访问 Harbor，可以将 IP 替换为域名

---

## 四、创建 TLS Secret

```bash
# 1. 创建 Harbor 命名空间（如果不存在）
kubectl create namespace harbor

# 2. 删除旧的 TLS Secret（如果存在）
kubectl delete secret harbor-tls -n harbor 2>/dev/null || echo "Secret 不存在，跳过"

# 3. 在 Harbor 命名空间创建 TLS Secret（使用证书文件）
kubectl create secret tls harbor-tls \
  --cert=harbor-core.harbor.crt \
  --key=harbor-core.harbor.key \
  -n harbor

# 4. 验证证书内容（确认 SANs 配置）
openssl x509 -in harbor-core.harbor.crt -text -noout | grep -A1 "Subject Alternative Name"
# 预期输出应包含：
# DNS:harbor-core.harbor, DNS:harbor.harbor, DNS:harbor, IP Address:192.168.80.101

# 5. 验证 Secret 创建成功
kubectl get secret harbor-tls -n harbor
kubectl describe secret harbor-tls -n harbor

# 6. 验证 Secret 中的证书是否正确（验证 SANs）
kubectl get secret harbor-tls -n harbor -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout | grep -A1 "Subject Alternative Name"
# 预期输出应包含：DNS:harbor-core.harbor, DNS:harbor.harbor, DNS:harbor, IP Address:192.168.80.101

# 7. 【重要】将 CA 证书添加到 Secret 中（用于 RKE2 节点信任）
kubectl patch secret harbor-tls -n harbor --type='json' -p='[{"op": "add", "path": "/data/ca.crt", "value": "'$(base64 -w 0 harbor-core.harbor.crt)'"}]'

# 8. 验证 CA 证书已添加
kubectl get secret harbor-tls -n harbor -o jsonpath='{.data.ca\.crt}' | base64 -d | openssl x509 -noout -subject
# 预期输出：subject=CN = harbor-core.harbor, O = harbor

> **注意**：上述验证步骤完成后，**请勿在此处重启 Harbor 服务或执行证书访问验证**。
> 这些操作应在 Harbor 部署完成后再进行，以避免在服务尚未启动时产生错误。
```

---

## 五、配置 RKE2 节点信任 Harbor 证书

> **关键步骤**：此步骤是 Kubernetes 节点能够从 Harbor 拉取镜像的前提条件。
> 如果跳过此步骤，部署到 Kubernetes 的应用将无法拉取 Harbor 镜像，报错 `ImagePullBackOff` 和 `x509: certificate signed by unknown authority`。

### 为什么需要此步骤？

当 Kubernetes 节点（RKE2）尝试从 Harbor 拉取镜像时，containerd 会验证 Harbor 的 TLS 证书。由于我们使用的是自签名证书，节点默认不信任该证书，导致镜像拉取失败。

### 配置步骤

**在所有 RKE2 节点上执行以下操作**（如果是单节点集群，只需在该节点执行）：

#### 1. 复制 CA 证书到 RKE2 配置目录

```bash
# 确保当前在证书目录
cd /tmp/harbor-cert

# 复制 CA 证书到 RKE2 配置目录
sudo cp harbor-core.harbor.crt /etc/rancher/rke2/harbor-ca.crt

# 验证文件已复制
ls -lh /etc/rancher/rke2/harbor-ca.crt

# 验证证书内容
openssl x509 -in /etc/rancher/rke2/harbor-ca.crt -noout -subject -dates
```

#### 2. 配置 containerd 使用 Harbor 证书

创建或编辑 `/etc/rancher/rke2/registries.yaml` 文件：

```bash
# 备份现有配置（如果存在）
sudo cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak 2>/dev/null || true

# 注意：将 YOUR_NODE_IP 替换为实际的节点 IP（例如：192.168.80.101）
# 使用 sudo tee 写入（sudo 对 > 重定向无效，必须用 tee）
sudo tee /etc/rancher/rke2/registries.yaml << EOF
mirrors:
  YOUR_NODE_IP:30009:
    endpoint:
      - https://YOUR_NODE_IP:30009
  harbor.harbor:
    endpoint:
      - https://YOUR_NODE_IP:30009

configs:
  YOUR_NODE_IP:30009:
    tls:
      ca_file: /etc/rancher/rke2/harbor-ca.crt
      insecure_skip_verify: false
  harbor.harbor:
    tls:
      ca_file: /etc/rancher/rke2/harbor-ca.crt
      insecure_skip_verify: false
EOF
```

**配置原理说明（重要，必读）：**

**为什么 `harbor.harbor` 的 endpoint 必须指向 NodePort 地址？**

- `harbor.harbor` 是 Kubernetes Service 的 DNS 名称，只能在集群内部的 Pod 中解析（通过 CoreDNS）
- containerd 运行在节点（宿主机）上，不在 Pod 内，因此**无法通过 CoreDNS 解析 `harbor.harbor`**
- 如果 endpoint 写成 `https://harbor.harbor`，containerd 会因 DNS 解析失败而无法拉取镜像
- 正确做法：将 `harbor.harbor` 的 endpoint 指向 NodePort 地址（`https://YOUR_NODE_IP:30009`），containerd 通过 NodePort 访问 Harbor，同时使用 `ca_file` 验证证书

**为什么不能在 `/etc/hosts` 中添加 `harbor.harbor` 条目？**

- 如果在 `/etc/hosts` 中添加 `192.168.80.101 harbor.harbor`，节点 DNS 会将 `harbor.harbor` 解析为节点 IP
- containerd 会直接连接 `192.168.80.101:443`（默认 HTTPS 端口），而不是 NodePort `30009`
- 这会导致连接失败或绕过 `registries.yaml` 中的 CA 证书配置，出现 `x509` 证书错误
- **结论：绝对不要在 `/etc/hosts` 中添加 `harbor.harbor` 条目**

**配置字段说明：**
- `mirrors`: 定义镜像仓库的镜像源
  - `YOUR_NODE_IP:30009`: 外部访问地址（NodePort），endpoint 指向自身
  - `harbor.harbor`: 集群内部域名，endpoint **必须指向 NodePort 地址**，不能指向 `harbor.harbor` 本身
- `configs`: 定义仓库的 TLS 配置
  - `ca_file`: 指向 CA 证书文件路径，containerd 用此证书验证 Harbor 的 TLS 证书
  - `insecure_skip_verify: false`: 启用证书验证（推荐）

#### 3. 验证配置文件

```bash
# 查看配置文件内容
cat /etc/rancher/rke2/registries.yaml

# 检查 YAML 语法是否正确
sudo rke2 server --dry-run 2>&1 | grep -i registry || echo "配置语法正确"
```

#### 4. 重启 RKE2 服务

```bash
# 重启 RKE2 服务以加载新配置
sudo systemctl restart rke2-server

# 等待 RKE2 完全启动（通常需要 1-2 分钟）
echo "等待 RKE2 启动..."
sleep 60

# 验证 RKE2 服务状态
sudo systemctl status rke2-server

# 验证 Kubernetes 节点状态
kubectl get nodes
```

#### 5. 验证 containerd 配置生效（可选）

```bash
# 方法1: 使用 crictl（如果命令可用）
sudo /var/lib/rancher/rke2/bin/crictl --runtime-endpoint unix:///run/k3s/containerd/containerd.sock info 2>/dev/null | grep -A 20 registry

# 方法2: 直接查看 containerd 配置文件
cat /var/lib/rancher/rke2/agent/etc/containerd/config.toml | grep -A 30 -i registry

# 方法3: 验证 registries.yaml 配置正确
cat /etc/rancher/rke2/registries.yaml

# 方法4: 检查 RKE2 服务状态
systemctl status rke2-server | grep Active
```

> **注意**：如果 `crictl` 命令找不到或报错，可以跳过此步骤。
> 只要 `registries.yaml` 配置正确且 RKE2 已重启，配置就会生效。
> 最终验证会在 Harbor 部署后通过实际拉取镜像来确认。

#### 6. 测试证书验证（可选）

```bash
# 测试从节点访问 Harbor API（Harbor 部署后才能测试）
# 注意：此步骤需要在 Harbor 部署完成后执行，现在会连接失败
# curl -v https://YOUR_NODE_IP:30009/v2/ 2>&1 | grep -E "SSL certificate|subject|issuer"

# 预期输出应包含证书信息，不应有 "certificate verify failed" 错误
```

> **重要**：此测试需要在 Harbor 部署完成后才能执行。
> 现在执行会显示"Connection refused"，这是正常的。

### 多节点集群配置

如果你的 RKE2 集群有多个节点（master 或 worker），需要在**每个节点**上重复上述步骤：

```bash
# 在每个节点上执行
for node in node1 node2 node3; do
  echo "配置节点: $node"

  # 复制证书到节点（使用 scp 或其他方式）
  scp /tmp/harbor-cert/harbor-core.harbor.crt root@$node:/etc/rancher/rke2/harbor-ca.crt

  # 复制 registries.yaml 到节点
  scp /etc/rancher/rke2/registries.yaml root@$node:/etc/rancher/rke2/registries.yaml

  # 重启节点上的 RKE2 服务
  ssh root@$node "systemctl restart rke2-server || systemctl restart rke2-agent"
done
```

### 常见问题

**Q1: 重启 RKE2 后 Pod 无法启动？**

A: 这是正常现象，RKE2 重启会导致所有 Pod 重启。等待 1-2 分钟后，Pod 会自动恢复。

```bash
# 查看 Pod 状态
kubectl get pods --all-namespaces
```

**Q2: 如何验证配置是否成功？**

A: 在部署 Harbor 后，尝试从集群内拉取镜像：

```bash
# 部署 Harbor 后执行
kubectl run test-pull --image=harbor.harbor/library/nginx:latest --rm -it --restart=Never
```

如果 Pod 成功启动，说明配置正确。

**Q3: 是否可以使用 insecure_skip_verify: true？**

A: 可以，但不推荐。这会跳过证书验证，存在安全风险：

```yaml
configs:
  "YOUR_NODE_IP:30009":
    tls:
      insecure_skip_verify: true  # 不推荐，仅用于测试
```

---

## 六、创建 HTTPS 配置文件

### 方法1: 使用 cat 命令创建

> **重要提示**：
> 如果仅需外部 HTTPS 访问 Harbor，不需要组件间内部加密，请将 `internalTLS.enabled` 设置为 `false`，否则会因缺少内部证书导致部署失败。

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

# ==================== 内部 TLS 配置 ====================
# Harbor 内部组件之间的 TLS 通信配置
# 推荐设置为 false，避免内部证书配置复杂性
internalTLS:
  enabled: false

# ==================== Helm Chart 仓库配置 ====================
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

## 七、部署 Harbor（HTTPS）

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

## 八、查看部署状态

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

## 九、访问 Harbor

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

## 十、配置 Docker 使用 Harbor（可选）

> **说明**：此章节仅适用于需要在**集群外**使用 Docker 客户端推送镜像的场景（例如开发者本地电脑）。
>
> **如果你的场景是 Jenkins + Kaniko 在集群内构建推送，Kubernetes 从 Harbor 拉取镜像，可以跳过本章节。**

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

## 十一、配置 Jenkins/Kaniko 使用 Harbor

### 1. 创建 Harbor Registry Secret

Jenkins 使用 Kaniko 构建镜像时需要 Harbor 认证 Secret。根据访问方式的不同，有两种 Secret 配置方式：

#### 方式1：集群内部访问（推荐，适用于 Jenkins/Kaniko 在集群内）

> **优势**：无需 TLS 证书，使用 HTTP 协议，配置简单，性能更好
> **适用场景**：Jenkins 和 Harbor 都在同一个 Kubernetes 集群内

```bash
# 创建集群内部访问的 Secret（使用 harbor-core.harbor:80）
# Harbor 在 harbor 命名空间，Jenkins 在 jenkins 命名空间，可以跨命名空间访问
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor:80 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

# 在其他命名空间也创建（如果需要）
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor:80 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n demo

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor:80 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default

# 批量创建多个命名空间
for ns in jenkins demo test prod default; do
  kubectl create secret docker-registry harbor-registry-secret \
    --docker-server=harbor-core.harbor:80 \
    --docker-username=admin \
    --docker-password=Harbor12345 \
    -n $ns
  echo "✓ Secret created in namespace: $ns"
done

# 验证 Secret 创建成功
kubectl get secret harbor-registry-secret -n default
kubectl get secret harbor-registry-secret -n jenkins
kubectl get secret harbor-registry-secret -n demo

# 查看 Secret 内容（集群内部地址）
kubectl get secret harbor-registry-secret -n default -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

**预期输出（集群内部地址）：**
```json
{
  "auths": {
    "harbor-core.harbor:80": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

**说明：**
- `harbor-core.harbor:80`：`harbor-core` 是 Service 名称，`harbor` 是命名空间，`:80` 是 HTTP 端口
- 集群内会自动解析为 `harbor-core.harbor.svc.cluster.local:80`
- 使用 HTTP 协议，无需 TLS 证书，无需 `--insecure` 参数

#### 方式2：集群外部访问（适用于客户端在集群外）

> **说明**：需要配置 TLS 证书，使用 HTTPS 协议
> **适用场景**：Docker 客户端在集群外访问 Harbor

```bash
# 创建集群外部访问的 Secret（使用 HTTPS，server 改为你的实际地址）
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

**预期输出（集群外部地址）：**
```json
{
  "auths": {
    "YOUR_NODE_IP:30009": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

**重要区别对比：**

| 项目 | 集群内部访问 | 集群外部访问 |
|------|-------------|-------------|
| 地址格式 | `harbor-core.harbor:80` | `YOUR_NODE_IP:30009` |
| 协议 | HTTP | HTTPS |
| TLS 证书 | 不需要 | 需要配置 |
| 适用场景 | Jenkins/Kaniko 在集群内 | Docker 客户端在集群外 |
| 性能 | 更快（直连） | 较慢（需绕出集群） |
| 配置复杂度 | 简单 | 较复杂 |

### 2. 在 Harbor 中创建项目

登录 Harbor Web UI (https://YOUR_NODE_IP:30009)：

1. 使用 admin / Harbor12345 登录
2. 点击"项目" → "新建项目"
3. 项目名称：`library`（或其他名称）
4. 访问级别：公开或私有
5. 点击"确定"

### 3. 配置 Jenkinsfile

在 Jenkinsfile 中配置 Harbor 地址。根据 Secret 配置方式，选择对应的地址：

#### 方式1：使用集群内部地址（推荐）

```groovy
// Harbor 集群内部访问配置（Jenkins/Kaniko 在集群内）
HARBOR_REGISTRY = 'harbor-core.harbor:80'  // ✅ 集群内部 HTTP 地址
HARBOR_PROJECT = 'library'
HARBOR_REPOSITORY_NAME = 'demo-springboot'
HARBOR_IMAGE_NAME = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPOSITORY_NAME}"
```

#### 方式2：使用集群外部地址

```groovy
// Harbor 集群外部访问配置（Docker 客户端在集群外）
HARBOR_REGISTRY = 'YOUR_NODE_IP:30009'  // 替换为实际IP或域名
HARBOR_PROJECT = 'library'
HARBOR_REPOSITORY_NAME = 'demo-springboot'
HARBOR_IMAGE_NAME = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPOSITORY_NAME}"
```

### 4. Kaniko 推送到 Harbor

根据访问方式选择不同的 Kaniko 配置：

#### 方式1：集群内部访问（推荐）

```groovy
// Kaniko executor 命令（集群内部访问，无需 TLS）
timeout 1800 /kaniko/executor \
  --context=${WORKSPACE} \
  --dockerfile=${WORKSPACE}/Dockerfile \
  --destination=harbor-core.harbor:80/library/demo-springboot:latest \
  --compressed-caching=true \
  --compression=gzip \
  --compression-level=9
```

**说明**：
- 使用 HTTP 协议，无需 `--insecure` 或 `--skip-tls-verify`
- Secret 中配置的是 `harbor-core.harbor:80`
- 集群内直接通信，性能最佳

#### 方式2：集群外部访问

```groovy
// Kaniko executor 命令（集群外部访问，需要 TLS）
timeout 1800 /kaniko/executor \
  --context=${WORKSPACE} \
  --dockerfile=${WORKSPACE}/Dockerfile \
  --destination=YOUR_NODE_IP:30009/library/demo-springboot:latest \
  --insecure-registry=YOUR_NODE_IP:30009 \
  --skip-tls-verify \
  --compressed-caching=true \
  --compression=gzip \
  --compression-level=9
```

**说明**：
- 使用 HTTPS 协议，需要 `--insecure-registry` 和 `--skip-tls-verify`
- Secret 中配置的是 `YOUR_NODE_IP:30009`
- 需要跳过 TLS 验证（自签名证书）

### 5. 验证镜像推送

```bash
# 方法 1：使用 Harbor Web UI（替换为你的实际地址）
# 访问 https://YOUR_NODE_IP:30009
# 进入 library 项目，查看仓库列表

# 方法 2：使用 Harbor API（替换为你的实际地址）
curl -k -u admin:Harbor12345 \
  https://YOUR_NODE_IP:30009/api/v2.0/projects/library/repositories

# 方法 3：使用 Docker CLI（集群外部访问，替换为你的实际地址）
docker login YOUR_NODE_IP:30009
docker pull YOUR_NODE_IP:30009/library/demo-springboot:latest
```

### 6. 常见问题排查

#### 问题 1：TLS 证书错误（集群外部访问）

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

**推荐方案：** 使用集群内部访问 `harbor-core.harbor:80`，无需 TLS 证书

#### 问题 2：unauthorized: authentication required

**错误信息：**
```
unauthorized: authentication required
```

**原因：** harbor-registry-secret 不存在或配置错误

**解决：**

**集群内部访问：**
```bash
# 重新创建 Secret（使用集群内部地址）
kubectl delete secret harbor-registry-secret -n default
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor:80 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

**集群外部访问：**
```bash
# 重新创建 Secret（使用集群外部地址）
kubectl delete secret harbor-registry-secret -n default
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=YOUR_NODE_IP:30009 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

#### 问题 3：http: server gave HTTP response to HTTPS client

**错误信息：**
```
error checking push permissions: Get "https://192.168.80.101:30009/v2/": http: server gave HTTP response to HTTPS client
```

**原因：** Secret 配置的地址与实际访问方式不匹配
- Secret 中配置的是 HTTPS 地址，但实际访问的是 HTTP 端口
- 或 Secret 中配置的是外部地址，但需要集群内部访问

**解决：**

**方案1：删除旧 Secret，创建集群内部 Secret（推荐）**
```bash
# 删除所有旧 Secret
kubectl delete secret harbor-registry-secret --all-namespaces 2>/dev/null || true

# 批量创建集群内部访问 Secret
for ns in jenkins demo test prod default; do
  kubectl create secret docker-registry harbor-registry-secret \
    --docker-server=harbor-core.harbor:80 \
    --docker-username=admin \
    --docker-password=Harbor12345 \
    -n $ns
  echo "✓ Secret created in namespace: $ns"
done
```

**方案2：使用 Jenkins 凭据动态生成配置**
```groovy
// 在 Jenkinsfile 中使用 withCredentials 动态生成配置
withCredentials([usernamePassword(
    credentialsId: 'harbor-credentials',
    usernameVariable: 'HARBOR_USER',
    passwordVariable: 'HARBOR_PASS'
)]) {
    sh """
        mkdir -p /kaniko/.docker
        echo -n "\${HARBOR_USER}:\${HARBOR_PASS}" | base64 > /tmp/harbor_auth
        cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "harbor-core.harbor:80": {
      "auth": "\$(cat /tmp/harbor_auth)"
    }
  }
}
EOF
        rm -f /tmp/harbor_auth
    """
}
```

#### 问题 4：project library not found

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

#### 问题 5：跨命名空间访问失败

**错误信息：**
```
dial tcp: lookup harbor-core.harbor: no such host
```

**原因：** Service 名称或命名空间错误

**解决：**
```bash
# 检查 Harbor Service 名称
kubectl get svc -n harbor

# 检查 Harbor 所在命名空间
kubectl get ns | grep harbor

# 正确的跨命名空间访问格式：
# <service-name>.<namespace>.svc.cluster.local
# 或简写为：<service-name>.<namespace>
# 例如：harbor-core.harbor

# 如果 Service 名称不是 harbor-core，需要修改
# 例如：如果是 harbor，则使用 harbor.harbor:80
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
  https://YOUR_NODE_IP:30009/api/v2.0/projects/library/repositories/demo-springboot/artifacts
# 预期输出: 镜像的 artifacts 列表

# 6. 验证集群内部访问（在集群内执行）
curl http://harbor-core.harbor/v2/
# 预期输出: {}
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
- [ ] harbor-registry-secret 是否已创建
- [ ] Secret 中的 docker-server 地址是否正确
- [ ] 项目是否已创建
- [ ] Registry Pod 是否正常

```bash
# 检查 Secret（集群内部地址）
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d

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
- ❌ RKE2 配置文件（/etc/rancher/rke2/registries.yaml、harbor-ca.crt）
- ❌ 本地证书文件（/tmp/harbor-cert）

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
sudo rm -f /etc/rancher/rke2/harbor-ca.crt
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

## 十九、附录：完整部署脚本

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

cat > san.cnf <<EOF2
[san_section]
subjectAltName = DNS:harbor-core.harbor,DNS:harbor.harbor,DNS:harbor,IP:${NODE_IP}
EOF2

openssl req -new -x509 -days 3650 \
  -key ${DOMAIN}.key \
  -out ${DOMAIN}.crt \
  -subj "/CN=${DOMAIN}/O=harbor" \
  -config <(cat /etc/ssl/openssl.cnf <(printf "\n[san_section]\n%s" "$(cat san.cnf)")) \
  -extensions san_section

echo "✓ TLS 证书生成完成"
openssl x509 -in ${DOMAIN}.crt -noout -text | grep -A 5 "Subject Alternative Name"

# 4. 创建 TLS Secret
echo ">>> 创建 TLS Secret..."
kubectl create namespace harbor 2>/dev/null || true
kubectl delete secret harbor-tls -n harbor 2>/dev/null || true
kubectl create secret tls harbor-tls \
  --cert=${DOMAIN}.crt \
  --key=${DOMAIN}.key \
  -n harbor

# 将 CA 证书添加到 Secret 中
kubectl patch secret harbor-tls -n harbor --type='json' -p='[{"op": "add", "path": "/data/ca.crt", "value": "'$(base64 -w 0 ${DOMAIN}.crt)'"}]'

echo "✓ TLS Secret 创建完成"

# 5. 配置 RKE2 节点信任 Harbor 证书（关键步骤）
echo ">>> 配置 RKE2 节点信任 Harbor 证书..."

# 复制 CA 证书到 RKE2 配置目录
sudo cp ${DOMAIN}.crt /etc/rancher/rke2/harbor-ca.crt

# 配置 containerd 使用 Harbor 证书
# 注意：harbor.harbor 的 endpoint 必须指向 NodePort，不能指向 harbor.harbor 本身
# 因为 containerd 运行在节点上，无法通过 CoreDNS 解析 harbor.harbor
sudo tee /etc/rancher/rke2/registries.yaml << REGEOF
mirrors:
  ${NODE_IP}:30009:
    endpoint:
      - https://${NODE_IP}:30009
  harbor.harbor:
    endpoint:
      - https://${NODE_IP}:30009

configs:
  ${NODE_IP}:30009:
    tls:
      ca_file: /etc/rancher/rke2/harbor-ca.crt
      insecure_skip_verify: false
  harbor.harbor:
    tls:
      ca_file: /etc/rancher/rke2/harbor-ca.crt
      insecure_skip_verify: false
REGEOF

echo "✓ registries.yaml 配置完成"

# 重启 RKE2 以加载新配置
echo ">>> 重启 RKE2 服务..."
sudo systemctl restart rke2-server
echo "等待 RKE2 启动（60秒）..."
sleep 60
sudo systemctl status rke2-server | grep Active
kubectl get nodes

echo "✓ RKE2 节点证书配置完成"

# 6. 创建配置文件
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

# 内部 TLS 配置（推荐关闭，简化配置）
internalTLS:
  enabled: false
EOF

# 7. 部署 Harbor
echo ">>> 部署 Harbor（HTTPS）..."
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-helm-values-https.yaml \
  --version 1.14.0

echo "✓ Harbor 部署完成"

# 8. 等待 Pod 就绪
echo ">>> 等待 Pod 就绪..."
kubectl wait --for=condition=ready pod \
  -l app=harbor \
  -n harbor \
  --timeout=600s || true

# 9. 显示访问信息
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

## 二十、更新 Harbor TLS 证书

> **说明**：本文档使用 `internalTLS.enabled: false`，Harbor 内部组件间通过 HTTP 通信，只有外部访问使用 HTTPS（通过 nginx 终止 TLS）。
> 更新证书只需更新外部 TLS Secret 并重启 Harbor 服务即可。

### 更新证书步骤

如果需要更新 Harbor 的 TLS 证书（例如添加新的域名或 IP 地址），请按照以下步骤操作：

```bash
# 1. 生成新的自签名证书（包含所有需要的 SANs）
cd /tmp/harbor-cert
openssl genrsa -out harbor-core.harbor.key 2048

openssl req -new -x509 -days 3650 \
  -key harbor-core.harbor.key \
  -out harbor-core.harbor.crt \
  -subj "/CN=harbor-core.harbor/O=harbor" \
  -addext "subjectAltName=DNS:harbor-core.harbor,DNS:harbor.harbor,DNS:harbor,IP:192.168.80.101"

# 2. 验证证书内容
openssl x509 -in harbor-core.harbor.crt -text -noout | grep -A1 "Subject Alternative Name"

# 3. 删除旧的 TLS Secret
kubectl delete secret harbor-tls -n harbor

# 4. 创建新的 TLS Secret
kubectl create secret tls harbor-tls \
  --cert=harbor-core.harbor.crt \
  --key=harbor-core.harbor.key \
  -n harbor

# 5. 验证 Secret 中的证书
kubectl get secret harbor-tls -n harbor -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout | grep -A1 "Subject Alternative Name"

# 6. 重启所有 Harbor 服务使新证书生效
kubectl rollout restart deployment/harbor-core -n harbor
kubectl rollout restart deployment/harbor-nginx -n harbor
kubectl rollout restart deployment/harbor-portal -n harbor
kubectl rollout restart deployment/harbor-registry -n harbor
kubectl rollout restart deployment/harbor-jobservice -n harbor

# 7. 等待所有服务重启完成
kubectl rollout status deployment/harbor-core -n harbor --timeout=120s
kubectl rollout status deployment/harbor-nginx -n harbor --timeout=120s
kubectl rollout status deployment/harbor-portal -n harbor --timeout=120s
kubectl rollout status deployment/harbor-registry -n harbor --timeout=120s
kubectl rollout status deployment/harbor-jobservice -n harbor --timeout=120s

# 8. 验证 core 使用的证书
kubectl exec -n harbor deployment/harbor-core -- cat /etc/harbor/tls/core.crt 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"

# 9. 测试访问 Harbor Registry API
curl -k -u admin:Harbor12345 https://harbor.harbor/v2/
```

### 验证证书是否生效

```bash
# 方法1: 使用 curl 测试
curl -k https://harbor.harbor/v2/_catalog

# 方法2: 使用 kubectl 检查 Pod 证书文件
kubectl exec -n harbor deployment/harbor-core -- cat /etc/harbor/tls/harbor-core.crt | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"

# 方法3: 从集群内测试镜像拉取
kubectl run test-pod --image=harbor.harbor/library/demo-springboot:latest --dry-run=client -o yaml | kubectl apply -f -
```

### 常见问题

**问题1: 证书验证失败 "x509: certificate is valid for ingress.local, not harbor.harbor"**

解决方法：
- 确认新生成的证书包含正确的 SANs（DNS:harbor.harbor）
- 确认 Secret 已经更新：`kubectl get secret harbor-tls -n harbor -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"`
- 确认所有 Harbor 服务都已重启

**问题2: Kubernetes Pod 无法拉取 Harbor 镜像**

解决方法：
- 确认 Kubernetes 节点信任 Harbor 证书
- 或者创建 docker-registry secret：
```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n <your-namespace>
```
- 在 Deployment 中添加 imagePullSecrets

---

**部署完成后，Harbor 就支持 HTTPS 了！** 🎉
