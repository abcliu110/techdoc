# DA4 规则建模
# 打印开关与分发规则规格

## 版本信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA4-PRINT-001 |
| 建模时间 | 2026/08/03 |
| 状态 | 初稿 |
| 参考文档 | DA2-概念建模, DA3-关系建模 |

---

## 1. 规则体系概览

### 1.1 规则分类

| 规则类型 | 说明 | 示例 |
|----------|------|------|
| R-SWITCH | 打印开关规则 | 禁用厨房联/设置打印份数 |
| R-ROUTING | 路由分发规则 | 菜品按出品部门分发 |
| R-CONDITION | 条件判断规则 | 满足条件才打印某项 |
| R-COPY | 份数控制规则 | 按数量出单/默认份数 |
| R-FAILOVER | 故障切换规则 | 主打印机故障切换备用 |

---

### 1.2 规则决策树

```
业务事件触发（点菜/结账/退菜...）
         │
         ▼
┌────────────────────────────────────────────────────────────┐
│ 规则R-SWITCH: 打印开关检查                                   │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  PrintJobTypeSwitch.get(type)                              │
│         │                                                 │
│         ├── disabledCustomer == true? ──Yes──► 跳过顾客联  │
│         │                                                 │
│         ├── disabledKitchen == true? ──Yes──► 跳过厨房联  │
│         │                                                 │
│         └── disabledWaiter == true? ──Yes──► 跳过传菜联   │
│                                                            │
└────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────┐
│ 规则R-COPY: 份数控制                                        │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  numOfCustomer / numOfKitchen / numOfWaiter                │
│         │                                                 │
│         ├── null? ──► 使用默认值1                          │
│         │                                                 │
│         └── >= 0? ──► 循环创建该份数                       │
│                                                            │
│  特殊：按数量出单 (paidNumber)                              │
│         ├── 有效正整数? ──► 使用该数量                     │
│         └── 无效? ──► 降级为默认份数                       │
│                                                            │
└────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────┐
│ 规则R-ROUTING: 路由分发                                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  顾客联: PosCustomerBillSetting.getPrnQueue()              │
│         │                                                 │
│         └── 多队列? ──► 每个队列创建一个任务               │
│                                                            │
│  厨房联: PosDept.prnQueue                                  │
│         │                                                 │
│         ├── 按菜品出品部门                                  │
│         └── 按做法出品部门 (CookwayPrintDeptPlanner)       │
│                                                            │
│  传菜联: PosWaiterBillSetting.getPrnQueue()                │
│         │                                                 │
│         └── 按传菜间关联的出品部门过滤菜品                  │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 2. 打印开关规则（R-SWITCH）

### 2.1 开关控制矩阵

| 票据类型 | 顾客联 | 厨房联 | 传菜联 | 典型业务场景 |
|----------|--------|--------|--------|--------------|
| CheckOut（结账单） | 默认开启×1 | 默认关闭 | 默认关闭 | 顾客结账 |
| OrderMenu（点菜单） | 默认关闭 | 默认开启×1 | 默认开启×1 | 新增菜品 |
| Nodiscount（整单优惠） | 默认开启×1 | 默认关闭 | 默认关闭 | 整单优惠 |
| ChangeTable（转台） | 默认开启×1 | 默认关闭 | 默认关闭 | 餐桌转移 |
| MergeTable（并台） | 默认开启×1 | 默认关闭 | 默认关闭 | 餐桌合并 |
| QuickCharge（快餐结账） | 默认开启×2 | 默认关闭 | 默认关闭 | 快餐模式 |

### 2.2 开关查询规则

**规则R-SW-01：开关不存在时使用默认值**

```
IF PrintJobTypeSwitch不存在 THEN
    numOfX = 1 (默认值)
    disabledX = false (默认不禁用)
END IF
```

**代码证据：**
```java
// PrintJobGenerator.java:1070-1080
private Integer getNumOfKitchen(Long mid, Long sid, PrnStyleTypeEnum jobType) {
    PrintJobTypeSwitch typeSwitch = printJobTypeSwitchServicePlus.get(mid, sid, jobType);
    if (typeSwitch == null) {
        return 1;  // 默认值
    }
    if (Boolean.TRUE.equals(typeSwitch.getDisabledKitchen())) {
        return 0;  // 禁用
    }
    return Optional.ofNullable(typeSwitch.getNumOfKitchen()).filter(i -> i >= 0).orElse(1);
}
```

**规则R-SW-02：禁用优先于份数控制**

```
IF disabledX == true THEN
    忽略numOfX设置
    直接跳过该联打印
END IF
```

**规则R-SW-03：份数不能为负数**

```
numOfX = MAX(0, numOfX)
```

### 2.3 开关配置数据结构

```java
PrintJobTypeSwitch {
    mid: Long           // 商户号
    sid: Long           // 门店号
    type: PrnStyleTypeEnum  // 票据类型（唯一索引）
    disabledKitchen: Boolean  // 禁用厨房联
    disabledWaiter: Boolean   // 禁用传菜联
    disabledCustomer: Boolean // 禁用顾客联
    numOfKitchen: Integer     // 厨房联打印份数（null=默认1）
    numOfWaiter: Integer      // 传菜联打印份数
    numOfCustomer: Integer    // 顾客联打印份数
    deleted: Integer          // 逻辑删除标记
}
```

---

## 3. 路由分发规则（R-ROUTING）

### 3.1 顾客联路由规则

**规则R-CUS-01：按结账设置路由**

```
顾客联路由 = PosCustomerBillSetting.getPrnQueue(mid, sid)
```

**规则R-CUS-02：多队列时逐个创建**

```
queues = toLongSet(setting.getPrnQueue())
FOR EACH queueId IN queues:
    createPrintJob(queueId)
END FOR
```

**代码证据：**
```java
// PrintJobGenerator.java:200-210
Set<Long> queues = toLongSet(setting.getPrnQueue());
for (Long queueId : queues) {
    PosPrnJobCreateDTO prnJobCreate = new PosPrnJobCreateDTO();
    prnJobCreate.setPrnQueueLid(queueId);
    prnJobCreate.setRows(posPrnStyleRowServicePlus.get(mid, sid, jobType));
    // ...
    posPrnJobServicePlus.create(prnJobCreate);
}
```

### 3.2 厨房联路由规则

**规则R-KIT-01：按菜品出品部门路由**

```
IF food.prnDeptLid == null OR food.prnDeptLid == -1 THEN
    LOG_ERROR("菜品没有设置出品部门")
    SKIP
END IF

dept = PosDept.get(food.prnDeptLid)
IF dept == null THEN
    LOG_ERROR("出品部门已被删除")
    SKIP
END IF

prnQueues = toLongSet(dept.prnQueue)
FOR EACH queueId IN prnQueues:
    createKitchenJob(queueId, food)
END FOR
```

**规则R-KIT-02：按做法出品部门路由（优先级更高）**

```
IF food存在做法 AND 做法有独立出品部门 THEN
    按做法出品部门分发
    // 一道菜可能生成多张票据（不同做法）
ELSE
    按菜品出品部门分发
END IF
```

**代码证据：**
```java
// PrintJobGenerator.java:886-956
Map<Long, List<CookwayPrintDeptPlanner.CookPrintItem>> cookwayDeptMap =
    CookwayPrintDeptPlanner.groupByPrintDept(
        cookMap.get(food.getLid()), tasteMap.get(food.getLid()));

// 按做法出品部门创建任务
for (Map.Entry<Long, List<CookwayPrintDeptPlanner.CookPrintItem>> entry :
    cookwayDeptMap.entrySet()) {
    Long deptId = entry.getKey();
    PosDept posDept = posDeptMap.get(deptId);
    Set<Long> prnQueueIdSet = toLongSet(posDept.getPrnQueue());
    // ...
}
```

**规则R-KIT-03：自助点餐替换打印队列**

```
IF source == SelfOrder AND devId != null THEN
    prnQueues = replacePrnQueueForSelfOrder(mid, sid, devId)
    // 使用自助设备专属的打印队列
END IF
```

### 3.3 传菜联路由规则

**规则R-WTR-01：按传菜间设置路由**

```
settings = PosWaiterBillSetting.get(mid, sid)
FOR EACH setting IN settings:
    prnDepts = toLongSet(setting.getPrnDept())
    foodsToPrint = foods.filter(f -> prnDepts.contains(f.prnDeptLid))
    IF foodsToPrint非空 THEN
        queues = toLongSet(setting.getPrnQueue())
        FOR EACH queueId IN queues:
            createWaiterJob(queueId, foodsToPrint)
        END FOR
    END IF
END FOR
```

**规则R-WTR-02：传菜联按出品部门汇总菜品**

```
// 同一传菜间只打印属于该传菜间的菜品
// 避免一个传菜间收到不属于它的菜品
```

### 3.4 标签单路由规则

**规则R-LBL-01：标签单按做法出品部门路由**

```
IF labelEnabled AND byQuantityOrder THEN
    prnQueues = 按做法出品部门获取队列
    FOR EACH queueId IN prnQueues:
        createLabelJob(queueId, food)
    END FOR
END IF
```

---

## 4. 份数控制规则（R-COPY）

### 4.1 基本份数规则

**规则R-CPY-01：默认份数为1**

```
IF numOfX == null THEN
    numOfX = 1
END IF
```

**规则R-CPY-02：循环创建指定份数**

```
FOR i = 1 TO numOfX:
    createPrintJob()
END FOR
```

**代码证据：**
```java
// PrintJobGenerator.java:829-831
for (int i = 0; i < number; i++) {
    operate.getData().setPageInfo(String.format("第%d张/共%d张", i + 1, number));
    posPrnJobServicePlus.create(prnJobCreate);
}
```

### 4.2 按数量出单规则

**规则R-CPY-03：按数量出单**

```
IF kitchenEnabled AND byQuantityOrder THEN
    IF food.paidNumber是有效正整数 THEN
        number = food.paidNumber.intValueExact()
    ELSE
        LOG_WARN("按数量出单降级为默认份数")
        number = 默认份数
    END IF
END IF
```

**代码证据：**
```java
// PrintJobGenerator.java:547-571
if (kitchenEnabled && byQuantityOrder) {
    BigDecimal paidNumber = food.getPaidNumber();
    if (paidNumber != null && paidNumber.compareTo(BigDecimal.ZERO) > 0) {
        try {
            numberNew = paidNumber.intValueExact();
        } catch (ArithmeticException exception) {
            log.warn("按数量出单降级为默认份数...");
            numberNew = number;
        }
    }
}
```

### 4.3 退菜打印规则

**规则R-CPY-04：退菜打印负数处理**

```
IF 退菜场景 AND g_refundPrintNumberNegative == true THEN
    food.printCount相关逻辑处理
    // 确保退菜不会产生额外的打印任务
END IF
```

---

## 5. 条件显示规则（R-CONDITION）

### 5.1 条件格式

```
格式: paramName operator value
操作符: =, <>, >, <, >=, <=
示例:
  - "isVip = true"        // VIP会员
  - "amt > 1000"          // 大额订单
  - "dishCount <> 0"      // 有菜品
```

### 5.2 参数来源优先级

**规则R-CON-01：tmpParas优先于allParas**

```
IF tmpParas.containsKey(paramName) THEN
    value = tmpParas.get(paramName)
ELSE IF allParas.containsKey(paramName) THEN
    value = allParas.get(paramName)
ELSE
    value = null
END IF
```

**代码证据：**
```java
// PrintJobHandlerBase.java
public Boolean isConditionOk() {
    // 先查tmpParas，再查allParas
}
```

### 5.3 条件判断结果

**规则R-CON-02：条件失败时跳过该行**

```
IF NOT evaluate(condition) THEN
    跳过该打印项
ELSE
    正常渲染该打印项
END IF
```

---

## 6. 故障切换规则（R-FAILOVER）

### 6.1 打印机故障检测

**规则R-FLR-01：状态检查失败视为故障**

```
status = handler.getStatus()
IF status != NORMAL THEN
    触发故障处理流程
END IF
```

### 6.2 主备切换规则

**规则R-FLR-02：主打印机故障时重定向到备用**

```
IF printerStatus == FAULT OR printerStatus == BUSY THEN
    FOR EACH job IN queue:
        standbyPrinters = getStandbyPrinters(queueId)
        IF standbyPrinters非空 THEN
            redirectJob(job, standbyPrinters)
        END IF
    END FOR
    Thread.sleep(5秒)
END IF
```

**代码证据：**
```java
// PrinterWorker.java:93-98
if (status != PrinterStatus.NORMAL) {
    redirect(); // 重发到其他打印队列
    logPrinterFault(status);
    Thread.sleep(Duration.ofSeconds(5));
    continue;
}
```

### 6.3 故障恢复通知

**规则R-FLR-03：故障恢复时记录日志**

```
IF prevStatus == FAULT AND currentStatus == NORMAL THEN
    LOG_INFO("打印机恢复")
END IF
```

---

## 7. 规则执行时序

### 7.1 顾客联生成时序

```
业务事件 (结账)
    │
    ▼
PrintJobTypeSwitchService.get(mid, sid, jobType)
    │
    ├── disabledCustomer == true? ──► 结束
    │
    ▼
numOfCustomer = MAX(0, numOfCustomer ?: 1)
    │
    ▼
PosCustomerBillSettingService.get(mid, sid)
    │
    ▼
FOR EACH setting:
    queues = setting.getPrnQueue()
    FOR EACH queueId IN queues:
        FOR i = 1 TO numOfCustomer:
            PosPrnJobService.create(prnJobCreate)
        END FOR
    END FOR
END FOR
```

### 7.2 厨房联生成时序

```
业务事件 (点菜)
    │
    ▼
PrintJobTypeSwitchService.get(mid, sid, jobType)
    │
    ├── disabledKitchen == true? ──► 结束
    │
    ▼
numOfKitchen = MAX(0, numOfKitchen ?: 1)
    │
    ▼
加载菜品数据、做法数据、口味数据
    │
    ▼
CookwayPrintDeptPlanner.groupByPrintDept(cookMap, tasteMap)
    │
    ├── 按做法出品部门分组
    └── 按菜品出品部门兜底
    │
    ▼
FOR EACH 部门分组:
    dept = posDeptMap.get(deptId)
    prnQueues = dept.getPrnQueue()
    FOR EACH queueId IN prnQueues:
        FOR i = 1 TO numOfKitchen:
            PosPrnJobService.create(kitchenJobCreate)
        END FOR
    END FOR
END FOR
```

### 7.3 打印执行时序

```
PrinterWorker线程启动
    │
    ▼
循环:
    │
    ▼
getStatus() 检查打印机状态
    │
    ├── 故障 ──► redirect() 重定向任务 ──► sleep(5s) ──► 继续
    │
    ▼
take() 从队列取任务
    │
    ▼
runInner(dispatchJob)
    │
    ├── 获取PrinterHandler (根据type选择)
    ├── handler.handle(job)
    │    │
    │    ├── 获取printContents
    │    ├── 遍历每项内容
    │    └── 按contentType分发处理
    │
    ▼
更新任务状态 (COMPLETED/FAILED)
```

---

## 8. 规则约束表

### 8.1 打印开关约束

| 约束ID | 约束描述 | 验证条件 |
|--------|----------|----------|
| C-SW-01 | 打印开关按票据类型唯一 | PrintJobTypeSwitch.type唯一 |
| C-SW-02 | 禁用开关优先于份数 | disabledX=true时忽略numOfX |
| C-SW-03 | 份数不能为负 | numOfX >= 0 |

### 8.2 路由分发约束

| 约束ID | 约束描述 | 验证条件 |
|--------|----------|----------|
| C-ROUTE-01 | 菜品必须有出品部门 | food.prnDeptLid != null && != -1 |
| C-ROUTE-02 | 出品部门必须有打印队列 | dept.prnQueue非空 |
| C-ROUTE-03 | 打印队列必须存在 | queueLid对应有效队列 |
| C-ROUTE-04 | 标签单必须有有效队列 | labelPrnQueueLids非空 |

### 8.3 份数控制约束

| 约束ID | 约束描述 | 验证条件 |
|--------|----------|----------|
| C-COPY-01 | 默认份数为1 | numOfX == null时使用1 |
| C-COPY-02 | 负数份数视为0 | numOfX < 0时使用0 |
| C-COPY-03 | 按数量出单必须是正整数 | paidNumber > 0且为整数 |

---

## 9. 异常场景处理

### 9.1 菜品无出品部门

```
场景: 菜品未设置出品部门
处理: 记录错误日志，跳过该菜品的厨房联
日志: "菜品{}没有设置出品部门"
```

### 9.2 出品部门已删除

```
场景: 出品部门被删除
处理: 记录错误日志，跳过该部门的任务生成
日志: "出品部门{}已经被删除"
```

### 9.3 做法出品部门无有效队列

```
场景: 做法出品部门没有关联打印队列
处理: 记录警告日志，按菜品出品部门打印
日志: "做法出品部门{}没有有效打印队列，按菜品出品部门打印"
```

### 9.4 按数量出单非法

```
场景: paidNumber不是正整数
处理: 降级为默认份数，记录警告日志
日志: "按数量出单降级为默认份数，数量不是正整数"
```

---

**DA4 状态：✅ 规则建模完成，可进入DA5不变量建模阶段**
