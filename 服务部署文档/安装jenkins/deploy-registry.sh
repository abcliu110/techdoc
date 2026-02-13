#!/bin/bash
# Docker Registry 快速部署脚本

set -e

echo "=========================================="
echo "  Docker Registry 快速部署"
echo "=========================================="

# 1. 检查 kubectl
echo ""
echo ">>> 检查 kubectl..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl 未安装，请先安装 kubectl"
    exit 1
fi
echo "✓ kubectl 已安装"

# 2. 检查集群连接
echo ""
echo ">>> 检查 Kubernetes 集群连接..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 无法连接到 Kubernetes 集群"
    exit 1
fi
echo "✓ 集群连接正常"

# 3. 检查存储类
echo ""
echo ">>> 检查存储类..."
if ! kubectl get storageclass longhorn &> /dev/null; then
    echo "⚠️  警告：longhorn 存储类不存在"
    echo "可用的存储类："
    kubectl get storageclass
    echo ""
    read -p "请输入要使用的存储类名称（直接回车使用默认）: " STORAGE_CLASS
    if [ -n "$STORAGE_CLASS" ]; then
        sed -i "s/storageClassName: longhorn/storageClassName: $STORAGE_CLASS/" docker-registry-simple.yaml
    fi
else
    echo "✓ longhorn 存储类存在"
fi

# 4. 部署 Registry
echo ""
echo ">>> 部署 Docker Registry..."
kubectl apply -f docker-registry-simple.yaml

# 5. 等待 Pod 就绪
echo ""
echo ">>> 等待 Pod 启动..."
kubectl wait --for=condition=ready pod -l app=docker-registry -n docker-registry --timeout=300s

# 6. 获取访问信息
echo ""
echo "=========================================="
echo "  部署成功！"
echo "=========================================="
echo ""

# 获取 Pod 信息
POD_NAME=$(kubectl get pods -n docker-registry -l app=docker-registry -o jsonpath='{.items[0].metadata.name}')
echo "Pod 名称: $POD_NAME"

# 获取 NodePort
NODE_PORT=$(kubectl get svc docker-registry-nodeport -n docker-registry -o jsonpath='{.spec.ports[0].nodePort}')
echo "NodePort: $NODE_PORT"

# 获取节点 IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "节点 IP: $NODE_IP"

echo ""
echo "=========================================="
echo "  访问方式"
echo "=========================================="
echo ""
echo "1. 集群内访问："
echo "   http://docker-registry.docker-registry.svc.cluster.local:5000"
echo ""
echo "2. 外部访问（NodePort）："
echo "   http://$NODE_IP:$NODE_PORT"
echo ""
echo "3. 测试访问："
echo "   curl http://$NODE_IP:$NODE_PORT/v2/"
echo "   应该返回: {}"
echo ""

# 7. 配置节点信任仓库（HTTP）
echo "=========================================="
echo "  配置节点信任仓库"
echo "=========================================="
echo ""
echo "由于使用 HTTP（无 TLS），需要在每个 RKE2 节点上配置："
echo ""
echo "cat <<EOF > /etc/rancher/rke2/registries.yaml"
echo "mirrors:"
echo "  \"$NODE_IP:$NODE_PORT\":"
echo "    endpoint:"
echo "      - \"http://$NODE_IP:$NODE_PORT\""
echo "configs:"
echo "  \"$NODE_IP:$NODE_PORT\":"
echo "    tls:"
echo "      insecure_skip_verify: true"
echo "EOF"
echo ""
echo "然后重启 RKE2："
echo "systemctl restart rke2-server  # 或 rke2-agent"
echo ""

# 8. 测试推送
echo "=========================================="
echo "  测试推送镜像"
echo "=========================================="
echo ""
echo "# 1. 拉取测试镜像"
echo "docker pull nginx:alpine"
echo ""
echo "# 2. 打标签"
echo "docker tag nginx:alpine $NODE_IP:$NODE_PORT/nginx:alpine"
echo ""
echo "# 3. 推送镜像"
echo "docker push $NODE_IP:$NODE_PORT/nginx:alpine"
echo ""
echo "# 4. 查看仓库中的镜像"
echo "curl http://$NODE_IP:$NODE_PORT/v2/_catalog"
echo ""

echo "=========================================="
echo "  部署完成！"
echo "=========================================="
