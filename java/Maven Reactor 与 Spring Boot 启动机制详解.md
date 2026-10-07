# Maven Reactor 与 Spring Boot 启动机制详解

> **核心结论**：
> - `mvn spring-boot:run -pl xxx -am` = Reactor 自动构建依赖 + 本地新代码生效
> - `mvn spring-boot:run -pl xxx`（无 `-am`）= 不构建依赖 + 本地仓库旧代码 → **新代码不生效**

---

## 一、核心问题

当我们执行 `mvn spring-boot:run -pl yudao-server -am` 时：

1. **`spring-boot:run`** 是什么？
2. **`-pl yudao-server`** 指定了什么？
3. **`-am` (Also Make)** 做了什么？
4. **classpath** 是如何工作的？
5. **jar 包**从哪里来？

---

## 二、classpath 机制

### 2.1 什么是 classpath

```
classpath = Java 运行时查找 .class 文件的路径
```

当 JVM 运行程序时，需要找到编译好的 `.class` 文件，classpath 就是告诉 JVM 去哪里找。

### 2.2 classpath 的默认值

```bash
java -cp "target/classes" com.example.Main
#                          ^
#                          默认从当前目录的 target/classes 查找
```

### 2.3 classpath 可以包含多个路径

```bash
java -cp "lib/a.jar:lib/b.jar:target/classes" com.example.Main
#           ^^^^^^^   ^^^^^^^   ^^^^^^^^^^^^^^
#           jar 包      jar 包    编译输出目录
```

### 2.4 classpath 的优先级

从左到右依次查找，找到就停止：
```
classpath = "target/classes:lib/helper.jar:~/.m2/repository/org/example/lib.jar"
            ^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            第1优先级         第2优先级           第3优先级
```

---

## 三、Maven 多模块项目结构

### 3.1 典型的多模块项目

```
yudao-project/
├── pom.xml                      # 父 POM，管理版本
├── yudao-common/               # 公共模块
├── yudao-framework/            # 框架模块
├── yudao-module-system/         # 系统模块
├── yudao-module-dcfee/         # 业务模块
└── yudao-server/               # 启动模块
```

### 3.2 模块间的依赖关系

```
yudao-server
    │
    ├── depends on yudao-module-dcfee
    │       │
    │       ├── depends on yudao-module-system
    │       │       │
    │       │       ├── depends on yudao-framework
    │       │       │       │
    │       │       │       └── depends on yudao-common
    │       │       │
    │       │       └── depends on yudao-framework
    │       │
    │       └── depends on yudao-framework
    │               │
    │               └── depends on yudao-common
    │
    └── depends on yudao-framework
            │
            └── depends on yudao-common
```

### 3.3 pom.xml 中的依赖声明

```xml
<!-- yudao-server/pom.xml -->
<dependencies>
    <dependency>
        <groupId>cn.iocoder.boot</groupId>
        <artifactId>yudao-module-dcfee</artifactId>
        <version>${revision}</version>
    </dependency>
</dependencies>
```

---

## 四、Maven Reactor 机制

### 4.1 什么是 Reactor

```
Reactor = Maven 的构建调度器
功能 = 分析依赖关系，确定构建顺序
```

**核心**：Reactor 在多模块项目中始终工作，与 `-am` 参数无关。

### 4.2 Reactor vs -am 的关系

| 情况 | Reactor 工作？ | 说明 |
|------|--------------|------|
| 多模块项目 | ✅ 始终工作 | 负责调度模块构建顺序 |
| `-pl xxx` | ✅ Reactor 工作 | 只构建指定模块 |
| `-pl xxx -am` | ✅ Reactor 工作 | 构建指定模块 + 所有依赖 |

```
Reactor = 多模块项目的构建调度器（始终工作）
    │
    ├── -pl = 指定构建范围
    │
    └── -am = 扩大构建范围到依赖项
```

**没有 -am，Reactor 仍然在工作**，只是构建范围不同。

### 4.2 Reactor 的输入输出

```
输入：模块间的依赖关系（从 pom.xml 读取）
         ↓
处理：拓扑排序，确定构建顺序
         ↓
输出：按正确顺序构建模块
```

### 4.3 Reactor 如何计算顺序

给定依赖关系：
```
yudao-server     depends on yudao-module-dcfee
yudao-module-dcfee depends on yudao-framework
yudao-framework depends on yudao-common
```

Reactor 拓扑排序结果：
```
1. yudao-common          # 没有依赖，最先构建
2. yudao-framework       # 依赖 common
3. yudao-module-dcfee     # 依赖 framework
4. yudao-server           # 依赖 dcfee，最后构建
```

### 4.4 Reactor Summary 示例

```
[INFO] Reactor Summary for yudao 2026.07-SNAPSHOT:
[INFO] 
[INFO] yudao .............................................. SKIPPED
[INFO] yudao-common ....................................... SUCCESS
[INFO] yudao-framework .................................... SUCCESS
[INFO] yudao-spring-boot-starter-mybatis .................... SUCCESS
[INFO] yudao-spring-boot-starter-security ................... SUCCESS
[INFO] yudao-module-system .................................. SUCCESS
[INFO] yudao-module-infra ................................. SUCCESS
[INFO] yudao-module-dcfee ................................. SUCCESS
[INFO] yudao-server ....................................... BUILDING
```

- `SKIPPED` = 父 POM，不单独构建
- `SUCCESS` = 构建成功
- `BUILDING` = 正在构建

---

## 五、参数详解

### 5.1 `-pl` (--projects)

```bash
# 只构建 yudao-server 模块
mvn clean install -pl yudao-server

# 构建多个模块
mvn clean install -pl yudao-server,yudao-module-dcfee
```

**作用**：告诉 Maven 只操作指定的模块，不涉及其他。

**注意**：如果依赖模块没编译过，会报错。

### 5.2 `-am` (--also-make)

```bash
# 构建 yudao-server 及其所有依赖
mvn clean install -pl yudao-server -am
```

**作用**：在 `-pl` 的基础上，同时构建**依赖项**。

### 5.3 -am 只处理项目内部模块

**两类依赖**：

| 类型 | 来源 | -am 处理？ |
|------|------|-----------|
| **项目内部模块** | pom.xml `<dependencies>` 中 groupId 为 cn.iocoder.boot | ✅ 会 |
| **第三方 jar** | pom.xml `<dependencies>` 如 spring-boot、mybatis | ❌ 不会 |

**说明**：

```xml
<!-- yudao-server/pom.xml -->
<dependencies>
    <!-- 项目内部模块依赖（-am 会处理）-->
    <dependency>
        <groupId>cn.iocoder.boot</groupId>     ← -am 会构建这个
        <artifactId>yudao-module-dcfee</artifactId>
    </dependency>

    <!-- 第三方依赖（-am 不会处理）-->
    <dependency>
        <groupId>org.springframework.boot</groupId>  ← -am 不管
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

### 5.4 -am 的展开

```bash
mvn spring-boot:run -pl yudao-server -am
```

等价于：
```bash
mvn spring-boot:run \
  -pl yudao-server,\
       yudao-module-dcfee,\
       yudao-module-system,\
       yudao-module-infra,\
       yudao-framework,\
       ...（所有项目内部模块）
```

**注意**：第三方依赖（spring-boot、mybatis 等）不在列表中，因为它们来自本地仓库，不需要重新构建。

---

## 六、spring-boot:run 详解

### 6.1 这是什么

`spring-boot:run` 是 **Spring Boot Maven 插件**的目标（goal）。

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

### 6.2 插件的目标列表

| 目标 | 作用 |
|------|------|
| `spring-boot:run` | 运行应用 ⭐ |
| `spring-boot:repackage` | 重新打包（生成可执行 jar） |
| `spring-boot:start` | 启动应用 |
| `spring-boot:stop` | 停止应用 |
| `spring-boot:build-image` | 构建 Docker 镜像 |

### 6.3 执行流程

```
mvn spring-boot:run
         │
         ├── 1. Maven Lifecycle
         │       validate → compile → test → package
         │
         ├── 2. 复制依赖到临时目录
         │
         └── 3. 启动 JVM
                 │
                 └── java -cp "..." SpringApplication.run()
```

### 6.4 classpath 如何构建

`spring-boot:run` 会构建 classpath：

```
classpath =
    target/classes/                                    # 当前模块的编译输出
  + target/dependency/*                              # 当前模块的依赖
  + ~/.m2/repository/.../xxx-1.0.jar                   # 本地仓库的依赖
```

---

## 七、关键问题：jar 包从哪里来？

### 7.1 两种 jar 来源

```
┌─────────────────────────────────────────────────────────┐
│                    classpath 的 jar 来源                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  来源1：本地仓库 (~/.m2/repository)                        │
│  ├── 之前 install 过                                       │
│  ├── mvn install -pl xxx -am 安装过                       │
│  └── 别人 deploy 的                                       │
│                                                          │
│  来源2：本地 target 目录                                   │
│  ├── 当前模块编译产生的 jar                                 │
│  └── -am 参数触发的依赖模块编译产生的 jar                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 7.2 有 -am vs 没有 -am

**没有 `-am`**：
```bash
mvn spring-boot:run -pl yudao-server
```
```
classpath:
├── target/yudao-server/classes/          ← 本地编译
├── ~/.m2/.../yudao-module-dcfee/1.0.jar  ← 本地仓库（可能是旧版）
├── ~/.m2/.../yudao-framework/1.0.jar      ← 本地仓库
└── ~/.m2/.../yudao-common/1.0.jar        ← 本地仓库
```

**有 `-am`**：
```bash
mvn spring-boot:run -pl yudao-server -am
```
```
classpath:
├── target/yudao-server/classes/          ← 本地编译
├── target/yudao-module-dcfee/classes/   ← 本地编译（新代码生效！）
├── target/yudao-module-system/classes/  ← 本地编译
├── target/yudao-framework/classes/      ← 本地编译
├── target/yudao-common/classes/        ← 本地编译
└── ~/.m2/...（其他不相关的依赖）
```

### 7.3 classpath 从左到右查找

**关键规则**：JVM 在 classpath 中**从左到右**查找，找到就停止。

```
classpath = "A:B:C"
           ^   ^   ^
           │   │   │
        先找A   │   │
          找到停止│   │
                ↓   ↓
```

### 7.4 有 -am vs 没有 -am 的区别

**没有 `-am`**：
```bash
mvn spring-boot:run -pl yudao-server
```
```
classpath:
├── target/yudao-server/classes/          ← 当前模块
├── ~/.m2/.../yudao-module-dcfee/       ← 本地仓库（可能是旧版）
├── ~/.m2/.../yudao-framework/          ← 本地仓库
└── ~/.m2/.../yudao-common/             ← 本地仓库
```

**有 `-am`**：
```bash
mvn spring-boot:run -pl yudao-server -am
```
```
classpath:
├── target/yudao-server/classes/          ← 当前模块
├── target/yudao-module-dcfee/classes/   ← 本地编译（新代码！）
├── target/yudao-module-system/classes/   ← 本地编译
├── target/yudao-framework/classes/       ← 本地编译
├── target/yudao-common/classes/          ← 本地编译
└── ~/.m2/...（其他第三方依赖）
```

### 7.5 为什么本地编译优先

```
classpath = "target/commons:本地仓库/dcfee.jar"
            ^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^
            左边（新代码）    右边（旧代码）

查找顺序：
1. 先在 target/commons 找
2. 找到了！停止查找
3. 不会去本地仓库
```

### 7.6 总结

| 命令 | classpath 内容 | 结果 |
|------|--------------|------|
| 有 `-am` | target/ 下有所有模块 | **新代码生效** |
| 没有 `-am` | 只有当前模块在 target/，依赖从仓库找 | 依赖可能是旧版 |

---

## 八、完整执行流程图

```
mvn spring-boot:run -pl yudao-server -am
            │
            ▼
┌───────────────────────────────────────────┐
│  1. Maven 解析命令                          │
│     -pl yudao-server                       │
│     -am (Also Make)                        │
└───────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────┐
│  2. Reactor 计算依赖树                     │
│                                           │
│     yudao-server                          │
│         │                                 │
│         ▼                                 │
│     yudao-module-dcfee                   │
│         │                                 │
│         ▼                                 │
│     yudao-framework → yudao-common        │
│     yudao-module-system → yudao-framework │
└───────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────┐
│  3. 按顺序编译模块                          │
│                                           │
│  [1] yudao-common          → classes/     │
│  [2] yudao-framework       → classes/     │
│  [3] yudao-spring-starters → classes/     │
│  [4] yudao-module-system   → classes/     │
│  [5] yudao-module-infra    → classes/     │
│  [6] yudao-module-dcfee   → classes/     │
│  [7] yudao-server          → classes/     │
└───────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────┐
│  4. 构建 classpath                        │
│                                           │
│  classpath =                              │
│    target/yudao-server/classes            │
│    target/yudao-module-dcfee/classes      │ ← 新编译！
│    target/yudao-module-system/classes     │ ← 新编译！
│    target/yudao-framework/classes          │ ← 新编译！
│    target/yudao-common/classes            │ ← 新编译！
│    ~/.m2/repository/...（其他第三方 jar）  │
└───────────────────────────────────────────┘
            │
            ▼
┌───────────────────────────────────────────┐
│  5. 启动 Spring Boot                      │
│                                           │
│  java -cp "classpath"                    │
│      org.springframework.boot.SpringApplication │
│          .run(YudaoServerApplication.class) │
└───────────────────────────────────────────┘
```

---

## 九、常见问题

### Q1: 改了代码为什么不生效？

**原因**：没有用 `-am`，用的是本地仓库的旧 jar。

**解决**：
```bash
# 方案1：用 -am 重新编译
mvn spring-boot:run -pl yudao-server -am

# 方案2：先 install 到本地仓库
mvn install -pl yudao-server -am
mvn spring-boot:run -pl yudao-server
```

### Q2: -am 和 -am后面的模块顺序有关系吗？

**没关系**。Reactor 会自动计算正确的顺序。

```bash
# 这两种写法效果一样
mvn spring-boot:run -pl yudao-server -am
mvn spring-boot:run -pl yudao-module-dcfee,yudao-server -am
```

### Q3: 如何查看 Reactor 的构建顺序？

```bash
mvn spring-boot:run -pl yudao-server -am -X | grep "Reactor Build Order"
```

### Q4: 可以只编译不打包吗？

```bash
mvn compile -pl yudao-server -am
```

这只编译，不打包，不运行。

---

## 十、总结

| 概念 | 说明 |
|------|------|
| **classpath** | JVM 查找 class 文件的路径列表 |
| **Reactor** | Maven 的构建调度器，自动计算模块依赖和构建顺序 |
| **-pl** | 指定要操作的项目（Project List） |
| **-am** | 同时构建依赖项（Also Make） |
| **spring-boot:run** | 编译 + 设置 classpath + 启动 JVM |
| **jar 来源** | 本地 target（高优先级） vs 本地仓库 |

**核心公式**：
```
mvn spring-boot:run -pl <模块> -am
         │
         ├── -pl = 指定要启动的模块
         │
         ├── -am = 自动构建所有依赖模块
         │
         └── 结果 = 本地新编译的 class 在 classpath 中优先加载
```

---

## 附录：命令速查表

| 场景 | 命令 |
|------|------|
| 开发启动（推荐） | `mvn spring-boot:run -pl yudao-server -am` |
| 只编译 | `mvn compile -pl yudao-server -am` |
| 打包 | `mvn package -pl yudao-server -am -DskipTests` |
| 安装到本地仓库 | `mvn install -pl yudao-server -am` |
| 跳过测试 | `mvn spring-boot:run -pl yudao-server -am -DskipTests` |
| 详细日志 | `mvn spring-boot:run -pl yudao-server -am -X` |
