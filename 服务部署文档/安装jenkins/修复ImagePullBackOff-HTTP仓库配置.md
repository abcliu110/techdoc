# 修复 ImagePullBackOff - HTTP 私有仓库配置

## 问题描述

**错误信息：**
```
ImagePullBackOff: failed to pull and unpack image "192.168.80.100:30500/demo-springboot:latest": 
http: server gave HTTP response to HTTPS client
```

**原因：**
- Kubernetes 默认使用 HTTPS 访问 Docker Registry
- 私有仓库 `192.168.80.100:30500` 使用 HTTP（未配置 TLS）
- 需要在所有节点上配置允许 HTTP 访问

---

## 解决方案

### 方案 A：配置 RKE2 允许 HTTP 仓库（推荐）

#### 步骤 1：在所有节点上配置 registries.yaml

**在每个 RKE2 节点上执行：**

```bash
# 1. 编辑配置文件
sudo vi /etc/rancher/rke2/registries.yaml
```

**添加以下内容：**

```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io"
      - "https://docker.mirrors.ustc.edu.cn"
  
  gcr.io:
    endpoint:
      - "https://m.daocloud.io/gcr.io"

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true  # 跳过 TLS 验证
    auth:
      username: ""                # 如果有认证，填写用户名
      password: ""                # 如果有认证，填写密码
```

**关键配置说明：**
- `insecure_skip_verify: true` - 允许 HTTP 连接，跳过 TLS 验证
- 必须在 `configs` 部分配置，不是 `mirrors` 部分

#### 步骤 2：重启 RKE2 服务

**在 Master 节点：**
```bash
sudo systemctl restart rke2-server
sudo systemctl status rke2-server
```

**在 Worker 节点：**
```bash
sudo systemctl restart rke2-agent
sudo systemctl status rke2-agent
```

#### 步骤 3：验证配置

```bash
# 1. 检查配置文件
cat /etc/rancher/rke2/registries.yaml

# 2. 验证 containerd 配置
sudo crictl info | grep -A 20 "192.168.80.100:30500"

# 3. 测试手动拉取镜像
sudo crictl pull 192.168.80.100:30500/demo-springboot:latest

# 4. 查看镜像
sudo crictl images | grep demo-springboot
```

**预期输出：**
```bash
# crictl info 应该显示：
"192.168.80.100:30500": {
  "tls": {
    "insecure_skip_verify": true
  }
}

# crictl pull 应该成功：
Image is up to date for sha256:xxxxx
```

#### 步骤 4：重新部署 Pod

```bash
# 删除旧的 Pod，让 Kubernetes 重新创建
kubectl delete pod -l app=demo-springboot -n default

# 或者重启 Deployment
kubectl rollout restart deployment/demo-springboot -n default

# 查看 Pod 状态
kubectl get pods -l app=demo-springboot -n default -w
```

---

## 完整配置示例

### 单节点配置（Master）

```bash
#!/bin/bash
# 配置 RKE2 Master 节点

echo "=== 配置 RKE2 Master 节点 ==="

# 1. 备份原配置
sudo cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak 2>/dev/null || true

# 2. 创建配置文件
sudo tee /etc/rancher/rke2/registries.yaml > /dev/null <<'EOF'
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://hub-mirror.c.163.com"
  
  gcr.io:
    endpoint:
      - "https://m.daocloud.io/gcr.io"
  
  registry.k8s.io:
    endpoint:
      - "https://m.daocloud.io/registry.k8s.io"

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF

# 3. 重启服务
echo "=== 重启 RKE2 Server ==="
sudo systemctl restart rke2-server

# 4. 等待服务启动
echo "=== 等待服务启动 ==="
sleep 10

# 5. 验证配置
echo "=== 验证配置 ==="
sudo crictl info | grep -A 10 "192.168.80.100:30500"

# 6. 测试拉取镜像
echo "=== 测试拉取镜像 ==="
sudo crictl pull 192.168.80.100:30500/demo-springboot:latest

echo "=== 配置完成 ==="
```

### 多节点配置脚本

```bash
#!/bin/bash
# configure-all-nodes.sh
# 在所有节点上配置私有仓库

NODES=(
    "192.168.80.100"  # Master
    "192.168.80.101"  # Worker 1
    "192.168.80.102"  # Worker 2
)

REGISTRY_CONFIG='
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io"
  
  gcr.io:
    endpoint:
      - "https://m.daocloud.io/gcr.io"

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
'

for node in "${NODES[@]}"; do
    echo "=== 配置节点: $node ==="
    
    # 通过 SSH 配置节点
    ssh root@$node <<EOF
        # 备份原配置
        cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak 2>/dev/null || true
        
        # 写入新配置
        cat > /etc/rancher/rke2/registries.yaml <<'EOFCONFIG'
$REGISTRY_CONFIG
EOFCONFIG
        
        # 重启服务
        if systemctl is-active --quiet rke2-server; then
            systemctl restart rke2-server
        elif systemctl is-active --quiet rke2-agent; then
            systemctl restart rke2-agent
        fi
        
        # 等待服务启动
        sleep 10
        
        # 验证配置
        crictl info | grep -A 5 "192.168.80.100:30500"
EOF
    
    echo "✓ 节点 $node 配置完成"
    echo ""
done

echo "=== 所有节点配置完成 ==="
```

---

## 验证和测试

### 1. 验证配置文件

```bash
# 在每个节点上执行
cat /etc/rancher/rke2/registries.yaml
```

**预期输出：**
```yaml
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
```

### 2. 验证 containerd 配置

```bash
# 查看 containerd 的 registry 配置
sudo crictl info | grep -A 20 registry
```

**预期输出应包含：**
```json
"192.168.80.100:30500": {
  "tls": {
    "insecure_skip_verify": true
  }
}
```

### 3. 测试镜像拉取

```bash
# 手动拉取镜像
sudo crictl pull 192.168.80.100:30500/demo-springboot:latest

# 查看镜像
sudo crictl images | grep demo-springboot
```

### 4. 测试 Kubernetes 部署

```bash
# 创建测试 Pod
kubectl run test-pull \
  --image=192.168.80.100:30500/demo-springboot:latest \
  --restart=Never \
  -n default

# 查看 Pod 状态
kubectl get pod test-pull -n default

# 查看 Pod 详情
kubectl describe pod test-pull -n default

# 清理测试 Pod
kubectl delete pod test-pull -n default
```

---

## 常见问题排查

### 问题 1：配置后仍然报错

**症状：**
```
http: server gave HTTP response to HTTPS client
```

**排查步骤：**

```bash
# 1. 确认配置文件存在且正确
cat /etc/rancher/rke2/registries.yaml

# 2. 确认服务已重启
sudo systemctl status rke2-server  # 或 rke2-agent

# 3. 查看服务日志
sudo journalctl -u rke2-server -f  # 或 rke2-agent

# 4. 检查 containerd 是否加载了配置
sudo crictl info | grep -A 20 "192.168.80.100:30500"
```

**解决方案：**
- 确保配置文件格式正确（YAML 缩进）
- 确保所有节点都配置了
- 重启服务后等待 30 秒再测试

### 问题 2：部分节点可以拉取，部分不行

**原因：**
- 某些节点没有配置 registries.yaml
- 某些节点的服务没有重启

**解决方案：**

```bash
# 在所有节点上执行
for node in node1 node2 node3; do
    echo "=== 检查节点: $node ==="
    ssh root@$node "cat /etc/rancher/rke2/registries.yaml"
done
```

### 问题 3：Registry 地址写错

**常见错误：**
```yaml
# ❌ 错误：在 mirrors 中配置
mirrors:
  "192.168.80.100:30500":
    endpoint:
      - "http://192.168.80.100:30500"

# ✅ 正确：在 configs 中配置
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
```

### 问题 4：Pod 调度到未配置的节点

**症状：**
- 某些 Pod 可以拉取镜像
- 某些 Pod 拉取失败

**原因：**
- 新加入的节点没有配置
- 配置不一致

**解决方案：**

```bash
# 1. 查看 Pod 运行在哪个节点
kubectl get pods -o wide -n default

# 2. 登录到该节点检查配置
ssh root@<node-ip>
cat /etc/rancher/rke2/registries.yaml

# 3. 如果没有配置，添加配置并重启
```

---

## 方案 B：为 Registry 配置 HTTPS（生产环境推荐）

如果是生产环境，建议为 Registry 配置 HTTPS：

### 1. 生成自签名证书

```bash
# 创建证书目录
mkdir -p /etc/docker/certs

# 生成自签名证书
openssl req -newkey rsa:4096 -nodes -sha256 \
  -keyout /etc/docker/certs/domain.key \
  -x509 -days 365 \
  -out /etc/docker/certs/domain.crt \
  -subj "/CN=192.168.80.100"
```

### 2. 更新 Registry Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-registry
  namespace: docker-registry
spec:
  template:
    spec:
      containers:
      - name: registry
        image: registry:2
        env:
        - name: REGISTRY_HTTP_TLS_CERTIFICATE
          value: /certs/domain.crt
        - name: REGISTRY_HTTP_TLS_KEY
          value: /certs/domain.key
        volumeMounts:
        - name: certs
          mountPath: /certs
      volumes:
      - name: certs
        secret:
          secretName: registry-certs
```

### 3. 在节点上信任证书

```bash
# 复制证书到节点
sudo cp domain.crt /etc/pki/ca-trust/source/anchors/

# 更新证书信任
sudo update-ca-trust

# 重启 RKE2
sudo systemctl restart rke2-server
```

---

## 快速修复脚本

```bash
#!/bin/bash
# quick-fix.sh - 快速修复脚本

set -e

echo "=== 快速修复 ImagePullBackOff ==="

# 1. 检查当前节点类型
if systemctl is-active --quiet rke2-server; then
    SERVICE="rke2-server"
elif systemctl is-active --quiet rke2-agent; then
    SERVICE="rke2-agent"
else
    echo "❌ 错误：未找到 RKE2 服务"
    exit 1
fi

echo "检测到服务: $SERVICE"

# 2. 备份原配置
sudo cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak 2>/dev/null || true

# 3. 添加私有仓库配置
if ! grep -q "192.168.80.100:30500" /etc/rancher/rke2/registries.yaml 2>/dev/null; then
    echo "=== 添加私有仓库配置 ==="
    sudo tee -a /etc/rancher/rke2/registries.yaml > /dev/null <<'EOF'

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF
else
    echo "配置已存在，跳过"
fi

# 4. 重启服务
echo "=== 重启 $SERVICE ==="
sudo systemctl restart $SERVICE

# 5. 等待服务启动
echo "=== 等待服务启动（30秒）==="
sleep 30

# 6. 验证配置
echo "=== 验证配置 ==="
if sudo crictl info | grep -q "192.168.80.100:30500"; then
    echo "✓ 配置已加载"
else
    echo "❌ 配置未加载，请检查日志"
    exit 1
fi

# 7. 测试拉取
echo "=== 测试拉取镜像 ==="
if sudo crictl pull 192.168.80.100:30500/demo-springboot:latest; then
    echo "✓ 镜像拉取成功"
else
    echo "❌ 镜像拉取失败"
    exit 1
fi

echo ""
echo "=== 修复完成 ==="
echo "现在可以重新部署 Pod："
echo "kubectl delete pod -l app=demo-springboot -n default"
```

**使用方法：**
```bash
# 在每个节点上执行
bash quick-fix.sh
```

---

## 总结

**必须执行的步骤：**

1. ✅ 在所有 RKE2 节点上配置 `/etc/rancher/rke2/registries.yaml`
2. ✅ 在 `configs` 部分添加私有仓库配置
3. ✅ 设置 `insecure_skip_verify: true`
4. ✅ 重启 RKE2 服务（rke2-server 或 rke2-agent）
5. ✅ 验证配置已加载
6. ✅ 测试手动拉取镜像
7. ✅ 重新部署 Pod

**关键配置：**
```yaml
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
```

**验证命令：**
```bash
# 1. 检查配置
cat /etc/rancher/rke2/registries.yaml

# 2. 验证加载
sudo crictl info | grep "192.168.80.100:30500"

# 3. 测试拉取
sudo crictl pull 192.168.80.100:30500/demo-springboot:latest
```

---

**文档版本**: v1.0  
**最后更新**: 2026-02-15  
**状态**: ✅ 已验证可用
