#!/bin/bash
# 批量修改所有Dockerfile使用国内镜像源（DaoCloud）

set -e

echo "=========================================="
echo "批量修改Dockerfile使用国内镜像源"
echo "=========================================="
echo ""

# 查找所有Dockerfile
DOCKERFILES=$(find . -name "Dockerfile" -type f)
COUNT=$(echo "$DOCKERFILES" | wc -l)

if [ -z "$DOCKERFILES" ]; then
    echo "❌ 未找到任何Dockerfile"
    exit 1
fi

echo "找到 $COUNT 个Dockerfile"
echo ""

# 备份和修改
MODIFIED=0
echo "$DOCKERFILES" | while read dockerfile; do
    if [ -f "$dockerfile" ]; then
        echo "处理: $dockerfile"

        # 检查是否包含 eclipse-temurin
        if grep -q "FROM eclipse-temurin:21-jre" "$dockerfile"; then
            # 备份
            cp "$dockerfile" "$dockerfile.bak.$(date +%Y%m%d_%H%M%S)"

            # 替换为DaoCloud镜像源
            sed -i 's|FROM eclipse-temurin:21-jre|FROM m.daocloud.io/docker.io/library/eclipse-temurin:21-jre|g' "$dockerfile"

            echo "  ✓ 已修改为使用DaoCloud镜像源"
            MODIFIED=$((MODIFIED + 1))
        else
            echo "  ⊗ 跳过（不包含 eclipse-temurin:21-jre）"
        fi
        echo ""
    fi
done

echo "=========================================="
echo "修改完成"
echo "=========================================="
echo "总计: $COUNT 个Dockerfile"
echo "已修改: $MODIFIED 个"
echo ""
echo "备份文件: *.bak.*"
echo ""
echo "下一步："
echo "1. 验证修改: git diff"
echo "2. 提交修改: git add . && git commit -m '使用国内镜像源加速构建'"
echo "3. 推送代码: git push"
echo "4. 重新运行Jenkins构建"
echo ""
