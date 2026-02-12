# Maven 多模块项目构建原理

## 概述

本文档详细介绍 Maven 多模块项目的构建原理，包括父子模块关系、依赖解析、构建顺序等核心概念。

---

## 一、Maven 多模块项目结构

### 1. 基本概念

Maven 多模块项目由一个父项目（Parent POM）和多个子模块（Sub-modules）组成：

```
nms4cloud/                          (父项目)
├── pom.xml                         (父POM，packaging=pom)
├── nms4cloud-starter/              (子模块1)
│   └── pom.xml
├── nms4cloud-app/                  (子模块2)
│   └── pom.xml
└── nms4cloud-bi/                   (子模块3，也是父模块)
    ├── pom.xml                     (packaging=pom)
    ├── nms4cloud-bi-api/           (子子模块)
    │   └── pom.xml
    ├── nms4cloud-bi-dao/
    │   └── pom.xml
    └── nms4cloud-bi-service/
        └── pom.xml
```

### 2. 父POM配置

父项目的 pom.xml：

```xml
<groupId>com.nms4cloud</groupId>
<artifactId>nms4cloud</artifactId>
<version>0.0.1-SNAPSHOT</version>
<packaging>pom</packaging>  <!-- 必须是 pom -->

<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <module>nms4cloud-bi</module>  <!-- 声明子模块 -->
</modules>
```

**关键点：**
- `packaging` 必须是 `pom`
- `<modules>` 中声明所有直接子模块
- 模块路径是相对于父pom.xml的相对路径

### 3. 子模块配置

子模块的 pom.xml：

```xml
<parent>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <relativePath>../pom.xml</relativePath>  <!-- 父POM的相对路径 -->
</parent>

<artifactId>nms4cloud-starter</artifactId>
<!-- 继承父项目的 groupId 和 version -->
```

**关键点：**
- `<parent>` 声明父项目
- `relativePath` 指向父pom.xml的相对路径
- 可以继承父项目的 groupId、version、dependencies 等

---

## 二、Maven 父POM 查找机制

### 1. 查找顺序

当Maven构建子模块时，按以下顺序查找父POM：

```
1. relativePath 指定的路径（优先）
   ↓ 如果找不到
2. 本地Maven仓库 (~/.m2/repository)
   ↓ 如果找不到
3. 远程Maven仓库（如Maven Central）
   ↓ 如果还找不到
4. 构建失败
```

### 2. relativePath 详解

**作用：** 告诉Maven在文件系统中哪里可以找到父pom.xml

#### relativePath 的计算起点

⚠️ **关键概念：** relativePath 是从**当前子模块的 pom.xml 文件所在的目录**开始计算的。

```
起点：当前子模块 pom.xml 所在的目录（不是文件本身）
终点：父项目的 pom.xml 文件
路径：从起点目录到终点文件的相对路径
```

#### 计算示例

**示例1：标准的父子结构**

```
项目目录结构：
nms4cloud/
├── pom.xml                    ← 父POM（目标）
└── nms4cloud-starter/
    └── pom.xml                ← 子模块POM（起点）
```

**计算过程：**
```
起点：nms4cloud/nms4cloud-starter/  （子模块pom.xml所在目录）
目标：nms4cloud/pom.xml             （父pom.xml文件）

计算：
nms4cloud/nms4cloud-starter/  （当前位置）
→ ../                          （上一级目录：nms4cloud/）
→ pom.xml                      （父pom.xml文件）

结果：<relativePath>../pom.xml</relativePath>
```

**示例2：嵌套的子模块**

```
项目目录结构：
nms4cloud/
├── pom.xml                    ← 父POM（目标）
└── modules/
    └── business/
        └── nms4cloud-bi/
            └── pom.xml        ← 子模块POM（起点）
```

**计算过程：**
```
起点：nms4cloud/modules/business/nms4cloud-bi/  （子模块pom.xml所在目录）
目标：nms4cloud/pom.xml                         （父pom.xml文件）

计算：
nms4cloud/modules/business/nms4cloud-bi/  （当前位置）
→ ../                                      （上一级：nms4cloud/modules/business/）
→ ../                                      （上一级：nms4cloud/modules/）
→ ../                                      （上一级：nms4cloud/）
→ pom.xml                                  （父pom.xml文件）

结果：<relativePath>../../../pom.xml</relativePath>
```

**示例3：你的实际项目（根据截图）**

```
项目目录结构（推测）：
nms4cloud/
├── pom.xml                    ← 父POM（目标）
└── xxx/
    └── xxx/
        └── nms4cloud-bi/
            └── pom.xml        ← 子模块POM（起点，relativePath=../../../pom.xml）
```

**验证方法：**
```bash
# 在 nms4cloud-bi 目录下执行
cd nms4cloud-bi

# 验证相对路径是否正确
ls -la ../../../pom.xml

# 如果显示文件存在，说明路径正确
# 如果显示 "No such file"，说明路径错误
```

#### 常见的 relativePath 配置

```xml
<!-- 父POM在上一级目录 -->
<relativePath>../pom.xml</relativePath>

<!-- 父POM在上两级目录 -->
<relativePath>../../pom.xml</relativePath>

<!-- 父POM在上三级目录 -->
<relativePath>../../../pom.xml</relativePath>

<!-- 父POM在同级的parent目录下 -->
<relativePath>../parent/pom.xml</relativePath>

<!-- 禁用relativePath查找，直接从仓库查找 -->
<relativePath/>
<!-- 或 -->
<relativePath></relativePath>
```

#### relativePath 计算规则

**规则1：`..` 表示上一级目录**
```
当前位置：/project/module/sub/
../         → /project/module/
../../      → /project/
../../../   → /
```

**规则2：路径必须指向 pom.xml 文件**
```
✅ 正确：<relativePath>../pom.xml</relativePath>
✅ 正确：<relativePath>../../parent/pom.xml</relativePath>
❌ 错误：<relativePath>..</relativePath>  （只指向目录，没有文件名）
```

**规则3：路径是相对于子模块 pom.xml 所在目录**
```
子模块位置：/project/modules/app/pom.xml
起点目录：  /project/modules/app/  （不是 pom.xml 文件本身）
```

#### 实际计算演练

**场景：** 你有一个子模块 `nms4cloud-bi/pom.xml`，其中配置了：
```xml
<relativePath>../../../pom.xml</relativePath>
```

**计算步骤：**

1. **确定起点**：找到子模块 pom.xml 所在的目录
   ```bash
   # 假设子模块pom.xml的完整路径是：
   /home/user/projects/nms4cloud/xxx/xxx/nms4cloud-bi/pom.xml

   # 起点目录就是：
   /home/user/projects/nms4cloud/xxx/xxx/nms4cloud-bi/
   ```

2. **应用相对路径**：从起点目录开始，按照 `../../../pom.xml` 计算
   ```
   起点：/home/user/projects/nms4cloud/xxx/xxx/nms4cloud-bi/

   第1个 ../  → /home/user/projects/nms4cloud/xxx/xxx/
   第2个 ../  → /home/user/projects/nms4cloud/xxx/
   第3个 ../  → /home/user/projects/nms4cloud/
   pom.xml   → /home/user/projects/nms4cloud/pom.xml
   ```

3. **验证结果**：检查计算出的路径是否存在
   ```bash
   ls -la /home/user/projects/nms4cloud/pom.xml
   ```

#### 如何确定正确的 relativePath

**方法1：手动计算**
```bash
# 1. 进入子模块目录
cd nms4cloud-bi

# 2. 使用 cd 命令测试相对路径
cd ../../../
pwd  # 应该显示父项目根目录

# 3. 检查父pom.xml是否存在
ls -la pom.xml

# 4. 如果存在，relativePath 就是 ../../../pom.xml
```

**方法2：使用 realpath 命令**
```bash
# 在子模块目录下
cd nms4cloud-bi

# 查看父pom的绝对路径
realpath ../../../pom.xml

# 如果命令成功执行，说明路径正确
```

**方法3：让Maven告诉你**
```bash
# 在子模块目录下构建，如果relativePath错误，Maven会报错
cd nms4cloud-bi
mvn validate

# 如果看到这个错误，说明relativePath不正确：
# [ERROR] Non-resolvable parent POM
```

#### 特殊情况

**情况1：relativePath 为空**
```xml
<relativePath/>
```
- Maven不会从文件系统查找父POM
- 直接从本地仓库或远程仓库查找
- 适用于父POM已发布到仓库的情况

**情况2：不配置 relativePath**
```xml
<parent>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <!-- 没有 relativePath -->
</parent>
```
- Maven使用默认值：`../pom.xml`
- 会先尝试从上一级目录查找父pom.xml
- 找不到再从仓库查找

**情况3：relativePath 指向不存在的路径**
```xml
<relativePath>../../../pom.xml</relativePath>
```
- Maven先尝试这个路径
- 如果找不到，会从本地仓库查找
- 如果本地仓库也没有，构建失败

### 3. 本地仓库查找

如果 relativePath 找不到，Maven会从本地仓库查找：

```
路径格式：
~/.m2/repository/{groupId}/{artifactId}/{version}/{artifactId}-{version}.pom

示例：
~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom
```

**如何安装父POM到本地仓库：**
```bash
# 在父项目根目录执行
mvn install -N
```

参数说明：
- `-N` 或 `--non-recursive`：只安装当前项目，不递归构建子模块

### 4. 只构建父POM详解

#### 什么是"只构建父POM"

执行 `mvn install -N` 时，Maven只处理当前目录的pom.xml，不会递归构建 `<modules>` 中声明的子模块。

#### 构建过程

```bash
# 在父项目根目录执行
cd nms4cloud
mvn install -N -DskipTests
```

**控制台输出示例：**
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
```

#### 生成的文件结构

假设父pom配置：
```xml
<groupId>com.nms4cloud</groupId>
<artifactId>nms4cloud</artifactId>
<version>0.0.1-SNAPSHOT</version>
<packaging>pom</packaging>
```

执行 `mvn install -N` 后，会在本地仓库生成：

```
~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/
├── nms4cloud-0.0.1-SNAPSHOT.pom          ← 父pom文件的副本
├── _remote.repositories                   ← 记录来源信息
└── maven-metadata-local.xml               ← 元数据信息
```

**重要：** 不会生成jar文件，因为父pom的 `packaging=pom`，不是 `jar`。

#### 生成文件说明

**1. nms4cloud-0.0.1-SNAPSHOT.pom**

这是父pom.xml的完整副本：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="...">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>

    <modules>
        <module>nms4cloud-starter</module>
        <module>nms4cloud-app</module>
    </modules>

    <!-- 其他配置... -->
</project>
```

**作用：**
- 子模块通过 relativePath 找不到父pom时，会从这里读取
- 其他项目可以将此pom作为parent引用

**2. maven-metadata-local.xml**

记录版本和更新时间：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<metadata modelVersion="1.1.0">
  <groupId>com.nms4cloud</groupId>
  <artifactId>nms4cloud</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <versioning>
    <snapshot>
      <localCopy>true</localCopy>
    </snapshot>
    <lastUpdated>20260212062000</lastUpdated>
    <snapshotVersions>
      <snapshotVersion>
        <extension>pom</extension>
        <value>0.0.1-SNAPSHOT</value>
        <updated>20260212062000</updated>
      </snapshotVersion>
    </snapshotVersions>
  </versioning>
</metadata>
```

**作用：**
- Maven用于版本管理
- 记录SNAPSHOT版本的更新时间

**3. _remote.repositories**

记录artifact的来源：
```
#NOTE: This is a Maven Resolver internal implementation file
#Wed Feb 12 14:20:00 CST 2026
nms4cloud-0.0.1-SNAPSHOT.pom>=
```

**作用：**
- 标记这个pom是本地构建的（`>=` 表示本地）
- 如果是从远程下载的，会显示仓库ID

#### 与构建子模块的区别

| 操作 | 命令 | 生成内容 | 构建时间 |
|------|------|---------|---------|
| **只构建父pom** | `mvn install -N` | 只有 pom 文件，无 jar 包 | 几秒钟 |
| **构建所有模块** | `mvn install` | pom 文件 + 所有子模块的 jar 包 | 几分钟 |
| **构建指定模块** | `mvn install -pl module-name` | 指定模块的 pom + jar | 取决于模块大小 |

**示例对比：**

**父pom（packaging=pom）：**
```
~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/
└── nms4cloud-0.0.1-SNAPSHOT.pom  ← 只有pom文件（约几KB）
```

**子模块（packaging=jar）：**
```
~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/
├── nms4cloud-bi-api-0.0.1-SNAPSHOT.jar  ← 有jar包（可能几MB）
└── nms4cloud-bi-api-0.0.1-SNAPSHOT.pom  ← 也有pom文件
```

#### 为什么需要只构建父POM

**场景1：子模块的 relativePath 找不到父pom**

当子模块的 relativePath 配置错误或目录结构变化时：

```xml
<!-- 子模块pom.xml -->
<parent>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <relativePath>../../../pom.xml</relativePath>  ← 如果这个路径不对
</parent>
```

Maven会从本地仓库查找：
```
~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom
```

**场景2：在Jenkins中构建（推荐做法）**

在Jenkins中，为了确保子模块能找到父pom，可以先安装父pom：

```groovy
stage('Maven构建') {
    steps {
        script {
            // 1. 先安装父pom（双保险）
            sh 'mvn install -N -DskipTests'

            // 2. 再构建所有模块
            sh 'mvn clean install -DskipTests -T 2C'
        }
    }
}
```

**好处：**
- 即使 relativePath 配置错误，也能正常构建
- 提高构建的可靠性
- 只需要几秒钟，不影响总构建时间

**场景3：只更新父pom配置**

如果只修改了父pom的配置（如依赖版本、插件配置），不需要重新构建所有子模块：

```bash
# 只更新父pom
mvn install -N

# 子模块下次构建时会使用新的父pom配置
```

**场景4：多模块项目的初始化**

在首次克隆项目后，可以先安装父pom，确保后续构建顺利：

```bash
# 1. 克隆项目
git clone https://xxx/nms4cloud.git
cd nms4cloud

# 2. 先安装父pom
mvn install -N

# 3. 再构建具体模块
mvn clean install -pl nms4cloud-bi -am -DskipTests
```

#### 验证父POM是否已安装

**方法1：检查文件是否存在**
```bash
# 检查父pom是否存在
ls -la ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/

# 应该看到：
# nms4cloud-0.0.1-SNAPSHOT.pom
# maven-metadata-local.xml
# _remote.repositories
```

**方法2：查看pom文件内容**
```bash
# 查看父pom文件内容
cat ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom

# 应该看到完整的父pom配置
```

**方法3：查看元数据**
```bash
# 查看元数据
cat ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/maven-metadata-local.xml

# 应该看到版本信息和更新时间
```

**方法4：使用Maven命令验证**
```bash
# 在子模块目录下验证
cd nms4cloud-bi
mvn validate

# 如果父pom已正确安装，不会报错
# 如果报错 "Non-resolvable parent POM"，说明父pom未安装或版本不匹配
```

#### 常见问题

**问题1：执行 mvn install -N 后仍然找不到父pom**

**可能原因：**
- groupId、artifactId 或 version 不匹配
- 子模块引用的版本与安装的版本不一致

**解决方法：**
```bash
# 检查父pom的坐标
grep -A 3 "<groupId>" pom.xml

# 检查子模块引用的父pom坐标
cd nms4cloud-bi
grep -A 4 "<parent>" pom.xml

# 确保两者完全一致
```

**问题2：SNAPSHOT版本冲突**

**现象：**
```
[WARNING] The POM for com.nms4cloud:nms4cloud:pom:0.0.1-SNAPSHOT is invalid
```

**解决方法：**
```bash
# 清理旧的SNAPSHOT版本
rm -rf ~/.m2/repository/com/nms4cloud/nms4cloud/0.0.1-SNAPSHOT/

# 重新安装父pom
mvn install -N
```

**问题3：Windows路径问题**

在Windows上，本地仓库路径是：
```
C:\Users\{用户名}\.m2\repository\com\nms4cloud\nms4cloud\0.0.1-SNAPSHOT\
```

使用PowerShell查看：
```powershell
ls C:\Users\$env:USERNAME\.m2\repository\com\nms4cloud\nms4cloud\0.0.1-SNAPSHOT\
```

#### 总结

**只构建父POM（mvn install -N）会：**

✅ 将父pom.xml安装到本地Maven仓库
✅ 生成元数据文件
✅ 供子模块引用
❌ 不会生成jar包（因为packaging=pom）
❌ 不会构建子模块（因为-N参数）

**适用场景：**
- 子模块的 relativePath 可能找不到父pom
- 在Jenkins中作为构建的第一步（提高可靠性）
- 只更新父pom配置，不需要重新构建所有模块
- 多模块项目的初始化

**最佳实践：**
```bash
# 推荐的构建顺序
mvn install -N              # 1. 先安装父pom（几秒钟）
mvn clean install -DskipTests -T 2C  # 2. 再构建所有模块
```

---

## 三、Maven 依赖解析原理

### 1. 依赖声明

模块A依赖模块B：

```xml
<!-- nms4cloud-order-service 的 pom.xml -->
<dependencies>
    <dependency>
        <groupId>com.nms4cloud</groupId>
        <artifactId>nms4cloud-bi-api</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </dependency>
</dependencies>
```

### 2. 依赖查找顺序

Maven按以下顺序查找依赖：

```
1. 本地Maven仓库 (~/.m2/repository)
   ↓ 如果找不到
2. 远程Maven仓库（settings.xml中配置的仓库）
   ↓ 如果找不到
3. Maven Central（默认中央仓库）
   ↓ 如果还找不到
4. 构建失败：Could not find artifact
```

### 3. SNAPSHOT 版本的特殊性

**SNAPSHOT 版本：**
- 表示开发中的版本，不稳定
- 通常不会发布到远程仓库
- 必须在本地构建并安装到本地仓库

**示例错误：**
```
[ERROR] Could not find artifact com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT
```

**原因：**
- `nms4cloud-bi-api` 是 SNAPSHOT 版本
- 本地仓库中没有这个版本
- 远程仓库也没有（因为是开发版本）

**解决方法：**
```bash
# 先构建并安装 bi-api 到本地仓库
mvn clean install -pl nms4cloud-bi-api -DskipTests
```

---

## 四、Maven 构建顺序（Reactor）

### 1. Reactor 机制

Maven Reactor 是 Maven 的核心组件，负责：
- 分析模块之间的依赖关系
- 确定构建顺序
- 并行构建独立的模块

### 2. 构建顺序计算

**示例项目结构：**
```
nms4cloud
├── nms4cloud-bi
│   └── nms4cloud-bi-api
├── nms4cloud-order-service (依赖 bi-api)
└── nms4cloud-app
```

**Maven 分析依赖关系：**
```
nms4cloud-bi-api (无依赖)
↓
nms4cloud-order-service (依赖 bi-api)
↓
nms4cloud-app (无依赖，可并行)
```

**构建顺序：**
```
[INFO] Reactor Build Order:
[INFO]
[INFO] nms4cloud                          [pom]
[INFO] nms4cloud-bi                       [pom]
[INFO] nms4cloud-bi-api                   [jar]  ← 先构建
[INFO] nms4cloud-order-service            [jar]  ← 后构建
[INFO] nms4cloud-app                      [jar]  ← 可并行
```

### 3. 构建命令参数

#### 构建所有模块
```bash
mvn clean install
```

#### 只构建父POM（不构建子模块）
```bash
mvn install -N
```

#### 构建指定模块
```bash
mvn clean install -pl nms4cloud-bi-api
```

#### 构建指定模块及其依赖
```bash
mvn clean install -pl nms4cloud-order-service -am
```

参数说明：
- `-pl` (--projects)：指定要构建的模块
- `-am` (--also-make)：同时构建该模块依赖的所有模块
- `-amd` (--also-make-dependents)：同时构建依赖该模块的所有模块

#### 并行构建
```bash
mvn clean install -T 2C
```

参数说明：
- `-T 2C`：使用 2 倍 CPU 核心数的线程并行构建
- `-T 4`：使用 4 个线程并行构建

---

## 五、常见构建问题及解决方案

### 问题1：找不到父POM

**错误信息：**
```
[ERROR] Non-resolvable parent POM for com.nms4cloud:nms4cloud-bi:0.0.1-SNAPSHOT:
Could not find artifact com.nms4cloud:nms4cloud:pom:0.0.1-SNAPSHOT
```

**原因：**
1. relativePath 路径错误
2. 父POM未安装到本地仓库

**解决方案：**
```bash
# 方案1：修正 relativePath
# 在子模块 pom.xml 中修改 <relativePath> 为正确路径

# 方案2：安装父POM到本地仓库
cd nms4cloud
mvn install -N
```

### 问题2：找不到依赖模块

**错误信息：**
```
[ERROR] Failed to execute goal on project nms4cloud-order-service:
Could not resolve dependencies for project com.nms4cloud:nms4cloud-order-service:jar:0.0.1-SNAPSHOT
[ERROR] dependency: com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT (compile)
[ERROR] Could not find artifact com.nms4cloud:nms4cloud-bi-api:jar:0.0.1-SNAPSHOT
```

**原因：**
- `nms4cloud-bi-api` 还没有被构建和安装到本地仓库
- `nms4cloud-order-service` 依赖 `nms4cloud-bi-api`

**解决方案：**

**方案1：在父项目根目录构建（推荐）**
```bash
cd nms4cloud
mvn clean install -DskipTests
```
Maven会自动按依赖顺序构建所有模块。

**方案2：先构建依赖模块**
```bash
# 1. 先构建 bi-api
mvn clean install -pl nms4cloud-bi-api -DskipTests

# 2. 再构建 order-service
mvn clean install -pl nms4cloud-order-service -am -DskipTests
```

**方案3：使用 -am 参数自动构建依赖**
```bash
# 构建 order-service 及其所有依赖
mvn clean install -pl nms4cloud-order-service -am -DskipTests
```

### 问题3：父POM未在modules中声明子模块

**现象：**
- 父POM的 `<modules>` 中缺少某个子模块
- 执行 `mvn clean install` 时不会构建该子模块
- 其他模块依赖该子模块时找不到

**示例：**
```xml
<!-- 父POM -->
<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <!-- 缺少 nms4cloud-bi -->
</modules>
```

**解决方案：**
```xml
<!-- 添加缺失的模块 -->
<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <module>nms4cloud-bi</module>  <!-- 添加这一行 -->
</modules>
```

---

## 六、在Jenkins中构建Maven项目

### 1. 基本构建流程

```groovy
pipeline {
    agent any

    stages {
        stage('代码检出') {
            steps {
                git(
                    url: 'https://codeup.aliyun.com/xxx/nms4cloud.git',
                    branch: 'main',
                    credentialsId: 'git-credentials'
                )
            }
        }

        stage('Maven构建') {
            steps {
                script {
                    // 在根目录构建所有模块
                    sh 'mvn clean install -DskipTests -T 2C'
                }
            }
        }
    }
}
```

### 2. 分步构建（处理复杂依赖）

```groovy
stage('Maven构建') {
    steps {
        script {
            // 步骤1：安装父POM
            sh 'mvn install -N -DskipTests'

            // 步骤2：构建 bi 模块
            sh 'mvn clean install -pl nms4cloud-bi -am -DskipTests'

            // 步骤3：构建所有模块
            sh 'mvn clean install -DskipTests -T 2C'
        }
    }
}
```

### 3. 参数化构建

```groovy
parameters {
    choice(
        name: 'BUILD_MODULE',
        choices: ['all', 'nms4cloud-starter', 'nms4cloud-app'],
        description: '选择构建模块'
    )
}

stage('Maven构建') {
    steps {
        script {
            if (params.BUILD_MODULE == 'all') {
                sh 'mvn clean install -DskipTests -T 2C'
            } else {
                sh "mvn clean install -pl ${params.BUILD_MODULE} -am -DskipTests"
            }
        }
    }
}
```

---

## 七、Maven 本地仓库结构

### 1. 仓库位置

**默认位置：**
```
Linux/Mac: ~/.m2/repository
Windows: C:\Users\{用户名}\.m2\repository
```

**自定义位置：**
在 `~/.m2/settings.xml` 中配置：
```xml
<settings>
    <localRepository>/path/to/custom/repo</localRepository>
</settings>
```

### 2. 仓库目录结构

```
~/.m2/repository/
└── com/
    └── nms4cloud/
        ├── nms4cloud/                    (父POM)
        │   └── 0.0.1-SNAPSHOT/
        │       ├── nms4cloud-0.0.1-SNAPSHOT.pom
        │       └── maven-metadata-local.xml
        ├── nms4cloud-bi-api/             (子模块)
        │   └── 0.0.1-SNAPSHOT/
        │       ├── nms4cloud-bi-api-0.0.1-SNAPSHOT.jar
        │       ├── nms4cloud-bi-api-0.0.1-SNAPSHOT.pom
        │       └── maven-metadata-local.xml
        └── nms4cloud-order-service/
            └── 0.0.1-SNAPSHOT/
                ├── nms4cloud-order-service-0.0.1-SNAPSHOT.jar
                └── nms4cloud-order-service-0.0.1-SNAPSHOT.pom
```

### 3. 验证模块是否已安装

```bash
# 检查 bi-api 是否已安装
ls -la ~/.m2/repository/com/nms4cloud/nms4cloud-bi-api/0.0.1-SNAPSHOT/

# 应该看到：
# nms4cloud-bi-api-0.0.1-SNAPSHOT.jar
# nms4cloud-bi-api-0.0.1-SNAPSHOT.pom
```

---

## 八、最佳实践

### 1. 项目结构设计

✅ **推荐：**
```
parent/
├── pom.xml (父POM)
├── module-a/
│   └── pom.xml (relativePath=../pom.xml)
└── module-b/
    └── pom.xml (relativePath=../pom.xml)
```

❌ **不推荐：**
```
parent/
├── pom.xml
└── deep/
    └── nested/
        └── module/
            └── pom.xml (relativePath=../../../pom.xml)
```

### 2. 构建命令选择

| 场景 | 推荐命令 |
|------|---------|
| 首次构建 | `mvn clean install` |
| 日常开发 | `mvn clean install -DskipTests` |
| 快速构建 | `mvn clean install -DskipTests -T 2C` |
| 只构建某个模块 | `mvn clean install -pl module-name -am` |
| 只安装父POM | `mvn install -N` |

### 3. 依赖管理

✅ **推荐：**
- 在父POM的 `<dependencyManagement>` 中统一管理版本
- 子模块只声明 groupId 和 artifactId，不指定版本

```xml
<!-- 父POM -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>3.4.1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<!-- 子模块 -->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <!-- 不需要指定版本，继承自父POM -->
    </dependency>
</dependencies>
```

### 4. SNAPSHOT 版本管理

✅ **推荐：**
- 开发阶段使用 SNAPSHOT 版本
- 发布时改为正式版本（如 1.0.0）
- 不要将 SNAPSHOT 版本发布到生产环境

❌ **不推荐：**
- 在生产环境依赖 SNAPSHOT 版本
- SNAPSHOT 版本不稳定，可能随时变化

---

## 九、故障排查

### 1. 查看Maven构建日志

```bash
# 详细日志
mvn clean install -X

# 只显示错误
mvn clean install -e
```

### 2. 查看依赖树

```bash
# 查看完整依赖树
mvn dependency:tree

# 查看指定模块的依赖树
mvn dependency:tree -pl nms4cloud-order-service
```

### 3. 清理本地仓库

```bash
# 清理所有构建产物
mvn clean

# 清理本地仓库中的SNAPSHOT版本
rm -rf ~/.m2/repository/com/nms4cloud/*/0.0.1-SNAPSHOT/
```

### 4. 验证POM文件

```bash
# 验证POM文件是否有效
mvn validate

# 查看有效POM（合并父POM后的最终POM）
mvn help:effective-pom
```

---

## 十、总结

### Maven 多模块构建的核心原理

1. **父子关系**：通过 `<parent>` 和 `<modules>` 建立关系
2. **依赖解析**：本地仓库 → 远程仓库 → Maven Central
3. **构建顺序**：Reactor 自动分析依赖关系，确定构建顺序
4. **relativePath**：优先从文件系统查找父POM，找不到再从仓库查找

### 解决依赖问题的通用方法

1. ✅ 在父项目根目录执行 `mvn clean install`
2. ✅ 使用 `-am` 参数自动构建依赖
3. ✅ 先安装父POM：`mvn install -N`
4. ✅ 验证 relativePath 是否正确

### 在Jenkins中的最佳实践

1. ✅ 克隆完整的代码仓库（保持目录结构）
2. ✅ 在根目录执行 `mvn clean install -DskipTests -T 2C`
3. ✅ Maven会自动处理所有依赖关系
4. ✅ 无需手动指定构建顺序

---

## 相关文档

- [Jenkins工作原理.md](./Jenkins工作原理.md)
- [Jenkins创建Pipeline任务指南.md](./Jenkins创建Pipeline任务指南.md)
- [Jenkins凭据设置.md](./Jenkins凭据设置.md)
