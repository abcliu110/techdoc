# nms4cloud 构建原理详解（从零开始）

## 概述

本文档从零开始，详细讲解 nms4cloud 项目在 Jenkins 中的构建原理，包括每个命令的作用、为什么需要这样设计，以及 Jenkins Pipeline 的基础知识。

**适合人群：** 不熟悉 Jenkins 和 Maven 的开发者

---

## 目录

1. [基础概念](#一基础概念)
2. [项目结构分析](#二项目结构分析)
3. [Jenkins Pipeline 基础](#三jenkins-pipeline-基础)
4. [完整构建流程](#四完整构建流程)
5. [每个阶段详解](#五每个阶段详解)
6. [常用命令解释](#六常用命令解释)
7. [问题排查](#七问题排查)

---

## 一、基础概念

### 1.1 什么是 Jenkins？

**Jenkins** 是一个自动化服务器，用于：
- 自动拉取代码
- 自动编译代码
- 自动运行测试
- 自动部署应用

**类比：** Jenkins 就像一个机器人助手，你告诉它要做什么，它就自动帮你完成。

### 1.2 什么是 Jenkins Pipeline？

**Pipeline（流水线）** 是 Jenkins 中定义自动化流程的方式。

**类比：** 就像工厂的生产线，原材料（代码）经过多个工序（阶段），最终生产出产品（可运行的程序）。

```
代码 → 拉取 → 编译 → 测试 → 打包 → 部署
```

### 1.3 什么是 Jenkinsfile？

**Jenkinsfile** 是一个文本文件，用代码的方式描述 Pipeline 的流程。

**类比：** 就像菜谱，告诉机器人（Jenkins）按照什么步骤做菜（构建项目）。

### 1.4 什么是 Maven？

**Maven** 是 Java 项目的构建工具，用于：
- 管理项目依赖（需要哪些第三方库）
- 编译 Java 代码
- 运行测试
- 打包成 jar 文件

**类比：** Maven 就像一个项目管理器，帮你组织和构建 Java 项目。

### 1.5 什么是 Git？

**Git** 是版本控制系统，用于：
- 保存代码的历史版本
- 多人协作开发
- 管理代码分支

**类比：** Git 就像一个时光机，可以回到代码的任何历史版本。

---

## 二、项目结构分析

### 2.1 nms4cloud 项目结构

```
nms4cloud/                          (主项目，在一个Git仓库)
├── pom.xml                         (父项目配置文件)
├── nms4cloud-app/                  (子模块1)
│   └── pom.xml
├── nms4cloud-starter/              (子模块2)
│   └── pom.xml
└── nms4cloud-bi/                   (子模块3，在另一个Git仓库)
    ├── pom.xml
    ├── nms4cloud-bi-api/           (bi的子模块)
    ├── nms4cloud-bi-dao/
    ├── nms4cloud-bi-service/
    └── nms4cloud-bi-app/
```

### 2.2 关键问题

**问题1：** `nms4cloud-bi` 在独立的 Git 仓库中
- 主项目仓库：`https://codeup.aliyun.com/.../nms4cloud.git`
- bi模块仓库：`https://codeup.aliyun.com/.../nms4cloud-bi.git`

**问题2：** 父项目的 pom.xml 中没有声明 `nms4cloud-bi` 模块

```xml
<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <!-- 缺少 nms4cloud-bi -->
</modules>
```

**问题3：** 其他模块依赖 `nms4cloud-bi-api`

```xml
<dependency>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud-bi-api</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

**结论：** 需要特殊的构建流程来解决这些问题。

---

## 三、Jenkins Pipeline 基础

### 3.1 Pipeline 的基本结构

```groovy
pipeline {                          // Pipeline 的开始
    agent any                       // 在任意可用的机器上运行

    environment {                   // 环境变量
        MAVEN_HOME = tool 'Maven'
    }

    stages {                        // 所有阶段
        stage('阶段1') {            // 第一个阶段
            steps {                 // 这个阶段的步骤
                echo '执行阶段1'
            }
        }

        stage('阶段2') {            // 第二个阶段
            steps {
                echo '执行阶段2'
            }
        }
    }
}
```

### 3.2 常用的 Pipeline 指令

#### agent

```groovy
agent any
```

**作用：** 指定在哪台机器上运行
- `any`：任意可用的机器
- `label 'linux'`：标签为 linux 的机器

#### environment

```groovy
environment {
    MAVEN_HOME = tool 'Maven'
    PATH = "${MAVEN_HOME}/bin:${env.PATH}"
}
```

**作用：** 设置环境变量
- `MAVEN_HOME`：Maven 的安装路径
- `PATH`：添加 Maven 到系统路径

#### parameters

```groovy
parameters {
    choice(
        name: 'BUILD_MODULE',
        choices: ['all', 'starter', 'app'],
        description: '选择构建模块'
    )
}
```

**作用：** 定义构建参数，用户可以在运行时选择

#### stages 和 stage

```groovy
stages {
    stage('代码检出') {
        steps {
            // 拉取代码
        }
    }

    stage('Maven构建') {
        steps {
            // 编译代码
        }
    }
}
```

**作用：** 定义构建的各个阶段

#### steps

```groovy
steps {
    echo '这是一条消息'
    sh 'ls -la'
}
```

**作用：** 定义这个阶段要执行的具体步骤

#### script

```groovy
script {
    def message = "Hello"
    echo message
}
```

**作用：** 在 steps 中执行 Groovy 脚本（更灵活的编程）

#### sh

```groovy
sh 'mvn clean install'
```

**作用：** 执行 Shell 命令（Linux/Unix 命令）

#### dir

```groovy
dir('nms4cloud-bi') {
    sh 'mvn install'
}
```

**作用：** 切换到指定目录，执行命令后返回

#### checkout

```groovy
checkout([
    $class: 'GitSCM',
    url: 'https://github.com/user/repo.git'
])
```

**作用：** 从 Git 仓库拉取代码

---

## 四、完整构建流程

### 4.1 流程图

```
┌─────────────────────────────────────────────────────────┐
│ 1. 环境检查                                              │
│    - 检查 Java 版本                                      │
│    - 检查 Maven 版本                                     │
│    - 检查 Git 版本                                       │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 2. 代码检出                                              │
│    - 清理工作空间                                        │
│    - 克隆主项目 (nms4cloud)                              │
│    - 克隆 bi 模块 (nms4cloud-bi)                         │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Maven构建                                            │
│    步骤1：安装父POM                                      │
│    步骤2：构建 bi 模块                                   │
│    步骤3：构建其他模块                                   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 4. 单元测试（可选）                                      │
│    - 运行测试                                            │
│    - 生成测试报告                                        │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 5. 归档构建产物                                          │
│    - 保存 jar 文件                                       │
│    - 保存 pom 文件                                       │
└─────────────────────────────────────────────────────────┘
                        ↓
                  ✅ 构建完成
```

### 4.2 为什么需要这样的流程？

**问题：** 为什么不能直接 `mvn clean install` 一次性构建？

**原因：**
1. bi 模块在独立的 Git 仓库，需要单独克隆
2. 父 pom 没有声明 bi 模块，需要单独构建
3. 其他模块依赖 bi-api，必须先构建 bi 模块

**解决方案：** 分步构建
1. 先安装父 pom（确保子模块能找到父 pom）
2. 再构建 bi 模块（安装 bi-api 到本地仓库）
3. 最后构建其他模块（现在能找到 bi-api 依赖了）

---


## 五、每个阶段详解

### 5.1 环境检查阶段

#### 代码

```groovy
stage('环境检查') {
    steps {
        script {
            // 设置构建显示名称
            currentBuild.displayName = "#${BUILD_NUMBER} - ${params.BUILD_MODULE}"
            currentBuild.description = "分支: ${GIT_BRANCH}"

            echo "=== 环境信息 ==="
            echo "Jenkins版本: ${env.JENKINS_VERSION}"
            echo "构建编号: ${env.BUILD_NUMBER}"
            echo "工作空间: ${env.WORKSPACE}"
            echo "构建模块: ${params.BUILD_MODULE}"

            sh '''
                echo "Java版本:"
                java -version
                echo ""
                echo "Maven版本:"
                mvn -version
                echo ""
                echo "Git版本:"
                git --version
            '''
        }
    }
}
```

#### 命令详解

**1. currentBuild.displayName**

```groovy
currentBuild.displayName = "#${BUILD_NUMBER} - ${params.BUILD_MODULE}"
```

**作用：** 设置构建的显示名称
- `BUILD_NUMBER`：构建编号（如 #1, #2, #3）
- `params.BUILD_MODULE`：用户选择的构建模块

**示例：** `#5 - all` 表示第5次构建，构建所有模块

**为什么需要：** 在 Jenkins 界面上更容易识别每次构建

