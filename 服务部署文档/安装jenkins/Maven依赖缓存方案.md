# Maven 依赖缓存方案详解

## 方案概述

通过配置持久化的 Maven 本地仓库目录，避免每次构建都重新下载依赖。

## 核心配置

```groovy
// 在 Jenkinsfile 的 environment 中添加
MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
MAVEN_CACHE_OPTS = "-Dmaven.repo.local=${MAVEN_LOCAL_REPO}"
```

所有 Maven 命令都添加 `${MAVEN_CACHE_OPTS}` 参数：
```bash
mvn install ${MAVEN_CACHE_OPTS}
```

## 工作原理

### 1. 首次构建（缓存为空）
```
Maven 构建流程：
1. 检查本地仓库 /var/jenkins_home/maven-repository
2. 发现依赖不存在
3. 从远程仓库下载（Maven Central、阿里云镜像等）
4. 保存到本地仓库
5. 使用依赖完成构建
```

**首次构建时间：** 正常（需要下载所有依赖）

### 2. 后续构建（缓存已有）
```
Maven 构建流程：
1. 检查本地仓库 /var/jenkins_home/maven-repository
2. 发现依赖已存在
3. 直接使用本地依赖（跳过下载）
4. 完成构建
```

**后续构建时间：** 大幅缩短（节省 50%-80% 的时间）

### 3. 新增依赖
```
Maven 构建流程：
1. 检查本地仓库
2. 已有依赖：直接使用
3. 新增依赖：从远程下载并缓存
4. 完成构建
```

**增量下载：** 只下载新增的依赖

## 优势分析

### ✅ 1. 构建速度大幅提升
- **首次构建后**，后续构建速度提升 50%-80%
- **示例**：原本 10 分钟的构建可能缩短到 2-3 分钟
- **原因**：跳过网络下载，直接使用本地缓存

### ✅ 2. 节省网络带宽
- 避免重复下载相同的依赖包
- 对于大型项目（依赖几百个 jar 包），节省效果明显
- **示例**：Kafka、Spring Boot 等大型依赖只下载一次

### ✅ 3. 提高构建稳定性
- 减少对外部网络的依赖
- 避免因网络波动导致构建失败
- 即使 Maven Central 暂时不可用，已缓存的依赖仍可使用

### ✅ 4. 支持离线构建
- 缓存完整后，可以在网络受限环境下构建
- 适合内网环境或网络不稳定的场景

### ✅ 5. 多项目共享缓存
- 如果多个项目使用相同的依赖，只需下载一次
- **示例**：项目 A 和项目 B 都用 Spring Boot 2.7.0，只下载一次

## 弊端分析

### ⚠️ 1. 占用磁盘空间
- **空间需求**：通常 2-10 GB（取决于项目规模）
- **示例**：
  - 小型项目：500 MB - 2 GB
  - 中型项目：2 GB - 5 GB
  - 大型项目：5 GB - 10 GB+
- **解决方案**：定期清理旧版本依赖

### ⚠️ 2. 缓存损坏风险
- **场景**：构建中断、磁盘满、权限问题
- **表现**：依赖下载不完整，导致构建失败
- **解决方案**：
  ```bash
  # 清理损坏的缓存
  rm -rf /var/jenkins_home/maven-repository
  ```

### ⚠️ 3. 版本更新延迟
- **SNAPSHOT 版本**：可能使用旧的缓存版本
- **示例**：
  - 依赖 `nms4cloud-wms:0.0.1-SNAPSHOT`
  - WMS 更新后，Jenkins 可能仍使用旧缓存
- **解决方案**：
  ```bash
  # 强制更新 SNAPSHOT
  mvn install -U ${MAVEN_CACHE_OPTS}
  ```
  或在 Jenkinsfile 中添加参数：
  ```groovy
  booleanParam(
      name: 'FORCE_UPDATE',
      defaultValue: false,
      description: '强制更新 SNAPSHOT 依赖'
  )
  ```

### ⚠️ 4. 多 Jenkins 节点同步问题
- **场景**：多个 Jenkins 节点（agent）
- **问题**：每个节点有独立的缓存，无法共享
- **解决方案**：
  - 使用共享存储（NFS、Ceph）
  - 或使用 Maven 仓库管理器（Nexus、Artifactory）

### ⚠️ 5. 首次构建仍然慢
- 缓存为空时，首次构建速度不变
- 需要等待所有依赖下载完成

## 最佳实践

### 1. 定期清理缓存
```bash
# 清理 30 天未使用的依赖
find /var/jenkins_home/maven-repository -type f -atime +30 -delete
```

### 2. 监控磁盘空间
```groovy
stage('检查磁盘空间') {
    steps {
        sh '''
            df -h /var/jenkins_home
            du -sh /var/jenkins_home/maven-repository
        '''
    }
}
```

### 3. 强制更新选项
```groovy
def updateFlag = params.FORCE_UPDATE ? '-U' : ''
mvn install ${updateFlag} ${MAVEN_CACHE_OPTS}
```

### 4. 使用 Maven 仓库管理器（推荐）
对于企业级应用，建议使用 Nexus 或 Artifactory：
- 统一管理所有依赖
- 支持多节点共享
- 提供依赖分析和安全扫描
- 支持私有依赖托管

## 配置示例对比

### 方案 A：无缓存（当前问题）
```groovy
mvn install -Dmaven.test.skip=true
```
- 每次构建都下载依赖
- 构建时间：10 分钟
- 网络流量：每次 500 MB

### 方案 B：本地缓存（本次优化）
```groovy
mvn install -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
```
- 首次：10 分钟（下载 + 缓存）
- 后续：2-3 分钟（使用缓存）
- 网络流量：首次 500 MB，后续几乎为 0

### 方案 C：Nexus 仓库管理器（企业级）
```groovy
// settings.xml 配置 Nexus 镜像
mvn install -Dmaven.test.skip=true
```
- 首次：8 分钟（内网下载更快）
- 后续：2-3 分钟
- 支持多节点共享
- 提供 Web 管理界面

## 总结

| 特性 | 无缓存 | 本地缓存 | Nexus |
|------|--------|----------|-------|
| 构建速度 | 慢 | 快 | 快 |
| 磁盘占用 | 无 | 中等 | 集中管理 |
| 配置复杂度 | 简单 | 简单 | 中等 |
| 多节点支持 | N/A | 不支持 | 支持 |
| 企业级功能 | 无 | 无 | 丰富 |
| 推荐场景 | 测试 | 单节点 CI | 生产环境 |

**建议**：
- 当前阶段：使用本地缓存方案（性价比最高）
- 未来规划：考虑部署 Nexus（企业级需求）
