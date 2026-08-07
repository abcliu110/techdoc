# DA5 不变量建模
# 打印系统不可违反的业务约束

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA5-PRINT-001 |
| 建模时间 | 2026/08/03 |
| 状态 | 初稿 |
| 参考文档 | DA2-概念建模, DA3-关系建模, DA4-规则建模 |

---

## 1. 不变量体系概览

### 1.1 不变量分类

| 不变量类型 | 符号 | 说明 | 违反后果 |
|------------|------|------|----------|
| INV-ENTITY | 实体完整性 | 实体属性必须满足约束 | NPE/数据不一致 |
| INV-REFERENTIAL | 引用完整性 | 外键关系必须有效 | 打印失败/路由错误 |
| INV-DOMAIN | 域完整性 | 属性值在允许范围内 | 业务逻辑错误 |
| INV-BUSINESS | 业务不变量 | 业务规则必须满足 | 打印结果不符合预期 |
| INV-CONCURRENCY | 并发不变量 | 并发操作的一致性保证 | 数据竞争/重复打印 |

---

### 1.2 核心不变量概览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        打印系统核心不变量                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  INV-ENT-01: 打印机必须有有效的连接配置                                   │
│  INV-ENT-02: 打印队列必须绑定至少一台打印机                               │
│  INV-ENT-03: 菜品必须有出品部门才能生成厨房联                             │
│  INV-ENT-04: 票据类型必须对应有效的样式配置                               │
│                                                                         │
│  INV-REF-01: 打印任务的qID必须指向有效队列                               │
│  INV-REF-02: 打印任务的pID必须指向有效打印机                             │
│  INV-REF-03: 出品部门的prnQueue必须指向有效队列                         │
│  INV-REF-04: 菜品出品部门引用的部门必须存在                              │
│                                                                         │
│  INV-DOM-01: 打印机type必须在PrinterTypeEnum范围内                       │
│  INV-DOM-02: 打印机model必须在PrinterModelEnum范围内                     │
│  INV-DOM-03: 任务status必须在PrnJobStatusEnum范围内                     │
│  INV-DOM-04: 打印份数必须非负                                            │
│                                                                         │
│  INV-BIZ-01: 一道菜同一时刻只能打印一次（防重）                           │
│  INV-BIZ-02: 标签单只在byQuantityOrder=true时生成                        │
│  INV-BIZ-03: 传菜联只包含属于该传菜间的菜品                               │
│  INV-BIZ-04: 主打印机故障时任务必须重定向                                 │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. 实体完整性不变量（INV-ENT）

### INV-ENT-01: 打印机必须有有效的连接配置

**约束描述：** 每个PosPrnPrinter记录必须包含完整的连接配置信息

**约束条件：**
```
PosPrnPrinter.type != null
PosPrnPrinter.model != null
PosPrnPrinter.extraInfo != null 且格式有效

额外验证：
  IF type == NET THEN extraInfo包含ip和port
  IF type == COM THEN extraInfo包含com和baudRate
  IF type == DRIVER THEN extraInfo包含driver名称
  IF type == XY_CLOUD THEN extraInfo包含deviceNo和secretKey
  IF type == JB_CLOUD THEN extraInfo包含deviceNo和apiKey
```

**违反后果：** PrinterWorker初始化失败，打印任务无法执行

**验证代码：**
```java
// PrinterWorker.<init>()
switch (printer.getType()) {
    case NET, COM, USB, LPT -> handler = new PortHandler();
    // extraInfo解析失败会抛出异常
}
```

---

### INV-ENT-02: 打印队列必须绑定至少一台打印机

**约束描述：** 每个PosPrnQueue记录必须至少绑定一台打印机（主打印机）

**约束条件：**
```
PosPrnQueue.primaryPrinter != null
toLongSet(primaryPrinter)非空
```

**违反后果：** 路由到该队列的任务无法找到打印机，任务积压

**验证代码：**
```java
// PrinterWorker.java:143-144
Set<Long> standbyPrinters = queueVO.parseStandbyPrinters();
Set<Long> primaryPrinters = queueVO.parsePrimaryPrinters();
if ((CollUtil.isEmpty(primaryPrinters) && CollUtil.isEmpty(standbyPrinters))) {
    log.error("[{}] redirect fail,主打印机[{}]，备打印机【{}】不存在",
        printer.getName(), queueVO.getPrimaryPrinter(), queueVO.getStandbyPrinter());
    continue;
}
```

---

### INV-ENT-03: 菜品必须有出品部门才能生成厨房联

**约束描述：** 生成厨房联时，每个菜品必须关联有效的出品部门

**约束条件：**
```
DwdFood.prnDeptLid != null
DwdFood.prnDeptLid != -1
PosDept.get(prnDeptLid) != null
PosDept.get(prnDeptLid).prnQueue != null
```

**违反后果：** 跳过该菜品的厨房联打印，记录错误日志

**验证代码：**
```java
// PrintJobGenerator.java:657-665
Long deptId = food.getPrnDeptLid();
if (Objects.isNull(deptId) || ObjectUtil.equal(deptId, -1L)) {
    log.error("菜品{}没有设置出品部门", food.getFoodName());
    continue;
}
PosDept posDept = posDeptMap.get(deptId);
if (posDept == null) {
    log.error("出品部门{}已经被删除", deptId);
    continue;
}
```

---

### INV-ENT-04: 票据类型必须对应有效的样式配置

**约束描述：** 每个打印任务引用的票据类型必须有对应的样式配置

**约束条件：**
```
Prn_PrintJob.styleType != null
PosPrnStyleRow.get(mid, sid, styleType) != null
```

**违反后果：** 任务创建成功但无法渲染，输出空白票据

**验证代码：**
```java
// PrintJobGenerator.java:812
prnJobCreate.setType(jobType);
prnJobCreate.setRows(posPrnStyleRowServicePlus.get(mid, sid, jobType));
// rows为null时会在渲染阶段失败
```

---

## 3. 引用完整性不变量（INV-REF）

### INV-REF-01: 打印任务的qID必须指向有效队列

**约束描述：** Prn_PrintJob.qID引用的队列必须存在且有效

**约束条件：**
```
Prn_PrintJob.qID != null
PosPrnQueue.get(qID) != null
```

**违反后果：** 任务无法分发到打印机，状态保持PENDING

**验证代码：**
```java
// PrinterWorker.java:136-142
PosPrnQueueVO queueVO = posPrnQueueServicePlus.get(
    dispatchJobDTO.getMid(), dispatchJobDTO.getSid(), dispatchJobDTO.getQueueLid());
if (Objects.isNull(queueVO)) {
    log.error("[{}] redirect fail,打印队列[{}]不存在,不需要转发到备打",
        printer.getName(), dispatchJobDTO.getQueueLid());
    continue;
}
```

---

### INV-REF-02: 打印任务的pID必须指向有效打印机

**约束描述：** Prn_PrintJob.pID引用的打印机必须存在且状态正常

**约束条件：**
```
Prn_PrintJob.pID != null
PosPrnPrinter.get(pID) != null
PrinterWorkerService.getStatus(pID) == NORMAL
```

**违反后果：** 任务分发到PrinterWorker后执行失败

**验证代码：**
```java
// PrinterWorker.run()
PrinterStatus status = getStatus();
if (status != PrinterStatus.NORMAL) {
    redirect();
    continue;
}
```

---

### INV-REF-03: 出品部门的prnQueue必须指向有效队列

**约束描述：** PosDept.prnQueue引用的打印队列必须存在

**约束条件：**
```
PosDept.prnQueue != null
FOR EACH queueId IN toLongSet(prnQueue):
    PosPrnQueue.get(queueId) != null
END FOR
```

**违反后果：** 厨房联路由到无效队列，无法打印

**验证代码：**
```java
// PrintJobGenerator.java:905-908
Set<Long> prnQueueIdSet = toLongSet(posDept.getPrnQueue());
if (CollUtil.isEmpty(prnQueueIdSet)) {
    log.error("做法出品部门{}没有有效打印队列", posDept.getName());
    continue;
}
```

---

### INV-REF-04: 菜品出品部门引用必须存在

**约束描述：** DwdFood.prnDeptLid引用的PosDept必须存在

**约束条件：**
```
DwdFood.prnDeptLid != null
PosDept.get(prnDeptLid) != null
```

**违反后果：** 菜品无法路由到正确的厨房打印机

**验证代码：**
```java
// PrintJobGenerator.java:663-665
PosDept posDept = posDeptMap.get(deptId);
if (posDept == null) {
    log.error("出品部门{}已经被删除", deptId);
    continue;
}
```

---

## 4. 域完整性不变量（INV-DOM）

### INV-DOM-01: 打印机type必须在枚举范围内

**约束描述：** PosPrnPrinter.type必须是PrinterTypeEnum的有效值

**约束条件：**
```
PrinterTypeEnum.values().contains(type)
```

**有效值：**
- DRIVER(1)
- NET(2)
- COM(3)
- USB(4)
- LPT(5)
- XY_CLOUD(6)
- JB_CLOUD(7)
- DRIVER_CMD(8)

**违反后果：** PrinterWorker初始化时无法选择正确的Handler

---

### INV-DOM-02: 打印机model必须在枚举范围内

**约束描述：** PosPrnPrinter.model必须是PrinterModelEnum的有效值

**约束条件：**
```
PrinterModelEnum.values().contains(model)
```

**有效值：**
- GP_R320C(1), EPSON_TM_220B(2), EPSON_T_T81(3)
- BTP_98NP(4), STAR_TSP700(5), STAR_SP700(6)
- STAR_TCP400(7), XP_80X(8), XP_76X(9), XP_58X(10)
- EPSON_TM_88IV(11), EPSON_T_T58(12), HS_80(13)
- GP_3150TFN(14), XP_T202UA(15), HY58(16), HY80(17)

**违反后果：** 无法选择正确的打印机型号适配器

---

### INV-DOM-03: 任务status必须在枚举范围内

**约束描述：** Prn_PrintJob.status必须是PrnJobStatusEnum的有效值

**约束条件：**
```
PrnJobStatusEnum.values().contains(status)
```

**有效值：**
- PENDING(0) - 待处理
- PRINTING(1) - 打印中
- COMPLETED(2) - 已完成
- FAILED(3) - 失败
- CANCELLED(4) - 已取消

**状态转换约束：**
```
PENDING → PRINTING → COMPLETED
PENDING → PRINTING → FAILED
PENDING → CANCELLED
```

---

### INV-DOM-04: 打印份数必须非负

**约束描述：** numOfCustomer/numOfKitchen/numOfWaiter必须>=0

**约束条件：**
```
numOfX == null OR numOfX >= 0
```

**违反后果：** 负数份数会导致无限循环或异常

**验证代码：**
```java
// PrintJobGenerator.java:1079
return Optional.ofNullable(typeSwitch.getNumOfKitchen())
    .filter(i -> i >= 0)  // 过滤掉负数
    .orElse(1);
```

---

## 5. 业务不变量（INV-BIZ）

### INV-BIZ-01: 一道菜同一时刻只能打印一次（防重）

**约束描述：** 防止同一菜品在短时间内被重复打印

**约束条件：**
```
同一菜品同一票据类型，同一时刻只生成一个打印任务
```

**实现机制：**
```java
// PrintJobGenerator.java:707-731
public static Integer getAndSetPrintCount(DwdFood food, PrnStyleTypeEnum type) {
    return OrderServiceUtil.lockAndGet(
        () -> {
            // 使用分布式锁保证原子性
            JSONObject printObj = ...
            int printCount = printObj.getInteger(type.name()) + 1;
            printObj.put(type.name(), printCount);
            // 更新到数据库
            Chain<DwdFood> forFoodUpdate = OrderServiceUtil.forFoodUpdate();
            forFoodUpdate.set(...).update();
            return printCount;
        },
        String.format("SetPrintCount:Food:%s", food.getLid()));
}
```

**违反后果：** 同一菜品被打印多次，造成浪费

---

### INV-BIZ-02: 标签单只在byQuantityOrder=true时生成

**约束描述：** 标签单打印必须满足数量点单的条件

**约束条件：**
```
生成标签单的条件：
  labelEnabled == true
  AND byQuantityOrder == true
  AND FoodLabelPrintJobCreator.shouldCreateFor(jobType, sendAfter)
  AND FoodLabelPrintJobCreator.hasValidQuantity(jobType, bill, food)
```

**代码证据：**
```java
// PrintJobGenerator.java:541-545
boolean shouldCreateLabel =
    labelEnabled
        && byQuantityOrder
        && FoodLabelPrintJobCreator.shouldCreateFor(jobType, sendAfter)
        && FoodLabelPrintJobCreator.hasValidQuantity(jobType, bill, food);
```

---

### INV-BIZ-03: 传菜联只包含属于该传菜间的菜品

**约束描述：** 每个传菜间只打印归属该传菜间的菜品

**约束条件：**
```
传菜联菜品过滤规则：
  foodsToPrint = foods.filter(f ->
      prnDeptSet.contains(f.prnDeptLid)
  )
```

**代码证据：**
```java
// PrintJobGenerator.java:1011-1021
for (DwdFood food : foods) {
    Long deptId = food.getPrnDeptLid();
    if (deptId == null) {
        continue;
    }
    if (prnDeptSet.contains(deptId)) {
        foodsToPrint.add(food);
    }
}
```

---

### INV-BIZ-04: 主打印机故障时任务必须重定向

**约束描述：** 当主打印机故障时，待打印任务必须重定向到备用打印机

**约束条件：**
```
IF printerStatus != NORMAL THEN
    FOR EACH task IN queue:
        redirect(task, standbyPrinters)
    END FOR
END IF
```

**代码证据：**
```java
// PrinterWorker.java:124-155
private void redirect() {
    Iterator<DelayedElement<DispatchJobDTO>> it = iterator();
    while (it.hasNext()) {
        DispatchJobDTO dispatchJobDTO = it.next().getData();
        Set<Long> standbyPrinters = queueVO.parseStandbyPrinters();
        if (CollUtil.isNotEmpty(standbyPrinters)) {
            // 重定向到备用打印机
            redirectToStandby(dispatchJobDTO, standbyPrinters);
        }
    }
}
```

---

### INV-BIZ-05: 做法出品部门优先于菜品出品部门

**约束描述：** 当菜品有做法且做法有独立出品部门时，优先按做法分单

**约束条件：**
```
IF food有做法 AND 做法.prnDeptLid有效 THEN
    按做法出品部门分单
    // 可能生成多张票据（一菜多单）
ELSE
    按菜品出品部门分单
END IF
```

**代码证据：**
```java
// PrintJobGenerator.java:539
boolean useFoodPrintDept = CookwayPrintDeptPlanner.shouldUseFoodPrintDept(foodTastes);
// ...
if (useFoodPrintDept) {
    // 按菜品出品部门
} else {
    // 按做法出品部门
}
```

---

## 6. 并发不变量（INV-CON）

### INV-CON-01: 打印机Worker线程互斥

**约束描述：** 每台打印机只能有一个活跃的Worker线程

**约束条件：**
```
同一打印机printerLid，同时最多只有一个PrinterWorker线程在运行
```

**实现机制：**
```java
// PrinterWorkerService接口
void addPrinterWorker(Long printerLid);
void removePrinterWorker(Long printerLid);
// 在PrinterWorkerServiceImpl中维护Map<printerLid, PrinterWorker>
```

**违反后果：** 同一打印机的任务被多个线程同时处理，导致输出混乱

---

### INV-CON-02: 任务状态转换原子性

**约束描述：** 任务状态转换必须原子完成

**约束条件：**
```
状态转换: PENDING → PRINTING → COMPLETED/FAILED
    ↓
    必须单次数据库UPDATE完成
    不能出现中间状态（PENDING但实际在打印中）
```

**实现机制：** 使用乐观锁（revision字段）防止并发更新

---

### INV-CON-03: 打印份数累加原子性

**约束描述：** 同一菜品的打印计数必须原子累加

**约束条件：**
```
打印计数 += 1
    ↓
    使用分布式锁保证原子性
```

**代码证据：**
```java
// PrintJobGenerator.java:709
return OrderServiceUtil.lockAndGet(
    () -> { /* 原子操作 */ },
    String.format("SetPrintCount:Food:%s", food.getLid()));
```

---

## 7. 不变量违反检测汇总

### 7.1 运行时检测

| 不变量ID | 检测时机 | 检测方式 | 处理策略 |
|----------|----------|----------|----------|
| INV-ENT-01 | Worker启动 | 解析extraInfo失败 | 抛出异常，Worker无法启动 |
| INV-ENT-02 | 任务分发 | 获取主备打印机为空 | 跳过任务，记录日志 |
| INV-ENT-03 | 厨房联生成 | 检查prnDeptLid | 跳过菜品，记录错误 |
| INV-ENT-04 | 任务渲染 | 检查styleRows | 输出空白票据 |
| INV-REF-01 | 任务分发 | 获取队列为null | 重定向到备用 |
| INV-REF-02 | 任务执行 | 检查打印机状态 | 故障重定向 |
| INV-REF-03 | 厨房联路由 | 队列集合为空 | 记录错误，跳过 |
| INV-DOM-04 | 份数计算 | numOfX < 0 | 使用默认值1 |

### 7.2 数据层检测

| 不变量ID | 检测方式 | 数据库约束 |
|----------|----------|------------|
| INV-ENT-01 | - | extraInfo NOT NULL，格式校验 |
| INV-ENT-02 | - | primaryPrinter NOT NULL |
| INV-DOM-01 | - | type字段枚举约束 |
| INV-DOM-02 | - | model字段枚举约束 |
| INV-DOM-03 | - | status字段枚举约束 |
| INV-DOM-04 | 应用层 | 应用层过滤负数 |

---

## 8. 不变量与规则的关系

### 8.1 不变量 vs 规则

| 对比维度 | 不变量 | 规则 |
|----------|--------|------|
| 约束性质 | 不可违反 | 可配置 |
| 违反后果 | 系统故障 | 业务行为变化 |
| 示例 | 队列必须绑定打印机 | 禁用厨房联 |
| 修改频率 | 几乎不变 | 可随时调整 |

### 8.2 不变量是规则的基础

```
不变量 (INV-*)
    │
    ├── 定义系统运行的前提条件
    ├── 违反后系统无法正常工作
    └── 通常在数据库和应用层双重保证
    │
    ▼
规则 (R-*)
    │
    ├── 定义系统的可配置行为
    ├── 违反后业务逻辑调整但系统仍运行
    └── 通常在应用层配置和执行
```

---

**DA5 状态：✅ 不变量建模完成，可进入DA6状态机建模阶段**
