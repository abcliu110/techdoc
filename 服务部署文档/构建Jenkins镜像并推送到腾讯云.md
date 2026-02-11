# 构建 Jenkins JDK21+Maven 镜像并推送到腾讯云

## 一、准备工作

### 1. 确认腾讯云信息

- **镜像仓库地址**：`ccr.ccs.tencentyun.com`
- **命名空间**：例如 `myproject` 或 `jenkins`
- **用户名**：你的腾讯云 UIN（在控制台查看）
- **密码**：在 TCR 控制台生成的访问凭证密码

### 2. 本地环境要求

- 已安装 Docker
- 已登录腾讯云容器镜像服务

---

## 二、创建 Dockerfile

### 方案一：精简版（推荐）

创建文件 `Dockerfile.jenkins`：

```dockerfile
FROM jenkins/jenkins:lts-jdk21

USER root

# 安装 Maven
ARG MAVEN_VERSION=3.9.6
RUN wget -q https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# 设置环境变量
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# 验证安装
RUN java -version && mvn -version

USER jenkins
```

### 方案二：完整版（包含常用工具）

创建文件 `Dockerfile.jenkins-full`：

```dockerfile
FROM jenkins/jenkins:lts-jdk21

USER root

# 安装基础工具
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    && rm -rf /var/lib/apt/lists/*

# 安装 Maven
ARG MAVEN_VERSION=3.9.6
RUN wget -q https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# 配置 Maven 使用阿里云镜像（加速下载）
RUN mkdir -p /opt/maven/conf && cat > /opt/maven/conf/settings.xml <<'EOF'
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
</settings>
EOF

# 设置环境变量
ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# 验证安装
RUN java -version && mvn -version

USER jenkins
```

---

## 三、构建并推送镜像

### 步骤 1：登录腾讯云容器镜像服务

```bash
# 登录腾讯云 TCR
docker login ccr.ccs.tencentyun.com

# 输入用户名（你的 UIN）和密码
```

### 步骤 2：构建镜像

```bash
# 使用精简版 Dockerfile
docker build -t ccr.ccs.tencentyun.com/<你的命名空间>/jenkins-jdk21-maven:latest \
  -f Dockerfile.jenkins .

# 或使用完整版 Dockerfile
docker build -t ccr.ccs.tencentyun.com/<你的命名空间>/jenkins-jdk21-maven:full \
  -f Dockerfile.jenkins-full .
```

**示例（假设命名空间是 myproject）：**
```bash
docker build -t ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:latest \
  -f Dockerfile.jenkins .
```

### 步骤 3：推送镜像到腾讯云

```bash
# 推送镜像
docker push ccr.ccs.tencentyun.com/<你的命名空间>/jenkins-jdk21-maven:latest

# 示例
docker push ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:latest
```

### 步骤 4：验证镜像

```bash
# 查看本地镜像
docker images | grep jenkins

# 在腾讯云控制台查看
# 访问：https://console.cloud.tencent.com/tcr
# 进入"镜像仓库" → 选择你的仓库 → 查看"镜像版本"
```

---

## 四、在 Kubernetes 中使用镜像

### 步骤 1：创建镜像拉取凭证

```bash
# 创建 Secret（如果还没有）
kubectl create secret docker-registry tencent-ccr-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=<你的UIN> \
  --docker-password=<你的密码> \
  --namespace=jenkins
```

### 步骤 2：更新 jenkins-deployment.yaml

修改 `jenkins-deployment.yaml` 文件：

```yaml
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
      # 添加镜像拉取凭证
      imagePullSecrets:
        - name: tencent-ccr-secret
      containers:
        - name: jenkins
          # 使用腾讯云的自定义镜像
          image: ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:latest
          env:
            - name: JAVA_OPTS
              value: "-Xmx2048m -Xms512m"
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 50000
              name: agent
          volumeMounts:
            - name: jenkins-storage
              mountPath: /var/jenkins_home
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "3Gi"
              cpu: "2000m"
      volumes:
        - name: jenkins-storage
          persistentVolumeClaim:
            claimName: jenkins-pvc
```

### 步骤 3：应用更新

```bash
# 应用更新的配置
kubectl apply -f jenkins-deployment.yaml

# 查看 Pod 状态
kubectl get pods -n jenkins -w

# 查看 Pod 详情（如果有问题）
kubectl describe pod -n jenkins <pod-name>

# 查看 Pod 日志
kubectl logs -n jenkins <pod-name>
```

---

## 五、更新 Jenkinsfile

由于镜像中已经预装了 Maven，更新 Jenkinsfile：

```groovy
pipeline {
    agent any

    environment {
        // Maven 已经预装在镜像中
        MAVEN_HOME = '/opt/maven'
        MAVEN_OPTS = '-Xmx2048m'

        // JDK 21 是容器默认的 Java
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // 项目配置
        PROJECT_NAME = 'nms4cloud-pos-java'

        // Docker 配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'myproject'
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
                        echo ""
                        echo "Git版本:"
                        git --version
                    '''
                }
            }
        }

        // ... 其他 stages ...
    }
}
```

---

## 六、完整操作流程（快速参考）

```bash
# 1. 创建 Dockerfile
cat > Dockerfile.jenkins <<'EOF'
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
EOF

# 2. 登录腾讯云
docker login ccr.ccs.tencentyun.com

# 3. 构建镜像（替换 myproject 为你的命名空间）
docker build -t ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:latest \
  -f Dockerfile.jenkins .

# 4. 推送镜像
docker push ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:latest

# 5. 创建 K8s Secret
kubectl create secret docker-registry tencent-ccr-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=<你的UIN> \
  --docker-password=<你的密码> \
  --namespace=jenkins

# 6. 更新 Deployment
kubectl apply -f jenkins-deployment.yaml

# 7. 查看状态
kubectl get pods -n jenkins -w
```

---

## 七、常见问题

### 1. 构建镜像时下载 Maven 很慢

**解决方案：使用国内镜像**

```dockerfile
# 使用清华大学镜像
RUN wget -q https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz \
    && tar -xzf apache-maven-3.9.6-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.6 /opt/maven \
    && rm apache-maven-3.9.6-bin.tar.gz
```

### 2. 推送镜像失败：unauthorized

**原因：**
- 未登录或登录过期
- 用户名或密码错误
- 命名空间不存在

**解决：**
```bash
# 重新登录
docker logout ccr.ccs.tencentyun.com
docker login ccr.ccs.tencentyun.com

# 检查命名空间是否存在
# 访问腾讯云控制台确认
```

### 3. Kubernetes 拉取镜像失败：ImagePullBackOff

**原因：**
- Secret 不存在或配置错误
- 镜像地址错误
- 命名空间不匹配

**解决：**
```bash
# 检查 Secret
kubectl get secret tencent-ccr-secret -n jenkins

# 查看 Pod 详情
kubectl describe pod -n jenkins <pod-name>

# 重新创建 Secret
kubectl delete secret tencent-ccr-secret -n jenkins
kubectl create secret docker-registry tencent-ccr-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=<你的UIN> \
  --docker-password=<你的密码> \
  --namespace=jenkins
```

### 4. 如何更新镜像？

```bash
# 1. 重新构建镜像（使用新标签）
docker build -t ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:v2 \
  -f Dockerfile.jenkins .

# 2. 推送新镜像
docker push ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:v2

# 3. 更新 Deployment
kubectl set image deployment/jenkins \
  jenkins=ccr.ccs.tencentyun.com/myproject/jenkins-jdk21-maven:v2 \
  -n jenkins

# 4. 查看滚动更新状态
kubectl rollout status deployment/jenkins -n jenkins
```

---

## 八、镜像大小优化（可选）

如果想减小镜像大小：

```dockerfile
FROM jenkins/jenkins:lts-jdk21-alpine

USER root

# Alpine 使用 apk 包管理器
RUN apk add --no-cache wget tar

# 安装 Maven
ARG MAVEN_VERSION=3.9.6
RUN wget -q https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

USER jenkins
```

**注意：** Alpine 版本可能与某些 Jenkins 插件不兼容，建议使用标准版。

---

## 九、总结

**完成后你将拥有：**
- ✅ 一个包含 JDK 21 和 Maven 的 Jenkins 镜像
- ✅ 镜像存储在腾讯云容器镜像服务
- ✅ Kubernetes 可以拉取并使用该镜像
- ✅ Jenkins 可以直接构建 Java 项目

**下一步：**
- 配置 Jenkins Pipeline 构建 Java 项目
- 添加 Docker 支持以构建应用镜像
- 配置自动部署到 Kubernetes

需要我帮你创建具体的文件或执行某个步骤吗？
