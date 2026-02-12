# Jenkins 凭据设置指南

## 概述

本文档介绍如何在 Jenkins 中添加阿里云效（Aliyun Codeup）的访问凭据，用于从阿里云效的 Git 仓库拉取代码。

---

## 一、获取阿里云效访问凭据

### 方式一：使用个人访问令牌（推荐）

#### 1. 创建个人访问令牌

1. 登录阿里云效：https://codeup.aliyun.com
2. 点击右上角头像 → **个人设置**
3. 左侧菜单选择 **个人访问令牌**
4. 点击 **新建令牌**
5. 配置令牌：
   - **令牌名称**：填写便于识别的名称（如：`Jenkins构建`）
   - **权限范围**：至少勾选 `repo`（代码仓库读写权限）
   - **过期时间**：根据需要设置（建议 90 天或更长）
6. 点击 **创建**
7. **立即复制生成的令牌字符串**

⚠️ **重要提示**：
- 令牌字符串只显示一次，关闭后无法再查看
- 令牌字符串是一串长的随机字符（如：`a1b2c3d4e5f6...`），不是令牌名称
- 建议立即保存到密码管理器或直接配置到 Jenkins

#### 2. 令牌名称 vs 令牌字符串

| 项目 | 说明 | 示例 | 用途 |
|------|------|------|------|
| **令牌名称** | 你给令牌起的标识名 | `Jenkins构建` | 仅用于管理和识别 |
| **令牌字符串** | 系统生成的随机字符串 | `a1b2c3d4e5f6g7h8...` | 用于认证（填入 Jenkins） |

### 方式二：使用账号密码

- **用户名**：阿里云账号或 RAM 用户名
- **密码**：阿里云账号密码

⚠️ **不推荐使用账号密码**，原因：
- 安全性较低
- 无法限制权限范围
- 泄露后需要修改主账号密码

### 方式三：Jenkins 如何区分令牌和密码？

#### 工作原理

很多人会疑惑：既然令牌和密码都填在同一个 `Password` 字段，Jenkins 如何知道用的是哪种方式？

**答案：Jenkins 本身不需要区分，区分工作是由阿里云效服务器完成的。**

```
┌─────────┐         ┌─────────┐         ┌──────────────┐
│ Jenkins │ ─────>  │   Git   │ ─────>  │ 阿里云效服务器 │
│         │  传递   │         │  发送   │              │
│ 凭据    │  凭据   │ HTTP请求│  认证   │ 自动识别类型  │
└─────────┘         └─────────┘         └──────────────┘
```

#### 详细说明

1. **Jenkins 的角色**：
   - Jenkins 只是将 `Username` 和 `Password` 字段的内容传递给 Git
   - 在执行 `git clone` 或 `git pull` 时，这些凭据会通过 HTTP Basic Auth 发送给远程服务器
   - Jenkins 不关心 Password 字段是密码还是令牌

2. **阿里云效服务器的角色**：
   - 收到认证请求后，检查 `Password` 字段的内容
   - 如果是**个人访问令牌**（通常有特定格式、长度、前缀），按令牌方式验证
   - 如果是**普通密码**，按账号密码方式验证
   - 服务器端自动识别并选择正确的验证方式

3. **类比说明**：
   - 就像你去银行取钱，可以用密码，也可以用指纹
   - 柜员机（服务器）会自动识别你用的是哪种方式
   - 你不需要告诉柜员机"我现在要用指纹"

#### 实际示例

对于 Jenkins 来说，这两个凭据的配置方式完全相同：

```groovy
// 方式一：使用令牌
git(
    url: 'https://codeup.aliyun.com/org/repo.git',
    credentialsId: 'aliyun-token'
    // Username: user@example.com
    // Password: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6  (令牌字符串)
)

// 方式二：使用密码
git(
    url: 'https://codeup.aliyun.com/org/repo.git',
    credentialsId: 'aliyun-password'
    // Username: user@example.com
    // Password: mypassword123  (账号密码)
)
```

两者都使用 `Username with password` 类型的凭据，但阿里云效服务器会根据 Password 字段的内容自动判断使用哪种验证方式。

#### 为什么推荐使用令牌？

虽然两种方式对 Jenkins 来说没区别，但令牌更安全：

| 特性 | 个人访问令牌 | 账号密码 |
|------|-------------|---------|
| 权限控制 | ✅ 可以限制权限范围（如只读） | ❌ 拥有账号的所有权限 |
| 过期时间 | ✅ 可以设置自动过期 | ❌ 永久有效 |
| 撤销方式 | ✅ 单独撤销，不影响账号 | ❌ 需要修改账号密码 |
| 多用途管理 | ✅ 可以为不同用途创建不同令牌 | ❌ 只有一个密码 |
| 泄露风险 | ✅ 影响范围小 | ❌ 整个账号都有风险 |

---

## 二、在 Jenkins 中添加凭据

### 1. 进入凭据管理页面

1. 访问 Jenkins：`http://<节点IP>:30080`
2. 点击左侧菜单 **Manage Jenkins**（系统管理）
3. 点击 **Manage Credentials**（凭据管理）
4. 点击 **(global)** 域
5. 点击左侧 **Add Credentials**（添加凭据）

### 2. 配置凭据信息

#### 使用个人访问令牌（推荐）

```
Kind: Username with password
Scope: Global
Username: 你的阿里云账号邮箱或用户名（必须是真实的）
Password: 粘贴生成的令牌字符串（不是令牌名称！）
ID: aliyun-codeup-token
Description: 阿里云效访问令牌
```

#### 使用账号密码

```
Kind: Username with password
Scope: Global
Username: 你的阿里云账号（真实账号）
Password: 你的阿里云密码（真实密码）
ID: aliyun-codeup-credentials
Description: 阿里云效账号密码
```

### 3. 保存凭据

点击 **Create** 按钮保存。

---

## 三、在 Jenkinsfile 中使用凭据

### 基本用法

```groovy
pipeline {
    agent any

    stages {
        stage('代码检出') {
            steps {
                script {
                    echo "=== 从阿里云效拉取代码 ==="

                    git(
                        url: 'https://codeup.aliyun.com/your-org/your-repo.git',
                        branch: 'main',
                        credentialsId: 'aliyun-codeup-token'  // 使用你创建的凭据ID
                    )
                }
            }
        }

        stage('Maven构建') {
            steps {
                script {
                    echo "=== Maven构建 ==="
                    sh 'mvn clean install -DskipTests'
                }
            }
        }
    }
}
```

### 使用多个分支

```groovy
stage('代码检出') {
    steps {
        script {
            // 根据参数选择分支
            def branch = params.BRANCH_NAME ?: 'main'

            git(
                url: 'https://codeup.aliyun.com/your-org/your-repo.git',
                branch: branch,
                credentialsId: 'aliyun-codeup-token'
            )
        }
    }
}
```

---

## 四、验证凭据是否有效

### 创建测试流水线

```groovy
pipeline {
    agent any

    stages {
        stage('测试阿里云效连接') {
            steps {
                script {
                    echo "=== 测试连接 ==="

                    git(
                        url: 'https://codeup.aliyun.com/your-org/your-repo.git',
                        branch: 'main',
                        credentialsId: 'aliyun-codeup-token'
                    )

                    sh '''
                        echo "代码拉取成功！"
                        ls -la
                        git log -1 --oneline
                    '''
                }
            }
        }
    }
}
```

---

## 五、常见问题

### 问题 1：令牌已经看不见了怎么办？

**解决方案**：重新创建新令牌

1. 登录阿里云效
2. 进入"个人设置" → "个人访问令牌"
3. 删除旧令牌（如果不确定是哪个，可以全部删除）
4. 创建新令牌
5. 立即复制令牌字符串并配置到 Jenkins

**最佳实践**：
- 打开两个浏览器标签页：一个是阿里云效，一个是 Jenkins
- 创建令牌后立即切换到 Jenkins 粘贴
- 或者先保存到密码管理器（如 1Password、Bitwarden）

### 问题 2：认证失败

**可能原因**：
- 令牌字符串复制错误（多了空格或少了字符）
- 用户名填写错误
- 令牌权限不足（未勾选 `repo` 权限）
- 令牌已过期

**解决方法**：
1. 检查用户名是否是真实的阿里云账号
2. 重新创建令牌，确保复制完整
3. 确认令牌权限包含 `repo`
4. 检查令牌是否过期

### 问题 3：仓库 URL 格式错误

**正确格式**：
```
HTTPS: https://codeup.aliyun.com/your-org/your-repo.git
SSH:   git@codeup.aliyun.com:your-org/your-repo.git
```

### 问题 4：需要使用 SSH 方式

如果使用 SSH 方式（`git@codeup.aliyun.com:...`）：

#### 1. 生成 SSH 密钥对

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### 2. 添加公钥到阿里云效

1. 复制公钥内容：`cat ~/.ssh/id_rsa.pub`
2. 登录阿里云效 → 个人设置 → SSH 公钥
3. 添加公钥

#### 3. 在 Jenkins 中添加 SSH 凭据

```
Kind: SSH Username with private key
ID: aliyun-codeup-ssh
Username: git
Private Key: 粘贴私钥内容（~/.ssh/id_rsa）
Passphrase: 如果设置了密码短语，填写这里
```

#### 4. 在 Jenkinsfile 中使用

```groovy
git(
    url: 'git@codeup.aliyun.com:your-org/your-repo.git',
    branch: 'main',
    credentialsId: 'aliyun-codeup-ssh'
)
```

---

## 六、安全建议

### 令牌管理最佳实践

✅ **推荐做法**：
- 为不同用途创建不同的令牌（如：Jenkins 令牌、本地开发令牌）
- 定期轮换令牌（建议每 3-6 个月更换一次）
- 令牌泄露后立即删除并重新创建
- 使用密码管理器保存令牌
- 设置合理的令牌过期时间

❌ **不推荐做法**：
- 将令牌保存在未加密的文本文件中
- 将令牌提交到 Git 仓库
- 多个系统共用一个令牌
- 使用永不过期的令牌
- 将令牌写在代码注释中

### 权限最小化原则

- 只授予必要的权限（如只需要读取代码，就只勾选 `repo:read`）
- 不要使用主账号密码，使用 RAM 子账号或令牌
- 定期审查和清理不再使用的凭据

---

## 七、其他凭据类型

### 腾讯云容器镜像仓库凭据

用于推送 Docker 镜像到腾讯云 CCR：

```
Kind: Username with password
Scope: Global
Username: 腾讯云账号 ID（数字）
Password: 腾讯云 API 密钥
ID: tencent-ccr-credentials
Description: 腾讯云容器镜像仓库
```

在 Jenkinsfile 中使用：

```groovy
stage('推送 Docker 镜像') {
    steps {
        script {
            withCredentials([usernamePassword(
                credentialsId: 'tencent-ccr-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh """
                    echo \${DOCKER_PASS} | docker login ccr.ccs.tencentyun.com -u \${DOCKER_USER} --password-stdin
                    docker push ccr.ccs.tencentyun.com/myproject/myapp:latest
                """
            }
        }
    }
}
```

---

## 八、快速配置流程

### 完整步骤（5 分钟完成）

1. **准备工作**
   - 打开阿里云效：https://codeup.aliyun.com
   - 打开 Jenkins：`http://<节点IP>:30080`

2. **创建令牌**
   - 阿里云效 → 个人设置 → 个人访问令牌 → 新建令牌
   - 令牌名称：`Jenkins-2026`
   - 权限：勾选 `repo`
   - 创建并复制令牌字符串

3. **添加凭据**
   - Jenkins → Manage Jenkins → Manage Credentials → Add Credentials
   - Username: 你的阿里云账号
   - Password: 粘贴令牌字符串
   - ID: `aliyun-codeup-token`
   - 保存

4. **测试验证**
   - 创建测试流水线
   - 使用 `credentialsId: 'aliyun-codeup-token'`
   - 运行构建，检查是否能成功拉取代码

5. **完成**
   - 凭据配置成功，可以在所有流水线中使用

---

## 相关文档

- [Jenkins流水线使用指南.md](./Jenkins流水线使用指南.md)
- [Jenkins配置JDK和Maven.md](./Jenkins配置JDK和Maven.md)
- [容器镜像仓库配置指南.md](./容器镜像仓库配置指南.md)
