#!/bin/bash
# 更新 Registry 配置

echo "=== 1. 应用新配置 ==="
kubectl apply -f registry-with-proxy.yaml

echo ""
echo "=== 2. 重启 Registry ==="
kubectl rollout restart deployment/docker-registry -n docker-registry

echo ""
echo "=== 3. 等待 Registry 就绪 ==="
kubectl rollout status deployment/docker-registry -n docker-registry

echo ""
echo "=== 4. 查看 Registry 环境变量 ==="
kubectl exec -n docker-registry deployment/docker-registry -- env | grep REGISTRY

echo ""
echo "=== 5. 测试 Registry API ==="
curl -v http://192.168.80.100:30500/v2/ 2>&1 | grep -E "(HTTP|Location)"

echo ""
echo "✓ Registry 更新完成！"
