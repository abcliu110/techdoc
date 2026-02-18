# Docker 认证配置合并方案对比

## 场景说明
需要同时推送镜像到两个仓库：
- 阿里云个人仓库
- Harbor 本地仓库

---

## 方案1：两个独立Secret + jq运行时合并（之前的方案）

### 1.1 Kubernetes中的配置

```yaml
# Secret 1: 阿里云认证
apiVersion: v1
kind: Secret
metadata:
  name: aliyun-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJhbGl5dW4uY29tIjp7fX19  # base64编码

# 解码后内容：
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "aliyun-user",
      "password": "aliyun-pass",
      "auth": "YWxpeXVuLXVzZXI6YWxpeXVuLXBhc3M="
    }
  }
}

---

# Secret 2: Harbor认证
apiVersion: v1
kind: Secret
metadata:
  name: harbor-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3IuY29tIjp7fX19  # base64编码

# 解码后内容：
{
  "auths": {
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

### 1.2 Pod中的挂载

```yaml
volumeMounts:
- name: aliyun-docker-config
  mountPath: /kaniko/.docker/aliyun    # 挂载到子目录
- name: harbor-docker-config
  mountPath: /kaniko/.docker/harbor    # 挂载到子目录

volumes:
- name: aliyun-docker-config
  secret:
    secretName: aliyun-registry-secret
- name: harbor-docker-config
  secret:
    secretName: harbor-registry-secret
```

### 1.3 运行时的文件结构

```
/kaniko/.docker/
├── aliyun/
│   └── config.json    # 只包含阿里云认证
└── harbor/
    └── config.json    # 只包含Harbor认证
```

### 1.4 需要在脚本中合并（使用jq）

```bash
# 创建空配置
echo '{"auths":{}}' > /kaniko/.docker/config.json

# 使用jq合并阿里云配置
jq -s '.[0].auths * .[1].auths | {auths: .}' \
    /kaniko/.docker/config.json \
    /kaniko/.docker/aliyun/config.json > /tmp/merged.json
mv /tmp/merged.json /kaniko/.docker/config.json

# 使用jq合并Harbor配置
jq -s '.[0].auths * .[1].auths | {auths: .}' \
    /kaniko/.docker/config.json \
    /kaniko/.docker/harbor/config.json > /tmp/merged.json
mv /tmp/merged.json /kaniko/.docker/config.json

# 最终得到：
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {...},
    "harbor-core.harbor": {...}
  }
}
```

### ❌ 问题
1. **依赖jq工具**：如果Kaniko镜像中没有jq，无法合并
2. **逻辑复杂**：需要40行代码处理各种情况
3. **运行时开销**：每次构建都要执行合并操作
4. **容易出错**：如果没有jq且两个都推送，只有一个会成功

---

## 方案2：一个合并的Secret（新方案）✅

### 2.1 Kubernetes中的配置

```yaml
# 只有一个Secret，包含两个仓库的认证
apiVersion: v1
kind: Secret
metadata:
  name: merged-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJhbGl5dW4uY29tIjp7fSwiaGFyYm9yLmNvbSI6e319fQ==

# 解码后内容（已经合并好了）：
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "aliyun-user",
      "password": "aliyun-pass",
      "auth": "YWxpeXVuLXVzZXI6YWxpeXVuLXBhc3M="
    },
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

### 2.2 Pod中的挂载

```yaml
volumeMounts:
- name: docker-config
  mountPath: /kaniko/.docker    # 直接挂载到目标目录

volumes:
- name: docker-config
  secret:
    secretName: merged-registry-secret
    items:
    - key: .dockerconfigjson
      path: config.json
```

### 2.3 运行时的文件结构

```
/kaniko/.docker/
└── config.json    # 已经包含两个仓库的认证
```

### 2.4 脚本中无需合并

```bash
# 只需要验证文件存在
if [ -f /kaniko/.docker/config.json ]; then
    echo "✓ Docker 认证配置已就绪"
else
    echo "❌ 错误: 未找到 Docker 认证配置"
    exit 1
fi

# Kaniko会自动读取这个文件，推送到两个仓库
```

### ✅ 优点
1. **无需jq**：认证信息在创建Secret时就已经合并好了
2. **逻辑简单**：只需要5行验证代码
3. **无运行时开销**：不需要每次构建都合并
4. **不会出错**：两个仓库的认证都在同一个文件中

---

## 如何创建合并的Secret

### 方法1：使用kubectl命令（只能添加一个仓库）

```bash
# 先创建包含阿里云认证的Secret
kubectl create secret docker-registry merged-registry-secret \
  --docker-server=crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com \
  --docker-username=your-aliyun-username \
  --docker-password=your-aliyun-password \
  --namespace=jenkins
```

### 方法2：手动创建JSON文件（推荐）

```bash
# 1. 创建包含两个仓库认证的JSON文件
cat > docker-config.json <<EOF
{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "your-aliyun-username",
      "password": "your-aliyun-password",
      "auth": "$(echo -n 'your-aliyun-username:your-aliyun-password' | base64)"
    },
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "$(echo -n 'admin:Harbor12345' | base64)"
    }
  }
}
EOF

# 2. 创建Secret
kubectl create secret generic merged-registry-secret \
  --from-file=.dockerconfigjson=docker-config.json \
  --type=kubernetes.io/dockerconfigjson \
  --namespace=jenkins

# 3. 删除临时文件
rm docker-config.json
```

### 方法3：使用YAML文件

```bash
# 1. 先生成base64编码的配置
CONFIG_JSON='{
  "auths": {
    "crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com": {
      "username": "your-aliyun-username",
      "password": "your-aliyun-password",
      "auth": "'$(echo -n 'your-aliyun-username:your-aliyun-password' | base64)'"
    },
    "harbor-core.harbor": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "'$(echo -n 'admin:Harbor12345' | base64)'"
    }
  }
}'

CONFIG_BASE64=$(echo -n "$CONFIG_JSON" | base64 -w 0)

# 2. 创建YAML文件
cat > merged-registry-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: merged-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: $CONFIG_BASE64
EOF

# 3. 应用
kubectl apply -f merged-registry-secret.yaml
```

---

## 总结

| 对比项 | 方案1（两个Secret+jq） | 方案2（一个合并Secret） |
|--------|----------------------|----------------------|
| Secret数量 | 2个 | 1个 |
| 挂载点 | 2个子目录 | 1个目录 |
| 是否需要jq | ✅ 需要 | ❌ 不需要 |
| 脚本代码行数 | ~40行 | ~5行 |
| 运行时合并 | ✅ 需要 | ❌ 不需要 |
| 复杂度 | 高 | 低 |
| 维护性 | 差 | 好 |

**推荐使用方案2**：一次性创建好合并的Secret，简单、高效、不易出错。
