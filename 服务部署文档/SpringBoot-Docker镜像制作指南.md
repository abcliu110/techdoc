# Spring Boot Docker 镜像制作指南

## 一、基础版 Dockerfile

### 1.1 最简单的 Dockerfile

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

**构建和运行：**
```bash
# 1. Maven 构建
mvn clean package -DskipTests

# 2. 构建镜像
docker build -t myapp:1.0 .

# 3. 运行容器
docker run -p 8080:8080 myapp:1.0
```

---

## 二、优化版 Dockerfile

### 2.1 添加 JVM 参数优化

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY target/*.jar app.jar

# JVM 参数优化
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**常用 JVM 参数：**
- `-Xmx512m`：最大堆内存 512MB
- `-Xms256m`：初始堆内存 256MB
- `-XX:+UseG1GC`：使用 G1 垃圾回收器
- `-XX:MaxGCPauseMillis=200`：最大 GC 停顿时间 200ms

---

### 2.2 添加时区和健康检查

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

# 安装 curl（用于健康检查）
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY target/*.jar app.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# JVM 参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"

EXPOSE 8080

# 健康检查（需要 Spring Boot Actuator）
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

---

## 三、多阶段构建（推荐）

### 3.1 完整的多阶段构建

```dockerfile
# ============ 阶段1：构建阶段 ============
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

# 先复制 pom.xml，利用 Docker 缓存
COPY pom.xml .
RUN mvn dependency:go-offline

# 再复制源代码
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# ============ 阶段2：运行阶段 ============
FROM openjdk:21-jdk-slim

WORKDIR /app

# 安装 curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制 jar 文件
COPY --from=builder /build/target/*.jar app.jar

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# JVM 参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**优点：**
- 最终镜像不包含 Maven 和源代码
- 镜像体积更小（约 200MB vs 700MB）
- 更安全，不暴露源代码

**构建：**
```bash
# 直接构建，不需要先 mvn package
docker build -t myapp:1.0 .
```

---

## 四、Spring Boot 分层构建（最优）

### 4.1 使用 Spring Boot Layered Jars

Spring Boot 2.3+ 支持分层 jar，可以更好地利用 Docker 缓存。

**第一步：配置 pom.xml**

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <layers>
                    <enabled>true</enabled>
                </layers>
            </configuration>
        </plugin>
    </plugins>
</build>
```

**第二步：创建 Dockerfile**

```dockerfile
# ============ 阶段1：构建阶段 ============
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# 解压分层 jar
RUN mkdir -p target/extracted && \
    java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# ============ 阶段2：运行阶段 ============
FROM openjdk:21-jdk-slim

WORKDIR /app

# 按层复制（利用 Docker 缓存）
COPY --from=builder /build/target/extracted/dependencies/ ./
COPY --from=builder /build/target/extracted/spring-boot-loader/ ./
COPY --from=builder /build/target/extracted/snapshot-dependencies/ ./
COPY --from=builder /build/target/extracted/application/ ./

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# JVM 参数
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
```

**优点：**
- 依赖层变化少，可以充分利用缓存
- 只有应用代码变化时才重新构建最后一层
- 构建速度更快

---

## 五、多模块项目的 Dockerfile

### 5.1 参数化 Dockerfile

```dockerfile
# 构建参数
ARG MODULE_NAME=nms4cloud-app
ARG JAR_VERSION=0.0.1-SNAPSHOT

# ============ 阶段1：构建阶段 ============
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

COPY pom.xml .
COPY ${MODULE_NAME}/pom.xml ./${MODULE_NAME}/

RUN mvn dependency:go-offline

COPY . .

# 只构建指定模块
RUN mvn clean package -pl ${MODULE_NAME} -am -DskipTests

# ============ 阶段2：运行阶段 ============
FROM openjdk:21-jdk-slim

WORKDIR /app

ARG MODULE_NAME
ARG JAR_VERSION

# 复制指定模块的 jar
COPY --from=builder /build/${MODULE_NAME}/target/${MODULE_NAME}-${JAR_VERSION}.jar app.jar

ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**构建不同模块：**
```bash
# 构建 nms4cloud-app
docker build -t nms4cloud-app:1.0 \
  --build-arg MODULE_NAME=nms4cloud-app \
  --build-arg JAR_VERSION=0.0.1-SNAPSHOT \
  .

# 构建 nms4cloud-gateway
docker build -t nms4cloud-gateway:1.0 \
  --build-arg MODULE_NAME=nms4cloud-gateway \
  --build-arg JAR_VERSION=0.0.1-SNAPSHOT \
  .
```

---

## 六、生产环境最佳实践

### 6.1 完整的生产级 Dockerfile

```dockerfile
# ============ 阶段1：构建阶段 ============
FROM maven:3.9.6-openjdk-21 AS builder

WORKDIR /build

# 复制依赖配置
COPY pom.xml .
COPY */pom.xml ./

# 下载依赖（利用缓存）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY . .

# 构建项目
RUN mvn clean package -DskipTests -B

# ============ 阶段2：运行阶段 ============
FROM openjdk:21-jdk-slim

# 创建非 root 用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# 安装必要工具
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# 复制 jar 文件
COPY --from=builder /build/target/*.jar app.jar

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

EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**特点：**
- 使用非 root 用户运行（安全）
- 配置 OOM 时自动生成堆转储
- 设置时区和编码
- 创建日志目录

---

## 七、Jenkins Pipeline 集成

### 7.1 完整的 Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        // Maven 配置
        MAVEN_HOME = tool 'Maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // Docker 镜像配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'myproject'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('代码检出') {
            steps {
                git(
                    url: 'https://github.com/your-repo/myapp.git',
                    branch: 'main',
                    credentialsId: 'git-credentials'
                )
            }
        }

        stage('Maven 构建') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('构建 Docker 镜像') {
            steps {
                script {
                    def fullImageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"

                    sh """
                        docker build -t ${fullImageName}:${IMAGE_TAG} \
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
                            docker push ${fullImageName}:${IMAGE_TAG}
                            docker push ${fullImageName}:latest
                        """
                    }
                }
            }
        }

        stage('清理本地镜像') {
            steps {
                script {
                    def fullImageName = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}"
                    sh """
                        docker rmi ${fullImageName}:${IMAGE_TAG} || true
                        docker rmi ${fullImageName}:latest || true
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ 镜像构建成功: ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ 镜像构建失败"
        }
    }
}
```

---

## 八、常用命令

### 8.1 构建镜像

```bash
# 基本构建
docker build -t myapp:1.0 .

# 指定 Dockerfile
docker build -t myapp:1.0 -f Dockerfile.prod .

# 传递构建参数
docker build -t myapp:1.0 --build-arg MODULE_NAME=myapp .

# 不使用缓存
docker build -t myapp:1.0 --no-cache .
```

### 8.2 运行容器

```bash
# 基本运行
docker run -p 8080:8080 myapp:1.0

# 后台运行
docker run -d -p 8080:8080 --name myapp myapp:1.0

# 传递环境变量
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xmx1024m" \
  myapp:1.0

# 挂载配置文件
docker run -p 8080:8080 \
  -v /path/to/application.yml:/app/config/application.yml \
  myapp:1.0

# 挂载日志目录
docker run -p 8080:8080 \
  -v /path/to/logs:/app/logs \
  myapp:1.0
```

### 8.3 查看和调试

```bash
# 查看镜像
docker images | grep myapp

# 查看容器日志
docker logs -f myapp

# 进入容器
docker exec -it myapp bash

# 查看容器资源使用
docker stats myapp

# 查看容器详情
docker inspect myapp
```

### 8.4 推送镜像

```bash
# 登录镜像仓库
docker login ccr.ccs.tencentyun.com -u username -p password

# 打标签
docker tag myapp:1.0 ccr.ccs.tencentyun.com/myproject/myapp:1.0

# 推送镜像
docker push ccr.ccs.tencentyun.com/myproject/myapp:1.0
```

---

## 九、常见问题

### 9.1 镜像太大

**问题：** 镜像体积超过 500MB

**解决方案：**
1. 使用 `openjdk:21-jdk-slim` 而不是 `openjdk:21-jdk`
2. 使用多阶段构建
3. 清理 apt 缓存：`rm -rf /var/lib/apt/lists/*`
4. 使用 Spring Boot 分层构建

### 9.2 构建速度慢

**问题：** 每次构建都很慢

**解决方案：**
1. 利用 Docker 缓存，先复制 pom.xml
2. 使用 Maven 本地仓库缓存
3. 使用 Spring Boot 分层构建

### 9.3 时区不正确

**问题：** 容器内时间不对

**解决方案：**
```dockerfile
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
```

### 9.4 中文乱码

**问题：** 日志中文显示乱码

**解决方案：**
```dockerfile
ENV JAVA_OPTS="-Dfile.encoding=UTF-8"
```

---

## 十、总结

### 10.1 推荐方案

**开发环境：** 使用基础版 Dockerfile（快速构建）

**生产环境：** 使用多阶段构建 + 分层 jar（最优性能）

### 10.2 最佳实践

1. ✅ 使用多阶段构建减小镜像体积
2. ✅ 使用 Spring Boot 分层 jar 提高构建速度
3. ✅ 配置健康检查
4. ✅ 使用非 root 用户运行
5. ✅ 设置合理的 JVM 参数
6. ✅ 配置时区和编码
7. ✅ 添加日志目录挂载

### 10.3 快速开始

```bash
# 1. 创建 Dockerfile（使用上面的多阶段构建模板）

# 2. 构建镜像
docker build -t myapp:1.0 .

# 3. 运行容器
docker run -d -p 8080:8080 --name myapp myapp:1.0

# 4. 查看日志
docker logs -f myapp
```
