# 安装程序 Java 组件安装与 Windows 服务机制说明

本文基于 `D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序` 目录下的说明文档，以及实际安装包工程 `D:\mywork\pos4install` 中的 Inno Setup 脚本、Launch4j 配置和 ActiveMQ 服务配置整理。

## 一、核心结论

当前安装程序里需要区分两类 Java 相关程序：

| 对象 | 是否注册为 Windows 服务 | 实现方式 |
| --- | --- | --- |
| POS 后端 `app-server\server.exe` | 否 | Launch4j 生成的 Java 启动壳，安装后直接运行 |
| 打印程序 `app-print-server\printer.exe` | 否 | Launch4j 生成的 Java 启动壳 |
| 监控程序 `app-monitor\monitor.exe` | 否 | Launch4j 生成的 Java 启动壳 |
| ActiveMQ | 是 | ActiveMQ 自带 `InstallService.bat` + Tanuki Java Service Wrapper |
| MySQL | 是 | `mysqld.exe --install NmsMysql` |
| Redis | 是 | `redis-server.exe --service-install ...` |

也就是说：

```text
POS 后端 server.exe 并没有被注册成 Windows 服务。
它只是一个 Launch4j Java 启动器。

当前真正作为 Windows 服务运行的 Java 组件是 ActiveMQ。
```

## 二、Java 运行环境如何安装

安装包没有要求客户电脑预先安装全局 Java，而是把 JDK 随安装包一起带进去。

`setup.iss` 中的关键配置：

```text
Source: "jdk-21_windows-x64_bin.zip"; DestDir: "{app}";
Source: "dll/*.dll"; DestDir: "{app}\jdk-21.0.5\bin";
Source: "dll/sqlite3.def"; DestDir: "{app}\jdk-21.0.5\bin";
Source: "dll/sqlite3.exe"; DestDir: "{app}\jdk-21.0.5\bin";
Source: "ext/*"; DestDir: "{app}/jdk-21.0.5/ext";
```

安装完成后，`[Run]` 段会执行：

```text
Filename: "{app}/unzip.bat"; Components: server
```

`unzip.bat` 中会解压 JDK：

```bat
.\unzip-5.51-1-bin\bin\unzip.exe jdk-21_windows-x64_bin.zip
```

最终形成的关键目录结构大致如下：

```text
C:\easySoft\SaasServer\
  jdk-21.0.5\
    bin\
      java.exe
      javaw.exe
      *.dll
    ext\
      *.jar
  libs\
    *.jar
  app-server\
    server.exe
    server.xml
    config\
      application.yml
```

因此，Java 组件使用的是安装目录中的内置 JDK：

```text
C:\easySoft\SaasServer\jdk-21.0.5
```

## 三、POS 后端 server.exe 如何启动 Java 程序

`app-server\server.exe` 是 Launch4j 生成的 Windows 启动壳。

对应配置文件是：

```text
D:\mywork\pos4install\app\app-server\server.xml
```

核心配置：

```xml
<launch4jConfig>
  <dontWrapJar>true</dontWrapJar>
  <headerType>gui</headerType>
  <jar></jar>
  <outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
  <chdir>.</chdir>
  <stayAlive>false</stayAlive>
  <restartOnCrash>false</restartOnCrash>

  <classPath>
    <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
    <cp>..\libs\*.jar</cp>
    <cp>..\jdk-21.0.5\ext\*.jar</cp>
  </classPath>

  <jre>
    <path>../jdk-21.0.5</path>
    <requiresJdk>false</requiresJdk>
  </jre>
</launch4jConfig>
```

关键点：

1. `<dontWrapJar>true</dontWrapJar>` 表示 `server.exe` 不包含业务 jar。
2. 业务代码来自 `..\libs\*.jar`。
3. 扩展依赖来自 `..\jdk-21.0.5\ext\*.jar`。
4. Java 运行环境来自 `../jdk-21.0.5`。
5. `<headerType>gui</headerType>` 表示通常使用 `javaw.exe` 启动，不弹控制台窗口。
6. `<stayAlive>false</stayAlive>` 和 `<restartOnCrash>false</restartOnCrash>` 表示 Launch4j 不负责守护进程，也不负责崩溃自动重启。

启动链路可以理解为：

```text
用户或安装脚本启动 server.exe
  ->
Launch4j 启动壳运行
  ->
根据 ../jdk-21.0.5 找到内置 JDK
  ->
调用 javaw.exe
  ->
设置 classpath:
  - ../libs/*.jar
  - ../jdk-21.0.5/ext/*.jar
  ->
调用 org.springframework.boot.loader.launch.JarLauncher
  ->
Spring Boot 应用启动
  ->
读取 app-server/config/application.yml
```

安装脚本中只是直接运行后端程序：

```text
Filename: "{app}\app-server\server.exe"; Components: server
```

这里没有看到 `sc create`、`winsw`、`nssm`、`InstallUtil` 或类似命令。因此，从当前脚本证据看，`server.exe` 没有被注册成 Windows 服务。

## 四、打印程序和监控程序也是 Launch4j 启动壳

打印程序配置：

```text
D:\mywork\pos4install\app\app-print-server\printer.xml
```

核心逻辑：

```xml
<mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
<cp>..\printerlibs\*.jar</cp>
<cp>..\jdk-21.0.5\ext\*.jar</cp>
<path>../jdk-21.0.5</path>
```

监控程序配置：

```text
D:\mywork\pos4install\app\app-monitor\monitor.xml
```

核心逻辑：

```xml
<mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
<cp>libs/*.jar</cp>
<path>../jdk-21.0.5</path>
```

它们和 `server.exe` 类似，都是通过 Launch4j 找到内置 JDK，然后启动对应 jar。当前安装脚本也没有把它们注册为 Windows 服务。

## 五、ActiveMQ 如何注册为 Windows 服务

ActiveMQ 是当前安装包中明确作为 Windows 服务运行的 Java 组件。

安装包先把 ActiveMQ 相关文件放入安装目录：

```text
Source: "apache-activemq-6.1.3-bin.zip"; DestDir: "{app}";
Source: "activemq.xml"; DestDir: "{app}/";
Source: "activemq.bat"; DestDir: "{app}/";
Source: "wrapper.conf"; DestDir: "{app}/";
```

`unzip.bat` 解压 ActiveMQ，并覆盖配置：

```bat
.\unzip-5.51-1-bin\bin\unzip.exe apache-activemq-6.1.3-bin.zip

xcopy /Y "activemq.xml" ".\apache-activemq-6.1.3\conf\"
xcopy /Y "activemq.bat" ".\apache-activemq-6.1.3\bin\"
xcopy /Y "wrapper.conf" ".\apache-activemq-6.1.3\bin\win64\"
```

然后 `setup.iss` 注册并启动 ActiveMQ 服务：

```text
Filename: "{app}/apache-activemq-6.1.3/bin/win64/InstallService.bat"; Parameters: "auto"; Components: server
Filename: net.exe; Parameters: "start ActiveMQ"; Components: server
```

ActiveMQ 自带的 `InstallService.bat` 会调用 Java Service Wrapper：

```bat
wrapper.exe -i "%ACTIVEMQ_HOME%\bin\win64\wrapper.conf" ...
```

`wrapper.conf` 决定服务运行时如何启动 Java：

```properties
wrapper.java.command=C:/easySoft/SaasServer/jdk-21.0.5/bin/java.exe
wrapper.java.mainclass=org.tanukisoftware.wrapper.WrapperSimpleApp
wrapper.java.classpath.1=%ACTIVEMQ_HOME%/bin/wrapper.jar
wrapper.java.classpath.2=%ACTIVEMQ_HOME%/bin/activemq.jar
wrapper.app.parameter.1=org.apache.activemq.console.Main
wrapper.app.parameter.2=start
```

服务属性也在 `wrapper.conf` 中定义：

```properties
wrapper.ntservice.name=ActiveMQ
wrapper.ntservice.displayname=ActiveMQ
wrapper.ntservice.description=ActiveMQ Broker
wrapper.ntservice.starttype=AUTO_START
wrapper.ntservice.interactive=false
```

所以 ActiveMQ 的服务启动链路是：

```text
setup.iss
  ->
InstallService.bat auto
  ->
wrapper.exe -i wrapper.conf
  ->
注册 Windows 服务 ActiveMQ
  ->
net start ActiveMQ
  ->
wrapper.exe 按 wrapper.conf 启动 Java
  ->
C:/easySoft/SaasServer/jdk-21.0.5/bin/java.exe
  ->
org.tanukisoftware.wrapper.WrapperSimpleApp
  ->
org.apache.activemq.console.Main start
```

卸载时，安装脚本会停止并移除 ActiveMQ 服务：

```text
Filename: net.exe; Parameters: "stop ActiveMQ"; Components: server
Filename: "{app}/apache-activemq-6.1.3/bin/win64/UninstallService.bat"; Components: server
```

`UninstallService.bat` 对应执行：

```bat
wrapper.exe -r "%ACTIVEMQ_HOME%\bin\win64\wrapper.conf"
```

## 六、MySQL 和 Redis 的服务注册

这两个也会注册为 Windows 服务，但它们不是 Java 程序。

MySQL：

```text
Filename: "{app}/mysql-8.0.28-winx64/bin/mysqld.exe"; Parameters: "--install NmsMysql"; Components: server
Filename: net.exe; Parameters: "start NmsMysql"; Components: server
```

Redis：

```text
Filename: "{app}/Redis-x64-5.0.14.1/redis-server.exe"; Parameters: "--service-install redis.windows.conf --loglevel verbose"; Components: server
Filename: net.exe; Parameters: "start redis"; Components: server
```

卸载时：

```text
Filename: net.exe; Parameters: "stop NmsMysql"; Components: server
Filename: "{app}/mysql-8.0.28-winx64/bin/mysqld.exe"; Parameters: "--remove NmsMysql"; Components: server

Filename: net.exe; Parameters: "stop redis"; Components: server
Filename: "{app}/Redis-x64-5.0.14.1/redis-server.exe"; Parameters: "--service-uninstall"; Components: server
```

## 七、整体安装流程

以服务器组件为例，安装流程可以抽象为：

```text
1. Inno Setup 复制安装资源到 {app}
   - jdk-21_windows-x64_bin.zip
   - apache-activemq-6.1.3-bin.zip
   - mysql-8.0.28-winx64.zip
   - Redis-x64-5.0.14.1.zip
   - libs/*.jar
   - ext/*.jar
   - app/app-server/*

2. 执行 unzip.bat
   - 解压 JDK
   - 解压 ActiveMQ
   - 解压 MySQL
   - 解压 Redis
   - 解压 VisualVM
   - 覆盖 ActiveMQ 配置

3. 注册并启动基础服务
   - MySQL -> NmsMysql
   - Redis -> redis
   - ActiveMQ -> ActiveMQ

4. 直接启动 POS 后端
   - {app}\app-server\server.exe

5. 如果安装客户端或自助点餐组件
   - 启动 printer.exe
   - 启动 client.exe 或 client_gzjj.exe
```

## 八、结论边界

从当前文档和 `D:\mywork\pos4install` 的脚本证据看：

1. Java 运行环境通过安装包内置 JDK 解决。
2. POS 后端、打印、监控程序通过 Launch4j 启动，不依赖系统 Java 环境变量。
3. POS 后端 `server.exe` 不是 Windows 服务。
4. ActiveMQ 是 Java 组件，并通过 Java Service Wrapper 注册成 Windows 服务。
5. MySQL 和 Redis 也注册为 Windows 服务，但它们不是 Java 程序。

如果后续希望把 POS 后端也改造成真正的 Windows 服务，需要额外引入服务包装方式，例如：

```text
WinSW
NSSM
sc create + 自定义服务程序
Tanuki Java Service Wrapper
Spring Boot Windows service wrapper
```

当前安装脚本中没有看到这些机制用于 `server.exe`。
