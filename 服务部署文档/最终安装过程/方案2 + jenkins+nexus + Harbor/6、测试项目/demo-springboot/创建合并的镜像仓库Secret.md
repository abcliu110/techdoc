# 创建合并的镜像仓库 Secret（Harbor + 阿里云）

## 问题说明

当 Kaniko 镜像中没有 `jq` 工具时，无法自动合并多个仓库的认证配置，导致推送失败。

## 解决方案

创建一个包含 Harbor 和阿里云两个仓库认证的合并 Secret。

## 步骤

### 1. 准备认证信息

**Harbor 仓库：**
- 服务器：`harbor-core.harbor`
- 用户名：`admin`
- 密码：`Harbor12345`

**阿里云个人版仓库：**
- 服务器：`crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com`
- 用户名：`abcliu110`
- 密码：`st11338st11338`

### 2. 生成 auth 字段

```bash
# Harbor auth
echo -n "admin:Harbor12345" | base64
# 输出: YWRtaW46SGFyYm9yMTIzNDU=

# 阿里云 auth
echo -n "abcliu110:st11338st11338" | base64
# 输出: YWJjbGl1MTEwOnN0MTEzMzhzdDExMzM4
```

### 3. 创建合并的 config.json

创建文件 `merged-docker-config.json`：

```json
{
  "auths": {
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    },
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "abcliu110",
      "password": "st11338st11338",
      "auth": "YWJjbGl1MTEwOnN0MTEzMzhzdDExMzM4"
    }
  }
}
```

### 4. 创建 Kubernetes Secret

```bash
# 删除旧的 Secret（如果存在）
kubectl delete secret merged-registry-secret -n jenkins

# 创建新的合并 Secret
kubectl create secret generic merged-registry-secret \
  --from-file=.dockerconfigjson=merged-docker-config.json \
  --type=kubernetes.io/dockerconfigjson \
  -n jenkins
```

### 5. 验证 Secret

```bash
# 查看 Secret
kubectl get secret merged-registry-secret -n jenkins -o yaml

# 解码查看内容
kubectl get secret merged-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

### 6. 修改 Jenkinsfile

修改 Pod 配置，使用合并的 Secret：

```groovy
  - name: kaniko
    image: m.daocloud.io/gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: jenkins-home
      mountPath: /var/jenkins_home
    # 使用合并的认证配置
    - name: merged-docker-config
      mountPath: /kaniko/.docker
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2000m
        memory: 2Gi

  volumes:
  - name: jenkins-home
    persistentVolumeClaim:
      claimName: jenkins-pvc
  # 使用合并的镜像仓库认证配置
  - name: merged-docker-config
    secret:
      secretName: merged-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
```

### 7. 简化 Shell 脚本

由于使用了合并的 Secret，不再需要手动合并配置：

```bash
# 不再需要合并逻辑，直接使用挂载的配置
echo ">>> 使用合并的镜像仓库认证配置"
ls -la /kaniko/.docker/

# 验证配置文件
if [ -f /kaniko/.docker/config.json ]; then
    echo "✓ 认证配置文件已就绪"
else
    echo "❌ 错误: 认证配置文件不存在"
    exit 1
fi
```

## 优势

1. **简化配置**：不需要在 Jenkinsfile 中合并 JSON
2. **无需 jq**：不依赖 Kaniko 镜像中的 jq 工具
3. **更可靠**：避免配置合并失败的风险
4. **易于维护**：所有认证信息集中管理

## 注意事项

1. **安全性**：
   - Secret 包含明文密码，确保 RBAC 权限正确配置
   - 不要将 `merged-docker-config.json` 提交到 Git

2. **更新密码**：
   - 如果任一仓库密码变更，需要重新创建 Secret
   - 删除旧 Secret 并创建新的

3. **命名空间**：
   - Secret 必须在 Jenkins Pod 所在的命名空间（jenkins）
   - 如果 Jenkins 在其他命名空间，需要相应调整

## 完整的 YAML 文件

创建文件 `merged-registry-secret.yaml`：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: merged-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3ItY29yZS5oYXJib3IiOnsidXNlcm5hbWUiOiJhZG1pbiIsInBhc3N3b3JkIjoiSGFyYm9yMTIzNDUiLCJhdXRoIjoiWVdSdGFXNDZTR0Z5WW05eU1USXpORFU9In0sImNycGktY3NnYnQydDdqMTVjajE3OC5jbi1oYW5nemhvdS5wZXJzb25hbC5jci5hbGl5dW5jcy5jb20iOnsidXNlcm5hbWUiOiJhYmNsaXUxMTAiLCJwYXNzd29yZCI6InN0MTEzMzhzdDExMzM4IiwiYXV0aCI6IllXSmpiR2wxTVRFd09uTjBNVEV6TXpoemRERXhNek00In19fQ==
```

应用：

```bash
kubectl apply -f merged-registry-secret.yaml
```

## 解码后的内容

```json
{
  "auths": {
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    },
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "abcliu110",
      "password": "st11338st11338",
      "auth": "YWJjbGl1MTEwOnN0MTEzMzhzdDExMzM4"
    }
  }
}
```
