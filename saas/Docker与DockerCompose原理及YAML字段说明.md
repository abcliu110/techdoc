# Docker 与 Docker Compose 原理及 YAML 字段说明

## 1. 为什么需要 Docker

传统部署 Java 项目时，通常需要在服务器上手动安装 JDK、Maven、MySQL、Redis、Kafka、Nginx 等环境，并维护大量配置文件和启动脚本。

这种方式最大的问题是环境不一致：

```text
开发环境：Java 21、MySQL 8、Redis 7
测试环境：Java 17、MySQL 5.7、Redis 6
生产环境：又是另一套配置
```

所以经常出现：

```text
本地能跑，服务器跑不了。
```

Docker 要解决的核心问题是：

```text
把应用和运行环境一起打包，让应用在不同机器上尽量以相同方式运行。
```

## 2. Docker 的核心原理

Docker 不是虚拟机。Docker 本质上是利用操作系统内核能力，把一个进程隔离起来运行。

容器看起来像一台独立机器，但它仍然是宿主机上的一个进程。

Docker 主要依赖三个核心能力：

```text
Namespace：隔离运行空间
Cgroups：限制资源使用
UnionFS：实现镜像分层
```

### 2.1 Namespace：隔离

Namespace 用来隔离容器的运行空间。

常见隔离内容：

| 类型 | 作用 |
|---|---|
| PID Namespace | 隔离进程 |
| Network Namespace | 隔离网络 |
| Mount Namespace | 隔离文件系统 |
| UTS Namespace | 隔离主机名 |
| IPC Namespace | 隔离进程通信 |
| User Namespace | 隔离用户权限 |

例如在容器内部执行：

```bash
ps
```

只能看到容器自己的进程，而不是宿主机所有进程。

### 2.2 Cgroups：资源限制

Cgroups 用来限制容器能使用多少宿主机资源。

例如：

```text
最多使用 2 个 CPU
最多使用 1GB 内存
最多使用 10MB/s 磁盘 IO
```

如果没有 Cgroups，一个异常容器可能会占满宿主机资源，影响其他服务。

### 2.3 UnionFS：镜像分层

Docker 镜像是分层的。

一个 Java 项目镜像可能包含：

```text
第 1 层：Linux 基础系统
第 2 层：安装 JDK
第 3 层：复制 jar 包
第 4 层：设置启动命令
```

Dockerfile 示例：

```dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/demo.jar app.jar
CMD ["java", "-jar", "app.jar"]
```

镜像分层的好处是：

```text
多个镜像可以复用相同基础层
构建速度更快
存储空间更省
发布时只需要传输变化的层
```

## 3. Docker 的核心概念

### 3.1 Image：镜像

镜像是一个只读模板。

例如：

```text
mysql:8.0
redis:7
nginx:1.27
apache/kafka:4.0.0
```

可以理解为：

```text
镜像 = 软件安装包 + 运行环境
```

### 3.2 Container：容器

容器是镜像运行后的实例。

例如：

```bash
docker run nginx
```

这条命令会基于 `nginx` 镜像启动一个容器。

可以理解为：

```text
镜像是类，容器是对象。
镜像是安装包，容器是运行中的程序。
```

### 3.3 Volume：数据卷

容器默认是临时的。容器内部虽然也有文件系统，但这个文件系统跟容器生命周期绑定得很紧。

如果删除容器，容器内部新产生的数据也可能一起丢失。

所以 MySQL、Kafka、Redis 等有状态服务通常需要挂载数据卷。

数据卷可以理解为：

```text
由 Docker 管理的一块持久化存储空间。
```

它不是某个容器自己的临时目录，而是 Docker 单独管理的数据区域。

容器可以把自己的某个目录挂载到这个数据卷上。这样容器读写这个目录时，数据实际会保存到数据卷中。

示例：

```yaml
volumes:                         # 当前服务要挂载哪些存储
  - mysql_data:/var/lib/mysql     # 把数据卷 mysql_data 挂载到容器内 /var/lib/mysql
```

含义是：

```text
把容器内 /var/lib/mysql 目录的数据保存到 Docker 数据卷 mysql_data 中。
```

这样即使容器删除，数据卷仍然可以保留。

数据卷的价值：

```text
1. 容器删除后，数据仍然保留。
2. 容器重建后，可以继续使用原来的数据。
3. 数据由 Docker 统一管理，不需要手动关心宿主机具体目录。
4. 适合保存数据库、Kafka 日志、Redis 持久化文件等重要数据。
```

数据卷和普通目录挂载的区别：

| 类型 | 示例 | 说明 |
|---|---|---|
| Docker 数据卷 | `mysql_data:/var/lib/mysql` | 数据由 Docker 管理，适合数据库、中间件持久化 |
| 宿主机目录挂载 | `D:/data/mysql:/var/lib/mysql` | 数据放在指定宿主机目录，路径更直观，但更依赖本机目录结构 |

数据卷是不是“全局的”：

```text
是，但要分两层理解。
```

第一层是：

```text
卷是 Docker 主机级别管理的资源，不属于某一个容器私有。
```

也就是说，只要你知道卷名，其他容器也可以挂载同一个卷。

例如：

```bash
docker run -v mysql_data:/data alpine
```

这个新容器也能访问同一个 `mysql_data` 卷。

第二层是：

```text
卷不会自动暴露给所有容器，必须显式挂载后容器才能访问。
```

所以更准确地说：

```text
卷是 Docker 管理的共享资源，但不是自动共享资源。
```

常见用法有两种：

```text
1. 数据持久化：MySQL、Kafka、Redis 把数据写入卷。
2. 数据共享：多个临时容器挂同一个卷，用来读取或复制文件。
```

但要注意：

```text
数据库卷虽然可以被别的容器挂载，但业务上通常不建议随便去读它的物理文件。
```

因为数据库内部文件格式通常不是给人直接编辑的，直接动这些文件可能引起损坏或不一致。

### 3.4 Network：网络

Docker 容器之间可以通过 Docker 网络通信。

在同一个 Compose 网络中，服务可以直接通过服务名访问。

声明网络的核心目的有两个：

```text
1. 连通：让需要互相访问的容器放到同一个网络里。
2. 隔离：让不应该互相访问的容器放到不同网络里。
```

如果不显式声明网络，Docker Compose 也会自动创建一个默认网络。简单项目可以不写 `networks`。

但是复杂项目建议显式声明网络，因为这样可以清楚表达：

```text
哪些容器可以互相访问。
哪些容器应该隔离。
哪些服务属于 Web 层、应用层、数据库层。
```

在下面的例子中，`app` 和 `mysql` 是两个服务。它们如果处于同一个 Docker Compose 项目网络中，`app` 不需要知道 MySQL 容器的 IP，只要使用服务名 `mysql` 就能访问 MySQL。

示例：

```yaml
services:                         # 定义这一组要启动的服务
  app:                             # 定义一个名为 app 的服务，通常是业务应用
    environment:                   # 给 app 容器传入环境变量
      MYSQL_HOST: mysql            # 告诉 app：MySQL 的主机名叫 mysql
    networks:                      # 声明 app 要加入哪些网络
      - app_net                    # app 加入 app_net 网络

  mysql:                           # 定义一个名为 mysql 的服务
    image: mysql:8.0               # mysql 服务使用 mysql:8.0 镜像启动
    networks:                      # 声明 mysql 要加入哪些网络
      - app_net                    # mysql 也加入 app_net 网络

networks:                          # 顶层网络声明
  app_net:                         # 声明 app_net 网络，由 Docker Compose 创建
```

`app` 容器可以直接访问：

```text
mysql:3306
```

这里的 `mysql` 不是固定 IP，而是 Compose 自动提供的服务名 DNS。

不要写死容器 IP。容器重启后 IP 可能变化，但服务名通常保持稳定。

网络也可以做分层隔离：

```yaml
services:                         # 定义服务
  nginx:                          # 对外入口服务
    networks:                     # nginx 同时连接外部访问网络和应用网络
      - web_net                   # 面向外部入口的网络
      - app_net                   # 面向业务应用的网络

  app:                            # 业务应用服务
    networks:                     # app 同时连接应用网络和数据库网络
      - app_net                   # 与 nginx 通信
      - db_net                    # 与 mysql 通信

  mysql:                          # 数据库服务
    networks:                     # mysql 只加入数据库网络
      - db_net                    # 只允许 app 这类加入 db_net 的服务访问

networks:                         # 顶层网络声明
  web_net:                        # Web 入口网络
  app_net:                        # 应用内部网络
  db_net:                         # 数据库网络
```

这表示：

```text
nginx 能访问 app。
app 能访问 mysql。
nginx 不能直接访问 mysql。
```

## 4. Docker Compose 是什么

Docker 适合运行单个容器。

例如：

```bash
docker run redis
docker run mysql
docker run kafka
docker run nginx
```

但真实项目通常是一组容器：

```text
Spring Boot 应用
MySQL
Redis
Kafka
Nginx
Kafka UI
Prometheus
Grafana
```

如果每个容器都手写 `docker run` 命令，维护成本很高。

Docker Compose 的作用是：

```text
用一个 YAML 文件描述一组容器，然后一键启动、停止和管理。
```

常用命令：

```bash
docker compose up -d
docker compose down
docker compose ps
docker compose logs -f
docker compose restart
```

## 5. Docker 和 Docker Compose 的关系

| 对比项 | Docker | Docker Compose |
|---|---|---|
| 作用 | 运行容器 | 编排多个容器 |
| 配置方式 | `docker run` 命令 | `docker-compose.yml` |
| 适合场景 | 单个服务测试 | 本地开发、小型部署 |
| 是否负责集群调度 | 否 | 否 |
| 是否适合复杂生产集群 | 不适合 | 不太适合 |

简单理解：

```text
Docker = 容器运行引擎
Docker Compose = 单机多容器编排工具
Kubernetes = 生产级集群容器编排平台
```

## 6. docker-compose.yml 示例

下面用 Kafka 和 Kafka UI 举例。

这份 YAML 里有几个重要概念：

```text
services：定义要启动的容器服务。
image：指定每个服务使用哪个镜像。
ports：把容器端口映射到宿主机端口。
environment：给容器传递配置参数。
volumes：把容器内的重要数据保存到 Docker 数据卷。
networks：让多个容器加入同一个网络，方便通过服务名通信。
depends_on：控制服务启动顺序。
```

完整示例：

```yaml
services:                                                    # 定义本文件要管理的所有服务
  kafka:                                                     # 定义 Kafka 服务，服务名是 kafka
    image: apache/kafka:4.0.0                                # 使用 Apache 官方 Kafka 4.0.0 镜像
    container_name: kafka-demo                               # 指定容器名称，方便 docker logs kafka-demo 查看日志
    ports:                                                   # 配置端口映射
      - "9092:9092"                                          # 宿主机 9092 端口映射到容器内 9092 端口
    environment:                                             # 给 Kafka 容器传递环境变量配置
      KAFKA_NODE_ID: 1                                       # Kafka 节点 ID，单机环境写 1
      KAFKA_PROCESS_ROLES: broker,controller                 # 当前节点同时承担 broker 和 controller 角色
      KAFKA_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093  # 容器内部监听 9092 客户端端口和 9093 控制器端口
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092 # Kafka 告诉宿主机客户端：请通过 localhost:9092 访问我
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER            # 指定 CONTROLLER 这个监听器用于控制器通信
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT # 指定监听器使用明文协议
      KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093           # KRaft 控制器投票节点，1 是节点 ID，kafka:9093 是控制器地址
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1              # 消费者 offset 内部 topic 的副本数，单机必须是 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1      # 事务状态内部 topic 的副本数，单机必须是 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1                 # 事务状态日志最少同步副本数，单机必须是 1
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0              # 消费者组启动时不额外等待，方便本地快速测试
    volumes:                                                 # 配置 Kafka 数据持久化
      - kafka_data:/var/lib/kafka/data                       # 把 Kafka 数据目录保存到 Docker 数据卷 kafka_data
    networks:                                                # 配置 Kafka 加入哪些 Docker 网络
      - kafka_net                                            # 加入 kafka_net 网络，方便其他容器用 kafka 这个服务名访问

  kafka-ui:                                                  # 定义 Kafka 可视化界面服务
    image: provectuslabs/kafka-ui:v0.7.2                     # 使用 Kafka UI 镜像
    container_name: kafka-ui-demo                            # 指定 Kafka UI 容器名称
    ports:                                                   # 配置 Kafka UI 端口映射
      - "8088:8080"                                          # 宿主机 8088 映射到容器内 8080，浏览器访问 localhost:8088
    environment:                                             # 给 Kafka UI 传递连接 Kafka 的配置
      KAFKA_CLUSTERS_0_NAME: local-kafka                     # Kafka UI 页面中显示的集群名称
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092          # Kafka UI 在容器网络内通过 kafka:9092 访问 Kafka
    depends_on:                                              # 配置服务启动顺序
      - kafka                                                # 先启动 kafka，再启动 kafka-ui
    networks:                                                # 配置 Kafka UI 加入哪些 Docker 网络
      - kafka_net                                            # 加入 kafka_net 网络，才能通过服务名 kafka 访问 Kafka

volumes:                                                     # 顶层 volumes，声明本 Compose 项目使用的数据卷
  kafka_data:                                                # 声明 kafka_data 数据卷，由 Docker 负责创建和管理

networks:                                                    # 顶层 networks，声明本 Compose 项目使用的网络
  kafka_net:                                                 # 声明 kafka_net 网络，由 Docker Compose 创建
```

## 7. docker-compose.yml 顶层字段说明

### 7.1 services

```yaml
services:
```

`services` 表示要启动哪些服务。

一个服务通常对应一个容器。

示例：

```yaml
services:
  kafka:
  kafka-ui:
```

这里定义了两个服务：

```text
kafka：Kafka 服务
kafka-ui：Kafka 可视化界面
```

### 7.2 volumes

```yaml
volumes:
  kafka_data:
```

顶层 `volumes` 用来声明 Docker 数据卷。

Compose 会自动创建这个数据卷。

查看数据卷：

```bash
docker volume ls
```

删除容器但保留数据卷：

```bash
docker compose down
```

删除容器并删除数据卷：

```bash
docker compose down -v
```

### 7.3 networks

```yaml
networks:             # 顶层 networks，用来声明当前 Compose 项目需要哪些网络
  kafka_net:          # 声明一个名为 kafka_net 的网络
```

顶层 `networks` 用来声明 Docker 网络。

Compose 会自动创建这个网络。

同一个网络里的容器可以通过服务名互相访问。

例如：

```text
kafka-ui -> kafka:9092
```

为什么要显式声明网络：

```text
1. 服务名访问更稳定，不依赖容器 IP。
2. 网络边界更清楚，方便看出哪些服务能互通。
3. 复杂项目可以拆分 web_net、app_net、db_net。
4. 多个 Compose 文件或外部网络集成时更容易管理。
```

如果所有服务都在一个简单项目里，不写 `networks` 也能运行，因为 Compose 会创建默认网络。

但如果你希望文档、部署结构和访问边界清晰，建议显式写出来。

## 8. service 内部字段说明

### 8.1 服务名

```yaml
kafka:
```

`kafka` 是服务名。

服务名有两个作用：

```text
1. 标识当前服务
2. 在 Compose 网络中作为 DNS 名称使用
```

所以 `kafka-ui` 可以通过下面地址访问 Kafka：

```text
kafka:9092
```

而不是写死 IP。

### 8.2 image

```yaml
image: apache/kafka:4.0.0
```

`image` 表示容器使用哪个镜像。

格式通常是：

```text
镜像名:版本号
```

例如：

```text
mysql:8.0
redis:7
nginx:1.27
apache/kafka:4.0.0
```

不建议生产环境使用：

```yaml
image: nginx:latest
```

因为 `latest` 版本会变化，不同时间部署出来的结果可能不一致。

### 8.3 container_name

```yaml
container_name: kafka-demo
```

`container_name` 指定容器名称。

如果不写，Compose 会自动生成类似名称：

```text
目录名-kafka-1
```

写了之后，容器名称固定为：

```text
kafka-demo
```

优点是方便查看日志：

```bash
docker logs kafka-demo
```

缺点是同一台机器上不能同时启动多个相同名称的容器。

### 8.4 ports

```yaml
ports:
  - "9092:9092"
```

`ports` 表示端口映射。

格式是：

```text
宿主机端口:容器端口
```

示例：

```yaml
ports:
  - "8088:8080"
```

表示：

```text
访问宿主机 localhost:8088
实际转发到容器内部 8080 端口
```

Kafka 示例：

```yaml
ports:
  - "9092:9092"
```

表示宿主机上的 Spring Boot 程序可以通过下面地址访问 Kafka：

```text
localhost:9092
```

### 8.5 environment

```yaml
environment:
  KAFKA_NODE_ID: 1
```

`environment` 用来给容器传递环境变量。

很多镜像都是通过环境变量完成配置的。

例如 MySQL：

```yaml
environment:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: demo
```

Kafka 也是通过环境变量配置节点 ID、监听地址、角色等。

### 8.6 service 内部 volumes

```yaml
volumes:
  - kafka_data:/var/lib/kafka/data
```

格式是：

```text
数据卷名称:容器内部路径
```

这里表示：

```text
把 Kafka 数据保存到 kafka_data 数据卷
容器内部 Kafka 数据目录是 /var/lib/kafka/data
```

如果不配置 volume，删除容器后 Kafka 数据可能丢失。

### 8.7 service 内部 networks

```yaml
networks:             # 当前服务要加入的网络列表
  - kafka_net         # 加入 kafka_net 网络
```

表示当前服务加入哪个 Docker 网络。

同一个网络里的容器可以通过服务名通信。

服务内部的 `networks` 和顶层 `networks` 是配套关系：

```yaml
services:             # 定义服务
  kafka:              # Kafka 服务
    networks:         # 这个服务要加入哪些网络
      - kafka_net     # kafka 加入 kafka_net

  kafka-ui:           # Kafka UI 服务
    networks:         # 这个服务要加入哪些网络
      - kafka_net     # kafka-ui 也加入 kafka_net

networks:             # 顶层声明网络
  kafka_net:          # 声明 kafka_net 这个网络
```

只有两个服务加入同一个网络，才可以稳定地通过服务名互相访问。

例如 Kafka UI 容器里访问 Kafka 时，应该写：

```text
kafka:9092
```

而不是：

```text
localhost:9092
```

因为在 Kafka UI 容器内部，`localhost` 指的是 Kafka UI 自己，不是 Kafka 容器。

### 8.8 depends_on

```yaml
depends_on:
  - kafka
```

表示 `kafka-ui` 依赖 `kafka`。

Compose 启动时会先启动 Kafka，再启动 Kafka UI。

但是要注意：

```text
depends_on 只保证启动顺序，不保证 Kafka 已经完全可用。
```

也就是说 Kafka 容器启动了，不代表 Kafka 服务已经准备好接收连接。

生产级场景通常还需要：

```text
healthcheck
重试机制
应用启动等待
```

## 9. Kafka 环境变量字段说明

### 9.1 KAFKA_NODE_ID

```yaml
KAFKA_NODE_ID: 1
```

表示 Kafka 节点 ID。

在 Kafka 集群中，每个节点都要有唯一 ID。

单机部署时写 `1` 即可。

### 9.2 KAFKA_PROCESS_ROLES

```yaml
KAFKA_PROCESS_ROLES: broker,controller
```

Kafka 可以使用 KRaft 模式，不再依赖 ZooKeeper。

这个字段表示当前节点承担哪些角色：

```text
broker：负责消息读写
controller：负责集群元数据管理
```

单机开发环境通常让一个节点同时承担两个角色。

### 9.3 KAFKA_LISTENERS

```yaml
KAFKA_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
```

表示 Kafka 容器内部监听哪些端口。

这里配置了两个监听器：

```text
PLAINTEXT://:9092：客户端访问 Kafka 的端口
CONTROLLER://:9093：Kafka 控制器内部通信端口
```

`PLAINTEXT` 表示未启用 SSL/SASL 认证，适合本地开发。

生产环境一般不建议直接使用明文访问。

### 9.4 KAFKA_ADVERTISED_LISTENERS

```yaml
KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
```

这是 Kafka 最容易配置错的字段。

它表示 Kafka 告诉客户端：

```text
你应该通过哪个地址访问我。
```

如果 Spring Boot 程序运行在宿主机上，应该写：

```text
localhost:9092
```

如果 Spring Boot 程序也运行在 Docker 网络里，应该写：

```text
kafka:9092
```

很多 Kafka 连不上，都是这个字段配置错了。

### 9.5 KAFKA_CONTROLLER_LISTENER_NAMES

```yaml
KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
```

告诉 Kafka 哪个 listener 是 controller 使用的。

这里指定的是：

```text
CONTROLLER
```

对应前面的：

```yaml
KAFKA_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093
```

### 9.6 KAFKA_LISTENER_SECURITY_PROTOCOL_MAP

```yaml
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
```

表示每个 listener 使用什么安全协议。

这里的意思是：

```text
CONTROLLER 使用 PLAINTEXT
PLAINTEXT 使用 PLAINTEXT
```

本地开发可以这样配。

生产环境通常需要考虑 SSL、SASL、ACL、认证和授权。

### 9.7 KAFKA_CONTROLLER_QUORUM_VOTERS

```yaml
KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
```

KRaft 模式下，controller 节点需要组成投票集合。

格式是：

```text
节点ID@主机名:端口
```

这里表示：

```text
节点 1 的 controller 地址是 kafka:9093
```

因为在 Compose 网络中，服务名 `kafka` 可以作为主机名使用。

### 9.8 KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR

```yaml
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
```

Kafka 会内部创建一个 topic 保存消费者 offset。

这个配置表示该内部 topic 的副本数。

单机环境只能设置为 `1`。

如果设置为 `3`，但只有一个 Kafka 节点，就会启动失败或无法正常创建内部 topic。

### 9.9 KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR

```yaml
KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
```

Kafka 事务需要内部 topic 保存事务状态。

这个字段表示事务状态 topic 的副本数。

单机环境设置为 `1`。

### 9.10 KAFKA_TRANSACTION_STATE_LOG_MIN_ISR

```yaml
KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
```

ISR 是 in-sync replicas，表示同步副本集合。

这个字段表示事务状态日志至少需要多少个同步副本才算可用。

单机环境只能设置为 `1`。

### 9.11 KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS

```yaml
KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
```

消费者组启动时，Kafka 默认可能等待一小段时间再进行分区分配。

本地开发设置为 `0`，可以让消费者组更快开始消费消息。

## 10. Kafka UI 字段说明

### 10.1 image

```yaml
image: provectuslabs/kafka-ui:v0.7.2
```

表示启动 Kafka 可视化界面。

启动后访问：

```text
http://localhost:8088
```

### 10.2 KAFKA_CLUSTERS_0_NAME

```yaml
KAFKA_CLUSTERS_0_NAME: local-kafka
```

表示 Kafka UI 页面中显示的集群名称。

### 10.3 KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS

```yaml
KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
```

表示 Kafka UI 连接 Kafka 的地址。

因为 Kafka UI 运行在 Docker 容器内部，所以不能写：

```text
localhost:9092
```

在 Kafka UI 容器里，`localhost` 指的是 Kafka UI 自己，不是 Kafka 容器。

所以这里应该使用服务名：

```text
kafka:9092
```

## 11. Docker Compose 的启动过程

执行：

```bash
docker compose up -d
```

大致会发生这些事情：

```text
1. 读取 docker-compose.yml
2. 创建网络 kafka_net
3. 创建数据卷 kafka_data
4. 拉取镜像 apache/kafka:4.0.0
5. 拉取镜像 provectuslabs/kafka-ui:v0.7.2
6. 创建 kafka 容器
7. 创建 kafka-ui 容器
8. 按依赖顺序启动容器
9. 将宿主机端口映射到容器端口
```

查看运行状态：

```bash
docker compose ps
```

查看日志：

```bash
docker compose logs -f
```

停止服务：

```bash
docker compose down
```

停止并删除数据卷：

```bash
docker compose down -v
```

## 12. Docker Compose 适合什么场景

Docker Compose 适合：

```text
本地开发环境
测试环境
单机部署
学习中间件
快速搭建依赖服务
小型内部系统
```

例如本地启动：

```text
MySQL + Redis + Kafka + Spring Boot
```

Docker Compose 非常方便。

## 13. Docker Compose 不适合什么场景

Docker Compose 不太适合复杂生产集群。

原因是它缺少：

```text
跨机器调度
自动扩容
自动故障迁移
滚动发布
服务发现
配置中心
密钥管理
资源编排
复杂网络策略
声明式健康恢复
```

如果服务规模变大，例如几十个服务、多台服务器、多副本部署、灰度发布、自动扩缩容、高可用要求，就更适合使用 Kubernetes。

## 14. Docker Compose 和 Kubernetes 的关系

| 内容 | Docker Compose | Kubernetes |
|---|---|---|
| 主要用途 | 单机多容器编排 | 集群级容器编排 |
| 配置文件 | `docker-compose.yml` | Deployment、Service、ConfigMap、Secret 等 YAML |
| 部署范围 | 一台机器 | 多台机器组成的集群 |
| 自动扩缩容 | 弱 | 强 |
| 故障恢复 | 基础 | 强 |
| 滚动发布 | 基础 | 强 |
| 学习成本 | 低 | 高 |
| 适合本地开发 | 很适合 | 较重 |
| 适合生产大规模系统 | 不太适合 | 适合 |

可以这样理解：

```text
Docker Compose 是本地开发和单机部署工具。
Kubernetes 是生产集群管理平台。
```

## 15. 最简单的理解

Docker 解决的是：

```text
怎么把一个应用和它的环境打包并运行起来。
```

Docker Compose 解决的是：

```text
怎么把多个容器按配置一次性启动起来。
```

Kubernetes 解决的是：

```text
怎么在一组服务器上稳定运行、扩容、更新、恢复大量容器。
```

对于 Kafka 学习和 Spring Boot 验证场景：

```text
Docker Compose 足够。
```

对于正式生产系统，尤其是有多个服务、多台服务器、高可用要求时：

```text
应该考虑 Kubernetes 或云厂商容器平台。
```
