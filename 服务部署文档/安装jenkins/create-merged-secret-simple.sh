#!/bin/bash
# 创建包含阿里云和Harbor认证的合并Secret

# ========== 配置区域（请修改这里） ==========
ALIYUN_USERNAME="your-aliyun-username"
ALIYUN_PASSWORD="your-aliyun-password"
HARBOR_USERNAME="admin"
HARBOR_PASSWORD="Harbor12345"
NAMESPACE="jenkins"
# ==========================================

# 生成auth字段（base64编码的 username:password）
ALIYUN_AUTH=$(echo -n "${ALIYUN_USERNAME}:${ALIYUN_PASSWORD}" | base64 -w 0)
HARBOR_AUTH=$(echo -n "${HARBOR_USERNAME}:${HARBOR_PASSWORD}" | base64 -w 0)

# 创建JSON配置
cat > /tmp/docker-config.json <<EOF
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "${ALIYUN_USERNAME}",
      "password": "${ALIYUN_PASSWORD}",
      "auth": "${ALIYUN_AUTH}"
    },
    "harbor-core.harbor": {
      "username": "${HARBOR_USERNAME}",
      "password": "${HARBOR_PASSWORD}",
      "auth": "${HARBOR_AUTH}"
    }
  }
}
EOF

echo "生成的配置文件内容："
cat /tmp/docker-config.json | jq . 2>/dev/null || cat /tmp/docker-config.json

# 删除旧的Secret（如果存在）
kubectl delete secret merged-registry-secret -n ${NAMESPACE} 2>/dev/null || true

# 创建新的Secret
kubectl create secret generic merged-registry-secret \
  --from-file=.dockerconfigjson=/tmp/docker-config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace=${NAMESPACE}

# 清理临时文件
rm /tmp/docker-config.json

echo ""
echo "✓ Secret创建成功！"
echo ""
echo "验证命令："
echo "kubectl get secret merged-registry-secret -n ${NAMESPACE} -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq ."
