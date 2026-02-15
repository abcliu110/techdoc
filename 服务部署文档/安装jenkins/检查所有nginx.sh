#!/bin/bash
# 检查集群中所有可能影响的 Nginx 实例

echo "=== 1. 检查 docker-registry namespace 中的所有资源 ==="
kubectl get all -n docker-registry

echo ""
echo "=== 2. 检查是否有 Ingress ==="
kubectl get ingress -n docker-registry

echo ""
echo "=== 3. 检查 Service 详情 ==="
kubectl describe svc nginx-proxy -n docker-registry

echo ""
echo "=== 4. 检查 NodePort 30500 被哪个服务使用 ==="
kubectl get svc --all-namespaces | grep 30500

echo ""
echo "=== 5. 测试从集群内访问 Registry ==="
kubectl run test-curl --image=curlimages/curl:latest --rm -it --restart=Never -- \
  curl -v http://docker-registry.docker-registry.svc.cluster.local:5000/v2/ 2>&1 | head -20

echo ""
echo "=== 6. 测试从集群内通过 Nginx 访问 ==="
kubectl run test-curl --image=curlimages/curl:latest --rm -it --restart=Never -- \
  curl -v http://nginx-proxy.docker-registry.svc.cluster.local/v2/ 2>&1 | head -20
