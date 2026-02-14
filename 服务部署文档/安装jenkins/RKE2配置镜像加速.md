# RKE2 配置镜像加速（containerd）

## 一、配置 containerd 镜像加速

RKE2 使用 containerd，配置文件位置：`/etc/rancher/rke2/registries.yaml`

### 1. 创建配置文件
```bash
sudo mkdir -p /etc/rancher/rke2
sudo vi /etc/rancher/rke2/registries.yaml
```

### 2. 添加镜像加速配置
```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://registry.cn-hangzhou.aliyuncs.com"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://hub-mirror.c.163.com"
  
  # 如果需要配置私有仓库
  "192.168.1.100:30500":
    endpoint:
      - "http://192.168.1.100:30500"

# 配置私有仓库（HTTP 或自签名证书）
configs:
  "192.168.1.100:30500":
    tls:
      insecure_skip_verify: true
```

### 3. 重启 RKE2
```bash
# Server 节点
sudo systemctl restart rke2-server

# Agent 节点
sudo systemctl restart rke2-agent
```

### 4. 验证配置
```bash
# 查看 containerd 配置
sudo cat /var/lib/rancher/rke2/agent/etc/containerd/config.toml | grep -A 10 registry

# 测试拉取镜像
sudo /var/lib/rancher/rke2/bin/crictl pull registry:2
```

## 二、方案选择

### 方案1：配置镜像加速（推荐）
按上面步骤配置后，使用官方镜像名：
```yaml
image: registry:2
image: joxit/docker-registry-ui:latest
```

### 方案2：使用阿里云镜像
直接在 YAML 中使用阿里云完整路径：
```yaml
image: registry.cn-hangzhou.aliyuncs.com/library/registry:2
image: registry.cn-hangzhou.aliyuncs.com/google_containers/docker-registry-ui:latest
```

### 方案3：手动导入镜像
```bash
# 在有网络的机器上导出
docker pull registry:2
docker save registry:2 -o registry.tar

docker pull joxit/docker-registry-ui:latest
docker save joxit/docker-registry-ui:latest -o registry-ui.tar

# 传输到 RKE2 节点后导入
sudo /var/lib/rancher/rke2/bin/ctr -n k8s.io images import registry.tar
sudo /var/lib/rancher/rke2/bin/ctr -n k8s.io images import registry-ui.tar
```

## 三、常用命令

### 查看镜像
```bash
# 列出所有镜像
sudo /var/lib/rancher/rke2/bin/crictl images

# 查看特定镜像
sudo /var/lib/rancher/rke2/bin/crictl images | grep registry
```

### 拉取镜像
```bash
sudo /var/lib/rancher/rke2/bin/crictl pull registry:2
```

### 删除镜像
```bash
sudo /var/lib/rancher/rke2/bin/crictl rmi <IMAGE_ID>
```

## 四、所有节点都需要配置

注意：`registries.yaml` 需要在所有 RKE2 节点（Server 和 Agent）上配置。

可以使用脚本批量配置：
```bash
#!/bin/bash
# 在所有节点执行

cat <<EOF | sudo tee /etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://registry.cn-hangzhou.aliyuncs.com"
      - "https://docker.mirrors.ustc.edu.cn"
EOF

# 重启服务
if systemctl is-active --quiet rke2-server; then
    sudo systemctl restart rke2-server
elif systemctl is-active --quiet rke2-agent; then
    sudo systemctl restart rke2-agent
fi
```
