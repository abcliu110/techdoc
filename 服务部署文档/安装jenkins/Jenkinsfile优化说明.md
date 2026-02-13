# Jenkinsfile 优化说明文档

## 一、主要改进

### 1.1 添加 WMS 支持

**新增配置：**
```groovy
REPO_WMS = 'git@codeup.aliyun.com:613895a803e1c17d57a7630f/nms4cloud-pos-java/nms4cloud-wms.git'
BUILD_WMS = true
```

**构建顺序：**
```
1. 安装父 POM
   ↓
2. 构建 WMS-API（bi-dao 的依赖）
   ↓
3. 构建完整的 BI 模块（包括 bi-dao、bi-service、bi-app）
   ↓
4. 构建主项目（nms4cloud-starter、nms4cloud-app）
```

### 1.2 代码重构和简化

**优化前：**
- 重复的代码检出逻辑
- 冗长的构建命令
- 难以维护的内联脚本

**优化后：**
- 提取公共函数（checkoutRepo、buildModule、buildStep）
- 清晰的构建流程
- 易于扩展和维护

### 1.3 更清晰的结构

```groovy
// ==================== 环境变量配置 ====================
// ==================== 参数化构建 ====================
// ==================== 构建选项 ====================
// ==================== 触发器 ====================
// ==================== 构建阶段 ====================
// ==================== 构建后处理 ====================
// ==================== 辅助函数 ====================
```

---

## 二、关键改进点

### 2.1 仓库地址统一管理

**优化前：**
```groovy
GIT_REPO_URL = 'https://...'
GIT_BI_REPO_URL = 'https://...'
```

**优化后：**
```groovy
REPO_MAIN = 'https://codeup.aliyun.com/.../nms4cloud.git'
REPO_BI = 'https://codeup.aliyun.com/.../nms4cloud-bi.git'
REPO_WMS = 'https://codeup.aliyun.com/.../nms4cloud-wms.git'
```

### 2.2 代码检出逻辑封装

**优化前：**
```groovy
// 重复的 checkout 代码块（50+ 行）
checkout([
    $class: 'GitSCM',
    branches: [[name: "*/${GIT_BRANCH}"]],
    // ... 大量重复配置
])
```

**优化后：**
```groovy
// 一行调用
checkoutRepo('主项目', REPO_MAIN, '.')
checkoutRepo('WMS 模块', REPO_WMS, 'nms4cloud-wms')
checkoutRepo('BI 模块', REPO_BI, 'nms4cloud-bi')
```

### 2.3 构建逻辑封装

**优化前：**
```groovy
sh """
    if [ -d "nms4cloud-bi" ]; then
        cd nms4cloud-bi
        mvn clean install -pl bi-api -am -DskipTests
        cd ..
    fi
"""
```

**优化后：**
```groovy
buildModule('BI 模块', 'nms4cloud-bi', '', cleanCmd, skipTests)
```

---

## 三、使用说明

### 3.1 文件位置

**优化后的文件：**
```
F:\python资料\服务部署文档\安装jenkins\Jenkinsfile-nms4cloud-optimized
```

**使用方式：**
1. 将文件重命名为 `Jenkinsfile`
2. 放到项目根目录
3. 在 Jenkins 中创建 Pipeline 任务
4. 指向你的 Git 仓库

### 3.2 配置说明

**必须配置的凭据：**
```
Jenkins → 凭据 → 添加凭据
- ID: aliyun-codeup-token
- 类型: Username with password
- 用户名: 你的阿里云效用户名
- 密码: 你的阿里云效密码或访问令牌
```

### 3.3 构建开关

**控制是否构建 WMS 和 BI：**
```groovy
BUILD_BI = true   // 设置为 false 跳过 BI 模块
BUILD_WMS = true  // 设置为 false 跳过 WMS 模块
```

---

## 四、构建流程详解

### 4.1 完整构建流程

```
┌─────────────────────────────────────────┐
│ 1. 环境检查                              │
│    - 检查 Java、Maven、Git 版本          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 2. 代码检出                              │
│    - 检出主项目（nms4cloud）             │
│    - 检出 WMS 模块（nms4cloud-wms）      │
│    - 检出 BI 模块（nms4cloud-bi）        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 3. Maven 构建                            │
│    ① 安装父 POM                          │
│    ② 构建 WMS-API                        │
│    ③ 构建完整的 BI 模块                  │
│    ④ 构建主项目                          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 4. 单元测试（可选）                      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 5. 归档构建产物                          │
│    - 归档所有 jar 包                     │
│    - 归档 pom.xml                        │
└─────────────────────────────────────────┘
```

### 4.2 依赖关系

```
父 POM
  ↓
WMS-API ← bi-dao 依赖
  ↓
BI 模块（完整）
  ├── bi-api
  ├── bi-dao
  ├── bi-service
  └── bi-app
  ↓
主项目
  ├── nms4cloud-starter
  └── nms4cloud-app
```

---

## 五、辅助函数说明

### 5.1 checkoutRepo()

**功能：** 检出 Git 仓库

**参数：**
- `name`: 仓库名称（用于日志）
- `url`: Git 仓库地址
- `dir`: 目标目录（'.' 表示当前目录）

**示例：**
```groovy
checkoutRepo('主项目', REPO_MAIN, '.')
checkoutRepo('WMS 模块', REPO_WMS, 'nms4cloud-wms')
```

### 5.2 buildModule()

**功能：** 构建 Maven 模块

**参数：**
- `moduleName`: 模块名称（用于日志）
- `moduleDir`: 模块目录
- `subModule`: 子模块名称（为空则构建整个模块）
- `cleanCmd`: clean 命令
- `skipTests`: 跳过测试参数

**示例：**
```groovy
// 只构建 wms-api 子模块
buildModule('WMS-API', 'nms4cloud-wms', 'wms-api', 'clean', '-DskipTests')

// 构建完整的 bi 模块
buildModule('BI 模块', 'nms4cloud-bi', '', 'clean', '-DskipTests')
```

### 5.3 buildStep()

**功能：** 执行构建步骤

**参数：**
- `stepName`: 步骤名称
- `command`: 执行命令

**示例：**
```groovy
buildStep('安装父 POM', """
    mvn install -N -DskipTests
""")
```

### 5.4 buildMainProject()

**功能：** 构建主项目

**参数：**
- `buildModule`: 构建模块选择（all/nms4cloud-starter/nms4cloud-app）
- `cleanCmd`: clean 命令
- `skipTests`: 跳过测试参数
- `mvnOpts`: Maven 选项

---

## 六、常见问题

### 6.1 配置阿里云效凭据

**使用 HTTPS 地址，配置用户名密码：**

```bash
# 在 Jenkins 中添加凭据
Jenkins → 凭据 → 添加凭据
- 类型: Username with password
- ID: aliyun-codeup-token
- 用户名: 你的阿里云效用户名
- 密码: 你的阿里云效密码或访问令牌
```

**获取访问令牌（推荐）：**
```
1. 登录阿里云效
2. 个人设置 → 访问令牌
3. 新建令牌
4. 复制令牌作为密码使用
```

### 6.2 如何跳过某个模块

**跳过 WMS 模块：**
```groovy
BUILD_WMS = false
```

**跳过 BI 模块：**
```groovy
BUILD_BI = false
```

### 6.3 如何只构建某个子模块

**修改 buildModule 调用：**
```groovy
// 只构建 bi-api
buildModule('BI-API', 'nms4cloud-bi', 'bi-api', cleanCmd, skipTests)

// 只构建 wms-api
buildModule('WMS-API', 'nms4cloud-wms', 'wms-api', cleanCmd, skipTests)
```

---

## 七、对比总结

### 7.1 代码行数对比

| 项目 | 优化前 | 优化后 | 减少 |
|------|--------|--------|------|
| 总行数 | 327 | 280 | 14% |
| 重复代码 | 多 | 少 | - |
| 可读性 | 中 | 高 | - |

### 7.2 主要优势

**优化前：**
- ❌ 重复代码多
- ❌ 难以维护
- ❌ 不支持 WMS

**优化后：**
- ✅ 代码简洁
- ✅ 易于维护
- ✅ 支持 WMS
- ✅ 函数化封装
- ✅ 清晰的结构

---

## 八、快速开始

### 8.1 第一次使用

```bash
# 1. 复制优化后的 Jenkinsfile
cp Jenkinsfile-nms4cloud-optimized Jenkinsfile

# 2. 提交到 Git
git add Jenkinsfile
git commit -m "优化 Jenkinsfile，添加 WMS 支持"
git push

# 3. 在 Jenkins 中创建 Pipeline 任务
# 4. 配置 Git 仓库和凭据
# 5. 运行构建
```

### 8.2 验证构建

**查看构建日志：**
```
=== 检出 主项目 ===
=== 检出 WMS 模块 ===
=== 检出 BI 模块 ===
✓ WMS 模块已检出
✓ BI 模块已检出

>>> 安装父 POM
>>> 构建 WMS-API
>>> 构建 BI 模块
>>> 构建主项目

╔════════════════════════════════════════╗
║         ✓ 构建成功                      ║
╚════════════════════════════════════════╝
```

---

## 九、下一步优化建议

### 9.1 添加 Docker 镜像构建

```groovy
stage('构建 Docker 镜像') {
    steps {
        script {
            // 使用 Kaniko 构建镜像
        }
    }
}
```

### 9.2 添加部署阶段

```groovy
stage('部署到 K8s') {
    steps {
        script {
            // 使用 kubectl 部署
        }
    }
}
```

### 9.3 添加通知

```groovy
post {
    success {
        // 发送钉钉/企业微信通知
    }
    failure {
        // 发送失败通知
    }
}
```

---

## 十、总结

**优化后的 Jenkinsfile 特点：**

1. ✅ 支持 WMS、BI、主项目的完整构建
2. ✅ 代码简洁，易于维护
3. ✅ 函数化封装，可复用
4. ✅ 清晰的构建流程
5. ✅ 完善的错误处理
6. ✅ 灵活的构建开关

**立即使用：**
```
F:\python资料\服务部署文档\安装jenkins\Jenkinsfile-nms4cloud-optimized
```
