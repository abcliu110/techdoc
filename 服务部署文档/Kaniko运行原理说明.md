# Kaniko 运行原理和部署说明

## 一、Kaniko 不需要"安装"

### 1.1 传统思维 vs 云原生思维

**传统方式（错误理解）：**
```
❌ 在 Jenkins 服务器上安装 Kaniko
❌ 在 K8s 节点上安装 Kaniko
❌ 把 Kaniko 加入到 Jenkins 镜像中
```

**云原生方式（正确理解）：**
```
✅ Kaniko 是一个容器镜像
✅ 需要时动态创建 Kaniko 容器
✅ 用完即销毁
```

### 1.2 Kaniko 的本质

```
Kaniko 镜像地址：gcr.io/kaniko-project/executor:latest

这是一个 Docker 镜像，里面包含：
- /kaniko/executor（可执行文件）
- 构建镜像所需的工具
- 无需 Docker daemon
```

---

## 二、Kaniko 在哪里运行？

### 2.1 完整流程图

```
Jenkins Master（jenkins 命名空间）
    ↓ 触发构建
    ↓
Kubernetes API
    ↓ 创建 Pod
    ↓
动态 Pod（临时创建）
├── Maven 容器（maven:3.9.6-openjdk-21）
│   └── 执行 mvn package
│
└── Kaniko 容器（gcr.io/kaniko-project/executor）
    └── 执行 /kaniko/executor 构建镜像
    ↓
构建完成
    ↓
Pod 自动销毁
```

### 2.2 实际运行位置

**Kaniko 运行在：**
- ✅ 动态创建的 Pod 中
- ✅ 可能在任何一个 K8s 节点上（由调度器决定）
- ✅ 构建完成后自动销毁

**不运行在：**
- ❌ Jenkins Master Pod 中
- ❌ K8s 节点的宿主机上
- ❌ 任何固定的位置

---

## 三、如何使用 Kaniko

### 3.1 前置条件

**只需要两个东西：**

1. **Jenkins 安装 Kubernetes 插件**
   ```
   Jenkins → 系统管理 → 插件管理 → 搜索 "Kubernetes" → 安装
   ```

2. **K8s 集群能拉取 Kaniko 镜像**
   ```bash
   # 测试能否拉取 Kaniko 镜像
   kubectl run kaniko-test --image=gcr.io/kaniko-project/executor:debug --rm -it -- /busybox/sh
   ```

### 3.2 Jenkinsfile 配置

**在 Jenkinsfile 中定义 Pod 模板：**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  # Maven 容器
  - name: maven
    image: maven:3.9.6-openjdk-21
    command: ['cat']
    tty: true

  # Kaniko 容器（这里指定镜像地址）
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
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

        stage('构建镜像') {
            steps {
                container('kaniko') {
                    sh """
                        /kaniko/executor \
                          --context=\${WORKSPACE} \
                          --dockerfile=\${WORKSPACE}/Dockerfile \
                          --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0
                    """
                }
            }
        }
    }
}
```

### 3.3 执行过程详解

**当 Jenkins 执行这个 Pipeline 时：**

```
1. Jenkins 读取 Jenkinsfile
   ↓
2. 发现 agent { kubernetes { ... } }
   ↓
3. 调用 Kubernetes API 创建 Pod
   ↓
4. Pod 包含两个容器：
   - maven:3.9.6-openjdk-21
   - gcr.io/kaniko-project/executor:debug
   ↓
5. 执行 Maven 构建阶段
   → 在 maven 容器中执行 mvn package
   ↓
6. 执行镜像构建阶段
   → 在 kaniko 容器中执行 /kaniko/executor
   ↓
7. Kaniko 读取 Dockerfile，构建镜像，推送到仓库
   ↓
8. 构建完成，Pod 自动销毁
```

---

## 四、实际验证

### 4.1 查看动态创建的 Pod

**在构建过程中，可以看到临时 Pod：**

```bash
# 查看 jenkins 命名空间的 Pod
kubectl get pods -n jenkins

# 输出示例（构建进行中）：
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123  1/1     Running   0          2d
myapp-build-1-xyz789       2/2     Running   0          30s  ← 这是动态创建的构建 Pod
```

**构建完成后：**

```bash
kubectl get pods -n jenkins

# 输出示例（构建完成）：
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-7d8f9c5b6d-abc123  1/1     Running   0          2d
# myapp-build-1-xyz789 已经被销毁
```

### 4.2 查看 Pod 详情

**在构建过程中查看 Pod：**

```bash
# 获取动态 Pod 名称
kubectl get pods -n jenkins | grep build

# 查看 Pod 详情
kubectl describe pod <pod-name> -n jenkins

# 输出会显示两个容器：
Containers:
  maven:
    Image: maven:3.9.6-openjdk-21
  kaniko:
    Image: gcr.io/kaniko-project/executor:debug
```

### 4.3 查看 Kaniko 执行日志

```bash
# 查看 kaniko 容器的日志
kubectl logs <pod-name> -c kaniko -n jenkins -f

# 输出示例：
INFO[0000] Retrieving image manifest openjdk:21-jdk-slim
INFO[0001] Retrieving image openjdk:21-jdk-slim
INFO[0005] Built cross stage deps: map[]
INFO[0005] Retrieving image manifest openjdk:21-jdk-slim
INFO[0006] Executing 0 build triggers
INFO[0006] Unpacking rootfs as cmd COPY requires it.
INFO[0010] WORKDIR /app
INFO[0010] cmd: workdir
INFO[0010] Changed working directory to /app
INFO[0010] COPY target/*.jar app.jar
INFO[0010] Taking snapshot of files...
INFO[0011] EXPOSE 8080
INFO[0011] cmd: EXPOSE
INFO[0011] Adding exposed port: 8080/tcp
INFO[0011] ENTRYPOINT ["java", "-jar", "app.jar"]
INFO[0011] Pushing image to ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0
INFO[0015] Pushed image to 1 destinations
```

---

## 五、常见问题

### 5.1 Kaniko 镜像拉取失败

**问题：**
```
Failed to pull image "gcr.io/kaniko-project/executor:debug":
rpc error: code = Unknown desc = Error response from daemon:
Get https://gcr.io/v2/: net/http: request canceled
```

**原因：** gcr.io 在国内访问受限

**解决方案 1：使用国内镜像**

```groovy
# 在 Jenkinsfile 中使用阿里云镜像
containers:
- name: kaniko
  image: registry.cn-hangzhou.aliyuncs.com/kaniko-project-mirror/executor:debug
```

**解决方案 2：手动下载并推送到私有仓库**

```bash
# 1. 在能访问 gcr.io 的机器上拉取
docker pull gcr.io/kaniko-project/executor:debug

# 2. 打标签
docker tag gcr.io/kaniko-project/executor:debug \
  ccr.ccs.tencentyun.com/nms4cloud/kaniko-executor:debug

# 3. 推送到腾讯云
docker push ccr.ccs.tencentyun.com/nms4cloud/kaniko-executor:debug

# 4. 在 Jenkinsfile 中使用
containers:
- name: kaniko
  image: ccr.ccs.tencentyun.com/nms4cloud/kaniko-executor:debug
```

### 5.2 Kaniko 构建失败：权限问题

**问题：**
```
error checking push permissions -- make sure you entered the correct tag name,
and that you are authenticated correctly
```

**解决方案：** 检查 docker-registry-secret 是否正确创建

```bash
# 查看 secret
kubectl get secret docker-registry-secret -n jenkins -o yaml

# 重新创建 secret
kubectl delete secret docker-registry-secret -n jenkins
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=100012345678 \
  --docker-password=your-secret-key \
  -n jenkins
```

### 5.3 Kaniko 找不到 Dockerfile

**问题：**
```
error building image: getting stage builder for stage 0:
Get Dockerfile: stat /workspace/Dockerfile: no such file or directory
```

**解决方案：** 确保 Dockerfile 在项目根目录

```bash
# 检查项目结构
E:\nms4cloud\
├── Dockerfile          ← 必须在这里
├── pom.xml
├── src/
└── target/
```

---

## 六、总结

### 6.1 关键点

1. **Kaniko 不需要安装**
   - 它是一个容器镜像
   - 通过 Jenkinsfile 中的 Pod 模板引用

2. **Kaniko 运行位置**
   - 动态创建的 Pod 中
   - 构建完成后自动销毁

3. **使用 Kaniko 的步骤**
   - ✅ Jenkins 安装 Kubernetes 插件
   - ✅ 创建镜像仓库凭据（Secret）
   - ✅ 在 Jenkinsfile 中定义包含 Kaniko 的 Pod 模板
   - ✅ 在项目根目录创建 Dockerfile

### 6.2 完整架构图

```
┌─────────────────────────────────────────────────────────┐
│ RKE2 Cluster                                            │
│                                                         │
│  ┌──────────────────┐                                  │
│  │ Jenkins Master   │                                  │
│  │ (固定 Pod)       │                                  │
│  └────────┬─────────┘                                  │
│           │                                            │
│           │ 触发构建                                    │
│           ↓                                            │
│  ┌──────────────────────────────────┐                 │
│  │ 动态构建 Pod（临时）              │                 │
│  │                                  │                 │
│  │  ┌────────────┐  ┌────────────┐ │                 │
│  │  │ Maven      │  │ Kaniko     │ │                 │
│  │  │ 容器       │  │ 容器       │ │                 │
│  │  │            │  │            │ │                 │
│  │  │ mvn build  │  │ 构建镜像   │ │                 │
│  │  └────────────┘  └──────┬─────┘ │                 │
│  └─────────────────────────┼───────┘                 │
│                            │                          │
└────────────────────────────┼──────────────────────────┘
                             │
                             ↓
                    ┌────────────────┐
                    │ 镜像仓库        │
                    │ (腾讯云 CCR)    │
                    └────────────────┘
```

### 6.3 对比传统方式

| 传统方式 | Kaniko 方式 |
|---------|------------|
| 需要安装 Docker | 不需要 Docker |
| 固定在某台机器 | 动态创建，用完即销毁 |
| 需要 privileged 权限 | 用户空间运行，更安全 |
| 适合传统 K8s | 适合 RKE2/containerd |
| 资源常驻 | 按需使用资源 |

---

## 七、快速开始

### 7.1 最小化配置

**1. 创建镜像仓库凭据：**

```bash
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=你的账号ID \
  --docker-password=你的密钥 \
  -n jenkins
```

**2. 在项目根目录创建 Dockerfile：**

```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**3. 创建 Jenkinsfile：**

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
    command: ['cat']
    tty: true
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-secret
      items:
      - key: .dockerconfigjson
        path: config.json
"""
        }
    }
    stages {
        stage('构建') {
            steps {
                container('maven') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }
        stage('镜像') {
            steps {
                container('kaniko') {
                    sh '/kaniko/executor --context=${WORKSPACE} --dockerfile=${WORKSPACE}/Dockerfile --destination=ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0'
                }
            }
        }
    }
}
```

**4. 在 Jenkins 中创建 Pipeline 任务，指向你的 Git 仓库**

**5. 运行构建**

完成！Kaniko 会自动在动态 Pod 中运行，构建并推送镜像。
