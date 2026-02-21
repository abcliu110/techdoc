# Jenkins 安装 Kubernetes 插件指南

## 一、安装方式

### 方法一：通过 Web 界面安装（推荐新手）

1. **进入插件管理页面**
   ```
   Jenkins 首页 → 系统管理（Manage Jenkins） → 插件管理（Manage Plugins）
   ```

2. **搜索并安装**
   - 点击 "可选插件"（Available plugins）标签
   - 搜索框输入 `Kubernetes`
   - 勾选 `Kubernetes` 插件
   - 点击底部 "Install without restart" 或 "Download now and install after restart"

3. **等待安装完成**
   - 建议勾选 "安装完成后重启 Jenkins"
   - 或手动重启：
     ```bash
     kubectl rollout restart deployment/jenkins -n jenkins
     ```

---

### 方法二：通过 Dockerfile 预装（推荐生产环境）

在构建 Jenkins 镜像时预装插件：

```dockerfile
FROM jenkins/jenkins:lts

USER root

# 安装 kubectl（可选，用于调试）
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

USER jenkins

# 预装插件
RUN jenkins-plugin-cli --plugins \
    kubernetes:4253.v7700d91739e5 \
    workflow-aggregator:596.v8c21c963d92d \
    git:5.2.2 \
    configuration-as-code:1810.v9b_c30a_249a_4c
```

**构建并推送镜像：**

```bash
docker build -t your-registry/jenkins:latest .
docker push your-registry/jenkins:latest
```

---

### 方法三：通过 Jenkins Configuration as Code（JCasC）

**1. 创建 `plugins.txt`：**

```txt
kubernetes:latest
workflow-aggregator:latest
git:latest
credentials:latest
configuration-as-code:latest
```

**2. 在 Dockerfile 中引用：**

```dockerfile
FROM jenkins/jenkins:lts

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
```

---

## 二、验证安装

### Web 界面验证

```
系统管理 → 系统配置 → 滚动到底部
应该能看到 "Cloud" 配置区域，可以添加 Kubernetes Cloud
```

### 命令行验证

```bash
# 进入 Jenkins Pod
kubectl exec -it <jenkins-pod> -n jenkins -- /bin/bash

# 查看已安装的插件
jenkins-plugin-cli --list | grep kubernetes
```

---

## 三、配置 Kubernetes Cloud

### 1. 进入配置页面

```
系统管理 → 节点管理 → Configure Clouds → Add a new cloud → Kubernetes
```

### 2. 基本配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Name | `kubernetes` | Cloud 名称 |
| Kubernetes URL | `https://kubernetes.default.svc.cluster.local` | Pod 内部访问 K8s API |
| Kubernetes Namespace | `jenkins` | Agent Pod 运行的命名空间 |
| Credentials | 留空或选择 SA 凭据 | 使用 Pod 的 ServiceAccount |
| Jenkins URL | `http://jenkins.jenkins.svc.cluster.local:8080` | Agent 回连地址 |
| WebSocket | 勾选（推荐） | 见下方说明 |
| Jenkins tunnel | 留空（使用 WebSocket 时不需要） | 见下方说明 |

### 3. WebSocket 与 Jenkins 通道的区别

**推荐使用 WebSocket 模式：**

| 模式 | 端口 | 说明 |
|------|------|------|
| WebSocket（推荐）✅ | 8080 | 走标准 HTTP 协议，K8s 内部网络稳定，配置简单 |
| Jenkins 通道（TCP） | 50000 | 需要额外暴露 50000 端口，配置复杂 |

**使用 TCP 通道模式的前提条件：**

1. Jenkins 开启 TCP Agent 监听：
   ```
   系统管理 → 全局安全配置 → Agent → TCP port for inbound agents → 固定 → 50000
   ```

2. Jenkins Service 必须暴露 50000 端口：
   ```yaml
   ports:
   - name: http
     port: 8080
     targetPort: 8080
   - name: agent
     port: 50000
     targetPort: 50000
   ```

3. Jenkins 通道填写格式（不能带 http://）：
   ```
   jenkins.jenkins.svc.cluster.local:50000
   ```

### 4. 测试连接

点击 "Test Connection"，应该显示：
```
Connected to Kubernetes v1.x.x
```

---

## 四、配置 RBAC 权限

Jenkins 需要权限在 K8s 中创建和管理 Pod。

### 创建 ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
```

### 创建 Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins
  namespace: jenkins
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
```

### 创建 RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins
  namespace: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

### 应用配置

```bash
kubectl apply -f jenkins-rbac.yaml
```

### 更新 Jenkins Deployment 使用 ServiceAccount

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  template:
    spec:
      serviceAccountName: jenkins  # 添加这一行
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        # ... 其他配置
```

应用更新：

```bash
kubectl apply -f jenkins-deployment.yaml
```

---

## 五、配置 Pod Template（Agent 模板）

### 在 Jenkins 中配置

```
Kubernetes Cloud 配置 → Pod Templates → Add Pod Template
```

### 基本配置

| 配置项 | 值 |
|--------|-----|
| Name | `jenkins-agent` |
| Namespace | `jenkins` |
| Labels | `jenkins-agent` |

### 容器配置

**Container Template：**

| 配置项 | 值 |
|--------|-----|
| Name | `jnlp` |
| Docker image | `jenkins/inbound-agent:latest` |
| Working directory | `/home/jenkins/agent` |
| Command to run | 留空 |
| Arguments to pass | 留空 |

**如果需要 Docker 构建（使用 Kaniko）：**

添加第二个容器：

| 配置项 | 值 |
|--------|-----|
| Name | `kaniko` |
| Docker image | `gcr.io/kaniko-project/executor:debug` |
| Working directory | `/workspace` |
| Command to run | `/busybox/cat` |
| Arguments to pass | 留空 |

---

## 六、测试 Pipeline

创建一个测试 Pipeline：

```groovy
pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
  - name: maven
    image: maven:3.8-openjdk-11
    command:
    - cat
    tty: true
"""
        }
    }
    stages {
        stage('Test') {
            steps {
                container('maven') {
                    sh 'mvn --version'
                }
            }
        }
    }
}
```

运行后应该能看到：
- Jenkins 在 K8s 中动态创建了一个 Pod
- Pipeline 在 Pod 中执行
- 执行完成后 Pod 自动删除

---

## 七、常见问题

### 问题1：找不到 Kubernetes 插件

**原因：**
- Jenkins 版本过旧
- 插件列表未更新

**解决：**
```bash
# 更新插件列表
插件管理 → 高级 → 立即检查更新

# 或升级 Jenkins 版本（建议 2.400+）
```

---

### 问题2：Test Connection 失败

**错误信息：**
```
Forbidden: User "system:serviceaccount:jenkins:default" cannot get resource "pods"
```

**原因：** RBAC 权限不足

**解决：** 检查并应用上面的 RBAC 配置

---

### 问题3：Agent Pod 无法连接到 Jenkins

**错误信息：**
```
java.io.IOException: Failed to connect to http://jenkins:8080/tcpSlaveAgentListener/
```

**原因：** Jenkins URL 配置错误

**解决：**
```
Kubernetes Cloud 配置中：
Jenkins URL 改为：http://jenkins.jenkins.svc.cluster.local:8080
```

---

### 问题4：jnlp 镜像拉取失败

**错误信息：**
```
Failed to pull image "jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21"
dial tcp xxx:443: connect: connection refused
```

**原因：**
- Docker Hub 在国内无法访问
- Jenkins Kubernetes 插件会自动根据 Jenkins 版本生成对应的 `inbound-agent` tag（格式：`<jenkins-version>-jdk<version>`），每次 Jenkins 升级 tag 就会变

**解决方案1：推送到私有 Harbor（推荐）**
```bash
# 在能访问外网的机器上
docker pull jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21

docker tag jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21 \
  <你的Harbor>/jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21

docker push <你的Harbor>/jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
```

**解决方案2：在 Pod Template 中固定 jnlp 镜像地址**

在 Kubernetes Cloud → Pod Templates → 容器列表中，找到 jnlp 容器，手动填写 Harbor 地址：
```
<你的Harbor>/jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21
```
不要留空，留空会自动使用 Jenkins 版本对应的 tag 从 Docker Hub 拉取。

**解决方案3：使用国内镜像源**
```bash
docker pull m.daocloud.io/docker.io/jenkins/inbound-agent:latest
```
注意：国内镜像源不稳定，可能出现 503，建议用方案1。

---

### 问题5：Pod 创建后一直 Pending

**检查原因：**
```bash
kubectl describe pod <agent-pod-name> -n jenkins
```

**常见原因：**
- 资源不足（CPU/内存）
- 镜像拉取失败
- 节点污点限制

---

## 八、最佳实践

### 1. 使用私有镜像仓库

避免依赖公网镜像源，提前将常用镜像推送到私有仓库：

```bash
# 常用镜像列表
jenkins/inbound-agent:latest
maven:3.8-openjdk-11
gcr.io/kaniko-project/executor:latest
```

### 2. 配置资源限制

在 Pod Template 中设置资源限制：

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "2000m"
```

### 3. 使用持久化缓存

挂载 PVC 用于 Maven 缓存：

```yaml
volumes:
- name: maven-cache
  persistentVolumeClaim:
    claimName: maven-cache
volumeMounts:
- name: maven-cache
  mountPath: /root/.m2
```

### 4. 配置镜像拉取策略

```yaml
imagePullPolicy: IfNotPresent  # 优先使用本地镜像
```

---

## 九、完整示例

### jenkins-rbac.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins
  namespace: jenkins
rules:
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log", "secrets"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins
  namespace: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

### 应用配置

```bash
kubectl apply -f jenkins-rbac.yaml
kubectl rollout restart deployment/jenkins -n jenkins
```
