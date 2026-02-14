# 配置 Jenkins Agent (jnlp) 镜像

## 问题

默认的 jnlp 镜像 `jenkins/inbound-agent` 来自 Docker Hub，国内无法访问。

## 解决方案

### 方案 1：在 Kubernetes Cloud 配置中修改（推荐）

#### 步骤 1：进入配置页面

```
Jenkins 首页
→ 系统管理 (Manage Jenkins)
→ 节点管理 (Manage Nodes and Clouds)
→ Configure Clouds
→ Kubernetes
```

#### 步骤 2：展开高级配置

向下滚动，找到 "Pod Templates" 部分，点击 "Add Pod Template"

或者找到 "Images" 或 "Container Template" 配置

#### 步骤 3：配置 jnlp 容器

```
Name: jnlp
Docker image: swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/jenkins/inbound-agent:latest
```

或者使用其他可用镜像：
- `dockerproxy.com/jenkins/inbound-agent:latest`
- `192.168.80.100:30500/jenkins/inbound-agent:latest` (私有仓库)

#### 步骤 4：保存

点击 "Save" 保存配置

### 方案 2：配置 RKE2 镜像加速（全局生效）

在所有 RKE2 节点上配置：

```bash
# 编辑 /etc/rancher/rke2/registries.yaml
sudo tee /etc/rancher/rke2/registries.yaml <<EOF
mirrors:
  docker.io:
    endpoint:
      - "https://swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io"
      - "https://dockerproxy.com"
  gcr.io:
    endpoint:
      - "https://swr.cn-north-4.myhuaweicloud.com/ddn-k8s/gcr.io"
EOF

# 重启 RKE2
sudo systemctl restart rke2-server
# 或
sudo systemctl restart rke2-agent
```

配置后，所有镜像拉取都会自动使用镜像加速。

### 方案 3：使用私有仓库（最稳定）

#### 步骤 1：在有外网的机器上准备镜像

```bash
# 拉取镜像
docker pull jenkins/inbound-agent:latest

# 重新打标签
docker tag jenkins/inbound-agent:latest \
  192.168.80.100:30500/jenkins/inbound-agent:latest

# 推送到私有仓库
docker push 192.168.80.100:30500/jenkins/inbound-agent:latest
```

#### 步骤 2：在 Kubernetes Cloud 配置中使用私有仓库镜像

```
Docker image: 192.168.80.100:30500/jenkins/inbound-agent:latest
```

## 验证配置

### 方法 1：查看 Pod 日志

触发一次构建，查看 Pod 创建情况：

```bash
kubectl get pods -n jenkins -w
```

### 方法 2：查看 jnlp 容器日志

```bash
kubectl logs <pod-name> -n jenkins -c jnlp
```

如果看到类似以下内容说明连接成功：

```
INFO: Connected
```

## 当前推荐配置

### 短期方案（快速测试）

在 Kubernetes Cloud 配置中设置：

```
Docker image: swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/jenkins/inbound-agent:latest
```

### 长期方案（生产环境）

1. 将镜像推送到私有仓库
2. 在 Kubernetes Cloud 配置中使用私有仓库镜像
3. 配置 RKE2 镜像加速作为备用

## 常见问题

### Q: jnlp 容器一直重启

A: 检查 Jenkins URL 配置是否正确

```
Kubernetes Cloud 配置
→ Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
→ Jenkins tunnel: jenkins.jenkins.svc.cluster.local:50000
```

### Q: jnlp 容器启动后立即退出

A: 可能是镜像版本不匹配，尝试使用 `latest` 标签或指定具体版本

### Q: 无法连接到 Jenkins Master

A: 检查网络连通性

```bash
# 在 Pod 中测试
kubectl exec -it <pod-name> -n jenkins -c jnlp -- /bin/sh
curl http://jenkins.jenkins.svc.cluster.local:8080
```

## 完成后

配置完成后，重新触发 Jenkins 构建，jnlp 容器应该能正常启动并连接到 Jenkins Master。
