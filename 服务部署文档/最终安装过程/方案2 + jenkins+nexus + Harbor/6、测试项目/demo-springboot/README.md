# Demo Spring Boot 项目

简单的 Spring Boot 示例项目，用于演示 Docker 镜像构建和推送。

## 项目结构

```
demo-springboot/
├── pom.xml                          # Maven 配置
├── Dockerfile                       # 多阶段构建 Dockerfile
├── Dockerfile.simple                # 简单版 Dockerfile
├── .dockerignore                    # Docker 忽略文件
├── src/
│   └── main/
│       ├── java/
│       │   └── com/example/demo/
│       │       ├── DemoApplication.java
│       │       └── controller/
│       │           └── HelloController.java
│       └── resources/
│           └── application.yml
└── README.md
```

## 本地开发

### 1. 编译项目
```bash
mvn clean package
```

### 2. 运行项目
```bash
java -jar target/demo-springboot.jar
```

### 3. 测试接口
```bash
# Hello 接口
curl http://localhost:8080/api/hello

# 健康检查
curl http://localhost:8080/api/health
curl http://localhost:8080/actuator/health
```

## Docker 构建

### 方式 1: 多阶段构建（推荐）
```bash
# 构建镜像（包含编译过程）
docker build -t demo-springboot:latest .

# 运行容器
docker run -d -p 8080:8080 --name demo-app demo-springboot:latest
```

### 方式 2: 简单构建（需要先编译）
```bash
# 先编译
mvn clean package

# 使用简单 Dockerfile 构建
docker build -f Dockerfile.simple -t demo-springboot:latest .

# 运行容器
docker run -d -p 8080:8080 --name demo-app demo-springboot:latest
```

## 推送到私有仓库

### 1. 配置 Docker 信任私有仓库
```bash
# 编辑 /etc/docker/daemon.json
{
  "insecure-registries": ["192.168.80.100:30500"]
}

# 重启 Docker
systemctl restart docker
```

### 2. 打标签并推送
```bash
# 打标签
docker tag demo-springboot:latest 192.168.80.100:30500/demo-springboot:latest
docker tag demo-springboot:latest 192.168.80.100:30500/demo-springboot:1.0.0

# 推送到私有仓库
docker push 192.168.80.100:30500/demo-springboot:latest
docker push 192.168.80.100:30500/demo-springboot:1.0.0
```

### 3. 从私有仓库拉取
```bash
docker pull 192.168.80.100:30500/demo-springboot:latest
```

## Jenkins 集成

在 Jenkinsfile 中使用：

```groovy
stage('构建 Docker 镜像') {
    steps {
        sh '''
            cd demo-springboot
            docker build -t 192.168.80.100:30500/demo-springboot:${BUILD_NUMBER} .
            docker tag 192.168.80.100:30500/demo-springboot:${BUILD_NUMBER} \\
                       192.168.80.100:30500/demo-springboot:latest
        '''
    }
}

stage('推送镜像') {
    steps {
        sh '''
            docker push 192.168.80.100:30500/demo-springboot:${BUILD_NUMBER}
            docker push 192.168.80.100:30500/demo-springboot:latest
        '''
    }
}
```

## K8s 部署

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-springboot
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo-springboot
  template:
    metadata:
      labels:
        app: demo-springboot
    spec:
      containers:
      - name: app
        image: 192.168.80.100:30500/demo-springboot:latest
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: demo-springboot
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
  selector:
    app: demo-springboot
```

## 环境变量配置

可以通过环境变量覆盖配置：

```bash
docker run -d -p 8080:8080 \
  -e SERVER_PORT=9090 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e JAVA_OPTS="-Xms512m -Xmx1024m" \
  demo-springboot:latest
```

## 日志查看

```bash
# 查看容器日志
docker logs -f demo-app

# 进入容器
docker exec -it demo-app sh
```
