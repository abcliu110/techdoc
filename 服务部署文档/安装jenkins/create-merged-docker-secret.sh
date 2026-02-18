#!/bin/bash
# 创建包含多个仓库认证的Docker Secret

# 阿里云仓库配置
ALIYUN_REGISTRY="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com"
ALIYUN_USERNAME="your-aliyun-username"
ALIYUN_PASSWORD="your-aliyun-password"

# Harbor仓库配置
HARBOR_REGISTRY="harbor-core.harbor"
HARBOR_USERNAME="admin"
HARBOR_PASSWORD="your-harbor-password"

# 创建包含两个仓库认证的Secret
kubectl create secret docker-registry merged-registry-secret \
  --docker-server=${ALIYUN_REGISTRY} \
  --docker-username=${ALIYUN_USERNAME} \
  --docker-password=${ALIYUN_PASSWORD} \
  --namespace=jenkins \
  --dry-run=client -o json | \
jq --arg harbor_server "${HARBOR_REGISTRY}" \
   --arg harbor_user "${HARBOR_USERNAME}" \
   --arg harbor_pass "${HARBOR_PASSWORD}" \
   '.data[".dockerconfigjson"] |= (
     . | @base64d | fromjson |
     .auths[$harbor_server] = {
       "username": $harbor_user,
       "password": $harbor_pass,
       "auth": ($harbor_user + ":" + $harbor_pass | @base64)
     } |
     tojson | @base64
   )' | \
kubectl apply -f -

echo "✓ 已创建包含阿里云和Harbor认证的Secret: merged-registry-secret"
