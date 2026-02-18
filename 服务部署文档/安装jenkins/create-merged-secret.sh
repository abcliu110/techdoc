#!/bin/bash
# ============================================================================
# 创建包含阿里云和Harbor认证的合并Docker Secret
# ============================================================================
#
# 使用说明：
# 1. 填写下面的配置信息（用户名和密码）
# 2. 保存文件
# 3. 执行: bash create-merged-secret.sh
# 4. 验证: kubectl get secret merged-registry-secret -n jenkins
#
# ============================================================================

# ==================== 配置区域（请填写这里） ====================

# 阿里云镜像仓库配置
# 说明：登录 https://cr.console.aliyun.com/ 查看你的用户名
ALIYUN_USERNAME=""                    # 填写你的阿里云用户名
ALIYUN_PASSWORD=""                    # 填写你的阿里云密码

# Harbor 本地镜像仓库配置
# 说明：Harbor默认管理员账号是 admin/Harbor12345
HARBOR_USERNAME="admin"               # 填写你的Harbor用户名（默认：admin）
HARBOR_PASSWORD="Harbor12345"         # 填写你的Harbor密码（默认：Harbor12345）

# Kubernetes 命名空间
NAMESPACE="jenkins"                   # Jenkins所在的namespace（默认：jenkins）

# ================================================================

# ==================== 以下内容无需修改 ====================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查必填项
if [ -z "$ALIYUN_USERNAME" ] || [ -z "$ALIYUN_PASSWORD" ]; then
    echo -e "${RED}❌ 错误: 请填写阿里云用户名和密码${NC}"
    echo ""
    echo "请编辑此脚本，填写以下配置："
    echo "  ALIYUN_USERNAME=\"你的阿里云用户名\""
    echo "  ALIYUN_PASSWORD=\"你的阿里云密码\""
    exit 1
fi

if [ -z "$HARBOR_USERNAME" ] || [ -z "$HARBOR_PASSWORD" ]; then
    echo -e "${RED}❌ 错误: 请填写Harbor用户名和密码${NC}"
    exit 1
fi

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  创建合并的Docker Registry Secret${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

# 显示配置信息（密码打码）
echo "配置信息："
echo "  阿里云用户名: $ALIYUN_USERNAME"
echo "  阿里云密码: ${ALIYUN_PASSWORD:0:3}***"
echo "  Harbor用户名: $HARBOR_USERNAME"
echo "  Harbor密码: ${HARBOR_PASSWORD:0:3}***"
echo "  命名空间: $NAMESPACE"
echo ""

# 生成auth字段（base64编码的 username:password）
echo "生成认证信息..."
ALIYUN_AUTH=$(echo -n "${ALIYUN_USERNAME}:${ALIYUN_PASSWORD}" | base64 -w 0 2>/dev/null || echo -n "${ALIYUN_USERNAME}:${ALIYUN_PASSWORD}" | base64)
HARBOR_AUTH=$(echo -n "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" | base64 -w 0 2>/dev/null || echo -n "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" | base64)

# 创建JSON配置文件
echo "创建配置文件..."
cat > /tmp/docker-config.json <<EOF
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "${ALIYUN_USERNAME}",
      "password": "${ALIYUN_PASSWORD}",
      "auth": "${ALIYUN_AUTH}"
    },
    "harbor-core.harbor": {
      "username": "${HARBOR_USERNAME}",
      "password": "${HARBOR_PASSWORD}",
      "auth": "${HARBOR_AUTH}"
    }
  }
}
EOF

echo -e "${GREEN}✓ 配置文件已生成${NC}"
echo ""

# 显示配置文件内容（可选，用于调试）
if command -v jq >/dev/null 2>&1; then
    echo "配置文件内容预览："
    cat /tmp/docker-config.json | jq .
    echo ""
fi

# 检查namespace是否存在
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 警告: namespace '$NAMESPACE' 不存在${NC}"
    read -p "是否创建namespace? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl create namespace "$NAMESPACE"
        echo -e "${GREEN}✓ namespace已创建${NC}"
    else
        echo -e "${RED}❌ 取消操作${NC}"
        rm /tmp/docker-config.json
        exit 1
    fi
fi

# 检查Secret是否已存在
if kubectl get secret merged-registry-secret -n "$NAMESPACE" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Secret 'merged-registry-secret' 已存在${NC}"
    read -p "是否删除并重新创建? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete secret merged-registry-secret -n "$NAMESPACE"
        echo -e "${GREEN}✓ 旧Secret已删除${NC}"
    else
        echo -e "${YELLOW}⚠ 保留现有Secret，取消操作${NC}"
        rm /tmp/docker-config.json
        exit 0
    fi
fi

# 创建Secret
echo "创建Kubernetes Secret..."
kubectl create secret generic merged-registry-secret \
  --from-file=.dockerconfigjson=/tmp/docker-config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace="$NAMESPACE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Secret创建成功！${NC}"
else
    echo -e "${RED}❌ Secret创建失败${NC}"
    rm /tmp/docker-config.json
    exit 1
fi

# 清理临时文件
rm /tmp/docker-config.json
echo -e "${GREEN}✓ 临时文件已清理${NC}"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  创建完成！${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "验证命令："
echo "  # 查看Secret"
echo "  kubectl get secret merged-registry-secret -n $NAMESPACE"
echo ""
echo "  # 查看Secret内容"
echo "  kubectl get secret merged-registry-secret -n $NAMESPACE -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq ."
echo ""
echo "下一步："
echo "  1. 验证Secret是否包含两个仓库的认证"
echo "  2. 使用新的Jenkinsfile运行构建"
echo "  3. 检查镜像是否成功推送到两个仓库"
echo ""
