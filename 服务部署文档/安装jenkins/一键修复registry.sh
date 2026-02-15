#!/bin/bash
# 一键修复 RKE2 私有仓库配置

set -e

echo "=========================================="
echo "RKE2 私有仓库一键修复工具"
echo "=========================================="
echo ""

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ 请使用 root 权限运行此脚本"
    echo "   sudo bash $0"
    exit 1
fi

# 1. 检测服务类型
echo "=== 1. 检测 RKE2 服务 ==="
if systemctl is-active --quiet rke2-server; then
    SERVICE="rke2-server"
    echo "✓ 检测到 Master 节点 (rke2-server)"
elif systemctl is-active --quiet rke2-agent; then
    SERVICE="rke2-agent"
    echo "✓ 检测到 Worker 节点 (rke2-agent)"
else
    echo "❌ 未检测到 RKE2 服务"
    exit 1
fi
echo ""

# 2. 备份原配置
echo "=== 2. 备份原配置 ==="
if [ -f /etc/rancher/rke2/registries.yaml ]; then
    BACKUP_FILE="/etc/rancher/rke2/registries.yaml.backup.$(date +%Y%m%d_%H%M%S)"
    cp /etc/rancher/rke2/registries.yaml "$BACKUP_FILE"
    echo "✓ 原配置已备份到: $BACKUP_FILE"
else
    echo "⚠️ 原配置文件不存在，将创建新文件"
fi
echo ""

# 3. 创建或更新配置
echo "=== 3. 配置私有仓库 ==="

# 检查是否已有配置
if [ -f /etc/rancher/rke2/registries.yaml ] && grep -q "192.168.80.100:30500" /etc/rancher/rke2/registries.yaml; then
    echo "⚠️ 配置已存在，将更新配置"
    
    # 检查是否有 insecure_skip_verify
    if grep -A 3 "192.168.80.100:30500" /etc/rancher/rke2/registries.yaml | grep -q "insecure_skip_verify: true"; then
        echo "✓ insecure_skip_verify 已配置"
    else
        echo "❌ insecure_skip_verify 未配置，需要手动修改"
        echo "   请编辑 /etc/rancher/rke2/registries.yaml"
        echo "   确保包含以下内容:"
        echo ""
        cat <<'EOF'
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF
        exit 1
    fi
else
    echo "创建新配置..."
    
    # 创建完整配置
    cat > /etc/rancher/rke2/registries.yaml <<'EOF'
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://hub-mirror.c.163.com"
  
  gcr.io:
    endpoint:
      - "https://m.daocloud.io/gcr.io"
  
  registry.k8s.io:
    endpoint:
      - "https://m.daocloud.io/registry.k8s.io"

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF
    
    echo "✓ 配置文件已创建"
fi
echo ""

# 4. 显示配置内容
echo "=== 4. 当前配置内容 ==="
cat /etc/rancher/rke2/registries.yaml
echo ""

# 5. 重启服务
echo "=== 5. 重启 $SERVICE ==="
echo "⚠️ 服务将重启，可能会短暂影响集群"
read -p "是否继续? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "重启服务..."
    systemctl restart $SERVICE
    
    echo "等待服务启动（30秒）..."
    sleep 30
    
    # 检查服务状态
    if systemctl is-active --quiet $SERVICE; then
        echo "✓ 服务已启动"
    else
        echo "❌ 服务启动失败"
        echo "查看日志: journalctl -u $SERVICE -n 50"
        exit 1
    fi
else
    echo "⚠️ 已取消重启，配置不会生效"
    echo "   手动重启: systemctl restart $SERVICE"
    exit 0
fi
echo ""

# 6. 验证配置
echo "=== 6. 验证配置 ==="
echo "检查 containerd 配置..."
if crictl info 2>/dev/null | grep -q "192.168.80.100:30500"; then
    echo "✓ containerd 已加载配置"
    echo ""
    echo "--- 配置详情 ---"
    crictl info 2>/dev/null | grep -A 10 "192.168.80.100:30500"
else
    echo "❌ containerd 未加载配置"
    echo "   可能需要更长时间等待，或者配置有误"
    exit 1
fi
echo ""

# 7. 测试镜像拉取
echo "=== 7. 测试镜像拉取 ==="
echo "尝试拉取测试镜像..."

if crictl pull 192.168.80.100:30500/demo-springboot:latest 2>&1; then
    echo ""
    echo "✓ 镜像拉取成功！"
    echo ""
    echo "--- 镜像信息 ---"
    crictl images | grep demo-springboot
else
    echo ""
    echo "❌ 镜像拉取失败"
    echo "   可能的原因:"
    echo "   1. 镜像不存在于仓库中"
    echo "   2. 网络连接问题"
    echo "   3. Registry 服务未运行"
    echo ""
    echo "   验证 Registry:"
    echo "   curl http://192.168.80.100:30500/v2/"
    echo "   curl http://192.168.80.100:30500/v2/demo-springboot/tags/list"
    exit 1
fi
echo ""

# 8. 完成
echo "=========================================="
echo "✓ 修复完成！"
echo "=========================================="
echo ""
echo "下一步操作:"
echo "1. 如果有多个节点，在每个节点上运行此脚本"
echo "2. 重新部署失败的 Pod:"
echo "   kubectl delete pod -l app=demo-springboot -n default"
echo "3. 或者重启 Deployment:"
echo "   kubectl rollout restart deployment/demo-springboot -n default"
echo ""
