# Harbor 连接问题排查指南

## 问题描述

Kaniko 推送镜像到 Harbor 时出现以下错误：

```
error checking push permissions -- make sure you entered the correct tag name, and that you are authenticated correctly, and try again: checking push permission for "192.168.1.100:30002/library/demo-springboot:109": creating push check transport for 192.168.1.100:30002 failed: Get "https://192.168.1.100:30002/v2/": net/http: TLS handshake timeout; Get "http://192.168.1.100:30002/v2/": EOF
```

## 原因分析

1. **TLS handshake timeout**：Kaniko 默认尝试 HTTPS 连接，但 Harbor 可能使用 HTTP
2. **EOF 错误**：HTTP 连接失败，可能是网络不通或认证问题

## 解决方案

### 方案 1：配置 Kaniko 支持 HTTP Harbor（已实施）

Jenkinsfile 已添加以下参数：

```groovy
--insecure-registry=${HARBOR_REGISTRY}  // 标记 Harbor 为 insecure registry
--skip-tls-verify                        // 跳过 TLS 验证
```

### 方案 2：验证 Harbor 可访问性

#### 1. 测试 Harbor HTTP 连接

```bash
# 从 Jenkins 所在节点测试
curl -v http://192.168.1.100:30002/v2/

# 预期输出（表示 Harbor 可访问）：
# HTTP/1.1 401 Unauthorized
# {"errors":[{"code":"UNAUTHORIZED","message":"authentication required"}]}
```

#### 2. 测试带认证的连接

```bash
# 使用 Harbor 用户名密码测试
curl -u admin:Harbor12345 http://192.168.1.100:30002/v2/_catalog

# 预期输出（显示仓库列表）：
# {"repositories":["library/demo-springboot"]}
```

#### 3. 检查 Harbor 服务状态

```bash
# 检查 Harbor 服务
kubectl get svc -n harbor harbor-core

# 检查 Harbor Pod 状态
kubectl get pods -n harbor

# 所有 Pod 应该是 Running 状态
```

### 方案 3：检查 Harbor Registry Secret

#### 1. 验证 Secret 存在

```bash
kubectl get secret harbor-registry-secret -n default
```

#### 2. 查看 Secret 内容

```bash
kubectl get secret harbor-registry-secret -n default -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

预期输出：

```json
{
  "auths": {
    "192.168.1.100:30002": {
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

#### 3. 重新创建 Secret（如果有问题）

```bash
# 删除旧的 Secret
kubectl delete secret harbor-registry-secret -n default

# 创建新的 Secret
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default

# 验证
kubectl get secret harbor-registry-secret -n default
```

### 方案 4：检查 Harbor 项目配置

#### 1. 登录 Harbor Web UI

访问：http://192.168.1.100:30002

默认账号：
- 用户名：admin
- 密码：Harbor12345

#### 2. 验证项目存在

- 进入"项目"页面
- 确认 `library` 项目存在
- 检查项目访问级别（公开/私有）

#### 3. 验证用户权限

- 进入 `library` 项目
- 点击"成员"标签
- 确认 `admin` 用户有"项目管理员"或"开发者"权限

#### 4. 创建项目（如果不存在）

```bash
# 使用 Harbor API 创建项目
curl -X POST "http://192.168.1.100:30002/api/v2.0/projects" \
  -H "Content-Type: application/json" \
  -u admin:Harbor12345 \
  -d '{
    "project_name": "library",
    "public": true
  }'
```

### 方案 5：网络连接测试

#### 1. 从 Jenkins Pod 测试连接

```bash
# 获取 Jenkins Pod 名称
kubectl get pods -n default | grep jenkins

# 进入 Jenkins Pod
kubectl exec -it <jenkins-pod-name> -n default -- bash

# 测试 Harbor 连接
curl -v http://192.168.1.100:30002/v2/

# 测试 DNS 解析（如果使用域名）
nslookup harbor.example.com

# 测试端口连通性
telnet 192.168.1.100 30002
```

#### 2. 检查防火墙规则

```bash
# 在 Harbor 所在节点检查防火墙
sudo iptables -L -n | grep 30002

# 或者检查 firewalld
sudo firewall-cmd --list-ports
```

### 方案 6：Harbor 使用 HTTPS（自签名证书）

如果 Harbor 配置了 HTTPS 但使用自签名证书：

#### 1. 配置 RKE2 节点信任证书

在每个 RKE2 节点上：

```bash
# 创建 registries.yaml
sudo mkdir -p /etc/rancher/rke2
sudo tee /etc/rancher/rke2/registries.yaml <<EOF
mirrors:
  "192.168.1.100:30002":
    endpoint:
      - "http://192.168.1.100:30002"

configs:
  "192.168.1.100:30002":
    tls:
      insecure_skip_verify: true
EOF

# 重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent
```

#### 2. 或者导入 Harbor 证书

```bash
# 从 Harbor 获取证书
openssl s_client -showcerts -connect 192.168.1.100:30002 </dev/null 2>/dev/null | \
  openssl x509 -outform PEM > harbor-ca.crt

# 在每个节点上安装证书
sudo cp harbor-ca.crt /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust

# 重启 RKE2
sudo systemctl restart rke2-server
```

### 方案 7：检查 Kaniko Pod 日志

```bash
# 查看 Jenkins 构建日志中的 Kaniko 详细输出
# 在 Jenkins 构建页面查看完整日志

# 或者如果 Kaniko Pod 还在运行
kubectl get pods -n default | grep kaniko
kubectl logs <kaniko-pod-name> -n default
```

## 验证修复

### 1. 重新触发 Jenkins 构建

在 Jenkins 中：
1. 选择项目
2. 点击"Build with Parameters"
3. 设置参数：
   - `PUSH_TO_HARBOR` = true
   - `PUSH_TO_ALIYUN` = false（先只测试 Harbor）
4. 点击"构建"

### 2. 查看构建日志

预期看到：

```
>>> 添加 Harbor 推送目标
  - 配置 Harbor 为 insecure registry (HTTP)
>>> 开始构建和推送镜像...

[Kaniko 构建输出...]

✓ 镜像已推送到 Harbor: 192.168.1.100:30002/library/demo-springboot:110
```

### 3. 验证镜像已推送

```bash
# 方法 1：使用 Harbor Web UI
# 访问 http://192.168.1.100:30002
# 进入 library 项目，查看 demo-springboot 仓库

# 方法 2：使用 Harbor API
curl -u admin:Harbor12345 \
  http://192.168.1.100:30002/api/v2.0/projects/library/repositories/demo-springboot/artifacts

# 方法 3：使用 Docker CLI
docker login 192.168.1.100:30002
docker pull 192.168.1.100:30002/library/demo-springboot:110
```

## 常见错误和解决方法

### 错误 1：unauthorized: authentication required

**原因**：harbor-registry-secret 不存在或配置错误

**解决**：
```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

### 错误 2：denied: requested access to the resource is denied

**原因**：用户没有项目权限

**解决**：
1. 登录 Harbor Web UI
2. 进入 library 项目
3. 添加用户权限或将项目设为公开

### 错误 3：project library not found

**原因**：Harbor 项目不存在

**解决**：
```bash
curl -X POST "http://192.168.1.100:30002/api/v2.0/projects" \
  -H "Content-Type: application/json" \
  -u admin:Harbor12345 \
  -d '{"project_name": "library", "public": true}'
```

### 错误 4：connection refused

**原因**：Harbor 服务未运行或端口不通

**解决**：
```bash
# 检查 Harbor Pod
kubectl get pods -n harbor

# 检查 Harbor 服务
kubectl get svc -n harbor harbor-core

# 重启 Harbor（如果需要）
kubectl rollout restart deployment -n harbor
```

### 错误 5：x509: certificate signed by unknown authority

**原因**：Harbor 使用自签名 HTTPS 证书

**解决**：
- 使用方案 6 配置 insecure registry
- 或者导入 Harbor CA 证书

## 最佳实践

### 1. 开发环境

- 使用 HTTP Harbor（简单快速）
- 配置 `--insecure-registry` 和 `--skip-tls-verify`

### 2. 生产环境

- 使用 HTTPS Harbor（安全）
- 使用受信任的 CA 证书
- 不使用 `--skip-tls-verify`

### 3. 混合环境

- Harbor（HTTP）用于内网快速推送
- 阿里云（HTTPS）用于云端备份
- 使用 Jenkinsfile 参数灵活控制

## 相关文档

- [Harbor-Helm完整部署指南.md](../Harbor-Helm完整部署指南.md)
- [创建Harbor镜像仓库Secret.md](./创建Harbor镜像仓库Secret.md)
- [Jenkinsfile双推送功能说明.md](./Jenkinsfile双推送功能说明.md)
- [Harbor 官方文档](https://goharbor.io/docs/)
- [Kaniko 官方文档](https://github.com/GoogleContainerTools/kaniko)
