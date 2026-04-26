# pos4install app-server server.xml 逐行详解

本文解析的文件是：

```text
D:\mywork\pos4install\app\app-server\server.xml
```

这个文件是当前 `pos4install` 新体系里的 Launch4j 配置。它用于生成或说明：

```text
server.exe
```

它不是 Java 源码，也不是 Inno 安装脚本，而是 Launch4j 的“制壳配置”。

## 一、这个 server.xml 的核心结论

这个配置生成的 `server.exe` 是：

```text
GUI 模式的 Java 启动壳
不把业务 jar 包进 exe
运行时使用安装目录里的 jdk-21.0.5
运行时加载安装目录里的 libs/*.jar
运行时额外加载 jdk-21.0.5/ext/*.jar
通过 Spring Boot 3 的 JarLauncher 启动应用
```

一句话：

```text
server.exe 只是启动器，真正业务代码在 libs/*.jar。
```

## 二、安装后的目录模型

理解 `server.xml` 前，先要理解安装后的目录结构。

结合 `setup.iss`，安装目录是：

```text
C:\easySoft\SaasServer
```

安装后大致结构：

```text
C:\easySoft\SaasServer\
  app-server\
    server.exe
    server.xml
    config\
      application.yml

  libs\
    *.jar

  jdk-21.0.5\
    bin\
      java.exe
      javaw.exe
    ext\
      *.jar
```

其中：

```text
app-server\server.exe
  -> Launch4j 生成的 Windows 启动壳

libs\*.jar
  -> Spring Boot 业务 jar 和依赖 jar

jdk-21.0.5
  -> 安装包内置 JDK

jdk-21.0.5\ext\*.jar
  -> 额外扩展依赖
```

## 三、原始 server.xml

原始文件内容如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<launch4jConfig>
  <dontWrapJar>true</dontWrapJar>
  <headerType>gui</headerType>
  <jar></jar>
  <outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
  <errTitle></errTitle>
  <cmdLine></cmdLine>
  <chdir>.</chdir>
  <priority>normal</priority>
  <downloadUrl>http://java.com/download</downloadUrl>
  <supportUrl></supportUrl>
  <stayAlive>false</stayAlive>
  <restartOnCrash>false</restartOnCrash>
  <manifest></manifest>
  <icon>D:\easySoft\SaasServer\Icon\server.ico</icon>

  <classPath>
    <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
    <cp>..\libs\*.jar</cp>
    <cp>..\jdk-21.0.5\ext\*.jar</cp>
  </classPath>
  <jre>
    <path>../jdk-21.0.5</path>
    <requiresJdk>false</requiresJdk>
    <requires64Bit>false</requires64Bit>
    <minVersion></minVersion>
    <maxVersion></maxVersion>
  </jre>
</launch4jConfig>
```

## 四、带行内注释版

下面是同一份配置的“学习注释版”。不要直接拿这份替换生产 XML，因为 XML 注释虽然合法，但生产资源建议保持简洁。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
  XML 声明。
  encoding="UTF-8" 表示这个配置文件按 UTF-8 编码读取。
  Launch4j 的配置本质上就是一个 XML 文件。
-->

<launch4jConfig>
  <!--
    Launch4j 配置根节点。
    所有 Launch4j 参数都写在这个节点下面。
  -->

  <dontWrapJar>true</dontWrapJar>
  <!--
    true 表示：不要把 jar 打进 exe 里。

    这点非常关键。

    如果是 false：
      Launch4j 会把指定 jar 包进 exe。
      exe 本身会包含 jar。
      小工具和 demo 常用这种方式。

    当前是 true：
      server.exe 只是一个启动壳。
      业务 jar 必须放在外部目录。
      当前配置里外部 jar 来自：
        ..\libs\*.jar

    这种方式的好处：
      1. server.exe 可以长期不变。
      2. 升级业务时主要替换 libs/*.jar。
      3. Inno 升级包可以只覆盖 jar，而不重做启动壳。

    对应当前项目结论：
      server.exe 里面没有业务代码。
      业务代码在 C:\easySoft\SaasServer\libs\*.jar。
  -->

  <headerType>gui</headerType>
  <!--
    exe 类型。

    gui：
      不显示黑色控制台窗口。
      更像普通 Windows 桌面程序。
      通常会用 javaw.exe 启动 Java。

    console：
      显示控制台窗口。
      更适合调试 Spring Boot 服务端。
      能直接看到启动日志、端口占用、异常堆栈。

    当前是 gui，说明正式安装后启动 server.exe 时不希望弹出控制台窗口。

    注意：
      gui 模式启动失败时，用户可能只感觉“没反应”。
      排查问题时建议临时改成 console 重新生成 exe。

    你之前 demo 中端口占用时看到 javaw.exe，
    就和 gui/无控制台运行方式有关。
  -->

  <jar></jar>
  <!--
    要包进 exe 的 jar 路径。

    当前为空是合理的。

    因为 dontWrapJar=true，
    当前不是“把 jar 包进 exe”的模式，
    而是使用 classPath 指定外部 jar。

    如果 dontWrapJar=false，
    这里就应该填写某个 jar，例如：
      target\xxx.jar
  -->

  <outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
  <!--
    Launch4j 生成 exe 时的输出路径。

    它表示：
      当运行 Launch4j 构建这个 XML 时，
      输出文件写到 D:\easySoft\SaasServer\app-server\server.exe。

    注意：
      这个路径是“制壳机器”上的输出路径，
      不是 Inno 安装时动态决定的路径。

    你们当前 pos4install 里已经有：
      D:\mywork\pos4install\app\app-server\server.exe

    Inno 打包时会把 app/app-server/* 复制到：
      {app}/app-server/

    setup.iss 里对应：
      Source: "app/app-server/*"; DestDir: "{app}/app-server/";

    默认 {app} 是：
      C:\easySoft\SaasServer

    所以客户机器最终也是：
      C:\easySoft\SaasServer\app-server\server.exe
  -->

  <errTitle></errTitle>
  <!--
    启动失败时错误弹窗的标题。

    当前为空，表示使用 Launch4j 默认标题。

    可以设置成中文或英文，例如：
      柠檬树收银服务器启动失败

    但正式环境通常更依赖日志或后台排查。
  -->

  <cmdLine></cmdLine>
  <!--
    额外传给 Java main 方法的命令行参数。

    当前为空。

    如果填写：
      --spring.profiles.active=prod

    则相当于启动 Spring Boot 时附加这个参数。

    当前项目可能主要通过 application.yml 或外部配置决定 profile，
    所以这里没有写。
  -->

  <chdir>.</chdir>
  <!--
    Change directory，进程启动后的工作目录。

    . 表示当前目录。

    对 Launch4j 生成的 exe 来说，通常可以理解为：
      server.exe 所在目录

    安装后 server.exe 位于：
      C:\easySoft\SaasServer\app-server

    因此工作目录大致是：
      C:\easySoft\SaasServer\app-server

    这会影响相对路径。

    例如下面的：
      ..\libs\*.jar

    从 app-server 目录解析就是：
      C:\easySoft\SaasServer\libs\*.jar

    下面的：
      ../jdk-21.0.5

    从 app-server 目录解析就是：
      C:\easySoft\SaasServer\jdk-21.0.5

    所以 chdir 和 classpath/JDK 相对路径必须一起看。
  -->

  <priority>normal</priority>
  <!--
    Windows 进程优先级。

    normal 表示普通优先级。

    一般服务端程序保持 normal 即可。
    不建议随意改成 high，避免影响客户机器其他程序。
  -->

  <downloadUrl>http://java.com/download</downloadUrl>
  <!--
    当 Launch4j 找不到可用 Java 时，用于提示用户下载 Java 的地址。

    当前项目理论上不依赖这个地址，
    因为 jre/path 指向内置 JDK：
      ../jdk-21.0.5

    只有当内置 JDK 不存在、不可用，且系统也找不到 Java 时，
    这个地址才可能出现在提示里。

    这个地址偏旧，现代 JDK 21 更推荐 Adoptium/Temurin 等来源。
    但生产安装包如果内置 JDK 正常，它不会影响运行。
  -->

  <supportUrl></supportUrl>
  <!--
    支持页面 URL。

    当前为空。
    可用于错误提示中的帮助链接。
  -->

  <stayAlive>false</stayAlive>
  <!--
    是否让 Launch4j wrapper 在启动 Java 程序后继续常驻。

    false 表示不额外常驻守护。

    当前 server.exe 启动 Java 后，不由 Launch4j 额外维持一个守护 wrapper。
  -->

  <restartOnCrash>false</restartOnCrash>
  <!--
    Java 程序崩溃后是否自动重启。

    false 表示不自动重启。

    所以如果 Spring Boot 服务挂了，
    Launch4j 不会自动拉起。

    如果要做稳定守护，通常应该交给：
      Windows 服务
      监控程序
      外部守护脚本
      或专门的服务管理工具
  -->

  <manifest></manifest>
  <!--
    Windows manifest 文件路径。

    当前为空。

    manifest 可用于声明 UAC 权限、兼容性等。
    当前配置没有通过 Launch4j manifest 强制管理员权限。

    注意：
      Inno 安装包本身要求管理员权限，
      但这不等于 server.exe 每次运行都内置管理员 manifest。
  -->

  <icon>D:\easySoft\SaasServer\Icon\server.ico</icon>
  <!--
    exe 图标。

    Launch4j 生成 server.exe 时会把这个 ico 写进 exe 资源。

    注意：
      这是生成 exe 时读取的路径。
      不是运行 server.exe 时每次都读取这个 ico。

    如果这个图标路径在制壳机器上不存在，
    Launch4j 生成 exe 可能失败或没有预期图标。
  -->

  <classPath>
    <!--
      classPath 是当前配置的核心部分。

      因为 dontWrapJar=true，
      server.exe 不包含 jar。

      所以它必须通过 classPath 知道：
        1. 主类是谁
        2. 运行时要加载哪些 jar
    -->

    <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
    <!--
      Java 主类。

      这里不是你们自己的业务 Application 类，
      而是 Spring Boot 3 的 JarLauncher。

      Spring Boot 可执行 jar 内部结构通常是：
        BOOT-INF/classes/
        BOOT-INF/lib/
        org/springframework/boot/loader/...

      JarLauncher 的作用：
        1. 识别 Spring Boot jar 内部结构
        2. 加载 BOOT-INF/classes
        3. 加载 BOOT-INF/lib
        4. 再启动真正的 Spring Boot 应用

      Spring Boot 3 常用：
        org.springframework.boot.loader.launch.JarLauncher

      Spring Boot 2 老版本常见：
        org.springframework.boot.loader.JarLauncher

      当前项目使用 Java 21 / Spring Boot 3.x，
      所以这里用带 .launch. 的 JarLauncher 是合理的。
    -->

    <cp>..\libs\*.jar</cp>
    <!--
      业务 jar 路径。

      从 server.exe 所在目录 app-server 看：
        ..\libs\*.jar

      解析为：
        C:\easySoft\SaasServer\libs\*.jar

      setup.iss 中对应：
        Source: "libs/*"; DestDir: "{app}/libs";

      这些 jar 是 Jenkins/Maven 构建后放入 pos4install\libs 的产物。

      这也是“替换 jar 升级业务”的基础：
        只要 server.exe 的 classpath 不变，
        替换 libs 里的 jar 就能更新业务代码。
    -->

    <cp>..\jdk-21.0.5\ext\*.jar</cp>
    <!--
      额外扩展 jar 路径。

      从 app-server 看：
        ..\jdk-21.0.5\ext\*.jar

      解析为：
        C:\easySoft\SaasServer\jdk-21.0.5\ext\*.jar

      setup.iss 中对应：
        Source: "ext/*"; DestDir: "{app}/jdk-21.0.5/ext";

      这些通常是业务运行时额外需要但不一定打进主 jar 的依赖，
      例如特定 SDK、驱动、打印相关 jar、语音相关 jar 等。

      注意：
        Java 9 以后不再推荐传统 JRE ext 机制。
        这里的 ext 不是依赖 JDK 自动扫描 ext，
        而是 Launch4j 显式把这个目录加入 classpath。
    -->
  </classPath>

  <jre>
    <!--
      JRE/JDK 查找配置。

      这部分决定 server.exe 用哪个 Java 启动。
    -->

    <path>../jdk-21.0.5</path>
    <!--
      指定内置 JDK 路径。

      从 app-server 目录看：
        ../jdk-21.0.5

      解析为：
        C:\easySoft\SaasServer\jdk-21.0.5

      所以客户机器不需要全局安装 Java。
      Inno 安装包会把 JDK zip 放进去，再通过 unzip.bat 解压。

      setup.iss 中对应：
        Source: "jdk-21_windows-x64_bin.zip"; DestDir: "{app}";

      unzip.bat 解压后应得到：
        {app}\jdk-21.0.5

      如果这个目录不存在，server.exe 会找不到 Java。
    -->

    <requiresJdk>false</requiresJdk>
    <!--
      是否强制要求 JDK。

      false 表示不强制必须是完整 JDK，JRE 理论上也可。

      但当前实际路径是 jdk-21.0.5，
      所以运行时用的仍然是 JDK。

      如果程序只运行，不编译 Java 代码，通常不需要强制 requiresJdk=true。
    -->

    <requires64Bit>false</requires64Bit>
    <!--
      是否强制 64 位 Java。

      false 表示不强制。

      但你们安装包实际使用：
        jdk-21_windows-x64_bin.zip

      所以实际环境还是 64 位 JDK。

      如果要避免误用 32 位 Java，可以考虑改成 true。
      不过当前已经指定内置 JDK 路径，误用概率不高。
    -->

    <minVersion></minVersion>
    <!--
      最低 Java 版本。

      当前为空，表示不通过 Launch4j 限制最低版本。

      因为 path 已经指定 ../jdk-21.0.5，
      实际会优先使用内置 JDK 21。

      如果希望配置更明确，可以写：
        21
    -->

    <maxVersion></maxVersion>
    <!--
      最高 Java 版本。

      当前为空，表示不限制最高版本。
      一般不建议限制最高版本，除非确认新版本 Java 会导致兼容问题。
    -->
  </jre>
</launch4jConfig>
```

## 五、和 setup.iss 的对应关系

`server.xml` 只负责描述 `server.exe` 怎么启动 Java。

真正把文件放到客户机器上的，是 Inno 的 `setup.iss`。

关键对应关系如下。

### 1. server.exe 放到 app-server

`setup.iss`：

```text
Source: "app/app-server/*"; DestDir: "{app}/app-server/";
```

含义：

```text
pos4install\app\app-server\*
  -> C:\easySoft\SaasServer\app-server\
```

所以：

```text
server.exe
server.xml
config\application.yml
```

都会被放到：

```text
C:\easySoft\SaasServer\app-server\
```

### 2. 业务 jar 放到 libs

`setup.iss`：

```text
Source: "libs/*"; DestDir: "{app}/libs";
```

对应 `server.xml`：

```xml
<cp>..\libs\*.jar</cp>
```

最终路径：

```text
C:\easySoft\SaasServer\libs\*.jar
```

### 3. JDK 放到 jdk-21.0.5

`setup.iss`：

```text
Source: "jdk-21_windows-x64_bin.zip"; DestDir: "{app}";
```

安装后 `unzip.bat` 解压为：

```text
C:\easySoft\SaasServer\jdk-21.0.5
```

对应 `server.xml`：

```xml
<path>../jdk-21.0.5</path>
```

### 4. ext jar 放到 JDK ext 目录

`setup.iss`：

```text
Source: "ext/*"; DestDir: "{app}/jdk-21.0.5/ext";
```

对应 `server.xml`：

```xml
<cp>..\jdk-21.0.5\ext\*.jar</cp>
```

最终路径：

```text
C:\easySoft\SaasServer\jdk-21.0.5\ext\*.jar
```

## 六、启动时真实发生了什么

当安装后执行：

```text
C:\easySoft\SaasServer\app-server\server.exe
```

大致流程是：

```text
1. server.exe 启动
2. Launch4j wrapper 读取内置配置
3. 根据 <path>../jdk-21.0.5</path> 找到 Java
4. 因为 headerType=gui，通常使用 javaw.exe
5. 设置 classpath：
     ..\libs\*.jar
     ..\jdk-21.0.5\ext\*.jar
6. 调用主类：
     org.springframework.boot.loader.launch.JarLauncher
7. JarLauncher 加载 Spring Boot jar
8. Spring Boot 应用启动
9. 本地服务开始监听端口
```

可以抽象成：

```text
server.exe
  -> ../jdk-21.0.5/bin/javaw.exe
  -> classpath: ../libs/*.jar + ../jdk-21.0.5/ext/*.jar
  -> org.springframework.boot.loader.launch.JarLauncher
  -> Spring Boot 应用
```

## 七、为什么这种设计适合安装包升级

因为：

```xml
<dontWrapJar>true</dontWrapJar>
```

所以：

```text
server.exe 不包含业务 jar。
```

业务升级时，通常只要：

```text
停止 server.exe 对应进程
覆盖 libs/*.jar
重新启动 server.exe
```

不用每次重新生成：

```text
server.exe
```

这也是 `patch.iss` 这类升级包能工作的基础。

## 八、调试建议

### 1. 启动失败看不到日志

当前是：

```xml
<headerType>gui</headerType>
```

调试时可临时改成：

```xml
<headerType>console</headerType>
```

重新用 Launch4j 生成 `server.exe`，再启动，就能看到控制台日志。

### 2. 怀疑 classpath 错误

检查安装后是否存在：

```text
C:\easySoft\SaasServer\libs\*.jar
C:\easySoft\SaasServer\jdk-21.0.5\ext\*.jar
```

检查 `server.exe` 是否在：

```text
C:\easySoft\SaasServer\app-server\server.exe
```

因为 `..\libs\*.jar` 是从 `app-server` 往上找。

### 3. 怀疑 JDK 路径错误

检查：

```text
C:\easySoft\SaasServer\jdk-21.0.5\bin\java.exe
C:\easySoft\SaasServer\jdk-21.0.5\bin\javaw.exe
```

如果没有，说明 JDK 没解压成功，或者目录名和 XML 里的 `jdk-21.0.5` 不一致。

### 4. 使用 Launch4j debug

可以给 exe 加：

```text
--l4j-debug
```

例如：

```text
server.exe --l4j-debug
```

它会生成：

```text
launch4j.log
```

用于排查 Java 路径、classpath、启动参数等问题。

## 九、当前配置的风险点

### 1. gui 模式不利于排查

正式环境隐藏控制台是合理的，但调试时不方便。

建议保留一份调试版配置：

```xml
<headerType>console</headerType>
```

### 2. minVersion 为空

当前：

```xml
<minVersion></minVersion>
```

因为已经指定内置 JDK，所以影响不大。

但如果将来去掉内置 JDK，建议明确写：

```xml
<minVersion>21</minVersion>
```

### 3. requires64Bit 为 false

当前：

```xml
<requires64Bit>false</requires64Bit>
```

实际内置的是 x64 JDK，所以问题不大。

但如果希望更严格，可以考虑：

```xml
<requires64Bit>true</requires64Bit>
```

### 4. downloadUrl 偏旧

当前：

```xml
<downloadUrl>http://java.com/download</downloadUrl>
```

这更像 Java 8 时代的下载入口。

如果未来需要依赖下载提示，可以改成 JDK 21 来源，例如 Adoptium。

但在内置 JDK 正常的情况下，这个字段基本不会影响运行。

## 十、最终总结

当前 `server.xml` 的核心设计是：

```text
server.exe 固定
JDK 内置
业务 jar 外置
classpath 使用相对路径
Spring Boot 3 使用 JarLauncher 启动
Inno 负责把这些资源放到正确目录
```

这套设计最重要的好处是：

```text
安装包首次安装时能完整落地运行环境；
升级包可以主要通过替换 libs/*.jar 更新业务代码。
```
