# Kubernetes 资源文件

## 说明

这些资源文件需要在 Jenkins 流水线运行前创建。

## 快速部署

### 方法 1：一次性创建所有资源

```bash
kubectl apply -f maven-cache-pvc.yaml
kubectl apply -f docker-config-configmap.yaml
```

### 方法 2：使用命令直接创建

#### 创建 Maven 缓存 PVC

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-maven-cache
  namespace: jenkins
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
EOF
```

#### 创建 Docker 配置 ConfigMap

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-config
  namespace: jenkins
data:
  config.json: |
    {
      "insecure-registries": ["192.168.80.100:30500"]
    }
EOF
```

## 验证资源创建

### 检查 PVC

```bash
kubectl get pvc -n jenkins

# 应该看到：
NAME                  STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
jenkins-maven-cache   Bound    pvc-xxx  10Gi       RWX            nfs-client     1m
```

### 检查 ConfigMap

```bash
kubectl get configmap -n jenkins

# 应该看到：
NAME            DATA   AGE
docker-config   1      1m
```

### 查看详细信息

```bash
# 查看 PVC 详情
kubectl describe pvc jenkins-maven-cache -n jenkins

# 查看 ConfigMap 详情
kubectl describe configmap docker-config -n jenkins
```

## 资源说明

### maven-cache-pvc.yaml

**用途：** 缓存 Maven 依赖，加速构建

**配置：**
- 存储大小：10Gi
- 访问模式：ReadWriteMany（多个 Pod 可以同时读写）
- 命名空间：jenkins

**注意：**
- 如果集群没有支持 RWX 的 StorageClass，可能需要修改为 ReadWriteOnce
- 如果有特定的 StorageClass，需要在 yaml 中指定 `storageClassName`

### docker-config-configmap.yaml

**用途：** 配置 Kaniko 访问私有 Docker 仓库

**配置：**
- 私有仓库地址：192.168.80.100:30500
- 标记为 insecure-registries（允许 HTTP 访问）

**注意：**
- 如果私有仓库地址不同，需要修改 IP 和端口
- 如果使用 HTTPS，可以移除 insecure-registries 配置

## 常见问题

### 问题 1：PVC 一直处于 Pending 状态

**原因：** 没有可用的 StorageClass 或 PV

**解决方案 1：** 检查 StorageClass

```bash
kubectl get storageclass

# 如果有 StorageClass，在 PVC yaml 中指定
storageClassName: <your-storage-class>
```

**解决方案 2：** 手动创建 PV（如果使用 NFS）

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-maven-cache-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS-SERVER-IP>
    path: /path/to/maven-cache
EOF
```

**解决方案 3：** 使用 hostPath（仅用于测试）

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-maven-cache-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/jenkins-maven-cache
    type: DirectoryOrCreate
EOF
```

### 问题 2：Pod 无法挂载 PVC

**原因：** PVC 的访问模式与 Pod 调度不匹配

**解决：** 
- 如果使用 ReadWriteOnce，确保 Pod 调度到同一节点
- 或者使用支持 ReadWriteMany 的存储（如 NFS）

### 问题 3：Kaniko 无法推送镜像

**原因：** Docker 配置不正确

**解决：** 检查 ConfigMap 中的私有仓库地址是否正确

```bash
kubectl get configmap docker-config -n jenkins -o yaml
```

## 删除资源

如果需要重新创建：

```bash
# 删除 PVC（注意：会删除缓存的数据）
kubectl delete pvc jenkins-maven-cache -n jenkins

# 删除 ConfigMap
kubectl delete configmap docker-config -n jenkins
```

## 资源清单

创建完成后，应该有以下资源：

```
☑ PersistentVolumeClaim: jenkins-maven-cache
☑ ConfigMap: docker-config
```

验证命令：

```bash
kubectl get pvc,configmap -n jenkins | grep -E "jenkins-maven-cache|docker-config"
```
