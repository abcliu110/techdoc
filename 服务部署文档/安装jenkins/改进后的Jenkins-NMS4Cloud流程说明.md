# 改进后的 Jenkins-NMS4Cloud 流程说明

## 一、整体流程概览

### 1.1 流程架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                    触发器（自动/手动）                            │
│  • 定时触发：每天凌晨 1 点                                        │
│  • SCM 轮询：每 5 分钟检查代码变更                                │
│  • 手动触发：用户点击构建                                         │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 1: 环境检查                                │
│  • 检查 Java、Maven、Git 版本                                    │
│  • 设置构建显示名称和描述                                         │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 2: 代码检出                                │
│  • 清理工作空间                                                   │
│  • 检出主项目（nms4cloud）                                        │
│  • 检出 WMS 模块（如果启用）                                      │
│  • 检出 BI 模块（如果启用）                                       │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 3: Maven 构建                              │
│  步骤 1：安装父 POM                                               │
│  步骤 2：构建 nms4cloud-starter 及所有子模块                      │
│  步骤 3：构建 biz-api（WMS 依赖）                                 │
│  步骤 4：构建 bi-api（WMS 依赖）                                  │
│  步骤 5：构建 generator 模块（WMS 测试依赖）                      │
│  步骤 6：构建完整的 WMS 模块                                      │
│  步骤 7：构建 nms4cloud-app 其他模块                              │
│  步骤 8：构建 BI 模块                                             │
│  → 生成 jar 文件到 target/ 目录                                   │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 4: 单元测试（可选）                        │
│  • 执行 mvn test                                                  │
│  • 生成测试报告                                                   │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 5: 归档构建产物                            │
│  • 归档所有 jar 文件                                              │
│  • 归档 pom.xml 文件                                              │
│  • 生成指纹（fingerprint）                                        │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Stage 6: 构建 Docker 镜像（可选）                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Jenkins 创建 Kaniko Pod                                  │   │
│  │  • 自动挂载工作空间 PVC                                   │   │
│  │  • 挂载 Docker 认证 Secret                                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         ↓                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  查找所有 *-app 模块                                      │   │
│  │  • nms4cloud-biz-app                                      │   │
│  │  • nms4cloud-wms-app                                      │   │
│  │  • nms4cloud-bi-app                                       │   │
│  │  • ...                                                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         ↓                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  对每个模块执行 Kaniko 构建                               │   │
│  │  1. 检查 Dockerfile 是否存在                              │   │
│  │  2. 检查 target/*.jar 是否存在                            │   │
│  │  3. 执行 /kaniko/executor                                 │   │
│  │     • 读取 Dockerfile                                     │   │
│  │     • 读取 jar 文件（通过共享 PVC）                       │   │
│  │     • 构建镜像层                                          │   │
│  │     • 推送到阿里云镜像仓库                                │   │
│  │       - <app>:<BUILD_NUMBER>                              │   │
│  │       - <app>:latest                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                         ↓                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Kaniko Pod 删除                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                  构建后处理                                       │
│  • 成功：显示成功信息                                             │
│  • 失败：显示失败信息                                             │
│  • 清理：删除 target 目录                                         │
└─────────────────────────────────────────────────────────────────┘
```

## 二、关键改进点

### 2.1 使用 Kaniko 替代传统 Docker 构建

**传统方式的问题：**
```
Jenkins Master Pod
    ↓
需要 Docker Daemon（特权模式）
    ↓
安全风险 + 资源占用
```

**改进后的方式：**
```
Jenkins Master Pod（Maven 构建）
    ↓
动态创建 Kaniko Pod（镜像构建）
    ↓
无需 Docker Daemon + 安全 + 资源隔离
```

### 2.2 PVC 共享机制

**改进前：** 需要手动配置文件传输或共享存储

**改进后：** Jenkins Kubernetes Plugin 自动处理
```
Jenkins Master Pod ──┐
                     ├─→ 共享 PVC ←─ Kaniko Pod
                     │   (自动挂载)
                     └─→ jar 文件自动可见
```

### 2.3 动态 Pod 创建

**改进前：** 固定的 Jenkins Agent

**改进后：** 按需创建 Kaniko Pod
```
构建开始 → 创建 Kaniko Pod → 构建镜像 → 删除 Pod → 释放资源
```

### 2.4 多模块并行构建

**改进后支持：**
- 自动发现所有 `*-app` 模块
- 为每个模块构建独立的 Docker 镜像
- 自动推送到镜像仓库

## 三、详细流程说明

### 3.1 触发机制

#### 自动触发
```groovy
triggers {
    cron('0 1 * * *')           // 每天凌晨 1 点自动构建
    pollSCM('H/5 * * * *')      // 每 5 分钟检查代码变更
}
```

#### 手动触发
- 用户在 Jenkins 界面点击"立即构建"
- 可选择参数：
  - 构建模块（all / nms4cloud-starter / nms4cloud-app）
  - Git 分支
  - 是否跳过测试
  - 是否清理构建
  - 是否构建 Docker 镜像
  - 是否推送 Docker 镜像

### 3.2 Maven 构建流程（核心改进）

#### 依赖关系处理

```
父 POM
  ↓
nms4cloud-starter（所有子模块）
  ↓
biz-api ──┐
          ├─→ WMS 模块依赖
bi-api ───┤
          │
generator─┘
  ↓
WMS 模块（完整构建）
  ↓
nms4cloud-app（其他模块）
  ↓
BI 模块（完整构建）
```

**关键改进：**
- 按依赖顺序构建，避免依赖缺失错误
- 使用 Maven 本地仓库缓存（`/var/jenkins_home/maven-repository`）
- 临时移除 generator 测试依赖，避免循环依赖

### 3.3 Kaniko 构建流程（最大改进）

#### 步骤 1：创建 Kaniko Pod

```groovy
agent {
    kubernetes {
        yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ['/busybox/cat']
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    secret:
      secretName: docker-registry-secret
"""
    }
}
```

**Jenkins 自动添加：**
- 工作空间 Volume 挂载
- jnlp 容器（与 Master 通信）

#### 步骤 2：查找应用模块

```groovy
def appDirs = sh(
    script: 'find . -type d -name "*-app" -path "*/target" -prune -o -type d -name "*-app" -print',
    returnStdout: true
).trim().split('\n')
```

**找到的模块示例：**
- `./nms4cloud-app/2_business/nms4cloud-biz/nms4cloud-biz-app`
- `./nms4cloud-wms/nms4cloud-wms-app`
- `./nms4cloud-bi/nms4cloud-bi-app`

#### 步骤 3：为每个模块构建镜像

```groovy
appDirs.each { appDir ->
    buildDockerImageWithKaniko(appDir)
}
```

**单个模块的构建过程：**

```groovy
dir(appDir) {
    // 1. 验证文件存在
    def hasDockerfile = fileExists('Dockerfile')
    def hasJar = sh(script: 'ls target/*.jar 2>/dev/null | wc -l', returnStdout: true).trim() != '0'

    if (hasDockerfile && hasJar) {
        // 2. 执行 Kaniko 构建
        sh """
            /kaniko/executor \
              --context=\$(pwd) \
              --dockerfile=Dockerfile \
              --destination=${imageName}:${IMAGE_TAG} \
              --destination=${imageName}:latest \
              --cache=true \
              --cache-repo=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/cache \
              --skip-tls-verify
        """
    }
}
```

#### 步骤 4：镜像推送

**自动推送到阿里云：**
```
registry.cn-hangzhou.aliyuncs.com/nms4cloud/biz-app:123
registry.cn-hangzhou.aliyuncs.com/nms4cloud/biz-app:latest
```

## 四、是否是循环流程？

### 4.1 流程本身不是循环

**Pipeline 执行是线性的：**
```
开始 → Stage 1 → Stage 2 → Stage 3 → ... → Stage 6 → 结束
```

每次执行都是从头到尾的完整流程，不是循环。

### 4.2 但有自动重复触发机制

**触发器形成"外部循环"：**

```
┌─────────────────────────────────────────┐
│  定时触发器（每天凌晨 1 点）             │
│         ↓                                │
│  ┌──────────────────────┐                │
│  │  执行完整 Pipeline    │                │
│  │  Stage 1 → 6         │                │
│  └──────────────────────┘                │
│         ↓                                │
│  等待下一次触发 ──────────┘              │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  SCM 轮询（每 5 分钟检查）               │
│         ↓                                │
│  检测到代码变更？                        │
│    是 → 执行 Pipeline                    │
│    否 → 继续等待 ──────────┘             │
└─────────────────────────────────────────┘
```

### 4.3 Stage 6 内部有循环

**唯一的循环在 Kaniko 构建阶段：**

```groovy
// 遍历所有 *-app 模块
appDirs.each { appDir ->
    // 为每个模块构建镜像
    buildDockerImageWithKaniko(appDir)
}
```

**示例：**
```
找到 3 个模块：
  循环 1：构建 biz-app 镜像
  循环 2：构建 wms-app 镜像
  循环 3：构建 bi-app 镜像
```

## 五、完整时序图

```
时间轴
  │
  ├─ T0: 触发构建（定时/手动/SCM）
  │
  ├─ T1: 环境检查（10秒）
  │      └─ 检查 Java、Maven、Git
  │
  ├─ T2: 代码检出（1-2分钟）
  │      ├─ 清理工作空间
  │      ├─ 检出主项目
  │      ├─ 检出 WMS 模块
  │      └─ 检出 BI 模块
  │
  ├─ T3: Maven 构建（10-15分钟）
  │      ├─ 安装父 POM
  │      ├─ 构建 starter 模块
  │      ├─ 构建 biz-api
  │      ├─ 构建 bi-api
  │      ├─ 构建 generator
  │      ├─ 构建 WMS 模块
  │      ├─ 构建 app 模块
  │      └─ 构建 BI 模块
  │      → jar 文件写入 PVC
  │
  ├─ T4: 单元测试（可选，2-5分钟）
  │      └─ 执行测试并生成报告
  │
  ├─ T5: 归档产物（30秒）
  │      └─ 归档 jar 和 pom 文件
  │
  ├─ T6: 构建 Docker 镜像（可选，5-10分钟）
  │      │
  │      ├─ T6.1: 创建 Kaniko Pod（30秒）
  │      │        └─ Jenkins 调用 K8s API
  │      │
  │      ├─ T6.2: 查找应用模块（5秒）
  │      │        └─ find 命令查找 *-app
  │      │
  │      ├─ T6.3: 循环构建镜像（每个模块 2-3分钟）
  │      │        │
  │      │        ├─ 模块 1: biz-app
  │      │        │   ├─ 检查 Dockerfile 和 jar
  │      │        │   ├─ Kaniko 读取文件（从 PVC）
  │      │        │   ├─ 构建镜像层
  │      │        │   └─ 推送到阿里云
  │      │        │
  │      │        ├─ 模块 2: wms-app
  │      │        │   └─ （同上）
  │      │        │
  │      │        └─ 模块 3: bi-app
  │      │            └─ （同上）
  │      │
  │      └─ T6.4: 删除 Kaniko Pod（10秒）
  │
  └─ T7: 构建后处理（10秒）
         ├─ 显示构建结果
         └─ 清理临时文件
```

**总耗时估算：**
- 不构建镜像：约 15-20 分钟
- 构建镜像（3个模块）：约 25-35 分钟

## 六、关键配置文件

### 6.1 Jenkinsfile 结构

```
Jenkinsfile-nms4cloud-optimized
├── environment（环境变量）
│   ├── Maven 配置
│   ├── Git 配置
│   └── Docker 配置
├── parameters（参数化构建）
│   ├── BUILD_MODULE
│   ├── GIT_BRANCH
│   ├── SKIP_TESTS
│   ├── CLEAN_BUILD
│   ├── BUILD_DOCKER_IMAGE
│   └── PUSH_DOCKER_IMAGE
├── options（构建选项）
├── triggers（触发器）
├── stages（构建阶段）
│   ├── Stage 1: 环境检查
│   ├── Stage 2: 代码检出
│   ├── Stage 3: Maven 构建
│   ├── Stage 4: 单元测试
│   ├── Stage 5: 归档构建产物
│   └── Stage 6: 构建 Docker 镜像
│       └── agent { kubernetes { ... } }  ← Kaniko Pod
├── post（构建后处理）
└── 辅助函数
    ├── checkoutRepo()
    ├── buildStep()
    ├── buildModule()
    ├── buildMainProject()
    └── buildDockerImageWithKaniko()  ← 核心函数
```

### 6.2 Dockerfile 配置

```dockerfile
# Dockerfile-kaniko
FROM eclipse-temurin:21-jre
WORKDIR /app

# 时区和语言
ENV TZ=Asia/Shanghai
ENV LANG=C.UTF-8

# 复制 jar 文件（相对路径）
COPY target/*.jar app.jar

# 复制配置文件
COPY src/main/resources/ ./config/

# JVM 参数
ENV JAVA_OPTS="-Xms512m -Xmx2048m ..."

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
```

### 6.3 Kubernetes Secret

```yaml
# docker-registry-secret
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
  namespace: jenkins
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64-encoded-docker-config>
```

**内容格式：**
```json
{
  "auths": {
    "registry.cn-hangzhou.aliyuncs.com": {
      "username": "your-username",
      "password": "your-password",
      "auth": "base64(username:password)"
    }
  }
}
```

## 七、监控和调试

### 7.1 查看构建日志

```bash
# 查看 Jenkins 构建日志
kubectl logs -n jenkins <jenkins-pod-name> -f

# 查看 Kaniko Pod 日志
kubectl logs -n jenkins <kaniko-pod-name> -c kaniko -f
```

### 7.2 调试 Kaniko 构建

在 Jenkinsfile 中添加：

```groovy
container('kaniko') {
    sh '''
        echo "=== 工作目录 ==="
        pwd

        echo "=== 文件列表 ==="
        ls -lah

        echo "=== jar 文件 ==="
        ls -lh target/

        echo "=== Dockerfile ==="
        cat Dockerfile

        echo "=== 挂载点 ==="
        df -h | grep jenkins
    '''
}
```

### 7.3 查看镜像推送状态

```bash
# 查看阿里云镜像
docker pull registry.cn-hangzhou.aliyuncs.com/nms4cloud/biz-app:latest

# 或使用 skopeo
skopeo inspect docker://registry.cn-hangzhou.aliyuncs.com/nms4cloud/biz-app:latest
```

## 八、总结

### 8.1 改进后的优势

| 方面 | 改进前 | 改进后 |
|------|--------|--------|
| **镜像构建** | Docker-in-Docker（特权模式） | Kaniko（用户空间，安全） |
| **资源使用** | Jenkins Master 负载重 | 动态 Pod，按需创建 |
| **文件共享** | 手动配置 | 自动 PVC 挂载 |
| **多模块构建** | 手动指定 | 自动发现并构建 |
| **镜像推送** | 需要额外配置 | Kaniko 直接推送 |
| **安全性** | 需要特权容器 | 普通用户权限 |
| **可扩展性** | 受限于 Master 资源 | 可水平扩展 |

### 8.2 核心技术栈

```
Jenkins (Master)
    ↓
Jenkins Kubernetes Plugin
    ↓
Kubernetes (RKE2)
    ↓
PersistentVolume (Longhorn)
    ↓
Kaniko (镜像构建)
    ↓
阿里云容器镜像仓库
```

### 8.3 关键流程

**不是循环，而是：**
1. ✅ 线性的 Pipeline 执行流程
2. ✅ 外部触发器可以重复执行整个流程
3. ✅ Stage 6 内部循环构建多个模块的镜像
4. ✅ 每次执行都是独立的、完整的构建过程