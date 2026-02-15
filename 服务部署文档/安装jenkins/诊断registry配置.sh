#!/bin/bash
# 诊断 RKE2 Registry 配置问题

echo "=========================================="
echo "RKE2 Registry 配置诊断工具"
echo "=========================================="
echo ""

# 1. 检查配置文件
echo "=== 1. 检查配置文件 ==="
if [ -f /etc/rancher/rke2/registries.yaml ]; then
    echo "✓ 配置文件存在"
    echo ""
    echo "--- 配置文件内容 ---"
    cat /etc/rancher/rke2/registries.yaml
    echo ""
else
    echo "❌ 配置文件不存在: /etc/rancher/rke2/registries.yaml"
    echo ""
fi

# 2. 检查服务状态
echo "=== 2. 检查 RKE2 服务状态 ==="
if systemctl is-active --quiet rke2-server; then
    echo "✓ rke2-server 正在运行"
    SERVICE="rke2-server"
elif systemctl is-active --quiet rke2-agent; then
    echo "✓ rke2-agent 正在运行"
    SERVICE="rke2-agent"
else
    echo "❌ RKE2 服务未运行"
    SERVICE=""
fi
echo ""

# 3. 检查 containerd 配置
echo "=== 3. 检查 containerd 是否加载了配置 ==="
if command -v crictl &> /dev/null; then
    echo "--- 查找私有仓库配置 ---"
    crictl info 2>/dev/null | grep -A 20 "192.168.80.100:30500" || echo "❌ 未找到私有仓库配置"
    echo ""
else
    echo "❌ crictl 命令不可用"
    echo ""
fi

# 4. 测试网络连接
echo "=== 4. 测试网络连接 ==="
if command -v curl &> /dev/null; then
    echo "--- 测试 HTTP 连接 ---"
    if curl -s -o /dev/null -w "%{http_code}" http://192.168.80.100:30500/v2/ | grep -q "200"; then
        echo "✓ HTTP 连接成功"
    else
        echo "❌ HTTP 连接失败"
    fi
    echo ""
else
    echo "⚠️ curl 命令不可用，跳过网络测试"
    echo ""
fi

# 5. 测试镜像拉取
echo "=== 5. 测试镜像拉取 ==="
if command -v crictl &> /dev/null; then
    echo "--- 尝试拉取镜像 ---"
    if crictl pull 192.168.80.100:30500/demo-springboot:latest 2>&1; then
        echo "✓ 镜像拉取成功"
    else
        echo "❌ 镜像拉取失败"
    fi
    echo ""
else
    echo "❌ crictl 命令不可用"
    echo ""
fi

# 6. 检查 Pod 状态
echo "=== 6. 检查 Pod 状态 ==="
if command -v kubectl &> /dev/null; then
    echo "--- 查找使用私有仓库的 Pod ---"
    kubectl get pods -A -o wide | grep "192.168.80.100:30500" || echo "未找到相关 Pod"
    echo ""
    
    echo "--- 查看 ImagePullBackOff 的 Pod ---"
    kubectl get pods -A | grep -E "ImagePullBackOff|ErrImagePull" || echo "未找到镜像拉取失败的 Pod"
    echo ""
else
    echo "⚠️ kubectl 命令不可用，跳过 Pod 检查"
    echo ""
fi

# 7. 检查服务日志
echo "=== 7. 检查服务日志（最近 20 行）==="
if [ -n "$SERVICE" ]; then
    echo "--- $SERVICE 日志 ---"
    journalctl -u $SERVICE -n 20 --no-pager | grep -i "registry\|insecure\|tls" || echo "未找到相关日志"
    echo ""
else
    echo "⚠️ 服务未运行，无法查看日志"
    echo ""
fi

# 8. 生成修复建议
echo "=========================================="
echo "修复建议"
echo "=========================================="
echo ""

if [ ! -f /etc/rancher/rke2/registries.yaml ]; then
    echo "❌ 配置文件不存在"
    echo "   执行: sudo vi /etc/rancher/rke2/registries.yaml"
    echo "   添加以下内容:"
    echo ""
    cat <<'EOF'
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF
    echo ""
elif ! grep -q "192.168.80.100:30500" /etc/rancher/rke2/registries.yaml; then
    echo "❌ 配置文件中没有私有仓库配置"
    echo "   在配置文件中添加:"
    echo ""
    cat <<'EOF'
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
EOF
    echo ""
elif ! crictl info 2>/dev/null | grep -q "192.168.80.100:30500"; then
    echo "❌ containerd 未加载配置"
    echo "   需要重启服务:"
    if [ "$SERVICE" = "rke2-server" ]; then
        echo "   sudo systemctl restart rke2-server"
    elif [ "$SERVICE" = "rke2-agent" ]; then
        echo "   sudo systemctl restart rke2-agent"
    fi
    echo "   等待 30 秒后重新测试"
    echo ""
else
    echo "✓ 配置看起来正确"
    echo "   如果仍然有问题，请检查:"
    echo "   1. 是否所有节点都配置了"
    echo "   2. Pod 是否调度到了未配置的节点"
    echo "   3. 镜像是否真的存在于仓库中"
    echo ""
fi

echo "=========================================="
echo "诊断完成"
echo "=========================================="
