# nms4cloud 项目构建顺序说明

## 项目结构

```
nms4cloud (父项目)
├── nms4cloud-starter (父 POM)
│   ├── nms4cloud-starter-parent
│   ├── nms4cloud-starter-redis
│   ├── nms4cloud-starter-oss
│   ├── nms4cloud-starter-mybatis
│   ├── nms4cloud-starter-mybatis-flex ← WMS 依赖
│   ├── nms4cloud-starter-shardingsphere
│   ├── nms4cloud-starter-rocketmq
│   ├── nms4cloud-starter-pdf
│   ├── nms4cloud-starter-mongodb
│   ├── nms4cloud-starter-xxjob
│   ├── nms4cloud-starter-mqtt
│   └── nms4cloud-starter-cloud ← WMS 依赖
├── nms4cloud-app (父 POM)
│   ├── nms4cloud-biz-api ← WMS 依赖
│   └── ... (其他子模块)
├── nms4cloud-wms (外部仓库)
│   ├── nms4cloud-wms-api
│   ├── nms4cloud-wms-dao
│   ├── nms4cloud-wms-service
│   └── nms4cloud-wms-app
└── nms4cloud-bi (外部仓库)
    ├── nms4cloud-bi-api
    ├── nms4cloud-bi-dao
    ├── nms4cloud-bi-service
    └── nms4cloud-bi-app
```

## 依赖关系

### WMS 模块的依赖
```
nms4cloud-wms-api 依赖：
├── nms4cloud-starter-cloud (来自 nms4cloud-starter)
├── nms4cloud-starter-mybatis-flex (来自 nms4cloud-starter)
└── nms4cloud-biz-api (来自 nms4cloud-app)
```

### BI 模块的依赖
```
nms4cloud-bi-app 依赖：
├── nms4cloud-generator (不存在，需要移除)
└── 其他 starter 模块
```

## 正确的构建顺序

### 步骤 1：安装父 POM
```bash
mvn install -N -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
```

**作用：**
- 安装 `nms4cloud` 父 POM 到 Maven 仓库
- 不构建任何子模块（`-N` 参数）

**输出：**
```
[INFO] Installing .../pom.xml to .../nms4cloud/0.0.1-SNAPSHOT/nms4cloud-0.0.1-SNAPSHOT.pom
[INFO] BUILD SUCCESS
```

---

### 步骤 2：构建 nms4cloud-starter 及其所有子模块
```bash
cd nms4cloud-starter
mvn clean install -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
cd ..
```

**作用：**
- 进入 `nms4cloud-starter` 目录
- 构建所有 starter 子模块（12 个）
- 安装到 Maven 仓库

**构建的模块：**
1. nms4cloud-starter-parent
2. nms4cloud-starter-redis
3. nms4cloud-starter-oss
4. nms4cloud-starter-mybatis
5. nms4cloud-starter-mybatis-flex ← **WMS 需要**
6. nms4cloud-starter-shardingsphere
7. nms4cloud-starter-rocketmq
8. nms4cloud-starter-pdf
9. nms4cloud-starter-mongodb
10. nms4cloud-starter-xxjob
11. nms4cloud-starter-mqtt
12. nms4cloud-starter-cloud ← **WMS 需要**

**输出：**
```
[INFO] Reactor Summary:
[INFO] nms4cloud-starter-parent ...................... SUCCESS
[INFO] nms4cloud-starter-redis ....................... SUCCESS
[INFO] ...
[INFO] nms4cloud-starter-cloud ....................... SUCCESS
[INFO] BUILD SUCCESS
```

**为什么要进入目录构建？**
- 如果使用 `mvn install -pl nms4cloud-starter`，只会构建父 POM
- 进入目录后，Maven 会自动构建 `<modules>` 中定义的所有子模块

---

### 步骤 3：构建 nms4cloud-app 模块
```bash
mvn clean install -pl nms4cloud-app -am -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
```

**作用：**
- 构建 `nms4cloud-app` 及其子模块
- 包含 `nms4cloud-biz-api` ← **WMS 需要**

**参数说明：**
- `-pl nms4cloud-app`：指定构建 nms4cloud-app 模块
- `-am`：also-make，同时构建依赖的模块

**输出：**
```
[INFO] Reactor Summary:
[INFO] nms4cloud-biz-api ............................. SUCCESS
[INFO] nms4cloud-app ................................. SUCCESS
[INFO] BUILD SUCCESS
```

---

### 步骤 4：构建 WMS 模块
```bash
cd nms4cloud-wms
mvn clean install -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
cd ..
```

**作用：**
- 构建完整的 WMS 模块（所有子模块）

**构建的模块：**
1. nms4cloud-wms-api ← 依赖已满足
2. nms4cloud-wms-dao
3. nms4cloud-wms-service
4. nms4cloud-wms-app

**依赖检查：**
```
✓ nms4cloud-starter-cloud (步骤 2 已安装)
✓ nms4cloud-starter-mybatis-flex (步骤 2 已安装)
✓ nms4cloud-biz-api (步骤 3 已安装)
```

**输出：**
```
[INFO] Reactor Summary:
[INFO] nms4cloud-wms-api ............................. SUCCESS
[INFO] nms4cloud-wms-dao ............................. SUCCESS
[INFO] nms4cloud-wms-service ......................... SUCCESS
[INFO] nms4cloud-wms-app ............................. SUCCESS
[INFO] BUILD SUCCESS
```

---

### 步骤 5：构建 BI 模块
```bash
cd nms4cloud-bi

# 移除 generator 依赖（临时修改，不影响 Git）
perl -i.bak -0pe 's/<dependency>\s*<groupId>com\.nms4cloud<\/groupId>\s*<artifactId>nms4cloud-generator<\/artifactId>.*?<\/dependency>//gs' nms4cloud-bi-app/pom.xml

# 构建完整的 BI 模块
mvn clean install -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository

cd ..
```

**作用：**
- 移除不存在的 `nms4cloud-generator` 依赖
- 构建完整的 BI 模块

**构建的模块：**
1. nms4cloud-bi-api
2. nms4cloud-bi-dao
3. nms4cloud-bi-service
4. nms4cloud-bi-app

**输出：**
```
[INFO] Reactor Summary:
[INFO] nms4cloud-bi-api .............................. SUCCESS
[INFO] nms4cloud-bi-dao .............................. SUCCESS
[INFO] nms4cloud-bi-service .......................... SUCCESS
[INFO] nms4cloud-bi-app .............................. SUCCESS
[INFO] BUILD SUCCESS
```

---

### 步骤 6：构建主项目其他模块（可选）
```bash
mvn clean install -Dmaven.test.skip=true -Dmaven.repo.local=/var/jenkins_home/maven-repository
```

**作用：**
- 根据参数构建主项目的其他模块
- 例如：nms4cloud-starter、nms4cloud-app 等

**参数控制：**
- `BUILD_MODULE=all`：构建所有模块
- `BUILD_MODULE=nms4cloud-starter`：只构建 starter
- `BUILD_MODULE=nms4cloud-app`：只构建 app

---

## 构建顺序总结

```
1. 父 POM (nms4cloud)
   ↓
2. nms4cloud-starter 及其 12 个子模块
   ├─ nms4cloud-starter-cloud
   ├─ nms4cloud-starter-mybatis-flex
   └─ ... (其他 10 个)
   ↓
3. nms4cloud-app 及其子模块
   └─ nms4cloud-biz-api
   ↓
4. nms4cloud-wms (外部仓库)
   ├─ nms4cloud-wms-api ← 依赖步骤 2 和 3
   ├─ nms4cloud-wms-dao
   ├─ nms4cloud-wms-service
   └─ nms4cloud-wms-app
   ↓
5. nms4cloud-bi (外部仓库)
   ├─ nms4cloud-bi-api
   ├─ nms4cloud-bi-dao
   ├─ nms4cloud-bi-service
   └─ nms4cloud-bi-app
   ↓
6. 主项目其他模块（可选）
```

## 为什么这个顺序？

### 原则：先构建依赖，再构建依赖者

```
依赖关系图：
nms4cloud-starter-cloud ──┐
nms4cloud-starter-mybatis-flex ──┼──→ nms4cloud-wms-api
nms4cloud-biz-api ──┘
```

**如果顺序错误：**
```
❌ 错误顺序：先构建 WMS
1. 构建 nms4cloud-wms-api
   → 找不到 nms4cloud-starter-cloud
   → 找不到 nms4cloud-starter-mybatis-flex
   → 找不到 nms4cloud-biz-api
   → BUILD FAILURE ✗
```

**正确顺序：先构建依赖**
```
✓ 正确顺序：先构建依赖
1. 构建 nms4cloud-starter → 安装 starter-cloud, starter-mybatis-flex
2. 构建 nms4cloud-app → 安装 biz-api
3. 构建 nms4cloud-wms → 找到所有依赖 → BUILD SUCCESS ✓
```

## 常见错误

### 错误 1：只构建父 POM，不构建子模块
```bash
# ❌ 错误
mvn install -pl nms4cloud-starter -am

# 结果：只安装 nms4cloud-starter 的 pom 文件，不构建子模块
```

```bash
# ✓ 正确
cd nms4cloud-starter
mvn install

# 结果：构建所有子模块
```

### 错误 2：构建顺序错误
```bash
# ❌ 错误顺序
1. 构建 WMS
2. 构建 starter

# 结果：WMS 找不到依赖，构建失败
```

```bash
# ✓ 正确顺序
1. 构建 starter
2. 构建 app
3. 构建 WMS

# 结果：所有依赖都能找到，构建成功
```

### 错误 3：忘记使用 Maven 缓存
```bash
# ❌ 没有缓存
mvn install

# 结果：每次都重新下载依赖，构建很慢
```

```bash
# ✓ 使用缓存
mvn install -Dmaven.repo.local=/var/jenkins_home/maven-repository

# 结果：依赖缓存，构建速度快
```

## 验证构建是否成功

### 检查 Maven 仓库
```bash
# 检查 starter-cloud 是否安装
ls -lh /var/jenkins_home/maven-repository/com/nms4cloud/nms4cloud-starter-cloud/0.0.1-SNAPSHOT/

# 应该看到：
nms4cloud-starter-cloud-0.0.1-SNAPSHOT.jar
nms4cloud-starter-cloud-0.0.1-SNAPSHOT.pom
```

### 检查构建日志
```
[INFO] Reactor Summary:
[INFO] nms4cloud-starter-cloud ....................... SUCCESS
[INFO] nms4cloud-biz-api ............................. SUCCESS
[INFO] nms4cloud-wms-api ............................. SUCCESS
[INFO] BUILD SUCCESS
```

### 检查构建产物
```bash
# 检查 WMS JAR 文件
ls -lh nms4cloud-wms/nms4cloud-wms-app/target/

# 应该看到：
nms4cloud-wms-app-0.0.1-SNAPSHOT.jar
```

## 完整的 Jenkinsfile 构建流程

```groovy
stage('Maven 构建') {
    steps {
        script {
            // 步骤 1：安装父 POM
            sh 'mvn install -N ${skipTests} ${MAVEN_CACHE_OPTS}'

            // 步骤 2：构建 nms4cloud-starter 及其所有子模块
            sh '''
                cd nms4cloud-starter
                mvn ${cleanCmd} install ${skipTests} ${MAVEN_CACHE_OPTS}
                cd ..
            '''

            // 步骤 3：构建 nms4cloud-app 模块
            sh 'mvn ${cleanCmd} install -pl nms4cloud-app -am ${skipTests} ${MAVEN_CACHE_OPTS}'

            // 步骤 4：构建 WMS 模块
            sh '''
                cd nms4cloud-wms
                mvn ${cleanCmd} install ${skipTests} ${MAVEN_CACHE_OPTS}
                cd ..
            '''

            // 步骤 5：构建 BI 模块
            sh '''
                cd nms4cloud-bi
                perl -i.bak -0pe 's/<dependency>\\s*<groupId>com\\.nms4cloud<\\/groupId>\\s*<artifactId>nms4cloud-generator<\\/artifactId>.*?<\\/dependency>//gs' nms4cloud-bi-app/pom.xml
                mvn ${cleanCmd} install ${skipTests} ${MAVEN_CACHE_OPTS}
                cd ..
            '''

            // 步骤 6：构建主项目其他模块（可选）
            buildMainProject(params.BUILD_MODULE, cleanCmd, skipTests, mvnOpts, MAVEN_CACHE_OPTS)
        }
    }
}
```

## 总结

**核心原则：**
1. 先构建依赖，再构建依赖者
2. 父 POM 必须先安装
3. 进入子模块目录构建，确保所有子模块都被构建
4. 使用 Maven 缓存加速构建

**构建顺序：**
1. 父 POM → 2. starter 子模块 → 3. app 子模块 → 4. WMS → 5. BI → 6. 其他

**关键命令：**
- `mvn install -N`：只安装父 POM
- `cd xxx && mvn install`：构建所有子模块
- `-Dmaven.repo.local=...`：使用缓存
