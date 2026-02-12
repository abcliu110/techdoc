# nms4cloud 构建原理详解 - 第二部分

## 六、常用命令解释

### 6.1 Jenkins Pipeline 命令

#### 1. echo

```groovy
echo "这是一条消息"
```

**作用：** 在控制台输出信息

**类比：** 类似于 JavaScript 的 `console.log()` 或 Python 的 `print()`

**使用场景：**
- 显示构建进度
- 输出变量值
- 调试信息

---

#### 2. sh

```groovy
sh 'ls -la'
sh '''
    echo "多行命令"
    pwd
'''
```

**作用：** 执行 Shell 命令

**单引号 vs 三引号：**
- 单引号：单行命令
- 三引号：多行命令

**示例：**
```groovy
sh 'mvn clean install'
sh '''
    cd nms4cloud-bi
    mvn install
'''
```

---

#### 3. dir

```groovy
dir('目录名') {
    // 在该目录中执行的操作
}
```

**作用：** 切换到指定目录执行操作

**工作原理：**
1. 创建目录（如果不存在）
2. 切换到该目录
3. 执行操作
4. 返回上一级目录

**示例：**
```groovy
dir('nms4cloud-bi') {
    sh 'mvn install'
}
```

---

#### 4. deleteDir

```groovy
deleteDir()
```

**作用：** 删除当前目录的所有内容

**使用场景：** 清理工作空间，确保干净的构建环境

---

#### 5. checkout

```groovy
checkout([
    $class: 'GitSCM',
    url: 'https://github.com/user/repo.git',
    branches: [[name: '*/master']]
])
```

**作用：** 从 Git 仓库克隆代码

**参数：**
- `url`：Git 仓库地址
- `branches`：分支名称
- `credentialsId`：凭据 ID

---

#### 6. archiveArtifacts

```groovy
archiveArtifacts artifacts: '**/target/*.jar'
```

**作用：** 归档构建产物

**参数：**
- `artifacts`：文件路径模式
- `fingerprint`：生成文件指纹
- `allowEmptyArchive`：允许空归档

---

### 6.2 Maven 命令

#### 1. mvn install

```bash
mvn install
```

**作用：** 编译、打包、安装到本地仓库

**生命周期：**
```
validate → compile → test → package → verify → install
```

**安装位置：** `~/.m2/repository/`

---

#### 2. mvn clean

```bash
mvn clean
```

**作用：** 删除 target 目录（清理构建产物）

**为什么需要：** 确保干净的构建环境

---

#### 3. mvn -N

```bash
mvn install -N
```

**作用：** 只处理当前项目，不递归构建子模块

**使用场景：** 只安装父 POM

---

#### 4. mvn -pl

```bash
mvn install -pl module-name
```

**作用：** 只构建指定的模块

**示例：**
```bash
mvn install -pl nms4cloud-starter
```

---

#### 5. mvn -am

```bash
mvn install -pl module-name -am
```

**作用：** 同时构建该模块依赖的所有模块

**示例：**
- 如果 starter 依赖 bi-api
- Maven 会先构建 bi-api，再构建 starter

---

#### 6. mvn -DskipTests

```bash
mvn install -DskipTests
```

**作用：** 跳过测试

**为什么需要：** 加快构建速度

---

#### 7. mvn -T

```bash
mvn install -T 2C
```

**作用：** 并行构建

**参数：**
- `2C`：使用 2 倍 CPU 核心数的线程
- `4`：使用 4 个线程

---

### 6.3 Shell 命令

#### 1. cd

```bash
cd 目录名
```

**作用：** 切换目录

**示例：**
```bash
cd nms4cloud-bi
```

---

#### 2. ls

```bash
ls -la
```

**作用：** 列出文件

**参数：**
- `-l`：详细信息
- `-a`：包括隐藏文件

---

#### 3. pwd

```bash
pwd
```

**作用：** 显示当前目录路径

**示例输出：**
```
/var/jenkins_home/workspace/nms4cloud-build
```

---

#### 4. if 语句

```bash
if [ -d "目录名" ]; then
    echo "目录存在"
else
    echo "目录不存在"
fi
```

**作用：** 条件判断

**测试选项：**
- `[ -d "路径" ]`：检查目录是否存在
- `[ -f "路径" ]`：检查文件是否存在
- `[ -z "$变量" ]`：检查变量是否为空

---

## 七、问题排查

### 7.1 找不到 nms4cloud-bi 目录

**错误信息：**
```
错误：找不到 nms4cloud-bi 目录
```

**原因：**
- bi 模块没有被克隆
- 代码检出阶段失败

**解决方法：**
1. 检查 Jenkins 日志中的"代码检出"阶段
2. 确认是否有"检出 bi 模块"的日志
3. 检查 bi 仓库地址是否正确
4. 检查凭据是否有效

---

### 7.2 找不到父 POM

**错误信息：**
```
[ERROR] Non-resolvable parent POM for com.nms4cloud:nms4cloud-bi:0.0.1-SNAPSHOT:
Could not find artifact com.nms4cloud:nms4cloud:pom:0.0.1-SNAPSHOT
```

**原因：**
- 父 POM 未安装到本地仓库
- relativePath 配置错误

**解决方法：**
```bash
# 先安装父 POM
mvn install -N
```

---

### 7.3 找不到 bi-api 依赖

**错误信息：**
```
[ERROR] Could not find artifact com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT
```

**原因：**
- bi-api 未构建和安装到本地仓库

**解决方法：**
```bash
# 先构建 bi 模块
cd nms4cloud-bi
mvn clean install -DskipTests
```

---

### 7.4 Jenkins 使用旧的 Jenkinsfile

**现象：**
- 修改了 Jenkinsfile，但构建时没有生效

**原因：**
- Jenkins 任务配置是"Pipeline script"（直接粘贴）
- 需要手动更新

**解决方法：**
1. 进入 Jenkins 任务配置页面
2. 找到 Pipeline 配置部分
3. 粘贴新的 Jenkinsfile 内容
4. 保存并重新运行

---

### 7.5 Git 凭据认证失败

**错误信息：**
```
[ERROR] Error cloning remote repo 'origin'
Authentication failed
```

**原因：**
- 凭据配置错误
- 令牌过期

**解决方法：**
1. 检查凭据 ID 是否正确
2. 检查用户名和令牌是否正确
3. 重新创建凭据

---

## 八、最佳实践

### 8.1 构建顺序

✅ **推荐：** 按照 3 步流程构建

```
1. 安装父 POM
2. 构建 bi 模块
3. 构建其他模块
```

❌ **不推荐：** 直接构建所有模块

```
mvn clean install  # 会失败，因为 bi 模块没有在父 pom 中声明
```

---

### 8.2 参数使用

✅ **推荐：**
- 使用 `-DskipTests` 跳过测试（加快构建）
- 使用 `-T 2C` 并行构建（提高效率）
- 使用 `-am` 自动构建依赖

❌ **不推荐：**
- 不使用 `-N` 就想只构建父 POM
- 不使用 `-pl` 就想只构建某个模块

---

### 8.3 日志查看

✅ **推荐：**
- 查看完整的构建日志
- 关注每个阶段的输出
- 查找错误信息

❌ **不推荐：**
- 只看最后的结果
- 忽略警告信息

---

### 8.4 安全注意事项

✅ **推荐：**
- 只使用 `mvn install`
- 不要使用 `mvn deploy`
- 定期检查构建日志

❌ **不推荐：**
- 使用 `mvn deploy`（会上传到远程仓库）
- 忽略安全警告

---

## 九、总结

### 9.1 核心概念

1. **Jenkins Pipeline**：自动化构建流程
2. **Maven**：Java 项目构建工具
3. **Git**：版本控制系统
4. **Jenkinsfile**：定义 Pipeline 的文件

### 9.2 构建流程

```
环境检查 → 代码检出 → Maven构建 → 单元测试 → 归档产物
```

### 9.3 关键命令

**Jenkins：**
- `echo`：输出信息
- `sh`：执行 Shell 命令
- `dir`：切换目录
- `checkout`：克隆代码

**Maven：**
- `mvn install`：编译、打包、安装
- `mvn -N`：只处理当前项目
- `mvn -pl`：只构建指定模块
- `mvn -am`：同时构建依赖

### 9.4 为什么需要分步构建？

1. bi 模块在独立的 Git 仓库
2. 父 pom 没有声明 bi 模块
3. 其他模块依赖 bi-api

**解决方案：**
1. 先安装父 POM
2. 再构建 bi 模块
3. 最后构建其他模块

---

## 十、快速参考

### 10.1 常用命令速查

| 命令 | 作用 |
|------|------|
| `mvn install` | 编译、打包、安装 |
| `mvn install -N` | 只安装父 POM |
| `mvn clean install` | 清理后构建 |
| `mvn install -DskipTests` | 跳过测试 |
| `mvn install -pl module -am` | 构建指定模块及依赖 |
| `mvn install -T 2C` | 并行构建 |

### 10.2 Jenkins Pipeline 速查

| 命令 | 作用 |
|------|------|
| `echo "message"` | 输出信息 |
| `sh 'command'` | 执行 Shell 命令 |
| `dir('path') { }` | 在指定目录执行 |
| `deleteDir()` | 删除当前目录内容 |
| `checkout([...])` | 克隆 Git 代码 |
| `archiveArtifacts` | 归档构建产物 |

### 10.3 Shell 命令速查

| 命令 | 作用 |
|------|------|
| `cd 目录` | 切换目录 |
| `ls -la` | 列出文件 |
| `pwd` | 显示当前目录 |
| `[ -d "路径" ]` | 检查目录是否存在 |
| `[ -f "路径" ]` | 检查文件是否存在 |

---

## 相关文档

- [Maven多模块项目构建原理.md](./Maven多模块项目构建原理.md)
- [Jenkins工作原理.md](./Jenkins工作原理.md)
- [Jenkins创建Pipeline任务指南.md](./Jenkins创建Pipeline任务指南.md)
- [Jenkins构建nms4cloud项目详解.md](./Jenkins构建nms4cloud项目详解.md)
