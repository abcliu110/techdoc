# 增强版推送时间统计示例

# 记录各阶段时间
BUILD_START=$(date +%s)

# 1. 构建镜像（不推送）
echo ">>> 开始构建镜像..."
/kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    --no-push \
    --tar-path=/tmp/image.tar

BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))

# 2. 推送镜像
echo ">>> 开始推送镜像到Harbor..."
PUSH_START=$(date +%s)

/kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    ${DESTINATIONS} \
    ${INSECURE_REGISTRIES} \
    --skip-tls-verify

PUSH_END=$(date +%s)
PUSH_DURATION=$((PUSH_END - PUSH_START))

TOTAL_DURATION=$((PUSH_END - BUILD_START))

# 显示详细统计
echo ""
echo "════════════════════════════════════════"
echo "镜像构建和推送统计"
echo "════════════════════════════════════════"
echo "构建时间: $((BUILD_DURATION / 60))分$((BUILD_DURATION % 60))秒"
echo "推送时间: $((PUSH_DURATION / 60))分$((PUSH_DURATION % 60))秒"
echo "总耗时:   $((TOTAL_DURATION / 60))分$((TOTAL_DURATION % 60))秒"
echo "════════════════════════════════════════"
echo ""
