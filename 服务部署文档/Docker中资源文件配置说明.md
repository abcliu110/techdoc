# Docker 中 Spring Boot 资源文件配置说明

## 一、问题分析

### 1.1 你的 Dockerfile 存在的问题

```dockerfile
FROM eclipse-temurin:21-jre
COPY target/*.jar app.jar
COPY src/main/resources/*   config/
ENTRYPOINT ["java","-jar","/app.jar"]
```

**问题：**
1. jar 包被复制到 `/app.jar`（根目录）
2. 资源文件被复制到 `/config/`（根目录下的 config 文件夹）
3. jar 包**无法自动找到** `/config/` 目录下的文件

### 1.2 为什么找不到？

**Spring Boot jar 包的资源查找顺序：**

```
1. jar 包内部：/BOOT-INF/classes/（优先级最低）
2. jar 包同级目录：./config/（优先级高）
3. jar 包同级目录：./（优先级高）
4. classpath 根路径
```

**你的目录结构：**
```
/
├── app.jar          # jar 包在根目录
└── config/          # config 也在根目录
    └── application.yml
```

虽然 config 和 app.jar 都在根目录，但是：
- 执行 `java -jar /app.jar` 时，工作目录是 `/`
- Spring Boot 会查找 `/config/` 目录（这个是对的）
- **但是**，你复制的是 `src/main/resources/*`，这些文件在构建时已经被打包进 jar 包了
- 重复复制这些文件是**没有意义**的

---

## 二、正确的做法

### 2.1 方案一：不复制资源文件（推荐）

**最简单的做法：不需要复制资源文件**

```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app

# 只复制 jar 包，资源文件已经在 jar 包内部了
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

**说明：**
- Maven/Gradle 构建时，`src/main/resources/` 下的所有文件都会被打包进 jar 包
- jar 包内部路径：`/BOOT-INF/classes/application.yml`
- 不需要额外复制

---

### 2.2 方案二：外部配置文件覆盖（生产环境推荐）

**如果你想用外部配置文件覆盖 jar 包内部的配置：**

```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app

# 复制 jar 包
COPY target/*.jar app.jar

# 创建 config 目录（可选，用于挂载外部配置）
RUN mkdir -p config

EXPOSE 8080

# Spring Boot 会自动查找 ./config/ 目录下的配置文件
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**运行容器时挂载外部配置：**

```bash
docker run -d \
  -p 8080:8080 \
  -v /path/to/config:/app/config \
  myapp:1.0
```

**目录结构：**
```
/app/
├── app.jar
└── config/              # 外部挂载的配置目录
    └── application.yml  # 会覆盖 jar 包内部的配置
```

---

### 2.3 方案三：指定配置文件位置

**使用 Spring Boot 参数指定配置文件位置：**

```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY target/*.jar app.jar

# 创建配置目录
RUN mkdir -p /config

EXPOSE 8080

# 使用 spring.config.location 指定配置文件位置
ENTRYPOINT ["java", "-jar", "app.jar", \
    "--spring.config.location=classpath:/,file:/config/"]
```

**说明：**
- `classpath:/`：从 jar 包内部加载
- `file:/config/`：从外部 /config/ 目录加载
- 外部配置会覆盖内部配置

---

### 2.4 方案四：多环境配置（最佳实践）

```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY target/*.jar app.jar

# 创建配置和日志目录
RUN mkdir -p config logs

# 设置环境变量
ENV SPRING_PROFILES_ACTIVE=prod

EXPOSE 8080

# 使用环境变量和外部配置
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar \
    --spring.profiles.active=${SPRING_PROFILES_ACTIVE} \
    --spring.config.additional-location=file:/app/config/"]
```

**运行不同环境：**

```bash
# 开发环境
docker run -d -e SPRING_PROFILES_ACTIVE=dev myapp:1.0

# 测试环境
docker run -d -e SPRING_PROFILES_ACTIVE=test myapp:1.0

# 生产环境（挂载外部配置）
docker run -d \
  -e SPRING_PROFILES_ACTIVE=prod \
  -v /path/to/prod-config:/app/config \
  myapp:1.0
```

---

## 三、Spring Boot 配置文件加载优先级

### 3.1 完整的加载顺序（从高到低）

```
1. 命令行参数
   java -jar app.jar --server.port=8081

2. 环境变量
   SPRING_APPLICATION_JSON='{"server.port":8081}'

3. 外部配置文件（jar 包外部）
   - file:./config/application.yml
   - file:./application.yml

4. 内部配置文件（jar 包内部）
   - classpath:/config/application.yml
   - classpath:/application.yml

5. @PropertySource 注解
6. 默认属性
```

### 3.2 实际示例

**jar 包内部配置（application.yml）：**
```yaml
server:
  port: 8080
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/dev_db
```

**外部配置（/app/config/application.yml）：**
```yaml
spring:
  datasource:
    url: jdbc:mysql://prod-db:3306/prod_db
```

**最终生效的配置：**
```yaml
server:
  port: 8080                                    # 来自 jar 包内部
spring:
  datasource:
    url: jdbc:mysql://prod-db:3306/prod_db    # 来自外部配置（覆盖）
```

---

## 四、常见场景和解决方案

### 4.1 场景一：开发环境（本地测试）

**需求：** 快速构建和测试

```dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**使用：**
```bash
mvn clean package
docker build -t myapp:dev .
docker run -p 8080:8080 myapp:dev
```

---

### 4.2 场景二：生产环境（需要外部配置）

**需求：** 配置文件不打包进镜像，通过挂载提供

```dockerfile
FROM eclipse-temurin:21-jre

WORKDIR /app

COPY target/*.jar app.jar

RUN mkdir -p config logs

ENV JAVA_OPTS="-Xmx1024m -Xms512m"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**使用：**
```bash
# 准备外部配置文件
mkdir -p /data/myapp/config
cat > /data/myapp/config/application.yml <<EOF
spring:
  datasource:
    url: jdbc:mysql://prod-db:3306/prod_db
    username: prod_user
    password: prod_pass
EOF

# 运行容器
docker run -d \
  -p 8080:8080 \
  -v /data/myapp/config:/app/config \
  -v /data/myapp/logs:/app/logs \
  -e JAVA_OPTS="-Xmx2048m" \
  myapp:prod
```

---

### 4.3 场景三：K8s 部署（使用 ConfigMap）

**创建 ConfigMap：**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  application.yml: |
    spring:
      datasource:
        url: jdbc:mysql://mysql-service:3306/prod_db
    server:
      port: 8080
```

**Deployment 配置：**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        volumeMounts:
        - name: config
          mountPath: /app/config
      volumes:
      - name: config
        configMap:
          name: myapp-config
```

---

## 五、总结

### 5.1 你的问题的答案

**问：** `COPY src/main/resources/* config/` 这样 jar 包可以找到吗？

**答：**
1. ❌ **不需要这样做**，因为资源文件已经在 jar 包内部了
2. ❌ 重复复制是浪费空间
3. ✅ 如果想要外部配置覆盖，应该在**运行时挂载**，而不是在构建时复制

### 5.2 推荐的做法

**开发环境：**
```dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**生产环境：**
```dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/*.jar app.jar
RUN mkdir -p config logs
ENV JAVA_OPTS="-Xmx1024m -Xms512m"
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**运行时挂载配置：**
```bash
docker run -d \
  -p 8080:8080 \
  -v /path/to/config:/app/config \
  -v /path/to/logs:/app/logs \
  myapp:1.0
```

### 5.3 关键点

1. ✅ jar 包已经包含了所有资源文件，不需要额外复制
2. ✅ 外部配置应该通过**挂载**提供，不是在构建时复制
3. ✅ Spring Boot 会自动查找 `./config/` 目录下的配置文件
4. ✅ 外部配置会覆盖 jar 包内部的配置
5. ✅ 使用 ConfigMap（K8s）或 Volume（Docker）管理配置文件
