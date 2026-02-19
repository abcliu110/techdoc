# 优化 Docker 镜像大小指南

## 当前镜像大小分析

### 基础镜像对比

| 基础镜像 | 大小 | 说明 |
|---------|------|------|
| `eclipse-temurin:21-jre` | ~400MB | 完整 JRE，基于 Ubuntu |
| `eclipse-temurin:21-jre-alpine` | ~180MB | Alpine 版本（当前使用） |
| `amazoncorretto:21-alpine` | ~170MB | Amazon Corretto Alpine |
| `openjdk:21-jre-slim` | ~220MB | Debian slim 版本 |
| `gcr.io/distroless/java21` | ~150MB | Google Distroless（最小） |

### 你的镜像组成

```
总大小 = 基础镜像 + JAR 包 + 依赖层
       = 180MB + JAR大小 + 其他层
```

## 优化方案

### 方案 1：使用 Distroless 镜像（推荐，最小）

Distroless 镜像只包含应用和运行时依赖，没有包管理器、shell 等。

```dockerfile
# 使用 Google Distroless Java 21 镜像（最小化）
FROM gcr.io/distroless/java21-debian12

# 设置工作目录
WORKDIR /app

# 复制已构建的 jar 包
COPY target/*.jar app.jar

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_TOOL_OPTIONS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令（Distroless 没有 shell，直接使用 java）
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**优点**：
- 镜像最小（约 150-200MB）
- 安全性最高（攻击面最小）
- 启动速度快

**缺点**：
- 没有 shell，调试困难
- 不能使用 `docker exec` 进入容器

**适用场景**：生产环境

---

### 方案 2：继续使用 Alpine + 优化层（推荐，平衡）

```dockerfile
# 使用 Alpine 版本（体积小）
FROM eclipse-temurin:21-jre-alpine

# 一次性安装所有依赖，减少层数
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    addgroup -S appuser && \
    adduser -S appuser -G appuser

# 设置工作目录
WORKDIR /app

# 复制 jar 包
COPY target/*.jar app.jar

# 修改权限
RUN chown appuser:appuser /app/app.jar

# 切换用户
USER appuser

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

**优化点**：
- 合并 RUN 命令，减少层数
- 删除不需要的 tzdata 包
- 使用 Alpine 的轻量级包管理

---

### 方案 3：使用 JLink 创建自定义 JRE（最小，但复杂）

如果你的应用只使用部分 Java 模块，可以用 JLink 创建最小化 JRE。

```dockerfile
# 阶段 1: 创建自定义 JRE
FROM eclipse-temurin:21-jdk-alpine AS jre-builder

# 分析 JAR 包依赖的模块
COPY target/*.jar /app.jar
RUN jdeps --print-module-deps --ignore-missing-deps /app.jar > /modules.txt

# 创建自定义 JRE（只包含需要的模块）
RUN jlink \
    --add-modules $(cat /modules.txt) \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /custom-jre

# 阶段 2: 运行镜像
FROM alpine:3.19

# 复制自定义 JRE
COPY --from=jre-builder /custom-jre /opt/java

# 设置环境变量
ENV JAVA_HOME=/opt/java
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# 创建用户
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app
COPY target/*.jar app.jar
RUN chown appuser:appuser /app/app.jar

USER appuser
EXPOSE 8080

ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

**优点**：
- 镜像极小（可能 100MB 以内）
- 只包含需要的 Java 模块

**缺点**：
- 构建复杂
- 需要分析模块依赖
- 可能遗漏某些运行时需要的模块

---

### 方案 4：Spring Boot 分层构建（推荐用于 Spring Boot）

Spring Boot 2.3+ 支持分层 JAR，可以更好地利用 Docker 缓存。

```dockerfile
FROM eclipse-temurin:21-jre-alpine AS builder

WORKDIR /app
COPY target/*.jar app.jar

# 解压 JAR 包（Spring Boot 分层）
RUN java -Djarmode=layertools -jar app.jar extract

# 运行阶段
FROM eclipse-temurin:21-jre-alpine

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    addgroup -S appuser && \
    adduser -S appuser -G appuser

WORKDIR /app

# 按层复制（利用 Docker 缓存）
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
```

**优点**：
- 更好的缓存利用（依赖层不常变化）
- 构建速度更快（依赖层可复用）
- 镜像大小相同，但推送/拉取更快

**需要在 pom.xml 中配置**：
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

---

## 其他优化技巧

### 1. 减少 JAR 包大小

在 `pom.xml` 中排除不需要的依赖：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <!-- 如果不需要 Tomcat，可以排除 -->
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

### 2. 使用 .dockerignore

创建 `.dockerignore` 文件，避免复制不需要的文件：

```
# .dockerignore
.git
.gitignore
README.md
target/classes
target/test-classes
target/maven-status
target/maven-archiver
*.log
*.md
```

### 3. 多阶段构建优化

如果必须在 Docker 中构建，使用多阶段：

```dockerfile
# 构建阶段
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# 运行阶段
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S appuser && adduser -S appuser -G appuser
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar
RUN chown appuser:appuser app.jar
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

---

## 推荐配置（根据场景选择）

### 开发/测试环境（方便调试）

```dockerfile
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

**大小**：约 180-200MB

---

### 生产环境（最小化 + 安全）

```dockerfile
FROM gcr.io/distroless/java21-debian12
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENV JAVA_TOOL_OPTIONS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**大小**：约 150-180MB

---

### 生产环境（平衡版）

```dockerfile
FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    addgroup -S appuser && adduser -S appuser -G appuser
WORKDIR /app
COPY target/*.jar app.jar
RUN chown appuser:appuser app.jar
USER appuser
EXPOSE 8080
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

**大小**：约 180-200MB

---

## 镜像大小对比总结

| 方案 | 镜像大小 | 安全性 | 调试难度 | 推荐场景 |
|------|---------|--------|---------|---------|
| Distroless | 150-180MB | 最高 | 困难 | 生产环境 |
| Alpine 优化 | 180-200MB | 高 | 简单 | 通用 |
| JLink 自定义 | 100-150MB | 高 | 中等 | 极致优化 |
| Spring Boot 分层 | 180-200MB | 高 | 简单 | Spring Boot 应用 |

---

## 检查镜像大小

构建后检查各层大小：

```bash
# 查看镜像大小
docker images | grep demo-springboot

# 查看镜像各层大小
docker history demo-springboot:latest

# 使用 dive 工具分析镜像
dive demo-springboot:latest
```

---

## 建议

1. **立即可用**：使用方案 2（Alpine 优化），简单有效
2. **生产环境**：使用方案 1（Distroless），最安全最小
3. **Spring Boot**：使用方案 4（分层构建），构建更快
4. **极致优化**：使用方案 3（JLink），但需要测试

根据你的实际需求选择合适的方案！
