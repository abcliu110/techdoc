# Sa-Token认证鉴权与Session原理说明

## 1. 背景

在后端系统里，登录认证和权限控制通常要解决几个基础问题：

- 用户登录后，服务端如何知道“这个请求是谁发起的”。
- 用户登录后，系统如何判断“这个用户能不能访问某个接口”。
- 用户登录期间，服务端如何保存一些临时状态数据。
- 分布式部署时，多台服务之间如何共享登录状态。
- 前后端分离、App、小程序等多端场景下，如何统一携带认证凭证。

传统方案通常使用 `HttpSession`，或者项目自研 `Token + Redis + 拦截器`。Sa-Token 解决的不是某一个单点能力，而是把登录态、权限态、会话态、踢人、封禁、二级认证、多端登录等通用认证鉴权能力封装成统一 API。

---

## 2. 登录态、权限态、会话态

### 2.1 登录态

登录态表示系统知道“当前请求对应的是哪个已登录用户”。

例如用户登录成功后，后续请求带上 `token` 或 `JSESSIONID`，服务端可以识别出：

```text
当前请求 -> 用户ID 1001
```

这就是登录态。

在 Sa-Token 中，登录态常用 API 是：

```java
StpUtil.login(userId);
StpUtil.checkLogin();
Object loginId = StpUtil.getLoginId();
StpUtil.logout();
```

### 2.2 权限态

权限态表示系统知道“当前用户能做什么”。

常见权限信息包括：

- 用户角色：如 `admin`、`user`、`manager`
- 用户权限：如 `user:add`、`user:delete`、`order:query`

例如：

```text
用户1001 -> 角色：admin
用户1001 -> 权限：user:add、user:delete
```

在 Sa-Token 中常用 API 是：

```java
StpUtil.checkRole("admin");
StpUtil.checkPermission("user:add");
```

### 2.3 会话态

会话态表示用户登录期间，服务端保存的一组临时数据。

例如：

- 当前用户昵称
- 当前门店ID
- 当前租户ID
- 登录设备信息
- 验证码状态
- 二级认证状态

传统 `HttpSession` 中可以这样保存：

```java
session.setAttribute("userId", user.getId());
session.setAttribute("nickname", user.getNickname());
```

Sa-Token 中可以这样保存：

```java
StpUtil.getSession().set("nickname", "张三");
Object nickname = StpUtil.getSession().get("nickname");
```

一句话区分：

```text
登录态 = 你是谁
权限态 = 你能做什么
会话态 = 你这次登录期间保存了什么
```

---

## 3. HttpSession 是什么

`HttpSession` 是 Java Servlet 规范提供的服务端会话机制。

它不是浏览器标准，也不是 HTTP 协议本身的登录机制。浏览器天然支持的是 `Cookie`，而 `HttpSession` 是服务端基于 Cookie 实现的一层会话抽象。

典型流程如下：

```text
1. 浏览器第一次访问服务端
2. 服务端创建 HttpSession
3. 服务端生成一个 session id，例如 abc123
4. 服务端通过响应头返回：Set-Cookie: JSESSIONID=abc123
5. 浏览器保存这个 Cookie
6. 浏览器后续请求自动携带：Cookie: JSESSIONID=abc123
7. 服务端根据 abc123 找到对应的 HttpSession
```

所以真正区分不同浏览器、不同用户会话的关键是 `JSESSIONID`。

例如：

```text
浏览器A -> JSESSIONID=aaa -> SessionA -> userId=1001
浏览器B -> JSESSIONID=bbb -> SessionB -> userId=2002
```

服务端内部可以理解成维护了一张映射表：

```text
aaa -> SessionA
bbb -> SessionB
```

当代码执行：

```java
Long userId = (Long) session.getAttribute("userId");
```

它的前提是：

```text
请求已经带上 JSESSIONID
Servlet 容器已经根据 JSESSIONID 找到正确的 HttpSession
Spring MVC 已经把当前请求对应的 HttpSession 注入给 Controller
```

也就是说，这段代码不是从所有 session 中查找，而是从“当前请求对应的 session”中取值。

### 3.1 客户端是否只保存 session id

在传统 `HttpSession` 模式下，客户端通常只保存一个 session id，也就是 Cookie 中的 `JSESSIONID`。

真正的 session 数据保存在服务端，不保存在客户端。

例如服务端 session 中可能保存：

```text
Session abc123:
  userId = 1001
  nickname = 张三
  tenantId = 88
  role = admin
```

客户端浏览器通常只保存：

```http
Cookie: JSESSIONID=abc123
```

后续请求时，浏览器把 `JSESSIONID=abc123` 自动带回服务端。服务端再根据 `abc123` 找到对应的 session 数据。

可以这样理解：

```text
客户端：只保存钥匙编号 JSESSIONID
服务端：保存真正的会话数据
```

所以 `HttpSession` 模式下，用户信息、权限信息、临时状态等数据本质上都在服务端，客户端只保存一个用于查找这些数据的编号。

需要注意几个补充点：

1. 客户端可能还保存其他 Cookie

例如语言、主题、埋点 ID 等，但这些不是 `HttpSession` 的核心数据。

2. session id 不一定只能放在 Cookie 中

Servlet 规范也支持 URL 重写方式，例如：

```text
/user/profile;jsessionid=abc123
```

但现代 Web 应用主流方式仍然是 Cookie。

3. JWT 不是这种模式

JWT 会把一部分用户信息或声明直接编码进 token 中。它不是传统 `HttpSession` 这种“客户端只保存 id，服务端保存数据”的模型。

---

## 4. HttpSession 为什么更偏浏览器 + 服务端模板模式

`HttpSession` 并不是只能用于服务端模板项目，但它的默认使用体验更适合这种模式。

传统服务端模板流程如下：

```text
浏览器 -> GET /login
服务端返回 login.html

浏览器 -> POST /login
服务端校验账号密码
服务端创建 HttpSession
服务端返回 Set-Cookie: JSESSIONID=xxx

浏览器 -> GET /user/profile
浏览器自动带 Cookie: JSESSIONID=xxx
服务端找到 session
服务端渲染 profile.html
```

在 JSP、Thymeleaf、Freemarker 这类服务端模板中，页面由服务端直接渲染。服务端天然可以从 `HttpSession` 中取当前用户信息，然后把数据渲染到 HTML 中。

例如：

```java
session.setAttribute("user", user);
```

模板页面可以直接使用 session 中的数据。

这种模式的特点是：

- 页面由服务端生成。
- 登录状态保存在服务端。
- 浏览器只负责自动带 Cookie。
- 前端不用显式管理 token。
- 服务端每次渲染页面时都能拿到当前用户。

所以说 `HttpSession` 更偏“浏览器 + 服务端模板”模式，是因为它天然依赖浏览器自动 Cookie 机制，并且服务端保存用户状态。

---

## 5. HttpSession 在前后端分离中的问题

前后端分离时，前端通常是独立应用，例如：

- Vue / React 单页应用
- App
- 小程序
- 第三方调用方

后端通常只提供 JSON API。

请求形态变成：

```text
前端应用 -> POST /api/login
后端返回 JSON

前端应用 -> GET /api/user/profile
后端返回 JSON
```

这时如果继续使用 `HttpSession`，仍然可以实现，但会有几个常见问题。

### 5.1 跨域 Cookie 配置复杂

例如：

```text
前端：http://localhost:5173
后端：http://localhost:8080
```

这是跨域请求。浏览器默认不会随便携带跨域 Cookie。

通常需要配置：

- 后端 CORS 允许 credentials。
- 前端请求开启 `withCredentials`。
- Cookie 的 `SameSite` 设置正确。
- Cookie 的 `Secure` 设置和 HTTPS 匹配。
- Cookie 的 domain、path 设置正确。

这些配置不正确，就会出现“登录成功了，但是下一个请求还是未登录”。

### 5.2 多端客户端不一定适合 Cookie

浏览器天然支持 Cookie 自动保存和自动携带。

但 App、小程序、第三方客户端更常见的方式是：

```text
登录后拿到 token
客户端自己保存 token
每次请求放到 Header 中
```

例如：

```http
Authorization: Bearer xxxxxx
```

或者：

```http
satoken: xxxxxx
```

这种方式对非浏览器客户端更直观。

### 5.3 分布式部署需要共享 Session

`HttpSession` 默认通常存放在当前服务实例内存中。

如果系统部署了多台服务：

```text
用户第一次请求 -> 服务器A -> 创建 SessionA
用户第二次请求 -> 服务器B -> 找不到 SessionA
```

这会导致用户明明登录了，却在下一次请求中变成未登录。

解决办法通常有两类：

1. 共享 Session

把 session 数据放到 Redis 等共享存储中，多台服务都能访问。

2. 粘性会话

让负载均衡器保证同一个用户始终打到同一台服务。

这两种方案都增加了部署和运维复杂度。

---

## 6. 传统 HttpSession 登录方案

传统登录流程如下：

```text
登录成功
-> 服务端创建 HttpSession
-> 把 userId 放进 session
-> 浏览器保存 JSESSIONID
-> 后续请求自动带 Cookie
-> 服务端根据 JSESSIONID 找 session
-> 从 session 里取 userId
```

代码示例：

```java
session.setAttribute("userId", user.getId());

Long userId = (Long) session.getAttribute("userId");
if (userId == null) {
    throw new RuntimeException("未登录");
}
```

这段代码能工作的前提是服务端已经完成了下面这些动作：

```text
请求进来
-> 从 Cookie 中解析 JSESSIONID
-> 根据 JSESSIONID 查找 HttpSession
-> 把查到的 HttpSession 绑定到当前 request
-> Controller 中拿到当前请求对应的 session
```

如果请求没有带 `JSESSIONID`，或者带了一个已经过期的 `JSESSIONID`，服务端就找不到原来的 session。

另外需要注意：

```java
request.getSession()
```

默认可能创建一个新的空 session。

如果只想获取已有 session，不想创建新 session，可以使用：

```java
request.getSession(false)
```

---

## 7. 传统自研 Token 方案

为了适配前后端分离，很多项目会自己实现 Token 方案。

典型流程：

```text
登录成功
-> 生成 token
-> token 存 Redis
-> token 返回给前端
-> 前端保存 token
-> 后续请求带 token
-> 后端拦截器解析 token
-> 后端去 Redis 查询 token 对应的 userId
-> 判断 token 是否过期
```

这种方案比 `HttpSession` 更适合 API 化和多端调用，但自研成本较高。

通常需要自己处理：

- token 生成规则
- token 存储
- token 过期时间
- token 自动续期
- token 和 userId 的映射
- userId 和 token 的反向映射
- 多端登录策略
- 踢人下线
- 账号封禁
- 角色权限判断
- 异常返回格式
- 注解鉴权
- Redis 存储结构

最终很容易变成“自己写一个小型认证框架”。

---

## 8. Sa-Token 如何解决这些问题

Sa-Token 的核心价值是把登录认证、权限鉴权、会话管理、Token 管理封装成统一 API。

登录时只需要：

```java
StpUtil.login(userId);
```

Sa-Token 内部会负责：

```text
生成 token
保存 token -> loginId 映射
保存 loginId -> token 映射
维护 token 过期时间
维护登录态
支持从请求中读取 token
```

后续判断登录：

```java
StpUtil.checkLogin();
```

获取当前用户：

```java
Object loginId = StpUtil.getLoginId();
```

退出登录：

```java
StpUtil.logout();
```

权限判断：

```java
StpUtil.checkRole("admin");
StpUtil.checkPermission("user:add");
```

踢人下线：

```java
StpUtil.kickout(userId);
```

封禁账号：

```java
StpUtil.disable(userId, 3600);
```

二级认证：

```java
StpUtil.openSafe(300);
StpUtil.checkSafe();
```

它解决的是认证鉴权的工程复杂度问题。

### 8.1 Redis 中三个 Sa-Token Key 如何对应

先记住一句话：

```text
请求只带 token，不会直接带 loginId。
Sa-Token 要先用 token 找到 loginId，再用 loginId 找到账号 Session。
```

以一次登录为例：

```text
登录账号 loginId = 1001
登录令牌 token   = e24c96f6-ab93-46f3-964a-84f461c394a6
```

Redis 里会出现三类 key：

| Key | 谁作为后缀 | 主要作用 |
|---|---|---|
| `satoken:login:token:e24c96f6-ab93-46f3-964a-84f461c394a6` | token | 通过 token 查到 `loginId = 1001` |
| `satoken:login:session:1001` | loginId | 保存账号 `1001` 的账号 Session |
| `satoken:login:token-session:e24c96f6-ab93-46f3-964a-84f461c394a6` | token | 保存这个 token 自己的 Token Session |

它们的查找链路如下：

```text
浏览器 / App 请求
  携带 token = e24c96f6-ab93-46f3-964a-84f461c394a6
        |
        v
1. 查 token 映射 key
   satoken:login:token:e24c96f6-ab93-46f3-964a-84f461c394a6
        |
        | 这个 key 的值能让 Sa-Token 知道：
        | 当前 token 属于 loginId = 1001
        v
2. 查账号 Session key
   satoken:login:session:1001
        |
        | 这里保存账号级数据：
        | loginId、角色、权限、loginName、自定义 dataMap 等
        v
3. 如有需要，再查 Token Session key
   satoken:login:token-session:e24c96f6-ab93-46f3-964a-84f461c394a6
        |
        | 这里保存当前这个 token 自己的数据
```

所以三者不是平级替代关系，而是职责不同：

| 数据 | 解决的问题 | 类比 |
|---|---|---|
| `token:{token}` | 这个 token 是谁的？ | 门票编号 -> 用户编号 |
| `session:{loginId}` | 这个账号有哪些登录态、权限态、会话态数据？ | 用户档案 |
| `token-session:{token}` | 这张 token 自己有什么临时数据？ | 某一张门票自己的附加记录 |

结合截图中的三个 key，可以这样读：

```text
satoken:login:token:e24c96f6-ab93-46f3-964a-84f461c394a6
表示：
这个 token 对应账号 1001。

satoken:login:session:1001
表示：
账号 1001 的账号 Session。
截图里看到的 roles、permissions、loginName、demoKey 等账号级数据就在这里。

satoken:login:token-session:e24c96f6-ab93-46f3-964a-84f461c394a6
表示：
token e24c96f6-ab93-46f3-964a-84f461c394a6 自己的 Token Session。
它不是账号 Session，而是当前这一个 token 的专属 Session。
```

`session` 和 `token-session` 的区别是最容易混淆的地方：

| 对比项 | `session:{loginId}` | `token-session:{token}` |
|---|---|---|
| 维度 | 账号维度 | token 维度 |
| 一个账号对应几个 | 通常一个账号一个 | 一个 token 一个 |
| key 后缀 | loginId，例如 `1001` | token，例如 `e24c96f6...` |
| 适合保存 | 账号级数据，如角色、权限、用户名、租户、门店 | 当前 token 级数据，如当前设备、当前端、某次登录令牌的临时状态 |

如果账号 `1001` 同时在电脑和手机登录，可能是这样：

```text
账号 Session：
satoken:login:session:1001

电脑端 token：
satoken:login:token:tokenA           -> loginId = 1001
satoken:login:token-session:tokenA   -> 电脑端这个 token 的数据

手机端 token：
satoken:login:token:tokenB           -> loginId = 1001
satoken:login:token-session:tokenB   -> 手机端这个 token 的数据
```

也就是：

```text
多个 token 可以指向同一个 loginId。
同一个 loginId 对应一个账号 Session。
每个 token 又各自拥有一个 Token Session。
```

### 8.2 token-session 可以存什么，如何存

`token-session` 适合保存“只属于当前这个 token”的数据。

换句话说：同一个账号如果在电脑、手机、小程序同时登录，这几个登录端可能共用同一个 `loginId`，但它们的 token 不同，所以它们的 `token-session` 也不同。

适合放进 `token-session` 的数据通常有：

| 数据 | 说明 |
|---|---|
| 登录设备类型 | 如 `PC`、`APP`、`MINI_PROGRAM` |
| 登录设备 ID | 如设备指纹、客户端生成的 deviceId |
| 登录端标识 | 如 `web-admin`、`mobile-app` |
| 登录 IP | 当前 token 创建时的 IP |
| User-Agent | 当前 token 创建时的浏览器或客户端信息 |
| 本次登录的临时状态 | 只对当前 token 生效的状态 |
| 当前 token 的二级认证扩展信息 | 如果业务需要按 token 记录额外安全状态 |

不建议放进 `token-session` 的数据：

| 数据 | 原因 |
|---|---|
| 用户姓名、角色、权限 | 这些通常属于账号级数据，更适合放账号 Session 或从数据库 / 权限服务查询 |
| 租户、门店等账号当前上下文 | 如果希望同账号多端共享，应该放账号 Session；如果希望每个端独立，才放 token-session |
| 大对象、大列表 | 会增加 Redis 体积和序列化成本 |
| 持久业务数据 | Redis Session 是会过期的，不适合当业务主表使用 |

保存 `token-session` 可以使用：

```java
StpUtil.getTokenSession().set("deviceType", "PC");
StpUtil.getTokenSession().set("deviceId", "device-001");
StpUtil.getTokenSession().set("client", "web-admin");
StpUtil.getTokenSession().set("loginIp", "127.0.0.1");
```

读取时：

```java
String deviceType = StpUtil.getTokenSession().getString("deviceType");
String deviceId = StpUtil.getTokenSession().getString("deviceId");
String client = StpUtil.getTokenSession().getString("client");
String loginIp = StpUtil.getTokenSession().getString("loginIp");
```

如果是在登录成功后立即保存当前 token 的设备信息，可以这样写：

```java
StpUtil.login(userId);

StpUtil.getTokenSession().set("deviceType", "PC");
StpUtil.getTokenSession().set("deviceId", "device-001");
StpUtil.getTokenSession().set("client", "web-admin");
```

这里的关键点是：`StpUtil.login(userId)` 执行后，当前请求上下文中已经有了本次登录生成的 token，`StpUtil.getTokenSession()` 拿到的就是这个 token 对应的 Token Session。

如果要对比账号 Session 和 Token Session，可以这样理解：

```java
// 账号 Session：按 loginId 存，账号维度
StpUtil.getSession().set("loginName", "admin");

// Token Session：按 token 存，token 维度
StpUtil.getTokenSession().set("deviceType", "PC");
```

对应到 Redis：

```text
StpUtil.getSession()
  -> satoken:login:session:1001

StpUtil.getTokenSession()
  -> satoken:login:token-session:e24c96f6-ab93-46f3-964a-84f461c394a6
```

一个常见误区是：以为 `token-session` 是用来保存 token 字符串本身的。

实际上：

```text
satoken:login:token:{token}
  负责保存 token 到 loginId 的映射。

satoken:login:token-session:{token}
  负责保存这个 token 自己附带的会话数据。
```

---

## 9. StpUtil 静态方法与请求上下文

`StpUtil` 是静态工具类，所以业务代码里可以直接这样写：

```java
Long userId = StpUtil.getLoginIdAsLong();
StpUtil.checkLogin();
StpUtil.checkPermission("order:list");
```

这并不代表 Sa-Token 把当前用户身份保存在静态变量里。

真正决定当前用户是谁的是当前 HTTP 请求携带的 token。

一次请求中的逻辑可以理解为：

```text
HTTP 请求进入 Spring Boot
  -> Web 容器分配一个线程处理请求
  -> Sa-Token 从当前请求中读取 token
  -> 使用 token 到 SaTokenDao 中查询 loginId
  -> 当前请求上下文中就能确定当前用户
  -> StpUtil.getLoginId() 返回这个请求对应的 loginId
```

所以更准确的说法是：

```text
StpUtil 的调用结果在一次 HTTP 请求上下文中是确定的。
```

不是：

```text
某个线程永久绑定某个用户。
```

Web 容器通常使用线程池处理请求：

```text
线程 A 本次处理 userId=10001 的请求
请求结束后线程 A 回到线程池
线程 A 下次可能处理 userId=20002 的请求
```

因此不能把登录用户身份理解成“永久绑定在线程上”。

Sa-Token 能在静态方法中获取当前用户，是因为它可以通过当前请求上下文拿到本次请求的 token，再根据 token 查询登录态。

### 9.1 异步线程中的注意点

如果在请求线程里直接调用：

```java
Long userId = StpUtil.getLoginIdAsLong();
```

通常可以正常获取当前登录用户。

但如果自己新开线程：

```java
new Thread(() -> {
    Long userId = StpUtil.getLoginIdAsLong();
}).start();
```

这个新线程通常拿不到原 HTTP 请求上下文。

原因是：

```text
新线程不是 Spring MVC 当前处理请求的线程
它没有绑定原请求的 Request 上下文
Sa-Token 也就无法从当前线程中定位到原请求 token
```

更稳妥的写法是在原请求线程中先取出必要信息，再传给异步任务：

```java
Long userId = StpUtil.getLoginIdAsLong();

new Thread(() -> {
    // 使用提前传入的 userId
    System.out.println(userId);
}).start();
```

如果项目使用线程池、异步任务、消息队列，建议不要在异步执行体里直接依赖 `StpUtil.getLoginId()`。

更推荐显式传递业务身份：

```text
Controller / Service 中获取 loginId
  -> 把 userId 作为参数传给异步任务
  -> 异步任务只处理明确传入的 userId
```

### 9.2 和 Nginx 转发的关系

Nginx 不负责理解 Sa-Token 的登录态。

它只是 HTTP 反向代理，请求经过 Nginx 转发到 Spring Boot 时，需要保证 token 所在的位置没有被丢掉。

如果前端把 token 放在请求头：

```http
satoken: xxxxx
```

那么 Nginx 需要把请求头正常转发给后端。

如果使用自定义 Header，通常要注意：

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

普通请求头一般会被 Nginx 转发，但如果做了特殊过滤、网关改写、跨域预检限制，就可能导致后端读取不到 token。

排查时可以按这个链路看：

```text
浏览器是否发出了 satoken
  -> Nginx 是否收到 satoken
  -> Nginx 是否转发 satoken
  -> Spring Boot 是否收到 satoken
  -> Sa-Token 是否按 token-name 读取 satoken
```

---

## 10. 二级认证是什么

二级认证是在用户已经登录的基础上，再做一次更高安全级别的身份确认。

常见场景：

- 修改密码前再次输入密码。
- 转账前输入短信验证码。
- 删除账号前再次确认身份。
- 查看敏感信息前做人脸或 OTP 验证。

普通登录只能证明“这个请求来自一个已登录用户”。

但如果用户电脑被别人临时拿到，或者 token 泄露，攻击者可能直接执行高危操作。

二级认证的作用是：

```text
已登录用户 != 可以直接执行高危操作
高危操作前必须再次确认身份
```

Sa-Token 中可以这样使用：

```java
// 二级认证通过，有效期 300 秒
StpUtil.openSafe(300);

// 高危接口执行前检查是否完成二级认证
StpUtil.checkSafe();
```

---


## 11. Access Token 与 Refresh Token 的存储和撤销实现

`access token + refresh token` 是前后端分离中常见的登录续期方案。

可以简单理解为：

```text
access token：短期通行证，用来访问业务接口
refresh token：长期续签凭证，用来换新的 access token
```

它解决的是一个矛盾：

```text
access token 有效期太长 -> 泄露后风险大
access token 有效期太短 -> 用户频繁重新登录
```

所以通常设计成：

```text
access token：5 分钟、15 分钟、30 分钟有效
refresh token：7 天、30 天、90 天有效
```

### 11.1 两种 token 分别存在哪里

两种 token 的存储策略不同。

```text
access token：短期、经常使用，前端要方便拿出来放到请求头
refresh token：长期、敏感，尽量不要被 JavaScript 直接读到
```

Web 端常见推荐组合：

```text
access token：存 JS 内存
refresh token：存 HttpOnly + Secure + SameSite Cookie
```

登录成功时：

```text
服务端返回 access token 给前端
服务端通过 Set-Cookie 写入 refresh token
```

例如：

```http
Set-Cookie: refresh_token=xxx; HttpOnly; Secure; SameSite=Lax; Path=/auth/refresh
```

这些属性的含义：

- `HttpOnly`：JavaScript 读不到，降低 XSS 窃取风险。
- `Secure`：只在 HTTPS 下发送。
- `SameSite`：降低 CSRF 风险。
- `Path=/auth/refresh`：只在刷新接口携带，不让所有接口都带 refresh token。

业务接口请求时：

```http
Authorization: Bearer access_token_xxx
```

刷新接口请求时，浏览器自动带上 refresh token Cookie。

```text
POST /auth/refresh
Cookie: refresh_token=xxx
```

不推荐把长期 refresh token 放在：

- `localStorage`
- 普通 Cookie
- URL 参数
- 前端全局变量

原因是 refresh token 有效期长，一旦泄露，攻击者可以持续换取新的 access token。

### 11.2 服务端是否要保存 refresh token

建议服务端保存 refresh token 的状态记录，但不要保存明文 token。

可以保存 token 的 hash：

```text
客户端：保存原始 refresh token
服务端：保存 refresh token 的 hash
```

类似密码存储思路，服务端不直接保存原文。

可以设计一张表或 Redis 结构：

```text
refresh_token
------------------------------------------------
id
user_id
device_id
token_hash
family_id
expires_at
revoked
revoked_reason
revoked_at
replaced_by
created_at
last_used_at
```

字段含义：

- `user_id`：属于哪个用户。
- `device_id`：属于哪个设备或客户端。
- `token_hash`：refresh token 的哈希值。
- `family_id`：同一次登录后不断轮换出来的一组 refresh token。
- `expires_at`：过期时间。
- `revoked`：是否已撤销。
- `revoked_reason`：撤销原因，例如 logout、kicked、password_changed、reuse_detected。
- `replaced_by`：当前 token 被哪个新 token 替换。
- `last_used_at`：最后使用时间。

### 11.3 登录时如何保存

用户登录成功后，服务端执行：

```text
1. 生成 access token
2. 生成 refresh token
3. 对 refresh token 做 hash
4. 保存 token_hash、user_id、device_id、expires_at、family_id
5. 把原始 refresh token 返回给客户端
```

服务端保存示例：

```text
token_hash = sha256(refresh_token)
user_id = 1001
device_id = web-chrome-001
family_id = login-chain-001
expires_at = 2026-06-01 00:00:00
revoked = false
```

客户端保存的是原始 refresh token，服务端保存的是 hash。

### 11.4 主动撤销如何实现

主动撤销通常发生在用户退出登录时。

流程：

```text
1. 客户端请求 /auth/logout
2. 服务端取到当前 refresh token
3. 计算 hash
4. 查询 refresh_token 记录
5. 设置 revoked = true
6. 设置 revoked_reason = logout
7. 设置 revoked_at = 当前时间
```

之后这个 refresh token 再来刷新时，服务端查到 `revoked = true`，直接拒绝刷新，要求重新登录。

伪代码：

```java
record.setRevoked(true);
record.setRevokedReason("logout");
record.setRevokedAt(LocalDateTime.now());
refreshTokenRepository.save(record);
```

### 11.5 踢某个设备下线如何实现

每个 refresh token 都绑定一个 `device_id`。

例如：

```text
用户1001：
- device_id = web-chrome-001
- device_id = iphone-001
- device_id = wechat-mini-001
```

用户在设备管理页面点击“踢掉 iPhone”时，服务端执行：

```text
更新 user_id = 1001 且 device_id = iphone-001 的 refresh token：
revoked = true
revoked_reason = kicked
revoked_at = 当前时间
```

这样 iPhone 上的 refresh token 就不能再换新的 access token。

需要注意：

```text
旧 access token 如果还没过期，可能还能继续访问几分钟
```

如果业务可以接受几分钟延迟，只要把 access token 设置得很短即可。

如果要求立刻下线，还需要额外处理 access token：

- 把 access token 加入黑名单。
- 或者使用 token version，让服务端每次校验 access token 时比对版本。
- 或者使用服务端存储型 token，每次请求都查一次 token 状态。

### 11.6 用户改密码后清理全部 refresh token

用户修改密码成功后，通常要让所有设备重新登录。

实现方式：

```text
更新 user_id = 1001 的所有 refresh token：
revoked = true
revoked_reason = password_changed
revoked_at = 当前时间
```

效果：

```text
所有设备都不能再刷新 access token
access token 过期后，全部回到登录页
```

如果要求修改密码后所有旧 access token 也立即失效，同样需要 access token 黑名单或 token version。

### 11.7 Refresh Token 轮换与重复使用检测

更安全的做法是 refresh token rotation，也就是每次刷新时同时返回新的 refresh token。

流程：

```text
1. 登录后得到：
   access_token_A
   refresh_token_A

2. access_token_A 过期

3. 客户端用 refresh_token_A 请求刷新

4. 服务端返回：
   access_token_B
   refresh_token_B

5. 服务端立即让 refresh_token_A 失效
```

服务端记录：

```text
refresh_token_A:
  revoked = true
  replaced_by = refresh_token_B 的 hash

refresh_token_B:
  revoked = false
  family_id = 与 A 相同
```

正常客户端以后只会使用 `refresh_token_B`。

如果服务端后来又收到 `refresh_token_A`，说明旧 refresh token 被重复使用。

可能原因：

- refresh token 泄露。
- 用户多窗口并发刷新。
- 客户端刷新逻辑有 bug。

安全处理方式可以是：

```text
撤销这个 family_id 下的整条 refresh token 链
或撤销该用户当前设备的所有 refresh token
严重时撤销该用户所有 refresh token
要求重新登录
```

伪代码：

```java
if (record.isRevoked() && record.getReplacedBy() != null) {
    revokeTokenFamily(record.getFamilyId(), "reuse_detected");
    throw new RuntimeException("refresh token reused");
}
```

### 11.8 完整刷新流程

一次完整刷新可以这样理解：

```text
客户端拿 refresh_token_A 请求 /auth/refresh

服务端：
1. hash(refresh_token_A)
2. 查询 refresh_token 记录
3. 不存在 -> 拒绝
4. 已过期 -> 拒绝
5. revoked = true 且 replaced_by 不为空 -> 判定重复使用
6. revoked = true -> 拒绝
7. 正常 -> 生成新的 access token
8. 生成新的 refresh_token_B
9. 保存 refresh_token_B
10. 标记 refresh_token_A 为 revoked = true，replaced_by = B
11. 返回新的 access token 和 refresh token
```

### 11.9 这些能力分别靠什么实现

| 能力 | 实现方式 |
|---|---|
| 主动撤销 | 设置 `revoked = true` |
| 踢设备下线 | 按 `user_id + device_id` 撤销 refresh token |
| 改密码清理全部 | 按 `user_id` 撤销全部 refresh token |
| 检测重复使用 | refresh token 轮换，旧 token 再出现就是异常 |
| 立即踢下线 | 额外处理 access token 黑名单或 token version |

一句话：

```text
refresh token 不是单纯的长期 token，而是服务端可管理、可撤销、可追踪的一条登录凭证记录。
```

## 12. Sa-Token 与传统方案对比

| 能力 | 传统 HttpSession | 自研 Token | Sa-Token |
|---|---|---|---|
| 登录态 | `session.setAttribute` | 自己生成 token | `StpUtil.login()` |
| 当前用户 | 从 session 取 | 从 Redis 或 JWT 解析 | `StpUtil.getLoginId()` |
| 是否登录 | 自己判断 | 自己写拦截器 | `StpUtil.checkLogin()` |
| 权限判断 | 自己写 | 自己写 | `checkRole` / `checkPermission` |
| 前后端分离 | 依赖 Cookie，跨域配置复杂 | 支持 | 原生支持 token |
| 分布式 | 要共享 session 或粘性会话 | 要接 Redis | 可接 Redis 持久化 |
| 踢人下线 | 需要自己维护 session 映射 | 需要自己维护 token 映射 | `StpUtil.kickout()` |
| 多端登录 | 实现复杂 | 要自己设计 | 配置 `is-concurrent` / `is-share` |
| 封禁账号 | 自己写 | 自己写 | `StpUtil.disable()` |
| 二级认证 | 自己写 | 自己写 | `openSafe()` / `checkSafe()` |
| 注解鉴权 | 自己写 AOP 或拦截器 | 自己写 | Sa-Token 内置支持 |

---

## 13. Sa-Token 具体是如何解决这些问题的

### 13.1 如何解决登录态管理重复造轮子

自研登录态时，通常要自己完成这条链路：

```text
登录成功
  -> 生成 token
  -> 把 token 存到 Redis
  -> 记录 token 对应哪个 userId
  -> 每次请求从 header / cookie 中取 token
  -> 到 Redis 查询 token 是否存在
  -> 判断 token 是否过期
  -> 查出 userId
  -> 把 userId 交给业务代码使用
```

Sa-Token 把这条链路封装成统一 API。

登录时业务代码只需要：

```java
StpUtil.login(userId);
```

执行后，Sa-Token 内部会完成：

```text
1. 生成 token。
2. 建立 token -> loginId 的映射。
3. 建立 loginId -> Session 的账号会话。
4. 设置 token 和 Session 的过期时间。
5. 把登录态保存到 SaTokenDao 中。
```

如果项目接入 Redis，`SaTokenDao` 的实现就会把这些数据保存到 Redis。

后续请求进来时，业务代码只需要：

```java
StpUtil.checkLogin();
Long userId = StpUtil.getLoginIdAsLong();
```

Sa-Token 内部会完成：

```text
1. 从当前请求中读取 token。
2. 用 token 查询登录态。
3. 判断 token 是否存在、是否过期、是否被踢下线。
4. 找到 token 对应的 loginId。
5. 把 loginId 返回给业务代码。
```

所以它解决的不是“帮你写一行登录代码”，而是把登录态的创建、保存、查询、过期、退出、踢下线这些通用状态管理都统一接管。

### 13.2 如何解决权限校验分散在业务代码中

自研权限时，常见写法是每个接口里手写判断：

```java
if (!user.hasPermission("order:list")) {
    throw new RuntimeException("无权限");
}
```

这种写法的问题是：

- 每个接口都要写一遍。
- 有的接口可能漏写。
- 有的地方按角色判断，有的地方按权限码判断，规则容易不统一。
- 权限失败后的异常格式也容易不统一。

Sa-Token 的解决方式是把权限判断收口到统一 API 和统一注解。

在代码中可以直接校验：

```java
StpUtil.checkRole("admin");
StpUtil.checkPermission("order:list");
```

也可以在接口入口声明：

```java
@SaCheckRole("admin")
@SaCheckPermission("order:list")
@PostMapping("/list")
public Object list() {
    return orderService.list();
}
```

这些 API 本身不负责“权限从哪里来”，权限数据通常由项目实现 `StpInterface` 提供：

```java
public class StpInterfaceImpl implements StpInterface {

    @Override
    public List<String> getPermissionList(Object loginId, String loginType) {
        return permissionService.listPermissionByUserId(loginId);
    }

    @Override
    public List<String> getRoleList(Object loginId, String loginType) {
        return roleService.listRoleByUserId(loginId);
    }
}
```

因此完整链路是：

```text
接口进入
  -> Sa-Token 注解或 checkPermission() 触发权限校验
  -> Sa-Token 获取当前 loginId
  -> 调用项目实现的 StpInterface
  -> 拿到当前用户角色 / 权限码
  -> 判断是否包含目标角色 / 权限
  -> 不通过则抛出统一异常
```

Sa-Token 解决的是“权限校验入口、权限校验流程、异常处理方式统一”，而不是替业务系统设计角色权限表。

### 13.3 如何解决 Token 生成、存储、续期、失效逻辑复杂

Token 生命周期至少包含这些状态：

```text
生成
保存
携带
校验
续期
过期
退出
踢下线
```

自研时要自己设计很多细节：

- token 用 UUID、JWT 还是自定义随机串。
- token 放 header 还是 cookie。
- Redis key 怎么设计。
- token 过期时间怎么设置。
- 用户主动退出后 token 如何失效。
- 长时间未操作是否要自动过期。
- 每次访问是否刷新有效期。

Sa-Token 通过配置和统一 API 处理这些问题。

常见配置类似：

```yaml
sa-token:
  token-name: satoken
  timeout: 7200
  active-timeout: -1
  is-concurrent: true
  is-share: false
```

含义是：

| 配置 | 作用 |
|---|---|
| `token-name` | 指定前端传 token 时使用的 header / 参数名 |
| `timeout` | token 总有效期 |
| `active-timeout` | token 最低活跃频率，超过时间未访问可失效 |
| `is-concurrent` | 是否允许同一账号多端同时登录 |
| `is-share` | 多端登录时是否共用同一个 token |

登录、校验、退出对应的 API 是：

```java
StpUtil.login(userId);
StpUtil.checkLogin();
StpUtil.logout();
```

它们背后的 Redis 数据可以理解为：

```text
satoken:login:token:{token}
  保存 token 与 loginId 的对应关系。

satoken:login:session:{loginId}
  保存账号级 Session。

satoken:login:token-session:{token}
  保存 token 级 Session。
```

用户退出时：

```java
StpUtil.logout();
```

Sa-Token 会清理当前 token 对应的登录态。后续请求再携带这个 token，`StpUtil.checkLogin()` 就不能通过。

所以 Sa-Token 是通过“统一配置 + 统一 API + 统一存储结构”来管理 token 生命周期。

### 13.4 如何解决分布式和前后端分离场景的问题

传统 `HttpSession` 默认依赖服务端内存。

```text
请求 1 -> 服务 A -> Session 存在
请求 2 -> 服务 B -> Session 不存在
```

如果没有共享 Session，就会出现用户在 A 服务登录后，到 B 服务变成未登录。

Sa-Token 的解决方式是把登录态抽象到 `SaTokenDao`。

```text
业务代码
  -> StpUtil
  -> Sa-Token 内部状态管理
  -> SaTokenDao
  -> Redis / 内存 / 其他存储
```

单机开发时可以使用内存实现。分布式部署时接入 Redis，让多台服务访问同一份登录态数据。

```text
服务 A 登录
  -> token 与 loginId 写入 Redis

服务 B 收到请求
  -> 从请求中读取同一个 token
  -> 到 Redis 查出 loginId
  -> 识别为同一个登录用户
```

前后端分离时，前端不一定依赖浏览器自动 Cookie。可以显式把 token 放到请求头：

```http
satoken: e24c96f6-ab93-46f3-964a-84f461c394a6
```

后端通过 `token-name` 配置读取：

```yaml
sa-token:
  token-name: satoken
```

因此 Sa-Token 对前后端分离更友好：前端保存 token，后端按 token 查询登录态，不强依赖 `JSESSIONID` 和传统 Cookie Session。

### 13.5 如何解决踢人、封禁、多端登录、二级认证

这些能力自研起来复杂，是因为它们不只是一个 if 判断，而是需要维护额外的账号状态。

#### 踢人下线

踢人下线要解决的问题是：

```text
管理员让用户 1001 下线
  -> 用户 1001 现有 token 不能继续使用
  -> 后续请求必须重新登录
```

Sa-Token 提供：

```java
StpUtil.kickout(1001);
```

之后用户再用旧 token 请求时，Sa-Token 校验登录态会失败，业务接口不需要自己再判断这个 token 是否被踢。

#### 封禁账号

封禁账号要解决的问题是：

```text
用户还可以是登录状态
但某些操作在封禁期间不能执行
```

Sa-Token 提供：

```java
StpUtil.disable(1001, 3600);
StpUtil.checkDisable(1001);
```

这表示封禁账号 `1001` 一小时。需要保护的接口可以检查账号是否被封禁。

#### 多端登录

多端登录要解决的问题是：

```text
同一个账号能不能同时在电脑、手机、小程序登录？
后登录是否要挤掉先登录？
多个端是否共用同一个 token？
```

Sa-Token 用配置处理：

```yaml
sa-token:
  is-concurrent: true
  is-share: false
```

常见含义：

| 配置组合 | 效果 |
|---|---|
| `is-concurrent: true` | 允许同账号多端同时在线 |
| `is-concurrent: false` | 后登录可能顶掉前一次登录 |
| `is-share: true` | 多端可能共用同一个 token |
| `is-share: false` | 每次登录生成不同 token |

这样业务代码不用自己维护“同一账号当前有哪些 token、是否要挤下线”的完整逻辑。

#### 二级认证

二级认证用于高危操作，例如改密码、转账、删除重要数据。

普通登录只能说明：

```text
这个请求来自已登录用户。
```

二级认证要额外说明：

```text
这个用户刚刚通过了更高安全级别确认。
```

Sa-Token 提供：

```java
StpUtil.openSafe(300);
StpUtil.checkSafe();
```

可以理解为：

```text
用户完成二次验证
  -> openSafe(300)
  -> 未来 300 秒内允许执行高危操作

进入高危接口
  -> checkSafe()
  -> 未通过二级认证或已过期则拒绝
```

因此二级认证状态也不用每个业务接口自己设计 Redis key、过期时间和校验逻辑。

---

## 14. 总结

传统 `HttpSession` 的思路是：

```text
服务端记住用户状态，浏览器自动携带 JSESSIONID
```

传统自研 Token 的思路是：

```text
客户端保存 token，服务端自己写拦截器、Redis 映射、过期和权限逻辑
```

Sa-Token 的思路是：

```text
客户端携带 token，服务端用统一框架管理登录态、权限态、会话态和账号控制能力
```

它主要解决的是：

| 问题 | 自己实现时通常要做什么 | Sa-Token 如何解决 |
|---|---|---|
| 登录态管理容易重复造轮子 | 生成 token、保存 token 与用户关系、校验 token 是否有效、处理过期、退出登录、踢人下线 | 用 `StpUtil.login()` 建立登录态，用 `StpUtil.checkLogin()` 校验登录态，用 `StpUtil.logout()` 退出登录，用 `StpUtil.kickout()` 踢人下线 |
| 权限校验分散在业务代码中 | 每个接口里手写角色、权限、菜单、按钮权限判断，容易漏校验或写法不统一 | 统一使用 `StpUtil.checkRole()`、`StpUtil.checkPermission()`，也可以配合 `@SaCheckRole`、`@SaCheckPermission` 注解把权限规则声明在接口入口 |
| Token 生成、存储、续期、失效逻辑复杂 | 自己设计 token 格式、Redis key、TTL、续期策略、退出后失效、过期判断 | Sa-Token 内部负责生成 token、维护 token 与 loginId 的映射、管理过期时间，并通过配置控制 timeout、active-timeout、自动续期等行为 |
| 分布式和前后端分离场景下传统 session 不够灵活 | 多台服务要共享 Session，前端还要处理 Cookie 跨域、SameSite、withCredentials 等问题 | Sa-Token 默认按 token 工作，前端可以通过 header 或参数携带 token；后端接入 Redis 后，多台服务共享同一份登录态数据 |
| 踢人、封禁、多端登录、二级认证等能力自研成本高 | 需要额外维护在线设备列表、账号状态、封禁时间、多端互斥策略、高危操作二次校验状态 | Sa-Token 提供 `kickout()`、`disable()`、多端登录配置、`openSafe()` / `checkSafe()` 等内置能力，把这些账号控制逻辑统一封装起来 |

一句话：

```text
传统方案是自己拼认证系统；Sa-Token 是直接使用一套封装好的认证状态管理框架。
```
