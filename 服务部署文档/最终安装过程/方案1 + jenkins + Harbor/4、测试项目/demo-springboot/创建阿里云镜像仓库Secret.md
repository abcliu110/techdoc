# 创建阿里云镜像仓库 Kubernetes Secret

## 重要提示

阿里云个人版镜像仓库必须使用专属域名，不能使用通用域名 `registry.cn-hangzhou.aliyuncs.com`。

每个账号的专属域名不同，格式为：`crpi-xxxxxx.cn-hangzhou.personal.cr.aliyuncs.com`

## 一、获取阿里云镜像仓库访问凭证

### 1. 登录阿里云容器镜像服务控制台

访问：https://cr.console.aliyun.com/

### 2. 获取专属域名

1. 点击左侧菜单 **"默认实例"** 或 **"个人实例"**
2. 点击 **"仓库管理"** → **"镜像仓库"**
3. 选择你的命名空间
4. 点击任意仓库名称
5. 在仓库详情页面查看 **公网地址**，记录专属域名

**示例**：
```
公网地址：crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/lgy-test-repository
专属域名：crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com
```

### 3. 设置访问凭证

1. 点击左侧菜单 **"访问凭证"**
2. 如果还没有设置固定密码，点击 **"设置固定密码"**
3. 设置并记住你的密码
4. 记录下用户名（通常显示在页面上）

**用户名格式示例**：
- 个人账号：`your-aliyun-account@aliyun.com` 或 `your-username`
- RAM 用户：`your-ram-username`

## 二、在 Kubernetes 中创建 Secret

### 重要：Secret 必须包含 auth 字段

阿里云个人版镜像仓库的 Secret 必须包含 `auth` 字段（base64 编码的 `username:password`），不能只有 `username` 和 `password` 字段。

### 推荐方式：使用 YAML 文件创建

#### 步骤 1: 生成 base64 编码的认证信息

```bash
# 1. 生成 auth 字段（base64 编码的 username:password）
echo -n '你的用户名:你的密码' | base64
# 示例：echo -n 'abcliu110:st11338st11338' | base64
# 输出：YWJjbGl1MTEwOnN0MTEzMzhzdDExMzM4

# 2. 创建认证配置文件（使用专属域名）
cat > config.json <<EOF
{
  "auths": {
    "crpi-xxxxxx.cn-hangzhou.personal.cr.aliyuncs.com": {
      "auth": "上面生成的base64字符串"
    }
  }
}
EOF

# 3. 生成 .dockerconfigjson 字段（base64 编码整个 config.json）
cat config.json | base64 -w 0
```

#### 步骤 2: 创建 Secret YAML 文件

创建 `aliyun-registry-secret.yaml`：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aliyun-registry-secret
  namespace: jenkins  # 注意：必须与 Jenkins 运行的命名空间一致
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <这里粘贴上面生成的 base64 字符串>
```

**完整示例**（使用实际值）：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aliyun-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  # 用户名: abcliu110
  # 密码: st11338st11338
  # 专属域名: crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com
  .dockerconfigjson: eyJhdXRocyI6eyJjcnBpLWNzZ2J0MnQ3ajE1Y2oxNzguY24taGFuZ3pob3UucGVyc29uYWwuY3IuYWxpeXVuY3MuY29tIjp7ImF1dGgiOiJZV0pqYkdsMU1URXdPbk4wTVRFek16aHpkREV4TXpNNCJ9fX0=
```

#### 步骤 3: 应用 Secret

```bash
kubectl apply -f aliyun-registry-secret.yaml
```

### 不推荐：使用 kubectl 命令创建

使用 `kubectl create secret docker-registry` 命令创建的 Secret 格式可能不正确（缺少 auth 字段），建议使用 YAML 文件方式。

如果一定要使用命令行，需要手动修改 Secret 添加 auth 字段：

```bash
# 1. 创建 Secret（会缺少 auth 字段）
kubectl create secret docker-registry aliyun-registry-secret \
  --docker-server=crpi-xxxxxx.cn-hangzhou.personal.cr.aliyuncs.com \
  --docker-username=你的用户名 \
  --docker-password=你的密码 \
  --docker-email=你的邮箱 \
  -n jenkins

# 2. 导出 Secret
kubectl get secret aliyun-registry-secret -n jenkins -o yaml > secret.yaml

# 3. 手动编辑 secret.yaml，添加 auth 字段
# 4. 重新应用
kubectl apply -f secret.yaml
```

## 三、验证 Secret 是否创建成功

### 1. 查看 Secret

```bash
kubectl get secret aliyun-registry-secret -n jenkins
```

输出示例：
```
NAME                      TYPE                             DATA   AGE
aliyun-registry-secret    kubernetes.io/dockerconfigjson   1      10s
```

### 2. 查看 Secret 详细信息

```bash
kubectl describe secret aliyun-registry-secret -n jenkins
```

### 3. 验证 Secret 内容格式

```bash
# 查看 Secret 内容
kubectl get secret aliyun-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

**正确的输出格式**（必须包含 auth 字段）：
```json
{"auths":{"crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com":{"auth":"YWJjbGl1MTEwOnN0MTEzMzhzdDExMzM4"}}}
```

**错误的输出格式**（只有 username 和 password，缺少 auth）：
```json
{"auths":{"crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com":{"username":"abcliu110","password":"st11338st11338"}}}
```

如果是错误格式，需要重新创建 Secret。

## 四、测试 Secret 是否有效

### 方式一：运行 Jenkins 流水线测试

1. 在 Jenkins 中运行构建
2. 勾选 `BUILD_DOCKER_IMAGE` 参数
3. 查看构建日志，确认镜像推送成功
4. 在阿里云控制台查看镜像是否上传

### 方式二：创建测试 Pod（可选）

创建 `test-pod.yaml`：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-aliyun-pull
  namespace: jenkins
spec:
  imagePullSecrets:
  - name: aliyun-registry-secret
  containers:
  - name: test
    image: crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/lgy-test-repository:latest
    command: ["sleep", "3600"]
```

应用并查看：
```bash
kubectl apply -f test-pod.yaml
kubectl get pod test-aliyun-pull -n jenkins
kubectl describe pod test-aliyun-pull -n jenkins
```

如果 Pod 成功拉取镜像并运行，说明 Secret 配置正确。

清理测试 Pod：
```bash
kubectl delete pod test-aliyun-pull -n jenkins
```

## 五、常见问题

### 1. Secret 创建失败

**错误**: `Error from server (AlreadyExists): secrets "aliyun-registry-secret" already exists`

**解决**: 删除旧的 Secret 后重新创建
```bash
kubectl delete secret aliyun-registry-secret -n jenkins
# 然后重新创建
```

### 2. 认证失败：DENIED: requested access to the resource is denied

**可能原因**：
- 使用了错误的域名（通用域名而不是专属域名）
- Secret 格式不正确（缺少 auth 字段）
- 用户名或密码错误

**解决**：
1. 确认使用的是专属域名（`crpi-xxxxxx.cn-hangzhou.personal.cr.aliyuncs.com`）
2. 验证 Secret 格式是否包含 auth 字段
3. 在阿里云控制台重新确认用户名和密码
4. 重新创建 Secret

### 3. 找不到 Secret

**错误**: Pod 启动失败，提示找不到 Secret

**解决**: 确认 Secret 和 Jenkins 在同一个命名空间
```bash
# 查看所有命名空间的 Secret
kubectl get secret --all-namespaces | grep aliyun

# 如果在错误的命名空间，删除后在正确的命名空间重新创建
kubectl delete secret aliyun-registry-secret -n default
kubectl apply -f aliyun-registry-secret.yaml
```

### 4. Secret 格式不正确

**错误**: 推送镜像时认证失败

**原因**: 使用 Rancher UI 或 `kubectl create` 命令创建的 Secret 可能缺少 auth 字段

**解决**: 使用 YAML 文件方式重新创建 Secret，确保包含 auth 字段

### 5. 密码包含特殊字符

如果密码包含特殊字符（如 `$`, `!`, `@` 等），在生成 base64 时需要注意：

```bash
# 使用单引号包裹密码，避免 shell 解释特殊字符
echo -n 'username:My$Pass!word@123' | base64
```

## 六、更新 Secret

如果需要更新密码：

```bash
# 删除旧的 Secret
kubectl delete secret aliyun-registry-secret -n jenkins

# 重新生成并应用新的 Secret
kubectl apply -f aliyun-registry-secret.yaml
```

## 七、安全建议

1. **不要在 Jenkinsfile 中硬编码密码**
2. **定期更换密码**
3. **使用 RAM 用户而不是主账号**（推荐）
4. **限制 RAM 用户权限**，只授予镜像推送权限
5. **定期审计 Secret 的使用情况**

## 八、完整流程总结

1. 登录阿里云容器镜像服务控制台
2. 获取专属域名（个人版必须）
3. 设置固定密码并记录用户名
4. 生成包含 auth 字段的 Secret YAML 文件
5. 在 K8s 集群的 jenkins 命名空间应用 Secret
6. 验证 Secret 格式正确
7. 运行 Jenkins 流水线测试推送镜像
8. 检查阿里云控制台确认镜像已上传

完成这些步骤后，你的 Jenkinsfile-k8s 就可以正常推送镜像到阿里云个人版镜像仓库了！
