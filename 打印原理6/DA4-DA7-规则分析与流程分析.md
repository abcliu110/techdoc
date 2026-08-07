# DA4-DA7 规则分析与流程分析

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | 打印相关模块 |
| 分析时间 | 2026-08-04 |

---

## 一、业务规则分析

### 1.1 打印分发规则

#### 规则1：主备打印机选择
```
IF 主打印机集合非空 THEN
    过滤故障打印机
    IF 有健康打印机 THEN
        使用随机负载均衡选择一台
        分发任务
    ELSE IF 备用打印机非空 THEN
        过滤故障打印机
        IF 有健康备用打印机 THEN
            使用随机负载均衡选择一台
            分发任务
        ELSE
            重试（2秒延迟）
    ELSE
        重试（2秒延迟）
ELSE
    重试（2秒延迟）
```

#### 规则2：故障重定向
```
当 PrinterWorker 检测到打印机状态 != NORMAL 时：
1. 暂停该打印机线程
2. 查询 PosPrnPrinterTransfer 规则
3. 获取目标打印机
4. 将队列中的 Pending 任务重新分发到目标打印机
```

#### 规则3：超时丢弃
```
任务生命周期超时（45分钟）：不再重试，直接丢弃
任务创建超时（30分钟）：PrinterWorker 不再处理该任务
```

### 1.2 打印内容渲染规则

#### 规则4：条件显示
```
格式: {参数} {操作符} {值}
示例: amount > 0
操作符: >, =, <>, <
支持类型: BigDecimal, Integer, Boolean, String
```

#### 规则5：补打标识
```
IF prnCount > 0 THEN
    打印红色提示文本："注：此单为补打单，如果之前已经收到过，可以忽略"
    隐藏 hideWhenZero=true 的行
```

#### 规则6：零值隐藏
```
IF hideWhenZero=true AND amount=0 THEN
    跳过该行，不打印
```

### 1.3 打印样式规则

#### 规则7：宽度计算
```
纸张宽度：80mm（标准热敏小票）
每列宽度百分比必须加起来接近100%
宽度格式: "XX%"
```

#### 规则8：字号映射
| 前端字号 | 后端字号 | 描述 |
|---|---|---|
| STANDARD | 11pt | 标准 |
| DOUBLE_WIDTH | 13pt | 倍宽 |
| DOUBLE_HEIGHT | 15pt | 倍高 |
| DOUBLE_WIDTH_AND_HEIGHT | 21pt | 倍宽高 |
| NINE | 9pt | 小九号 |
| FOUR_TIMES | 32pt | 四倍大 |

---

## 二、交互流程分析

### 2.1 打印任务完整生命周期

```
┌─────────────────────────────────────────────────────────────┐
│                    Phase 1: 任务创建                          │
├─────────────────────────────────────────────────────────────┤
│ 业务系统（订单/结账等）                                        │
│     ↓ MQ消息                                                 │
│ PrintJobActiveMQListener.onMessage()                        │
│     ↓                                                       │
│ PosPrnJobMapper.insert(PosPrnJob)                           │
│     ↓ 持久化到MySQL                                          │
│ PosPrnJobServicePlus.keepToFile(job) → Redis                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 2: 任务初始化                        │
├─────────────────────────────────────────────────────────────┤
│ PrintJobActiveMQListener.initJob(jobLid)                    │
│     ↓                                                       │
│ PrintInitMpScHandler.put(jobLid) → 内存队列                   │
│     ↓                                                       │
│ PosPrnQueueServicePlus.initJob()                            │
│     ├── 从Redis加载任务数据                                   │
│     ├── 加载打印样式模板 PosPrnStyleRow                      │
│     ├── 数据源填充 PrintJobInitUtil.convert()                │
│     └── 重新保存到Redis                                      │
│     ↓                                                       │
│ PrintUtil.dispatchJob() → 分发阶段                           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 3: 任务分发                          │
├─────────────────────────────────────────────────────────────┤
│ PrintDispatchMpScHandler.put(dispatchJob) → 内存队列         │
│     ↓                                                       │
│ PosPrnQueueServicePlus.dispatchJob()                        │
│     ├── 获取打印队列 PosPrnQueue                             │
│     ├── 解析主打印机列表（逗号分隔 → Set<Long>）               │
│     ├── 应用转发规则 resolveTargets()                        │
│     ├── 过滤故障打印机 selectHealthyPrinters()              │
│     ├── 随机负载均衡 RandomLoadBalanceUtil.random()         │
│     └── PrintUtil.handle() → 提交到打印机                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 4: 打印执行                          │
├─────────────────────────────────────────────────────────────┤
│ PrinterWorkerService.handlePrnJob()                         │
│     ↓                                                       │
│ PrinterWorker.run() (虚拟线程)                               │
│     ├── getStatus() → 检查打印机状态                         │
│     ├── IF 状态 != NORMAL → redirect() → 重发到其他打印机    │
│     └── runInner(dispatchJob)                               │
│         ├── 从文件加载任务详情 PrnJobCreateDTO               │
│         ├── 超时检查（30分钟）                               │
│         ├── 渲染打印内容 buildPrintJob()                     │
│         │   ├── 遍历 rows                                   │
│         │   ├── 遍历 cols                                   │
│         │   │   ├── 解析宽度/对齐/字号/颜色                  │
│         │   │   └── 构建 Prn_PrintJobItem                  │
│         │   └── 补打提示（prnCount > 0）                     │
│         └── handler.handle(Prn_PrintJob)                   │
│             ├── 选择处理器（根据 type 和 model）             │
│             └── 调用底层驱动/云API完成打印                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Phase 5: 任务归档                         │
├─────────────────────────────────────────────────────────────┤
│ IF handle() 返回 true THEN                                  │
│     PosPrnJobServicePlus.removeFromFile() → 从Redis删除      │
│     PosPrnJob.print = true                                  │
│ ELSE                                                        │
│     posPrnJobServicePlus.addPrnCount() → 补打计数+1          │
│     put(dispatchJob, 10秒) → 重试                           │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 故障恢复流程

```
┌────────────────────────────────────────────┐
│ 打印机故障检测                               │
│ PrinterWorker.getStatus() = FAULT           │
└────────────────────────────────────────────┘
                    ↓
┌────────────────────────────────────────────┐
│ 暂停当前打印机线程                           │
│ PrinterWorker.stopped = true               │
└────────────────────────────────────────────┘
                    ↓
┌────────────────────────────────────────────┐
│ 重定向 Pending 任务                         │
│ Iterator<DelayedElement> it = iterator()   │
│     FOR each dispatchJob IN queue:         │
│         查询 PosPrnQueue                   │
│         解析主/备打印机列表                 │
│         查找转发规则                       │
│         PrintUtil.dispatchJob(job)         │
│         it.remove()                        │
└────────────────────────────────────────────┘
                    ↓
┌────────────────────────────────────────────┐
│ 启动备打印机线程                           │
│ PrinterWorker(printer=target).start()      │
└────────────────────────────────────────────┘
```

### 2.3 云打印流程

```
┌────────────────────────────────────────────┐
│ PrinterWorker.handler = XpCloudPrinter     │
│ 或 JBCloudPrinter                          │
└────────────────────────────────────────────┘
                    ↓
┌────────────────────────────────────────────┐
│ handler.handle(Prn_PrintJob)               │
│     ├── 渲染票据内容                       │
│     ├── 转换为字节流/图片                   │
│     └── 调用云打印API                      │
│         ├── XpCloudPrinter                │
│         │   → 芯燚云HTTP API              │
│         └── JBCloudPrinter                │
│             → 精打云HTTP API              │
└────────────────────────────────────────────┘
```

---

## 三、数据模型分析

### 3.1 核心表结构

**pos_prn_queue（打印队列）**
```sql
CREATE TABLE pos_prn_queue (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL,
  sid BIGINT NOT NULL,
  lid BIGINT NOT NULL UNIQUE,
  name VARCHAR(64),
  pc_lid BIGINT DEFAULT -1,  -- -1表示通用
  primary_printer VARCHAR(1024),  -- 逗号分隔的打印机LID
  standby_printer VARCHAR(1024),  -- 逗号分隔的备用打印机LID
  created_time DATETIME,
  updated_time DATETIME
);
```

**pos_prn_printer（打印机）**
```sql
CREATE TABLE pos_prn_printer (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL,
  sid BIGINT NOT NULL,
  lid BIGINT NOT NULL UNIQUE,
  name VARCHAR(64),
  type VARCHAR(32),  -- NET/COM/USB/Driver/Cloud
  model VARCHAR(32),
  pc_lid BIGINT DEFAULT -1,
  extra_info JSON,  -- 连接参数
  created_time DATETIME,
  updated_time DATETIME
);
```

**pos_prn_job（打印任务）**
```sql
CREATE TABLE pos_prn_job (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL,
  sid BIGINT NOT NULL,
  lid BIGINT NOT NULL UNIQUE,
  biz_bill_id VARCHAR(64),  -- 关联业务单据
  type_ VARCHAR(32),  -- 打印类型
  purpose INT,  -- 用途：1厨房联/2划菜联/3楼面联
  prn_queue_lid BIGINT,  -- 打印队列
  prn_printer_lid BIGINT,  -- 分发的打印机
  prn_count INT DEFAULT 0,  -- 打印次数
  print BOOLEAN DEFAULT FALSE,
  status INT DEFAULT 1,  -- 1PENDING/2SUCCESS/3FAILED
  created_time DATETIME,
  updated_time DATETIME
);
```

**pos_prn_style_row（打印样式行）**
```sql
CREATE TABLE pos_prn_style_row (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL,
  sid BIGINT NOT NULL,
  lid BIGINT NOT NULL UNIQUE,
  ds_id VARCHAR(64),  -- 数据源ID
  style_type VARCHAR(32),  -- 适用的打印类型
  show_index INT,  -- 显示顺序
  display_condition VARCHAR(256),  -- 显示条件
  summarize BOOLEAN,  -- 是否汇总
  created_time DATETIME
);
```

---

## 四、关键实现映射

### 4.1 服务职责映射

| 功能 | 实现类 | 仓库 |
|---|---|---|
| 任务初始化 | `PrintInitMpScHandler` | pos3boot |
| 任务分发 | `PrintDispatchMpScHandler` | pos3boot |
| 队列管理 | `PosPrnQueueServicePlus` | pos2plugin |
| 任务持久化 | `PosPrnJobServicePlus` | pos2plugin |
| 转发规则 | `PosPrnPrinterTransferServicePlus` | pos2plugin |
| 打印执行 | `PrinterWorker` | pos3boot |
| 打印处理器 | `PrintJobHandlerBase` | pos2plugin |

### 4.2 配置映射

| 配置 | 来源 | 说明 |
|---|---|---|
| 打印样式 | `pos_prn_style_row/col` 表 | 每门店每类型独立配置 |
| 打印机参数 | `PosPrnPrinter.extraInfo` | JSON格式存储 |
| 队列缓存 | Redis `pos_prn_queue:{sid}:{lid}` | 热点数据缓存 |
| 任务数据 | Redis `pos_prn_job:{lid}` | 打印内容存储 |

---

## DA4-DA7 结论

**核心规则：8条**（分发/重定向/超时/渲染/补打/隐藏/宽度/字号）
**核心流程：3个**（完整生命周期/故障恢复/云打印）
**核心表：4张**

---

## G0-D 门禁结论：通过

规则和流程分析已完成，关键实现已映射，可进入最终交付阶段。
