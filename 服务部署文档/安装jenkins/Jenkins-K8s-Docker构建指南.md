# Jenkins 在 Kubernetes 中构建 Docker 镜像指南

## 一、问题说明

在 Kubernetes 中运行的 Jenkins Pod 默认无法构建 Docker 镜像，因为：
1. Pod 内没有 Docker daemon
2. 没有权限访问宿主机的 Docker socket

## 二、解决方案

### 方案 1：Docker in Docker (DinD) - 推荐

使用 Docker in Docker 容器作为 sidecar。

#### 1. 创建 Jenkins 部署配置

```yaml
# jenkins-with-docker.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 20Gi

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccountName: jenkins
      securityContext:
        fsGroup: 1000
      containers:
      # Jenkins 容器
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 50000
          name: agent
        env:
        - name: DOCKER_HOST
          value: "tcp://localhost:2375"
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
      
      # Docker in Docker 容器
      - name: dind
        image: docker:24-dind
        securityContext:
          privileged: true
        env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
        volumeMounts:
        - name: docker-storage
          mountPath: /var/lib/docker
        resources:
          requests:
            cpu: 500m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 2Gi
      
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
      - name: docker-storage
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
    name: http
  - port: 50000
    targetPort: 50000
    nodePort: 30050
    name: agent
  selector:
    app: jenkins
```

#### 2. 部署 Jenkins

```bash
# 部署
kubectl apply -f jenkins-with-docker.yaml

# 查看状态
kubectl get pods -n jenkins

# 查看日志
kubectl logs -f -n jenkins <pod-name> -c jenkins

# 获取初始密码
kubectl exec -n jenkins <pod-name> -c jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

#### 3. 配置私有仓库访问

```bash
# 进入 Jenkins 容器
kubectl exec -it -n jenkins <pod-name> -c jenkins -- bash

# 配置 insecure-registry（在 dind 容器中）
kubectl exec -it -n jenkins <pod-name> -c dind -- sh

# 创建 daemon.json
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.80.100:30500"]
}
EOF

# 重启 Docker（dind 会自动重启）
exit
```

### 方案 2：挂载宿主机 Docker Socket

直接使用宿主机的 Docker daemon。

#### 1. 创建 Jenkins 部署配置

```yaml
# jenkins-host-docker.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 20Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      securityContext:
        fsGroup: 1000
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
        - containerPort: 50000
        volumeMounts:
        - name: jenkins-home
          mountPath: /var/jenkins_home
        - name: docker-sock
          mountPath: /var/run/docker.sock
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 4Gi
      
      volumes:
      - name: jenkins-home
        persistentVolumeClaim:
          claimName: jenkins-pvc
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
          type: Socket

---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: jenkins
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
  - port: 50000
    targetPort: 50000
    nodePort: 30050
  selector:
    app: jenkins
```

#### 2. 安装 Docker 客户端

```bash
# 进入 Jenkins 容器
kubectl exec -it -n jenkins <pod-name> -- bash

# 安装 Docker 客户端
apt-get update
apt-get install -y docker.io

# 添加 jenkins 用户到 docker 组
usermod -aG docker jenkins

# 退出并重启 Pod
exit
kubectl delete pod -n jenkins <pod-name>
```

### 方案 3：使用 Kaniko（无需 Docker）

Kaniko 可以在 Kubernetes 中构建镜像，无需 Docker daemon。

#### 1. 修改 Jenkinsfile

```groovy
stage('构建 Docker 镜像 - Kaniko') {
    when {
        expression { params.BUILD_DOCKER_IMAGE }
    }
    steps {
        script {
            echo "=== 使用 Kaniko 构建镜像 ==="
            
            sh """
                # 创建 Kaniko 配置
                cat > /tmp/kaniko-config.json <<EOF
{
  "auths": {
    "${DOCKER_REGISTRY}": {
      "auth": ""
    }
  }
}
EOF

                # 使用 Kaniko 构建
                kubectl run kaniko-build-${BUILD_NUMBER} \\
                  --image=gcr.io/kaniko-project/executor:latest \\
                  --restart=Never \\
                  --overrides='{
                    "spec": {
                      "containers": [{
                        "name": "kaniko",
                        "image": "gcr.io/kaniko-project/executor:latest",
                        "args": [
                          "--dockerfile=Dockerfile",
                          "--context=dir:///workspace",
                          "--destination=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}",
                          "--insecure",
                          "--skip-tls-verify"
                        ],
                        "volumeMounts": [{
                          "name": "workspace",
                          "mountPath": "/workspace"
                        }]
                      }],
                      "volumes": [{
                        "name": "workspace",
                        "hostPath": {
                          "path": "${WORKSPACE}"
                        }
                      }]
                    }
                  }'
                
                # 等待构建完成
                kubectl wait --for=condition=complete --timeout=600s pod/kaniko-build-${BUILD_NUMBER}
                
                # 清理
                kubectl delete pod kaniko-build-${BUILD_NUMBER}
            """
        }
    }
}
```

## 三、配置私有仓库

### 1. 配置 insecure-registry

**方案 1 (DinD)：**
```bash
# 在 dind 容器中配置
kubectl exec -it -n jenkins <pod-name> -c dind -- sh

mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.80.100:30500"]
}
EOF

# 重启 dind 容器
kubectl delete pod -n jenkins <pod-name>
```

**方案 2 (宿主机 Docker)：**
```bash
# 在所有 RKE2 节点上配置
sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["192.168.80.100:30500"]
}
EOF

sudo systemctl restart docker
```

### 2. 测试 Docker 连接

```bash
# 进入 Jenkins 容器
kubectl exec -it -n jenkins <pod-name> -c jenkins -- bash

# 测试 Docker
docker version
docker info

# 测试推送
docker pull nginx:alpine
docker tag nginx:alpine 192.168.80.100:30500/test:latest
docker push 192.168.80.100:30500/test:latest
```

## 四、验证构建

### 1. 创建测试任务

在 Jenkins 中创建流水线任务，使用 Jenkinsfile-git。

### 2. 执行构建

```bash
# 点击 "Build with Parameters"
# 勾选 "BUILD_DOCKER_IMAGE"
# 勾选 "PUSH_TO_REGISTRY"
# 点击 "开始构建"
```

### 3. 查看构建日志

应该看到：
```
>>> 构建 Docker 镜像
Sending build context to Docker daemon...
Step 1/8 : FROM openjdk:11-jre-slim
...
Successfully built abc123def456
Successfully tagged 192.168.80.100:30500/demo-springboot:123

>>> 推送镜像
The push refers to repository [192.168.80.100:30500/demo-springboot]
...
123: digest: sha256:... size: 1234
```

### 4. 验证镜像

```bash
# 查看私有仓库
curl http://192.168.80.100:30500/v2/_catalog

# 查看镜像标签
curl http://192.168.80.100:30500/v2/demo-springboot/tags/list

# 拉取镜像测试
docker pull 192.168.80.100:30500/demo-springboot:latest
```

## 五、常见问题

### 1. Docker 命令找不到

**错误：**
```
docker: command not found
```

**解决：**
- 方案 1：检查 DOCKER_HOST 环境变量
- 方案 2：安装 Docker 客户端
- 方案 3：使用 Kaniko

### 2. 权限不足

**错误：**
```
permission denied while trying to connect to the Docker daemon socket
```

**解决：**
```bash
# 添加 jenkins 用户到 docker 组
kubectl exec -n jenkins <pod-name> -- usermod -aG docker jenkins

# 重启 Pod
kubectl delete pod -n jenkins <pod-name>
```

### 3. 推送镜像失败

**错误：**
```
http: server gave HTTP response to HTTPS client
```

**解决：**
配置 insecure-registry（见上文）

### 4. DinD 容器启动失败

**错误：**
```
failed to start daemon: error initializing graphdriver
```

**解决：**
```yaml
# 添加 privileged: true
securityContext:
  privileged: true
```

## 六、性能优化

### 1. 使用 Docker 缓存

```yaml
# 挂载 Docker 缓存
volumes:
- name: docker-cache
  hostPath:
    path: /var/lib/docker
    type: DirectoryOrCreate

volumeMounts:
- name: docker-cache
  mountPath: /var/lib/docker
```

### 2. 使用镜像加速

```json
{
  "insecure-registries": ["192.168.80.100:30500"],
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

### 3. 限制并发构建

```groovy
options {
    disableConcurrentBuilds()
}
```

## 七、推荐配置

综合考虑，推荐使用**方案 1 (Docker in Docker)**：

优点：
- ✅ 隔离性好
- ✅ 不影响宿主机
- ✅ 易于管理
- ✅ 支持多租户

缺点：
- ❌ 需要 privileged 权限
- ❌ 资源占用较多

部署命令：
```bash
kubectl apply -f jenkins-with-docker.yaml
kubectl get pods -n jenkins -w
```

访问地址：
```
http://<节点IP>:30080
```
