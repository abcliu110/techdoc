# 配置Harbor作为Docker Hub代理

## 方案说明

让Kaniko从本地Harbor拉取基础镜像，而不是从Docker Hub拉取。

### 架构图

```
Kaniko → Harbor (代理) → Docker Hub (或国内镜像源)
         ↓ 缓存
      本地存储
```

---

## 步骤1：在Harbor中创建代理项目

### 1.1 登录Harbor Web界面

访问：http://harbor-core.harbor

### 1.2 创建代理项目

1. 点击 **"项目"** → **"新建项目"**

2. 填写项目信息：
   - **项目名称**: `dockerhub-proxy`
   - **访问级别**: 公开
   - **代理缓存**: ✅ 启用

3. 配置代理设置：
   - **提供者**: Docker Hub
   - **端点URL**:
     - 官方源: `https://registry-1.docker.io`
     - 或国内源: `https://docker.m.daocloud.io`
   - **访问ID**: (留空，公开镜像不需要)
   - **访问密钥**: (留空)

4. 点击 **"测试连接"** 验证

5. 点击 **"确定"** 创建

---

## 步骤2：修改Jenkinsfile使用Harbor代理

### 2.1 添加环境变量

在Jenkinsfile中添加：

```groovy
environment {
    // Harbor代理配置
    HARBOR_PROXY = 'harbor-core.harbor/dockerhub-proxy'
    BASE_IMAGE = "${HARBOR_PROXY}/library/eclipse-temurin:21-jre"
}
```

### 2.2 修改Kaniko构建命令

在 `buildModuleImage` 函数中添加 `--build-arg`：

```groovy
/kaniko/executor \
    --context=${buildContext} \
    --dockerfile=${dockerfilePath} \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    --destination=${harborImageName}:${DOCKER_IMAGE_TAG} \
    ...
```

### 2.3 修改Dockerfile使用构建参数

**原来的Dockerfile:**
```dockerfile
FROM eclipse-temurin:21-jre
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

**修改为:**
```dockerfile
ARG BASE_IMAGE=eclipse-temurin:21-jre
FROM ${BASE_IMAGE}
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

这样：
- 如果提供了 `BASE_IMAGE` 参数，使用Harbor代理
- 如果没有提供，使用默认的Docker Hub（兼容本地开发）

---

## 步骤3：预热Harbor缓存

首次使用前，预先拉取镜像到Harbor：

```bash
# 方法1：使用docker拉取并推送
docker pull eclipse-temurin:21-jre
docker tag eclipse-temurin:21-jre harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
docker push harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre

# 方法2：使用Harbor的预热功能（推荐）
# 在Harbor Web界面中：
# 项目 → dockerhub-proxy → 预热 → 添加预热策略
# 镜像: library/eclipse-temurin:21-jre
```

---

## 完整的Jenkinsfile修改示例

### 修改 Jenkinsfile-nms4cloud-final

```groovy
environment {
    // ... 其他配置

    // Harbor代理配置
    HARBOR_PROXY = 'harbor-core.harbor/dockerhub-proxy'
    BASE_IMAGE = "${HARBOR_PROXY}/library/eclipse-temurin:21-jre"
}

def buildModuleImage(String moduleName, String modulePath) {
    // ... 前面的代码

    sh """
        # ... 验证代码

        # ========== 第1步: 构建镜像（不推送） ==========
        echo ">>> [1/2] 开始构建镜像..."
        echo "  使用基础镜像: ${BASE_IMAGE}"
        BUILD_START=\$(date +%s)

        /kaniko/executor \\
            --context=${buildContext} \\
            --dockerfile=${dockerfilePath} \\
            --build-arg BASE_IMAGE=${BASE_IMAGE} \\
            --no-push \\
            --tar-path=/tmp/${moduleName}-image.tar \\
            ...

        # ========== 第2步: 推送镜像到Harbor ==========
        echo ">>> [2/2] 开始推送镜像到Harbor..."
        PUSH_START=\$(date +%s)

        timeout 1800 /kaniko/executor \\
            --context=${buildContext} \\
            --dockerfile=${dockerfilePath} \\
            --build-arg BASE_IMAGE=${BASE_IMAGE} \\
            \${DESTINATIONS} \\
            ...
    """
}
```

---

## 方案对比

### 方案A：修改Dockerfile（需要改代码）

```dockerfile
FROM harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
```

**优点：**
- ✅ 最简单
- ✅ 速度最快

**缺点：**
- ❌ 需要修改代码
- ❌ 本地开发需要访问Harbor

### 方案B：使用构建参数（推荐）⭐

```dockerfile
ARG BASE_IMAGE=eclipse-temurin:21-jre
FROM ${BASE_IMAGE}
```

```groovy
--build-arg BASE_IMAGE=harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
```

**优点：**
- ✅ 不破坏原有逻辑
- ✅ 本地开发仍可用
- ✅ Jenkins构建使用Harbor

**缺点：**
- ❌ 需要修改Dockerfile（但改动很小）
- ❌ 需要修改Jenkinsfile

### 方案C：配置Kubernetes镜像加速（之前的方案）

**优点：**
- ✅ 完全不修改代码

**缺点：**
- ❌ 需要配置所有节点
- ❌ 需要重启RKE2
- ❌ 首次仍需从外网拉取

---

## 推荐方案：方案B（构建参数）

### 优势

1. **最小改动**
   - Dockerfile只加2行
   - Jenkinsfile加几行配置

2. **兼容性好**
   - 本地开发：使用默认镜像
   - Jenkins构建：使用Harbor代理

3. **速度最快**
   - 从本地Harbor拉取
   - 通常 < 5秒

---

## 实施步骤总结

### 1. 在Harbor中创建代理项目
```
项目名称: dockerhub-proxy
代理端点: https://docker.m.daocloud.io
```

### 2. 修改Dockerfile（所有项目）
```dockerfile
ARG BASE_IMAGE=eclipse-temurin:21-jre
FROM ${BASE_IMAGE}
```

### 3. 修改Jenkinsfile
```groovy
environment {
    BASE_IMAGE = "harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre"
}

# 在kaniko命令中添加
--build-arg BASE_IMAGE=${BASE_IMAGE}
```

### 4. 预热Harbor缓存
```bash
docker pull eclipse-temurin:21-jre
docker tag eclipse-temurin:21-jre harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
docker push harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
```

---

## 效果

**配置前：**
```
Retrieving image eclipse-temurin:21-jre from registry index.docker.io
Timeout has been exceeded (60秒+)
```

**配置后：**
```
Retrieving image harbor-core.harbor/dockerhub-proxy/library/eclipse-temurin:21-jre
✓ Image pulled successfully (3秒)
```

**速度提升：20倍+**

---

需要我帮你生成具体的修改代码吗？
