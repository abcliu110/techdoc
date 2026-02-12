# RKE2 + Rancher 环境下 Jenkins 构建 Docker 镜像方案

## 一、RKE2 环境特点

### 1.1 RKE2 vs 传统 K8s

| 特性 | 传统 K8s | RKE2 |
|------|----------|------|
| 容器运行时 | Docker | containerd |
| Docker daemon | ✅ 有 | ❌ 没有 |
| Docker socket | /var/run/docker.sock | ❌ 不存在 |
| 镜像构建 | 可以用 Docker | 需要其他方案 |

### 1.2 问题分析

```
RKE2 节点
├── containerd（容器运行时）
├── ❌ 没有 Docker daemon
├── ❌ 没有 /var/run/docker.sock
└── Jenkins Pod
    └── ❌ 无法使用 docker build
```

**结论：** 在 RKE2 环境下，必须使用**无需 Docker daemon** 的镜像构建工具。

---

## 二、适合 RKE2 的方案

### 2.1 方案对比

| 方案 | 是否需要 Docker | 难度 | 推荐度 |
|------|----------------|------|--------|
| Kaniko | ❌ 不需要 | 简单 | ⭐⭐⭐⭐⭐ |
| Buildah | ❌ 不需要 | 中等 | ⭐⭐⭐⭐ |
| Docker-in-Docker | ✅ 需要（独立） | 复杂 | ⭐⭐⭐ |
| nerdctl | ❌ 不需要 | 简单 | ⭐⭐⭐⭐ |

---

## 三、方案一：Kaniko（强烈推荐）

### 3.1 什么是 Kaniko？

**Kaniko** 是 Google 开源的容器镜像构建工具，专为 Kubernetes 环境设计。

**特点：**
- ✅ 无需 Docker daemon
- ✅ 在用户空间构建镜像
- ✅ 安全性高（无需 privileged）
- ✅ 完全兼容 Dockerfile
- ✅ 适合 RKE2/containerd 环境

### 3.2 工作原理

```
Jenkins Pipeline
    ↓
启动 Kaniko Pod
    ↓
读取 Dockerfile
    ↓
在用户空间构建镜像
    ↓
直接推送到镜像仓库
```

### 3.3 完整的 Jenkinsfile（Kaniko 方案）

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
  # Maven 容器（用于构建 Java 项目）
  - name: maven
    image: maven:3.9.6-openjdk-21
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2
    - name: workspace
      mountPath: /workspace

  # Kaniko 容器（用于构建 Docker 镜像）
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: workspace
      mountPath: /workspace

  volumes:
  - name: maven-cache
    emptyDir: {}
  - name: workspace
    emptyDir: {}
  - name: docker-config
    secret:
      secretName: docker-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
"""
        }
    }

    environment {
        // 镜像仓库配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'nms4cloud'

        // 项目配置
        PROJECT_NAME = 'nms4cloud'
        MODULE_NAME = 'nms4cloud-platform-app'
        MODULE_PATH = 'nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app'

        // 版本信息
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        BUILD_TIME = sh(script: "date +%Y%m%d-%H%M%S", returnStdout: true).trim()
        VERSION = "1.0.0"
        IMAGE_TAG = "${VERSION}-${GIT_COMMIT_SHORT}"
    }

    stages {
        stage('代码检出') {
            steps {
                echo "检出代码..."
                checkout scm
            }
        }

        stage('Maven 构建') {
            steps {
                container('maven') {
                    echo "开始 Maven 构建..."
                    sh """
                        cd /workspace
                        mvn clean package -pl ${MODULE_PATH} -am -DskipTests -B
                    """
                }
            }
        }

        stage('构建 Docker 镜像') {
            steps {
                container('kaniko') {
                    echo "使用 Kaniko 构建镜像..."
                    sh """
                        /kaniko/executor \
                          --context=/workspace \
                          --dockerfile=/workspace/Dockerfile \
                          --destination=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:${IMAGE_TAG} \
                          --destination=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:latest \
                          --cache=true \
                          --cache-ttl=24h \
                          --build-arg MODULE_PATH=${MODULE_PATH} \
                          --build-arg MODULE_NAME=${MODULE_NAME}
                    """
                }
            }
        }

        stage('部署到 K8s') {
            steps {
                echo "部署到 Kubernetes..."
                sh """
                    kubectl set image deployment/${MODULE_NAME} \
                      ${MODULE_NAME}=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:${IMAGE_TAG} \
                      -n production
                """
            }
        }
    }

    post {
        success {
            echo "构建成功！"
            echo "镜像: ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "构建失败！"
        }
    }
}
```

### 3.4 创建镜像仓库凭据

#### 方法一：通过 Rancher UI 创建

```
1. 登录 Rancher
2. 选择集群 → 项目/命名空间 → jenkins
3. 资源 → 密文 → 创建
4. 类型：docker-registry
5. 名称：docker-registry-secret
6. 镜像仓库地址：ccr.ccs.tencentyun.com
7. 用户名：你的腾讯云账号 ID
8. 密码：你的腾讯云密钥
```

#### 方法二：通过 kubectl 创建

```bash
# 创建 Docker 镜像仓库凭据
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=100012345678 \
  --docker-password=your-secret-key \
  --docker-email=your-email@example.com \
  -n jenkins
```

#### 方法三：使用 YAML 文件

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

**生成 base64 编码的配置：**

```bash
# 1. 创建 Docker 配置文件
cat > config.json <<EOF
{
  "auths": {
    "ccr.ccs.tencentyun.com": {
      "username": "100012345678",
      "password": "your-secret-key",
      "email": "your-email@example.com",
      "auth": "$(echo -n '100012345678:your-secret-key' | base64)"
    }
  }
}
EOF

# 2. Base64 编码
cat config.json | base64 -w 0

# 3. 将输出的内容填入 YAML 的 data..dockerconfigjson 字段
```

### 3.5 项目根目录创建 Dockerfile

**在 `E:\nms4cloud\Dockerfile`：**

```dockerfile
# ============ 阶段1：运行阶段 ============
FROM openjdk:21-jdk-slim

WORKDIR /app

# 构建参数
ARG MODULE_PATH
ARG MODULE_NAME

# 复制 jar 文件
COPY ${MODULE_PATH}/target/*.jar app.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# JVM 参数
ENV JAVA_OPTS="-Xmx1024m -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 创建日志目录
RUN mkdir -p logs

EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

---

## 四、方案二：nerdctl（RKE2 原生方案）

### 4.1 什么是 nerdctl？

**nerdctl** 是 containerd 的 Docker 兼容 CLI，命令和 Docker 几乎一样。

**特点：**
- ✅ RKE2 原生支持
- ✅ 命令与 Docker 兼容
- ✅ 直接使用 containerd
- ❌ 需要访问宿主机的 containerd socket

### 4.2 修改 Jenkins 部署配置

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
        - name: jenkins
          image: jenkins/jenkins:lts-jdk21
          securityContext:
            runAsUser: 0
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
            # 挂载 containerd socket
            - name: containerd-sock
              mountPath: /run/containerd/containerd.sock
            # 挂载 nerdctl 二进制
            - name: nerdctl-bin
              mountPath: /usr/local/bin/nerdctl
      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        # containerd socket（RKE2 路径）
        - name: containerd-sock
          hostPath:
            path: /run/k3s/containerd/containerd.sock
            type: Socket
        # nerdctl 二进制
        - name: nerdctl-bin
          hostPath:
            path: /usr/local/bin/nerdctl
            type: File
```

**注意：** RKE2 的 containerd socket 路径是 `/run/k3s/containerd/containerd.sock`

### 4.3 Jenkinsfile（nerdctl 方案）

```groovy
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'nms4cloud'
        MODULE_NAME = 'nms4cloud-platform-app'
        VERSION = "1.0.0"
    }

    stages {
        stage('Maven 构建') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('构建镜像') {
            steps {
                script {
                    // 使用 nerdctl 构建镜像（命令和 docker 一样）
                    sh """
                        nerdctl build -t ${MODULE_NAME}:${VERSION} .
                        nerdctl tag ${MODULE_NAME}:${VERSION} ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:${VERSION}
                        nerdctl tag ${MODULE_NAME}:${VERSION} ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:latest
                    """
                }
            }
        }

        stage('推送镜像') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-registry-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        nerdctl login ${DOCKER_REGISTRY} -u \$DOCKER_USER -p \$DOCKER_PASS
                        nerdctl push ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:${VERSION}
                        nerdctl push ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${MODULE_NAME}:latest
                    """
                }
            }
        }
    }
}
```

---

## 五、方案三：Docker-in-Docker（备选）

### 5.1 在 Jenkins Pod 中运行独立的 Docker

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
              value: tcp://localhost:2376
            - name: DOCKER_TLS_VERIFY
              value: "1"
            - name: DOCKER_CERT_PATH
              value: /certs/client
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
            - name: docker-certs
              mountPath: /certs/client
              readOnly: true

        # Docker daemon 容器
        - name: docker
          image: docker:24-dind
          securityContext:
            privileged: true
          env:
            - name: DOCKER_TLS_CERTDIR
              value: /certs
          volumeMounts:
            - name: docker-storage
              mountPath: /var/lib/docker
            - name: docker-certs
              mountPath: /certs/client

      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        - name: docker-storage
          emptyDir: {}
        - name: docker-certs
          emptyDir: {}
```

---

## 六、推荐方案总结

### 6.1 针对 RKE2 + Rancher 环境

**最佳方案：Kaniko（方案一）**

**理由：**
1. ✅ 无需 Docker daemon，完美适配 RKE2
2. ✅ 无需 privileged 权限，安全性高
3. ✅ 与 Kubernetes 深度集成
4. ✅ Rancher 官方推荐
5. ✅ 支持镜像缓存，构建速度快

### 6.2 实施步骤

```
1. 在 Rancher 中创建 docker-registry-secret
   ↓
2. 在项目根目录创建 Dockerfile
   ↓
3. 创建使用 Kaniko 的 Jenkinsfile
   ↓
4. 在 Jenkins 中创建 Pipeline 任务
   ↓
5. 运行构建
```

### 6.3 验证 RKE2 环境

```bash
# 1. 查看 RKE2 节点的容器运行时
kubectl get nodes -o wide

# 2. 检查是否有 Docker
ssh <node-ip>
docker version  # 应该报错：command not found

# 3. 检查 containerd
sudo crictl version

# 4. 检查 containerd socket 位置
ls -la /run/k3s/containerd/containerd.sock
```

---

## 七、完整示例：nms4cloud 项目

### 7.1 目录结构

```
nms4cloud/
├── Dockerfile                    # 镜像构建文件
├── Jenkinsfile                   # Jenkins Pipeline
├── pom.xml
├── nms4cloud-starter/
└── nms4cloud-app/
    └── 1_platform/
        └── nms4cloud-platform/
            └── nms4cloud-platform-app/
```

### 7.2 Dockerfile

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

ARG MODULE_PATH
ARG MODULE_NAME

COPY ${MODULE_PATH}/target/*.jar app.jar

ENV TZ=Asia/Shanghai
ENV JAVA_OPTS="-Xmx1024m -Xms512m -XX:+UseG1GC"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    mkdir -p logs

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### 7.3 在 Rancher 中创建凭据

```
1. 登录 Rancher UI
2. 集群 → 项目/命名空间 → jenkins
3. 资源 → 密文 → 创建
4. 类型：docker-registry
5. 名称：docker-registry-secret
6. 镜像仓库地址：ccr.ccs.tencentyun.com
7. 用户名：<腾讯云账号 ID>
8. 密码：<腾讯云密钥>
9. 保存
```

### 7.4 在 Jenkins 中创建 Pipeline

```
1. Jenkins → 新建任务
2. 输入任务名称：nms4cloud-platform
3. 选择：Pipeline
4. Pipeline 配置：
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: <你的 Git 仓库>
   - Script Path: Jenkinsfile
5. 保存
```

### 7.5 运行构建

```
1. 点击"立即构建"
2. 查看控制台输出
3. 构建成功后，镜像会自动推送到腾讯云 CCR
```

---

## 八、常见问题

### Q1: Kaniko 构建很慢怎么办？

**A:** 启用缓存

```groovy
sh """
    /kaniko/executor \
      --cache=true \
      --cache-ttl=24h \
      --cache-repo=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/cache \
      ...
"""
```

### Q2: 如何查看 RKE2 的 containerd socket 路径？

**A:**

```bash
# RKE2 默认路径
/run/k3s/containerd/containerd.sock

# 验证
ls -la /run/k3s/containerd/containerd.sock
```

### Q3: Kaniko 推送镜像失败？

**A:** 检查凭据配置

```bash
# 查看 secret
kubectl get secret docker-registry-secret -n jenkins -o yaml

# 验证凭据
kubectl create secret docker-registry test-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --dry-run=client -o yaml
```

### Q4: 在 Rancher 中如何查看构建日志？

**A:**

```
Rancher UI → 集群 → 工作负载 → Pods →
选择 Jenkins Pod → 查看日志
```

---

## 九、总结

### 9.1 RKE2 环境的关键点

1. ❌ RKE2 没有 Docker daemon
2. ✅ RKE2 使用 containerd
3. ✅ 必须使用无需 Docker 的构建工具
4. ✅ Kaniko 是最佳选择

### 9.2 推荐配置

```
RKE2 + Rancher
    ↓
Jenkins（Kubernetes 插件）
    ↓
动态 Pod（Maven + Kaniko）
    ↓
构建镜像并推送到 CCR
    ↓
部署到 K8s
```

这是最适合 RKE2 + Rancher 环境的企业级 CI/CD 方案。