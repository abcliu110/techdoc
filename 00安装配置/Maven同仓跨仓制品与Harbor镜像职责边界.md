# Maven 同仓、跨仓制品与 Harbor 镜像职责边界

## 1. 文档目标

本文说明多模块 Java 项目中三类产物的职责边界：

- Jenkins 工作区内的临时 Maven 构建产物；
- Nexus 中供其他构建消费的 Maven 制品；
- Harbor 中供部署、分发和回滚使用的容器镜像。

核心原则不是“所有 Jar 都上传 Nexus”，而是根据调用边界决定制品是否需要跨构建保存。

## 2. 三种存储的职责

| 位置 | 主要用途 | 生命周期 | 典型内容 |
|---|---|---|---|
| Jenkins 工作区 | 完成本次 Reactor 构建和镜像制作 | 单次流水线 | `target/*.jar`、临时 Maven 本地仓库、测试报告 |
| Nexus | 供其他仓库或独立流水线解析 Maven 坐标 | 跨流水线 | API、Feign、公共 Starter、BOM、必要父 POM |
| Harbor | 供 Kubernetes 等运行环境部署和回滚 | 跨部署 | 含应用 Jar、运行时和配置结构的 OCI 镜像 |

同一个应用 Jar 可以先出现在 Jenkins 工作区，再被复制进镜像；这不意味着它还必须单独上传 Nexus。

## 3. 同仓 Reactor 为什么通常不需要 Nexus

Maven Reactor 在一次命令中构建多个模块时，会直接使用本次 Reactor 中已经生成的模块产物。例如：

```text
nms4cloud-crm-api
        -> nms4cloud-crm-dao
        -> nms4cloud-crm-service
        -> nms4cloud-crm-app
```

如果这些模块属于同一个源码仓库，并由同一条命令构建：

```bash
mvn clean package
```

那么下游模块可以直接解析 Reactor 中的上游模块，不要求上游 Jar 预先存在于 Nexus。

这类 Jar 的典型处理方式是：

1. 在 Jenkins 工作区的 `target/` 中生成；
2. 供同次 Reactor 的后续模块使用；
3. `*-app.jar` 被 Dockerfile 或 Kaniko复制进镜像；
4. 镜像推送 Harbor 后，工作区可以删除。

同仓不等于永远禁止上传 Nexus。如果某个模块需要被另一个独立流水线单独消费，或者组织要求保存可复用 Maven 制品，它就已经形成跨构建契约，应按跨仓制品处理。

## 4. 跨仓依赖为什么需要 Nexus

不同 Git 仓库不会天然处于同一个 Maven Reactor。例如主项目依赖独立仓库提供的：

```text
nms4cloud-wms-api
nms4cloud-bi-api
```

构建主项目时，Maven 无法从当前源码树找到这些模块，必须从远程 Maven 仓库解析：

```text
独立仓库流水线
  -> mvn deploy
  -> Nexus maven-snapshots
  -> 主项目从 maven-public 解析
```

跨仓通常应发布：

- `*-api.jar`；
- `*-feign.jar`；
- 多仓共用的 Starter、SDK 或客户端；
- BOM 和依赖管理 POM；
- 解析上述 POM 所必需的父 POM。

使用 `mvn deploy -pl <目标模块> -am` 时，Maven 会同时发布目标模块及其 Reactor 上游。上游中可能出现 Starter 和父 POM，这是依赖模型完整性的需要，不是无意义重复。

## 5. 应用 Jar 与镜像的关系

典型应用 Dockerfile：

```dockerfile
FROM eclipse-temurin:21-jre
COPY target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

对应流水线：

```text
源码
  -> mvn package
  -> target/nms4cloud-order-app.jar
  -> Kaniko COPY 为镜像内 /app.jar
  -> Harbor library/nms4cloud-order:<tag>
```

部署系统拉取的是 Harbor 镜像，不是从 Nexus 下载 `*-app.jar`。因此在以镜像为唯一部署制品的体系中，`*-app.jar` 通常无需再上传 Nexus。

同理，只在同仓 Reactor 内使用的 `*-dao.jar` 和 `*-service.jar` 通常也无需长期保存到 Nexus。

例外包括：

- 运维平台明确以 Jar 方式部署，而不是以镜像部署；
- 其他仓库直接声明依赖该 Service 或 DAO；
- 合规要求单独归档 Maven 制品；
- 需要脱离镜像进行可重复的 Jar 级交付。

存在这些事实时，应保存对应 Jar，不能机械套用“App Jar 不进 Nexus”。

## 6. 判断矩阵

| 模块或产物 | 默认保存位置 | 是否进入 Nexus | 原因 |
|---|---|---|---|
| 同仓 `*-dao.jar` | Jenkins 临时工作区 | 通常否 | 同一 Reactor 直接解析 |
| 同仓 `*-service.jar` | Jenkins 临时工作区 | 通常否 | 同一 Reactor 直接解析 |
| `*-app.jar` | Harbor 镜像内部 | 通常否 | 部署单位是镜像 |
| 跨仓 `*-api.jar` | Nexus | 是 | 其他仓库需要 Maven 坐标 |
| 跨仓 `*-feign.jar` | Nexus | 是 | 远程调用契约需要独立消费 |
| 公共 Starter/SDK | Nexus | 是 | 多仓复用 |
| 父 POM/BOM | Nexus | 是 | 保证依赖模型可解析 |
| 第三方依赖 | Nexus Proxy 缓存 | 是 | 降低外网依赖和重复下载 |
| 可部署镜像 | Harbor | 是 | 部署、分发和回滚的正式制品 |

## 7. `package` 与 `deploy` 的区别

```bash
mvn clean package
```

只在当前工作区生成产物。它足以完成同仓 Reactor 构建和镜像制作，但不会上传 Nexus。

```bash
mvn clean deploy
```

在构建完成后，将 Maven 制品上传远程仓库。它适合需要跨仓或跨流水线消费的模块。

不能用“流水线构建成功”推断“Nexus 已有全部 Jar”；必须检查命令是否执行了 `deploy`，并验证 Nexus 中的实际坐标。

## 8. 保留策略的正确粒度

### 8.1 Nexus

Nexus 的目标是保留必要的 Maven 坐标种类，而不是只保留一个全局 Jar。

对于 Snapshot，合理粒度是：

```text
groupId + artifactId + baseVersion
```

例如以下坐标应各自保留最新一次：

```text
com.nms4cloud:nms4cloud-wms-api:0.0.1-SNAPSHOT
com.nms4cloud:nms4cloud-bi-api:0.0.1-SNAPSHOT
```

不能在所有 artifact 中全局只保留一个，否则会破坏依赖闭包。父 POM和当前 API 所依赖的 Starter 也必须保留。

Release 制品通常不可覆盖，并且需要独立的合规保留策略；不要把 Snapshot 的“只保留最新一次”直接套到 Release 仓库。

第三方 Proxy 缓存按访问时间和磁盘容量管理，不按项目 Snapshot 规则清理。

### 8.2 Harbor

Harbor 的合理粒度是每个镜像仓库保留最新一个 artifact，例如：

```text
library/nms4cloud-order
library/nms4cloud-crm
library/nms4cloud-payment
```

多个标签可以指向同一个 artifact。界面中看到两个标签不等于保存了两份镜像层。

只保留最新一个 artifact 会失去历史回滚能力，适合磁盘极度受限的开发环境；生产环境通常至少保留一个已验证回滚版本。

## 9. 当前 nms4cloud 环境结论

截至 2026-08-12 的直接验证事实：

- `nms4cloud` 主仓库包含 64 个 Jar packaging 模块；
- Nexus `maven-snapshots` 中有 19 个唯一 Jar artifact；
- Nexus 现有制品主要来自 WMS API 和 BI API 流水线的 `deploy -pl ... -am`；
- 主项目流水线执行 `mvn clean package`，应用 Jar 用于制作 Harbor 镜像，不上传 Nexus；
- `nms4cloud/jujiao_master #7` 已成功构建并推送 12 个应用镜像；
- Harbor `library` 已配置每天执行的 `latestPushedK=1` 保留策略。

因此，当前 Nexus 的制品范围设计基本正确：它保存跨仓 API、必要上游 Starter 和父 POM，不保存所有 DAO、Service 和 App Jar。

当前 Nexus 仍有一个待收敛点：部分 Snapshot 坐标保存了多次时间戳构建。应在确认依赖闭包后，按每个 Maven 坐标保留最新一次，而不是扩大为发布全部 64 个 Jar，也不是全局只保留一个 Jar。

## 10. 验收问题

调整流水线或清理策略前，应能回答：

1. 哪些模块被其他 Git 仓库直接依赖？
2. 这些模块的 POM 还依赖哪些父 POM、Starter 和 API？
3. 部署单位是 Jar 还是镜像？
4. Nexus 清理后，能否从空 Maven 本地仓库重新构建所有独立仓库？
5. Harbor 清理后，是否仍保留业务要求的回滚版本？
6. 清理策略针对 Snapshot、Release、Proxy 缓存还是镜像 artifact？

只有以上问题有可验证答案后，才能执行自动删除策略。
