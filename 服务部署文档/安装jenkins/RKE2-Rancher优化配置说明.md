# Jenkins on RKE2/Rancher 性能优化配置说明

## 📋 当前优化配置

### Maven 容器资源
```yaml
resources:
  requests:
    cpu: 2000m (2核)
    memory: 4Gi
  limits:
    cpu: 6000m (6核)
    memory: 8Gi
```

**优化理由：**
- ✅ 多模块项目（13+ 模块）需要更多内存
- ✅ 提高 CPU 可以加快并行编译速度
- ✅ 8GB 内存限制防止 OOM（Out of Memory）

### Kaniko 容器资源
```yaml
resources:
  requests:
    cpu: 1000m (1核)
    memory: 2Gi
  limits:
    cpu: 4000m (4核)
    memory: 4Gi
```

**优化理由：**
- ✅ 镜像构建和推送需要足够的 CPU
- ✅ 处理大型镜像层需要更多内存
- ✅ 4GB 限制防止镜像构建 OOM

---

## 🎯 RKE2/Rancher 特定优化

### 1. 节点选择器（可选）

如果你有专门的 CI/CD 节点，可以启用节点选择器：

```yaml
nodeSelector:
  kubernetes.io/os: linux
  node-role.kubernetes.io/worker: "true"
  # 或者自定义标签
  workload: ci-cd
```

**如何给节点打标签：**
```bash
kubectl label nodes <node-name> workload=ci-cd
```

### 2. 容忍度（Tolerations）

如果 CI/CD 节点有污点（Taint），需要添加容忍度：

```yaml
tolerations:
- key: "workload"
  operator: "Equal"
  value: "ci-cd"
  effect: "NoSchedule"
```

**如何给节点添加污点：**
```bash
kubectl taint nodes <node-name> workload=ci-cd:NoSchedule
```

### 3. Pod 优先级

确保构建 Pod 优先调度：

```yaml
priorityClassName: high-priority
```

**创建优先级类：**
```bash
kubectl apply -f - <<EOF
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
globalDefault: false
description: "用于 CI/CD 构建任务的高优先级"
EOF
```

---

## 💾 存储优化

### 检查 jenkins-pvc 存储类

```bash
kubectl get pvc jenkins-pvc -n <namespace> -o yaml
```

**推荐配置：**
- 存储类型：SSD（不要用 HDD）
- 访问模式：ReadWriteOnce
- 容量：至少 50Gi（Maven 仓库会很大）

**Rancher 中创建高性能 StorageClass：**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: rancher.io/local-path  # 或者你的 CSI 驱动
parameters:
  type: ssd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

---

## 🔧 根据集群资源调整

### 场景 1：资源充足的集群（推荐）
**当前配置已优化，无需调整**

总需求：
- CPU requests: 3 核（2 + 1）
- CPU limits: 10 核（6 + 4）
- Memory requests: 6 GB（4 + 2）
- Memory limits: 12 GB（8 + 4）

### 场景 2：资源有限的集群

如果节点资源不足，降低 requests：

```yaml
# Maven 容器
resources:
  requests:
    cpu: 1000m      # 降低到 1 核
    memory: 2Gi     # 降低到 2GB
  limits:
    cpu: 4000m      # 保持 4 核
    memory: 6Gi     # 保持 6GB

# Kaniko 容器
resources:
  requests:
    cpu: 500m       # 降低到 0.5 核
    memory: 1Gi     # 降低到 1GB
  limits:
    cpu: 2000m      # 保持 2 核
    memory: 3Gi     # 降低到 3GB
```

### 场景 3：超大型项目

如果构建仍然 OOM，进一步提高：

```yaml
# Maven 容器
resources:
  requests:
    cpu: 4000m      # 4 核
    memory: 6Gi     # 6GB
  limits:
    cpu: 8000m      # 8 核
    memory: 12Gi    # 12GB
```

---

## 📊 监控和调优

### 1. 查看 Pod 资源使用情况

```bash
# 实时监控
kubectl top pod -n <namespace> | grep jenkins

# 查看详细指标（需要 Metrics Server）
kubectl describe pod <pod-name> -n <namespace>
```

### 2. 在 Rancher UI 中监控

1. 进入 Rancher UI
2. 选择集群 → 工作负载 → Pods
3. 找到 Jenkins agent Pod
4. 查看 "Metrics" 标签页

### 3. 常见问题排查

**问题 1：Pod 一直 Pending**
```bash
kubectl describe pod <pod-name> -n <namespace>
```
可能原因：
- 节点资源不足（降低 requests）
- 没有满足 nodeSelector 的节点
- PVC 无法绑定

**问题 2：构建过程中 OOMKilled**
```bash
kubectl logs <pod-name> -n <namespace> -c maven --previous
```
解决方案：
- 提高 memory limits
- 调整 MAVEN_OPTS 中的 -Xmx 参数

**问题 3：构建速度慢**
- 提高 CPU limits
- 检查 PVC 存储性能
- 启用 Maven 并行构建

---

## 🚀 推荐的 Jenkinsfile 环境变量优化

当前已优化的 MAVEN_OPTS：
```groovy
env:
- name: MAVEN_OPTS
  value: "-Xmx6g -Xms2g -XX:+UseG1GC -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError"
```

**参数说明：**
- `-Xmx6g`：最大堆内存 6GB（根据 limits 调整）
- `-Xms2g`：初始堆内存 2GB（减少 GC 频率）
- `-XX:+UseG1GC`：使用 G1 垃圾回收器（适合大内存）
- `-XX:MaxMetaspaceSize=512m`：元空间最大 512MB
- `-XX:+HeapDumpOnOutOfMemoryError`：OOM 时生成堆转储

---

## ✅ 验证优化效果

### 构建前
```bash
# 记录开始时间
date
```

### 构建后
```bash
# 查看构建日志中的耗时
# 对比优化前后的构建时间
```

### 预期改进
- ✅ Maven 编译速度提升 30-50%
- ✅ 镜像构建速度提升 20-30%
- ✅ 减少 OOM 错误
- ✅ 更稳定的构建过程

---

## 📝 注意事项

1. **首次应用配置后**，观察几次构建，根据实际情况微调
2. **不要设置过高的 requests**，否则 Pod 无法调度
3. **limits 可以设置较高**，但不要超过节点实际资源
4. **定期清理 Maven 本地仓库**，避免 PVC 空间不足
5. **使用 SSD 存储**，HDD 会严重影响构建速度

---

## 🔗 相关命令

```bash
# 查看节点资源
kubectl describe nodes

# 查看 PVC 状态
kubectl get pvc -n <namespace>

# 查看 StorageClass
kubectl get storageclass

# 查看 Pod 事件
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# 强制删除卡住的 Pod
kubectl delete pod <pod-name> -n <namespace> --force --grace-period=0
```
