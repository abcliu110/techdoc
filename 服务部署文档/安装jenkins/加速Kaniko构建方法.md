# 加速Kaniko构建的方法

## 问题分析

从日志看，Kaniko在拉取基础镜像时超时：
```
Retrieving image manifest eclipse-temurin:21-jre
Retrieving image eclipse-temurin:21-jre from registry index.docker.io
Body did not finish within grace period; terminating with extreme prejudice
```

**原因：**
- Docker Hub (index.docker.io) 在国内访问很慢
- 基础镜像 `eclipse-temurin:21-jre` 约 220MB
- 网络超时导致构建失败

---

## 解决方案

### 方案1：使用国内镜像源（推荐）⭐⭐⭐

#### 1.1 修改所有Dockerfile

**原来的Dockerfile：**
```dockerfile
FROM eclipse-temurin:21-jre
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

**修改为使用阿里云镜像：**
```dockerfile
# 使用阿里云镜像加速
FROM registry.cn-hangzhou.aliyuncs.com/zhangshier/eclipse-temurin:21-jre
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

或者使用DaoCloud镜像：
```dockerfile
FROM m.daocloud.io/docker.io/library/eclipse-temurin:21-jre
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

#### 1.2 批量修改脚本

```bash
#!/bin/bash
# 批量修改所有Dockerfile使用国内镜像源

# 查找所有Dockerfile
find . -name "Dockerfile" -type f | while read dockerfile; do
    echo "处理: $dockerfile"

    # 备份
    cp "$dockerfile" "$dockerfile.bak"

    # 替换镜像源
    sed -i 's|FROM eclipse-temurin:21-jre|FROM m.daocloud.io/docker.io/library/eclipse-temurin:21-jre|g' "$dockerfile"

    echo "✓ 已修改"
done

echo ""
echo "✓ 所有Dockerfile已修改为使用国内镜像源"
```

---

### 方案2：配置Kubernetes镜像加速

#### 2.1 配置containerd镜像加速（RKE2）

编辑 `/etc/rancher/rke2/registries.yaml`：

```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://docker.m.daocloud.io"
      - "https://dockerproxy.com"
      - "https://docker.mirrors.ustc.edu.cn"
      - "https://registry.docker-cn.com"

configs:
  "docker.io":
    tls:
      insecure_skip_verify: true
```

重启RKE2：
```bash
systemctl restart rke2-server
# 或
systemctl restart rke2-agent
```

#### 2.2 验证配置

```bash
# 查看配置
crictl info | grep -A 10 registry

# 测试拉取
crictl pull eclipse-temurin:21-jre
```

---

### 方案3：预先拉取基础镜像到所有节点

#### 3.1 使用DaemonSet预拉取

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: pull-base-images
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: pull-base-images
  template:
    metadata:
      labels:
        app: pull-base-images
    spec:
      initContainers:
      # 拉取eclipse-temurin
      - name: pull-eclipse-temurin
        image: eclipse-temurin:21-jre
        command: ['sh', '-c', 'echo "Image pulled"']
      # 拉取maven
      - name: pull-maven
        image: maven:3.9-eclipse-temurin-21
        command: ['sh', '-c', 'echo "Image pulled"']
      containers:
      - name: pause
        image: registry.k8s.io/pause:3.9
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
```

应用：
```bash
kubectl apply -f pull-base-images-daemonset.yaml

# 等待完成
kubectl get pods -n kube-system -l app=pull-base-images

# 删除DaemonSet
kubectl delete daemonset pull-base-images -n kube-system
```

#### 3.2 手动在每个节点拉取

```bash
# 在每个Kubernetes节点上执行
crictl pull eclipse-temurin:21-jre
crictl pull maven:3.9-eclipse-temurin-21

# 验证
crictl images | grep eclipse-temurin
```

---

### 方案4：增加Kaniko超时时间

修改Jenkinsfile，增加超时时间：

```groovy
# 从 60 分钟增加到 120 分钟
timeout 7200 /kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    ...
```

但这只是治标不治本，建议配合方案1或方案2使用。

---

### 方案5：启用Kaniko缓存

修改Jenkinsfile，启用缓存：

```groovy
/kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    --cache=true \                           # 启用缓存
    --cache-repo=${HARBOR_REGISTRY}/cache \  # 缓存仓库
    --cache-ttl=168h \                       # 缓存7天
    ...
```

**注意：** 需要在Harbor中创建 `cache` 项目。

---

## 推荐方案组合

### 最佳实践（推荐）⭐⭐⭐

**1. 修改Dockerfile使用国内镜像源**
```dockerfile
FROM m.daocloud.io/docker.io/library/eclipse-temurin:21-jre
```

**2. 配置Kubernetes镜像加速**
```yaml
# /etc/rancher/rke2/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://docker.m.daocloud.io"
```

**3. 预先拉取基础镜像**
```bash
crictl pull m.daocloud.io/docker.io/library/eclipse-temurin:21-jre
```

**4. 启用Kaniko缓存**
```groovy
--cache=true
--cache-repo=${HARBOR_REGISTRY}/cache
```

---

## 效果对比

| 方案 | 首次构建 | 后续构建 | 难度 | 推荐度 |
|------|---------|---------|------|--------|
| 使用国内镜像源 | 30秒 | 30秒 | 简单 | ⭐⭐⭐ |
| 配置镜像加速 | 1分钟 | 10秒 | 中等 | ⭐⭐⭐ |
| 预拉取镜像 | 5秒 | 5秒 | 简单 | ⭐⭐ |
| 增加超时 | 5分钟+ | 5分钟+ | 简单 | ⭐ |
| 启用缓存 | 2分钟 | 30秒 | 中等 | ⭐⭐ |
| **组合方案** | **10秒** | **5秒** | 中等 | **⭐⭐⭐** |

---

## 立即可用的解决方案

### 快速修复（5分钟内）

1. **批量修改Dockerfile**
```bash
cd /path/to/project
find . -name "Dockerfile" -type f -exec sed -i 's|FROM eclipse-temurin:21-jre|FROM m.daocloud.io/docker.io/library/eclipse-temurin:21-jre|g' {} \;
```

2. **提交修改**
```bash
git add .
git commit -m "使用国内镜像源加速构建"
git push
```

3. **重新运行Jenkins构建**

---

## 验证效果

修改后，构建日志应该显示：
```
[INFO] Retrieving image manifest m.daocloud.io/docker.io/library/eclipse-temurin:21-jre
[INFO] Retrieving image m.daocloud.io/docker.io/library/eclipse-temurin:21-jre from registry m.daocloud.io
[INFO] Built cross stage deps: map[]
[INFO] Executing 0 build triggers
[INFO] Unpacking rootfs as cmd COPY target/*.jar app.jar requires it.
✓ 镜像构建完成 (耗时: 0分15秒)  ← 快很多！
```

---

## 相关文件

- `pull-base-images.sh` - 预拉取镜像脚本
- `registries.yaml` - Kubernetes镜像加速配置示例

选择最适合你的方案，推荐使用**方案1（修改Dockerfile）+ 方案2（配置镜像加速）**的组合！
