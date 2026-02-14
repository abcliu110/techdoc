# Jenkins Kubernetes Plugin 安装和配置步骤

## 一、安装 Kubernetes Plugin

### 方法 1：通过 Jenkins UI 安装（推荐）

1. **登录 Jenkins**
   ```
   http://<节点IP>:30080
   ```

2. **进入插件管理**
   - 点击 "系统管理" (Manage Jenkins)
   - 点击 "插件管理" (Manage Plugins)

3. **搜索并安装插件**
   - 点击 "可选插件" (Available plugins) 标签
   - 在搜索框输入 "Kubernetes"
   - 勾选 "Kubernetes plugin"
   - 点击 "Install without restart" 或 "Download now and install after restart"

4. **等待安装完成**
   - 安装过程中会自动安装依赖插件
   - 建议勾选 "安装完成后重启 Jenkins"

5. **验证安装**
   - 系统管理 → 插件管理 → 已安装
   - 搜索 "Kubernetes"，应该看到已安装

### 方法 2：通过 Jenkins CLI 安装

```bash
# 获取 Jenkins Pod 名称
POD_NAME=$(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}')

# 进入 Jenkins 容器
kubectl exec -it -n jenkins $POD_NAME -- bash

# 安装插件
java -jar /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ \
  install-plugin kubernetes -restart
```

### 方法 3：通过 Dockerfile 预装（推荐用于新部署）

```dockerfile
FROM jenkins/jenkins:lts

# 安装插件
RUN jenkins-plugin-cli --plugins \
    kubernetes:latest \
    workflow-aggregator:latest \
    git:latest \
    configuration-as-code:latest
```

## 二、配置 Kubernetes Cloud

### 1. 进入配置页面

- 系统管理 (Manage Jenkins)
- 节点管理 (Manage Nodes and Clouds)
- Configure Clouds

### 2. 添加 Kubernetes Cloud

点击 "Add a new cloud" → 选择 "Kubernetes"

### 3. 基本配置

#### Kubernetes 配置

```
名称: kubernetes
Kubernetes 地址: https://kubernetes.default.svc.cluster.local
Kubernetes 服务证书 key: 留空
禁用 https 证书检查: 不勾选
Kubernetes 命名空间: jenkins
凭据: 留空（使用 ServiceAccount）
WebSocket: 勾选
Jenkins 地址: http://jenkins.jenkins.svc.cluster.local:8080
Jenkins 通道: jenkins.jenkins.svc.cluster.local:50000
```

#### 连接测试

点击 "Test Connection" 按钮

**成功显示：**
```
Connection test successful
Kubernetes version: v1.28.x
```

**如果失败，检查：**
1. Jenkins 是否在 Kubernetes 中运行
2. ServiceAccount 是否有足够权限
3. 网络是否可达

### 4. Pod 模板配置（可选）

如果需要默认模板，可以配置：

```
名称: jenkins-agent
命名空间: jenkins
标签: jenkins-agent
用法: 尽可能使用这个节点
```

添加容器模板：
```
名称: jnlp
Docker 镜像: jenkins/inbound-agent:latest
工作目录: /home/jenkins/agent
命令: 留空
参数: 留空
```

### 5. 保存配置

点击 "保存" 按钮

## 三、验证配置

### 1. 创建测试流水线

创建一个新的流水线任务，使用以下脚本：

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.8.6-openjdk-11
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

### 2. 执行构建

点击 "立即构建"

### 3. 查看结果

**成功标志：**
- 构建日志显示 Pod 创建成功
- Maven 版本信息正确显示
- 构建完成后 Pod 自动删除

**查看 Pod：**
```bash
# 构建过程中查看
kubectl get pods -n jenkins

# 应该看到临时 Pod
NAME                                    READY   STATUS    RESTARTS   AGE
jenkins-xxx                             1/1     Running   0          10m
test-pipeline-1-abc-xyz                 1/1     Running   0          5s
```

## 四、常见问题和解决方案

### 问题 1：插件安装失败

**错误：**
```
Failed to download plugin
```

**解决：**
1. 检查网络连接
2. 配置插件镜像源：
   ```
   系统管理 → 插件管理 → 高级
   升级站点: https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
   ```
3. 手动下载插件：
   - 访问 https://plugins.jenkins.io/kubernetes/
   - 下载 .hpi 文件
   - 系统管理 → 插件管理 → 高级 → 上传插件

### 问题 2：连接测试失败

**错误：**
```
Connection test failed
```

**解决：**

#### 检查 ServiceAccount 权限

```bash
# 查看 ServiceAccount
kubectl get sa -n jenkins

# 查看 ClusterRoleBinding
kubectl get clusterrolebinding | grep jenkins

# 如果不存在，创建
kubectl create clusterrolebinding jenkins \
  --clusterrole=cluster-admin \
  --serviceaccount=jenkins:jenkins
```

#### 检查网络连接

```bash
# 进入 Jenkins Pod
kubectl exec -it -n jenkins <pod-name> -- bash

# 测试连接
curl -k https://kubernetes.default.svc.cluster.local
```

### 问题 3：Pod 无法创建

**错误：**
```
Error creating pod: pods is forbidden
```

**解决：**

创建 RBAC 权限：

```yaml
# jenkins-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins
rules:
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```

```bash
kubectl apply -f jenkins-rbac.yaml
```

### 问题 4：镜像拉取失败

**错误：**
```
Failed to pull image "maven:3.8.6-openjdk-11"
```

**解决：**

1. 使用国内镜像：
   ```groovy
   image: registry.cn-hangzhou.aliyuncs.com/library/maven:3.8.6-openjdk-11
   ```

2. 或配置镜像加速（在所有节点）：
   ```bash
   # RKE2 节点配置
   sudo mkdir -p /etc/rancher/rke2
   sudo tee /etc/rancher/rke2/registries.yaml <<EOF
   mirrors:
     docker.io:
       endpoint:
         - "https://registry.cn-hangzhou.aliyuncs.com"
   EOF
   
   sudo systemctl restart rke2-server
   ```

### 问题 5：Kaniko 构建失败

**错误：**
```
error building image: error building stage
```

**解决：**

1. 检查 Dockerfile 是否存在
2. 检查 Kaniko 镜像版本：
   ```groovy
   image: gcr.io/kaniko-project/executor:v1.9.0-debug
   ```
3. 使用国内镜像：
   ```groovy
   image: registry.cn-hangzhou.aliyuncs.com/google_containers/kaniko-project-executor:v1.9.0-debug
   ```

## 五、完整部署检查清单

### 1. Jenkins 部署检查

- [ ] Jenkins 在 Kubernetes 中运行
- [ ] Jenkins 使用 ServiceAccount
- [ ] Jenkins 可以访问 Kubernetes API

### 2. 插件安装检查

- [ ] Kubernetes Plugin 已安装
- [ ] 插件版本兼容
- [ ] 依赖插件已安装

### 3. Kubernetes Cloud 配置检查

- [ ] Cloud 已添加
- [ ] 连接测试成功
- [ ] 命名空间正确
- [ ] ServiceAccount 有权限

### 4. RBAC 权限检查

- [ ] ServiceAccount 已创建
- [ ] ClusterRole 已创建
- [ ] ClusterRoleBinding 已创建
- [ ] 权限测试通过

### 5. 网络连接检查

- [ ] Jenkins 可以访问 Kubernetes API
- [ ] Pod 可以拉取镜像
- [ ] Pod 可以访问私有仓库

### 6. 测试流水线检查

- [ ] 测试流水线创建成功
- [ ] Pod 创建成功
- [ ] 构建执行成功
- [ ] Pod 自动清理

## 六、快速安装脚本

```bash
#!/bin/bash

echo "=== Jenkins Kubernetes Plugin 安装脚本 ==="

# 1. 检查 Jenkins Pod
echo ">>> 检查 Jenkins Pod"
POD_NAME=$(kubectl get pods -n jenkins -o jsonpath='{.items[0].metadata.name}')
if [ -z "$POD_NAME" ]; then
    echo "❌ 未找到 Jenkins Pod"
    exit 1
fi
echo "✓ Jenkins Pod: $POD_NAME"

# 2. 创建 RBAC
echo ">>> 创建 RBAC 权限"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
EOF

# 3. 创建 Maven 缓存 PVC
echo ">>> 创建 Maven 缓存 PVC"
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-maven-cache
  namespace: jenkins
spec:
  accessModes: [ReadWriteMany]
  storageClassName: local-path
  resources:
    requests:
      storage: 10Gi
EOF

# 4. 创建 Docker 配置
echo ">>> 创建 Docker 配置"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-config
  namespace: jenkins
data:
  config.json: |
    {
      "auths": {
        "192.168.80.100:30500": {"auth": ""}
      }
    }
EOF

echo ""
echo "=== 安装完成 ==="
echo "请在 Jenkins UI 中："
echo "1. 系统管理 → 插件管理"
echo "2. 搜索并安装 'Kubernetes plugin'"
echo "3. 系统管理 → 节点管理 → Configure Clouds"
echo "4. 添加 Kubernetes Cloud"
echo "5. 测试连接"
```

保存为 `install-k8s-plugin.sh` 并执行：

```bash
chmod +x install-k8s-plugin.sh
./install-k8s-plugin.sh
```

## 七、下一步

安装完成后：

1. 使用 Jenkinsfile-k8s 创建流水线
2. 执行构建测试
3. 查看构建日志和 Pod 状态
4. 验证镜像推送到私有仓库
