# Maven 本地仓库缓存说明

## 一、缓存机制

### 1. Maven 本地仓库位置

在 Jenkinsfile 中配置：
```groovy
environment {
    // Maven 本地仓库缓存（持久化目录）
    MAVEN_LOCAL_REPO = '/var/jenkins_home/maven-repository'
    MAVEN_BASE_OPTS = "-Dmaven.repo.local=${MAVEN_LOCAL_REPO} -Dmaven.compile.fork=true"
}
```

### 2. 缓存工作原理

```
第一次构建:
  Maven → 下载依赖 → 保存到 /var/jenkins_home/maven-repository
  
后续构建:
  Maven → 检查本地仓库 → 如果存在则直接使用 → 不再下载
```

### 3. 缓存优势

- ✅ 加快构建速度（不需要重复下载依赖）
- ✅ 减少网络流量
- ✅ 提高构建稳定性（不依赖外网）
- ✅ 支持离线构建

## 二、构建流程

### 1. 依赖下载阶段

```groovy
buildStep('1/2', 'Maven 依赖下载', """
    echo ">>> 下载项目依赖到本地仓库"
    mvn dependency:go-offline ${mvnOpts}
""")
```

**说明：**
- `dependency:go-offline`：下载所有依赖到本地仓库
- 首次构建会下载所有依赖
- 后续构建会跳过已存在的依赖

### 2. 编译打包阶段

```groovy
buildStep('2/2', 'Maven 编译打包', """
    mvn ${cleanCmd} package ${mvnOpts}
    
    echo ">>> 查看构建产物"
    ls -lh target/*.jar
""")
```

**说明：**
- 使用本地仓库中的依赖进行编译
- 不需要再次下载依赖

## 三、查看缓存信息

### 1. 在构建日志中查看

构建完成后会显示：
```
>>> Maven 本地仓库信息
仓库路径: /var/jenkins_home/maven-repository
仓库大小: 1.2G
文件数量: 15234
```

### 2. 手动查看

```bash
# 进入 Jenkins 容器
docker exec -it jenkins bash

# 查看仓库大小
du -sh /var/jenkins_home/maven-repository

# 查看仓库内容
ls -la /var/jenkins_home/maven-repository

# 查看特定依赖
ls -la /var/jenkins_home/maven-repository/org/springframework/boot/
```

### 3. 查看依赖树

```bash
# 在项目目录中执行
mvn dependency:tree -Dmaven.repo.local=/var/jenkins_home/maven-repository
```

## 四、缓存管理

### 1. 清理缓存

**清理所有缓存：**
```bash
docker exec jenkins rm -rf /var/jenkins_home/maven-repository
```

**清理特定依赖：**
```bash
# 清理 Spring Boot 相关依赖
docker exec jenkins rm -rf /var/jenkins_home/maven-repository/org/springframework/boot
```

**清理快照版本：**
```bash
# 清理所有 SNAPSHOT 版本
docker exec jenkins find /var/jenkins_home/maven-repository -name "*SNAPSHOT*" -type d -exec rm -rf {} +
```

### 2. 备份缓存

```bash
# 备份 Maven 仓库
docker exec jenkins tar -czf /tmp/maven-repo-backup.tar.gz /var/jenkins_home/maven-repository

# 复制到本地
docker cp jenkins:/tmp/maven-repo-backup.tar.gz .
```

### 3. 恢复缓存

```bash
# 复制备份到容器
docker cp maven-repo-backup.tar.gz jenkins:/tmp/

# 恢复
docker exec jenkins bash -c "
  rm -rf /var/jenkins_home/maven-repository
  tar -xzf /tmp/maven-repo-backup.tar.gz -C /
"
```

## 五、优化配置

### 1. 配置 Maven 镜像加速

创建 `settings.xml`：

```bash
docker exec -u root jenkins bash -c "
mkdir -p /var/jenkins_home/.m2
cat > /var/jenkins_home/.m2/settings.xml <<'EOF'
<settings xmlns=\"http://maven.apache.org/SETTINGS/1.0.0\"
          xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
          xsi:schemaLocation=\"http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd\">
  
  <!-- 本地仓库路径 -->
  <localRepository>/var/jenkins_home/maven-repository</localRepository>
  
  <!-- 镜像配置 -->
  <mirrors>
    <!-- 阿里云镜像 -->
    <mirror>
      <id>aliyun-central</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven Central</name>
      <url>https://maven.aliyun.com/repository/central</url>
    </mirror>
    
    <mirror>
      <id>aliyun-public</id>
      <mirrorOf>public</mirrorOf>
      <name>Aliyun Maven Public</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
    
    <mirror>
      <id>aliyun-spring</id>
      <mirrorOf>spring</mirrorOf>
      <name>Aliyun Maven Spring</name>
      <url>https://maven.aliyun.com/repository/spring</url>
    </mirror>
  </mirrors>
  
  <!-- 配置文件激活 -->
  <profiles>
    <profile>
      <id>aliyun</id>
      <repositories>
        <repository>
          <id>aliyun-central</id>
          <url>https://maven.aliyun.com/repository/central</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>false</enabled></snapshots>
        </repository>
        <repository>
          <id>aliyun-public</id>
          <url>https://maven.aliyun.com/repository/public</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>false</enabled></snapshots>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>aliyun-plugin</id>
          <url>https://maven.aliyun.com/repository/public</url>
          <releases><enabled>true</enabled></releases>
          <snapshots><enabled>false</enabled></snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
  
  <activeProfiles>
    <activeProfile>aliyun</activeProfile>
  </activeProfiles>
</settings>
EOF

chown jenkins:jenkins /var/jenkins_home/.m2/settings.xml
"
```

### 2. 增加 Maven 内存

在 Jenkinsfile 中：
```groovy
environment {
    MAVEN_OPTS = '-Xmx2048m -XX:+UseG1GC -XX:MaxMetaspaceSize=512m'
}
```

### 3. 并行下载依赖

```groovy
sh "mvn dependency:go-offline -T 4 ${mvnOpts}"
```
- `-T 4`：使用 4 个线程并行下载

## 六、缓存持久化

### 1. 使用 Docker Volume

创建 Jenkins 容器时挂载 Volume：

```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v maven_repo:/var/jenkins_home/maven-repository \
  jenkins/jenkins:lts
```

### 2. 使用宿主机目录

```bash
docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /data/jenkins_home:/var/jenkins_home \
  -v /data/maven_repo:/var/jenkins_home/maven-repository \
  jenkins/jenkins:lts
```

### 3. 验证持久化

```bash
# 重启容器
docker restart jenkins

# 检查缓存是否还在
docker exec jenkins ls -la /var/jenkins_home/maven-repository
```

## 七、监控缓存

### 1. 添加缓存监控脚本

创建 `check-maven-cache.sh`：

```bash
#!/bin/bash

REPO_PATH="/var/jenkins_home/maven-repository"

echo "=== Maven 本地仓库监控 ==="
echo "路径: $REPO_PATH"
echo ""

if [ -d "$REPO_PATH" ]; then
    echo "仓库大小: $(du -sh $REPO_PATH | cut -f1)"
    echo "文件数量: $(find $REPO_PATH -type f | wc -l)"
    echo "目录数量: $(find $REPO_PATH -type d | wc -l)"
    echo ""
    
    echo "=== 最大的 10 个依赖 ==="
    du -sh $REPO_PATH/*/* 2>/dev/null | sort -rh | head -10
    echo ""
    
    echo "=== 最近下载的依赖 ==="
    find $REPO_PATH -type f -mtime -1 | head -10
else
    echo "仓库不存在"
fi
```

使用：
```bash
docker exec jenkins bash /path/to/check-maven-cache.sh
```

### 2. 在 Jenkinsfile 中添加监控

```groovy
post {
    always {
        script {
            sh '''
                echo "=== Maven 缓存统计 ==="
                if [ -d "${MAVEN_LOCAL_REPO}" ]; then
                    echo "缓存大小: $(du -sh ${MAVEN_LOCAL_REPO} | cut -f1)"
                    echo "缓存文件: $(find ${MAVEN_LOCAL_REPO} -type f | wc -l)"
                fi
            '''
        }
    }
}
```

## 八、常见问题

### 1. 依赖下载失败

**问题：**
```
Could not resolve dependencies
```

**解决：**
- 检查网络连接
- 配置 Maven 镜像
- 清理损坏的缓存

### 2. 缓存占用空间过大

**问题：**
```
Maven 仓库占用 10GB+
```

**解决：**
```bash
# 清理 SNAPSHOT 版本
find /var/jenkins_home/maven-repository -name "*SNAPSHOT*" -type d -exec rm -rf {} +

# 清理旧版本（保留最新版本）
# 需要手动清理或使用 Maven 插件
```

### 3. 缓存损坏

**问题：**
```
Artifact corrupt or incomplete
```

**解决：**
```bash
# 删除损坏的依赖
rm -rf /var/jenkins_home/maven-repository/org/springframework/boot/spring-boot-starter/2.7.18

# 重新下载
mvn dependency:purge-local-repository -DreResolve=true
```

## 九、最佳实践

### 1. 定期清理

- 每月清理一次 SNAPSHOT 版本
- 每季度清理一次旧版本依赖
- 保持缓存大小在合理范围（< 5GB）

### 2. 使用私有 Maven 仓库

搭建 Nexus 或 Artifactory：
- 统一管理依赖
- 加速下载
- 支持离线构建

### 3. 监控缓存健康

- 定期检查缓存大小
- 监控下载失败率
- 记录缓存命中率

### 4. 备份重要依赖

- 定期备份 Maven 仓库
- 保存关键依赖的副本
- 准备离线依赖包
