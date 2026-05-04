# verInfo.ini 生成来源与安装包遗漏问题说明

## 一、问题现象

安装完成后启动 POS 后端 `server.exe`，界面停留在：

```text
正在检测Mysql状态
```

表面看像是 MySQL 没有启动，但实际检查发现：

1. `NmsMysql` 服务曾经处于运行状态。
2. `8066` 端口可以监听。
3. `nms` 数据库存在。
4. 真正的异常是启动前数据库升级逻辑读取不到版本文件：

```text
File not exist: C:\easySoft\SaasServer\verInfo.ini
```

由于程序把这个异常统一当成“MySQL 检测失败”，并且会不断重试，所以界面一直卡在“正在检测Mysql状态”。

## 二、运行时代码为什么需要 verInfo.ini

POS 后端启动时会执行 MySQL 检测：

```java
mainFrame.setTips("正在检测Mysql状态");
checkMysqlStatus(configUtil);
```

`checkMysqlStatus()` 会循环调用 `mysqlIsRunning()`。

`mysqlIsRunning()` 不只是测试数据库连接，还会执行：

```java
new VerMgrServer().upgrade(false);
```

数据库升级逻辑会读取版本文件：

```java
public static String getCompileTime() {
  String userDir = System.getProperty("user.dir");
  String iniPath;
  if (userDir.contains("nms4pos")) {
    iniPath = userDir + "/verInfo.ini";
  } else {
    iniPath = userDir + "/../verInfo.ini";
  }
  JSONObject versionFile = JSON.parseObject(FileUtil.readUtf8String(iniPath));
  return versionFile.getString(PosConfigKey.POS_VERSION);
}
```

安装后的 `server.exe` 工作目录通常是：

```text
C:\easySoft\SaasServer\app-server
```

因此程序会读取：

```text
C:\easySoft\SaasServer\app-server\..\verInfo.ini
```

也就是：

```text
C:\easySoft\SaasServer\verInfo.ini
```

如果这个文件缺失，`VerMgrServer.upgrade(false)` 抛异常，`mysqlIsRunning()` 返回 `false`，启动流程继续重试。

## 三、verInfo.ini 是如何产生的

经检查，`verInfo.ini` 不是 `D:\mywork\pos4install` 下的批处理生成的。

它由 `D:\mywork\nms4pos` 项目中的 JUnit 测试生成：

```text
D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-app\src\test\java\com\nms4cloud\pos3boot\Pos3BootApplicationTest.java
```

关键代码：

```java
@Test
public void contextLoads() {
  SimpleDateFormat sdfTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  JSONObject json = new JSONObject();
  json.put(PosConfigKey.POS_VERSION, sdfTime.format(new Date()));
  String content = json.toJSONString();
  List<String> files = new LinkedList<>();
  files.add("../../../3_pos_install/verInfo.ini");
  files.add("../../verInfo.ini");
  files.forEach(
      s -> {
        try {
          FileUtils.writeStringToFile(new File(s), content, StandardCharsets.UTF_8);
        } catch (IOException e) {
          log.error(ExceptionUtils.getStackTrace(e));
        }
      });
}
```

从该测试类所在目录计算，它会生成两个文件：

```text
D:\mywork\3_pos_install\verInfo.ini
D:\mywork\nms4pos\verInfo.ini
```

当前文件内容示例：

```json
{"POS_VERSION":"2026-04-27 18:34:47"}
```

## 四、为什么 Git 仓库里看不到这个文件

`D:\mywork\nms4pos\.gitignore` 中明确忽略了版本文件：

```text
/nms4cloud-pos3boot/verInfo.ini
/verInfo.ini
```

这说明 `verInfo.ini` 被设计成本地构建/测试过程中生成的临时版本文件，不是随源码提交的固定文件。

## 五、安装包工程中的问题

`D:\mywork\pos4install` 的 Inno Setup 脚本都声明要打包 `verinfo.ini`。

例如：

```text
setup.iss
setupGzjj.iss
setupSenHai.iss
setupYJX.iss
patch.iss
patchGzjj.iss
```

都包含类似配置：

```text
Source: "verinfo.ini"; DestDir: "{app}/";Flags:ignoreversion recursesubdirs createallsubdirs
```

也就是说安装包预期当前目录存在：

```text
D:\mywork\pos4install\verinfo.ini
```

然后安装到：

```text
C:\easySoft\SaasServer\verinfo.ini
```

但是检查 `D:\mywork\pos4install\build.bat` 后发现，它只做了这些事情：

1. 清空并重建 `libs/`、`printerlibs/`、`libs6/`、`dist/`。
2. 从 Ubuntu 拉取后端 jar 和打印/监控 jar。
3. 调用 Inno Setup 编译安装包。

它没有生成 `verinfo.ini`，也没有从 `D:\mywork\nms4pos\verInfo.ini` 或 `D:\mywork\3_pos_install\verInfo.ini` 复制到 `D:\mywork\pos4install\verinfo.ini`。

因此，打包链路存在缺口：

```text
nms4pos 测试生成 verInfo.ini
  ->
pos4install 安装脚本需要 verinfo.ini
  ->
build.bat 没有复制这个文件
  ->
安装包可能缺失 verInfo.ini
  ->
安装后 C:\easySoft\SaasServer\verInfo.ini 不存在
  ->
server.exe 启动卡在“正在检测Mysql状态”
```

## 六、当前问题的直接原因

本次卡住的直接原因是：

```text
C:\easySoft\SaasServer\verInfo.ini 缺失
```

更上游的打包原因是：

```text
D:\mywork\pos4install\build.bat 没有把 D:\mywork\nms4pos\verInfo.ini 复制到 D:\mywork\pos4install\verinfo.ini
```

而 `pos4install` 的 Inno 脚本又依赖这个文件作为安装输入。

## 七、升级包与安装包的区别

`pos4install` 通过 `build.bat` 同时生成两类安装包，均使用 Inno Setup 编译。

### 安装包（setup.iss）

完整安装，包含所有组件：

| 组件 | 说明 |
|------|------|
| JDK 21 | Java 运行环境 |
| MySQL 8.0.28 | 本地数据库 |
| Redis | 缓存服务 |
| ActiveMQ | 消息队列 |
| libs / printerlibs / libs6 | 全部后端 JAR |
| verinfo.ini | 版本文件 |
| client / printer / monitor | 前端客户端 |

用途：**新装机**，默认安装路径 `C:\easySoft\SaasServer`。

### 升级包（patch.iss）

名称：**柠檬树SaaS收银系统升级包**

仅包含变更部分：

| 组件 | 说明 |
|------|------|
| libs / printerlibs / libs6 | 变更的后端 JAR |
| verinfo.ini | 版本文件 |
| pos_printer*.dll | 打印 SDK |

**不包含**：JDK、MySQL、Redis、ActiveMQ、数据库文件、前端客户端。

用途：**已有机型打补丁**，只替换发生变更的 JAR 文件。

### 打包流程

```bat
# build.bat 依次执行：
# 1. 从 Ubuntu 构建服务器拉取最新 JAR
scp ... nms4cloud-pos3boot-*.jar    -> libs/
scp ... nms4cloud-pos10printer-*.jar -> printerlibs/
scp ... nms4cloud-pos6monitor-*.jar -> libs6/

# 2. 编译生成完整安装包
"Compil32.exe" /cc ".\setup.iss"

# 3. 编译生成升级包
"Compil32.exe" /cc ".\patch.iss"

# 4. 编译区域版本（贵州家家、森海等）
"Compil32.exe" /cc ".\setupGzjj.iss"
"Compil32.exe" /cc ".\patchGzjj.iss"
"Compil32.exe" /cc ".\setupSenHai.iss"
```

输出到 `dist/` 目录：

```
dist/
├── 柠檬树SaaS收银系统.exe              # 完整安装包
├── 柠檬树SaaS收银系统升级包.exe        # 升级包
├── 柠檬树SaaS收银系统贵州家家版本.exe
├── 柠檬树SaaS收银系统升级包贵州家家.exe
├── 柠檬树SaaS收银系统森海版本.exe
└── 柠檬树SaaS收银系统森海升级包.exe
```

两类包的 `build.bat` 编译步骤相同，区别在于 Inno Setup 脚本中声明要打包的文件范围不同。

## 八、不改 Java 代码的处理方式

### 1. 运行环境临时修复

把已有版本文件复制到安装目录：

```bat
copy /Y D:\mywork\nms4pos\verInfo.ini C:\easySoft\SaasServer\verInfo.ini
```

如果当前 POS 后端已经卡住，需要先结束 `javaw.exe`，再重启或恢复 MySQL 连接后重新启动 `server.exe`。

### 2. 安装包工程修复

打包前必须确保：

```text
D:\mywork\pos4install\verinfo.ini
```

存在。

可以从下面任一来源复制：

```text
D:\mywork\nms4pos\verInfo.ini
D:\mywork\3_pos_install\verInfo.ini
```

推荐在 `D:\mywork\pos4install\build.bat` 编译 Inno 前增加复制步骤：

```bat
copy /Y D:\mywork\nms4pos\verInfo.ini verinfo.ini
```

如果希望完全依赖 `3_pos_install`：

```bat
copy /Y D:\mywork\3_pos_install\verInfo.ini verinfo.ini
```

注意文件名大小写在 Windows 上不敏感，但为了和 Inno 脚本保持一致，建议安装包工程中统一命名为：

```text
verinfo.ini
```

安装目录中代码读取的是：

```text
verInfo.ini
```

Windows 文件系统大小写不敏感，通常可以正常读取；但为了降低歧义，也可以在 Inno 脚本中加 `DestName: "verInfo.ini"`。

## 九、建议的标准打包链路

建议后续打包固定为：

```text
1. 构建 nms4pos 后端
2. 运行或生成 verInfo.ini
3. 把 verInfo.ini 复制到 pos4install\verinfo.ini
4. pos4install 从 Ubuntu 拉取 libs/printerlibs/libs6
5. Inno Setup 编译 setup/patch 安装包
6. 安装包安装后必须包含 C:\easySoft\SaasServer\verInfo.ini
7. 启动 server.exe 验证能越过“正在检测Mysql状态”
```

## 十、验证方法

打包前检查：

```bat
dir D:\mywork\pos4install\verinfo.ini
type D:\mywork\pos4install\verinfo.ini
```

安装后检查：

```bat
dir C:\easySoft\SaasServer\verInfo.ini
type C:\easySoft\SaasServer\verInfo.ini
```

文件内容应类似：

```json
{"POS_VERSION":"2026-04-27 18:34:47"}
```

启动后如果仍卡在 MySQL 检测，可启用控制台日志：

```bat
echo. > C:\easySoft\SaasServer\app-server\enableConsoleLog
```

然后查看：

```bat
type C:\easySoft\SaasServer\app-server\console.log
```

如果不再出现：

```text
File not exist: C:\easySoft\SaasServer\verInfo.ini
```

则说明版本文件缺失问题已经解决。
