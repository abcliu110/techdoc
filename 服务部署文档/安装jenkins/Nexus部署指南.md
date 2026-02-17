# Nexus Repository 部署指南

## 简介

Nexus Repository 是一个企业级的仓库管理器，支持：
- ✅ Docker 镜像仓库
- ✅ Maven、npm、PyPI 等多种仓库
- ✅ 完整的 Web UI 界面
- ✅ 比 Harbor 更简单，单个容器运行
- ✅ 企业级功能（权限管理、审计日志等）

## 部署步骤

### 1. 删除之前的 Harbor 部署

```bash
kubectl delete namespace harbor
```

### 2. 部署 Nexus

```bash
kubectl apply -f nexus-deployment.yaml
```

### 3. 等待 Nexus 启动（约 2-3 分钟）

```bash
# 查看 Pod 状态
kubectl get pods -n nexus -w

# 查看日志
kubectl logs -n nexus -l app=nexus -f
```

当看到 `Started Sonatype Nexus` 日志时，表示启动成功。

### 4. 获取初始管理员密码

```bash
# 获取 Pod 名称
POD_NAME=$(kubectl get pods -n nexus -l app=nexus -o jsonpath='{.items[0].metadata.name}')

# 获取初始密码
kubectl exec -n nexus $POD_NAME -- cat /nexus-data/admin.password
```

复制显示的密码（类似：`a1b2c3d4-e5f6-7890-abcd-ef1234567890`）

### 5. 访问 Nexus Web UI

打开浏览器访问：`http://<节点IP>:30002`

- 用户名：`admin`
- 密码：上一步获取的密码

### 6. 首次登录配置

1. 点击右上角 "Sign in" 登录
2. 输入用户名 `admin` 和初始密码
3. 按照向导设置新密码（建议：`Nexus12345`）
4. 选择 "Enable anonymous access"（允许匿名访问）
5. 完成配置

## 配置 Docker Registry

### 1. 创建 Docker Hosted Repository

1. 登录 Nexus Web UI
2. 点击顶部齿轮图标 ⚙️ → Repositories
3. 点击 "Create repository"
4. 选择 "docker (hosted)"
5. 配置：
   - Name: `docker-hosted`
   - HTTP: 勾选，端口填 `5000`
   - Allow anonymous docker pull: 勾选
   - Deployment policy: `Allow redeploy`
6. 点击 "Create repository"

### 2. 配置 Docker 客户端

在需要推送镜像的机器上：

```bash
# 编辑 /etc/docker/daemon.json
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["<节点IP>:30005"]
}
EOF

# 重启 Docker
sudo systemctl restart docker
```

### 3. 登录 Nexus Docker Registry

```bash
docker login <节点IP>:30005
# 用户名: admin
# 密码: Nexus12345（你设置的新密码）
```

### 4. 推送镜像测试

```bash
# 标记镜像
docker tag myimage:latest <节点IP>:30005/myimage:latest

# 推送镜像
docker push <节点IP>:30005/myimage:latest
```

### 5. 在 Web UI 查看镜像

1. 登录 Nexus Web UI
2. 点击 "Browse" → "docker-hosted"
3. 可以看到刚推送的镜像

## 配置 Jenkins 使用 Nexus

### 方法 1: 修改 Jenkinsfile 环境变量

```groovy
environment {
    DOCKER_REGISTRY = '<节点IP>:30005'
    DOCKER_NAMESPACE = ''  // Nexus 不需要 namespace
}
```

### 方法 2: 创建 Nexus 凭证

1. Jenkins → Manage Jenkins → Credentials
2. 添加 Username with password
   - Username: `admin`
   - Password: `Nexus12345`
   - ID: `nexus-registry`

3. 在 Jenkinsfile 中使用：

```groovy
stage('构建并推送 Docker 镜像') {
    steps {
        container('kaniko') {
            script {
                sh """
                    /kaniko/executor \\
                        --context=${buildContext} \\
                        --dockerfile=${dockerfilePath} \\
                        --destination=<节点IP>:30005/${moduleName}:${TAG} \\
                        --insecure \\
                        --skip-tls-verify
                """
            }
        }
    }
}
```

## 配置 RKE2 使用 Nexus

在每个 RKE2 节点上：

```bash
# 创建 registries.yaml
sudo mkdir -p /etc/rancher/rke2
sudo tee /etc/rancher/rke2/registries.yaml > /dev/null <<EOF
mirrors:
  "<节点IP>:30005":
    endpoint:
      - "http://<节点IP>:30005"
configs:
  "<节点IP>:30005":
    auth:
      username: admin
      password: Nexus12345
    tls:
      insecure_skip_verify: true
EOF

# 重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent
```

## 管理功能

### 查看镜像

Web UI → Browse → docker-hosted

### 删除镜像

1. 找到要删除的镜像
2. 点击镜像名称
3. 点击 "Delete component"

### 查看存储使用

Web UI → Administration → System → Blob Stores

### 配置清理策略

Web UI → Administration → Repository → Cleanup Policies

可以配置自动删除旧镜像。

## 性能对比

| 指标 | 阿里云个人版 | Nexus 本地 |
|------|-------------|-----------|
| 推送速度 | 0.5-1 MB/s | 100-1000 MB/s |
| 推送 200MB | 3-7 分钟 | 2-20 秒 |
| 13 个模块 | 2-6.5 小时 | 2-13 分钟 |
| 速度提升 | - | **100-1000 倍** |

## 故障排查

### Nexus Pod 无法启动

```bash
kubectl describe pod -n nexus -l app=nexus
kubectl logs -n nexus -l app=nexus --tail=100
```

### 无法访问 Web UI

1. 检查 Pod 是否 Running
2. 检查防火墙是否开放 30002 端口
3. 等待 2-3 分钟让 Nexus 完全启动

### 无法推送镜像

1. 确认已创建 docker-hosted repository
2. 确认 HTTP 端口设置为 5000
3. 确认 Docker daemon.json 配置正确
4. 确认已登录：`docker login <节点IP>:30005`

### 忘记密码

```bash
# 重置为初始密码
kubectl exec -n nexus $POD_NAME -- rm -f /nexus-data/admin.password
kubectl delete pod -n nexus -l app=nexus
# 等待 Pod 重启，重新获取初始密码
```

## 备份和恢复

### 备份

```bash
# 备份 Nexus 数据
kubectl exec -n nexus $POD_NAME -- tar czf /tmp/nexus-backup.tar.gz /nexus-data
kubectl cp nexus/$POD_NAME:/tmp/nexus-backup.tar.gz ./nexus-backup.tar.gz
```

### 恢复

```bash
# 恢复 Nexus 数据
kubectl cp ./nexus-backup.tar.gz nexus/$POD_NAME:/tmp/
kubectl exec -n nexus $POD_NAME -- tar xzf /tmp/nexus-backup.tar.gz -C /
kubectl delete pod -n nexus -l app=nexus
```

## 升级

```bash
# 修改 nexus-deployment.yaml 中的镜像版本
# 然后重新应用
kubectl apply -f nexus-deployment.yaml
```

## 卸载

```bash
kubectl delete -f nexus-deployment.yaml
kubectl delete namespace nexus
```

## 优势总结

✅ **简单** - 单个容器，无复杂依赖
✅ **稳定** - 企业级产品，久经考验
✅ **功能全** - 完整的 Web UI 和管理功能
✅ **多仓库** - 支持 Docker、Maven、npm 等
✅ **快速** - 本地推送速度快 100-1000 倍
