# DA7 实现映射 — 打印系统

> **定位**：SOP-00 DA7 阶段产出物，建立业务概念到实现代码的映射关系，记录设计决策
> **版本**：v1.0 | **日期**：2026-08-05
> **执行人**：AI
> **依赖**：DA0-DA6 全系列文档

---

## 模板加载记录

```
**模板加载记录**：
- 模板文件：SOP-00-DA7-模板.md
- 加载时间：2026-08-05
- 版本：v1.0
- 门禁检查：3/3 项通过
```

---

## 一、核心类映射

### 1.1 任务生命周期映射

| 业务概念 | 实现类 | 模块 | 关键方法 | 代码行 | 证据 |
|---------|--------|------|---------|--------|------|
| 打印任务创建 | PosPrnJobServicePlus | pos2plugin-biz | create() | E-001:79 | E-001 |
| 打印任务重打 | PosPrnJobServicePlus | pos2plugin-biz | reprint() | E-001:929 | E-001 |
| 打印任务删除 | PosPrnJobServicePlus | pos2plugin-biz | delete() | E-001:978 | E-001 |
| 任务文件写入 | PosPrnJobServicePlus | pos2plugin-biz | keepToFile() | E-001:79 | E-001 |
| 任务文件读取 | PosPrnJobServicePlus | pos2plugin-biz | getFromFile() | E-001:79 | E-001 |
| 任务状态计算 | PosPrnJobServicePlus | pos2plugin-biz | resolveEffectiveStatus() | E-001:993 | E-001 |
| 打印次数递增 | PosPrnJobServicePlus | pos2plugin-biz | incrPrnCount() | E-001:1072 | E-001 |

### 1.2 打印分发映射

| 业务概念 | 实现类 | 模块 | 关键方法 | 代码行 | 证据 |
|---------|--------|------|---------|--------|------|
| ActiveMQ监听 | PrintJobActiveMQListener | pos3boot-biz | onMessage() | E-009 | E-009 |
| 任务初始化 | PrintInitMpScHandler | - | put(jobLid) | E-009 | E-009 |
| 任务分发 | PrintDispatchMpScHandler | - | put(dispatchJob) | E-009 | E-009 |
| 主备选择 | PrinterWorkerService | pos2plugin-service | handlePrnJob() | E-013:54 | E-013 |
| 转移规则查询 | PrinterTransferService | pos2plugin-biz | getTransfer() | E-001:1042 | E-001 |

### 1.3 打印执行映射

| 业务概念 | 实现类 | 模块 | 关键方法 | 代码行 | 证据 |
|---------|--------|------|---------|--------|------|
| 本地打印执行 | PrinterWorkerServiceLocalImpl | - | handlePrnJob() | E-013 | E-013 |
| 驱动打印处理 | DriverHandler | pos10printer-app | handle() | E-012:1 | E-012 |
| 协议基类 | PrintJobHandlerBase | pos10printer-app | handle() | E-011:1 | E-011 |
| 品牌映射 | PrintJobHandlerBase | pos10printer-app | getBrand() | E-011:36 | E-011 |
| 类型映射 | PrintJobHandlerBase | pos10printer-app | getType() | E-011:36 | E-011 |
| 离线打印执行 | PrinterWorkerServiceOfflineImpl | - | handlePrnJob() | E-013 | E-013 |
| 云打印执行 | PrinterWorkerServiceOnlineImpl | pos4cloud-biz | handlePrnJob() | 空实现 | E-015 |

### 1.4 WMS打印映射

| 业务概念 | 实现类 | 模块 | 关键方法 | 代码行 | 证据 |
|---------|--------|------|---------|--------|------|
| WMS打印渲染 | WmsPrintRenderService | pos4cloud-biz | render() | E-010:1 | E-010 |
| ESC/POS生成 | EscPosRenderService | pos4cloud-biz | generate() | E-010 | E-010 |
| 样式加载 | WmsPrintRenderService | pos4cloud-biz | loadStyle() | E-010:49 | E-010 |
| 参数替换 | WmsPrintRenderService | pos4cloud-biz | replaceParams() | E-010 | E-010 |

### 1.5 实体映射

| 业务概念 | 实现类 | 模块 | 主键 | 证据 |
|---------|--------|------|------|------|
| 打印任务 | PosPrnJob | pos2plugin-dal | lid | E-002 |
| 打印队列 | PosPrnQueue | pos2plugin-dal | lid | E-004 |
| 打印机 | PosPrnPrinter | pos2plugin-dal | lid | E-003 |
| 打印机转移 | PosPrnPrinterTransfer | pos2plugin-dal | id | E-001:1042 |
| 打印样式行 | PosPrnStyleRow | pos2plugin-dal | id | E-010 |
| 打印样式列 | PosPrnStyleCol | pos2plugin-dal | id | E-010 |

### 1.6 枚举映射

| 业务概念 | 实现类 | 模块 | 值范围 | 证据 |
|---------|--------|------|--------|------|
| 任务状态 | PrnJobStatusEnum | pos2plugin-api | PENDING/SUCCESS/FAILED | E-005 |
| 打印机状态 | PrinterStatus | pos2plugin-api | DEFAULT/FAULT/NORMAL/BUSY | E-006 |
| 打印机类型 | PrinterTypeEnum | pos2plugin-api | DRIVER/NET/COM/USB/LPT/CLOUD | E-007 |
| 打印样式类型 | PrnStyleTypeEnum | pos2plugin-api | 10-73业务, 1000-1048 WMS | E-007 |
| 打印机型号 | PrinterModelEnum | pos10printer | 20+品牌 | E-011:36 |

---

## 二、配置映射

### 2.1 运行时配置

| 配置项 | 配置位置 | 默认值 | 说明 | 证据 |
|--------|---------|--------|------|------|
| 任务文件路径 | PosPrnJobServicePlus | {appDir}/jobs/{date}/ | 按日期分目录 | E-001:79 |
| Redis计数Key | PosPrnJobServicePlus | pos_service:pos_prn_job:count:{lid} | 15分钟TTL | E-001:142 |
| 消息推送Key | PosPrnJobServicePlus | pos_service:pos_prn_job:{mid}:{sid} | 状态变更推送 | E-001 |
| 任务文件过期 | keepToFile() | 15分钟后改.del | 软删除 | E-001:79-80 |
| 文件物理删除 | PrintJobActiveMQListener | 30天 | 定时清理 | E-009 |
| 未完成任务加载 | PrintJobActiveMQListener | 45分钟 | 启动时恢复 | E-009:47 |

### 2.2 打印机扩展信息结构

| 打印机类型 | extraInfo结构 | 关键字段 | 证据 |
|-----------|--------------|---------|------|
| DRIVER | extraInfoDriver | driverName | E-012 |
| NET | extraInfoNet | ip, port, cutSound | E-012 |
| COM | extraInfoCom | port, baudRate | E-012 |
| USB/LPT | extraInfo | feedLines | E-012 |

### 2.3 样式配置结构

| 配置表 | 关键字段 | 加载条件 | 证据 |
|--------|---------|---------|------|
| pos_prn_style_row | content (支持{@fieldName}) | mid + sid + styleType | E-010:49 |
| pos_prn_style_col | width | mid + sid + styleType | E-010 |

---

## 三、设计决策记录（DEC 卡）

### DEC-001：打印任务内容与元数据分离存储

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要将打印内容存储在文件系统中，而不是直接存入数据库？ |
| 当时约束 | 数据库存储大文本效率低；打印内容可能较大（多行格式） |
| 可选方案 | A. 存数据库BLOB字段；B. 存文件系统；C. 压缩后存数据库 |
| 选择与理由 | 选择B（文件系统）。打印内容是临时数据（15分钟后过期），不应占用数据库长期空间；文件系统便于按日期清理；JSON格式便于调试查看。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 伤历史（历史任务详情不可查）；只伤未来（需维护文件存储） |

**证据**：E-001:79（keepToFile路径格式）

---

### DEC-002：打印次数使用Redis计数而非数据库更新

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要用Redis计数打印次数，而不是每次打印后直接更新数据库？ |
| 当时约束 | 高频打印场景下，频繁更新数据库造成性能瓶颈 |
| 可选方案 | A. 直接更新数据库；B. Redis计数+异步写回；C. 仅记录成功次数 |
| 选择与理由 | 选择B（Redis+DB回写）。Redis提供高性能计数；DB作为持久化和Redis失效时的回退源；TTL15分钟避免历史数据残留。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来（需维护Redis和DB一致性） |

**证据**：E-001:1072-1074（Redis计数逻辑），E-001:142（TTL 15分钟）

---

### DEC-003：打印队列主备使用逗号分隔存储

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要用逗号分隔的字符串存储多个打印机ID，而不是用关联表？ |
| 当时约束 | 简化查询，减少表关联 |
| 可选方案 | A. 关联表（pos_prn_queue_printer）；B. 逗号分隔字符串；C. JSON数组 |
| 选择与理由 | 选择B（逗号分隔）。查询时无需关联表；主备概念清晰；但不支持灵活的多对多关系。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 勉强（查询简单但扩展性差） |
| 当前合理性 | 仍合理（但限制了队列的灵活性） |
| 影响面 | 伤未来（难以支持复杂的多打印机策略） |

**证据**：E-004（PosPrnQueue.primaryPrinter/standbyPrinter字段）

---

### DEC-004：PrinterWorkerService三套实现（Local/Offline/Online）

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么设计三套PrinterWorkerService实现，而不是统一的实现？ |
| 当时约束 | 本地打印、云打印、离线打印的场景差异大 |
| 可选方案 | A. 统一实现（通过参数区分）；B. 三套独立实现；C. 策略模式+统一接口 |
| 选择与理由 | 选择C（策略模式+统一接口）。统一接口保证行为一致性；三套实现隔离差异；OnlineImpl为空实现说明云打印尚未完成。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来（OnlineImpl空实现需要完成） |

**证据**：E-013（PrinterWorkerService接口），E-015（OnlineImpl空实现）

---

### DEC-005：消息在事务提交后发布

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要确保消息在数据库事务提交后才发布？ |
| 当时约束 | 消费者可能在事务未提交时就开始处理，导致数据不存在 |
| 可选方案 | A. 先发消息再提交事务；B. 事务内发消息；C. 事务提交后发消息 |
| 选择与理由 | 选择C。保证消费者读到已提交的数据；通过TransactionSynchronization实现；避免分布式事务复杂性。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 伤未来（消息延迟增加） |

**证据**：E-001:1114-1125（TransactionSynchronization实现）

---

### DEC-006：打印样式类型使用大量枚举值

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要用70+个枚举值表示打印样式类型，而不是动态配置？ |
| 当时约束 | 打印样式与业务逻辑强关联，需要编译期检查 |
| 可选方案 | A. 枚举硬编码；B. 数据库配置；C. 枚举+扩展点 |
| 选择与理由 | 选择A（枚举硬编码）。编译期类型检查；IDE自动完成；便于代码维护。但WMS的50+种类型增长较快，可能需要动态化。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 部分过期（WMS打印场景增长，枚举膨胀） |
| 影响面 | 伤未来（新增WMS类型需修改代码） |

**证据**：E-007（PrnStyleTypeEnum枚举，70+值）

---

### DEC-007：使用Virtual Thread实现并发控制

| 字段 | 内容 |
|------|------|
| 决策点 | 为什么要使用Virtual Thread而不是线程池实现打印并发控制？ |
| 当时约束 | Java 21 Virtual Thread正式发布，降低并发编程复杂度 |
| 可选方案 | A. 传统线程池；B. Virtual Thread；C. CompletableFuture |
| 选择与理由 | 选择B。Virtual Thread简化并发编程；减少线程创建开销；便于实现打印任务的串行化控制。 |
| 成因分类 | 有意决策 |
| 当时合理性 | 合理 |
| 当前合理性 | 仍合理 |
| 影响面 | 只伤未来（依赖Java 21+） |

**证据**：E-013（PrinterWorkerServiceLocalImpl使用Virtual Thread）

---

## 四、代码架构映射图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           打印系统代码架构                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    nms4cloud-pos2plugin（业务层）                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │ PosPrnJobServicePlus                                         │    │   │
│  │  │ ├── create() ──→ INSERT DB + keepToFile() + Redis + MQ     │    │   │
│  │  │ ├── reprint() ──→ getFromFile() + create()                  │    │   │
│  │  │ ├── delete() ──→ DELETE + MQ                               │    │   │
│  │  │ ├── listVO() ──→ 状态计算                                   │    │   │
│  │  │ └── incrPrnCount() ──→ Redis INCR                           │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                       │
│                                     ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    nms4cloud-pos3boot（消息层）                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │ PrintJobActiveMQListener                                      │    │   │
│  │  │ ├── onMessage() ──→ PrintInitMpScHandler + PrintDispatch    │    │   │
│  │  │ ├── 启动时加载45分钟未完成任务                                 │    │   │
│  │  │ └── 清理30天前.del文件                                        │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                     │                                       │
│                                     ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PrinterWorkerService（执行层）                    │   │
│  │  ┌─────────────────┐ ┌──────────────────┐ ┌──────────────────┐     │   │
│  │  │ LocalImpl       │ │ OfflineImpl      │ │ OnlineImpl       │     │   │
│  │  │ (本地打印)      │ │ (离线打印)        │ │ (云打印-空)      │     │   │
│  │  └────────┬────────┘ └────────┬─────────┘ └────────┬─────────┘     │   │
│  └───────────┼──────────────────┼───────────────────┼───────────────┘   │
│              │                  │                   │                     │
│              ▼                  ▼                   │                     │
│  ┌───────────────────────────────────────────────────────┐              │
│  │              nms4cloud-pos10printer（驱动层）           │              │
│  │  ┌─────────────────────────────────────────────────┐  │              │
│  │  │ PrintJobHandlerBase                               │  │              │
│  │  │ ├── getBrand() ──→ PrinterModelEnum → PrinterBrand│ │              │
│  │  │ └── getType() ──→ PrinterTypeEnum → PrinterType  │  │              │
│  │  ├─────────────────────────────────────────────────┤  │              │
│  │  │ DriverHandler（Windows驱动打印）                   │  │              │
│  │  │ ├── handle() ──→ 打印执行                        │  │              │
│  │  │ ├── 参数替换 ──→ {@fieldName} / ${fieldName}   │  │              │
│  │  │ ├── 条码打印 ──→ ESC/POS指令                    │  │              │
│  │  │ └── 二维码打印 ──→ ESC/POS指令                  │  │              │
│  │  └─────────────────────────────────────────────────┘  │              │
│  └───────────────────────────────────────────────────────┘              │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    nms4cloud-pos4cloud（云端层）                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐    │   │
│  │  │ WmsPrintRenderService                                         │    │   │
│  │  │ ├── render() ──→ 加载样式 + 参数替换 + ESC/POS生成           │    │   │
│  │  │ ├── GBK字符集                                                 │    │   │
│  │  │ └── 58mm/80mm纸宽                                            │    │   │
│  │  └─────────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 五、关键代码示例

### 5.1 任务创建与文件写入（E-001:79）

```java
// 任务创建 + 文件写入 + Redis初始化 + MQ发布
public Long create(PosPrnJobCreateDTO dto) {
    Long lid = idWorker.nextId(); // BR-01: 全局唯一lid
    PosPrnJob job = new PosPrnJob();
    job.setLid(lid);
    // ... 设置其他字段 ...
    job.setStatus(PrnJobStatusEnum.PENDING.getCode());
    jobMapper.insertSelective(job);

    // BR-05: 文件按日期存储
    keepToFile(lid, dto);

    // BR-07: Redis计数初始化，TTL 15分钟
    redisTemplate.opsForValue().set(
        "pos_service:pos_prn_job:count:" + lid,
        "0",
        15, TimeUnit.MINUTES
    );

    // BR-12: 事务提交后发布消息
    TransactionSynchronizationManager.registerSynchronization(
        new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                mqPublishService.publishPrintTaskCreated(lid);
            }
        }
    );
    return lid;
}
```

### 5.2 主备打印机failover（E-001:54-59）

```java
// 主备打印机选择逻辑
private Long selectPrinter(Long queueLid) {
    PosPrnQueue queue = queueMapper.selectByPrimaryKey(queueLid);

    // 尝试主打印机
    for (Long printerId : parsePrinterIds(queue.getPrimaryPrinter())) {
        if (isPrinterHealthy(printerId)) {
            return printerId;
        }
    }

    // BR-10: 主打印机故障，切换备用
    for (Long printerId : parsePrinterIds(queue.getStandbyPrinter())) {
        if (isPrinterHealthy(printerId)) {
            return printerId;
        }
    }

    return null; // 主备都不可用
}
```

### 5.3 打印机转移规则（E-001:1042-1058）

```java
// 打印机转移规则查询
private Long applyTransfer(Long originalPrinterId, Long mid, Long sid) {
    PosPrnPrinterTransfer transfer = transferMapper.selectBySourcePrinter(
        originalPrinterId, mid, sid
    );
    if (transfer != null) {
        // 转移规则优先于队列静态配置
        return transfer.getTargetPrinterLid();
    }
    return originalPrinterId;
}
```

### 5.4 ESC/POS参数替换（E-012:1-50）

```java
// DriverHandler中的参数替换
public String replaceParams(String template, Map<String, Object> data) {
    // {@fieldName} 格式
    Pattern p1 = Pattern.compile("\\{@(\\w+)}");
    Matcher m1 = p1.matcher(template);
    String result = m1.replaceAll(match -> {
        String fieldName = m1.group(1);
        Object value = data.get(fieldName);
        return value != null ? value.toString() : "";
    });

    // ${fieldName} 格式
    Pattern p2 = Pattern.compile("\\$\\{(\\w+)}");
    Matcher m2 = p2.matcher(result);
    return m2.replaceAll(match -> {
        String fieldName = m2.group(1);
        Object value = data.get(fieldName);
        return value != null ? value.toString() : "";
    });
}
```

---

## 六、模块依赖关系

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           模块依赖拓扑                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  nms4pos-ui / nms4cloud-biz-ui                                              │
│           │                                                                  │
│           ▼                                                                  │
│  nms4cloud-pos2plugin-biz ──→ 业务层（核心服务）                            │
│           │                     ├── PosPrnJobServicePlus                     │
│           │                     ├── 打印机转移服务                           │
│           │                     └── 消息发布服务                             │
│           │                                                                  │
│           ▼                                                                  │
│  nms4cloud-pos2plugin-dal ──→ 数据访问层                                    │
│           │                     ├── PosPrnJobMapper                          │
│           │                     ├── PosPrnQueueMapper                        │
│           │                     ├── PosPrnPrinterMapper                      │
│           │                     └── PosPrnPrinterTransferMapper               │
│           │                                                                  │
│           ▼                                                                  │
│  nms4cloud-pos3boot ──→ 消息消费层                                          │
│           │                     └── PrintJobActiveMQListener                 │
│           │                                                                  │
│           ▼                                                                  │
│  nms4cloud-pos2plugin-service ──→ 执行层（策略模式）                        │
│           │                     ├── PrinterWorkerService（接口）             │
│           │                     ├── PrinterWorkerServiceLocalImpl            │
│           │                     ├── PrinterWorkerServiceOfflineImpl           │
│           │                     └── PrinterWorkerServiceOnlineImpl（空）      │
│           │                                                                  │
│           ▼                                                                  │
│  nms4cloud-pos10printer-app ──→ 驱动层                                     │
│           │                     ├── PrintJobHandlerBase                      │
│           │                     └── DriverHandler                            │
│                                                                             │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
│                                                                             │
│  nms4cloud-pos4cloud-biz ──→ 云端层（独立部署）                            │
│           │                     ├── WmsPrintRenderService                   │
│           │                     └── PrinterWorkerServiceOnlineImpl（空）     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 七、模板字段对照表

| 模板要求字段 | 实际输出位置 | 状态 |
|-------------|-------------|------|
| 核心类映射 | §1 | ✅ |
| 任务生命周期映射 | §1.1 | ✅ |
| 打印分发映射 | §1.2 | ✅ |
| 打印执行映射 | §1.3 | ✅ |
| WMS打印映射 | §1.4 | ✅ |
| 实体映射 | §1.5 | ✅ |
| 枚举映射 | §1.6 | ✅ |
| 配置映射 | §2 | ✅ |
| DEC卡 | §3 | ✅ |
| DEC-001（文件分离） | §3 | ✅ |
| DEC-002（Redis计数） | §3 | ✅ |
| DEC-003（逗号分隔） | §3 | ✅ |
| DEC-004（三套实现） | §3 | ✅ |
| DEC-005（事务后MQ） | §3 | ✅ |
| DEC-006（枚举类型） | §3 | ✅ |
| DEC-007（Virtual Thread） | §3 | ✅ |
| 代码架构映射图 | §4 | ✅ |
| 关键代码示例 | §5 | ✅ |
| 模块依赖关系 | §6 | ✅ |
| E-* 证据 | 每节 | ✅ |

**全面性检查**：
- [x] 覆盖全部核心业务概念到实现类的映射
- [x] 每个DEC卡包含全部8个字段
- [x] 包含关键代码示例
- [x] 覆盖所有设计怪点
- [x] 配置映射覆盖所有核心配置项

---

**DA7实现映射完成时间**：2026-08-05
**分析人**：AI
**状态**：✅ 完成，进入DA8阶段
