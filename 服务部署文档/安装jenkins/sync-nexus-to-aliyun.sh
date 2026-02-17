#!/bin/bash
# 手动同步 Nexus 镜像到阿里云
# 用法: ./sync-nexus-to-aliyun.sh <tag>
# 例如: ./sync-nexus-to-aliyun.sh 25

set -e

# 配置
NEXUS_REGISTRY="192.168.80.100:30005"  # 修改为你的 Nexus 地址
ALIYUN_REGISTRY="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com"
ALIYUN_NAMESPACE="lgy-images"

# 要同步的模块列表
MODULES=(
    "nms4cloud-platform"
    "nms4cloud-mq"
    "nms4cloud-netty"
    "nms4cloud-reg"
    "nms4cloud-wechat"
    "nms4cloud-biz"
    "nms4cloud-crm"
    "nms4cloud-mall"
    "nms4cloud-payment"
    "nms4cloud-pos"
    "nms4cloud-product"
    "nms4cloud-scm"
    "nms4cloud-order"
)

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 <tag>"
    echo "例如: $0 25"
    echo ""
    echo "或者同步 latest 标签:"
    echo "$0 latest"
    exit 1
fi

TAG=$1

echo "=========================================="
echo "同步 Nexus 镜像到阿里云"
echo "=========================================="
echo "Nexus: ${NEXUS_REGISTRY}"
echo "阿里云: ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}"
echo "标签: ${TAG}"
echo "模块数量: ${#MODULES[@]}"
echo "=========================================="
echo ""

# 检查 Docker 是否登录阿里云
echo ">>> 检查阿里云登录状态..."
if ! docker info 2>/dev/null | grep -q "${ALIYUN_REGISTRY}"; then
    echo "⚠️  请先登录阿里云镜像仓库:"
    echo "docker login ${ALIYUN_REGISTRY}"
    exit 1
fi

SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_MODULES=()

# 同步每个模块
for MODULE in "${MODULES[@]}"; do
    echo ""
    echo "=========================================="
    echo "[$((SUCCESS_COUNT + FAIL_COUNT + 1))/${#MODULES[@]}] 同步: ${MODULE}:${TAG}"
    echo "=========================================="

    NEXUS_IMAGE="${NEXUS_REGISTRY}/${MODULE}:${TAG}"
    ALIYUN_IMAGE="${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${MODULE}:${TAG}"

    # 1. 从 Nexus 拉取
    echo ">>> [1/4] 从 Nexus 拉取镜像..."
    if docker pull ${NEXUS_IMAGE}; then
        echo "✓ 拉取成功"
    else
        echo "❌ 拉取失败: ${MODULE}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_MODULES+=("${MODULE}")
        continue
    fi

    # 2. 重新标记
    echo ">>> [2/4] 标记为阿里云地址..."
    if docker tag ${NEXUS_IMAGE} ${ALIYUN_IMAGE}; then
        echo "✓ 标记成功"
    else
        echo "❌ 标记失败: ${MODULE}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_MODULES+=("${MODULE}")
        continue
    fi

    # 3. 推送到阿里云
    echo ">>> [3/4] 推送到阿里云..."
    PUSH_START=$(date +%s)
    if docker push ${ALIYUN_IMAGE}; then
        PUSH_END=$(date +%s)
        PUSH_DURATION=$((PUSH_END - PUSH_START))
        echo "✓ 推送成功 (耗时: ${PUSH_DURATION}秒)"
    else
        echo "❌ 推送失败: ${MODULE}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_MODULES+=("${MODULE}")
        continue
    fi

    # 4. 清理本地镜像
    echo ">>> [4/4] 清理本地镜像..."
    docker rmi ${NEXUS_IMAGE} 2>/dev/null || true
    docker rmi ${ALIYUN_IMAGE} 2>/dev/null || true
    echo "✓ 清理完成"

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    echo "✓ ${MODULE} 同步完成"
done

# 显示统计信息
echo ""
echo "=========================================="
echo "同步完成"
echo "=========================================="
echo "成功: ${SUCCESS_COUNT}/${#MODULES[@]}"
echo "失败: ${FAIL_COUNT}/${#MODULES[@]}"

if [ ${FAIL_COUNT} -gt 0 ]; then
    echo ""
    echo "失败的模块:"
    for MODULE in "${FAILED_MODULES[@]}"; do
        echo "  - ${MODULE}"
    done
    exit 1
fi

echo ""
echo "✓ 所有镜像同步成功！"
