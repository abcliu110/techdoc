# Jenkins Kubernetes Plugin 配置指南

## 一、前置准备

### 1. 安装 Kubernetes Plugin

在 Jenkins 中：
1. 系统管理 → 插件管理
2. 搜索 "Kubernetes"
3. 安装 "Kubernetes plugin"
4. 重启 Jenkins

### 2. 创建必要的 Kubernetes 资源

#### 创建 Maven 缓存 PVC

```yaml
# maven-cache-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-maven-cache
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: local-path
  resources:
    requests:
      storage: 10Gi
```

```bash
kubectl apply -f maven-cache-pvc.yaml
```

#### 创建 Docker 配置 ConfigMap

```yaml
# docker-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-config
  namespace: jenkins
data:
  config.json: |
    {
      "auths": {
        "192.168.80.100:30500": {
          "auth": ""
        }
      },
      "insecure-registries": ["192.168.80.100:30500"]
    }
```

```bash
kubectl apply -f docker-config.yaml
```

## 二、配置 Kubernetes Cloud

### 1. 进入配置页面

Jenkins → 系统管理 → 节点管理 → Configure Clouds

### 2. 添加 Kubernetes Cloud

点击 "Add a new cloud" → 选择 "Kubernetes"

### 3. 配置 Kubernetes

#### 基本配置

```
名称: kubernetes
Kubernetes 地址: https://kubernetes.default.svc.cluster.local
Kubernetes 命名空间: jenkins
凭据: 留空（使用 ServiceAccount）
```

#### 测试连接

点击 "Test Connection"，应该看到：
```
Connection test successful
```

#### Pod 模板配置（可选）

如果需要默认模板，可以配置：

```
名称: jenkins-agent
命名空间: jenkins
标签: jenkins-agent
```

添加容器：
- 名称: jnlp
- Docker 镜像: jenkins/inbound-agent:latest
- 工作目录: /home/jenkins/agent

## 三、使用 Jenkinsfile-k8s

### 1. 创建流水线任务

1. 新建任务 → 流水线
2. 任务名称: `demo-springboot-k8s`
3. 流水线配置:
   - 定义: Pipeline script from SCM
   - SCM: Git
   - 仓库 URL: 你的 Git 仓库
   - 脚本路径: `Jenkinsfile-k8s`

### 2. 执行构建

点击 "Build with Parameters"，配置参数后开始构建。

### 3. 查看构建过程

构建时会自动：
1. 在 RKE2 集群中创建临时 Pod
2. Pod 包含 maven、kaniko、git 容器
3. 在不同容器中执行不同任务
4. 构建完成后自动删除 Pod

查看 Pod：
```bash
# 构建过程中查看
kubectl get pods -n jenkins

# 应该看到类似
NAME                                    READY   STATUS    RESTARTS   AGE
jenkins-xxx                             1/1     Running   0          10m
demo-springboot-k8s-123-abc-xyz         3/3     Running   0          30s
```

## 四、Kaniko 构建镜像

### 1. Kaniko 优势

- ✅ 无需 Docker daemon
- ✅ 在 Kubernetes 中原生运行
- ✅ 支持缓存
- ✅ 安全性高（无需 privileged）

### 2. Kaniko 配置

在 Jenkinsfile-k8s 中已配置：

```groovy
container('kaniko') {
    sh """
        /kaniko/executor \\
            --context=\${PWD} \\
            --dockerfile=Dockerfile \\
            --destination=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \\
            --destination=${DOCKER_IMAGE_NAME}:latest \\
            --insecure \\
            --skip-tls-verify \\
            --cache=true \\
            --cache-ttl=24h
    """
}
```

### 3. Kaniko 参数说明

- `--context`: 构建上下文目录
- `--dockerfile`: Dockerfile 路径
- `--destination`: 目标镜像（可以多个）
- `--insecure`: 允许 HTTP 仓库
- `--skip-tls-verify`: 跳过 TLS 验证
- `--cache`: 启用缓存
- `--cache-ttl`: 缓存有效期

## 五、配置私有仓库认证

### 方式 1：使用 ConfigMap（当前方式）

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-config
  namespace: jenkins
data:
  config.json: |
    {
      "auths": {
        "192.168.80.100:30500": {
          "auth": ""
        }
      }
    }
```

### 方式 2：使用 Secret（推荐用于有认证的仓库）

```bash
# 创建 Docker 认证 Secret
kubectl create secret docker-registry regcred \
  --docker-server=192.168.80.100:30500 \
  --docker-username=admin \
  --docker-password=password \
  --namespace=jenkins

# 在 Jenkinsfile 中使用
volumeMounts:
- name: kaniko-secret
  mountPath: /kaniko/.docker

volumes:
- name: kaniko-secret
  secret:
    secretName: regcred
    items:
    - key: .dockerconfigjson
      path: config.json
```

## 六、优化配置

### 1. 资源限制

在 Jenkinsfile-k8s 中已配置：

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 4Gi
```

### 2. Maven 缓存

使用 PVC 持久化 Maven 依赖：

```yaml
volumeMounts:
- name: maven-cache
  mountPath: /root/.m2

volumes:
- name: maven-cache
  persistentVolumeClaim:
    claimName: jenkins-maven-cache
```

### 3. Kaniko 缓存

启用 Kaniko 缓存加速构建：

```bash
--cache=true
--cache-ttl=24h
```

## 七、故障排查

### 1. Pod 无法创建

**错误：**
```
Error creating pod: pods is forbidden
```

**解决：**
```bash
# 检查 ServiceAccount 权限
kubectl get clusterrolebinding jenkins

# 如果不存在，创建
kubectl create clusterrolebinding jenkins \
  --clusterrole=cluster-admin \
  --serviceaccount=jenkins:jenkins
```

### 2. Kaniko 推送失败

**错误：**
```
UNAUTHORIZED: authentication required
```

**解决：**
- 检查 docker-config ConfigMap
- 确认私有仓库地址正确
- 使用 `--insecure` 和 `--skip-tls-verify`

### 3. Maven 依赖下载慢

**解决：**

配置 Maven 镜像：

```yaml
# maven-settings-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: maven-settings
  namespace: jenkins
data:
  settings.xml: |
    <settings>
      <mirrors>
        <mirror>
          <id>aliyun</id>
          <mirrorOf>central</mirrorOf>
          <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
      </mirrors>
    </settings>
```

在 Jenkinsfile 中挂载：

```yaml
volumeMounts:
- name: maven-settings
  mountPath: /root/.m2/settings.xml
  subPath: settings.xml

volumes:
- name: maven-settings
  configMap:
    name: maven-settings
```

### 4. 查看 Pod 日志

```bash
# 查看 Pod 列表
kubectl get pods -n jenkins

# 查看特定容器日志
kubectl logs -n jenkins <pod-name> -c maven
kubectl logs -n jenkins <pod-name> -c kaniko
kubectl logs -n jenkins <pod-name> -c git
```

## 八、完整部署流程

### 1. 创建资源

```bash
# 创建 Maven 缓存
kubectl apply -f maven-cache-pvc.yaml

# 创建 Docker 配置
kubectl apply -f docker-config.yaml

# 验证
kubectl get pvc -n jenkins
kubectl get cm -n jenkins
```

### 2. 配置 Jenkins

1. 安装 Kubernetes Plugin
2. 配置 Kubernetes Cloud
3. 测试连接

### 3. 创建流水线

1. 新建流水线任务
2. 使用 Jenkinsfile-k8s
3. 执行构建

### 4. 验证结果

```bash
# 查看镜像
curl http://192.168.80.100:30500/v2/_catalog

# 拉取镜像
docker pull 192.168.80.100:30500/demo-springboot:latest
```

## 九、对比 Docker 方式

| 特性 | Docker in Docker | Kubernetes Plugin + Kaniko |
|------|------------------|----------------------------|
| 需要 Docker daemon | ✅ 需要 | ❌ 不需要 |
| 需要 privileged | ✅ 需要 | ❌ 不需要 |
| 资源隔离 | ⚠️ 一般 | ✅ 好 |
| 动态扩展 | ❌ 不支持 | ✅ 支持 |
| 安全性 | ⚠️ 一般 | ✅ 高 |
| 配置复杂度 | ⚠️ 中等 | ⚠️ 中等 |
| 构建速度 | ✅ 快 | ✅ 快（有缓存） |

**推荐：** 在 Kubernetes 环境中使用 Kubernetes Plugin + Kaniko 方案。
