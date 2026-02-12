# Jenkins 中使用 Docker 的完整方案

## 一、问题分析

### 1.1 当前情况

你的 Jenkins 部署配置：
```yaml
containers:
  - name: jenkins
    image: jenkins/jenkins:lts-jdk21
    # 没有挂载 Docker socket
    # 没有安装 Docker
```

**问题：** Jenkins 容器内部没有 Docker 命令，无法执行 `docker build`、`docker push` 等操作。

### 1.2 为什么需要 Docker？

在 CI/CD 流程中需要：
```
Jenkins Pipeline
    ↓
Maven 构建 jar 包
    ↓
Docker 构建镜像 ← 需要 Docker 命令
    ↓
推送到镜像仓库 ← 需要 Docker 命令
```

---

## 二、解决方案对比

### 2.1 四种方案

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| 1. 挂载宿主机 Docker | 简单、快速 | 安全风险、权限问题 | ⭐⭐⭐ |
| 2. Docker-in-Docker | 隔离性好 | 复杂、性能差 | ⭐⭐ |
| 3. Kubernetes 插件 | 最佳实践、资源隔离 | 配置复杂 | ⭐⭐⭐⭐⭐ |
| 4. Kaniko | 无需 Docker daemon | 功能受限 | ⭐⭐⭐⭐ |

---

## 三、方案一：挂载宿主机 Docker（最简单）

### 3.1 原理

```
K8s 节点（宿主机）
├── Docker daemon (/var/run/docker.sock)
│
└── Jenkins Pod
    └── 挂载 /var/run/docker.sock
        └── 可以使用宿主机的 Docker
```

### 3.2 修改 Jenkins 部署配置

**更新 `jenkins-deployment.yaml`：**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccountName: jenkins
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts-jdk21
          # 使用 root 用户运行（需要访问 Docker socket）
          securityContext:
            runAsUser: 0
          env:
            - name: JAVA_OPTS
              value: "-Xmx3072m -Xms1024m -XX:+UseG1GC"
            - name: JENKINS_OPTS
              value: "--sessionTimeout=1440"
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 50000
              name: agent
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
            # 挂载 Docker socket
            - name: docker-sock
              mountPath: /var/run/docker.sock
            # 挂载 Docker 二进制文件（可选）
            - name: docker-bin
              mountPath: /usr/bin/docker
      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        # Docker socket
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
            type: Socket
        # Docker 二进制文件
        - name: docker-bin
          hostPath:
            path: /usr/bin/docker
            type: File
---
```

### 3.3 应用配置

```bash
# 更新部署
kubectl apply -f jenkins-deployment.yaml

# 重启 Jenkins Pod
kubectl rollout restart deployment/jenkins -n jenkins

# 查看 Pod 状态
kubectl get pods -n jenkins

# 进入 Pod 验证
kubectl exec -it <jenkins-pod-name> -n jenkins -- bash

# 在 Pod 内测试 Docker
docker version
docker ps
```

### 3.4 优缺点

**优点：**
- ✅ 配置简单
- ✅ 性能好（直接使用宿主机 Docker）
- ✅ 镜像缓存共享

**缺点：**
- ❌ 安全风险（Jenkins 可以访问宿主机所有容器）
- ❌ 需要 root 权限
- ❌ 多个 Jenkins 共享 Docker daemon

---

## 四、方案二：Docker-in-Docker（DinD）

### 4.1 原理

```
Jenkins Pod
├── Jenkins 容器
└── Docker daemon 容器（sidecar）
    └── 独立的 Docker 环境
```

### 4.2 修改部署配置

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  template:
    spec:
      containers:
        # Jenkins 容器
        - name: jenkins
          image: jenkins/jenkins:lts-jdk21
          env:
            - name: DOCKER_HOST
              value: tcp://localhost:2375
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home

        # Docker-in-Docker 容器
        - name: dind
          image: docker:dind
          securityContext:
            privileged: true
          env:
            - name: DOCKER_TLS_CERTDIR
              value: ""
          volumeMounts:
            - name: docker-storage
              mountPath: /var/lib/docker

      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        - name: docker-storage
          emptyDir: {}
```

### 4.3 优缺点

**优点：**
- ✅ 隔离性好
- ✅ 不影响宿主机

**缺点：**
- ❌ 需要 privileged 权限
- ❌ 性能较差
- ❌ 镜像缓存不共享

---

## 五、方案三：Kubernetes 插件（推荐）

### 5.1 原理

```
Jenkins Master
    ↓ 触发构建
动态创建 Pod（包含 Docker）
    ↓ 执行构建
构建完成后销毁 Pod
```

### 5.2 配置步骤

#### 步骤 1：安装 Kubernetes 插件

```
Jenkins → 系统管理 → 插件管理 → 可选插件
搜索 "Kubernetes" → 安装
```

#### 步骤 2：配置 Kubernetes Cloud

```
Jenkins → 系统管理 → 节点管理 → Configure Clouds → Add a new cloud → Kubernetes

配置：
- Name: kubernetes
- Kubernetes URL: https://kubernetes.default
- Kubernetes Namespace: jenkins
- Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
```

#### 步骤 3：创建 Pod 模板

```yaml
# 在 Jenkins 中配置 Pod Template
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  # Maven 容器
  - name: maven
    image: maven:3.9.6-openjdk-21
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2

  # Docker 容器
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock

  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
  - name: maven-cache
    emptyDir: {}
```

#### 步骤 4：使用 Pod Template 的 Jenkinsfile

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
    image: maven:3.9.6-openjdk-21
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
  - name: maven-cache
    emptyDir: {}
"""
        }
    }

    environment {
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'nms4cloud'
        IMAGE_NAME = 'myapp'
    }

    stages {
        stage('代码检出') {
            steps {
                git(
                    url: 'https://github.com/your-repo/myapp.git',
                    branch: 'main'
                )
            }
        }

        stage('Maven 构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Docker 构建') {
            steps {
                container('docker') {
                    script {
                        def imageTag = "${env.BUILD_NUMBER}"
                        def fullImage = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"

                        sh """
                            docker build -t ${fullImage}:${imageTag} .
                            docker tag ${fullImage}:${imageTag} ${fullImage}:latest
                        """
                    }
                }
            }
        }

        stage('推送镜像') {
            steps {
                container('docker') {
                    script {
                        def fullImage = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"

                        withCredentials([usernamePassword(
                            credentialsId: 'docker-credentials',
                            usernameVariable: 'USER',
                            passwordVariable: 'PASS'
                        )]) {
                            sh """
                                echo \${PASS} | docker login ${DOCKER_REGISTRY} -u \${USER} --password-stdin
                                docker push ${fullImage}:${env.BUILD_NUMBER}
                                docker push ${fullImage}:latest
                            """
                        }
                    }
                }
            }
        }
    }
}
```

### 5.3 优缺点

**优点：**
- ✅ 资源隔离（每个构建独立 Pod）
- ✅ 弹性伸缩
- ✅ 最佳实践
- ✅ 构建完成自动清理

**缺点：**
- ❌ 配置复杂
- ❌ 需要学习 Kubernetes 插件

---

## 六、方案四：使用 Kaniko（无需 Docker daemon）

### 6.1 原理

Kaniko 是 Google 开源的工具，可以在没有 Docker daemon 的环境中构建镜像。

```
Kaniko
    ↓ 读取 Dockerfile
    ↓ 构建镜像层
    ↓ 直接推送到镜像仓库
```

### 6.2 Jenkinsfile 示例

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
    image: maven:3.9.6-openjdk-21
    command:
    - cat
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: docker-credentials
"""
        }
    }

    stages {
        stage('Maven 构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Kaniko 构建镜像') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                            --context=\${WORKSPACE} \
                            --dockerfile=Dockerfile \
                            --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:${env.BUILD_NUMBER} \
                            --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:latest
                    """
                }
            }
        }
    }
}
```

### 6.3 创建 Docker 凭据 Secret

```bash
# 创建 Docker 配置文件
kubectl create secret generic docker-credentials \
  --from-file=config.json=/path/to/.docker/config.json \
  -n jenkins
```

**config.json 内容：**

```json
{
  "auths": {
    "ccr.ccs.tencentyun.com": {
      "auth": "base64(username:password)"
    }
  }
}
```

### 6.4 优缺点

**优点：**
- ✅ 无需 Docker daemon
- ✅ 安全性高
- ✅ 适合 Kubernetes 环境

**缺点：**
- ❌ 功能有限（不支持某些 Dockerfile 指令）
- ❌ 调试困难

---

## 七、推荐方案选择

### 7.1 根据场景选择

**快速测试（开发环境）：**
- 使用方案一：挂载宿主机 Docker
- 配置简单，快速上手

**生产环境（推荐）：**
- 使用方案三：Kubernetes 插件
- 资源隔离，弹性伸缩

**高安全要求：**
- 使用方案四：Kaniko
- 无需 Docker daemon，安全性高

### 7.2 我的推荐

**对于你的情况，推荐使用方案一（挂载宿主机 Docker）：**

理由：
1. ✅ 配置简单，快速实现
2. ✅ 性能好
3. ✅ 适合中小型团队
4. ✅ 可以后续升级到方案三

---

## 八、实施步骤（方案一）

### 8.1 更新 Jenkins 部署

**创建新的 `jenkins-deployment-with-docker.yaml`：**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccountName: jenkins
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts-jdk21
          # 使用 root 用户
          securityContext:
            runAsUser: 0
          env:
            - name: JAVA_OPTS
              value: "-Xmx3072m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
            - name: JENKINS_OPTS
              value: "--sessionTimeout=1440"
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 50000
              name: agent
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
            # 挂载 Docker socket
            - name: docker-sock
              mountPath: /var/run/docker.sock
            # 挂载 Docker 二进制文件
            - name: docker-bin
              mountPath: /usr/bin/docker
          resources:
            requests:
              memory: "2Gi"
              cpu: "1000m"
            limits:
              memory: "4Gi"
              cpu: "3000m"
      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        # Docker socket
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
            type: Socket
        # Docker 二进制文件
        - name: docker-bin
          hostPath:
            path: /usr/bin/docker
            type: File
```

### 8.2 应用配置

```bash
# 1. 备份当前配置
kubectl get deployment jenkins -n jenkins -o yaml > jenkins-backup.yaml

# 2. 应用新配置
kubectl apply -f jenkins-deployment-with-docker.yaml

# 3. 等待 Pod 重启
kubectl rollout status deployment/jenkins -n jenkins

# 4. 查看 Pod 状态
kubectl get pods -n jenkins

# 5. 进入 Pod 验证
kubectl exec -it $(kubectl get pod -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -n jenkins -- bash

# 6. 测试 Docker
docker version
docker ps
docker images
```

### 8.3 验证

**在 Jenkins 中创建测试 Pipeline：**

```groovy
pipeline {
    agent any

    stages {
        stage('测试 Docker') {
            steps {
                sh 'docker version'
                sh 'docker ps'
                sh 'docker images'
            }
        }
    }
}
```

---

## 九、常见问题

### 9.1 权限问题

**问题：** `permission denied while trying to connect to the Docker daemon socket`

**解决：**
```yaml
# 方法 1：使用 root 用户
securityContext:
  runAsUser: 0

# 方法 2：添加到 docker 组
securityContext:
  runAsUser: 1000
  fsGroup: 999  # docker 组 ID
```

### 9.2 Docker 命令找不到

**问题：** `docker: command not found`

**解决：**
```yaml
# 挂载 Docker 二进制文件
volumeMounts:
  - name: docker-bin
    mountPath: /usr/bin/docker
volumes:
  - name: docker-bin
    hostPath:
      path: /usr/bin/docker
      type: File
```

### 9.3 镜像推送失败

**问题：** `unauthorized: authentication required`

**解决：**
```bash
# 在 Jenkins 中配置凭据
Jenkins → 凭据 → 添加凭据
- 类型: Username with password
- ID: docker-credentials
- 用户名: 镜像仓库用户名
- 密码: 镜像仓库密码
```

---

## 十、总结

### 10.1 快速决策

```
需要快速实现？
    ↓ 是
使用方案一：挂载宿主机 Docker

需要资源隔离？
    ↓ 是
使用方案三：Kubernetes 插件

需要高安全性？
    ↓ 是
使用方案四：Kaniko
```

### 10.2 关键配置

**最简单的配置（方案一）：**

```yaml
volumeMounts:
  - name: docker-sock
    mountPath: /var/run/docker.sock
  - name: docker-bin
    mountPath: /usr/bin/docker
volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
  - name: docker-bin
    hostPath:
      path: /usr/bin/docker
```

**记住：** 配置完成后，Jenkins 就可以执行 Docker 命令了！
