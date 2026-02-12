# Jenkins 工作原理

## 概述

本文档介绍 Jenkins 的核心工作原理，包括构建触发机制、流水线执行、工具配置等内容。

---

## 一、Jenkins 架构概述

### 1. 核心组件

```
┌─────────────────────────────────────────┐
│           Jenkins Master                │
│  ┌─────────────────────────────────┐   │
│  │   Web UI / REST API             │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   Job 管理 / 调度器              │   │
│  └─────────────────────────────────┘   │
│  ┌─────────────────────────────────┐   │
│  │   插件系统                       │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
         │
         ├─── Agent 1 (执行构建)
         ├─── Agent 2 (执行构建)
         └─── Agent 3 (执行构建)
```

### 2. 工作流程

```
1. 用户/触发器 → 触发构建
   ↓
2. Jenkins Master → 调度任务
   ↓
3. Jenkins Agent → 执行构建
   ↓
4. 构建结果 → 归档/通知
```

---

## 二、构建触发机制

### 1. Git 轮询（pollSCM）

#### 工作原理

Git轮询是Jenkins主动检测代码变更的机制：

```
Jenkins每隔一段时间（如5分钟）主动去检查Git仓库
↓
对比上次构建的commit和当前最新commit
↓
如果发现有新的提交（commit）
↓
自动触发构建任务
```

#### 配置示例

```groovy
pipeline {
    agent any

    triggers {
        pollSCM('H/5 * * * *')  // 每5分钟检查一次
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}
```

#### 轮询间隔语法

```groovy
// Cron语法：分 时 日 月 周
pollSCM('H/5 * * * *')   // 每5分钟检查一次
pollSCM('H/10 * * * *')  // 每10分钟检查一次
pollSCM('H/15 * * * *')  // 每15分钟检查一次
pollSCM('H * * * *')     // 每小时检查一次
pollSCM('H/10 8-18 * * 1-5')  // 工作日8-18点，每10分钟
```

⚠️ **使用 `H` 而不是具体数字**：
- `H/5` 表示每5分钟，但具体时间由Jenkins分散（避免所有任务同时运行）
- `*/5` 表示每5分钟的整点（0、5、10、15...）
- `H` 是 Hash 的缩写，Jenkins会根据任务名称计算一个哈希值来分散执行时间

#### 检测过程详解

```
1. Jenkins读取上次构建记录的Git commit ID
   例如：abc123

2. 连接到Git仓库，获取最新的commit ID
   例如：def456

3. 对比两个commit ID
   - 如果相同：无变更，不触发构建
   - 如果不同：有新提交，触发构建

4. 记录新的commit ID，用于下次对比
```

#### Git轮询 vs Webhook 对比

| 特性 | Git轮询（pollSCM） | Webhook |
|------|-------------------|---------|
| **触发方式** | Jenkins主动定期检查 | Git服务器推送通知 |
| **实时性** | 有延迟（取决于轮询间隔） | 实时触发（秒级） |
| **网络要求** | Jenkins能访问Git仓库 | Git服务器能访问Jenkins |
| **配置复杂度** | 简单（只需配置轮询间隔） | 复杂（需要配置Webhook URL和Token） |
| **服务器负载** | 较高（频繁检查） | 较低（按需触发） |
| **适用场景** | Jenkins在内网，Git在外网 | 两者都能互相访问 |
| **可靠性** | 高（不依赖外部推送） | 中（依赖网络和配置） |
| **资源消耗** | 高（即使无变更也检查） | 低（只在有变更时触发） |

#### 实际应用场景

**场景1：内网Jenkins + 外网Git（推荐用轮询）**

```
外网阿里云效 ←─── 轮询检查 ←─── 内网Jenkins
（无法访问内网）              （可以访问外网）
```

配置：
```groovy
triggers {
    pollSCM('H/5 * * * *')  // Jenkins主动检查
}
```

**场景2：都在公网（推荐用Webhook）**

```
阿里云效 ──── Webhook推送 ───→ Jenkins
（可以访问Jenkins）           （接收通知）
```

配置：在阿里云效中配置Webhook URL：
```
http://your-jenkins.com/generic-webhook-trigger/invoke?token=your-token
```

**场景3：混合使用（最佳实践）**

```groovy
triggers {
    // 主要使用Webhook（实时）
    GenericTrigger(
        genericVariables: [
            [key: 'ref', value: '$.ref']
        ],
        token: 'your-token',
        causeString: 'Triggered by Webhook'
    )

    // 备用轮询（防止Webhook失败）
    pollSCM('H/30 * * * *')  // 每30分钟检查一次
}
```

#### 优缺点分析

**Git轮询的优点：**

✅ **配置简单**
- 只需在Jenkinsfile中添加一行配置
- 不需要在Git服务器端配置

✅ **适合内网环境**
- Jenkins在内网，Git在外网时仍然可用
- 不需要暴露Jenkins到公网

✅ **可靠性高**
- 不依赖外部推送
- 即使Webhook失败也能检测到变更

✅ **无需额外权限**
- 不需要在Git服务器配置Webhook权限
- 只需要Git仓库的读取权限

**Git轮询的缺点：**

❌ **有延迟**
- 最快也要等到下一次轮询
- 5分钟轮询意味着最多5分钟延迟

❌ **增加服务器负载**
- 频繁检查Git仓库
- 即使没有变更也要检查

❌ **浪费资源**
- 大部分时间检查结果是"无变更"
- 多个任务同时轮询会增加负载

❌ **网络消耗**
- 每次检查都需要连接Git服务器
- 大量任务会产生大量网络请求

#### 最佳实践建议

**1. 选择合适的轮询间隔**

```groovy
// 开发环境：频繁检查（快速反馈）
pollSCM('H/5 * * * *')   // 每5分钟

// 测试环境：适中检查
pollSCM('H/15 * * * *')  // 每15分钟

// 生产环境：较少检查
pollSCM('H/30 * * * *')  // 每30分钟

// 夜间构建：只在工作时间检查
pollSCM('H/10 8-18 * * 1-5')  // 工作日8-18点，每10分钟
```

**2. 结合定时构建**

```groovy
triggers {
    // 定时构建（每天凌晨全量构建）
    cron('0 1 * * *')

    // Git轮询（工作时间增量构建）
    pollSCM('H/10 8-18 * * 1-5')
}
```

**3. 优先使用Webhook**

如果条件允许，优先使用Webhook：
- 实时性更好（秒级触发）
- 资源消耗更低（按需触发）
- 只在有变更时触发

**4. 轮询作为备用方案**

```groovy
triggers {
    // 主要：Webhook（实时）
    GenericTrigger(...)

    // 备用：轮询（防止Webhook失败）
    pollSCM('H/30 * * * *')
}
```

**5. 避免过于频繁的轮询**

```groovy
// ❌ 不推荐：太频繁
pollSCM('* * * * *')  // 每分钟检查

// ✅ 推荐：合理间隔
pollSCM('H/5 * * * *')  // 每5分钟检查
```

#### 如何禁用Git轮询

如果不需要自动触发，可以：

**方式1：注释掉配置**
```groovy
triggers {
    // pollSCM('H/5 * * * *')  // 已禁用
}
```

**方式2：删除整个triggers块**
```groovy
// triggers {
//     pollSCM('H/5 * * * *')
// }
```

**方式3：只保留手动触发**
- 不配置任何triggers
- 只能通过"Build Now"或"Build with Parameters"手动触发

#### 监控轮询状态

**查看轮询日志：**
1. 进入任务页面
2. 点击左侧菜单 **Git Polling Log**
3. 查看每次轮询的结果

**日志示例：**
```
Started on 2026-02-12 14:00:00
Using strategy: Default
[poll] Last Built Revision: Revision abc123
[poll] Latest Remote Revision: Revision def456
Changes found
Done. Took 1.2 sec
```

### 2. 定时构建（cron）

#### 工作原理

定时构建不检查代码变更，按照固定时间表触发构建：

```groovy
triggers {
    cron('0 1 * * *')  // 每天凌晨1点构建
}
```

#### 常用定时表达式

```groovy
cron('0 1 * * *')        // 每天凌晨1点
cron('0 */2 * * *')      // 每2小时
cron('0 9-17 * * 1-5')   // 工作日9-17点，每小时
cron('0 0 * * 0')        // 每周日凌晨
```

### 3. Webhook 触发

#### 工作原理

Git服务器在代码变更时主动推送通知给Jenkins：

```
开发者提交代码
↓
Git服务器检测到push事件
↓
Git服务器发送HTTP请求到Jenkins
↓
Jenkins接收请求并触发构建
```

#### 配置示例

```groovy
triggers {
    GenericTrigger(
        genericVariables: [
            [key: 'ref', value: '$.ref'],
            [key: 'commit', value: '$.after']
        ],
        token: 'your-secret-token',
        causeString: 'Triggered by Git Webhook',
        printContributedVariables: true
    )
}
```

### 4. 手动触发

- **Build Now**：立即构建（使用默认参数）
- **Build with Parameters**：使用自定义参数构建

---

## 三、流水线执行原理

### 1. 声明式流水线（Declarative Pipeline）

```groovy
pipeline {
    agent any  // 在任意可用的agent上执行

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
    }
}
```

### 2. 脚本式流水线（Scripted Pipeline）

```groovy
node {
    stage('Build') {
        sh 'mvn clean install'
    }
}
```

---

## 四、工具配置原理

### 1. Maven 工具

```groovy
environment {
    MAVEN_HOME = tool 'Maven'  // 引用全局配置的Maven
    PATH = "${MAVEN_HOME}/bin:${env.PATH}"
}
```

**工作流程：**
1. Jenkins从全局工具配置中查找名为"Maven"的工具
2. 如果配置了自动安装，首次使用时自动下载
3. 返回Maven的安装路径
4. 添加到PATH环境变量

### 2. JDK 工具

```groovy
environment {
    JAVA_HOME = tool name: 'JDK21', type: 'jdk'
    PATH = "${JAVA_HOME}/bin:${env.PATH}"
}
```

---

## 五、凭据管理原理

### 1. 凭据存储

Jenkins将凭据加密存储在：
```
/var/jenkins_home/credentials.xml
```

### 2. 凭据使用

```groovy
withCredentials([usernamePassword(
    credentialsId: 'aliyun-codeup-token',
    usernameVariable: 'GIT_USER',
    passwordVariable: 'GIT_PASS'
)]) {
    sh 'git clone https://${GIT_USER}:${GIT_PASS}@codeup.aliyun.com/repo.git'
}
```

**安全机制：**
- 凭据在日志中自动脱敏（显示为 `****`）
- 只在构建过程中临时注入环境变量
- 构建结束后自动清理

---

## 六、构建产物归档原理

### 1. 归档机制

```groovy
archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
```

**工作流程：**
1. 在工作空间中查找匹配的文件
2. 复制到Jenkins的归档目录
3. 生成文件指纹（MD5哈希）
4. 可通过Web UI下载

### 2. 存储位置

```
/var/jenkins_home/jobs/<job-name>/builds/<build-number>/archive/
```

---

## 七、总结

### Git轮询的核心作用

Git轮询是**自动检测代码变更并触发构建**的机制，适合：
- ✅ Jenkins在内网，无法接收外部Webhook
- ✅ 作为Webhook的备用方案
- ✅ 不需要实时构建的场景
- ✅ 无法配置Webhook权限的情况

### 选择建议

| 场景 | 推荐方案 |
|------|---------|
| Jenkins和Git都在公网 | Webhook（实时） |
| Jenkins在内网，Git在外网 | Git轮询 |
| 需要高可靠性 | Webhook + Git轮询（双保险） |
| 定期全量构建 | 定时构建（cron） |
| 手动控制构建时机 | 手动触发 |

---

## 相关文档

- [Jenkins凭据设置.md](./Jenkins凭据设置.md)
- [Jenkins创建Pipeline任务指南.md](./Jenkins创建Pipeline任务指南.md)
- [Jenkins流水线使用指南.md](./Jenkins流水线使用指南.md)
- [Jenkins性能优化指南.md](./Jenkins性能优化指南.md)
