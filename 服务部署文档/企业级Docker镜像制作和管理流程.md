# 企业级 Docker 镜像制作和管理流程

## 一、整体流程概览

```
开发提交代码 → Git 仓库 → 触发 CI/CD → Maven 构建 → Docker 镜像构建 → 推送到镜像仓库 → 部署到 K8s
```

---

## 二、项目结构分析（nms4cloud）

### 2.1 项目架构

```
nms4cloud/
├── nms4cloud-starter/          # 公共组件（不需要构建镜像）
│   ├── nms4cloud-starter-cloud
│   ├── nms4cloud-starter-redis
│   └── ...
└── nms4cloud-app/              # 应用模块（需要构建镜像）
    ├── 1_platform/             # 平台服务
    │   ├── nms4cloud-platform
    │   ├── nms4cloud-mq
    │   ├── nms4cloud-netty
    │   └── ...
    ├── 2_business/             # 业务服务
    └── 3_customer/             # 客户服务
```

### 2.2 需要构建镜像的服务

根据你的项目结构，需要为以下服务构建 Docker 镜像：
- nms4cloud-platform（平台服务）
- nms4cloud-mq（消息队列服务）
- nms4cloud-netty（Netty 服务）
- nms4cloud-reg（注册服务）
- nms4cloud-wechat（微信服务）
- 其他业务服务...

---

## 三、企业级镜像制作方案

### 3.1 方案一：统一 Dockerfile（推荐）

在项目根目录创建一个通用的 Dockerfile，通过构建参数指定不同的模块。

**创建 `Dockerfile`：**

```dockerfile
# ============ 阶段1：构建阶段 ============
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

# 复制 Maven 配置
COPY settings.xml /root/.m2/settings.xml
COPY pom.xml .
COPY nms4cloud-starter/pom.xml ./nms4cloud-starter/
COPY nms4cloud-app/pom.xml ./nms4cloud-app/

# 下载依赖（利用 Docker 缓存）
RUN mvn dependency:go-offline -B || true

# 复制所有源代码
COPY . .

# 构建参数：指定要构建的模块
ARG MODULE_PATH
ARG MODULE_NAME

# 构建指定模块
RUN mvn clean package -pl ${MODULE_PATH} -am -DskipTests -B

# ============ 阶段2：运行阶段 ============
FROM openjdk:21-jdk-slim

# 创建非 root 用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# 安装必要工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# 构建参数
ARG MODULE_PATH
ARG MODULE_NAME

# 从构建阶段复制 jar 文件
COPY --from=builder /build/${MODULE_PATH}/target/*.jar app.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# JVM 参数（生产环境）
ENV JAVA_OPTS="-Xmx1024m -Xms512m \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/app/logs/heapdump.hprof \
    -Dfile.encoding=UTF-8 \
    -Duser.timezone=Asia/Shanghai"

# 创建日志目录
RUN mkdir -p /app/logs && chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 声明端口（根据实际情况调整）
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**构建不同服务的镜像：**

```bash
# 构建 platform 服务
docker build -t nms4cloud-platform:1.0 \
  --build-arg MODULE_PATH=nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app \
  --build-arg MODULE_NAME=nms4cloud-platform-app \
  .

# 构建 mq 服务
docker build -t nms4cloud-mq:1.0 \
  --build-arg MODULE_PATH=nms4cloud-app/1_platform/nms4cloud-mq/nms4cloud-mq-app \
  --build-arg MODULE_NAME=nms4cloud-mq-app \
  .
```

---

### 3.2 方案二：为每个服务创建独立 Dockerfile

在每个服务的 app 目录下创建 Dockerfile。

**示例：`nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app/Dockerfile`**

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

# 复制 jar 文件（相对于项目根目录）
COPY target/*.jar app.jar

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV JAVA_OPTS="-Xmx1024m -Xms512m -XX:+UseG1GC"

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**构建：**

```bash
# 先在项目根目录构建
cd E:\nms4cloud
mvn clean package -DskipTests

# 然后构建镜像
cd nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app
docker build -t nms4cloud-platform:1.0 .
```

---

## 四、企业级镜像仓库管理

### 4.1 常用企业镜像仓库

#### 1. 腾讯云容器镜像服务（CCR）

**特点：**
- 与腾讯云 TKE 深度集成
- 支持镜像安全扫描
- 按流量计费

**镜像命名规范：**
```
ccr.ccs.tencentyun.com/[命名空间]/[镜像名]:[标签]
```

**示例：**
```
ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0.0
ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:latest
```

#### 2. 阿里云容器镜像服务（ACR）

**镜像命名规范：**
```
registry.cn-hangzhou.aliyuncs.com/[命名空间]/[镜像名]:[标签]
```

**示例：**
```
registry.cn-hangzhou.aliyuncs.com/nms4cloud/nms4cloud-platform:1.0.0
```

#### 3. Harbor（私有镜像仓库）

**特点：**
- 开源、可自建
- 支持镜像复制、安全扫描
- 适合大型企业

**镜像命名规范：**
```
harbor.company.com/[项目名]/[镜像名]:[标签]
```

---

### 4.2 镜像版本管理策略

#### 企业常用标签策略

```bash
# 1. 使用 Git commit SHA（推荐）
nms4cloud-platform:a1b2c3d

# 2. 使用语义化版本
nms4cloud-platform:1.0.0
nms4cloud-platform:1.0.1

# 3. 使用构建号
nms4cloud-platform:build-123

# 4. 使用日期时间
nms4cloud-platform:20260212-1430

# 5. 使用环境标签
nms4cloud-platform:dev
nms4cloud-platform:test
nms4cloud-platform:prod

# 6. 组合使用（最佳实践）
nms4cloud-platform:1.0.0-a1b2c3d
nms4cloud-platform:1.0.0-build-123
```

#### 推荐的标签策略

```bash
# 每次构建打三个标签
docker tag nms4cloud-platform:temp ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0.0
docker tag nms4cloud-platform:temp ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:latest
docker tag nms4cloud-platform:temp ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:${GIT_COMMIT}
```

---

## 五、Jenkins 自动化构建流程（企业标准）

### 5.1 完整的 Jenkinsfile

**创建 `Jenkinsfile`：**

```groovy
pipeline {
    agent any

    environment {
        // Maven 配置
        MAVEN_HOME = tool 'Maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // Docker 镜像仓库配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'nms4cloud'

        // Git 信息
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        BUILD_TIME = sh(script: "date +%Y%m%d-%H%M%S", returnStdout: true).trim()

        // 版本号
        VERSION = "1.0.0"
    }

    parameters {
        choice(
            name: 'SERVICE_NAME',
            choices: [
                'nms4cloud-platform',
                'nms4cloud-mq',
                'nms4cloud-netty',
                'nms4cloud-reg',
                'nms4cloud-wechat'
            ],
            description: '选择要构建的服务'
        )
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'test', 'prod'],
            description: '选择部署环境'
        )
    }

    stages {
        stage('代码检出') {
            steps {
                echo "=== 代码检出 ==="
                git(
                    url: 'https://codeup.aliyun.com/your-repo/nms4cloud.git',
                    branch: 'main',
                    credentialsId: 'git-credentials'
                )

                echo "Git Commit: ${GIT_COMMIT_SHORT}"
                echo "Build Time: ${BUILD_TIME}"
            }
        }

        stage('Maven 构建') {
            steps {
                echo "=== Maven 构建 ==="
                script {
                    // 根据服务名确定模块路径
                    def modulePath = getModulePath(params.SERVICE_NAME)

                    sh """
                        mvn clean package -pl ${modulePath} -am -DskipTests -B
                    """
                }
            }
        }

        stage('构建 Docker 镜像') {
            steps {
                echo "=== 构建 Docker 镜像 ==="
                script {
                    def modulePath = getModulePath(params.SERVICE_NAME)
                    def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}"

                    // 构建镜像
                    sh """
                        docker build -t ${imageName}:${VERSION} \
                            -t ${imageName}:${VERSION}-${GIT_COMMIT_SHORT} \
                            -t ${imageName}:${params.ENVIRONMENT} \
                            -t ${imageName}:latest \
                            --build-arg MODULE_PATH=${modulePath} \
                            --build-arg MODULE_NAME=${params.SERVICE_NAME}-app \
                            -f Dockerfile .
                    """

                    echo "镜像构建成功："
                    sh "docker images | grep ${params.SERVICE_NAME}"
                }
            }
        }

        stage('镜像安全扫描') {
            steps {
                echo "=== 镜像安全扫描 ==="
                script {
                    // 使用 Trivy 进行安全扫描
                    def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}:${VERSION}"

                    sh """
                        trivy image --severity HIGH,CRITICAL ${imageName} || true
                    """
                }
            }
        }

        stage('推送到镜像仓库') {
            steps {
                echo "=== 推送到镜像仓库 ==="
                script {
                    def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}"

                    withCredentials([usernamePassword(
                        credentialsId: 'tencent-ccr-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            # 登录镜像仓库
                            echo \${DOCKER_PASS} | docker login ${DOCKER_REGISTRY} -u \${DOCKER_USER} --password-stdin

                            # 推送所有标签
                            docker push ${imageName}:${VERSION}
                            docker push ${imageName}:${VERSION}-${GIT_COMMIT_SHORT}
                            docker push ${imageName}:${params.ENVIRONMENT}
                            docker push ${imageName}:latest

                            echo "镜像推送成功："
                            echo "${imageName}:${VERSION}"
                            echo "${imageName}:${VERSION}-${GIT_COMMIT_SHORT}"
                            echo "${imageName}:${params.ENVIRONMENT}"
                        """
                    }
                }
            }
        }

        stage('清理本地镜像') {
            steps {
                echo "=== 清理本地镜像 ==="
                script {
                    def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}"

                    sh """
                        docker rmi ${imageName}:${VERSION} || true
                        docker rmi ${imageName}:${VERSION}-${GIT_COMMIT_SHORT} || true
                        docker rmi ${imageName}:${params.ENVIRONMENT} || true
                        docker rmi ${imageName}:latest || true
                    """
                }
            }
        }

        stage('更新 K8s 部署') {
            when {
                expression { params.ENVIRONMENT != 'prod' }
            }
            steps {
                echo "=== 更新 K8s 部署 ==="
                script {
                    def imageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}:${VERSION}"

                    sh """
                        kubectl set image deployment/${params.SERVICE_NAME} \
                            ${params.SERVICE_NAME}=${imageName} \
                            -n ${params.ENVIRONMENT}

                        kubectl rollout status deployment/${params.SERVICE_NAME} -n ${params.ENVIRONMENT}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ 构建成功"
            echo "镜像地址: ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${params.SERVICE_NAME}:${VERSION}"
        }
        failure {
            echo "❌ 构建失败"
        }
        always {
            // 清理工作空间
            cleanWs()
        }
    }
}

// 辅助函数：根据服务名获取模块路径
def getModulePath(serviceName) {
    def moduleMap = [
        'nms4cloud-platform': 'nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app',
        'nms4cloud-mq': 'nms4cloud-app/1_platform/nms4cloud-mq/nms4cloud-mq-app',
        'nms4cloud-netty': 'nms4cloud-app/1_platform/nms4cloud-netty/nms4cloud-netty-app',
        'nms4cloud-reg': 'nms4cloud-app/1_platform/nms4cloud-reg/nms4cloud-reg-app',
        'nms4cloud-wechat': 'nms4cloud-app/1_platform/nms4cloud-wechat/nms4cloud-wechat-app'
    ]

    return moduleMap[serviceName] ?: serviceName
}
```

---

### 5.2 Jenkins 配置步骤

#### 1. 创建 Jenkins Pipeline 任务

```
Jenkins 首页 → 新建任务 → 输入任务名称 → 选择 Pipeline → 确定
```

#### 2. 配置 Pipeline

```
Pipeline 配置：
- Definition: Pipeline script from SCM
- SCM: Git
- Repository URL: https://codeup.aliyun.com/your-repo/nms4cloud.git
- Credentials: 选择 Git 凭据
- Branch: */main
- Script Path: Jenkinsfile
```

#### 3. 配置凭据

**Git 凭据：**
```
Jenkins → 凭据 → 系统 → 全局凭据 → 添加凭据
- 类型: Username with password
- ID: git-credentials
- 用户名: your-username
- 密码: your-token
```

**Docker 镜像仓库凭据：**
```
Jenkins → 凭据 → 系统 → 全局凭据 → 添加凭据
- 类型: Username with password
- ID: tencent-ccr-credentials
- 用户名: 腾讯云账号 ID
- 密码: 腾讯云密钥
```

---

## 六、GitLab CI/CD 方案（替代方案）

### 6.1 创建 `.gitlab-ci.yml`

```yaml
stages:
  - build
  - docker
  - deploy

variables:
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"
  DOCKER_REGISTRY: "ccr.ccs.tencentyun.com"
  DOCKER_NAMESPACE: "nms4cloud"
  VERSION: "1.0.0"

# Maven 构建
build:
  stage: build
  image: maven:3.9.6-openjdk-21
  script:
    - mvn clean package -DskipTests -B
  artifacts:
    paths:
      - "**/target/*.jar"
    expire_in: 1 hour
  cache:
    paths:
      - .m2/repository
  only:
    - main
    - develop

# 构建 Docker 镜像
docker:platform:
  stage: docker
  image: docker:latest
  services:
    - docker:dind
  variables:
    SERVICE_NAME: "nms4cloud-platform"
    MODULE_PATH: "nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app"
  script:
    - docker login -u $DOCKER_USER -p $DOCKER_PASS $DOCKER_REGISTRY
    - |
      docker build -t $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$SERVICE_NAME:$VERSION \
        -t $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$SERVICE_NAME:latest \
        --build-arg MODULE_PATH=$MODULE_PATH \
        --build-arg MODULE_NAME=$SERVICE_NAME-app \
        -f Dockerfile .
    - docker push $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$SERVICE_NAME:$VERSION
    - docker push $DOCKER_REGISTRY/$DOCKER_NAMESPACE/$SERVICE_NAME:latest
  only:
    - main

# 部署到 K8s
deploy:dev:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/nms4cloud-platform nms4cloud-platform=$DOCKER_REGISTRY/$DOCKER_NAMESPACE/nms4cloud-platform:$VERSION -n dev
    - kubectl rollout status deployment/nms4cloud-platform -n dev
  only:
    - develop
```

---

## 七、镜像仓库操作指南

### 7.1 腾讯云 CCR 操作

#### 1. 登录镜像仓库

```bash
docker login ccr.ccs.tencentyun.com -u [账号ID] -p [密钥]
```

#### 2. 推送镜像

```bash
# 打标签
docker tag nms4cloud-platform:1.0 ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0

# 推送
docker push ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
```

#### 3. 拉取镜像

```bash
docker pull ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
```

---

### 7.2 配置 K8s 拉取私有镜像

#### 1. 创建 Secret

```bash
kubectl create secret docker-registry tencent-ccr-secret \
  --docker-server=ccr.ccs.tencentyun.com \
  --docker-username=[账号ID] \
  --docker-password=[密钥] \
  --docker-email=[邮箱] \
  -n default
```

#### 2. 在 Deployment 中使用

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-platform
spec:
  template:
    spec:
      imagePullSecrets:
      - name: tencent-ccr-secret
      containers:
      - name: nms4cloud-platform
        image: ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
```

---

## 八、完整操作流程示例

### 8.1 手动构建和推送（开发测试）

```bash
# 1. 进入项目目录
cd E:\nms4cloud

# 2. Maven 构建
mvn clean package -DskipTests

# 3. 构建 Docker 镜像
docker build -t nms4cloud-platform:1.0 \
  --build-arg MODULE_PATH=nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app \
  --build-arg MODULE_NAME=nms4cloud-platform-app \
  -f Dockerfile .

# 4. 打标签
docker tag nms4cloud-platform:1.0 ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
docker tag nms4cloud-platform:1.0 ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:latest

# 5. 登录镜像仓库
docker login ccr.ccs.tencentyun.com -u [账号ID] -p [密钥]

# 6. 推送镜像
docker push ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
docker push ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:latest

# 7. 验证
docker pull ccr.ccs.tencentyun.com/nms4cloud/nms4cloud-platform:1.0
```

---

### 8.2 Jenkins 自动化构建（生产环境）

```
1. 开发提交代码到 Git
   ↓
2. Jenkins 自动触发构建（Webhook）
   ↓
3. Jenkins 执行 Jenkinsfile
   - 代码检出
   - Maven 构建
   - Docker 镜像构建
   - 镜像安全扫描
   - 推送到镜像仓库
   - 更新 K8s 部署
   ↓
4. 自动部署到测试环境
   ↓
5. 人工审批后部署到生产环境
```

---

## 九、最佳实践总结

### 9.1 镜像构建

1. ✅ 使用多阶段构建减小镜像体积
2. ✅ 使用非 root 用户运行容器
3. ✅ 配置健康检查
4. ✅ 设置合理的 JVM 参数
5. ✅ 配置时区和编码

### 9.2 版本管理

1. ✅ 使用语义化版本号（1.0.0）
2. ✅ 每次构建打多个标签（版本号、latest、Git commit）
3. ✅ 不同环境使用不同标签（dev、test、prod）
4. ✅ 生产环境使用固定版本号，不使用 latest

### 9.3 安全管理

1. ✅ 镜像仓库使用私有仓库
2. ✅ 使用 Secret 管理镜像仓库凭据
3. ✅ 定期进行镜像安全扫描
4. ✅ 及时更新基础镜像

### 9.4 CI/CD 流程

1. ✅ 使用 Jenkins/GitLab CI 自动化构建
2. ✅ 代码提交自动触发构建
3. ✅ 测试环境自动部署
4. ✅ 生产环境人工审批

---

## 十、快速开始

### 10.1 第一次构建

```bash
# 1. 在项目根目录创建 Dockerfile（使用上面的模板）

# 2. 创建 Jenkinsfile（使用上面的模板）

# 3. 在 Jenkins 中创建 Pipeline 任务

# 4. 配置 Git 和 Docker 凭据

# 5. 运行构建

# 6. 查看镜像仓库中的镜像
```

### 10.2 日常开发流程

```bash
# 1. 开发代码
# 2. 提交到 Git
# 3. Jenkins 自动构建和推送镜像
# 4. 自动部署到测试环境
# 5. 测试通过后，手动触发生产环境部署
```
