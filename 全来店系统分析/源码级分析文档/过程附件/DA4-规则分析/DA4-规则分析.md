# DA4 规则分析 - KACI POS 核心规则与状态机

**文档版本**: 1.0  
**生成日期**: 2026-08-31  
**分析范围**: 全来店餐饮 POS 系统核心业务规则  
**证据级别**: E-SRC (精确源码行号)

---

## 1. 状态枚举定义

### 1.1 订单状态枚举 (OrderStatusEnum)

**源码位置**: `kaci-pos-localserver/src/com/shouqianba/localserver/biz/common/enums/order/OrderStatusEnum.java`

```java
public enum OrderStatusEnum implements IIntegerEnum {
    ORDER_DJZ(Integer.valueOf(10), "待结账"),    // 10 - 订单创建，等待结账
    ORDER_YJZ(Integer.valueOf(20), "已结账"),    // 20 - 订单已完成支付
    ORDER_DTD(Integer.valueOf(29), "待退单"),    // 29 - 退单审核中
    ORDER_YTD(Integer.valueOf(30), "已退单"),    // 30 - 整单退款完成
    ORDER_YCX(Integer.valueOf(40), "已冲销"),    // 40 - 订单冲销(部分退款)
    ORDER_YQX(Integer.valueOf(50), "已取消");   // 50 - 订单取消
}
```

**状态机图**:
```
                                    [退单审核]
                                        ↓
    [待结账]───[结账]──→[已结账]←─[反结账]──[待退单]──→[已退单]
      ↑              │                   │
      │              │                   │
      └─────[取消]───┴───────[取消]───────┘
                                        │
                                   [部分退款]
                                        ↓
                                    [已冲销]
```

### 1.2 支付状态枚举 (IsPayEnum)

**源码位置**: `kaci-pos-localserver/src/com/shouqianba/localserver/order/enums/IsPayEnum.java`

```java
public enum IsPayEnum implements IIntegerEnum {
    WZF(Integer.valueOf(0), "未支付"),     // 0 - 订单未付款
    YZF(Integer.valueOf(1), "已支付"),     // 1 - 订单已付款
    ZFZ(Integer.valueOf(2), "支付中"),     // 2 - 支付进行中
    ZFSB(Integer.valueOf(3), "支付失败");  // 3 - 支付失败
}
```

### 1.3 支付状态枚举 (PayStatusEnum)

**源码位置**: `kaci-pos-localserver/src/com/shouqianba/localserver/biz/common/enums/pay/PayStatusEnum.java`

```java
public enum PayStatusEnum implements IIntegerEnum {
    SUCCESS(Integer.valueOf(1), "支付成功"),    // 1 - 支付完成
    PAYMENT(Integer.valueOf(2), "支付中"),      // 2 - 支付处理中
    FAILED(Integer.valueOf(3), "支付失败");     // 3 - 支付失败

    public static boolean paySuccess(final Integer payStatus) {
        return PayStatusEnum.SUCCESS.code.equals(payStatus);  // E-SRC: L18-19
    }
}
```

### 1.4 桌台状态枚举 (TableStatusEnum)

**源码位置**: `kaci-pos-localserver/src/com/shouqianba/localserver/table/enums/TableStatusEnum.java`

```java
public enum TableStatusEnum {
    FREE(Integer.valueOf(0), "空闲"),           // 0 - 桌台可用
    PREORDER(Integer.valueOf(1), "待下单"),     // 1 - 预点餐状态
    RESERVE(Integer.valueOf(2), "已预订"),      // 2 - 预订锁定
    PRESETTLEMENT(Integer.valueOf(3), "待结账"),// 3 - 反结账后待重新结账
    TOSETTLEMENT(Integer.valueOf(4), "已预结"), // 4 - 预结账/结账中
    PRECLEAR(Integer.valueOf(5), "待清台");     // 5 - 等待清理

    public static final List<Integer> USEING;   // 使用中状态列表

    static {
        // E-SRC: L58 - 定义使用中状态：待下单、待结账、已预结
        USEING = Lists.newArrayList(
            TableStatusEnum.PREORDER.getCode(),
            TableStatusEnum.PRESETTLEMENT.getCode(),
            TableStatusEnum.TOSETTLEMENT.getCode()
        );
    }
}
```

**桌台状态转换图**:
```
[空闲] ←──────────────────────────────┐
   ↑                                  │
   │ [开台/占用]                       │
   │ [清台完成]                        │
   │                                  │
[待下单] ←──[开台]                    │ [取消预订]
   │       (顾客扫码)                   │
   │                                  │
   │ [提交订单]                        │ [清台]
   ↓                                  ↓
[已预订]                           [待清台]
   │                                  │
   │ [到达/开始用餐]                    │
   ↓                                  │
[已预结] ←──[预结账/结账]───────────────┘
   │
   │ [反结账]
   ↓
[待结账] ──→ [已结账]
```

### 1.5 发票状态枚举 (InvoiceStatusEnum)

**源码位置**: `kaci-pos-localserver/src/com/shouqianba/localserver/order/enums/InvoiceStatusEnum.java`

```java
public enum InvoiceStatusEnum implements IIntegerEnum {
    WSQ(Integer.valueOf(0), "未申请"),     // 0 - 未发起开票
    YTJ(Integer.valueOf(1), "已提交"),     // 1 - 发票申请已提交
    YK(Integer.valueOf(2), "已开票"),      // 2 - 发票已开具
    YHC(Integer.valueOf(3), "已红冲"),     // 3 - 发票已红冲(作废)
    ZF(Integer.valueOf(4), "已作废");      // 4 - 发票作废
}
```

**发票状态转换图**:
```
[未申请] ──→ [已提交] ──→ [已开票]
                         │
                         │ [反结账/取消]
                         ↓
                      [已红冲]
```

---

## 2. 核心业务规则 (BR-*)

### 2.1 订单创建规则 (BR-001)

**规则名称**: 加菜规则
**E-SRC**: `PlaceOrderService.java:62-93`

| 规则ID | 规则描述 | 触发条件 | 约束 |
|--------|----------|----------|------|
| BR-001 | 下单前必须验证订单存在 | `PlaceOrderService.java:64-65` | 订单不存在抛出 `0101010103` |
| BR-001a | 已通过审核(orderPass=IN)的订单需进行加料/做法/沽清校验 | `PlaceOrderService.java:67-71` | 调用 `orderDetailPracticeCheck`, `orderDetailTagCheck`, `checkSoldOut` |
| BR-001b | 禁止重复加菜 | `PlaceOrderService.java:73` | 调用 `checkRepeatGoods` 校验 |
| BR-001c | 快餐订单(bizType=FAST_GOODS)不更新桌台状态 | `PlaceOrderService.java:77,89-91` | 仅堂食订单更新桌台 |

**核心代码片段** (E-SRC: L62-93):
```java
public ExecutePromotionResponse placeOrder(final PlaceOrderRequest request) throws Exception {
    final OrderMaster orderMaster = super.orderMasterService.getOrderMaster(request.getBillNo());
    if (orderMaster == null) {
        throw new BusinessException("0101010103");  // 订单不存在
    }
    if (OrderPassEnum.IN.getCode().equals(orderMaster.getOrderPass())) {
        super.orderDetailPracticeCheck(...);    // BR-001a
        super.orderDetailTagCheck(...);         // BR-001a
        super.checkSoldOut(...);                // BR-001a
    }
    // ...
    final boolean isFastGoods = BizTypeEnum.FAST_GOODS.getCode().equals(orderMaster.getBizType());
    // ...
    if (!isFastGoods) {
        super.updateTableStatus(orderSale, orderMaster);  // BR-001c
    }
}
```

### 2.2 支付规则 (BR-002)

**规则名称**: 支付状态校验
**E-SRC**: `BasePayService.java:99-140`

| 规则ID | 规则描述 | E-SRC | 异常代码 |
|--------|----------|-------|----------|
| BR-002 | 支付前校验未支付金额 | `BasePayService.java:104` | - |
| BR-002a | 合台订单需正确设置原订单号 | `BasePayService.java:105-109` | - |
| BR-002b | 支付完成后检查是否自动结账 | `BasePayService.java:115` | - |
| BR-002c | 支付成功(PAID)后刷新未支付金额 | `BasePayService.java:120-122` | - |

### 2.3 反结账规则 (BR-003)

**规则名称**: 反结账前置校验
**E-SRC**: `RevCheckoutService.java:100-126`

| 规则ID | 规则描述 | E-SRC | 异常代码 |
|--------|----------|-------|----------|
| BR-003 | 订单必须处于已结账状态 | `RevCheckoutService.java:103-105` | `0101010913` |
| BR-003a | 存在进行中的退款不允许反结账 | `RevCheckoutService.java:106-112` | `0101012004` |
| BR-003b | 非跨日反结账校验(默认) | `RevCheckoutService.java:117-122` | `0101010953` |
| BR-003c | 结账后修改时限校验(默认12小时) | `RevCheckoutService.java:123-126` | `0101010915` |

**核心校验代码** (E-SRC: L103-126):
```java
public RevCheckoutResponse revCheckout(final RevCheckoutRequest request) throws Exception {
    // BR-003: 必须已结账
    if (!OrderStatusEnum.ORDER_YJZ.getCode().equals(orderStatus.getOrderStatus())) {
        throw new BusinessException("0101010913");
    }
    // BR-003a: 无进行中退款
    if (this.orderStatusService.isExistRefunding(refundOrderNos)) {
        throw new BusinessException("0101012004");
    }
    // BR-003b: 跨日校验
    if (revFlag == 0) {
        if (!BizBaseUtil.getBusinessDate().equals(orderMaster.getWorkDate())) {
            throw new BusinessException("0101010953");
        }
    }
    // BR-003c: 时限校验
    final long hours = Duration.between(TimeUtil.toLocalDateTime(orderStatus.getCheckoutTime()), LocalDateTime.now()).toHours();
    if (hours > closedBillModifyTimeLimit) {
        throw new BusinessException("0101010915", ...);
    }
}
```

### 2.4 发票规则 (BR-004)

**规则名称**: 发票状态管理
**E-SRC**: `OrderInvoiceService.java:56-100`

| 规则ID | 规则描述 | E-SRC | 约束 |
|--------|----------|-------|------|
| BR-004 | 仅已开票状态可红冲 | `OrderInvoiceService.java:73-76` | 非已开票状态退出 |
| BR-004a | 小费订单(XFK)和外卖订单使用外部订单号 | `OrderInvoiceService.java:80-85` | - |
| BR-004b | 反结账后自动红冲发票 | `RevCheckoutService.java:190-200` | 异步执行 |

### 2.5 桌台状态规则 (BR-005)

**规则名称**: 桌台状态与订单联动
**E-SRC**: `RevCheckoutService.java:139-147`, `PlaceOrderService.java:89-91`

| 规则ID | 规则描述 | E-SRC | 触发条件 |
|--------|----------|-------|----------|
| BR-005 | 反结账后更新桌台为待结账 | `RevCheckoutService.java:139-147` | 桌台状态为空闲或待清台 |
| BR-005a | 加菜后更新桌台为已预结 | `PlaceOrderService.java:89-91` | 非快餐订单 |
| BR-005b | 结账后设置桌台为待清台 | `OrderDomainService.java:214-230` | isPayed=true |
| BR-005c | 清台后恢复桌台为空闲 | `TableService.java` | - |

---

## 3. 核心不变量 (INV-*)

### 3.1 订单金额不变量

| 约束ID | 不变量描述 | E-SRC | 验证逻辑 |
|--------|------------|-------|----------|
| INV-001 | 未支付金额 = 订单总额 - 订单优惠 - 支付优惠 - 实收金额 | `OrderMasterDO.java:210-212` | `getUnpaidAmount()` |
| INV-002 | 实收金额 = 所有支付记录实收之和 | `OrderMasterDO.java:75` | `actualReceiptAmount.add(orderPay.getActualReceiptAmount())` |
| INV-003 | 已结账状态判定 | `OrderMasterDO.java:214-216` | `OrderStatusEnum.ORDER_YJZ.getCode().equals(statusInfo.getOrderStatus())` |
| INV-004 | 结账时无未点菜商品则取消订单 | `OrderDomainService.java:217-220` | 检查所有明细 `isDel=NO` |

**核心代码** (E-SRC: L210-212):
```java
public BigDecimal getUnpaidAmount() {
    return this.orderTotalAmount
        .subtract(this.orderDiscountAmount)
        .subtract(this.payDiscountAmount)
        .subtract(this.actualReceiptAmount);
}
```

### 3.2 订单状态不变量

| 约束ID | 不变量描述 | E-SRC | 验证逻辑 |
|--------|------------|-------|----------|
| INV-005 | 已结账订单isPay必须为已支付 | `OrderStatusDO.java:24-33` | `payComplete()` 时设置 |
| INV-006 | 反结账次数递增 | `RevCheckoutService.java:134` | `revCheckoutCount + 1` |
| INV-007 | 首次结账记录firstCheckoutTime | `OrderStatusDO.java:30-32` | `revCheckoutCount == 0` 时设置 |
| INV-008 | 整单退款后状态为已退单 | `OrderDomainService.java:219` | 条件满足时设置 |

### 3.3 桌台状态不变量

| 约束ID | 不变量描述 | E-SRC | 验证逻辑 |
|--------|------------|-------|----------|
| INV-009 | 桌台使用中状态列表 | `TableStatusEnum.java:58` | `USEING = [PREORDER, PRESETTLEMENT, TOSETTLEMENT]` |
| INV-010 | 桌台与订单号绑定 | `RevCheckoutService.java:140` | `tableInfo.setOrderKey(orderMaster.getOrderNo())` |
| INV-011 | 快餐订单不占用桌台 | `PlaceOrderService.java:77,89-91` | `isFastGoods` 判断 |

---

## 4. 状态转换矩阵

### 4.1 订单状态转换矩阵

| 当前状态 | 目标状态 | 触发操作 | E-SRC | 业务规则 |
|----------|----------|----------|-------|----------|
| (新建) | 待结账 | 加菜/落单 | `PlaceOrderService.java:83` | BR-001 |
| 待结账 | 已结账 | 结账完成 | `OrderStatusDO.java:26` | BR-002 |
| 已结账 | 待结账 | 反结账 | `RevCheckoutService.java:132` | BR-003 |
| 待结账 | 已取消 | 取消订单 | `OrderDomainService.java:219` | INV-004 |
| 已结账 | 已退单 | 整单退款 | `WholeOrderRefundService` | BR-refund |
| 已结账 | 已冲销 | 部分退款 | `WholeOrderRefundService` | BR-partial-refund |
| * | 待退单 | 发起退款 | `OrderStatusEnum.ORDER_DTD` | - |

### 4.2 桌台状态转换矩阵

| 当前状态 | 目标状态 | 触发操作 | E-SRC | 业务规则 |
|----------|----------|----------|-------|----------|
| 空闲 | 待下单 | 扫码开台 | `OpenTableService` | BR-005 |
| 待下单 | 已预订 | 提交订单 | `PlaceOrderService.java:90` | BR-005a |
| 空闲/待清台 | 待结账 | 反结账 | `RevCheckoutService.java:144` | BR-005 |
| 已预结 | 待清台 | 结账完成 | `OrderDomainService.java` | BR-005b |
| 待清台 | 空闲 | 清台 | `ClearTableService` | BR-005c |
| 已预订 | 已预结 | 预结账 | - | - |
| * | 已预订 | 预订 | `BookOrderTableStatusService` | - |

### 4.3 发票状态转换矩阵

| 当前状态 | 目标状态 | 触发操作 | E-SRC | 业务规则 |
|----------|----------|----------|-------|----------|
| 未申请 | 已提交 | 申请开票 | `OrderInvoiceService` | - |
| 已提交 | 已开票 | 开票成功回调 | `OrderInvoiceService.java:117` | BR-004a |
| 已开票 | 已红冲 | 反结账 | `RevCheckoutService.java:193` | BR-004b |
| 已开票 | 已红冲 | 发票红冲 | `OrderInvoiceService.java:99` | BR-004 |
| 已提交 | 已作废 | 作废 | - | - |

---

## 5. 异常代码映射

### 5.1 订单相关异常

| 错误码 | 错误消息 | E-SRC | 触发场景 |
|--------|----------|-------|----------|
| `0101010103` | 订单不存在 | `PlaceOrderService.java:65`, `RevCheckoutService.java:210`, `OrderDomainService.java:82` | 订单表查询为空 |
| `0101010125` | 当前订单状态为非待结账状态 | `OrderService.java:506` | 非待结账状态落菜 |
| `0101010913` | 订单状态不正确，无法反结账 | `RevCheckoutService.java:104` | 非已结账状态反结账 |
| `0101010953` | 不允许跨日反结账 | `RevCheckoutService.java:120` | 营业日与结账日不同 |
| `0101010915` | 结账单已超过可修改时限({0}小时) | `RevCheckoutService.java:125` | 结账后超过12小时 |
| `0101010919` | 外卖订单不允许反结账 | `RevCheckoutService.java:220` | 平台订单类型 |
| `0101011007` | 退款商品状态不正确 | `DcqRefundHandler.java:77` | 商品已被退款 |
| `0101011009` | 存在关联退款明细 | `OrderDetailRefundService.java:110` | 重复退款 |
| `0101012004` | 存在进行中的退款，无法反结账 | `RevCheckoutService.java:110` | 有退款记录 |

### 5.2 桌台相关异常

| 错误码 | 错误消息 | E-SRC | 触发场景 |
|--------|----------|-------|----------|
| `0101010518` | 桌台{0}状态不正确 | `TableOperateHandler.java:44`, `OpenBuffetTableHandler.java:35` | 桌台状态校验失败 |
| `0101010125` | 外卖账单非落单状态，无法打印结账单 | `PrintBillTicketHandler.java:172` | 外卖订单状态 |

### 5.3 支付相关异常

| 错误码 | 错误消息 | E-SRC | 触发场景 |
|--------|----------|-------|----------|
| `0101010107` | 账单非落单状态 | `PrintBillTicketHandler.java:113` | 非待结账状态打印 |
| `0101011900` | 结账单打印失败 | `PrintBillTicketHandler.java:199` | 打印服务异常 |

### 5.4 打印相关异常

| 错误码 | 错误消息 | E-SRC | 触发场景 |
|--------|----------|-------|----------|
| `0101010124` | 相同的票据正在打印,请稍候再试 | `PrintBillTicketHandler.java:103`, `PrintBusinessTicketHandler.java:49` | 并发打印 |
| `0101010125` | 当前账单状态为非待结账状态 | `PrintBillTicketHandler.java:196` | 状态校验 |

---

## 6. 核心状态机实现

### 6.1 OrderStatusDO.payComplete() 状态转换

**E-SRC**: `kaci-pos-localserver/src/com/shouqianba/localserver/order/domain/entity/OrderStatusDO.java:24-33`

```java
public void payComplete() {
    this.isPay = IsPayEnum.YZF.getCode();              // 设置为已支付
    this.orderStatus = OrderStatusEnum.ORDER_YJZ.getCode(); // 状态转为已结账
    this.payTime = TimeUtil.currentDateTime();         // 记录支付时间
    this.checkoutBy = RequestContext.getUser().getUserName(); // 记录结账人
    this.checkoutTime = this.payTime;                  // 记录结账时间
    if (this.revCheckoutCount == null || this.revCheckoutCount == 0) {
        this.firstCheckoutTime = this.payTime;         // 首次结账记录
    }
}
```

### 6.2 OrderMasterDO.isPayed() 状态判断

**E-SRC**: `kaci-pos-localserver/src/com/shouqianba/localserver/order/domain/entity/OrderMasterDO.java:214-216`

```java
public boolean isPayed() {
    return OrderStatusEnum.ORDER_YJZ.getCode().equals(this.statusInfo.getOrderStatus());
}
```

### 6.3 沽清处理状态机

**E-SRC**: `SoldOutStockBizService.java:48-113`

| 沽清类型 | 处理逻辑 | E-SRC |
|----------|----------|-------|
| DAILY (每日) | 按日期更新，删除过期记录 | `dailySoldOutHandle()`, L174-209 |
| MEAL_SECTION (餐段) | 按餐段ID/时段更新 | `mealSectionSoldOutHandle()`, L115-143 |
| FOREVER (永久) | 保留永久记录，删除其他 | `foreverSoldOutHandle()`, L152-172 |

---

## 7. 关键数据流

### 7.1 加菜流程状态变化

```
输入: PlaceOrderRequest
  ↓
[订单主表] billNo 查询 → 不存在? → 抛异常 0101010103
  ↓
OrderPass=IN 时:
  - orderDetailPracticeCheck() 做法校验
  - orderDetailTagCheck() 标签校验
  - checkSoldOut() 沽清校验
  ↓
checkRepeatGoods() 重复菜品校验
  ↓
executePromotion() 执行优惠
  ↓
事务内:
  - 更新 OrderStatus.orderStatus = ORDER_DJZ (待结账)
  - 更新 OrderDetail.ldStatus 已落单
  - 更新 TableStatus (非快餐)
  ↓
输出: ExecutePromotionResponse
```

### 7.2 反结账流程状态变化

```
输入: RevCheckoutRequest
  ↓
校验 OrderStatus = ORDER_YJZ? → 否 → 0101010913
  ↓
校验无进行中退款? → 有 → 0101012004
  ↓
校验营业日一致? → 否且revFlag=0 → 0101010953
  ↓
校验结账时限? → 超时 → 0101010915
  ↓
事务内:
  - OrderStatus.orderStatus = ORDER_DJZ (待结账)
  - OrderStatus.isPay = WZF (未支付)
  - OrderStatus.revCheckoutCount++
  - TableStatus = PRESETTLEMENT (待结账)
  ↓
异步:
  - 同步桌台到云端
  - 删除上传记录
  - 退还积分礼品
  - 发票红冲 (如果已开票)
  ↓
输出: RevCheckoutResponse
```

---

## 8. 参考文件索引

| 编号 | 文件路径 | 说明 |
|------|----------|------|
| E-SRC-001 | `kaci-pos-localserver/src/com/shouqianba/localserver/biz/common/enums/order/OrderStatusEnum.java` | 订单状态枚举 |
| E-SRC-002 | `kaci-pos-localserver/src/com/shouqianba/localserver/order/enums/IsPayEnum.java` | 支付状态枚举 |
| E-SRC-003 | `kaci-pos-localserver/src/com/shouqianba/localserver/biz/common/enums/pay/PayStatusEnum.java` | 支付状态枚举(PayStatus) |
| E-SRC-004 | `kaci-pos-localserver/src/com/shouqianba/localserver/table/enums/TableStatusEnum.java` | 桌台状态枚举 |
| E-SRC-005 | `kaci-pos-localserver/src/com/shouqianba/localserver/order/enums/InvoiceStatusEnum.java` | 发票状态枚举 |
| E-SRC-006 | `kaci-pos-localserver/src/com/shouqianba/localserver/service/order/PlaceOrderService.java` | 加菜服务 |
| E-SRC-007 | `kaci-pos-localserver/src/com/shouqianba/localserver/service/pay/extension/BasePayService.java` | 支付基础服务 |
| E-SRC-008 | `kaci-pos-localserver/src/com/shouqianba/localserver/service/order/RevCheckoutService.java` | 反结账服务 |
| E-SRC-009 | `kaci-pos-localserver/src/com/shouqianba/localserver/service/order/OrderInvoiceService.java` | 发票服务 |
| E-SRC-010 | `kaci-pos-localserver/src/com/shouqianba/localserver/soldout/service/biz/SoldOutStockBizService.java` | 沽清业务服务 |
| E-SRC-011 | `kaci-pos-localserver/src/com/shouqianba/localserver/order/domain/entity/OrderMasterDO.java` | 订单主实体 |
| E-SRC-012 | `kaci-pos-localserver/src/com/shouqianba/localserver/order/domain/entity/OrderStatusDO.java` | 订单状态实体 |
| E-SRC-013 | `kaci-pos-localserver/src/com/shouqianba/localserver/order/domain/service/OrderDomainService.java` | 订单域服务 |
| E-SRC-014 | `kaci-pos-localserver/src/com/shouqianba/localserver/service/table/TableService.java` | 桌台服务 |

---

## 9. 附录：枚举值速查表

### 9.1 订单状态值

| 枚举 | 值 | 含义 |
|------|-----|------|
| ORDER_DJZ | 10 | 待结账 |
| ORDER_YJZ | 20 | 已结账 |
| ORDER_DTD | 29 | 待退单 |
| ORDER_YTD | 30 | 已退单 |
| ORDER_YCX | 40 | 已冲销 |
| ORDER_YQX | 50 | 已取消 |

### 9.2 支付状态值

| 枚举 | 值 | 含义 |
|------|-----|------|
| WZF | 0 | 未支付 |
| YZF | 1 | 已支付 |
| ZFZ | 2 | 支付中 |
| ZFSB | 3 | 支付失败 |

### 9.3 桌台状态值

| 枚举 | 值 | 含义 |
|------|-----|------|
| FREE | 0 | 空闲 |
| PREORDER | 1 | 待下单 |
| RESERVE | 2 | 已预订 |
| PRESETTLEMENT | 3 | 待结账 |
| TOSETTLEMENT | 4 | 已预结 |
| PRECLEAR | 5 | 待清台 |

### 9.4 发票状态值

| 枚举 | 值 | 含义 |
|------|-----|------|
| WSQ | 0 | 未申请 |
| YTJ | 1 | 已提交 |
| YK | 2 | 已开票 |
| YHC | 3 | 已红冲 |
| ZF | 4 | 已作废 |
