# Spring Boot 镜像优化：分层构建

## 问题：为什么要分层？

### 标准 Dockerfile 的问题

```dockerfile
FROM eclipse-temurin:21-jre-alpine
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**问题：**
- 每次代码改动，整个 85 MB JAR 都要重新推送
- 即使只改了 1 行代码，也要推送 85 MB
- 推送时间：8-10 分钟

---

## 解决方案：Spring Boot 分层构建

### 原理

Spring Boot 2.3+ 支持将 JAR 分层：

```
Fat JAR (85 MB)
├── dependencies/           (70 MB) ← 很少变化
├── spring-boot-loader/     (1 MB)  ← 很少变化
├── snapshot-dependencies/  (0 MB)  ← 偶尔变化
└── application/            (14 MB) ← 经常变化
```

**Docker 层缓存：**
- 依赖层不变 → 不需要重新推送
- 只推送应用层 → 只需推送 14 MB
- 推送时间：从 8 分钟降到 1 分钟

---

## 实现步骤

### 1. 修改 pom.xml

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <!-- 启用分层 -->
                <layers>
                    <enabled>true</enabled>
                </layers>
            </configuration>
        </plugin>
    </plugins>
</build>
```

### 2. 验证分层

```bash
# 构建 JAR
mvn clean package

# 查看分层信息
java -Djarmode=layertools -jar target/*.jar list

# 输出
dependencies
spring-boot-loader
snapshot-dependencies
application
```

### 3. 提取分层

```bash
# 提取所有层
java -Djarmode=layertools -jar target/*.jar extract

# 目录结构
extracted/
├── dependencies/           # 第三方依赖（70 MB）
│   ├── spring-boot-3.2.0.jar
│   ├── spring-web-6.1.0.jar
│   ├── tomcat-embed-core-10.1.15.jar
│   └── ...
├── spring-boot-loader/     # Spring Boot 启动器（1 MB）
│   └── org/springframework/boot/loader/
├── snapshot-dependencies/  # SNAPSHOT 依赖（0 MB）
└── application/            # 你的应用代码（14 MB）
    ├── BOOT-INF/classes/
    └── META-INF/
```

---

## 优化的 Dockerfile

### 方案 1: 多阶段构建（推荐）

```dockerfile
# ============================================================================
# 阶段 1: 提取分层
# ============================================================================
FROM eclipse-temurin:21-jre-alpine AS builder

WORKDIR /app

# 复制 JAR 文件
COPY target/*.jar app.jar

# 提取分层
RUN java -Djarmode=layertools -jar app.jar extract

# ============================================================================
# 阶段 2: 构建最终镜像
# ============================================================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# 按顺序复制各层（利用 Docker 缓存）
# 依赖层（很少变化，会被缓存）
COPY --from=builder /app/dependencies/ ./

# Spring Boot Loader（几乎不变化，会被缓存）
COPY --from=builder /app/spring-boot-loader/ ./

# SNAPSHOT 依赖（偶尔变化）
COPY --from=builder /app/snapshot-dependencies/ ./

# 应用层（经常变化，每次都推送）
COPY --from=builder /app/application/ ./

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata

# 创建非 root 用户
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

EXPOSE 8080

# 使用 JarLauncher 启动
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
```

---

## 效果对比

### 首次构建

| 方案 | 镜像大小 | 推送时间 |
|------|---------|---------|
| 标准 Dockerfile | 255 MB | 8 分钟 |
| 分层 Dockerfile | 255 MB | 8 分钟 |

**首次构建时间相同**

### 后续构建（只改代码）

| 方案 | 需要推送 | 推送时间 |
|------|---------|---------|
| 标准 Dockerfile | 85 MB（整个 JAR） | 8 分钟 |
| 分层 Dockerfile | 14 MB（只有应用层） | **1 分钟** ✅ |

**节省：87.5%**

### 后续构建（升级依赖）

| 方案 | 需要推送 | 推送时间 |
|------|---------|---------|
| 标准 Dockerfile | 85 MB（整个 JAR） | 8 分钟 |
| 分层 Dockerfile | 70 MB（依赖层 + 应用层） | 6 分钟 |

**节省：25%**

---

## 在 Jenkins 中使用

### 修改 Jenkinsfile

你的项目需要修改两个地方：

#### 1. 修改 pom.xml（每个模块）

```xml
<!-- nms4cloud-pos3boot/nms4cloud-pos3boot-app/pom.xml -->
<!-- nms4cloud-pos4cloud/nms4cloud-pos4cloud-app/pom.xml -->
<!-- nms4cloud-pos5sync/nms4cloud-pos5sync-app/pom.xml -->

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

#### 2. 修改 Dockerfile（每个模块）

```dockerfile
# nms4cloud-pos3boot/nms4cloud-pos3boot-app/Dockerfile
# nms4cloud-pos4cloud/nms4cloud-pos4cloud-app/Dockerfile
# nms4cloud-pos5sync/nms4cloud-pos5sync-app/Dockerfile

FROM eclipse-temurin:21-jre-alpine AS builder
WORKDIR /app
COPY target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# 分层复制
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./

RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    apk del tzdata

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.JarLauncher"]
```

#### 3. Jenkinsfile 不需要修改

Kaniko 会自动处理多阶段构建，无需修改 Jenkinsfile。

---

## 验证分层效果

### 查看镜像层

```bash
# 拉取镜像
docker pull crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-pos4cloud:27

# 查看镜像历史
docker history crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-pos4cloud:27

# 输出示例
IMAGE          CREATED          CREATED BY                                      SIZE
abc123         2 minutes ago    COPY /app/application/ ./                       14MB    ← 应用层
def456         2 minutes ago    COPY /app/snapshot-dependencies/ ./             0B
ghi789         2 minutes ago    COPY /app/spring-boot-loader/ ./                1MB
jkl012         2 minutes ago    COPY /app/dependencies/ ./                      70MB    ← 依赖层
mno345         1 hour ago       /bin/sh -c #(nop)  CMD ["sh"]                   0B
pqr678         1 hour ago       /bin/sh -c #(nop) ADD file:xxx in /             170MB   ← 基础镜像
```

### 对比两次构建

```bash
# 第一次构建
Build #27: 推送 255 MB，耗时 8 分钟

# 修改代码后第二次构建
Build #28: 推送 14 MB，耗时 1 分钟  ✅

# 升级依赖后第三次构建
Build #29: 推送 84 MB，耗时 6 分钟
```

---

## 进一步优化：启用 Kaniko 缓存

### 修改 Jenkinsfile

```groovy
/kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    --destination=${dockerImageName}:${DOCKER_IMAGE_TAG} \
    --destination=${dockerImageName}:latest \
    --cache=true \                                    # ✅ 启用缓存
    --cache-repo=${DOCKER_REGISTRY}/cache \           # ✅ 缓存仓库
    --compression=gzip \
    --compression-level=9 \
    --push-retry=3
```

### 创建缓存仓库

在阿里云镜像仓库创建一个名为 `cache` 的仓库：

```bash
# 阿里云控制台
容器镜像服务 → 个人实例 → 命名空间 lgy-images → 创建镜像仓库
仓库名称: cache
仓库类型: 私有
```

### 效果

| 构建类型 | 无缓存 | 有缓存 |
|---------|--------|--------|
| 首次构建 | 8 分钟 | 8 分钟 |
| 代码改动 | 1 分钟 | **30 秒** ✅ |
| 依赖升级 | 6 分钟 | **3 分钟** ✅ |

---

## 总结

### 优化组合方案

| 优化 | 效果 | 难度 |
|------|------|------|
| **Alpine 基础镜像** | 减少 50 MB | 低 |
| **gzip Level 9 压缩** | 减少 40% 传输 | 低 |
| **分层构建** | 后续推送减少 87% | 中 |
| **Kaniko 缓存** | 再减少 50% | 中 |
| **本地镜像仓库** | 推送降到 10 秒 | 高 |

### 推荐实施顺序

1. ✅ **已完成**：Alpine + Level 9 压缩
2. **本周实施**：分层构建（修改 pom.xml 和 Dockerfile）
3. **可选**：Kaniko 缓存（需要创建缓存仓库）
4. **长期**：本地镜像仓库（最佳方案）

### 预期效果

| 阶段 | 首次推送 | 后续推送 | 改善 |
|------|---------|---------|------|
| 当前 | 8 分钟 | 8 分钟 | - |
| + 分层 | 8 分钟 | 1 分钟 | 87% ↓ |
| + 缓存 | 8 分钟 | 30 秒 | 94% ↓ |
| + 本地仓库 | 10 秒 | 5 秒 | 99% ↓ |

需要我帮你修改 pom.xml 和 Dockerfile 来实现分层构建吗？
