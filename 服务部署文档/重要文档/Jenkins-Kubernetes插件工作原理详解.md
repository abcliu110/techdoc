# Jenkins Kubernetes 插件工作原理详解

## 一、Jenkins 如何动态创建 Pod

### 1.1 传统 Jenkins vs Kubernetes Jenkins

**传统 Jenkins（固定 Agent）：**
```
Jenkins Master（固定服务器）
    ↓
Jenkins Agent 1（固定服务器）
Jenkins Agent 2（固定服务器）
Jenkins Agent 3（固定服务器）

问题：
- 资源浪费（Agent 空闲时也占用资源）
- 扩展性差（需要手动添加 Agent）
- 环境不一致（每个 Agent 配置可能不同）
```

**Kubernetes Jenkins（动态 Agent）：**
```
Jenkins Master（K8s Pod）
    ↓ 需要构建时
动态创建 Agent Pod
    ↓ 构建完成
自动销毁 Agent Pod

优点：
- 按需创建，用完即销毁
- 无限扩展（只要 K8s 有资源）
- 环境一致（每次都是全新的）
```

### 1.2 工作流程图

```
用户触发构建
    ↓
Jenkins Master 接收请求
    ↓
读取 Jenkinsfile 中的 agent { kubernetes { ... } }
    ↓
调用 Kubernetes API
    ↓
Kubernetes 创建 Pod（包含 Maven、Kaniko 等容器）
    ↓
Pod 调度到某个 K8s 节点
    ↓
执行构建任务
    ↓
构建完成
    ↓
Jenkins 通知 Kubernetes
    ↓
Kubernetes 销毁 Pod
```

---

## 二、Pod 存在于哪里？

### 2.1 物理位置

**Pod 运行在 K8s 集群的节点上：**

```
RKE2 集群
├── 节点 1（192.168.1.101）
│   ├── Jenkins Master Pod（固定）
│   ├── Nacos Pod
│   └── MySQL Pod
│
├── 节点 2（192.168.1.102）
│   ├── 动态构建 Pod（临时）← 可能在这里
│   ├── Gateway Pod
│   └── Platform Pod
│
└── 节点 3（192.168.1.103）
    ├── 动态构建 Pod（临时）← 也可能在这里
    └── Redis Pod

Kubernetes 调度器决定 Pod 运行在哪个节点
```

### 2.2 逻辑位置

**Pod 在 jenkins 命名空间中：**

```bash
# 查看 jenkins 命名空间的所有 Pod
kubectl get pods -n jenkins

# 输出示例（构建进行中）：
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d        ← Jenkins Master（固定）
myapp-build-1-xyz789-abcde     2/2     Running   0          30s       ← 动态构建 Pod（临时）
```

**构建完成后：**

```bash
kubectl get pods -n jenkins

# 输出示例（构建完成）：
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d        ← 只剩 Jenkins Master
# myapp-build-1-xyz789-abcde 已被销毁
```

---

## 三、详细工作机制

### 3.1 Jenkins Kubernetes 插件的作用

**Jenkins Kubernetes 插件做了什么：**

1. **监听构建请求**
   - 当 Pipeline 执行到 `agent { kubernetes { ... } }` 时触发

2. **生成 Pod 定义**
   - 根据 Jenkinsfile 中的 YAML 生成 Pod 配置

3. **调用 Kubernetes API**
   - 使用 ServiceAccount 权限调用 K8s API
   - 创建 Pod

4. **等待 Pod 就绪**
   - 等待所有容器启动完成

5. **执行构建任务**
   - 在指定的容器中执行命令

6. **清理资源**
   - 构建完成后删除 Pod

### 3.2 实际例子

**Jenkinsfile：**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
"""
        }
    }

    stages {
        stage('Maven 构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }

        stage('构建镜像') {
            steps {
                container('kaniko') {
                    sh '/kaniko/executor --dockerfile=Dockerfile --destination=myapp:1.0'
                }
            }
        }
    }
}
```

**执行过程：**

```
时间线：

T0: 用户点击 "立即构建"
    ↓
T1: Jenkins Master 读取 Jenkinsfile
    ↓
T2: Jenkins 调用 Kubernetes API 创建 Pod
    POST /api/v1/namespaces/jenkins/pods
    Body: {上面的 YAML 定义}
    ↓
T3: Kubernetes 调度器选择节点（例如：节点 2）
    ↓
T4: 节点 2 拉取镜像
    - maven:3.9.6-openjdk-21
    - gcr.io/kaniko-project/executor:debug
    ↓
T5: Pod 启动，两个容器运行
    - maven 容器：执行 cat 命令（保持运行）
    - kaniko 容器：执行 /busybox/cat 命令（保持运行）
    ↓
T6: Jenkins 连接到 Pod，执行 Maven 构建
    在 maven 容器中执行：mvn clean package
    ↓
T7: Maven 构建完成，执行镜像构建
    在 kaniko 容器中执行：/kaniko/executor ...
    ↓
T8: 镜像构建完成，推送到仓库
    ↓
T9: 所有任务完成，Jenkins 调用 K8s API 删除 Pod
    DELETE /api/v1/namespaces/jenkins/pods/myapp-build-1-xyz789-abcde
    ↓
T10: Pod 被销毁，资源释放
```

---

## 四、实际验证

### 4.1 查看动态 Pod 创建过程

**终端 1：持续监控 Pod**

```bash
# 持续监控 jenkins 命名空间的 Pod
watch -n 1 'kubectl get pods -n jenkins'

# 或者
kubectl get pods -n jenkins -w
```

**终端 2：触发 Jenkins 构建**

```
在 Jenkins UI 中点击 "立即构建"
```

**你会看到：**

```
# 构建开始前
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d

# 构建开始后（Pod 创建中）
NAME                           READY   STATUS              RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running             0          2d
myapp-build-1-xyz789-abcde     0/2     ContainerCreating   0          5s

# Pod 运行中
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d
myapp-build-1-xyz789-abcde     2/2     Running   0          30s

# 构建完成后（Pod 终止中）
NAME                           READY   STATUS        RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running       0          2d
myapp-build-1-xyz789-abcde     2/2     Terminating   0          5m

# Pod 已销毁
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d
```

### 4.2 查看 Pod 详细信息

**在构建过程中：**

```bash
# 获取动态 Pod 名称
POD_NAME=$(kubectl get pods -n jenkins | grep build | awk '{print $1}')

# 查看 Pod 详情
kubectl describe pod $POD_NAME -n jenkins

# 输出示例：
Name:         myapp-build-1-xyz789-abcde
Namespace:    jenkins
Node:         node-2/192.168.1.102          ← Pod 运行在节点 2
Start Time:   Wed, 12 Feb 2026 10:30:00 +0800
Labels:       jenkins=agent
Status:       Running

Containers:
  maven:
    Container ID:   containerd://abc123...
    Image:          maven:3.9.6-openjdk-21
    State:          Running
      Started:      Wed, 12 Feb 2026 10:30:05 +0800

  kaniko:
    Container ID:   containerd://def456...
    Image:          gcr.io/kaniko-project/executor:debug
    State:          Running
      Started:      Wed, 12 Feb 2026 10:30:10 +0800

Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  30s   default-scheduler  Successfully assigned jenkins/myapp-build-1-xyz789-abcde to node-2
  Normal  Pulling    29s   kubelet            Pulling image "maven:3.9.6-openjdk-21"
  Normal  Pulled     25s   kubelet            Successfully pulled image "maven:3.9.6-openjdk-21"
  Normal  Created    25s   kubelet            Created container maven
  Normal  Started    25s   kubelet            Started container maven
  Normal  Pulling    25s   kubelet            Pulling image "gcr.io/kaniko-project/executor:debug"
  Normal  Pulled     20s   kubelet            Successfully pulled image "gcr.io/kaniko-project/executor:debug"
  Normal  Created    20s   kubelet            Created container kaniko
  Normal  Started    20s   kubelet            Started container kaniko
```

### 4.3 查看容器日志

```bash
# 查看 maven 容器日志
kubectl logs $POD_NAME -c maven -n jenkins -f

# 查看 kaniko 容器日志
kubectl logs $POD_NAME -c kaniko -n jenkins -f
```

### 4.4 进入容器调试

```bash
# 进入 maven 容器
kubectl exec -it $POD_NAME -c maven -n jenkins -- bash

# 查看工作目录
ls -la /workspace

# 查看 Maven 缓存
ls -la /root/.m2/repository
```

---

## 五、Jenkins 如何与 Kubernetes 通信

### 5.1 ServiceAccount 权限

**你的 jenkins-deployment.yaml 中已经配置了：**

```yaml
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
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get","list","watch"]
---
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      serviceAccountName: jenkins  ← Jenkins 使用这个 ServiceAccount
```

**这些权限允许 Jenkins：**
- ✅ 创建 Pod（create pods）
- ✅ 删除 Pod（delete pods）
- ✅ 查看 Pod 状态（get, list, watch pods）
- ✅ 执行命令（pods/exec）
- ✅ 查看日志（pods/log）

### 5.2 Jenkins 调用 Kubernetes API 的过程

```
Jenkins Master Pod
    ↓
读取 ServiceAccount Token
    位置：/var/run/secrets/kubernetes.io/serviceaccount/token
    ↓
调用 Kubernetes API Server
    URL: https://kubernetes.default.svc.cluster.local
    Header: Authorization: Bearer <token>
    ↓
创建 Pod
    POST /api/v1/namespaces/jenkins/pods
    Body: {Pod 定义}
    ↓
Kubernetes API Server 验证权限
    ↓
调度器分配节点
    ↓
节点拉取镜像并启动容器
```

### 5.3 在 Rancher 中查看

**查看 ServiceAccount：**

```
Rancher → 集群 → 更多资源 → 核心 → ServiceAccounts
命名空间：jenkins
找到：jenkins
```

**查看 ClusterRole：**

```
Rancher → 集群 → 更多资源 → RBAC → ClusterRoles
找到：jenkins
查看权限规则
```

---

## 六、资源管理

### 6.1 Pod 资源限制

**在 Jenkinsfile 中可以设置资源限制：**

```groovy
agent {
    kubernetes {
        yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "2000m"

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    resources:
      requests:
        memory: "512Mi"
        cpu: "250m"
      limits:
        memory: "1Gi"
        cpu: "1000m"
"""
    }
}
```

### 6.2 并发构建

**多个构建同时进行时：**

```bash
kubectl get pods -n jenkins

# 输出示例：
NAME                           READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123      1/1     Running   0          2d
platform-build-1-aaa111        2/2     Running   0          1m    ← 构建 1
gateway-build-2-bbb222         2/2     Running   0          45s   ← 构建 2
mq-build-3-ccc333              2/2     Running   0          30s   ← 构建 3
```

**每个构建都是独立的 Pod，互不影响。**

---

## 七、常见问题

### 7.1 Pod 创建失败

**问题：** Jenkins 构建卡在 "等待 Pod 启动"

**排查：**

```bash
# 查看 Pod 状态
kubectl get pods -n jenkins

# 查看 Pod 事件
kubectl describe pod <pod-name> -n jenkins

# 常见原因：
# 1. 镜像拉取失败（ImagePullBackOff）
# 2. 资源不足（Insufficient memory/cpu）
# 3. 权限问题（ServiceAccount 权限不足）
```

### 7.2 Pod 无法访问私有镜像

**解决方案：** 在 Pod 定义中添加 imagePullSecrets

```groovy
agent {
    kubernetes {
        yaml """
apiVersion: v1
kind: Pod
spec:
  imagePullSecrets:
  - name: docker-registry-secret
  containers:
  - name: maven
    image: your-private-registry.com/maven:3.9.6
"""
    }
}
```

### 7.3 Pod 保留时间

**默认情况：** Pod 构建完成后立即销毁

**保留 Pod 用于调试：**

```groovy
pipeline {
    options {
        // 保留最近 5 个构建的 Pod
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
}
```

**或者在 Jenkins 系统配置中设置：**

```
Jenkins → 系统管理 → 节点管理 → Configure Clouds → Kubernetes
→ Pod Retention: 选择 "Always" 或 "On Failure"
```

---

## 八、总结

### 8.1 核心概念

```
Jenkins Master（固定 Pod）
    ↓ 触发构建
动态创建 Agent Pod（临时）
    ├── Maven 容器
    └── Kaniko 容器
    ↓ 执行构建
构建完成
    ↓ 自动销毁
资源释放
```

### 8.2 Pod 存在位置

- **逻辑位置：** jenkins 命名空间
- **物理位置：** K8s 集群的某个节点（由调度器决定）
- **生命周期：** 临时（构建期间存在，完成后销毁）

### 8.3 优势

- ✅ 按需创建，节省资源
- ✅ 环境隔离，互不影响
- ✅ 无限扩展，只要集群有资源
- ✅ 环境一致，每次都是全新的

### 8.4 关键配置

1. **ServiceAccount 权限**（已配置）
2. **Kubernetes 插件**（需要安装）
3. **Jenkinsfile 中的 agent { kubernetes { ... } }**
4. **镜像仓库凭据**（docker-registry-secret）
