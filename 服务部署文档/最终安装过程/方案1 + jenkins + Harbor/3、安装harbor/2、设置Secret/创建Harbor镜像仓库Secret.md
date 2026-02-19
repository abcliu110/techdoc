# 创建 Harbor 镜像仓库 Kubernetes Secret

## 一、获取 Harbor 访问凭证

### 1. Harbor 默认管理员账号

- **用户名**：`admin`
- **密码**：在 Harbor 安装时设置的密码

### 2. 登录 Harbor Web UI 验证

访问 Harbor Web UI：
```
http://harbor-core.harbor  # 集群内访问
或
http://<NodeIP>:<NodePort>  # 集群外访问
```

使用 admin 账号登录，确认密码正确。

### 3. 创建项目（如果不存在）

在 Harbor Web UI 中：
1. 点击 "项目"
2. 点击 "新建项目"
3. 项目名称：`library`（或其他名称）
4. 访问级别：选择 "公开" 或 "私有"
5. 点击 "确定"

## 二、在 Kubernetes 中创建 Secret

### 方式 1：使用 kubectl 命令创建（推荐）

```bash
# 在 jenkins 命名空间创建 Secret
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=你的Harbor密码 \
  -n jenkins

# 如果 Harbor 使用 HTTPS 和自定义域名
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor.yourdomain.com \
  --docker-username=admin \
  --docker-password=你的Harbor密码 \
  -n jenkins
```

**参数说明**：
- `harbor-registry-secret`: Secret 的名称（与 Jenkinsfile 中引用的名称一致）
- `--docker-server`: Harbor 服务地址
  - 集群内：`harbor-core.harbor` 或 `harbor-core.harbor.svc.cluster.local`
  - 集群外：`harbor.yourdomain.com` 或 `<NodeIP>:<NodePort>`
- `--docker-username`: Harbor 用户名（默认 admin）
- `--docker-password`: Harbor 密码
- `-n jenkins`: 在 jenkins 命名空间创建

### 方式 2：使用 YAML 文件创建

#### 步骤 1: 生成 base64 编码的认证信息

```bash
# 1. 生成 auth 字段（base64 编码的 username:password）
echo -n 'admin:你的Harbor密码' | base64
# 示例：echo -n 'admin:Harbor12345' | base64
# 输出：YWRtaW46SGFyYm9yMTIzNDU=

# 2. 创建认证配置文件
cat > config.json <<EOF
{
  "auths": {
    "harbor-core.harbor": {
      "auth": "上面生成的base64字符串"
    }
  }
}
EOF

# 3. 生成 .dockerconfigjson 字段（base64 编码整个 config.json）
cat config.json | base64 -w 0
```

#### 步骤 2: 创建 Secret YAML 文件

创建 `harbor-registry-secret.yaml`：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: harbor-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <这里粘贴上面生成的 base64 字符串>
```

**完整示例**（使用实际值）：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: harbor-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  # 用户名: admin
  # 密码: Harbor12345
  # 服务器: harbor-core.harbor
  .dockerconfigjson: eyJhdXRocyI6eyJoYXJib3ItY29yZS5oYXJib3IiOnsiYXV0aCI6IllXUnRhVzQ2U0dGeVltOXlNVEl6TkRVPSJ9fX0=
```

#### 步骤 3: 应用 Secret

```bash
kubectl apply -f harbor-registry-secret.yaml
```

## 三、验证 Secret 是否创建成功

### 1. 查看 Secret

```bash
kubectl get secret harbor-registry-secret -n jenkins
```

输出示例：
```
NAME                      TYPE                             DATA   AGE
harbor-registry-secret    kubernetes.io/dockerconfigjson   1      10s
```

### 2. 查看 Secret 详细信息

```bash
kubectl describe secret harbor-registry-secret -n jenkins
```

### 3. 验证 Secret 内容格式

```bash
# 查看 Secret 内容
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

**正确的输出格式**：
```json
{"auths":{"harbor-core.harbor":{"auth":"YWRtaW46SGFyYm9yMTIzNDU="}}}
```

## 四、测试 Secret 是否有效

### 方式 1：运行 Jenkins 流水线测试

1. 在 Jenkins 中运行构建
2. 勾选 `BUILD_DOCKER_IMAGE` 和 `PUSH_TO_HARBOR`
3. 查看构建日志，确认镜像推送成功
4. 在 Harbor Web UI 查看镜像是否上传

### 方式 2：创建测试 Pod（可选）

创建 `test-pod.yaml`：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-harbor-pull
  namespace: jenkins
spec:
  imagePullSecrets:
  - name: harbor-registry-secret
  containers:
  - name: test
    image: harbor-core.harbor/library/demo-springboot:latest
    command: ["sleep", "3600"]
```

应用并查看：
```bash
kubectl apply -f test-pod.yaml
kubectl get pod test-harbor-pull -n jenkins
kubectl describe pod test-harbor-pull -n jenkins
```

如果 Pod 成功拉取镜像并运行，说明 Secret 配置正确。

清理测试 Pod：
```bash
kubectl delete pod test-harbor-pull -n jenkins
```

## 五、常见问题

### 1. Secret 创建失败

**错误**: `Error from server (AlreadyExists): secrets "harbor-registry-secret" already exists`

**解决**: 删除旧的 Secret 后重新创建
```bash
kubectl delete secret harbor-registry-secret -n jenkins
# 然后重新创建
```

### 2. 认证失败：UNAUTHORIZED

**错误**: `UNAUTHORIZED: unauthorized to access repository`

**可能原因**：
- 用户名或密码错误
- Harbor 项目不存在
- 用户没有推送权限

**解决**：
1. 在 Harbor Web UI 确认用户名和密码
2. 确认项目 `library` 存在
3. 确认用户有推送权限（admin 默认有所有权限）
4. 重新创建 Secret

### 3. 找不到 Secret

**错误**: Pod 启动失败，提示找不到 Secret

**解决**: 确认 Secret 和 Jenkins 在同一个命名空间
```bash
# 查看所有命名空间的 Secret
kubectl get secret --all-namespaces | grep harbor

# 如果在错误的命名空间，删除后在正确的命名空间重新创建
kubectl delete secret harbor-registry-secret -n default
kubectl apply -f harbor-registry-secret.yaml
```

### 4. Harbor 服务地址错误

**错误**: `dial tcp: lookup harbor-core.harbor: no such host`

**解决**: 确认 Harbor 服务地址
```bash
# 查看 Harbor 服务
kubectl get svc -n harbor

# 使用完整的服务名
# 格式：<service-name>.<namespace>.svc.cluster.local
# 示例：harbor-core.harbor.svc.cluster.local
```

### 5. HTTP vs HTTPS

**Harbor 使用 HTTP**：
- 在 Jenkinsfile 中添加 `--insecure-registry` 和 `--skip-tls-verify`
- 已在当前 Jenkinsfile 中配置

**Harbor 使用 HTTPS**：
- 移除 `--insecure-registry` 和 `--skip-tls-verify`
- 确保证书有效

## 六、Harbor 项目权限配置

### 1. 创建项目

在 Harbor Web UI：
1. 登录 Harbor
2. 点击 "项目"
3. 点击 "新建项目"
4. 项目名称：`library`
5. 访问级别：
   - **公开**：任何人都可以拉取镜像（推荐用于内部开发）
   - **私有**：需要认证才能拉取镜像
6. 点击 "确定"

### 2. 添加用户到项目

如果使用非 admin 用户：
1. 进入项目 `library`
2. 点击 "成员"
3. 点击 "添加成员"
4. 选择用户
5. 角色：选择 "项目管理员" 或 "开发者"（需要推送权限）
6. 点击 "确定"

## 七、更新 Secret

如果需要更新密码：

```bash
# 删除旧的 Secret
kubectl delete secret harbor-registry-secret -n jenkins

# 创建新的 Secret
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=新密码 \
  -n jenkins
```

## 八、安全建议

1. **不要在 Jenkinsfile 中硬编码密码**
2. **定期更换密码**
3. **使用专用账号而不是 admin**（推荐）
4. **限制用户权限**，只授予必要的推送权限
5. **定期审计 Secret 的使用情况**

## 九、完整流程总结

1. 登录 Harbor Web UI 确认密码
2. 在 Harbor 中创建项目 `library`
3. 在 K8s 的 jenkins 命名空间创建 Secret
4. 验证 Secret 创建成功
5. 运行 Jenkins 流水线测试推送镜像
6. 在 Harbor Web UI 确认镜像已上传

完成这些步骤后，你的 Jenkinsfile 就可以正常推送镜像到 Harbor 了！

## 十、快速命令（复制粘贴）

```bash
# 1. 创建 Harbor Secret（修改密码为实际值）
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

# 2. 验证 Secret
kubectl get secret harbor-registry-secret -n jenkins

# 3. 查看 Secret 内容
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d

# 4. 如果需要删除重建
kubectl delete secret harbor-registry-secret -n jenkins
```
