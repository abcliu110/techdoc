<div id="chap-mybatis-family"></div>

[返回目录](#catalog)

## MyBatis、MyBatis-Plus、MyBatis-Flex详解

生成时间：2026-04-14

---

## 1. 总览

这三个技术经常被一起提到，但它们并不是完全并列的关系。

- `MyBatis` 是底层 SQL 映射框架
- `MyBatis-Plus` 是在 MyBatis 之上的增强框架
- `MyBatis-Flex` 也是一套面向 MyBatis 风格的数据访问增强框架

一句话理解：

- `MyBatis`：你自己写 SQL，框架帮你执行和映射
- `MyBatis-Plus`：框架帮你写大量通用 CRUD SQL
- `MyBatis-Flex`：框架也帮你写大量通用 SQL，但更强调 DSL 和链式表达

---

## 2. 先理解 MyBatis

### 2.1 MyBatis 解决什么问题

JDBC 原生写法很繁琐，通常需要手动处理：

- 获取连接
- 创建 `PreparedStatement`
- 绑定参数
- 执行 SQL
- 遍历 `ResultSet`
- 将结果组装成 Java 对象
- 关闭资源

MyBatis 主要帮你解决的是：

- SQL 参数绑定
- 查询结果映射
- Mapper 接口代理
- 动态 SQL 组织

但它不替你决定 SQL 长什么样，SQL 仍然主要由你写。

### 2.2 原生 MyBatis 最小例子

#### 2.2.1 建表

```sql
create database if not exists demo charset utf8mb4;

use demo;

create table if not exists user (
  id bigint primary key,
  name varchar(50),
  age int
);

delete from user;
insert into user(id, name, age) values (1, '张三', 18);
```

#### 2.2.2 实体类

```java
package com.demo.mybatisraw.entity;

public class User {
    private Long id;
    private String name;
    private Integer age;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
}
```

#### 2.2.3 Mapper 接口

```java
package com.demo.mybatisraw.mapper;

import com.demo.mybatisraw.entity.User;
import org.apache.ibatis.annotations.Param;

public interface UserMapper {
    User getById(@Param("id") Long id);
    int updateName(@Param("id") Long id, @Param("name") String name);
}
```

#### 2.2.4 XML

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.demo.mybatisraw.mapper.UserMapper">

  <select id="getById" resultType="com.demo.mybatisraw.entity.User">
    select id, name, age
    from user
    where id = #{id}
  </select>

  <update id="updateName">
    update user
    set name = #{name}
    where id = #{id}
  </update>

</mapper>
```

#### 2.2.5 启动类

```java
package com.demo.mybatisraw;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.demo.mybatisraw.mapper")
public class MybatisRawApplication {
    public static void main(String[] args) {
        SpringApplication.run(MybatisRawApplication.class, args);
    }
}
```

#### 2.2.6 Service

```java
package com.demo.mybatisraw.service;

import com.demo.mybatisraw.entity.User;
import com.demo.mybatisraw.mapper.UserMapper;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User getById(Long id) {
        return userMapper.getById(id);
    }

    public int updateName(Long id, String name) {
        return userMapper.updateName(id, name);
    }
}
```

#### 2.2.7 Controller

```java
package com.demo.mybatisraw.controller;

import com.demo.mybatisraw.entity.User;
import com.demo.mybatisraw.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/raw/user")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) {
        return userService.getById(id);
    }

    @PostMapping("/{id}/name")
    public String updateName(@PathVariable Long id, @RequestParam String name) {
        userService.updateName(id, name);
        return "ok";
    }
}
```

### 2.3 原生 MyBatis 运行时到底发生了什么

调用：

```java
User user = userMapper.getById(1L);
```

内部大致流程：

1. Spring 注入的 `userMapper` 实际上是动态代理对象
2. 代理对象拦截 `getById(1L)` 调用
3. 根据接口全限定名 + 方法名找到 `MappedStatement`
4. 将 SQL 中的 `#{id}` 转换为 JDBC 参数 `?`
5. 将 `1L` 绑定到 `?`
6. 执行 SQL
7. 将结果集映射成 `User`
8. 返回对象

### 2.4 原生 MyBatis 的特点

优点：

- SQL 可控性最高
- 复杂 SQL、报表、联合查询写起来最灵活
- 性能问题定位清晰

缺点：

- 简单 CRUD 也要自己写
- 表多时容易出现大量重复代码
- XML/注解 SQL 会越来越多

---

## 3. MyBatis-Plus 是怎么进一步封装的

### 3.1 核心思想

MyBatis-Plus 并没有抛弃 MyBatis。

它是在 MyBatis 上做了两层增强：

- 自动通用 CRUD
- 条件构造器 Wrapper

也就是说，你不再需要每张表都手写：

- `selectById`
- `insert`
- `updateById`
- `deleteById`

### 3.2 MyBatis-Plus 最小例子

#### 3.2.1 实体类

```java
package com.demo.mybatisplusdemo.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

@TableName("user")
public class User {
    @TableId
    private Long id;
    private String name;
    private Integer age;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
}
```

#### 3.2.2 Mapper

```java
package com.demo.mybatisplusdemo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.demo.mybatisplusdemo.entity.User;

public interface UserMapper extends BaseMapper<User> {
}
```

#### 3.2.3 启动类

```java
package com.demo.mybatisplusdemo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.demo.mybatisplusdemo.mapper")
public class MybatisPlusApplication {
    public static void main(String[] args) {
        SpringApplication.run(MybatisPlusApplication.class, args);
    }
}
```

#### 3.2.4 Service

```java
package com.demo.mybatisplusdemo.service;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.demo.mybatisplusdemo.entity.User;
import com.demo.mybatisplusdemo.mapper.UserMapper;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User getById(Long id) {
        return userMapper.selectById(id);
    }

    public boolean updateName(Long id, String name) {
        LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(User::getId, id)
               .set(User::getName, name);
        return userMapper.update(null, wrapper) > 0;
    }
}
```

#### 3.2.5 Controller

```java
package com.demo.mybatisplusdemo.controller;

import com.demo.mybatisplusdemo.entity.User;
import com.demo.mybatisplusdemo.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/plus/user")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) {
        return userService.getById(id);
    }

    @PostMapping("/{id}/name")
    public String updateName(@PathVariable Long id, @RequestParam String name) {
        userService.updateName(id, name);
        return "ok";
    }
}
```

### 3.3 MyBatis-Plus 进一步封装了什么

#### 3.3.1 自动 CRUD

你只写：

```java
public interface UserMapper extends BaseMapper<User> {
}
```

框架就已经提供：

- `selectById`
- `insert`
- `updateById`
- `deleteById`
- `selectList`

#### 3.3.2 Wrapper 条件构造器

例如：

```java
LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
wrapper.eq(User::getId, id)
       .set(User::getName, name);
```

框架内部会把它翻译成类似：

```sql
update user
set name = ?
where id = ?
```

#### 3.3.3 额外能力

MyBatis-Plus 常见增强能力还包括：

- 分页插件
- 乐观锁
- 逻辑删除
- 自动填充
- 代码生成器

### 3.4 MyBatis-Plus 的特点

优点：

- CRUD 场景开发效率很高
- 与 MyBatis 兼容度高
- 复杂查询仍然可以手写 SQL

缺点：

- Wrapper 复杂后可读性下降
- 对复杂 join 或特殊 SQL 仍然要回退原生写法

---

## 4. MyBatis-Flex 是怎么进一步封装的

### 4.1 核心思想

MyBatis-Flex 也做了增强，但它更强调：

- 查询链 `QueryChain`
- 更新链 `UpdateChain`
- DSL 风格表达

与 MyBatis-Plus 相比，它的链式风格更明显。

### 4.2 MyBatis-Flex 最小例子

#### 4.2.1 实体类

```java
package com.demo.mybatisflexdemo.entity;

import com.mybatis.flex.annotation.Id;
import com.mybatis.flex.annotation.Table;

@Table("user")
public class User {
    @Id
    private Long id;
    private String name;
    private Integer age;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
}
```

#### 4.2.2 Mapper

```java
package com.demo.mybatisflexdemo.mapper;

import com.demo.mybatisflexdemo.entity.User;
import com.mybatis.flex.core.BaseMapper;

public interface UserMapper extends BaseMapper<User> {
}
```

#### 4.2.3 启动类

```java
package com.demo.mybatisflexdemo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.demo.mybatisflexdemo.mapper")
public class MybatisFlexApplication {
    public static void main(String[] args) {
        SpringApplication.run(MybatisFlexApplication.class, args);
    }
}
```

#### 4.2.4 Service

```java
package com.demo.mybatisflexdemo.service;

import com.demo.mybatisflexdemo.entity.User;
import com.demo.mybatisflexdemo.mapper.UserMapper;
import com.mybatis.flex.core.query.QueryWrapper;
import com.mybatis.flex.core.update.UpdateChain;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public User getById(Long id) {
        return userMapper.selectOneByQuery(
            QueryWrapper.create().where("id = ?", id)
        );
    }

    public boolean updateName(Long id, String name) {
        return UpdateChain.of(userMapper)
                .setRaw("name = ?", name)
                .where("id = ?", id)
                .update();
    }
}
```

#### 4.2.5 Controller

```java
package com.demo.mybatisflexdemo.controller;

import com.demo.mybatisflexdemo.entity.User;
import com.demo.mybatisflexdemo.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/flex/user")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public User get(@PathVariable Long id) {
        return userService.getById(id);
    }

    @PostMapping("/{id}/name")
    public String updateName(@PathVariable Long id, @RequestParam String name) {
        userService.updateName(id, name);
        return "ok";
    }
}
```

### 4.3 MyBatis-Flex 进一步封装了什么

#### 4.3.1 QueryChain / UpdateChain

查询和更新不是同一个对象模型。

查询链：

```java
QueryChain.of(userMapper) ...
```

更新链：

```java
UpdateChain.of(userMapper) ...
```

#### 4.3.2 DSL 风格

它会把“查询条件”“更新字段”“where 条件”抽象成对象链，而不是直接手写整条 SQL。

#### 4.3.3 通用能力

和 MyBatis-Plus 类似，也具备：

- CRUD 支持
- 条件拼装
- 分页等能力

### 4.4 MyBatis-Flex 的特点

优点：

- 链式风格统一
- 更新链和查询链概念明确
- 对 DSL 风格偏好的团队很友好

缺点：

- 团队不熟时容易混淆 QueryChain / UpdateChain
- 项目里如果混用多套 ORM 风格，理解成本会上升

---

## 5. 三种方式运行时的共同点

虽然写法不同，但运行时主链其实类似：

```text
Controller
-> Service
-> Mapper / Chain / Wrapper
-> 生成或找到 SQL
-> 绑定参数
-> 执行 JDBC
-> 映射结果
-> 返回对象
```

区别主要在“SQL 是谁生成的”。

### 5.1 原生 MyBatis

- SQL 来源：开发者自己写

### 5.2 MyBatis-Plus

- SQL 来源：`BaseMapper` + `Wrapper` 自动生成

### 5.3 MyBatis-Flex

- SQL 来源：`QueryWrapper` / `QueryChain` / `UpdateChain` 自动生成

---

## 6. 三种方式完整对比

| 对比项 | MyBatis | MyBatis-Plus | MyBatis-Flex |
| :-- | :-- | :-- | :-- |
| SQL 编写方式 | 手写 SQL | 通用 CRUD 自动生成，复杂 SQL 可手写 | 通用 CRUD 和 DSL 自动生成 |
| 条件表达 | XML / 注解 / 动态 SQL | Wrapper | QueryChain / UpdateChain / DSL |
| 控制力 | 最高 | 高 | 高 |
| 开发效率 | 较低 | 高 | 高 |
| 复杂 SQL 场景 | 最适合 | 适合但常需回退原生 SQL | 适合但复杂场景仍可能回退 |
| 学习成本 | 中 | 中 | 中偏高 |
| 常见问题 | XML 多、重复 SQL 多 | Wrapper 复杂后可读性差 | 查询链和更新链混用 |

---

## 7. 结合当前项目的理解

你当前项目里并不只用一种技术，而是混合了：

- 原生 MyBatis
- MyBatis-Plus
- MyBatis-Flex
- 以及你们自己在 Flex 之上封装的 `Chain`

例如你们项目里的自定义写法：

```java
Chain.forQuery(mapper)
Chain.forUpdate(mapper)
```

这本质上是对 MyBatis-Flex 再封了一层统一外观。

好处：

- 业务代码更统一
- 调用风格更顺手

代价：

- 查询链和更新链虽然表面都叫 `Chain<T>`
- 但内部不是同一个对象
- 容易写出：

```java
forQuery(...).set(...)
```

这种编译通过、运行时报错的代码

---

## 8. 为什么会出现“查询链调用 set 更新”的错误

以你当前项目的错误为例：

```java
OrderServiceUtil.forFoodQuery()
    .set(DwdFood::getOrderStatus, OrderStatusEnum.CANCEL)
    .update();
```

问题在于：

- `forFoodQuery()` 返回的是查询链
- `.set(...)` 属于更新动作
- 查询链内部没有 `updateChain`

于是运行时就会报：

```text
Cannot invoke "UpdateChain.set(...)" because "this.updateChain" is null
```

这不是业务问题，而是技术封装使用错误。

---

## 9. 如何选择

### 9.1 选择 MyBatis

适合场景：

- SQL 非常复杂
- 报表查询多
- 联表查询多
- 对 SQL 完全可控有强要求

### 9.2 选择 MyBatis-Plus

适合场景：

- 中后台 CRUD 很多
- 开发速度要求高
- 团队普遍熟悉 MyBatis 生态

### 9.3 选择 MyBatis-Flex

适合场景：

- 团队愿意接受更明显的 DSL / Chain 风格
- 想统一用链式查询和更新表达
- 对 Flex 风格有统一规范

---

## 10. 建议与经验

### 10.1 如果团队混用多种风格

要明确约束：

- 哪些模块用原生 MyBatis
- 哪些模块用 MyBatis-Plus
- 哪些模块用 MyBatis-Flex
- 自定义封装方法名要足够明确

### 10.2 如果使用 MyBatis-Flex 或自定义 Chain

建议：

- 查询链方法名用 `forQuery`
- 更新链方法名用 `forUpdate`
- 看到 `.set(...)` 时，前面必须来自更新链
- 对查询链和更新链做更严格的类型区分，减少误用

### 10.3 如果是新手学习顺序

推荐顺序：

1. 先学原生 MyBatis
2. 再学 MyBatis-Plus
3. 最后看 MyBatis-Flex 和项目里的二次封装

原因：

- 先理解原始 SQL 执行和映射原理
- 再理解增强框架到底增强了什么
- 最后看项目里的自定义封装才不会迷糊

---

## 11. 小结

这三者并不是谁取代谁，而是抽象层次不同。

- `MyBatis` 提供 SQL 映射基础能力
- `MyBatis-Plus` 在其上补充通用 CRUD 和 Wrapper
- `MyBatis-Flex` 在其上提供另一套更强调链式与 DSL 的增强方式

真正理解它们的关键不是背 API，而是理解：

- SQL 是谁写的
- 条件是如何构造的
- 运行时谁负责执行
- 查询链和更新链是否是同一个对象模型

如果你已经能把这四个问题想明白，后面再看项目里的持久层代码，判断错误会快很多。

---

## 12. 本轮问题补充整理

这一节专门补充前面交流里你重点追问、但主文档里还没有完全展开的内容。

---

### 12.1 Mapper 接口为什么没有实现类也能执行

例如：

```java
public interface UserMapper {
    User getById(Long id);
}
```

你没有手写 `UserMapperImpl`，但它仍然可以被调用，原因是：

- MyBatis 在启动时会为 Mapper 接口创建动态代理对象
- Spring 注入给业务层的不是接口本体，而是这个代理对象

你可以把它理解成运行时近似生成了这样一个对象：

```java
class UserMapperProxy implements UserMapper {
    @Override
    public User getById(Long id) {
        // 根据接口方法找到 SQL
        // 绑定参数
        // 执行查询
        // 返回结果
        return ...;
    }
}
```

真实内部更复杂，但理解方式可以先这样建立。

---

### 12.2 注解方式的 Mapper 是如何扫描到的

例如：

```java
@Mapper
public interface UserMapper {
    @Select("select id, name, age from user where id = #{id}")
    User getUserById(Long id);
}
```

它之所以能被注入，是因为启动时做了 Mapper 扫描。

常见方式有两种。

#### 12.2.1 方式一：接口上加 `@Mapper`

```java
@Mapper
public interface UserMapper {
    ...
}
```

表示：

- 这是一个 MyBatis Mapper 接口
- 启动时需要把它注册成 Bean

#### 12.2.2 方式二：启动类上加 `@MapperScan`

```java
@SpringBootApplication
@MapperScan("com.demo.mapper")
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

表示：

- 扫描 `com.demo.mapper` 包
- 把里面的 Mapper 接口统一注册

#### 12.2.3 启动时实际发生了什么

大致流程：

1. Spring Boot 启动
2. MyBatis 自动配置生效
3. Mapper 扫描器扫描目标包
4. 找到 `UserMapper`
5. 为它注册 `MapperFactoryBean`
6. `MapperFactoryBean` 再创建动态代理对象
7. Spring 容器里就有了 `UserMapper` Bean

所以业务层才能写：

```java
private final UserMapper userMapper;
```

---

### 12.3 Controller 构造器是谁初始化的

例如：

```java
@RestController
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }
}
```

这个构造器不是你手动调用的，而是 Spring 容器创建 Bean 时调用的。

大致过程：

1. Spring 扫描到 `@RestController`
2. 发现它只有一个构造器
3. 发现构造器参数需要 `UserService`
4. Spring 容器里刚好有 `UserService` Bean
5. Spring 自动执行：

```java
new UserController(userServiceBean)
```

也就是说，这属于构造器注入。

这种写法比字段注入更推荐，因为：

- 依赖关系清晰
- 可以使用 `final`
- 更适合测试
- 初始化时依赖完整

---

### 12.4 `#{}` 和 `${}` 的区别

这是 MyBatis 最重要的基础知识之一。

#### 12.4.1 `#{}`：预编译参数绑定

例如：

```sql
select * from user where id = #{id}
```

运行时会变成：

```sql
select * from user where id = ?
```

然后再把参数值绑定进去。

优点：

- 安全
- 能防 SQL 注入
- 是最常用、最推荐的写法

#### 12.4.2 `${}`：字符串直接拼接

例如：

```sql
select * from ${tableName}
```

运行时会直接拼接成 SQL 字符串。

优点：

- 适合表名、列名、排序字段这类不能用 `?` 占位的场景

缺点：

- 有 SQL 注入风险
- 不能乱用

#### 12.4.3 经验

正常参数几乎都应该优先用：

```text
#{}
```

只有在动态表名、动态字段名、排序字段等必须拼接 SQL 结构时，才考虑：

```text
${}
```

---

### 12.5 XML SQL 和注解 SQL 是如何解析的

无论你是：

```xml
<select id="getById"> ... </select>
```

还是：

```java
@Select("select ...")
```

最终 MyBatis 都会把它们解析成内部统一结构，通常可以理解为：

- statementId
- SQL 模板
- 参数映射规则
- 结果映射规则

其中一个很关键的概念是：

#### 12.5.1 `MappedStatement`

它可以理解成：

- Mapper 某个方法对应的一条已注册 SQL 定义

例如：

```text
com.demo.mapper.UserMapper.getById
```

会对应一条 `MappedStatement`。

当你调用：

```java
userMapper.getById(1L);
```

代理对象会根据：

- 接口全限定名
- 方法名

找到这条 `MappedStatement`，然后执行。

---

### 12.6 MyBatis 执行链路中的几个关键对象

#### 12.6.1 `SqlSession`

`SqlSession` 可以理解成：

- MyBatis 执行数据库操作时的核心会话对象

它负责：

- 执行 SQL
- 获取 Mapper 代理
- 管理一次数据库交互上下文

#### 12.6.2 `MapperFactoryBean`

这是 Spring 集成 MyBatis 时的重要桥梁。

作用是：

- 把 Mapper 接口注册成 Spring Bean
- 创建 Mapper 动态代理对象

#### 12.6.3 `MappedStatement`

前面提过，它代表：

- 某个 Mapper 方法对应的一条 SQL 定义

#### 12.6.4 动态代理

你调用的是接口方法，例如：

```java
userMapper.getById(1L);
```

但实际执行的是 MyBatis 生成的代理对象逻辑，而不是你手写的实现类。

---

### 12.7 MyBatis-Plus 的进一步封装到底多了什么

除了基础 CRUD，MyBatis-Plus 最常用的封装是 `Wrapper`。

#### 12.7.1 查询 Wrapper

```java
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.eq(User::getName, "张三")
       .gt(User::getAge, 18);

List<User> list = userMapper.selectList(wrapper);
```

它会被翻译成类似：

```sql
select id, name, age
from user
where name = ? and age > ?
```

#### 12.7.2 更新 Wrapper

```java
LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
wrapper.eq(User::getId, 1L)
       .set(User::getName, "李四");

userMapper.update(null, wrapper);
```

它会被翻译成类似：

```sql
update user
set name = ?
where id = ?
```

#### 12.7.3 为什么 Wrapper 常见

因为它很适合：

- 简单增删改查
- 后台管理页面
- 通用列表筛选

但如果 where 条件、join、子查询过于复杂，代码可读性会迅速下降。

---

### 12.8 MyBatis-Flex 的进一步封装到底多了什么

MyBatis-Flex 最值得记住的是：

- 查询链和更新链是两套模型

例如：

```java
QueryChain.of(userMapper) ...
UpdateChain.of(userMapper) ...
```

#### 12.8.1 查询链

用于：

- 查单条
- 查列表
- 构造 where 条件

#### 12.8.2 更新链

用于：

- `.set(...)`
- `.where(...)`
- `.update()`

#### 12.8.3 你当前项目为什么容易出错

因为你们又在 Flex 上做了二次封装：

```java
Chain.forQuery(...)
Chain.forUpdate(...)
```

它们外观看起来都返回：

```java
Chain<T>
```

但内部状态不一样：

- `forQuery(...)` 只有 `queryChain`
- `forUpdate(...)` 才有 `updateChain`

所以这种代码就会出问题：

```java
forQuery(...).set(...)
```

编译能过，运行时报错。

---

### 12.9 为什么你这次的 bug 会表现成“第一次失败，第二次成功”

这类问题常见原因是：

- 第一次请求时，前半段逻辑已经执行了一部分
- 后半段执行到错误代码才抛异常
- 第二次请求时，前置状态已经变化
- 因而请求走到了不同分支，或者绕开了出错路径

换句话说：

- 第一次失败，不代表什么都没做
- 第二次成功，也不代表第一次的问题不存在

这类问题特别危险，因为会制造“重试一下就好了”的假象，但实际可能已经改动了部分数据。

---

### 12.10 结合当前项目的实战经验

在当前项目里，如果你看到：

```java
forQuery(...)
```

就要优先把它理解成：

- 这个对象主要用于查数据

如果后面出现：

```java
.set(...)
.update()
```

要立刻反查：

- 前面是不是应该是 `forUpdate(...)`

这是目前排查这类 bug 最有效的经验之一。

---

### 12.11 本轮交流里最重要的几个结论

#### 12.11.1 技术层面

- `MyBatis` 是底层 SQL 映射框架
- `MyBatis-Plus` 是对 MyBatis 的 CRUD 与 Wrapper 增强
- `MyBatis-Flex` 是另一套更强调链式 DSL 的增强框架

#### 12.11.2 Spring 层面

- `Controller` / `Service` / `Mapper` 都是 Spring 容器管理的 Bean
- 构造器注入是 Spring 自动完成的
- Mapper 接口本身没有实现类，运行时通过代理对象工作

#### 12.11.3 当前项目层面

- 你们项目里 `Chain` 是在 MyBatis-Flex 之上的二次封装
- `forQuery` 与 `forUpdate` 外观统一，但内部不是同一个对象模型
- 当前这个 `updateChain is null` 的问题，本质上就是“查询链被误用于更新”

---

## 13. 最终建议

如果你后面要继续深入 Java 持久层，建议按这个顺序学习：

1. 原生 MyBatis
2. Spring Bean 扫描、注入、动态代理
3. MyBatis-Plus 的 BaseMapper 和 Wrapper
4. MyBatis-Flex 的 QueryChain / UpdateChain
5. 项目里的二次封装

这样学习路径最稳，也最容易把项目里的混合风格看明白。

---

[返回目录](#catalog) | [文章开头](#chap-mybatis-family)
