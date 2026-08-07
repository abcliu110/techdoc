# DA6 - 交互流程

> 阶段：DA6 交互流程
> 目标系统：打印系统
> 日期：2026-08-04
> 状态：✅ 分析完成

---

## 1. 概述

本文档定义打印系统的交互流程，包括任务生命周期、核心调用序列、异常处理与重试机制。

---

## 2. 打印任务生命周期

### 2.1 状态枚举

```java
public enum PrnJobStatusEnum {
  PENDING(1, "pending"),   // 待打印
  SUCCESS(2, "success"),   // 打印成功
  FAILED(3, "failed");     // 打印失败
}
```

### 2.2 状态流转图

```
                                    ┌─────────────┐
                                    │   创建任务   │
                                    │  PENDING(1) │
                                    └──────┬──────┘
                                           │
                                           ▼
                              ┌────────────────────────┐
                              │    PrinterWorker       │
                              │  1. 检查打印机状态      │
                              │  2. 执行打印            │
                              │  3. 检查超时(30分钟)    │
                              └───────────┬────────────┘
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    │                     │                     │
                    ▼                     ▼                     ▼
           ┌────────────────┐    ┌────────────────┐    ┌────────────────┐
           │   打印成功      │    │   打印失败      │    │   超时放弃      │
           │  → SUCCESS(2)  │    │  → 重试队列     │    │  → 归档失败     │
           │  → finish_time │    │  → 10秒后重试   │    │  → 归档失败     │
           └────────────────┘    └────────────────┘    └────────────────┘
```

### 2.3 状态说明

| 状态 | 值 | 说明 | 后续动作 |
|------|---|------|----------|
| PENDING | 1 | 待打印，任务已创建但未处理 | PrinterWorker 消费 |
| SUCCESS | 2 | 打印成功，记录 finish_time | 任务结束 |
| FAILED | 3 | 打印失败，触发重试 | 最多重试 N 次后归档 |

---

## 3. 核心调用序列

### 3.1 打印任务生成流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        打印任务生成序列                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  POS前端/后端                 Service层              DAO层                   │
│      │                          │                     │                     │
│      │ normalCheckOut()         │                     │                     │
│      │  └─► CheckOutService     │                     │                     │
│      │                          │                     │                     │
│      │                          ▼                     │                     │
│      │              PosPrnJobService.generateJob()    │                     │
│      │                          │                     │                     │
│      │                          ▼                     │                     │
│      │               PrintJobGenerator.generateXXX()  │                     │
│      │               (1127行大服务)                    │                     │
│      │                          │                     │                     │
│      │                          ├─────────────────────┤                     │
│      │                          │                     │                     │
│      │                          ▼                     ▼                     │
│      │                   PosPrnJobMapper.insert()     │                     │
│      │                   写入 pos_prn_job 表           │                     │
│      │                   status = PENDING(1)          │                     │
│      │                          │                     │                     │
│      │                          ▼                     │                     │
│      │                   BlockQueueHandler.put()      │                     │
│      │                   加入打印队列                  │                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 打印任务执行流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        打印任务执行序列（PrinterWorker）                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  BlockQueueHandler              PrinterWorker            HandlerFactory     │
│         │                            │                        │             │
│         │ take() 阻塞等待             │                        │             │
│         │◄───────────────────────────│                        │             │
│         │                            │                        │             │
│         │ 取出任务                    │                        │             │
│         │───────────────────────────►│                        │             │
│         │                            │                        │             │
│         │                    ┌───────┴───────┐               │             │
│         │                    │ 检查超时(30分钟) │               │             │
│         │                    └───────┬───────┘               │             │
│         │                            │                        │             │
│         │              ┌─────────────┼─────────────┐          │             │
│         │              │超时不处理    │继续执行      │          │             │
│         │              ▼             ▼             │          │             │
│         │        archiveFailed()  ┌─────────┐      │          │             │
│         │        归档失败任务       │获取打印机│      │          │             │
│         │                         └────┬────┘      │          │             │
│         │                              │           │          │             │
│         │                              ▼           │          │             │
│         │                     检查打印机状态        │          │             │
│         │                    NORMAL/FAULT/BUSY     │          │             │
│         │                              │           │          │             │
│         │              ┌───────────────┼───────┐   │          │             │
│         │              │FAULT时重定向   │其他继续 │   │          │             │
│         │              ▼               ▼       │   │          │             │
│         │         重定向到备用    ┌────────────┐ │   │          │             │
│         │         打印机          │HandlerFactory│ │   │          │             │
│         │                         │getHandler()  │ │   │          │             │
│         │                         └──────┬───────┘ │   │          │             │
│         │                                │         │   │          │             │
│         │                                ▼         │   │          │             │
│         │                    ┌───────────────────┐ │   │          │             │
│         │                    │ DriverHandler     │ │   │          │             │
│         │                    │ PortHandler       │ │   │          │             │
│         │                    │ UsbLptHandler     │◄─┼───┘          │             │
│         │                    │ JBCloudPrinter    │ │              │             │
│         │                    │ XpCloudPrinter    │ │              │             │
│         │                    │ HanYinPrinter     │ │              │             │
│         │                    └─────────┬─────────┘ │              │             │
│         │                              │           │              │             │
│         │              ┌───────────────┴─────┐     │              │             │
│         │              │打印成功  │打印失败    │     │              │             │
│         │              ▼          ▼          │     │              │             │
│         │        updateStatus  put重试      │     │              │             │
│         │        → SUCCESS    延迟10秒      │     │              │             │
│         │              │          │          │     │              │             │
│         │              │          └──────────┤     │              │             │
│         │              │                   回到队列  │              │             │
│         │              ▼                                 │              │             │
│         │       finish_time = NOW                        │              │             │
│         │                                              ▼              │             │
│         │                                     继续取下一个任务          │             │
│         │                                              │              │             │
│         │                                              ▼              │             │
│         │                                        take()阻塞           │             │
│         │                                              │              │             │
│         └──────────────────────────────────────────────┘              │             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 打印类型与联次

### 4.1 常见打印场景

| 场景 | 样式类型 | 联次 | 说明 |
|------|---------|------|------|
| 点餐打印 | OrderMenu (10) | 厨房联 | 厨房接单 |
| 结账打印 | CheckOut (26) | 顾客联 | 小票打印 |
| 交班单 | ShiftReport (29) | 财务联 | 账务汇总 |
| 会员充值 | MemberSavingBill (39) | 顾客联 | 充值凭证 |
| 标签单 | FoodLabel (52) | 厨房联 | 菜品标签 |

### 4.2 三联打印场景

```
┌─────────────────────────────────────────────────────────────────┐
│                      餐饮场景三联打印                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│   │   厨房联     │    │   传菜联     │    │   顾客联     │       │
│   │ Kitchen Copy│    │Dish Deliverer│    │ Customer Copy│      │
│   ├─────────────┤    ├─────────────┤    ├─────────────┤       │
│   │ 菜品明细     │    │ 菜品明细     │    │ 收银信息     │       │
│   │ 做法要求     │    │ 桌号桌名     │    │ 支付明细     │       │
│   │ 制作时间     │    │ 叫起标识     │    │ 找零信息     │       │
│   └─────────────┘    └─────────────┘    └─────────────┘       │
│         │                  │                  │                │
│         ▼                  ▼                  ▼                │
│   厨房显示屏/KDS      传菜员手持设备        顾客收银凭证          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. 重试与超时机制

### 5.1 BlockQueueHandler 队列处理

```java
public abstract class BlockQueueHandler<T> implements Runnable {
  private final LinkedBlockingQueue<T> blockingQueue = new LinkedBlockingQueue<>();

  @Override
  public void run() {
    while (!stopped) {
      try {
        // take() 阻塞等待，有任务时立即消费
        T t = blockingQueue.take();
        runInner(t);
      } catch (Throwable ex) {
        // 异常时休眠5秒后重试
        sleep(Duration.ofSeconds(5));
      }
    }
  }

  public void put(T t, long delayMillis, long timeoutNanos) {
    // delayMillis > 0 时使用定时放入
    // timeoutNanos > 0 时限时阻塞
  }
}
```

### 5.2 重试延迟策略

| 场景 | 延迟时间 | 说明 |
|------|---------|------|
| 打印失败重试 | 10 秒 | 失败任务放回队列，延迟 10 秒后重试 |
| 队列异常恢复 | 5 秒 | BlockQueueHandler 异常后休眠 5 秒 |

### 5.3 超时处理

```java
// PrinterWorker.java 约第 180 行
if (Duration.between(jobDate, LocalDateTime.now()).toMinutes() > 30) {
  posPrnJobServicePlus.archiveFailed(
    prnJob.getMid(),
    prnJob.getSid(),
    prnJob.getLid(),
    "Print task timeout"
  );
  return; // 超过30分钟不再处理
}
```

| 参数 | 值 | 说明 |
|------|---|------|
| 超时阈值 | 30 分钟 | 任务从创建到执行不能超过 30 分钟 |
| 超时动作 | archiveFailed | 归档任务到失败状态，记录原因 |
| 超时判断 | 创建时间 job_date | 与当前时间比较 |

---

## 6. 打印机故障处理

### 6.1 状态检查

PrinterWorker 在执行打印前检查打印机状态：

```java
// 获取打印机状态
PrinterStatusEnum status = getPrinterStatus(printerLid);

if (status == PrinterStatusEnum.FAULT) {
  // 故障状态，重定向到备用打印机
  redirectToStandbyPrinter(job);
} else if (status == PrinterStatusEnum.BUSY) {
  // 忙状态，稍后重试
  put(job, 5000, 0); // 5秒后重试
}
```

### 6.2 打印机状态枚举

| 状态 | 值 | 说明 | 处理策略 |
|------|---|------|----------|
| NORMAL | 1 | 正常 | 直接执行打印 |
| FAULT | 2 | 故障 | 切换到备用打印机 |
| BUSY | 3 | 忙碌 | 延迟后重试 |

### 6.3 故障转移流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      打印机故障转移流程                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   打印机故障检测                                                  │
│        │                                                        │
│        ▼                                                        │
│   获取主打印机 lid                                               │
│        │                                                        │
│        ▼                                                        │
│   PosPrnQueue 中查找 standby_printer                            │
│        │                                                        │
│        ├──────────────────┐                                     │
│        │有备用打印机       │无备用打印机                          │
│        ▼                  ▼                                     │
│  切换到备用打印机    标记任务失败                                  │
│        │           archiveFailed("No standby printer")          │
│        ▼                                                         │
│  使用备用打印机                                                   │
│  执行打印                                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 7. 重打流程

### 7.1 REST 接口

```
POST /api/pos4cloud/pos_prn_job/reprint
```

### 7.2 PosPrnJobController 实现

```java
@PostMapping("/reprint")
public Result<Void> reprint(@RequestBody ReprintRequest request) {
  return service.reprint(request);
}
```

### 7.3 重打流程

```
┌─────────────────────────────────────────────────────────────────┐
│                        重打流程                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   前端/客户端                                                    │
│        │                                                        │
│        │ POST /reprint                                          │
│        │ { jobLid: "123456789" }                                │
│        ▼                                                        │
│   PosPrnJobController.reprint()                                 │
│        │                                                        │
│        ▼                                                        │
│   PosPrnJobServicePlus.reprint()                                │
│        │                                                        │
│        │ 1. 查询原任务                                           │
│        │ 2. 创建新任务（复制 content）                            │
│        │ 3. 设置状态为 PENDING                                   │
│        │ 4. 放入打印队列                                         │
│        │ 5. 更新原任务打印次数                                    │
│        │                                                        │
│        ▼                                                        │
│   BlockQueueHandler.put()                                       │
│        │                                                        │
│        ▼                                                        │
│   PrinterWorker 消费新任务                                       │
│        │                                                        │
│        ▼                                                        │
│   正常执行打印流程                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 8. Handler 工厂模式

### 8.1 Handler 类型

| Handler | 类型 | 说明 |
|---------|------|------|
| DriverHandler | 1 | Windows 驱动打印 |
| PortHandler | 2/3 | 串口/并口打印 |
| UsbLptHandler | 4/5 | USB/LPT 打印 |
| JBCloudPrinter | 7 | 佳博云打印 |
| XpCloudPrinter | 6 | 芯烨云打印 |
| HanYinPrinter | ? | 汉印打印 |

### 8.2 Handler 选择逻辑

```java
// PrinterWorker.java
PosPrnPrinter printer = getPrinter(lid);
PrinterHandler handler = HandlerFactory.getHandler(printer.getType(), printer.getModel());
handler.print(content, printer.getExtraInfo());
```

---

## 9. 关键时序点

| 时序 | 说明 | 代码位置 |
|------|------|----------|
| 任务创建 | 生成打印任务，状态=PENDING | PrintJobGenerator |
| 任务入队 | 加入 LinkedBlockingQueue | BlockQueueHandler.put() |
| 任务消费 | take() 阻塞等待，有任务立即处理 | BlockQueueHandler.run() |
| 超时检查 | 创建时间 > 30 分钟则归档 | PrinterWorker ~180行 |
| 状态检查 | 检查打印机 NORMAL/FAULT/BUSY | PrinterWorker |
| 打印执行 | 调用 Handler 执行实际打印 | PrinterWorker |
| 重试延迟 | 失败任务延迟 10 秒重试 | PrinterWorker 196-197行 |
| 成功归档 | 设置 finish_time，状态=SUCCESS | PrinterWorker |
| 重打 | 创建新任务，复制 content | PosPrnJobServicePlus.reprint() |

---

**DA6 交互流程分析完成。**
