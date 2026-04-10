# Kafka 部署文档

## 一、前置条件

- Kubernetes 集群正常运行
- 已部署 Zookeeper 服务（集群内可通过 `zookeeper:2181` 访问）
- 私有镜像仓库：`ccr.ccs.tencentyun.com`
- 已创建镜像拉取凭据 `docker-secret`
- 集群已安装 `local-path` StorageClass（Rancher local-path-provisioner，状态 Active）

---

## 二、镜像信息

使用 Bitnami Kafka 镜像，已推送至私有仓库：

```
192.168.1.119:30020/library/kafka:latest
```

```bash
# 1. 拉取镜像
docker pull docker.1panel.live/bitnami/kafka:latest

# 2. 打标签
docker tag docker.1panel.live/bitnami/kafka:latest 192.168.1.119:30020/library/kafka:latest

# 3. 登录私有仓库
docker login 192.168.1.119:30020

# 4. 推送
docker push 192.168.1.119:30020/library/kafka:latest
```

---

## 三、创建镜像拉取凭据（如已存在可跳过）

```bash
kubectl create secret docker-registry docker-secret \
  --docker-server=192.168.1.119:30020 \
  --docker-username=你的用户名 \
  --docker-password=你的密码 \
  -n nms4cloud
```

---

## 四、部署文件

### 1. PersistentVolumeClaim

使用 `local-path` StorageClass 动态供给，无需手动创建 PV。

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-data
  namespace: nms4cloud
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 10Gi
```

### 2. Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka
  namespace: nms4cloud
  labels:
    k8s-app: kafka
    qcloud-app: kafka
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kafka
      qcloud-app: kafka
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: kafka
        qcloud-app: kafka
    spec:
      containers:
      - name: broker
        image: 192.168.1.119:30020/library/kafka:latest
        imagePullPolicy: Always
        env:
        - name: KAFKA_CFG_ZOOKEEPER_CONNECT
          value: zookeeper:2181
        - name: ALLOW_PLAINTEXT_LISTENER
          value: "yes"
        - name: KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP
          value: CLIENT:PLAINTEXT,EXTERNAL:PLAINTEXT
        - name: KAFKA_CFG_LISTENERS
          value: CLIENT://:9092,EXTERNAL://:9093
        - name: KAFKA_CFG_ADVERTISED_LISTENERS
          value: CLIENT://kafka:9092,EXTERNAL://localhost:9093
        - name: KAFKA_CFG_INTER_BROKER_LISTENER_NAME
          value: CLIENT
        resources:
          requests:
            cpu: 250m
            memory: 2Gi
          limits:
            cpu: 500m
            memory: 2Gi
        securityContext:
          privileged: true
          runAsUser: 0
        volumeMounts:
        - name: data
          mountPath: /bitnami/kafka/data
      imagePullSecrets:
      - name: docker-secret
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: kafka-data
```

### 3. Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kafka
  namespace: nms4cloud
  labels:
    k8s-app: kafka
spec:
  selector:
    k8s-app: kafka
    qcloud-app: kafka
  ports:
  - name: client
    port: 9092
    targetPort: 9092
  - name: external
    port: 9093
    targetPort: 9093
  type: ClusterIP
```

---

## 五、部署执行

```bash
kubectl apply -f kafka-pvc.yaml
kubectl apply -f kafka-deployment.yaml
kubectl apply -f kafka-service.yaml

# 查看部署状态（PVC 会自动触发 PV 动态创建）
kubectl get pvc kafka-data -n nms4cloud
kubectl get pv
kubectl get pods -n nms4cloud | grep kafka
kubectl logs -f <kafka-pod-name> -n nms4cloud
```

---

## 六、验证部署

```bash
# 确认 Pod 正常运行
kubectl get pods -n nms4cloud | grep kafka

# 进入 Kafka 容器验证
kubectl exec -it <kafka-pod-name> -n nms4cloud -- bash

# 创建测试 topic
kafka-topics.sh --create --topic test --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# 查看 topic 列表
kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## 七、业务服务接入

业务服务连接 Kafka 时使用以下地址：

```properties
# 同 namespace（nms4cloud）
spring.kafka.bootstrap-servers=kafka:9092

# 跨 namespace
spring.kafka.bootstrap-servers=kafka.nms4cloud.svc.cluster.local:9092
```

---

## 八、监听器说明

| 监听器 | 端口 | 用途 |
|--------|------|------|
| CLIENT | 9092 | 集群内部服务通信 |
| EXTERNAL | 9093 | 外部访问（如本地开发调试） |

> `KAFKA_CFG_ADVERTISED_LISTENERS` 中 EXTERNAL 配置为 `localhost:9093`，仅适用于端口转发场景。
> 如需从集群外直接访问，需修改为实际可达地址并配合 NodePort 或 Ingress。

---

## 九、常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 镜像拉取失败 ImagePullBackOff | docker-secret 不存在或凭据过期 | 重新创建 docker-secret |
| Pod 启动后立即重启 | Zookeeper 未就绪或不可达 | 确认 zookeeper:2181 可访问 |
| OOMKilled | 内存不足 | 调大 memory limits |
| PVC Pending | local-path provisioner 未运行 | 确认 local-path-provisioner Pod 正常：`kubectl get pods -n local-path-storage` |
| 连接超时 Connection refused | Service 未创建或端口不匹配 | 确认 Service 已部署且端口正确 |
| 数据丢失 | Pod 重建后未挂载持久化存储 | 确认 PVC 正常绑定 |
