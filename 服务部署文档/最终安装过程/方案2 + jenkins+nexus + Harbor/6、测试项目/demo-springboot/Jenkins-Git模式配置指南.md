# Jenkins Git 模式配置指南

## 一、前置准备

### 1. 将项目上传到 Git 仓库

**选项 1：使用 GitHub**
```bash
cd demo-springboot

# 初始化 Git 仓库
git init

# 添加文件
git add .

# 提交
git commit -m "Initial commit"

# 添加远程仓库
git remote add origin https://github.com/your-username/demo-springboot.git

# 推送到远程
git push -u origin master
```

**选项 2：使用 Gitee（国内推荐）**
```bash
git remote add origin https://gitee.com/your-username/demo-springboot.git
git push -u origin master
```

**选项 3：使用阿里云 CodeUp**
```bash
git remote add origin https://codeup.aliyun.com/your-org/demo-springboot.git
git push -u origin master
```

### 2. 在 Jenkins 中配置 Git 凭据

#### 方式 1：使用用户名密码

1. 进入 Jenkins → 系统管理 → 凭据
2. 点击 "全局" → "添加凭据"
3. 类型：选择 "Username with password"
4. 范围：全局
5. 用户名：你的 Git 用户名
6. 密码：你的 Git 密码或 Personal Access Token
7. ID：`git-credentials`（与 Jenkinsfile 中的 GIT_CREDENTIAL_ID 一致）
8. 描述：Git 凭据
9. 点击 "确定"

#### 方式 2：使用 SSH 密钥

1. 生成 SSH 密钥（如果还没有）：
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

2. 将公钥添加到 Git 仓库：
   - GitHub: Settings → SSH and GPG keys → New SSH key
   - Gitee: 设置 → SSH 公钥 → 添加公钥

3. 在 Jenkins 中添加 SSH 凭据：
   - 类型：选择 "SSH Username with private key"
   - ID：`git-credentials`
   - 用户名：git
   - Private Key：粘贴私钥内容
   - 点击 "确定"

## 二、修改 Jenkinsfile 配置

打开 `Jenkinsfile-git`，修改以下配置：

### 1. Git 仓库地址

```groovy
environment {
    // 修改为你的 Git 仓库地址
    GIT_REPO_URL = 'https://github.com/your-username/demo-springboot.git'
    
    // 或者使用 SSH
    // GIT_REPO_URL = 'git@github.com:your-username/demo-springboot.git'
}
```

### 2. Git 凭据 ID

```groovy
environment {
    // 修改为你在 Jenkins 中配置的凭据 ID
    GIT_CREDENTIAL_ID = 'git-credentials'
}
```

### 3. 默认分支

```groovy
parameters {
    string(
        name: 'GIT_BRANCH',
        defaultValue: 'master',  // 或 'main'
        description: 'Git 分支名称'
    )
}
```

## 三、创建 Jenkins 任务

### 方式 1：Pipeline script from SCM（推荐）

1. 新建任务 → 流水线
2. 任务名称：`demo-springboot-git`
3. 流水线配置：
   - 定义：选择 "Pipeline script from SCM"
   - SCM：选择 "Git"
   - 仓库 URL：输入你的 Git 仓库地址
   - 凭据：选择刚才创建的凭据
   - 分支：`*/master` 或 `*/main`
   - 脚本路径：`Jenkinsfile-git`
4. 保存

### 方式 2：Pipeline script

1. 新建任务 → 流水线
2. 任务名称：`demo-springboot-git`
3. 流水线配置：
   - 定义：选择 "Pipeline script"
   - 脚本：复制 `Jenkinsfile-git` 的完整内容
4. 保存

## 四、执行构建

### 1. 首次构建

1. 点击 "立即构建"
2. 查看 "控制台输出"
3. 观察构建过程：
   ```
   环境检查 → 代码检出 → Maven 构建 → 单元测试 → 归档产物
   ```

### 2. 参数化构建

1. 点击 "Build with Parameters"
2. 配置参数：
   - `GIT_BRANCH`：分支名称（如 master, develop, feature/xxx）
   - `SKIP_TESTS`：跳过测试（默认：true）
   - `CLEAN_BUILD`：清理构建（默认：true）
3. 点击 "开始构建"

### 3. 查看构建结果

构建成功后会显示：
```
╔════════════════════════════════════════╗
║         ✓ 构建成功                      ║
╚════════════════════════════════════════╝
项目: demo-springboot
版本: 1.0.0
分支: master
耗时: 1 min 23 sec
```

## 五、配置自动触发构建

### 1. 轮询 SCM（定期检查代码变更）

在任务配置中：
1. 构建触发器 → 勾选 "Poll SCM"
2. 日程表：`H/5 * * * *`（每 5 分钟检查一次）
3. 保存

### 2. Webhook（推送时自动构建）

#### GitHub Webhook

1. 在 Jenkins 中：
   - 构建触发器 → 勾选 "GitHub hook trigger for GITScm polling"

2. 在 GitHub 仓库中：
   - Settings → Webhooks → Add webhook
   - Payload URL：`http://your-jenkins-url/github-webhook/`
   - Content type：`application/json`
   - 触发事件：选择 "Just the push event"
   - 点击 "Add webhook"

#### Gitee Webhook

1. 在 Jenkins 中：
   - 安装 "Gitee Plugin"
   - 构建触发器 → 勾选 "Gitee webhook 触发构建"

2. 在 Gitee 仓库中：
   - 管理 → WebHooks → 添加 WebHook
   - URL：`http://your-jenkins-url/gitee-project/demo-springboot-git`
   - 密码：留空或设置密码
   - 勾选 "Push"
   - 点击 "添加"

## 六、多分支构建

### 1. 创建多分支流水线

1. 新建任务 → 多分支流水线
2. 任务名称：`demo-springboot-multibranch`
3. 分支源：
   - 添加源 → Git
   - 项目仓库：输入 Git 仓库地址
   - 凭据：选择 Git 凭据
4. 构建配置：
   - 模式：按名称（Jenkinsfile-git）
   - 脚本路径：`Jenkinsfile-git`
5. 保存

### 2. 自动发现分支

Jenkins 会自动扫描所有分支，为每个包含 Jenkinsfile 的分支创建构建任务。

## 七、常见问题

### 1. Git 克隆失败

**错误信息：**
```
Failed to connect to repository
```

**解决方法：**
- 检查 Git 仓库地址是否正确
- 检查凭据是否配置正确
- 检查网络连接
- 如果使用 HTTPS，尝试使用 SSH

### 2. 凭据认证失败

**错误信息：**
```
Authentication failed
```

**解决方法：**
- 检查用户名密码是否正确
- 如果使用 Personal Access Token，确保有足够权限
- 重新创建凭据

### 3. 分支不存在

**错误信息：**
```
Couldn't find any revision to build
```

**解决方法：**
- 检查分支名称是否正确
- 确保分支已推送到远程仓库
- 使用 `git branch -a` 查看所有分支

### 4. Maven 依赖下载慢

**解决方法：**

配置 Maven 阿里云镜像：

```bash
docker exec -u root jenkins bash -c "
mkdir -p /var/jenkins_home/.m2
cat > /var/jenkins_home/.m2/settings.xml <<'EOF'
<settings>
  <mirrors>
    <mirror>
      <id>aliyun</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
EOF
chown jenkins:jenkins /var/jenkins_home/.m2/settings.xml
"
```

## 八、最佳实践

### 1. 使用 .gitignore

在项目根目录创建 `.gitignore`：
```
target/
*.class
*.jar
*.war
.idea/
*.iml
.DS_Store
```

### 2. 提交 Jenkinsfile 到仓库

将 `Jenkinsfile-git` 重命名为 `Jenkinsfile` 并提交：
```bash
mv Jenkinsfile-git Jenkinsfile
git add Jenkinsfile
git commit -m "Add Jenkinsfile"
git push
```

### 3. 使用分支策略

- `master/main`：生产环境
- `develop`：开发环境
- `feature/*`：功能分支
- `hotfix/*`：紧急修复

### 4. 添加构建状态徽章

在 README.md 中添加：
```markdown
[![Build Status](http://your-jenkins-url/buildStatus/icon?job=demo-springboot-git)](http://your-jenkins-url/job/demo-springboot-git/)
```

## 九、完整示例

### 项目结构
```
demo-springboot/
├── .git/
├── .gitignore
├── Jenkinsfile
├── pom.xml
├── README.md
└── src/
    └── main/
        ├── java/
        └── resources/
```

### 开发流程
```
1. 开发代码
2. 提交到 Git
   git add .
   git commit -m "Add new feature"
   git push

3. Jenkins 自动触发构建（如果配置了 Webhook）
   或手动点击 "立即构建"

4. 查看构建结果
5. 下载构建产物
```
