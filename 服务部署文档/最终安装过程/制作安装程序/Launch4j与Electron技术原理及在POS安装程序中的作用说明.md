# Launch4j 与 Electron 技术原理及在 POS 安装程序中的作用说明

## 1. 文档目的

本文用于用通俗、系统、可落地的方式说明以下问题：

1. `Launch4j` 是什么，它的技术原理是什么。
2. `Electron` 是什么，它的技术原理是什么。
3. 两者分别适合解决什么问题。
4. 在当前 POS 安装程序体系中，`server.exe`、`client.exe` 分别更像是哪一种技术路线。
5. 为什么 Spring Boot 的外部配置文件放在 `app-server/config/application.yml` 仍然能被读取。
6. 打包、启动、目录布局、运行时查找配置之间到底是什么关系。

本文尽量避免只给结论，不讲过程。读完后，应当能看懂当前安装包结构，也能向别人解释为什么要这样设计。

---

## 2. 先说结论

当前这套 POS 安装程序里，至少有两条完全不同的技术路线：

1. `server.exe`
   更像是 `Launch4j + Java + Spring Boot` 的路线。
   它的作用是把 Java 服务端程序包装成 Windows 可执行文件，并负责启动 Spring Boot 服务。

2. `client.exe`
   从版本资源信息看，更像是 `Electron` 路线。
   它的作用是提供桌面客户端壳，内部承载网页界面，并和本地系统能力交互。

两者虽然最终都表现为 `.exe`，但技术原理完全不同：

- `Launch4j` 的本质：帮 Java 程序套一层 Windows 启动器。
- `Electron` 的本质：把浏览器内核和 Node.js 打包成一个桌面应用运行时，再把网页应用装进去。

一句话记忆：

- `Launch4j` 是“把 Java 程序伪装成 exe”。
- `Electron` 是“把网页程序做成桌面软件”。

---

## 3. 什么是 Launch4j

### 3.1 Launch4j 的定位

`Launch4j` 是一个 Windows 平台上的 Java 启动器封装工具。

它的作用不是把 Java 源码编译成原生机器码，也不是把 Spring Boot 重新打包成 C++ 程序，而是：

1. 生成一个 Windows 的 `.exe` 外壳。
2. 这个 `.exe` 在运行时去寻找本机或随程序一起发布的 JRE/JDK。
3. 然后按预设参数启动 Java 主类或 jar。

也就是说：

`Launch4j` 生成的 `.exe` 本质上仍然是在启动 JVM。

### 3.2 为什么要用 Launch4j

如果不用 `Launch4j`，用户启动 Java 程序通常要这样：

```bat
java -jar xxx.jar
```

这对开发人员没问题，但对最终客户不友好，因为会带来几个问题：

1. 用户看不懂 `jar` 是什么。
2. 用户机器未必配置了 Java 环境变量。
3. 可以直接双击的 `.exe` 更符合 Windows 用户习惯。
4. 可以附加图标、错误提示、JRE 路径等 Windows 分发能力。

所以 `Launch4j` 的目标是：

把“命令行启动 Java 程序”包装成“像普通 Windows 软件一样启动”。

---

## 4. Launch4j 的技术原理

### 4.1 运行链路

`Launch4j` 的核心运行链路可以理解为：

```text
用户双击 server.exe
    ->
Launch4j 启动器运行
    ->
检查 JRE/JDK 路径
    ->
拼接 Java 启动参数
    ->
调用 java.exe 或 javaw.exe
    ->
启动指定主类 / jar
    ->
Spring Boot 程序真正开始运行
```

注意：

真正跑业务代码的不是 `server.exe` 自己，而是它拉起的 JVM。

### 4.2 Launch4j 不做什么

`Launch4j` 不负责：

1. 改写 Spring Boot 的配置加载逻辑。
2. 改写 Java 类加载机制。
3. 把 Java 代码编译成原生 exe。
4. 实现网页界面。

它只负责“启动入口包装”。

### 4.3 Launch4j 配置的关键字段

以当前项目的 `server.xml` 为例：

```xml
<launch4jConfig>
  <dontWrapJar>true</dontWrapJar>
  <headerType>gui</headerType>
  <outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
  <cmdLine></cmdLine>
  <chdir>.</chdir>

  <classPath>
    <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
    <cp>..\libs\*.jar</cp>
    <cp>..\jdk-21.0.5\ext\*.jar</cp>
  </classPath>

  <jre>
    <path>../jdk-21.0.5</path>
  </jre>
</launch4jConfig>
```

这些字段的含义如下：

#### `outfile`

生成的 exe 路径。

例如：

```xml
<outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
```

表示最终 Windows 启动文件叫 `server.exe`。

#### `mainClass`

指定 JVM 启动后执行哪个主类。

这里是：

```xml
<mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
```

说明当前不是直接执行某个普通 `main()`，而是通过 Spring Boot Loader 的 `JarLauncher` 去组织类路径并启动应用。

#### `cp`

指定类路径。

例如：

```xml
<cp>..\libs\*.jar</cp>
```

表示业务 jar 在 `app-server` 上一级的 `libs` 目录。

#### `jre.path`

指定随程序发布的 JRE/JDK 位置。

例如：

```xml
<path>../jdk-21.0.5</path>
```

说明这个程序优先使用安装目录里自带的 JDK，而不是依赖用户自己安装 Java。

#### `chdir`

这是整个目录理解里最关键的字段：

```xml
<chdir>.</chdir>
```

表示：启动 `server.exe` 后，将当前工作目录切换到 `server.exe` 所在目录。

如果 `server.exe` 在：

```text
C:\easySoft\SaasServer\app-server\
```

那么启动后工作目录就是：

```text
C:\easySoft\SaasServer\app-server\
```

这个设置会影响：

1. 相对 classpath 的解析。
2. Spring Boot 外部配置文件的搜索。
3. 代码里相对路径文件的读写。
4. 日志、图标、资源文件的相对定位。

---

## 5. Launch4j 下 Spring Boot 为什么能读到外部配置

### 5.1 目录现象

当前安装目录的典型结构是：

```text
SaasServer/
  libs/
    业务 jar ...
  app-server/
    server.exe
    server.xml
    config/
      application.yml
```

很多人看到这个结构会困惑：

“jar 在 `libs/`，配置却在 `app-server/config/`，Spring Boot 为什么还能读到？”

### 5.2 真正原因

原因不是“jar 会自动找自己的父目录”。

真正原因是：

1. `server.exe` 启动时通过 `Launch4j` 将工作目录设置为 `app-server`。
2. Spring Boot 默认支持从当前工作目录查找外部配置。
3. 它会查找：
   - `./application.yml`
   - `./config/application.yml`
   - `./config/*/application.yml`
4. 所以 `app-server/config/application.yml` 正好命中。

也就是说：

**Spring Boot 找外部配置时，看的是运行时搜索路径，不是 jar 文件实际磁盘位置。**

### 5.3 当前项目里的完整理解

当前项目可以理解为：

1. `Launch4j` 负责把工作目录固定在 `app-server`。
2. `JarLauncher` 负责从 `..\libs\*.jar` 加载业务代码。
3. Spring Boot 负责在 `app-server/config` 下读取外部配置。

所以三件事虽然都与“路径”有关，但不是同一个机制：

1. `Launch4j` 决定站在哪儿。
2. `classpath` 决定从哪儿加载 jar。
3. Spring Boot 决定去哪儿找配置。

---

## 6. 什么是 Electron

### 6.1 Electron 的定位

`Electron` 是一个桌面应用运行时框架。

它把这三样东西组合到一起：

1. `Chromium`
   负责渲染网页界面。
2. `Node.js`
   负责文件系统、进程、网络、系统 API 等能力。
3. 桌面应用壳
   负责窗口、托盘、菜单、快捷键、多屏、系统集成。

因此，Electron 应用本质上是：

**用网页技术开发的桌面软件。**

### 6.2 为什么很多桌面客户端用 Electron

因为它允许前端团队用熟悉的 Web 技术做桌面应用：

1. 界面可以用 React/Vue/HTML/CSS/JS。
2. 可以快速复用已有 Web 页面。
3. 可以直接加载本地服务地址或静态页面。
4. 可以通过 Electron 暴露系统能力。

在 POS 这类场景下，它非常适合做：

1. 登录壳程序
2. 收银桌面客户端
3. 副屏控制
4. 托盘管理
5. 本地配置读写
6. 和打印、扫码、系统能力交互

---

## 7. Electron 的技术原理

### 7.1 Electron 的两层进程模型

Electron 最重要的概念是：

它不是单进程纯前端程序，而是至少分两层：

1. **主进程 Main Process**
2. **渲染进程 Renderer Process**

#### 主进程

主进程是桌面程序控制层，负责：

1. 创建窗口
2. 控制菜单和托盘
3. 处理本地文件
4. 调系统 API
5. 管理多窗口、多屏
6. 暴露接口给前端页面

#### 渲染进程

渲染进程本质上是一个 Chromium 网页页面。

负责：

1. 展示 UI
2. 处理页面逻辑
3. 发起页面跳转
4. 调用主进程暴露出来的能力

### 7.2 Electron 运行链路

Electron 应用启动过程通常是：

```text
用户双击 client.exe
    ->
Electron Runtime 启动
    ->
读取应用 package.json
    ->
找到主进程入口 main.js
    ->
执行主进程代码
    ->
主进程创建 BrowserWindow
    ->
BrowserWindow 加载网页
    ->
网页界面显示
```

这个网页可以是：

1. 本地静态文件
   例如 `dist/index.html`
2. 本地服务地址
   例如 `http://127.0.0.1:9180/user/login`
3. 远程网址

### 7.3 Electron 与普通浏览器的差别

虽然渲染层也是网页，但它不是普通浏览器标签页。

因为 Electron 主进程可以提供普通网页做不到的能力，比如：

1. 读取本地配置文件
2. 最小化窗口
3. 打开副屏窗口
4. 获取多显示器信息
5. 系统托盘交互
6. 打开软键盘
7. 退出程序

这些能力通常通过 `preload` 或 `ipc` 暴露给页面。

例如页面里可能出现：

```js
window.api.quit()
window.api.isDev()
window.api.openSecondScreen()
window.api.setConfig()
```

这类接口不是浏览器原生提供的，而是 Electron 壳注入给页面的。

---

## 8. Electron 打包后的目录原理

### 8.1 打包结果一般长什么样

一个典型 Electron 应用打包后，往往包含下面这些文件：

```text
MyApp/
  MyApp.exe
  resources/
    app.asar
  chrome_100_percent.pak
  chrome_200_percent.pak
  icudtl.dat
  ffmpeg.dll
  libEGL.dll
  libGLESv2.dll
  snapshot_blob.bin
  v8_context_snapshot.bin
```

#### `MyApp.exe`

这是 Electron 的启动壳。

#### `resources/app.asar`

这是应用代码归档包，里面往往包含：

1. `package.json`
2. `main.js`
3. `preload.js`
4. 打包后的前端页面 `dist/`

#### 其他资源文件

这些文件是 Chromium / V8 运行时需要的资源，不是业务代码。

### 8.2 Electron 打包做了什么

Electron 打包工具通常做了下面几件事：

1. 收集主进程代码
2. 收集预加载脚本
3. 收集前端打包产物
4. 生成 `app.asar`
5. 把 `app.asar` 放到 `resources/`
6. 附带 Electron Runtime 运行时文件
7. 生成安装包或绿色版 exe

所以 Electron 的“exe”不是业务逻辑本身，而是：

**Electron Runtime + 应用资源包**

---

## 9. Electron 如何加载页面

Electron 页面加载有两种常见模式：

### 9.1 加载本地静态页面

例如：

```js
win.loadFile('dist/index.html')
```

这说明前端构建产物已经放到客户端安装包里，离线也能运行。

### 9.2 加载本地服务地址

例如：

```js
win.loadURL('http://127.0.0.1:9180/user/login')
```

这说明 Electron 更像“桌面浏览器壳”，真正页面由本地 Web 服务提供。

当前 POS 项目的行为更接近这种模式，因为前端源码里出现了：

1. `http://127.0.0.1:9180/user/login`
2. `http://${serverIp}:9181/app/`
3. `http://127.0.0.1:${port}/second-screen`

这说明桌面客户端壳的职责之一，就是根据运行场景跳转到本地服务页面。

---

## 10. 当前 POS 项目里 Electron 的落点

### 10.1 现有证据

从当前已知证据看：

1. `client.exe` 的版本资源中包含：
   - `FileDescription = A minimal Electron application`
   - `ProductName = 柠檬树SaaS餐饮收银系统客户端`
   - `CompanyName = GitHub`

2. 安装脚本把 `client.exe` 当作独立客户端安装器来触发。

3. 前端源码中存在明显的桌面壳 API：

```js
window.api.isDev()
window.api.isSelfOrder()
window.api.setSecondaryUrl()
window.api.openSecondScreen()
window.api.quit()
```

4. 页面启动后会跳转到本地地址：

```js
http://${serverIp}:9180/user/login
http://${serverIp}:9181/app/
```

### 10.2 这说明了什么

这说明当前客户端大概率是：

1. 用 Electron 做的桌面壳
2. 壳里加载前端页面
3. 页面再跳转到本地 Spring Boot 服务地址
4. 同时通过 `window.api` 调用本地桌面能力

也就是说：

`client.exe` 更像桌面 UI 壳  
`server.exe` 更像本地业务服务壳

两者分工不同，但配合完成整套 POS 客户端体验。

---

## 11. Launch4j 与 Electron 的根本区别

### 11.1 技术本体不同

#### Launch4j

本体仍然是 Java 程序。

它的 exe 只是启动器。

#### Electron

本体是 Chromium + Node.js + 桌面壳。

它的 exe 是运行时本身。

### 11.2 运行目标不同

#### Launch4j 适合

1. Spring Boot 服务端
2. Swing / JavaFX 客户端
3. 后台服务控制程序
4. 配置工具

#### Electron 适合

1. 桌面前端壳
2. 复杂 UI 客户端
3. 多窗口 / 多屏桌面应用
4. 需要网页技术开发桌面程序的场景

### 11.3 包含运行时的方式不同

#### Launch4j

依赖 JVM。

可以使用系统 Java，也可以随程序附带 JRE/JDK。

#### Electron

自带 Chromium 和 Node.js 运行时。

不依赖系统浏览器或系统 Node.js。

### 11.4 页面来源不同

#### Launch4j + Spring Boot

本身不是页面壳。

只是启动 Java 服务，页面一般由浏览器或别的客户端访问。

#### Electron

本身就是桌面界面承载者。

它直接显示网页。

---

## 12. 为什么安装程序里两者可以同时存在

因为它们负责的是不同层次的任务：

### 12.1 服务端层

由 `Launch4j` 包出来的 `server.exe` 启动本地 Java 服务：

1. 启动 Spring Boot
2. 开启端口 `9180`
3. 读取 `app-server/config/application.yml`
4. 提供接口与页面资源

### 12.2 客户端桌面层

由 `Electron` 包出来的 `client.exe` 提供桌面交互壳：

1. 启动客户端窗口
2. 控制副屏
3. 管理桌面行为
4. 加载本地页面
5. 跳转到本地 Web 服务地址

因此，一套完整的 POS 安装程序完全可能同时包含：

1. `server.exe`：Java 服务端启动器
2. `client.exe`：Electron 桌面客户端
3. `printer.exe`：打印服务
4. `monitor.exe`：监控程序

这不是重复建设，而是分层设计。

---

## 13. 用生活化比喻理解两者

### 13.1 Launch4j 像什么

可以把 `Launch4j` 理解成：

“给 Java 程序装了一个 Windows 门把手。”

本来用户要敲命令：

```text
java -jar app.jar
```

现在用户只要双击：

```text
app.exe
```

但屋子里真正干活的还是 Java。

### 13.2 Electron 像什么

可以把 `Electron` 理解成：

“自带浏览器引擎的一整套桌面房子。”

它不是给已有程序装门把手，而是自己本身就是一套房子：

1. 有窗户
2. 有操作系统接口
3. 有浏览器内核
4. 网页界面直接住在里面

---

## 14. 当前项目最值得记住的几个事实

1. `server.exe` 不是 Spring Boot 源码本身，而是 `Launch4j` 生成的 Java 启动壳。
2. `server.exe` 真正启动的是 `JarLauncher` 和 `..\libs\*.jar` 中的业务程序。
3. `app-server/config/application.yml` 能生效，不是因为它在 jar 旁边，而是因为 `Launch4j` 的工作目录设置为 `app-server`。
4. `client.exe` 从版本资源看是 Electron 客户端路线，不是 `Launch4j`。
5. `client.exe` 更像桌面前端壳，负责窗口、多屏、本地配置和页面跳转。
6. 前端源码中 `window.api.*` 和本地 `9180/9181` 地址跳转，是 Electron 壳 + 本地 Web 服务协作的典型模式。

---

## 15. 面向维护人员的排查思路

### 15.1 如果 `server.exe` 启动了，但配置没生效

先检查：

1. `server.xml` 里的 `<chdir>` 是不是正确。
2. `app-server/config/application.yml` 是否存在。
3. 程序是不是从预期目录启动。
4. Spring Boot 是否被额外参数覆盖了配置路径。

### 15.2 如果客户端页面打开异常

先区分是：

1. `client.exe` 没启动
2. Electron 壳启动了，但页面没加载
3. 页面加载了，但跳转地址错了
4. 本地 `9180/9181` 服务没启动

这个问题不能只盯一个 exe，要按分层排查。

### 15.3 如果用户问“这到底是前端问题还是后端问题”

可以按下面方式判断：

1. `server.exe` 启不来、端口没开、接口报错
   多半是后端或 Java 启动层问题。

2. `client.exe` 窗口打不开、托盘异常、副屏异常、`window.api` 无响应
   多半是 Electron 壳层问题。

3. 客户端打开了，但页面跳到错误地址
   多半是前端启动页逻辑或本地配置问题。

---

## 16. 总结

`Launch4j` 和 `Electron` 都能产出 `.exe`，但二者不是同一类技术。

### Launch4j

它解决的是：

“如何让 Java 程序像 Windows 软件一样启动”

它的原理是：

“用 exe 启动器去拉起 JVM 和 Java 主类”

### Electron

它解决的是：

“如何把网页应用做成桌面软件”

它的原理是：

“把 Chromium、Node.js 和应用代码打包成桌面运行时”

### 在当前 POS 项目里

1. `server.exe`
   负责启动 Spring Boot，本质属于 `Launch4j + Java` 路线。

2. `client.exe`
   负责桌面界面壳、本地交互和页面承载，本质更像 `Electron` 路线。

3. `application.yml`
   虽然不在 `libs` 里的 jar 旁边，但仍能被 Spring Boot 读取，因为运行时工作目录被固定在 `app-server`，而 Spring Boot 默认会从 `./config/application.yml` 读取外部配置。

理解了这一点，当前安装包结构就不再混乱：

- `Launch4j` 负责服务启动
- `Electron` 负责桌面客户端
- `Inno Setup` 负责安装分发
- `Spring Boot` 负责业务服务

它们不是相互替代关系，而是同一套部署体系中的不同角色。
