#!/bin/bash

# ============================================================================
# 批量同步 Harbor 镜像到阿里云个人仓库
# ============================================================================
#
# 功能：批量将 Harbor 中的所有镜像同步到阿里云
#
# 使用方法：
#   ./批量同步Harbor镜像到阿里云.sh
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

# ==================== 函数定义 ====================

# 同步单个镜像
sync_image() {
    local IMAGE_NAME=$1
    local IMAGE_TAG=$2
    
    local HARBOR_IMAGE="${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
    local ALIYUN_IMAGE="${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "同步: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 拉取镜像
    echo ">>> 拉取镜像..."
    if ! docker pull ${HARBOR_IMAGE}; then
        echo "❌ 拉取失败: ${HARBOR_IMAGE}"
        return 1
    fi
    
    # 标记镜像
    echo ">>> 标记镜像..."
    if ! docker tag ${HARBOR_IMAGE} ${ALIYUN_IMAGE}; then
        echo "❌ 标记失败"
        return 1
    fi
    
    # 推送镜像
    echo ">>> 推送镜像..."
    PUSH_START=$(date +%s)
    
    if ! docker push ${ALIYUN_IMAGE}; then
        echo "❌ 推送失败: ${ALIYUN_IMAGE}"
        return 1
    fi
    
    PUSH_END=$(date +%s)
    PUSH_DURATION=$((PUSH_END - PUSH_START))
    
    # 清理本地镜像
    docker rmi ${HARBOR_IMAGE} ${ALIYUN_IMAGE} 2>/dev/null || true
    
    echo "✓ 同步成功 (耗时: ${PUSH_DURATION}s)"
    return 0
}

# ==================== 主流程 ====================

echo "╔════════════════════════════════════════╗"
echo "║   批量同步 Harbor 镜像到阿里云          ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 登录 Harbor
echo ">>> 登录 Harbor..."
echo "${HARBOR_PASSWORD}" | docker login ${HARBOR_REGISTRY} \
    --username ${HARBOR_USERNAME} \
    --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ Harbor 登录失败"
    exit 1
fi
echo "✓ Harbor 登录成功"

# 登录阿里云
echo ">>> 登录阿里云..."
echo "${ALIYUN_PASSWORD}" | docker login ${ALIYUN_REGISTRY} \
    --username ${ALIYUN_USERNAME} \
    --password-stdin

if [ $? -ne 0 ]; then
    echo "❌ 阿里云登录失败"
    exit 1
fi
echo "✓ 阿里云登录成功"

# 获取 Harbor 中的所有镜像
echo ""
echo ">>> 获取 Harbor 镜像列表..."

# 方式 1: 使用 Harbor API（推荐）
# 需要安装 jq: apt-get install jq 或 yum install jq

if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    echo "使用 Harbor API 获取镜像列表..."
    
    # 获取项目中的所有仓库
    REPOS=$(curl -s -u "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
        "http://${HARBOR_REGISTRY}/api/v2.0/projects/${HARBOR_PROJECT}/repositories" | \
        jq -r '.[].name' | sed "s|${HARBOR_PROJECT}/||")
    
    if [ -z "$REPOS" ]; then
        echo "❌ 未找到任何镜像仓库"
        exit 1
    fi
    
    echo "找到以下仓库:"
    echo "$REPOS"
    echo ""
    
    # 统计
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    TOTAL_START=$(date +%s)
    
    # 遍历每个仓库
    for REPO in $REPOS; do
        # 获取仓库的所有标签
        TAGS=$(curl -s -u "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" \
            "http://${HARBOR_REGISTRY}/api/v2.0/projects/${HARBOR_PROJECT}/repositories/${REPO}/artifacts" | \
            jq -r '.[].tags[].name')
        
        if [ -z "$TAGS" ]; then
            echo "⚠ ${REPO}: 没有标签"
            continue
        fi
        
        # 同步每个标签
        for TAG in $TAGS; do
            if sync_image "${REPO}" "${TAG}"; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        done
    done
    
else
    # 方式 2: 手动指定镜像列表
    echo "⚠ 未安装 curl 或 jq，使用手动指定的镜像列表"
    echo ""
    
    # 在这里手动添加要同步的镜像
    IMAGES=(
        "demo-springboot:latest"
        "demo-springboot:114"
        # 添加更多镜像...
    )
    
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    TOTAL_START=$(date +%s)
    
    for IMAGE in "${IMAGES[@]}"; do
        IMAGE_NAME=$(echo $IMAGE | cut -d: -f1)
        IMAGE_TAG=$(echo $IMAGE | cut -d: -f2)
        
        if sync_image "${IMAGE_NAME}" "${IMAGE_TAG}"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done
fi

TOTAL_END=$(date +%s)
TOTAL_DURATION=$((TOTAL_END - TOTAL_START))
TOTAL_DURATION_MIN=$((TOTAL_DURATION / 60))
TOTAL_DURATION_SEC=$((TOTAL_DURATION % 60))

# ==================== 完成统计 ====================

echo ""
echo "╔════════════════════════════════════════╗"
echo "║         同步完成统计                    ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "成功: ${SUCCESS_COUNT}"
echo "失败: ${FAIL_COUNT}"
echo "总计: $((SUCCESS_COUNT + FAIL_COUNT))"
echo "总耗时: ${TOTAL_DURATION_MIN} 分 ${TOTAL_DURATION_SEC} 秒"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo "⚠ 有 ${FAIL_COUNT} 个镜像同步失败，请检查日志"
    exit 1
fi

echo "✓ 所有镜像同步成功"
