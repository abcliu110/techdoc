# Docker Registry + Web UI 部署说明

## 一、部署步骤

### 1. 部署 Registry + UI
```bash
kubectl apply -f docker-registry-with-ui.yaml
```

### 2. 检查部署状态
```bash
# 查看 Pod 状态
kubectl get pods -n docker-registry

# 查看 Service
kubectl get svc -n docker-registry
```

### 3. 访问地址
- **Web UI**: `http://<节点IP>:30501`
- **Registry API**: `http://<节点IP>:30500`

## 二、配置 Docker 客户端

### 1. 配置 insecure-registry（HTTP 访问）
编辑 `/etc/docker/daemon.json`：
```json
{
  "insecure-registries": ["<节点IP>:30500"]
}
```

重启 Docker：
```bash
systemctl restart docker
```

### 2. 推送镜像测试
```bash
# 拉取测试镜像
docker pull nginx:alpine

# 打标签
docker tag nginx:alpine <节点IP>:30500/nginx:alpine

# 推送到私有仓库
docker push <节点IP>:30500/nginx:alpine

# 从私有仓库拉取
docker pull <节点IP>:30500/nginx:alpine
```

## 三、Web UI 功能

访问 `http://<节点IP>:30501` 后可以：

1. **浏览镜像列表** - 查看所有已推送的镜像
2. **查看镜像标签** - 点击镜像查看所有版本标签
3. **查看镜像详情** - 查看层信息、大小、创建时间等
4. **删除镜像** - 删除不需要的镜像或标签
5. **搜索镜像** - 快速查找镜像

## 四、K8s 中使用私有镜像

### 方法1：直接使用（无认证）
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: nginx
    image: <节点IP>:30500/nginx:alpine
```

### 方法2：配置节点 Docker（推荐）
在所有 K8s 节点上配置 insecure-registries，Pod 就能直接拉取镜像。

## 五、常见问题

### 1. UI 无法连接 Registry
检查 Registry Service 是否正常：
```bash
kubectl get svc docker-registry -n docker-registry
```

### 2. 无法推送镜像
确认已配置 `insecure-registries` 并重启 Docker。

### 3. UI 显示空白
检查浏览器控制台，可能是跨域问题。Registry 已配置 CORS 头。

### 4. 删除镜像失败
确认 Registry 环境变量 `REGISTRY_STORAGE_DELETE_ENABLED=true` 已设置。

## 六、升级到 HTTPS（可选）

如果需要 HTTPS 访问，可以：
1. 使用 Ingress + TLS 证书
2. 配置 Registry 的 TLS 证书
3. 使用反向代理（Nginx）

## 七、清理
```bash
kubectl delete -f docker-registry-with-ui.yaml
```
