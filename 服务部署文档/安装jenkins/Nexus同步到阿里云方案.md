# Nexus 镜像同步到阿里云方案

## 方案 1: Jenkins 双推送（推荐）

在 Jenkins 构建时同时推送到 Nexus（快速）和阿里云（生产）。

### 修改 Jenkinsfile 环境变量

```groovy
environment {
    // Nexus 本地仓库（快速推送）
    NEXUS_REGISTRY = '<节点IP>:30005'

    // 阿里云镜像仓库（生产环境）
    ALIYUN_REGISTRY = 'crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com'
    ALIYUN_NAMESPACE = 'lgy-images'

    DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
}
```

### 修改 buildModuleImage 函数

在 Kaniko 构建时同时推送到两个仓库：

```groovy
def buildModuleImage(String moduleName, String modulePath) {
    def dockerfilePath = "${WORKSPACE}/${modulePath}/Dockerfile"
    def buildContext = "${WORKSPACE}/${modulePath}"

    // Nexus 镜像地址
    def nexusImageName = "${NEXUS_REGISTRY}/${moduleName}"

    // 阿里云镜像地址
    def aliyunImageName = "${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${moduleName}"

    try {
        sh """
            echo ">>> 构建并推送镜像到 Nexus 和阿里云"

            # 使用 Kaniko 同时推送到两个仓库
            /kaniko/executor \\
                --context=${buildContext} \\
                --dockerfile=${dockerfilePath} \\
                --destination=${nexusImageName}:${DOCKER_IMAGE_TAG} \\
                --destination=${nexusImageName}:latest \\
                --destination=${aliyunImageName}:${DOCKER_IMAGE_TAG} \\
                --destination=${aliyunImageName}:latest \\
                --insecure \\
                --skip-tls-verify \\
                --compression=gzip \\
                --compression-level=9 \\
                --push-retry=3 \\
                --cache=false

            echo "✓ 镜像已推送到:"
            echo "  - Nexus: ${nexusImageName}:${DOCKER_IMAGE_TAG}"
            echo "  - 阿里云: ${aliyunImageName}:${DOCKER_IMAGE_TAG}"
        """

        return [success: true, imageName: "${nexusImageName}:${DOCKER_IMAGE_TAG}", reason: ""]
    } catch (Exception e) {
        echo "❌ 构建失败: ${moduleName}"
        return [success: false, imageName: null, reason: e.message]
    }
}
```

**优势：**
- ✅ 本地推送到 Nexus 超快（2-20秒）
- ✅ 同时推送到阿里云（生产环境可用）
- ✅ 一次构建，两个仓库都有

---

## 方案 2: 定时同步脚本

构建时只推送到 Nexus，定时将镜像同步到阿里云。

### 创建同步脚本

```bash
#!/bin/bash
# sync-to-aliyun.sh - 同步 Nexus 镜像到阿里云

NEXUS_REGISTRY="<节点IP>:30005"
ALIYUN_REGISTRY="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com"
ALIYUN_NAMESPACE="lgy-images"

# 要同步的镜像列表
IMAGES=(
    "nms4cloud-platform"
    "nms4cloud-mq"
    "nms4cloud-netty"
    "nms4cloud-reg"
    "nms4cloud-wechat"
    "nms4cloud-biz"
    "nms4cloud-crm"
    "nms4cloud-mall"
    "nms4cloud-payment"
    "nms4cloud-pos"
    "nms4cloud-product"
    "nms4cloud-scm"
    "nms4cloud-order"
)

echo "=== 开始同步镜像到阿里云 ==="

for IMAGE in "${IMAGES[@]}"; do
    echo ""
    echo ">>> 同步镜像: $IMAGE"

    # 从 Nexus 拉取
    echo "  - 从 Nexus 拉取..."
    docker pull ${NEXUS_REGISTRY}/${IMAGE}:latest

    # 重新标记为阿里云地址
    echo "  - 标记为阿里云地址..."
    docker tag ${NEXUS_REGISTRY}/${IMAGE}:latest \
               ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE}:latest

    # 推送到阿里云
    echo "  - 推送到阿里云..."
    docker push ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE}:latest

    # 清理本地镜像
    docker rmi ${NEXUS_REGISTRY}/${IMAGE}:latest
    docker rmi ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${IMAGE}:latest

    echo "  ✓ $IMAGE 同步完成"
done

echo ""
echo "=== 所有镜像同步完成 ==="
```

### 设置定时任务

```bash
# 添加到 crontab（每天凌晨2点同步）
crontab -e

# 添加以下行
0 2 * * * /path/to/sync-to-aliyun.sh >> /var/log/nexus-sync.log 2>&1
```

---

## 方案 3: 手动同步特定镜像

需要时手动同步特定镜像到阿里云。

### 单个镜像同步

```bash
# 1. 从 Nexus 拉取
docker pull <节点IP>:30005/nms4cloud-platform:25

# 2. 重新标记
docker tag <节点IP>:30005/nms4cloud-platform:25 \
           crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-platform:25

# 3. 推送到阿里云
docker push crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-platform:25
```

### 批量同步脚本

```bash
#!/bin/bash
# 同步指定 tag 的所有镜像

TAG=$1  # 例如: 25

if [ -z "$TAG" ]; then
    echo "用法: $0 <tag>"
    exit 1
fi

NEXUS_REGISTRY="<节点IP>:30005"
ALIYUN_REGISTRY="crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images"

MODULES=(
    "nms4cloud-platform"
    "nms4cloud-mq"
    # ... 其他模块
)

for MODULE in "${MODULES[@]}"; do
    echo "同步 $MODULE:$TAG"
    docker pull ${NEXUS_REGISTRY}/${MODULE}:${TAG}
    docker tag ${NEXUS_REGISTRY}/${MODULE}:${TAG} ${ALIYUN_REGISTRY}/${MODULE}:${TAG}
    docker push ${ALIYUN_REGISTRY}/${MODULE}:${TAG}
done
```

使用：
```bash
bash sync-tag.sh 25  # 同步 tag 25 的所有镜像
```

---

## 方案 4: Jenkins Pipeline 后置同步

在 Jenkins 构建完成后，添加同步阶段。

### 添加同步阶段到 Jenkinsfile

```groovy
stage('同步镜像到阿里云') {
    when {
        expression { params.SYNC_TO_ALIYUN == true }
    }
    steps {
        container('docker') {  // 需要 Docker 容器
            script {
                def modules = getDockerModules()

                modules.each { module ->
                    sh """
                        echo ">>> 同步 ${module.name} 到阿里云"

                        # 从 Nexus 拉取
                        docker pull ${NEXUS_REGISTRY}/${module.name}:${DOCKER_IMAGE_TAG}

                        # 标记为阿里云地址
                        docker tag ${NEXUS_REGISTRY}/${module.name}:${DOCKER_IMAGE_TAG} \\
                                   ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${module.name}:${DOCKER_IMAGE_TAG}

                        # 推送到阿里云
                        docker push ${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${module.name}:${DOCKER_IMAGE_TAG}

                        echo "✓ ${module.name} 同步完成"
                    """
                }
            }
        }
    }
}
```

添加参数：
```groovy
parameters {
    booleanParam(
        name: 'SYNC_TO_ALIYUN',
        defaultValue: false,
        description: '构建完成后同步镜像到阿里云'
    )
}
```

---

## 推荐方案对比

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|---------|
| 方案1: 双推送 | 实时同步，一次构建 | 构建时间稍长 | 每次构建都需要生产镜像 |
| 方案2: 定时同步 | 构建快速，批量同步 | 不是实时的 | 定期发布到生产 |
| 方案3: 手动同步 | 灵活可控 | 需要手动操作 | 偶尔发布到生产 |
| 方案4: 后置同步 | 可选同步，灵活 | 需要 Docker 容器 | 按需同步到生产 |

## 我的建议

**开发阶段：** 只推送到 Nexus（快速）
**发布阶段：** 使用方案1双推送，或方案2定时同步

这样既能享受 Nexus 的快速推送，又能保证生产环境的镜像可用。
