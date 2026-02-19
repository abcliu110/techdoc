# Jenkins archiveArtifacts 命令详解

## 一、archiveArtifacts 是什么？

### 1.1 基本概念

**archiveArtifacts** 是 Jenkins Pipeline 的内置命令，用于**保存构建产物**。

**类比理解：**
```
构建过程 = 做菜
构建产物 = 做好的菜
归档 = 把菜打包保存起来

不归档：菜做好了，但吃完就没了
归档：菜做好了，打包保存，随时可以下载
```

### 1.2 为什么需要归档？

**问题场景：**
```
构建完成：
/var/jenkins_home/workspace/nms4cloud-build/
├── target/
│   └── myapp.jar  ← 构建产物

构建结束后：
- 工作空间被清理（cleanWs）
- myapp.jar 被删除 ✗
- 无法下载构建产物 ✗
```

**使用归档后：**
```
构建完成：
1. 生成 myapp.jar
2. archiveArtifacts 保存到 Jenkins
3. 工作空间被清理
4. myapp.jar 仍然可以下载 ✓
```

---

## 二、命令 1：归档 JAR 文件

```groovy
archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true, allowEmptyArchive: true
```

### 2.1 参数详解

#### artifacts: '**/target/*.jar'

**作用：** 指定要归档的文件模式

**通配符说明：**
```
**/target/*.jar
│   │      │
│   │      └─ 任意 .jar 文件
│   └──────── target 目录
└──────────── 任意层级的目录
```

**匹配示例：**
```
✓ nms4cloud-app/target/app.jar
✓ nms4cloud-wms/nms4cloud-wms-api/target/wms-api.jar
✓ nms4cloud-bi/nms4cloud-bi-app/target/bi-app.jar
✓ target/myapp.jar

✗ src/main/java/App.java（不在 target 目录）
✗ target/classes/App.class（不是 .jar 文件）
```

**实际匹配的文件：**
```
工作空间：
/var/jenkins_home/workspace/nms4cloud-build/
├── nms4cloud-wms/
│   ├── nms4cloud-wms-api/
│   │   └── target/
│   │       └── nms4cloud-wms-api-0.0.1-SNAPSHOT.jar  ✓
│   ├── nms4cloud-wms-dao/
│   │   └── target/
│   │       └── nms4cloud-wms-dao-0.0.1-SNAPSHOT.jar  ✓
│   └── nms4cloud-wms-app/
│       └── target/
│           └── nms4cloud-wms-app-0.0.1-SNAPSHOT.jar  ✓
└── nms4cloud-bi/
    └── nms4cloud-bi-app/
        └── target/
            └── nms4cloud-bi-app-0.0.1-SNAPSHOT.jar  ✓

归档结果：所有 jar 文件都被保存
```

#### fingerprint: true

**作用：** 为每个文件生成指纹（MD5 哈希值）

**指纹的用途：**

**1. 追踪文件变化**
```
构建 #10：myapp.jar → MD5: abc123def456
构建 #11：myapp.jar → MD5: abc123def456（相同）
构建 #12：myapp.jar → MD5: 789ghi012jkl（不同）

结论：
- #10 和 #11 的 jar 文件完全相同
- #12 的 jar 文件有变化
```

**2. 追踪文件使用**
```
Jenkins 可以追踪：
- 哪个构建生成了这个文件
- 这个文件被哪些构建使用
- 文件的传播路径
```

**3. 去重存储**
```
构建 #10：myapp.jar（MD5: abc123）→ 保存
构建 #11：myapp.jar（MD5: abc123）→ 不保存（相同）
构建 #12：myapp.jar（MD5: 789ghi）→ 保存（不同）

节省磁盘空间
```

**在 Jenkins UI 中查看：**
```
构建 #15 → 构建产物 → 查看指纹
显示：
- 文件名：myapp.jar
- MD5：abc123def456789...
- 首次出现：构建 #10
- 最后使用：构建 #15
```

#### allowEmptyArchive: true

**作用：** 允许没有匹配到文件时不报错

**场景对比：**

**allowEmptyArchive: false（默认）：**
```
如果没有找到 .jar 文件：
→ 构建失败 ✗
→ 错误：No artifacts found
```

**allowEmptyArchive: true：**
```
如果没有找到 .jar 文件：
→ 构建继续 ✓
→ 警告：No artifacts found（但不失败）
```

**使用场景：**
```
场景 1：某些模块可能不生成 jar
- nms4cloud-starter（只是依赖管理，不生成 jar）
- 使用 allowEmptyArchive: true

场景 2：必须生成 jar
- nms4cloud-app（必须生成可执行 jar）
- 使用 allowEmptyArchive: false
```

---

## 三、命令 2：归档 POM 文件

```groovy
archiveArtifacts artifacts: '**/pom.xml', fingerprint: true
```

### 3.1 参数详解

#### artifacts: '**/pom.xml'

**作用：** 归档所有 pom.xml 文件

**匹配示例：**
```
✓ pom.xml（根目录）
✓ nms4cloud-wms/pom.xml
✓ nms4cloud-wms/nms4cloud-wms-api/pom.xml
✓ nms4cloud-bi/nms4cloud-bi-app/pom.xml
```

### 3.2 为什么归档 pom.xml？

**用途 1：版本追踪**
```
可以查看每次构建使用的依赖版本：
构建 #10：Spring Boot 3.4.0
构建 #11：Spring Boot 3.4.1
```

**用途 2：问题排查**
```
生产环境出现问题：
1. 查看生产环境的构建编号：#15
2. 下载构建 #15 的 pom.xml
3. 查看当时使用的依赖版本
4. 对比当前版本，找出差异
```

**用途 3：依赖审计**
```
安全审计时：
- 下载所有构建的 pom.xml
- 检查是否使用了有漏洞的依赖
- 追溯问题版本
```

---

## 四、归档后的文件在哪里？

### 4.1 存储位置

**Jenkins 服务器上：**
```
/var/jenkins_home/jobs/nms4cloud-build/builds/15/archive/
├── nms4cloud-wms/
│   └── nms4cloud-wms-api/
│       └── target/
│           └── nms4cloud-wms-api-0.0.1-SNAPSHOT.jar
├── nms4cloud-bi/
│   └── nms4cloud-bi-app/
│       └── target/
│           └── nms4cloud-bi-app-0.0.1-SNAPSHOT.jar
└── pom.xml
```

### 4.2 在 Jenkins UI 中查看

**步骤：**
```
1. Jenkins 首页
   ↓
2. 点击任务名称：nms4cloud-build
   ↓
3. 点击构建编号：#15
   ↓
4. 左侧菜单：构建产物（Build Artifacts）
   ↓
5. 看到归档的文件列表
   ↓
6. 点击文件名即可下载
```

**UI 显示：**
```
构建 #15
├─ 控制台输出
├─ 构建产物 ← 点击这里
│   ├─ nms4cloud-wms-api-0.0.1-SNAPSHOT.jar（下载）
│   ├─ nms4cloud-bi-app-0.0.1-SNAPSHOT.jar（下载）
│   └─ pom.xml（下载）
└─ 工作空间
```

### 4.3 通过 URL 下载

**直接访问 URL：**
```
http://jenkins.example.com/job/nms4cloud-build/15/artifact/nms4cloud-wms/nms4cloud-wms-api/target/nms4cloud-wms-api-0.0.1-SNAPSHOT.jar
```

**格式：**
```
http://[Jenkins地址]/job/[任务名]/[构建号]/artifact/[文件路径]
```

---

## 五、完整示例

### 5.1 在 Jenkinsfile 中使用

```groovy
stage('归档构建产物') {
    steps {
        script {
            echo "=== 归档构建产物 ==="

            // 归档所有 jar 包
            archiveArtifacts artifacts: '**/target/*.jar',
                           fingerprint: true,
                           allowEmptyArchive: true

            // 归档 pom 文件
            archiveArtifacts artifacts: '**/pom.xml',
                           fingerprint: true
        }
    }
}
```

### 5.2 构建日志输出

```
=== 归档构建产物 ===
Archiving artifacts
Recording fingerprints
Archived 5 artifacts
  - nms4cloud-wms/nms4cloud-wms-api/target/nms4cloud-wms-api-0.0.1-SNAPSHOT.jar
  - nms4cloud-wms/nms4cloud-wms-dao/target/nms4cloud-wms-dao-0.0.1-SNAPSHOT.jar
  - nms4cloud-wms/nms4cloud-wms-service/target/nms4cloud-wms-service-0.0.1-SNAPSHOT.jar
  - nms4cloud-wms/nms4cloud-wms-app/target/nms4cloud-wms-app-0.0.1-SNAPSHOT.jar
  - nms4cloud-bi/nms4cloud-bi-app/target/nms4cloud-bi-app-0.0.1-SNAPSHOT.jar
Recorded 5 fingerprints
```

### 5.3 在 Jenkins UI 中查看

**构建产物页面：**
```
构建 #15 - 构建产物

📦 nms4cloud-wms/
   └─ nms4cloud-wms-api/
      └─ target/
         └─ nms4cloud-wms-api-0.0.1-SNAPSHOT.jar (2.5 MB) [下载]

📦 nms4cloud-bi/
   └─ nms4cloud-bi-app/
      └─ target/
         └─ nms4cloud-bi-app-0.0.1-SNAPSHOT.jar (3.2 MB) [下载]

📄 pom.xml (2 KB) [下载]
```

---

## 六、高级用法

### 6.1 归档特定文件

```groovy
// 只归档可执行的 jar（带 -app 后缀）
archiveArtifacts artifacts: '**/*-app/target/*.jar'

// 归档配置文件
archiveArtifacts artifacts: '**/application.yml'

// 归档多种文件
archiveArtifacts artifacts: '**/target/*.jar, **/target/*.war, **/dist/*.zip'
```

### 6.2 排除某些文件

```groovy
// 归档所有 jar，但排除测试 jar
archiveArtifacts artifacts: '**/target/*.jar',
               excludes: '**/target/*-tests.jar'
```

### 6.3 设置保留策略

```groovy
// 只保留最近 5 次构建的产物
options {
    buildDiscarder(logRotator(
        numToKeepStr: '10',           // 保留 10 次构建记录
        artifactNumToKeepStr: '5'     // 但只保留 5 次构建的产物
    ))
}
```

**效果：**
```
构建 #15：有产物 ✓
构建 #14：有产物 ✓
构建 #13：有产物 ✓
构建 #12：有产物 ✓
构建 #11：有产物 ✓
构建 #10：无产物（已删除）
构建 #9：无产物（已删除）
...
```

---

## 七、参数对比

### 7.1 fingerprint 参数

| 值 | 作用 | 使用场景 |
|----|------|----------|
| `true` | 生成文件指纹 | 需要追踪文件变化 |
| `false` | 不生成指纹 | 不需要追踪 |

**示例：**
```groovy
// 需要追踪 jar 文件的变化
archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true

// 不需要追踪配置文件
archiveArtifacts artifacts: '**/config/*.yml', fingerprint: false
```

### 7.2 allowEmptyArchive 参数

| 值 | 作用 | 使用场景 |
|----|------|----------|
| `true` | 允许没有文件 | 某些模块可能不生成产物 |
| `false` | 必须有文件 | 必须生成产物，否则失败 |

**示例：**
```groovy
// 某些模块可能不生成 jar（如 starter 模块）
archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true

// 必须生成 jar，否则构建失败
archiveArtifacts artifacts: '**/target/*-app.jar', allowEmptyArchive: false
```

---

## 八、实际应用场景

### 8.1 场景 1：下载构建产物

**需求：** 开发人员需要下载某次构建的 jar 包

**步骤：**
```
1. 打开 Jenkins
2. 找到任务：nms4cloud-build
3. 点击构建 #15
4. 点击"构建产物"
5. 下载 nms4cloud-bi-app-0.0.1-SNAPSHOT.jar
6. 部署到测试服务器
```

### 8.2 场景 2：版本回滚

**需求：** 生产环境出现问题，需要回滚到上一个版本

**步骤：**
```
1. 当前版本：构建 #20（有问题）
2. 上一个版本：构建 #19（正常）
3. 从 Jenkins 下载构建 #19 的 jar 包
4. 部署到生产环境
5. 问题解决
```

### 8.3 场景 3：依赖分析

**需求：** 分析某次构建使用的依赖版本

**步骤：**
```
1. 下载构建 #15 的 pom.xml
2. 查看依赖版本：
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter</artifactId>
       <version>3.4.1</version>
   </dependency>
3. 对比其他构建的版本
4. 找出问题原因
```

---

## 九、归档 vs 不归档

### 9.1 对比

| 特性 | 不归档 | 归档 |
|------|--------|------|
| 构建产物 | 构建完成后删除 | 永久保存 |
| 下载 | ✗ 无法下载 | ✓ 可以下载 |
| 磁盘占用 | 0 | 每次构建占用空间 |
| 版本追踪 | ✗ 无法追踪 | ✓ 可以追踪 |
| 回滚 | ✗ 无法回滚 | ✓ 可以回滚 |

### 9.2 磁盘占用

**示例计算：**
```
每次构建产物：
- jar 文件：50 MB
- pom 文件：1 MB
- 总计：51 MB

保留 10 次构建：
51 MB × 10 = 510 MB

保留 100 次构建：
51 MB × 100 = 5.1 GB
```

**优化建议：**
```groovy
options {
    buildDiscarder(logRotator(
        numToKeepStr: '30',           // 保留 30 次构建记录
        artifactNumToKeepStr: '10'    // 但只保留 10 次产物
    ))
}
```

---

## 十、完整的归档流程

### 10.1 执行流程

```
Maven 构建
    ↓
生成 jar 文件
    ↓ target/myapp.jar
archiveArtifacts 执行
    ↓
1. 扫描工作空间，匹配 **/target/*.jar
   ↓
2. 找到所有 jar 文件
   ↓
3. 计算 MD5 指纹（如果 fingerprint: true）
   ↓
4. 复制文件到归档目录
   /var/jenkins_home/jobs/nms4cloud-build/builds/15/archive/
   ↓
5. 记录指纹信息
   ↓
6. 在 Jenkins UI 中显示
   ↓
cleanWs 清理工作空间
    ↓
工作空间的 jar 文件被删除
    ↓
但归档的 jar 文件仍然存在 ✓
```

### 10.2 文件路径对比

**工作空间（临时）：**
```
/var/jenkins_home/workspace/nms4cloud-build/
└── nms4cloud-wms/
    └── nms4cloud-wms-api/
        └── target/
            └── wms-api.jar  ← 构建完成后会被删除
```

**归档目录（永久）：**
```
/var/jenkins_home/jobs/nms4cloud-build/builds/15/archive/
└── nms4cloud-wms/
    └── nms4cloud-wms-api/
        └── target/
            └── wms-api.jar  ← 永久保存，可以下载
```

---

## 十一、总结

### 11.1 两个命令的作用

**命令 1：**
```groovy
archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true, allowEmptyArchive: true
```
- 归档所有 jar 文件
- 生成指纹追踪变化
- 允许没有 jar 文件时不报错

**命令 2：**
```groovy
archiveArtifacts artifacts: '**/pom.xml', fingerprint: true
```
- 归档所有 pom.xml 文件
- 生成指纹追踪变化
- 用于版本追踪和问题排查

### 11.2 关键点

- ✅ 归档的文件永久保存（直到被清理策略删除）
- ✅ 可以通过 Jenkins UI 下载
- ✅ 支持指纹追踪文件变化
- ✅ 工作空间清理后，归档文件仍然存在
- ✅ 适合版本管理、回滚、问题排查

### 11.3 最佳实践

```groovy
stage('归档构建产物') {
    steps {
        script {
            // 归档可执行 jar（必须存在）
            archiveArtifacts artifacts: '**/*-app/target/*.jar',
                           fingerprint: true,
                           allowEmptyArchive: false

            // 归档所有 jar（可选）
            archiveArtifacts artifacts: '**/target/*.jar',
                           fingerprint: true,
                           allowEmptyArchive: true

            // 归档配置文件
            archiveArtifacts artifacts: '**/pom.xml, **/application.yml',
                           fingerprint: true
        }
    }
}
```
