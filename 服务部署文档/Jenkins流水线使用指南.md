# Jenkins 使用镜像编译构建 Java 项目（无需本地 Docker）

## 方案选择

由于你的本地是 Windows 系统且没有安装 Docker，推荐以下方案：

---

## 方案一：使用官方镜像 + Jenkins UI 配置（最简单，推荐）

### 优点
- ✅ 无需本地 Docker
- ✅ 无需构建自定义镜像
- ✅ 配置简单，5 分钟完成

### 步骤

#### 1. 更新 jenkins-deployment.yaml

已经帮你更新为使用官方 JDK 21 镜像：
```yaml
image: jenkins/jenkins:lts-jdk21
```

#### 2. 应用更新

在你的 Kubernetes 集群上执行：
```bash
kubectl apply -f jenkins-deployment.yaml
```

#### 3. 在 Jenkins UI 中配置 Maven

访问 Jenkins：`http://<节点IP>:30080`

进入：`Manage Jenkins` → `Global Tool Configuration`

**配置 Maven：**
- 点击 `Add Maven`
- Name: `Maven`
- 勾选 `Install automatically`
- 选择 `Install from Apache`
- 版本：`3.9.6`
- 点击 `Save`

#### 4. 更新 Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        // Maven 通过 Jenkins 自动安装
        MAVEN_HOME = tool 'Maven'
        MAVEN_OPTS = '-Xmx2048m'

        // JDK 21 已经是容器默认的 Java
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // 项目配置
        PROJECT_NAME = 'nms4cloud-pos-java'
    }

    stages {
        stage('环境检查') {
            steps {
                script {
                    echo "=== 环境信息 ==="
                    sh '''
                        echo "Java版本:"
                        java -version
                        echo ""
                        echo "Maven版本:"
                        mvn -version
                    '''
                }
            }
        }

        stage('代码检出') {
            steps {
                script {
                    echo "=== 拉取代码 ==="
                    // 你的 Git 检出逻辑
                }
            }
        }

        stage('Maven构建') {
            steps {
                script {
                    echo "=== Maven构建 ==="
                    sh '''
                        mvn clean install -DskipTests -T 1C
                    '''
                }
            }
        }

        stage('打包构建产物') {
            steps {
                script {
                    echo "=== 打包构建产物 ==="
                    sh '''
                        mkdir -p artifacts
                        find . -name "*.jar" -path "*/target/*" -exec cp {} artifacts/ \\;
                    '''
                }
            }
        }
    }
}
```

**完成！** 首次构建时，Jenkins 会自动下载 Maven（约 1-2 分钟）。

---

## 方案二：使用腾讯云镜像构建功能（无需本地 Docker）

如果你想要预装 Maven 的自定义镜像，可以使用腾讯云的镜像构建功能。

### 步骤

#### 1. 在腾讯云控制台创建镜像构建

访问：https://console.cloud.tencent.com/tcr

1. 进入"个人版"
2. 点击"镜像构建"
3. 点击"新建"

#### 2. 配置构建规则

- **构建源**：选择"Dockerfile"
- **Dockerfile 内容**：粘贴以下内容

```dockerfile
FROM jenkins/jenkins:lts-jdk21

USER root

ARG MAVEN_VERSION=3.9.6
RUN wget -q https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

RUN java -version && mvn -version

USER jenkins
```

- **目标镜像**：`<你的命名空间>/jenkins-jdk21-maven:latest`
- 点击"立即构建"

#### 3. 等待构建完成

腾讯云会自动构建镜像并推送到你的仓库。

#### 4. 更新 jenkins-deployment.yaml

```yaml
spec:
  containers:
    - name: jenkins
      image: ccr.ccs.tencentyun.com/<你的命名空间>/jenkins-jdk21-maven:latest
  imagePullSecrets:
    - name: tencent-ccr-secret
```

---

## 方案三：在 Jenkins 中构建镜像（推荐用于构建应用镜像）

如果你需要在 Jenkins 中构建 Java 应用的 Docker 镜像，需要让 Jenkins 能够使用 Docker。

### 方式 A：挂载宿主机 Docker（推荐）

修改 `jenkins-deployment.yaml`：

```yaml
spec:
  containers:
    - name: jenkins
      image: jenkins/jenkins:lts-jdk21
      volumeMounts:
        - name: jenkins-storage
          mountPath: /var/jenkins_home
        # 挂载 Docker socket
        - name: docker-sock
          mountPath: /var/run/docker.sock
        # 挂载 Docker 命令
        - name: docker-bin
          mountPath: /usr/bin/docker
  volumes:
    - name: jenkins-storage
      persistentVolumeClaim:
        claimName: jenkins-pvc
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
        type: Socket
    - name: docker-bin
      hostPath:
        path: /usr/bin/docker
        type: File
```

### 在 Jenkinsfile 中使用 Docker

```groovy
stage('构建 Docker 镜像') {
    steps {
        script {
            echo "=== 构建 Docker 镜像 ==="

            def imageName = "ccr.ccs.tencentyun.com/myproject/myapp"
            def imageTag = "${env.BUILD_NUMBER}"

            sh """
                docker build -t ${imageName}:${imageTag} \
                    -t ${imageName}:latest \
                    -f Dockerfile .
            """
        }
    }
}

stage('推送 Docker 镜像') {
    steps {
        script {
            echo "=== 推送 Docker 镜像 ==="

            withCredentials([usernamePassword(
                credentialsId: 'tencent-ccr-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh """
                    echo \${DOCKER_PASS} | docker login ccr.ccs.tencentyun.com -u \${DOCKER_USER} --password-stdin
                    docker push ccr.ccs.tencentyun.com/myproject/myapp:${env.BUILD_NUMBER}
                    docker push ccr.ccs.tencentyun.com/myproject/myapp:latest
                """
            }
        }
    }
}
```

---

## 完整的 CI/CD 流程

```
1. 开发提交代码到 Git
   ↓
2. Jenkins 自动触发构建
   ↓
3. Jenkins Pod 使用 jenkins/jenkins:lts-jdk21 镜像
   ↓
4. Maven 编译打包 Java 项目（生成 JAR）
   ↓
5. Docker 构建应用镜像（包含 JAR）
   ↓
6. 推送应用镜像到腾讯云 CCR
   ↓
7. 更新 Kubernetes Deployment
   ↓
8. Kubernetes 拉取新镜像并部署应用
```

---

## 镜像说明

### Jenkins 镜像（用于运行 Jenkins）
- **官方镜像**：`jenkins/jenkins:lts-jdk21`
- **包含**：Jenkins + JDK 21
- **用途**：运行 Jenkins 服务
- **Maven**：通过 Jenkins UI 自动安装

### 应用镜像（用于运行 Java 应用）
- **基础镜像**：`openjdk:21-jdk-slim`
- **包含**：JDK 21 + 你的 JAR 文件
- **用途**：运行你的 Java 应用
- **构建**：在 Jenkins 中使用 Docker 构建

---

## 推荐配置

### 对于你的情况（Windows 本地，无 Docker）

**推荐使用方案一：**
1. ✅ 使用官方 `jenkins/jenkins:lts-jdk21` 镜像
2. ✅ 在 Jenkins UI 中配置 Maven 自动安装
3. ✅ 在 Jenkins 中挂载宿主机 Docker 来构建应用镜像
4. ✅ 推送应用镜像到腾讯云 CCR

**优点：**
- 无需在本地安装 Docker
- 无需构建自定义 Jenkins 镜像
- 配置简单，维护方便
- 首次构建会自动下载 Maven（只需等待 1-2 分钟）

---

## 下一步操作

1. **应用更新的 jenkins-deployment.yaml**
   ```bash
   kubectl apply -f jenkins-deployment.yaml
   ```

2. **等待 Pod 重启**
   ```bash
   kubectl get pods -n jenkins -w
   ```

3. **访问 Jenkins 配置 Maven**
   - 访问：`http://<节点IP>:30080`
   - 配置 Maven 自动安装

4. **运行第一次构建**
   - 首次构建会自动下载 Maven
   - 后续构建直接使用

需要我帮你创建完整的 Jenkinsfile 示例吗？
