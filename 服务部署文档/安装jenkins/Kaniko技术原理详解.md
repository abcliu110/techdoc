# Kaniko 在 Jenkins Kubernetes 环境中的技术原理详解

## 一、整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes 集群 (RKE2)                     │
│                                                               │
│  ┌─────────────────────┐         ┌──────────────────────┐   │
│  │  Jenkins Master Pod │         │  Kaniko Builder Pod  │   │
│  │                     │         │                      │   │
│  │  ┌──────────────┐   │         │  ┌───────────────┐  │   │
│  │  │ Maven 构建   │   │         │  │ Kaniko        │  │   │
│  │  │ 生成 jar     │   │         │  │ 读取 jar      │  │   │
│  │  └──────────────┘   │         │  │ 构建镜像      │  │   │
│  │         ↓           │         │  └───────────────┘  │   │
│  │  /home/jenkins/     │         │  /home/jenkins/     │   │
│  │  agent/workspace/   │         │  agent/workspace/   │   │
│  └─────────┬───────────┘         └──────────┬──────────┘   │
│            │                                 │              │
│            └────────────┬────────────────────┘              │
│                         ↓                                   │
│              ┌──────────────────────┐                       │
│              │  PersistentVolume    │                       │
│              │  (共享存储)           │                       │
│              │  - NFS / Longhorn    │                       │
│              │  - 存储 jar 文件     │                       │
│              └──────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

## 二、技术原理分解

### 1. Jenkins Kubernetes Plugin 的 Pod 创建机制

#### 1.1 声明式 Pipeline 触发

当 Jenkinsfile 中遇到 `agent { kubernetes { ... } }` 时：

```groovy
stage('构建 Docker 镜像') {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: kaniko
                image: gcr.io/kaniko-project/executor:debug
            """
        }
    }
    steps {
        container('kaniko') {
            // 在 Kaniko 容器中执行
        }
    }
}
```

**Jenkins Kubernetes Plugin 执行流程：**

1. **解析 YAML 定义** → 生成 Pod 模板
2. **调用 Kubernetes API** → 创建新的 Pod
3. **等待 Pod Ready** → 容器启动完成
4. **执行 steps** → 在指定容器中运行命令
5. **清理 Pod** → stage 结束后删除 Pod

#### 1.2 Pod 模板自动增强

Jenkins Kubernetes Plugin 会自动在你定义的 Pod 模板基础上添加：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-agent-kaniko-<random-id>
  labels:
    jenkins: agent
    jenkins/label: <pipeline-name>
spec:
  # 你定义的容器
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']  # 保持容器运行
    tty: true
    volumeMounts:
    - name: workspace-volume      # ← 自动添加
      mountPath: /home/jenkins/agent
    - name: docker-config
      mountPath: /kaniko/.docker

  # Jenkins 自动添加的 jnlp 容器（用于与 Master 通信）
  - name: jnlp
    image: jenkins/inbound-agent:latest
    volumeMounts:
    - name: workspace-volume      # ← 自动添加
      mountPath: /home/jenkins/agent

  # 自动挂载的 Volume
  volumes:
  - name: workspace-volume        # ← 关键：自动挂载工作空间
    persistentVolumeClaim:
      claimName: jenkins-pvc      # 与 Jenkins Master 相同的 PVC
  - name: docker-config
    secret:
      secretName: docker-registry-secret
```

**关键点：**
- Jenkins 自动检测 Master Pod 使用的工作空间 Volume
- 将相同的 Volume 挂载到新创建的 agent Pod
- 挂载路径保持一致：`/home/jenkins/agent`

### 2. PersistentVolume 共享机制

#### 2.1 存储类型要求

Kaniko Pod 能访问 jar 文件的**前提条件**：

```yaml
# Jenkins PVC 必须使用支持 ReadWriteMany 或多 Pod 访问的存储
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
spec:
  accessModes:
    - ReadWriteOnce   # 单节点多 Pod 可以共享
    # 或
    - ReadWriteMany   # 多节点多 Pod 可以共享
  storageClassName: longhorn  # RKE2 常用 Longhorn
  resources:
    requests:
      storage: 50Gi
```

**RKE2 环境中的存储选项：**

| 存储类型 | 访问模式 | 是否支持 Kaniko | 说明 |
|---------|---------|----------------|------|
| **Longhorn** | RWO/RWX | ✅ 是 | RKE2 默认存储，支持多 Pod 访问 |
| **NFS** | RWX | ✅ 是 | 网络文件系统，天然支持共享 |
| **Local Path** | RWO | ⚠️ 有条件 | 仅当 Jenkins Master 和 Kaniko Pod 在同一节点 |
| **HostPath** | - | ⚠️ 有条件 | 需要 Pod 调度到同一节点 |

#### 2.2 Pod 调度与 Volume 绑定

**场景 1：ReadWriteOnce (RWO) 存储**

```
节点 1 (node-1)
├── Jenkins Master Pod (运行中)
│   └── 挂载: jenkins-pvc → /var/jenkins_home
│
└── Kaniko Pod (新创建)
    └── 挂载: jenkins-pvc → /home/jenkins/agent

✅ 可以访问：两个 Pod 在同一节点，共享同一个 Volume
```

**Kubernetes 调度器行为：**
- 当 PVC 使用 RWO 模式时
- Kubernetes 会自动将 Kaniko Pod 调度到 Jenkins Master 所在的节点
- 因为 RWO Volume 只能挂载到一个节点

**场景 2：ReadWriteMany (RWX) 存储**

```
节点 1 (node-1)                    节点 2 (node-2)
├── Jenkins Master Pod             ├── Kaniko Pod
│   └── 挂载: jenkins-pvc          │   └── 挂载: jenkins-pvc
│                                  │
└── 共享存储后端 (NFS/Longhorn) ───┘

✅ 可以访问：RWX 支持跨节点访问
```

### 3. 文件路径映射原理

#### 3.1 工作空间路径结构

```
PersistentVolume 实际存储：
/mnt/longhorn/jenkins-pvc/
└── workspace/
    └── nms4cloud-build/              # Job 名称
        ├── nms4cloud-app/
        │   └── 2_business/
        │       └── nms4cloud-biz/
        │           └── nms4cloud-biz-app/
        │               ├── Dockerfile
        │               └── target/
        │                   └── nms4cloud-biz-app-0.0.1-SNAPSHOT.jar
        └── Jenkinsfile

Jenkins Master Pod 视角：
挂载: /mnt/longhorn/jenkins-pvc → /var/jenkins_home
工作目录: /var/jenkins_home/workspace/nms4cloud-build
环境变量: WORKSPACE=/var/jenkins_home/workspace/nms4cloud-build

Kaniko Pod 视角：
挂载: /mnt/longhorn/jenkins-pvc → /home/jenkins/agent
工作目录: /home/jenkins/agent/workspace/nms4cloud-build
环境变量: WORKSPACE=/home/jenkins/agent/workspace/nms4cloud-build
```

**关键理解：**
- 两个 Pod 挂载的是**同一个物理存储**
- 只是挂载点路径不同
- 但相对路径是一致的：`workspace/nms4cloud-build/...`

#### 3.2 Kaniko 构建上下文

```groovy
container('kaniko') {
    dir(appDir) {  // 例如：nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-app
        sh """
            /kaniko/executor \
              --context=\$(pwd) \        # 当前目录作为构建上下文
              --dockerfile=Dockerfile \
              --destination=registry.example.com/app:tag
        """
    }
}
```

**Kaniko 执行时：**

1. **读取构建上下文**
   ```bash
   pwd  # 输出：/home/jenkins/agent/workspace/nms4cloud-build/nms4cloud-app/.../nms4cloud-biz-app
   ```

2. **解析 Dockerfile**
   ```dockerfile
   COPY target/*.jar app.jar
   # Kaniko 在构建上下文中查找：./target/*.jar
   # 实际路径：/home/jenkins/agent/workspace/.../nms4cloud-biz-app/target/*.jar
   ```

3. **访问文件**
   - Kaniko 通过挂载的 Volume 直接读取文件
   - 不需要网络传输
   - 就像访问本地文件系统一样

### 4. 技术实现细节

#### 4.1 Jenkins Kubernetes Plugin 源码逻辑（简化）

```java
// Jenkins Kubernetes Plugin 核心逻辑
public Pod createPod(PodTemplate template) {
    // 1. 获取 Jenkins Master 的 Volume 配置
    List<Volume> masterVolumes = getJenkinsMasterVolumes();

    // 2. 创建 Pod 定义
    Pod pod = new PodBuilder()
        .withNewMetadata()
            .withName("jenkins-agent-" + UUID.randomUUID())
        .endMetadata()
        .withNewSpec()
            .addAllToContainers(template.getContainers())
            .addAllToVolumes(masterVolumes)  // ← 复用 Master 的 Volume
        .endSpec()
        .build();

    // 3. 为每个容器添加 Volume 挂载
    for (Container container : pod.getSpec().getContainers()) {
        container.getVolumeMounts().add(
            new VolumeMountBuilder()
                .withName("workspace-volume")
                .withMountPath("/home/jenkins/agent")  // ← 标准挂载路径
                .build()
        );
    }

    // 4. 调用 Kubernetes API 创建 Pod
    kubernetesClient.pods().create(pod);

    return pod;
}
```

#### 4.2 Kubernetes Volume 挂载机制

```
Pod 创建流程：
1. Scheduler 调度 Pod 到节点
   ↓
2. Kubelet 在节点上准备 Volume
   ↓
3. 对于 PVC：
   - 查找对应的 PV
   - 挂载存储到节点：/var/lib/kubelet/pods/<pod-id>/volumes/kubernetes.io~<type>/<pvc-name>
   ↓
4. 启动容器，bind mount 到容器内
   - 节点路径：/var/lib/kubelet/pods/.../jenkins-pvc
   - 容器路径：/home/jenkins/agent
   ↓
5. 容器内进程可以直接访问文件
```

**底层技术：**
- Linux Bind Mount
- 容器看到的是宿主机上的目录
- 多个容器可以 bind mount 同一个宿主机目录
- 实现文件共享

#### 4.3 Kaniko 无需 Docker Daemon 的原理

传统 Docker 构建：
```
docker build -t image:tag .
         ↓
Docker Daemon (需要特权模式)
         ↓
读取 Dockerfile → 执行指令 → 生成镜像层 → 推送到仓库
```

Kaniko 构建：
```
/kaniko/executor --context=. --dockerfile=Dockerfile
         ↓
Kaniko 用户空间程序（无需特权）
         ↓
1. 解析 Dockerfile
2. 在用户空间执行每条指令
3. 直接操作文件系统生成镜像层
4. 使用 Go 库推送到仓库
```

**关键技术：**
- **用户空间文件系统操作**：不需要 Docker Daemon
- **镜像层构建**：使用 `go-containerregistry` 库
- **直接推送**：通过 HTTP API 推送到 Registry
- **安全性**：不需要特权模式，适合 Kubernetes

## 三、完整工作流程时序图

```
Jenkins Master Pod          Kubernetes API          Kaniko Pod              Storage
      |                           |                       |                    |
      |-- Maven 构建 jar -------->|                       |                    |
      |                           |                       |                    |
      |-- 写入 jar 文件 ---------------------------------->|-- PVC 写入 ------->|
      |                           |                       |                    |
      |-- 触发 Kaniko stage ----->|                       |                    |
      |                           |                       |                    |
      |                           |-- 创建 Pod 请求 ------>|                    |
      |                           |                       |                    |
      |                           |-- 挂载 PVC ---------->|<-- 挂载相同 PVC ---|
      |                           |                       |                    |
      |                           |<-- Pod Ready ---------|                    |
      |                           |                       |                    |
      |-- 执行 Kaniko 命令 ------>|-- 转发到容器 -------->|                    |
      |                           |                       |                    |
      |                           |                       |-- 读取 jar 文件 -->|
      |                           |                       |                    |
      |                           |                       |-- 构建镜像层 ----->|
      |                           |                       |                    |
      |                           |                       |-- 推送到 Registry  |
      |                           |                       |                    |
      |<-- 构建完成 --------------|<-- 容器退出 ----------|                    |
      |                           |                       |                    |
      |                           |-- 删除 Pod ---------->|                    |
```

## 四、常见问题与原理解释

### Q1: 为什么 Kaniko Pod 能访问 Maven 构建的 jar？

**答：** 因为 Jenkins Kubernetes Plugin 自动将 Jenkins Master 的工作空间 PVC 挂载到 Kaniko Pod，两个 Pod 共享同一个存储卷。

**技术原理：**
- PVC 是 Kubernetes 的持久化存储抽象
- 多个 Pod 可以挂载同一个 PVC（取决于 AccessMode）
- 文件系统级别的共享，无需网络传输

### Q2: 如果 Jenkins Master 和 Kaniko Pod 在不同节点怎么办？

**答：** 取决于存储类型：

- **RWO (ReadWriteOnce)**：Kubernetes 会自动将 Kaniko Pod 调度到 Jenkins Master 所在节点
- **RWX (ReadWriteMany)**：可以在不同节点，通过网络存储（NFS/Longhorn）共享

**RKE2 环境：**
- 默认使用 Longhorn，支持 RWX
- 即使在不同节点也能访问

### Q3: 为什么不直接在 Jenkins Master Pod 中构建镜像？

**答：** 安全性和隔离性考虑：

1. **Docker-in-Docker 需要特权模式**
   ```yaml
   securityContext:
     privileged: true  # 安全风险
   ```

2. **Kaniko 无需特权**
   ```yaml
   securityContext:
     runAsUser: 1000  # 普通用户
   ```

3. **资源隔离**
   - 镜像构建消耗大量 CPU/内存
   - 独立 Pod 不影响 Jenkins Master 稳定性

4. **弹性伸缩**
   - 构建完成后 Pod 自动删除
   - 节省资源

### Q4: Dockerfile 中的 COPY 指令如何找到文件？

**答：** Kaniko 使用 `--context` 参数指定的目录作为构建上下文：

```bash
/kaniko/executor --context=$(pwd) --dockerfile=Dockerfile
```

**文件查找过程：**
1. Kaniko 读取 Dockerfile：`COPY target/*.jar app.jar`
2. 在构建上下文中查找：`$(pwd)/target/*.jar`
3. 实际路径：`/home/jenkins/agent/workspace/.../target/*.jar`
4. 通过挂载的 PVC 访问文件

**关键：** 使用相对路径，不要使用绝对路径。

### Q5: 如何验证 Volume 是否正确共享？

**方法 1：查看 Pod 定义**
```bash
kubectl get pod <kaniko-pod-name> -o yaml | grep -A 10 volumes
```

**方法 2：在 Jenkinsfile 中添加调试**
```groovy
container('kaniko') {
    sh '''
        echo "=== 挂载点 ==="
        df -h | grep jenkins

        echo "=== 工作目录 ==="
        pwd

        echo "=== 查找 jar 文件 ==="
        find /home/jenkins/agent -name "*.jar" -path "*/target/*"
    '''
}
```

**方法 3：检查 PVC 绑定**
```bash
kubectl get pvc jenkins-pvc -o yaml
kubectl describe pod <kaniko-pod-name>
```

## 五、最佳实践建议

### 1. 存储配置

```yaml
# 推荐：使用 Longhorn 并配置 RWX
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
spec:
  accessModes:
    - ReadWriteMany  # 支持跨节点
  storageClassName: longhorn
  resources:
    requests:
      storage: 100Gi  # 根据项目大小调整
```

### 2. Jenkinsfile 配置

```groovy
// 显式指定工作目录，确保路径正确
container('kaniko') {
    dir("${env.WORKSPACE}/${appDir}") {
        sh """
            # 验证文件存在
            ls -la target/*.jar || exit 1

            # 构建镜像
            /kaniko/executor \
              --context=\$(pwd) \
              --dockerfile=Dockerfile \
              --destination=\${IMAGE_NAME}:\${IMAGE_TAG}
        """
    }
}
```

### 3. Dockerfile 优化

```dockerfile
# 使用相对路径
COPY target/*.jar app.jar

# 避免绝对路径
# ❌ COPY /home/jenkins/agent/workspace/.../target/*.jar app.jar

# 使用 .dockerignore 减少构建上下文
# .dockerignore:
# .git
# .mvn
# *.md
```

### 4. 监控和调试

```groovy
// 添加详细日志
sh '''
    echo "=== 构建上下文 ==="
    pwd
    ls -lah

    echo "=== jar 文件 ==="
    ls -lh target/*.jar

    echo "=== 磁盘空间 ==="
    df -h
'''
```

## 六、总结

**Kaniko 在 Jenkins Kubernetes 中的核心技术：**

1. ✅ **Jenkins Kubernetes Plugin** 自动管理 Pod 生命周期
2. ✅ **PersistentVolume** 提供跨 Pod 的文件共享
3. ✅ **Volume 自动挂载** 确保工作空间一致性
4. ✅ **Kaniko 用户空间构建** 无需 Docker Daemon
5. ✅ **相对路径引用** 保证文件访问正确性

**jar 包共享的本质：**
- 不是"传输"或"复制"
- 而是通过 Kubernetes Volume 机制实现的**文件系统级别共享**
- 两个 Pod 访问的是同一个物理存储上的同一个文件
