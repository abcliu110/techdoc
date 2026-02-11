# Docker 镜像制作指南

## 一、前置条件

1. 已安装 Docker
2. 已完成 Maven 构建，生成 jar 包
3. 了解项目的 Dockerfile 位置

## 二、项目 Dockerfile 分析

项目使用的 Dockerfile 模板：

```dockerfile
FROM eclipse-temurin:21-jre

COPY target/*.jar app.jar
COPY src/main/resources/*   config/
ENTRYPOINT ["java","-jar","/app.jar"]
```

**特点：**
- 使用 JDK 21 运行时环境
- 简单直接，适合 Spring Boot 应用
- 配置文件外置到 `/config/` 目录

## 三、手动构建镜像

### 步骤 1：构建 Maven 项目

```bash
# 进入项目目录
cd E:\mywork\nms4cloud

# 构建整个项目
mvn clean install -DskipTests

# 或构建单个模块（以 platform 为例）
cd nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app
mvn clean package -DskipTests
```

### 步骤 2：构建 Docker 镜像

```bash
# 在包含 Dockerfile 的目录中执行
cd nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app

# 构建镜像
docker build -t nms4cloud-platform:latest .

# 或指定标签
docker build -t nms4cloud-platform:0.0.1-SNAPSHOT .
```

### 步骤 3：查看镜像

```bash
# 查看本地镜像
docker images | grep nms4cloud

# 查看镜像详情
docker inspect nms4cloud-platform:latest
```

### 步骤 4：测试运行

```bash
# 运行容器
docker run -d \
  --name nms4cloud-platform \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=dev \
  nms4cloud-platform:latest

# 查看日志
docker logs -f nms4cloud-platform

# 停止容器
docker stop nms4cloud-platform

# 删除容器
docker rm nms4cloud-platform
```

## 四、推送到镜像仓库

### 推送到腾讯云容器镜像服务

```bash
# 1. 登录腾讯云
docker login ccr.ccs.tencentyun.com

# 2. 打标签
docker tag nms4cloud-platform:latest \
  ccr.ccs.tencentyun.com/<命名空间>/nms4cloud-platform:latest

# 3. 推送镜像
docker push ccr.ccs.tencentyun.com/<命名空间>/nms4cloud-platform:latest
```

### 推送到阿里云容器镜像服务

```bash
# 1. 登录阿里云
docker login --username=<用户名> registry.cn-hangzhou.aliyuncs.com

# 2. 打标签
docker tag nms4cloud-platform:latest \
  registry.cn-hangzhou.aliyuncs.com/<命名空间>/nms4cloud-platform:latest

# 3. 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/<命名空间>/nms4cloud-platform:latest
```

## 五、优化 Dockerfile

### 优化版 Dockerfile（推荐生产环境使用）

```dockerfile
FROM eclipse-temurin:21-jre

# 设置工作目录
WORKDIR /app

# 添加非 root 用户
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 复制 jar 包和配置文件
COPY --chown=appuser:appuser target/*.jar app.jar
COPY --chown=appuser:appuser src/main/resources/* config/

# 切换到非 root 用户
USER appuser

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

### 多阶段构建 Dockerfile（包含构建过程）

```dockerfile
# 第一阶段：构建
FROM maven:3.9.6-eclipse-temurin-21 AS builder

WORKDIR /build

# 复制 pom 文件
COPY pom.xml .
COPY ../../../pom.xml ../../../pom.xml

# 下载依赖（利用 Docker 缓存）
RUN mvn dependency:go-offline

# 复制源代码
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# 第二阶段：运行
FROM eclipse-temurin:21-jre

WORKDIR /app

RUN groupadd -r appuser && useradd -r -g appuser appuser

# 从构建阶段复制 jar 包
COPY --from=builder --chown=appuser:appuser /build/target/*.jar app.jar

USER appuser

EXPOSE 8080

ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

## 六、批量构建所有模块

### 创建构建脚本

创建 `build-all-images.sh`：

```bash
#!/bin/bash

# 镜像仓库地址
REGISTRY="ccr.ccs.tencentyun.com/<命名空间>"
VERSION="0.0.1-SNAPSHOT"

# 定义要构建的模块
MODULES=(
    "nms4cloud-app/1_platform/nms4cloud-platform/nms4cloud-platform-app:nms4cloud-platform"
    "nms4cloud-app/1_platform/nms4cloud-reg/nms4cloud-reg-app:nms4cloud-reg"
    "nms4cloud-app/1_platform/nms4cloud-mq/nms4cloud-mq-app:nms4cloud-mq"
    "nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-app:nms4cloud-pos"
    "nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-app:nms4cloud-biz"
)

# 遍历构建
for module in "${MODULES[@]}"; do
    IFS=':' read -r path name <<< "$module"

    echo "=== 构建 $name ==="

    # 进入模块目录
    cd "$path" || continue

    # 构建镜像
    docker build -t "$name:$VERSION" .
    docker tag "$name:$VERSION" "$name:latest"

    # 推送到镜像仓库
    docker tag "$name:$VERSION" "$REGISTRY/$name:$VERSION"
    docker tag "$name:$VERSION" "$REGISTRY/$name:latest"
    docker push "$REGISTRY/$name:$VERSION"
    docker push "$REGISTRY/$name:latest"

    # 返回根目录
    cd - > /dev/null

    echo "=== $name 构建完成 ==="
    echo ""
done

echo "所有镜像构建完成！"
```

使用脚本：

```bash
chmod +x build-all-images.sh
./build-all-images.sh
```

## 七、在 Kubernetes 中使用

### 创建 Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-platform
  namespace: nms4cloud
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nms4cloud-platform
  template:
    metadata:
      labels:
        app: nms4cloud-platform
    spec:
      containers:
        - name: nms4cloud-platform
          image: ccr.ccs.tencentyun.com/<命名空间>/nms4cloud-platform:latest
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "prod"
            - name: JAVA_OPTS
              value: "-Xms512m -Xmx1024m"
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
---
apiVersion: v1
kind: Service
metadata:
  name: nms4cloud-platform
  namespace: nms4cloud
spec:
  type: ClusterIP
  ports:
    - port: 8080
      targetPort: 8080
  selector:
    app: nms4cloud-platform
```

## 八、常见问题

### 1. 镜像太大

**解决方案：**
- 使用 `-jre` 而不是 `-jdk` 基础镜像
- 使用 Alpine 版本（更小）：`eclipse-temurin:21-jre-alpine`
- 使用多阶段构建

### 2. 配置文件问题

**问题：** `COPY src/main/resources/* config/` 可能复制失败

**解决方案：**
```dockerfile
# 方式一：复制整个目录
COPY src/main/resources/ config/

# 方式二：只复制特定文件
COPY src/main/resources/application.yml config/
COPY src/main/resources/application-prod.yml config/
```

### 3. 时区问题

**解决方案：**
```dockerfile
FROM eclipse-temurin:21-jre

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ... 其他配置
```

### 4. 字符编码问题

**解决方案：**
```dockerfile
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
```

## 九、最佳实践

1. **使用 .dockerignore**：排除不需要的文件
2. **分层构建**：利用 Docker 缓存加速构建
3. **最小权限**：使用非 root 用户运行
4. **健康检查**：添加 HEALTHCHECK 指令
5. **版本标签**：使用语义化版本号
6. **镜像扫描**：定期扫描安全漏洞

## 十、总结

**基本流程：**
1. Maven 构建生成 jar 包
2. 使用 Dockerfile 构建镜像
3. 推送到镜像仓库
4. 在 Kubernetes 中部署

**推荐工具：**
- Docker Desktop（本地开发）
- Jenkins（自动化构建）
- Harbor/腾讯云 TCR（镜像仓库）
- Kubernetes（容器编排）
