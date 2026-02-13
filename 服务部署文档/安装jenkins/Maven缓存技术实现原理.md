# Maven 缓存技术实现原理

## 1. 缓存到哪里？

### 默认缓存位置

Maven 使用 **本地仓库（Local Repository）** 作为缓存：

```bash
# Linux/Mac 默认位置
~/.m2/repository

# Windows 默认位置
C:\Users\<用户名>\.m2\repository

# Jenkins 环境默认位置
/var/jenkins_home/.m2/repository
```

### 目录结构

```
~/.m2/repository/
├── org/
│   └── springframework/
│       └── boot/
│           └── spring-boot-starter-web/
│               └── 2.7.0/
│                   ├── spring-boot-starter-web-2.7.0.jar
│                   ├── spring-boot-starter-web-2.7.0.pom
│                   ├── spring-boot-starter-web-2.7.0.jar.sha1
│                   └── _remote.repositories
├── org/
│   └── apache/
│       └── kafka/
│           └── kafka-clients/
│               └── 3.3.1/
│                   ├── kafka-clients-3.3.1.jar
│                   ├── kafka-clients-3.3.1.pom
│                   └── kafka-clients-3.3.1.jar.sha1
└── com/
    └── nms4cloud/
        └── nms4cloud-wms-api/
            └── 0.0.1-SNAPSHOT/
                ├── maven-metadata-local.xml
                ├── nms4cloud-wms-api-0.0.1-SNAPSHOT.jar
                └── nms4cloud-wms-api-0.0.1-SNAPSHOT.pom
```

### 路径规则

依赖坐标转换为文件路径：

```xml
<!-- pom.xml 中的依赖 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>2.7.0</version>
</dependency>
```

转换为文件路径：
```
groupId: org.springframework.boot → org/springframework/boot
artifactId: spring-boot-starter-web
version: 2.7.0

完整路径：
~/.m2/repository/org/springframework/boot/spring-boot-starter-web/2.7.0/spring-boot-starter-web-2.7.0.jar
```

## 2. 如何实现缓存？

### 缓存查找流程

```
Maven 构建流程：
┌─────────────────────────────────────────┐
│ 1. 读取 pom.xml，解析依赖列表           │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 2. 对每个依赖，检查本地仓库             │
│    路径: ${maven.repo.local}/           │
│          groupId/artifactId/version/    │
└─────────────────────────────────────────┘
                  ↓
         ┌────────┴────────┐
         │                 │
    [存在]              [不存在]
         │                 │
         ↓                 ↓
┌─────────────────┐  ┌─────────────────────┐
│ 3a. 验证完整性  │  │ 3b. 从远程仓库下载  │
│  - 检查 .sha1   │  │  - Maven Central    │
│  - 检查文件大小 │  │  - 阿里云镜像       │
└─────────────────┘  │  - 私有 Nexus       │
         │           └─────────────────────┘
         │                 │
         │                 ↓
         │           ┌─────────────────────┐
         │           │ 4. 保存到本地仓库   │
         │           │  - 保存 .jar        │
         │           │  - 保存 .pom        │
         │           │  - 生成 .sha1       │
         │           │  - 记录来源         │
         │           └─────────────────────┘
         │                 │
         └────────┬────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 5. 使用依赖进行编译                     │
└─────────────────────────────────────────┘
```

### 详细实现步骤

#### 步骤 1：解析依赖

```java
// Maven 内部伪代码
List<Dependency> dependencies = parsePom("pom.xml");

for (Dependency dep : dependencies) {
    String groupId = dep.getGroupId();      // org.springframework.boot
    String artifactId = dep.getArtifactId(); // spring-boot-starter-web
    String version = dep.getVersion();       // 2.7.0

    resolveArtifact(groupId, artifactId, version);
}
```

#### 步骤 2：构建本地路径

```java
// 构建本地仓库路径
String localRepoPath = System.getProperty("maven.repo.local",
                                          System.getProperty("user.home") + "/.m2/repository");

String artifactPath = localRepoPath + "/" +
                      groupId.replace('.', '/') + "/" +
                      artifactId + "/" +
                      version + "/" +
                      artifactId + "-" + version + ".jar";

// 结果: ~/.m2/repository/org/springframework/boot/spring-boot-starter-web/2.7.0/spring-boot-starter-web-2.7.0.jar
```

#### 步骤 3：检查缓存

```java
File localFile = new File(artifactPath);

if (localFile.exists()) {
    // 验证文件完整性
    String expectedSha1 = readFile(artifactPath + ".sha1");
    String actualSha1 = calculateSha1(localFile);

    if (expectedSha1.equals(actualSha1)) {
        System.out.println("使用本地缓存: " + artifactPath);
        return localFile;  // ✓ 使用缓存
    } else {
        System.out.println("缓存损坏，重新下载");
        localFile.delete();
    }
}

// 缓存不存在或已损坏，需要下载
downloadFromRemote(groupId, artifactId, version);
```

#### 步骤 4：下载并缓存

```java
void downloadFromRemote(String groupId, String artifactId, String version) {
    // 远程仓库 URL
    String remoteUrl = "https://repo.maven.apache.org/maven2/" +
                       groupId.replace('.', '/') + "/" +
                       artifactId + "/" +
                       version + "/" +
                       artifactId + "-" + version + ".jar";

    System.out.println("Downloading from central: " + remoteUrl);

    // 下载文件
    byte[] jarData = httpGet(remoteUrl);

    // 保存到本地仓库
    File localFile = new File(artifactPath);
    localFile.getParentFile().mkdirs();  // 创建目录
    writeFile(localFile, jarData);

    // 计算并保存 SHA1 校验和
    String sha1 = calculateSha1(jarData);
    writeFile(artifactPath + ".sha1", sha1);

    // 记录下载来源
    writeFile(artifactPath.replace(".jar", "") + "/_remote.repositories",
              "spring-boot-starter-web-2.7.0.jar>central=");

    System.out.println("Downloaded from central: " + remoteUrl + " (" + jarData.length + " bytes)");
}
```

### 缓存元数据文件

每个缓存的依赖包含多个文件：

```bash
spring-boot-starter-web-2.7.0/
├── spring-boot-starter-web-2.7.0.jar          # 主文件
├── spring-boot-starter-web-2.7.0.pom          # 项目描述文件
├── spring-boot-starter-web-2.7.0.jar.sha1     # SHA1 校验和
├── spring-boot-starter-web-2.7.0.pom.sha1     # POM 校验和
└── _remote.repositories                        # 下载来源记录
```

**_remote.repositories 内容示例：**
```
#NOTE: This is a Maven Resolver internal implementation file
spring-boot-starter-web-2.7.0.jar>central=
spring-boot-starter-web-2.7.0.pom>central=
```

## 3. 我们的修改如何工作？

### 修改前（默认行为）

```groovy
// Jenkinsfile
mvn install -Dmaven.test.skip=true
```

**Maven 内部处理：**
```java
// 1. 读取系统属性
String localRepo = System.getProperty("maven.repo.local");

// 2. 如果未设置，使用默认值
if (localRepo == null) {
    localRepo = System.getProperty("user.home") + "/.m2/repository";
    // 在 Jenkins Pod 中: /root/.m2/repository
}

// 3. 使用这个路径作为缓存
// 问题：如果是临时 Pod，这个路径在 Pod 内部，会随 Pod 销毁
```

### 修改后（明确指定）

```groovy
// Jenkinsfile
MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
mvn install -Dmaven.repo.local=/var/jenkins_home/maven-repository -Dmaven.test.skip=true
```

**Maven 内部处理：**
```java
// 1. 读取命令行参数
String localRepo = System.getProperty("maven.repo.local");
// 结果: /var/jenkins_home/maven-repository

// 2. 使用这个路径作为缓存
// 优势：如果 /var/jenkins_home 是持久化卷，缓存会保留
```

### 对比示例

#### 场景 A：临时 Pod + 默认缓存（无效）

```bash
# 构建 #1
Pod: maven-build-abc123
  └─ /root/.m2/repository/  (Pod 内部临时目录)
      └─ org/springframework/boot/...  (下载 500 MB)
  构建完成 → Pod 销毁 → 缓存丢失

# 构建 #2
Pod: maven-build-xyz789  (全新 Pod)
  └─ /root/.m2/repository/  (又是空的)
      └─ org/springframework/boot/...  (再次下载 500 MB)
```

#### 场景 B：临时 Pod + 持久化缓存（有效）

```bash
# 构建 #1
Pod: maven-build-abc123
  └─ /var/jenkins_home/maven-repository/  (挂载持久化卷)
      └─ org/springframework/boot/...  (下载 500 MB)
  构建完成 → Pod 销毁 → 缓存保留在持久化卷

# 构建 #2
Pod: maven-build-xyz789  (全新 Pod)
  └─ /var/jenkins_home/maven-repository/  (挂载同一个持久化卷)
      └─ org/springframework/boot/...  (已存在，直接使用)
```

## 4. SNAPSHOT 版本的特殊处理

### SNAPSHOT 缓存机制

```xml
<dependency>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud-wms-api</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

**SNAPSHOT 目录结构：**
```
nms4cloud-wms-api/0.0.1-SNAPSHOT/
├── maven-metadata-local.xml              # 元数据
├── nms4cloud-wms-api-0.0.1-SNAPSHOT.jar  # 最新版本
├── nms4cloud-wms-api-0.0.1-SNAPSHOT.pom
├── nms4cloud-wms-api-0.0.1-20260213.023045-1.jar  # 带时间戳的版本
└── nms4cloud-wms-api-0.0.1-20260213.023045-1.pom
```

**maven-metadata-local.xml 内容：**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>com.nms4cloud</groupId>
  <artifactId>nms4cloud-wms-api</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <versioning>
    <snapshot>
      <localCopy>true</localCopy>
    </snapshot>
    <lastUpdated>20260213023045</lastUpdated>
  </versioning>
</metadata>
```

### 更新策略

```bash
# 默认：使用缓存的 SNAPSHOT（可能是旧版本）
mvn install

# 强制更新：检查远程仓库，下载最新的 SNAPSHOT
mvn install -U
# 或
mvn install --update-snapshots
```

**-U 参数的作用：**
```java
if (updateSnapshots) {
    // 检查远程仓库的 maven-metadata.xml
    String remoteMetadata = downloadMetadata(remoteUrl);
    String localMetadata = readLocalMetadata();

    if (remoteIsNewer(remoteMetadata, localMetadata)) {
        // 下载新版本
        downloadArtifact(remoteUrl);
    }
}
```

## 5. 缓存验证机制

### SHA1 校验

```bash
# 下载时生成 SHA1
$ sha1sum spring-boot-starter-web-2.7.0.jar
a1b2c3d4e5f6... spring-boot-starter-web-2.7.0.jar

# 保存到 .sha1 文件
$ echo "a1b2c3d4e5f6..." > spring-boot-starter-web-2.7.0.jar.sha1

# 使用时验证
$ sha1sum -c spring-boot-starter-web-2.7.0.jar.sha1
spring-boot-starter-web-2.7.0.jar: OK  ✓
```

### 损坏检测

```java
// Maven 验证逻辑
if (localFile.exists()) {
    String expectedSha1 = readSha1File(localFile + ".sha1");
    String actualSha1 = calculateSha1(localFile);

    if (!expectedSha1.equals(actualSha1)) {
        logger.warn("Checksum validation failed, re-downloading");
        localFile.delete();
        downloadFromRemote();
    }
}
```

## 6. 实际文件示例

### 查看缓存内容

```bash
# 查看 Spring Boot 缓存
$ ls -lh ~/.m2/repository/org/springframework/boot/spring-boot-starter-web/2.7.0/
-rw-r--r-- 1 user user 1.2M  Feb 13 10:30 spring-boot-starter-web-2.7.0.jar
-rw-r--r-- 1 user user   40  Feb 13 10:30 spring-boot-starter-web-2.7.0.jar.sha1
-rw-r--r-- 1 user user 2.1K  Feb 13 10:30 spring-boot-starter-web-2.7.0.pom
-rw-r--r-- 1 user user   40  Feb 13 10:30 spring-boot-starter-web-2.7.0.pom.sha1
-rw-r--r-- 1 user user  180  Feb 13 10:30 _remote.repositories

# 查看 SHA1 内容
$ cat spring-boot-starter-web-2.7.0.jar.sha1
a1b2c3d4e5f6789012345678901234567890abcd

# 查看下载来源
$ cat _remote.repositories
#NOTE: This is a Maven Resolver internal implementation file
spring-boot-starter-web-2.7.0.jar>central=
spring-boot-starter-web-2.7.0.pom>central=
```

### 缓存大小统计

```bash
# 查看整个缓存大小
$ du -sh ~/.m2/repository
5.2G    /home/user/.m2/repository

# 查看各个组织的缓存大小
$ du -sh ~/.m2/repository/*/ | sort -h
120M    ~/.m2/repository/com/
450M    ~/.m2/repository/org/
890M    ~/.m2/repository/io/
2.1G    ~/.m2/repository/org/springframework/
```

## 总结

### 缓存位置
- **默认**：`~/.m2/repository`
- **自定义**：通过 `-Dmaven.repo.local=<路径>` 指定
- **结构**：`groupId/artifactId/version/artifactId-version.jar`

### 缓存实现
1. **查找**：检查本地路径是否存在
2. **验证**：通过 SHA1 校验文件完整性
3. **下载**：从远程仓库下载缺失的依赖
4. **保存**：存储 JAR、POM、SHA1、来源信息
5. **使用**：直接使用本地缓存文件

### 关键点
- Maven 自动管理缓存，无需手动干预
- 缓存基于文件系统，简单高效
- 支持完整性验证，防止损坏
- SNAPSHOT 版本需要 `-U` 强制更新
- 持久化存储是缓存有效的前提
