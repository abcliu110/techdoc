#!/bin/bash
# 从 Git 仓库中删除 .dockerignore 并重新构建

echo "=== 步骤 1: 检查 Git 仓库状态 ==="
cd 服务部署文档/安装jenkins/demo-springboot/

# 检查 .dockerignore 是否在 Git 中
if git ls-files | grep -q "^\.dockerignore$"; then
    echo "✗ .dockerignore 仍在 Git 仓库中，需要删除"
    
    echo ""
    echo "=== 步骤 2: 从 Git 中删除 .dockerignore ==="
    git rm .dockerignore
    git commit -m "删除 .dockerignore 以允许 Docker 构建时复制 target 目录"
    
    echo ""
    echo "=== 步骤 3: 推送到远程仓库 ==="
    git push
    
    echo ""
    echo "✓ .dockerignore 已从 Git 仓库中删除"
else
    echo "✓ .dockerignore 不在 Git 仓库中"
fi

echo ""
echo "=== 步骤 4: 验证文件已删除 ==="
git ls-files | grep dockerignore || echo "✓ 确认 .dockerignore 已从 Git 中删除"

echo ""
echo "=========================================="
echo "下一步: 在 Jenkins 中重新构建项目"
echo "=========================================="
echo "1. 打开 Jenkins: http://your-jenkins-url"
echo "2. 找到项目: 测试项目"
echo "3. 点击 'Build with Parameters'"
echo "4. 确保勾选 'BUILD_DOCKER_IMAGE'"
echo "5. 点击 'Build'"
echo ""
echo "构建时检查日志中是否显示:"
echo "  >>> 检查 .dockerignore 文件"
echo "  未找到 .dockerignore 文件"
echo ""
