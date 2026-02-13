# deleteDir() 和 checkoutRepo() 快速参考

## deleteDir() - 清理工作空间

### 作用
删除工作空间的所有内容，确保每次构建都是干净的环境。

### 使用
```groovy
stage('代码检出') {
    steps {
        script {
            deleteDir()  // 清理旧文件
            checkout(...)  // 检出新代码
        }
    }
}
```

### 效果
```
执行前：/workspace/nms4cloud-build/
       ├── target/old.jar
       ├── .git/
       └── src/

执行后：/workspace/nms4cloud-build/
       (空目录)
```

---

## checkoutRepo() - 检出 Git 仓库

### 函数定义
```groovy
def checkoutRepo(String name, String url, String targetDir)
```

### 参数说明
- `name`：仓库名称（用于日志显示）
- `url`：Git 仓库地址
- `targetDir`：目标目录（'.' 表示当前目录）

### 使用示例

**检出主项目（到当前目录）：**
```groovy
checkoutRepo('主项目', 'https://github.com/main.git', '.')
```

**结果：**
```
/workspace/nms4cloud-build/
├── pom.xml
└── src/
```

**检出子模块（到子目录）：**
```groovy
checkoutRepo('WMS 模块', 'https://github.com/wms.git', 'nms4cloud-wms')
```

**结果：**
```
/workspace/nms4cloud-build/
├── pom.xml
└── nms4cloud-wms/
    ├── pom.xml
    └── src/
```

### 关键特性

**1. 浅克隆（Shallow Clone）**
```groovy
depth: 1, shallow: true
```
- 只下载最新提交
- 速度快，占用空间小

**2. 超时控制**
```groovy
timeout: 20
```
- 20 分钟超时自动终止

**3. 凭据认证**
```groovy
credentialsId: "${GIT_CREDENTIAL_ID}"
```
- 使用 Jenkins 配置的凭据

### 完整流程

```
1. 打印日志："=== 检出 WMS 模块 ==="
   ↓
2. 判断目标目录
   - '.' → 当前目录
   - 其他 → 创建子目录
   ↓
3. 执行 Git 克隆
   - 使用凭据登录
   - 浅克隆（depth=1）
   - 检出指定分支
   ↓
4. 完成
```

### 实际应用

**在 Jenkinsfile 中：**
```groovy
stage('代码检出') {
    steps {
        script {
            deleteDir()  // 清理

            // 检出主项目
            checkoutRepo('主项目', REPO_MAIN, '.')

            // 检出 WMS 模块
            if (BUILD_WMS) {
                checkoutRepo('WMS 模块', REPO_WMS, 'nms4cloud-wms')
            }

            // 检出 BI 模块
            if (BUILD_BI) {
                checkoutRepo('BI 模块', REPO_BI, 'nms4cloud-bi')
            }
        }
    }
}
```

**最终目录结构：**
```
/workspace/nms4cloud-build/
├── pom.xml              ← 主项目
├── src/
├── nms4cloud-wms/       ← WMS 模块
│   ├── pom.xml
│   └── src/
└── nms4cloud-bi/        ← BI 模块
    ├── pom.xml
    └── src/
```
