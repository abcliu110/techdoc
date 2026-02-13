# buildModule 函数详解

## 一、函数定义

```groovy
def buildModule(String moduleName, String moduleDir, String subModule, String cleanCmd, String skipTests)
```

### 参数说明

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `moduleName` | String | 模块名称（用于日志显示） | `'WMS-API'` |
| `moduleDir` | String | 模块所在目录 | `'nms4cloud-wms'` |
| `subModule` | String | 子模块名称（可选） | `'nms4cloud-wms-api'` 或 `''` |
| `cleanCmd` | String | clean 命令 | `'clean'` 或 `''` |
| `skipTests` | String | 跳过测试参数 | `'-DskipTests'` 或 `''` |

---

## 二、函数逻辑详解

### 2.1 完整代码结构

```groovy
def buildModule(String moduleName, String moduleDir, String subModule, String cleanCmd, String skipTests) {
    echo ">>> 构建 ${moduleName}"                    // 1. 打印日志
    sh """                                           // 2. 执行 Shell 脚本
        if [ -d "${moduleDir}" ]; then               // 3. 检查目录是否存在
            cd ${moduleDir}                          // 4. 进入模块目录
            if [ -n "${subModule}" ]; then           // 5. 判断是否有子模块
                echo "构建子模块: ${subModule}"       // 6a. 构建子模块
                mvn ${cleanCmd} install -pl ${subModule} -am ${skipTests}
            else
                echo "构建完整模块"                   // 6b. 构建完整模块
                mvn ${cleanCmd} install ${skipTests}
            fi
            cd ..                                    // 7. 返回上级目录
        else
            echo "⚠️ 警告：${moduleDir} 目录不存在，跳过构建"  // 8. 目录不存在
        fi
    """
}
```

---

## 三、逐行解析

### 3.1 打印日志

```groovy
echo ">>> 构建 ${moduleName}"
```

**作用：** 在 Jenkins 控制台输出构建信息

**示例：**
```
>>> 构建 WMS-API
```

**变量替换：**
```groovy
moduleName = 'WMS-API'
echo ">>> 构建 ${moduleName}"
// 输出：>>> 构建 WMS-API
```

---

### 3.2 Shell 脚本块

```groovy
sh """
    ...
"""
```

**作用：** 执行多行 Shell 命令

**等价于：**
```bash
#!/bin/bash
# 在 Jenkins 工作空间执行以下命令
...
```

---

### 3.3 检查目录是否存在

```bash
if [ -d "${moduleDir}" ]; then
```

**Shell 语法：**
- `[ -d "..." ]`：测试目录是否存在
- `-d`：directory（目录）
- `then`：如果条件为真，执行以下命令

**示例：**
```bash
moduleDir='nms4cloud-wms'

# 检查目录
if [ -d "nms4cloud-wms" ]; then
    echo "目录存在"
else
    echo "目录不存在"
fi
```

**实际执行：**
```bash
# 在 Jenkins 工作空间
/var/jenkins_home/workspace/nms4cloud-build/

# 检查
ls -la
# 输出：
# nms4cloud-wms/  ← 目录存在
# nms4cloud-bi/

# 结果：条件为真，执行 then 块
```

---

### 3.4 进入模块目录

```bash
cd ${moduleDir}
```

**作用：** 切换到模块目录

**示例：**
```bash
moduleDir='nms4cloud-wms'
cd nms4cloud-wms

# 当前目录变为：
# /var/jenkins_home/workspace/nms4cloud-build/nms4cloud-wms/
```

**为什么需要 cd？**
```
Maven 需要在项目根目录执行：
nms4cloud-wms/
├── pom.xml          ← Maven 需要这个文件
├── src/
└── target/

如果不 cd，Maven 找不到 pom.xml
```

---

### 3.5 判断是否有子模块

```bash
if [ -n "${subModule}" ]; then
```

**Shell 语法：**
- `[ -n "..." ]`：测试字符串是否非空
- `-n`：non-zero length（非零长度）

**示例：**
```bash
# 情况 1：有子模块
subModule='nms4cloud-wms-api'
if [ -n "nms4cloud-wms-api" ]; then
    # 条件为真（字符串非空）
    echo "构建子模块"
fi

# 情况 2：没有子模块
subModule=''
if [ -n "" ]; then
    # 条件为假（字符串为空）
else
    echo "构建完整模块"
fi
```

---

### 3.6a 构建子模块

```bash
echo "构建子模块: ${subModule}"
mvn ${cleanCmd} install -pl ${subModule} -am ${skipTests}
```

**Maven 命令详解：**

#### 基本结构
```bash
mvn [生命周期] [参数]
```

#### 参数展开示例
```bash
cleanCmd='clean'
subModule='nms4cloud-wms-api'
skipTests='-DskipTests'

# 展开后：
mvn clean install -pl nms4cloud-wms-api -am -DskipTests
```

#### 参数说明

**1. clean（可选）**
```bash
mvn clean install
    ↑
  清理 target 目录
```

**作用：** 删除之前的构建产物

**执行：**
```bash
# 删除
rm -rf target/

# 然后重新构建
```

**2. install**
```bash
mvn install
```

**作用：** 构建项目并安装到本地 Maven 仓库

**Maven 生命周期：**
```
validate  → 验证项目
compile   → 编译源代码
test      → 运行测试
package   → 打包（生成 jar/war）
verify    → 验证
install   → 安装到本地仓库 ← 我们在这里
deploy    → 部署到远程仓库
```

**install 做了什么：**
```bash
1. 编译代码
   src/main/java/*.java → target/classes/*.class

2. 运行测试（如果没有跳过）
   src/test/java/*.java → 运行测试

3. 打包
   target/classes/ → target/myapp.jar

4. 安装到本地仓库
   target/myapp.jar → ~/.m2/repository/com/nms4cloud/myapp/0.0.1-SNAPSHOT/myapp.jar
```

**3. -pl（--projects）**
```bash
mvn install -pl nms4cloud-wms-api
            ↑
      project list（项目列表）
```

**作用：** 只构建指定的模块

**示例：**
```bash
# 项目结构
nms4cloud-wms/
├── pom.xml
├── nms4cloud-wms-api/
├── nms4cloud-wms-dao/
├── nms4cloud-wms-service/
└── nms4cloud-wms-app/

# 只构建 api 模块
mvn install -pl nms4cloud-wms-api

# 结果：
# ✓ nms4cloud-wms-api 被构建
# ✗ nms4cloud-wms-dao 不构建
# ✗ nms4cloud-wms-service 不构建
# ✗ nms4cloud-wms-app 不构建
```

**多个模块：**
```bash
# 构建多个模块
mvn install -pl nms4cloud-wms-api,nms4cloud-wms-dao
```

**4. -am（--also-make）**
```bash
mvn install -pl nms4cloud-wms-api -am
                                   ↑
                            also make（同时构建依赖）
```

**作用：** 同时构建指定模块的依赖模块

**依赖关系：**
```
nms4cloud-wms-api（基础）
    ↓ 依赖
nms4cloud-wms-dao
    ↓ 依赖
nms4cloud-wms-service
    ↓ 依赖
nms4cloud-wms-app
```

**不使用 -am：**
```bash
mvn install -pl nms4cloud-wms-dao

# 结果：
# ✗ 失败！因为 dao 依赖 api，但 api 没有构建
```

**使用 -am：**
```bash
mvn install -pl nms4cloud-wms-dao -am

# Maven 自动分析依赖：
# 1. dao 依赖 api
# 2. 先构建 api
# 3. 再构建 dao

# 结果：
# ✓ nms4cloud-wms-api（依赖）
# ✓ nms4cloud-wms-dao（目标）
```

**5. -DskipTests**
```bash
mvn install -DskipTests
            ↑
      跳过测试执行
```

**作用：** 跳过测试执行（但会编译测试代码）

**对比：**
```bash
# -DskipTests：编译测试代码，但不执行
mvn install -DskipTests
# ✓ 编译 src/test/java/*.java
# ✗ 不运行测试

# -Dmaven.test.skip=true：完全跳过测试
mvn install -Dmaven.test.skip=true
# ✗ 不编译测试代码
# ✗ 不运行测试
```

---

### 3.6b 构建完整模块

```bash
echo "构建完整模块"
mvn ${cleanCmd} install ${skipTests}
```

**展开示例：**
```bash
cleanCmd='clean'
skipTests='-DskipTests'

# 展开后：
mvn clean install -DskipTests
```

**作用：** 构建模块下的所有子模块

**示例：**
```bash
# 项目结构
nms4cloud-wms/
├── pom.xml
├── nms4cloud-wms-api/
├── nms4cloud-wms-dao/
├── nms4cloud-wms-service/
└── nms4cloud-wms-app/

# 执行
cd nms4cloud-wms
mvn clean install -DskipTests

# 结果：构建所有子模块
# ✓ nms4cloud-wms-api
# ✓ nms4cloud-wms-dao
# ✓ nms4cloud-wms-service
# ✓ nms4cloud-wms-app
```

---

### 3.7 返回上级目录

```bash
cd ..
```

**作用：** 返回到工作空间根目录

**示例：**
```bash
# 当前目录
/var/jenkins_home/workspace/nms4cloud-build/nms4cloud-wms/

# 执行 cd ..
cd ..

# 返回到
/var/jenkins_home/workspace/nms4cloud-build/
```

**为什么需要 cd ..？**
```
构建多个模块时，需要回到根目录：

1. cd nms4cloud-wms
2. mvn install
3. cd ..              ← 回到根目录
4. cd nms4cloud-bi    ← 进入下一个模块
5. mvn install
```

---

### 3.8 目录不存在的处理

```bash
else
    echo "⚠️ 警告：${moduleDir} 目录不存在，跳过构建"
fi
```

**作用：** 如果目录不存在，输出警告并跳过

**示例：**
```bash
moduleDir='nms4cloud-wms'

# 检查目录
ls -la
# 输出：
# nms4cloud-bi/  ← 只有 bi 目录
# (没有 wms 目录)

# 结果：
⚠️ 警告：nms4cloud-wms 目录不存在，跳过构建
```

---

## 四、使用示例

### 4.1 构建子模块

```groovy
buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', 'clean', '-DskipTests')
```

**展开后的命令：**
```bash
>>> 构建 WMS-API

if [ -d "nms4cloud-wms" ]; then
    cd nms4cloud-wms
    if [ -n "nms4cloud-wms-api" ]; then
        echo "构建子模块: nms4cloud-wms-api"
        mvn clean install -pl nms4cloud-wms-api -am -DskipTests
    fi
    cd ..
fi
```

**执行流程：**
```
1. 检查 nms4cloud-wms 目录 → 存在 ✓
2. 进入 nms4cloud-wms
3. 检查 subModule → 非空 ✓
4. 执行：mvn clean install -pl nms4cloud-wms-api -am -DskipTests
   - clean：清理 target
   - install：构建并安装
   - -pl nms4cloud-wms-api：只构建 api 模块
   - -am：同时构建 api 的依赖
   - -DskipTests：跳过测试
5. 返回上级目录
```

### 4.2 构建完整模块

```groovy
buildModule('BI 模块', 'nms4cloud-bi', '', 'clean', '-DskipTests')
```

**展开后的命令：**
```bash
>>> 构建 BI 模块

if [ -d "nms4cloud-bi" ]; then
    cd nms4cloud-bi
    if [ -n "" ]; then
        # 条件为假，跳过
    else
        echo "构建完整模块"
        mvn clean install -DskipTests
    fi
    cd ..
fi
```

**执行流程：**
```
1. 检查 nms4cloud-bi 目录 → 存在 ✓
2. 进入 nms4cloud-bi
3. 检查 subModule → 为空 ✗
4. 执行：mvn clean install -DskipTests
   - 构建所有子模块：
     ✓ nms4cloud-bi-api
     ✓ nms4cloud-bi-dao
     ✓ nms4cloud-bi-service
     ✓ nms4cloud-bi-app
5. 返回上级目录
```

### 4.3 目录不存在

```groovy
buildModule('Generator', 'nms4cloud-generator', '', 'clean', '-DskipTests')
```

**展开后的命令：**
```bash
>>> 构建 Generator

if [ -d "nms4cloud-generator" ]; then
    # 目录不存在，跳过
else
    echo "⚠️ 警告：nms4cloud-generator 目录不存在，跳过构建"
fi
```

**输出：**
```
>>> 构建 Generator
⚠️ 警告：nms4cloud-generator 目录不存在，跳过构建
```

---

## 五、Maven 命令对比

### 5.1 不同参数组合的效果

| 命令 | 作用 | 构建范围 |
|------|------|----------|
| `mvn install` | 构建所有模块 | 全部 |
| `mvn install -pl api` | 只构建 api | api |
| `mvn install -pl api -am` | 构建 api 及其依赖 | 依赖 + api |
| `mvn clean install` | 清理后构建所有模块 | 全部 |
| `mvn install -DskipTests` | 构建但跳过测试 | 全部 |

### 5.2 实际构建时间对比

```
完整构建（所有模块）：
mvn clean install
时间：10 分钟

只构建一个模块：
mvn clean install -pl nms4cloud-wms-api -am
时间：2 分钟

跳过测试：
mvn clean install -DskipTests
时间：5 分钟
```

---

## 六、总结

### 6.1 函数的核心逻辑

```
1. 检查目录是否存在
   ↓ 存在
2. 进入模块目录
   ↓
3. 判断是否有子模块
   ├─ 有 → 构建子模块（mvn -pl）
   └─ 无 → 构建完整模块（mvn）
   ↓
4. 返回上级目录
```

### 6.2 关键 Maven 参数

| 参数 | 作用 | 示例 |
|------|------|------|
| `clean` | 清理 target | `mvn clean install` |
| `install` | 构建并安装 | `mvn install` |
| `-pl` | 指定模块 | `-pl nms4cloud-wms-api` |
| `-am` | 构建依赖 | `-pl api -am` |
| `-DskipTests` | 跳过测试 | `mvn install -DskipTests` |

### 6.3 使用场景

**场景 1：只构建某个模块的 API**
```groovy
buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', 'clean', '-DskipTests')
```

**场景 2：构建完整的模块**
```groovy
buildModule('BI 模块', 'nms4cloud-bi', '', 'clean', '-DskipTests')
```

**场景 3：不清理，快速构建**
```groovy
buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', '', '-DskipTests')
```
