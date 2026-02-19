# Harbor Helm 部署完整指南

## 环境要求

- Kubernetes 集群（RKE2）
- kubectl 已配置
- 节点 IP: 192.168.80.100（根据实际修改）
- StorageClass: local-path

---

## 一、安装 Helm

```bash
# 下载并安装 Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 验证安装
helm version
```

---

## 二、准备工作

### 1. 检查 StorageClass

```bash
# 查看可用的 StorageClass
kubectl get storageclass

# 应该看到 local-path
# NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
# local-path   rancher.io/local-path   Delete          WaitForFirstConsumer
```

### 2. 删除之前的部署（如果有）

```bash
# 卸载 Helm Release（如果存在）
helm uninstall harbor -n harbor 2>/dev/null || true

# 删除旧的 PVC（重要！）
kubectl delete pvc -n harbor --all 2>/dev/null || true

# 删除命名空间
kubectl delete namespace harbor 2>/dev/null || true
kubectl delete namespace nexus 2>/dev/null || true

# 等待清理完成
sleep 10

# 验证清理
kubectl get namespace harbor 2>/dev/null && echo "⚠️ Harbor 命名空间还存在" || echo "✓ Harbor 已清理"
kubectl get pvc -n harbor 2>/dev/null && echo "⚠️ PVC 还存在" || echo "✓ PVC 已清理"
```

### 3. 添加 Harbor Helm 仓库

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```

---

## 三、创建配置文件

### 方法1: 使用 cat 命令创建

```bash
cat > harbor-helm-values.yaml <<'EOF'
# Harbor Helm Chart 配置文件
# 适用于 RKE2 Kubernetes 集群

# 暴露方式：NodePort
expose:
  type: nodePort
  tls:
    enabled: false  # 不使用 HTTPS
  nodePort:
    name: harbor
    ports:
      http:
        nodePort: 30002  # Web UI 和 Registry 端口

# 外部访问地址（修改为你的节点 IP）
externalURL: http://192.168.80.101:30002

# 持久化存储
persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "local-path"
      size: 200Gi
    database:
      storageClass: "local-path"
      size: 10Gi
    redis:
      storageClass: "local-path"
      size: 5Gi
    jobservice:
      jobLog:
        storageClass: "local-path"
        size: 1Gi
      scanDataExports:
        storageClass: "local-path"
        size: 1Gi

# Harbor 管理员密码
harborAdminPassword: "Harbor12345"

# 数据库配置
database:
  type: internal  # 使用内置 PostgreSQL
  internal:
    password: "changeit"

# Redis 配置
redis:
  type: internal  # 使用内置 Redis

# 禁用不需要的组件
trivy:
  enabled: false  # 漏洞扫描（可选）
notary:
  enabled: false  # 镜像签名（可选）
chartmuseum:
  enabled: false  # Helm Chart 仓库（可选）

# 资源限制
portal:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

core:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi

jobservice:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

registry:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
EOF
```

### 方法2: 修改 IP 地址

```bash
# 使用 sed 替换 IP（将 YOUR_NODE_IP 替换为实际 IP）
sed -i 's/192.168.80.100/YOUR_NODE_IP/g' harbor-helm-values.yaml

# 或者手动编辑
vim harbor-helm-values.yaml
# 修改第 14 行: externalURL: http://YOUR_NODE_IP:30002
```

### 验证配置文件

```bash
cat harbor-helm-values.yaml
```

---

## 四、部署 Harbor

### 重要提示

**如果之前部署过 Harbor，必须先删除旧的 PVC：**

```bash
# 删除旧的 PVC（避免 "spec is immutable" 错误）
kubectl delete pvc harbor-jobservice harbor-registry harbor-database harbor-redis -n harbor 2>/dev/null || true

# 验证 PVC 已删除
kubectl get pvc -n harbor
# 应该显示: No resources found in harbor namespace.
```

### 部署命令

```bash
# 一键部署
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-helm-values.yaml \
  --version 1.14.0
```
  --create-namespace \
  -f harbor-helm-values.yaml \
  --version 1.14.0
```

**预期输出：**
```
NAME: harbor
LAST DEPLOYED: ...
NAMESPACE: harbor
STATUS: deployed
REVISION: 1
```

---

## 五、查看部署状态

### 1. 查看 Pod 状态（等待 3-5 分钟）

```bash
kubectl get pods -n harbor -w
```

**预期输出（所有 Pod 都是 Running）：**
```
NAME                                    READY   STATUS    RESTARTS   AGE
harbor-core-xxx                         1/1     Running   0          3m
harbor-database-0                       1/1     Running   0          3m
harbor-jobservice-xxx                   1/1     Running   0          3m
harbor-nginx-xxx                        1/1     Running   0          3m
harbor-portal-xxx                       1/1     Running   0          3m
harbor-redis-0                          1/1     Running   0          3m
harbor-registry-xxx                     1/1     Running   0          3m
```

### 2. 查看所有资源

```bash
kubectl get all -n harbor
```

### 3. 查看 PVC 状态

```bash
kubectl get pvc -n harbor
```

### 4. 查看服务

```bash
kubectl get svc -n harbor
```

---

## 六、访问 Harbor

### 1. 访问 Web UI

打开浏览器访问：`http://<节点IP>:30002`

- **用户名**: `admin`
- **密码**: `Harbor12345`

### 2. 首次登录

1. 输入用户名和密码登录
2. 建议修改默认密码
3. 创建项目（如：nms4cloud）

---

## 七、配置 Docker 使用 Harbor

### 1. 配置 Docker daemon

```bash
# 编辑 Docker 配置
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["<节点IP>:30002"]
}
EOF

# 重启 Docker
sudo systemctl restart docker
```

### 2. 登录 Harbor

```bash
docker login <节点IP>:30002
# 用户名: admin
# 密码: Harbor12345
```

### 3. 测试推送镜像

```bash
# 标记镜像
docker tag nginx:latest <节点IP>:30002/nms4cloud/nginx:latest

# 推送镜像
docker push <节点IP>:30002/nms4cloud/nginx:latest
```

---

## 八、配置 Jenkins/Kaniko 使用 Harbor

### 1. 创建 Harbor Registry Secret

Jenkins 使用 Kaniko 构建镜像时需要 Harbor 认证 Secret：

```bash
# 创建 harbor-registry-secret

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default

# 验证 Secret 创建成功
kubectl get secret harbor-registry-secret -n default

# 查看 Secret 内容
kubectl get secret harbor-registry-secret -n default -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

**预期输出：**
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

### 2. 在 Harbor 中创建项目

登录 Harbor Web UI (http://192.168.1.100:30002)：

1. 使用 admin / Harbor12345 登录
2. 点击"项目" → "新建项目"
3. 项目名称：`library`（或其他名称）
4. 访问级别：公开或私有
5. 点击"确定"

### 3. 配置 Jenkinsfile

在 Jenkinsfile 中配置 Harbor 地址：

```groovy
// Harbor 本地镜像仓库配置
HARBOR_REGISTRY = '192.168.1.100:30002'
HARBOR_PROJECT = 'library'
HARBOR_REPOSITORY_NAME = 'demo-springboot'
HARBOR_IMAGE_NAME = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPOSITORY_NAME}"
```

### 4. Kaniko 推送到 Harbor（HTTP）

由于 Harbor 使用 HTTP（非 HTTPS），Kaniko 需要配置 insecure registry：

```groovy
// 在 Kaniko executor 命令中添加
--insecure-registry=${HARBOR_REGISTRY}
--skip-tls-verify
```

**完整示例：**
```bash
/kaniko/executor \
  --context=${WORKSPACE} \
  --dockerfile=${WORKSPACE}/Dockerfile \
  --destination=192.168.1.100:30002/library/demo-springboot:latest \
  --insecure-registry=192.168.1.100:30002 \
  --skip-tls-verify \
  --compressed-caching=true \
  --compression=gzip \
  --compression-level=9
```

### 5. 验证镜像推送

```bash
# 方法 1：使用 Harbor Web UI
# 访问 http://192.168.1.100:30002
# 进入 library 项目，查看仓库列表

# 方法 2：使用 Harbor API
curl -u admin:Harbor12345 \
  http://192.168.1.100:30002/api/v2.0/projects/library/repositories

# 方法 3：使用 Docker CLI
docker login 192.168.1.100:30002
docker pull 192.168.1.100:30002/library/demo-springboot:latest
```

### 6. 常见问题排查

#### 问题 1：TLS handshake timeout

**错误信息：**
```
Get "https://192.168.1.100:30002/v2/": net/http: TLS handshake timeout
```

**原因：** Kaniko 尝试使用 HTTPS 连接 HTTP Harbor

**解决：** 添加 `--insecure-registry` 和 `--skip-tls-verify` 参数

#### 问题 2：unauthorized: authentication required

**错误信息：**
```
unauthorized: authentication required
```

**原因：** harbor-registry-secret 不存在或配置错误

**解决：**
```bash
# 重新创建 Secret
kubectl delete secret harbor-registry-secret -n default
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

#### 问题 3：project library not found

**错误信息：**
```
project library not found
```

**原因：** Harbor 项目不存在

**解决：**
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

### 7. 测试完整流程

```bash
# 1. 确认 Harbor 可访问
curl -v http://192.168.1.100:30002/v2/

# 2. 确认 Secret 存在
kubectl get secret harbor-registry-secret -n default

# 3. 确认项目存在
curl -u admin:Harbor12345 \
  http://192.168.1.100:30002/api/v2.0/projects/library

# 4. 在 Jenkins 中触发构建
# 选择 PUSH_TO_HARBOR = true

# 5. 验证镜像已推送
curl -u admin:Harbor12345 \
  http://192.168.1.100:30002/api/v2.0/projects/library/repositories/demo-springboot/artifacts
```

### 8. 相关文档

- [创建Harbor镜像仓库Secret.md](./demo-springboot/创建Harbor镜像仓库Secret.md) - 详细的 Secret 创建指南
- [Harbor连接问题排查.md](./demo-springboot/Harbor连接问题排查.md) - 完整的故障排查指南
- [Jenkinsfile双推送功能说明.md](./demo-springboot/Jenkinsfile双推送功能说明.md) - Jenkins 双推送功能文档

---

## 九、配置 RKE2 使用 Harbor

在每个 RKE2 节点上执行：

```bash
# 创建 registries.yaml
sudo mkdir -p /etc/rancher/rke2
sudo tee /etc/rancher/rke2/registries.yaml > /dev/null <<EOF
mirrors:
  "<节点IP>:30002":
    endpoint:
      - "http://<节点IP>:30002"
configs:
  "<节点IP>:30002":
    auth:
      username: admin
      password: Harbor12345
    tls:
      insecure_skip_verify: true
EOF

# 重启 RKE2
sudo systemctl restart rke2-server  # 或 rke2-agent

# 验证配置
sudo crictl info | grep -A 10 registry
```

---

## 十、配置镜像复制到阿里云

### 1. 在 Harbor Web UI 中配置

1. 登录 Harbor → Administration → Registries
2. 点击 "NEW ENDPOINT"
3. 配置：
   ```
   Provider: Alibaba Cloud CR
   Name: aliyun-acr
   Endpoint URL: https://crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com
   Access ID: <阿里云用户名>
   Access Secret: <阿里云密码>
   ```
4. 点击 "TEST CONNECTION" 测试
5. 点击 "OK" 保存

### 2. 创建复制规则

1. Administration → Replications
2. 点击 "NEW REPLICATION RULE"
3. 配置：
   ```
   Name: sync-to-aliyun
   Replication mode: Push-based
   Source resource filter:
     - Name: nms4cloud-*
     - Tag: prod-*, v*
   Destination registry: aliyun-acr
   Destination namespace: lgy-images
   Trigger Mode:
     - Manual (手动触发)
     - Scheduled (定时，如每天凌晨2点)
     - Event Based (推送时自动触发)
   ```
4. 点击 "SAVE"

### 3. 手动触发同步

1. Replications → 选择规则
2. 点击 "REPLICATE"
3. 查看同步进度

---

## 十一、常用管理命令

### Helm 命令

```bash
# 查看 Harbor 状态
helm status harbor -n harbor

# 查看 Harbor 配置
helm get values harbor -n harbor

# 导出当前配置
helm get values harbor -n harbor > current-values.yaml

# 升级 Harbor
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values.yaml

# 回滚 Harbor
helm rollback harbor -n harbor

# 卸载 Harbor
helm uninstall harbor -n harbor
```

### Kubernetes 命令

```bash
# 查看 Pod 日志
kubectl logs -n harbor -l app=harbor-core --tail=50
kubectl logs -n harbor -l app=harbor-registry --tail=50

# 查看 Pod 详情
kubectl describe pod -n harbor <pod-name>

# 查看事件
kubectl get events -n harbor --sort-by='.lastTimestamp'

# 重启 Pod
kubectl rollout restart deployment/harbor-core -n harbor
kubectl rollout restart deployment/harbor-registry -n harbor

# 查看资源使用
kubectl top pods -n harbor
```

---

## 十二、故障排查

### 1. Pod 无法启动

```bash
# 查看 Pod 状态
kubectl get pods -n harbor

# 查看 Pod 详情
kubectl describe pod -n harbor <pod-name>

# 查看日志
kubectl logs -n harbor <pod-name> --tail=100
```

### 2. 无法访问 Web UI

**检查项：**
- [ ] 所有 Pod 是否 Running
- [ ] NodePort 30002 是否被占用
- [ ] 防火墙是否开放 30002 端口
- [ ] externalURL 配置是否正确

```bash
# 检查服务
kubectl get svc -n harbor

# 检查端口
netstat -tlnp | grep 30002
```

### 3. 镜像推送失败

**检查项：**
- [ ] Docker daemon.json 配置是否正确
- [ ] 是否已登录 Harbor
- [ ] 项目是否已创建
- [ ] Registry Pod 是否正常

```bash
# 检查 Docker 配置
cat /etc/docker/daemon.json

# 重新登录
docker logout <节点IP>:30002
docker login <节点IP>:30002

# 检查 Registry Pod
kubectl logs -n harbor -l app=harbor-registry
```

### 4. PVC 无法绑定（Unbound PersistentVolumeClaims）

**错误信息：**
```
pod has unbound immediate PersistentVolumeClaims
```

**原因：**
- StorageClass 不存在或名称错误
- local-path provisioner 未运行

**解决方法：**

```bash
# 1. 检查 StorageClass
kubectl get storageclass

# 2. 如果 StorageClass 名称不是 local-path，修改配置文件
# 假设实际名称是 local-storage
sed -i 's/local-path/local-storage/g' harbor-helm-values.yaml

# 3. 重新部署
helm uninstall harbor -n harbor
kubectl delete pvc -n harbor --all
helm install harbor harbor/harbor -n harbor -f harbor-helm-values.yaml --version 1.14.0
```

### 5. PVC Spec 不可变错误

**错误信息：**
```
PersistentVolumeClaim "harbor-registry" is invalid: spec: Forbidden: spec is immutable after creation
```

**原因：**
- 旧的 PVC 还存在，但 StorageClass 名称不匹配
- Helm 尝试修改已存在的 PVC

**解决方法：**

```bash
# 1. 删除所有旧的 PVC
kubectl delete pvc -n harbor --all

# 2. 确保配置文件使用正确的 StorageClass
grep storageClass harbor-helm-values.yaml
# 应该显示: storageClass: "local-path"

# 3. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values.yaml --version 1.14.0
```

### 6. 端口已被占用

**错误信息：**
```
spec.ports[0].nodePort: Invalid value: 30002: provided port is already allocated
```

**解决方法：**

```bash
# 1. 查看哪个服务占用了端口
kubectl get svc --all-namespaces | grep 30002

# 2. 删除占用端口的服务（如 Nexus）
kubectl delete namespace nexus

# 3. 或者修改 Harbor 使用其他端口
sed -i 's/nodePort: 30002/nodePort: 30003/g' harbor-helm-values.yaml
sed -i 's/:30002/:30003/g' harbor-helm-values.yaml

# 4. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values.yaml --version 1.14.0
```

### 7. Helm Release 名称已存在

**错误信息：**
```
cannot re-use a name that is still in use
```

**解决方法：**

```bash
# 1. 卸载已存在的 Release
helm uninstall harbor -n harbor

# 2. 等待清理完成
sleep 10

# 3. 重新部署
helm install harbor harbor/harbor -n harbor -f harbor-helm-values.yaml --version 1.14.0
```

### 4. 镜像复制失败

**检查项：**
- [ ] 目标仓库凭证是否正确
- [ ] 网络是否可达
- [ ] 复制规则是否正确

```bash
# 查看复制任务日志
# 在 Harbor Web UI → Replications → 点击任务 → 查看日志
```

---

## 十三、备份和恢复

### 备份

```bash
# 1. 备份 Helm 配置
helm get values harbor -n harbor > harbor-backup-values.yaml

# 2. 备份 PVC 数据（使用存储系统快照）
kubectl get pvc -n harbor

# 3. 备份 Harbor 数据库
kubectl exec -n harbor harbor-database-0 -- \
  pg_dumpall -U postgres > harbor-db-backup.sql
```

### 恢复

```bash
# 使用备份的配置重新部署
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-backup-values.yaml \
  --version 1.14.0
```

---

## 十四、升级 Harbor

```bash
# 1. 备份当前配置
helm get values harbor -n harbor > harbor-backup-values.yaml

# 2. 更新 Helm 仓库
helm repo update

# 3. 查看可用版本
helm search repo harbor/harbor --versions

# 4. 升级到新版本
helm upgrade harbor harbor/harbor \
  -n harbor \
  -f harbor-helm-values.yaml \
  --version 1.15.0

# 5. 查看升级状态
kubectl get pods -n harbor -w
```

---

## 十五、卸载 Harbor

```bash
# 1. 卸载 Helm Release
helm uninstall harbor -n harbor

# 2. 删除 PVC（可选，会删除所有数据）
kubectl delete pvc -n harbor --all

# 3. 删除命名空间
kubectl delete namespace harbor
```

---

## 十六、性能优化建议

### 1. 增加资源限制

编辑 `harbor-helm-values.yaml`，增加资源：

```yaml
core:
  resources:
    requests:
      cpu: 1000m
      memory: 1Gi
    limits:
      cpu: 2000m
      memory: 2Gi

registry:
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

然后升级：
```bash
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values.yaml
```

### 2. 启用镜像缓存

```yaml
redis:
  type: internal
  internal:
    resources:
      requests:
        memory: 512Mi
      limits:
        memory: 1Gi
```

### 3. 增加存储空间

```bash
# 如果 StorageClass 支持扩容
kubectl patch pvc harbor-registry -n harbor \
  -p '{"spec":{"resources":{"requests":{"storage":"500Gi"}}}}'
```

---

## 十七、常见问题（FAQ）

### Q1: Helm 安装失败？
**A**: 检查 Helm 版本，需要 v3.x：
```bash
helm version
```

### Q2: Pod 一直 Pending？
**A**: 检查 PVC 是否绑定：
```bash
kubectl get pvc -n harbor
kubectl describe pvc -n harbor
```

如果 PVC 状态是 Pending，检查 StorageClass：
```bash
kubectl get storageclass
# 确保 local-path 存在
```

### Q3: 忘记管理员密码？
**A**: 通过 Helm 重新设置：
```bash
# 修改配置文件中的密码
vim harbor-helm-values.yaml
# 修改: harborAdminPassword: "NewPassword123"

# 升级 Harbor
helm upgrade harbor harbor/harbor -n harbor -f harbor-helm-values.yaml
```

### Q4: 镜像推送速度慢？
**A**:
- 检查网络带宽
- 增加 Registry 资源
- 使用 SSD 存储

### Q5: 如何完全卸载 Harbor？
**A**:
```bash
# 1. 卸载 Helm Release
helm uninstall harbor -n harbor

# 2. 删除 PVC（会删除所有数据）
kubectl delete pvc -n harbor --all

# 3. 删除命名空间
kubectl delete namespace harbor
```

### Q6: 部署时提示 PVC spec 不可变？
**A**: 删除旧的 PVC：
```bash
kubectl delete pvc -n harbor --all
helm install harbor harbor/harbor -n harbor -f harbor-helm-values.yaml --version 1.14.0
```

### Q7: 端口 30002 被占用？
**A**: 删除占用端口的服务或修改 Harbor 端口：
```bash
# 查看占用情况
kubectl get svc --all-namespaces | grep 30002

# 删除 Nexus（如果是 Nexus 占用）
kubectl delete namespace nexus

# 或修改 Harbor 端口为 30003
sed -i 's/30002/30003/g' harbor-helm-values.yaml
```

---

## 附录：完整部署脚本

```bash
#!/bin/bash
# Harbor 一键部署脚本

set -e

NODE_IP="192.168.80.100"  # 修改为你的节点 IP

echo "=== Harbor 部署脚本 ==="

# 1. 安装 Helm
if ! command -v helm &> /dev/null; then
    echo ">>> 安装 Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 2. 添加 Harbor 仓库
echo ">>> 添加 Harbor Helm 仓库..."
helm repo add harbor https://helm.goharbor.io
helm repo update

# 3. 创建配置文件
echo ">>> 创建配置文件..."
cat > harbor-helm-values.yaml <<EOF
expose:
  type: nodePort
  tls:
    enabled: false
  nodePort:
    ports:
      http:
        nodePort: 30002

externalURL: http://${NODE_IP}:30002

persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "local-path"
      size: 200Gi
    database:
      storageClass: "local-path"
      size: 10Gi
    redis:
      storageClass: "local-path"
      size: 5Gi

harborAdminPassword: "Harbor12345"

database:
  type: internal
  internal:
    password: "changeit"

redis:
  type: internal

trivy:
  enabled: false
notary:
  enabled: false
chartmuseum:
  enabled: false
EOF

# 4. 部署 Harbor
echo ">>> 部署 Harbor..."
helm install harbor harbor/harbor \
  -n harbor \
  --create-namespace \
  -f harbor-helm-values.yaml \
  --version 1.14.0

# 5. 等待 Pod 就绪
echo ">>> 等待 Pod 就绪..."
kubectl wait --for=condition=ready pod \
  -l app=harbor \
  -n harbor \
  --timeout=600s || true

# 6. 显示访问信息
echo ""
echo "=== Harbor 部署完成 ==="
echo "访问地址: http://${NODE_IP}:30002"
echo "用户名: admin"
echo "密码: Harbor12345"
echo ""
echo "查看状态: kubectl get pods -n harbor"
```

保存为 `deploy-harbor.sh`，然后执行：
```bash
chmod +x deploy-harbor.sh
./deploy-harbor.sh
```

---

**部署完成后，Harbor 就可以使用了！**
