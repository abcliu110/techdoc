#!/bin/bash
# 快速诊断脚本 - 检查 Harbor 各组件状态

echo "=== Harbor 组件状态 ==="
kubectl get pods -n harbor 2>/dev/null || echo "Harbor 命名空间不存在"

echo ""
echo "=== 检查镜像是否可以拉取 ==="
echo "测试 goharbor 镜像..."
kubectl run test-harbor --image=goharbor/harbor-core:v2.10.0 --restart=Never -n default --dry-run=client 2>&1 | head -5

echo ""
echo "=== 如果上面显示镜像问题，尝试使用国内镜像源 ==="
echo "建议：修改 harbor-deployment.yaml 使用 DaoCloud 镜像加速"
