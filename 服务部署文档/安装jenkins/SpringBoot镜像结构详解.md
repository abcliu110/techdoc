# Spring Boot Docker 镜像结构详解

## 核心问题

**Q: Spring Boot 镜像包含第三方依赖吗？**
**A: 是的，完全包含！**

---

## 1. Spring Boot "Fat JAR" 原理

### 什么是 Fat JAR？

Spring Boot 默认使用 `spring-boot-maven-plugin` 打包成 **Fat JAR（胖 JAR）**：

```xml
<!-- pom.xml -->
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

**打包结果：**
```
nms4cloud-pos4cloud-app-0.0.1-SNAPSHOT.jar  (85 MB)
├── BOOT-INF/
│   ├── classes/                    # 你的应用代码
│   │   ├── com/example/MyApp.class
│   │   └── application.yml
│   └── lib/                        # 所有第三方依赖 ✅
│       ├── spring-boot-3.2.0.jar
│       ├── spring-web-6.1.0.jar
│       ├── tomcat-embed-core-10.1.15.jar
│       ├── mysql-connector-8.0.33.jar
│       ├── mybatis-3.5.13.jar
│       └── ... (所有依赖，约 200+ 个 JAR)
├── META-INF/
│   └── MANIFEST.MF
└── org/springframework/boot/loader/  # Spring Boot 启动器
```

---

## 2. 镜像结构详解

### 标准 Dockerfile

```dockerfile
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# 复制 Fat JAR（包含所有依赖）
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### 镜像层结构

```
Docker 镜像（总大小：约 255 MB）
│
├── Layer 1: 基础镜像（170 MB）
│   ├── Alpine Linux
│   ├── OpenJDK 21 JRE
│   └── 系统库
│
├── Layer 2: Fat JAR（85 MB）
│   ├── 你的应用代码（5 MB）
│   ├── 第三方依赖（75 MB）✅
│   │   ├── Spring Boot 框架（20 MB）
│   │   ├── Spring Web（10 MB）
│   │   ├── Tomcat 内嵌服务器（10 MB）
│   │   ├── 数据库驱动（5 MB）
│   │   ├── MyBatis（3 MB）
│   │   └── 其他依赖（27 MB）
│   └── Spring Boot Loader（1 MB）
│
└── Layer 3: 配置文件（可选，2 MB）
    └── application.yml
```

---

## 3. 验证：查看 JAR 文件内容

### 方法 1: 解压 JAR 文件

```bash
# JAR 文件本质上是 ZIP 文件
unzip -l target/nms4cloud-pos4cloud-app-0.0.1-SNAPSHOT.jar | head -50

# 输出示例
Archive:  nms4cloud-pos4cloud-app-0.0.1-SNAPSHOT.jar
  Length      Date    Time    Name
---------  ---------- -----   ----
        0  2024-01-15 10:30   BOOT-INF/
        0  2024-01-15 10:30   BOOT-INF/classes/
        0  2024-01-15 10:30   BOOT-INF/classes/com/
        0  2024-01-15 10:30   BOOT-INF/classes/com/example/
     1234  2024-01-15 10:30   BOOT-INF/classes/com/example/MyApp.class
        0  2024-01-15 10:30   BOOT-INF/lib/                    ← 依赖目录
  3456789  2024-01-15 10:30   BOOT-INF/lib/spring-boot-3.2.0.jar
  2345678  2024-01-15 10:30   BOOT-INF/lib/spring-web-6.1.0.jar
  1234567  2024-01-15 10:30   BOOT-INF/lib/tomcat-embed-core-10.1.15.jar
   987654  2024-01-15 10:30   BOOT-INF/lib/mysql-connector-8.0.33.jar
   ...
```

### 方法 2: 统计依赖数量

```bash
# 统计 BOOT-INF/lib 中的 JAR 数量
unzip -l target/*.jar | grep "BOOT-INF/lib/" | grep ".jar" | wc -l

# 输出示例
237    # 包含 237 个依赖 JAR
```

### 方法 3: 查看 MANIFEST.MF

```bash
unzip -p target/*.jar META-INF/MANIFEST.MF

# 输出示例
Manifest-Version: 1.0
Spring-Boot-Version: 3.2.0
Main-Class: org.springframework.boot.loader.JarLauncher  ← Spring Boot 启动器
Start-Class: com.example.MyApp                           ← 你的主类
Spring-Boot-Classes: BOOT-INF/classes/
Spring-Boot-Lib: BOOT-INF/lib/                           ← 依赖位置
```

---

## 4. 运行时如何加载依赖？

### Spring Boot Loader 机制

```
容器启动
    ↓
java -jar app.jar
    ↓
JVM 加载 JarLauncher（Spring Boot Loader）
    ↓
JarLauncher 读取 MANIFEST.MF
    ↓
创建自定义 ClassLoader
    ↓
加载 BOOT-INF/classes/（你的代码）
    ↓
加载 BOOT-INF/lib/*.jar（所有依赖）✅
    ↓
启动 Spring Boot 应用
    ↓
启动内嵌 Tomcat
    ↓
应用运行
```

**关键点：**
- ✅ 所有依赖都在 JAR 内部
- ✅ 不需要外部 Maven 仓库
- ✅ 不需要网络下载
- ✅ 完全自包含

---

## 5. 对比：传统 WAR vs Spring Boot JAR

### 传统 WAR 部署

```
应用服务器（Tomcat）
├── bin/
├── lib/                    # 共享依赖
│   ├── servlet-api.jar
│   └── jsp-api.jar
└── webapps/
    └── myapp.war           # 只包含应用代码
        ├── WEB-INF/
        │   ├── classes/    # 你的代码
        │   └── lib/        # 应用特定依赖
        └── index.jsp
```

**问题：**
- ❌ 需要预先安装 Tomcat
- ❌ 依赖外部服务器
- ❌ 版本冲突风险

### Spring Boot JAR 部署

```
Docker 容器
├── JRE（基础镜像）
└── app.jar                 # 完全自包含 ✅
    ├── 应用代码
    ├── 所有依赖
    └── 内嵌 Tomcat
```

**优点：**
- ✅ 完全自包含
- ✅ 无需外部服务器
- ✅ 无版本冲突
- ✅ 一次构建，到处运行

---

## 6. 依赖来源：构建时 vs 运行时

### 构建时（Maven）

```bash
# Jenkins 构建阶段
mvn clean package

# Maven 做了什么？
1. 读取 pom.xml
2. 从 Maven 仓库下载依赖
   ├── 中央仓库（https://repo.maven.apache.org）
   ├── 阿里云镜像（https://maven.aliyun.com）
   └── 本地缓存（/var/jenkins_home/maven-repository）
3. 编译你的代码
4. 将代码 + 所有依赖打包到 JAR
5. 生成 Fat JAR（85 MB）
```

**依赖下载位置：**
```
Jenkins 容器
└── /var/jenkins_home/maven-repository/  # Maven 本地仓库
    ├── org/springframework/boot/spring-boot/3.2.0/
    ├── org/springframework/spring-web/6.1.0/
    ├── org/apache/tomcat/embed/tomcat-embed-core/10.1.15/
    └── ...
```

### 运行时（Docker）

```bash
# 容器启动
docker run my-image

# 做了什么？
1. 启动 JVM
2. 加载 app.jar
3. 从 JAR 内部加载所有依赖 ✅
4. 启动应用

# 不需要：
❌ 不需要 Maven
❌ 不需要网络
❌ 不需要下载依赖
```

---

## 7. 为什么 JAR 这么大？

### 大小分解（以 85 MB 为例）

| 组件 | 大小 | 说明 |
|------|------|------|
| **你的应用代码** | 5 MB | .class 文件 |
| **Spring Boot 框架** | 20 MB | spring-boot, spring-context, spring-beans |
| **Spring Web** | 10 MB | spring-web, spring-webmvc |
| **内嵌 Tomcat** | 10 MB | tomcat-embed-core, tomcat-embed-el |
| **数据库驱动** | 5 MB | mysql-connector, HikariCP |
| **MyBatis** | 3 MB | mybatis, mybatis-spring |
| **日志框架** | 5 MB | logback, slf4j |
| **JSON 处理** | 3 MB | jackson-databind, jackson-core |
| **工具库** | 5 MB | commons-lang3, guava |
| **其他依赖** | 19 MB | 各种小依赖 |
| **总计** | **85 MB** | |

### 查看依赖树

```bash
# 查看项目依赖
mvn dependency:tree

# 输出示例
[INFO] com.example:nms4cloud-pos4cloud-app:jar:0.0.1-SNAPSHOT
[INFO] +- org.springframework.boot:spring-boot-starter-web:jar:3.2.0:compile
[INFO] |  +- org.springframework.boot:spring-boot-starter:jar:3.2.0:compile
[INFO] |  |  +- org.springframework.boot:spring-boot:jar:3.2.0:compile
[INFO] |  |  +- org.springframework.boot:spring-boot-autoconfigure:jar:3.2.0:compile
[INFO] |  |  +- org.springframework.boot:spring-boot-starter-logging:jar:3.2.0:compile
[INFO] |  |  |  +- ch.qos.logback:logback-classic:jar:1.4.11:compile
[INFO] |  |  |  +- org.apache.logging.log4j:log4j-to-slf4j:jar:2.21.0:compile
[INFO] |  |  |  \- org.slf4j:jul-to-slf4j:jar:2.0.9:compile
[INFO] |  |  \- org.yaml:snakeyaml:jar:2.2:compile
[INFO] |  +- org.springframework.boot:spring-boot-starter-tomcat:jar:3.2.0:compile
[INFO] |  |  +- org.apache.tomcat.embed:tomcat-embed-core:jar:10.1.15:compile
[INFO] |  |  +- org.apache.tomcat.embed:tomcat-embed-el:jar:10.1.15:compile
[INFO] |  |  \- org.apache.tomcat.embed:tomcat-embed-websocket:jar:10.1.15:compile
[INFO] |  +- org.springframework:spring-web:jar:6.1.0:compile
[INFO] |  \- org.springframework:spring-webmvc:jar:6.1.0:compile
[INFO] +- mysql:mysql-connector-java:jar:8.0.33:compile
[INFO] +- org.mybatis.spring.boot:mybatis-spring-boot-starter:jar:3.0.2:compile
[INFO] \- ... (更多依赖)
```

---

## 8. 优化：减小镜像大小

### 方法 1: 使用分层 JAR（推荐）

Spring Boot 2.3+ 支持分层 JAR：

```xml
<!-- pom.xml -->
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

**Dockerfile：**
```dockerfile
FROM eclipse-temurin:21-jre-alpine as builder
WORKDIR /app
COPY target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# 分层复制（依赖层变化少，可以利用 Docker 缓存）
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
```

**效果：**
```
镜像层结构
├── Layer 1: 基础镜像（170 MB）         # 几乎不变
├── Layer 2: 第三方依赖（70 MB）        # 很少变化 ✅
├── Layer 3: Spring Boot Loader（1 MB） # 几乎不变
├── Layer 4: Snapshot 依赖（2 MB）      # 偶尔变化
└── Layer 5: 应用代码（5 MB）           # 经常变化 ✅

首次推送：248 MB，10 分钟
后续推送：只推送 Layer 5（5 MB），30 秒 ✅
```

### 方法 2: 排除不必要的依赖

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <!-- 排除不需要的依赖 -->
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>

<!-- 使用更轻量的 Undertow -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-undertow</artifactId>
</dependency>
```

### 方法 3: 使用 Spring Boot Thin Launcher（不推荐）

**原理：** JAR 不包含依赖，运行时从 Maven 仓库下载

**问题：**
- ❌ 需要网络连接
- ❌ 启动慢
- ❌ 依赖外部服务
- ❌ 不适合容器化

---

## 9. 总结

### 核心答案

**Q: Spring Boot 镜像包含第三方依赖吗？**
**A: 是的，完全包含在 Fat JAR 中！**

**Q: 部署时如何下载依赖？**
**A: 不需要下载，所有依赖已经在 JAR 内部！**

### 工作流程

```
开发阶段
  ├── 编写代码
  └── 配置 pom.xml

构建阶段（Jenkins）
  ├── mvn clean package
  ├── Maven 下载依赖到本地仓库
  ├── 编译代码
  └── 打包成 Fat JAR（包含所有依赖）✅

镜像构建阶段
  ├── COPY target/*.jar app.jar
  └── 构建 Docker 镜像

部署阶段（Kubernetes）
  ├── 拉取镜像
  ├── 启动容器
  ├── java -jar app.jar
  ├── 从 JAR 内部加载依赖 ✅
  └── 应用运行

运行时
  ├── 不需要 Maven
  ├── 不需要网络
  └── 完全自包含 ✅
```

### 优点

✅ 完全自包含，无外部依赖
✅ 一次构建，到处运行
✅ 无版本冲突
✅ 启动快速
✅ 适合容器化

### 缺点

⚠️ JAR 文件较大（50-100 MB）
⚠️ 镜像较大（200-300 MB）
⚠️ 推送时间长（阿里云个人版）

### 优化建议

1. **使用分层 JAR**：后续推送只需 30 秒
2. **使用 Alpine 基础镜像**：减少 50 MB
3. **排除不必要的依赖**：减少 10-20 MB
4. **部署本地镜像仓库**：推送时间降到 10 秒
