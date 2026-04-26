﻿# Launch4j 完整使用过程说明

本文配套目录：

```text
D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序\安装模拟\launch4j-spring-demo
```

这个目录里放了一个完整 Spring Boot demo，用来演示如何通过 IntelliJ IDEA 构建 jar，再通过 Launch4j 图形界面生成 Windows exe。

说明：工具正确名称是 `Launch4j`。日常写成 `Lanch4j` 时，通常也是指这个工具。

## 一、Launch4j 是什么

Launch4j 是 Java 程序的 Windows exe 启动器生成工具。

它的作用是：

```text
读取 XML 配置
  -> 生成 Windows exe
  -> exe 启动指定 JRE/JDK
  -> exe 加载指定 jar 或 classpath
  -> exe 调用 Java main class
```

它不是 Java 编译器，也不是安装包工具。

```text
Maven / IDEA  -> 编译 Java 项目，生成 jar
Launch4j     -> 把 Java 启动方式包装成 Windows exe
Inno Setup   -> 把 exe、jar、JDK、MySQL、Redis 等资源打成最终安装包
```

## 二、Demo 项目结构

```text
launch4j-spring-demo/
  pom.xml
  src/main/java/com/example/launch4jdemo/
    Launch4jSpringDemoApplication.java
    DemoController.java
  src/main/resources/application.yml
  launch4j/
    wrap-jar.xml
    external-libs-server.xml
```

demo 启动后监听：

```text
http://localhost:18080/
http://localhost:18080/ping
```

## 三、安装 Launch4j

优先使用官方入口，不建议从第三方软件下载站下载。

```text
Launch4j 官网：
https://launch4j.sourceforge.net/

Launch4j 官方文档：
https://launch4j.sourceforge.net/docs.html

SourceForge 下载页：
https://sourceforge.net/projects/launch4j/files/launch4j-3/

Windows 版下载示例：
https://sourceforge.net/projects/launch4j/files/launch4j-3/3.50/launch4j-3.50-win32.exe/download
```

Windows 安装步骤：

```text
1. 打开 https://launch4j.sourceforge.net/
2. 点击 Download
3. 进入 SourceForge 后选择 launch4j-3/3.50/
4. 下载 launch4j-3.50-win32.exe
5. 双击安装
6. 建议安装到默认目录 C:\Program Files (x86)\Launch4j
```

安装后常见文件：

```text
C:\Program Files (x86)\Launch4j\launch4j.exe
C:\Program Files (x86)\Launch4j\launch4jc.exe
```

本文使用图形界面：

```text
launch4j.exe
```

`launch4jc.exe` 是命令行工具，适合 Jenkins 或批处理自动化；本文不使用它。

## 四、用 IDEA 构建 Spring Boot jar

### 1. 打开项目

打开 IntelliJ IDEA，选择：

```text
File
  -> Open
```

选择目录：

```text
D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序\安装模拟\launch4j-spring-demo
```

IDEA 会识别 `pom.xml`，自动作为 Maven 项目导入。

### 2. 配置 JDK

进入：

```text
File
  -> Project Structure
  -> Project
```

确认：

```text
SDK: JDK 21
Language level: 21
```

如果没有 JDK 21，需要先安装 JDK 21。

### 3. 等 Maven 下载依赖

IDEA 右下角如果显示 Maven 正在导入，等它完成。

也可以打开右侧：

```text
Maven
```

点击刷新按钮，让 IDEA 重新加载 `pom.xml`。

### 4. 运行测试

在 IDEA 右侧 Maven 面板：

```text
launch4j-spring-demo
  -> Lifecycle
    -> test
```

双击 `test`。

成功后，IDEA 控制台不应出现编译错误。

### 5. 打包 jar

在 IDEA 右侧 Maven 面板：

```text
launch4j-spring-demo
  -> Lifecycle
    -> clean
```

先双击 `clean`。

然后双击：

```text
package
```

打包成功后，确认生成：

```text
target\launch4j-spring-demo-1.0.0.jar
```

这是 Launch4j 后面要使用的 jar。

### 6. 在 IDEA 里先运行 Java 项目

打开：

```text
src/main/java/com/example/launch4jdemo/Launch4jSpringDemoApplication.java
```

点击 `main` 方法旁边的绿色运行按钮。

启动成功后访问：

```text
http://localhost:18080/ping
```

看到：

```json
{"status":"ok"}
```

说明 Java 项目本身没问题。

先保证 Java 项目能在 IDEA 里跑，再进入 Launch4j。否则 exe 出错时不好判断是 Java 项目问题，还是 Launch4j 配置问题。

## 五、方式一：Launch4j 把 jar 包进 exe

这是最适合学习的方式。

配置文件：

```text
launch4j\wrap-jar.xml
```

核心配置：

```xml
<dontWrapJar>false</dontWrapJar>
<headerType>console</headerType>
<jar>../target/launch4j-spring-demo-1.0.0.jar</jar>
<outfile>../target/launch4j-spring-demo.exe</outfile>
```

含义：

```text
dontWrapJar=false
  -> jar 会被包进 exe

headerType=console
  -> exe 启动时显示控制台，便于看 Spring Boot 日志

jar=../target/launch4j-spring-demo-1.0.0.jar
  -> IDEA 打包出来的 jar。这里写 ../target，是因为 XML 在 launch4j 目录下

outfile=../target/launch4j-spring-demo.exe
  -> Launch4j 要生成的 exe
```

### 图形界面操作步骤

1. 打开：

```text
C:\Program Files (x86)\Launch4j\launch4j.exe
```

2. 点击左上角文件夹图标，打开配置文件：

```text
D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序\安装模拟\launch4j-spring-demo\launch4j\wrap-jar.xml
```

3. 检查 `Basic` 页签：

```text
Output file:
../target/launch4j-spring-demo.exe

Jar:
../target/launch4j-spring-demo-1.0.0.jar

Don't wrap the jar:
不勾选

Header type:
Console
```

4. 检查 `JRE` 页签：

```text
Min JRE version:
21

64-bit:
勾选
```

5. 点击齿轮按钮：

```text
Build wrapper
```

6. 成功后看到输出文件：

```text
target\launch4j-spring-demo.exe
```

7. 双击 exe。

8. 浏览器访问：

```text
http://localhost:18080/ping
```

预期返回：

```json
{"status":"ok"}
```

如果点击 `Build wrapper` 出现：

```text
Application jar doesn't exist.
```

先检查两件事：

```text
1. IDEA 是否已经执行 Maven package，生成 target\launch4j-spring-demo-1.0.0.jar
2. Launch4j 的 Jar 字段是否是 ../target/launch4j-spring-demo-1.0.0.jar
```

原因是：当前 XML 文件放在 `launch4j` 目录下，Launch4j 打开 XML 后，通常会按 XML 所在目录解析相对路径。所以如果写成：

```text
target/launch4j-spring-demo-1.0.0.jar
```

它可能会去找：

```text
launch4j\target\launch4j-spring-demo-1.0.0.jar
```

但真实 jar 在：

```text
target\launch4j-spring-demo-1.0.0.jar
```

所以配置里要写：

```text
../target/launch4j-spring-demo-1.0.0.jar
```

## 六、方式二：Launch4j 生成外部 jar 启动壳

这是更接近你们 `pos4install` 的方式。

配置文件：

```text
launch4j\external-libs-server.xml
```

核心配置：

```xml
<dontWrapJar>true</dontWrapJar>
<outfile>../runtime/app-server/server.exe</outfile>
<classPath>
  <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
  <cp>..\libs\launch4j-spring-demo-1.0.0.jar</cp>
</classPath>
<jre>
  <path>../jdk-21.0.5</path>
</jre>
```

含义：

```text
dontWrapJar=true
  -> exe 不包含 jar，只做启动器

outfile=../runtime/app-server/server.exe
  -> 生成一个类似 pos4install/app-server/server.exe 的启动壳

cp=..\libs\launch4j-spring-demo-1.0.0.jar
  -> server.exe 运行时从相邻 libs 目录加载 jar

jre/path=../jdk-21.0.5
  -> server.exe 使用安装目录里的内置 JDK
```

### 手工准备运行目录

在项目根目录下手工创建：

```text
runtime/
  app-server/
  libs/
  jdk-21.0.5/
```

把 IDEA 打包生成的 jar 复制到：

```text
runtime\libs\launch4j-spring-demo-1.0.0.jar
```

把 JDK 21 复制或解压到：

```text
runtime\jdk-21.0.5
```

确保存在：

```text
runtime\jdk-21.0.5\bin\java.exe
```

### 图形界面操作步骤

1. 打开 `launch4j.exe`。

2. 打开配置文件：

```text
launch4j\external-libs-server.xml
```

3. 检查 `Basic` 页签：

```text
Output file:
../runtime/app-server/server.exe

Don't wrap the jar:
勾选
```

4. 检查 `Classpath` 页签：

```text
Main class:
org.springframework.boot.loader.launch.JarLauncher

Classpath:
..\libs\launch4j-spring-demo-1.0.0.jar
```

5. 检查 `JRE` 页签：

```text
Bundled JRE path:
../jdk-21.0.5

Min JRE version:
21
```

6. 点击齿轮按钮 `Build wrapper`。

7. 成功后生成：

```text
runtime\app-server\server.exe
```

8. 进入：

```text
runtime\app-server
```

9. 双击：

```text
server.exe
```

10. 浏览器访问：

```text
http://localhost:18080/ping
```

## 七、和 pos4install 的对应关系

你们当前配置类似：

```xml
<dontWrapJar>true</dontWrapJar>
<outfile>D:\easySoft\SaasServer\app-server\server.exe</outfile>
<classPath>
  <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
  <cp>..\libs\*.jar</cp>
  <cp>..\jdk-21.0.5\ext\*.jar</cp>
</classPath>
<jre>
  <path>../jdk-21.0.5</path>
</jre>
```

对应关系：

```text
server.exe
  -> Launch4j 生成的启动壳

..\libs\*.jar
  -> Jenkins/Maven 构建出来的业务 jar

..\jdk-21.0.5
  -> Inno 安装包解压出来的内置 JDK

org.springframework.boot.loader.launch.JarLauncher
  -> Spring Boot 3 可执行 jar 的启动入口
```

## 八、必须掌握的核心字段

### 1. `dontWrapJar`

```xml
<dontWrapJar>false</dontWrapJar>
```

jar 会被包进 exe。适合小 demo。

```xml
<dontWrapJar>true</dontWrapJar>
```

exe 不包含 jar，只做启动器。适合你们的安装包模式。

### 2. `headerType`

```xml
<headerType>console</headerType>
```

显示控制台，适合调试。

```xml
<headerType>gui</headerType>
```

不显示控制台，适合正式交付。调试阶段不建议一开始就用 `gui`，否则启动失败时像“没反应”。

### 3. `chdir`

```xml
<chdir>.</chdir>
```

影响相对路径从哪里开始算。

例如：

```text
runtime/
  app-server/
    server.exe
  libs/
    launch4j-spring-demo-1.0.0.jar
```

从 `runtime\app-server` 看：

```text
..\libs\launch4j-spring-demo-1.0.0.jar
```

才能找到 jar。

### 4. `classPath`

```xml
<classPath>
  <mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
  <cp>..\libs\launch4j-spring-demo-1.0.0.jar</cp>
</classPath>
```

外部 jar 启动壳模式的核心。

### 5. `jre/path`

```xml
<jre>
  <path>../jdk-21.0.5</path>
</jre>
```

表示使用相对路径里的内置 JDK。客户电脑可以不全局安装 Java。

## 九、Spring Boot 为什么用 JarLauncher

Spring Boot 可执行 jar 的内部结构比较特殊：

```text
BOOT-INF/classes/
BOOT-INF/lib/
org/springframework/boot/loader/...
```

`JarLauncher` 负责读取这个结构：

```text
加载 BOOT-INF/classes
加载 BOOT-INF/lib
再调用真正的 Spring Boot main
```

Spring Boot 3 常用：

```xml
<mainClass>org.springframework.boot.loader.launch.JarLauncher</mainClass>
```

Spring Boot 2 常见：

```xml
<mainClass>org.springframework.boot.loader.JarLauncher</mainClass>
```

## 十、Launch4j 和 Inno Setup 的边界

Launch4j 是制壳工具：

```text
XML + jar + JDK 路径
  -> server.exe
```

Inno Setup 是安装包工具：

```text
setup.iss + server.exe + jar + JDK zip + MySQL zip + Redis zip
  -> 最终客户安装程序
```

客户电脑不需要安装 Launch4j。客户只运行 Inno 生成的最终安装程序。

## 十一、常见问题

### 1. 双击 exe 没反应

把：

```xml
<headerType>gui</headerType>
```

改成：

```xml
<headerType>console</headerType>
```

重新用 Launch4j GUI 点击 `Build wrapper`，再运行 exe，看控制台错误。

### 2. 提示找不到 Java

检查内置 JDK：

```text
runtime\jdk-21.0.5\bin\java.exe
```

或者检查 Launch4j 的 JRE 页签：

```text
Bundled JRE path:
../jdk-21.0.5
```

### 3. 找不到 jar 或 class

检查：

```text
runtime\libs\launch4j-spring-demo-1.0.0.jar
```

以及 Launch4j 的 Classpath 页签：

```text
..\libs\launch4j-spring-demo-1.0.0.jar
```

### 4. 如何看 Launch4j 调试日志

运行 exe 时加参数：

```text
--l4j-debug
```

例如在 Windows 终端里进入 exe 所在目录后执行：

```text
server.exe --l4j-debug
```

会生成：

```text
launch4j.log
```

用于排查 JDK 路径、classpath、启动参数等问题。

## 十二、学习检查清单

能回答下面这些问题，才算真正理解这套机制：

```text
server.exe 里面有没有业务 jar？
客户电脑为什么不需要装 Launch4j？
客户电脑为什么可以不全局装 JDK？
只替换 libs/*.jar 为什么可以升级业务？
为什么 classpath 写 ..\libs\*.jar？
为什么 Spring Boot 3 用 JarLauncher？
console 和 gui 的区别是什么？
Inno 和 Launch4j 各自负责什么？
```
