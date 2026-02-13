# Maven 缓存机制说明

## 你的问题：更改之前，下载的第三方库难道不会缓存吗？

**答案：理论上会，但实际可能不会！** 这取决于你的 Jenkins 部署方式。

## Maven 默认缓存机制

### 默认行为
Maven 默认会缓存依赖到：
```bash
# Linux/Mac
~/.m2/repository

# Windows
C:\Users\<用户名>\.m2\repository

# Jenkins 环境
/var/jenkins_home/.m2/repository
```

### 示例
```bash
# 第一次运行
mvn install
# 下载 spring-boot-starter-web-2.7.0.jar 到 ~/.m2/repository

# 第二次运行
mvn install
# 直接使用 ~/.m2/repository 中的缓存，不再下载
```

**理论上，这个缓存应该自动工作！**

## 为什么你的 Jenkins 可能没有缓存？

### 场景 1：使用 Kubernetes 动态 Pod（最可能）

你使用的是 **RKE2 + Rancher**，很可能 Jenkins 使用 Kubernetes 插件创建临时 Pod 来执行构建。

```yaml
# 每次构建的流程
构建 #1:
  1. 创建新 Pod (maven-pod-abc123)
  2. Pod 内部目录: /root/.m2/repository (空的)
  3. 下载所有依赖 (500 MB)
  4. 构建完成
  5. 删除 Pod (缓存丢失！)

构建 #2:
  1. 创建新 Pod (maven-pod-xyz789)  ← 全新的 Pod
  2. Pod 内部目录: /root/.m2/repository (又是空的！)
  3. 再次下载所有依赖 (500 MB)  ← 重复下载
  4. 构建完成
  5. 删除 Pod
```

**问题**：每个 Pod 都是全新的容器，没有持久化存储，缓存随 Pod 销毁而丢失。

### 场景 2：使用静态 Jenkins Agent

如果 Jenkins 运行在固定的虚拟机或物理机上：

```bash
# 第一次构建
Jenkins Agent (固定机器)
  └─ /var/jenkins_home/.m2/repository
      └─ 下载依赖并缓存

# 第二次构建
Jenkins Agent (同一台机器)
  └─ /var/jenkins_home/.m2/repository
      └─ 使用缓存 ✓ (缓存有效！)
```

**这种情况下，默认缓存是有效的！**

### 场景 3：多个 Jenkins Agent

```bash
构建 #1 → Agent-1
  └─ /var/jenkins_home/.m2/repository (Agent-1 的缓存)

构建 #2 → Agent-2  ← 调度到不同的 Agent
  └─ /var/jenkins_home/.m2/repository (Agent-2 的缓存，是空的)
```

**问题**：每个 Agent 有独立的缓存，无法共享。

## 如何判断你的情况？

### 方法 1：检查 Jenkins 日志

查看构建日志中的 Maven 下载信息：

```bash
# 如果每次都看到这些下载日志，说明没有缓存
Downloading from central: https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-starter-web/2.7.0/spring-boot-starter-web-2.7.0.jar
Downloaded from central: https://repo.maven.apache.org/maven2/org/springframework/boot/spring-boot-starter-web/2.7.0/spring-boot-starter-web-2.7.0.jar (1.2 MB)
```

### 方法 2：对比构建时间

```bash
# 如果缓存有效
构建 #1: 10 分钟 (首次下载)
构建 #2: 2-3 分钟 (使用缓存)

# 如果缓存无效
构建 #1: 10 分钟
构建 #2: 10 分钟 (又下载了一遍)
构建 #3: 10 分钟 (还是下载)
```

### 方法 3：检查 Jenkins 配置

在 Jenkins 中运行：

```groovy
stage('检查缓存') {
    steps {
        sh '''
            echo "当前用户: $(whoami)"
            echo "HOME 目录: $HOME"
            echo "Maven 仓库位置:"
            ls -lh $HOME/.m2/repository 2>/dev/null || echo "默认缓存目录不存在"
            du -sh $HOME/.m2/repository 2>/dev/null || echo "无法计算大小"
        '''
    }
}
```

## 我们的优化做了什么？

### 之前（可能的情况）
```groovy
mvn install
# 使用默认位置: /root/.m2/repository (临时 Pod 内部)
# 每次构建都是新 Pod，缓存丢失
```

### 之后（明确指定持久化位置）
```groovy
MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
mvn install -Dmaven.repo.local=/var/jenkins_home/maven-repository
# 使用持久化位置: /var/jenkins_home/maven-repository
# 需要配合 PersistentVolume 使用
```

## 关键点：需要持久化存储

**仅仅指定缓存目录还不够**，还需要确保这个目录是持久化的！

### Kubernetes 环境需要配置 PVC

```yaml
# jenkins-deployment.yaml 中需要添加
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
# 在 Jenkins Pod 中挂载
volumes:
  - name: maven-cache
    persistentVolumeClaim:
      claimName: maven-cache-pvc
volumeMounts:
  - name: maven-cache
    mountPath: /var/jenkins_home/maven-repository
```

### 静态 Agent 环境

如果是静态 Agent，直接使用本地目录即可：
```groovy
MAVEN_LOCAL_REPO = '/opt/maven-cache'  # 确保这个目录存在且可写
```

## 总结

| 问题 | 答案 |
|------|------|
| Maven 默认会缓存吗？ | 是的，缓存到 `~/.m2/repository` |
| 为什么还是每次都下载？ | 可能使用临时 Pod，缓存随 Pod 销毁 |
| 我们的修改有用吗？ | 有用，但需要配合持久化存储 |
| 需要额外配置吗？ | Kubernetes 环境需要配置 PVC |
| 静态 Agent 需要改吗？ | 不一定，默认缓存可能已经有效 |

## 下一步建议

### 1. 先验证当前是否有缓存

在 Jenkinsfile 中添加诊断阶段：

```groovy
stage('诊断缓存') {
    steps {
        sh '''
            echo "=== 环境信息 ==="
            echo "当前用户: $(whoami)"
            echo "HOME: $HOME"
            echo "工作目录: $(pwd)"

            echo "=== 检查默认 Maven 缓存 ==="
            if [ -d "$HOME/.m2/repository" ]; then
                echo "✓ 默认缓存目录存在"
                du -sh $HOME/.m2/repository
                ls -lh $HOME/.m2/repository | head -20
            else
                echo "✗ 默认缓存目录不存在"
            fi

            echo "=== 检查自定义缓存 ==="
            if [ -d "/var/jenkins_home/maven-repository" ]; then
                echo "✓ 自定义缓存目录存在"
                du -sh /var/jenkins_home/maven-repository
            else
                echo "✗ 自定义缓存目录不存在"
            fi
        '''
    }
}
```

### 2. 根据诊断结果决定

**如果默认缓存有效**：
- 不需要修改，保持原样
- 或者只是明确指定路径以便管理

**如果默认缓存无效**：
- 使用我们的优化方案
- 配置 PVC 持久化存储（Kubernetes 环境）
- 或使用 Nexus 仓库管理器（企业级方案）

## 实际测试方法

```bash
# 第一次构建
触发构建 → 观察日志 → 记录构建时间 (例如: 10 分钟)

# 第二次构建（不修改代码）
触发构建 → 观察日志 → 记录构建时间

# 对比
如果第二次明显更快 (2-3 分钟) → 缓存有效 ✓
如果第二次时间相同 (10 分钟) → 缓存无效 ✗
```
