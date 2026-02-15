#!/bin/bash
# 诊断 Nginx 配置问题

echo "=== 1. 查看 Nginx Pod 状态和创建时间 ==="
kubectl get pods -n docker-registry -l app=nginx-proxy -o wide

echo ""
echo "=== 2. 查看 Pod 详细信息（检查重启次数）==="
kubectl describe pod -n docker-registry -l app=nginx-proxy | grep -A 5 "State:"

echo ""
echo "=== 3. 查看 ConfigMap 内容 ==="
kubectl get configmap nginx-config -n docker-registry -o yaml | grep -A 50 "nginx.conf:"

echo ""
echo "=== 4. 查看 Pod 内实际的配置文件 ==="
kubectl exec -n docker-registry deployment/nginx-proxy -- cat /etc/nginx/nginx.conf

echo ""
echo "=== 5. 测试 Nginx 配置语法 ==="
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -t 2>&1

echo ""
echo "=== 6. 查看 Nginx 运行时配置（包含所有生效的配置）==="
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -T 2>&1 | grep -E "(client_max_body_size|proxy_request_buffering)"

echo ""
echo "=== 7. 查看 Nginx 进程 ==="
kubectl exec -n docker-registry deployment/nginx-proxy -- ps aux | grep nginx

echo ""
echo "=== 8. 尝试在容器内重载配置 ==="
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -s reload
echo "配置已重载"

echo ""
echo "=== 9. 再次检查配置 ==="
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -T 2>&1 | grep -E "(client_max_body_size|proxy_request_buffering)"
