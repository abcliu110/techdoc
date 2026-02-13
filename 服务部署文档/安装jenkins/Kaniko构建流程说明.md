# Kaniko 构建流程说明

## 问题：Kaniko Pod 如何访问 jar 文件？

### 场景
1. **Jenkins 主 Pod** → Maven 构建 → 生成 jar 文件
2. **Kaniko Pod** → 独立的 Pod → 需要访问 jar 文件构建镜像

### 解决方案：Jenkins 自动挂载工作空间

## 工作原理

### 1. Jenkins 工作空间配置

Jenkins 在 Kubernetes 中运行时，使用 PersistentVolumeClaim (PVC) 作为工作空间：

```yaml
# Jenkins StatefulSet 配置
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: jenkins
spec:
  volumeClaimTemplates:
  - metadata:
      name: jenkins-home
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 50Gi
```

### 2. Kaniko Pod 自动挂载

当使用 `agent { kubernetes { ... } }` 时，Jenkins 会：

1. **创建新的 Pod**（包含 Kaniko 容器）
2. **自动挂载工作空间 PVC** 到新 Pod
3. **保持相同的工作目录路径**

```yaml
# Jenkins 自动生成的 Kaniko Pod 配置
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-agent-kaniko-xxx
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    volumeMounts:
    - name: workspace-volume
      mountPath: /home/jenkins/agent  # 自动挂载
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: workspace-volume
    persistentVolumeClaim:
      claimName: jenkins-home  # 同一个 PVC
  - name: docker-config
    secret:
      secretName: docker-registry-secret
```

### 3. 文件路径映射

```
Jenkins 工作空间 PVC:
/var/jenkins_home/workspace/nms4cloud-build/
├── nms4cloud-app/
│   └── 2_business/
│       └── nms4cloud-biz/
│           └── nms4cloud-biz-app/
│               └── target/
│                   └── nms4cloud-biz-app-0.0.1-SNAPSHOT.jar

Maven 构建容器（Jenkins 主 Pod）:
挂载点: /home/jenkins/agent/workspace/nms4cloud-build/
访问路径: ./nms4cloud-app/.../target/*.jar

Kaniko 构建容器（Kaniko Pod）:
挂载点: /home/jenkins/agent/workspace/nms4cloud-build/  # 同一个 PVC
访问路径: ./nms4cloud-app/.../target/*.jar  # 相同的文件
```

## 验证方法

### 在 Jenkinsfile 中添加调试信息

```groovy
stage('构建 Docker 镜像') {
    agent {
        kubernetes {
            yaml """
            ...
            """
        }
    }
    steps {
        container('kaniko') {
            script {
                // 验证工作空间
                sh '''
                    echo "=== 当前工作目录 ==="
                    pwd

                    echo "=== 工作空间内容 ==="
                    ls -la

                    echo "=== 查找 jar 文件 ==="
                    find . -name "*.jar" -path "*/target/*" | head -10
                '''
            }
        }
    }
}
```

## 常见问题

### Q1: 如果 Kaniko Pod 找不到 jar 文件怎么办？

**原因：**
- PVC 没有正确挂载
- 工作目录路径不一致

**解决方法：**
```groovy
// 在 Kaniko 容器中显式指定工作目录
container('kaniko') {
    dir("${env.WORKSPACE}") {  // 确保在正确的工作目录
        sh '/kaniko/executor ...'
    }
}
```

### Q2: 是否需要手动配置 PVC？

**不需要**。Jenkins Kubernetes Plugin 会自动：
1. 检测 Jenkins 主 Pod 的工作空间 Volume
2. 将相同的 Volume 挂载到 agent Pod
3. 保持相同的挂载路径

### Q3: 如何确认 PVC 是否共享？

在 Jenkins 构建日志中查看：

```
[Pipeline] podTemplate
...
Created Pod: kubernetes jenkins/jenkins-agent-kaniko-xxx
...
Mounting volumes:
  - workspace-volume (PersistentVolumeClaim: jenkins-home)
```

## 最佳实践

### 1. 使用相对路径

在 Dockerfile 中使用相对路径：

```dockerfile
# 好的做法
COPY target/*.jar app.jar

# 避免使用绝对路径
# COPY /home/jenkins/agent/workspace/.../target/*.jar app.jar
```

### 2. 在 Kaniko 命令中指定正确的 context

```bash
/kaniko/executor \
  --context=$(pwd) \  # 使用当前目录作为构建上下文
  --dockerfile=Dockerfile \
  --destination=...
```

### 3. 验证文件存在

在构建镜像前验证 jar 文件：

```groovy
def hasJar = sh(
    script: 'ls target/*.jar 2>/dev/null | wc -l',
    returnStdout: true
).trim() != '0'

if (!hasJar) {
    error "找不到 jar 文件，请检查 Maven 构建是否成功"
}
```

## 总结

**Kaniko Pod 能访问 jar 文件的原因：**

1. ✅ Jenkins 使用 PVC 作为工作空间
2. ✅ Kaniko Pod 自动挂载相同的 PVC
3. ✅ 两个 Pod 共享相同的文件系统
4. ✅ 工作目录路径保持一致

**无需手动配置，Jenkins Kubernetes Plugin 自动处理！**
