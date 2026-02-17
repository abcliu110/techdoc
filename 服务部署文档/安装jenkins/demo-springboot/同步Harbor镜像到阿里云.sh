#!/bin/bash

# ============================================================================
# Harbor 镜像同步到阿里云个人仓库脚本
# ============================================================================
#
# 功能：将 Harbor 中的镜像拉取并推送到阿里云个人仓库
#
# 使用方法：
#   ./同步Harbor镜像到阿里云.sh <镜像名称> <标签>
#
# 示例：
#   ./同步Harbor镜像到阿里云.sh demo-springboot 114
#   ./同步Harbor镜像到阿里云.sh demo-springboot latest
#
# ============================================================================

set -e

# ==================== 配置区域 ====================

# Harbor 配置
HARBOR_REGISTRY="harbor-core.harbor"
HARBOR_PROJECT="library"
HARBOR_USERNAME="admin"
HARBOR_PASSWORD="Harbor12345"

# 阿里云配置
ALIYUN_REGISTRY="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com"
ALIYUN_NAMESPACE="lgy-images"
ALIYUN_USERNAME="abcliu110"
ALIYUN_PASSWORD="st11338st11338"

# ==================== 参数检查 ====================

if [ $# -lt 2 ]; then
    echo "错误: 缺少参数"
    echo ""
    echo "使用方法:"
    echo "  $0 <镜像名称> <标签>"
    echo ""
    echo "示例:"
    echo "  $0 demo-springboot 114"
    echo "  $0 demo-springboot latest"
    exit 1
fi

IMAGE_NAME=$1
IMAGE_TAG=$2

# ==================== 镜像地址 ====================

HARBOR_IMAGE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
ALIYUN_IMAGE="${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "╔════════════════════════════════════════╗"
echo "║     Harbor 镜像同步到阿里云             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "源镜像: ${HARBOR_IMAGE}"
echo "目标镜像: ${ALIYUN_IMAGE}"
echo ""

# ==================== 登录 Harbor ====================

echo ">>> 登录 Harbor..."
echo "${HARBOR_PASSWORD}" | docker login ${HARBOR_REGISTRY} \
    --username ${HARBOR_USERNAME} \
    --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ Harbor 登录失败"
    exit 1
fi
echo "✓ Harbor 登录成功"
echo ""

# ==================== 拉取镜像 ====================

echo ">>> 从 Harbor 拉取镜像..."
docker pull ${HARBOR_IMAGE}

if [ $? -ne 0 ]; then
    echo "❌ 镜像拉取失败"
    exit 1
fi
echo "✓ 镜像拉取成功"
echo ""

# ==================== 查看镜像信息 ====================

echo ">>> 镜像信息:"
docker images ${HARBOR_IMAGE} --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""

# ==================== 标记镜像 ====================

echo ">>> 标记镜像为阿里云地址..."
docker tag ${HARBOR_IMAGE} ${ALIYUN_IMAGE}

if [ $? -ne 0 ]; then
    echo "❌ 镜像标记失败"
    exit 1
fi
echo "✓ 镜像标记成功"
echo ""

# ==================== 登录阿里云 ====================

echo ">>> 登录阿里云镜像仓库..."
echo "${ALIYUN_PASSWORD}" | docker login ${ALIYUN_REGISTRY} \
    --username ${ALIYUN_USERNAME} \
    --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ 阿里云登录失败"
    exit 1
fi
echo "✓ 阿里云登录成功"
echo ""

# ==================== 推送镜像 ====================

echo ">>> 推送镜像到阿里云..."
PUSH_START_TIME=$(date +%s)

docker push ${ALIYUN_IMAGE}

if [ $? -ne 0 ]; then
    echo "❌ 镜像推送失败"
    exit 1
fi

PUSH_END_TIME=$(date +%s)
PUSH_DURATION=$((PUSH_END_TIME - PUSH_START_TIME))
PUSH_DURATION_MIN=$((PUSH_DURATION / 60))
PUSH_DURATION_SEC=$((PUSH_DURATION % 60))

echo "✓ 镜像推送成功"
echo ""

# ==================== 清理本地镜像 ====================

echo ">>> 清理本地镜像..."
docker rmi ${HARBOR_IMAGE} ${ALIYUN_IMAGE} 2>/dev/null || true
echo "✓ 本地镜像已清理"
echo ""

# ==================== 完成 ====================

echo "╔════════════════════════════════════════╗"
echo "║         ✓ 同步完成                      ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "源镜像: ${HARBOR_IMAGE}"
echo "目标镜像: ${ALIYUN_IMAGE}"
echo "推送耗时: ${PUSH_DURATION_MIN} 分 ${PUSH_DURATION_SEC} 秒"
echo ""
echo "验证镜像:"
echo "  阿里云控制台: https://cr.console.aliyun.com/"
echo "  命名空间: ${ALIYUN_NAMESPACE}"
echo "  仓库: ${IMAGE_NAME}"
echo ""
