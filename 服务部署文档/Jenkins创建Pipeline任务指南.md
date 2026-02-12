# Jenkins 创建 Pipeline 任务指南

## 概述

本文档详细介绍如何在 Jenkins 中创建一个 Pipeline 任务，使用 Jenkinsfile 脚本来构建 nms4cloud 项目。

---

## 前置条件检查

在创建 Pipeline 任务之前，请确保以下配置已完成：

### 1. JDK 工具配置

访问：`Manage Jenkins` → `Global Tool Configuration`

#### 方式一：使用镜像预装的 JDK（推荐）

如果你使用的是 `jenkins/jenkins:lts-jdk21` 镜像，JDK 21 已经预装在镜像中，**无需额外配置**。

Jenkinsfile 会自动使用镜像中的 JDK：
```groovy
// JDK 21 已经是容器默认的 Java
PATH = "${MAVEN_HOME}/bin:${env.PATH}"
```

验证 JDK 是否可用：
- 运行任务后，在"环境检查"阶段会显示 Java 版本
- 或者在 Jenkins 容器中执行：`java -version`

#### 方式二：在 Jenkins 中配置 JDK 工具

如果需要使用不同版本的 JDK，或者需要在 Jenkinsfile 中明确引用 JDK 工具：

**配置 JDK：**
1. 在 `Global Tool Configuration` 页面找到 **JDK** 部分
2. 点击 **Add JDK**
3. 配置 JDK：
   - Name: `JDK21`（可自定义，用于在 Jenkinsfile 中引用）
   - 勾选 `Install automatically`
   - 选择 `Install from adoptium.net`
   - 版本：选择 `jdk-21.x.x+x`（最新的 JDK 21 版本）
4. 点击 **Save**

**在 Jenkinsfile 中使用：**
```groovy
environment {
    // 使用配置的 JDK 工具
    JAVA_HOME = tool name: 'JDK21', type: 'jdk'
    PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"
}
```

#### JDK 版本说明

| JDK 版本 | 适用场景 | 镜像 |
|---------|---------|------|
| JDK 21 | 最新的 LTS 版本（推荐） | `jenkins/jenkins:lts-jdk21` |
| JDK 17 | 上一个 LTS 版本 | `jenkins/jenkins:lts-jdk17` |
| JDK 11 | 旧项目 | `jenkins/jenkins:lts-jdk11` |

⚠️ **重要**：确保 Jenkins 镜像的 JDK 版本与项目要求的 JDK 版本一致。

### 2. Maven 工具配置

访问：`Manage Jenkins` → `Global Tool Configuration`

**配置 Maven：**
- Name: `Maven`（必须与 Jenkinsfile 中的 `tool 'Maven'` 名称一致）
- 勾选 `Install automatically`
- 选择 `Install from Apache`
- 版本：`3.9.6` 或更高版本

### 2. 阿里云效凭据配置

访问：`Manage Jenkins` → `Manage Credentials` → `(global)` → `Add Credentials`

**配置凭据：**
```
Kind: Username with password
Scope: Global
Username: 你的阿里云账号
Password: 阿里云效个人访问令牌
ID: aliyun-codeup-token（必须与 Jenkinsfile 中的 GIT_CREDENTIAL_ID 一致）
Description: 阿里云效访问令牌
```

⚠️ **重要**：凭据 ID 必须与 Jenkinsfile 第 18 行的 `GIT_CREDENTIAL_ID` 值一致。

### 3. Git 仓库地址确认

确认你的 Git 仓库地址，需要在 Jenkinsfile 中配置：
- 第 19 行：`GIT_REPO_URL`

---

## 一、创建 Pipeline 任务

### 1. 进入 Jenkins 首页

访问：`http://<节点IP>:30080`

### 2. 创建新任务

1. 点击左侧菜单 **New Item**（新建任务）
2. 输入任务名称：`nms4cloud-build`（可自定义）
3. 选择任务类型：**Pipeline**
4. 点击 **OK**

![创建Pipeline任务](https://docs.jenkins.io/doc/book/resources/pipeline/new-item-creation.png)

---

## 二、配置 Pipeline 任务

### 1. General（常规配置）

#### 描述信息
```
Description: nms4cloud 项目构建流水线
```

#### 构建选项（可选）
- ☑️ **Discard old builds**（丢弃旧的构建）
  - Strategy: Log Rotation
  - Max # of builds to keep: `10`

#### 参数化构建
⚠️ **不需要手动添加参数**，Jenkinsfile 中已经定义了参数（第 24-50 行）：
- `BUILD_MODULE`：选择构建模块
- `GIT_BRANCH`：指定 Git 分支
- `SKIP_TESTS`：是否跳过单元测试
- `CLEAN_BUILD`：是否清理构建

这些参数会在第一次运行后自动出现。

### 2. Build Triggers（构建触发器）

Jenkinsfile 中已经配置了触发器（第 64-70 行）：
- 定时构建：每天凌晨 1 点
- Git 轮询：每 5 分钟检查一次

如果不需要自动触发，可以在 Jenkinsfile 中注释掉 `triggers` 部分。

### 3. Pipeline（流水线配置）

这是最重要的配置部分！

#### 方式一：Pipeline script from SCM（推荐）

如果 Jenkinsfile 已经提交到 Git 仓库：

1. **Definition**: 选择 `Pipeline script from SCM`
2. **SCM**: 选择 `Git`
3. **Repositories**:
   - Repository URL: `https://codeup.aliyun.com/613895a803e1c17d57a7630f/nms4cloud-pos-java/nms4cloud.git`
   - Credentials: 选择 `aliyun-codeup-token`
4. **Branches to build**:
   - Branch Specifier: `*/master`（或你的默认分支）
5. **Script Path**: `Jenkinsfile`（Jenkinsfile 在仓库中的路径）
   - 如果 Jenkinsfile 在 `安装jenkins` 目录下，填写：`安装jenkins/Jenkinsfile-nms4cloud`

**优点**：
- Jenkinsfile 版本化管理
- 团队协作方便
- 修改 Jenkinsfile 不需要在 Jenkins UI 中操作

#### 方式二：Pipeline script（直接粘贴）

如果 Jenkinsfile 还没有提交到仓库：

1. **Definition**: 选择 `Pipeline script`
2. **Script**: 将整个 Jenkinsfile 内容粘贴到文本框中

**优点**：
- 快速测试
- 不需要提交到 Git

**缺点**：
- 不便于版本管理
- 修改需要在 Jenkins UI 中操作

### 4. 保存配置

点击页面底部的 **Save** 按钮。

---

## 三、修改 Jenkinsfile 配置

在运行任务之前，需要修改 Jenkinsfile 中的配置：

### 1. 必须修改的配置

打开 `Jenkinsfile-nms4cloud` 文件，修改以下内容：

#### Git 仓库地址（第 19 行）
```groovy
GIT_REPO_URL = 'https://codeup.aliyun.com/你的组织/你的仓库/nms4cloud.git'
```
替换为你的实际仓库地址。

#### Git 凭据 ID（第 18 行）
```groovy
GIT_CREDENTIAL_ID = 'aliyun-codeup-token'
```
确保与你在 Jenkins 中创建的凭据 ID 一致。

#### 默认分支（第 20 行）
```groovy
GIT_BRANCH = "${params.GIT_BRANCH ?: 'master'}"
```
如果你的默认分支是 `main`，修改为：
```groovy
GIT_BRANCH = "${params.GIT_BRANCH ?: 'main'}"
```

### 2. 可选修改的配置

#### 项目名称（第 14 行）
```groovy
PROJECT_NAME = 'nms4cloud'
```

#### 构建模块（第 28-32 行）
根据你的项目实际模块修改：
```groovy
choices: [
    'all',
    'nms4cloud-starter',
    'nms4cloud-app'
]
```

#### 构建超时时间（第 59 行）
```groovy
timeout(time: 30, unit: 'MINUTES')
```
根据项目大小调整。

#### 定时构建（第 67 行）
```groovy
cron('0 1 * * *')  // 每天凌晨1点
```
修改为你需要的时间，或注释掉不使用。

---

## 四、运行 Pipeline 任务

### 1. 第一次运行（初始化参数）

1. 进入任务页面：点击 `nms4cloud-build`
2. 点击左侧菜单 **Build Now**（立即构建）
3. 等待构建完成

⚠️ **第一次运行**：
- 会自动下载 Maven（如果配置了自动安装）
- 会初始化参数（之后会显示"Build with Parameters"）
- 可能需要 2-5 分钟

### 2. 后续运行（使用参数）

第一次运行后，左侧菜单会出现 **Build with Parameters**（参数化构建）：

1. 点击 **Build with Parameters**
2. 配置参数：
   - **BUILD_MODULE**: 选择要构建的模块
     - `all`: 构建所有模块
     - `nms4cloud-starter`: 只构建 starter 模块
     - `nms4cloud-app`: 只构建 app 模块
   - **GIT_BRANCH**: 输入分支名（默认 `master`）
   - **SKIP_TESTS**: 是否跳过单元测试（默认 `true`）
   - **CLEAN_BUILD**: 是否清理构建（默认 `true`）
3. 点击 **Build** 开始构建

### 3. 查看构建过程

#### 查看控制台输出
1. 点击构建编号（如 `#1`）
2. 点击左侧菜单 **Console Output**（控制台输出）
3. 实时查看构建日志

#### 查看 Stage View（阶段视图）
在任务页面可以看到流水线的各个阶段：
- 环境检查
- 代码检出
- Maven构建
- 单元测试
- 代码质量检查
- 归档构建产物

每个阶段会显示：
- ✅ 成功（绿色）
- ❌ 失败（红色）
- ⏸️ 跳过（灰色）
- ⏳ 进行中（蓝色动画）

---

## 五、常见问题排查

### 问题 1：Maven 工具未找到

**错误信息**：
```
ERROR: No tool named Maven found
```

**解决方法**：
1. 进入 `Manage Jenkins` → `Global Tool Configuration`
2. 添加 Maven 工具，Name 必须是 `Maven`
3. 保存后重新运行

### 问题 2：Git 凭据认证失败

**错误信息**：
```
ERROR: Error cloning remote repo 'origin'
Authentication failed
```

**解决方法**：
1. 检查凭据 ID 是否正确（`aliyun-codeup-token`）
2. 检查凭据中的用户名和令牌是否正确
3. 检查仓库 URL 是否正确
4. 参考 [Jenkins凭据设置.md](./Jenkins凭据设置.md)

### 问题 3：Maven 构建失败

**错误信息**：
```
[ERROR] Failed to execute goal ...
```

**解决方法**：
1. 查看完整的错误日志
2. 检查 pom.xml 配置
3. 检查依赖是否能正常下载
4. 尝试在本地运行 `mvn clean install` 验证

### 问题 4：工作空间权限问题

**错误信息**：
```
Permission denied
```

**解决方法**：
检查 Jenkins Pod 的存储卷权限：
```bash
kubectl exec -it <jenkins-pod> -n jenkins -- ls -la /var/jenkins_home
```

### 问题 5：构建超时

**错误信息**：
```
Build timed out (after 30 minutes)
```

**解决方法**：
修改 Jenkinsfile 第 59 行，增加超时时间：
```groovy
timeout(time: 60, unit: 'MINUTES')
```

---

## 六、高级配置

### 1. 配置构建通知

在 Jenkinsfile 的 `post` 部分添加通知：

#### 邮件通知
```groovy
post {
    success {
        emailext(
            subject: "构建成功: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "构建成功！查看详情: ${env.BUILD_URL}",
            to: "your-email@example.com"
        )
    }
    failure {
        emailext(
            subject: "构建失败: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
            body: "构建失败！查看详情: ${env.BUILD_URL}",
            to: "your-email@example.com"
        )
    }
}
```

#### 钉钉通知（需要安装插件）
```groovy
post {
    success {
        dingtalk(
            robot: 'your-robot-id',
            type: 'MARKDOWN',
            title: '构建成功',
            text: ["### 构建成功\n项目: ${env.JOB_NAME}\n构建号: ${env.BUILD_NUMBER}"]
        )
    }
}
```

### 2. 配置多分支流水线

如果需要为每个分支自动创建流水线：

1. 创建任务时选择 **Multibranch Pipeline**
2. 配置 Branch Sources：
   - Add source: `Git`
   - Project Repository: 你的仓库地址
   - Credentials: `aliyun-codeup-token`
3. Build Configuration:
   - Mode: `by Jenkinsfile`
   - Script Path: `安装jenkins/Jenkinsfile-nms4cloud`

### 3. 配置 Webhook 自动触发

在阿里云效中配置 Webhook，代码提交后自动触发构建：

1. 登录阿里云效
2. 进入仓库设置 → Webhook
3. 添加 Webhook：
   - URL: `http://<jenkins-url>/generic-webhook-trigger/invoke?token=<your-token>`
   - 触发事件：Push events
4. 在 Jenkinsfile 中添加：
```groovy
triggers {
    GenericTrigger(
        genericVariables: [
            [key: 'ref', value: '$.ref']
        ],
        token: 'your-token',
        causeString: 'Triggered by Aliyun Codeup',
        printContributedVariables: true,
        printPostContent: true
    )
}
```

---

## 七、最佳实践

### 1. Jenkinsfile 版本管理

✅ **推荐**：
- 将 Jenkinsfile 提交到 Git 仓库
- 使用 "Pipeline script from SCM" 方式
- 团队成员可以通过 PR 修改流水线

❌ **不推荐**：
- 直接在 Jenkins UI 中编辑
- 难以追踪修改历史

### 2. 参数化构建

✅ **推荐**：
- 使用参数控制构建行为
- 提供合理的默认值
- 添加清晰的参数描述

### 3. 构建产物管理

✅ **推荐**：
- 使用 `archiveArtifacts` 归档重要文件
- 设置合理的构建保留策略
- 定期清理旧的构建产物

### 4. 错误处理

✅ **推荐**：
- 使用 `try-catch` 捕获异常
- 在 `post` 部分处理构建结果
- 添加详细的日志输出

### 5. 性能优化

✅ **推荐**：
- 使用 Maven 并行构建（`-T 2C`）
- 启用浅克隆（`shallow: true`）
- 合理设置构建超时时间
- 参考 [Jenkins性能优化指南.md](./Jenkins性能优化指南.md)

---

## 八、快速开始检查清单

在创建和运行 Pipeline 任务之前，请确认以下事项：

- [ ] Maven 工具已配置（Name: `Maven`）
- [ ] 阿里云效凭据已添加（ID: `aliyun-codeup-token`）
- [ ] Jenkinsfile 中的 `GIT_REPO_URL` 已修改为实际仓库地址
- [ ] Jenkinsfile 中的 `GIT_CREDENTIAL_ID` 与凭据 ID 一致
- [ ] Jenkinsfile 中的默认分支与实际分支一致
- [ ] 已创建 Pipeline 任务
- [ ] Pipeline 配置已保存
- [ ] 已执行第一次构建（初始化参数）
- [ ] 构建成功，产物已归档

---

## 相关文档

- [Jenkins凭据设置.md](./Jenkins凭据设置.md) - 如何配置阿里云效凭据
- [Jenkins流水线使用指南.md](./Jenkins流水线使用指南.md) - 流水线基础知识
- [Jenkins配置JDK和Maven.md](./Jenkins配置JDK和Maven.md) - 工具配置详解
- [Jenkins性能优化指南.md](./Jenkins性能优化指南.md) - 性能优化建议
