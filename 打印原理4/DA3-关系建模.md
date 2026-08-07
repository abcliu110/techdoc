# DA3 关系建模
# 打印系统模块间关系与依赖规格

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA3-PRINT-001 |
| 建模时间 | 2026/08/03 |
| 状态 | 初稿 |
| 参考文档 | DA1-侦察报告, DA2-概念建模 |

---

## 1. 核心关系概览

### 1.1 关系类型分类

| 关系类型 | 符号 | 说明 |
|----------|------|------|
| REL-CONTAIN | 1:N | 包含关系，如队列包含多个任务 |
| REL-ATTRIBUTE | N:1 | 属性关系，如任务归属某队列 |
| REL-ROUTING | N→1 | 路由关系，如菜品路由到出品部门 |
| REL-EXECUTE | 1→N | 执行关系，如Worker执行多个任务 |
| REL-GENERATE | 1→N | 生成关系，如Generator生成多个任务 |
| REL-SELECT | N→1 | 选择关系，如根据类型选择Handler |

---

### 1.2 完整关系链图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           打印系统完整关系链                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐                                                       │
│  │   PosPrnQueue    │◄──────────────────┐                                   │
│  │   打印队列        │   REL-ATTRIBUTE   │                                   │
│  │──────────────────│   (qID外键)       │                                   │
│  │ lid (PK)         │                   │                                   │
│  │ primaryPrinter   │                   │                                   │
│  │ standbyPrinter   │                   │                                   │
│  └────────┬─────────┘                   │                                   │
│           │ REL-SELECT                                        ┌────────────┐ │
│           │ 根据primaryPrinter/standbyPrinter                  │ Prn_PrintJob│ │
│           │ 选择打印机                                         │ 打印任务    │ │
│           ▼                                                   │────────────│ │
│  ┌──────────────────┐    REL-GENERATE    ┌──────────────────┐ │ lid (PK)   │ │
│  │ PosPrnPrinter    │ ─────────────────► │ PrintJobGenerator│─► type      │ │
│  │ 打印机           │                    │ 任务生成器        │ │ status     │ │
│  │──────────────────│                    │──────────────────│ │ items[]    │ │
│  │ lid (PK)         │                    │ generateCustomer │ └─────┬──────┘ │
│  │ type (连接方式)  │                    │ generateKitchen  │       │       │
│  │ model (型号)     │                    │ generateWaiter   │       │       │
│  │ extraInfo (配置) │                    └──────────────────┘       │       │
│  └────────┬─────────┘                                           REL-ATTRIBUTE │
│           │                                                        │         │
│           │ REL-EXECUTE                                           │         │
│           │ 绑定到PrinterWorker                                    │         │
│           ▼                                                        │         │
│  ┌──────────────────┐                    ┌──────────────────┐       │         │
│  │ PrinterWorker    │                    │ PrintJobTypeSwitch│      │         │
│  │ 打印机线程        │                    │ 打印开关          │       │         │
│  │──────────────────│                    │──────────────────│       │         │
│  │ printer (关联)   │                    │ type (票据类型)   │──────┘         │
│  │ handler (执行)   │                    │ disabledX        │               │
│  └────────┬─────────┘                    │ numOfX           │               │
│           │                              └──────────────────┘               │
│           │ REL-SELECT                                                      │
│           │ 根据type选择Handler                                             │
│           ▼                                                                 │
│  ┌──────────────────┐                    ┌──────────────────┐               │
│  │PrintJobHandlerBase│                   │ PosDept          │               │
│  │ 打印处理器基类    │                    │ 出品部门          │               │
│  │──────────────────│                    │──────────────────│               │
│  │ 抽象方法:        │                    │ lid (PK)         │               │
│  │ handle()         │                    │ type             │               │
│  │ getStatus()      │                    │ prnQueue (JSON)  │               │
│  └────────┬─────────┘                    └────────┬─────────┘               │
│           │                                        │                        │
│  ┌────────┴────────┐                              │ REL-ROUTING             │
│  │                 │                              │ 根据菜品出品部门        │
│  │ ┌─────────────┐ │                              │ 分发到对应队列          │
│  │ │DriverHandler│ │◄── DRIVER                    │                        │
│  │ │PortHandler  │ │◄── NET/COM/USB/LPT           │                        │
│  │ │XYTagPrinter │ │◄── XY_CLOUD                  │                        │
│  │ │JBTagPrinter │ │◄── JB_CLOUD                  │                        │
│  │ │HanYinPrinter│ │◄── HY58/HY80                  │                        │
│  │ └─────────────┘ │                              │                        │
│  └─────────────────┘                              │                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 关系规格明细

### 2.1 REL-ATTRIBUTE: 打印任务归属队列

| 规格项 | 内容 |
|--------|------|
| **关系定义** | Prn_PrintJob → PosPrnQueue |
| **关系类型** | N:1（多个任务归属一个队列） |
| **字段连接** | `Prn_PrintJob.qID = PosPrnQueue.lid` |
| **关联路径** | Prn_PrintJob.qID → PosPrnQueue.lid |
| **约束条件** | qID必须对应有效的队列记录；队列删除时任务状态需处理 |
| **使用方式** | 任务分发时设置qID；Worker根据qID获取队列配置 |
| **修改影响** | 修改队列配置影响该队列所有任务的分发逻辑 |
| **级联行为** | 队列删除时需先清空待处理任务或迁移到其他队列 |
| **实现证据** | `PosPrnJobCreateDTO.setPrnQueueLid()` → `prnJobCreate.setPrnQueueLid(queueId)` |

**代码证据：**
```java
// PrintJobGenerator.java:775
prnJobCreate.setPrnQueueLid(prnQueueId);
posPrnJobServicePlus.create(prnJobCreate);

// PrinterWorker.java:135
PosPrnQueueVO queueVO = posPrnQueueServicePlus.get(
    dispatchJobDTO.getMid(), dispatchJobDTO.getSid(), dispatchJobDTO.getQueueLid());
```

---

### 2.2 REL-ATTRIBUTE: 打印队列绑定打印机

| 规格项 | 内容 |
|--------|------|
| **关系定义** | PosPrnQueue → PosPrnPrinter |
| **关系类型** | 1:N（一个队列绑定多台打印机：1主+N备） |
| **字段连接** | `PosPrnQueue.primaryPrinter/standbyPrinter` = JSON数组含`lid` |
| **关联路径** | `PosPrnQueue.primaryPrinter` → `PosPrnPrinter.lid` |
| **约束条件** | 主备打印机必须存在且type兼容；主备不能为同一台打印机 |
| **使用方式** | Worker启动时获取队列的主备打印机；主打印机故障时切换到备用 |
| **修改影响** | 修改主备打印机影响该队列所有任务的路由 |
| **级联行为** | 删除主打印机时自动提升备用打印机为主打印机 |
| **实现证据** | `PosPrnQueueVO.parsePrimaryPrinters()` / `parseStandbyPrinters()` |

**代码证据：**
```java
// PrinterWorker.java:143-144
Set<Long> standbyPrinters = queueVO.parseStandbyPrinters();
Set<Long> primaryPrinters = queueVO.parsePrimaryPrinters();

// PosPrnQueueVO.java
public Set<Long> parsePrimaryPrinters() {
    return toLongSet(getPrimaryPrinter());
}
```

---

### 2.3 REL-ROUTING: 菜品按出品部门分发

| 规格项 | 内容 |
|--------|------|
| **关系定义** | DwdFood → PosDept → PosPrnQueue |
| **关系类型** | N:1:1（菜品→部门→队列） |
| **字段连接** | `DwdFood.prnDeptLid = PosDept.lid`; `PosDept.prnQueue` = JSON数组 |
| **关联路径** | food.getPrnDeptLid() → posDeptMap.get(deptId) → posDept.getPrnQueue() |
| **约束条件** | 菜品必须设置prnDeptLid；部门必须关联有效的打印队列 |
| **使用方式** | 厨房联生成时按菜品所属部门路由到对应打印队列 |
| **修改影响** | 修改菜品出品部门影响厨房联分发目标 |
| **级联行为** | 删除出品部门时菜品需迁移到其他部门 |
| **实现证据** | `CookwayPrintDeptPlanner.groupByPrintDept()` |

**代码证据：**
```java
// PrintJobGenerator.java:662-668
Long deptId = food.getPrnDeptLid();
PosDept posDept = posDeptMap.get(deptId);
Set<Long> prnQueueIdSet = toLongSet(posDept.getPrnQueue());
// 每个队列创建一个打印任务
for (Long prnQueueId : prnQueueIdSet) {
    prnJobCreate.setPrnQueueLid(prnQueueId);
    posPrnJobServicePlus.create(prnJobCreate);
}
```

---

### 2.4 REL-GENERATE: 打印开关控制任务生成

| 规格项 | 内容 |
|--------|------|
| **关系定义** | PrintJobTypeSwitch → PrintJobGenerator |
| **关系类型** | 1:N（一个开关配置控制多种任务生成） |
| **字段连接** | 无直接字段连接，通过参数传递开关状态 |
| **关联路径** | PrintJobTypeSwitch.type → getNumOfKitchen/Waiter/Customer() |
| **约束条件** | typeSwitch为null时默认生成1份；disabledX=true时跳过生成 |
| **使用方式** | 生成任务前查询开关配置，决定是否生成及生成份数 |
| **修改影响** | 修改开关配置立即影响后续任务生成（无缓存） |
| **级联行为** | 关闭开关后，已生成的任务不受影响 |
| **实现证据** | `PrintJobGenerator.getNumOfKitchen()` |

**代码证据：**
```java
// PrintJobGenerator.java:1070-1080
private Integer getNumOfKitchen(Long mid, Long sid, PrnStyleTypeEnum jobType) {
    PrintJobTypeSwitch typeSwitch = printJobTypeSwitchServicePlus.get(mid, sid, jobType);
    if (typeSwitch == null) {
        return 1;
    }
    if (Boolean.TRUE.equals(typeSwitch.getDisabledKitchen())) {
        return 0;
    }
    return Optional.ofNullable(typeSwitch.getNumOfKitchen()).filter(i -> i >= 0).orElse(1);
}
```

---

### 2.5 REL-SELECT: 打印机类型选择Handler

| 规格项 | 内容 |
|--------|------|
| **关系定义** | PosPrnPrinter.type → PrintJobHandlerBase |
| **关系类型** | N:1（多种类型选择同一Handler） |
| **字段连接** | `PosPrnPrinter.type = PrinterTypeEnum` |
| **关联路径** | printer.getType() → switch case → new Handler() |
| **约束条件** | 每种type必须有对应的Handler；云打印需要额外的设备凭证 |
| **使用方式** | PrinterWorker初始化时根据type实例化对应Handler |
| **修改影响** | 新增type需同时新增Handler；修改type导致切换Handler |
| **级联行为** | 无 |
| **实现证据** | `PrinterWorker.<init>()` |

**Handler选择矩阵：**

| type | Handler | 打印机型号额外条件 |
|------|---------|-------------------|
| DRIVER | GraphicsHandler | 无 |
| DRIVER_CMD | PortHandlerWithDriver | 无 |
| NET | PortHandler | 无 |
| COM | PortHandler | 无 |
| USB | PortHandler | 无 |
| LPT | PortHandler | 无 |
| XY_CLOUD | XpCloudPrinter | 无 |
| JB_CLOUD | JBCloudPrinter | 无 |
| NET/COM/USB/LPT | JBTagPrinter | model = GP_3150TFN |
| NET/COM/USB/LPT | XYTagPrinter | model = XP_T202UA |
| NET/COM/USB/LPT | HanYinPrinter | model = HY58 或 HY80 |

**代码证据：**
```java
// PrinterWorker.java:50-68
switch (printer.getType()) {
    case DRIVER -> handler = new GraphicsHandler();
    case DRIVER_CMD -> handler = new PortHandlerWithDriver();
    case NET, COM, USB, LPT -> {
        PrinterModelEnum printerModel = printer.getModel();
        if (Objects.equals(printerModel, PrinterModelEnum.GP_3150TFN)) {
            handler = new JBTagPrinter();
        } else if (Objects.equals(printerModel, PrinterModelEnum.XP_T202UA)) {
            handler = new XYTagPrinter();
        } else if (Objects.equals(printerModel, PrinterModelEnum.HY58)
                || Objects.equals(printerModel, PrinterModelEnum.HY80)) {
            handler = new HanYinPrinter();
        } else {
            handler = new PortHandler();
        }
    }
    case XY_CLOUD -> handler = new XpCloudPrinter();
    case JB_CLOUD -> handler = new JBCloudPrinter();
}
```

---

### 2.6 REL-EXECUTE: Worker执行打印任务

| 规格项 | 内容 |
|--------|------|
| **关系定义** | PrinterWorker → Prn_PrintJob |
| **关系类型** | 1:N（一个Worker执行多个任务） |
| **字段连接** | 通过阻塞队列传递DispatchJobDTO |
| **关联路径** | PrinterWorker.queue → take() → runInner(dispatchJob) |
| **约束条件** | Worker与Printer绑定；任务按FIFO顺序执行 |
| **使用方式** | Worker线程循环从队列取任务并执行；主打印机故障时重定向 |
| **修改影响** | Worker崩溃导致打印机离线；任务堆积在队列中 |
| **级联行为** | Worker异常退出时自动重启（通过PrinterWorkerService） |
| **实现证据** | `PrinterWorker.run()` |

**代码证据：**
```java
// PrinterWorker.java:77-119
@Override
public void run() {
    while (!stopped) {
        try {
            PrinterStatus status = getStatus();
            if (status != PrinterStatus.NORMAL) {
                redirect(); // 重发到其他打印队列
                Thread.sleep(Duration.ofSeconds(5));
                continue;
            }
            DispatchJobDTO dispatchJob = take();
            runInner(dispatchJob);
        } catch (Throwable e) {
            log.error("打印异常,{}=>{}", printer.getName(), ExceptionUtils.getStackTrace(e));
        }
    }
}
```

---

### 2.7 REL-ATTRIBUTE: 任务关联打印样式

| 规格项 | 内容 |
|--------|------|
| **关系定义** | Prn_PrintJob → PosPrnStyleRow → PosPrnStyleCol |
| **关系类型** | 1:N:1（任务→多行样式→多个打印项） |
| **字段连接** | `Prn_PrintJob.styleType = PosPrnStyleRow.styleType`; `PosPrnStyleRow.lid = PosPrnStyleCol.rowLid` |
| **关联路径** | prnJobCreate.setRows() → posPrnStyleRowServicePlus.get() |
| **约束条件** | 每种票据类型必须有对应的样式配置；样式行按showIndex排序 |
| **使用方式** | 任务生成时设置样式；Handler渲染时按contentType分发处理 |
| **修改影响** | 修改样式配置立即影响后续任务的打印效果 |
| **级联行为** | 无 |
| **实现证据** | `PrintJobGenerator.java` |

**代码证据：**
```java
// PrintJobGenerator.java:812
prnJobCreate.setType(jobType);
prnJobCreate.setRows(posPrnStyleRowServicePlus.get(mid, sid, jobType));
```

---

### 2.8 REL-EXECUTE: Handler处理打印内容

| 规格项 | 内容 |
|--------|------|
| **关系定义** | PrintJobHandlerBase → Prn_StyleContent |
| **关系类型** | 1:N（一个Handler处理多个打印项） |
| **字段连接** | 通过printContents列表传递 |
| **关联路径** | handler.setPrintContents() → handleText/handleLine/handleImg() |
| **约束条件** | 每种contentType必须有对应的处理方法；条件判断失败时跳过该项 |
| **使用方式** | 遍历printContents，对每项调用对应的handle方法 |
| **修改影响** | Handler异常导致整张票据打印失败 |
| **级联行为** | 无 |
| **实现证据** | `PrintJobHandlerBase.java` |

**内容处理分发：**

| contentType | 处理方法 |
|-------------|----------|
| TEXT | handleText() |
| SQL | handleSqlQuery() |
| LINE | handleLine() |
| IMG | handleImg() |
| BARCODE | handleImg() |
| QRCODE | handleImg() |
| CUT | handleCutPaper() |
| BLANK | handleBlankLine() |

---

## 3. 职责矩阵

### 3.1 核心模块职责

| 模块 | 职责 | 边界 |
|------|------|------|
| PrintJobGenerator | 业务事件触发后生成打印任务 | 负责决定生成什么任务、几份 |
| PrinterWorkerService | 管理PrinterWorker生命周期 | 负责Worker的添加、移除、状态查询 |
| PrinterWorker | 从队列取任务并执行打印 | 负责任务分发、故障重定向 |
| PrintJobHandlerBase | 实际执行打印输出 | 负责将任务内容渲染到物理打印机 |
| PosPrnQueue | 路由配置和主备管理 | 负责路由规则和故障切换 |
| PrintJobTypeSwitch | 开关配置查询 | 负责联票开关和份数控制 |

### 3.2 调用依赖图

```
PrintJobGenerator
    │
    ├──► PrintJobTypeSwitchServicePlus.get()     // 查询开关
    ├──► PosDeptServicePlus.get()                // 查询出品部门
    ├──► PosPrnQueueServicePlus.get()            // 查询打印队列
    ├──► PosPrnStyleRowServicePlus.get()         // 查询样式
    └──► PosPrnJobServicePlus.create()           // 创建任务
              │
              ▼
Prn_PrintJob (数据库记录)
              │
              ▼
PrinterWorkerService.handlePrnJob()
              │
              ▼
PrinterWorker (线程)
    │
    ├──► PosPrnQueueServicePlus.get()            // 获取主备打印机
    ├──► PosPrnPrinterServicePlus.get()          // 获取打印机配置
    └──► handler.handle(job)                     // 执行打印
              │
              ▼
PrintJobHandlerBase (具体Handler)
    │
    ├──► DriverHandler      (DRIVER)
    ├──► PortHandler        (NET/COM/USB/LPT)
    ├──► GraphicsHandler    (DRIVER)
    ├──► XpCloudPrinter     (XY_CLOUD)
    ├──► JBCloudPrinter     (JB_CLOUD)
    ├──► JBTagPrinter       (GP_3150TFN)
    ├──► XYTagPrinter       (XP_T202UA)
    └──► HanYinPrinter      (HY58/HY80)
```

---

## 4. 关键设计决策

### 决策4.1: 为什么用JSON存储主备打印机？

**问题：** 为什么PosPrnQueue.primaryPrinter和standbyPrinter用JSON而不是外键？

**分析：**
- 一个队列可能绑定多个主打印机（负载均衡）
- 主备关系是队列级别的，不是全局的
- JSON灵活性高，支持随时增减打印机

**结论：** JSON格式允许N主N备的灵活配置，适合复杂场景

### 决策4.2: 为什么按出品部门分单？

**问题：** 为什么厨房联要按出品部门分开打印？

**分析：**
- 不同出品部门（炒菜间/凉菜间）位于不同位置
- 同时打印到一台打印机会导致混乱
- 支持"一菜一单"或"多菜一单"的灵活配置

**结论：** 出品部门是厨房联分单的核心维度

### 决策4.3: 为什么用Worker线程池？

**问题：** 为什么不直接在线程池中执行打印？

**分析：**
- 每台打印机需要独立的阻塞队列
- 打印机故障需要单独的重定向逻辑
- 打印机状态需要单独监控

**结论：** PrinterWorker封装了打印机的所有状态和行为

---

## 5. 关系约束汇总

### 5.1 必须满足的业务约束

| 约束ID | 约束描述 | 验证点 |
|--------|----------|--------|
| C01 | 菜品必须有有效的出品部门 | food.prnDeptLid存在且对应部门有prnQueue |
| C02 | 打印队列必须绑定至少一台打印机 | queue.primaryPrinter非空 |
| C03 | 任务生成时必须指定有效的打印队列 | job.qID对应有效队列 |
| C04 | 打印开关按票据类型区分 | typeSwitch.type唯一 |
| C05 | 样式配置按票据类型区分 | styleRow.styleType唯一 |

### 5.2 关系完整性规则

| 规则 | 说明 |
|------|------|
| 删除部门前 | 必须先迁移菜品到其他部门或清理菜品关联 |
| 删除队列前 | 必须先清空待处理任务或迁移到其他队列 |
| 删除打印机前 | 必须先从所有队列中移除引用 |
| 禁用开关后 | 不影响已生成的任务 |

---

## 6. 扩展点分析

### 6.1 新增打印机类型

**步骤：**
1. 在PrinterTypeEnum中添加新类型
2. 在PrinterWorker中添加新case
3. 创建新的Handler类继承PrintJobHandlerBase
4. 在前端添加对应的extraInfo配置项

**影响范围：** PrinterWorker.switch语句

### 6.2 新增联票类型

**步骤：**
1. 在PrnStyleTypeEnum中添加新类型
2. 在PrintJobGenerator中添加generateXxxJob方法
3. 在PrintJobTypeSwitchService中添加相关配置查询
4. 在前端添加开关配置界面

**影响范围：** PrintJobGenerator, PrintJobTypeSwitch表

### 6.3 新增分发维度

**步骤：**
1. 确定分发依据字段（如楼层、区域）
2. 在对应实体中添加prnQueue关联
3. 在PrintJobGenerator中添加分发逻辑
4. 在前端添加配置界面

**影响范围：** PrintJobGenerator分发逻辑

---

**DA3 状态：✅ 关系建模完成，可进入DA4规则建模阶段**
