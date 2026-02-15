# Jenkins + Kubernetes + Kaniko 完整配置指南

## 概述

本文档记录了在 RKE2 Kubernetes 集群中配置 Jenkins 流水线，使用 Kaniko 构建 Docker 镜像并推送到私有 Registry 的完整过程。

## 架构说明

```
Jenkins Master (K8s Pod)
    ↓
动态创建 K8s Pod (Maven + Kaniko 容器)
    ↓
构建产物通过 PVC 共享
    ↓
Kaniko 构建镜像 → 推送到私有 Registry (通过 Nginx 反向代理)
```

## 核心组件版本

- **Jenkins**: 部署在 Kubernetes 中
- **Kubernetes**: RKE2
- **Maven**: 3.9-eclipse-temurin-21
- **Kaniko**: gcr.io/kaniko-project/executor:debug (通过 DaoCloud 镜像)
- **Java**: 21 (Eclipse Temurin)
- **Docker Registry**: 2.x
- **Nginx**: alpine

---

## 一、私有 Docker Registry 配置

### 1.1 关键配置要点

#### Registry 环境变量
```yaml
env:
- name: REGISTRY_STORAGE_DELETE_ENABLED
  value: "true"
- name: REGISTRY_HTTP_ADDR
  value: "0.0.0.0:5000"
- name: REGISTRY_HTTP_HOST
  value: "http://192.168.80.100:30500"  # ⚠️ 关键：外部访问地址
```

**为什么需要 REGISTRY_HTTP_HOST？**
- Registry 在返回上传 Location 头时需要知道自己的外部地址
- 如果不配置，会返回内部地址，导致 Kaniko 推送时 404 错误
- 必须包含完整的协议、IP 和端口

#### Nginx 反向代理配置
```nginx
http {
    # ⚠️ 关键：全局配置，对所有 location 生效
    client_max_body_size 0;           # 无限制上传大小
    proxy_request_buffering off;      # 禁用缓冲，流式传输
    
    upstream registry {
        server docker-registry.docker-registry.svc.cluster.local:5000;
    }
    
    server {
        listen 80;
        chunked_transfer_encoding on;
        
        location /v2 {
            proxy_pass http://registry/v2;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # CORS 头（用于 Web UI）
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization,Accept,Cache-Control,Content-Type' always;
            add_header 'Access-Control-Expose-Headers' 'Docker-Content-Digest' always;
            
            if ($request_method = 'OPTIONS') {
                return 204;
            }
        }
    }
}
```

**常见问题排查：**

1. **413 Request Entity Too Large**
   - 原因：`client_max_body_size` 限制太小（默认 1MB）
   - 解决：设置为 `0`（无限制）
   - 位置：必须在 `http` 块中，确保对所有 location 生效

2. **404 Not Found (推送时)**
   - 原因：Registry 返回的 Location 头缺少端口号
   - 解决：配置 `REGISTRY_HTTP_HOST` 环境变量

3. **配置更新不生效**
   - 原因：ConfigMap 更新后 Pod 不会自动重载
   - 解决：删除 Pod 重建或执行 `nginx -s reload`

### 1.2 验证配置

```bash
# 1. 检查 Nginx 配置
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -T | grep client_max_body_size

# 2. 检查 Registry 环境变量
kubectl exec -n docker-registry deployment/docker-registry -- env | grep REGISTRY

# 3. 测试 API
curl -v http://192.168.80.100:30500/v2/
```

---

## 二、RKE2 镜像加速配置

### 2.1 配置文件位置
`/etc/rancher/rke2/registries.yaml`

### 2.2 配置内容
```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://m.daocloud.io"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://hub-mirror.c.163.com"
  
  gcr.io:
    endpoint:
      - "https://m.daocloud.io/gcr.io"
  
  registry.k8s.io:
    endpoint:
      - "https://m.daocloud.io/registry.k8s.io"

configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true
```

### 2.3 应用配置
```bash
# 重启 RKE2 服务
systemctl restart rke2-server

# 验证配置
crictl info | grep -A 20 registry
```

---

## 三、Jenkins Kubernetes Cloud 配置

### 3.1 关键配置项

| 配置项 | 值 | 说明 |
|--------|-----|------|
| Jenkins URL | `http://jenkins.jenkins.svc.cluster.local:8080` | 集群内部地址 |
| Jenkins tunnel | **必须留空** | ⚠️ 关键：WebSocket 模式下不能配置 |
| WebSocket | ☑ 必须启用 | Kubernetes 环境的唯一可用模式 |
| Pod Labels | `jenkins=slave` | 用于识别 agent Pod |

**为什么必须使用 WebSocket 模式？**

在 Kubernetes 环境中，Jenkins 和 agent Pod 都运行在容器中：

1. **Tunnel 模式的问题：**
   - 需要 Jenkins 暴露额外的 TCP 端口（默认 50000）
   - 动态创建的 agent Pod 难以访问这个端口
   - 需要额外的 Service 和网络配置
   - 不适合容器化环境

2. **WebSocket 模式的优势：**
   - 复用 Jenkins HTTP 端口（8080），无需额外端口
   - 通过 Kubernetes Service 自动路由
   - 适合动态 Pod 环境
   - 配置简单，无需额外网络策略

**配置步骤：**

1. 进入 Jenkins 管理界面
2. 系统管理 → 节点管理 → Configure Clouds
3. 添加或编辑 Kubernetes Cloud
4. 配置如下：
   ```
   Name: kubernetes
   Kubernetes URL: https://kubernetes.default.svc.cluster.local
   Kubernetes Namespace: jenkins
   Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
   Jenkins tunnel: [留空，不填任何内容]
   ☑ WebSocket
   ```

**常见错误：**
- ❌ 同时配置 tunnel 和 WebSocket → 报错 "Tunneling is not currently supported in WebSocket mode"
- ❌ 只配置 tunnel 不配置 WebSocket → agent Pod 无法连接
- ✅ 只配置 WebSocket，tunnel 留空 → 正确配置

### 3.2 全局 jnlp 镜像配置

在 Kubernetes Cloud 配置中设置 Pod Template：
- Name: `default`
- Container Template:
  - Name: `jnlp`
  - Docker image: `jenkins/inbound-agent:3355.v388858a_47b_33-3-jdk21`

---

## 四、Jenkinsfile 配置详解

### 4.1 整体架构

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
            # 定义包含 Maven 和 Kaniko 的 Pod
            """
        }
    }
    
    stages {
        // 所有阶段在同一个 Pod 中执行
        stage('Maven 构建') {
            steps {
                container('maven') {
                    // Maven 构建
                }
            }
        }
        
        stage('Kaniko 构建镜像') {
            steps {
                container('kaniko') {
                    // 构建并推送镜像
                }
            }
        }
    }
}
```

### 4.2 Pod YAML 配置

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
    version: v6
spec:
  containers:
  # Maven 容器
  - name: maven
    image: maven:3.9-eclipse-temurin-21
    command:
    - cat
    tty: true
    volumeMounts:
    - name: jenkins-home
      mountPath: /var/jenkins_home    # 挂载 Jenkins PVC
    - name: maven-cache
      mountPath: /root/.m2            # Maven 本地仓库
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2000m
        memory: 2Gi
  
  # Kaniko 容器
  - name: kaniko
    image: m.daocloud.io/gcr.io/kaniko-project/executor:debug
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: jenkins-home
      mountPath: /var/jenkins_home    # 共享 PVC，访问构建产物
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 2000m
        memory: 2Gi
  
  volumes:
  - name: jenkins-home
    persistentVolumeClaim:
      claimName: jenkins-pvc          # ⚠️ 使用实际的 PVC 名称
  - name: maven-cache
    emptyDir: {}                      # 临时缓存，Pod 重启后清空
```

**关键点：**
1. **共享 PVC**：Maven 和 Kaniko 都挂载 `jenkins-pvc`，实现文件共享
2. **无需 stash/unstash**：通过 PVC 直接共享，更高效
3. **镜像使用 DaoCloud 镜像**：避免 gcr.io 访问问题

### 4.3 Maven 构建阶段

```groovy
stage('Maven 构建') {
    steps {
        container('maven') {
            script {
                def cleanCmd = params.CLEAN_BUILD ? 'clean' : ''
                def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''

                sh """
                    echo ">>> 下载依赖"
                    mvn dependency:go-offline -B ${skipTests}
                    
                    echo ">>> 编译打包"
                    mvn ${cleanCmd} package -B ${skipTests}
                    
                    echo ">>> 查看构建产物"
                    ls -lh target/*.jar
                """
            }
        }
    }
}
```

**Maven 依赖缓存：**
- 缓存位置：`/root/.m2`（挂载 emptyDir）
- 生命周期：Pod 级别，Pod 删除后清空
- 优化：可以改用 PVC 持久化缓存

### 4.4 Kaniko 构建阶段

```groovy
stage('构建并推送 Docker 镜像') {
    when {
        expression { params.BUILD_DOCKER_IMAGE }
    }
    steps {
        container('kaniko') {
            script {
                sh """
                    # 验证文件存在
                    ls -lh ${WORKSPACE}/target/*.jar
                    ls -lh ${WORKSPACE}/Dockerfile
                    
                    # 使用 Kaniko 构建并推送
                    /kaniko/executor \\
                        --context=${WORKSPACE} \\
                        --dockerfile=${WORKSPACE}/Dockerfile \\
                        --destination=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \\
                        --destination=${DOCKER_IMAGE_NAME}:latest \\
                        --insecure \\
                        --skip-tls-verify \\
                        --cache=true \\
                        --cache-ttl=24h
                """
            }
        }
    }
}
```

**Kaniko 参数说明：**
- `--context`: 构建上下文目录（包含 Dockerfile 和构建产物）
- `--dockerfile`: Dockerfile 路径
- `--destination`: 目标镜像（可以多个）
- `--insecure`: 允许 HTTP Registry
- `--skip-tls-verify`: 跳过 TLS 验证
- `--cache`: 启用层缓存
- `--cache-ttl`: 缓存有效期

---

## 五、Dockerfile 配置

### 5.1 单阶段 Dockerfile

```dockerfile
# 使用 Eclipse Temurin Java 21 JRE
FROM eclipse-temurin:21-jre-alpine

# 设置时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 创建应用目录
WORKDIR /app

# 复制已构建的 jar 包
COPY target/*.jar app.jar

# 创建非 root 用户
RUN addgroup -S appuser && adduser -S appuser -G appuser
RUN chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

**为什么使用单阶段？**
- Maven 构建已在流水线中完成
- Dockerfile 只需要复制 JAR 并运行
- 减少镜像层数，简化构建

**镜像选择：**
- ✅ `eclipse-temurin:21-jre-alpine` - 官方支持，体积小
- ❌ `openjdk:21-jre-slim` - 已废弃，不可用
- ❌ `openjdk:11-jre-slim` - 版本不匹配

---

## 六、完整流程图

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Jenkins 触发构建                                          │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Kubernetes Plugin 创建 Pod                                │
│    - Maven 容器 (maven:3.9-eclipse-temurin-21)              │
│    - Kaniko 容器 (kaniko-project/executor:debug)            │
│    - 共享 PVC (jenkins-pvc)                                  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Maven 容器执行构建                                        │
│    - 代码检出                                                │
│    - mvn package                                             │
│    - 产物保存到 ${WORKSPACE}/target/*.jar                    │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Kaniko 容器构建镜像                                       │
│    - 从 ${WORKSPACE} 读取 Dockerfile 和 JAR                 │
│    - 构建镜像                                                │
│    - 推送到 192.168.80.100:30500                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. 镜像推送流程                                              │
│    Kaniko → Nginx (30500) → Docker Registry (5000)          │
│    - Nginx 处理大文件上传 (client_max_body_size 0)          │
│    - Registry 返回正确的 Location 头 (REGISTRY_HTTP_HOST)   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. 构建完成                                                  │
│    - 镜像: 192.168.80.100:30500/demo-springboot:BUILD_NUM   │
│    - 镜像: 192.168.80.100:30500/demo-springboot:latest      │
└─────────────────────────────────────────────────────────────┘
```

---

## 七、常见问题排查

### 7.1 jnlp 容器连接问题

**症状：**
```
Tunneling is not currently supported in WebSocket mode
```

**原因分析：**
- Jenkins Kubernetes Plugin 支持两种 agent 连接模式：
  1. **Jenkins tunnel** (JNLP TCP 模式) - 需要额外的 TCP 端口（默认 50000）
  2. **WebSocket** - 通过 HTTP/HTTPS 连接，无需额外端口
- 这两种模式**互斥**，不能同时使用
- 在 Kubernetes 环境中，**必须使用 WebSocket 模式**，原因：
  - Jenkins 部署在 K8s 中，动态 Pod 无法访问 Jenkins 的 TCP tunnel 端口
  - WebSocket 通过 Jenkins Service 的 HTTP 端口通信，更适合容器环境
  - 无需配置额外的 Service 端口和网络策略

**错误配置示例：**
```
Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
Jenkins tunnel: jenkins.jenkins.svc.cluster.local:50000  ❌ 错误
WebSocket: ☑ 启用
```
→ 报错：Tunneling is not currently supported in WebSocket mode

**正确配置：**
1. 进入 Jenkins → 系统管理 → 节点管理 → Configure Clouds
2. 找到 Kubernetes Cloud 配置
3. 设置 Jenkins URL: `http://jenkins.jenkins.svc.cluster.local:8080`
4. ✅ 勾选 "WebSocket"
5. ❌ **Jenkins tunnel 字段必须留空**（不填任何内容）
6. 保存配置

**为什么必须用 WebSocket？**
- Jenkins 在 K8s 中运行，agent Pod 通过 Service 访问 Jenkins
- WebSocket 复用 HTTP 端口（8080），无需额外配置
- Tunnel 模式需要暴露 50000 端口，且动态 Pod 难以访问
- WebSocket 是 Kubernetes 环境的推荐方式

**验证配置：**
```bash
# 查看 Jenkins Service 端口
kubectl get svc -n jenkins

# 应该只有 8080 端口，不需要 50000
NAME      TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
jenkins   NodePort   10.43.xxx.xxx   <none>        8080:30080/TCP   1d
```

### 7.2 Maven 找不到

**症状：**
```
mvn: not found
```

**原因：**
- 使用了 `agent any` 或 `agent { label 'built-in' }`
- 实际执行在没有 Maven 的容器中

**解决：**
- 使用 `agent { kubernetes { ... } }` 定义包含 Maven 的 Pod
- 在 `container('maven')` 块中执行 Maven 命令

### 7.3 镜像推送 413 错误

**症状：**
```
unexpected status code 413 Request Entity Too Large
```

**原因：**
- Nginx `client_max_body_size` 限制太小

**解决：**
```nginx
http {
    client_max_body_size 0;           # 设置为 0（无限制）
    proxy_request_buffering off;      # 禁用缓冲
}
```

**验证：**
```bash
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -T | grep client_max_body_size
```

### 7.4 镜像推送 404 错误

**症状：**
```
PATCH http://192.168.80.100/v2/demo-springboot/blobs/uploads/...: 404 Not Found
```

**原因：**
- URL 缺少端口号
- Registry 不知道自己的外部地址

**解决：**
```yaml
env:
- name: REGISTRY_HTTP_HOST
  value: "http://192.168.80.100:30500"  # 包含完整地址和端口
```

**验证：**
```bash
kubectl exec -n docker-registry deployment/docker-registry -- env | grep REGISTRY_HTTP_HOST
```

### 7.5 Kaniko 拉取镜像失败

**症状：**
```
failed to pull image: Get https://gcr.io/...: dial tcp: i/o timeout
```

**原因：**
- gcr.io 在国内无法访问

**解决：**
- 使用 DaoCloud 镜像：`m.daocloud.io/gcr.io/kaniko-project/executor:debug`
- 配置 RKE2 镜像加速（见第二节）

### 7.6 ConfigMap 更新不生效

**症状：**
- 修改了 ConfigMap，但 Nginx 配置没变

**原因：**
- Pod 不会自动重载 ConfigMap

**解决：**
```bash
# 方式 1: 删除 Pod（推荐）
kubectl delete pod -n docker-registry -l app=nginx-proxy

# 方式 2: 在容器内重载
kubectl exec -n docker-registry deployment/nginx-proxy -- nginx -s reload
```

---

## 八、性能优化建议

### 8.1 Maven 依赖缓存持久化

当前配置使用 `emptyDir`，Pod 重启后缓存丢失。

**优化方案：**
```yaml
volumes:
- name: maven-cache
  persistentVolumeClaim:
    claimName: maven-cache-pvc  # 创建专用 PVC
```

### 8.2 Kaniko 缓存优化

```bash
/kaniko/executor \
    --cache=true \
    --cache-ttl=168h \              # 增加缓存时间到 7 天
    --cache-repo=192.168.80.100:30500/cache  # 使用 Registry 缓存
```

### 8.3 并行构建

如果有多个模块，可以使用 Maven 并行构建：
```bash
mvn -T 4 package  # 使用 4 个线程
```

---

## 九、安全建议

### 9.1 使用 HTTPS

生产环境应该配置 TLS：
```yaml
env:
- name: REGISTRY_HTTP_TLS_CERTIFICATE
  value: "/certs/domain.crt"
- name: REGISTRY_HTTP_TLS_KEY
  value: "/certs/domain.key"
```

### 9.2 启用认证

配置 Registry 基本认证：
```yaml
env:
- name: REGISTRY_AUTH
  value: "htpasswd"
- name: REGISTRY_AUTH_HTPASSWD_PATH
  value: "/auth/htpasswd"
- name: REGISTRY_AUTH_HTPASSWD_REALM
  value: "Registry Realm"
```

### 9.3 限制资源

为容器设置合理的资源限制：
```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 2Gi
```

---

## 十、维护命令

### 10.1 查看日志

```bash
# Jenkins
kubectl logs -n jenkins deployment/jenkins -f

# Registry
kubectl logs -n docker-registry deployment/docker-registry -f

# Nginx
kubectl logs -n docker-registry deployment/nginx-proxy -f

# 构建 Pod
kubectl logs -n jenkins <pod-name> -c maven
kubectl logs -n jenkins <pod-name> -c kaniko
```

### 10.2 清理镜像

```bash
# 列出所有镜像
curl http://192.168.80.100:30500/v2/_catalog

# 列出镜像标签
curl http://192.168.80.100:30500/v2/demo-springboot/tags/list

# 删除镜像（需要启用 REGISTRY_STORAGE_DELETE_ENABLED）
# 1. 获取 digest
curl -I -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
  http://192.168.80.100:30500/v2/demo-springboot/manifests/latest

# 2. 删除
curl -X DELETE http://192.168.80.100:30500/v2/demo-springboot/manifests/<digest>

# 3. 垃圾回收
kubectl exec -n docker-registry deployment/docker-registry -- \
  registry garbage-collect /etc/docker/registry/config.yml
```

### 10.3 备份 Registry

```bash
# 备份 Registry 数据
kubectl exec -n docker-registry deployment/docker-registry -- \
  tar czf /tmp/registry-backup.tar.gz /var/lib/registry

kubectl cp docker-registry/<pod-name>:/tmp/registry-backup.tar.gz \
  ./registry-backup-$(date +%Y%m%d).tar.gz
```

---

## 十一、参考资料

- [Kaniko 官方文档](https://github.com/GoogleContainerTools/kaniko)
- [Docker Registry 配置](https://docs.docker.com/registry/configuration/)
- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Nginx 反向代理配置](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)

---

## 附录：完整配置文件清单

1. `registry-with-proxy.yaml` - Registry + Nginx + UI 完整部署
2. `Jenkinsfile-k8s` - Jenkins 流水线配置
3. `Dockerfile` - Spring Boot 应用镜像
4. `rke2-registries.yaml` - RKE2 镜像加速配置
5. `pom.xml` - Maven 项目配置

---

**文档版本**: v1.0  
**最后更新**: 2026-02-15  
**状态**: ✅ 已验证可用
