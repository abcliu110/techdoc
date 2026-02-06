<div id="chap-yaml"></div>

[⬆️ 返回目录](#catalog)

## yaml

你好。看到你问 **"yarm"**，作为一名深耕 Java 多年的老兵，我首先要帮你纠正一个小小的笔误：在 Java 乃至整个软件工程领域，你指的应该是 **YAML**（读作 `/ˈjæməl/`），它的全称是 "YAML Ain't Markup Language"。

虽然名字有点拗口，但它是目前 Java 项目（尤其是 **Spring Boot**）中处理配置文件的“工业标准”。

以下我将从资深开发者的视角，为你拆解 YAML 的核心逻辑、在 Java 中的实战用法，以及如何“一眼读懂”复杂的 YAML 文件。

---

### 一、 为什么我们要弃用 `.properties` 改用 YAML？

在早期的 Java 开发中，我们习惯用 `application.properties`。但当你面对一个超大型项目时，你会发现：

1. **冗余严重**：每一行都要重复写前缀（如 `spring.datasource.url`, `spring.datasource.username`）。
2. **缺乏层次感**：很难一眼看出配置之间的父子关系。

**YAML 的核心优势**：

- **分层结构**：天然支持树状结构，极度简洁。
- **原生支持列表**：处理数组和集合非常优雅。
- **跨语言**：不仅仅是 Java，Python、Go、Docker、Kubernetes 全都在用它。

---

### 二、 如何读懂 YAML？（一眼看穿本质）

读懂 YAML 的秘诀在于：**“缩进即等级，冒号即键值，横杠即列表”**。

#### 1. 基础语法：键值对

```yaml
server:
  port: 8080 # 注意：冒号后面必须有一个空格！
```

- **资深建议**：YAML 对空格极其敏感，**严禁使用 Tab 键**，必须使用空格缩进（通常是 2 个或 4 个）。

#### 2. 对象嵌套

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/db
```

- 这等同于 properties 里的 `spring.datasource.url`。

#### 3. 数组与列表（最核心的区别）

```yaml
security:
  white-list:
    - /auth/login
    - /auth/register
    - /public/**
```

- **识别技巧**：看到开头的 **`-` (横杠)**，就意味着这是一个 `List` 或数组。

#### 4. 高级进阶：锚点与引用（DRY原则）

这是资深程序员为了减少重复配置常用的技巧：

```yaml
default-settings: &base
  timeout: 5000
  retries: 3

service-a:
  <<: *base # 引用上面的 base 配置
  name: "Service A"
```

---

### 三、 在 Java 中如何使用 YAML？

在现代 Java 开发中，你很少需要手写解析代码，通常由框架代劳。

#### 1. Spring Boot 自动装配（最常用）

这是最推荐的做法，利用 `@ConfigurationProperties` 将 YAML 直接映射为 Java Bean。

**YAML 文件：**

```yaml
my-app:
  config:
    app-name: "PhoenixSystem"
    max-users: 100
```

**Java 实体类：**

```java
@Component
@ConfigurationProperties(prefix = "my-app.config")
@Data // 使用 Lombok
public class AppConfig {
    private String appName;
    private Integer maxUsers;
}
```

#### 2. 原生 Java 解析（不使用框架时）

如果你在写一个基础工具库，不想依赖 Spring，通常会使用 **SnakeYAML**（Spring 内部也是用它）或 **Jackson**。

**使用 Jackson 解析：**

```java
ObjectMapper mapper = new ObjectMapper(new YAMLFactory());
// 将 yaml 文件直接转为 Map 或 POJO
MyConfig config = mapper.readValue(new File("config.yml"), MyConfig.class);
```

---

### 四、 资深程序员的避坑指南

1. **“Norway Problem”（挪威问题）**：
   在老版本的 YAML 解析器中，如果你写 `country: NO`，解析器会把 `NO` 当成布尔值 `false`。
   - **规避方案**：所有的字符串，如果包含特殊字符或可能是布尔关键字，**一律加双引号**：`country: "NO"`。

2. **类型转换陷阱**：
   YAML 默认会根据格式猜测类型（整型、浮点、布尔）。如果你需要一个字符串，但填了 `12345`，Java 在映射到 `String` 字段时通常没问题，但如果你在动态处理 Map，记得手动转换类型。

3. **格式校验**：
   当你的 YAML 文件很大，启动报错却找不到哪行空格多了时，不要肉眼去找。直接搜索 **"YAML Lint"**，把内容贴进去在线校验。

4. **安全提示**：
   解析外部传入的 YAML 时，务必注意 **"Billion Laughs Attack"**（一种类似 XML 炸弹的递归引用攻击）。现代框架（如新版 SnakeYAML）默认已经限制了递归深度，但如果你是手动写解析逻辑，记得开启防御。

**总结**：
读懂 YAML 靠的是对**缩进**的敏感度；用好 YAML 靠的是对 **`@ConfigurationProperties`** 的熟练掌握。只要记住“冒号后必有空格”，你已经掌握了 YAML 50% 的精髓。

没错，从功能角度来看，**YAML 和 Properties 是完全等效的**。在 Spring Boot 启动时，它们都会被加载到同一个 `Environment` 对象中。

作为资深开发者，我通常把 **Properties 看作是“平铺的列表”**，而把 **YAML 看作是“一颗结构化的树”**。

下面我通过四个最常见的实战场景，为你对比这两者的转换关系。

---

### 场景一：基础键值对（层级嵌套）

这是最基础的用法。YAML 通过缩进消除重复的前缀。

**YAML 格式：**

```yaml
server:
  port: 8080
  servlet:
    context-path: /api
```

**等效的 Properties 格式：**

```properties
server.port=8080
server.servlet.context-path=/api
```

- **资深点评**：当配置项达到上百行时，Properties 的前缀冗余会让你看得很痛苦，而 YAML 的树状结构非常清晰。

---

### 场景二：数组与集合（List/Array）

这是 YAML 优势最大的地方。

**YAML 格式：**

```yaml
spring:
  redis:
    cluster:
      nodes:
        - 192.168.1.1:6379
        - 192.168.1.2:6379
        - 192.168.1.3:6379
```

**等效的 Properties 格式：**

```properties
spring.redis.cluster.nodes[0]=192.168.1.1:6379
spring.redis.cluster.nodes[1]=192.168.1.2:6379
spring.redis.cluster.nodes[2]=192.168.1.3:6379
```

- **资深点评**：在 Properties 中维护索引（`[0]`, `[1]`）非常容易出错。如果你删除了中间的一行，你还得手动修改后续所有的索引数字。而在 YAML 中，你只需要增减一行 `-` 即可。

---

### 场景三：复杂对象映射

假设我们要配置一个自定义的支付网关列表。

**YAML 格式：**

```yaml
my-app:
  gateways:
    - name: alipay
      url: https://alipay.com
      timeout: 3000
    - name: wechat
      url: https://pay.weixin.qq.com
      timeout: 5000
```

**等效的 Properties 格式：**

```properties
my-app.gateways[0].name=alipay
my-app.gateways[0].url=https://alipay.com
my-app.gateways[0].timeout=3000
my-app.gateways[1].name=wechat
my-app.gateways[1].url=https://pay.weixin.qq.com
my-app.gateways[1].timeout=5000
```

- **资深点评**：这种对象列表，在 Properties 里简直是噩梦，可读性极差。

---

### 场景四：多环境配置（Profile）

在 Spring Boot 2.4+ 中，我们可以在一个 YAML 文件里定义多个环境。

**YAML 格式：**

```yaml
spring:
  profiles:
    active: dev
---
spring:
  config:
    activate:
      on-profile: dev
server:
  port: 8081
---
spring:
  config:
    activate:
      on-profile: prod
server:
  port: 80
```

**等效的 Properties 方式：**
Properties 无法在同一个文件里优雅地实现这一点。通常你需要建立三个文件：

1. `application.properties` (内容：`spring.profiles.active=dev`)
2. `application-dev.properties` (内容：`server.port=8081`)
3. `application-prod.properties` (内容：`server.port=80`)

- **资深点评**：YAML 的 `---` 分隔符允许我们将逻辑相关的多环境配置放在一起，减少了文件数量，非常适合云原生部署。

---

### 进阶思考：为什么有时候还要用 Properties？

虽然我极力推荐 YAML，但在以下两种情况，资深程序员会选择 Properties：

1.  **简单的脚本或临时工具**：如果配置只有 3-5 行，Properties 简单粗暴，不需要考虑缩进。
2.  **国际化 (i18n)**：Java 原生的 `ResourceBundle` 对 `.properties` 的支持是内置的，且专门优化了字符编码处理。所以在 `messages.properties` 场景下，Properties 依然是绝对的主角。

### 总结建议

如果你在做一个正式的 **Java 微服务项目**：

- **主配置文件**：一律使用 `application.yml`。
- **多环境管理**：利用 YAML 的树状结构。
- **快速转换技巧**：如果你手头有一段 Properties 想转成 YAML，或者反过来，直接搜索 **"Properties to YAML converter"** 这种在线工具，不要浪费时间去手写转换。

如果你在面试中被问到两者的区别，你可以这样回答：

> “它们在功能上是等效的，底层都由 `PropertySource` 承载。但 YAML 提供了更好的层级结构、支持原生列表映射、并且能够在一个文件中通过文档块（Document Block）定义多环境配置，更符合现代 DevOps 的配置管理习惯。”
>
> 从资深程序员的角度来看，这个问题触及了 Spring 核心设计的精髓：**抽象与归一化**。

无论你在外部写的是 `.properties`（平铺式）还是 `.yml`（树状式），在 Spring 的底层，它们最终都会被“降维打击”，转化成同一种结构：**`PropertySource`**。

### 1. PropertySource 的本质结构

在 Spring 源码中，`PropertySource` 是一个抽象类。它的核心结构极其简单，你可以把它理解为一个 **“带名字的键值对容器”**。

```java
public abstract class PropertySource<T> {
    protected final String name; // 来源的名字（比如 "applicationConfig: [classpath:/application.yml]"）
    protected final T source;    // 真实的配置数据（通常是一个 Map）

    public abstract Object getProperty(String name); // 根据 Key 获取 Value
}
```

- **它的核心思想是：** 屏蔽外部文件格式的差异。
- **它的最终形态是：** `Map<String, Object>`。所有的层次结构都会被**扁平化（Flattened）**为“点分表示法”的字符串 Key。

---

### 2. Spring 如何描述这两种结构？（扁平化算法）

这是读懂源码的关键：**Spring 内部并不存在“树状配置”，只存在“扁平配置”。**

#### A. 针对 Properties 文件

Properties 本身就是扁平的，所以处理起来非常直接。

- 文件内容：`server.port=8080`
- 加载后：`Map` 里存的就是 Key: `"server.port"`, Value: `"8080"`。

#### B. 针对 YAML 文件

YAML 是有层级的。Spring 通过 `YamlPropertySourceLoader` 调用 `SnakeYAML` 库解析文件，然后执行一个**递归扁平化算法**。

**例子：**

```yaml
spring:
  datasource:
    url: jdbc:mysql...
```

**扁平化过程：**

1. 扫描到 `spring`。
2. 扫描到子节点 `datasource`，拼接成 `spring.datasource`。
3. 扫描到末端节点 `url`，最终生成 Key：`spring.datasource.url`。

**对于列表（List）：**

```yaml
services:
  - auth
  - order
```

**扁平化后：**

- `services[0]` = `auth`
- `services[1]` = `order`

---

### 3. 图解：从文件到内存的演变

无论是哪种文件，进入 Spring 内存后的逻辑视图如下：

| 物理形态 (File)  | 加载器 (Loader)                  | 逻辑形态 (PropertySource)        | 内部存储 (Map)   |
| :--------------- | :------------------------------- | :------------------------------- | :--------------- |
| `app.properties` | `PropertiesPropertySourceLoader` | `MapPropertySource`              | `{"a.b.c": "1"}` |
| `app.yml`        | `YamlPropertySourceLoader`       | `OriginTrackedMapPropertySource` | `{"a.b.c": "1"}` |

**为什么要归一化？**
为了让 `Environment` 接口和 `@Value` 注解工作。
当你写 `@Value("${server.port}")` 时，Spring 不需要关心这个值是从 YAML 的缩进里抠出来的，还是从 Properties 的等号后面读出来的。它只需要去 `MutablePropertySources` 这个集合里，按优先级遍历每一个 `PropertySource`，问一句：“你家有叫 `server.port` 的 Key 吗？”

---

### 4. 资深开发者关心的细节：OriginTrackedMapPropertySource

如果你去看 Spring Boot 的源码，你会发现它处理 YAML 或 Properties 后生成的对象通常是 **`OriginTrackedMapPropertySource`**。

**为什么要“OriginTracked”（追踪来源）？**
这是资深开发者排查问题的利器。

- 如果是普通 Map，报错时只告诉你“值不对”。
- 如果是 `OriginTracked`，Spring 会记录下：这个值来自 `application.yml` 的第 15 行、第 8 列。
- 这就是为什么当 Spring Boot 启动失败时，控制台能精准打印出配置文件出错位置的原因。

### 总结

1.  **结构上**：`PropertySource` 是对 `Map<String, Object>` 的封装。
2.  **描述上**：
    - **Properties**：天然描述，Key-Value 一一对应。
    - **YAML**：通过**深度优先遍历**，将树状路径拼接成“点分字符串”（如 `a.b.c`），将数组索引化（如 `a.b[0]`），从而模拟出 Properties 的扁平结构。
3.  **结果上**：在 Spring 运行期，两者完全没有区别，都是“扁平化”后的配置项。

**经验之谈：**
理解了这一点，你就能理解为什么在 Spring Boot 中，你可以用环境变量 `SPRING_DATASOURCE_URL` 来覆盖 `spring.datasource.url` 的 YAML 配置。因为在底层，它们都被统一成了 **字符串 Key 的匹配**。

作为资深程序员，我非常欣赏你这种“动手验证底层逻辑”的态度。只有亲手写过一遍，你才能真正理解配置加载的**优先级**和**生命周期**。

下面我带你手把手搭建一个最简 Spring Boot 项目，通过实验验证以下三个核心逻辑：

1. **多文档 YAML 的 Profile 切换**
2. **占位符 `${...}` 的跨文档/跨文件解析**
3. **Environment 接口的实时取值**

---

### 第一步：准备项目环境

如果你有 IDE（如 IntelliJ IDEA），创建一个标准的 Spring Boot 项目，勾选 **Spring Web** 依赖即可。

**目录结构：**

```text
src/main/resources/
  └── application.yml
src/main/java/com/example/demo/
  ├── DemoApplication.java
  └── ConfigCheckController.java  <-- 我们主要写在这里
```

---

### 第二步：编写配置文件 (`application.yml`)

我们将你提到的逻辑整合进一个文件。请注意 `---` 的分隔作用。

```yaml
# 第一段：默认配置（公共配置）
spring:
  profiles:
    active: dev # 默认激活 dev 环境
app:
  name: "PhoenixSystem"
  description: "${app.name} is a great system" # 验证占位符解析

---
# 第二段：dev 环境
spring:
  config:
    activate:
      on-profile: dev
server:
  port: 8081
app:
  name: "Phoenix-Dev" # 覆盖公共配置

---
# 第三段：prod 环境
spring:
  config:
    activate:
      on-profile: prod
server:
  port: 80
app:
  name: "Phoenix-Prod"
```

---

### 第三步：编写验证代码

我们编写一个简单的 Rest 接口，直接注入 `Environment` 和使用 `@Value`。

```java
package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class ConfigCheckController {

    // 方式1：通过 @Value 注入（启动时已解析完毕）
    @Value("${app.description}")
    private String appDescription;

    @Value("${server.port}")
    private String serverPort;

    // 方式2：直接注入 Environment 接口（大管家，随时可以调取）
    @Autowired
    private Environment env;

    @GetMapping("/check")
    public Map<String, Object> checkConfig() {
        Map<String, Object> result = new HashMap<>();

        // 验证占位符解析结果
        result.put("Value_Annotation_Description", appDescription);
        result.put("Value_Annotation_Port", serverPort);

        // 验证 Environment 实时获取
        result.put("Env_App_Name", env.getProperty("app.name"));
        result.put("Active_Profiles", env.getActiveProfiles());

        return result;
    }
}
```

---

### 第四步：运行并验证

#### 1. 验证 dev 环境（默认）

直接启动项目。你会发现：

- 控制台日志显示：`Tomcat initialized with port(s): 8081 (http)`
- 浏览器访问 `http://localhost:8081/check`，结果如下：
  ```json
  {
    "Env_App_Name": "Phoenix-Dev",
    "Active_Profiles": ["dev"],
    "Value_Annotation_Description": "Phoenix-Dev is a great system",
    "Value_Annotation_Port": "8081"
  }
  ```
  **资深观察点**：注意 `description`。虽然它定义在第一段（公共段），但它引用的 `${app.name}` 成功拿到了 dev 段定义的 `"Phoenix-Dev"`。这证明了：**占位符的解析是在所有配置加载完毕后，在 Environment 全局查找的。**

#### 2. 验证 prod 环境

启动时添加 VM 参数（在 IDE 的 Run Configuration 中设置）：
`-Dspring.profiles.active=prod`

启动后：

- 端口变为 `80`。
- 访问 `http://localhost/check`，结果：
  ```json
  {
    "Env_App_Name": "Phoenix-Prod",
    "Value_Annotation_Description": "Phoenix-Prod is a great system"
  }
  ```

---

### 第五步：实验对比（Properties 方案）

如果你想验证“等效的 properties”，请**删除** `application.yml`，创建以下两个文件：

**`application.properties`**:

```properties
spring.profiles.active=dev
app.name=PhoenixSystem
app.description=${app.name} is a great system
```

**`application-dev.properties`**:

```properties
server.port=8081
app.name=Phoenix-Dev
```

再次启动，你会发现效果**完全一致**。

---

### 资深程序员的“实验总结”：

1.  **加载时机**：Spring Boot 会先加载 `application.yml` 的主文档，发现激活了 `dev`，然后再去加载匹配 `dev` 的文档块或文件。
2.  **动态覆盖**：`dev` 环境里的 `app.name` 覆盖了公共段的 `app.name`。
3.  **延迟解析**：当解析 `${app.description}` 时，Spring 已经在 `Environment` 里把所有的 `PropertySource` 准备好了。它发现 `app.name` 在不同的来源里有多个值，于是根据**“后加者优先”**原则，取了 `dev` 里的值。
4.  **接口力量**：`Environment` 接口不仅能拿到当前值，还能让你通过 `env.acceptsProfiles(Profiles.of("dev"))` 在代码里做逻辑分支，这是资深开发做多环境适配的常用手段。

通过这个简单的实验，你不仅验证了配置的写法，更深刻理解了 **Spring Environment 归一化存储** 的魅力。

<!-- 跳转链接 -->

[⬆️ 返回目录](#catalog) | [文章开头 ➡️](#chap-yaml)
