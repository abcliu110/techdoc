# Sa-Token多账号体系与POS云端权限设计原理

## 1. 这篇文档说明什么

本文说明 `nms4cloud` 和 `nms4pos` 项目中 Sa-Token 的实际设计方式，重点回答几个问题：

- 为什么项目里不是只用一个 `StpUtil`。
- `StpBizUtil`、`StpPlatformUtil`、`StpInstUtil`、`StpSplUtil` 分别解决什么问题。
- 多账号体系在 Sa-Token 底层是如何隔离 token、Session、角色、权限的。
- 云端平台、云端商户、POS 端、C 端会员分别怎么登录。
- 权限校验时，接口上的注解如何找到当前登录用户的权限。
- POS 端权限和云端权限是什么关系。
- Session 中存了哪些关键数据，为什么权限校验不每次查数据库。

本文基于以下项目代码分析：

```text
D:\mywork\nms4cloud
D:\mywork\nms4pos
```

核心代码集中在：

```text
nms4cloud-starter/nms4cloud-starter-parent/src/main/java/com/nms4cloud/common/satoken
nms4cloud-starter/nms4cloud-starter-parent/src/main/java/com/nms4cloud/common/config/SaTokenConfigure.java
nms4cloud-app/1_platform/nms4cloud-platform
nms4cloud-app/2_business/nms4cloud-biz
nms4cloud-app/2_business/nms4cloud-crm
nms4pos/nms4cloud-pos3boot
nms4pos/nms4cloud-pos2plugin
```

---

## 2. 先理解 Sa-Token 默认模型

Sa-Token 默认最常见的用法是：

```java
StpUtil.login(userId);
StpUtil.checkLogin();
StpUtil.checkPermission("xxx");
```

在默认模型中，可以简单理解为只有一套账号体系：

```text
loginType = login
```

一个用户登录后，Sa-Token 会围绕这个 `loginType` 管理 token、Session、权限校验。

例如：

```text
StpUtil.login(1001)
```

可以理解为：

```text
默认账号体系 login 下，账号 1001 登录。
```

后续请求带 token 访问接口：

```text
请求携带 token
  -> Sa-Token 读取 token
  -> 找到 loginType=login 下的 loginId
  -> 得到 loginId=1001
  -> 从 login 体系的 Session 中取用户、角色、权限
```

如果一个系统只有一种用户，例如只有后台管理员，这样足够。

但 `nms4cloud` / `nms4pos` 不是这种情况。

---

## 3. 为什么这个项目需要多账号体系

这套系统里同时存在很多种“用户”：

| 用户类型 | 典型入口 | 业务含义 |
|---|---|---|
| 平台管理员 | 云端平台后台 | 管平台、商户、配置、全局资源 |
| 商户管理员 / 老板通用户 | 云端商户后台、老板通、小程序管理端 | 管商户自己的门店、菜品、订单、营销 |
| POS 操作员 | 门店本地 POS | 在收银终端操作开台、下单、退菜、结账、报表 |
| 机构用户 | 机构端 | 独立机构业务 |
| 特殊商户 / 供应链类用户 | 特定业务端 | 特殊业务域 |
| C 端会员 | 微信小程序、会员端 | 消费者、会员卡、储值、券 |

这些用户可能都有一个数值 ID，例如都可能是 `1001`。

如果全部使用默认 `StpUtil`，会出现概念混乱：

```text
平台管理员 1001
商户用户 1001
POS 用户 1001
C端会员 1001
```

如果都落在同一套默认账号体系里，就容易变成：

```text
login:session:1001
```

这会带来几个问题：

- 用户 ID 可能冲突。
- 平台端和商户端权限会混在一起。
- C 端会员 Session 可能被后台 Session 覆盖。
- 接口权限校验不知道应该按哪种身份判断。
- 平台后台 token 可能被商户端接口误识别。

所以项目需要把不同身份隔离成不同的 Sa-Token 账号体系。

---

## 4. 项目的多账号体系总览

项目实际拆成了多套 Sa-Token 登录体系：

| 账号体系 | 工具类 | loginType | 注解 |
|---|---|---|---|
| C 端会员 | `StpUtil` | 默认 `login` | `@SaCheckLogin`、`@SaCheckPermission` |
| 商户端 / POS 端 | `StpBizUtil` | `biz` | `@SaBizCheckLogin`、`@SaBizCheckPermission`、`@SaBizCheckRole` |
| 平台端 | `StpPlatformUtil` | `platform` | `@SaPlatformCheckLogin`、`@SaPlatformCheckPermission`、`@SaPlatformCheckRole` |
| 机构端 | `StpInstUtil` | `inst` | `@SaInstCheckLogin`、`@SaInstCheckPermission`、`@SaInstCheckRole` |
| 特殊商户 / 供应链类 | `StpSplUtil` | `spl` | `@SaSpCheckLogin`、`@SaSpCheckPermission`、`@SaSpCheckRole` |

这几个体系的核心区别不是工具类名字不同，而是底层 `StpLogic` 的 `loginType` 不同。

可以理解为：

```text
StpUtil
  -> 默认 login 体系

StpBizUtil
  -> biz 体系

StpPlatformUtil
  -> platform 体系

StpInstUtil
  -> inst 体系

StpSplUtil
  -> spl 体系
```

它们共享 Sa-Token 框架能力，但登录态、Session、权限上下文互相隔离。

---

## 5. 多账号体系的核心实现：自定义 StpLogic

### 5.1 Stp 是什么意思

Sa-Token 中大量类名都以 `Stp` 开头，例如：

```java
StpUtil
StpLogic
StpInterface
```

这里的 `Stp` 可以理解为：

```text
Stp = Sa-Token Permission
```

也就是 Sa-Token 权限认证体系的前缀。

常见类名可以这样理解：

| 名称 | 含义 |
|---|---|
| `StpUtil` | 默认账号体系的登录、鉴权、Session、token 操作入口 |
| `StpLogic` | `StpUtil` 背后的具体实现逻辑对象 |
| `StpInterface` | 给 `StpLogic` 提供角色和权限数据的接口 |
| `StpBizUtil` | 项目自定义的商户 / POS 端账号体系操作入口 |
| `StpPlatformUtil` | 项目自定义的平台端账号体系操作入口 |

一句话：

```text
StpUtil 是门面工具类。
StpLogic 是真正干活的登录鉴权逻辑。
StpInterface 是权限和角色数据提供者。
```

### 5.2 StpLogic 是什么

`StpLogic` 可以理解为 Sa-Token 中“一套账号体系的操作对象”。

默认 `StpUtil` 内部使用的是默认 `StpLogic`。

项目自己封装的 `StpBizUtil`、`StpPlatformUtil` 等，本质是给不同身份各自创建一个 `StpLogic`。

更具体地说，`StpLogic` 负责处理这些事情：

| 能力 | `StpLogic` 负责什么 |
|---|---|
| 登录 | 根据 loginId 创建登录态，生成 token |
| token 解析 | 从当前请求中读取 token |
| token 映射 | 根据 token 找到 loginId |
| Session | 根据 loginId 找账号 Session，根据 token 找 Token Session |
| 过期控制 | 管理 token、Session、Token Session 的过期时间 |
| 登录校验 | 判断当前请求是否已登录 |
| 权限校验 | 调用 `StpInterface` 获取权限，再判断是否包含目标权限 |
| 角色校验 | 调用 `StpInterface` 获取角色，再判断是否包含目标角色 |
| 踢人 / 顶人 / 退出 | 清理或标记对应 token 登录态 |
| 封禁 / 二级认证 | 管理额外账号状态 |

所以：

```java
StpUtil.login(1001);
```

表面看是调用工具类，实际会委托给默认 `StpLogic`：

```text
StpUtil.login(1001)
  -> 默认 StpLogic.login(1001)
  -> 生成 token
  -> 保存 token 与 loginId 的映射
  -> 创建 / 更新 Session
```

项目里的：

```java
StpBizUtil.login(1001);
```

则是：

```text
StpBizUtil.login(1001)
  -> biz StpLogic.login(1001)
  -> 在 biz 账号体系下生成 token 和 Session
```

这就是多账号体系能成立的关键：不是多个工具类共用同一套逻辑，而是每个工具类背后都有自己的 `StpLogic`。

### 5.3 StpInterface 是什么

`StpInterface` 是 Sa-Token 留给业务系统实现的权限数据接口。

Sa-Token 自己不知道项目的角色表、权限表长什么样，也不知道某个用户有哪些权限。因此它只规定两个方法：

```java
List<String> getPermissionList(Object loginId, String loginType);

List<String> getRoleList(Object loginId, String loginType);
```

这里有两个参数非常关键：

| 参数 | 含义 | 来源 |
|---|---|---|
| `loginId` | 当前登录账号的业务 ID | 登录时传给 `login(...)` 的值 |
| `loginType` | 当前账号属于哪套 Sa-Token 登录体系 | 当前使用的 `StpLogic` 的类型 |

也就是说：

```text
loginId 解决“是谁”。
loginType 解决“是哪一类账号体系里的谁”。
```

### 5.3.1 loginId 是什么

`loginId` 是登录时传入 Sa-Token 的账号标识。

例如 C 端会员登录：

```java
StpUtil.login(userVO.getCardLid(), false);
```

这里传入的：

```java
userVO.getCardLid()
```

后续就会成为默认账号体系下的 `loginId`。

商户 / POS 用户登录：

```java
StpBizUtil.login(vo.getLid(), saLoginModel);
```

这里传入的：

```java
vo.getLid()
```

后续就会成为 `biz` 账号体系下的 `loginId`。

平台用户登录：

```java
StpPlatformUtil.login(user.getLid(), false);
```

这里传入的：

```java
user.getLid()
```

后续就会成为 `platform` 账号体系下的 `loginId`。

所以 `loginId` 不固定等于数据库表里的 `id`，它等于项目登录时主动传给 Sa-Token 的那个业务标识。

在本项目中常见是：

| 账号体系 | 登录代码 | loginId 实际含义 |
|---|---|---|
| C 端会员 | `StpUtil.login(userVO.getCardLid())` | 会员卡 lid / cardLid |
| 商户端 | `StpBizUtil.login(vo.getLid())` | 商户用户 lid |
| POS 端 | `StpBizUtil.login(vo.getLid())` | POS 用户 lid |
| 平台端 | `StpPlatformUtil.login(user.getLid())` | 平台用户 lid |

`loginId` 的类型是 `Object`，是因为 Sa-Token 允许项目传：

```text
Long
Integer
String
```

甚至其他可序列化对象。

但实际项目里一般应该保持稳定，避免同一套体系里一会儿传 `Long 1001`，一会儿传 `"1001"`，否则会造成 Session key 和判断逻辑不一致。

### 5.3.2 loginType 是什么

`loginType` 是当前 Sa-Token 登录体系的类型。

它来自 `StpLogic`。

默认 `StpUtil` 的 loginType 通常是：

```text
login
```

项目自定义工具类分别定义了自己的类型：

```java
StpBizUtil.TYPE = "biz";
StpPlatformUtil.TYPE = "platform";
StpInstUtil.TYPE = "inst";
StpSplUtil.TYPE = "spl";
```

当调用：

```java
StpBizUtil.login(1001);
```

就是：

```text
loginId = 1001
loginType = biz
```

当调用：

```java
StpPlatformUtil.login(1001);
```

就是：

```text
loginId = 1001
loginType = platform
```

当调用：

```java
StpUtil.login(1001);
```

就是：

```text
loginId = 1001
loginType = login
```

### 5.3.3 为什么有 loginId 还要 loginType

`loginId` 和 `loginType` 都是 Sa-Token 本身支持的概念，不是本项目自己发明的。

Sa-Token 的设计理念是：

```text
loginId   = 当前登录账号的标识
loginType = 当前登录账号所属的账号体系
```

也可以理解为：

```text
loginType = 命名空间
loginId   = 命名空间内的账号 ID
```

因为不同账号体系里可能存在相同的 `loginId`。

例如：

```text
C端会员 loginId = 1001
商户用户 loginId = 1001
平台用户 loginId = 1001
```

如果只有 `loginId`，Sa-Token 无法知道：

```text
1001 到底是会员、商户用户，还是平台管理员？
```

所以必须同时有：

```text
loginId + loginType
```

才能唯一确定当前身份上下文。

可以理解为：

```text
loginType = 命名空间
loginId   = 命名空间内的账号 ID
```

类似：

```text
login:1001     -> C端会员 1001
biz:1001       -> 商户 / POS 用户 1001
platform:1001  -> 平台用户 1001
```

这也是 Redis 中为什么要按不同 loginType 隔离 Session：

```text
satoken:login:session:1001
satoken:biz:session:1001
satoken:platform:session:1001
```

这三个 key 后缀都是 `1001`，但属于不同账号体系，保存的用户对象和权限完全不同。

这也是 Sa-Token 多账号体系的核心设计：

```text
Sa-Token 不假设一个系统里只有一种用户。
它允许用不同 loginType 把不同身份隔离开。
```

例如 SaaS 系统里可能同时有：

```text
平台管理员
商户管理员
门店 POS 操作员
C端会员
机构用户
供应商用户
```

这些身份可能来自不同数据库表，也可能 ID 重复。

Sa-Token 用：

```text
loginType + loginId
```

共同确定当前登录身份。

所以：

```text
platform:1001
  -> 平台用户 1001

biz:1001
  -> 商户 / POS 用户 1001

login:1001
  -> 默认体系用户，项目里主要是 C端会员 1001
```

它们即使 `loginId` 都是 `1001`，也不是同一个登录身份。

### 5.3.4 这两个参数在权限校验中如何传入

业务代码一般不会手动调用：

```java
getPermissionList(loginId, loginType)
```

而是写：

```java
@SaBizCheckPermission("dish:add")
```

或者：

```java
StpBizUtil.checkPermission("dish:add");
```

Sa-Token 内部会自动得到这两个值。

流程如下：

```text
1. 请求携带 token。

2. 接口注解是 @SaBizCheckPermission。

3. 注解上绑定 type = "biz"。

4. Sa-Token 使用 biz 对应 StpLogic。

5. biz StpLogic 根据 token 找到 loginId。

6. biz StpLogic 调用：
   StpInterface.getPermissionList(loginId, "biz")
```

平台端类似：

```text
@SaPlatformCheckPermission
  -> type = "platform"
  -> StpInterface.getPermissionList(loginId, "platform")
```

C 端默认体系类似：

```text
@SaCheckLogin / @SaCheckPermission
  -> type = "login"
  -> StpInterface.getPermissionList(loginId, "login")
```

因此这两个方法的完整含义是：

```text
给我一个 loginId 和 loginType，
你告诉我这个账号有哪些权限码和角色标识。
```

权限校验时，Sa-Token 的链路大致是：

```text
StpLogic.checkPermission("xxx")
  -> 获取当前 loginId
  -> 获取当前 loginType
  -> 调用 StpInterface.getPermissionList(loginId, loginType)
  -> 判断返回的权限列表是否包含 xxx
  -> 不包含则抛出无权限异常
```

角色校验类似：

```text
StpLogic.checkRole("admin")
  -> 获取当前 loginId
  -> 获取当前 loginType
  -> 调用 StpInterface.getRoleList(loginId, loginType)
  -> 判断返回的角色列表是否包含 admin
```

在这个项目里，`StpInterfaceImpl` 的实现不是实时查数据库，而是从 SaSession 中取：

```java
public List<String> getPermissionList(Object loginId, String loginType) {
  SaSession session = getSession(loginType);
  return Optional.ofNullable(session)
      .map(i -> (List<String>) i.get(CommonConstants.PERMISSION_IN_SA_TOKEN))
      .orElse(Collections.emptyList());
}
```

角色也是从 Session 取：

```java
public List<String> getRoleList(Object loginId, String loginType) {
  SaSession session = getSession(loginType);
  return Optional.ofNullable(session)
      .map(i -> (List<String>) i.get(CommonConstants.ROLE_IN_SA_TOKEN))
      .orElse(Collections.emptyList());
}
```

也就是说，项目的权限技术路线是：

```text
登录时：
  查数据库 / 远程服务，算出角色和权限
  -> 写入 SaSession

鉴权时：
  Sa-Token 调 StpInterface
  -> StpInterface 从 SaSession 取角色和权限
  -> Sa-Token 判断是否放行
```

这比每次鉴权都查数据库更快，也更适合 POS 高频操作。

### 5.4 StpLogic 和 StpInterface 的关系

二者关系可以这样理解：

```text
StpLogic = 执行认证鉴权动作的人
StpInterface = 告诉 StpLogic 当前用户拥有哪些角色和权限的人
```

用接口权限校验举例：

```text
接口上写：
@SaBizCheckPermission("dish:add")

请求进来：
  -> Sa-Token 找到 biz StpLogic
  -> biz StpLogic 识别当前 token 和 loginId
  -> biz StpLogic 要校验 dish:add
  -> biz StpLogic 调 StpInterface.getPermissionList(loginId, "biz")
  -> StpInterfaceImpl 找 StpBizUtil.getSession()
  -> 从 biz Session 中取 PERMISSION_IN_SA_TOKEN
  -> 返回权限码列表
  -> biz StpLogic 判断是否包含 dish:add
```

所以 `StpLogic` 不直接知道权限存在哪里。

它只知道：

```text
我要校验权限，就去问 StpInterface。
```

而 `StpInterfaceImpl` 才知道本项目把权限放在：

```java
CommonConstants.PERMISSION_IN_SA_TOKEN
CommonConstants.ROLE_IN_SA_TOKEN
```

这也是 Sa-Token 的扩展点设计：

```text
框架负责认证鉴权流程。
项目负责提供业务权限数据。
```

### 5.5 商户端 StpBizUtil

商户端工具类中定义：

```java
public static final String TYPE = "biz";

public static StpLogic stpLogic =
    new StpLogic(TYPE) {
      @Override
      public String splicingKeyTokenName() {
        return super.splicingKeyTokenName() + "-" + TYPE;
      }
    };
```

关键点是：

```java
new StpLogic("biz")
```

这表示创建一套名为 `biz` 的登录体系。

以后调用：

```java
StpBizUtil.login(userId);
```

就不是默认 `login` 体系登录，而是：

```text
biz 体系下的 userId 登录。
```

### 5.6 平台端 StpPlatformUtil

平台端类似：

```java
public static final String TYPE = "platform";

public static StpLogic stpLogic =
    new StpLogic(TYPE) {
      @Override
      public String splicingKeyTokenName() {
        return super.splicingKeyTokenName() + "-" + TYPE;
      }
    };
```

调用：

```java
StpPlatformUtil.login(userId);
```

表示：

```text
platform 体系下的 userId 登录。
```

### 5.7 为什么要重写 splicingKeyTokenName

项目中每个自定义 `StpLogic` 都重写了：

```java
splicingKeyTokenName()
```

返回值类似：

```java
super.splicingKeyTokenName() + "-" + TYPE
```

全局 token 名称配置是：

```java
config.setTokenName("nms4token");
```

重写后，不同体系会在 tokenName 上拼接账号类型。

概念上可以理解为：

```text
默认 C 端：nms4token
商户端：nms4token-biz
平台端：nms4token-platform
机构端：nms4token-inst
特殊端：nms4token-spl
```

这样做的目的：

- 前端可以同时保存不同端的 token。
- 后端读取 token 时能按对应体系读取。
- 平台 token 和商户 token 不会因为 header 名相同而混淆。

实际 header 名要以 Sa-Token 运行时配置和 `StpLogic` 结果为准，但设计意图就是区分不同账号体系的 token 名。

---

## 6. 启动时如何让多套 StpLogic 生效

配置类：

```text
SaTokenConfigure.java
```

核心逻辑：

```java
@PostConstruct
public void rewriteSaStrategy() {
  StpLogic userLogic = StpBizUtil.stpLogic;
  StpLogic instLogic = StpInstUtil.stpLogic;
  StpLogic managerLogic = StpPlatformUtil.stpLogic;
  StpLogic stpSpLogic = StpSplUtil.stpLogic;

  SaStrategy.me.getAnnotation = AnnotatedElementUtils::getMergedAnnotation;
}
```

这段代码看起来只是声明变量，但注释说明了用途：

```text
调用 StpBizUtil、StpPlatformUtil 等，用于初始化它们的静态变量。
不要删除。
```

也就是说，项目启动时通过访问这些类的静态字段，让各自的 `StpLogic` 被创建和注册。

同时这里还重写了 Sa-Token 的注解获取策略：

```java
SaStrategy.me.getAnnotation = AnnotatedElementUtils::getMergedAnnotation;
```

原因是项目自定义了组合注解，例如：

```java
@SaBizCheckPermission
@SaPlatformCheckPermission
```

这些注解本身又包装了 Sa-Token 原生注解：

```java
@SaCheckPermission(type = StpBizUtil.TYPE)
```

使用 `AnnotatedElementUtils.getMergedAnnotation` 可以让 Spring 风格的组合注解、别名属性正常合并解析。

如果没有这一步，自定义注解上的 `@AliasFor`、组合注解可能无法按预期被 Sa-Token 识别。

---

## 7. 多账号体系里这些类和注解是如何串起来的

多账号体系不是靠某一个类单独完成的，而是由下面几类组件串在一起：

| 组件 | 代表类 / 注解 | 职责 |
|---|---|---|
| 账号体系逻辑 | `StpLogic` | 真正执行登录、取 token、查 Session、校验权限 |
| 账号体系工具类 | `StpBizUtil`、`StpPlatformUtil`、`StpInstUtil`、`StpSplUtil` | 对外提供静态 API，内部委托给对应 `StpLogic` |
| 自定义注解 | `@SaBizCheckPermission`、`@SaPlatformCheckPermission` 等 | 在接口上声明要使用哪套账号体系校验 |
| 启动配置 | `SaTokenConfigure` | 初始化多套 `StpLogic`，让组合注解能被 Sa-Token 识别 |
| 权限数据提供者 | `StpInterfaceImpl` | 根据 `loginType` 找对应 Session，返回角色和权限 |
| 登录入口 | 平台 / 商户 / POS / C端登录 Controller 或 Service | 调用对应工具类登录，并把用户、角色、权限写入 Session |
| Session 常量 | `CommonConstants.USER_IN_SA_TOKEN` 等 | 约定 Session 中保存哪些登录态和权限态数据 |
| Redis 存储 | `SaTokenDaoRedisJackson` 等 | 把 token、Session、token-session 持久化到 Redis |

可以先用一句话理解：

```text
工具类决定“用哪套 StpLogic 登录”。
注解决定“用哪套 StpLogic 鉴权”。
StpInterfaceImpl 决定“这套 StpLogic 到哪里拿角色和权限”。
Session 决定“角色和权限实际存在哪里”。
Redis 决定“这些登录态和 Session 最终落在哪里”。
```

### 7.1 登录时这些组件如何串起来

以 POS / 商户端登录为例。

业务登录入口调用：

```java
StpBizUtil.login(vo.getLid(), saLoginModel);
```

`StpBizUtil` 内部不是自己实现登录细节，而是转给它持有的：

```java
StpBizUtil.stpLogic
```

也就是：

```text
StpBizUtil.login(...)
  -> biz StpLogic.login(...)
```

`biz StpLogic` 根据 `loginId` 创建登录态：

```text
loginId = vo.getLid()
loginType = biz
```

然后 Sa-Token 底层生成 token，并通过 `SaTokenDao` 保存登录态。

如果接入 Redis，则概念上会写入：

```text
satoken:biz:token:{token}
satoken:biz:session:{loginId}
satoken:biz:token-session:{token}
```

登录成功后，项目业务代码继续写账号 Session：

```java
SaSession session = StpBizUtil.getSession();

session.set(CommonConstants.USER_IN_SA_TOKEN, user);
session.set(CommonConstants.PERMISSION_IN_SA_TOKEN, user.getPermissionKes());
session.set(CommonConstants.ROLE_IN_SA_TOKEN, rolesKey);
session.set(CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN, DataScopeEnum.SELF_DEPT);
```

完整登录链路：

```text
POS / 商户登录接口
  -> StpBizUtil.login(loginId)
  -> StpBizUtil.stpLogic.login(loginId)
  -> biz StpLogic 生成 token
  -> SaTokenDao 写 token 映射和 Session
  -> 项目代码 StpBizUtil.getSession()
  -> 项目代码写 USER / PERMISSION / ROLE / DATA_SCOPE
  -> 返回 token 给前端
```

平台端同理，只是换成：

```java
StpPlatformUtil.login(user.getLid(), false);
StpPlatformUtil.getSession();
```

链路变成：

```text
平台登录接口
  -> StpPlatformUtil.login(loginId)
  -> platform StpLogic.login(loginId)
  -> Redis 写 platform 命名空间
  -> StpPlatformUtil.getSession()
  -> 写 PlatformAdminVO、平台权限、平台角色、平台数据范围
```

C 端会员则使用默认：

```java
StpUtil.login(userVO.getCardLid(), false);
StpUtil.getSession();
```

链路是：

```text
C端登录接口
  -> StpUtil.login(cardLid)
  -> 默认 login StpLogic.login(cardLid)
  -> Redis 写 login 命名空间
  -> StpUtil.getSession()
  -> 写 CUserVO
```

### 7.2 接口鉴权时这些组件如何串起来

以商户 / POS 接口为例：

```java
@SaBizCheckPermission("dish:add")
public Object addDish() {
  ...
}
```

`@SaBizCheckPermission` 本身是项目自定义注解，它内部绑定了 Sa-Token 原生注解：

```java
@SaCheckPermission(type = StpBizUtil.TYPE)
```

而：

```java
StpBizUtil.TYPE = "biz"
```

所以这个注解等价于告诉 Sa-Token：

```text
请使用 biz 账号体系校验 dish:add 权限。
```

请求进入时：

```text
1. SaInterceptor 拦截请求。

2. Sa-Token 解析接口注解。

3. 发现 @SaBizCheckPermission。

4. 通过组合注解拿到 type = biz。

5. Sa-Token 找到 biz 对应的 StpLogic。

6. biz StpLogic 从请求中读取 biz token。

7. biz StpLogic 根据 token 找到 loginId。

8. biz StpLogic 需要校验权限 dish:add。

9. biz StpLogic 调 StpInterfaceImpl.getPermissionList(loginId, "biz")。

10. StpInterfaceImpl 根据 loginType=biz 调 StpBizUtil.getSession()。

11. 从 biz Session 读取 PERMISSION_IN_SA_TOKEN。

12. 返回权限码列表给 biz StpLogic。

13. biz StpLogic 判断是否包含 dish:add。

14. 有权限则放行，没有权限则抛出 NotPermissionException。
```

平台端接口类似：

```java
@SaPlatformCheckPermission("merchant:add")
```

对应链路：

```text
@SaPlatformCheckPermission
  -> type = platform
  -> platform StpLogic
  -> StpInterfaceImpl.getPermissionList(loginId, "platform")
  -> StpPlatformUtil.getSession()
  -> 读取平台 Session 中的 PERMISSION_IN_SA_TOKEN
```

C 端会员接口：

```java
@SaCheckLogin
```

对应链路：

```text
@SaCheckLogin
  -> 默认 login StpLogic
  -> StpUtil.getSession()
  -> 读取 C端 Session
```

### 7.3 自定义注解为什么能被 Sa-Token 识别

项目不是直接在 Controller 上写：

```java
@SaCheckPermission(type = "biz", value = "dish:add")
```

而是写：

```java
@SaBizCheckPermission("dish:add")
```

原因是自定义注解内部封装了：

```java
@SaCheckPermission(type = StpBizUtil.TYPE)
```

并通过 `@AliasFor` 把 `value`、`mode`、`orRole` 等属性转交给原生注解。

例如：

```java
@AliasFor(annotation = SaCheckPermission.class)
String[] value() default {};
```

这表示：

```text
@SaBizCheckPermission("dish:add")
中的 "dish:add"
会传给 Sa-Token 原生 @SaCheckPermission 的 value。
```

但是普通 Java 反射直接取注解时，不一定能完整解析 Spring 组合注解和 `@AliasFor`。

所以启动配置中重写了：

```java
SaStrategy.me.getAnnotation = AnnotatedElementUtils::getMergedAnnotation;
```

这一步让 Sa-Token 在读取注解时，能够按 Spring 的合并注解规则识别：

```text
@SaBizCheckPermission
  -> 内部的 @SaCheckPermission
  -> type = biz
  -> value = dish:add
```

如果没有这一步，自定义组合注解可能无法稳定地被 Sa-Token 当作原生权限注解处理。

### 7.4 StpInterfaceImpl 如何把 loginType 映射回工具类

权限校验时，Sa-Token 调的是统一接口：

```java
getPermissionList(Object loginId, String loginType)
```

但项目里有多套 Session：

```text
StpUtil.getSession()
StpBizUtil.getSession()
StpPlatformUtil.getSession()
StpInstUtil.getSession()
StpSplUtil.getSession()
```

所以 `StpInterfaceImpl` 必须根据 `loginType` 选择对应工具类：

```java
if (Objects.equals(loginType, StpPlatformUtil.TYPE)) {
  return StpPlatformUtil.getSession();
} else if (Objects.equals(loginType, StpBizUtil.TYPE)) {
  return StpBizUtil.getSession();
} else if (Objects.equals(loginType, StpInstUtil.TYPE)) {
  return StpInstUtil.getSession();
} else if (Objects.equals(loginType, StpSplUtil.TYPE)) {
  return StpSplUtil.getSession();
}
return StpUtil.getSession();
```

这段映射非常关键。

如果 `loginType = biz`，却错误地去 `StpUtil.getSession()` 取权限，就会去默认 C 端 Session 里找商户权限，结果必然不对。

正确映射是：

| loginType | 应该使用的 Session |
|---|---|
| `login` | `StpUtil.getSession()` |
| `biz` | `StpBizUtil.getSession()` |
| `platform` | `StpPlatformUtil.getSession()` |
| `inst` | `StpInstUtil.getSession()` |
| `spl` | `StpSplUtil.getSession()` |

### 7.5 多账号体系的完整串联图

```text
启动阶段：

SaTokenConfigure
  -> 触发 StpBizUtil.stpLogic 初始化
  -> 触发 StpPlatformUtil.stpLogic 初始化
  -> 触发 StpInstUtil.stpLogic 初始化
  -> 触发 StpSplUtil.stpLogic 初始化
  -> 重写 SaStrategy.me.getAnnotation
     让自定义组合注解可被 Sa-Token 识别


登录阶段：

登录接口
  -> 调对应工具类 login()
     例如 StpBizUtil.login(loginId)
  -> 工具类委托给自己的 StpLogic
     例如 biz StpLogic
  -> StpLogic 生成 token / 创建登录态
  -> SaTokenDao 保存到 Redis
  -> 业务代码把用户、角色、权限、数据范围写入对应 Session


鉴权阶段：

Controller 注解
  -> @SaBizCheckPermission / @SaPlatformCheckPermission / @SaCheckLogin
  -> Sa-Token 解析注解 type
  -> 找到对应 StpLogic
  -> StpLogic 根据 token 找 loginId
  -> StpLogic 调 StpInterfaceImpl
  -> StpInterfaceImpl 根据 loginType 找对应 Session
  -> 从 Session 取角色 / 权限
  -> StpLogic 完成权限判断


业务阶段：

业务代码
  -> BaseService.getAdmin() / getPlatformAdmin() / getUser()
  -> 内部调用对应工具类 getSession()
  -> 从 Session 取 USER_IN_SA_TOKEN
  -> 得到当前登录用户对象
```

### 7.6 记忆口诀

可以用这几句话记住整体关系：

```text
StpLogic 定义一套账号体系。
StpBizUtil 这类工具类包装 StpLogic。
自定义注解把接口绑定到某个 loginType。
SaTokenConfigure 让这些工具类和注解生效。
登录代码把用户、角色、权限写入对应 Session。
StpInterfaceImpl 根据 loginType 从对应 Session 取权限。
SaTokenDao 把这些 token 和 Session 落到 Redis。
```

---

## 8. Sa-Token 全局配置

项目在 `SaTokenConfigure` 中设置了全局参数：

```java
config.setTokenName("nms4token");
config.setTimeout(1 * 24 * 60 * 60L);
config.setActivityTimeout(-1);
config.setIsConcurrent(true);
config.setIsShare(true);
config.setTokenStyle("uuid");
config.setIsReadCookie(false);
config.setIsLog(false);
```

含义如下：

| 配置 | 含义 | 项目效果 |
|---|---|---|
| `tokenName = nms4token` | token 名称 | 默认请求头 / 参数名以 `nms4token` 为基础 |
| `timeout = 86400` | token 总有效期，秒 | 默认 1 天 |
| `activityTimeout = -1` | 临时活跃过期 | 不按未操作时间过期 |
| `isConcurrent = true` | 是否允许并发登录 | 同账号可多处登录 |
| `isShare = true` | 多处登录是否共享 token | 默认同账号可能共享 token |
| `tokenStyle = uuid` | token 生成风格 | 使用 UUID 风格 |
| `isReadCookie = false` | 是否从 Cookie 读 token | 不依赖 Cookie，更适合前后端分离 |
| `isLog = false` | Sa-Token 日志 | 不输出框架操作日志 |

需要注意：POS 端登录时又通过 `SaLoginModel` 单独覆盖了超时时间。

---

## 9. 不同账号体系如何登录

### 9.1 平台端登录

平台端登录使用：

```java
StpPlatformUtil.login(user.getLid(), false);
```

登录后获取 token：

```java
SaTokenInfo tokenInfo = StpPlatformUtil.getTokenInfo();
```

然后把平台用户信息写入平台 Session：

```java
session.set(CommonConstants.USER_IN_SA_TOKEN, vo);
session.set(CommonConstants.PERMISSION_IN_SA_TOKEN, permissionIds);
session.set(CommonConstants.ROLE_IN_SA_TOKEN, rolesKey);
session.set(CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN, dataScope);
```

如果是自定义数据权限，还会写：

```java
session.set(CommonConstants.DEPT_ID_LIST, deptIds);
```

完整链路：

```text
平台用户提交账号密码
  -> 查询 SysUser
  -> 查询角色 SysRole
  -> 查询权限 SysPermission
  -> 计算 DataScopeEnum
  -> StpPlatformUtil.login(user.lid)
  -> 得到平台 token
  -> 写入 platform Session
  -> 返回 tokenName、tokenValue、tokenTimeout
```

### 9.2 云端商户登录

云端商户端使用：

```java
StpBizUtil.login(vo.getLid(), false);
```

或者在某些入口中先踢掉旧 token：

```java
List<String> tokenValueListByLoginId = StpBizUtil.getTokenValueListByLoginId(loginId);
tokenValueListByLoginId.forEach(StpBizUtil::kickoutByTokenValue);
StpBizUtil.login(loginId, false);
```

登录后写入商户 Session：

```java
session.set(CommonConstants.USER_IN_SA_TOKEN, vo);
session.set(CommonConstants.PERMISSION_IN_SA_TOKEN, permissionsResult);
session.set(CommonConstants.ROLE_IN_SA_TOKEN, rolesKey);
session.set(CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN, dataScope);
```

如果数据范围是自定义或本部门及下级，还会写：

```java
session.set(CommonConstants.DEPT_ID_LIST, deptLids);
```

完整链路：

```text
商户用户登录
  -> 查询商户、门店、用户
  -> 查询角色
  -> 查询权限
  -> 查询数据权限范围
  -> StpBizUtil.login(loginId)
  -> 写入 biz Session
  -> 返回商户端 token
```

### 9.3 POS 端登录

POS 端也使用商户体系：

```java
StpBizUtil.login(vo.getLid(), saLoginModel);
```

但 POS 端会设置特殊登录参数：

```java
SaLoginModel saLoginModel = new SaLoginModel();
saLoginModel.setTimeout(-1L);
saLoginModel.setIsLastingCookie(false);
```

含义：

```text
POS token 设置为不过期或长期有效。
不使用持久 Cookie。
```

登录后 POS 调用：

```java
authService.refreshSession(vo, session, StpBizUtil.getTokenTimeout());
```

`refreshSession` 中写入：

```java
session.set(CommonConstants.USER_IN_SA_TOKEN, user);
session.set(CommonConstants.PERMISSION_IN_SA_TOKEN, user.getPermissionKes());
session.set(CommonConstants.ROLE_IN_SA_TOKEN, rolesKey);
session.set(CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN, DataScopeEnum.SELF_DEPT);
PermissionUtil.put(user.getLid(), permissions.getKey(), timeout);
```

这里非常关键：

```text
POS 系统中，只能操作本门店的数据。
```

所以 POS 端固定写：

```java
DataScopeEnum.SELF_DEPT
```

完整链路：

```text
POS 用户登录
  -> 查询本地用户 / 门店 / 角色 / 权限
  -> StpBizUtil.login(user.lid, timeout=-1)
  -> 写 USER_IN_SA_TOKEN
  -> 写 PERMISSION_IN_SA_TOKEN
  -> 写 ROLE_IN_SA_TOKEN
  -> 写 DATA_SCOPE_OF_ROLE_IN_SA_TOKEN = SELF_DEPT
  -> 写 POS 细粒度权限缓存
  -> 返回 token 给 POS 前端
```

### 9.4 C 端会员登录

C 端会员使用 Sa-Token 默认体系：

```java
StpUtil.login(userVO.getCardLid(), false);
SaTokenInfo tokenInfo = StpUtil.getTokenInfo();
SaSession session = StpUtil.getSession();
session.set(CommonConstants.USER_IN_SA_TOKEN, userVO);
```

C 端会员登录态保存的是：

```text
CUserVO
```

不是 `BizAdminVO`，也不是 `PlatformAdminVO`。

完整链路：

```text
微信 / 会员端登录
  -> 解析 openid / unionid / 手机号 / 会员卡
  -> StpUtil.login(cardLid)
  -> 写 CUserVO 到默认 Session
  -> 返回 token
```

---

## 10. Session 中到底存了什么

项目把 SaSession 当成登录后的“身份缓存 + 权限缓存 + 数据范围缓存”。

常见 key：

| Session Key | 存放内容 | 用途 |
|---|---|---|
| `USER_IN_SA_TOKEN` | 当前登录用户 VO | 后续业务获取当前用户 |
| `BOSS_IN_SA_TOKEN` | 老板通 / 特殊商户用户 VO | 某些商户入口特殊身份 |
| `PERMISSION_IN_SA_TOKEN` | 权限码列表 | Sa-Token 权限校验 |
| `ROLE_IN_SA_TOKEN` | 角色标识列表 | Sa-Token 角色校验 |
| `DATA_SCOPE_OF_ROLE_IN_SA_TOKEN` | 数据权限枚举 | 控制数据范围 |
| `DEPT_ID_LIST` | 自定义数据范围 ID 列表 | 数据权限为自定义时使用 |
| POS 自定义 key | POS 细粒度权限 map | 退菜、赠菜、报表、金额等操作权限 |

### 10.1 为什么登录时就把权限写入 Session

如果每次接口请求都查数据库：

```text
每个接口
  -> 查用户
  -> 查角色
  -> 查角色权限
  -> 查数据权限
  -> 再判断接口权限
```

会带来几个问题：

- 高频接口性能差。
- POS 本地操作很多，不能每次都依赖远程权限查询。
- 权限判断逻辑分散。
- 数据库压力大。

所以项目选择：

```text
登录时查一次权限
  -> 写入 SaSession
  -> 后续权限校验直接读 Session
```

如果权限变更，需要刷新 Session。

POS 端有：

```java
PermissionUtil.reload()
```

用于重新加载已登录用户权限。

---

## 11. 权限校验是如何执行的

### 11.1 自定义权限注解

商户端权限注解：

```java
@SaCheckPermission(type = StpBizUtil.TYPE)
public @interface SaBizCheckPermission {
}
```

平台端权限注解：

```java
@SaCheckPermission(type = StpPlatformUtil.TYPE)
public @interface SaPlatformCheckPermission {
}
```

所以：

```java
@SaBizCheckPermission("xxx")
```

意思不是“普通用户需要 xxx 权限”，而是：

```text
使用 biz 账号体系检查 xxx 权限。
```

而：

```java
@SaPlatformCheckPermission("xxx")
```

意思是：

```text
使用 platform 账号体系检查 xxx 权限。
```

### 11.2 权限数据由 StpInterfaceImpl 提供

Sa-Token 校验权限时，会调用项目实现的：

```java
StpInterfaceImpl
```

核心方法：

```java
public List<String> getPermissionList(Object loginId, String loginType)
public List<String> getRoleList(Object loginId, String loginType)
```

项目实现不是去数据库查，而是：

```java
SaSession session = getSession(loginType);
return session.get(CommonConstants.PERMISSION_IN_SA_TOKEN);
```

角色类似：

```java
return session.get(CommonConstants.ROLE_IN_SA_TOKEN);
```

### 11.3 getSession(loginType) 如何选择不同体系

核心逻辑：

```java
private SaSession getSession(String loginType) {
  if (Objects.equals(loginType, StpPlatformUtil.TYPE)) {
    return StpPlatformUtil.getSession();
  } else if (Objects.equals(loginType, StpBizUtil.TYPE)) {
    return StpBizUtil.getSession();
  } else if (Objects.equals(loginType, StpInstUtil.TYPE)) {
    return StpInstUtil.getSession();
  } else if (Objects.equals(loginType, StpSplUtil.TYPE)) {
    return StpSplUtil.getSession();
  }
  return StpUtil.getSession();
}
```

这就是多账号体系权限隔离的关键。

同样是检查权限：

```text
@SaBizCheckPermission
  -> loginType = biz
  -> StpBizUtil.getSession()
  -> 读取 biz Session 里的权限

@SaPlatformCheckPermission
  -> loginType = platform
  -> StpPlatformUtil.getSession()
  -> 读取 platform Session 里的权限

@SaCheckLogin
  -> 默认 login
  -> StpUtil.getSession()
  -> 读取 C 端 Session
```

### 11.4 一次商户端权限校验完整链路

```text
1. 请求进入商户端接口

2. 接口标注：
   @SaBizCheckPermission("pos_dish:add")

3. Sa-Token 解析注解：
   type = biz
   permission = pos_dish:add

4. Sa-Token 使用 biz 对应 StpLogic

5. 从请求中读取 biz token

6. 根据 token 找到 loginId

7. 调用 StpInterfaceImpl.getPermissionList(loginId, "biz")

8. StpInterfaceImpl 调用 StpBizUtil.getSession()

9. 从 Session 中取：
   PERMISSION_IN_SA_TOKEN

10. 判断权限列表中是否包含 pos_dish:add

11. 包含则放行，不包含则抛出 NotPermissionException
```

### 11.5 一次平台端权限校验完整链路

```text
1. 请求进入平台端接口

2. 接口标注：
   @SaPlatformCheckPermission("merchant:add")

3. Sa-Token 解析注解：
   type = platform

4. 使用 platform 对应 StpLogic

5. 读取平台 token

6. 找到平台 loginId

7. 调 StpInterfaceImpl.getPermissionList(loginId, "platform")

8. 调 StpPlatformUtil.getSession()

9. 从平台 Session 读取权限码

10. 判断是否包含 merchant:add
```

---

## 12. 多账号体系如何避免 token 和 Session 串用

假设三个身份都有 `loginId = 1001`：

```text
平台用户 1001
商户用户 1001
C端会员 1001
```

项目中它们分别登录：

```java
StpPlatformUtil.login(1001);
StpBizUtil.login(1001);
StpUtil.login(1001);
```

概念上会形成三套不同上下文：

```text
platform:
  loginId = 1001
  user = PlatformAdminVO
  roles = 平台角色
  permissions = 平台权限

biz:
  loginId = 1001
  user = BizAdminVO
  roles = 商户角色
  permissions = 商户/POS权限

login:
  loginId = 1001
  user = CUserVO
  roles = 通常为空或C端角色
  permissions = C端权限
```

请求访问时，接口注解决定使用哪套上下文：

```text
@SaPlatformCheckPermission
  只认 platform 登录态

@SaBizCheckPermission
  只认 biz 登录态

@SaCheckLogin
  只认默认 login 登录态
```

所以即使 ID 相同，也不会混用用户对象和权限。

---

## 13. Redis 中的隔离方式

如果项目使用 Redis 作为 `SaTokenDao`，Sa-Token 的登录态、账号 Session、Token Session 都会落到 Redis。

先看单账号体系中的三类核心 key。

以默认 C 端会员体系为例：

```text
loginType = login
loginId   = 1001
token     = e24c96f6-ab93-46f3-964a-84f461c394a6
```

Redis 中通常会有三类数据：

| Redis Key | 后缀是谁 | 作用 |
|---|---|---|
| `satoken:login:token:e24c96f6-ab93-46f3-964a-84f461c394a6` | token | 通过 token 找到 `loginId=1001` |
| `satoken:login:session:1001` | loginId | 保存账号 `1001` 的账号 Session |
| `satoken:login:token-session:e24c96f6-ab93-46f3-964a-84f461c394a6` | token | 保存这个 token 自己的 Token Session |

请求进来时，Sa-Token 的查找链路是：

```text
请求携带 token
  -> 查 token key
  -> 得到 loginId
  -> 查 session key
  -> 得到账号 Session
  -> 如需要，再查 token-session key
```

也就是：

```text
token:{token}
  解决“这个 token 是谁的？”

session:{loginId}
  解决“这个账号有哪些用户信息、角色、权限、数据范围？”

token-session:{token}
  解决“当前这个 token 自己有什么临时数据？”
```

### 13.1 多账号体系下 Redis key 的变化

多账号体系的本质是：

```text
不同 loginType 拥有不同的 Redis 命名空间。
```

同样是 `loginId=1001`，如果分别是 C 端会员、商户用户、平台用户，那么它们不应该共用同一个 Session。

概念上可以这样理解：

```text
默认 C端：
satoken:login:token:{token}
satoken:login:session:{loginId}
satoken:login:token-session:{token}

商户端：
satoken:biz:token:{token}
satoken:biz:session:{loginId}
satoken:biz:token-session:{token}

平台端：
satoken:platform:token:{token}
satoken:platform:session:{loginId}
satoken:platform:token-session:{token}
```

实际 Redis key 的完整格式会受 Sa-Token 版本、配置和 `StpLogic` 拼接规则影响，因此不要死记具体字符串。真正要记住的是：

```text
loginType 不同，token 映射、账号 Session、Token Session 都属于不同命名空间。
```

一个商户 token 不应该被平台接口当成平台 token 使用。

一个 C 端会员 token 也不应该被商户后台接口当成商户管理员 token 使用。

### 13.2 默认 C 端会员在 Redis 中的数据

C 端会员使用原生 `StpUtil`，loginType 是默认值：

```text
loginType = login
```

登录代码类似：

```java
StpUtil.login(userVO.getCardLid(), false);
SaSession session = StpUtil.getSession();
session.set(CommonConstants.USER_IN_SA_TOKEN, userVO);
```

Redis 结构可以理解为：

```text
satoken:login:token:{cUserToken}
  -> value 中能找到 C端 loginId，例如 cardLid

satoken:login:session:{cardLid}
  -> USER_IN_SA_TOKEN = CUserVO

satoken:login:token-session:{cUserToken}
  -> 当前 C端 token 自己的数据，项目中不一定显式使用
```

C 端 Session 里主要放：

| Session 字段 | 内容 |
|---|---|
| `USER_IN_SA_TOKEN` | `CUserVO`，会员端当前登录用户 |

典型用途：

```java
BaseService.getUser()
  -> StpUtil.getSession()
  -> session.get(USER_IN_SA_TOKEN)
  -> CUserVO
```

### 13.3 商户端 / POS 端在 Redis 中的数据

商户端和 POS 端都使用：

```text
StpBizUtil
loginType = biz
```

云端商户登录或 POS 登录后，Redis 结构可以理解为：

```text
satoken:biz:token:{bizToken}
  -> value 中能找到商户 / POS 用户 loginId

satoken:biz:session:{loginId}
  -> USER_IN_SA_TOKEN
  -> BOSS_IN_SA_TOKEN
  -> PERMISSION_IN_SA_TOKEN
  -> ROLE_IN_SA_TOKEN
  -> DATA_SCOPE_OF_ROLE_IN_SA_TOKEN
  -> DEPT_ID_LIST
  -> POS 细粒度权限缓存

satoken:biz:token-session:{bizToken}
  -> 当前 biz token 自己的数据
```

云端商户 Session 常见字段：

| Session 字段 | 内容 | 用途 |
|---|---|---|
| `USER_IN_SA_TOKEN` | `BizAdminVO` | 当前商户用户 |
| `BOSS_IN_SA_TOKEN` | `BizAdminVO` | 老板通 / 特殊商户身份入口 |
| `PERMISSION_IN_SA_TOKEN` | `List<String>` | 商户端接口权限码 |
| `ROLE_IN_SA_TOKEN` | `List<String>` | 商户端角色标识 |
| `DATA_SCOPE_OF_ROLE_IN_SA_TOKEN` | `DataScopeEnum` | 数据权限范围 |
| `DEPT_ID_LIST` | `List<Long>` / `Set<Long>` | 自定义数据范围的门店 / 部门 ID |

POS 端 Session 也属于 `biz` 命名空间，但会额外写 POS 本地权限：

```text
satoken:biz:session:{posUserLid}
  -> USER_IN_SA_TOKEN = BizAdminVO
  -> PERMISSION_IN_SA_TOKEN = POS 普通权限码
  -> ROLE_IN_SA_TOKEN = POS 角色
  -> DATA_SCOPE_OF_ROLE_IN_SA_TOKEN = SELF_DEPT
  -> PermissionUtil 写入的权限 map
```

POS 端最重要的特点是：

```text
DATA_SCOPE_OF_ROLE_IN_SA_TOKEN = SELF_DEPT
```

表示本地 POS 只操作本门店数据。

`PermissionUtil.put(userLid, permissionMap, timeout)` 会把更细的 POS 操作权限放到同一个账号 Session 中，例如退菜、赠菜、报表、数值限制等权限缓存。

### 13.4 平台端在 Redis 中的数据

平台端使用：

```text
StpPlatformUtil
loginType = platform
```

Redis 结构可以理解为：

```text
satoken:platform:token:{platformToken}
  -> value 中能找到平台用户 loginId

satoken:platform:session:{loginId}
  -> USER_IN_SA_TOKEN
  -> PERMISSION_IN_SA_TOKEN
  -> ROLE_IN_SA_TOKEN
  -> DATA_SCOPE_OF_ROLE_IN_SA_TOKEN
  -> DEPT_ID_LIST

satoken:platform:token-session:{platformToken}
  -> 当前平台 token 自己的数据
```

平台 Session 常见字段：

| Session 字段 | 内容 | 用途 |
|---|---|---|
| `USER_IN_SA_TOKEN` | `PlatformAdminVO` | 当前平台管理员 |
| `PERMISSION_IN_SA_TOKEN` | `List<String>` | 平台端权限码 |
| `ROLE_IN_SA_TOKEN` | `List<String>` | 平台端角色 |
| `DATA_SCOPE_OF_ROLE_IN_SA_TOKEN` | `DataScopeEnum` | 平台数据权限范围 |
| `DEPT_ID_LIST` | 部门 ID 列表 | 自定义数据范围 |

平台接口使用：

```java
@SaPlatformCheckPermission
```

因此 Sa-Token 会按 `platform` 命名空间找 token 和 Session，而不是去 `biz` 或默认 `login` 命名空间找。

### 13.5 机构端和特殊端在 Redis 中的数据

机构端和特殊端同理：

```text
StpInstUtil
  -> loginType = inst

StpSplUtil
  -> loginType = spl
```

概念结构：

```text
satoken:inst:token:{instToken}
satoken:inst:session:{instLoginId}
satoken:inst:token-session:{instToken}

satoken:spl:token:{splToken}
satoken:spl:session:{splLoginId}
satoken:spl:token-session:{splToken}
```

`StpInterfaceImpl` 会根据 `loginType` 选择：

```text
inst -> StpInstUtil.getSession()
spl  -> StpSplUtil.getSession()
```

然后从对应 Session 里读取：

```text
PERMISSION_IN_SA_TOKEN
ROLE_IN_SA_TOKEN
```

### 13.6 同一个 loginId 在 Redis 中如何隔离

假设三个体系里都有 `loginId=1001`：

```text
C端会员 1001
商户用户 1001
平台用户 1001
```

如果三个用户分别登录，概念上会出现：

```text
satoken:login:session:1001
  -> USER_IN_SA_TOKEN = CUserVO

satoken:biz:session:1001
  -> USER_IN_SA_TOKEN = BizAdminVO
  -> PERMISSION_IN_SA_TOKEN = 商户/POS权限

satoken:platform:session:1001
  -> USER_IN_SA_TOKEN = PlatformAdminVO
  -> PERMISSION_IN_SA_TOKEN = 平台权限
```

同样是 `1001`，但因为 `loginType` 不同，Redis key 所属命名空间不同，所以不会互相覆盖。

请求访问时：

```text
@SaCheckLogin
  -> 查 login 命名空间

@SaBizCheckLogin
  -> 查 biz 命名空间

@SaPlatformCheckLogin
  -> 查 platform 命名空间
```

这就是多账号体系在 Redis 层面的本质隔离。

### 13.7 一个账号多个 token 时 Redis 如何表示

如果允许同账号多端登录，并且每次登录生成不同 token，概念上会变成：

```text
satoken:biz:session:1001
  -> 账号 1001 的商户 Session

satoken:biz:token:tokenA
  -> loginId = 1001

satoken:biz:token-session:tokenA
  -> tokenA 自己的数据

satoken:biz:token:tokenB
  -> loginId = 1001

satoken:biz:token-session:tokenB
  -> tokenB 自己的数据
```

这时：

```text
session:1001 是账号级的。
token-session:tokenA 是 tokenA 专属的。
token-session:tokenB 是 tokenB 专属的。
```

如果同一账号多端共享 token，则 token 数量会减少，但账号 Session 仍然是按 loginId 存。

### 13.8 账号 Session 和 Token Session 在项目里的取舍

这个项目大部分身份、权限、角色、数据范围都放在账号 Session：

```text
session:{loginId}
```

原因是这些数据属于账号维度：

- 当前用户对象。
- 角色列表。
- 权限码列表。
- 数据权限范围。
- POS 细粒度权限缓存。

`token-session:{token}` 更适合放 token 维度数据，例如：

- 当前设备类型。
- 当前设备 ID。
- 当前登录端。
- 当前 token 的临时二级认证扩展。
- 只对某一个 token 生效的临时状态。

如果一个商户账号同时在后台和 POS 登录，且两个端使用不同 token：

```text
账号级权限：
  放在 satoken:biz:session:{loginId}

后台 token 自己的数据：
  放在 satoken:biz:token-session:{backOfficeToken}

POS token 自己的数据：
  放在 satoken:biz:token-session:{posToken}
```

### 13.9 用 Redis 视角看一次 POS 权限校验

POS 登录后：

```text
StpBizUtil.login(posUserLid)
  -> Redis 写 biz token 映射
  -> Redis 写 biz session
  -> session 中保存 BizAdminVO、权限码、角色、SELF_DEPT、POS 权限缓存
```

POS 请求接口：

```text
请求携带 biz token
  -> @SaBizCheckPermission 触发 biz 权限校验
  -> Sa-Token 查 satoken:biz:token:{token}
  -> 得到 loginId = posUserLid
  -> 查 satoken:biz:session:{posUserLid}
  -> StpInterfaceImpl 从 Session 取 PERMISSION_IN_SA_TOKEN
  -> 判断接口权限
  -> 业务代码再按需要从同一个 Session 取 POS 细粒度权限缓存
```

所以 Redis 中真正支撑 POS 权限判断的核心不是单独一个权限 key，而是：

```text
satoken:biz:session:{posUserLid}
```

里面挂着当前 POS 用户的身份、角色、普通权限、数据权限和 POS 本地细粒度权限缓存。

---

## 14. 云端权限模型

云端权限主要是典型 RBAC + 数据权限。

### 14.1 功能权限

功能权限用于判断：

```text
这个人能不能访问某个接口、页面、按钮、功能点。
```

相关数据通常来自：

```text
SysPermission
SysRole
SysRolePermission
SysUserRole
```

登录时计算出权限码列表，写入：

```java
CommonConstants.PERMISSION_IN_SA_TOKEN
```

接口上使用：

```java
@SaBizCheckPermission("xxx")
@SaPlatformCheckPermission("xxx")
```

### 14.2 角色权限

角色用于判断：

```text
这个人是不是某类角色。
```

登录时写入：

```java
CommonConstants.ROLE_IN_SA_TOKEN
```

接口或业务可使用：

```java
@SaBizCheckRole("xxx")
@SaPlatformCheckRole("xxx")
```

或者：

```java
StpBizUtil.checkRole("xxx");
StpPlatformUtil.checkRole("xxx");
```

### 14.3 数据权限

数据权限解决的不是“能不能访问接口”，而是：

```text
访问接口后，能看哪些数据。
```

项目中常见数据范围：

| 数据范围 | 含义 |
|---|---|
| `ALL` | 全部数据 |
| `SELF_DEPT` | 本部门 / 本门店 |
| `SELF_DEPT_AND_UNDER_DEPT` | 本部门及下级 |
| `CUSTOM` | 自定义范围 |

登录时写入：

```java
CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN
```

如果是自定义或下级范围，还会写：

```java
CommonConstants.DEPT_ID_LIST
```

后续业务查询数据时，可以根据 Session 中的数据范围拼接查询条件。

---

## 15. POS 端权限模型

POS 端有两个层次的权限。

### 15.1 第一层：复用商户端 Sa-Token 登录体系

POS 使用：

```java
StpBizUtil
```

也就是和商户端一样属于：

```text
loginType = biz
```

这说明 POS 操作员在认证层面被当作商户体系用户。

POS Controller 中大量使用：

```java
@SaBizCheckLogin
@SaBizCheckPermission
@SaBizCheckRole
```

这些注解都会走 `biz` 体系。

### 15.2 第二层：POS 本地细粒度权限

POS 不只需要普通接口权限，还需要大量收银业务细粒度权限。

例如：

- 是否允许赠菜。
- 是否允许退菜。
- 是否允许改价。
- 是否允许查看某类报表。
- 是否允许跨营业日查询。
- 是否允许操作某些菜品、套餐、赠品。
- 是否允许某些金额上限操作。

这些权限不一定适合全部做成普通接口权限。

所以 POS 有：

```text
PermissionUtil
```

登录刷新 Session 时：

```java
PermissionUtil.put(user.getLid(), permissions.getKey(), timeout);
```

`PermissionUtil` 会把更细的权限 map 放到 SaSession 中。

概念上类似：

```text
SaSession(biz user)
  USER_IN_SA_TOKEN = BizAdminVO
  PERMISSION_IN_SA_TOKEN = 普通权限码列表
  ROLE_IN_SA_TOKEN = 角色列表
  DATA_SCOPE_OF_ROLE_IN_SA_TOKEN = SELF_DEPT
  pos_permission_xxx = POS细粒度权限缓存
```

### 15.3 POS 为什么固定 SELF_DEPT

POS 是门店本地系统，本机通常只服务当前门店。

所以 POS 登录时写：

```java
session.set(CommonConstants.DATA_SCOPE_OF_ROLE_IN_SA_TOKEN, DataScopeEnum.SELF_DEPT);
```

这和云端后台不同。

云端后台可能有：

```text
总部看全部门店
区域经理看下级门店
店长看本门店
自定义角色看指定门店
```

POS 本地则更简单：

```text
当前 POS 只能操作本门店数据。
```

---

## 16. POS 与云端权限关系

### 16.1 云端是权限主设计中心

云端有完整的权限管理模型：

```text
用户
角色
权限
角色权限
用户角色
数据权限
部门 / 门店范围
```

云端决定：

- 用户有哪些角色。
- 角色有哪些权限。
- 角色能访问哪些门店或部门。
- 哪些权限需要同步到 POS。

### 16.2 POS 是本地执行端

POS 负责：

- 本地登录。
- 本地 Session 缓存。
- 本门店数据权限约束。
- 收银业务细粒度权限判断。
- 离线或弱网场景下继续执行本地权限判断。

### 16.3 两者关系

可以这样理解：

```text
云端：
  设计和维护权限规则。

POS：
  在本地执行这些权限规则，并针对收银场景扩展更细权限。
```

更完整的链路：

```text
云端配置角色权限
  -> 权限数据同步到 POS 本地库
  -> POS 用户登录
  -> POS 从本地库计算该用户角色和权限
  -> 写入 StpBizUtil 的 SaSession
  -> POS 接口使用 @SaBizCheckPermission 校验普通权限
  -> POS 业务使用 PermissionUtil 校验细粒度操作权限
```

---

## 17. 为什么权限不是每次查数据库

项目选择 Session 缓存权限，原因很实际。

### 17.1 后台接口性能

如果每次请求都查角色权限表：

```text
接口请求
  -> 查用户角色
  -> 查角色权限
  -> 查数据范围
  -> 再执行业务
```

会导致每个接口都额外访问权限表。

### 17.2 POS 场景要求更高

POS 是收银终端，操作频率高，并且可能处于弱网或离线环境。

如果每次退菜、加菜、结账、赠菜都依赖实时查库或远程查权限，会影响收银体验。

所以 POS 更适合：

```text
登录时加载权限
  -> 本地 Session 缓存
  -> 操作时快速判断
```

### 17.3 权限变更如何生效

权限缓存的代价是：

```text
权限变更后，已登录用户的 Session 里还是旧权限。
```

项目里 POS 提供了：

```java
PermissionUtil.reload()
```

它会扫描已登录 token，找到对应 Session，然后重新执行：

```java
authService.refreshSession(user, session, sessionTimeout);
```

也就是重新计算并写入权限。

---

## 18. 一次完整请求如何被识别和鉴权

以 POS 端接口为例。

### 18.1 登录阶段

```text
POS 用户输入账号密码
  -> POS 后端查询用户
  -> 生成 BizAdminVO
  -> 查询角色
  -> 查询权限
  -> StpBizUtil.login(user.lid, timeout=-1)
  -> Sa-Token 生成 token
  -> Sa-Token 写 token 与 loginId 映射
  -> 项目写 USER_IN_SA_TOKEN
  -> 项目写 PERMISSION_IN_SA_TOKEN
  -> 项目写 ROLE_IN_SA_TOKEN
  -> 项目写 DATA_SCOPE_OF_ROLE_IN_SA_TOKEN=SELF_DEPT
  -> 项目写 POS 细粒度权限缓存
  -> 返回 token 给 POS 前端
```

### 18.2 请求阶段

```text
POS 前端请求接口
  -> 请求头携带 biz token
  -> 接口上标注 @SaBizCheckPermission
  -> Sa-Token 按 type=biz 找 StpBizUtil 对应 StpLogic
  -> 读取 token
  -> 查出 loginId
  -> 调 StpInterfaceImpl.getPermissionList(loginId, "biz")
  -> 从 StpBizUtil.getSession() 读取 PERMISSION_IN_SA_TOKEN
  -> 判断权限
  -> 通过后进入业务代码
  -> 业务代码可通过 BaseService.getAdmin() 获取 BizAdminVO
  -> 如需更细权限，再调 PermissionUtil
```

### 18.3 数据查询阶段

业务查询数据时，可以读取：

```text
DATA_SCOPE_OF_ROLE_IN_SA_TOKEN
DEPT_ID_LIST
```

POS 场景通常是：

```text
SELF_DEPT
```

所以只查本门店数据。

---

## 19. BaseService 在登录态中的作用

项目里很多业务不会直接写：

```java
StpBizUtil.getSession().get(...)
```

而是通过 `BaseService` 获取当前用户。

例如：

```java
BaseService.getAdmin()
BaseService.getPlatformAdmin()
BaseService.getUser()
```

这些方法内部会判断对应体系是否登录，然后从对应 Session 取：

```java
CommonConstants.USER_IN_SA_TOKEN
```

对应关系：

| 方法 | 使用体系 | 返回对象 |
|---|---|---|
| `getPlatformAdmin()` | `StpPlatformUtil` | `PlatformAdminVO` |
| `getAdmin()` / `getForceAdmin()` | `StpBizUtil` | `BizAdminVO` |
| `getInstAdmin()` | `StpInstUtil` | `InstAdminVO` |
| `getUser()` | `StpUtil` | `CUserVO` |
| `getSpAdmin()` | `StpSplUtil` | `BizAdminVO` |

这相当于给业务层提供了统一入口：

```text
业务代码不用关心 Session key。
业务代码只调用对应 getXXX 方法拿当前登录对象。
```

---

## 20. 注解体系为什么要自己封装

项目完全可以直接写：

```java
@SaCheckPermission(type = "biz", value = "xxx")
```

但这样会有几个问题：

- 每个接口都要手写 `type`。
- 容易把 `biz` 写错成 `platform`。
- 平台端和商户端代码可读性差。
- 后续如果 loginType 改名，改动面大。

所以项目封装成：

```java
@SaBizCheckPermission
@SaPlatformCheckPermission
@SaInstCheckPermission
@SaSpCheckPermission
```

好处：

```text
看到注解就知道接口属于哪个端。
type 由注解固定，不容易写错。
权限值仍然可以通过 value 传入。
```

例如：

```java
@SaBizCheckPermission("dish:add")
```

比下面这种更清晰：

```java
@SaCheckPermission(type = "biz", value = "dish:add")
```

---

## 21. 多账号体系下的常见误区

### 21.1 误区一：以为多个工具类只是名字不同

不是。

`StpBizUtil` 和 `StpPlatformUtil` 底层是不同 `StpLogic`。

它们的 loginType 不同，Session 命名空间不同，权限读取上下文也不同。

### 21.2 误区二：以为权限校验时会实时查数据库

不是。

项目的 `StpInterfaceImpl` 是从 SaSession 中取权限和角色。

数据库查询主要发生在登录和刷新 Session 阶段。

### 21.3 误区三：以为 POS 有独立 Sa-Token 账号类型

从目前代码看，POS 没有单独的 `pos` loginType。

POS 使用的是：

```text
biz
```

也就是商户体系。

POS 的特殊性体现在：

- 登录 timeout 特殊。
- 数据范围固定本门店。
- 额外有 `PermissionUtil` 细粒度权限缓存。

### 21.4 误区四：以为 C 端会员和商户用户可以共用注解

不能混用。

C 端会员接口一般用：

```java
@SaCheckLogin
```

商户端接口应使用：

```java
@SaBizCheckLogin
```

如果商户接口误用 `@SaCheckLogin`，就可能按默认 C 端体系检查登录态。

如果 C 端接口误用 `@SaBizCheckLogin`，则会要求商户端登录态。

---

## 22. 设计总结

项目的 Sa-Token 设计可以概括为：

```text
一套 Sa-Token 框架
多套 StpLogic 账号体系
多组自定义注解绑定不同 loginType
登录时写入用户、角色、权限、数据范围到 SaSession
StpInterfaceImpl 从对应 SaSession 读取权限进行校验
云端负责主权限模型
POS 端复用 biz 体系并扩展本地细粒度权限
```

更直观地看：

```text
平台端
  -> StpPlatformUtil
  -> platform Session
  -> PlatformAdminVO
  -> 平台角色 / 平台权限 / 平台数据范围

商户云端
  -> StpBizUtil
  -> biz Session
  -> BizAdminVO
  -> 商户角色 / 商户权限 / 门店数据范围

POS端
  -> StpBizUtil
  -> biz Session
  -> BizAdminVO
  -> 商户/POS权限
  -> SELF_DEPT
  -> PermissionUtil 细粒度权限缓存

C端会员
  -> StpUtil
  -> login Session
  -> CUserVO
  -> 会员登录态
```

一句话：

```text
nms4cloud / nms4pos 不是简单使用 Sa-Token 做登录，而是基于 Sa-Token 的 StpLogic 扩展能力，把平台、商户、POS、机构、C端会员拆成互相隔离的多账号体系，再通过 Session 缓存角色权限和数据范围完成高频鉴权。
```
