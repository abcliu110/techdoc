<div id="chap-APT"></div>

[⬆️ 返回目录](#catalog)

## APT

作为资深程序员，我非常乐意为你介绍 **MyBatis-Flex**。

如果说原生 MyBatis 是“手动挡”，MyBatis-Plus 是“自动挡”，那么 **MyBatis-Flex** 就像是“全自动驾驶的特斯拉”。它是近两年异军突起的一个框架，核心设计哲学是 **“极致流畅（Flex）”** 和 **“编译期安全”**。

在 MyBatis-Plus 逐渐变得臃肿、且对多表联查支持较弱的背景下，MyBatis-Flex 凭借其**链式 API** 和**强大的 APT（自动代码生成）** 机制，成为了很多新项目的首选。

---

### 一、 核心概念：为什么选 MyBatis-Flex？

1.  **强类型检查（APT 技术）**：在写查询条件时，你不需要写字符串字段名（如 `"user_name"`），而是直接引用生成的类属性（如 `USER.USER_NAME`）。如果数据库改了字段名，编译直接报错，不用等到运行时。
2.  **极简的联表查询**：它把复杂的 Join 变成了非常直观的流式代码。
3.  **零插件实现分页与多租户**：内置支持，性能更好。

---

### 二、 快速上手步骤

#### 1. 引入依赖

在 Spring Boot 项目的 `pom.xml` 中引入：

```xml
<dependency>
    <groupId>com.mybatisflex</groupId>
    <artifactId>mybatis-flex-spring-boot-starter</artifactId>
    <version>1.8.2</version>
</dependency>
```

#### 2. 开启 APT 插件（关键步骤）

MyBatis-Flex 会根据你的实体类自动生成一个 `TableDef` 类（类似于查询手册）。你需要在 Maven 中配置编译插件：

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <annotationProcessorPaths>
            <path>
                <groupId>com.mybatisflex</groupId>
                <artifactId>mybatis-flex-processor</artifactId>
                <version>1.8.2</version>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

#### 3. 定义实体类

```java
@Table("tb_account")
public class Account {
    @Id(keyType = KeyType.Auto)
    private Long id;
    private String userName;
    private Integer age;
    private LocalDateTime birthday;
    // getter setter...
}
```

**编译后：** 框架会自动生成一个 `AccountTableDef` 类（通常简写为 `ACCOUNT`），这是后续写 SQL 的核心。

---

### 三、 实战使用（资深开发者的姿势）

#### 1. 基础 CRUD

Mapper 接口继承 `BaseMapper`，这和 MyBatis-Plus 一样：

```java
@Mapper
public interface AccountMapper extends BaseMapper<Account> {
    // 基础的增删改查已经自动拥有了
}
```

#### 2. 核心：流畅的 QueryWrapper（查询）

这是 MyBatis-Flex 最爽的地方。不需要拼 SQL，也不需要拼字符串：

```java
@Autowired
private AccountMapper accountMapper;

public void demo() {
    // 引入自动生成的静态变量
    import static com.example.entity.table.AccountTableDef.ACCOUNT;

    QueryWrapper query = QueryWrapper.create()
        .select(ACCOUNT.ID, ACCOUNT.USER_NAME)
        .where(ACCOUNT.AGE.ge(18)) // age >= 18
        .and(ACCOUNT.USER_NAME.like("张"))
        .orderBy(ACCOUNT.ID.desc());

    List<Account> accounts = accountMapper.selectListByQuery(query);
}
```

#### 3. 强大的联表查询 (Join)

这是它超越 MyBatis-Plus 的杀手锏：

```java
QueryWrapper query = QueryWrapper.create()
    .select(ACCOUNT.ALL_COLUMNS, ROLE.ROLE_NAME)
    .from(ACCOUNT)
    .leftJoin(ROLE).on(ACCOUNT.ROLE_ID.eq(ROLE.ID))
    .where(ROLE.ROLE_NAME.eq("管理员"));

List<AccountVO> list = accountMapper.selectListByQueryAs(query, AccountVO.class);
```

---

### 四、 技术原理浅析（Senior Level）

你可能会好奇，它是怎么做到的？

1.  **APT (Annotation Processing Tool)**：
    - 在编译阶段（按编译按钮时），MyBatis-Flex 的处理器会扫描 `@Table` 注解，自动生成 `.java` 源代码（即 `TableDef`）。
    - **原理**：它利用了 Java 编译器的 Hook，在代码变二进制之前多做了一步。

2.  **SQL 构建引擎**：
    - 当你写 `ACCOUNT.AGE.ge(18)` 时，它内部其实是在构建一个抽象语法树（AST）。
    - 最终在执行前，MyBatis-Flex 会把这棵树翻译成标准的 `SELECT ... WHERE age >= ?`，并交给原生的 MyBatis 执行。

3.  **对 Spring 事务的支持**：
    - 它完全复用了 `mybatis-spring` 的逻辑。它的 `BaseMapper` 最终还是调用的 `SqlSessionTemplate`。
    - **原理**：它只是在 SQL 进入 MyBatis 执行前，做了一层高级的“预处理”和“包装”。

---

### 五、 资深程序员建议：选 MyBatis 还是 MyBatis-Flex？

- **如果你的项目 SQL 极其变态**（比如几百行的金融报表 SQL）：建议回归 **原生 MyBatis 写 XML**，因为 XML 维护复杂 SQL 最清晰。
- **如果你的项目追求开发效率、字段经常变动**：强力推荐 **MyBatis-Flex**。它的编译期检查能帮你规避 90% 的低级 SQL 错误。
- **对比 MyBatis-Plus**：MyBatis-Flex 更轻量，多表联查更优雅，且没有 MP 那么重的“各种插件”历史包袱。

**一句话总结：**
MyBatis-Flex 是用 **Java 代码的逻辑** 代替了 **XML 的字符串**，通过编译器的力量确保了 SQL 的正确性。

这个问题问得非常精准！你抓住了**编译期检查**的核心点。

很多开发者初听“数据库改了字段名，编译直接报错”会觉得不可思议：数据库的变化怎么可能直接影响到 Java 程序的编译？

其实，这里的“报错”发生在一个**特定的开发链路**中。作为资深程序员，我为你拆解这个“连锁反应”发生的具体场景：

---

### 1. 核心链路：APT 是如何工作的？

首先，你要理解 **APT (Annotation Processing Tool)** 是在编译时多加的一个步骤：

1.  **定义实体**：你写了一个 `User.java`，里面有一个属性叫 `userName`。
2.  **触发编译**：你按下编译按钮（或执行 `mvn compile`）。
3.  **APT 介入**：MyBatis-Flex 的插件扫描到 `User.java`，**自动在内存/生成目录**产生一个新的 Java 类，叫 `UserTableDef.java`（里面定义了一个常量 `public static final QueryColumn USER_NAME = ...`）。
4.  **业务代码引用**：你在 Service 里写 `query.where(USER.USER_NAME.eq("张三"))`。

---

### 2. 报错场景模拟（对比实验）

#### 场景 A：使用 MyBatis-Plus 或原生 MyBatis（基于字符串）

- **代码**：`queryWrapper.eq("user_name", "张三")`
- **动作**：数据库字段从 `user_name` 改成了 `login_name`。你同步把实体类里的属性也改成了 `loginName`。
- **结果**：此时，你代码里的字符串 `"user_name"` **依然是有效的字符串**。编译器（Java 编译器）认为这段代码完全合法。
- **后果**：**编译通过**，但在程序跑起来查数据库时，控制台报错：`Column 'user_name' not found`。

#### 场景 B：使用 MyBatis-Flex（基于 APT 强类型）

- **代码**：`query.where(USER.USER_NAME.eq("张三"))`
- **动作**：数据库字段改了，你同步把实体类 `User.java` 里的属性从 `userName` 改成了 `loginName`。
- **触发报错的机制**：
  1.  你再次编译。
  2.  MyBatis-Flex 的 APT 重新扫描 `User.java`。
  3.  因为它发现属性名变了，它生成的 `UserTableDef.java` 里，**原来的 `USER_NAME` 属性消失了**，取而代之的是新生成的 `LOGIN_NAME`。
  4.  **编译器立刻尖叫**：你的业务代码里引用的 `USER.USER_NAME` 现在指向了一个**不存在的变量**！

**报错信息如下：**

> `Error: cannot find symbol`
> `symbol:   variable USER_NAME`
> `location: class com.example.entity.table.UserTableDef`

---

### 3. 这为什么是“资深程序员”眼中的神器？

这种报错在以下两种场景下价值连城：

#### 场景一：大型项目的重构（Refactoring）

在一个有 500 个类的项目里，如果你要把 `user_name` 改成 `login_name`。

- **字符串模式**：你要在全局搜字符串 `"user_name"`。万一漏掉一处，就是线上 Bug。
- **Flex 模式**：你只改实体类一个地方，然后全局点“编译”。**编译器会自动帮你找出全项目所有需要修改的地方**（因为没改的地方都会报红线）。这就是所谓的**“编译器驱动重构”**。

#### 场景二：多人协作

同事 A 修改了数据库字段并提交了代码。你拉取代码后，如果你之前的代码引用的旧字段已经不存在了，你的 IDE 会立刻满屏飘红，**根本不给你部署上线运行报错的机会**。

---

### 总结

**“编译报错”的前提是：你修改了实体类（Entity）来匹配数据库的变化。**

MyBatis-Flex 通过 APT 把 **“实体类”** 和 **“查询逻辑”** 深度绑定了。只要实体类一动，查询代码如果不同步动，编译器就不答应。这把原本属于“运行时”的风险，提前在“编译时”就彻底消灭了。这就是强类型语言（Java）结合 APT 技术的威力所在。

为了让你看清“**强类型检查**”到底是怎么保命的，我们来模拟一个真实的开发场景：**字段重命名**。

---

### 第一阶段：正常开发（一切顺利）

#### 1. 你定义了实体类

你写了一个 `Student` 类，字段叫 `name`。

```java
@Table("tb_student")
public class Student {
    @Id
    private Long id;
    private String name; // 这里的属性名是 name
    // ... getter setter
}
```

#### 2. MyBatis-Flex 自动为你生成了“影子类”

当你按下编译键，APT 会在后台偷偷生成一个类 `StudentTableDef.java`。内容大概长这样：

```java
// 这是自动生成的，你不需要写
public class StudentTableDef extends TableDef {
    public final QueryColumn NAME = new QueryColumn(this, "name");
    public static final StudentTableDef STUDENT = new StudentTableDef();
}
```

#### 3. 你在 Service 里写查询逻辑

```java
// 这里的 STUDENT.NAME 是有代码提示的，非常顺滑
List<Student> list = studentMapper.selectListByQuery(
    QueryWrapper.create().where(STUDENT.NAME.eq("张三"))
);
```

---

### 第二阶段：需求变更（危机降临）

老板说：数据库里的 `name` 字段太模糊了，统一改成 `full_name`。

#### 1. 你修改了实体类（Entity）

你作为负责任的程序员，修改了代码以匹配数据库：

```java
@Table("tb_student")
public class Student {
    @Id
    private Long id;
    private String fullName; // 你把 name 改成了 fullName
}
```

#### 2. 关键点：MyBatis-Flex 自动更新“影子类”

当你再次触发编译（或者 IDE 自动保存编译），APT 会重新扫描 `Student` 类。
因为旧的 `name` 属性没了，新的影子类变成了：

```java
// 自动更新后的影子类
public class StudentTableDef extends TableDef {
    // 原来的 NAME 变量消失了！
    public final QueryColumn FULL_NAME = new QueryColumn(this, "full_name");
    public static final StudentTableDef STUDENT = new StudentTableDef();
}
```

---

### 第三阶段：编译报错（救你一命）

这时候，你之前写的那些查询代码（还没来得及改的部分）会发生什么？

**在你的 Service 类里：**

```java
List<Student> list = studentMapper.selectListByQuery(
    QueryWrapper.create().where(STUDENT.NAME.eq("张三"))
                                   // ^^^ 此时这里会立刻飘红！
);
```

**编译控制台会直接报错：**

> `[ERROR] /Users/dev/UserService.java:[45,35] 找不到符号`
> `  符号:   变量 NAME`
> `  位置:   类 com.example.entity.table.StudentTableDef`

---

### 资深程序员的深度对比

为什么我们要强调这是“强类型”的好处？对比一下 **MyBatis-Plus** 或 **原生 MyBatis**：

#### 1. MyBatis-Plus 的隐患（基于字符串）

如果你用的是 MP，你的代码可能是：

```java
queryWrapper.eq("name", "张三"); // "name" 是一个硬编码字符串
```

当你修改了数据库和实体类后，**Java 编译器根本不知道这个 `"name"` 字符串代表什么**。

- **结果**：项目成功打包、成功上线。
- **下场**：用户访问页面时，程序执行到这一行，数据库报错 `Unknown column 'name' in 'where clause'`。这时你可能正在休假，却不得不打开电脑改 Bug。

#### 2. MyBatis-Flex 的优势（基于引用）

因为你引用的是 `STUDENT.NAME` 这个**实实在在的变量**：

- **结果**：只要字段一改，所有引用旧变量的地方**全部编译失败**。
- **价值**：你根本没法把带 Bug 的代码打包上线。编译器强迫你在发布前，把所有受影响的代码全部改正确。

---

### 总结：报错的本质

**报错不是因为数据库连不上，而是因为“影子类”里的变量名变了，导致你的 Java 代码在语法层面上就不成立了。**

这就是资深程序员常说的：**“能把错误暴露在编译期的框架，才是好框架。”** 因为运行时报错（Runtime Error）可能发生在凌晨三点，而编译期报错（Compile Error）只发生在你的开发阶段。

这个问题问到了 MyBatis-Flex 设计的灵魂。作为资深开发，我必须告诉你：这不仅仅是代码风格的问题，而是一套**“元数据模型（Meta Model）”**的设计哲学。

我们拆开来解释：**为什么用大写？** 以及 **为什么它们是类的字段？**

---

### 一、 为什么是大写？（约定与语义区分）

在 Java 编程中，全大写通常代表 **`public static final`（常量）**。MyBatis-Flex 这样设计有三个初衷：

1.  **区分“数据”与“结构”**：
    - `student.getName()`：这是**数据**。代表某个具体学生的姓名（如“张三”）。
    - `STUDENT.NAME`：这是**结构**。代表数据库表里的那根**列（Column）**。
    - 全大写让你在看代码时，一眼就能分清：哪些是在操作逻辑，哪些是在引用数据库结构。

2.  **模拟 SQL 体验**：
    - 在 SQL 标准中，表名和列名通常不区分大小写，且在文档和工具中经常以大写展示（如 `SELECT NAME FROM TB_STUDENT`）。使用大写变量名，会让写代码的体感更接近原生 SQL。

3.  **防止命名冲突**：
    - 你的实体类里可能有一个属性叫 `case`（虽然不建议），Java 里 `case` 是关键字。如果生成小写的 `student.case` 会很麻烦，但生成大写的 `STUDENT.CASE` 就避开了可能的变量命名冲突。

---

### 二、 为什么设计成“类的字段”？（对象化 SQL）

这是最关键的技术实现。你要明白：**`STUDENT.NAME` 并不是一个字符串，它是一个对象。**

#### 1. 看看生成的代码背后是什么

当你看到 `STUDENT.NAME` 时，它在自动生成的类里长这样：

```java
// 这是 MyBatis-Flex 自动生成的代码片段
public class StudentTableDef extends TableDef {

    // 1. STUDENT 是这个类的静态实例（单例）
    public static final StudentTableDef STUDENT = new StudentTableDef();

    // 2. NAME 是一个 QueryColumn 类型的对象字段
    public final QueryColumn NAME = new QueryColumn(this, "name");

    // ...
}
```

#### 2. 为什么要设计成对象字段？（为了链式调用）

如果 `NAME` 只是一个字符串（`"name"`），你只能写 `eq("name", value)`。
但因为 `NAME` 是一个 **`QueryColumn` 对象**，它可以拥有方法！

当你写 `STUDENT.NAME.eq("张三")` 时：

- 调用了 `NAME` 对象的 `.eq()` 方法。
- 这个方法会返回一个 `QueryCondition` 对象。
- 这个对象内部记录了：列名是 `name`，操作符是 `=`，值是 `张三`。

**这就是“对象化 SQL”：用操作对象的方式，替代了拼凑字符串。**

---

### 三、 深度对比：实体类 vs 影子类

作为资深程序员，你可以这样理解这两者的分工：

| 特性         | 实体类 (`Student.java`)        | 影子类 (`StudentTableDef.java`)         |
| :----------- | :----------------------------- | :-------------------------------------- |
| **角色**     | **搬运工**（承载数据）         | **地图**（描述数据库结构）              |
| **字段类型** | `String`, `Integer` 等基本类型 | `QueryColumn` (MyBatis-Flex 特有类型)   |
| **使用场景** | `new Student()`, 接收查询结果  | `QueryWrapper.where(...)`, 编写查询逻辑 |
| **生成方式** | 手写或工具生成一次             | **每次编译时由 APT 自动更新**           |

---

### 四、 这种设计带来的极致体验

正因为 `NAME` 是一个类的字段（对象），你在 IDE（如 IntelliJ IDEA）里写代码时，会享受到：

1.  **自动补全**：输入 `STUDENT.` 后面会自动弹出 `NAME`, `AGE`, `ID`。你不需要翻数据库表结构，IDE 全告诉你了。
2.  **一键跳转**：按住 Ctrl/Command 点击 `NAME`，可以直接跳到对应的实体类属性。
3.  **安全重构**：如前所述，如果你在实体类改了名，这个字段就会变，导致代码报错。

### 总结

`STUDENT.NAME` 采用 **大写静态常量字段** 的形式，本质上是把 **SQL 的元数据（表和列）映射成了 Java 的对象树**。

它让你在 Java 代码里写的每一行查询，都在编译阶段被 Java 强类型系统死死地保护着。这正是 MyBatis-Flex 敢自称为“极致流畅”的核心原因。

这个问题问得非常专业。作为资深程序员，我带你深入到 Java 编译器的内部“流水线”去看一看。

这种技术统称为 **APT（Annotation Processing Tool，注解处理工具）**。它不是在运行时（Runtime）起作用，而是在**编译期（Compile time）**起作用。

---

### 一、 IDE 什么时候调用这个插件？

IDE 并不是随意调用插件，它遵循 Java 编译器的标准规范（JSR 269）。调用的时机非常精准：

#### 1. 触发时机：

- **手动构建**：当你点击 `Build -> Build Project` 或执行 `mvn compile` 时。
- **自动保存（增量编译）**：在 IntelliJ IDEA 中，如果你开启了 `Build project automatically`，每当你修改了一个 `.java` 文件并停顿几百毫秒，IDE 就会在后台启动一次“增量编译”。

#### 2. 编译流水线中的位置：

Java 编译器的整个过程像是一个**循环（Round）**：

1.  **解析与填充符号表**：编译器读取你的 `User.java`，识别出它带有一个 `@Table` 注解。
2.  **调用注解处理器（APT 介入）**：编译器发现 MyBatis-Flex 注册了对 `@Table` 的关注。于是，编译器把 `User.java` 的结构信息交给 MyBatis-Flex 插件。
3.  **生成新代码**：MyBatis-Flex 根据这些信息，在硬盘上写下 `UserTableDef.java`。
4.  **循环处理**：**关键点来了！** 编译器发现有新的 `.java` 文件产生，它会开启**下一轮循环**，去编译这个新生成的 `UserTableDef.java`。
5.  **生成字节码**：直到没有新的文件产生，编译器才把所有的 `.java` 统一变成 `.class`。

**一句话总结**：只要你改了代码并触发了编译，编译器就会自动拉起 APT 插件进行“脑补”。

---

### 二、 这种技术还用在什么地方？

APT 技术是现代 Java 开发的“幕后英雄”，几乎所有追求**高性能**和**类型安全**的顶级框架都在用它。

#### 1. Lombok（最广为人知）

- **用途**：生成 Getter/Setter, Builder, NoArgsConstructor 等。
- **原理**：Lombok 比较特殊，它不仅生成代码，还直接**修改**原有的抽象语法树（AST）。虽然它比标准 APT 更暴力，但核心时机也是在编译期。

#### 2. MapStruct（对象拷贝神器）

- **用途**：在 POJO 和 DTO 之间进行属性拷贝。
- **为什么用它**：普通的 `BeanUtils.copyProperties` 使用的是**反射**，性能差且容易出错。MapStruct 在编译时直接生成 `target.setName(source.getName())` 这种原生代码。
- **体验**：你定义一个接口，编译后它自动生成实现类。

#### 3. Dagger 2 / Hilt（依赖注入）

- **用途**：主要用于 Android 开发中的依赖注入（DI）。
- **对比**：Spring 的 DI 主要是运行时反射，而 Dagger 2 在编译时就计算好了对象之间的依赖关系图，并生成好了注入代码。
- **优势**：在手机这种内存敏感的设备上，编译期生成的代码比运行时反射快得多，且省电。

#### 4. Spring Boot Configuration Processor

- **用途**：生成自定义配置文件的元数据。
- **体验**：你在 `application.yml` 里写自定义配置时，IDE 能给你自动提示，就是因为这个处理器在编译时生成了一个 `spring-configuration-metadata.json` 文件。

#### 5. Querydsl / JOOQ

- **用途**：和 MyBatis-Flex 类似，它们也是为了实现“强类型 SQL”。
- **特点**：它们会扫描你的数据库表结构或实体类，生成 `QUser` 或 `TUser` 这样的类，让你能像写 Java 代码一样写 SQL。

---

### 三、 为什么资深开发喜欢 APT 胜过“反射”？

如果你问一个资深程序员为什么要用这种技术，他会告诉你三个不可替代的理由：

1.  **性能（Performance）**：
    - 反射（Reflection）是在程序运行时去“猜”那个字段叫什么，非常耗 CPU。
    - APT 是在编译时直接把代码写死。运行生成的代码，速度和手写的一模一样。
2.  **提前发现错误（Fail-Fast）**：
    - 反射错误只能在程序跑起来、用户点击页面时才发现（Crash）。
    - APT 错误在编译时就会让你的进度条变红。**“把 Bug 扼杀在摇篮里”**。
3.  **代码即文档**：
    - 生成的 `UserTableDef.java` 是可以阅读的源码。当你不确定框架做了什么，直接点进去看生成的代码，没有秘密。

### 总结

APT 技术本质上是**“让机器写代码给机器看”**。它让 Java 这种略显笨重的静态语言，拥有了极强的动态能力和开发效率，同时又不损失一丁点性能。

这是一个非常深刻的问题。虽然 **Lombok** 和 **MyBatis-Flex** 都使用了注解处理技术，但从技术底层实现来看，Lombok 属于**“黑科技”**，而 MyBatis-Flex 属于**“正规军”**。

作为资深程序员，我带你从 **JSR 269 规范**、**AST 抽象语法树** 和 **编译流程** 三个维度拆解它们的本质区别。

---

### 1. 核心区别：生成的“目的地”不同

这是两者最直观的区别：

- **MyBatis-Flex (标准 APT)**：
  - **原则**：只准新建，不准修改。
  - **行为**：它读取你的 `User.java`，然后在另一个地方生成一个全新的 `UserTableDef.java`。
  - **结果**：你最终拥有两个独立的源文件。

- **Lombok (非标准黑科技)**：
  - **原则**：直接修改你的源代码。
  - **行为**：它读取你的 `User.java`，发现上面有 `@Data`，它会直接在这个类的**内存结构（AST）**里强行插入 `getName()`、`setName()` 等方法。
  - **结果**：你只有一个 `User.java` 文件，但在编译后的 `User.class` 字节码里，方法已经全在那了。

---

### 2. 技术实现：合法 vs 越界

Java 的注解处理规范（JSR 269）其实有一条铁律：**注解处理器只能创建新的源文件，不能修改现有的源文件。**

#### MyBatis-Flex 的实现（合法守信）：

它严格遵守 JSR 269 规范。编译器给它看一眼 `User.java`，它写出一份 `UserTableDef.java`。这是 Java 官方允许的标准操作。所以它**不需要**任何 IDE 插件，只要 IDE 识别了生成的目录，一切都能正常工作。

#### Lombok 的实现（暴力入侵）：

Lombok 觉得“只能新建”太笨了，它想直接改你的类。

- **它是怎么做的？** 它通过绕过公共 API，直接调用 Java 编译器的内部私有接口（针对 `javac` 和 `ecj` 做专门的适配）。
- **篡改 AST**：它在编译器把代码变成字节码之前的“解析阶段”，直接修改了**抽象语法树（AST）**。它强行往树的节点上挂载新的方法节点。
- **代价**：因为这种做法是不合法的“越界”行为，Java 官方编译器并不认可。这就是为什么你必须在 IntelliJ IDEA 里安装 **Lombok 插件** 的原因。如果没有插件，IDE 会根据标准语法报错：“兄弟，你没写 `getName()` 方法啊！”插件的作用就是欺骗 IDE，让 IDE 承认那些被强行插入的方法。

---

### 3. 对比总结表

| 特性         | MyBatis-Flex / MapStruct / QueryDSL | Lombok                                                                    |
| :----------- | :---------------------------------- | :------------------------------------------------------------------------ |
| **技术类型** | 标准 APT (JSR 269)                  | AST 修改 (Compiler Hack)                                                  |
| **文件变化** | 生成**新**的 `.java` 文件           | 修改**原**类的 `.class` 字节码                                            |
| **IDE 插件** | 不需要（标准支持）                  | **必须安装**（否则 IDE 无法识别方法）                                     |
| **可见性**   | 生成的源码清晰可见，可打断点        | 源码中不可见，只能看编译后的字节码                                        |
| **稳定性**   | 极高，不随 Java 版本升级而崩溃      | 较高，但 Java 大版本升级（如 9, 17）时经常需要更新版本以适配内部 API 变化 |
| **调试体验** | 方便，直接点进生成的类里看逻辑      | 较差，需要使用 "Delombok" 才能看到还原后的源码                            |

---

### 4. 资深程序员的看法：该怎么选？

在生产环境下，这两者并不是替代关系，而是**互补关系**：

1.  **Lombok 的价值**：在于**消除冗余代码**。它解决的是 Java 语言本身“太啰嗦”的问题（Bean 必须写 Getter/Setter）。
2.  **MyBatis-Flex 的价值**：在于**类型安全**。它解决的是“如何用 Java 代码优雅地写出不报错的 SQL”的问题。

**关于“黑科技”的担忧：**
有些严谨的架构师（特别是金融领域）会禁止使用 Lombok，因为他们认为修改 AST 具有不可控性，且增加了团队对插件的依赖。但几乎没有人会禁止 MyBatis-Flex 或 MapStruct，因为它们生成的代码是“看得见、摸得着”的，符合 Java 的原生标准。

### 总结

- **MyBatis-Flex** 就像是一个**勤劳的秘书**，看到你写了实体类，就帮你写一份“配套说明书（TableDef）”。
- **Lombok** 就像是一个**基因改造专家**，它直接在你的实体类胚胎期，强行给它多加了几只手（Getter/Setter）。

理解了这一点，你就理解了 Java 编译期处理技术的精髓。

这是一个非常有意思的话题。如果说 MyBatis-Flex 是在规则内跳舞，那么 **Lombok 就是在规则的边缘“反复横跳”，并成功“黑”进了 Java 编译器的内部。**

作为资深程序员，我带你深入到 Java 编译器的源码底层，看看 Lombok 是如何完成这一场“瞒天过海”的欺骗的。

---

### 1. 编译器的“正常流水线”

要理解 Lombok 的欺骗手段，首先要看标准的 Java 编译过程（以 Javac 为例）：

1.  **Parse（解析）**：读取 `.java` 源码，变成一棵 **AST（抽象语法树）**。
2.  **Enter（输入）**：把类、方法、变量等符号填入符号表。
3.  **Annotation Processing（注解处理）**：**这是 MyBatis-Flex 干活的地方。** 规范规定这里只能产生新文件。
4.  **Attribute（标注）** & **Flow（流分析）**：检查语义、变量是否初始化等。
5.  **Desugar（解糖）**：把高级语法（如泛型、foreach）转成基础语法。
6.  **Generate（生成）**：把 AST 变成 `.class` 字节码。

---

### 2. Lombok 的“欺骗”三部曲

Lombok 并不满足于在第 3 步生成新文件，它的目标是**修改第 1 步生成的内存中的那棵 AST 树**。

#### 第一步：非法潜入（强制转型）

在注解处理阶段，编译器会传给插件一个 `Element` 对象（代表被注解的类）。

- **正常插件**：只调用 `Element` 的公共接口，读取信息，写出新文件。
- **Lombok**：它知道在 Sun/Oracle 的编译器实现中，这个 `Element` 对象的底层实现其实是 `JavacElement`。它会通过**强制类型转换**，把对象转成编译器内部的私有类型。
- **潜台词**：这就像是一个外来人员通过伪造工卡，进入了编译器的“限制访问区”。

#### 第二步：手术刀式修改（操作 AST）

一旦拿到了编译器内部对象的引用，Lombok 就可以访问到 `TreeMaker`（树构造器）和 `Names`（符号表）。

- 当它看到 `@Data` 时，它会手动编写一段代码逻辑（比如 `getName` 方法的结构）。
- 它调用 `TreeMaker` 构造出一个“方法节点”。
- 然后，它**强行把这个新节点挂载到原来的类节点（ClassTree）上**。
- **欺骗点**：此时，编译器内存里的那棵 AST 树已经变了。原本只有 2 个字段的类，现在在内存里莫名其妙多了 10 个方法。

#### 第三步：既成事实（欺骗后续环节）

当编译流程进入到第 4 步（语义检查）和第 6 步（生成字节码）时，编译器**根本不知道这棵树被动过手脚**。它只看到 AST 树上有这些方法，于是就按照这些方法生成了字节码。

**结果**：最终生成的 `.class` 文件里，完美地包含了 Getter/Setter。

---

### 3. 为什么 IDE 还需要单独安装插件？

这是最能证明 Lombok “欺骗”成功的地方：**它骗过了编译器，但骗不过 IDE。**

1.  **编译器层面**：因为 Lombok 在编译流里改了树，所以 `javac` 运行得很开心，打包没问题。
2.  **IDE 层面**：IntelliJ IDEA 为了给你提供实时补全，它自己也有一套解析代码的引擎。IDE 的引擎在读取 `User.java` 时，发现里面真的没有 `getName()`，它就会在代码里给你画红线。
3.  **Lombok 插件的作用**：就是给 IDE 的引擎打个补丁。告诉 IDE：“别慌，虽然源码里没有这些方法，但在我的记忆里它们是存在的。” 这样 IDE 就不报错了，且能给你提供补全。

---

### 4. 资深程序员的技术复盘：为什么这不是官方标准？

你可能会问：既然这种技术这么好用，为什么 Java 官方不把它标准化（允许修改 AST）？

1.  **安全性与稳定性**：允许任意插件修改 AST 会导致编译过程极其不可控。如果两个插件都想修改同一个方法，谁先谁后？报错了算谁的？
2.  **兼容性风险**：Lombok 严重依赖编译器的内部 API（`com.sun.tools.javac` 等）。这些 API 是私有的，Oracle 随时可能修改。这就是为什么每次 Java 大版本更新（比如从 Java 8 到 11，再到 17），Lombok 经常会崩溃，必须发布新版本适配。
3.  **“所见即所得”原则**：Java 的哲学倾向于代码应该是透明的。Lombok 这种“源码里没有，字节码里有”的现象，会增加调试和理解的成本。

### 总结

Lombok 的“欺骗”艺术在于：**利用 Java 反射和强制转型，拿到了编译器内部数据结构的控制权，在编译器还没反应过来之前，直接把内存里的代码模型给改了。**

这种技术在 Java 界被称为 **"Hack"**。虽然它不符合官方的“优雅规范”，但它确实极大地解决了 Java 开发者的痛点，因此成为了一个“虽然非官方，但近乎标准”的存在。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-APT)
