# Jenkins 性能优化指南

## 一、当前问题诊断

### 检查资源使用情况

```bash
# 查看 Jenkins Pod 资源使用
kubectl top pod -n jenkins

# 查看 Pod 详情
kubectl describe pod -n jenkins <jenkins-pod-name>

# 查看 Jenkins 日志
kubectl logs -n jenkins <jenkins-pod-name> --tail=100
```

## 二、优化方案

### 方案一：增加资源限制（推荐）

修改 `jenkins-deployment.yaml`：

```yaml
spec:
  containers:
    - name: jenkins
      image: jenkins/jenkins:lts-jdk21
      env:
        - name: JAVA_OPTS
          value: "-Xmx3072m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
      resources:
        requests:
          memory: "2Gi"      # 从 1Gi 增加到 2Gi
          cpu: "1000m"       # 从 500m 增加到 1000m
        limits:
          memory: "4Gi"      # 从 3Gi 增加到 4Gi
          cpu: "3000m"       # 从 2000m 增加到 3000m
```

应用更新：

```bash
kubectl apply -f jenkins-deployment.yaml
kubectl rollout status deployment/jenkins -n jenkins
```

### 方案二：配置 Maven 本地仓库持久化

Maven 每次下载依赖很慢，需要持久化本地仓库。

**创建 PVC for Maven 仓库：**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-maven-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: local-path
```

**修改 Deployment 挂载 Maven 仓库：**

```yaml
spec:
  containers:
    - name: jenkins
      volumeMounts:
        - name: jenkins-storage
          mountPath: /var/jenkins_home
        - name: maven-repo
          mountPath: /var/jenkins_home/.m2/repository
  volumes:
    - name: jenkins-storage
      persistentVolumeClaim:
        claimName: jenkins-pvc
    - name: maven-repo
      persistentVolumeClaim:
        claimName: jenkins-maven-pvc
```

### 方案三：配置 Maven 使用阿里云镜像

在 Jenkins 中配置 Maven settings.xml 使用国内镜像源。

**创建 ConfigMap：**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: maven-settings
  namespace: jenkins
data:
  settings.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
              http://maven.apache.org/xsd/settings-1.0.0.xsd">
      <mirrors>
        <mirror>
          <id>aliyunmaven</id>
          <mirrorOf>*</mirrorOf>
          <name>阿里云公共仓库</name>
          <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
      </mirrors>
      <localRepository>/var/jenkins_home/.m2/repository</localRepository>
    </settings>
```

**挂载到 Jenkins：**

```yaml
spec:
  containers:
    - name: jenkins
      volumeMounts:
        - name: jenkins-storage
          mountPath: /var/jenkins_home
        - name: maven-settings
          mountPath: /var/jenkins_home/.m2
  volumes:
    - name: jenkins-storage
      persistentVolumeClaim:
        claimName: jenkins-pvc
    - name: maven-settings
      configMap:
        name: maven-settings
```

### 方案四：优化 Jenkinsfile 构建参数

修改 Jenkinsfile 中的 Maven 构建命令：

```groovy
sh """
    mvn ${cleanCmd} install ${buildModule} ${skipTests} \
    -Dmaven.compile.fork=true \
    -T 2C \
    -Dmaven.artifact.threads=10 \
    -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120
"""
```

参数说明：
- `-T 2C`：使用 2 倍 CPU 核心数的线程并行构建
- `-Dmaven.artifact.threads=10`：并行下载依赖
- 其他参数：优化 HTTP 连接

### 方案五：清理 Jenkins 工作空间

Jenkins 工作空间占用太多磁盘空间也会导致卡顿。

**在 Jenkinsfile 中添加清理：**

```groovy
post {
    always {
        echo "=== 清理工作空间 ==="
        cleanWs(
            deleteDirs: true,
            patterns: [
                [pattern: 'target/**', type: 'INCLUDE'],
                [pattern: '.m2/**', type: 'INCLUDE']
            ]
        )
    }
}
```

**或在 Jenkins UI 中配置：**
- Manage Jenkins → System Configuration → Workspace Cleanup Plugin
- 设置自动清理策略

### 方案六：禁用不必要的插件

在 Jenkins UI 中：
1. Manage Jenkins → Manage Plugins
2. 禁用不使用的插件
3. 重启 Jenkins

### 方案七：增加 PVC 存储空间

如果磁盘空间不足：

```bash
# 检查 PVC 使用情况
kubectl exec -n jenkins <jenkins-pod> -- df -h

# 如果需要扩容 PVC（需要存储类支持）
kubectl edit pvc jenkins-pvc -n jenkins
# 修改 storage: 20Gi -> 50Gi
```

## 三、完整优化配置

### 优化后的 jenkins-deployment.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Gi  # 增加存储空间
  storageClassName: local-path
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-maven-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi  # Maven 本地仓库
  storageClassName: local-path
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: maven-settings
  namespace: jenkins
data:
  settings.xml: |
    <?xml version="1.0" encoding="UTF-8"?>
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
              http://maven.apache.org/xsd/settings-1.0.0.xsd">
      <mirrors>
        <mirror>
          <id>aliyunmaven</id>
          <mirrorOf>*</mirrorOf>
          <name>阿里云公共仓库</name>
          <url>https://maven.aliyun.com/repository/public</url>
        </mirror>
      </mirrors>
      <localRepository>/var/jenkins_home/.m2/repository</localRepository>
    </settings>
---
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
---
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
          env:
            - name: JAVA_OPTS
              value: "-Xmx3072m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dhudson.slaves.NodeProvisioner.initialDelay=0"
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
            - name: maven-repo
              mountPath: /var/jenkins_home/.m2/repository
            - name: maven-settings
              mountPath: /var/jenkins_home/.m2
              subPath: settings.xml
          resources:
            requests:
              memory: "2Gi"
              cpu: "1000m"
            limits:
              memory: "4Gi"
              cpu: "3000m"
          livenessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 90
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 5
          readinessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 60
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
        - name: maven-repo
          persistentVolumeClaim:
            claimName: jenkins-maven-pvc
        - name: maven-settings
          configMap:
            name: maven-settings
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30080
      name: http
    - port: 50000
      targetPort: 50000
      nodePort: 30050
      name: agent
  selector:
    app: jenkins
```

## 四、应用优化

```bash
# 1. 备份当前配置
kubectl get deployment jenkins -n jenkins -o yaml > jenkins-backup.yaml

# 2. 应用新配置
kubectl apply -f jenkins-deployment-optimized.yaml

# 3. 等待 Pod 重启
kubectl rollout status deployment/jenkins -n jenkins

# 4. 查看 Pod 状态
kubectl get pods -n jenkins -w

# 5. 查看资源使用
kubectl top pod -n jenkins
```

## 五、监控和诊断

### 查看 Jenkins 系统信息

在 Jenkins UI 中：
- Manage Jenkins → System Information
- 查看内存使用、线程数等

### 查看构建日志

- 进入具体构建 → Console Output
- 查看哪个阶段最慢

### 常见卡顿点

1. **Maven 下载依赖**：配置阿里云镜像
2. **Maven 编译**：增加并行线程 `-T 2C`
3. **Git 克隆**：使用浅克隆 `depth: 1`
4. **磁盘 I/O**：使用 SSD 存储

## 六、快速临时解决方案

如果需要立即缓解卡顿：

```bash
# 重启 Jenkins Pod
kubectl rollout restart deployment/jenkins -n jenkins

# 清理 Jenkins 工作空间（在 Jenkins UI 中）
# Manage Jenkins → Manage Nodes and Clouds → Built-In Node → Clean Up

# 手动清理 Maven 本地仓库
kubectl exec -n jenkins <jenkins-pod> -- rm -rf /var/jenkins_home/.m2/repository/*
```

## 七、总结

**优先级排序：**
1. ⭐⭐⭐ 增加内存和 CPU 资源
2. ⭐⭐⭐ 配置 Maven 阿里云镜像
3. ⭐⭐ 持久化 Maven 本地仓库
4. ⭐⭐ 优化 Maven 构建参数
5. ⭐ 清理工作空间和禁用不必要插件

**预期效果：**
- 首次构建：可能仍需 5-10 分钟（下载依赖）
- 后续构建：2-5 分钟（利用缓存）
