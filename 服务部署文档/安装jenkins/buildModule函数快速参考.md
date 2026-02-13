# buildModule 函数快速参考

## 函数签名

```groovy
def buildModule(String moduleName, String moduleDir, String subModule, String cleanCmd, String skipTests)
```

## 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `moduleName` | 模块名称（日志用） | `'WMS-API'` |
| `moduleDir` | 模块目录 | `'nms4cloud-wms'` |
| `subModule` | 子模块名（空=构建全部） | `'nms4cloud-wms-api'` 或 `''` |
| `cleanCmd` | clean 命令 | `'clean'` 或 `''` |
| `skipTests` | 跳过测试 | `'-DskipTests'` 或 `''` |

## 使用示例

### 示例 1：构建单个子模块

```groovy
buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', 'clean', '-DskipTests')
```

**执行的命令：**
```bash
cd nms4cloud-wms
mvn clean install -pl nms4cloud-wms-api -am -DskipTests
```

**结果：**
- 构建 `nms4cloud-wms-api` 及其依赖

### 示例 2：构建完整模块

```groovy
buildModule('WMS 模块', 'nms4cloud-wms', '', 'clean', '-DskipTests')
```

**执行的命令：**
```bash
cd nms4cloud-wms
mvn clean install -DskipTests
```

**结果：**
- 构建 WMS 下的所有子模块

### 示例 3：不清理构建

```groovy
buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', '', '-DskipTests')
```

**执行的命令：**
```bash
cd nms4cloud-wms
mvn install -pl nms4cloud-wms-api -am -DskipTests
```

**结果：**
- 不删除 target 目录，增量构建

## Maven 参数详解

### mvn clean install -pl xxx -am -DskipTests

| 参数 | 说明 | 作用 |
|------|------|------|
| `clean` | 清理 | 删除 target 目录 |
| `install` | 安装 | 构建并安装到本地仓库 |
| `-pl xxx` | 指定模块 | 只构建指定的模块 |
| `-am` | 同时构建依赖 | 自动构建依赖的模块 |
| `-DskipTests` | 跳过测试 | 不执行测试（但编译测试代码） |

## Shell 命令详解

### if [ -d "${moduleDir}" ]

```bash
[ -d "nms4cloud-wms" ]  # 检查目录是否存在
```

- `-d`：directory（目录）
- 返回：存在=true，不存在=false

### if [ -n "${subModule}" ]

```bash
[ -n "nms4cloud-wms-api" ]  # 检查字符串是否非空
```

- `-n`：non-zero length（非零长度）
- 返回：非空=true，空=false

### cd ${moduleDir}

```bash
cd nms4cloud-wms  # 切换到模块目录
```

### cd ..

```bash
cd ..  # 返回上级目录
```

## 执行流程图

```
开始
  ↓
打印日志：">>> 构建 WMS-API"
  ↓
检查目录是否存在？
  ├─ 否 → 打印警告 → 结束
  └─ 是 ↓
进入模块目录：cd nms4cloud-wms
  ↓
检查是否有子模块？
  ├─ 是 → mvn install -pl xxx -am
  └─ 否 → mvn install
  ↓
返回上级目录：cd ..
  ↓
结束
```

## 实际应用

### 在 Jenkinsfile 中使用

```groovy
stage('Maven 构建') {
    steps {
        script {
            def cleanCmd = params.CLEAN_BUILD ? 'clean' : ''
            def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''

            // 构建 WMS-API
            buildModule('WMS-API', 'nms4cloud-wms', 'nms4cloud-wms-api', cleanCmd, skipTests)

            // 构建完整的 BI 模块
            buildModule('BI 模块', 'nms4cloud-bi', '', cleanCmd, skipTests)
        }
    }
}
```

### 构建日志输出

```
>>> 构建 WMS-API
构建子模块: nms4cloud-wms-api
[INFO] Scanning for projects...
[INFO] Building nms4cloud-wms-api 0.0.1-SNAPSHOT
[INFO] BUILD SUCCESS

>>> 构建 BI 模块
构建完整模块
[INFO] Scanning for projects...
[INFO] Building nms4cloud-bi-api 0.0.1-SNAPSHOT
[INFO] Building nms4cloud-bi-dao 0.0.1-SNAPSHOT
[INFO] Building nms4cloud-bi-service 0.0.1-SNAPSHOT
[INFO] Building nms4cloud-bi-app 0.0.1-SNAPSHOT
[INFO] BUILD SUCCESS
```

## 常见问题

### Q1: 为什么需要 -am 参数？

**A:** 因为模块之间有依赖关系。

```
示例：
nms4cloud-wms-dao 依赖 nms4cloud-wms-api

不使用 -am：
mvn install -pl nms4cloud-wms-dao
→ 失败！因为 api 没有构建

使用 -am：
mvn install -pl nms4cloud-wms-dao -am
→ 成功！Maven 自动先构建 api，再构建 dao
```

### Q2: clean 和不 clean 有什么区别？

**A:** clean 会删除之前的构建产物。

```
使用 clean：
mvn clean install
→ 删除 target/ → 重新构建（慢但干净）

不使用 clean：
mvn install
→ 保留 target/ → 增量构建（快但可能有问题）
```

### Q3: -DskipTests 和 -Dmaven.test.skip=true 的区别？

**A:**

```
-DskipTests：
✓ 编译测试代码
✗ 不执行测试

-Dmaven.test.skip=true：
✗ 不编译测试代码
✗ 不执行测试
```

## 总结

**buildModule 函数的核心作用：**
1. 检查模块目录是否存在
2. 根据参数决定构建单个子模块还是完整模块
3. 执行 Maven 构建命令
4. 返回到原始目录

**适用场景：**
- 多模块 Maven 项目
- 需要选择性构建某些模块
- CI/CD 自动化构建
