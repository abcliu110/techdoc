# Jenkins Master 性能优化指南

## 📊 当前配置 vs 优化配置对比

### 资源配置对比

| 项目 | 当前配置 | 优化配置 | 提升 |
|------|---------|---------|------|
| CPU Requests | 1 核 | 2 核 | +100% |
| CPU Limits | 3 核 | 6 核 | +100% |
| Memory Requests | 2 GB | 4 GB | +100% |
| Memory Limits | 4 GB | 8 GB | +100% |
| JVM 堆内存 | 3 GB | 6 GB | +100% |

### JVM 参数优化对比

**当前配置：**
```bash
-Xmx3072m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

**优化配置：**
```bash
-Xmx6g                          # 最大堆内存 6GB（提高 100%）
-Xms2g                          # 初始堆内存 2GB（减少 GC 频率）
-XX:+UseG1GC                    # G1 垃圾回收器
-XX:MaxGCPauseMillis=100        # GC 暂停时间从 200ms 降到 100ms
-XX:+ParallelRefProcEnabled     # 并行处理引用对象
-XX:+DisableExplicitGC          # 禁用显式 GC 调用
-XX:+AlwaysPreTouch             # 启动时预分配内存
-XX:MaxMetaspaceSize=512m       # 元空间限制
-Djava.awt.headless=true        # 无头模式
-Duser.timezone=Asia/Shanghai   # 时区设置
```

---

## 🚀 应用优化配置

### 方法 1：通过 Rancher UI 更新（推荐）

1. **登录 Rancher UI**
2. **导航到 Deployment**
   - 集群 → 工作负载 → Deployments
   - 找到 `jenkins` namespace 下的 `jenkins` Deployment

3. **编辑配置**
   - 点击右侧的 "⋮" → "编辑配置"
   - 或者点击 "⋮" → "查看/编辑 YAML"

4. **更新资源配置**
   ```yaml
   resources:
     requests:
       cpu: "2"
       memory: 4Gi
     limits:
       cpu: "6"
       memory: 8Gi
   ```

5. **更新环境变量**
   - 找到 `JAVA_OPTS` 环境变量
   - 替换为优化后的值：
   ```
   -Xmx6g -Xms2g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:MaxMetaspaceSize=512m -Djava.awt.headless=true -Duser.timezone=Asia/Shanghai
   ```

6. **保存并等待 Pod 重启**

### 方法 2：通过 kubectl 命令行

```bash
# 应用优化后的配置
kubectl apply -f jenkins-master-optimized.yaml

# 查看 Pod 重启状态
kubectl get pods -n jenkins -w

# 查看新 Pod 的日志
kubectl logs -n jenkins -l app=jenkins -f
```

### 方法 3：直接编辑（快速方法）

```bash
# 编辑 Deployment
kubectl edit deployment jenkins -n jenkins

# 找到 resources 和 env 部分，按照上面的配置修改
# 保存退出后，Pod 会自动重启
```

---

## 🎯 完整优化方案（Master + Agent）

### 1. Jenkins Master 优化（刚才的配置）
- ✅ 提高 CPU 和内存资源
- ✅ 优化 JVM 参数
- ✅ 添加健康检查

### 2. Jenkins Agent 优化（Jenkinsfile 中已完成）
- ✅ Maven 容器：2 核 4GB → 6 核 8GB
- ✅ Kaniko 容器：1 核 2GB → 4 核 4GB
- ✅ 优化 MAVEN_OPTS

### 3. 存储优化

**检查当前 PVC：**
```bash
kubectl get pvc jenkins-pvc -n jenkins -o yaml
```

**如果使用的不是 SSD，创建新的 StorageClass：**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: jenkins-fast-ssd
provisioner: rancher.io/local-path  # 根据你的环境调整
parameters:
  type: ssd
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
reclaimPolicy: Retain
```

**迁移到新的 PVC（如果需要）：**
```bash
# 1. 创建新的 PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc-fast
  namespace: jenkins
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: jenkins-fast-ssd
  resources:
    requests:
      storage: 100Gi
EOF

# 2. 备份数据
kubectl exec -n jenkins <jenkins-pod> -- tar czf /tmp/jenkins-backup.tar.gz /var/jenkins_home

# 3. 更新 Deployment 使用新 PVC
# 4. 恢复数据
```

---

## 📈 预期性能提升

### 构建速度提升

| 阶段 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| Maven 编译 | ~10 分钟 | ~5-6 分钟 | 40-50% |
| 镜像构建 | ~5 分钟 | ~3-4 分钟 | 20-30% |
| 镜像推送 | ~8-10 分钟 | ~4-6 分钟 | 40-50% |
| **总耗时** | **~23-25 分钟** | **~12-16 分钟** | **~45%** |

### 资源利用率

- ✅ CPU 利用率更高（更快的编译和构建）
- ✅ 内存充足（避免 OOM 和频繁 GC）
- ✅ 更稳定的构建过程

---

## 🔍 验证优化效果

### 1. 检查 Jenkins Master 资源使用

```bash
# 实时监控
kubectl top pod -n jenkins

# 查看详细信息
kubectl describe pod -n jenkins -l app=jenkins
```

### 2. 在 Rancher UI 中查看

1. 进入 Rancher UI
2. 集群 → 工作负载 → Pods
3. 找到 jenkins Pod
4. 查看 "Metrics" 标签页

### 3. 查看 Jenkins 系统信息

1. 登录 Jenkins UI
2. 系统管理 → 系统信息
3. 查看：
   - JVM 内存使用情况
   - 可用处理器数量
   - 系统属性

### 4. 运行测试构建

```bash
# 触发一次完整构建
# 观察构建日志中的耗时

# 对比优化前后的构建时间
```

---

## ⚠️ 注意事项

### 1. 资源充足性检查

**在应用配置前，确保节点有足够资源：**

```bash
# 查看节点资源
kubectl describe nodes | grep -A 5 "Allocated resources"

# 计算总需求
# Master: 2 核 4GB (requests) + 6 核 8GB (limits)
# Agent: 3 核 6GB (requests) + 10 核 12GB (limits)
# 总计: 5 核 10GB (requests) + 16 核 20GB (limits)
```

### 2. 分阶段应用

**建议顺序：**
1. 先优化 Jenkins Master（重启一次）
2. 测试 Master 是否正常
3. 再使用优化后的 Jenkinsfile（Agent 自动应用）

### 3. 监控和调优

**应用后观察 1-2 天：**
- 查看 CPU 和内存使用情况
- 查看是否有 OOM 或 CPU 限流
- 根据实际情况微调

### 4. 回滚方案

**如果出现问题，快速回滚：**

```bash
# 查看历史版本
kubectl rollout history deployment jenkins -n jenkins

# 回滚到上一个版本
kubectl rollout undo deployment jenkins -n jenkins

# 回滚到指定版本
kubectl rollout undo deployment jenkins -n jenkins --to-revision=1
```

---

## 🛠️ 进一步优化建议

### 1. Maven 本地仓库优化

**定期清理：**
```bash
# 进入 Jenkins Pod
kubectl exec -it -n jenkins <jenkins-pod> -- bash

# 清理 Maven 本地仓库（保留最近使用的）
find /var/jenkins_home/maven-repository -type f -atime +30 -delete
```

**使用 Maven 仓库管理器（推荐）：**
- Nexus Repository
- Artifactory
- 可以大幅减少下载时间

### 2. 并行构建

**在 Jenkinsfile 中启用并行构建：**
```groovy
// 已经在 parallel 块中实现
stage('检出子模块') {
    parallel {
        stage('检出 WMS') { ... }
        stage('检出 BI') { ... }
    }
}
```

### 3. 构建缓存

**启用 Docker 层缓存（如果使用 Kaniko）：**
```groovy
// 在 Jenkinsfile 中
--cache=true
--cache-repo=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/cache
```

### 4. 网络优化

**使用国内镜像源：**
- Maven: 阿里云 Maven 镜像
- Docker: 阿里云容器镜像服务
- NPM: 淘宝 NPM 镜像

---

## 📞 常见问题

### Q1: Pod 一直 Pending？
**A:** 节点资源不足，降低 requests 或添加节点

### Q2: 构建过程中 OOMKilled？
**A:** 提高 memory limits 或优化代码

### Q3: 构建速度没有明显提升？
**A:** 检查：
- 存储性能（是否使用 SSD）
- 网络带宽（镜像推送速度）
- Maven 仓库（是否使用本地仓库管理器）

### Q4: Jenkins Master 启动很慢？
**A:**
- 检查插件数量（禁用不需要的插件）
- 检查 PVC 性能
- 增加 initialDelaySeconds

---

## ✅ 检查清单

应用优化前，确认以下事项：

- [ ] 节点有足够的 CPU 和内存资源
- [ ] PVC 使用 SSD 存储
- [ ] 已备份 Jenkins 配置和数据
- [ ] 在非高峰时段进行更新
- [ ] 准备好回滚方案
- [ ] 通知团队成员（Jenkins 会短暂不可用）

应用优化后，验证以下事项：

- [ ] Jenkins Master Pod 正常运行
- [ ] 可以正常登录 Jenkins UI
- [ ] Agent Pod 可以正常启动
- [ ] 测试构建可以成功完成
- [ ] 构建时间有明显缩短
- [ ] 没有 OOM 或资源不足错误

---

## 🎉 总结

通过以上优化，你的 Jenkins 构建速度应该能提升 **40-50%**：

1. **Jenkins Master**: 2 核 4GB → 6 核 8GB
2. **Maven Agent**: 2 核 4GB → 6 核 8GB
3. **Kaniko Agent**: 1 核 2GB → 4 核 4GB
4. **JVM 优化**: 更高效的 GC 和内存管理
5. **镜像推送**: Level 9 压缩 + 重试机制

**立即开始优化吧！** 🚀
