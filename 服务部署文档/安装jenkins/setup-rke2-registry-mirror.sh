#!/bin/bash
# 配置RKE2的Docker Hub镜像加速
# 在所有Kubernetes节点上执行此脚本

set -e

echo "=========================================="
echo "配置RKE2镜像加速"
echo "=========================================="
echo ""

# 检查是否是root
if [ "$EUID" -ne 0 ]; then
    echo "❌ 请使用root权限运行此脚本"
    echo "   sudo bash $0"
    exit 1
fi

# 创建配置目录
mkdir -p /etc/rancher/rke2

# 备份现有配置
if [ -f /etc/rancher/rke2/registries.yaml ]; then
    echo ">>> 备份现有配置"
    cp /etc/rancher/rke2/registries.yaml /etc/rancher/rke2/registries.yaml.bak.$(date +%Y%m%d_%H%M%S)
fi

# 创建镜像加速配置
echo ">>> 创建镜像加速配置"
cat > /etc/rancher/rke2/registries.yaml <<'EOF'
mirrors:
  docker.io:
    endpoint:
      - "http://harbor-core.harbor/v2/dockerhub-proxy"
      - "https://docker.m.daocloud.io"
      - "https://registry-1.docker.io"

configs:
  "harbor-core.harbor":
    tls:
      insecure_skip_verify: true
EOF

echo "✓ 配置文件已创建: /etc/rancher/rke2/registries.yaml"
echo ""

# 显示配置内容
echo "配置内容："
cat /etc/rancher/rke2/registries.yaml
echo ""

# 检测RKE2服务类型
if systemctl is-active --quiet rke2-server; then
    SERVICE="rke2-server"
elif systemctl is-active --quiet rke2-agent; then
    SERVICE="rke2-agent"
else
    echo "❌ 未检测到RKE2服务"
    echo "   请手动重启RKE2服务："
    echo "   systemctl restart rke2-server  # 或"
    echo "   systemctl restart rke2-agent"
    exit 1
fi

echo ">>> 检测到服务: $SERVICE"
echo ""

# 询问是否重启
read -p "是否立即重启 $SERVICE 服务? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ">>> 重启 $SERVICE 服务..."
    systemctl restart $SERVICE

    echo ">>> 等待服务启动..."
    sleep 10

    # 检查服务状态
    if systemctl is-active --quiet $SERVICE; then
        echo "✓ $SERVICE 服务已重启"
    else
        echo "❌ $SERVICE 服务重启失败"
        systemctl status $SERVICE
        exit 1
    fi
else
    echo "⚠ 跳过重启，请稍后手动重启："
    echo "   systemctl restart $SERVICE"
fi

echo ""
echo "=========================================="
echo "配置完成"
echo "=========================================="
echo ""
echo "验证命令："
echo "  # 查看配置"
echo "  crictl info | grep -A 20 registry"
echo ""
echo "  # 测试拉取镜像"
echo "  crictl pull eclipse-temurin:21-jre"
echo ""
echo "  # 查看已拉取的镜像"
echo "  crictl images | grep eclipse-temurin"
echo ""
