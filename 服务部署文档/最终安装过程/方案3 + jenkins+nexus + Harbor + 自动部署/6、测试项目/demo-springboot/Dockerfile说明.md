# Dockerfile 说明

## 当前 Dockerfile 设计

### 设计理念

**单阶段构建 - 直接使用已构建的 JAR**

```dockerfile
FROM openjdk:11-jre-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### 为什么这样设计？

在 Jenkins 流水线中：

```
Stage 1: Maven 构建 → 生成 target/*.jar
Stage 2: 构建镜像 → 使用 target/*.jar
```

**优点：**
- ✅ 避免重复构建（Maven 已经构建过）
- ✅ 构建速度快（只需复制 JAR）
- ✅ 镜像体积小（只包含 JRE）
- ✅ 构建过程清晰（Maven 和 Docker 分离）

**缺点：**
- ⚠️ 依赖 Jenkins 流水线先构建 JAR
- ⚠️ 不能单独使用 `docker build` 构建

## 对比：多阶段构建 vs 单阶段构建

### 多阶段构建（不推荐用于流水线）

```dockerfile
# 阶段 1: 构建
FROM maven:3.8.6-openjdk-11-slim AS builder
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# 阶段 2: 运行
FROM openjdk:11-jre-slim
COPY --from=builder /build/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**适用场景：**
- 本地开发（直接 `docker build`）
- 没有 CI/CD 流水线
- 需要自包含的构建过程

**问题：**
- ❌ 在流水线中会重复构建（Maven 构建 + Docker 构建）
- ❌ 构建时间长（需要下载依赖）
- ❌ 镜像构建慢

### 单阶段构建（推荐用于流水线）

```dockerfile
FROM openjdk:11-jre-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**适用场景：**
- Jenkins/GitLab CI 流水线
- 已经有 Maven 构建步骤
- 需要快速构建镜像

**优点：**
- ✅ 不重复构建
- ✅ 构建速度快
- ✅ 流程清晰

## 完整的 Dockerfile（当前版本）

```dockerfile
# 简化版 Dockerfile - 直接使用已构建的 JAR
# 适用于 Jenkins 流水线中已经完成 Maven 构建的场景

FROM openjdk:11-jre-slim

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 创建应用目录
WORKDIR /app

# 复制已构建的 jar 包（从 target 目录）
COPY target/*.jar app.jar

# 创建非 root 用户
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

## 流水线中的使用

### Jenkinsfile-k8s 中的流程

```groovy
stages {
    // Stage 1: Maven 构建
    stage('Maven 构建') {
        steps {
            container('maven') {
                sh 'mvn clean package -DskipTests'
                // 生成 target/demo-springboot.jar
            }
        }
    }
    
    // Stage 2: 构建镜像
    stage('构建 Docker 镜像') {
        steps {
            container('kaniko') {
                sh '''
                    /kaniko/executor \
                        --context=${PWD} \
                        --dockerfile=Dockerfile \
                        --destination=192.168.80.100:30500/demo-springboot:${BUILD_NUMBER}
                '''
                // Dockerfile 中 COPY target/*.jar 会使用上一步生成的 JAR
            }
        }
    }
}
```

### 关键点

1. **Maven 构建在前**
   ```groovy
   sh 'mvn clean package'
   // 生成 target/demo-springboot.jar
   ```

2. **Dockerfile 使用 JAR**
   ```dockerfile
   COPY target/*.jar app.jar
   ```

3. **Kaniko 构建镜像**
   ```bash
   /kaniko/executor --context=${PWD} --dockerfile=Dockerfile
   ```

## 本地测试

如果需要在本地测试，先手动构建 JAR：

```bash
# 1. Maven 构建
mvn clean package -DskipTests

# 2. 验证 JAR 存在
ls -lh target/*.jar

# 3. 构建镜像
docker build -t demo-springboot:local .

# 4. 运行容器
docker run -d -p 8080:8080 demo-springboot:local

# 5. 测试
curl http://localhost:8080/api/hello
```

## 其他 Dockerfile 变体

### 最小化版本

```dockerfile
FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### 带健康检查版本

```dockerfile
FROM openjdk:11-jre-slim

# 安装 curl（用于健康检查）
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY target/*.jar app.jar

EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### 使用 Alpine 版本（更小）

```dockerfile
FROM openjdk:11-jre-alpine

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

WORKDIR /app
COPY target/*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

## 总结

**当前 Dockerfile 的设计原则：**

1. ✅ **单一职责** - Dockerfile 只负责打包运行环境
2. ✅ **避免重复** - 不在 Docker 中重复 Maven 构建
3. ✅ **快速构建** - 只复制 JAR，不编译代码
4. ✅ **适合流水线** - 与 Jenkins 流水线完美配合

**这是在 CI/CD 流水线中使用 Docker 的最佳实践！**
