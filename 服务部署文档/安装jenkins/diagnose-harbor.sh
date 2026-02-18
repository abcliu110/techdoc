#!/bin/bash

echo "========================================="
echo "Harbor 服务诊断脚本"
echo "========================================="
echo ""

# 1. 检查Harbor命名空间
echo ">>> 1. 检查Harbor命名空间"
kubectl get namespace harbor 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ Harbor命名空间不存在"
    exit 1
fi
echo "✓ Harbor命名空间存在"
echo ""

# 2. 检查Harbor Pod状态
echo ">>> 2. 检查Harbor Pod状态"
kubectl get pods -n harbor
echo ""

# 3. 检查Harbor Core Pod详细状态
echo ">>> 3. 检查Harbor Core Pod详细状态"
kubectl get pods -n harbor -l component=core -o wide
echo ""

# 4. 检查Harbor服务
echo ">>> 4. 检查Harbor服务"
kubectl get svc -n harbor
echo ""

# 5. 检查harbor-core服务详细信息
echo ">>> 5. 检查harbor-core服务详细信息"
kubectl get svc harbor-core -n harbor -o yaml 2>/dev/null
if [ $? -ne 0 ]; then
    echo "❌ harbor-core服务不存在"
fi
echo ""

# 6. 检查服务端点
echo ">>> 6. 检查harbor-core服务端点"
kubectl get endpoints harbor-core -n harbor 2>/dev/null
echo ""

# 7. 测试DNS解析
echo ">>> 7. 测试DNS解析"
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup harbor-core.harbor 2>/dev/null || echo "DNS解析测试失败"
echo ""

# 8. 从Jenkins命名空间测试连接
echo ">>> 8. 从Jenkins命名空间测试Harbor连接"
kubectl run test-harbor --image=curlimages/curl --rm -it --restart=Never -n jenkins -- curl -I http://harbor-core.harbor/v2/ 2>/dev/null || echo "连接测试失败"
echo ""

# 9. 检查Harbor Core日志
echo ">>> 9. 检查Harbor Core最近日志"
HARBOR_CORE_POD=$(kubectl get pods -n harbor -l component=core -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$HARBOR_CORE_POD" ]; then
    echo "Harbor Core Pod: $HARBOR_CORE_POD"
    kubectl logs $HARBOR_CORE_POD -n harbor --tail=20
else
    echo "❌ 未找到Harbor Core Pod"
fi
echo ""

echo "========================================="
echo "诊断完成"
echo "========================================="
