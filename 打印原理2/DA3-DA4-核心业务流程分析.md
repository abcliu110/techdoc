# 打印功能 DA3-DA4：核心业务流程分析

> **分析范围**：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui  
> **分析时间**：2026-08-03  
> **SOP 依据**：SOP-00 业务系统分析 v2.9  
> **前置文档**：DA0-DA1-全景扫描与概念建模.md

---

## 1. 概述

本文档分析打印系统的三大核心业务流程：点餐流程、结账流程、划菜流程。每条流程覆盖完整的调用链、数据流、决策点和异常处理。

### 1.1 三大流程概览

| 流程 | 触发时机 | 打印类型 | 核心类 |
|------|----------|----------|--------|
| 点餐流程 | 送单（toOrder） | FOR_KITCHEN（厨房联） | `PrintJobGenerator.generateKitchenJob()` |
| 结账流程 | 结账完成（checkOut） | FOR_CUSTOMER（顾客联） | `PrintJobGenerator.generateCustomerJob()` |
| 划菜流程 | 划菜完成（finished） | FOR_DISH_DELIVERER（划菜联） | `PrintJobGenerator.generateWaiterJob()` |

---

## 2. 点餐流程（Kitchen Print）

### 2.1 完整调用链

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                              点餐流程完整调用链                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  【前端触发】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  POS前端 → DwdBillOpsForBizController.toOrder()      // 送单接口                        │  │
│  │          → DwdBillServicePlus.toOrder()              // 转调加菜服务                   │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【菜品落库】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  DwdBillServicePlus.toOrder()                                                   │  │
│  │     → DwdFoodOpsServiceImpl.addFood()        // 实际加菜入口                        │  │
│  │          → PtDishMapper.selectByCode()       // 查询菜品信息                        │  │
│  │          → DwdFoodMapper.insert()            // 保存菜品明细                        │  │
│  │          → DwdCook/DwdTaste/DwdRequire      // 保存做法/口味/要求                   │  │
│  │          → CalcOrderService.calc()           // 重新计算订单金额                    │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【打印任务生成】                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  OrderServiceUtil.send() 或 DwdBillOpsServiceImpl 内部调用                            │  │
│  │     → OrderServiceUtil.generateJob()         // 统一入口（委托 PrintJobGenerator）     │  │
│  │          → PrintJobGenerator.generateKitchenJob()  // 生成厨房联打印任务                │  │
│  │               ├─ CookwayPrintDeptPlanner        // 按做法分组到出品部门                │  │
│  │               ├─ FoodLabelPrintJobCreator       // 生成标签打印任务（可选）           │  │
│  │               └─ PosPrnJobServicePlus.create()  // 持久化任务到数据库                 │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【任务分发】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PrintUtil.initJob()                        // 异步触发初始化                         │  │
│  │     → PosPrnQueueServicePlus.initJob()      // 加载任务 + 渲染模板                    │  │
│  │          → PosPrnQueueServicePlus.dispatchJob()  // 分发到打印机队列                  │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【打印执行】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PrinterWorker.run()                        // 工作线程从队列取任务                   │  │
│  │     → 读取 .job 文件                        // 加载打印内容                          │  │
│  │     → 生成 ESC/POS 指令                    // 根据打印机型号生成指令                 │  │
│  │     → 发送到打印机                         // 网口/串口/USB/云端                     │  │
│  │     → 更新任务状态                         // SUCCESS / FAILED                        │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 关键代码片段

#### 2.2.1 加菜入口（DwdFoodOpsServiceImpl）

```java
// DwdFoodOpsServiceImpl.addFood() - 核心加菜逻辑
public DwdBillOpsVO addFood(DwdFoodAddDTO request, BizAdminVO user) {
    // 1. 校验菜品（存在、启用、库存）
    PtDish dish = ptDishMapper.selectByCode(mid, sid, foodCode);
    Assert.notNull(dish, "菜品不存在或已禁用");

    // 2. 保存菜品明细
    DwdFood dwdFood = new DwdFood();
    dwdFood.setFoodName(dish.getName());
    dwdFood.setFoodNumber(request.getFoodNumber());
    dwdFood.setDeptLid(dish.getDeptLid());  // 关联出品部门
    dwdFood.setCookwayLid(request.getCookwayLid());  // 做法
    dwdFood.setFoodStatus(FoodStatusEnum.PENDING);  // 待送单
    dwdFoodMapper.insert(dwdFood);

    // 3. 保存做法/口味/要求
    if (CollUtil.isNotEmpty(cookways)) {
        DwdCook cook = new DwdCook();
        cook.setDwdFoodLid(dwdFood.getLid());
        cook.setCookwayLid(cookwayLid);
        dwdCookMapper.insert(cook);
    }

    // 4. 重新计算订单
    CalcOrderVO calc = CalcOrderService.calc(mid, lid);

    // 5. 送单打印（通过消息触发）
    // 注：实际触发点在前端调用 toOrder 接口
    return OrderServiceUtil.toBillOpsVO(calc);
}
```

#### 2.2.2 送单触发（OrderServiceUtil.send）

```java
// OrderServiceUtil.send() - 送单并触发打印
public static void send(Long mid, Long lid, BizAdminVO user, Long devId, String source) {
    // 1. 更新菜品状态为已送
    OrderServiceUtil.forFoodUpdate()
        .set(DwdFood::getFoodStatus, FoodStatusEnum.SENT)
        .eq(DwdFood::getMid, mid)
        .eq(DwdFood::getSaasOrderNo, lid)
        .eq(DwdFood::getFoodStatus, FoodStatusEnum.PENDING)
        .update();

    // 2. 生成厨房打印任务
    DwdBill order = OrderServiceUtil.getOrder(mid, lid);
    List<DwdFood> foods = OrderServiceUtil.getPendingFoods(mid, lid);
    List<DwdCook> cooks = OrderServiceUtil.getCooks(mid, lid);
    List<DwdTaste> tastes = OrderServiceUtil.getTastes(mid, lid);

    generateKitchenJob(PrnStyleTypeEnum.OrderMenu, order, foods, cooks, tastes,
                      user, true, source, devId, false);
}
```

#### 2.2.3 厨房打印任务生成（PrintJobGenerator）

```java
// PrintJobGenerator.generateKitchenJob() - 核心编排逻辑
public void generateKitchenJob(PrnStyleTypeEnum styleType, DwdBill order,
                               List<DwdFood> foods, List<DwdCook> cooks,
                               List<DwdTaste> tastes, BizAdminVO user,
                               boolean calcDept, String source, Long devId,
                               boolean reprint) {
    // 1. 检查打印开关
    int printCount = getNumOfKitchen(mid, sid, styleType);
    if (printCount <= 0) {
        return;  // 打印被禁用
    }

    // 2. 按做法分组到出品部门（支持多厨房）
    CookwayPrintDeptPlanner planner = new CookwayPrintDeptPlanner();
    Map<Long, List<DwdFood>> deptFoodMap = planner.plan(foods, cooks);

    // 3. 为每个出品部门生成打印任务
    for (Map.Entry<Long, List<DwdFood>> entry : deptFoodMap.entrySet()) {
        Long deptLid = entry.getKey();
        List<DwdFood> deptFoods = entry.getValue();

        // 4. 构建数据源
        PrnDataSourceDTO<?> storeInfo = OrderServiceUtil.getStoreInfo(sid);
        PrnDataSourceDTO<?> billInfo = DwdBillConvert.toInfo(order);
        PrnDataSourceDTO<?> foodInfo = DwdFoodConvert.toInfoList(deptFoods);

        // 5. 获取出品部门的打印队列
        PosDept dept = posDeptService.getByLid(mid, deptLid);
        String prnQueueLid = dept.getPrnQueue();  // 逗号分隔的队列LID

        // 6. 创建打印任务
        PosPrnJobCreateDTO createDTO = new PosPrnJobCreateDTO();
        createDTO.setMid(mid);
        createDTO.setSid(sid);
        createDTO.setType(styleType);
        createDTO.setPurpose(PrnJobPurposeEnum.FOR_KITCHEN);
        createDTO.setPrnQueueLid(prnQueueLid);
        createDTO.setSources(sources);
        createDTO.setSource(source);

        posPrnJobServicePlus.create(createDTO);

        // 7. 触发异步分发
        PrintUtil.initJob(createDTO.getLid());
    }

    // 8. 标签打印（可选）
    if (printLabelEnabled) {
        foodLabelPrintJobCreator.create(order, foods, user, devId);
    }
}
```

### 2.3 决策点与分支

| 决策点 | 条件 | 分支行为 |
|--------|------|----------|
| 打印开关检查 | `numOfKitchen > 0` | 为零则跳过打印 |
| 多厨房分组 | 菜品按做法/部门分组 | 每个部门生成独立任务 |
| 标签打印 | `PosConfigKey.g_foodLabelPrintEnabled` | 启用时额外生成标签打印任务 |
| 分单打印 | `PosConfigKey.g_floorSplitPrintEnabled` | 启用时按楼层分组打印 |
| 自助点餐路由 | 订单来源为扫码点餐 | 路由到特定出品部门 |

### 2.4 异常处理

| 异常场景 | 处理方式 |
|----------|----------|
| 菜品不存在 | 抛出 `BizException`，不进入打印流程 |
| 出品部门未配置打印队列 | 记录错误日志，跳过该部门打印 |
| 打印机故障 | 任务状态保持 PENDING，后续可重试 |
| 数据库写入失败 | 事务回滚，打印任务不生成 |

---

## 3. 结账流程（Customer Print）

### 3.1 完整调用链

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                              结账流程完整调用链                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  【前端触发】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  POS前端 → CheckOutController.normalCheckOut()     // 结账接口                         │  │
│  │          → DwdBillOpsServiceImpl.checkOut()        // 结账服务                         │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【结账核心处理】                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  DwdBillOpsServiceImpl.checkOut()                                                    │  │
│  │     → CalcOrderService.calc()                 // 重新计算订单                         │  │
│  │          → DwdBillCheckOutUtil.check()        // 校验支付方式                         │  │
│  │          → OrderServiceUtil.dealMobile()       // 处理移动支付                         │  │
│  │          → OrderServiceUtil.CardConsume()      // 处理会员卡                           │  │
│  │          → OrderServiceUtil.checkOut()         // 更新订单状态为CLOSED                 │  │
│  │          → crmPointsEarnLocalService.refresh() // 更新会员积分                         │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【打印任务生成】                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  结账成功后触发打印                                                                      │  │
│  │     → OrderServiceUtil.generateCustomerJob()    // 生成顾客联打印任务                  │  │
│  │          → PrintJobGenerator.generateCustomerJob()                                      │  │
│  │               ├─ PosCustomerBillSetting        // 获取顾客联打印队列                  │  │
│  │               ├─ PrnDataSourceDTO 构造         // 构建数据源（store/bill/food/pay）  │  │
│  │               └─ PosPrnJobServicePlus.create()  // 持久化任务                          │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【任务分发与执行】                                                                           │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PrintUtil.initJob()                        // 异步分发                               │  │
│  │     → PosPrnQueueServicePlus.dispatchJob()  // 发送到顾客联打印机                     │  │
│  │          → PrinterWorker.run()               // 执行打印                               │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 关键代码片段

#### 3.2.1 结账入口（DwdBillOpsServiceImpl.checkOut）

```java
// DwdBillOpsServiceImpl.checkOut() - 结账核心逻辑
@Override
@Transactional(rollbackFor = Throwable.class)
public CheckOutVO checkOut(DwdBillCheckOutDTO request, BizAdminVO user) throws Throwable {
    Long mid = request.getMid();
    Long lid = request.getLid();
    List<DwdPayCreateDTO> pays = request.getPays();

    // 1. 重新计算订单（确保金额准确）
    CalcOrderVO calc = OrderServiceUtil.calc(mid, lid, true);
    DwdBill dwdBill = calc.getDwdBill();
    List<DwdFood> dwdFoods = calc.getDwdFoods();

    // 2. 校验支付方式
    check(pays, dwdBill, request, user);

    // 3. 处理移动支付
    CheckOutVO checkOutVO = dealMobile(types, calc, request, user);

    // 4. 更新现金
    updateCash(dwdBill);

    // 5. 处理挂账
    OrderServiceUtil.dealCredit(types, dwdBill, request);

    // 6. 处理会员卡
    OrderServiceUtil.CardConsumeResult cardConsumeResult =
        OrderServiceUtil.dealCardWithBalance(types, dwdBill, request);

    // 7. 处理积分抵现
    OrderServiceUtil.dealCardPoint(types, dwdBill, memberCheckVO, request);

    // 8. 结账（更新订单状态）
    calc = OrderServiceUtil.checkOut(dwdBill, dwdFoods, checkType, user);

    // 9. 更新会员积分
    crmPointsEarnLocalService.refreshBillPointsForPrint(calc.getDwdBill(), memberCheckVO, ...);

    // 10. 生成顾客联打印任务
    OrderServiceUtil.generateCustomerJob(
        PrnStyleTypeEnum.CheckOut,
        dwdBill,
        dwdFoods,
        pays,
        request.getDevId(),
        user,
        request.getSource());

    // 11. 更新交班数据
    updateCash(dwdBill);

    return checkOutVO;
}
```

#### 3.2.2 顾客联打印任务生成（PrintJobGenerator）

```java
// PrintJobGenerator.generateCustomerJob() - 顾客联打印
public void generateCustomerJob(PrnStyleTypeEnum styleType, DwdBill order,
                                 List<DwdFood> foods, List<DwdPay> pays,
                                 Long devId, BizAdminVO user, String source) {
    // 1. 检查打印开关
    int printCount = getNumOfCustomer(mid, sid, styleType);
    if (printCount <= 0) {
        return;
    }

    // 2. 获取顾客联打印队列（按优先级：桌台 > 区域 > 桌型 > PC）
    PosCustomerBillSetting setting =
        posCustomerBillSettingService.getSetting(mid, sid, order.getTableLid(), devId);
    String prnQueueLid = setting.getPrnQueue();

    // 3. 构建数据源
    PrnDataSourceDTO<?> storeInfo = OrderServiceUtil.getStoreInfo(sid);
    PrnDataSourceDTO<?> billInfo = DwdBillConvert.toInfo(order);

    // 菜品信息（需要特殊处理金额显示）
    List<FoodInfo> foodInfoList = DwdFoodConvert.toInfoList(foods);
    DwdFoodConvert.addPrnDataSourceEx(foods, billInfo, order, sources);
    PrnDataSourceDTO<?> foodInfo = PrnDataSourceDTO.array(foodInfoList, "food_info");

    // 支付信息
    PrnDataSourceDTO<?> payInfo = DwdPayConvert.toInfoList(pays);

    // 操作员信息
    PrnDataSourceDTO<?> operate = PrnDataSourceDTO.operate(user);

    // 4. 创建打印任务
    PosPrnJobCreateDTO createDTO = new PosPrnJobCreateDTO();
    createDTO.setMid(mid);
    createDTO.setSid(sid);
    createDTO.setType(styleType);
    createDTO.setPurpose(PrnJobPurposeEnum.FOR_CUSTOMER);
    createDTO.setPrnQueueLid(prnQueueLid);
    createDTO.setSources(sources);
    createDTO.setSource(source);
    createDTO.setDevId(devId);

    posPrnJobServicePlus.create(createDTO);
    PrintUtil.initJob(createDTO.getLid());
}
```

### 3.3 决策点与分支

| 决策点 | 条件 | 分支行为 |
|--------|------|----------|
| 打印开关检查 | `numOfCustomer > 0` | 为零则跳过打印 |
| 打印份数 | `numOfCustomer = N` | 生成 N 份打印任务 |
| 顾客联队列选择 | 优先级：桌台 > 区域 > 桌型 > PC | 根据配置层级选择队列 |
| 移动支付 | `checkOutVO.mobile == true` | 打印可能在支付成功后再触发 |
| 快速结账（K） | `checkType == K` | 打印结算单而非结账单 |

### 3.4 特殊场景

#### 3.4.1 退菜打印（refundByFoods / refundByOrder）

```java
// DwdBillOpsServiceImpl.refundByFoods() - 部分退菜
// 行 3473-3483
OrderServiceUtil.generateJob(
    PrnStyleTypeEnum.BackMenu, calc, user, request.getDevId(), request.getSource());
OrderServiceUtil.generateCustomerJob(
    PrnStyleTypeEnum.CheckOut,
    refundOrder,
    refundFoods,
    refundPays,
    request.getDevId(),
    user,
    request.getSource());
```

退菜流程会同时打印：
1. `BackMenu` - 退菜单（厨房联，通知厨房取消该菜品）
2. `CheckOut` - 结账单（顾客联，显示退款明细）

#### 3.4.2 反结账打印（cancel）

反结账会撤销原结账单打印，并可能生成新的结算单。

---

## 4. 划菜流程（Waiter/Dish Deliverer Print）

### 4.1 完整调用链

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│                              划菜流程完整调用链                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  【前端触发】                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  KDS前端 → DwdFoodMakingController.finished()    // 划菜接口                            │  │
│  │          → DwdFoodMakingServicePlus.finished()  // 划菜服务                            │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【菜品状态更新】                                                                              │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  DwdFoodMakingServicePlus.finished()                                               │  │
│  │     → DwdFoodMapper.updateStatus()        // 更新菜品状态为SERVED                   │  │
│  │     → DwdFoodOpsServiceImpl.urgentUpdate() // 更新催菜信息                          │  │
│  │     → MessageUtil.broadcastInfo()          // 推送消息到前端                        │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【打印任务生成】                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  DwdFoodMakingService 或 DwdBillOpsService 内部调用                                  │  │
│  │     → OrderServiceUtil.generateWaiterJob()    // 生成划菜联打印任务                   │  │
│  │          → PrintJobGenerator.generateWaiterJob()                                     │  │
│  │               ├─ PosWaiterBillSetting        // 获取划菜联打印队列                   │  │
│  │               ├─ 按出品部门过滤菜品           // 只打印当前部门的菜品                │  │
│  │               └─ PosPrnJobServicePlus.create()                                      │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                      │                                                        │
│                                      ▼                                                        │
│  【任务分发与执行】                                                                           │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │  PrintUtil.initJob()                        // 异步分发                               │  │
│  │     → PosPrnQueueServiceService.dispatchJob()  // 发送到传菜间打印机                 │  │
│  └────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 关键代码片段

#### 4.2.1 划菜入口（DwdFoodMakingServicePlus）

```java
// DwdFoodMakingServicePlus.finished() - 划菜核心逻辑
public void finished(DwdFoodMakingFinishedDTO request, BizAdminVO user) {
    Long mid = request.getMid();
    Long lid = request.getLid();
    Set<Long> foodLids = request.getFoodLids();

    // 1. 更新菜品状态为已上菜
    OrderServiceUtil.forFoodUpdate()
        .set(DwdFood::getFoodStatus, FoodStatusEnum.SERVED)
        .eq(DwdFood::getMid, mid)
        .eq(DwdFood::getSaasOrderNo, lid)
        .in(DwdFood::getLid, foodLids)
        .update();

    // 2. 推送消息到前端
    MessageUtil.broadcastInfo("RefreshOrder", mid, sid, lid);

    // 3. 生成划菜打印任务（按出品部门）
    DwdBill order = OrderServiceUtil.getOrder(mid, lid);
    List<DwdFood> foods = OrderServiceUtil.getFoods(mid, lid, foodLids);

    OrderServiceUtil.generateWaiterJob(PrnStyleTypeEnum.TotalBill, order, foods, user);
}
```

#### 4.2.2 划菜联打印任务生成（PrintJobGenerator）

```java
// PrintJobGenerator.generateWaiterJob() - 划菜联打印
public void generateWaiterJob(PrnStyleTypeEnum styleType, DwdBill order,
                               List<DwdFood> foods, BizAdminVO user) {
    // 1. 检查打印开关
    int printCount = getNumOfWaiter(mid, sid, styleType);
    if (printCount <= 0) {
        return;
    }

    // 2. 按出品部门分组
    Map<Long, List<DwdFood>> deptFoodMap =
        foods.stream().collect(Collectors.groupingBy(DwdFood::getDeptLid));

    // 3. 为每个传菜间生成打印任务
    for (Map.Entry<Long, List<DwdFood>> entry : deptFoodMap.entrySet()) {
        Long deptLid = entry.getKey();
        List<DwdFood> deptFoods = entry.getValue();

        // 4. 获取传菜间打印队列
        PosWaiterBillSetting setting =
            posWaiterBillSettingService.getSetting(mid, sid, deptLid);
        String prnQueueLid = setting.getPrnQueue();

        // 5. 构建数据源
        PrnDataSourceDTO<?> storeInfo = OrderServiceUtil.getStoreInfo(sid);
        PrnDataSourceDTO<?> billInfo = DwdBillConvert.toInfo(order);
        PrnDataSourceDTO<?> foodInfo = DwdFoodConvert.toInfoList(deptFoods);
        PrnDataSourceDTO<?> operate = PrnDataSourceDTO.operate(user);

        List<PrnDataSourceDTO<?>> sources = CollUtil.newArrayList(
            operate, storeInfo, billInfo, foodInfo
        );

        // 6. 创建打印任务
        PosPrnJobCreateDTO createDTO = new PosPrnJobCreateDTO();
        createDTO.setMid(mid);
        createDTO.setSid(sid);
        createDTO.setType(styleType);
        createDTO.setPurpose(PrnJobPurposeEnum.FOR_DISH_DELIVERER);
        createDTO.setPrnQueueLid(prnQueueLid);
        createDTO.setSources(sources);
        createDTO.setDeptLid(deptLid);  // 标记出品部门

        posPrnJobServicePlus.create(createDTO);
        PrintUtil.initJob(createDTO.getLid());
    }
}
```

### 4.3 决策点与分支

| 决策点 | 条件 | 分支行为 |
|--------|------|----------|
| 打印开关检查 | `numOfWaiter > 0` | 为零则跳过打印 |
| 多传菜间 | 菜品按出品部门分组 | 每个传菜间生成独立任务 |
| 菜品状态 | 只有 SERVED 状态才触发 | 防止重复打印 |

### 4.4 异常处理

| 异常场景 | 处理方式 |
|----------|----------|
| 传菜间未配置打印队列 | 记录错误日志，跳过该传菜间打印 |
| 菜品已被取消 | 更新状态时条件过滤，自动跳过 |
| 打印机故障 | 任务状态保持 PENDING |

---

## 5. 打印任务持久化与分发

### 5.1 任务创建（PosPrnJobServicePlus.create）

```java
// PosPrnJobServicePlus.create() - 任务创建
@Override
public PosPrnJob create(PosPrnJobCreateDTO createDTO) {
    // 1. 校验字段
    Assert.notNull(createDTO.getMid(), "商户ID不能为空");
    Assert.notNull(createDTO.getPrnQueueLid(), "打印队列不能为空");

    // 2. 生成雪花ID
    Long lid = IdWorkerPlus.getId();

    // 3. 构建任务实体
    PosPrnJob job = new PosPrnJob();
    job.setMid(createDTO.getMid());
    job.setSid(createDTO.getSid());
    job.setType(createDTO.getType());
    job.setPurpose(createDTO.getPurpose());
    job.setPrnQueueLid(createDTO.getPrnQueueLid());
    job.setStatus(PrnJobStatusEnum.PENDING);
    job.setCreateBy(createDTO.getUserName());
    job.setCreateTime(LocalDateTime.now());

    // 4. 写入数据库
    posPrnJobMapper.insert(job);

    // 5. 写入 .job 文件
    String jobFile = buildJobFilePath(lid, createDTO);
    writeJobFile(jobFile, createDTO);

    return job;
}
```

### 5.2 任务初始化与分发（PrintUtil.initJob）

```java
// PrintUtil.initJob() - 触发任务初始化
public static void initJob(Long jobLid) {
    // 通过消息队列异步触发
    messagePublisher.publish("print.job.init", jobLid);
}

// PosPrnQueueServicePlus.initJob() - 任务初始化
public void initJob(Long jobLid) {
    // 1. 从数据库加载任务
    PosPrnJob job = posPrnJobMapper.selectByLid(jobLid);

    // 2. 从 .job 文件加载数据源
    String jobFile = getJobFilePath(jobLid);
    PosPrnJobCreateDTO createDTO = readJobFile(jobFile);

    // 3. 补全打印模板
    List<PosPrnStyleRow> styleRows = posPrnStyleRowService.getByType(
        job.getMid(), job.getSid(), job.getType());

    // 4. 渲染打印内容
    String content = PrintJobInitUtil.convert(styleRows, createDTO.getSources());

    // 5. 分发到打印机
    dispatchJob(job, content);
}
```

### 5.3 任务分发（PosPrnQueueServicePlus.dispatchJob）

```java
// PosPrnQueueServicePlus.dispatchJob() - 分发到打印机
public void dispatchJob(PosPrnJob job, String content) {
    // 1. 查询队列配置
    PosPrnQueue queue = posPrnQueueMapper.selectByLid(job.getPrnQueueLid());

    // 2. 解析主/备打印机ID
    List<Long> primaryPrinterLids = parsePrinterLids(queue.getPrimaryPrinter());
    List<Long> standbyPrinterLids = parsePrinterLids(queue.getStandbyPrinter());

    // 3. 过滤故障打印机
    List<Long> healthyPrinters = selectHealthyPrinters(primaryPrinterLids);
    if (CollUtil.isEmpty(healthyPrinters)) {
        healthyPrinters = selectHealthyPrinters(standbyPrinterLids);
    }

    // 4. 负载均衡选择
    Long selectedPrinterLid = RandomLoadBalanceUtil.select(healthyPrinters);

    // 5. 发送到打印机
    PrintUtil.handle(selectedPrinterLid, content);
}
```

---

## 6. 打印执行层

### 6.1 线下模式（PrinterWorkerServiceOfflineImpl）

```java
// PrinterWorkerServiceOfflineImpl.handlePrnJob() - 离线打印
public void handlePrnJob(Long jobLid) {
    // 1. 从队列获取任务
    PrinterJob printerJob = queue.take();

    // 2. 读取 .job 文件
    PosPrnJobCreateDTO createDTO = readJobFile(printerJob.getJobFile());

    // 3. 查询打印机配置
    PosPrnPrinter printer = posPrnPrinterMapper.selectByLid(createDTO.getPrinterLid());

    // 4. 根据打印机类型生成指令
    String content;
    switch (printer.getType()) {
        case NET:
            content = generateNetPrinterContent(createDTO);
            break;
        case COM:
            content = generateComPrinterContent(createDTO);
            break;
        case USB:
            content = generateUsbPrinterContent(createDTO);
            break;
        default:
            content = generateDefaultContent(createDTO);
    }

    // 5. 发送到打印机
    try {
        sendToPrinter(printer, content);
        updateJobStatus(jobLid, PrnJobStatusEnum.SUCCESS);
    } catch (Exception e) {
        log.error("打印失败: {}", jobLid, e);
        updateJobStatus(jobLid, PrnJobStatusEnum.FAILED);
    }

    // 6. 标记任务完成（删除 .job 文件）
    removeFromFile(jobLid);
}
```

### 6.2 云端模式（云打印机）

```java
// 云打印机处理流程
public void handleCloudPrinter(Long printerLid, String content) {
    PosPrnPrinter printer = posPrnPrinterMapper.selectByLid(printerLid);
    PrinterConfig config = JSON.parseObject(printer.getExtraInfo(), PrinterConfig.class);

    switch (printer.getType()) {
        case XY_CLOUD:  // 芯烨云
            XpCloudPrinter.print(config.getApiKey(), config.getMachineCode(), content);
            break;
        case JB_CLOUD:  // 佳博云
            JBCloudPrinter.print(config.getApiKey(), config.getMachineCode(), content);
            break;
    }
}
```

---

## 7. 流程对比总结

### 7.1 三流程对比表

| 维度 | 点餐流程 | 结账流程 | 划菜流程 |
|------|----------|----------|----------|
| **触发入口** | `toOrder()` | `checkOut()` | `finished()` |
| **打印用途** | FOR_KITCHEN | FOR_CUSTOMER | FOR_DISH_DELIVERER |
| **打印类型** | OrderMenu (10) | CheckOut (26) | TotalBill (14) |
| **数据源构建** | store + bill + foods + cooks + tastes | store + bill + foods + pays | store + bill + foods |
| **队列选择** | PosDept.prnQueue | PosCustomerBillSetting | PosWaiterBillSetting |
| **分组逻辑** | 按出品部门/做法 | 无分组 | 按出品部门 |
| **打印份数** | 可配置 | 可配置 | 可配置 |
| **异步/同步** | 异步 | 异步 | 异步 |

### 7.2 统一入口（OrderServiceUtil）

```java
// OrderServiceUtil - 打印任务统一入口
public class OrderServiceUtil {

    // 送单（点餐）
    public static void send(Long mid, Long lid, BizAdminVO user, Long devId, String source) {
        DwdBill order = getOrder(mid, lid);
        List<DwdFood> foods = getPendingFoods(mid, lid);
        List<DwdCook> cooks = getCooks(mid, lid);
        List<DwdTaste> tastes = getTastes(mid, lid);
        generateKitchenJob(PrnStyleTypeEnum.OrderMenu, order, foods, cooks, tastes,
                          user, true, source, devId, false);
    }

    // 厨房打印
    public static void generateKitchenJob(PrnStyleTypeEnum styleType, DwdBill order,
                                          List<DwdFood> foods, List<DwdCook> cooks,
                                          List<DwdTaste> tastes, BizAdminVO user,
                                          boolean calcDept, String source, Long devId,
                                          boolean reprint) {
        printJobGenerator.generateKitchenJob(styleType, order, foods, cooks, tastes,
                                              user, calcDept, source, devId, reprint);
    }

    // 顾客联打印
    public static void generateCustomerJob(PrnStyleTypeEnum styleType, DwdBill order,
                                            List<DwdFood> foods, Long devId,
                                            BizAdminVO user, String source) {
        printJobGenerator.generateCustomerJob(styleType, order, foods, null, devId,
                                              user, source);
    }

    // 顾客联打印（带支付信息）
    public static void generateCustomerJob(PrnStyleTypeEnum styleType, DwdBill order,
                                            List<DwdFood> foods, List<DwdPay> pays,
                                            Long devId, BizAdminVO user, String source) {
        printJobGenerator.generateCustomerJob(styleType, order, foods, pays, devId,
                                              user, source);
    }

    // 划菜联打印
    public static void generateWaiterJob(PrnStyleTypeEnum styleType, DwdBill order,
                                          List<DwdFood> foods, BizAdminVO user) {
        printJobGenerator.generateWaiterJob(styleType, order, foods, user);
    }
}
```

---

## 8. 异常处理总结

### 8.1 打印任务级异常

| 异常类型 | 触发场景 | 处理方式 | 是否回滚业务 |
|----------|----------|----------|--------------|
| 打印机离线 | 打印机网络断开 | 任务保持 PENDING | 否 |
| 打印超时 | 打印机响应超时 | 任务标记 FAILED，可重试 | 否 |
| 队列不存在 | prnQueueLid 无效 | 跳过打印，记录日志 | 否 |
| 模板不存在 | 样式类型无配置 | 跳过打印，记录日志 | 否 |

### 8.2 业务级异常

| 异常类型 | 触发场景 | 处理方式 | 是否回滚业务 |
|----------|----------|----------|--------------|
| 菜品不存在 | 点餐时菜品已删除 | 抛出异常 | 是 |
| 支付失败 | 余额不足 | 抛出异常 | 是 |
| 日结锁定 | 日结后操作订单 | 抛出异常 | 是 |

---

## 9. 文档状态

**文档状态**：DA3-DA4 完成  
**下一步**：DA5 数据模型分析、DA6 功能深度分析（样式配置）

