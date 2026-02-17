#!/bin/bash
# Harbor 在 RKE2 上的部署脚本
# 使用 Helm Chart 部署

set -e

echo "=========================================="
echo "Harbor 部署脚本 for RKE2"
echo "=========================================="

# ==================== 配置参数 ====================
HARBOR_NAMESPACE="harbor"
HARBOR_RELEASE_NAME="harbor"
HARBOR_VERSION="1.14.0"  # Harbor Chart 版本
HARBOR_VALUES_FILE="harbor-values.yaml"

# 节点 IP（修改为你的节点 IP）
NODE_IP="192.168.80.100"
HARBOR_PORT="30002"

# ==================== 检查前置条件 ====================
echo ""
echo ">>> 检查前置条件"

# 检查 kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl 未安装"
    exit 1
fi
echo "✓ kubectl 已安装"

# 检查 helm
if ! command -v helm &> /dev/null; then
    echo "❌ helm 未安装"
    echo ">>> 安装 Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
echo "✓ helm 已安装"

# 检查 Kubernetes 连接
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 无法连接到 Kubernetes 集群"
    exit 1
fi
echo "✓ Kubernetes 集群连接正常"

# ==================== 添加 Harbor Helm 仓库 ====================
echo ""
echo ">>> 添加 Harbor Helm 仓库"
helm repo add harbor https://helm.goharbor.io
helm repo update
echo "✓ Harbor Helm 仓库已添加"

# ==================== 创建命名空间 ====================
echo ""
echo ">>> 创建命名空间: $HARBOR_NAMESPACE"
kubectl create namespace $HARBOR_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo "✓ 命名空间已创建"

# ==================== 检查配置文件 ====================
echo ""
echo ">>> 检查配置文件"
if [ ! -f "$HARBOR_VALUES_FILE" ]; then
    echo "❌ 配置文件不存在: $HARBOR_VALUES_FILE"
    exit 1
fi
echo "✓ 配置文件存在: $HARBOR_VALUES_FILE"

# ==================== 部署 Harbor ====================
echo ""
echo ">>> 部署 Harbor"
echo "命名空间: $HARBOR_NAMESPACE"
echo "Release 名称: $HARBOR_RELEASE_NAME"
echo "Chart 版本: $HARBOR_VERSION"
echo "配置文件: $HARBOR_VALUES_FILE"
echo ""

helm upgrade --install $HARBOR_RELEASE_NAME harbor/harbor \
    --namespace $HARBOR_NAMESPACE \
    --version $HARBOR_VERSION \
    --values $HARBOR_VALUES_FILE \
    --wait \
    --timeout 10m

echo "✓ Harbor 部署完成"

# ==================== 等待 Pod 就绪 ====================
echo ""
echo ">>> 等待 Harbor Pod 就绪（可能需要 3-5 分钟）"
kubectl wait --for=condition=ready pod \
    -l app=harbor \
    -n $HARBOR_NAMESPACE \
    --timeout=600s || true

# ==================== 显示部署状态 ====================
echo ""
echo "=========================================="
echo "Harbor 部署状态"
echo "=========================================="

echo ""
echo ">>> Pod 状态:"
kubectl get pods -n $HARBOR_NAMESPACE

echo ""
echo ">>> Service 状态:"
kubectl get svc -n $HARBOR_NAMESPACE

echo ""
echo ">>> PVC 状态:"
kubectl get pvc -n $HARBOR_NAMESPACE

# ==================== 显示访问信息 ====================
echo ""
echo "=========================================="
echo "Harbor 访问信息"
echo "=========================================="
echo ""
echo "Harbor UI 地址: http://$NODE_IP:$HARBOR_PORT"
echo "用户名: admin"
echo "密码: Harbor12345"
echo ""
echo "Docker 登录命令:"
echo "  docker login $NODE_IP:$HARBOR_PORT"
echo ""
echo "Kubernetes Secret 创建命令:"
echo "  kubectl create secret docker-registry harbor-registry-secret \\"
echo "    --docker-server=$NODE_IP:$HARBOR_PORT \\"
echo "    --docker-username=admin \\"
echo "    --docker-password=Harbor12345 \\"
echo "    --namespace=jenkins"
echo ""

# ==================== 配置 RKE2 信任 Harbor ====================
echo "=========================================="
echo "配置 RKE2 信任 Harbor（HTTP）"
echo "=========================================="
echo ""
echo "在每个 RKE2 节点上执行以下命令:"
echo ""
cat <<'EOF'
# 1. 创建 registries.yaml 配置文件
sudo mkdir -p /etc/rancher/rke2
sudo tee /etc/rancher/rke2/registries.yaml > /dev/null <<YAML
mirrors:
  "NODE_IP:30002":
    endpoint:
      - "http://NODE_IP:30002"
configs:
  "NODE_IP:30002":
    tls:
      insecure_skip_verify: true
YAML

# 2. 重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent

# 3. 验证配置
sudo crictl info | grep -A 10 registry
EOF

echo ""
echo "注意: 将 NODE_IP 替换为实际的节点 IP: $NODE_IP"
echo ""

# ==================== 完成 ====================
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo ""
echo "下一步:"
echo "1. 访问 Harbor UI: http://$NODE_IP:$HARBOR_PORT"
echo "2. 使用 admin/Harbor12345 登录"
echo "3. 创建项目: nms4cloud"
echo "4. 配置 RKE2 信任 Harbor（见上面的命令）"
echo "5. 更新 Jenkinsfile 使用 Harbor"
echo ""
