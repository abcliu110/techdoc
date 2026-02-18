#!/bin/bash
# 在所有Kubernetes节点上预先拉取基础镜像

# 基础镜像列表
IMAGES=(
    "eclipse-temurin:21-jre"
    "maven:3.9-eclipse-temurin-21"
)

echo "开始在所有节点上拉取基础镜像..."

# 获取所有节点
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for IMAGE in "${IMAGES[@]}"; do
    echo ""
    echo "=========================================="
    echo "拉取镜像: $IMAGE"
    echo "=========================================="

    for NODE in $NODES; do
        echo ">>> 节点: $NODE"

        # 使用DaemonSet在每个节点上拉取镜像
        kubectl run pull-image-$RANDOM \
            --image=$IMAGE \
            --restart=Never \
            --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"'$NODE'"}}}' \
            --command -- sleep 1

        sleep 2
        kubectl delete pod -l run=pull-image --force --grace-period=0 2>/dev/null
    done
done

echo ""
echo "✓ 所有镜像已拉取到集群节点"
echo ""
echo "验证命令："
echo "kubectl get nodes -o wide"
echo "ssh <node> 'crictl images | grep eclipse-temurin'"
