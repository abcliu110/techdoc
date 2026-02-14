#!/bin/bash

# 准备 Jenkins 和 Kaniko 镜像到私有仓库
# 在有外网访问的机器上执行此脚本

set -e

PRIVATE_REGISTRY="192.168.80.100:30500"

echo "=== 准备镜像到私有仓库 ==="
echo "私有仓库地址: ${PRIVATE_REGISTRY}"
echo ""

# 1. 拉取 Jenkins inbound-agent 镜像
echo ">>> 拉取 Jenkins inbound-agent 镜像"
docker pull jenkins/inbound-agent:latest

# 2. 拉取 Kaniko 镜像
echo ">>> 拉取 Kaniko 镜像"
docker pull gcr.io/kaniko-project/executor:debug

# 3. 重新打标签
echo ">>> 重新打标签"
docker tag jenkins/inbound-agent:latest \
  ${PRIVATE_REGISTRY}/jenkins/inbound-agent:latest

docker tag gcr.io/kaniko-project/executor:debug \
  ${PRIVATE_REGISTRY}/kaniko-project/executor:debug

# 4. 推送到私有仓库
echo ">>> 推送到私有仓库"
docker push ${PRIVATE_REGISTRY}/jenkins/inbound-agent:latest
docker push ${PRIVATE_REGISTRY}/kaniko-project/executor:debug

echo ""
echo "=== 完成 ==="
echo "镜像已推送到私有仓库："
echo "  - ${PRIVATE_REGISTRY}/jenkins/inbound-agent:latest"
echo "  - ${PRIVATE_REGISTRY}/kaniko-project/executor:debug"
echo ""
echo "现在可以在 Jenkinsfile-k8s 中使用这些镜像"
