#!/bin/bash

echo "========================================="
echo "Harbor认证问题完整诊断和修复"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 步骤1: 检查Secret是否存在
echo ">>> 步骤1: 检查harbor-registry-secret是否存在"
if kubectl get secret harbor-registry-secret -n jenkins &>/dev/null; then
    echo -e "${GREEN}✓ Secret存在${NC}"
else
    echo -e "${RED}✗ Secret不存在${NC}"
    echo "需要创建Secret"
    exit 1
fi
echo ""

# 步骤2: 检查Secret内容
echo ">>> 步骤2: 检查Secret配置"
echo "Secret内容:"
SECRET_CONTENT=$(kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d)
echo "$SECRET_CONTENT" | jq . 2>/dev/null || echo "$SECRET_CONTENT"
echo ""

# 检查服务器地址
if echo "$SECRET_CONTENT" | grep -q "harbor-core.harbor"; then
    echo -e "${RED}✗ 问题发现: Secret使用了错误的服务器地址 'harbor-core.harbor'${NC}"
    echo -e "${YELLOW}需要修复: 应该使用 'harbor.harbor'${NC}"
    FIX_NEEDED=true
elif echo "$SECRET_CONTENT" | grep -q "harbor.harbor"; then
    echo -e "${GREEN}✓ Secret服务器地址正确: harbor.harbor${NC}"
    FIX_NEEDED=false
else
    echo -e "${YELLOW}⚠ 无法确定服务器地址${NC}"
    FIX_NEEDED=true
fi
echo ""

# 步骤3: 如果需要修复，重新创建Secret
if [ "$FIX_NEEDED" = true ]; then
    echo ">>> 步骤3: 重新创建Secret"
    echo "删除旧Secret..."
    kubectl delete secret harbor-registry-secret -n jenkins

    echo "创建新Secret (使用harbor.harbor)..."
    kubectl create secret docker-registry harbor-registry-secret \
      --docker-server=harbor.harbor \
      --docker-username=admin \
      --docker-password=Harbor12345 \
      -n jenkins

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Secret创建成功${NC}"
    else
        echo -e "${RED}✗ Secret创建失败${NC}"
        exit 1
    fi

    echo ""
    echo "验证新Secret:"
    kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
    echo ""
else
    echo ">>> 步骤3: Secret配置正确，跳过修复"
    echo ""
fi

# 步骤4: 测试Harbor连接
echo ">>> 步骤4: 测试Harbor连接"
echo "测试HTTP连接到Harbor..."
kubectl run test-harbor-conn --image=curlimages/curl --rm -it --restart=Never -n jenkins \
  --command -- curl -v http://harbor.harbor/v2/ 2>&1 | grep -E "HTTP|401|200" || echo "连接测试完成"
echo ""

# 步骤5: 测试认证
echo ">>> 步骤5: 测试Harbor认证"
echo "使用admin/Harbor12345测试登录..."
kubectl run test-harbor-auth --image=curlimages/curl --rm -it --restart=Never -n jenkins \
  --command -- curl -u admin:Harbor12345 http://harbor.harbor/v2/_catalog 2>&1 | head -10 || echo "认证测试完成"
echo ""

# 步骤6: 检查Harbor服务
echo ">>> 步骤6: 检查Harbor服务状态"
kubectl get svc harbor -n harbor -o wide 2>/dev/null || echo "Harbor服务不存在"
echo ""

# 步骤7: 提供下一步建议
echo "========================================="
echo "诊断完成"
echo "========================================="
echo ""
echo "下一步操作:"
echo ""
echo "1. 如果Secret已修复，重新运行Jenkins构建"
echo ""
echo "2. 如果仍然失败，检查Harbor Web界面:"
echo "   - 访问: http://<节点IP>:30002"
echo "   - 登录: admin / Harbor12345"
echo "   - 检查 'library' 项目是否存在"
echo "   - 如果不存在，创建一个公开项目"
echo ""
echo "3. 手动测试推送:"
echo "   docker login harbor.harbor -u admin -p Harbor12345"
echo "   docker pull busybox"
echo "   docker tag busybox harbor.harbor/library/test:latest"
echo "   docker push harbor.harbor/library/test:latest"
echo ""
