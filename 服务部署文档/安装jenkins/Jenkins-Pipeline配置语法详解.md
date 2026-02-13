# Jenkins Pipeline 配置语法详解

## 一、options（构建选项）

### 1.1 完整配置

```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
}
```

### 1.2 逐项解释

#### buildDiscarder - 构建历史保留策略

```groovy
buildDiscarder(logRotator(numToKeepStr: '10'))
```

**作用：** 自动清理旧的构建记录，节省磁盘空间

**参数说明：**
- `numToKeepStr: '10'`：只保留最近 10 次构建记录
- 超过 10 次的旧构建会被自动删除

**其他可选参数：**
```groovy
buildDiscarder(logRotator(
    numToKeepStr: '10',           // 保留最近 10 次构建
    daysToKeepStr: '30',          // 保留最近 30 天的构建
    artifactNumToKeepStr: '5',    // 保留最近 5 次构建的产物
    artifactDaysToKeepStr: '7'    // 保留最近 7 天的构建产物
))
```

**示例：**
```
构建历史：
#15 ← 最新
#14
#13
...
#6
#5  ← 保留到这里（第 10 次）
#4  ← 会被删除
#3  ← 会被删除
#2  ← 会被删除
#1  ← 会被删除
```

---

#### disableConcurrentBuilds - 禁止并发构建

```groovy
disableConcurrentBuilds()
```

**作用：** 同一时间只允许一个构建任务运行

**场景：**
```
情况 1：没有 disableConcurrentBuilds
用户 A 触发构建 #10 → 正在运行
用户 B 触发构建 #11 → 同时运行 ✅
结果：两个构建同时进行（可能冲突）

情况 2：有 disableConcurrentBuilds
用户 A 触发构建 #10 → 正在运行
用户 B 触发构建 #11 → 排队等待 ⏳
结果：#11 等待 #10 完成后才开始
```

**为什么需要：**
- 避免资源冲突（如数据库、文件系统）
- 避免 Maven 本地仓库冲突
- 确保构建顺序

---

#### timeout - 构建超时

```groovy
timeout(time: 30, unit: 'MINUTES')
```

**作用：** 如果构建超过 30 分钟，自动终止

**参数：**
- `time: 30`：超时时间
- `unit: 'MINUTES'`：时间单位

**可用的时间单位：**
```groovy
timeout(time: 30, unit: 'SECONDS')   // 30 秒
timeout(time: 30, unit: 'MINUTES')   // 30 分钟
timeout(time: 2, unit: 'HOURS')      // 2 小时
timeout(time: 1, unit: 'DAYS')       // 1 天
```

**示例：**
```
构建开始：10:00
构建超时：10:30（30 分钟后）
如果到 10:30 还没完成 → 自动终止 ❌
```

---

#### timestamps - 添加时间戳

```groovy
timestamps()
```

**作用：** 在构建日志中显示每行的时间戳

**效果对比：**

**没有 timestamps：**
```
[INFO] Building nms4cloud-bi-api
[INFO] Compiling 50 source files
[INFO] BUILD SUCCESS
```

**有 timestamps：**
```
10:15:23  [INFO] Building nms4cloud-bi-api
10:15:45  [INFO] Compiling 50 source files
10:16:30  [INFO] BUILD SUCCESS
```

**好处：**
- 方便定位耗时的步骤
- 便于性能分析
- 便于问题排查

---

## 二、triggers（触发器）

### 2.1 完整配置

```groovy
triggers {
    cron('0 1 * * *')           // 每天凌晨 1 点
    pollSCM('H/5 * * * *')      // 每 5 分钟检查一次
}
```

### 2.2 逐项解释

#### cron - 定时触发

```groovy
cron('0 1 * * *')
```

**作用：** 按照 Cron 表达式定时触发构建

**Cron 表达式格式：**
```
分 时 日 月 周
│ │ │ │ │
│ │ │ │ └─── 星期几（0-7，0 和 7 都表示周日）
│ │ │ └───── 月份（1-12）
│ │ └─────── 日期（1-31）
│ └───────── 小时（0-23）
└─────────── 分钟（0-59）
```

**常用示例：**

```groovy
// 每天凌晨 1 点
cron('0 1 * * *')

// 每天凌晨 2:30
cron('30 2 * * *')

// 每周一凌晨 3 点
cron('0 3 * * 1')

// 每月 1 号凌晨 4 点
cron('0 4 1 * *')

// 每天早上 8 点和下午 6 点
cron('0 8,18 * * *')

// 每小时执行一次
cron('0 * * * *')

// 每 30 分钟执行一次
cron('H/30 * * * *')

// 工作日（周一到周五）早上 9 点
cron('0 9 * * 1-5')
```

**特殊符号：**
- `*`：任意值
- `H`：哈希值（Jenkins 自动分散，避免同时触发）
- `/`：间隔
- `,`：多个值
- `-`：范围

**示例解释：**
```groovy
cron('0 1 * * *')
     │ │ │ │ │
     │ │ │ │ └─ 每周的任意一天
     │ │ │ └─── 每月的任意一天
     │ │ └───── 每天
     │ └─────── 凌晨 1 点
     └───────── 0 分

结果：每天凌晨 1:00 触发构建
```

---

#### pollSCM - 轮询 Git 仓库

```groovy
pollSCM('H/5 * * * *')
```

**作用：** 定期检查 Git 仓库是否有新提交，如果有则触发构建

**格式：** 与 cron 相同

**示例解释：**
```groovy
pollSCM('H/5 * * * *')
        │││ │ │ │ │
        │││ │ │ │ └─ 每周的任意一天
        │││ │ │ └─── 每月的任意一天
        │││ │ └───── 每天
        │││ └─────── 每小时
        ││└───────── 每 5 分钟
        │└────────── 哈希值（分散触发）
        └─────────── 分钟

结果：每 5 分钟检查一次 Git 仓库
```

**工作流程：**
```
时间轴：
10:00 → 检查 Git → 没有新提交 → 不触发
10:05 → 检查 Git → 有新提交 → 触发构建 ✅
10:10 → 检查 Git → 没有新提交 → 不触发
10:15 → 检查 Git → 有新提交 → 触发构建 ✅
```

**H 的作用：**
```
不使用 H：
所有项目都在 10:00、10:05、10:10... 检查
→ 可能导致 Jenkins 负载过高

使用 H：
项目 A：10:02、10:07、10:12...
项目 B：10:03、10:08、10:13...
项目 C：10:04、10:09、10:14...
→ 分散负载，避免同时触发
```

---

## 三、常用配置示例

### 3.1 开发环境配置

```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '5'))  // 只保留 5 次
    disableConcurrentBuilds()
    timeout(time: 15, unit: 'MINUTES')             // 15 分钟超时
    timestamps()
}

triggers {
    pollSCM('H/2 * * * *')  // 每 2 分钟检查一次（开发频繁）
}
```

### 3.2 生产环境配置

```groovy
options {
    buildDiscarder(logRotator(
        numToKeepStr: '30',          // 保留 30 次构建
        daysToKeepStr: '90',         // 保留 90 天
        artifactNumToKeepStr: '10'   // 保留 10 次产物
    ))
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')  // 60 分钟超时
    timestamps()
}

triggers {
    cron('0 2 * * *')       // 每天凌晨 2 点定时构建
    pollSCM('H/10 * * * *') // 每 10 分钟检查一次
}
```

### 3.3 测试环境配置

```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
}

triggers {
    // 工作日每天早上 8 点和下午 6 点
    cron('0 8,18 * * 1-5')
    // 每 5 分钟检查一次
    pollSCM('H/5 * * * *')
}
```

---

## 四、实际应用场景

### 4.1 场景：夜间定时构建

**需求：** 每天凌晨自动构建，确保代码可编译

```groovy
triggers {
    cron('0 1 * * *')  // 每天凌晨 1 点
}
```

### 4.2 场景：代码提交后自动构建

**需求：** 开发人员提交代码后，自动触发构建

```groovy
triggers {
    pollSCM('H/5 * * * *')  // 每 5 分钟检查一次
}
```

**更好的方式：** 使用 Git Webhook（实时触发，不需要轮询）

### 4.3 场景：工作时间频繁构建

**需求：** 工作时间（9:00-18:00）每小时构建一次

```groovy
triggers {
    cron('0 9-18 * * 1-5')  // 周一到周五，9 点到 18 点，每小时
}
```

### 4.4 场景：避免构建冲突

**需求：** 确保同一时间只有一个构建

```groovy
options {
    disableConcurrentBuilds()
}
```

---

## 五、总结

### 5.1 options 总结

| 选项 | 作用 | 推荐值 |
|------|------|--------|
| buildDiscarder | 清理旧构建 | 保留 10-30 次 |
| disableConcurrentBuilds | 禁止并发 | 建议启用 |
| timeout | 构建超时 | 30-60 分钟 |
| timestamps | 时间戳 | 建议启用 |

### 5.2 triggers 总结

| 触发器 | 作用 | 推荐值 |
|--------|------|--------|
| cron | 定时构建 | 凌晨 1-3 点 |
| pollSCM | 轮询 Git | 5-10 分钟 |

### 5.3 最佳实践

**推荐配置：**
```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
}

triggers {
    cron('0 2 * * *')       // 每天凌晨 2 点定时构建
    pollSCM('H/5 * * * *')  // 每 5 分钟检查 Git
}
```

**注意事项：**
1. 不要设置过短的轮询间隔（增加服务器负载）
2. 使用 `H` 分散触发时间
3. 根据项目规模调整超时时间
4. 定期清理旧构建节省空间

---

## 六、Jenkins 内置变量详解

### 6.1 BUILD_NUMBER - 构建编号

#### 什么是 BUILD_NUMBER？

**BUILD_NUMBER** 是 Jenkins 自动提供的内置环境变量，表示当前构建的编号。

**特点：**
- ✅ 自动递增，永不重复
- ✅ 每个 Jenkins 任务独立计数
- ✅ 无需配置，开箱即用

#### 从哪里来？

```
Jenkins 自动生成：

第 1 次构建 → BUILD_NUMBER = 1
第 2 次构建 → BUILD_NUMBER = 2
第 3 次构建 → BUILD_NUMBER = 3
...
第 123 次构建 → BUILD_NUMBER = 123
```

#### 在哪里体现？

**1. Jenkins 任务页面**
```
任务名称：nms4cloud-build

构建历史：
#15  ← BUILD_NUMBER = 15
#14
#13
#12
```

**2. 构建详情页面**
```
构建 #15                    ← BUILD_NUMBER = 15
状态：成功
持续时间：5 分 23 秒
```

**3. 构建 URL**
```
http://jenkins.example.com/job/nms4cloud-build/15/
                                                 ↑
                                          BUILD_NUMBER
```

**4. 构建日志中**
```bash
Started by user admin
Building in workspace /var/jenkins_home/workspace/nms4cloud-build
当前构建编号: 15              ← 如果在代码中打印
镜像标签: myapp:15
```

**5. Docker 镜像标签**
```bash
docker images

REPOSITORY                                    TAG     IMAGE ID
ccr.ccs.tencentyun.com/nms4cloud/myapp       15      abc123def456
ccr.ccs.tencentyun.com/nms4cloud/myapp       14      def456abc789
                                             ↑
                                      BUILD_NUMBER
```

#### 如何使用？

**方式 1：直接使用**
```groovy
stage('示例') {
    steps {
        script {
            echo "当前构建编号: ${BUILD_NUMBER}"
        }
    }
}
```

**方式 2：通过 env 对象**
```groovy
stage('示例') {
    steps {
        script {
            echo "当前构建编号: ${env.BUILD_NUMBER}"
        }
    }
}
```

**方式 3：用于 Docker 镜像标签**
```groovy
stage('构建镜像') {
    steps {
        sh """
            docker build -t myapp:${BUILD_NUMBER} .
            docker tag myapp:${BUILD_NUMBER} myapp:latest
        """
    }
}
```

**输出结果：**
```
构建 #15 → myapp:15
构建 #16 → myapp:16
构建 #17 → myapp:17
```

**方式 4：设置构建显示名称**
```groovy
stage('设置构建名称') {
    steps {
        script {
            currentBuild.displayName = "#${BUILD_NUMBER} - ${params.BUILD_MODULE}"
            // 显示为：#15 - nms4cloud-app
        }
    }
}
```

**方式 5：归档文件名**
```groovy
stage('归档') {
    steps {
        sh """
            cp target/myapp.jar artifacts/myapp-${BUILD_NUMBER}.jar
        """
    }
}
```

**结果：**
```
myapp-15.jar
myapp-16.jar
myapp-17.jar
```

---

### 6.2 其他常用的 Jenkins 内置变量

#### 构建信息

```groovy
environment {
    BUILD_NUMBER = "${env.BUILD_NUMBER}"        // 构建编号：15
    BUILD_ID = "${env.BUILD_ID}"                // 构建 ID：15
    BUILD_TAG = "${env.BUILD_TAG}"              // 构建标签：jenkins-myapp-15
    BUILD_URL = "${env.BUILD_URL}"              // 构建 URL
}
```

**示例输出：**
```
BUILD_NUMBER: 15
BUILD_ID: 15
BUILD_TAG: jenkins-nms4cloud-build-15
BUILD_URL: http://jenkins.example.com/job/nms4cloud-build/15/
```

#### 任务信息

```groovy
environment {
    JOB_NAME = "${env.JOB_NAME}"                // 任务名称：nms4cloud-build
    JOB_BASE_NAME = "${env.JOB_BASE_NAME}"      // 任务基础名称
    JOB_URL = "${env.JOB_URL}"                  // 任务 URL
}
```

#### 工作空间

```groovy
environment {
    WORKSPACE = "${env.WORKSPACE}"              // 工作空间路径
}
```

**示例值：**
```
WORKSPACE: /var/jenkins_home/workspace/nms4cloud-build
```

#### Git 信息（如果使用 Git）

```groovy
environment {
    GIT_COMMIT = "${env.GIT_COMMIT}"            // Git 提交 SHA
    GIT_BRANCH = "${env.GIT_BRANCH}"            // Git 分支
    GIT_URL = "${env.GIT_URL}"                  // Git 仓库 URL
}
```

**示例值：**
```
GIT_COMMIT: a1b2c3d4e5f6...
GIT_BRANCH: origin/master
GIT_URL: https://github.com/your/repo.git
```

#### Jenkins 信息

```groovy
environment {
    JENKINS_HOME = "${env.JENKINS_HOME}"        // Jenkins 主目录
    JENKINS_URL = "${env.JENKINS_URL}"          // Jenkins URL
}
```

#### 系统环境

```groovy
environment {
    PATH = "${env.PATH}"                        // 系统 PATH
    HOME = "${env.HOME}"                        // 用户主目录
}
```

---

### 6.3 完整的环境变量示例

```groovy
pipeline {
    agent any

    environment {
        // Maven 配置
        MAVEN_HOME = tool 'Maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // 项目配置
        PROJECT_NAME = 'nms4cloud'
        VERSION = "1.0.0-${BUILD_NUMBER}"       // 使用 BUILD_NUMBER

        // Docker 配置
        DOCKER_REGISTRY = 'ccr.ccs.tencentyun.com'
        DOCKER_NAMESPACE = 'nms4cloud'
        IMAGE_TAG = "${BUILD_NUMBER}"           // 使用 BUILD_NUMBER
    }

    stages {
        stage('环境检查') {
            steps {
                script {
                    echo "=== 构建信息 ==="
                    echo "BUILD_NUMBER: ${BUILD_NUMBER}"
                    echo "BUILD_TAG: ${BUILD_TAG}"
                    echo "JOB_NAME: ${JOB_NAME}"
                    echo "WORKSPACE: ${WORKSPACE}"
                    echo "VERSION: ${VERSION}"
                    echo "IMAGE_TAG: ${IMAGE_TAG}"
                }
            }
        }

        stage('构建镜像') {
            steps {
                sh """
                    docker build -t ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${PROJECT_NAME}:${IMAGE_TAG} .
                    docker tag ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${PROJECT_NAME}:${IMAGE_TAG} \
                               ${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/${PROJECT_NAME}:latest
                """
            }
        }
    }
}
```

**构建 #15 时的输出：**
```
=== 构建信息 ===
BUILD_NUMBER: 15
BUILD_TAG: jenkins-nms4cloud-build-15
JOB_NAME: nms4cloud-build
WORKSPACE: /var/jenkins_home/workspace/nms4cloud-build
VERSION: 1.0.0-15
IMAGE_TAG: 15

docker build -t ccr.ccs.tencentyun.com/nms4cloud/nms4cloud:15 .
docker tag ccr.ccs.tencentyun.com/nms4cloud/nms4cloud:15 \
           ccr.ccs.tencentyun.com/nms4cloud/nms4cloud:latest
```

---

### 6.4 变量来源总结

| 变量 | 来源 | 配置位置 | 示例值 |
|------|------|----------|--------|
| `BUILD_NUMBER` | Jenkins 自动生成 | 无需配置 | `15` |
| `MAVEN_HOME` | `tool 'Maven'` | Jenkins → 全局工具配置 | `/var/jenkins_home/tools/.../Maven` |
| `env.PATH` | 系统环境变量 | 操作系统 | `/usr/local/bin:/usr/bin` |
| `params.GIT_BRANCH` | 参数化构建 | Jenkinsfile 的 parameters 块 | `master` |

---

### 6.5 实用技巧

#### 技巧 1：组合使用多个变量

```groovy
environment {
    VERSION = "1.0.0"
    BUILD_VERSION = "${VERSION}-${BUILD_NUMBER}"
    IMAGE_NAME = "${PROJECT_NAME}:${BUILD_VERSION}"
}
```

**结果：**
```
VERSION: 1.0.0
BUILD_VERSION: 1.0.0-15
IMAGE_NAME: nms4cloud:1.0.0-15
```

#### 技巧 2：使用 Git Commit SHA

```groovy
environment {
    GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    IMAGE_TAG = "${BUILD_NUMBER}-${GIT_COMMIT_SHORT}"
}
```

**结果：**
```
GIT_COMMIT_SHORT: a1b2c3d
IMAGE_TAG: 15-a1b2c3d
```

#### 技巧 3：打印所有环境变量

```groovy
stage('调试') {
    steps {
        sh 'env | sort'
    }
}
```

**输出：**
```
BUILD_ID=15
BUILD_NUMBER=15
BUILD_TAG=jenkins-nms4cloud-build-15
GIT_BRANCH=origin/master
GIT_COMMIT=a1b2c3d4e5f6...
JENKINS_HOME=/var/jenkins_home
JOB_NAME=nms4cloud-build
WORKSPACE=/var/jenkins_home/workspace/nms4cloud-build
...
```
