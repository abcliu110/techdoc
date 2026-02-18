#!/bin/bash
# ============================================================================
# 合并现有的阿里云和Harbor Secret
# ============================================================================
#
# 使用说明：
# 1. 确保已经存在 aliyun-registry-secret 和 harbor-registry-secret
# 2. 执行: bash merge-existing-secrets.sh
# 3. 验证: kubectl get secret merged-registry-secret -n jenkins
#
# ============================================================================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="jenkins"

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  合并现有的Docker Registry Secret${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

# 检查jq是否安装
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: 需要安装jq工具${NC}"
    echo ""
    echo "安装方法："
    echo "  Ubuntu/Debian: apt-get install jq"
    echo "  CentOS/RHEL:   yum install jq"
    echo "  macOS:         brew install jq"
    exit 1
fi

# 检查阿里云Secret是否存在
if ! kubectl get secret aliyun-registry-secret -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: aliyun-registry-secret 不存在${NC}"
    exit 1
fi

# 检查Harbor Secret是否存在
if ! kubectl get secret harbor-registry-secret -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}❌ 错误: harbor-registry-secret 不存在${NC}"
    exit 1
fi

echo "✓ 找到现有的Secret"
echo ""

# 导出阿里云Secret
echo "导出阿里云Secret..."
kubectl get secret aliyun-registry-secret -n "$NAMESPACE" -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > /tmp/aliyun-config.json

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 导出阿里云Secret失败${NC}"
    exit 1
fi

# 导出Harbor Secret
echo "导出Harbor Secret..."
kubectl get secret harbor-registry-secret -n "$NAMESPACE" -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d > /tmp/harbor-config.json

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 导出Harbor Secret失败${NC}"
    rm /tmp/aliyun-config.json
    exit 1
fi

echo -e "${GREEN}✓ Secret导出成功${NC}"
echo ""

# 显示导出的内容
echo "阿里云配置内容："
cat /tmp/aliyun-config.json | jq .
echo ""

echo "Harbor配置内容："
cat /tmp/harbor-config.json | jq .
echo ""

# 合并两个配置
echo "合并配置..."
jq -s '.[0].auths * .[1].auths | {auths: .}' /tmp/aliyun-config.json /tmp/harbor-config.json > /tmp/merged-config.json

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 合并配置失败${NC}"
    rm /tmp/aliyun-config.json /tmp/harbor-config.json
    exit 1
fi

echo -e "${GREEN}✓ 配置合并成功${NC}"
echo ""

# 显示合并后的内容
echo "合并后的配置："
cat /tmp/merged-config.json | jq .
echo ""

# 检查合并后的配置是否包含两个仓库
REGISTRY_COUNT=$(cat /tmp/merged-config.json | jq '.auths | length')
if [ "$REGISTRY_COUNT" -ne 2 ]; then
    echo -e "${YELLOW}⚠ 警告: 合并后只有 $REGISTRY_COUNT 个仓库认证${NC}"
    echo "预期应该有2个（阿里云和Harbor）"
    echo ""
fi

# 检查merged-registry-secret是否已存在
if kubectl get secret merged-registry-secret -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Secret 'merged-registry-secret' 已存在${NC}"
    read -p "是否删除并重新创建? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete secret merged-registry-secret -n "$NAMESPACE"
        echo -e "${GREEN}✓ 旧Secret已删除${NC}"
    else
        echo -e "${YELLOW}⚠ 保留现有Secret，取消操作${NC}"
        rm /tmp/aliyun-config.json /tmp/harbor-config.json /tmp/merged-config.json
        exit 0
    fi
fi

# 创建新的Secret
echo "创建合并的Secret..."
kubectl create secret generic merged-registry-secret \
  --from-file=.dockerconfigjson=/tmp/merged-config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace="$NAMESPACE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Secret创建成功！${NC}"
else
    echo -e "${RED}❌ Secret创建失败${NC}"
    rm /tmp/aliyun-config.json /tmp/harbor-config.json /tmp/merged-config.json
    exit 1
fi

# 清理临时文件
rm /tmp/aliyun-config.json /tmp/harbor-config.json /tmp/merged-config.json
echo -e "${GREEN}✓ 临时文件已清理${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  合并完成！${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "验证命令："
echo "  # 查看Secret"
echo "  kubectl get secret merged-registry-secret -n $NAMESPACE"
echo ""
echo "  # 查看Secret内容（应该包含两个仓库）"
echo "  kubectl get secret merged-registry-secret -n $NAMESPACE -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq ."
echo ""
echo "  # 检查仓库数量"
echo "  kubectl get secret merged-registry-secret -n $NAMESPACE -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq '.auths | length'"
echo ""
echo "下一步："
echo "  1. 验证Secret是否包含两个仓库的认证"
echo "  2. 使用新的Jenkinsfile运行构建"
echo "  3. 检查镜像是否成功推送到两个仓库"
echo ""
