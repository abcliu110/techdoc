#!/bin/bash

echo "========================================="
echo "Harbor连接问题诊断和修复"
echo "========================================="
echo ""

# 1. 检查harbor-core服务
echo ">>> 1. 检查harbor-core服务配置"
kubectl get svc harbor-core -n harbor -o wide
echo ""

# 2. 检查服务端点
echo ">>> 2. 检查harbor-core服务端点"
kubectl get endpoints harbor-core -n harbor
echo ""

# 3. 检查服务详细配置
echo ">>> 3. 检查harbor-core服务详细配置"
kubectl describe svc harbor-core -n harbor
echo ""

# 4. 测试从Jenkins命名空间访问Harbor
echo ">>> 4. 测试从Jenkins命名空间访问Harbor"
echo "测试HTTP连接..."
kubectl run test-harbor-http --image=curlimages/curl --rm -it --restart=Never -n jenkins -- curl -v http://harbor-core.harbor/v2/ 2>&1 | head -20
echo ""

echo "测试HTTPS连接..."
kubectl run test-harbor-https --image=curlimages/curl --rm -it --restart=Never -n jenkins -- curl -kv https://harbor-core.harbor/v2/ 2>&1 | head -20
echo ""

# 5. 检查Harbor nginx服务(可能是真正的入口)
echo ">>> 5. 检查harbor服务(nginx入口)"
kubectl get svc -n harbor | grep -E "NAME|harbor"
echo ""

# 6. 测试harbor服务(不是harbor-core)
echo ">>> 6. 测试harbor服务连接"
kubectl run test-harbor-svc --image=curlimages/curl --rm -it --restart=Never -n jenkins -- curl -v http://harbor.harbor/v2/ 2>&1 | head -20
echo ""

echo "========================================="
echo "诊断完成"
echo "========================================="
echo ""
echo "根据上面的输出:"
echo "1. 如果harbor-core服务端口是80,Jenkinsfile应该使用 http://harbor-core.harbor"
echo "2. 如果harbor-core服务端口是443,Jenkinsfile应该使用 https://harbor-core.harbor"
echo "3. 如果有harbor服务(nginx),可能应该使用 http://harbor.harbor"
