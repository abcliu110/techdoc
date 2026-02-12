# Jenkins 构建 nms4cloud 项目详解

## 概述

本文档详细说明如何在 Jenkins 中构建 nms4cloud 多模块项目，包括父POM构建、bi模块构建以及其他模块的构建流程。

---

## 一、项目结构分析

### 1. 父项目 pom.xml 配置

```xml
<groupId>com.nms4cloud</groupId>
<artifactId>nms4cloud</artifactId>
<version>0.0.1-SNAPSHOT</version>
<packaging>pom</packaging>

<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <!-- ⚠️ 注意：缺少 nms4cloud-bi 模块声明 -->
</modules>
```

### 2. 项目依赖关系

```
nms4cloud (父项目)
├── nms4cloud-starter
├── nms4cloud-app
└── nms4cloud-bi (未在父pom中声明)
    ├── nms4cloud-bi-api
    ├── nms4cloud-bi-dao
    ├── nms4cloud-bi-service
    └── nms4cloud-bi-app

其他模块：
└── nms4cloud-order-service (依赖 nms4cloud-bi-api)
```

### 3. 核心问题

**问题：** `nms4cloud-bi` 模块没有在父pom的 `<modules>` 中声明

**影响：**
- 执行 `mvn clean install` 时不会构建 `nms4cloud-bi` 模块
- `nms4cloud-bi-api` 不会被安装到本地仓库
- 其他模块依赖 `nms4cloud-bi-api` 时找不到，构建失败

**错误信息：**
```
[ERROR] Failed to execute goal on project nms4cloud-order-service:
Could not resolve dependencies for project com.nms4cloud:nms4cloud-order-service:jar:0.0.1-SNAPSHOT
[ERROR] dependency: com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT (compile)
[ERROR] Could not find artifact com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT
```

---

## 二、Jenkins 构建流程

### 完整的 3 步构建流程

```groovy
stage('Maven构建') {
    steps {
        script {
            echo "=== Maven构建 ==="

            def cleanCmd = params.CLEAN_BUILD ? 'clean' : ''
            def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''

            // 步骤1：先安装父POM到本地仓库
            echo "步骤1：安装父POM..."
            sh """
                mvn install -N ${skipTests}
            """

            // 步骤2：构建 bi 模块
            echo "步骤2：构建 bi 模块..."
            sh """
                mvn ${cleanCmd} install -pl nms4cloud-bi -am ${skipTests} -T 2C
            """

            // 步骤3：根据选择的模块构建
            echo "步骤3：构建指定模块..."
            def buildModule = ''

            switch(params.BUILD_MODULE) {
                case 'nms4cloud-starter':
                    buildModule = '-pl nms4cloud-starter -am'
                    break
                case 'nms4cloud-app':
                    buildModule = '-pl nms4cloud-app -am'
                    break
                case 'all':
                    buildModule = ''
                    break
                default:
                    buildModule = ''
            }

            if (buildModule) {
                sh """
                    mvn ${cleanCmd} install ${buildModule} ${skipTests} \
                    -Dmaven.compile.fork=true \
                    -T 2C
                """
            } else {
                sh """
                    mvn ${cleanCmd} install ${skipTests} \
                    -Dmaven.compile.fork=true \
                    -T 2C
                """
            }
        }
    }
}
```

---

## 三、步骤详解

### 步骤1：构建父POM

#### 命令

```bash
mvn install -N -DskipTests
```

#### 参数说明

| 参数 | 说明 |
|------|------|
| `install` | 将pom文件安装到本地Maven仓库 |
| `-N` (--non-recursive) | 只处理当前项目，不递归构建子模块 |
| `-DskipTests` | 跳过测试 |

#### 执行过程

```
1. Maven读取父项目的 pom.xml
   ↓
2. 验证pom文件的有效性
   ↓
3. 将父pom安装到本地仓库：
   ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom
   ↓
4. 不会构建任何子模块（因为 -N 参数）
   ↓
5. 不会生成jar包（因为 packaging=pom）
```

#### 生成结果

```
~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/
├── nms4cloud-0.0.1-SNAPSHOT.pom          ← 父pom文件的副本
├── maven-metadata-local.xml               ← 元数据信息
└── _remote.repositories                   ← 来源信息
```

#### 为什么需要这一步？

✅ **确保子模块能从本地仓库找到父pom**
- 即使子模块的 `relativePath` 配置错误，也能正常构建
- 提高构建的可靠性

✅ **双保险机制**
- Maven查找父pom的顺序：relativePath → 本地仓库 → 远程仓库
- 先安装父pom，确保本地仓库有备份

✅ **执行速度快**
- 只需要几秒钟
- 不影响总构建时间

#### 控制台输出示例

```
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------< com.nms4cloud:nms4cloud >-------------------
[INFO] Building nms4cloud 0.0.1-SNAPSHOT
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]
[INFO] --- maven-install-plugin:3.1.1:install (default-install) @ nms4cloud ---
[INFO] Installing /path/to/nms4cloud/pom.xml to ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.521 s
```

---

### 步骤2：构建 bi 模块

#### 命令

```bash
mvn clean install -pl nms4cloud-bi -am -DskipTests -T 2C
```

#### 参数说明

| 参数 | 说明 |
|------|------|
| `clean` | 清理之前的构建产物（如果 CLEAN_BUILD=true） |
| `install` | 编译、打包、安装到本地仓库 |
| `-pl nms4cloud-bi` (--projects) | 只构建指定的模块 |
| `-am` (--also-make) | 同时构建该模块依赖的所有模块 |
| `-DskipTests` | 跳过测试 |
| `-T 2C` | 使用2倍CPU核心数并行构建 |

#### 执行过程

```
1. Maven分析 nms4cloud-bi 的依赖关系
   ↓
2. 确定构建顺序（Reactor Build Order）
   ↓
3. 按顺序构建 nms4cloud-bi 及其所有子模块：
   - nms4cloud-bi (父pom)
   - nms4cloud-bi-api      ← 重要！其他模块依赖这个
   - nms4cloud-bi-dao
   - nms4cloud-bi-service
   - nms4cloud-bi-app
   ↓
4. 对每个子模块：
   - 编译Java代码
   - 运行测试（如果没有 -DskipTests）
   - 打包成jar文件
   - 安装到本地仓库
   ↓
5. 并行构建独立的模块（-T 2C）
```

#### 生成结果

```
~/.m2/repository/com/nms4cloud/
├── nms4cloud-bi/
│   └── 0.0.1-SNAPSHOT/
│       └── nms4cloud-bi-0.0.1-SNAPSHOT.pom
├── nms4cloud-bi-api/
│   └── 0.0.1-SNAPSHOT/
│       ├── nms4cloud-bi-api-0.0.1-SNAPSHOT.jar  ← 重要！
│       └── nms4cloud-bi-api-0.0.1-SNAPSHOT.pom
├── nms4cloud-bi-dao/
│   └── 0.0.1-SNAPSHOT/
│       ├── nms4cloud-bi-dao-0.0.1-SNAPSHOT.jar
│       └── nms4cloud-bi-dao-0.0.1-SNAPSHOT.pom
├── nms4cloud-bi-service/
│   └── 0.0.1-SNAPSHOT/
│       ├── nms4cloud-bi-service-0.0.1-SNAPSHOT.jar
│       └── nms4cloud-bi-service-0.0.1-SNAPSHOT.pom
└── nms4cloud-bi-app/
    └── 0.0.1-SNAPSHOT/
        ├── nms4cloud-bi-app-0.0.1-SNAPSHOT.jar
        └── nms4cloud-bi-app-0.0.1-SNAPSHOT.pom
```

#### 为什么需要这一步？

✅ **解决核心依赖问题**
- `nms4cloud-bi` 没有在父pom的 `<modules>` 中声明
- 如果不单独构建，`nms4cloud-bi-api` 不会被安装到本地仓库
- 其他模块（如 `nms4cloud-order-service`）依赖 `bi-api` 时就能找到了

✅ **确保依赖可用**
- 将 `nms4cloud-bi-api` 安装到本地仓库
- 后续构建的模块可以正常引用这个依赖

#### 控制台输出示例

```
[INFO] Scanning for projects...
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Build Order:
[INFO]
[INFO] nms4cloud-bi                                                       [pom]
[INFO] nms4cloud-bi-api                                                   [jar]
[INFO] nms4cloud-bi-dao                                                   [jar]
[INFO] nms4cloud-bi-service                                               [jar]
[INFO] nms4cloud-bi-app                                                   [jar]
[INFO]
[INFO] ------------------< com.nms4cloud:nms4cloud-bi >-------------------
[INFO] Building nms4cloud-bi 0.0.1-SNAPSHOT                          [1/5]
[INFO] --------------------------------[ pom ]---------------------------------
[INFO]
[INFO] ------------------< com.nms4cloud:nms4cloud-bi-api >---------------
[INFO] Building nms4cloud-bi-api 0.0.1-SNAPSHOT                      [2/5]
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] Compiling 25 source files to /path/to/target/classes
[INFO] Building jar: /path/to/nms4cloud-bi-api-0.0.1-SNAPSHOT.jar
[INFO] Installing /path/to/nms4cloud-bi-api-0.0.1-SNAPSHOT.jar to ~/.m2/repository/...
[INFO]
[INFO] ... (其他模块构建日志)
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 2:15 min
```

---

### 步骤3：构建其他模块

#### 命令（根据参数选择）

**情况1：BUILD_MODULE = 'nms4cloud-starter'**
```bash
mvn clean install -pl nms4cloud-starter -am -DskipTests -T 2C
```
- 只构建 `nms4cloud-starter` 及其依赖

**情况2：BUILD_MODULE = 'nms4cloud-app'**
```bash
mvn clean install -pl nms4cloud-app -am -DskipTests -T 2C
```
- 只构建 `nms4cloud-app` 及其依赖

**情况3：BUILD_MODULE = 'all'**
```bash
mvn clean install -DskipTests -T 2C
```
- 构建所有剩余模块（包括 starter、app、order-service 等）

#### 执行过程

```
1. Maven分析所有模块的依赖关系
   ↓
2. 确定构建顺序（Reactor Build Order）
   ↓
3. 按顺序构建模块：
   - nms4cloud-starter
   - nms4cloud-app
   - nms4cloud-order-service (现在能找到 bi-api 依赖了)
   - 其他模块...
   ↓
4. 对每个模块：
   - 编译Java代码
   - 运行测试（如果没有 -DskipTests）
   - 打包成jar文件
   - 安装到本地仓库
   ↓
5. 并行构建独立的模块（-T 2C）
```

#### 为什么现在能成功构建？

✅ **依赖已经就绪**
- 步骤2已经将 `nms4cloud-bi-api` 安装到本地仓库
- `nms4cloud-order-service` 依赖 `bi-api` 时能从本地仓库找到

✅ **构建顺序正确**
- Maven自动分析依赖关系
- 先构建被依赖的模块，再构建依赖它的模块

---

## 四、完整构建流程图

```
┌─────────────────────────────────────────────────────────┐
│ 步骤1：构建父POM                                         │
│ mvn install -N                                          │
│                                                         │
│ 执行时间：约 5 秒                                        │
│                                                         │
│ 结果：父pom安装到本地仓库                                │
│ ~/.m2/repository/com/nms4cloud/nms4cloud/...           │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 步骤2：构建 bi 模块                                      │
│ mvn clean install -pl nms4cloud-bi -am                 │
│                                                         │
│ 执行时间：约 1-3 分钟                                    │
│                                                         │
│ 构建顺序：                                               │
│ 1. nms4cloud-bi (父pom)                                │
│ 2. nms4cloud-bi-api ← 重要！其他模块依赖这个             │
│ 3. nms4cloud-bi-dao                                    │
│ 4. nms4cloud-bi-service                                │
│ 5. nms4cloud-bi-app                                    │
│                                                         │
│ 结果：所有bi模块的jar安装到本地仓库                       │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ 步骤3：构建其他模块                                      │
│ mvn clean install (根据参数选择)                        │
│                                                         │
│ 执行时间：约 2-5 分钟                                    │
│                                                         │
│ 现在可以成功构建：                                       │
│ - nms4cloud-starter                                    │
│ - nms4cloud-app                                        │
│ - nms4cloud-order-service (依赖bi-api，现在能找到了)    │
│ - 其他所有模块...                                       │
│                                                         │
│ 结果：所有模块构建完成                                   │
└─────────────────────────────────────────────────────────┘
                        ↓
                  ✅ 构建成功
```

---

## 五、Maven 参数详解

### 常用参数对比

| 参数 | 作用 | 示例 |
|------|------|------|
| `-N` | 只构建当前项目，不递归构建子模块 | `mvn install -N` |
| `-pl` | 指定要构建的模块 | `mvn install -pl nms4cloud-bi` |
| `-am` | 同时构建该模块依赖的所有模块 | `mvn install -pl app -am` |
| `-amd` | 同时构建依赖该模块的所有模块 | `mvn install -pl api -amd` |
| `-T` | 并行构建（指定线程数） | `mvn install -T 2C` (2倍CPU核心数) |
| `clean` | 清理之前的构建产物 | `mvn clean install` |
| `-DskipTests` | 跳过测试 | `mvn install -DskipTests` |
| `-Dmaven.test.skip=true` | 跳过测试编译和执行 | `mvn install -Dmaven.test.skip=true` |

### Maven 生命周期

```
validate → compile → test → package → verify → install → deploy
```

**常用命令：**
- `mvn compile`：编译代码
- `mvn test`：运行测试
- `mvn package`：打包成jar
- `mvn install`：安装到本地仓库
- `mvn deploy`：发布到远程仓库（⚠️ 不要使用！）

---

## 六、构建时间估算

| 步骤 | 命令 | 预计时间 |
|------|------|---------|
| 步骤1：构建父POM | `mvn install -N` | 5 秒 |
| 步骤2：构建bi模块 | `mvn install -pl nms4cloud-bi -am` | 1-3 分钟 |
| 步骤3：构建其他模块 | `mvn install` | 2-5 分钟 |
| **总计** | | **约 3-8 分钟** |

**影响因素：**
- 服务器性能（CPU、内存）
- 网络速度（下载依赖）
- 项目大小（代码量、依赖数量）
- 是否跳过测试（`-DskipTests`）
- 是否并行构建（`-T 2C`）

---

## 七、验证构建结果

### 1. 检查父pom是否安装

```bash
ls -la ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/

# 应该看到：
# nms4cloud-0.0.1-SNAPSHOT.pom
# maven-metadata-local.xml
```

### 2. 检查bi-api是否安装

```bash
ls -la ~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/

# 应该看到：
# nms4cloud-bi-api-0.0.1-SNAPSHOT.jar  ← 重要！
# nms4cloud-bi-api-0.0.1-SNAPSHOT.pom
```

### 3. 检查所有模块

```bash
ls ~/.m2/repository/com/nms4cloud/

# 应该看到所有模块的目录
```

### 4. 查看jar包内容

```bash
# 查看jar包内容
jar -tf ~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/nms4cloud-bi-api-0.0.1-SNAPSHOT.jar

# 或者解压查看
unzip -l ~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/nms4cloud-bi-api-0.0.1-SNAPSHOT.jar
```

---

## 八、常见问题排查

### 问题1：找不到父POM

**错误信息：**
```
[ERROR] Non-resolvable parent POM for com.nms4cloud:nms4cloud-bi:0.0.1-SNAPSHOT:
Could not find artifact com.nms4cloud:nms4cloud:pom:0.0.1-SNAPSHOT
```

**原因：**
- 父POM未安装到本地仓库
- relativePath 配置错误

**解决方法：**
```bash
# 先安装父POM
mvn install -N
```

### 问题2：找不到 bi-api 依赖

**错误信息：**
```
[ERROR] Could not find artifact com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT
```

**原因：**
- `nms4cloud-bi-api` 未构建和安装到本地仓库

**解决方法：**
```bash
# 先构建 bi 模块
mvn clean install -pl nms4cloud-bi -am -DskipTests
```

### 问题3：构建顺序错误

**错误信息：**
```
[ERROR] Failed to execute goal on project nms4cloud-order-service:
Could not resolve dependencies
```

**原因：**
- 先构建了依赖 bi-api 的模块，但 bi-api 还没有被构建

**解决方法：**
- 按照3步流程构建：父POM → bi模块 → 其他模块

### 问题4：并行构建冲突

**错误信息：**
```
[ERROR] Could not acquire write lock
```

**原因：**
- 多个线程同时写入同一个文件

**解决方法：**
```bash
# 减少并行线程数
mvn install -T 1C  # 使用1倍CPU核心数

# 或者不使用并行构建
mvn install  # 不加 -T 参数
```

### 问题5：内存不足

**错误信息：**
```
[ERROR] Java heap space
```

**原因：**
- Maven构建过程中内存不足

**解决方法：**
```bash
# 在 Jenkinsfile 中设置 Maven 内存
export MAVEN_OPTS="-Xmx2048m -Xms512m"
mvn clean install
```

或者在 Jenkinsfile 中：
```groovy
environment {
    MAVEN_OPTS = '-Xmx2048m -Xms512m'
}
```

---

## 九、安全注意事项

### ⚠️ 不要使用 mvn deploy

父pom中配置了 `distributionManagement`：

```xml
<distributionManagement>
    <repository>
        <id>repo-tbmiu</id>
        <name>maven</name>
        <url>https://packages.aliyun.com/613895a803e1c17d57a7630f/maven/repo-tbmiu</url>
    </repository>
    <snapshotRepository>
        <id>repo-tbmiu</id>
        <name>maven</name>
        <url>https://packages.aliyun.com/613895a803e1c17d57a7630f/maven/repo-tbmiu</url>
    </snapshotRepository>
</distributionManagement>
```

**这个配置的作用：**
- 配置Maven项目发布到远程仓库的位置
- **只有执行 `mvn deploy` 时才会触发**

**安全建议：**

✅ **只使用 `mvn install`**
- 只在本地构建和安装
- 不会上传到远程仓库

❌ **不要使用 `mvn deploy`**
- 会将jar包上传到阿里云Maven仓库
- 可能泄露代码

**验证方法：**
```bash
# 检查 Jenkinsfile 中是否有 deploy
grep -n "deploy" Jenkinsfile-nms4cloud

# 应该没有任何输出
```

---

## 十、最佳实践

### 1. 构建顺序

✅ **推荐：** 按照3步流程构建
```bash
# 步骤1：安装父POM
mvn install -N

# 步骤2：构建bi模块
mvn clean install -pl nms4cloud-bi -am -DskipTests

# 步骤3：构建其他模块
mvn clean install -DskipTests -T 2C
```

❌ **不推荐：** 直接构建所有模块
```bash
# 会失败，因为 bi 模块没有在父pom中声明
mvn clean install
```

### 2. 参数使用

✅ **推荐：**
- 使用 `-DskipTests` 跳过测试（加快构建）
- 使用 `-T 2C` 并行构建（提高效率）
- 使用 `-am` 自动构建依赖

❌ **不推荐：**
- 不使用 `-N` 就想只构建父POM
- 不使用 `-pl` 就想只构建某个模块

### 3. 构建策略

**开发环境：**
```bash
# 快速构建，跳过测试
mvn clean install -DskipTests -T 2C
```

**测试环境：**
```bash
# 运行测试，确保质量
mvn clean install -T 2C
```

**生产环境：**
```bash
# 完整构建，包括测试和代码检查
mvn clean install
mvn sonar:sonar  # 代码质量检查
```

### 4. Jenkins 配置

✅ **推荐：**
- 使用参数化构建（BUILD_MODULE、SKIP_TESTS等）
- 分步构建（父POM → bi模块 → 其他模块）
- 归档构建产物（archiveArtifacts）

❌ **不推荐：**
- 一次性构建所有模块（可能失败）
- 不跳过测试（构建时间长）
- 不使用并行构建（效率低）

---

## 十一、总结

### 核心要点

1. **父pom的 modules 中缺少 nms4cloud-bi 声明**
   - 这是问题的根源
   - 需要单独构建 bi 模块

2. **3步构建流程**
   - 步骤1：安装父POM（双保险）
   - 步骤2：构建bi模块（解决依赖问题）
   - 步骤3：构建其他模块（现在能找到依赖了）

3. **Maven参数的正确使用**
   - `-N`：只构建当前项目
   - `-pl`：指定模块
   - `-am`：自动构建依赖
   - `-T 2C`：并行构建

4. **安全注意事项**
   - 只使用 `mvn install`
   - 不要使用 `mvn deploy`
   - 不会上传到远程仓库

### 构建时间

- 总计：约 3-8 分钟
- 步骤1：5秒
- 步骤2：1-3分钟
- 步骤3：2-5分钟

### 验证方法

```bash
# 检查父pom
ls ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/

# 检查bi-api
ls ~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/

# 检查所有模块
ls ~/.m2/repository/com/nms4cloud/
```

---

## 相关文档

- [Maven多模块项目构建原理.md](./Maven多模块项目构建原理.md)
- [Jenkins工作原理.md](./Jenkins工作原理.md)
- [Jenkins创建Pipeline任务指南.md](./Jenkins创建Pipeline任务指南.md)
- [Jenkins凭据设置.md](./Jenkins凭据设置.md)
