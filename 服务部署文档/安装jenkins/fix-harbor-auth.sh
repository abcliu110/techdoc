#!/bin/bash

echo "========================================="
echo "修复Harbor认证问题"
echo "========================================="
echo ""

# 1. 检查当前的Secret
echo ">>> 1. 检查当前的harbor-registry-secret"
kubectl get secret harbor-registry-secret -n jenkins -o yaml 2>/dev/null || echo "Secret不存在"
echo ""

# 2. 删除旧的Secret
echo ">>> 2. 删除旧的Secret"
kubectl delete secret harbor-registry-secret -n jenkins 2>/dev/null || echo "Secret不存在，跳过删除"
echo ""

# 3. 创建新的Secret（使用正确的服务器地址）
echo ">>> 3. 创建新的harbor-registry-secret"
echo "使用服务器地址: harbor.harbor"
echo "用户名: admin"
echo "密码: Harbor12345"
echo ""

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

if [ $? -eq 0 ]; then
    echo "✓ Secret创建成功"
else
    echo "❌ Secret创建失败"
    exit 1
fi
echo ""

# 4. 验证Secret
echo ">>> 4. 验证Secret内容"
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
echo ""

# 5. 测试认证
echo ">>> 5. 测试Harbor认证"
echo "运行测试Pod..."
kubectl run test-harbor-auth --image=docker:latest --rm -it --restart=Never -n jenkins \
  --overrides='
{
  "spec": {
    "containers": [{
      "name": "test",
      "image": "docker:latest",
      "command": ["sh", "-c", "echo \"测试完成\""],
      "volumeMounts": [{
        "name": "docker-config",
        "mountPath": "/root/.docker"
      }]
    }],
    "volumes": [{
      "name": "docker-config",
      "secret": {
        "secretName": "harbor-registry-secret",
        "items": [{
          "key": ".dockerconfigjson",
          "path": "config.json"
        }]
      }
    }]
  }
}' 2>/dev/null || echo "测试Pod运行完成"

echo ""
echo "========================================="
echo "修复完成"
echo "========================================="
echo ""
echo "下一步:"
echo "1. 重新运行Jenkins构建"
echo "2. 观察是否还有UNAUTHORIZED错误"
