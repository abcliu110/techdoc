# Jenkinsfile 双推送功能说明

## 概述

Jenkinsfile-k8s 已升级到 v10.0，支持同时推送 Docker 镜像到 Harbor 本地仓库和阿里云镜像仓库。通过 Jenkins 构建参数，可以灵活控制推送目标。

## 主要特性

### 1. 双推送支持
- **Harbor 本地仓库**：快速推送，适合内网部署
- **阿里云镜像仓库**：云端备份，适合外网访问
- **灵活控制**：通过构建参数选择推送目标

### 2. 新增构建参数

| 参数名称 | 类型 | 默认值 | 说明 |
|---------|------|--------|------|
| `PUSH_TO_HARBOR` | Boolean | true | 推送镜像到 Harbor 本地仓库 |
| `PUSH_TO_ALIYUN` | Boolean | true | 推送镜像到阿里云镜像仓库 |

### 3. 环境变量配置

```groovy
// Harbor 本地镜像仓库配置
HARBOR_REGISTRY = '192.168.1.100:30002'  // 修改为实际的 Harbor 地址
HARBOR_PROJECT = 'library'  // 修改为实际的 Harbor 项目名称
HARBOR_REPOSITORY_NAME = 'demo-springboot'
HARBOR_IMAGE_NAME = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${HARBOR_REPOSITORY_NAME}"

// 阿里云镜像仓库配置（保持不变）
DOCKER_REGISTRY = 'crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com'
DOCKER_NAMESPACE = 'lgy-images'
DOCKER_REPOSITORY_NAME = 'demo-springboot'
DOCKER_IMAGE_NAME = "${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${DOCKER_REPOSITORY_NAME}"
```

## 使用场景

### 场景 1：同时推送到两个仓库（默认）
- **用途**：生产环境，需要本地和云端双备份
- **配置**：
  - `PUSH_TO_HARBOR` = true
  - `PUSH_TO_ALIYUN` = true
- **结果**：镜像同时推送到 Harbor 和阿里云

### 场景 2：仅推送到 Harbor
- **用途**：开发/测试环境，快速迭代
- **配置**：
  - `PUSH_TO_HARBOR` = true
  - `PUSH_TO_ALIYUN` = false
- **优势**：推送速度快（本地网络），节省云端流量

### 场景 3：仅推送到阿里云
- **用途**：云端部署，不使用本地仓库
- **配置**：
  - `PUSH_TO_HARBOR` = false
  - `PUSH_TO_ALIYUN` = true
- **优势**：适合纯云端架构

## 技术实现

### 1. 多仓库认证配置

Jenkinsfile 使用两个独立的 Secret：
- `aliyun-registry-secret`：阿里云镜像仓库认证
- `harbor-registry-secret`：Harbor 本地仓库认证

在 Kaniko 容器启动时，自动合并两个认证配置：

```bash
# 合并 Docker 认证配置
mkdir -p /kaniko/.docker
echo '{"auths":{}}' > /kaniko/.docker/config.json

# 合并阿里云配置
if [ "${params.PUSH_TO_ALIYUN}" = "true" ]; then
    jq -s '.[0].auths * .[1].auths | {auths: .}' \
        /kaniko/.docker/config.json \
        /kaniko/.docker/aliyun/config.json > /tmp/merged.json
    mv /tmp/merged.json /kaniko/.docker/config.json
fi

# 合并 Harbor 配置
if [ "${params.PUSH_TO_HARBOR}" = "true" ]; then
    jq -s '.[0].auths * .[1].auths | {auths: .}' \
        /kaniko/.docker/config.json \
        /kaniko/.docker/harbor/config.json > /tmp/merged.json
    mv /tmp/merged.json /kaniko/.docker/config.json
fi
```

### 2. 动态构建推送目标

根据构建参数动态生成 Kaniko 的 `--destination` 参数：

```bash
DESTINATIONS=""

if [ "${params.PUSH_TO_HARBOR}" = "true" ]; then
    DESTINATIONS="${DESTINATIONS} --destination=${HARBOR_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    DESTINATIONS="${DESTINATIONS} --destination=${HARBOR_IMAGE_NAME}:latest"
fi

if [ "${params.PUSH_TO_ALIYUN}" = "true" ]; then
    DESTINATIONS="${DESTINATIONS} --destination=${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
    DESTINATIONS="${DESTINATIONS} --destination=${DOCKER_IMAGE_NAME}:latest"
fi

/kaniko/executor \
    --context=${WORKSPACE} \
    --dockerfile=${WORKSPACE}/Dockerfile \
    ${DESTINATIONS} \
    --compressed-caching=true \
    --compression=gzip \
    --compression-level=9 \
    --push-retry=3
```

### 3. 推送时间预估

根据推送目标数量和网络速度预估推送时间：

- **Harbor 本地推送**：约 10 MB/s（千兆网络）
- **阿里云推送**：约 0.5-1 MB/s（个人版带宽限制）

示例：
- 镜像大小：250 MB
- 仅 Harbor：约 25 秒
- 仅阿里云：约 4-8 分钟
- 双推送：约 4-8 分钟（并行推送，以最慢的为准）

## 前置要求

### 1. Harbor 部署
参考文档：`Harbor-Helm完整部署指南.md`

```bash
# 使用 Helm 部署 Harbor
helm install harbor harbor/harbor \
  -f harbor-helm-values.yaml \
  -n harbor \
  --create-namespace
```

### 2. 创建 Harbor Secret
参考文档：`创建Harbor镜像仓库Secret.md`

```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

### 3. 创建 Harbor 项目

在 Harbor Web UI 中创建项目：
1. 访问 Harbor：http://192.168.1.100:30002
2. 登录（默认：admin/Harbor12345）
3. 创建项目：library（或其他名称）
4. 设置项目为公开或私有

### 4. 修改 Jenkinsfile 配置

更新 Harbor 地址和项目名称：

```groovy
HARBOR_REGISTRY = '192.168.1.100:30002'  // 修改为实际地址
HARBOR_PROJECT = 'library'  // 修改为实际项目名称
```

## 构建流程

### 1. 触发构建

在 Jenkins 中选择项目，点击"Build with Parameters"：

```
GIT_BRANCH: master
SKIP_TESTS: true
CLEAN_BUILD: true
BUILD_DOCKER_IMAGE: true
PUSH_TO_HARBOR: true      ← 推送到 Harbor
PUSH_TO_ALIYUN: true      ← 推送到阿里云
```

### 2. 构建输出示例

```
╔════════════════════════════════════════╗
║    构建并推送 Docker 镜像 (Kaniko)      ║
╚════════════════════════════════════════╝
推送目标: Harbor (192.168.1.100:30002), 阿里云 (crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com)
镜像标签: 42, latest
工作目录: /var/jenkins_home/workspace/demo-springboot

>>> 合并镜像仓库认证配置
  - 添加阿里云仓库认证
  - 添加 Harbor 仓库认证

╔════════════════════════════════════════╗
║         镜像大小预估                    ║
╚════════════════════════════════════════╝
>>> JAR 文件大小:
    target/demo-springboot-1.0.0.jar: 25M
    总计: 25 MB
>>> 配置文件大小: 1 MB
>>> 基础镜像大小: 220 MB (eclipse-temurin:21-jre)

>>> 预估镜像总大小: 246 MB
>>> 推送目标数量: 2
>>> 预估阿里云推送时间: 4-8 分钟
>>> 预估 Harbor 推送时间: 0 分钟

>>> 添加 Harbor 推送目标
>>> 添加阿里云推送目标
>>> 开始构建和推送镜像...

[Kaniko 构建输出...]

╔════════════════════════════════════════╗
║         推送完成统计                    ║
╚════════════════════════════════════════╝
>>> 推送耗时: 5 分 23 秒
>>> 平均速度: 0 MB/s (763 KB/s)

✓ 镜像已推送到 Harbor: 192.168.1.100:30002/library/demo-springboot:42
✓ 镜像已推送到阿里云: crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/demo-springboot:42
```

### 3. 构建成功输出

```
╔════════════════════════════════════════╗
║         ✓ 构建成功                      ║
╚════════════════════════════════════════╝
项目: demo-springboot
版本: 1.0.0
分支: master
耗时: 8 min 15 sec

Docker 镜像已构建并推送:

Harbor 本地仓库:
- 192.168.1.100:30002/library/demo-springboot:42
- 192.168.1.100:30002/library/demo-springboot:latest

在 K8s 中使用 Harbor 镜像:
kubectl set image deployment/demo-springboot \
  demo-springboot=192.168.1.100:30002/library/demo-springboot:42 \
  -n default

阿里云镜像仓库:
- crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/demo-springboot:42
- crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/demo-springboot:latest

在 K8s 中使用阿里云镜像:
kubectl set image deployment/demo-springboot \
  demo-springboot=crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/demo-springboot:42 \
  -n default
```

## 验证镜像推送

### 验证 Harbor 镜像

```bash
# 方法 1：使用 Harbor Web UI
# 访问 http://192.168.1.100:30002
# 进入 library 项目，查看 demo-springboot 仓库

# 方法 2：使用 Docker CLI
docker login 192.168.1.100:30002
docker pull 192.168.1.100:30002/library/demo-springboot:42

# 方法 3：使用 curl
curl -u admin:Harbor12345 \
  http://192.168.1.100:30002/api/v2.0/projects/library/repositories/demo-springboot/artifacts
```

### 验证阿里云镜像

```bash
# 方法 1：使用阿里云控制台
# 访问阿里云容器镜像服务控制台

# 方法 2：使用 Docker CLI
docker login crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com
docker pull crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/demo-springboot:42
```

## 故障排查

### 1. Harbor 推送失败

**错误**：`unauthorized: authentication required`

**解决**：
```bash
# 检查 Secret 是否存在
kubectl get secret harbor-registry-secret -n default

# 检查 Secret 内容
kubectl get secret harbor-registry-secret -n default -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d

# 重新创建 Secret
kubectl delete secret harbor-registry-secret -n default
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=192.168.1.100:30002 \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n default
```

### 2. 阿里云推送失败

**错误**：`denied: requested access to the resource is denied`

**解决**：
- 检查阿里云镜像仓库命名空间是否存在
- 检查阿里云 Secret 是否正确
- 确认使用的是个人版专属域名

### 3. jq 命令未找到

**错误**：`command not found: jq`

**影响**：无法合并多个仓库认证配置

**解决方案 1**：在 Kaniko 镜像中安装 jq（不推荐）

**解决方案 2**：创建合并的 Secret（推荐）
```bash
# 参考 "创建Harbor镜像仓库Secret.md" 中的合并 Secret 方法
```

### 4. 推送超时

**错误**：`镜像推送失败或超时（30分钟）`

**原因**：
- 镜像太大
- 网络不稳定
- 阿里云个人版带宽限制

**解决**：
- 使用 Alpine 基础镜像减小体积
- 仅推送到 Harbor（本地网络快）
- 升级阿里云企业版

## 性能优化建议

### 1. 优先使用 Harbor
- 开发/测试环境：仅推送到 Harbor
- 生产环境：双推送（Harbor + 阿里云）

### 2. 减小镜像体积
- 使用 Alpine 基础镜像
- 多阶段构建
- 清理不必要的文件

### 3. 网络优化
- Harbor 部署在同一网络
- 使用千兆网络
- 配置镜像加速

## 相关文档

- [Harbor-Helm完整部署指南.md](../Harbor-Helm完整部署指南.md)
- [创建Harbor镜像仓库Secret.md](./创建Harbor镜像仓库Secret.md)
- [创建阿里云镜像仓库Secret.md](../创建阿里云镜像仓库Secret.md)
- [Jenkinsfile-k8s](./Jenkinsfile-k8s)

## 版本历史

- **v10.0** (2024)：支持双推送（Harbor + 阿里云）
- **v9.0** (2024)：使用阿里云个人镜像仓库
- **v8.0** (2024)：使用 Kaniko 构建镜像
