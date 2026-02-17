# Kubernetes 部署策略对比

## 1. 滚动更新（Rolling Update）- 默认推荐

### 特点
- K8s 默认策略
- 逐步替换旧 Pod，零停机
- 自动控制更新速度

### 配置示例
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-pos3boot
  namespace: dev
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 最多可以多创建 1 个 Pod
      maxUnavailable: 1  # 最多可以有 1 个 Pod 不可用
  template:
    spec:
      containers:
      - name: nms4cloud-pos3boot
        image: crpi-xxx.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-pos3boot:dev-123
        ports:
        - containerPort: 8080
        # 健康检查配置（重要！）
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
```

### Jenkins 部署命令
```groovy
sh """
    kubectl set image deployment/nms4cloud-pos3boot \
        nms4cloud-pos3boot=${DOCKER_IMAGE} \
        -n ${K8S_NAMESPACE}

    kubectl rollout status deployment/nms4cloud-pos3boot \
        -n ${K8S_NAMESPACE} \
        --timeout=300s
"""
```

### 适用场景
- 开发环境、测试环境
- 生产环境的常规更新

---

## 2. 蓝绿部署（Blue-Green Deployment）

### 特点
- 同时运行两个版本（蓝色=旧版本，绿色=新版本）
- 通过切换 Service 实现瞬间切换
- 可以快速回滚

### 实现方式
```yaml
# 蓝色部署（当前生产版本）
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-pos3boot-blue
  namespace: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nms4cloud-pos3boot
      version: blue
  template:
    metadata:
      labels:
        app: nms4cloud-pos3boot
        version: blue
    spec:
      containers:
      - name: nms4cloud-pos3boot
        image: xxx/nms4cloud-pos3boot:v1.0.0

---
# 绿色部署（新版本）
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nms4cloud-pos3boot-green
  namespace: prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nms4cloud-pos3boot
      version: green
  template:
    metadata:
      labels:
        app: nms4cloud-pos3boot
        version: green
    spec:
      containers:
      - name: nms4cloud-pos3boot
        image: xxx/nms4cloud-pos3boot:v1.1.0

---
# Service（通过修改 selector 切换版本）
apiVersion: v1
kind: Service
metadata:
  name: nms4cloud-pos3boot
  namespace: prod
spec:
  selector:
    app: nms4cloud-pos3boot
    version: blue  # 切换到 green 即可切换版本
  ports:
  - port: 8080
    targetPort: 8080
```

### Jenkins 部署流程
```groovy
stage('蓝绿部署') {
    steps {
        container('kubectl') {
            script {
                // 1. 部署绿色版本
                sh """
                    kubectl apply -f k8s/deployment-green.yaml
                    kubectl rollout status deployment/nms4cloud-pos3boot-green -n prod
                """

                // 2. 验证绿色版本
                echo ">>> 验证绿色版本..."
                sh """
                    kubectl run test-pod --rm -i --restart=Never \
                        --image=curlimages/curl -- \
                        curl http://nms4cloud-pos3boot-green:8080/actuator/health
                """

                // 3. 人工确认
                input message: '绿色版本验证通过，切换流量？', ok: '确认切换'

                // 4. 切换 Service 到绿色版本
                sh """
                    kubectl patch service nms4cloud-pos3boot -n prod \
                        -p '{"spec":{"selector":{"version":"green"}}}'
                """

                echo "✓ 流量已切换到绿色版本"

                // 5. 等待一段时间后删除蓝色版本
                sleep(time: 5, unit: 'MINUTES')
                sh "kubectl delete deployment nms4cloud-pos3boot-blue -n prod"
            }
        }
    }
}
```

### 适用场景
- 生产环境重大版本更新
- 需要快速回滚的场景
- 有充足资源（需要双倍资源）

---

## 3. 金丝雀发布（Canary Deployment）

### 特点
- 先发布到少量实例（如 10%）
- 观察指标，逐步扩大范围
- 风险最小

### 实现方式 A：使用副本数控制
```groovy
stage('金丝雀发布') {
    steps {
        container('kubectl') {
            script {
                // 1. 缩减到 1 个副本（金丝雀）
                sh """
                    kubectl scale deployment/nms4cloud-pos3boot \
                        -n prod --replicas=1
                """

                // 2. 更新镜像
                sh """
                    kubectl set image deployment/nms4cloud-pos3boot \
                        nms4cloud-pos3boot=${DOCKER_IMAGE} \
                        -n prod

                    kubectl rollout status deployment/nms4cloud-pos3boot -n prod
                """

                echo "✓ 金丝雀实例已部署（1/3）"

                // 3. 监控指标（可以集成 Prometheus）
                sleep(time: 5, unit: 'MINUTES')

                // 4. 人工确认
                input message: '金丝雀验证通过？', ok: '继续全量发布'

                // 5. 扩展到全部副本
                sh """
                    kubectl scale deployment/nms4cloud-pos3boot \
                        -n prod --replicas=3
                """

                echo "✓ 全量发布完成"
            }
        }
    }
}
```

### 实现方式 B：使用 Istio/Ingress 流量控制
```yaml
# 使用 Istio VirtualService 控制流量比例
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nms4cloud-pos3boot
spec:
  hosts:
  - nms4cloud-pos3boot
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: nms4cloud-pos3boot
        subset: v2
  - route:
    - destination:
        host: nms4cloud-pos3boot
        subset: v1
      weight: 90  # 90% 流量到旧版本
    - destination:
        host: nms4cloud-pos3boot
        subset: v2
      weight: 10  # 10% 流量到新版本
```

### 适用场景
- 生产环境所有更新（推荐）
- 需要逐步验证的场景
- 有监控系统支持

---

## 4. A/B 测试部署

### 特点
- 根据用户特征路由到不同版本
- 用于功能测试和对比

### 实现方式
```yaml
# 使用 Ingress 根据 Header 路由
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nms4cloud-pos3boot
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "X-Version"
    nginx.ingress.kubernetes.io/canary-by-header-value: "v2"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nms4cloud-pos3boot-v2
            port:
              number: 8080
```

---

## 策略选择建议

| 环境 | 推荐策略 | 原因 |
|------|---------|------|
| 开发环境 | 滚动更新 | 快速迭代，无需复杂策略 |
| 测试环境 | 滚动更新 | 验证功能，无需高可用 |
| 生产环境（常规更新） | 金丝雀发布 | 风险可控，逐步验证 |
| 生产环境（重大更新） | 蓝绿部署 | 快速回滚，影响最小 |
| 功能测试 | A/B 测试 | 对比效果，数据驱动 |

---

## 回滚策略

### 自动回滚
```groovy
post {
    failure {
        container('kubectl') {
            echo ">>> 部署失败，自动回滚..."
            sh """
                kubectl rollout undo deployment/${MODULE_NAME} \
                    -n ${K8S_NAMESPACE}

                kubectl rollout status deployment/${MODULE_NAME} \
                    -n ${K8S_NAMESPACE}
            """
        }
    }
}
```

### 手动回滚
```bash
# 回滚到上一个版本
kubectl rollout undo deployment/nms4cloud-pos3boot -n prod

# 回滚到指定版本
kubectl rollout undo deployment/nms4cloud-pos3boot -n prod --to-revision=3

# 查看历史版本
kubectl rollout history deployment/nms4cloud-pos3boot -n prod
```
