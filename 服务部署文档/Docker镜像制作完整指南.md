# Docker 镜像制作完整指南（从零开始）

## 概述

本文档从零开始，详细讲解如何为 Java 项目制作 Dockerfile 并构建 Docker 镜像。

**适合人群：** 不熟悉 Docker 的开发者

---

## 一、基础概念

### 1.1 什么是 Docker？

**Docker** 是一个容器化平台，用于：
- 打包应用程序及其依赖
- 在任何环境中运行应用
- 确保"在我机器上能运行，在你机器上也能运行"

**类比：** Docker 就像一个集装箱，把应用和所有需要的东西打包在一起，可以在任何地方运行。

### 1.2 什么是 Docker 镜像？

**Docker 镜像** 是一个只读的模板，包含：
- 操作系统（如 Ubuntu、Alpine）
- 运行环境（如 JDK、Node.js）
- 应用程序（如你的 jar 文件）
- 配置文件

**类比：** 镜像就像一个"快照"或"模板"，可以用它创建多个容器。

### 1.3 什么是 Dockerfile？

**Dockerfile** 是一个文本文件，包含构建镜像的指令。

**类比：** Dockerfile 就像一个菜谱，告诉 Docker 如何一步步制作镜像。

### 1.4 镜像 vs 容器

```
镜像（Image）          容器（Container）
    ↓                      ↓
  模板/快照              运行中的实例
    ↓                      ↓
  只读                   可读写
    ↓                      ↓
  类比：程序文件         类比：运行中的进程
```

---

## 二、Dockerfile 基础语法

### 2.1 基本指令

#### FROM - 指定基础镜像

```dockerfile
FROM openjdk:21-jdk-slim
```

**作用：** 指定基础镜像（在哪个镜像的基础上构建）

**常用基础镜像：**
- `openjdk:21-jdk-slim`：Java 21 运行环境（精简版）
- `openjdk:17-jdk-slim`：Java 17 运行环境
- `ubuntu:22.04`：Ubuntu 操作系统
- `alpine:3.18`：Alpine Linux（最小化）

**类比：** 就像盖房子，先选择地基。

---

#### WORKDIR - 设置工作目录

```dockerfile
WORKDIR /app
```

**作用：** 设置容器内的工作目录

**效果：**
- 后续的命令都在这个目录中执行
- 类似于 `cd /app`

---

#### COPY - 复制文件

```dockerfile
COPY target/myapp.jar /app/app.jar
```

**作用：** 从本地复制文件到镜像中

**语法：** `COPY <源路径> <目标路径>`

**示例：**
```dockerfile
COPY target/*.jar /app/
COPY config/ /app/config/
```

---

#### ADD - 复制文件（增强版）

```dockerfile
ADD target/myapp.jar /app/app.jar
```

**作用：** 类似 COPY，但支持：
- 自动解压 tar 文件
- 从 URL 下载文件

**推荐：** 一般情况使用 COPY，更明确

---

#### RUN - 执行命令

```dockerfile
RUN apt-get update && apt-get install -y curl
```

**作用：** 在构建镜像时执行命令

**使用场景：**
- 安装软件包
- 创建目录
- 下载文件

**注意：** 每个 RUN 会创建一层镜像层

---

#### ENV - 设置环境变量

```dockerfile
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV APP_PORT=8080
```

**作用：** 设置环境变量

**使用：** 在容器运行时可以访问这些变量

---

#### EXPOSE - 声明端口

```dockerfile
EXPOSE 8080
```

**作用：** 声明容器监听的端口

**注意：** 这只是声明，不会自动映射端口

---

#### CMD - 容器启动命令

```dockerfile
CMD ["java", "-jar", "/app/app.jar"]
```

**作用：** 容器启动时执行的命令

**语法：**
- JSON 数组格式：`["命令", "参数1", "参数2"]`
- Shell 格式：`java -jar /app/app.jar`

**注意：** 一个 Dockerfile 只能有一个 CMD

---

#### ENTRYPOINT - 入口点

```dockerfile
ENTRYPOINT ["java", "-jar"]
CMD ["/app/app.jar"]
```

**作用：** 设置容器的入口点

**与 CMD 的区别：**
- ENTRYPOINT：固定的命令
- CMD：可以被覆盖的参数

---

## 三、为 Java 项目制作 Dockerfile

### 3.1 简单版本（单模块项目）

```dockerfile
# 使用 OpenJDK 21 作为基础镜像
FROM openjdk:21-jdk-slim

# 设置工作目录
WORKDIR /app

# 复制 jar 文件到容器
COPY target/myapp-0.0.1-SNAPSHOT.jar /app/app.jar

# 声明端口
EXPOSE 8080

# 启动命令
CMD ["java", "-jar", "/app/app.jar"]
```

**使用：**
```bash
# 1. 先用 Maven 构建项目
mvn clean package

# 2. 构建 Docker 镜像
docker build -t myapp:latest .

# 3. 运行容器
docker run -p 8080:8080 myapp:latest
```

---

### 3.2 优化版本（添加 JVM 参数）

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

# 复制 jar 文件
COPY target/myapp-0.0.1-SNAPSHOT.jar /app/app.jar

# 设置 JVM 参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"

# 声明端口
EXPOSE 8080

# 启动命令（使用环境变量）
CMD java $JAVA_OPTS -jar /app/app.jar
```

---

### 3.3 生产版本（多阶段构建）

```dockerfile
# 阶段1：构建阶段
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

# 复制 pom.xml 和源代码
COPY pom.xml .
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# 阶段2：运行阶段
FROM openjdk:21-jdk-slim

WORKDIR /app

# 从构建阶段复制 jar 文件
COPY --from=builder /build/target/myapp-0.0.1-SNAPSHOT.jar /app/app.jar

# 设置 JVM 参数
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 声明端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
CMD java $JAVA_OPTS -jar /app/app.jar
```

**优点：**
- 最终镜像更小（不包含 Maven 和源代码）
- 更安全（不暴露源代码）
- 更适合生产环境

---

### 3.4 nms4cloud 项目的 Dockerfile

#### 为 nms4cloud-app 制作 Dockerfile

```dockerfile
# 使用 OpenJDK 21 精简版
FROM openjdk:21-jdk-slim

# 维护者信息
LABEL maintainer="your-email@example.com"
LABEL description="nms4cloud-app application"

# 设置工作目录
WORKDIR /app

# 复制 jar 文件
# 注意：jar 文件路径根据实际情况调整
COPY nms4cloud-app/target/nms4cloud-app-0.0.1-SNAPSHOT.jar /app/app.jar

# 设置时区（可选）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置 JVM 参数
ENV JAVA_OPTS="-Xmx1024m -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 声明端口（根据实际应用端口）
EXPOSE 8080

# 健康检查（如果应用有健康检查接口）
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

---

## 四、构建 Docker 镜像

### 4.1 本地构建（在有 Docker 的机器上）

#### 基本命令

```bash
docker build -t myapp:latest .
```

**参数说明：**
- `build`：构建镜像
- `-t myapp:latest`：镜像名称和标签
  - `myapp`：镜像名称
  - `latest`：标签（版本）
- `.`：Dockerfile 所在目录（当前目录）

#### 指定 Dockerfile

```bash
docker build -t myapp:latest -f Dockerfile.app .
```

**参数：**
- `-f Dockerfile.app`：指定 Dockerfile 文件名

#### 构建时传递参数

```dockerfile
# Dockerfile
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /app/app.jar
```

```bash
# 构建时指定参数
docker build -t myapp:latest --build-arg JAR_FILE=target/myapp.jar .
```

---

### 4.2 在 Jenkins 中构建

#### 方式1：挂载宿主机 Docker

**前提：** Jenkins Pod 挂载了宿主机的 Docker

```groovy
stage('构建 Docker 镜像') {
    steps {
        script {
            echo "=== 构建 Docker 镜像 ==="

            def imageName = "myapp"
            def imageTag = "${env.BUILD_NUMBER}"

            sh """
                docker build -t ${imageName}:${imageTag} \
                    -t ${imageName}:latest \
                    -f Dockerfile .
            """
        }
    }
}
```

---

#### 方式2：使用 Docker-in-Docker

**前提：** Jenkins Pod 运行 Docker daemon

```groovy
stage('构建 Docker 镜像') {
    agent {
        docker {
            image 'docker:latest'
        }
    }
    steps {
        sh 'docker build -t myapp:latest .'
    }
}
```

---

### 4.3 推送镜像到仓库

#### 推送到腾讯云容器镜像仓库

```groovy
stage('推送 Docker 镜像') {
    steps {
        script {
            echo "=== 推送 Docker 镜像 ==="

            def imageName = "ccr.ccs.tencentyun.com/myproject/myapp"
            def imageTag = "${env.BUILD_NUMBER}"

            withCredentials([usernamePassword(
                credentialsId: 'tencent-ccr-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh """
                    # 登录腾讯云容器镜像仓库
                    echo \${DOCKER_PASS} | docker login ccr.ccs.tencentyun.com -u \${DOCKER_USER} --password-stdin

                    # 推送镜像
                    docker push ${imageName}:${imageTag}
                    docker push ${imageName}:latest
                """
            }
        }
    }
}
```

---

## 五、完整的 Jenkins Pipeline（包含 Docker 构建）

### 5.1 完整流程

```groovy
pipeline {
    agent any

    environment {
        MAVEN_HOME = tool 'Maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // Docker 镜像配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'myproject'
        IMAGE_NAME = 'nms4cloud-app'
    }

    stages {
        stage('代码检出') {
            steps {
                git(
                    url: 'https://codeup.aliyun.com/.../nms4cloud.git',
                    branch: 'master',
                    credentialsId: 'aliyun-codeup-token'
                )
            }
        }

        stage('Maven构建') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('构建 Docker 镜像') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"
                    def fullImageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"

                    sh """
                        docker build -t ${fullImageName}:${imageTag} \
                            -t ${fullImageName}:latest \
                            -f Dockerfile .
                    """
                }
            }
        }

        stage('推送 Docker 镜像') {
            steps {
                script {
                    def fullImageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"

                    withCredentials([usernamePassword(
                        credentialsId: 'tencent-ccr-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo \${DOCKER_PASS} | docker login ${DOCKER_REGISTRY} -u \${DOCKER_USER} --password-stdin
                            docker push ${fullImageName}:${env.BUILD_NUMBER}
                            docker push ${fullImageName}:latest
                        """
                    }
                }
            }
        }
    }
}
```

---

## 六、实际示例

### 6.1 为 nms4cloud-app 制作 Dockerfile

#### 创建 Dockerfile

在项目根目录创建 `Dockerfile`：

```dockerfile
# 使用 OpenJDK 21 精简版作为基础镜像
FROM openjdk:21-jdk-slim

# 维护者信息
LABEL maintainer="your-email@example.com"
LABEL description="nms4cloud-app application"
LABEL version="0.0.1-SNAPSHOT"

# 设置工作目录
WORKDIR /app

# 复制 jar 文件到容器
# 注意：路径根据实际情况调整
COPY nms4cloud-app/target/nms4cloud-app-0.0.1-SNAPSHOT.jar /app/app.jar

# 设置时区为中国时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 设置 JVM 参数
ENV JAVA_OPTS="-Xmx1024m -Xms512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dfile.encoding=UTF-8"

# 声明应用端口
EXPOSE 8080

# 健康检查（如果应用有健康检查接口）
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# 容器启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

---

### 6.2 构建镜像

#### 在本地构建

```bash
# 1. 先用 Maven 构建项目
mvn clean package -DskipTests

# 2. 构建 Docker 镜像
docker build -t nms4cloud-app:0.0.1 .

# 3. 查看镜像
docker images | grep nms4cloud-app
```

#### 在 Jenkins 中构建

在 Jenkinsfile 中添加：

```groovy
stage('构建 Docker 镜像') {
    steps {
        script {
            echo "=== 构建 Docker 镜像 ==="

            def imageName = "nms4cloud-app"
            def imageTag = "${env.BUILD_NUMBER}"

            sh """
                docker build -t ${imageName}:${imageTag} \
                    -t ${imageName}:latest \
                    -f Dockerfile .

                echo "镜像构建成功："
                docker images | grep ${imageName}
            """
        }
    }
}
```

---

### 6.3 运行容器测试

```bash
# 运行容器
docker run -d \
  --name nms4cloud-app \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xmx512m" \
  nms4cloud-app:latest

# 查看容器日志
docker logs -f nms4cloud-app

# 查看容器状态
docker ps | grep nms4cloud-app

# 进入容器
docker exec -it nms4cloud-app bash

# 停止容器
docker stop nms4cloud-app

# 删除容器
docker rm nms4cloud-app
```

---

## 七、多模块项目的 Dockerfile

### 7.1 为每个模块创建独立的 Dockerfile

#### nms4cloud-app 的 Dockerfile

```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY nms4cloud-app/target/nms4cloud-app-0.0.1-SNAPSHOT.jar /app/app.jar
ENV JAVA_OPTS="-Xmx1024m -Xms512m"
EXPOSE 8080
CMD java $JAVA_OPTS -jar /app/app.jar
```

#### nms4cloud-starter 的 Dockerfile

```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY nms4cloud-starter/target/nms4cloud-starter-0.0.1-SNAPSHOT.jar /app/app.jar
ENV JAVA_OPTS="-Xmx512m -Xms256m"
EXPOSE 8081
CMD java $JAVA_OPTS -jar /app/app.jar
```

---

### 7.2 使用参数化 Dockerfile

```dockerfile
# 使用构建参数
ARG MODULE_NAME=nms4cloud-app
ARG JAR_VERSION=0.0.1-SNAPSHOT

FROM openjdk:21-jdk-slim

WORKDIR /app

# 使用参数复制 jar 文件
COPY ${MODULE_NAME}/target/${MODULE_NAME}-${JAR_VERSION}.jar /app/app.jar

ENV JAVA_OPTS="-Xmx1024m -Xms512m"

EXPOSE 8080

CMD java $JAVA_OPTS -jar /app/app.jar
```

**构建时指定参数：**
```bash
docker build -t nms4cloud-app:latest \
  --build-arg MODULE_NAME=nms4cloud-app \
  --build-arg JAR_VERSION=0.0.1-SNAPSHOT \
  .
```

---

## 八、Docker 镜像优化

### 8.1 减小镜像大小

#### 使用精简版基础镜像

```dockerfile
# ❌ 不推荐：完整版（约 500MB）
FROM openjdk:21-jdk

# ✅ 推荐：精简版（约 200MB）
FROM openjdk:21-jdk-slim

# ✅ 更小：Alpine 版本（约 150MB）
FROM openjdk:21-jdk-alpine
```

#### 多阶段构建

```dockerfile
# 阶段1：构建（大镜像）
FROM maven:3.9.6-openjdk-21 AS builder
WORKDIR /build
COPY . .
RUN mvn clean package -DskipTests

# 阶段2：运行（小镜像）
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=builder /build/target/*.jar /app/app.jar
CMD ["java", "-jar", "/app/app.jar"]
```

**效果：**
- 构建阶段：使用完整的 Maven 镜像（约 700MB）
- 运行阶段：只使用 JDK 镜像（约 200MB）
- 最终镜像：只包含运行时需要的文件

---

### 8.2 利用缓存加速构建

#### 分层复制依赖

```dockerfile
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

# 先复制 pom.xml（依赖变化少，可以缓存）
COPY pom.xml .
RUN mvn dependency:go-offline

# 再复制源代码（变化频繁）
COPY src ./src
RUN mvn package -DskipTests
```

**优点：**
- 依赖不变时，使用缓存，不重新下载
- 只有代码变化时才重新编译

---

### 8.3 清理不必要的文件

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY target/myapp.jar /app/app.jar

# 清理 APT 缓存
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["java", "-jar", "/app/app.jar"]
```

---

