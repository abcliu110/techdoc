# Kubernetes Pod 间共享缓存的实现原理

## 你的问题：为什么可以指定缓存到另外一个 Pod？

**答案：不是缓存到"另外一个 Pod"，而是缓存到"持久化存储"，多个 Pod 都挂载这个存储。**

## 核心概念

### Pod 的临时性

```
Pod 的生命周期：
┌─────────────┐
│  创建 Pod   │  ← 全新的文件系统
└─────────────┘
       ↓
┌─────────────┐
│  运行构建   │  ← 在 Pod 内部操作
└─────────────┘
       ↓
┌─────────────┐
│  删除 Pod   │  ← 所有数据丢失
└─────────────┘
```

**问题**：Pod 内部的文件系统是临时的，Pod 删除后数据就丢失了。

### 持久化存储的作用

```
使用持久化存储：
┌─────────────┐     ┌──────────────────┐
│   Pod #1    │────→│  持久化存储 (PV) │
└─────────────┘     │  /maven-cache    │
                    └──────────────────┘
       ↓                     ↑
   (Pod 删除)                │
                             │
┌─────────────┐             │
│   Pod #2    │─────────────┘
└─────────────┘
```

**解决方案**：使用 Kubernetes 持久化卷（PersistentVolume），多个 Pod 可以挂载同一个存储。

## 技术实现

### 1. Kubernetes 存储架构

```
┌─────────────────────────────────────────────────────┐
│                    Kubernetes 集群                   │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │
│  │   Pod #1     │  │   Pod #2     │  │  Pod #3  │  │
│  │ (构建 #1)    │  │ (构建 #2)    │  │ (构建#3) │  │
│  └──────┬───────┘  └──────┬───────┘  └────┬─────┘  │
│         │                 │                │        │
│         └─────────────────┼────────────────┘        │
│                           ↓                         │
│              ┌────────────────────────┐             │
│              │  PersistentVolumeClaim │             │
│              │   (maven-cache-pvc)    │             │
│              └────────────┬───────────┘             │
│                           ↓                         │
│              ┌────────────────────────┐             │
│              │   PersistentVolume     │             │
│              │   (实际存储空间)        │             │
│              └────────────┬───────────┘             │
└───────────────────────────┼─────────────────────────┘
                            ↓
              ┌─────────────────────────┐
              │   物理存储               │
              │  - NFS                  │
              │  - Ceph                 │
              │  - 云盘 (EBS/云硬盘)    │
              │  - 本地磁盘 (hostPath)  │
              └─────────────────────────┘
```

### 2. 配置步骤

#### 步骤 1：创建 PersistentVolumeClaim (PVC)

```yaml
# maven-cache-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteMany  # 多个 Pod 可以同时读写
  resources:
    requests:
      storage: 10Gi  # 申请 10GB 存储空间
  storageClassName: nfs-storage  # 使用 NFS 存储类
```

**关键参数说明：**
- `ReadWriteMany`：允许多个 Pod 同时挂载（必须）
- `storage: 10Gi`：缓存空间大小
- `storageClassName`：存储类型（NFS、Ceph、云盘等）

#### 步骤 2：在 Jenkins Pod 中挂载 PVC

```yaml
# jenkins-deployment.yaml
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
        image: jenkins/jenkins:lts
        volumeMounts:
        - name: maven-cache
          mountPath: /var/jenkins_home/maven-repository  # 挂载到这个路径
      volumes:
      - name: maven-cache
        persistentVolumeClaim:
          claimName: maven-cache-pvc  # 引用上面创建的 PVC
```

#### 步骤 3：配置 Kubernetes Plugin（动态 Pod）

如果使用 Jenkins Kubernetes Plugin 创建动态构建 Pod：

```groovy
// Jenkinsfile
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
    image: maven:3.8-openjdk-11
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2/repository  # Maven 默认路径
  volumes:
  - name: maven-cache
    persistentVolumeClaim:
      claimName: maven-cache-pvc  # 挂载共享缓存
"""
        }
    }
    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn install'  # 自动使用 /root/.m2/repository (已挂载 PVC)
                }
            }
        }
    }
}
```

### 3. 工作流程详解

#### 构建 #1（首次）

```
1. Jenkins 创建 Pod #1
   ┌─────────────────────────────┐
   │ Pod: maven-build-abc123     │
   │                             │
   │ /root/.m2/repository ───────┼──→ 挂载 PVC
   │   (空的)                    │
   └─────────────────────────────┘
                ↓
2. Maven 下载依赖
   ┌─────────────────────────────┐
   │ Pod: maven-build-abc123     │
   │                             │
   │ /root/.m2/repository        │
   │   └─ org/springframework/   │
   │       └─ boot/              │
   │           └─ *.jar (500MB)  │
   └─────────────────────────────┘
                ↓
3. 数据写入 PVC
   ┌─────────────────────────────┐
   │  PersistentVolume (NFS)     │
   │                             │
   │  /maven-cache/              │
   │   └─ org/springframework/   │
   │       └─ boot/              │
   │           └─ *.jar (500MB)  │  ← 保存在持久化存储
   └─────────────────────────────┘
                ↓
4. Pod 删除
   ┌─────────────────────────────┐
   │ Pod: maven-build-abc123     │  ← 删除
   │   (已销毁)                  │
   └─────────────────────────────┘

   但是 PVC 中的数据保留！
   ┌─────────────────────────────┐
   │  PersistentVolume (NFS)     │
   │  /maven-cache/              │
   │   └─ org/springframework/   │  ← 数据仍然存在
   └─────────────────────────────┘
```

#### 构建 #2（使用缓存）

```
1. Jenkins 创建 Pod #2（全新 Pod）
   ┌─────────────────────────────┐
   │ Pod: maven-build-xyz789     │  ← 新 Pod
   │                             │
   │ /root/.m2/repository ───────┼──→ 挂载同一个 PVC
   └─────────────────────────────┘
                ↓
2. 挂载后自动看到缓存
   ┌─────────────────────────────┐
   │ Pod: maven-build-xyz789     │
   │                             │
   │ /root/.m2/repository        │
   │   └─ org/springframework/   │  ← 自动出现（来自 PVC）
   │       └─ boot/              │
   │           └─ *.jar (500MB)  │
   └─────────────────────────────┘
                ↓
3. Maven 检查缓存
   Maven: "检查 /root/.m2/repository/org/springframework/boot/..."
   Maven: "文件存在！使用缓存，跳过下载" ✓
                ↓
4. 快速完成构建
   构建时间：10 分钟 → 2 分钟
```

### 4. 存储类型对比

#### 方案 A：hostPath（本地磁盘）

```yaml
volumes:
- name: maven-cache
  hostPath:
    path: /data/maven-cache  # 宿主机路径
    type: DirectoryOrCreate
```

**特点：**
- ✓ 简单，无需额外配置
- ✓ 性能好（本地磁盘）
- ✗ 只能在同一个节点上共享
- ✗ Pod 调度到不同节点时无法使用缓存

**适用场景：** 单节点 Kubernetes 集群

#### 方案 B：NFS（网络文件系统）

```yaml
volumes:
- name: maven-cache
  nfs:
    server: 192.168.1.100  # NFS 服务器
    path: /exports/maven-cache
```

**特点：**
- ✓ 支持多节点共享
- ✓ 配置简单
- ✓ 支持 ReadWriteMany
- ✗ 性能一般（网络 IO）
- ✗ 需要单独的 NFS 服务器

**适用场景：** 多节点集群，中小型项目

#### 方案 C：Ceph RBD（分布式存储）

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: rook-cephfs
  resources:
    requests:
      storage: 10Gi
```

**特点：**
- ✓ 高可用（分布式）
- ✓ 支持多节点共享
- ✓ 性能好
- ✗ 配置复杂
- ✗ 需要 Ceph 集群

**适用场景：** 大型生产环境

#### 方案 D：云盘（EBS/云硬盘）

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache-pvc
spec:
  accessModes:
    - ReadWriteOnce  # 注意：云盘通常只支持单 Pod
  storageClassName: alicloud-disk-ssd
  resources:
    requests:
      storage: 10Gi
```

**特点：**
- ✓ 云平台原生支持
- ✓ 性能好
- ✗ 通常只支持 ReadWriteOnce（单 Pod）
- ✗ 成本较高

**适用场景：** 云环境，单 Pod 构建

## 5. 实际配置示例（RKE2 环境）

### 完整配置

```yaml
# 1. 创建 PVC
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi
  storageClassName: local-path  # RKE2 默认存储类

---
# 2. 修改 Jenkins Deployment
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
        image: jenkins/jenkins:lts
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: maven-cache
          mountPath: /var/jenkins_home/maven-repository
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
      - name: maven-cache
        persistentVolumeClaim:
          claimName: maven-cache-pvc  # 挂载 Maven 缓存
```

### Jenkinsfile 配置

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
    image: maven:3.8-openjdk-11
    command: ['cat']
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2/repository
  volumes:
  - name: maven-cache
    persistentVolumeClaim:
      claimName: maven-cache-pvc
"""
        }
    }

    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh '''
                        echo "=== 检查缓存 ==="
                        du -sh /root/.m2/repository || echo "缓存为空"

                        echo "=== 开始构建 ==="
                        mvn clean install -Dmaven.test.skip=true

                        echo "=== 缓存大小 ==="
                        du -sh /root/.m2/repository
                    '''
                }
            }
        }
    }
}
```

## 6. 验证缓存是否生效

### 方法 1：检查 PVC 状态

```bash
# 查看 PVC
kubectl get pvc -n jenkins

# 输出示例
NAME              STATUS   VOLUME                                     CAPACITY   ACCESS MODES
maven-cache-pvc   Bound    pvc-12345678-1234-1234-1234-123456789012   20Gi       RWX

# 查看 PVC 详情
kubectl describe pvc maven-cache-pvc -n jenkins
```

### 方法 2：进入 Pod 检查

```bash
# 获取 Pod 名称
kubectl get pods -n jenkins

# 进入 Pod
kubectl exec -it jenkins-xxx -n jenkins -- bash

# 检查挂载点
df -h | grep maven
# 输出: /dev/sda1  20G  5.2G  14G  28%  /var/jenkins_home/maven-repository

# 查看缓存内容
ls -lh /var/jenkins_home/maven-repository/
du -sh /var/jenkins_home/maven-repository/
```

### 方法 3：对比构建时间

```bash
# 第一次构建
构建 #1: 10:30 开始 → 10:40 结束 (10 分钟)
日志: Downloading from central: ...

# 第二次构建
构建 #2: 11:00 开始 → 11:03 结束 (3 分钟) ✓
日志: 没有 "Downloading" 信息
```

## 总结

### 关键点

1. **不是缓存到另一个 Pod**，而是缓存到持久化存储
2. **多个 Pod 挂载同一个 PVC**，实现缓存共享
3. **PVC 独立于 Pod 生命周期**，数据持久保存
4. **需要支持 ReadWriteMany** 的存储类型（NFS、Ceph 等）

### 配置清单

- [ ] 创建 PersistentVolumeClaim
- [ ] 配置 accessModes: ReadWriteMany
- [ ] 在 Pod 中挂载 PVC
- [ ] 修改 Jenkinsfile 使用缓存路径
- [ ] 验证缓存是否生效

### 推荐方案

| 环境 | 推荐方案 | 原因 |
|------|----------|------|
| 单节点 | hostPath | 简单，性能好 |
| 多节点 | NFS | 支持共享，配置简单 |
| 生产环境 | Ceph/云盘 | 高可用，性能好 |
| RKE2 | local-path + NFS | RKE2 默认支持 |
