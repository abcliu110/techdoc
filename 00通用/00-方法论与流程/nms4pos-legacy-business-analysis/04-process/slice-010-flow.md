# SLICE-010：云端数据同步

> **切片目标**：还原云端到门店的数据同步机制，包括 Canal 增量同步和门店本地缓存
> **优先级**：P0
> **停止条件**：同步机制和数据校验清晰

## 1. 数据同步架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              云端 (nms4cloud)                                │
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│  │   MySQL      │ → │    Canal     │ → │    Kafka     │                 │
│  │  (业务数据)   │    │  (增量监听)  │    │  (消息队列)   │                 │
│  └──────────────┘    └──────────────┘    └──────┬───────┘                 │
│                                                  │                          │
└──────────────────────────────────────────────────┼──────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           pos5sync (同步服务)                               │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ CanalWorker - Canal 客户端                                            │   │
│  │   - 订阅 MySQL binlog                                                │   │
│  │   - 解析增量数据                                                      │   │
│  │   - 事件转换                                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ CanalEventService - 事件处理                                          │   │
│  │   - 过滤需要同步的表                                                  │   │
│  │   - 按门店过滤 (sid)                                                 │   │
│  │   - 发送到 Kafka                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  代码位置: nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/    │
└─────────────────────────────────────────────────────────────────────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           门店 POS 终端                                     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ KafkaListenerForSync - Kafka 消费者                                   │   │
│  │   - 消费 Kafka 消息                                                  │   │
│  │   - 解析增量事件                                                      │   │
│  │   - 写入本地 SQLite                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ IncrementalSyncDataService - 增量同步                                 │   │
│  │   - 根据 tbl_name 路由到对应处理                                      │   │
│  │   - CLASS_MAP: 表名 → 实体类                                         │   │
│  │   - 写入本地表                                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  本地表: pos_local.db (SQLite)                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 2. Canal 增量同步机制

### 2.1 Canal 工作原理

Canal 是阿里巴巴开源的 MySQL binlog 增量订阅和消费组件：

```
┌─────────────┐     binlog      ┌─────────────┐
│   MySQL     │ ──────────────→ │   Canal     │
│  (Master)   │                 │   Server    │
└─────────────┘                 └──────┬──────┘
                                       │
                                       │  TCP/HTTP
                                       ▼
                               ┌─────────────┐
                               │   Client    │
                               │ (CanalWorker)│
                               └─────────────┘
```

### 2.2 CanalWorker 实现

```java
// nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/service/app/CanalWorker.java
@Slf4j
public class CanalWorker implements Runnable {
    @Override
    public void run() {
        // 1. 创建 Canal 连接器
        CanalConnector connector = CanalConnectors.newSingleConnector(
            new InetSocketAddress(properties.getAddress(), properties.getPort()),
            properties.getDestination(),
            properties.getUsername(),
            properties.getPassword()
        );

        try {
            connector.connect();
            connector.subscribe(".*\\..*");  // 订阅所有表
            connector.rollback();

            while (true) {
                // 2. 获取增量数据
                Message message = connector.getWithoutAck(batchSize);
                long batchId = message.getId();
                int size = message.getEntries().size();

                if (batchId != -1 && size > 0) {
                    // 3. 处理事件
                    eventService.handleCanalEvent(message.getEntries());
                    // 4. 确认消费
                    connector.ack(batchId);
                } else {
                    Thread.sleep(1000);  // 无数据则等待
                }
            }
        } finally {
            connector.disconnect();
        }
    }
}
```

### 2.3 事件类型

| 事件类型 | 说明 | 处理方式 |
|----------|------|----------|
| INSERT | 新增记录 | 插入本地表 |
| UPDATE | 更新记录 | 更新本地表 |
| DELETE | 删除记录 | 删除本地表（软删除） |

## 3. CanalEventService 事件处理

### 3.1 核心逻辑

```java
// nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/service/app/CanalEventService.java
@Slf4j
@Service
public class CanalEventService {
    public static final String TOPIC = "nms4cloud-pos5sync";

    public void handleCanalEvent(List<CanalEntry.Entry> entries) {
        for (CanalEntry.Entry entry : entries) {
            CanalEntry.EntryType entryType = entry.getEntryType();

            // 只处理 ROWDATA 事件
            if (!CanalEntry.EntryType.ROWDATA.equals(entryType)) {
                continue;
            }

            // 检查是否需要同步该表
            String tableName = entry.getHeader().getTableName();
            if (!tablesToBeMonitoredServicePlus.needSync(tableName)) {
                continue;
            }

            // 解析事件
            CanalEntry.RowChange rowChange = CanalEntry.RowChange.parseFrom(entry.getStoreValue());
            handleRowDataList(entry.getHeader(), tableName, rowChange);
        }
    }

    private void handleRowDataList(CanalEntry.Header header, String tableName,
                                   CanalEntry.RowChange rowChange) {
        List<CanalEvent> canalEvents = new ArrayList<>();

        for (CanalEntry.RowData rowData : rowChange.getRowDatasList()) {
            // 获取列数据
            List<CanalEntry.Column> columns = rowChange.getEventType() == CanalEntry.EventType.DELETE
                ? rowData.getBeforeColumnsList()
                : rowData.getAfterColumnsList();

            // 构建事件
            CanalEvent event = convert(header, tableName, rowChange.getEventType(), columns);

            // 按门店过滤
            if (sidToBeMonitoredServicePlus.needSync(event.getSid())) {
                canalEvents.add(event);
            }
        }

        // 发送到 Kafka
        for (CanalEvent event : canalEvents) {
            JSONObject json = buildMessage(event);
            kafkaTemplate.send(TOPIC, json.toJSONString());
        }
    }
}
```

### 3.2 消息格式

```json
{
    "mid": 1001,                    // 商户ID
    "sid": 2001,                    // 门店ID
    "lid": 1234567890,              // 逻辑编号
    "tbl_name": "pt_dish",          // 表名
    "type": "UPDATE",               // 事件类型: INSERT/UPDATE/DELETE
    "log_file_name": "binlog.001",  // binlog 文件名
    "execute_time": 1700000000,     // 执行时间戳(秒)
    "content": {                    // 变更数据(JSON)
        "lid": "1234567890",
        "name": "宫保鸡丁",
        "price": "38.00",
        "status": "1"
    }
}
```

## 4. 门店增量同步

### 4.1 表名映射

| 云端表名 | 门店本地表 | 说明 |
|----------|-----------|------|
| pt_dish | local_dish | 菜品表 |
| pt_dish_type | local_dish_type | 菜品分类 |
| pt_tbl | local_tbl | 桌台表 |
| pt_tbl_area | local_tbl_area | 区域表 |
| biz_member | local_member | 会员表 |
| biz_pay_way | local_pay_way | 支付方式 |
| pt_dish_price_special | local_dish_price_special | 特价菜 |

### 4.2 增量同步处理

```java
// IncrementalSyncDataService 核心映射
public class IncrementalSyncDataService {
    public static final Map<String, Class<?>> CLASS_MAP = new HashMap<>();

    static {
        CLASS_MAP.put("pt_dish", PtDish.class);
        CLASS_MAP.put("pt_dish_type", PtDishType.class);
        CLASS_MAP.put("pt_tbl", PtTbl.class);
        CLASS_MAP.put("pt_tbl_area", PtTblArea.class);
        CLASS_MAP.put("biz_member", BizMember.class);
        CLASS_MAP.put("biz_pay_way", BizPayWay.class);
        // ... 更多映射
    }

    public void sync(String tblName, CanalEvent event) {
        Class<?> entityClass = CLASS_MAP.get(tblName);
        if (entityClass == null) {
            log.warn("未知的表名: {}", tblName);
            return;
        }

        // 根据事件类型处理
        switch (event.getType()) {
            case "INSERT":
            case "UPDATE":
                upsert(entityClass, event);
                break;
            case "DELETE":
                softDelete(entityClass, event);
                break;
        }
    }
}
```

## 5. 同步配置管理

### 5.1 需要同步的表配置

```java
// TablesToBeMonitoredServicePlus
@Service
public class TablesToBeMonitoredServicePlus {
    public boolean needSync(String tableName) {
        // 从配置表读取需要同步的表
        // 默认同步: pt_dish, pt_dish_type, pt_tbl, pt_tbl_area, biz_member
        List<String> tables = getMonitoredTables();
        return tables.contains(tableName);
    }
}
```

### 5.2 需要同步的门店配置

```java
// SidToBeMonitoredServicePlus
@Service
public class SidToBeMonitoredServicePlus {
    public boolean needSync(long sid) {
        // 从配置表读取需要同步的门店
        // 只有配置了该 sid 的门店才同步
        return isSidMonitored(sid);
    }
}
```

## 6. 同步冲突处理

### 6.1 冲突场景

| 场景 | 描述 | 处理策略 |
|------|------|----------|
| 数据版本冲突 | 云端和本地同时修改同一记录 | 以云端时间戳为准 |
| 门店离线期间修改 | 本地修改后云端有更新 | 保留本地修改，云端标记冲突 |
| 删除冲突 | 本地有修改，云端已删除 | 以云端为准 |

### 6.2 冲突解决策略

```java
public SyncResult syncWithConflict(CanalEvent event, LocalRecord local) {
    long cloudTime = event.getExecuteTime();
    long localTime = local.getLastModifiedTime();

    if (cloudTime > localTime) {
        // 云端更新更新：直接应用云端变更
        return SyncResult.APPLY_CLOUD;
    } else if (cloudTime < localTime) {
        // 本地更新更新：标记冲突，人工处理
        return SyncResult.MARK_CONFLICT;
    } else {
        // 时间相同：以 lid 大的为准
        return event.getLid() > local.getLid()
            ? SyncResult.APPLY_CLOUD
            : SyncResult.MARK_CONFLICT;
    }
}
```

## 7. 同步性能优化

### 7.1 批量处理

```java
// 批量处理 Canal 事件
public void handleBatch(List<CanalEntry.Entry> entries) {
    // 按表分组
    Map<String, List<CanalEvent>> grouped = entries.stream()
        .filter(this::isRowData)
        .map(this::toCanalEvent)
        .filter(this::needSync)
        .collect(Collectors.groupingBy(CanalEvent::getTblName));

    // 批量写入
    for (Map.Entry<String, List<CanalEvent>> entry : grouped.entrySet()) {
        String tableName = entry.getKey();
        List<CanalEvent> events = entry.getValue();
        batchUpsert(tableName, events);
    }
}
```

### 7.2 增量索引

```sql
-- 本地表创建索引
CREATE INDEX idx_lid ON local_dish(lid);
CREATE INDEX idx_sid ON local_dish(sid);
CREATE INDEX idx_updated_time ON local_dish(updated_time);

-- 用于快速查询最新数据
SELECT * FROM local_dish
WHERE sid = ? AND updated_time > ?
ORDER BY updated_time;
```

## 8. 代码位置索引

| 功能 | 类 | 文件路径 |
|------|---|----------|
| Canal 客户端 | CanalWorker | pos5sync-biz/service/app/ |
| 事件处理 | CanalEventService | pos5sync-biz/service/app/ |
| Kafka 监听 | KafkaListenerForSync | pos5sync-biz/listeners/ |
| 表配置 | TablesToBeMonitoredServicePlus | pos5sync-biz/service/admin/ |
| 门店配置 | SidToBeMonitoredServicePlus | pos5sync-biz/service/admin/ |
| 增量同步 | IncrementalSyncDataService | (位置待确认) |

## 9. 同步状态监控

### 9.1 同步延迟指标

```java
// 监控同步延迟
public class SyncMonitor {
    public long getSyncDelay(String tableName) {
        long lastEventTime = getLastEventTime(tableName);
        long currentTime = System.currentTimeMillis() / 1000;
        return currentTime - lastEventTime;
    }

    public boolean isSyncHealthy(String tableName) {
        long delay = getSyncDelay(tableName);
        return delay < MAX_DELAY_SECONDS;  // 阈值: 5分钟
    }
}
```

### 9.2 同步异常告警

```yaml
# 同步告警配置
sync:
  alert:
    delay_threshold: 300  # 延迟超过5分钟告警
    error_threshold: 10   # 连续错误超过10次告警
    batch_size: 1000      # 每批处理1000条
```

## 10. 遗留问题

| 问题 | 描述 | 影响 | 验证方式 |
|------|------|------|----------|
| Q1 | 冲突处理的实际实现需验证 | 可能存在数据不一致 | 需读 IncrementalSyncDataService |
| Q2 | 同步失败的回滚机制不明 | 异常情况处理不确定 | 需读 CanalEventService |
| Q3 | 全量同步的触发条件不明 | 首次部署或恢复场景 | 需确认业务需求 |

## 11. 证据缺口

| 缺口ID | 缺口描述 | 优先级 |
|--------|----------|--------|
| G004 | IncrementalSyncDataService 具体实现不明 | 高 |
| G005 | 冲突处理的实际逻辑不明 | 中 |
| G006 | 全量同步机制不明 | 中 |
