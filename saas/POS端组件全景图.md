# POS 端组件全景图

## 一、POS 机是一台什么机器

POS 机本质上是一台**独立运行的 Windows 电脑**，上面跑了多个服务组件，协同完成收银工作。

```
+------------------------------------------------------------------+
|                        POS 物理机（Windows）                        |
|                                                                   |
|  +------------------+    +------------------+    +--------------+ |
|  |   MySQL 8.0     |    |   Redis 5.0      |    |  ActiveMQ   | |
|  |   本地数据库     |    |   缓存+锁        |    |  消息队列    | |
|  +------------------+    +------------------+    +--------------+ |
|                                                                   |
|  +------------------+    +------------------+                    |
|  |   JDK 21         |    |   ActiveMQ 6.1   |                    |
|  |   Java 运行时    |    |   Broker（内嵌）  |                    |
|  +------------------+    +------------------+                    |
|                                                                   |
|  +------------------+    +------------------+    +--------------+ |
|  |  app-server      |    |  app-monitor     |    |   client.exe | |
|  |  Java 后端服务   |    |  机器监控        |    |  Electron 前端 | |
|  +------------------+    +------------------+    +--------------+ |
|                                                                   |
|  +------------------+    +------------------+                    |
|  |  app-print-server|    |  printerlibs     |                    |
|  |  打印服务        |    |  打印机 SDK      |                    |
|  +------------------+    +------------------+                    |
+------------------------------------------------------------------+
```

---

## 二、三种安装角色

安装 POS 时，可以选择三种不同的角色，安装的组件范围不同：

| 角色 | 英文名 | 说明 | 包含哪些组件 |
|------|--------|------|-------------|
| **主机** | server | 完整安装 | MySQL + Redis + ActiveMQ + 后端 + 前端 + 打印 + 监控 |
| **副机** | client | 仅客户端 | 前端 + 打印服务（连主机的 MySQL） |
| **自助点餐** | selforder | 自助终端 | 前端 + 打印服务（扫码点餐用） |

> 自助点餐安装后会创建标识文件 `C:\easySoft\SaasClient\forSelfOrder`，告知系统该终端是自助点餐模式。

---

## 三、每个组件是什么、有什么用

下面按功能分类，逐个说明每个组件是什么、干什么、什么时候有数据、存什么数据。

### 3.1 基础设施层

#### MySQL 8.0.28 — 本地关系数据库

**是什么**：运行在 Windows 上的 MySQL 数据库服务，进程名 `mysqld.exe`，服务名 `NmsMysql`，监听端口 `8066`。

**干什么**：存储 POS 所有业务数据。

**有什么数据**：

| 表/数据 | 说明 |
|---------|------|
| `dwd_bill` | 账单表（每笔消费记录） |
| `dwd_bill_error` | 账单异常记录 |
| `dwd_apply_pay` | 支付申请记录（扫码支付） |
| `pt_dish` | 菜品表 |
| `pt_tbl` | 桌台表 |
| `pt_member` | 会员表 |
| `sys_config_data` | 系统配置（营业日期等） |
| `pos_prn_job` | 打印任务队列 |
| `pos_prn_queue` | 打印排队表 |

> MySQL 是 POS 的**唯一持久化存储**，所有数据最终都落在这里。

**安装内容**：
- `mysql-8.0.28-winx64.zip` — MySQL 服务器程序
- `mysql_data.zip` — 初始化数据库文件（nms 库 + 建表脚本）
- `my.ini` / `my_d.ini` — MySQL 配置文件

---

#### Redis 5.0.14 — 内存缓存 + 分布式锁

**是什么**：运行在 Windows 上的 Redis 服务，进程名 `redis-server.exe`，服务名 `redis`，默认端口 `6379`。

**干什么**：做两件事——**缓存热点数据** + **提供分布式锁**。

**什么时候有数据、有什么数据**：

| Key 模式 | 什么时候写入 | 存什么 | 什么时候消失 |
|---------|------------|--------|------------|
| `nms4token:var:same-token` | POS 登录云端成功后 | 云端认证 Token（有效期 2 小时） | Token 过期后云端刷新 |
| `*_lock` | 业务操作开始时 | 分布式锁（SETNX，TTL=30秒） | 业务完成后自动释放 |
| `nms:app:ver:*` | POS 启动或检查更新时 | APP 升级包版本信息 | 10 分钟缓存 |
| `nms:app:downing` | 正在下载升级包时 | 下载中标记（TTL=10分钟） | 下载完成或超时 |
| `nms:device:uuid` | 设备注册时 | 设备唯一标识（TTL=2小时） | 过期后重新生成 |

**典型使用场景**：

```java
// 场景1：云端 API 调用前读取 Token
String saToken = redisTemplatePlus.get("nms4token:var:same-token");

// 场景2：防止同一账单并发结账
lockServiceUtil.runAndGet(
    () -> handler.handle(orderMsgDTO),
    String.format("%s_lock", orderMsgDTO.getMsgId()),  // 锁 key
    30  // 30 秒超时
);

// 场景3：升级包下载中加锁，防止重复下载
redisTemplatePlus.setIfAbsent(KEY_IN_REDIS_DOWNING, Boolean.TRUE, 10, TimeUnit.MINUTES);
```

> **Redis 是内存数据库，重启后数据丢失。** 业务主数据不存 Redis，Redis 只存临时运行时状态。

---

#### ActiveMQ 6.1.3 — 消息队列（POS 本地 Broker）

**是什么**：POS 机器上运行的 ActiveMQ 消息代理，进程名 `activemq.bat` 启动，服务名 `ActiveMQ`，默认端口 `61616`。

**干什么**：POS 订阅云端下发的消息，实现**被动接收**云端指令。

> 和云端的 RocketMQ 不同，**POS 上的 ActiveMQ 是本地运行的 Broker**，云端把消息推送到 POS 本地这个 Broker，POS 再消费。

**什么时候有数据**：

| Topic | 什么时候收到 | 存什么 |
|-------|------------|--------|
| `TAKE_OUT_ORDER_MSG` | 外卖平台有订单时 | 美团/饿了么/扫呗外卖订单 |
| `SCAN_ORDER_MSG` | 微信扫码点餐时 | 扫码下单/结账/拉单指令 |
| `PRINT_JOB_MSG` | 云端统一下发打印任务时 | 厨打、小票打印指令 |
| `SOLD_OUT_CHANGE` | 菜品沽清状态变更时 | 沽清菜品 ID 列表 |

**详细说明见下一节。**

---

### 3.2 Java 运行时层

#### JDK 21 — Java 运行环境

**是什么**：Java 虚拟机，所有 Java 服务都依赖它运行。

**干什么**：运行 `app-server`、`app-monitor`、`app-print-server` 三个 Java 服务。

**安装路径**：`C:\easySoft\SaasServer\jdk-21.0.5`

> POS 后端纯 Java 实现，不像普通应用需要 .NET Framework，JDK 21 是自带的。

---

#### ext/* — JDK 扩展包

**是什么**：第三方 Java 库，按需加载，不是 JDK 自带的。

**干什么**：给业务功能提供基础能力支持。

| JAR 包 | 干什么 |
|--------|--------|
| `nls-sdk-common*.jar` | 语音合成基础库 |
| `nls-sdk-tts*.jar` | 文字转语音（TTS） |
| `kafka-clients*.jar` | Kafka 消息客户端（连云端 Kafka） |
| `spring-kafka*.jar` | Spring 集成 Kafka |
| `spring-retry*.jar` | 重试框架 |
| `lz4-java*.jar` / `snappy-java*.jar` / `zstd-jni*.jar` | 高效压缩算法 |
| `fastjson*.jar` | JSON 序列化 |
| `jdframe*.jar` | 内部框架基座 |

---

### 3.3 业务服务层

#### app-server — Java 后端主程序

**是什么**：`C:\easySoft\SaasServer\app-server\server.exe`，由 Launch4j 包装的 Java 应用（实质是启动 JVM 运行 Spring Boot）。

**干什么**：POS 的核心业务引擎，处理所有收银逻辑。

**主要功能**：

| 功能模块 | 说明 |
|---------|------|
| 账单管理 | 开台、点菜、加菜、减菜、结账、反结账 |
| 支付处理 | 扫码支付（微信/支付宝）、现金、会员卡、积分 |
| 本地数据库升级 | 启动时执行 VerMgrServer，自动建表和字段升级 |
| 外卖接入 | 接收外卖平台订单，在本地生成账单 |
| 语音播报 | 下发语音指令（通过 voiceBroadcastMpScHandler） |
| 订单上传 | 结账后自动上传到云端 |

**启动流程**：

```
server.exe 启动
  → Launch4j 启动 JVM
  → Spring Boot 初始化
  → 检测 MySQL 是否运行
    → mysqlIsRunning() 调用 VerMgrServer.upgrade(false)
    → 读取 verInfo.ini 获取版本号
    → 比对 sys_config_data 版本，执行 SQL 升级
  → 启动成功，开始接收请求
```

**依赖**：`libs/*.jar`（核心业务 JAR，由 Jenkins 每次构建后拉取）

---

#### app-monitor — 机器监控程序

**是什么**：`C:\easySoft\SaasServer\app-monitor\app-monitor.exe`，独立的 Java 进程。

**干什么**：监控 POS 机器状态（网络、打印机连接状态等），上报到云端。

**依赖**：`libs6/*.jar`

---

#### app-print-server — 打印服务

**是什么**：`C:\easySoft\SaasServer\app-print-server\printer.exe`，独立的 Java 进程。

**干什么**：统一管理所有打印机（厨打机、小票机、标签机），接收打印任务并分发到对应打印机。

**依赖**：`printerlibs/*.jar`（各厂商打印机 SDK）

**数据**：
- `pos_prn_job` 表 — 打印任务记录
- `pos_prn_queue` 表 — 打印排队队列

---

### 3.4 客户端层

#### client.exe — 前台收银客户端

**是什么**：`C:\easySoft\SaasClient\client.exe`，基于 Electron 构建的 Windows 桌面应用。

**干什么**：面向收银员的图形界面，负责：
- 菜品展示与点单
- 账单操作（加菜、折扣、结账）
- 会员查询与积分
- 小票打印触发
- 与 app-server 通过 HTTP API 通信

> Electron = Chromium（浏览器内核）+ Node.js + 你写的 Web 前端代码，打包成 exe。

---

### 3.5 工具层

#### dll/*.dll — Windows 原生动态链接库

**干什么**：供 Java JNI 调用原生 Windows 功能（如某些硬件驱动依赖）。

#### unzip-5.51-1-bin — 解压工具

**干什么**：安装时解压 JDK、Redis、ActiveMQ、MySQL 等 zip 包。

**为什么不用 Inno Setup 自带解压**：Inno Setup 自带的解压不支持大文件或特定压缩格式，所以用专门的 unzip 工具。

#### vc_redist.x64.exe — Visual C++ 运行库

**干什么**：MySQL 等组件依赖 VC++ 运行库，安装时静默检测，如未安装则自动执行。

#### verInfo.ini — 版本文件

**干什么**：记录当前构建版本号 `{"POS_VERSION":"2026-04-27 18:34:47"}`，供 VerMgrServer 判断是否需要执行数据库升级。

**怎么产生**：由 JUnit 测试 `Pos3BootApplicationTest.contextLoads()` 运行时生成，不是 Maven 编译产出。

---

## 四、组件关系图

```
收银员操作 client.exe（Electron 前端）
         │  HTTP / WebSocket
         ▼
  app-server（Java 后端）
         │
         ├─────────────────────────────────────────────┐
         │                                             │
         ▼                                             ▼
   ┌──────────┐                              ┌──────────────────┐
   │  MySQL   │                              │   ActiveMQ       │
   │  本地数据库│                              │   本地 Broker    │
   │          │                              │                  │
   │ 账单/菜品 │                              │ ← 外卖订单        │
   │ 会员/支付│                              │ ← 扫码点餐        │
   └──────────┘                              │ ← 打印任务        │
         ▲                                   │ ← 沽清变更        │
         │                                   └──────────────────┘
         │                                          ▲
         │                                   云端推送消息
         │                                          │
         └──────────────────────────────────────────┘
                                             RocketMQ
                                           （云端 Broker）

   app-print-server（打印服务）
         │
         ▼
   ┌──────────────┐
   │  厨打打印机   │  小票打印机  │  标签打印机
   └──────────────┘

   app-monitor（监控服务） → 上报机器状态到云端

   Redis（缓存 + 锁）
         │
         ├─ 云端 Token
         ├─ 分布式锁（防并发）
         └─ 版本信息缓存
```

---

## 五、打包结构：安装包 vs 升级包

### 安装包（setup.iss）

完整安装，包含**所有**组件，用于**新装机**。

### 升级包（patch.iss）

只包含**变更部分**，用于**已有机型打补丁**：

| 组件 | 安装包 | 升级包 |
|------|--------|--------|
| JDK 21 | ✅ | ❌ |
| MySQL 8.0.28 | ✅ | ❌ |
| Redis 5.0.14 | ✅ | ❌ |
| ActiveMQ 6.1.3 | ✅ | ❌ |
| libs/*.jar（业务 JAR） | ✅ | ✅ |
| libs6/*.jar（监控 JAR） | ✅ | ✅ |
| printerlibs/*.jar（打印 SDK） | ✅ | ✅ |
| ext/*.jar（扩展包） | ✅ | ✅ |
| verInfo.ini | ✅ | ✅ |
| printer.sdk.dll | ✅ | ✅ |
| client.exe | ✅ | ❌ |

---

*文档生成时间: 2026-04-29*
