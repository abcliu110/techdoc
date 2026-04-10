# Zookeeper 部署文档

## 一、前置条件

- Kubernetes 集群正常运行
- 私有镜像仓库：`192.168.1.119:30020`
- 已创建镜像拉取凭据 `docker-secret`
- 集群已安装 `local-path` StorageClass（Rancher local-path-provisioner，状态 Active）

---

## 二、镜像信息

使用官方 Zookeeper 镜像，已推送至私有仓库：

```
192.168.1.119:30020/library/zookeeper:3.9.3
```

```bash
# 1. 拉取镜像
docker pull docker.1panel.live/library/zookeeper:3.9.3

# 2. 打标签
docker tag docker.1panel.live/library/zookeeper:3.9.3 192.168.1.119:30020/library/zookeeper:3.9.3

# 3. 登录私有仓库
docker login 192.168.1.119:30020

# 4. 推送
docker push 192.168.1.119:30020/library/zookeeper:3.9.3
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

Deployment、PVC、Service 合并在同一文件 `zookeeper-deployment.yaml`，使用 `local-path` StorageClass 动态供给，无需手动创建 PV。

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: zookeeper-data
  namespace: nms4cloud
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: zookeeper-datalog
  namespace: nms4cloud
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zookeeper
  namespace: nms4cloud
  labels:
    k8s-app: zookeeper
    qcloud-app: zookeeper
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: zookeeper
      qcloud-app: zookeeper
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: zookeeper
        qcloud-app: zookeeper
    spec:
      containers:
      - name: zookeeper
        image: 192.168.1.119:30020/library/zookeeper:3.9.3
        imagePullPolicy: Always
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 250m
            memory: 512Mi
        volumeMounts:
        - name: data
          mountPath: /data
        - name: datalog
          mountPath: /datalog
      imagePullSecrets:
      - name: docker-secret
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: zookeeper-data
      - name: datalog
        persistentVolumeClaim:
          claimName: zookeeper-datalog
---
apiVersion: v1
kind: Service
metadata:
  name: zookeeper
  namespace: nms4cloud
  labels:
    k8s-app: zookeeper
spec:
  selector:
    k8s-app: zookeeper
    qcloud-app: zookeeper
  ports:
  - name: client
    port: 2181
    targetPort: 2181
  - name: follower
    port: 2888
    targetPort: 2888
  - name: election
    port: 3888
    targetPort: 3888
  type: ClusterIP
```

---

## 五、部署执行

```bash
kubectl apply -f zookeeper-deployment.yaml

# 查看部署状态（PVC 会自动触发 PV 动态创建）
kubectl get pvc -n nms4cloud | grep zookeeper
kubectl get pods -n nms4cloud | grep zookeeper
kubectl logs -f <zookeeper-pod-name> -n nms4cloud
```

---

## 六、验证部署

```bash
# 确认 Pod 正常运行
kubectl get pods -n nms4cloud | grep zookeeper

# 进入容器验证
kubectl exec -it <zookeeper-pod-name> -n nms4cloud -- bash

# 连接 Zookeeper 检查状态
zkCli.sh -server localhost:2181

# 查看节点
ls /
```

---

## 七、业务服务接入

其他服务连接 Zookeeper 时使用以下地址：

```properties
# 同 namespace（nms4cloud）
zookeeper.connect=zookeeper:2181

# 跨 namespace
zookeeper.connect=zookeeper.nms4cloud.svc.cluster.local:2181
```

---

## 八、端口说明

| 端口 | 用途 |
|------|------|
| 2181 | 客户端连接（Kafka 等服务使用此端口） |
| 2888 | Follower 连接 Leader（集群内部通信） |
| 3888 | Leader 选举（集群内部通信） |

> 单节点部署时 2888 和 3888 端口不会被实际使用，但保留以便后续扩展为集群模式。

---

## 九、常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 镜像拉取失败 ImagePullBackOff | docker-secret 不存在或凭据过期 | 重新创建 docker-secret |
| Pod 启动后立即重启 | 数据目录权限不足 | 检查 local-path-provisioner 是否正常：`kubectl get pods -n local-path-storage` |
| OOMKilled | 内存不足 | 调大 memory limits |
| PVC Pending | local-path provisioner 未运行 | 确认 local-path-provisioner Pod 正常：`kubectl get pods -n local-path-storage` |
