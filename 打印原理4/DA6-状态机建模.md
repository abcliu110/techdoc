# DA6 状态机建模
# 打印任务生命周期状态机

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA6-PRINT-001 |
| 建模时间 | 2026/08/03 |
| 状态 | 初稿 |
| 参考文档 | DA2-概念建模, DA5-不变量建模 |

---

## 1. 状态机体系概览

### 1.1 核心状态

| 状态 | 枚举值 | 含义 | 说明 |
|------|--------|------|------|
| PENDING | 1 | 待处理 | 任务已创建，等待执行 |
| SUCCESS | 2 | 成功 | 打印任务执行成功完成 |
| FAILED | 3 | 失败 | 打印任务执行失败 |

### 1.2 状态转换图

```
                    ┌─────────────────────────────────────────┐
                    │                                         │
                    │   ┌───────────┐     ┌───────────┐      │
                    │   │  PENDING  │────►│  SUCCESS  │      │
                    │   └─────┬─────┘     └───────────┘      │
                    │         │                               │
                    │         │ 重试成功                       │
                    │         │                               │
                    │         ▼                               │
                    │   ┌───────────┐                         │
              首次  │   │  SUCCESS  │                         │
              执行  │   └───────────┘                         │
                    │                                         │
                    │   ┌───────────┐     ┌───────────┐      │
                    │   │  PENDING  │────►│  FAILED   │      │
                    │   └───────────┘     └───────────┘      │
                    │         │                               │
                    │         │ 重试失败/超时/取消             │
                    │         │                               │
                    │         ▼                               │
                    │   ┌───────────┐                         │
                    │   │  FAILED   │                         │
                    │   └───────────┘                         │
                    │                                         │
                    └─────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────┐
    │                      状态转换事件                            │
    ├─────────────────────────────────────────────────────────────┤
    │                                                              │
    │  PENDING → SUCCESS:                                          │
    │    - handler.handle(job) 返回 true                          │
    │                                                              │
    │  PENDING → FAILED:                                           │
    │    - handler.handle(job) 返回 false                         │
    │    - 打印机状态检查失败 (status != NORMAL)                   │
    │    - 打印任务超时 (>30分钟)                                  │
    │    - 打印任务不存在                                          │
    │                                                              │
    │  FAILED → SUCCESS (重试成功):                                │
    │    - 下次执行时 handler.handle(job) 返回 true                │
    │                                                              │
    │  FAILED → FAILED (重试失败):                                 │
    │    - 连续重试多次仍失败                                      │
    │                                                              │
    └─────────────────────────────────────────────────────────────┘
```

---

## 2. 状态转换规格

### 2.1 PENDING → SUCCESS

**触发条件：**
```
handler.handle(job) == true
```

**转换条件：**
```
1. PrinterWorker 从队列中取出 DispatchJobDTO
2. 调用 handlePrintJob(prnJob)
3. 遍历打印内容，渲染到物理打印机
4. 所有内容渲染成功，返回 true
5. 更新任务状态为 SUCCESS
6. 删除任务文件
```

**代码证据：**
```java
// PrinterWorker.java:190-193
if (handlePrintJob(prnJob)) {
    log.error("成功处理打印任务:{}_{}", jobLid, prnJob.getBizBillId());
    posPrnJobServicePlus.removeFromFile(prnJob.getMid(), prnJob.getSid(), prnJob.getLid());
}
```

```java
// PosPrnJobServicePlus.java:124-136
CompletableFuture.runAsync(() -> {
    boolean updated = Chain.forUpdate(mapper)
        .set(PosPrnJob::getPrint, true)
        .set(PosPrnJob::getPrintAt, LocalDateTime.now())
        .set(PosPrnJob::getStatus, PrnJobStatusEnum.SUCCESS)
        .eq(PosPrnJob::getLid, lid)
        .update();
});
```

---

### 2.2 PENDING → FAILED

**触发条件（多种）：**

| 触发条件 | 说明 | 处理方式 |
|----------|------|----------|
| 打印机状态异常 | status != NORMAL | 任务重定向，标记FAILED |
| 打印任务超时 | 超过30分钟未处理 | 直接标记FAILED |
| 打印任务不存在 | getFromFile返回null | 结束处理 |
| handle返回false | 渲染失败 | 重试或标记FAILED |

**超时处理代码：**
```java
// PrinterWorker.java:180-188
LocalDateTime jobDate = IdWorkerPlus.parseDateTime(prnJob.getLid());
if (Duration.between(jobDate, LocalDateTime.now()).toMinutes() > 30) {
    log.error("打印任务超时:{}，超过30分钟不再处理", jobLid);
    posPrnJobServicePlus.archiveFailed(prnJob.getMid(), prnJob.getSid(), prnJob.getLid(), "Print task timeout");
    return;
}
```

**失败处理代码：**
```java
// PrinterWorker.java:194-197
} else {
    log.error("失败处理打印任务:{}_{}", jobLid, prnJob.getBizBillId());
    posPrnJobServicePlus.addPrnCount(jobLid);
    put(dispatchJob, 10 * 1000, 0);  // 10秒后重试
}
```

---

### 2.3 状态转换约束

**约束SM-01：状态只能向前转换**

```
允许的转换序列：
  PENDING → SUCCESS
  PENDING → FAILED
  FAILED → SUCCESS (重试成功)
  FAILED → FAILED (重试失败)

不允许的转换：
  SUCCESS → 任何状态 (终态)
  FAILED → PENDING (不能回退)
  PENDING → PENDING (不能重复)
```

**约束SM-02：SUCCESS是终态**

```
一旦任务状态变为 SUCCESS：
  - 任务文件被删除
  - 状态不可变更
  - 不再参与重试
```

**约束SM-03：FAILED后自动重试**

```
任务状态变为 FAILED 后：
  - 打印计数 +1 (addPrnCount)
  - 任务放回队列，10秒后重试
  - 最多重试次数 = 打印计数上限
```

---

## 3. 打印计数机制

### 3.1 计数规则

```
打印计数 (prnCount) 用于：
  1. 跟踪任务重试次数
  2. 控制重复打印的样式行 (hideWhenZero)
  3. 标识任务执行状态

初始值：0
每次失败：+1
重置条件：任务成功
```

### 3.2 计数存储

**Redis存储：**
```java
// PosPrnJobServicePlus.java:142
redisTemplatePlus.incWithExpire(KEY_FOR_COUNT_IN_REDIS + lid, 15, TimeUnit.MINUTES);
```

**有效期：** 15分钟
**过期后：** 下次查询时重新初始化为数据库中的值

### 3.3 计数使用

```java
// PrinterWorker.java:225
if (prnCount == 0 && Boolean.TRUE.equals(row.getHideWhenZero())) {
    // 打印次数超过1的时候，不打印的行
    continue;
}
```

---

## 4. 打印机状态机

### 4.1 打印机状态枚举

| 状态 | 枚举值 | 含义 |
|------|--------|------|
| NORMAL | 0 | 正常，可接受任务 |
| FAULT | 1 | 故障，无法打印 |
| BUSY | 2 | 忙碌，队列积压 |

### 4.2 打印机状态转换图

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌──────────┐    状态检查失败     ┌──────────┐            │
│   │  NORMAL  │───────────────────►│   FAULT  │            │
│   └────┬─────┘                    └────┬─────┘            │
│        │                               │                   │
│        │ 状态恢复                      │                  │
│        │                               │                  │
│        ▼                               ▼                   │
│   ┌──────────┐                    ┌──────────┐            │
│   │  NORMAL  │◄───────────────────│   BUSY   │            │
│   └──────────┘    队列清空         └──────────┘            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 状态处理逻辑

```java
// PrinterWorker.java:82-98
PrinterStatus status = getStatus();
printerWorkerService.addPrinterStatus(printer.getLid(), status);

if (status != PrinterStatus.NORMAL) {
    redirect();  // 重定向任务到其他打印机
    logPrinterFault(status);
    Thread.sleep(Duration.ofSeconds(5));  // 5秒后重试
    continue;
}
logPrinterRecovered();  // 故障恢复日志
```

---

## 5. 任务分发状态

### 5.1 分发流程状态

```
┌────────────────────────────────────────────────────────────────┐
│                      任务分发状态流转                            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│   创建任务 (PosPrnJobServicePlus.create)                       │
│        │                                                        │
│        ▼                                                        │
│   文件存储 (任务详情写入文件)                                    │
│        │                                                        │
│        ▼                                                        │
│   消息通知 (MQ通知PrinterWorker)                                │
│        │                                                        │
│        ▼                                                        │
│   队列积压 (PrinterWorker阻塞队列)                              │
│        │                                                        │
│        ▼                                                        │
│   线程执行 (PrinterWorker.runInner)                            │
│        │                                                        │
│        ├─────► 成功 ──► 删除文件 ──► 更新状态为SUCCESS         │
│        │                                                        │
│        └─────► 失败 ──► 重试计数+1 ──► 放回队列 ──► 重试       │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 5.2 状态持久化

**数据库字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| status | PrnJobStatusEnum | 任务状态 |
| print | Boolean | 是否已打印 |
| printAt | LocalDateTime | 打印时间 |
| prnCount | Integer | 打印次数 |

**文件存储：**
- 任务详情存储在文件中：`/prn_jobs/{lid}.json`
- 成功时删除文件
- 失败时保留文件供重试

---

## 6. 异常状态处理

### 6.1 超时任务

```
定义：任务创建超过30分钟未处理
处理：
  1. 记录超时日志
  2. 更新状态为 FAILED
  3. 设置失败原因为 "Print task timeout"
  4. 清理任务文件
```

### 6.2 丢失任务

```
定义：任务文件不存在 (getFromFile返回null)
处理：
  1. 记录错误日志
  2. 结束当前处理
  3. 任务状态保持 PENDING（最终超时）
```

### 6.3 无限重试保护

```
保护机制：
  1. prnCount 存储在 Redis，过期时间15分钟
  2. Redis 过期后重新从数据库加载
  3. 无明确的最大重试次数限制
  4. 最终依赖超时机制 (30分钟) 兜底
```

---

## 7. 状态转换时序图

### 7.1 成功流程

```
用户/系统          PrintJobGenerator       PosPrnJobService      PrinterWorker
    │                     │                       │                    │
    │ generateXxxJob()    │                       │                    │
    │────────────────────►│                       │                    │
    │                     │ create()              │                    │
    │                     │──────────────────────►│                    │
    │                     │                       │ 文件存储            │
    │                     │                       │ 状态=PENDING        │
    │                     │                       │                    │
    │                     │       MQ消息          │                    │
    │                     │◄──────────────────────│                    │
    │                     │                       │                    │
    │                     │                       │  任务文件           │
    │                     │                       │───────────────────►│
    │                     │                       │                    │
    │                     │                       │                    │ handlePrintJob()
    │                     │                       │                    │   │
    │                     │                       │                    │   ▼
    │                     │                       │                    │ 渲染打印
    │                     │                       │                    │   │
    │                     │                       │                    │ ◄─┘ (成功)
    │                     │                       │                    │
    │                     │                       │ 更新状态=SUCCESS    │
    │                     │                       │◄───────────────────│
    │                     │                       │                    │
    │                     │                       │ 删除任务文件        │
    │                     │                       │                    │
```

### 7.2 失败重试流程

```
用户/系统          PrintJobGenerator       PosPrnJobService      PrinterWorker
    │                     │                       │                    │
    │ generateKitchenJob()│                       │                    │
    │────────────────────►│                       │                    │
    │                     │ ... (同上)            │                    │
    │                     │                       │                    │
    │                     │                       │                    │ handlePrintJob()
    │                     │                       │                    │   │
    │                     │                       │                    │   ▼
    │                     │                       │                    │ 渲染失败
    │                     │                       │                    │   │
    │                     │                       │                    │ ◄─┘ (失败)
    │                     │                       │                    │
    │                     │                       │ addPrnCount()      │
    │                     │                       │◄───────────────────│
    │                     │                       │                    │
    │                     │                       │ prnCount+1         │
    │                     │                       │                    │
    │                     │                       │      10秒后        │
    │                     │                       │◄───────────────────│
    │                     │                       │                    │
    │                     │                       │                    │ 再次执行...
    │                     │                       │                    │
```

### 7.3 故障切换流程

```
PrinterWorker A              PrinterWorker B          PosPrnQueueService
    (主打印机故障)                   (备用打印机)
         │                              │                      │
         │ getStatus()                  │                      │
         │──────────────►               │                      │
         │  返回 FAULT                  │                      │
         │◄───────────────              │                      │
         │                              │                      │
         │ redirect()                   │                      │
         │ 遍历队列中的任务              │                      │
         │                              │                      │
         │ getStandbyPrinters()         │                      │
         │─────────────────────────────►│                      │
         │                              │ 返回备用打印机列表     │
         │                              │◄─────────────────────│
         │                              │                      │
         │ dispatchJob(备用打印机)       │                      │
         │─────────────────────────────►│                      │
         │                              │                      │
         │                              │ 取任务并执行          │
         │                              │                      │
```

---

## 8. 状态机完整性约束

### 8.1 状态一致性约束

| 约束ID | 约束描述 |
|--------|----------|
| SC-01 | 任务状态为SUCCESS时，print必须为true |
| SC-02 | 任务状态为SUCCESS时，printAt必须有值 |
| SC-03 | 任务状态为PENDING时，print必须为false |
| SC-04 | 任务状态为FAILED时，prnCount必须>0 |

### 8.2 状态转换约束

| 约束ID | 约束描述 |
|--------|----------|
| TC-01 | 状态只能从PENDING转到SUCCESS或FAILED |
| TC-02 | 状态只能从FAILED转到SUCCESS（重试成功） |
| TC-03 | SUCCESS是终态，不可转换到其他状态 |
| TC-04 | 状态转换必须原子完成 |

### 8.3 时间约束

| 约束ID | 约束描述 |
|--------|----------|
| TC-05 | 任务超时时间 = 30分钟 |
| TC-06 | 重试间隔 = 10秒 |
| TC-07 | 打印计数Redis过期时间 = 15分钟 |

---

## 9. 监控指标

### 9.1 状态统计

| 指标 | 计算方式 | 告警阈值 |
|------|----------|----------|
| PENDING任务数 | count(status=PENDING) | >100时告警 |
| FAILED任务数 | count(status=FAILED) | >10时告警 |
| 成功率 | count(SUCCESS)/total | <95%时告警 |
| 平均处理时间 | avg(endTime-startTime) | >5s时告警 |

### 9.2 打印机状态统计

| 指标 | 计算方式 | 告警阈值 |
|------|----------|----------|
| FAULT打印机数 | count(status=FAULT) | >0时告警 |
| BUSY打印机数 | count(status=BUSY) | >3时告警 |
| 平均队列长度 | avg(queueSize) | >50时告警 |

---

**DA6 状态：✅ 状态机建模完成，可进入DA7架构决策记录阶段**
