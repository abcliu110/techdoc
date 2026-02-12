# Rancher 中创建 Docker Registry Secret 详细指南

## 一、通过 Rancher UI 创建（推荐）

### 1.1 登录 Rancher

```
1. 打开浏览器访问 Rancher 地址
2. 输入用户名和密码登录
```

### 1.2 选择集群和命名空间

```
1. 在 Rancher 首页，点击你的集群名称
2. 左侧菜单：工作负载 → 密文（Secrets）
3. 右上角选择命名空间：jenkins
```

**详细步骤：**

```
Rancher 首页
    ↓
点击集群（例如：local）
    ↓
左侧菜单：工作负载（Workloads）
    ↓
密文（Secrets）
    ↓
右上角命名空间下拉框：选择 jenkins
```

### 1.3 创建 Registry 密文

**步骤 1：点击创建按钮**

```
在密文页面，点击右上角 "创建" 按钮
```

**步骤 2：选择密文类型**

```
密文类型：选择 "Registry"（镜像仓库凭证）
```

**步骤 3：填写基本信息**

```
名称：docker-registry-secret
命名空间：jenkins
描述：用于 Jenkins 推送镜像到腾讯云 CCR（可选）
```

**步骤 4：填写镜像仓库信息**

根据你使用的镜像仓库填写：

#### 腾讯云容器镜像服务（CCR）

```
镜像仓库地址：ccr.ccs.tencentyun.com
用户名：你的腾讯云账号 ID（例如：100012345678）
密码：你的腾讯云访问密钥
```

**如何获取腾讯云凭据：**

```
1. 登录腾讯云控制台
2. 右上角头像 → 访问管理 → 访问密钥 → API 密钥管理
3. 新建密钥或使用现有密钥
4. SecretId 作为用户名
5. SecretKey 作为密码
```

**完整示例：**

```
镜像仓库地址：ccr.ccs.tencentyun.com
用户名：AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
密码：xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 阿里云容器镜像服务（ACR）

```
镜像仓库地址：registry.cn-hangzhou.aliyuncs.com
用户名：你的阿里云账号
密码：你的阿里云镜像仓库密码
```

**如何获取阿里云凭据：**

```
1. 登录阿里云控制台
2. 容器镜像服务 → 访问凭证
3. 设置 Registry 登录密码
4. 使用阿里云账号和 Registry 密码
```

#### Docker Hub

```
镜像仓库地址：docker.io（或留空）
用户名：你的 Docker Hub 用户名
密码：你的 Docker Hub 密码或访问令牌
```

#### Harbor（私有仓库）

```
镜像仓库地址：harbor.company.com
用户名：你的 Harbor 用户名
密码：你的 Harbor 密码
```

**步骤 5：保存**

```
点击页面底部 "保存" 按钮
```

### 1.4 验证创建成功

**在密文列表中查看：**

```
工作负载 → 密文 → 命名空间选择 jenkins
应该能看到：
- 名称：docker-registry-secret
- 类型：kubernetes.io/dockerconfigjson
- 命名空间：jenkins
```

---

## 二、通过 kubectl 创建

### 2.1 方法一：使用 kubectl create 命令

**腾讯云 CCR：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-password=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-email=your-email@example.com \
  -n jenkins
```

**阿里云 ACR：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=registry.cn-hangzhou.aliyuncs.com \
  --docker-username=your-aliyun-account \
  --docker-password=your-registry-password \
  --docker-email=your-email@example.com \
  -n jenkins
```

**Docker Hub：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=docker.io \
  --docker-username=your-dockerhub-username \
  --docker-password=your-dockerhub-password \
  --docker-email=your-email@example.com \
  -n jenkins
```

**Harbor：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=harbor.company.com \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  --docker-email=admin@company.com \
  -n jenkins
```

### 2.2 方法二：使用 YAML 文件

**步骤 1：生成 Docker 配置文件**

```bash
# 创建临时目录
mkdir -p /tmp/docker-secret
cd /tmp/docker-secret

# 创建 Docker 配置文件
cat > config.json <<EOF
{
  "auths": {
    "ccr.ccs.tencentyun.com": {
      "username": "AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "email": "your-email@example.com",
      "auth": "$(echo -n 'AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' | base64)"
    }
  }
}
EOF
```

**步骤 2：Base64 编码**

```bash
# 对配置文件进行 base64 编码
cat config.json | base64 -w 0 > config.json.base64

# 查看编码结果
cat config.json.base64
```

**步骤 3：创建 YAML 文件**

```yaml
# docker-registry-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <将 config.json.base64 的内容粘贴到这里>
```

**完整示例：**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ewogICJhdXRocyI6IHsKICAgICJjY3IuY2NzLnRlbmNlbnR5dW4uY29tIjogewogICAgICAidXNlcm5hbWUiOiAiQUtJRHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4IiwKICAgICAgInBhc3N3b3JkIjogInh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHgiLAogICAgICAiZW1haWwiOiAieW91ci1lbWFpbEBleGFtcGxlLmNvbSIsCiAgICAgICJhdXRoIjogIlFVdEpSSGg0ZUhoNGVIZzZlSGg0ZUhoNGVIZzZlSGc9IgogICAgfQogIH0KfQo=
```

**步骤 4：应用 YAML**

```bash
kubectl apply -f docker-registry-secret.yaml
```

### 2.3 方法三：通过 Rancher kubectl Shell

**步骤 1：打开 Rancher kubectl Shell**

```
Rancher → 选择集群 → 右上角 "kubectl Shell" 图标
```

**步骤 2：执行创建命令**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-password=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-email=your-email@example.com \
  -n jenkins
```

---

## 三、验证 Secret 创建成功

### 3.1 通过 Rancher UI 验证

```
1. Rancher → 集群 → 工作负载 → 密文
2. 命名空间选择：jenkins
3. 查找：docker-registry-secret
4. 点击查看详情
```

**应该看到：**

```
名称：docker-registry-secret
类型：kubernetes.io/dockerconfigjson
命名空间：jenkins
数据：
  .dockerconfigjson: *** (已加密)
```

### 3.2 通过 kubectl 验证

**查看 Secret 列表：**

```bash
kubectl get secrets -n jenkins

# 输出示例：
NAME                      TYPE                             DATA   AGE
docker-registry-secret    kubernetes.io/dockerconfigjson   1      5m
```

**查看 Secret 详情：**

```bash
kubectl describe secret docker-registry-secret -n jenkins

# 输出示例：
Name:         docker-registry-secret
Namespace:    jenkins
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  XXX bytes
```

**查看 Secret 内容（Base64 解码）：**

```bash
kubectl get secret docker-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq

# 输出示例：
{
  "auths": {
    "ccr.ccs.tencentyun.com": {
      "username": "AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "email": "your-email@example.com",
      "auth": "QUtJRHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4Onh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHg="
    }
  }
}
```

### 3.3 测试 Secret 是否有效

**创建测试 Pod 使用 Secret：**

```bash
kubectl run test-pull \
  --image=ccr.ccs.tencentyun.com/nms4cloud/test:latest \
  --image-pull-policy=Always \
  --overrides='{"spec":{"imagePullSecrets":[{"name":"docker-registry-secret"}]}}' \
  -n jenkins
```

**查看 Pod 状态：**

```bash
kubectl get pod test-pull -n jenkins

# 如果 Secret 有效，Pod 应该能成功拉取镜像
# 如果 Secret 无效，会看到 ImagePullBackOff 错误
```

**清理测试 Pod：**

```bash
kubectl delete pod test-pull -n jenkins
```

---

## 四、在 Jenkinsfile 中使用 Secret

### 4.1 Kaniko 使用 Secret

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
"""
        }
    }

    stages {
        stage('构建镜像') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                          --context=\${WORKSPACE} \
                          --dockerfile=\${WORKSPACE}/Dockerfile \
                          --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0
                    """
                }
            }
        }
    }
}
```

### 4.2 Pod 拉取私有镜像使用 Secret

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  namespace: jenkins
spec:
  containers:
  - name: myapp
    image: ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0
  imagePullSecrets:
  - name: docker-registry-secret
```

---

## 五、常见问题排查

### 5.1 Secret 创建失败

**问题：** 在 Rancher UI 中创建 Secret 时提示错误

**排查步骤：**

```bash
# 1. 检查命名空间是否存在
kubectl get namespace jenkins

# 2. 检查是否有权限
kubectl auth can-i create secrets -n jenkins

# 3. 查看详细错误信息
kubectl get events -n jenkins --sort-by='.lastTimestamp'
```

### 5.2 Kaniko 推送镜像失败

**问题：** Kaniko 构建成功但推送失败

```
error checking push permissions -- make sure you entered the correct tag name,
and that you are authenticated correctly
```

**排查步骤：**

**1. 检查 Secret 是否正确挂载：**

```bash
# 查看 Pod 中的 Docker 配置
kubectl exec -it <kaniko-pod-name> -c kaniko -n jenkins -- cat /kaniko/.docker/config.json
```

**2. 检查镜像仓库地址是否匹配：**

```bash
# Secret 中的地址
kubectl get secret docker-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq '.auths | keys'

# 输出应该包含你要推送的镜像仓库地址
# 例如：["ccr.ccs.tencentyun.com"]
```

**3. 检查凭据是否有效：**

```bash
# 手动测试登录
docker login ccr.ccs.tencentyun.com \
  -u AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -p xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 5.3 Secret 内容错误

**问题：** Secret 创建成功但内容不正确

**解决方案：删除并重新创建**

```bash
# 删除 Secret
kubectl delete secret docker-registry-secret -n jenkins

# 重新创建
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=正确的用户名 \
  --docker-password=正确的密码 \
  --docker-email=your-email@example.com \
  -n jenkins
```

### 5.4 多个镜像仓库

**问题：** 需要同时访问多个镜像仓库（例如：腾讯云 + 阿里云）

**解决方案：创建包含多个仓库的 Secret**

```bash
# 1. 创建 Docker 配置文件
cat > config.json <<EOF
{
  "auths": {
    "ccr.ccs.tencentyun.com": {
      "username": "腾讯云用户名",
      "password": "腾讯云密码",
      "auth": "$(echo -n '腾讯云用户名:腾讯云密码' | base64)"
    },
    "registry.cn-hangzhou.aliyuncs.com": {
      "username": "阿里云用户名",
      "password": "阿里云密码",
      "auth": "$(echo -n '阿里云用户名:阿里云密码' | base64)"
    }
  }
}
EOF

# 2. 创建 Secret
kubectl create secret generic docker-registry-secret \
  --from-file=.dockerconfigjson=config.json \
  --type=kubernetes.io/dockerconfigjson \
  -n jenkins
```

---

## 六、安全最佳实践

### 6.1 使用最小权限原则

```
1. 为 Jenkins 创建专用的镜像仓库账号
2. 只授予推送镜像的权限，不授予删除权限
3. 定期轮换密钥
```

### 6.2 Secret 加密

**RKE2 默认启用 Secret 加密，但可以验证：**

```bash
# 查看 Secret 加密配置
kubectl get secrets -n jenkins -o yaml | grep -A 5 "encryption"
```

### 6.3 限制 Secret 访问

**创建 RBAC 规则限制 Secret 访问：**

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-secret-reader
  namespace: jenkins
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["docker-registry-secret"]
  verbs: ["get"]
```

---

## 七、快速参考

### 7.1 腾讯云 CCR 完整示例

**通过 Rancher UI：**

```
密文类型：Registry
名称：docker-registry-secret
命名空间：jenkins
镜像仓库地址：ccr.ccs.tencentyun.com
用户名：AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
密码：xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**通过 kubectl：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=AKIDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-password=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --docker-email=your-email@example.com \
  -n jenkins
```

### 7.2 验证命令

```bash
# 查看 Secret
kubectl get secret docker-registry-secret -n jenkins

# 查看详情
kubectl describe secret docker-registry-secret -n jenkins

# 查看内容
kubectl get secret docker-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq
```

### 7.3 删除和重建

```bash
# 删除
kubectl delete secret docker-registry-secret -n jenkins

# 重建
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=新用户名 \
  --docker-password=新密码 \
  -n jenkins
```

---

## 八、总结

### 8.1 推荐方式

**对于不熟悉 kubectl 的用户：**
- ✅ 使用 Rancher UI 创建（最简单、最直观）

**对于熟悉命令行的用户：**
- ✅ 使用 kubectl create 命令（快速、可脚本化）

**对于需要版本控制的场景：**
- ✅ 使用 YAML 文件（可以纳入 Git 管理，但注意不要提交敏感信息）

### 8.2 关键点

1. ✅ Secret 名称必须是 `docker-registry-secret`（或在 Jenkinsfile 中指定的名称）
2. ✅ Secret 必须在 `jenkins` 命名空间中
3. ✅ Secret 类型必须是 `kubernetes.io/dockerconfigjson`
4. ✅ 镜像仓库地址必须与推送的镜像地址匹配
5. ✅ 凭据必须有推送镜像的权限

### 8.3 下一步

创建 Secret 后，可以：
1. 在 Jenkinsfile 中使用 Kaniko 构建镜像
2. 在 K8s Deployment 中使用 imagePullSecrets 拉取私有镜像
3. 配置自动化 CI/CD 流程
