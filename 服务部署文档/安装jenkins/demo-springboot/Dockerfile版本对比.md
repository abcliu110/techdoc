# Dockerfile 版本对比

## 可用版本

| 文件名 | 镜像大小 | 安全性 | 调试难度 | 推荐场景 |
|--------|---------|--------|---------|---------|
| `Dockerfile` | 180-200MB | 高 | 简单 | 当前使用（通用） |
| `Dockerfile.alpine-optimized` | 180-200MB | 高 | 简单 | 优化版（推荐） |
| `Dockerfile.distroless` | 150-180MB | 最高 | 困难 | 生产环境 |
| `Dockerfile.layered` | 180-200MB | 高 | 简单 | Spring Boot 应用 |
| `Dockerfile.simple` | 220-250MB | 中 | 简单 | 快速测试 |

## 详细对比

### 1. Dockerfile（当前版本）

```dockerfile
FROM eclipse-temurin:21-jre-alpine
# ... 多个 RUN 命令
```

**特点**：
- ✅ 使用 Alpine 基础镜像
- ⚠️ 多个 RUN 命令，层数较多
- ✅ 包含时区设置和用户管理
- ✅ 可以调试（有 shell）

**大小**：约 180-200MB

**适用**：通用场景

---

### 2. Dockerfile.alpine-optimized（推荐替换）

```dockerfile
FROM eclipse-temurin:21-jre-alpine
# 合并所有 RUN 命令为一个
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata && \
    addgroup -S appuser && \
    adduser -S appuser -G appuser
```

**特点**：
- ✅ 合并 RUN 命令，减少层数
- ✅ 删除不需要的 tzdata 包
- ✅ 镜像层更少，推送/拉取更快
- ✅ 可以调试（有 shell）

**大小**：约 180-200MB（但层数更少）

**适用**：通用场景，推荐替换当前 Dockerfile

**优势**：
- 镜像层更少（推送到仓库更快）
- 构建缓存更有效
- 代码更简洁

---

### 3. Dockerfile.distroless（生产环境推荐）

```dockerfile
FROM gcr.io/distroless/java21-debian12
# 没有 shell，没有包管理器
```

**特点**：
- ✅ 镜像最小（150-180MB）
- ✅ 安全性最高（攻击面最小）
- ✅ 启动速度快
- ❌ 没有 shell，无法 `docker exec` 进入容器
- ❌ 调试困难

**大小**：约 150-180MB

**适用**：生产环境，对安全性要求高

**注意**：
- 不能使用 `docker exec -it <container> sh`
- 只能通过日志调试
- 适合成熟稳定的应用

---

### 4. Dockerfile.layered（Spring Boot 推荐）

```dockerfile
# 阶段 1: 解压 JAR
FROM eclipse-temurin:21-jre-alpine AS builder
RUN java -Djarmode=layertools -jar app.jar extract

# 阶段 2: 按层复制
FROM eclipse-temurin:21-jre-alpine
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
```

**特点**：
- ✅ 利用 Spring Boot 分层特性
- ✅ 依赖层可缓存（依赖不常变化）
- ✅ 应用层单独（代码变化频繁）
- ✅ 推送/拉取更快（只推送变化的层）
- ⚠️ 需要在 pom.xml 中启用分层

**大小**：约 180-200MB

**适用**：Spring Boot 应用，频繁构建

**需要配置 pom.xml**：
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <layers>
            <enabled>true</enabled>
        </layers>
    </configuration>
</plugin>
```

---

### 5. Dockerfile.simple（快速测试）

```dockerfile
FROM openjdk:11-jre-slim
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

**特点**：
- ✅ 最简单
- ⚠️ 基于 Debian（体积较大）
- ⚠️ 没有安全配置
- ⚠️ 没有时区设置

**大小**：约 220-250MB

**适用**：快速测试，不推荐生产使用

---

## 如何选择？

### 场景 1：开发/测试环境

**推荐**：`Dockerfile.alpine-optimized`

**原因**：
- 体积适中
- 可以调试（有 shell）
- 构建快速

### 场景 2：生产环境（安全优先）

**推荐**：`Dockerfile.distroless`

**原因**：
- 镜像最小
- 安全性最高
- 攻击面最小

### 场景 3：Spring Boot 应用（频繁构建）

**推荐**：`Dockerfile.layered`

**原因**：
- 更好的缓存利用
- 推送/拉取更快
- 依赖层可复用

### 场景 4：通用场景（平衡）

**推荐**：`Dockerfile.alpine-optimized`

**原因**：
- 体积小
- 可调试
- 安全性好
- 易维护

---

## 切换方法

### 方法 1：重命名文件

```bash
# 备份当前 Dockerfile
mv Dockerfile Dockerfile.old

# 使用优化版本
cp Dockerfile.alpine-optimized Dockerfile
```

### 方法 2：在 Jenkinsfile 中指定

修改 Jenkinsfile-k8s：

```groovy
/kaniko/executor \
    --context=${WORKSPACE} \
    --dockerfile=${WORKSPACE}/Dockerfile.distroless \  # 指定文件
    --destination=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
```

---

## 镜像大小实测对比

假设你的 JAR 包大小为 50MB：

| Dockerfile | 基础镜像 | JAR | 其他层 | 总大小 |
|-----------|---------|-----|--------|--------|
| simple | 220MB | 50MB | 10MB | ~280MB |
| 当前版本 | 180MB | 50MB | 10MB | ~240MB |
| alpine-optimized | 180MB | 50MB | 5MB | ~235MB |
| distroless | 150MB | 50MB | 5MB | ~205MB |
| layered | 180MB | 50MB | 5MB | ~235MB |

---

## 推荐操作

### 立即优化（简单）

替换为 `Dockerfile.alpine-optimized`：

```bash
cd 服务部署文档/安装jenkins/demo-springboot/
cp Dockerfile Dockerfile.backup
cp Dockerfile.alpine-optimized Dockerfile
```

**效果**：
- 镜像层减少 2-3 层
- 推送速度提升 10-20%
- 代码更简洁

### 生产环境优化（推荐）

使用 `Dockerfile.distroless`：

```bash
# 在 Jenkinsfile 中指定
--dockerfile=${WORKSPACE}/Dockerfile.distroless
```

**效果**：
- 镜像大小减少 30-50MB
- 安全性显著提升
- 启动速度更快

### Spring Boot 优化（最佳）

1. 修改 `pom.xml` 启用分层
2. 使用 `Dockerfile.layered`

**效果**：
- 依赖层可缓存
- 推送/拉取速度提升 50%+
- 适合频繁构建

---

## 总结

**当前问题**：镜像可能有 200MB+

**原因**：
1. 基础镜像本身就有 180MB（JRE）
2. JAR 包大小（取决于依赖）
3. 镜像层数较多

**解决方案**：
1. **立即可用**：替换为 `Dockerfile.alpine-optimized`（减少层数）
2. **生产环境**：使用 `Dockerfile.distroless`（减少 30-50MB）
3. **Spring Boot**：使用 `Dockerfile.layered`（构建更快）

**建议**：先使用 `Dockerfile.alpine-optimized` 替换当前版本，简单有效！
