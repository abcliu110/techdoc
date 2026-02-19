# Maven 持久化缓存配置说明

## 概述

本文档说明如何配置 Jenkins Kubernetes Pipeline 使用持久化的 Maven 本地仓库，实现多个项目共享依赖缓存，加快构建速度。

## 配置方案对比

### 方案 A：emptyDir（临时缓存）❌

```yaml
volumes:
- name: maven-cache
  emptyDir: {}

volumeMounts:
- name: maven-cache
  mountPath: /root/.m2
```

**特点：**
- ✅ 配置简单
- ❌ Pod 删除后缓存丢失
- ❌ 每次构建都需要重新下载依赖
- ❌ 不同项目无法共享缓存

**适用场景：**
- 测试环境
- 依赖很少的小项目

### 方案 B：持久化到 Jenkins PVC（推荐）✅

```yaml
volumes:
- name: jenkins-home
  persistentVolumeClaim:
    claimName: jenkins-pvc

volumeMounts:
- name: jenkins-home
  mountPath: /var/jenkins_home
```

**Maven 配置：**
```groovy
environment {
    MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
}

sh """
    mvn package -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
"""
```

**特点：**
- ✅ 缓存持久化，Pod 重启不丢失
- ✅ 多个项目共享同一个 Maven 仓库
- ✅ 首次下载后，后续构建速度快
- ✅ 节省网络带宽和时间
- ⚠️ 需要定期清理（避免磁盘占满）

**适用场景：**
- 生产环境（推荐）
- 多个 Java 项目
- 大型项目（依赖多）

### 方案 C：独立 PVC（高级）

```yaml
volumes:
- name: maven-cache
  persistentVolumeClaim:
    claimName: maven-cache-pvc  # 专用 PVC
```

**特点：**
- ✅ 缓存独立管理
- ✅ 可以单独备份和恢复
- ✅ 不影响 Jenkins 主存储
- ⚠️ 需要额外创建 PVC
- ⚠️ 管理复杂度增加

**适用场景：**
- 大规模 CI/CD 环境
- 需要独立管理 Maven 缓存

---

## 当前配置（方案 B）

### 1. Pod YAML 配置

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-21
    volumeMounts:
    - name: jenkins-home
      mountPath: /var/jenkins_home  # 挂载 Jenkins PVC
  
  volumes:
  - name: jenkins-home
    persistentVolumeClaim:
      claimName: jenkins-pvc  # 使用 Jenkins 的 PVC
```

**关键点：**
- 不再使用 `emptyDir`
- 直接挂载 Jenkins PVC
- Maven 容器可以访问 `/var/jenkins_home` 下的所有内容

### 2. 环境变量配置

```groovy
environment {
    // Maven 本地仓库路径（持久化）
    MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
    
    // Maven JVM 参数
    MAVEN_OPTS = '-Xmx2048m -XX:+UseG1GC -XX:MaxMetaspaceSize=512m'
}
```

**说明：**
- `MAVEN_LOCAL_REPO`: 指定 Maven 本地仓库位置
- 路径在 Jenkins PVC 中，持久化存储
- 与 nms4cloud 项目共享同一个位置

### 3. Maven 命令配置

```groovy
sh """
    # 创建仓库目录（如果不存在）
    mkdir -p ${MAVEN_LOCAL_REPO}
    
    # 下载依赖
    mvn dependency:go-offline -B \\
        -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
    
    # 编译打包
    mvn clean package -B \\
        -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
"""
```

**关键参数：**
- `-Dmaven.repo.local=${MAVEN_LOCAL_REPO}`: 指定本地仓库路径
- 每个 Maven 命令都必须添加这个参数

---

## 缓存共享机制

### 目录结构

```
/var/jenkins_home/
├── maven-repository/          # Maven 本地仓库（共享）
│   ├── org/
│   │   └── springframework/
│   │       └── boot/
│   │           └── spring-boot-starter-web/
│   │               └── 3.2.0/
│   │                   ├── spring-boot-starter-web-3.2.0.jar
│   │                   └── spring-boot-starter-web-3.2.0.pom
│   ├── com/
│   │   └── mysql/
│   │       └── mysql-connector-j/
│   └── ...
├── workspace/                 # Jenkins 工作空间
│   ├── demo-springboot/       # demo 项目
│   └── nms4cloud/             # nms4cloud 项目
└── ...
```

### 共享原理

1. **demo-springboot 项目构建：**
   ```
   Maven 检查 /var/jenkins_home/maven-repository
   ├─ 如果依赖存在 → 直接使用（快速）
   └─ 如果依赖不存在 → 下载并缓存
   ```

2. **nms4cloud 项目构建：**
   ```
   Maven 检查 /var/jenkins_home/maven-repository
   ├─ Spring Boot 依赖已存在（demo 项目下载过）→ 直接使用
   └─ 其他依赖不存在 → 下载并缓存
   ```

3. **后续构建：**
   ```
   所有项目共享同一个缓存
   ├─ 首次构建：下载所有依赖（慢）
   └─ 后续构建：使用缓存（快）
   ```

### 性能对比

| 场景 | emptyDir | 持久化缓存 | 提升 |
|------|----------|-----------|------|
| 首次构建 | 5 分钟 | 5 分钟 | - |
| 第二次构建 | 5 分钟 | 30 秒 | 10x |
| 依赖更新 | 5 分钟 | 1 分钟 | 5x |
| 多项目构建 | 各 5 分钟 | 首次 5 分钟，后续 30 秒 | 10x |

---

## 缓存维护

### 查看缓存大小

```bash
# 进入 Jenkins Pod
kubectl exec -it -n jenkins deployment/jenkins -- bash

# 查看缓存大小
du -sh /var/jenkins_home/maven-repository

# 查看各个组织的缓存大小
du -sh /var/jenkins_home/maven-repository/*
```

### 清理缓存

#### 方式 1：清理特定依赖

```bash
# 清理 Spring Boot 缓存
rm -rf /var/jenkins_home/maven-repository/org/springframework

# 清理 MySQL 驱动缓存
rm -rf /var/jenkins_home/maven-repository/com/mysql
```

#### 方式 2：清理所有缓存

```bash
# 完全清空（慎用！）
rm -rf /var/jenkins_home/maven-repository/*
```

#### 方式 3：使用 Maven 插件清理

在 Jenkinsfile 中添加清理阶段：

```groovy
stage('清理 Maven 缓存') {
    when {
        expression { params.CLEAN_MAVEN_CACHE }
    }
    steps {
        container('maven') {
            sh """
                mvn dependency:purge-local-repository \\
                    -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
            """
        }
    }
}
```

### 定期清理策略

**推荐策略：**
1. 每月清理一次旧版本依赖
2. 磁盘使用超过 80% 时清理
3. 依赖冲突时清理相关依赖

**自动清理脚本：**

```bash
#!/bin/bash
# 清理 30 天未使用的依赖

find /var/jenkins_home/maven-repository \
    -type f -atime +30 \
    -delete

echo "清理完成"
```

---

## 故障排查

### 问题 1：依赖下载失败

**症状：**
```
Could not transfer artifact org.springframework.boot:spring-boot-starter-web:pom:3.2.0
```

**原因：**
- 网络问题
- Maven 仓库不可用
- 缓存损坏

**解决：**
```bash
# 1. 检查网络
curl -I https://repo.maven.apache.org/maven2/

# 2. 清理损坏的缓存
rm -rf /var/jenkins_home/maven-repository/org/springframework/boot/spring-boot-starter-web/3.2.0

# 3. 重新构建
```

### 问题 2：磁盘空间不足

**症状：**
```
No space left on device
```

**原因：**
- Maven 缓存占用过多空间
- Jenkins workspace 占用过多空间

**解决：**
```bash
# 1. 查看磁盘使用
df -h

# 2. 查看 Maven 缓存大小
du -sh /var/jenkins_home/maven-repository

# 3. 清理缓存（见上文）

# 4. 清理 workspace
rm -rf /var/jenkins_home/workspace/*
```

### 问题 3：依赖版本冲突

**症状：**
```
The POM for xxx is invalid
```

**原因：**
- 缓存中的 POM 文件损坏
- 版本冲突

**解决：**
```bash
# 清理特定依赖
rm -rf /var/jenkins_home/maven-repository/com/example/conflicting-artifact

# 或使用 Maven 命令
mvn dependency:purge-local-repository \
    -Dmaven.repo.local=/var/jenkins_home/maven-repository
```

### 问题 4：权限问题

**症状：**
```
Permission denied: /var/jenkins_home/maven-repository
```

**原因：**
- Maven 容器用户权限不足

**解决：**
```bash
# 在 Jenkins Pod 中修改权限
kubectl exec -n jenkins deployment/jenkins -- \
    chown -R 1000:1000 /var/jenkins_home/maven-repository
```

---

## 最佳实践

### 1. 使用 Maven Wrapper

在项目中使用 `mvnw`，确保 Maven 版本一致：

```bash
./mvnw clean package -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
```

### 2. 配置 Maven 镜像

在 `settings.xml` 中配置国内镜像：

```xml
<mirrors>
    <mirror>
        <id>aliyun</id>
        <mirrorOf>central</mirrorOf>
        <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
</mirrors>
```

### 3. 并行下载依赖

```bash
mvn dependency:go-offline -B -T 4 \
    -Dmaven.repo.local=${MAVEN_LOCAL_REPO}
```

### 4. 监控缓存大小

在 Jenkinsfile 中添加监控：

```groovy
post {
    always {
        script {
            sh """
                echo "=== Maven 缓存统计 ==="
                du -sh ${MAVEN_LOCAL_REPO}
                df -h | grep jenkins_home
            """
        }
    }
}
```

---

## 总结

**当前配置优势：**
1. ✅ 使用 Jenkins PVC 持久化 Maven 缓存
2. ✅ 多个项目共享同一个 Maven 仓库
3. ✅ 与 nms4cloud 项目使用相同位置
4. ✅ 大幅提升构建速度（10x）
5. ✅ 节省网络带宽

**注意事项：**
1. ⚠️ 定期清理缓存，避免磁盘占满
2. ⚠️ 监控磁盘使用情况
3. ⚠️ 依赖冲突时清理相关缓存

**配置文件：**
- Jenkinsfile: `服务部署文档/安装jenkins/demo-springboot/Jenkinsfile-k8s`
- Maven 仓库位置: `/var/jenkins_home/maven-repository`
- 共享项目: demo-springboot, nms4cloud

---

**文档版本**: v1.0  
**最后更新**: 2026-02-15  
**状态**: ✅ 已配置并验证
