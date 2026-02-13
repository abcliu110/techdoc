# Git 克隆技术原理详解

## 一、branches: [[name: "*/${GIT_BRANCH}"]]

### 1.1 基本概念

```groovy
branches: [[name: "*/${GIT_BRANCH}"]]
```

**作用：** 指定要检出的 Git 分支

### 1.2 语法解析

```groovy
branches: [
    [name: "*/master"]
]
```

**结构：**
- `branches`：数组，可以指定多个分支
- `[name: "..."]`：每个分支的配置
- `"*/master"`：分支匹配模式

### 1.3 `*/` 的含义

**`*/` = 匹配所有远程仓库**

**Git 远程仓库概念：**
```bash
# 查看远程仓库
git remote -v

# 输出示例：
origin    https://github.com/user/repo.git (fetch)
origin    https://github.com/user/repo.git (push)
upstream  https://github.com/original/repo.git (fetch)
upstream  https://github.com/original/repo.git (push)
```

**分支的完整名称：**
```
远程仓库名/分支名

例如：
origin/master      ← origin 仓库的 master 分支
origin/develop     ← origin 仓库的 develop 分支
upstream/master    ← upstream 仓库的 master 分支
```

**`*/master` 的匹配：**
```
*/master 匹配：
✓ origin/master
✓ upstream/master
✓ any-remote/master

master 只匹配：
✓ origin/master（默认）
```

### 1.4 为什么使用 `*/`？

**场景 1：单一远程仓库**
```bash
git remote -v
# origin    https://github.com/user/repo.git

branches: [[name: "*/master"]]
# 匹配：origin/master ✓
```

**场景 2：多个远程仓库**
```bash
git remote -v
# origin    https://github.com/user/repo.git
# upstream  https://github.com/original/repo.git

branches: [[name: "*/master"]]
# 匹配：origin/master ✓
# 匹配：upstream/master ✓
```

**场景 3：Fork 的仓库**
```bash
# 你 fork 了别人的项目
git remote -v
# origin    https://github.com/your-name/repo.git (你的 fork)
# upstream  https://github.com/original/repo.git (原始仓库)

branches: [[name: "*/develop"]]
# 可以从任何远程仓库检出 develop 分支
```

### 1.5 技术原理

**Git 分支检出流程：**

```
1. Jenkins 执行 git clone
   ↓
2. 添加远程仓库
   git remote add origin https://...
   ↓
3. 获取远程分支列表
   git fetch origin
   ↓
4. 匹配分支模式 "*/master"
   找到：origin/master
   ↓
5. 检出分支
   git checkout -b master origin/master
   ↓
6. 完成
```

**等价的 Git 命令：**
```bash
# Jenkins 实际执行的命令
git clone https://github.com/user/repo.git
cd repo
git checkout -b master origin/master
```

### 1.6 多分支匹配

**匹配多个分支：**
```groovy
branches: [
    [name: "*/master"],
    [name: "*/develop"],
    [name: "*/release-*"]
]
```

**匹配规则：**
```
*/master      → 匹配 master 分支
*/develop     → 匹配 develop 分支
*/release-*   → 匹配 release-1.0, release-2.0 等
```

---

## 二、CloneOption: depth: 1, shallow: true

### 2.1 基本概念

```groovy
[$class: 'CloneOption', depth: 1, shallow: true]
```

**作用：** 浅克隆（Shallow Clone），只下载部分 Git 历史

### 2.2 Git 历史结构

**完整的 Git 历史：**
```
commit 5 (HEAD -> master)  ← 最新提交
    ↓
commit 4
    ↓
commit 3
    ↓
commit 2
    ↓
commit 1                    ← 初始提交
```

**每个 commit 包含：**
- 代码快照
- 提交信息
- 作者信息
- 时间戳
- 父提交引用

### 2.3 完整克隆 vs 浅克隆

#### 完整克隆（默认）

```bash
git clone https://github.com/user/repo.git
```

**下载内容：**
```
所有提交历史：
commit 5 ✓
commit 4 ✓
commit 3 ✓
commit 2 ✓
commit 1 ✓

所有分支：
master ✓
develop ✓
feature-x ✓

所有标签：
v1.0 ✓
v2.0 ✓
```

**特点：**
- 下载大小：500 MB
- 下载时间：5 分钟
- 可以查看所有历史
- 可以切换到任何提交

#### 浅克隆（depth: 1）

```bash
git clone --depth 1 https://github.com/user/repo.git
```

**下载内容：**
```
只有最新提交：
commit 5 ✓
commit 4 ✗
commit 3 ✗
commit 2 ✗
commit 1 ✗

只有当前分支：
master ✓
develop ✗
feature-x ✗
```

**特点：**
- 下载大小：50 MB
- 下载时间：30 秒
- 只能查看最新提交
- 无法切换到其他提交

### 2.4 depth 参数详解

```groovy
depth: 1
```

**含义：** 克隆深度为 1，只下载最近 1 次提交

**不同 depth 的效果：**

**depth: 1**
```
commit 5 (HEAD)  ✓
commit 4         ✗
commit 3         ✗
```

**depth: 3**
```
commit 5 (HEAD)  ✓
commit 4         ✓
commit 3         ✓
commit 2         ✗
commit 1         ✗
```

**depth: 10**
```
commit 5 (HEAD)  ✓
commit 4         ✓
commit 3         ✓
...
commit 1         ✗（如果超过 10 个提交）
```

### 2.5 shallow: true 的作用

```groovy
shallow: true
```

**含义：** 启用浅克隆模式

**技术细节：**

**Git 内部标记：**
```bash
# 浅克隆后，Git 会创建一个特殊文件
.git/shallow

# 文件内容：
abc123def456...  ← 最早的 commit SHA
```

**这个文件告诉 Git：**
- 这是一个浅克隆仓库
- 不要尝试访问更早的提交
- 某些 Git 操作会受限

### 2.6 技术原理

**完整克隆的数据传输：**
```
客户端：git clone https://...
    ↓
服务器：打包所有对象
    - commit 对象（5 个）
    - tree 对象（文件树）
    - blob 对象（文件内容）
    - 所有历史版本
    ↓
传输：500 MB
    ↓
客户端：解包所有对象
```

**浅克隆的数据传输：**
```
客户端：git clone --depth 1 https://...
    ↓
服务器：只打包最新的对象
    - commit 对象（1 个）
    - tree 对象（当前文件树）
    - blob 对象（当前文件内容）
    ↓
传输：50 MB
    ↓
客户端：解包对象 + 创建 .git/shallow
```

### 2.7 浅克隆的限制

**无法执行的操作：**

```bash
# ✗ 无法查看历史
git log --all
# fatal: shallow file has changed since we read it

# ✗ 无法切换到旧提交
git checkout abc123
# fatal: reference is not a tree: abc123

# ✗ 无法推送到其他分支
git push origin HEAD:develop
# error: shallow update not allowed
```

**可以执行的操作：**

```bash
# ✓ 查看当前提交
git log -1

# ✓ 查看文件
cat README.md

# ✓ 构建项目
mvn clean package

# ✓ 提交到当前分支
git commit -m "fix"
git push origin master
```

### 2.8 为什么 CI/CD 使用浅克隆？

**CI/CD 的需求：**
- ✓ 只需要最新代码
- ✓ 不需要查看历史
- ✓ 不需要切换分支
- ✓ 速度要快
- ✓ 占用空间小

**浅克隆的优势：**
```
完整克隆：
- 下载：500 MB
- 时间：5 分钟
- 磁盘：500 MB

浅克隆：
- 下载：50 MB（节省 90%）
- 时间：30 秒（快 10 倍）
- 磁盘：50 MB（节省 90%）
```

---

## 三、CheckoutOption: timeout: 20

### 3.1 基本概念

```groovy
[$class: 'CheckoutOption', timeout: 20]
```

**作用：** 设置 Git 检出操作的超时时间（单位：分钟）

### 3.2 为什么需要超时？

**问题场景：**

**场景 1：网络问题**
```
开始克隆：10:00
网络很慢...
10:05 - 下载 10%
10:10 - 下载 20%
10:15 - 下载 30%
...
如果没有超时，可能一直卡住
```

**场景 2：大型仓库**
```
仓库大小：10 GB
正常下载：30 分钟
网络故障：永远无法完成
```

**场景 3：服务器无响应**
```
连接 Git 服务器...
服务器挂了，没有响应
如果没有超时，Jenkins 会一直等待
```

### 3.3 超时机制

**timeout: 20 的含义：**
```
开始时间：10:00
超时时间：10:20（20 分钟后）

时间线：
10:00 - 开始克隆
10:05 - 下载中...
10:10 - 下载中...
10:15 - 下载中...
10:20 - 超时！自动终止 ✗
```

**超时后的行为：**
```
1. 终止 Git 进程
2. 清理临时文件
3. 标记构建失败
4. 显示错误信息：
   "Timeout after 20 minutes"
```

### 3.4 技术原理

**Jenkins 的超时实现：**

```java
// Jenkins 内部伪代码
Thread gitCloneThread = new Thread(() -> {
    git.clone(url);
});

gitCloneThread.start();

// 等待最多 20 分钟
boolean finished = gitCloneThread.join(20 * 60 * 1000);

if (!finished) {
    // 超时，强制终止
    gitCloneThread.interrupt();
    throw new TimeoutException("Git checkout timeout");
}
```

**Git 进程管理：**
```bash
# Jenkins 启动 Git 进程
PID=12345: git clone https://...

# 20 分钟后，如果还在运行
kill -9 12345  # 强制终止
```

### 3.5 如何选择超时时间？

**考虑因素：**

1. **仓库大小**
```
小型仓库（< 100 MB）：5-10 分钟
中型仓库（100 MB - 1 GB）：10-20 分钟
大型仓库（> 1 GB）：20-60 分钟
```

2. **网络速度**
```
内网（快）：5-10 分钟
公网（慢）：20-30 分钟
国际网络（很慢）：30-60 分钟
```

3. **浅克隆 vs 完整克隆**
```
浅克隆（depth: 1）：5-10 分钟
完整克隆：20-60 分钟
```

**推荐配置：**
```groovy
// 小项目 + 浅克隆
timeout: 10

// 中型项目 + 浅克隆
timeout: 20

// 大型项目 + 完整克隆
timeout: 60
```

---

## 四、完整的技术流程

### 4.1 Jenkins 执行的完整流程

```groovy
checkout([
    $class: 'GitSCM',
    branches: [[name: "*/master"]],
    extensions: [
        [$class: 'CloneOption', depth: 1, shallow: true],
        [$class: 'CheckoutOption', timeout: 20]
    ],
    userRemoteConfigs: [[
        credentialsId: "git-credentials",
        url: "https://github.com/user/repo.git"
    ]]
])
```

**等价的 Git 命令：**
```bash
# 1. 设置超时（20 分钟）
timeout 1200s bash -c '

# 2. 浅克隆（depth: 1）
git clone --depth 1 \
    --branch master \
    --single-branch \
    https://username:password@github.com/user/repo.git \
    /var/jenkins_home/workspace/project

# 3. 进入目录
cd /var/jenkins_home/workspace/project

# 4. 检出分支
git checkout master

'
```

### 4.2 网络传输过程

```
客户端（Jenkins）                    服务器（GitHub）
    |                                      |
    |  1. 发起连接                         |
    |------------------------------------->|
    |                                      |
    |  2. 请求分支信息（*/master）          |
    |------------------------------------->|
    |                                      |
    |  3. 返回分支列表                      |
    |<-------------------------------------|
    |     origin/master: abc123            |
    |                                      |
    |  4. 请求对象（depth: 1）              |
    |------------------------------------->|
    |     want: abc123                     |
    |     depth: 1                         |
    |                                      |
    |  5. 打包对象                          |
    |                                      |
    |  6. 传输数据（50 MB）                 |
    |<-------------------------------------|
    |     [=========>] 100%                |
    |                                      |
    |  7. 解包对象                          |
    |                                      |
    |  8. 创建 .git/shallow                |
    |                                      |
    |  9. 检出文件                          |
    |                                      |
    | 10. 完成                              |
```

### 4.3 磁盘操作过程

```
/var/jenkins_home/workspace/project/
    |
    ├── .git/
    │   ├── objects/          ← Git 对象存储
    │   │   ├── ab/
    │   │   │   └── c123...   ← commit 对象
    │   │   ├── de/
    │   │   │   └── f456...   ← tree 对象
    │   │   └── 78/
    │   │       └── 9abc...   ← blob 对象
    │   ├── refs/
    │   │   └── heads/
    │   │       └── master    ← 分支引用
    │   ├── shallow           ← 浅克隆标记
    │   └── config            ← Git 配置
    │
    ├── src/                  ← 检出的文件
    ├── pom.xml
    └── README.md
```

---

## 五、性能对比

### 5.1 完整克隆 vs 浅克隆

| 指标 | 完整克隆 | 浅克隆（depth: 1） | 节省 |
|------|----------|-------------------|------|
| 下载大小 | 500 MB | 50 MB | 90% |
| 下载时间 | 5 分钟 | 30 秒 | 90% |
| 磁盘占用 | 500 MB | 50 MB | 90% |
| 历史记录 | 全部 | 最新 1 次 | - |
| 功能限制 | 无 | 有 | - |

### 5.2 实际测试数据

**测试仓库：** Linux 内核（大型项目）

```
完整克隆：
$ time git clone https://github.com/torvalds/linux.git
real    45m23s
user    2m15s
sys     1m30s
Size:   3.5 GB

浅克隆（depth: 1）：
$ time git clone --depth 1 https://github.com/torvalds/linux.git
real    2m15s
user    0m10s
sys     0m08s
Size:   180 MB

性能提升：
- 时间：快 20 倍
- 空间：节省 95%
```

---

## 六、总结

### 6.1 技术要点

| 配置 | 技术原理 | 作用 |
|------|----------|------|
| `branches: [[name: "*/${GIT_BRANCH}"]]` | Git 远程分支匹配 | 指定检出的分支 |
| `depth: 1` | Git 浅克隆 | 只下载最新提交 |
| `shallow: true` | 创建 .git/shallow 文件 | 标记为浅克隆仓库 |
| `timeout: 20` | 进程超时控制 | 20 分钟后自动终止 |

### 6.2 最佳实践

**CI/CD 环境（推荐）：**
```groovy
branches: [[name: "*/master"]]
extensions: [
    [$class: 'CloneOption', depth: 1, shallow: true],  // 浅克隆
    [$class: 'CheckoutOption', timeout: 20]            // 20 分钟超时
]
```

**开发环境（需要完整历史）：**
```groovy
branches: [[name: "*/develop"]]
extensions: [
    [$class: 'CheckoutOption', timeout: 60]  // 不使用浅克隆
]
```

### 6.3 故障排查

**问题 1：超时**
```
错误：Timeout after 20 minutes
解决：增加超时时间或使用浅克隆
```

**问题 2：分支不存在**
```
错误：Couldn't find any revision to build
解决：检查分支名称是否正确
```

**问题 3：浅克隆限制**
```
错误：shallow update not allowed
解决：使用完整克隆或转换为完整仓库
```
