#!/bin/bash

# 阿里云个人镜像仓库凭证配置脚本
# 用于 Jenkins 构建并推送镜像到阿里云个人免费版镜像仓库

# ============================================
# 配置参数（请根据实际情况修改）
# ============================================

# 阿里云容器镜像服务信息
REGISTRY_SERVER="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com"
REGISTRY_USERNAME="你的阿里云账号"  # 通常是阿里云账号或子账号
REGISTRY_PASSWORD="你的镜像仓库密码"  # 在阿里云容器镜像服务中设置的密码
NAMESPACE="jenkins"  # Jenkins 所在的 Kubernetes 命名空间

# ============================================
# 创建 Docker Registry Secret
# ============================================

echo "正在创建阿里云镜像仓库凭证..."

kubectl create secret docker-registry aliyun-registry-secret \
  --docker-server=${REGISTRY_SERVER} \
  --docker-username=${REGISTRY_USERNAME} \
  --docker-password=${REGISTRY_PASSWORD} \
  --namespace=${NAMESPACE}

if [ $? -eq 0 ]; then
    echo "✅ 凭证创建成功！"
    echo ""
    echo "验证凭证："
    kubectl get secret aliyun-registry-secret -n ${NAMESPACE}
    echo ""
    echo "查看凭证详情："
    kubectl describe secret aliyun-registry-secret -n ${NAMESPACE}
else
    echo "❌ 凭证创建失败！"
    echo ""
    echo "如果凭证已存在，可以先删除再创建："
    echo "kubectl delete secret aliyun-registry-secret -n ${NAMESPACE}"
fi

# ============================================
# 使用说明
# ============================================

cat <<'EOF'

📝 使用说明：

1. 在阿里云容器镜像服务中获取密码：
   - 登录阿里云控制台
   - 容器镜像服务 → 个人版 → 访问凭证
   - 设置或重置固定密码

2. 修改本脚本中的配置参数：
   - REGISTRY_USERNAME: 你的阿里云账号
   - REGISTRY_PASSWORD: 镜像仓库密码

3. 运行脚本：
   bash 创建阿里云镜像仓库凭证.sh

4. 验证凭证是否可用：
   kubectl get secret aliyun-registry-secret -n jenkins -o yaml

EOF
