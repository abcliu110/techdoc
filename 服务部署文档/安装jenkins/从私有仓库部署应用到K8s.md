# 从私有 Docker Registry 部署应用到 Kubernetes

## 概述

本文档说明如何从私有 Docker Registry (`192.168.80.100:30500`) 拉取镜像并部署到 RKE2 Kubernetes 集群。

---

## 一、配置节点访问私有仓库

### 1.1 配置 RKE2 节点

在**所有** RKE2 节点上配置私有仓库（已完成）：

**文件位置：** `/etc/rancher/rke2/registries.yaml`

```yaml
configs:
  "192.168.80.100:30500":
    tls:
      insecure_skip_verify: true  # 允许 HTTP 访问
```

**应用配置：**
```bash
# 重启 RKE2 服务
systemctl restart rke2-server  # 或 rke2-agent

# 验证配置
crictl info | grep -A 10 "192.168.80.100:30500"
```

### 1.2 测试镜像拉取

```bash
# 使用 crictl 测试拉取
crictl pull 192.168.80.100:30500/demo-springboot:latest

# 查看镜像
crictl images | grep demo-springboot
```

---

## 二、创建 Kubernetes Deployment

### 2.1 基础 Deployment（HTTP Registry）

由于私有仓库配置了 `insecure_skip_verify: true`，可以直接使用镜像：

**文件：** `demo-springboot-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-springboot
  namespace: default
  labels:
    app: demo-springboot
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
      - name: demo-springboot
        image: 192.168.80.100:30500/demo-springboot:latest
        imagePullPolicy: Always  # 总是拉取最新镜像
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        env:
        - name: JAVA_OPTS
          value: "-Xms256m -Xmx512m"
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3

---
apiVersion: v1
kind: Service
metadata:
  name: demo-springboot
  namespace: default
spec:
  type: NodePort
  selector:
    app: demo-springboot
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080  # 外部访问端口
    protocol: TCP
    name: http
```

**部署命令：**
```bash
kubectl apply -f demo-springboot-deployment.yaml
```

### 2.2 使用特定版本的镜像

```yaml
spec:
  containers:
  - name: demo-springboot
    image: 192.168.80.100:30500/demo-springboot:75  # 使用构建号
    imagePullPolicy: IfNotPresent  # 如果本地有则不拉取
```

### 2.3 使用 ImagePullSecrets（可选，用于认证）

如果私有仓库启用了认证，需要创建 Secret：

```bash
# 创建 Docker Registry Secret
kubectl create secret docker-registry regcred \
  --docker-server=192.168.80.100:30500 \
  --docker-username=admin \
  --docker-password=password \
  --docker-email=admin@example.com \
  -n default
```

**在 Deployment 中使用：**
```yaml
spec:
  imagePullSecrets:
  - name: regcred
  containers:
  - name: demo-springboot
    image: 192.168.80.100:30500/demo-springboot:latest
```

---

## 三、部署操作

### 3.1 创建部署

```bash
# 1. 创建 Deployment
kubectl apply -f demo-springboot-deployment.yaml

# 2. 查看部署状态
kubectl get deployments -n default

# 3. 查看 Pod 状态
kubectl get pods -n default -l app=demo-springboot

# 4. 查看 Pod 详情（检查镜像拉取）
kubectl describe pod -n default -l app=demo-springboot
```

### 3.2 查看日志

```bash
# 查看应用日志
kubectl logs -n default -l app=demo-springboot -f

# 查看特定 Pod 日志
kubectl logs -n default <pod-name> -f
```

### 3.3 访问应用

```bash
# 获取 Service 信息
kubectl get svc -n default demo-springboot

# 访问应用（通过 NodePort）
curl http://<node-ip>:30080/actuator/health

# 或者使用任意节点 IP
curl http://192.168.80.100:30080/actuator/health
```

---

## 四、更新部署

### 4.1 滚动更新到新版本

```bash
# 方式 1: 使用 kubectl set image
kubectl set image deployment/demo-springboot \
  demo-springboot=192.168.80.100:30500/demo-springboot:76 \
  -n default

# 方式 2: 修改 YAML 后重新应用
# 编辑 demo-springboot-deployment.yaml，修改镜像标签
kubectl apply -f demo-springboot-deployment.yaml

# 方式 3: 使用 kubectl edit
kubectl edit deployment demo-springboot -n default
```

### 4.2 查看更新状态

```bash
# 查看滚动更新状态
kubectl rollout status deployment/demo-springboot -n default

# 查看更新历史
kubectl rollout history deployment/demo-springboot -n default
```

### 4.3 回滚部署

```bash
# 回滚到上一个版本
kubectl rollout undo deployment/demo-springboot -n default

# 回滚到特定版本
kubectl rollout undo deployment/demo-springboot -n default --to-revision=2
```

---

## 五、完整部署示例

### 5.1 创建 Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo-app
```

### 5.2 创建 ConfigMap

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-springboot-config
  namespace: demo-app
data:
  application.properties: |
    server.port=8080
    spring.application.name=demo-springboot
    logging.level.root=INFO
```

### 5.3 创建完整 Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-springboot
  namespace: demo-app
  labels:
    app: demo-springboot
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: demo-springboot
  template:
    metadata:
      labels:
        app: demo-springboot
        version: v1
    spec:
      containers:
      - name: demo-springboot
        image: 192.168.80.100:30500/demo-springboot:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: JAVA_OPTS
          value: "-Xms512m -Xmx1024m -XX:+UseG1GC"
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: TZ
          value: "Asia/Shanghai"
        volumeMounts:
        - name: config
          mountPath: /config
          readOnly: true
        resources:
          requests:
            cpu: 500m
            memory: 1Gi
          limits:
            cpu: 2000m
            memory: 2Gi
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 90
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 0
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 30
      volumes:
      - name: config
        configMap:
          name: demo-springboot-config

---
apiVersion: v1
kind: Service
metadata:
  name: demo-springboot
  namespace: demo-app
  labels:
    app: demo-springboot
spec:
  type: ClusterIP
  selector:
    app: demo-springboot
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
    name: http

---
apiVersion: v1
kind: Service
metadata:
  name: demo-springboot-nodeport
  namespace: demo-app
  labels:
    app: demo-springboot
spec:
  type: NodePort
  selector:
    app: demo-springboot
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
    protocol: TCP
    name: http
```

### 5.4 部署完整应用

```bash
# 1. 创建 Namespace
kubectl apply -f namespace.yaml

# 2. 创建 ConfigMap
kubectl apply -f configmap.yaml

# 3. 创建 Deployment 和 Service
kubectl apply -f deployment.yaml

# 4. 验证部署
kubectl get all -n demo-app

# 5. 查看 Pod 日志
kubectl logs -n demo-app -l app=demo-springboot -f

# 6. 测试访问
curl http://192.168.80.100:30080/actuator/health
```

---

## 六、使用 Helm 部署（推荐）

### 6.1 创建 Helm Chart

```bash
# 创建 Chart 目录结构
mkdir -p demo-springboot-chart
cd demo-springboot-chart

# 创建 Chart.yaml
cat > Chart.yaml <<EOF
apiVersion: v2
name: demo-springboot
description: Demo Spring Boot Application
type: application
version: 1.0.0
appVersion: "1.0.0"
EOF

# 创建 values.yaml
cat > values.yaml <<EOF
replicaCount: 2

image:
  registry: 192.168.80.100:30500
  repository: demo-springboot
  tag: latest
  pullPolicy: Always

service:
  type: NodePort
  port: 8080
  nodePort: 30080

resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi

env:
  - name: JAVA_OPTS
    value: "-Xms256m -Xmx512m"
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
EOF

# 创建 templates/deployment.yaml
mkdir -p templates
cat > templates/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "demo-springboot.fullname" . }}
  labels:
    {{- include "demo-springboot.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "demo-springboot.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "demo-springboot.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.registry }}/{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.port }}
        env:
        {{- toYaml .Values.env | nindent 8 }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
EOF
```

### 6.2 使用 Helm 部署

```bash
# 安装
helm install demo-springboot ./demo-springboot-chart -n demo-app --create-namespace

# 升级
helm upgrade demo-springboot ./demo-springboot-chart -n demo-app

# 升级到新版本镜像
helm upgrade demo-springboot ./demo-springboot-chart \
  --set image.tag=76 \
  -n demo-app

# 回滚
helm rollback demo-springboot -n demo-app

# 卸载
helm uninstall demo-springboot -n demo-app
```

---

## 七、CI/CD 集成

### 7.1 Jenkins Pipeline 自动部署

在 Jenkinsfile 中添加部署阶段：

```groovy
stage('部署到 Kubernetes') {
    when {
        expression { params.DEPLOY_TO_K8S }
    }
    steps {
        script {
            echo """
            ╔════════════════════════════════════════╗
            ║         部署到 Kubernetes               ║
            ╚════════════════════════════════════════╝
            """

            // 使用 kubectl 更新镜像
            sh """
                kubectl set image deployment/demo-springboot \\
                  demo-springboot=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \\
                  -n demo-app
                
                # 等待部署完成
                kubectl rollout status deployment/demo-springboot -n demo-app --timeout=5m
                
                # 验证部署
                kubectl get pods -n demo-app -l app=demo-springboot
            """
        }
    }
}
```

### 7.2 添加部署参数

```groovy
parameters {
    booleanParam(
        name: 'DEPLOY_TO_K8S',
        defaultValue: false,
        description: '部署到 Kubernetes'
    )
    choice(
        name: 'DEPLOY_ENV',
        choices: ['dev', 'test', 'prod'],
        description: '部署环境'
    )
}
```

---

## 八、故障排查

### 8.1 镜像拉取失败

**症状：**
```
Failed to pull image "192.168.80.100:30500/demo-springboot:latest": 
rpc error: code = Unknown desc = failed to pull and unpack image
```

**排查步骤：**

```bash
# 1. 检查节点配置
cat /etc/rancher/rke2/registries.yaml

# 2. 测试手动拉取
crictl pull 192.168.80.100:30500/demo-springboot:latest

# 3. 检查镜像是否存在
curl http://192.168.80.100:30500/v2/demo-springboot/tags/list

# 4. 查看 Pod 事件
kubectl describe pod <pod-name> -n demo-app

# 5. 检查 kubelet 日志
journalctl -u rke2-server -f | grep "192.168.80.100:30500"
```

**解决方案：**

1. 确保 `/etc/rancher/rke2/registries.yaml` 配置正确
2. 重启 RKE2 服务：`systemctl restart rke2-server`
3. 确保镜像已推送到仓库
4. 检查网络连接：`curl http://192.168.80.100:30500/v2/`

### 8.2 Pod 启动失败

**症状：**
```
CrashLoopBackOff
```

**排查步骤：**

```bash
# 1. 查看 Pod 日志
kubectl logs <pod-name> -n demo-app

# 2. 查看 Pod 事件
kubectl describe pod <pod-name> -n demo-app

# 3. 查看上一次容器日志
kubectl logs <pod-name> -n demo-app --previous

# 4. 进入容器调试
kubectl exec -it <pod-name> -n demo-app -- sh
```

**常见原因：**
- 应用启动失败（检查日志）
- 健康检查失败（调整探针参数）
- 资源不足（增加 resources.limits）
- 配置错误（检查环境变量和 ConfigMap）

### 8.3 Service 无法访问

**排查步骤：**

```bash
# 1. 检查 Service
kubectl get svc -n demo-app

# 2. 检查 Endpoints
kubectl get endpoints -n demo-app

# 3. 测试 Pod IP 直接访问
kubectl get pods -n demo-app -o wide
curl http://<pod-ip>:8080/actuator/health

# 4. 测试 Service ClusterIP
kubectl get svc demo-springboot -n demo-app
curl http://<cluster-ip>:8080/actuator/health

# 5. 测试 NodePort
curl http://<node-ip>:30080/actuator/health
```

---

## 九、监控和日志

### 9.1 查看资源使用

```bash
# 查看 Pod 资源使用
kubectl top pods -n demo-app

# 查看节点资源使用
kubectl top nodes
```

### 9.2 查看事件

```bash
# 查看 Namespace 事件
kubectl get events -n demo-app --sort-by='.lastTimestamp'

# 持续监控事件
kubectl get events -n demo-app --watch
```

### 9.3 导出日志

```bash
# 导出所有 Pod 日志
for pod in $(kubectl get pods -n demo-app -l app=demo-springboot -o name); do
    kubectl logs -n demo-app $pod > ${pod}.log
done
```

---

## 十、最佳实践

### 10.1 镜像标签策略

```yaml
# ❌ 不推荐：使用 latest
image: 192.168.80.100:30500/demo-springboot:latest

# ✅ 推荐：使用具体版本
image: 192.168.80.100:30500/demo-springboot:75

# ✅ 推荐：使用 Git commit hash
image: 192.168.80.100:30500/demo-springboot:abc123f
```

### 10.2 资源限制

```yaml
resources:
  requests:  # 最小保证资源
    cpu: 200m
    memory: 512Mi
  limits:    # 最大可用资源
    cpu: 1000m
    memory: 1Gi
```

### 10.3 健康检查

```yaml
# 启动探针：应用启动检查
startupProbe:
  httpGet:
    path: /actuator/health
    port: 8080
  failureThreshold: 30
  periodSeconds: 10

# 存活探针：应用是否运行
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10

# 就绪探针：是否可以接收流量
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5
```

### 10.4 滚动更新策略

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # 最多多创建 1 个 Pod
    maxUnavailable: 0  # 最多 0 个 Pod 不可用（保证服务不中断）
```

---

## 十一、快速参考

### 常用命令

```bash
# 部署
kubectl apply -f deployment.yaml

# 更新镜像
kubectl set image deployment/demo-springboot \
  demo-springboot=192.168.80.100:30500/demo-springboot:76 -n demo-app

# 扩缩容
kubectl scale deployment/demo-springboot --replicas=5 -n demo-app

# 查看状态
kubectl get pods -n demo-app -w

# 查看日志
kubectl logs -f -l app=demo-springboot -n demo-app

# 回滚
kubectl rollout undo deployment/demo-springboot -n demo-app

# 删除
kubectl delete -f deployment.yaml
```

### 镜像操作

```bash
# 查看仓库中的镜像
curl http://192.168.80.100:30500/v2/_catalog

# 查看镜像标签
curl http://192.168.80.100:30500/v2/demo-springboot/tags/list

# 手动拉取镜像
crictl pull 192.168.80.100:30500/demo-springboot:latest
```

---

## 附录：完整部署脚本

```bash
#!/bin/bash
# deploy.sh - 一键部署脚本

set -e

NAMESPACE="demo-app"
APP_NAME="demo-springboot"
REGISTRY="192.168.80.100:30500"
IMAGE_TAG="${1:-latest}"

echo "=== 部署 ${APP_NAME} ==="
echo "镜像: ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
echo "命名空间: ${NAMESPACE}"

# 创建 Namespace
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# 部署应用
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  type: NodePort
  selector:
    app: ${APP_NAME}
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
EOF

# 等待部署完成
echo "=== 等待部署完成 ==="
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=5m

# 显示部署信息
echo "=== 部署完成 ==="
kubectl get all -n ${NAMESPACE}

echo ""
echo "访问地址: http://<node-ip>:30080"
```

**使用方法：**
```bash
# 部署 latest 版本
bash deploy.sh

# 部署特定版本
bash deploy.sh 75
```

---

**文档版本**: v1.0  
**最后更新**: 2026-02-15  
**私有仓库**: 192.168.80.100:30500  
**状态**: ✅ 已验证可用
