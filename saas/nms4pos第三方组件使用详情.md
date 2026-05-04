# nms4pos 第三方组件使用详情

> 项目路径：`D:\mywork\nms4pos`
> 分析范围：pos1starter、pos2plugin、pos3boot、pos4cloud、pos5sync、pos6monitor、pos9cash、pos10printer
> 最后更新：2026-04-30

---

## 一、模块架构概览

nms4pos 是餐饮行业 POS 收银系统，基于 Spring Boot 微服务架构，继承 nms4cloud 主平台技术栈，额外引入大量第三方组件。与 nms4cloud 其他子项目最大的差异在于：需要直连打印机、钱箱等外设（串口/JNA），以及 AI 语音合成、OCR 识别等能力。

### 子模块职责

| 子模块 | 职责 | 技术特点 |
|--------|------|----------|
| `nms4cloud-pos1starter` | 通用启动器，所有其他模块的公共依赖 | 串口通信、缓存框架、二维码生成 |
| `nms4cloud-pos2plugin` | 收银核心业务（点餐、结账、KDS划菜） | 阿里云 TTS 语音播报、Kafka 消息、串口打印 |
| `nms4cloud-pos3boot` | 本地启动服务（独立运行） | Thymeleaf 模板、健康检查 |
| `nms4cloud-pos4cloud` | 云端通信（与 nms4cloud 主平台交互） | AI 能力最密集：TTS/OCR/通义大模型；Canal CDC 同步；多云存储 |
| `nms4cloud-pos5sync` | 数据同步（本地 → 云端） | Canal binlog 订阅、Kafka 消息队列 |
| `nms4cloud-pos6monitor` | 系统监控（独立部署） | WebFlux 响应式、串口外设监控 |
| `nms4cloud-pos9cash` | 现金管理 | 无第三方组件，仅依赖平台 API |
| `nms4cloud-pos10printer` | 打印服务 | 无第三方组件 |

---

## 二、第三方组件详情

### 2.1 消息中间件

| 组件 | GroupId | 版本 | 使用模块 | 引入方式 |
|------|---------|------|---------|----------|
| **RocketMQ** | `nms4cloud-starter-rocketmq` | 继承 | pos4cloud-biz | Maven 依赖，nms4cloud 主平台提供 |
| **Apache Kafka** | `spring-kafka` | Spring Boot 管理 | pos2plugin-biz, pos4cloud-biz, pos5sync-biz | Maven 依赖 |

**应用场景**：
- **RocketMQ**：pos4cloud 接收本地 POS 推送的订单消息，经 RocketMQ 异步上传到云端，实现本地收银与云端数据同步的解耦
- **Kafka**：pos2plugin 本地事件流（如扫码事件、支付完成事件）；pos5sync 数据同步流水线；pos4cloud 云端事件分发

### 2.2 硬件设备集成

这是 POS 系统区别于其他 nms4cloud 模块的核心能力。收银机需要连接小票打印机（串口）、钱箱、电子秤、扫码枪等外设。

| 组件 | GroupId | 版本 | 使用模块 | 引入方式 | 用途 |
|------|---------|------|---------|----------|------|
| **jSerialComm** | `com.fazecast:jSerialComm` | 2.10.2 / 2.11.0 | pos1starter, pos2plugin-biz, pos6monitor | Maven 仓库 | 跨平台串口通信，连接热敏小票打印机 |
| **RXTXcomm** | `org.rxtx:rxtx` | 2.1.7 | pos2plugin-biz, pos6monitor | `system` scope，本地 `lib/` 目录 jar | 串口通信（老旧库，与 jSerialComm 并存） |
| **JNA** | `net.java.dev.jna:jna` | 5.12.1 | pos2plugin-biz | Maven 仓库 | Java 调用本地 C/C++ 动态库（厂商提供的 DLL/SO） |
| **jna-platform** | `net.java.dev.jna:jna-platform` | 5.17.0 | pos2plugin-biz, pos6monitor | `system` scope，本地 `lib/` 目录 jar | JNA 扩展，提供平台级系统调用 |

**技术细节**：
- `pos2plugin-biz/lib/` 和 `pos6monitor/lib/` 目录下存放 `jna-platform-5.17.0.jar` 和 `RXTXcomm.jar`，通过 `<systemPath>` 引用
- `pos6monitor` 是独立 Spring Boot 项目（parent 为 `spring-boot-starter-parent 3.4.1`），通过 `includeSystemScope` 打包 system scope 依赖
- jSerialComm 是推荐的新一代跨平台串口库，支持 Windows/Linux/macOS；RXTX 是遗留依赖，可能用于兼容某些老旧设备

### 2.3 AI / 语音合成

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **阿里云 NLS TTS SDK** | `com.alibaba.nls:nls-sdk-tts` | 2.2.18 | pos2plugin-biz | 阿里云实时语音合成，订单完成/叫号语音播报 |
| **阿里云 NLS Common** | `com.alibaba.nls:nls-sdk-common` | 2.2.18 | pos4cloud-biz | 通用 NLP 组件 |
| **百度 AI Java SDK** | `com.baidu.aip:java-sdk` | 4.8.0 | pos4cloud-biz | OCR 文字识别，扫描小票自动识别金额/菜品 |
| **腾讯云语音 SDK** | `com.tencentcloudapi:tencentcloud-speech-sdk-java` | 1.0.53 | pos4cloud-biz | 腾讯云语音合成/识别（作为阿里云 TTS 的备选） |
| **腾讯云 SDK（基础）** | `com.tencentcloudapi:tencentcloud-sdk-java` | 3.1.1222 | pos4cloud-biz | 腾讯云开放 API，覆盖人脸识别、OCR 等能力 |
| **通义千问 DashScope SDK** | `com.alibaba:dashscope-sdk-java` | 2.18.5 | pos4cloud-biz | 阿里云 Qwen 大语言模型，智能客服/AI 助手 |

**应用场景**：
- **TTS 语音播报**：顾客结账后，pos2plugin 调用阿里云 NLS TTS 合成"订单完成，欢迎下次光临"；KDS 叫号时播报菜品名称
- **OCR 票据识别**：pos4cloud 接入百度 OCR，扫描发票/收据自动识别文字，用于财务对账
- **AI 大模型**：pos4cloud 通过通义千问实现智能客服，自动回复顾客咨询

**注意**：腾讯云语音 SDK（`tencentcloud-speech-sdk-java`）中排除了 Hutool 依赖（`cn.hutool:hutool-all` 和 `cn.hutool:hutool-core`），避免与 nms4cloud 已有 Hutool 版本冲突。

### 2.4 二维码 / 条码生成

| 组件 | GroupId | 版本 | 使用模块 | 引入方式 | 用途 |
|------|---------|------|---------|----------|------|
| **ZXing Core** | `com.google.zxing:core` | 3.4.1 / 3.5.2 | pos1starter, pos2plugin-biz | Maven 仓库 | 生成一维码（EAN/UPC）和二维码（QR Code） |
| **ZXing JavaSE** | `com.google.zxing:javase` | 3.4.1 | pos2plugin-biz | Maven 仓库 | ZXing 的 JavaSE 扩展，支持图像渲染 |

**应用场景**：POS 收银时生成支付二维码（微信/支付宝）；会员卡二维码；小票上的订单二维码。

### 2.5 OCR / 文档处理

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **Tess4J** | `net.sourceforge.tess4j:tess4j` | 4.5.4 | pos4cloud-biz | Tesseract OCR 引擎的 Java 封装，扫描纸质小票识别文字 |
| **Apache PDFBox** | `org.apache.pdfbox:pdfbox` | 2.0.30 | pos4cloud-biz | PDF 解析，小票电子化存档/打印 |

**应用场景**：
- **Tess4J**：对接财务系统时，扫描手写收据/发票，自动识别金额、日期、商户名
- **PDFBox**：将电子小票导出为 PDF 文件存档；打印模板生成 PDF 后发送至打印机

### 2.6 云存储

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **阿里云 OSS** | `nms4cloud-starter-oss` | 继承 | pos4cloud-biz | 对象存储，存储小票图片、电子发票、备份文件 |
| **腾讯云 COS** | `com.qcloud:cos_api` | 5.6.54 | pos4cloud-biz | 腾讯云对象存储，作为阿里云 OSS 的备选或跨云备份 |

**应用场景**：pos2plugin 生成的电子小票图片上传到阿里云 OSS；pos4cloud 将数据备份到腾讯云 COS，实现多云冗余。

### 2.7 数据同步（CDC）

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **Canal Client** | `com.alibaba.otter:canal.client` | 1.1.7 | pos4cloud-biz, pos5sync-biz | 订阅 MySQL binlog，实时获取本地 POS 数据变更 |
| **Canal Protocol** | `com.alibaba.otter:canal.protocol` | 1.1.7 | pos4cloud-biz, pos5sync-biz | Canal 通信协议定义 |

**应用场景**：
- **pos5sync**：监听本地 MySQL 数据库的 binlog，将菜品更新、价格变更实时同步到云端
- **pos4cloud**：接收 Canal 推送的变更事件，上传至 nms4cloud 主平台

> 这是典型的 CDC（Change Data Capture）模式，避免了定时轮询带来的延迟和数据一致性问题。

### 2.8 HTTP 客户端

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **OkHttp** | `com.squareup.okhttp3:okhttp` | 4.12.0 | pos4cloud-biz | 轻量 HTTP 客户端，调用第三方 API（AI 服务、支付通道） |
| **OkHttp SSE** | `com.squareup.okhttp3:okhttp-sse` | 4.12.0 | pos4cloud-biz | Server-Sent Events，实时推送（KDS 显示更新） |

**说明**：pos4cloud 使用 OkHttp 4.12.0 而非 Spring 默认的 RestTemplate，因为 OkHttp 在连接复用、超时控制、流式响应（SSE）方面更灵活。

### 2.9 缓存 / 认证

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **JetCache** | `com.alicp.jetcache:jetcache-starter-redisson` | 2.7.6 | pos1starter | 分布式缓存抽象层，提供 @Cacheable 等注解 |
| **Redisson** | `org.redisson:redisson-spring-boot-starter` | 3.26.0 | pos1starter | Redis 分布式锁、Set/Map 等数据结构 |
| **Sa-Token Redis** | `cn.dev33:sa-token-dao-redis-jackson` | 1.34.0 | pos1starter | 鉴权框架，Session 存储到 Redis |

**技术细节**：JetCache 是缓存抽象层，底层由 Redisson 提供 Redis 连接能力。pos1starter 中 Sa-Token 使用 `sa-token-dao-redis-jackson` 序列化器，将 Session 存入 Redis。

### 2.10 其他工具库

| 组件 | GroupId | 版本 | 使用模块 | 用途 |
|------|---------|------|---------|------|
| **Reflections** | `org.reflections:reflections` | 0.10.2 | pos1starter | 运行时注解扫描，组件自动发现/注册 |
| **Jackson JSR310** | `com.fasterxml.jackson.datatype:jackson-datatype-jsr310` | 2.13.0 | pos3boot-app | Java 8 时间类型（LocalDateTime）的 JSON 序列化支持 |
| **Thymeleaf** | `spring-boot-starter-thymeleaf` | Spring Boot | pos3boot-app | 服务端模板引擎，生成收据/小票 HTML 页面 |
| **Spring Boot Actuator** | `spring-boot-starter-actuator` | Spring Boot | pos3boot-app | 健康检查、HikariCP 连接池监控端点 |
| **Spring WebFlux** | `spring-boot-starter-webflux` | 3.4.1 | pos6monitor | 响应式 Web 框架，pos6monitor 独立模块的核心 |
| **MyBatis** | `org.mybatis:mybatis` | 3.5.16 | pos1starter, pos3boot-app | 数据持久化（pos3boot 排除 starter 中的依赖后重新显式引入） |

---

## 三、各模块依赖矩阵

```
模块                    | 消息       | 串口       | AI/TTS      | OCR     | 存储   | Canal | OkHttp | 缓存
-----------------------|------------|------------|-------------|---------|--------|-------|--------|------
pos1starter（启动器）     | Kafka      | jSC        | -           | ZXing   | OSS    | -     | -      | JetCache/Redisson
pos2plugin-biz（核心）   | Kafka      | jSC, RXTX  | NLS TTS     | -       | -      | -     | -      | -
pos3boot-app（启动）     | -          | -          | -           | -       | -      | -     | -      | -
pos4cloud-biz（云端）    | RocketMQ   | -          | NLS, 百度AI | Tess4J  | OSS,COS| Canal | OkHttp | -
pos5sync-biz（同步）     | Kafka      | -          | -           | -       | -      | Canal | -      | -
pos6monitor（监控）      | -          | jSC, RXTX  | -           | -       | -      | -     | -      | -
pos9cash（现金）         | -          | -          | -           | -       | -      | -     | -      | -
pos10printer（打印）     | -          | -          | -           | -       | -      | -     | -      | -
```

---

## 四、技术选型特点分析

### 亮点

1. **AI 能力全面**：同时集成了阿里云（语音 TTS、通义大模型）、腾讯云（语音、COS）、百度 AI（OCR）三套 AI 生态，覆盖语音播报、票据识别、智能客服等多种场景

2. **本地设备集成完善**：通过 jSerialComm/RXTX + JNA 实现串口和本地 Native 调用，POS 收银机的外设（热敏打印机、钱箱、电子秤）均能接入

3. **CDC 实时同步**：本地 POS 数据通过 Canal 订阅 MySQL binlog 实时同步到云端，无需定时轮询，保证数据一致性

4. **多云存储**：同时使用阿里云 OSS 和腾讯云 COS，避免单厂商锁定

5. **AI/TTS 双厂商**：语音合成同时支持阿里云 NLS 和腾讯云语音 SDK，可按需切换或作为灾备

### 潜在风险

1. **RXTX 与 jSerialComm 并存**：两套串口库同时存在于 pos2plugin 和 pos6monitor 中，RXTX 以 `system` scope 引用本地 jar，可能造成重复连接或版本冲突，建议逐步废弃 RXTX，统一使用 jSerialComm

2. **jna-platform 作为 system scope**：`jna-platform-5.17.0.jar` 存放在各模块的 `lib/` 目录下，通过 `<systemPath>` 引用，在 CI/CD 环境中需要确保这些文件被正确提交和打包

3. **pos6monitor 独立 parent**：使用 `spring-boot-starter-parent` 而非 `nms4cloud`，是一个轻量级独立部署模块，打包配置中 `includeSystemScope=true` 确保本地 jar 被打包，可能增加镜像体积

4. **腾讯云 SDK 排除了 Hutool**：`tencentcloud-speech-sdk-java` 中排除了 Hutool 依赖，避免与 nms4cloud 已有版本冲突，但需注意传递依赖中的 Hutool 是否被正确排除

5. **多 AI SDK 并存**：同时引入阿里云 NLS、百度 AI、腾讯云、腾讯云语音、通义千问等多个 AI SDK，依赖体积较大，可按需裁剪

---

## 五、相关文档

- [RocketMQ 角色作用与技术原理](./RocketMQ角色作用与技术原理.md) — RocketMQ 在 nms4cloud 中的应用
- [Netty 与 MQ 通信架构部署文档](./Netty与MQ通信架构部署文档.md) — Netty 长连接与 MQ 配合机制
- [POS 端组件全景图](./POS端组件全景图.md) — POS 各子模块职责与交互关系
- [Netty 与 MQ 通信流程详解](./Netty与MQ通信流程详解.md) — 消息发送完整链路

---

**最后更新**：2026-04-30
