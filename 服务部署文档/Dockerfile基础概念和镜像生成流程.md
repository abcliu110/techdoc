# Dockerfile 基础概念和镜像生成流程

## 一、Dockerfile 是什么？

### 1.1 定义

**Dockerfile** 是一个文本文件，包含了一系列指令，用于自动化构建 Docker 镜像。

**类比理解：**
- Dockerfile = 菜谱（告诉你怎么做菜）
- Docker 镜像 = 做好的菜（可以直接吃）
- Docker 容器 = 正在吃的菜（运行中的实例）

### 1.2 Dockerfile 的本质

```
Dockerfile（文本文件）
    ↓ docker build
Docker 镜像（二进制文件）
    ↓ docker run
Docker 容器（运行中的进程）
```

---

## 二、Dockerfile 的作用

### 2.1 核心作用

1. **定义镜像构建步骤**
   - 指定基础镜像（FROM）
   - 安装软件包（RUN）
   - 复制文件（COPY）
   - 设置环境变量（ENV）
   - 定义启动命令（CMD/ENTRYPOINT）

2. **实现自动化构建**
   - 无需手动操作
   - 可重复构建
   - 版本可控

3. **标准化部署**
   - 确保环境一致性
   - 避免"在我机器上能运行"的问题

### 2.2 实际例子

**Dockerfile 示例：**

```dockerfile
# 1. 指定基础镜像（就像选择一个操作系统）
FROM openjdk:21-jdk-slim

# 2. 设置工作目录
WORKDIR /app

# 3. 复制应用文件
COPY target/myapp.jar app.jar

# 4. 设置环境变量
ENV JAVA_OPTS="-Xmx512m"

# 5. 声明端口
EXPOSE 8080

# 6. 定义启动命令
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**这个 Dockerfile 的作用：**
- 创建一个包含 Java 21 运行环境的镜像
- 把你的 jar 包放进去
- 设置好启动命令
- 任何人拿到这个镜像都能运行你的应用

---

## 三、如何生成镜像

### 3.1 完整流程

```
1. 编写 Dockerfile
   ↓
2. 执行 docker build 命令
   ↓
3. Docker 读取 Dockerfile
   ↓
4. 逐行执行指令
   ↓
5. 生成 Docker 镜像
```

### 3.2 详细步骤

#### 步骤 1：准备项目文件

```
myproject/
├── Dockerfile          # 镜像构建文件
├── target/
│   └── myapp.jar      # 应用程序
└── src/
    └── ...
```

#### 步骤 2：编写 Dockerfile

```dockerfile
FROM openjdk:21-jdk-slim
WORKDIR /app
COPY target/myapp.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

#### 步骤 3：构建镜像

```bash
# 基本命令
docker build -t myapp:1.0 .

# 参数说明：
# docker build    - 构建命令
# -t myapp:1.0    - 镜像名称和标签（tag）
#   myapp         - 镜像名称
#   1.0           - 版本标签
# .               - Dockerfile 所在目录（当前目录）
```

#### 步骤 4：查看生成的镜像

```bash
docker images

# 输出示例：
# REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
# myapp        1.0       abc123def456   2 minutes ago   250MB
```

### 3.3 构建过程详解

**执行 `docker build -t myapp:1.0 .` 时发生了什么：**

```
Step 1/5 : FROM openjdk:21-jdk-slim
 ---> 下载或使用本地的 openjdk:21-jdk-slim 镜像

Step 2/5 : WORKDIR /app
 ---> 在镜像中创建 /app 目录并设为工作目录

Step 3/5 : COPY target/myapp.jar app.jar
 ---> 从本地复制 jar 文件到镜像的 /app 目录

Step 4/5 : EXPOSE 8080
 ---> 声明容器将监听 8080 端口

Step 5/5 : ENTRYPOINT ["java", "-jar", "app.jar"]
 ---> 设置容器启动时执行的命令

Successfully built abc123def456
Successfully tagged myapp:1.0
```

**每一步都会创建一个镜像层（Layer）：**

```
openjdk:21-jdk-slim (基础层)
    ↓
+ WORKDIR /app (层 1)
    ↓
+ COPY jar 文件 (层 2)
    ↓
+ EXPOSE 8080 (层 3)
    ↓
+ ENTRYPOINT (层 4)
    ↓
最终镜像 myapp:1.0
```

---

## 四、如何推送到镜像仓库

### 4.1 镜像仓库的概念

**镜像仓库** 就像 GitHub，但存储的是 Docker 镜像而不是代码。

**常见的镜像仓库：**
- Docker Hub（公共）
- 腾讯云容器镜像服务（CCR）
- 阿里云容器镜像服务（ACR）
- Harbor（私有）

### 4.2 推送流程

```
本地镜像
    ↓ docker tag（打标签）
带仓库地址的镜像
    ↓ docker login（登录）
认证成功
    ↓ docker push（推送）
镜像仓库
```

### 4.3 实际操作步骤

#### 方案一：推送到腾讯云 CCR

**步骤 1：构建镜像**

```bash
docker build -t myapp:1.0 .
```

**步骤 2：打标签（添加仓库地址）**

```bash
# 格式：docker tag 本地镜像 仓库地址/命名空间/镜像名:标签
docker tag myapp:1.0 ccr.ccs.tencentyun.com/myproject/myapp:1.0
docker tag myapp:1.0 ccr.ccs.tencentyun.com/myproject/myapp:latest
```

**步骤 3：登录镜像仓库**

```bash
docker login ccr.ccs.tencentyun.com -u [账号ID] -p [密钥]

# 输出：
# Login Succeeded
```

**步骤 4：推送镜像**

```bash
docker push ccr.ccs.tencentyun.com/myproject/myapp:1.0
docker push ccr.ccs.tencentyun.com/myproject/myapp:latest
```

**推送过程：**

```
The push refers to repository [ccr.ccs.tencentyun.com/myproject/myapp]
5f70bf18a086: Pushed
e16c52e9c8f0: Pushed
...
1.0: digest: sha256:abc123... size: 1234
```

#### 方案二：推送到阿里云 ACR

```bash
# 1. 构建镜像
docker build -t myapp:1.0 .

# 2. 打标签
docker tag myapp:1.0 registry.cn-hangzhou.aliyuncs.com/myproject/myapp:1.0

# 3. 登录
docker login registry.cn-hangzhou.aliyuncs.com -u [用户名] -p [密码]

# 4. 推送
docker push registry.cn-hangzhou.aliyuncs.com/myproject/myapp:1.0
```

#### 方案三：推送到 Docker Hub

```bash
# 1. 构建镜像
docker build -t myapp:1.0 .

# 2. 打标签（Docker Hub 格式：用户名/镜像名）
docker tag myapp:1.0 yourusername/myapp:1.0

# 3. 登录
docker login

# 4. 推送
docker push yourusername/myapp:1.0
```

---

## 五、完整的实战示例

### 5.1 场景：构建 Spring Boot 应用并推送到腾讯云

**项目结构：**

```
nms4cloud/
├── Dockerfile
├── pom.xml
├── src/
└── target/
    └── myapp.jar
```

**步骤 1：编写 Dockerfile**

```dockerfile
FROM openjdk:21-jdk-slim

WORKDIR /app

COPY target/myapp.jar app.jar

ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**步骤 2：构建应用**

```bash
# Maven 构建
mvn clean package -DskipTests
```

**步骤 3：构建 Docker 镜像**

```bash
# 构建镜像
docker build -t myapp:1.0.0 .

# 查看镜像
docker images | grep myapp
```

**步骤 4：本地测试**

```bash
# 运行容器测试
docker run -d -p 8080:8080 --name myapp-test myapp:1.0.0

# 查看日志
docker logs -f myapp-test

# 测试接口
curl http://localhost:8080/health

# 停止并删除测试容器
docker stop myapp-test
docker rm myapp-test
```

**步骤 5：打标签**

```bash
# 打多个标签
docker tag myapp:1.0.0 ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0
docker tag myapp:1.0.0 ccr.ccs.tencentyun.com/nms4cloud/myapp:latest
docker tag myapp:1.0.0 ccr.ccs.tencentyun.com/nms4cloud/myapp:prod
```

**步骤 6：登录镜像仓库**

```bash
docker login ccr.ccs.tencentyun.com \
  -u 100012345678 \
  -p your-secret-key
```

**步骤 7：推送镜像**

```bash
# 推送所有标签
docker push ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0
docker push ccr.ccs.tencentyun.com/nms4cloud/myapp:latest
docker push ccr.ccs.tencentyun.com/nms4cloud/myapp:prod
```

**步骤 8：验证**

```bash
# 删除本地镜像
docker rmi ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0

# 从仓库拉取
docker pull ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0

# 运行
docker run -d -p 8080:8080 ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0
```

---

## 六、自动化脚本

### 6.1 构建和推送脚本

**创建 `build-and-push.sh`：**

```bash
#!/bin/bash

# 配置
IMAGE_NAME="myapp"
VERSION="1.0.0"
REGISTRY="ccr.ccs.tencentyun.com"
NAMESPACE="nms4cloud"

# 完整镜像名
FULL_IMAGE="${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}"

echo "=== 开始构建镜像 ==="

# 1. Maven 构建
echo "1. Maven 构建..."
mvn clean package -DskipTests

# 2. 构建 Docker 镜像
echo "2. 构建 Docker 镜像..."
docker build -t ${IMAGE_NAME}:${VERSION} .

# 3. 打标签
echo "3. 打标签..."
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE}:${VERSION}
docker tag ${IMAGE_NAME}:${VERSION} ${FULL_IMAGE}:latest

# 4. 推送镜像
echo "4. 推送镜像..."
docker push ${FULL_IMAGE}:${VERSION}
docker push ${FULL_IMAGE}:latest

# 5. 清理本地镜像
echo "5. 清理本地镜像..."
docker rmi ${IMAGE_NAME}:${VERSION}
docker rmi ${FULL_IMAGE}:${VERSION}
docker rmi ${FULL_IMAGE}:latest

echo "=== 构建完成 ==="
echo "镜像地址: ${FULL_IMAGE}:${VERSION}"
```

**使用：**

```bash
chmod +x build-and-push.sh
./build-and-push.sh
```

---

## 七、镜像仓库管理

### 7.1 镜像命名规范

**格式：**
```
[仓库地址]/[命名空间]/[镜像名]:[标签]
```

**示例：**
```
ccr.ccs.tencentyun.com/nms4cloud/myapp:1.0.0
│                      │         │      │
│                      │         │      └─ 标签（版本）
│                      │         └──────── 镜像名
│                      └────────────────── 命名空间（项目）
└───────────────────────────────────────── 仓库地址
```

### 7.2 标签策略

**推荐的标签策略：**

```bash
# 1. 语义化版本
myapp:1.0.0
myapp:1.0.1
myapp:2.0.0

# 2. latest（最新版本）
myapp:latest

# 3. 环境标签
myapp:dev
myapp:test
myapp:prod

# 4. Git commit
myapp:a1b2c3d

# 5. 构建号
myapp:build-123

# 6. 组合标签
myapp:1.0.0-a1b2c3d
myapp:1.0.0-prod
```

### 7.3 镜像生命周期管理

```
开发 → 测试 → 预发布 → 生产

myapp:dev
  ↓ 测试通过
myapp:test
  ↓ 验收通过
myapp:staging
  ↓ 上线
myapp:prod
myapp:1.0.0
```

---

## 八、常见问题

### 8.1 镜像太大怎么办？

**问题：** 镜像 500MB+

**解决方案：**
1. 使用精简版基础镜像（`-slim` 或 `-alpine`）
2. 使用多阶段构建
3. 清理不必要的文件

```dockerfile
# 多阶段构建示例
FROM maven:3.9.6-openjdk-21 AS builder
WORKDIR /build
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 8.2 构建速度慢怎么办？

**问题：** 每次构建都很慢

**解决方案：**
1. 利用 Docker 缓存
2. 先复制依赖配置，再复制代码

```dockerfile
# 优化前（每次都重新下载依赖）
COPY . .
RUN mvn package

# 优化后（依赖不变时使用缓存）
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn package
```

### 8.3 如何查看镜像内容？

```bash
# 查看镜像历史
docker history myapp:1.0

# 运行容器并进入
docker run -it myapp:1.0 bash

# 查看镜像详细信息
docker inspect myapp:1.0
```

---

## 九、总结

### 9.1 核心流程

```
编写 Dockerfile
    ↓
docker build（构建镜像）
    ↓
docker tag（打标签）
    ↓
docker login（登录仓库）
    ↓
docker push（推送镜像）
    ↓
镜像仓库
    ↓
docker pull（拉取镜像）
    ↓
docker run（运行容器）
```

### 9.2 关键命令

```bash
# 构建镜像
docker build -t myapp:1.0 .

# 查看镜像
docker images

# 打标签
docker tag myapp:1.0 registry.com/project/myapp:1.0

# 登录仓库
docker login registry.com

# 推送镜像
docker push registry.com/project/myapp:1.0

# 拉取镜像
docker pull registry.com/project/myapp:1.0

# 运行容器
docker run -d -p 8080:8080 myapp:1.0
```

### 9.3 最佳实践

1. ✅ 使用多阶段构建减小镜像体积
2. ✅ 利用 Docker 缓存加速构建
3. ✅ 使用语义化版本管理镜像
4. ✅ 为不同环境打不同标签
5. ✅ 使用私有镜像仓库保护代码
6. ✅ 定期清理无用镜像
7. ✅ 使用 CI/CD 自动化构建和推送
