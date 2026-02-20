# Nexus Maven 仓库配置指南

## 概述

本文档介绍如何配置 Jenkins 使用 Nexus 作为 Maven 依赖仓库和构建产物存储仓库，替代原有的 PVC 本地缓存方案。

---

## 一、Nexus 仓库说明

### 1. Nexus 仓库类型

| 仓库名称 | 类型 | 用途 |
|---------|------|------|
| `maven-central` | proxy | 代理 Maven Central，加速依赖下载 |
| `maven-releases` | hosted | 存储正式版本的 JAR（如 1.0.0） |
| `maven-snapshots` | hosted | 存储快照版本的 JAR（如 1.0.0-SNAPSHOT） |
| `maven-public` | group | 聚合以上仓库，统一访问入口 |

### 2. 访问地址

```
集群内访问：http://nexus.nexus:8081
集群外访问：http://<NodeIP>:30003
```

**说明**：
- 集群内 Pod 之间访问使用 Service 名称：`nexus.nexus:8081`
- 集群外浏览器访问使用 NodePort：`<NodeIP>:30003`

---

## 二、在 Jenkins 中添加 Nexus 凭据

### 1. 获取 Nexus 访问凭证

#### 默认管理员账号

- **用户名**：`admin`
- **密码**：首次安装时在 `/nexus-data/admin.password` 文件中

#### 登录 Nexus 验证

访问 Nexus Web UI：
```
集群内：http://nexus.nexus:8081
集群外：http://<NodeIP>:30003
```

使用 admin 账号登录，首次登录会要求修改密码。

### 2. 在 Jenkins 中添加凭据

#### 步骤

1. 访问 Jenkins：`http://<NodeIP>:30080`
2. 点击左侧菜单 **Manage Jenkins**
3. 点击 **Manage Credentials**
4. 点击 **System** → **Global credentials (unrestricted)**
5. 点击右上角 **Add Credentials**

#### 配置凭据

| 字段 | 值 | 说明 |
|------|-----|------|
| **Kind** | `Username with password` | 用户名密码类型 |
| **Scope** | `Global` | 全局可用 |
| **Username** | `admin` | Nexus 用户名 |
| **Password** | `你的Nexus密码` | Nexus 密码 |
| **ID** | `nexus-credentials` | 凭据 ID（与 Jenkinsfile 中一致） |
| **Description** | `Nexus Maven Repository` | 描述信息 |

6. 点击 **Create** 保存

### 3. 验证凭据

在 Jenkins 凭据列表中应该能看到：

```
ID: nexus-credentials
Description: Nexus Maven Repository
```

---

## 三、Jenkinsfile 配置说明

### 1. 环境变量配置

```groovy
environment {
    // Nexus 配置
    NEXUS_URL = 'http://nexus.nexus:8081'
    NEXUS_REPO_GROUP = 'maven-public'        // 用于拉取依赖
    NEXUS_REPO_RELEASES = 'maven-releases'   // 用于推送正式版
    NEXUS_REPO_SNAPSHOTS = 'maven-snapshots' // 用于推送快照版
    NEXUS_CRED_ID = 'nexus-credentials'      // Jenkins 凭据 ID

    MAVEN_SETTINGS = '/tmp/maven-settings.xml'
}
```

### 2. Maven settings.xml 动态生成

Jenkinsfile 会在构建时自动生成 `settings.xml`：

```xml
<settings>
  <mirrors>
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://nexus.nexus:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>
  <servers>
    <server>
      <id>nexus-releases</id>
      <username>admin</username>
      <password>你的密码</password>
    </server>
    <server>
      <id>nexus-snapshots</id>
      <username>admin</username>
      <password>你的密码</password>
    </server>
  </servers>
</settings>
```

### 3. 构建参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `DEPLOY_TO_NEXUS` | `false` | 是否将 JAR 推送到 Nexus（供其他项目依赖） |

---

## 四、使用场景

### 场景 1：只构建 Docker 镜像（默认）

```
参数设置：
- BUILD_DOCKER_IMAGE = true
- DEPLOY_TO_NEXUS = false

流程：
1. 从 Nexus 拉取依赖
2. Maven 编译打包
3. Kaniko 构建镜像
4. 推送到 Harbor
```

### 场景 2：构建 + 推送到 Nexus（供其他项目依赖）

```
参数设置：
- BUILD_DOCKER_IMAGE = true
- DEPLOY_TO_NEXUS = true

流程：
1. 从 Nexus 拉取依赖
2. Maven 编译打包
3. 推送 JAR 到 Nexus（自动判断 releases/snapshots）
4. Kaniko 构建镜像
5. 推送到 Harbor
```

---

## 五、跨项目依赖配置

### 1. Project-A 推送到 Nexus

在 Project-A 的 Jenkins 构建中：
- 勾选 `DEPLOY_TO_NEXUS = true`
- 构建完成后，JAR 会推送到 Nexus

### 2. Project-B 引用 Project-A

在 Project-B 的 `pom.xml` 中添加依赖：

```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>project-a</artifactId>
    <version>1.0.0</version>
</dependency>
```

Project-B 构建时会自动从 Nexus 拉取 Project-A 的 JAR。

---

## 六、验证配置

### 1. 验证依赖拉取

运行 Jenkins 构建，查看日志：

```
>>> 下载依赖（通过 Nexus）
Downloading from nexus: http://nexus.nexus:8081/repository/maven-public/...
```

### 2. 验证推送到 Nexus

勾选 `DEPLOY_TO_NEXUS = true` 后，查看日志：

```
>>> 推送到 Nexus 仓库: maven-releases
Uploading to nexus-releases: http://nexus.nexus:8081/repository/maven-releases/...
```

### 3. 在 Nexus Web UI 验证

1. 登录 Nexus Web UI
2. 点击左侧 **Browse**
3. 选择 `maven-releases` 或 `maven-snapshots`
4. 找到你的 `groupId/artifactId/version`
5. 确认 JAR 文件已上传

---

## 七、常见问题

### 1. 401 Unauthorized

**原因**：Nexus 凭据错误

**解决**：
```bash
# 验证 Jenkins 凭据中的用户名密码是否正确
# 在 Nexus Web UI 中测试登录
```

### 2. Connection refused

**原因**：Nexus 服务未启动或地址错误

**解决**：
```bash
# 检查 Nexus Pod 状态
kubectl get pods -n nexus

# 检查 Nexus Service
kubectl get svc -n nexus

# 测试连通性
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl -v http://nexus.nexus:8081
```

### 3. 推送失败：405 Method Not Allowed

**原因**：尝试推送到 proxy 或 group 类型的仓库

**解决**：
- 确保推送到 `maven-releases` 或 `maven-snapshots`（hosted 类型）
- 不要推送到 `maven-public`（group 类型）

### 4. 版本冲突

**原因**：尝试重复推送相同版本到 releases 仓库

**解决**：
- releases 仓库默认不允许覆盖
- 使用 SNAPSHOT 版本进行开发
- 或在 Nexus 中修改仓库策略允许重新部署

---

## 八、Nexus 仓库策略配置

### 1. 允许重新部署（开发环境）

在 Nexus Web UI 中：
1. 点击左侧 **Repository** → **Repositories**
2. 选择 `maven-releases`
3. 点击 **Configuration**
4. 找到 **Deployment policy**
5. 改为 `Allow redeploy`
6. 点击 **Save**

⚠️ **生产环境不建议开启**，会导致版本混乱。

### 2. 清理旧版本

在 Nexus Web UI 中：
1. 点击左侧 **Repository** → **Repositories**
2. 选择 `maven-snapshots`
3. 点击 **Configuration**
4. 找到 **Cleanup Policies**
5. 配置保留策略（如：保留最近 30 天的 SNAPSHOT）

---

## 九、安全建议

1. **不要使用 admin 账号**：创建专用的部署账号
2. **最小权限原则**：只授予必要的推送权限
3. **定期更换密码**
4. **启用 HTTPS**：生产环境使用 TLS 加密
5. **审计日志**：定期检查 Nexus 访问日志

---

## 十、快速命令（复制粘贴）

### 创建 Jenkins 凭据（手动操作）

```
1. Jenkins → Manage Jenkins → Manage Credentials
2. Add Credentials:
   - Kind: Username with password
   - Username: admin
   - Password: 你的Nexus密码
   - ID: nexus-credentials
   - Description: Nexus Maven Repository
3. Create
```

### 验证 Nexus 连通性

```bash
# 检查 Nexus Pod
kubectl get pods -n nexus

# 检查 Nexus Service（应该看到 8081:30003 和 5000:30005）
kubectl get svc -n nexus

# 从集群外测试访问（替换为实际 NodeIP）
curl -u admin:你的密码 http://<NodeIP>:30003/service/rest/v1/status

# 从集群内测试访问
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl -u admin:你的密码 http://nexus.nexus:8081/service/rest/v1/status
```

### 查看 Nexus 仓库列表

```bash
# 从集群外访问（替换为实际 NodeIP）
curl -u admin:你的密码 \
  http://<NodeIP>:30003/service/rest/v1/repositories

# 从集群内访问
curl -u admin:你的密码 \
  http://nexus.nexus:8081/service/rest/v1/repositories
```

---

## 十一、与 PVC 方案对比

| 对比项 | PVC 方案 | Nexus 方案 |
|--------|---------|-----------|
| 跨 Pipeline 共享 | ✓ 同一 Jenkins 实例 | ✓ 所有 Jenkins 实例 |
| 跨团队共享 | ✗ 无法跨实例 | ✓ 支持 |
| 版本管理 | ✗ 只有最新版 | ✓ 多版本管理 |
| 外部访问 | ✗ 无法访问 | ✓ 可通过 HTTP 访问 |
| 依赖加速 | ✗ 直连外网 | ✓ 缓存加速 |
| 存储占用 | 每个项目独立缓存 | 全局去重缓存 |
| 配置复杂度 | 简单 | 中等 |

---

## 十二、相关文档

- [Jenkins凭据设置.md](../../2、安装jenkins/3、设置凭据/Jenkins凭据设置.md)
- [创建Harbor镜像仓库Secret.md](./创建Harbor镜像仓库Secret.md)
- [Jenkinsfile-k8s](./Jenkinsfile-k8s)
