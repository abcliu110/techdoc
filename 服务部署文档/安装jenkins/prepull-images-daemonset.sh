#!/bin/bash
# 在所有Kubernetes节点上预拉取基础镜像

set -e

echo "=========================================="
echo "预拉取基础镜像到所有节点"
echo "=========================================="
echo ""

# 基础镜像列表
IMAGES=(
    "eclipse-temurin:21-jre"
    "maven:3.9-eclipse-temurin-21"
)

# 获取所有节点
echo ">>> 获取Kubernetes节点列表"
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

if [ -z "$NODES" ]; then
    echo "❌ 未找到任何节点"
    exit 1
fi

echo "找到节点:"
echo "$NODES" | tr ' ' '\n' | sed 's/^/  - /'
echo ""

# 为每个镜像创建DaemonSet
for IMAGE in "${IMAGES[@]}"; do
    IMAGE_NAME=$(echo "$IMAGE" | tr ':/' '-')
    DAEMONSET_NAME="pull-image-${IMAGE_NAME}"

    echo "=========================================="
    echo "拉取镜像: $IMAGE"
    echo "=========================================="

    # 创建DaemonSet
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ${DAEMONSET_NAME}
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: ${DAEMONSET_NAME}
  template:
    metadata:
      labels:
        app: ${DAEMONSET_NAME}
    spec:
      initContainers:
      - name: pull-image
        image: ${IMAGE}
        command: ['sh', '-c', 'echo "Image ${IMAGE} pulled successfully"']
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.9
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
          limits:
            cpu: 10m
            memory: 10Mi
      tolerations:
      - operator: Exists
EOF

    echo "✓ DaemonSet已创建: ${DAEMONSET_NAME}"
    echo ""

    # 等待所有Pod就绪
    echo ">>> 等待镜像拉取完成..."
    kubectl rollout status daemonset/${DAEMONSET_NAME} -n kube-system --timeout=300s

    echo "✓ 镜像已拉取到所有节点"
    echo ""

    # 删除DaemonSet
    echo ">>> 清理DaemonSet"
    kubectl delete daemonset ${DAEMONSET_NAME} -n kube-system

    echo "✓ 清理完成"
    echo ""
done

echo "=========================================="
echo "所有镜像已拉取完成"
echo "=========================================="
echo ""
echo "验证命令（在任意节点上执行）："
echo "  crictl images | grep eclipse-temurin"
echo "  crictl images | grep maven"
echo ""
