# Canal CDC 数据同步

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz、pos5sync-biz
> 核心源文件：`CanalEventController.java`、`CanalSyncService.java`
> 最后更新：2026-05-03

---

## 一、组件概述

**Canal**（`com.alibaba.otter:canal`）是阿里巴巴开源的 MySQL binlog 增量订阅与消费组件，实现了 MySQL CDC（Change Data Capture）。nms4pos 使用 Canal 将本地 POS 数据库的变更实时同步到云端，无需定时轮询，保证数据一致性。

**典型场景**：本地收银台修改了菜品价格，通过 Canal 实时感知 MySQL binlog 变化，将变更推送给 pos4cloud，再上传到 nms4cloud 主平台。

**一句话理解**：

- MySQL 负责存数据
- MySQL binlog 负责记录“谁变了”
- Canal Server 负责读取 binlog
- Canal Client 负责把变更取出来并交给业务代码处理

---

## 二、Maven 依赖

```xml
<!-- pos4cloud-biz / pos5sync-biz 共用 -->
<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.client</artifactId>
    <version>1.1.7</version>
</dependency>
<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.protocol</artifactId>
    <version>1.1.7</version>
</dependency>
```

---

## 三、核心实现

### 3.1 Canal 客户端创建

```java
// CanalEventController.java — Canal 连接配置
import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.client.CanalConnectors;

public CanalConnector createConnector() {
    // 方式一：单节点直连
    CanalConnector connector = CanalConnectors.newSingleConnector(
        new InetSocketAddress("192.168.1.100", 11111), // Canal Server 地址
        "example",       // destination（对应 Canal 实例名）
        "canal",         // username（Canal 用户名）
        "canal"          // password
    );

    // 方式二：ZooKeeper 高可用集群
    // CanalConnector connector = CanalConnectors.newClusterConnector(
    //     "192.168.1.101:2181,192.168.1.102:2181", // ZooKeeper 地址
    //     "example", "", ""
    // );

    return connector;
}
```

### 3.2 订阅 binlog 事件

```java
// CanalEventController.java — 订阅数据库变更
public void subscribe(CanalConnector connector) {
    connector.connect();  // 建立连接
    connector.subscribe(); // 订阅所有库表（可用正则过滤）

    // 推荐：精确订阅指定表，避免处理无关数据
    // connector.subscribe("pos_\\d+\\.pos_dish,pos_\\d+\\.pos_order");
}

// 批量轮询消费
while (running) {
    // 每次最多拉取 1000 条变更
    Message message = connector.getWithoutAck(100);

    long batchId = message.getId();
    try {
        List<Entry> entries = message.getEntries();
        if (entries.size() > 0) {
            processEntries(entries); // 处理变更事件
        }
        connector.ack(batchId); // 确认已处理
    } catch (Exception e) {
        connector.rollback(batchId); // 处理失败，回滚重试
        log.error("Canal 消息处理失败, batchId={}", batchId, e);
    }
}
```

### 3.3 解析 binlog Entry

```java
// CanalEventController.java — 解析 Entry
private void processEntries(List<Entry> entries) {
    for (Entry entry : entries) {
        // 只处理行数据变更（忽略 DDL）
        if (entry.getEntryType() != EntryType.ROWDATA) {
            continue;
        }

        RowChange rowChange;
        try {
            rowChange = RowChange.parseFrom(entry.getStoreValue());
        } catch (Exception e) {
            log.error("解析 RowChange 失败", e);
            continue;
        }

        // 获取表名
        String tableName = entry.getHeader().getTableName();

        // 遍历每一行变更
        for (RowData rowData : rowChange.getRowDatasList()) {
            EventType eventType = rowChange.getEventType();

            switch (eventType) {
                case INSERT:
                    // 解析新增行
                    handleInsert(tableName, rowData.getAfterColumnsList());
                    break;
                case UPDATE:
                    // 解析变更前后的值
                    handleUpdate(tableName,
                        rowData.getBeforeColumnsList(),
                        rowData.getAfterColumnsList());
                    break;
                case DELETE:
                    // 解析被删除的行
                    handleDelete(tableName, rowData.getBeforeColumnsList());
                    break;
            }
        }
    }
}
```

### 3.4 字段解析

```java
// CanalEventController.java — 解析字段值
private void handleInsert(String tableName, List<CanalEntry.Column> columns) {
    Map<String, String> data = new HashMap<>();
    for (CanalEntry.Column column : columns) {
        data.put(column.getName(), column.getValue());
    }

    log.info("INSERT: table={}, data={}", tableName, data);

    // 根据表名分发到不同业务处理器
    if ("pos_dish".equals(tableName)) {
        dishSyncService.syncDishInsert(data);
    } else if ("pos_order".equals(tableName)) {
        orderSyncService.syncOrderInsert(data);
    }
}

// 列值获取示例
private String getColumnValue(List<CanalEntry.Column> columns, String name) {
    return columns.stream()
        .filter(c -> c.getName().equals(name))
        .findFirst()
        .map(CanalEntry.Column::getValue)
        .orElse(null);
}
```

---

## 四、在 nms4pos 中的实际使用方式

### 4.1 当前系统中的角色划分

结合 `nms4pos` 代码与 Nacos 配置，当前系统里的角色不是“所有模块都直接连 Canal”，而是下面这种结构：

```text
MySQL
  ↓ binlog
Canal Server（独立服务）
  ↓ TCP 11111
pos5sync（Canal Client）
  ↓ 解析 / 过滤 / 转换
Kafka
  ↓
pos4cloud（Kafka 消费者）
  ↓
Netty / RocketMQ / 云端业务
```

### 4.2 谁是 Canal Server

`Canal Server` 不是 MySQL，也不是项目里的某个 Java 类，它是**独立部署的 Canal 服务进程**。

当前 Nacos 配置如下：

```yaml
pos5sync:
  canals:
    - address: 10.11.254.13
      port: 11111
      destination: example
    - address: 10.11.255.25
      port: 11111
      destination: example
```

说明：

- `10.11.254.13:11111` 是一台 Canal Server
- `10.11.255.25:11111` 是另一台 Canal Server
- `destination: example` 是 Canal 实例名

### 4.3 谁是 Canal Client

当前系统中的 `Canal Client` 是 `pos5sync` 模块里的消费线程，例如 `CanalWorker`。

它负责：

- 连接 Canal Server
- 订阅变更事件
- 拉取 binlog 对应的数据变更
- 解析成业务事件
- 发送到 Kafka

### 4.4 pos4cloud 在这条链路里的角色

当前代码实现里，`pos4cloud` 更准确地说是 **Kafka 消费者**，不是主要的 Canal Client。

也就是说，文档里如果写“pos4cloud 也部署了 Canal Client”，要以实际代码为准。当前主链路是：

- `pos5sync` 直连 Canal Server
- `pos4cloud` 消费 `pos5sync` 发出的 Kafka 消息

---

## 五、初学者理解这套同步原理

可以把它想成“仓库发货”的过程：

- `MySQL`：仓库，真正放货
- `binlog`：发货记录单，记录谁被新增、修改、删除
- `Canal Server`：分拣中心，负责盯着发货记录
- `Canal Client`：收货员，负责把货领回来并处理
- `Kafka / RocketMQ`：中转站，把消息继续分发给其他系统

所以这套方案的关键不是“定时查数据库”，而是：

- 数据一变
- binlog 就记下来
- Canal 读到这个日志
- 业务系统立刻接着处理

这就是 **基于日志的增量同步**。

---

## 六、只能使用 MySQL 数据库吗

按当前这套方案，**是以 MySQL 为前提的**。

原因：

1. Canal 的核心就是读取 **MySQL binlog**
2. 需要源数据库开启 `log_bin`
3. 通常要求 `binlog_format=ROW`

所以：

- **当前实现只适用于 MySQL 类场景**
- **CDC 这个思想不只属于 MySQL**
- 但如果换 PostgreSQL、Oracle、SQL Server，就要换对应的日志订阅方案，不能直接照搬 Canal

---

## 七、企业中通常怎么做

### 7.1 Canal Server 是不是阿里云默认提供的

不是。

`Canal` 是阿里巴巴开源组件，不是“阿里云默认帮你开好的托管服务”。企业里通常有两种做法：

1. 自建 Canal Server
2. 使用云厂商托管的数据同步产品（例如 DTS 一类）

当前系统明显属于 **自建 Canal**：

- Nacos 里明确配置了两台 Canal Server 地址
- 应用代码通过这些地址主动去连接

### 7.2 企业里常见部署方式

常见做法：

1. Canal Server 单独部署在 Linux 服务器、Docker 或 K8s 中
2. Canal Server 连接 MySQL 主库或可读取 binlog 的实例
3. 业务系统中的 Canal Client 去连接 Canal Server
4. 再通过 Kafka / RocketMQ 分发给多个下游系统

常见链路：

```text
MySQL -> Canal Server -> Kafka -> 多个业务系统
```

这样做的好处：

- 采集职责和业务职责分离
- 下游解耦
- 更容易扩展多个消费者
- 更适合企业级监控和运维

---

## 八、K8s 中部署 Canal Server

### 8.1 是否有现成镜像

有。Canal Server 可以使用现成的 Docker 镜像，例如：

- `canal/canal-server`

在 K8s 中通常就是把它作为一个独立服务部署。

### 8.2 最小可用 K8s 示例

下面是一份最小可用示例：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: canal-config
  namespace: middleware
data:
  canal.properties: |
    canal.ip =
    canal.port = 11111
    canal.destinations = example
    canal.serverMode = tcp
    canal.auto.scan = false

  instance.properties: |
    canal.instance.mysql.slaveId = 1234
    canal.instance.master.address = 10.0.1.18:3306
    canal.instance.dbUsername = canal
    canal.instance.dbPassword = canal_password
    canal.instance.connectionCharset = UTF-8
    canal.instance.tsdb.enable = true

    canal.instance.filter.regex = .*\\..*
    canal.instance.gtidon = false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: canal-server
  namespace: middleware
spec:
  replicas: 1
  selector:
    matchLabels:
      app: canal-server
  template:
    metadata:
      labels:
        app: canal-server
    spec:
      containers:
        - name: canal-server
          image: canal/canal-server:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 11111
              name: tcp-11111
          volumeMounts:
            - name: canal-config
              mountPath: /home/admin/canal-server/conf/canal.properties
              subPath: canal.properties
            - name: canal-config
              mountPath: /home/admin/canal-server/conf/example/instance.properties
              subPath: instance.properties
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"
            limits:
              cpu: "1"
              memory: "1Gi"
      volumes:
        - name: canal-config
          configMap:
            name: canal-config
---
apiVersion: v1
kind: Service
metadata:
  name: canal-server
  namespace: middleware
spec:
  selector:
    app: canal-server
  ports:
    - name: tcp-11111
      port: 11111
      targetPort: 11111
  type: ClusterIP
```

### 8.3 在 K8s 中如何给 pos5sync 配置地址

如果 `pos5sync` 也跑在 K8s 中，可以把地址配成 Service 名称：

```yaml
pos5sync:
  canals:
    - address: canal-server.middleware.svc.cluster.local
      port: 11111
      destination: example
```

### 8.4 生产环境建议

最小示例只适合验证链路，生产环境建议至少补上：

- 固定镜像版本，不直接用 `latest`
- `readinessProbe` 和 `livenessProbe`
- 配置持久化和日志采集
- 明确是一库一实例还是多库多实例
- 明确主备或高可用策略

---

## 九、部署注意事项

| 配置项 | 说明 | nms4pos 默认值 |
|--------|------|---------------|
| Canal Server 端口 | Canal Server 监听端口 | 11111 |
| destination | Canal 实例名，需与 server 配置匹配 | `example` |
| batchSize | 每次拉取的最大消息数 | 1000 |
| 过滤规则 | 正则表达式过滤表 | 订阅所有库表 |
| 连接超时 | 客户端与 server 的连接超时 | 60 秒 |

### 注意事项

1. **需要开启 MySQL binlog**：Canal 依赖 MySQL 的 binlog 复制，MySQL 配置中需要设置 `log_bin=mysql_bin` 和 `binlog_format=ROW`
2. **Canal Server 独立部署**：建议部署在靠近 MySQL 的网络环境中，通常是 Linux 服务器、容器或 K8s
3. **pos5sync 的消费确认要谨慎**：如果消息还没真正安全写入下游，就提前 `ack`，有可能丢数据
4. **高可用方案**：生产环境可采用 Canal + ZooKeeper 或结合消息队列做更稳妥的高可用与重试机制
5. **过滤配置要准确**：表过滤、门店过滤如果配置错误，业务上会表现为“漏同步”

---

## 十、相关文档

- [Kafka消息队列使用](./Kafka消息队列使用.md)
- [RocketMQ消息中间件](./RocketMQ消息中间件.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)
