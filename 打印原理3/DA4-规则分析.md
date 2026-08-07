# DA4 - 规则分析：打印功能业务规则

> **分析范围**：打印功能
> **版本**：v1.0
> **日期**：2026-08-03

---

## 1. 打印触发规则

### 1.1 业务场景触发规则

| 业务场景 | 触发条件 | 打印类型 | 张数规则 |
|----------|----------|----------|----------|
| 点菜 | DwdFoodOpsService.addFood() | KitchenBill | 按菜品出品部门 |
| 加菜 | 同上 | KitchenBill | 同上 |
| 整单退菜 | DwdFoodOpsService.refund() | CancelBill | 同上 |
| 催菜 | DwdFoodOpsService.urge() | UrgeBill | 同上 |
| 结账 | CheckOutService.normalCheckOut() | CheckOut | 1-2张（可配置） |
| 预结 | 同上（预结模式） | PreCheck | 1张 |
| 弹钱箱 | 结账成功/手动触发 | CashboxPop | 触发设备指令 |
| 划菜 | DwdFoodMakingServicePlus.finished() | WaiterBill | 按传菜间 |
| 交班 | DwdShiftService.shift() | ShiftReport | 1张 |
| 日结 | 日结定时任务 | DayReport | 1张 |
| 会员充值 | MemberService.recharge() | MemberCardRecharge | 1张 |

### 1.2 打印开关规则

```java
// 获取顾客联张数
public int getNumOfCustomer(Long mid, Long sid, PrnStyleTypeEnum jobType) {
    PrintJobTypeSwitch config = getSwitch(mid, sid, jobType);
    if (config == null) return 1;                    // 无配置默认1张
    if (config.isDisabledCustomer()) return 0;         // 禁用则不打印
    int num = config.getNumOfCustomer();
    return num <= 0 ? 1 : num;                       // 小于等于0按1处理
}
```

**规则总结**：
- 无配置：默认打印1张
- disabled=true：完全不打印
- num<=0：按1处理
- 张数>0：按配置张数打印

---

## 2. 队列分配规则

### 2.1 顾客联队列分配规则

**匹配优先级**：
```
结账场景 (forCheckOut=true):
  顾客端: 桌台 → 区域 → 桌型 → PC
  PC端:   PC → 区域 → 桌型 → 桌台

非结账场景:
  顾客端: 桌台 → 区域 → 桌型 → PC
  PC端:   PC → 区域 → 桌型 → 桌台
```

**匹配条件组合**：

| 场景 | forCheckOut | source | 匹配字段 |
|------|-------------|--------|----------|
| 顾客端结账 | true | CUSTOMER | tableLid |
| 顾客端非结账 | false | CUSTOMER | tableLid |
| PC端结账 | true | WAITER | pcLid |
| PC端非结账 | false | WAITER | pcLid |

**兜底规则**：
- 找不到任何匹配配置：不生成顾客联任务
- 配置队列为空：不生成顾客联任务

### 2.2 厨房联队列分配规则

**标准分发规则**：
```java
// 按菜品出品部门分发
for (DwdFood food : foods) {
    Long prnDeptLid = food.getPrnDeptLid();
    PosDept dept = deptMap.get(prnDeptLid);
    Set<Long> queues = parseQueues(dept.getPrnQueue());
    // 为该部门生成打印任务
}
```

**特殊分发规则**：

| 场景 | 规则 | 处理方式 |
|------|------|----------|
| 自助点餐 | 替换为自助点餐队列 | replacePrnQueueForSelfOrder |
| 楼面分单 | floorSplitOrder=true时额外打楼面联 | needFloorSplit |
| 按数量出单 | byQuantityOrder=true时按数量出张 | number = food.paidNumber |
| 多做法 | 使用OrderMenuEx模板 | 分组后生成多张 |

### 2.3 传菜联队列分配规则

```java
// 按传菜间设置分发
for (PosWaiterBillSetting setting : settings) {
    Set<Long> prnDeptSet = parseDepts(setting.getPrnDept());
    List<DwdFood> matchedFoods = filterByDept(foods, prnDeptSet);
    if (matchedFoods.isEmpty()) continue;

    // 统计该传菜间金额小计
    BigDecimal subtotal = calculateSubtotal(matchedFoods);

    // 为该传菜间生成任务
    for (Long queueLid : setting.getPrnQueues()) {
        createJob(queueLid, matchedFoods, subtotal);
    }
}
```

---

## 3. 故障转移规则

### 3.1 打印机状态检测

```java
public PrinterStatus getStatus(Long printerLid) {
    // 1. 检查内存状态缓存
    PrinterStatus cached = statusCache.get(printerLid);
    if (cached != null) return cached;

    // 2. 检查上次失败时间
    Long lastFailTime = failTimeMap.get(printerLid);
    if (lastFailTime != null) {
        // 超过恢复阈值，返回FAULT
        if (System.currentTimeMillis() - lastFailTime < RECOVER_INTERVAL) {
            return PrinterStatus.FAULT;
        }
    }

    return PrinterStatus.HEALTHY;
}
```

### 3.2 分发重试规则

```
分发策略伪代码:

1. 选择主打印机列表
2. 过滤健康打印机 (status != FAULT)
3. if (健康打印机非空):
       随机选择一台
       分发任务
   else:
       选择备打印机列表
       过滤健康打印机
       if (备打印机非空):
           随机选择一台
           分发任务
       else:
           // 无可用打印机
           if (未超时45分钟):
               延迟2秒重试
           else:
               标记失败
```

### 3.3 超时规则

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 重试延迟 | 2000ms | 2秒 |
| 超时阈值 | 45分钟 | 2700000ms |

---

## 4. 内容渲染规则

### 4.1 数据源字段引用规则

```javascript
// 模板字段格式
"customizedContent": "${dsId,fieldName}"
// 或
"customizedContent": "${dsId,nested.fieldName}"
```

**示例**：

| 模板内容 | dsId | fieldName | 渲染结果 |
|----------|------|-----------|----------|
| `${storeInfo,name}` | storeInfo | name | 门店名称 |
| `${billInfo,orderNo}` | billInfo | orderNo | 订单号 |
| `${foodInfo,foodName}` | foodInfo | foodName | 菜品名称 |
| `${payInfo,payTypeName}` | payInfo | payTypeName | 支付方式名称 |

### 4.2 显示条件规则

```java
public boolean isRowVisible(PosPrnStyleRow row, Map<String, Object> dataSourceMap) {
    // 1. 无条件：显示
    if (row.getConditionDsId() == null) return true;

    // 2. 获取条件值
    String leftValue = extractValue(dataSourceMap,
        row.getConditionDsId(), row.getConditionValue());
    String rightValue = row.getConditionValue();

    // 3. 按运算符比较
    switch (row.getConditionOperator()) {
        case EQ: return leftValue.equals(rightValue);
        case NE: return !leftValue.equals(rightValue);
        case GT: return compare(leftValue, rightValue) > 0;
        case GTE: return compare(leftValue, rightValue) >= 0;
        case LT: return compare(leftValue, rightValue) < 0;
        case LTE: return compare(leftValue, rightValue) <= 0;
        case IN: return inList(leftValue, rightValue);
        case NOT_IN: return !inList(leftValue, rightValue);
        case LIKE: return like(leftValue, rightValue);
        case NOT_LIKE: return !like(leftValue, rightValue);
        default: return true;
    }
}
```

**枚举字段比较规则**：
- 枚举值按 `name()` 字符串比较
- 示例：`foodInfo,foodStatus` = "COOK" 表示状态等于COOK

### 4.3 汇总规则

```java
// 行级汇总
if (row.getSummarize()) {
    String colName = row.getSummarizeColName();
    BigDecimal sum = foods.stream()
        .map(f -> f.get(colName))
        .reduce(BigDecimal.ZERO, BigDecimal::add);
    return sum;
}
```

---

## 5. 任务状态规则

### 5.1 状态流转规则

```
                    ┌─────────────┐
                    │   PENDING   │
                    │   (等待中)   │
                    └──────┬──────┘
                           │ initJob成功
                           ▼
┌─────────────┐    ┌─────────────┐
│   FAILED    │◀───│  PRINTING   │
│   (失败)     │    │   (打印中)   │
└─────────────┘    └──────┬──────┘
                           │ 打印完成
                           ▼
                    ┌─────────────┐
                    │   SUCCESS   │
                    │   (成功)    │
                    └─────────────┘
```

### 5.2 状态更新规则

| 事件 | 触发时机 | 新状态 |
|------|----------|--------|
| 任务创建 | PosPrnJobServicePlus.create() | PENDING |
| 开始处理 | PrinterWorker.dequeue() | PRINTING |
| 打印成功 | PrinterWorker.printSuccess() | SUCCESS + .job→.del |
| 打印失败 | PrinterWorker.printFailed() | FAILED + 记录原因 |
| 重新打印 | PosPrnJobServicePlus.reprint() | 重新PENDING |

### 5.3 打印计数规则

```java
// 打印次数递增
public void addPrnCount(Long lid) {
    String key = "pos_service:pos_prn_job:count:" + lid;
    redisTemplate.opsForValue().increment(key);
}

// 重打时重置计数
public void resetPrnCount(Long lid) {
    String key = "pos_service:pos_prn_job:count:" + lid;
    redisTemplate.delete(key);
}
```

---

## 6. 事务边界规则

### 6.1 事务传播规则

| 服务方法 | 事务属性 | 说明 |
|----------|----------|------|
| PrintJobGenerator.generateXxx() | 无事务 | 由调用方控制 |
| PosPrnJobServicePlus.create() | REQUIRED | 插入DB+写文件 |
| PosPrnJobServicePlus.reprint() | REQUIRED | 重打新任务 |
| PosPrnQueueServicePlus.initJob() | 无事务 | 异步执行 |
| PosPrnQueueServicePlus.dispatchJob() | 无事务 | 异步执行 |

### 6.2 事务边界建议

```java
@Transactional
public void normalCheckOut(DwdBill bill, ...) {
    // 1. 业务操作（订单状态、支付记录）
    updateBillStatus(bill);
    insertPayRecords(pays);

    // 2. 打印任务创建（在同一事务）
    printJobGenerator.generateCustomerJob(...);

    // 3. 异步后续（PrintUtil.initJob之后）
    // 由JobTaskHandle异步处理，不在当前事务
}
```

**警告**：避免在事务回滚后触发打印任务

---

## 7. 配置约束规则

### 7.1 队列配置约束

- 同一商户+门店下队列名称唯一
- 主/备打印机可为空，但不能同时为空
- 打印机ID必须存在且有效

### 7.2 样式配置约束

- 同一打印类型下 showIndex 唯一
- displayCondition JSON 必须符合格式规范
- 数据源ID必须为已定义的数据源

### 7.3 打印机配置约束

- 同一商户+门店下打印机名称唯一
- extraInfo JSON格式必须符合type对应的schema
- 云打印机需要有效的API密钥

---

*文档版本：v1.0 | 生成时间：2026-08-03*
