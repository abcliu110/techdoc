<div id="chap-maven"></div>

[⬆️ 返回目录](#catalog)

## maven

作为一个资深程序员，你可能习惯了某些语言（如 C/C++）在链接阶段如果发现多个 `main` 函数会报错。但在 Java 的世界里，**`main` 方法不存在“冲突”这一说**。

这里有几个核心概念需要理清：

### 1. 核心原理：Java 的入口是“类”，而不是“方法”

在 C 语言中，`main` 是一个全局符号，链接器在构建可执行文件时要求它必须唯一。
但在 Java 中，`main` 方法必须依附于某个具体的类。启动 JVM 的命令是：
`java [参数] com.example.MyMainClass`

**JVM 根本不在乎你的 Classpath 路径下有多少个 `main` 方法**，它只在乎你启动命令里指定的那个 **“主类”（Main Class）**。

### 2. IDEA 是如何处理的？（Run Configuration）

当你右键点击某个类的 `main` 方法并选择 "Run" 时，IDEA 会自动为你创建一个 **Run/Debug Configuration**。

在该配置中，IDEA 明确指定了：

- **Main Class**: `com.foo.ModuleAMain`（这是你选中的那个类）
- **Classpath**: 包含当前模块、依赖模块、以及所有三方 JAR 包。

即使依赖的模块 `ModuleB` 也有一个 `com.bar.ModuleBMain`，IDEA 在启动命令里只会把 `com.foo.ModuleAMain` 传给 JVM。JVM 加载 `ModuleAMain` 后，只会寻找该类下的 `public static void main(String[] args)`。

### 3. 真正会产生冲突的情况：类路径冲突 (Classpath Shadowing)

虽然多个 `main` 方法不冲突，但如果 **全限定类名（包名+类名）** 冲突了，那才是真正的灾难。

假设：

- 你的主模块里有一个类：`com.common.Util`
- 你的依赖模块里也有一个类：`com.common.Util`

这种情况下，IDEA 的 Classpath 字符串里会同时包含这两个路径。根据 Java 的 **双亲委派机制** 和 **类加载器顺序**：

1.  AppClassLoader 会按照 Classpath 字符串里的先后顺序进行搜索。
2.  **谁排在前面，谁就被加载。** 排在后面的那个类将被完全“遮蔽”（Shadowing），永远不会被用到。

这通常被称为 **“Classpath Hell”（类路径地狱）**，是引起 `NoSuchMethodError` 或 `ClassNotFoundException` 的常见原因。

### 4. 扩展：可执行 JAR 包（Fat Jar）又是怎么回事？

当你用 Maven 插件（如 `maven-shade-plugin`）打成一个可执行的 JAR 包时，项目里可能有几百个 `main` 方法，为什么双击 JAR 包它知道运行哪一个？

这是因为在 `JAR` 包的 `META-INF/MANIFEST.MF` 文件中，有一行明确的定义：

```manifest
Main-Class: com.example.YourTargetMainClass
```

如果你在 `pom.xml` 里没有配置这个 `mainClass`，打出来的 JAR 包是无法直接 `java -jar` 运行的。

### 5. 总结资深程序员的视角

- **方法层面**：`main` 只是一个普通的静态方法，放在不同的类里互不干扰。
- **启动层面**：必须显式指定一个特定的类作为入口。
- **工程层面**：IDEA 通过 `Run Configuration` 隔离了不同的启动入口。
- **冲突风险**：关注 **全路径类名冲突**，而不是方法名冲突。

所以，在 Maven 多模块开发中，你可以每个模块都写一个 `main` 函数用来做单元测试或局部调试，这完全没有问题，也不会对最终的系统运行产生任何干扰。

在标准的 Spring Boot 项目中，Maven 并不是“自发”去寻找主类的，而是通过 **`spring-boot-maven-plugin`** 这个插件来完成主类的定位、打包和运行的。

作为资深程序员，我们需要从 **构建期（Package）** 和 **运行期（Run）** 两个维度来拆解 Maven 寻找主类的逻辑。

---

### 1. 运行期：`mvn spring-boot:run` 是如何找主类的？

当你执行这条命令时，`spring-boot-maven-plugin` 会介入。它的寻找逻辑如下（按优先级排序）：

1.  **显式配置**：它会检查 `pom.xml` 中插件的配置。如果你手动指定了 `<mainClass>`，它直接使用。
    ```xml
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <mainClass>com.example.MyApplication</mainClass>
        </configuration>
    </plugin>
    ```
2.  **查找 `start-class` 属性**：它会检查 Maven 的 `<properties>` 标签里是否定义了 `<start-class>`。
3.  **自动扫描（最常见）**：如果上面都没写，插件会扫描 `target/classes` 目录下的所有字节码文件。它会寻找一个包含 `public static void main(String[] args)` 且满足以下条件的类：
    - 通常带有 `@SpringBootApplication` 或 `@EnableAutoConfiguration` 注解。
    - 如果找到**唯一**一个带 `main` 方法的类，就选它。
    - 如果找到**多个**带 `main` 方法的类，且没有显式指定，Maven 运行会**报错**，提示你必须指定一个。

---

### 2. 构建期：`mvn package` 是如何写入主类的？

Spring Boot 的核心黑科技是 **Repackage（重新打包）**。

1.  **编译**：Maven 先把代码编译到 `target/classes`。
2.  **默认打包**：`maven-jar-plugin` 先打出一个普通的 JAR（这个 JAR 没法直接运行，里面没依赖）。
3.  **重打包 (Repackage)**：`spring-boot-maven-plugin` 接管。它会：
    - 把项目依赖的 JAR 包全部塞进这个 JAR 里的 `/lib` 目录下。
    - **寻找主类**：逻辑同上（扫描注解和 main 方法）。
    - **生成 MANIFEST.MF**：这是关键！它会在 JAR 包的 `META-INF/MANIFEST.MF` 中写入两行：
      ```manifest
      Main-Class: org.springframework.boot.loader.JarLauncher
      Start-Class: com.example.MyApplication  <-- 这里就是它找到的主类
      ```
    - **注意**：`Main-Class` 变成了 Spring Boot 的加载器，而你的类被放在了 `Start-Class`。

---

### 3. 标准 Maven 项目（非 Spring Boot）

如果你是一个**不使用** Spring Boot 框架的标准 Maven 项目，Maven 默认**根本不找主类**。

- 执行 `mvn package`：只会生成一个包含字节码的 JAR，里面没有 `Main-Class` 信息，无法通过 `java -jar` 运行。
- 如果你想让它找主类，你必须在 `maven-jar-plugin` 中手动告诉它：
  ```xml
  <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-jar-plugin</artifactId>
      <configuration>
          <archive>
              <manifest>
                  <mainClass>com.example.Main</mainClass>
              </manifest>
          </archive>
      </configuration>
  </plugin>
  ```

---

### 4. 深度追问：如果有多个类都有 `main` 方法且都有 `@SpringBootApplication` 怎么办？

这在多模块或测试代码中偶尔会发生。

- **命令行报错**：当你执行 `mvn spring-boot:run` 时，Maven 会直接罢工，报错提示：`TypeNotPresentException: ... found multiple declarations of main classes`。
- **解决方案**：
  1.  在 `pom.xml` 的插件配置中通过 `<mainClass>` 锁定。
  2.  或者在执行命令时动态指定：
      `mvn spring-boot:run -Dspring-boot.run.main-class=com.example.SpecificMain`

### 总结资深程序员的认知：

1.  **Maven 本身不具备“找主类”的语义**，它只是一个构建生命周期的管理者。
2.  **Spring Boot 插件通过“约定优于配置”**，自动扫描 `target/classes` 中带有特殊注解的 `main` 方法。
3.  **结果固化在 MANIFEST.MF**：寻找的结果最终通过修改 JAR 包的元数据（MANIFEST 文件）来实现生产环境的可执行性。
4.  **IDEA 的运行逻辑**：IDEA 在运行 Spring 项目时，其实是绕过了 Maven 的这种寻找机制，它直接根据你当前鼠标点击的类或 `Run Configuration` 中选中的类，拼装 `java -cp` 命令。只有当你通过命令行 `mvn` 运行时，上述逻辑才生效。

这是一个非常深入且核心的 Maven 机制问题。作为资深程序员，我们要透视 Maven 的**生命周期（Lifecycle）**、**插件绑定（Plugin Binding）**以及**仓库解析机制**。

你的 `pom.xml` 中只写了简单的几行，但背后发生了很多“隐形”的操作。

---

### 1. Maven 在哪个阶段执行这个插件？

这个插件最核心的目标（Goal）是 `repackage`（将普通 JAR 改造成可执行的 Fat JAR）。

- **默认绑定阶段**：`spring-boot-maven-plugin` 的 `repackage` 目标默认绑定在 Maven 生命周期的 **`package`** 阶段。
- **执行顺序**：在执行 `mvn package` 命令时，Maven 会按顺序触发：
  1.  `compiler:compile` (编译源码)
  2.  `surefire:test` (单元测试)
  3.  `jar:jar` (打成普通 JAR)
  4.  **`spring-boot:repackage`** (这就是该插件介入的时刻)

**关键点：** 它是在 `maven-jar-plugin` 生成了标准的、不可执行的 JAR 之后，再跑出来把那个 JAR 拆开，把依赖塞进去，重新封装成一个带 `JarLauncher` 的 Fat JAR。

---

### 2. Maven 是如何执行这个插件的？（底层逻辑）

当你运行 `mvn package` 时，Maven 的执行引擎（Maven Core）会扫描所有配置的插件：

1.  **插件目标（Goal）解析**：Maven 插件是由多个“目标”组成的。对于 Spring Boot 插件，它包含 `run`、`repackage`、`start`、`stop` 等。
2.  **生命周期绑定**：Maven 会查看该插件内部的 `@Phase` 注解。在 `spring-boot-maven-plugin` 的源码中，`repackage` 目标标注了它属于 `package` 阶段。
3.  **Fork 生命周期（可选）**：有些插件目标（如 `spring-boot:run`）会 fork 一个新的生命周期来确保代码已经编译。
4.  **类加载器隔离**：Maven 会为这个插件创建一个独立的 `ClassRealm`（类空间），加载插件所需的依赖，然后调用插件类中的 `execute()` 方法。

---

### 3. Maven 怎么知道这个插件在哪里？

这就是 Maven 的 **坐标（Coordinates）** 与 **仓库（Repository）** 机制。

#### (1) 坐标搜索

你虽然只写了：

```xml
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-maven-plugin</artifactId>
```

但 Maven 需要三个要素才能定位文件：`groupId` : `artifactId` : `version`。

- **版本号（Version）去哪了？**
  如果你使用了 `spring-boot-starter-parent` 作为父工程，父工程里的 `<pluginManagement>` 已经帮你定义好了版本号。Maven 会自动继承这个版本。
- **如果没有父工程？**
  Maven 会尝试去本地和远程仓库找最新的版本（但这会导致构建不稳定，通常不建议这么做）。

#### (2) 物理路径查找

Maven 会按以下顺序寻找插件的 `.jar` 文件：

1.  **本地仓库**：`~/.m2/repository/org/springframework/boot/spring-boot-maven-plugin/[version]/...`
2.  **远程仓库（Mirror）**：如果你配置了阿里镜像或公司私服，它会去那里下载。
3.  **Maven Central**：如果配置中都没有，最后去中央仓库下载。

---

### 4. 深度细节：为什么你的配置能生效？（资深程序员必知）

在 Maven 的逻辑里，**仅仅把插件放在 `<plugins>` 标签下，并不代表它一定会执行。**

通常需要这样配置：

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal> <!-- 显式声明执行这个目标 -->
            </goals>
        </execution>
    </executions>
</plugin>
```

**但是为什么你没写 `<executions>` 也能成功？**

这是因为 Spring Boot 的 **`spring-boot-starter-parent`** 在其内部已经预设了这一段配置。你写的那几行 XML 实际上是在**激活**父工程中预定义的插件配置。

### 5. 总结

1.  **阶段**：绑定在 `package` 阶段，在普通 JAR 生成之后执行。
2.  **执行方式**：Maven 通过反射调用插件内部的 `repackage` 逻辑，处理 `target` 目录下的文件。
3.  **查找位置**：通过 GAV 坐标在本地 `.m2` 仓库或远程仓库中定位 `.jar` 插件包。
4.  **魔法来源**：大部分自动化行为归功于 `spring-boot-starter-parent` 预做的配置，它遵循了 Maven 的“约定优于配置”原则。
5.

这是一个非常深入且核心的 Maven 机制问题。作为资深程序员，我们要透视 Maven 的**生命周期（Lifecycle）**、**插件绑定（Plugin Binding）**以及**仓库解析机制**。

你的 `pom.xml` 中只写了简单的几行，但背后发生了很多“隐形”的操作。

---

### 1. Maven 在哪个阶段执行这个插件？

这个插件最核心的目标（Goal）是 `repackage`（将普通 JAR 改造成可执行的 Fat JAR）。

- **默认绑定阶段**：`spring-boot-maven-plugin` 的 `repackage` 目标默认绑定在 Maven 生命周期的 **`package`** 阶段。
- **执行顺序**：在执行 `mvn package` 命令时，Maven 会按顺序触发：
  1.  `compiler:compile` (编译源码)
  2.  `surefire:test` (单元测试)
  3.  `jar:jar` (打成普通 JAR)
  4.  **`spring-boot:repackage`** (这就是该插件介入的时刻)

**关键点：** 它是在 `maven-jar-plugin` 生成了标准的、不可执行的 JAR 之后，再跑出来把那个 JAR 拆开，把依赖塞进去，重新封装成一个带 `JarLauncher` 的 Fat JAR。

---

### 2. Maven 是如何执行这个插件的？（底层逻辑）

当你运行 `mvn package` 时，Maven 的执行引擎（Maven Core）会扫描所有配置的插件：

1.  **插件目标（Goal）解析**：Maven 插件是由多个“目标”组成的。对于 Spring Boot 插件，它包含 `run`、`repackage`、`start`、`stop` 等。
2.  **生命周期绑定**：Maven 会查看该插件内部的 `@Phase` 注解。在 `spring-boot-maven-plugin` 的源码中，`repackage` 目标标注了它属于 `package` 阶段。
3.  **Fork 生命周期（可选）**：有些插件目标（如 `spring-boot:run`）会 fork 一个新的生命周期来确保代码已经编译。
4.  **类加载器隔离**：Maven 会为这个插件创建一个独立的 `ClassRealm`（类空间），加载插件所需的依赖，然后调用插件类中的 `execute()` 方法。

---

### 3. Maven 怎么知道这个插件在哪里？

这就是 Maven 的 **坐标（Coordinates）** 与 **仓库（Repository）** 机制。

#### (1) 坐标搜索

你虽然只写了：

```xml
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-maven-plugin</artifactId>
```

但 Maven 需要三个要素才能定位文件：`groupId` : `artifactId` : `version`。

- **版本号（Version）去哪了？**
  如果你使用了 `spring-boot-starter-parent` 作为父工程，父工程里的 `<pluginManagement>` 已经帮你定义好了版本号。Maven 会自动继承这个版本。
- **如果没有父工程？**
  Maven 会尝试去本地和远程仓库找最新的版本（但这会导致构建不稳定，通常不建议这么做）。

#### (2) 物理路径查找

Maven 会按以下顺序寻找插件的 `.jar` 文件：

1.  **本地仓库**：`~/.m2/repository/org/springframework/boot/spring-boot-maven-plugin/[version]/...`
2.  **远程仓库（Mirror）**：如果你配置了阿里镜像或公司私服，它会去那里下载。
3.  **Maven Central**：如果配置中都没有，最后去中央仓库下载。

---

### 4. 深度细节：为什么你的配置能生效？（资深程序员必知）

在 Maven 的逻辑里，**仅仅把插件放在 `<plugins>` 标签下，并不代表它一定会执行。**

通常需要这样配置：

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal> <!-- 显式声明执行这个目标 -->
            </goals>
        </execution>
    </executions>
</plugin>
```

**但是为什么你没写 `<executions>` 也能成功？**

这是因为 Spring Boot 的 **`spring-boot-starter-parent`** 在其内部已经预设了这一段配置。你写的那几行 XML 实际上是在**激活**父工程中预定义的插件配置。

### 5. 总结

1.  **阶段**：绑定在 `package` 阶段，在普通 JAR 生成之后执行。
2.  **执行方式**：Maven 通过反射调用插件内部的 `repackage` 逻辑，处理 `target` 目录下的文件。
3.  **查找位置**：通过 GAV 坐标在本地 `.m2` 仓库或远程仓库中定位 `.jar` 插件包。
4.  **魔法来源**：大部分自动化行为归功于 `spring-boot-starter-parent` 预做的配置，它遵循了 Maven 的“约定优于配置”原则。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-maven)
