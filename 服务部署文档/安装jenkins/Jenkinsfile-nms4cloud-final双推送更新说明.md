# Jenkinsfile-nms4cloud-final 双推送功能更新说明

## 更新日期
2024年

## 更新版本
v3.0

## 更新内容

### 1. 支持双推送功能
- 支持同时推送到 Harbor 本地仓库和阿里云镜像仓库
- 通过构建参数控制推送目标
- 至少需要选择一个推送目标

### 2. 新增构建参数
- `PUSH_TO_HARBOR`: 推送镜像到 Harbor 本地仓库（默认: true）
- `PUSH_TO_ALIYUN`: 推送镜像到阿里云镜像仓库（默认: true）

### 3. 环境变量更新
```groovy
// 阿里云镜像仓库配置
ALIYUN_REGISTRY = 'crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com'
ALIYUN_NAMESPACE = 'lgy-images'

// Harbor 本地镜像仓库配置
HARBOR_REGISTRY = 'harbor-core.harbor'
HARBOR_PROJECT = 'library'
```

### 4. Pod 配置更新
- 挂载两个 Secret：`aliyun-registry-secret` 和 `harbor-registry-secret`
- Kaniko 容器挂载两个认证配置目录：
  - `/kaniko/.docker/aliyun` - 阿里云认证
  - `/kaniko/.docker/harbor` - Harbor 认证

### 5. buildModuleImage() 函数更新

#### 5.1 推送目标验证
```groovy
if (!params.PUSH_TO_HARBOR && !params.PUSH_TO_ALIYUN) {
    error("错误: 必须至少选择一个推送目标（Harbor 或阿里云）")
}
```

#### 5.2 镜像名称定义
```groovy
def aliyunImageName = "${ALIYUN_REGISTRY}/${ALIYUN_NAMESPACE}/${moduleName}"
def harborImageName = "${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${moduleName}"
```

#### 5.3 Docker 认证配置合并
- 使用 `jq` 工具合并多个仓库的认证配置
- 如果没有 `jq`，使用简单的文件复制（可能导致配置覆盖）
- 建议安装 `jq` 或创建包含两个仓库认证的单一 Secret

#### 5.4 Kaniko 推送参数构建
```bash
# 动态构建推送目标
DESTINATIONS=""
INSECURE_REGISTRIES=""

if [ "${params.PUSH_TO_HARBOR}" = "true" ]; then
    DESTINATIONS="${DESTINATIONS} --destination=${harborImageName}:${DOCKER_IMAGE_TAG}"
    DESTINATIONS="${DESTINATIONS} --destination=${harborImageName}:latest"
    INSECURE_REGISTRIES="${INSECURE_REGISTRIES} --insecure-registry=${HARBOR_REGISTRY}"
fi

if [ "${params.PUSH_TO_ALIYUN}" = "true" ]; then
    DESTINATIONS="${DESTINATIONS} --destination=${aliyunImageName}:${DOCKER_IMAGE_TAG}"
    DESTINATIONS="${DESTINATIONS} --destination=${aliyunImageName}:latest"
fi
```

#### 5.5 Kaniko 执行参数
- 添加 `--skip-tls-verify`：跳过 TLS 验证（Harbor 使用 HTTP）
- 添加 `--insecure-registry`：配置 Harbor 为不安全仓库
- 动态添加多个 `--destination` 参数

## 与 Jenkinsfile-nms4cloud-pos-java-optimized 的区别

### 相同点
1. 双推送逻辑完全一致
2. 认证配置合并方式相同
3. Kaniko 参数配置相同
4. 环境变量配置相同

### 不同点
1. **项目结构**：
   - `nms4cloud-final`: 多仓库项目（主项目 + BI + WMS）
   - `nms4cloud-pos-java-optimized`: 单仓库多模块项目

2. **构建流程**：
   - `nms4cloud-final`: 复杂的分步构建（解决循环依赖）
   - `nms4cloud-pos-java-optimized`: 简单的模块构建

3. **镜像构建**：
   - `nms4cloud-final`: 批量构建多个模块的镜像
   - `nms4cloud-pos-java-optimized`: 单个或全部模块构建

4. **模块数量**：
   - `nms4cloud-final`: 15+ 个模块
   - `nms4cloud-pos-java-optimized`: 9 个模块

## 使用方法

### 1. 创建 Harbor Secret
```bash
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor-core.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins
```

### 2. 创建阿里云 Secret
参考文档：`创建阿里云镜像仓库Secret.md`
```bash
kubectl apply -f aliyun-registry-secret.yaml -n jenkins
```

### 3. 构建选项
- **仅推送到 Harbor**：
  - PUSH_TO_HARBOR: ✓
  - PUSH_TO_ALIYUN: ✗
  
- **仅推送到阿里云**：
  - PUSH_TO_HARBOR: ✗
  - PUSH_TO_ALIYUN: ✓
  
- **双推送（推荐）**：
  - PUSH_TO_HARBOR: ✓
  - PUSH_TO_ALIYUN: ✓

### 4. 模块选择
- `all`: 构建所有模块的镜像（15+ 个）
- `nms4cloud-app`: 构建所有应用模块
- 单个模块名: 只构建指定模块

## 优势

### Harbor 本地仓库
- ✓ 推送速度快（10 MB/s）
- ✓ 拉取速度快（本地网络）
- ✓ 无带宽限制
- ✓ 适合开发和测试环境
- ✗ 仅限内网访问

### 阿里云镜像仓库
- ✓ 外网可访问
- ✓ 高可用性
- ✓ 适合生产环境
- ✓ 作为备份仓库
- ✗ 推送速度慢（0.5-1 MB/s）
- ✗ 个人版有带宽限制

### 双推送策略
- Harbor 作为主仓库（快速访问）
- 阿里云作为备份仓库（外网访问、高可用）
- 开发环境使用 Harbor
- 生产环境使用阿里云

## 注意事项

1. **Secret 命名空间**：
   - Secret 必须在 `jenkins` 命名空间
   - 与 Jenkins Pod 在同一命名空间

2. **Harbor 配置**：
   - Harbor 使用 HTTP 协议
   - 需要配置 `--insecure-registry` 和 `--skip-tls-verify`

3. **阿里云个人版**：
   - 必须使用专属域名
   - 不能使用通用域名 `registry.cn-hangzhou.aliyuncs.com`

4. **jq 工具**：
   - 建议在 Kaniko 镜像中安装 `jq`
   - 用于合并多个仓库的认证配置
   - 如果没有 `jq`，可能导致配置覆盖

5. **推送时间**：
   - 镜像越大，推送时间越长
   - 双推送会增加总推送时间
   - Harbor 推送很快，主要时间在阿里云推送
   - 15+ 个模块全部推送可能需要较长时间

6. **构建顺序**：
   - 必须按照依赖顺序构建
   - BI 和 WMS 模块有特殊的构建顺序
   - 不要随意修改构建步骤

## 性能优化建议

1. **选择性构建**：
   - 只构建修改过的模块
   - 使用 `BUILD_MODULE` 参数指定单个模块

2. **并行推送**：
   - Harbor 和阿里云推送是串行的
   - 可以考虑只推送到 Harbor，定期同步到阿里云

3. **镜像优化**：
   - 使用分层构建减小镜像大小
   - 使用 Alpine 基础镜像
   - 清理不必要的文件

## 参考文档
- `Jenkinsfile-k8s` - 简单项目的参考实现
- `Jenkinsfile-nms4cloud-pos-java-optimized` - 多模块项目的参考实现
- `创建阿里云镜像仓库Secret.md` - 阿里云 Secret 创建
- `创建Harbor镜像仓库Secret.md` - Harbor Secret 创建
- `阿里云个人版镜像仓库配置说明.md` - 阿里云配置详解
