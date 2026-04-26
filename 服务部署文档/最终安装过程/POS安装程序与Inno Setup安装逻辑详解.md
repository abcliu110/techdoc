# POS安装程序与 Inno Setup 安装逻辑详解

## 1. 文档目的

这份文档面向不熟悉 Inno Setup 的同事，目的不是讲 Inno 的全部语法，而是把当前这套 POS 安装包的真实生成链路、安装包内部结构、安装时实际发生的动作讲清楚。

当前这套安装程序不是“把一个 exe 直接打出来”这么简单，而是下面这条完整链路：

1. Jenkins 在 K8s 中构建后端模块。
2. Jenkins 将构建产物上传到 Ubuntu 中转目录。
3. Windows 机器从 Ubuntu 把需要的 jar 拉回本地。
4. Windows 侧执行 `pos4install` 仓库中的 `build.bat`。
5. `build.bat` 调用 Inno Setup，将静态资源和最新 jar 一起编译成安装包。

对应目录和脚本主要有两处：

- 安装包数据与脚本仓库：`D:\mywork\pos4install`
- 构建方案文档目录：`D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序`

---

## 2. 什么是 Inno Setup

`Inno Setup` 是一个 Windows 安装包制作工具。它的核心思路是：

- 你先写一个 `.iss` 脚本。
- 脚本里定义安装包名称、安装目录、需要打进去的文件、安装完成后要执行的命令、卸载时要执行的命令。
- 再用 Inno 的编译器把脚本和资源编译成一个安装程序。

在这套工程里，编译命令是：

```bat
"C:\Program Files (x86)\Inno Setup 5\Compil32.exe" /cc ".\setup.iss"
```

其中：

- `Compil32.exe` 是 Inno Setup 5 的编译器。
- `/cc` 表示命令行编译指定脚本。
- `setup.iss`、`patch.iss`、`setupGzjj.iss` 这些文件就是安装定义。

可以把 Inno Setup 简单理解成：

- `.iss` 是安装包的“源代码”。
- `Compil32.exe` 是编译器。
- 编出来的 `dist\xxx.exe` 是最终交付给客户执行的安装程序。

---

## 3. Inno 脚本最常见的几个段

当前项目里最关键的 Inno 段如下。

### 3.1 `#define`

这是编译期常量，类似宏定义。比如：

- 产品名称
- 版本号
- 发布者
- 输出安装包文件名
- 图标目录

例如标准包里会定义：

- `AppName`
- `AppVersion`
- `ApplicationVersion`

其中 `ApplicationVersion` 使用当前时间生成，所以最终生成的安装包文件名会带时间戳。

### 3.2 `[Setup]`

这是安装包的全局配置，决定安装包整体行为。比如：

- 安装到哪里
- 是否必须管理员权限
- 输出目录在哪
- 压缩方式是什么
- 图标是什么

这套工程里最重要的几项是：

- 安装目录固定为 `C:\easySoft\SaasServer`
- `PrivilegesRequired=admin`，说明必须管理员权限运行
- 安装包输出到 `dist\`

### 3.3 `[Types]` 和 `[Components]`

这两个段用来定义安装角色。

当前主安装包中定义了三种类型：

- `server`：本机是主机
- `client`：本机是副机
- `selforder`：本机用于自助点餐

后续 `[Files]`、`[Run]` 中很多动作都会加 `Components:`，表示这个文件或命令只在特定安装类型下生效。

### 3.4 `[Files]`

这个段定义“把哪些文件打进安装包，以及安装时复制到哪里”。

要注意一个关键点：

- `[Files]` 只负责把文件复制到磁盘。
- `[Files]` 不负责启动服务，也不负责解压 zip 内部文件。

所以这套脚本虽然把很多 zip 放进安装目录，但真正解压和初始化动作是在后面的 `[Run]` 和脚本里完成的。

### 3.5 `[Code]`

这是 Inno 的脚本代码区，语言是 PascalScript。

这里可以写：

- 安装前检查
- 注册表判断
- 安装向导过程中的自定义逻辑
- 自定义执行命令
- 杀进程、读文件、判断路径等操作

当前项目里比较重要的逻辑有：

- 检查是否已安装 VC++ 运行库
- 加载安装界面皮肤
- 升级包安装前按 pid 杀掉服务进程
- 判断是否需要启动客户端安装器

### 3.6 `[Run]`

这个段表示“文件复制完成以后继续执行哪些命令”。

你可以把它理解成安装后的自动化步骤。

这套工程里真正重要的安装行为都在 `[Run]`：

- 调用 `unzip.bat`
- 安装 MySQL Windows 服务
- 启动 MySQL
- 安装 Redis Windows 服务
- 启动 Redis
- 安装 ActiveMQ Windows 服务
- 启动 ActiveMQ
- 启动综合服务器 `server.exe`
- 启动打印服务 `printer.exe`
- 必要时启动客户端安装器

### 3.7 `[UninstallRun]` 和 `[UninstallDelete]`

这两个段负责卸载时的动作。

- `[UninstallRun]`：执行停服务、反注册服务等命令
- `[UninstallDelete]`：删除安装时解压出来的目录

所以这套安装程序不仅能装，也内置了卸载时的清理逻辑。

---

## 4. 当前项目中的打包总链路

### 4.1 老方式和新方式的区别

你最开始给出的老脚本是本地直接 `xcopy`：

- 从本地 Maven 构建结果目录拷 jar
- 填充 `libs\`
- 填充 `printerlibs\`
- 填充 `libs6\`
- 最后执行 Inno 编译

现在这套新方案已经改成：

1. Jenkins 在 K8s 中构建 Java 模块。
2. Jenkins 把构建产物传到 Ubuntu。
3. Windows 本地再用 `scp` 从 Ubuntu 拉包。
4. 本地的 Inno Setup 只负责最终组装安装包。

也就是说，Windows 现在不再承担 Java 编译，只承担“拿产物 + 组装安装包”。

### 4.2 Jenkins 到 Ubuntu 的产物目录

根据后端方案文档，Ubuntu 中转根目录是：

```text
/data/backend-build-output/01-nms4pos-java
```

文档中已把老脚本目录和 Ubuntu 路径做了映射：

- `libs/` 对应 `nms4cloud-pos3boot` 相关产物
- `printerlibs/` 对应 `nms4cloud-pos10printer` 相关产物
- `libs6/` 对应 `nms4cloud-pos6monitor` 相关产物

### 4.3 Windows 侧 `build.bat` 的作用

当前实际执行的组装脚本是：

`D:\mywork\pos4install\build.bat`

它的流程非常清晰：

1. 清空本地旧目录：
   - `libs\`
   - `printerlibs\`
   - `libs6\`
   - `dist\`
2. 重新创建这些目录。
3. 使用 `scp` 从 Ubuntu 拉取最新 jar。
4. 调用 Inno Setup 编译安装包。

当前 `build.bat` 会编译以下安装脚本：

- `setup.iss`
- `patch.iss`
- `setupGzjj.iss`
- `patchGzjj.iss`
- `setupSenHai.iss`

注意：

- 仓库中虽然还有 `setupYJX.iss`
- 但它当前没有出现在 `build.bat` 的编译命令里
- 所以它不是当前这条流水线正在产出的安装包之一

---

## 5. `pos4install` 仓库里的资源到底分几类

`D:\mywork\pos4install` 不是单纯的脚本仓库，而是“安装包装配仓库”。里面混合了多类资源。

### 5.1 运行时大件资源

这些资源会被打进主安装包，并在安装时解压或安装：

- `jdk-21_windows-x64_bin.zip`
- `mysql-8.0.28-winx64.zip`
- `mysql_data.zip`
- `Redis-x64-5.0.14.1.zip`
- `apache-activemq-6.1.3-bin.zip`
- `visualvm_2110.zip`
- `vc_redist.x64.exe`

### 5.2 Java 业务产物

这些目录在打包前由 `build.bat` 先准备好：

- `libs\`
- `printerlibs\`
- `libs6\`

它们分别喂给综合服务、打印服务、监控程序。

### 5.3 安装时辅助脚本和配置

例如：

- `unzip.bat`
- `unzip_client.bat`
- `activemq.bat`
- `activemq.xml`
- `wrapper.conf`
- `my.ini`
- `my_d.ini`
- `visualvm.conf`

### 5.4 Windows 外壳和图标资源

例如：

- `client.exe`
- `client_gzjj.exe`
- `app\app-server\server.exe`
- `app\app-print-server\printer.exe`
- `app\app-monitor\monitor.exe`
- `Icon\*.ico`

### 5.5 Launch4j 配置

例如：

- `app\app-server\server.xml`
- `app\app-print-server\printer.xml`
- `app\app-monitor\monitor.xml`

这些 xml 不是 Inno 的脚本，而是 Java 包装为 Windows exe 时使用的 Launch4j 配置。

---

## 6. 主安装包 `setup*.iss` 的职责

主安装包的核心职责是：

- 首次完整安装环境
- 安装并启动基础服务
- 落地业务程序
- 在需要时启动客户端安装器

它不是简单覆盖文件，而是完整建环境。

### 6.1 主安装包包含哪些脚本

当前主安装包包括：

- `setup.iss`：标准版
- `setupGzjj.iss`：广州酒家版
- `setupSenHai.iss`：森海版

它们的总体结构相同，差异主要在品牌、图标、客户端 exe 和 Spring profile。

### 6.2 安装目录和权限

主安装包统一把程序装到：

```text
C:\easySoft\SaasServer
```

并要求管理员权限运行，因为后面需要：

- 安装 Windows 服务
- 写注册表
- 启动系统级服务

### 6.3 主安装包把哪些内容复制进去

以 `setup.iss` 为例，主安装包会把以下内容打进去：

- 客户端安装器 `client.exe`
- 解压工具 `unzip-5.51-1-bin`
- JDK 21 zip
- VisualVM zip 和配置
- Redis zip
- ActiveMQ zip 和配置
- MySQL zip、MySQL 数据 zip、MySQL 配置
- 业务 jar 到 `libs\`
- 打印 jar 到 `printerlibs\`
- 监控 jar 到 `app-monitor\libs\`
- JDK 扩展 jar 到 `jdk-21.0.5\ext`
- `server.exe`、`printer.exe`、`monitor.exe`

### 6.4 主安装包为什么先放 zip，再运行脚本解压

这套安装包没有把 JDK、MySQL、Redis、ActiveMQ 的目录树直接展开后整体放进 `[Files]`。

它采用的是另一种方式：

1. 先把 zip 文件复制到安装目录。
2. 安装完成后运行 `unzip.bat`。
3. 由 `unzip.bat` 负责解压和二次覆盖配置。

这么做的好处通常是：

- 安装脚本更简单
- 上游更新大件资源时更容易替换
- 某些配置可以在解压后统一覆盖

### 6.5 `unzip.bat` 实际做了什么

`unzip.bat` 是主安装包里非常关键的一步。

它会依次解压：

- `mysql_data.zip`
- `jdk-21_windows-x64_bin.zip`
- `apache-activemq-6.1.3-bin.zip`
- `mysql-8.0.28-winx64.zip`
- `Redis-x64-5.0.14.1.zip`
- `visualvm_2110.zip`

然后继续做二次初始化：

- 如果有 D 盘，把 `mysql_data` 复制到 `D:\nms\mysql_data\`
- 否则复制到 `C:\nms\mysql_data\`
- 如果有 D 盘，使用 `my_d.ini`
- 否则使用 `my.ini`
- 将 `visualvm.conf` 覆盖到 VisualVM 目录
- 将 `activemq.xml` 覆盖到 ActiveMQ `conf\`
- 将 `activemq.bat` 覆盖到 ActiveMQ `bin\`
- 将 `wrapper.conf` 覆盖到 ActiveMQ `bin\win64\`

最后还会删除安装过程中临时用到的 zip 和配置文件。

换句话说：

- `[Files]` 把原料送进去
- `unzip.bat` 把原料加工成真正可运行环境

### 6.6 主安装包安装后会启动哪些服务

在 `[Run]` 中，主安装包会执行以下关键动作：

1. 运行 `unzip.bat`
2. 如果是客户端或自助点餐机，运行 `unzip_client.bat`
3. 自助点餐模式下创建 `forSelfOrder` 标识文件
4. 安装 MySQL 服务：`NmsMysql`
5. 启动 MySQL 服务
6. 安装 Redis 服务
7. 启动 Redis 服务
8. 安装 ActiveMQ 服务
9. 启动 ActiveMQ 服务
10. 启动综合服务 `server.exe`
11. 启动打印服务 `printer.exe`
12. 必要时启动客户端安装器

所以主安装包的本质不是“把程序拷进去”，而是：

- 建 Java 环境
- 建数据库环境
- 建缓存环境
- 建消息队列环境
- 启动业务程序

### 6.7 主安装包中的客户端安装逻辑

脚本里有一个 `IsClientNotExists` 判断：

- 它检查 `C:\easySoft\SaasClient\snapshot_blob.bin` 是否存在
- 如果不存在，才执行 `client.exe` 或 `client_gzjj.exe`

这说明：

- `client.exe` 很可能是另一个独立客户端安装器
- 主安装包只是按条件触发它
- 不是每次都强制重装客户端

从当前仓库证据看，`snapshot_blob.bin` 很像桌面客户端运行产物，但无法仅凭这一点百分之百确认它的底层技术。

### 6.8 主安装包的卸载动作

卸载时主安装包会：

1. `net stop NmsMysql`
2. `mysqld.exe --remove NmsMysql`
3. `net stop redis`
4. Redis 服务卸载
5. `net stop ActiveMQ`
6. ActiveMQ 服务卸载
7. 删除解压出来的目录：
   - `jdk-21.0.5`
   - `visualvm_2110`
   - `Redis-x64-5.0.14.1`
   - `apache-activemq-6.1.3`
   - `mysql-8.0.28-winx64`
   - `unzip-5.51-1-bin`

因此这套安装包有完整的装和卸的闭环。

---

## 7. 升级包 `patch*.iss` 的职责

升级包和主安装包不是同一种东西。

主安装包负责：

- 首次完整建环境
- 安装服务
- 启动整套程序

升级包负责：

- 覆盖核心业务 jar
- 停掉正在运行的程序
- 覆盖完成后重新拉起程序

### 7.1 当前升级包脚本

当前升级包包括：

- `patch.iss`
- `patchGzjj.iss`

### 7.2 升级包复制哪些内容

升级包主要复制：

- `libs\*`
- `printerlibs\*`
- `libs6\*`
- 少量 `ext\` 中的 jar
- 少量 `dll\` 中的文件

这说明它的目标是：

- 更新 Java 业务代码
- 补少量运行依赖
- 不重装 JDK、MySQL、Redis、ActiveMQ

### 7.3 升级包为什么要在安装前杀进程

升级包的 `[Code]` 中实现了 `NextButtonClick` 逻辑。

当安装向导进入指定步骤时，它会：

- 读取 `{app}\app-server\pid`
- 读取 `{app}\app-print-server\pid`
- 读取 `{app}\app-monitor\pid`
- 用 `taskkill /F /PID` 强制结束对应进程

这样做的目的很直接：

- 程序正在运行时，jar 文件可能被占用
- 不先停进程，覆盖文件容易失败

### 7.4 升级包安装后会重启什么

升级包的 `[Run]` 里只做两件事：

- 启动 `server.exe`
- 启动 `printer.exe`

从当前脚本看，它没有显式重启 `monitor.exe`。

这是一条需要特别注意的现状，不一定是 bug，但至少说明：

- `monitor` 被杀掉后是否会自动恢复
- 不能从当前 `patch.iss` 直接看出

### 7.5 为什么升级包不负责基础环境

因为升级包假设：

- 目标机器已经安装过主程序
- 安装目录已存在
- JDK 已存在
- MySQL、Redis、ActiveMQ 已存在
- 程序运行框架已就绪

所以升级包只是“增量覆盖”，不是“重新建环境”。

---

## 8. `server.exe`、`printer.exe`、`monitor.exe` 到底是什么

这是理解整套安装逻辑时最容易误解的地方。

很多人会以为：

- `server.exe` 是业务服务器本体
- `printer.exe` 是打印程序本体

其实从仓库证据看，它们更准确的身份是：

- Java 程序的 Windows 启动包装器

### 8.1 Launch4j 在这里扮演什么角色

仓库里有这些文件：

- `app\app-server\server.xml`
- `app\app-print-server\printer.xml`
- `app\app-monitor\monitor.xml`

它们都是 `launch4jConfig`。

Launch4j 的作用是：

- 把 Java 程序包装成 Windows 可双击的 exe
- 指定内置 JRE/JDK 路径
- 指定类路径
- 指定主类

### 8.2 `server.exe` 的运行方式

`server.xml` 中最关键的信息是：

- 主类：`org.springframework.boot.loader.launch.JarLauncher`
- 类路径：`..\libs\*.jar`
- 类路径：`..\jdk-21.0.5\ext\*.jar`
- JRE 路径：`../jdk-21.0.5`

这说明 `server.exe` 并不是把业务代码编译成一个 C++ 程序，而是：

1. 启动内置 JDK
2. 加载 `libs\` 下的业务 jar
3. 通过 Spring Boot 的 `JarLauncher` 启动应用

### 8.3 `printer.exe` 的运行方式

`printer.xml` 同理：

- 主类也是 `JarLauncher`
- 业务 jar 目录换成了 `..\printerlibs\*.jar`
- 仍然依赖内置 JDK 和 `ext\` 依赖

所以打印服务和综合服务本质上都是 Java 程序，只是依赖的 jar 集合不同。

### 8.4 `monitor.exe` 的运行方式

`monitor.xml` 更简单：

- 主类也是 `JarLauncher`
- 它读取 `libs\*.jar`
- 使用同一套内置 JDK

这里的 `libs` 是 `app-monitor` 自己目录下的 `libs`，也就是安装时由 `libs6\*` 复制进去的监控程序 jar。

### 8.5 为什么这样设计

这种设计的优点通常有：

- 客户端机器不需要单独安装 Java
- 用户只看到 exe，使用体验更像原生 Windows 程序
- 上层安装程序只要替换 jar 即可升级业务代码

所以这套体系实际上是：

- Inno Setup：负责安装和系统级动作
- Launch4j：负责把 Java 应用包装成 Windows exe
- Spring Boot jar：负责真正业务逻辑

---

## 9. 标准版、广州酒家版、森海版之间的差异

这些脚本不是不同技术路线，而是同一技术框架下的不同客户变体。

### 9.1 标准版 `setup.iss`

标准版使用：

- `client.exe`
- `config\application.yml`
- `Icon\setup.ico`

服务端 profile 默认是：

- `prod`

### 9.2 广州酒家版 `setupGzjj.iss`

广州酒家版主要差异有：

- 客户端安装器改为 `client_gzjj.exe`
- 安装图标改为 `gzjjServer.ico`
- 用 `application-gzjj.yml` 覆盖为 `application.yml`
- 用 `trayGzjj.png` 覆盖托盘图标
- 发布者、网址、产品名都改成广州酒家对应信息

服务端 profile 变为：

- `gzjj`

### 9.3 森海版 `setupSenHai.iss`

森海版差异相对少，核心是：

- 用 `application-senhai.yml` 覆盖为 `application.yml`

服务端 profile 变为：

- `senhai`

### 9.4 升级包也有客户变体

升级包中目前有：

- 标准版 `patch.iss`
- 广州酒家版 `patchGzjj.iss`

它们结构基本一致，主要差异还是产品名、图标、品牌信息。

---

## 10. 安装流程按时间顺序还原

如果从用户双击主安装包开始，整套动作可以按时间顺序理解为：

1. 安装包启动。
2. Inno 检查是否需要先安装 VC++ 运行库。
3. Inno 加载安装界面皮肤。
4. 用户选择安装类型：主机、副机、自助点餐。
5. Inno 把定义在 `[Files]` 中的文件复制到目标目录。
6. 如果是主机，运行 `unzip.bat` 解压 JDK、MySQL、Redis、ActiveMQ、VisualVM 等。
7. 如果是客户端或自助点餐机，运行 `unzip_client.bat` 解压客户端所需的 JDK。
8. 自助点餐模式下创建 `forSelfOrder` 标识文件。
9. 如果是主机，安装并启动 `NmsMysql`、Redis、ActiveMQ。
10. 启动 `server.exe`。
11. 如有需要，启动 `printer.exe`。
12. 如果检测到本机尚未安装 `SaasClient`，再启动客户端安装器。

如果是升级包，顺序则是：

1. 升级包启动。
2. Inno 加载安装界面皮肤。
3. 进入指定步骤时，读取 pid 文件。
4. 先杀掉 `server`、`printer`、`monitor` 进程。
5. 覆盖新的 jar 和依赖。
6. 重启 `server.exe`。
7. 重启 `printer.exe`。

这样看就很清楚了：

- 主安装包像“全量部署脚本”
- 升级包像“增量热更新安装器”

---

## 11. 当前已确认的注意事项和风险点

下面这些点不是推测，而是阅读当前仓库后应当明确知道的现状。

### 11.1 `verinfo.ini` 当前仓库中缺失

多个安装脚本都引用了：

```text
Source: "verinfo.ini"
```

但当前 `D:\mywork\pos4install` 仓库根目录里没有这个文件。

这意味着至少有三种可能：

1. 它在正式打包前由别的流程生成。
2. 它在本机环境的别处补入。
3. 当前仓库状态并不是可直接无缺失编译的完整状态。

如果没有补齐这个文件，Inno 编译时会缺输入。

### 11.2 `patch.iss` 会杀掉 `monitor`，但没有显式重启

升级包会读取并杀掉：

- `app-server\pid`
- `app-print-server\pid`
- `app-monitor\pid`

但安装后只重启：

- `server.exe`
- `printer.exe`

没有看到明确重启 `monitor.exe` 的动作。

因此升级后监控程序是否恢复，需要另外确认。

### 11.3 `setupYJX.iss` 当前不是流水线产物

仓库中存在 `setupYJX.iss`，但：

- 当前 `build.bat` 没有编译它
- 所以它不属于当前标准输出物

这通常意味着：

- 它是历史脚本
- 或备用客户脚本
- 或尚未接入当前流水线

### 11.4 `DeinitializeSetup` 中有一些疑似遗留清理逻辑

主安装脚本的 `DeinitializeSetup` 中会尝试删除：

- `{app}\config`
- `{app}\dist`
- `{app}\dll`
- `{app}\Icon`
- `{app}\lanch4j`
- `{app}\mysql_data`
- `{app}\ext`
- `{app}\app`

但从当前 `[Files]` 的复制目标看，其中部分目录未必会真实出现在 `{app}` 根下。

因此这里至少有一部分逻辑可能是旧版结构遗留下来的清理代码。

这一点不影响理解主流程，但说明脚本里存在历史演进痕迹。

---

## 12. 用一句话总结整套安装逻辑

如果把整套系统压缩成一句话，可以这样理解：

> Jenkins 先把 Java 模块编译好并放到 Ubuntu，Windows 再把这些 jar 拉回 `pos4install`，最后由 Inno Setup 把“基础运行环境 + 业务 jar + Java 启动包装器 + 初始化脚本”编译成主安装包和升级包；主安装包负责首次完整建环境，升级包负责按 pid 停进程并覆盖 jar。

---

## 13. 对不懂 Inno 的同事最重要的三个理解点

### 13.1 Inno 不是业务程序，它只是安装编排器

Inno Setup 自己不提供业务逻辑，它只是负责：

- 拷文件
- 跑命令
- 写注册表
- 控制安装与卸载过程

### 13.2 真正的业务程序是 Java jar，不是 `server.exe` 本身

`server.exe`、`printer.exe`、`monitor.exe` 更像 Java 启动壳。

真正会变化的业务代码主要在：

- `libs\`
- `printerlibs\`
- `libs6\`

### 13.3 主安装包和升级包一定要分开理解

- `setup*.iss` 是全量安装
- `patch*.iss` 是增量升级

如果把这两类脚本混在一起看，就很容易误解为什么有些脚本要解压 JDK、注册 MySQL 服务，而有些脚本只替换 jar。

---

## 14. 参考位置

本说明对应的主要材料位置如下：

- 安装包组装仓库：`D:\mywork\pos4install`
- 主组装脚本：`D:\mywork\pos4install\build.bat`
- 标准主安装脚本：`D:\mywork\pos4install\setup.iss`
- 标准升级脚本：`D:\mywork\pos4install\patch.iss`
- 广州酒家主安装脚本：`D:\mywork\pos4install\setupGzjj.iss`
- 广州酒家升级脚本：`D:\mywork\pos4install\patchGzjj.iss`
- 森海主安装脚本：`D:\mywork\pos4install\setupSenHai.iss`
- Launch4j 配置：
  - `D:\mywork\pos4install\app\app-server\server.xml`
  - `D:\mywork\pos4install\app\app-print-server\printer.xml`
  - `D:\mywork\pos4install\app\app-monitor\monitor.xml`
- 后端构建方案文档：
  - `D:\mywork\techdoc\服务部署文档\最终安装过程\制作安装程序\Jenkins在K8s构建后端并由Windows从Ubuntu取包方案.md`

如果后续需要，还可以继续补一份“按 `setup.iss` 从上到下逐段翻译”的细版说明，专门讲每一行 Inno 语法在这里是什么意思。
