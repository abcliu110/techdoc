# Jenkins Pipeline 函数详解

## 一、deleteDir() - 清理工作空间

### 1.1 基本概念

```groovy
deleteDir()
```

**作用：** 删除当前工作空间的所有内容

**等价于：**
```bash
rm -rf /var/jenkins_home/workspace/nms4cloud-build/*
```

### 1.2 为什么需要 deleteDir()？

**问题场景：**
```
第 1 次构建：
- 检出代码
- 构建成功
- 留下文件：target/*.jar, node_modules/, .git/

第 2 次构建：
- 旧文件还在
- 可能导致：
  ✗ 使用了旧的依赖
  ✗ 旧的构建产物混入
  ✗ Git 冲突
```

**使用 deleteDir() 后：**
```
第 1 次构建：
- 检出代码
- 构建成功
- deleteDir() 清理

第 2 次构建：
- 工作空间是空的 ✓
- 全新的环境 ✓
- 没有旧文件干扰 ✓
```

### 1.3 使用位置

**在代码检出阶段使用：**
```groovy
stage('代码检出') {
    steps {
        script {
            echo "=== 清理工作空间 ==="
            deleteDir()  // ← 先清理

            echo "=== 检出代码 ==="
            checkout(...)  // ← 再检出
        }
    }
}
```

**执行顺序：**
```
1. deleteDir() → 删除所有旧文件
2. checkout → 检出全新的代码
```

### 1.4 实际效果

**执行前：**
```bash
/var/jenkins_home/workspace/nms4cloud-build/
├── target/
│   └── old-app.jar          ← 旧的构建产物
├── node_modules/            ← 旧的依赖
├── .git/                    ← 旧的 Git 信息
└── src/
    └── old-code.java        ← 可能是旧代码
```

**执行 deleteDir() 后：**
```bash
/var/jenkins_home/workspace/nms4cloud-build/
(空目录)
```

**检出代码后：**
```bash
/var/jenkins_home/workspace/nms4cloud-build/
├── .git/                    ← 全新的 Git 信息
├── pom.xml
├── src/
│   └── new-code.java        ← 最新代码
└── README.md
```

### 1.5 注意事项

**优点：**
- ✅ 确保每次构建都是干净的环境
- ✅ 避免旧文件干扰
- ✅ 避免 Git 冲突

**缺点：**
- ❌ 每次都要重新下载依赖（Maven、npm）
- ❌ 构建时间可能变长

**优化方案：**
```groovy
// 不删除 Maven 缓存
deleteDir()
sh 'mkdir -p .m2'
// 挂载 Maven 缓存到 .m2
```

---

## 二、checkoutRepo() 函数详解

### 2.1 完整代码

```groovy
def checkoutRepo(String name, String url, String targetDir) {
    echo "=== 检出 ${name} ==="
    if (targetDir == '.') {
        checkout([
            $class: 'GitSCM',
            branches: [[name: "*/${GIT_BRANCH}"]],
            extensions: [
                [$class: 'CloneOption', depth: 1, shallow: true],
                [$class: 'CheckoutOption', timeout: 20]
            ],
            userRemoteConfigs: [[
                credentialsId: "${GIT_CREDENTIAL_ID}",
                url: "${url}"
            ]]
        ])
    } else {
        dir(targetDir) {
            checkout([
                $class: 'GitSCM',
                branches: [[name: "*/${GIT_BRANCH}"]],
                extensions: [
                    [$class: 'CloneOption', depth: 1, shallow: true],
                    [$class: 'CheckoutOption', timeout: 20]
                ],
                userRemoteConfigs: [[
                    credentialsId: "${GIT_CREDENTIAL_ID}",
                    url: "${url}"
                ]]
            ])
        }
    }
}
```

### 2.2 函数参数

```groovy
def checkoutRepo(String name, String url, String targetDir)
```

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `name` | String | 仓库名称（用于日志） | `'主项目'` |
| `url` | String | Git 仓库地址 | `'https://github.com/...'` |
| `targetDir` | String | 目标目录 | `'.'` 或 `'nms4cloud-wms'` |

### 2.3 逻辑分支

#### 分支 1：检出到当前目录（targetDir == '.'）

```groovy
if (targetDir == '.') {
    checkout([...])  // 直接在当前目录检出
}
```

**使用场景：** 检出主项目

**调用示例：**
```groovy
checkoutRepo('主项目', 'https://github.com/main.git', '.')
```

**结果：**
```
/var/jenkins_home/workspace/nms4cloud-build/
├── pom.xml              ← 主项目文件
├── src/
└── README.md
```

#### 分支 2：检出到子目录（targetDir != '.'）

```groovy
else {
    dir(targetDir) {      // 切换到子目录
        checkout([...])   // 在子目录中检出
    }
}
```

**使用场景：** 检出子模块

**调用示例：**
```groovy
checkoutRepo('WMS 模块', 'https://github.com/wms.git', 'nms4cloud-wms')
```

**结果：**
```
/var/jenkins_home/workspace/nms4cloud-build/
├── pom.xml              ← 主项目文件
├── src/
└── nms4cloud-wms/       ← 子目录
    ├── pom.xml          ← WMS 项目文件
    └── src/
```

### 2.4 checkout 参数详解

```groovy
checkout([
    $class: 'GitSCM',
    branches: [[name: "*/${GIT_BRANCH}"]],
    extensions: [
        [$class: 'CloneOption', depth: 1, shallow: true],
        [$class: 'CheckoutOption', timeout: 20]
    ],
    userRemoteConfigs: [[
        credentialsId: "${GIT_CREDENTIAL_ID}",
        url: "${url}"
    ]]
])
```

#### $class: 'GitSCM'

**作用：** 指定使用 Git 源码管理

#### branches

```groovy
branches: [[name: "*/${GIT_BRANCH}"]]
```

**作用：** 指定要检出的分支

**示例：**
```groovy
GIT_BRANCH = 'master'
branches: [[name: "*/master"]]  // 检出 master 分支

GIT_BRANCH = 'develop'
branches: [[name: "*/develop"]]  // 检出 develop 分支
```

**`*/` 的含义：** 匹配所有远程仓库（origin、upstream 等）

#### extensions - CloneOption

```groovy
[$class: 'CloneOption', depth: 1, shallow: true]
```

**作用：** 浅克隆（Shallow Clone）

**参数说明：**
- `depth: 1`：只克隆最近 1 次提交的历史
- `shallow: true`：启用浅克隆

**效果对比：**

**完整克隆（默认）：**
```bash
git clone https://github.com/repo.git
# 下载所有历史记录
# 大小：500 MB
# 时间：5 分钟
```

**浅克隆（depth: 1）：**
```bash
git clone --depth 1 https://github.com/repo.git
# 只下载最新提交
# 大小：50 MB
# 时间：30 秒
```

**优点：**
- ✅ 下载速度快
- ✅ 占用空间小
- ✅ 适合 CI/CD（不需要完整历史）

**缺点：**
- ❌ 无法查看历史提交
- ❌ 无法切换到其他分支

#### extensions - CheckoutOption

```groovy
[$class: 'CheckoutOption', timeout: 20]
```

**作用：** 设置检出超时时间

**参数：**
- `timeout: 20`：20 分钟超时

**场景：**
```
大型仓库检出：
- 正常情况：5 分钟完成
- 网络慢：15 分钟完成
- 超过 20 分钟：自动终止 ✗
```

#### userRemoteConfigs

```groovy
userRemoteConfigs: [[
    credentialsId: "${GIT_CREDENTIAL_ID}",
    url: "${url}"
]]
```

**作用：** 配置 Git 仓库信息

**参数：**
- `credentialsId`：Jenkins 中配置的凭据 ID
- `url`：Git 仓库地址

**凭据配置：**
```
Jenkins → 凭据 → 添加凭据
- ID: aliyun-codeup-token
- 类型: Username with password
- 用户名: your-username
- 密码: your-password
```

### 2.5 完整执行流程

**调用：**
```groovy
checkoutRepo('WMS 模块', 'https://github.com/wms.git', 'nms4cloud-wms')
```

**执行步骤：**
```
1. echo "=== 检出 WMS 模块 ==="
   ↓
2. 判断 targetDir: 'nms4cloud-wms' != '.'
   ↓
3. 执行 dir('nms4cloud-wms') { ... }
   ↓
4. 创建目录：/workspace/nms4cloud-build/nms4cloud-wms/
   ↓
5. 切换到该目录
   ↓
6. 执行 checkout:
   - 使用凭据：aliyun-codeup-token
   - 克隆仓库：https://github.com/wms.git
   - 检出分支：master
   - 浅克隆：depth=1
   - 超时：20 分钟
   ↓
7. 完成
```

**日志输出：**
```
=== 检出 WMS 模块 ===
Cloning repository https://github.com/wms.git
 > git init /var/jenkins_home/workspace/nms4cloud-build/nms4cloud-wms
 > git fetch --depth 1 --no-tags origin +refs/heads/master:refs/remotes/origin/master
 > git checkout -f origin/master
Commit message: "Update README"
```

### 2.6 实际使用示例

```groovy
stage('代码检出') {
    steps {
        script {
            deleteDir()  // 清理工作空间

            // 检出主项目到当前目录
            checkoutRepo('主项目', REPO_MAIN, '.')

            // 检出 WMS 模块到子目录
            checkoutRepo('WMS 模块', REPO_WMS, 'nms4cloud-wms')

            // 检出 BI 模块到子目录
            checkoutRepo('BI 模块', REPO_BI, 'nms4cloud-bi')
        }
    }
}
```

**最终目录结构：**
```
/var/jenkins_home/workspace/nms4cloud-build/
├── pom.xml                  ← 主项目
├── src/
├── nms4cloud-wms/           ← WMS 模块
│   ├── pom.xml
│   └── src/
└── nms4cloud-bi/            ← BI 模块
    ├── pom.xml
    └── src/
```

---

## 三、总结

### 3.1 deleteDir()

| 特性 | 说明 |
|------|------|
| 作用 | 删除工作空间所有内容 |
| 使用时机 | 代码检出前 |
| 优点 | 确保干净环境 |
| 缺点 | 需要重新下载依赖 |

### 3.2 checkoutRepo()

| 特性 | 说明 |
|------|------|
| 作用 | 封装 Git 检出逻辑 |
| 参数 | name, url, targetDir |
| 特点 | 支持浅克隆、超时控制 |
| 优点 | 代码复用、逻辑清晰 |

### 3.3 关键配置

```groovy
// 浅克隆（快速）
depth: 1, shallow: true

// 超时控制（避免卡死）
timeout: 20

// 凭据管理（安全）
credentialsId: "${GIT_CREDENTIAL_ID}"
```
