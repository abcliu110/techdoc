# Jenkins 配置 JDK 21 和 Maven

## 方案一：通过 Jenkins UI 配置（推荐快速开始）

### 1. 访问 Jenkins 配置页面

访问 Jenkins：`http://<节点IP>:30080`

进入：`Manage Jenkins` → `Global Tool Configuration`

### 2. 配置 JDK 21

在 JDK 配置区域：

1. 点击 `Add JDK`
2. 配置如下：
   - **Name**: `JDK21`（这个名称要在 Jenkinsfile 中使用）
   - **取消勾选** `Install automatically`（如果要手动安装）
   - 或者 **勾选** `Install automatically`：
     - 选择 `Install from adoptium.net`
     - 版本选择：`jdk-21.0.x+y`（最新的 LTS 版本）

### 3. 配置 Maven

在 Maven 配置区域：

1. 点击 `Add Maven`
2. 配置如下：
   - **Name**: `Maven`（这个名称要在 Jenkinsfile 中使用）
   - **勾选** `Install automatically`
   - 选择 `Install from Apache`
   - 版本选择：`3.9.6`（或最新稳定版）

### 4. 保存配置

点击页面底部的 `Save` 按钮。

### 5. 更新 Jenkinsfile

修改 Jenkinsfile 中的 JDK 配置：

```groovy
environment {
    // Maven配置
    MAVEN_HOME = tool 'Maven'
    MAVEN_OPTS = '-Xmx2048m'

    // JDK配置 - 改为 JDK21
    JAVA_HOME = tool 'JDK21'
    PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
}
```

### 6. 首次构建说明

首次运行构建时，Jenkins 会自动下载并安装 JDK 21 和 Maven 到 `/var/jenkins_home/tools/` 目录。这个过程可能需要几分钟。

---

## 方案二：自定义 Jenkins 镜像（推荐生产环境）

如果需要更快的构建速度和更稳定的环境，可以创建包含 JDK 21 和 Maven 的自定义镜像。

### 选项 A：直接使用官方 JDK 21 镜像（最简单）

Jenkins 官方提供了 JDK 21 的镜像，可以直接使用：

```yaml
# 修改 jenkins-deployment.yaml
spec:
  containers:
    - name: jenkins
      image: jenkins/jenkins:lts-jdk21  # 使用官方 JDK 21 镜像
```

然后在 Jenkins UI 中配置 Maven 自动安装（参考方案一）。

**优点**：
- 官方维护，稳定可靠
- 自动更新安全补丁
- 无需自己构建镜像

**缺点**：
- 首次构建时需要下载 Maven（约 1-2 分钟）

### 选项 B：基于官方镜像添加 Maven（推荐）

如果想要预装 Maven，可以基于官方 JDK 21 镜像创建：

```dockerfile
FROM jenkins/jenkins:lts-jdk21

USER root

# 安装 Maven
ARG MAVEN_VERSION=3.9.6
RUN wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# 设置环境变量
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

USER jenkins
```

**优点**：
- 基于官方镜像，稳定性好
- 预装 Maven，构建速度快
- Dockerfile 简单，易于维护

### 选项 C：使用社区镜像（不推荐）

也可以使用社区维护的镜像，但需要注意安全性和更新频率：

- [SRodi/dockerized-jenkins](https://github.com/SRodi/dockerized-jenkins) - 包含 Maven、Node.js 和 Docker
- [gefilte/docker-jenkins-jdk](https://github.com/gefilte/docker-jenkins-jdk) - 包含 JDK 和 Maven

**注意**：社区镜像可能不及时更新，存在安全风险。

### 构建和部署步骤

#### 如果使用选项 A（直接使用官方镜像）

```bash
# 1. 修改 jenkins-deployment.yaml
kubectl edit deployment jenkins -n jenkins

# 或者直接应用修改后的文件
kubectl apply -f jenkins-deployment.yaml

# 2. 等待 Pod 重启
kubectl rollout status deployment/jenkins -n jenkins

# 3. 访问 Jenkins UI 配置 Maven（参考方案一）
```

#### 如果使用选项 B（自定义镜像）

```bash
# 1. 创建 Dockerfile（使用上面的内容）
cat > Dockerfile <<'EOF'
FROM jenkins/jenkins:lts-jdk21

USER root

# 安装 Maven
ARG MAVEN_VERSION=3.9.6
RUN wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

USER jenkins
EOF

# 2. 构建镜像（根据你的镜像仓库地址修改）
docker build -t your-registry.com/jenkins-jdk21-maven:latest .

# 如果使用腾讯云容器镜像服务
docker build -t ccr.ccs.tencentyun.com/your-namespace/jenkins-jdk21-maven:latest .

# 3. 推送到镜像仓库
docker push your-registry.com/jenkins-jdk21-maven:latest

# 或推送到腾讯云
docker push ccr.ccs.tencentyun.com/your-namespace/jenkins-jdk21-maven:latest

# 4. 更新 jenkins-deployment.yaml
kubectl set image deployment/jenkins jenkins=your-registry.com/jenkins-jdk21-maven:latest -n jenkins

# 5. 等待 Pod 重启
kubectl rollout status deployment/jenkins -n jenkins
```

### 更新 Jenkinsfile

#### 如果使用选项 A（UI 配置 Maven）

```groovy
environment {
    // Maven 通过 Jenkins UI 配置
    MAVEN_HOME = tool 'Maven'
    MAVEN_OPTS = '-Xmx2048m'

    // JDK 21 已经是容器默认的 Java
    // 无需配置 JAVA_HOME，直接使用系统 Java
    PATH = "${MAVEN_HOME}/bin:${env.PATH}"
}
```

#### 如果使用选项 B（预装 Maven）

```groovy
environment {
    // 使用预装的 Maven
    MAVEN_HOME = '/opt/maven'
    MAVEN_OPTS = '-Xmx2048m'

    // JDK 21 已经是容器默认的 Java
    PATH = "${MAVEN_HOME}/bin:${env.PATH}"
}
```

---

## 推荐方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| **方案一：UI 配置** | 最简单，无需构建镜像 | 首次构建慢 | 快速开始、测试环境 |
| **方案二-A：官方镜像** | 官方维护，稳定 | 需要配置 Maven | 追求稳定性 |
| **方案二-B：自定义镜像** | 构建最快，完全控制 | 需要维护镜像 | 生产环境、频繁构建 |
| **方案三：JCasC** | 配置即代码，易于管理 | 配置复杂 | 自动化运维 |

## 我的推荐

1. **快速开始**：使用 `jenkins/jenkins:lts-jdk21` + UI 配置 Maven（方案二-A）
2. **生产环境**：基于 `lts-jdk21` 构建自定义镜像（方案二-B）
3. **大规模部署**：使用 JCasC 自动化配置（方案三）

### 1. 创建 JCasC 配置文件

创建 `jenkins-casc-config.yaml`：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: jenkins-casc-config
  namespace: jenkins
data:
  jenkins.yaml: |
    tool:
      jdk:
        installations:
        - name: "JDK21"
          properties:
          - installSource:
              installers:
              - jdkInstaller:
                  id: "jdk-21.0.2+13"
                  acceptLicense: true
      maven:
        installations:
        - name: "Maven"
          properties:
          - installSource:
              installers:
              - maven:
                  id: "3.9.6"
```

### 2. 更新 jenkins-deployment.yaml

添加 ConfigMap 挂载：

```yaml
spec:
  containers:
    - name: jenkins
      image: jenkins/jenkins:lts
      env:
        - name: JAVA_OPTS
          value: "-Xmx2048m -Xms512m"
        - name: CASC_JENKINS_CONFIG
          value: /var/jenkins_config/jenkins.yaml
      volumeMounts:
        - name: jenkins-storage
          mountPath: /var/jenkins_home
        - name: jenkins-casc-config
          mountPath: /var/jenkins_config
  volumes:
    - name: jenkins-storage
      persistentVolumeClaim:
        claimName: jenkins-pvc
    - name: jenkins-casc-config
      configMap:
        name: jenkins-casc-config
```

### 3. 应用配置

```bash
kubectl apply -f jenkins-casc-config.yaml
kubectl apply -f jenkins-deployment.yaml
```

---

## 验证安装

构建完成后，在 Jenkins 构建日志中查看：

```bash
Java版本:
openjdk version "21.0.2" 2024-01-16
OpenJDK Runtime Environment Temurin-21.0.2+13 (build 21.0.2+13)
OpenJDK 64-Bit Server VM Temurin-21.0.2+13 (build 21.0.2+13, mixed mode, sharing)

Maven版本:
Apache Maven 3.9.6
Maven home: /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/Maven
Java version: 21.0.2, vendor: Eclipse Adoptium
```

---

## 推荐方案选择

- **快速开始**：使用方案一（UI 配置自动安装）
- **生产环境**：使用方案二（自定义镜像）
- **自动化管理**：使用方案三（JCasC）

## 常见问题

### 1. 下载速度慢

如果自动下载 JDK/Maven 速度慢，可以：
- 使用国内镜像源
- 提前下载到 PVC 中
- 使用自定义镜像（方案二）

### 2. 磁盘空间不足

确保 PVC 有足够空间：
- JDK 21 约需 300MB
- Maven 约需 10MB
- Maven 本地仓库可能需要几个 GB

### 3. 权限问题

如果遇到权限问题，检查：
```bash
kubectl exec -it -n jenkins <jenkins-pod> -- ls -la /var/jenkins_home/tools/
```
