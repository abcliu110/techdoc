# Maven 知识总结

## 一、Maven 三套生命周期

Maven 有三套独立的生命周期，互不干扰。

### 1. Clean 生命周期

| 阶段 | 说明 | 产物 |
|------|------|------|
| `pre-clean` | 清理前的准备工作 | 无 |
| `clean` | 删除上次构建生成的文件 | 删除 `target/` 目录 |
| `post-clean` | 清理后的收尾工作 | 无 |

### 2. Default 生命周期（核心）

| 阶段 | 说明 | 产物位置 |
|------|------|---------|
| `validate` | 验证项目结构是否正确 | 无 |
| `compile` | 编译源代码 | `target/classes/` |
| `test-compile` | 编译测试代码 | `target/test-classes/` |
| `test` | 运行单元测试 | `target/surefire-reports/` |
| `package` | 打包（jar/war） | `target/xxx-1.0.jar` |
| `install` | 安装到本地仓库 | `~/.m2/repository/...` |
| `deploy` | 部署到远程仓库 | Nexus / Harbor / Artifactory |

> 关键规则：执行某个阶段时，它之前的所有阶段都会自动执行。
> 例如 `mvn package` 会依次执行 validate → compile → test → package。

### 3. Site 生命周期

| 阶段 | 说明 | 产物 |
|------|------|------|
| `pre-site` | 生成站点前准备 | 无 |
| `site` | 生成项目文档 | `target/site/` |
| `post-site` | 生成站点后处理 | 无 |
| `site-deploy` | 发布站点到服务器 | 远程服务器 |

---

## 二、各阶段产物说明

### 默认不包含第三方包

各阶段产物默认只包含自己写的代码，第三方依赖存放在本地 Maven 仓库：

```
~/.m2/repository/
├── org/springframework/...
├── com/mysql/...
└── ...
```

### 典型构建后的 target 目录结构

```
target/
├── classes/              ← compile 产物（业务字节码）
├── test-classes/         ← test-compile 产物（测试字节码）
├── surefire-reports/     ← test 产物（测试报告）
├── generated-sources/    ← generate-sources 产物
├── maven-archiver/       ← 打包元信息
├── my-app-1.0.0.jar      ← package 产物（最终交付物）
└── site/                 ← site 产物（文档）
```

### package 产物取决于 packaging 类型

```xml
<packaging>jar</packaging>   <!-- 生成 .jar -->
<packaging>war</packaging>   <!-- 生成 .war，包含第三方包在 WEB-INF/lib/ -->
<packaging>pom</packaging>   <!-- 父工程，无二进制产物 -->
<packaging>ear</packaging>   <!-- 生成 .ear -->
```

---

## 三、三种 Fat Jar 打包方式

### 方式对比

| 方式 | 原理 | 类冲突风险 | 可直接运行 |
|------|------|-----------|-----------|
| 普通 jar | 只有自己的 class | 无 | 需指定 classpath |
| maven-shade-plugin | 解压合并所有 class | 有 | 是 |
| maven-assembly-plugin | 类合并（jar-with-deps） | 有 | 是 |
| Spring Boot jar | 嵌套 jar + 自定义 ClassLoader | 无 | 是 |

---

### 1. 普通 jar（不含依赖）

原理：`maven-jar-plugin` 直接把 `target/classes/` 下的字节码压缩打包。

```bash
# 运行时需手动指定 classpath
java -cp my-app.jar:lib/spring-core.jar com.example.Main
```

---

### 2. maven-shade-plugin（类合并）

**原理：解压所有依赖 jar，把所有 .class 文件合并到一个 jar 里。**

```
my-app.jar + spring-core.jar + commons-lang.jar
         ↓ 解压全部 class ↓
my-app-shaded.jar
├── com/example/Main.class
├── org/springframework/*.class   ← 第三方 class 直接放进来
└── org/apache/*.class
```

**配置示例：**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.5.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals><goal>shade</goal></goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>com.example.Main</mainClass>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**类冲突解决（relocation）：**

```xml
<relocations>
    <relocation>
        <pattern>com.google.guava</pattern>
        <shadedPattern>shaded.com.google.guava</shadedPattern>
    </relocation>
</relocations>
```

---

### 3. maven-assembly-plugin

**原理：把依赖 jar 原封不动放进去（实际 jar-with-dependencies 也是类合并方式）。**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <mainClass>com.example.Main</mainClass>
            </manifest>
        </archive>
        <descriptorRefs>
            <descriptorRef>jar-with-dependencies</descriptorRef>
        </descriptorRefs>
    </configuration>
    <executions>
        <execution>
            <phase>package</phase>
            <goals><goal>single</goal></goals>
        </execution>
    </executions>
</plugin>
```

> 注意：标准 JVM 无法加载 jar 内部嵌套的 jar，所以非 Spring Boot 项目推荐用 shade 插件。

---

### 4. Spring Boot Fat Jar（嵌套 jar + 自定义 ClassLoader）

**原理：自己实现 ClassLoader，突破标准 JVM 的限制，支持嵌套 jar。**

**内部结构：**

```
my-app.jar
├── BOOT-INF/
│   ├── classes/          ← 你的 class
│   └── lib/              ← 所有第三方 jar（原封不动）
├── META-INF/
│   └── MANIFEST.MF       ← Main-Class 指向 Spring Boot Loader
└── org/springframework/boot/loader/
    ├── JarLauncher.class         ← 真正的入口
    └── LaunchedURLClassLoader    ← 自定义 ClassLoader
```

**启动流程：**

```
java -jar my-app.jar
    ↓
JVM 读取 MANIFEST.MF → Main-Class: org.springframework.boot.loader.JarLauncher
    ↓
JarLauncher 创建 LaunchedURLClassLoader
    ↓
LaunchedURLClassLoader 读取嵌套 jar 内的 class（自定义 URL 协议 jar:jar:）
    ↓
加载 BOOT-INF/classes/ 下你的 Main 类并执行
```

**配置示例：**

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>
```

执行 `mvn package` 后生成两个文件：

```
target/
├── my-app-1.0.0.jar          ← Fat Jar（含所有依赖，可直接 java -jar 运行）
└── my-app-1.0.0.jar.original ← 原始 jar（不含依赖）
```

---

## 四、常用命令

```bash
mvn clean                      # 清理 target 目录
mvn compile                    # 只编译
mvn test                       # 运行测试
mvn package                    # 打包
mvn clean package              # 清理后重新打包
mvn clean package -DskipTests  # 跳过测试打包
mvn clean install              # 打包并安装到本地仓库
mvn clean deploy               # 打包并发布到远程仓库
```
