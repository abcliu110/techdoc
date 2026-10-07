# DA2-概念字典：KACI POS 核心实体全景分析

## 文档信息

| 属性 | 值 |
|------|-----|
| 文档编号 | DA2 |
| 文档名称 | KACI POS 核心实体概念字典 |
| 生成日期 | 2026-08-31 |
| 分析范围 | OrderMasterDO / OrderDetailDO / OrderStatusDO / OrderPay / OrderSaleDO |
| 数据来源 | kaci-pos-localserver 源码级反编译文件 |
| 分析方法 | 10维度全景卡（E-SRC 精确行号追踪） |

---

## 实体一：OrderMasterDO（订单主实体）

### ① 身份（Identity）

| 维度 | 描述 |
|------|------|
| **类型名称** | `OrderMasterDO` |
| **包路径** | `com.shouqianba.localserver.order.domain.entity` |
| **职责定位** | 订单领域驱动设计的聚合根（Aggregate Root），是整个订单领域模型的核心实体 |
| **职责描述** | 封装订单的完整业务状态，负责订单支付、退款、折扣分摊等核心业务逻辑编排 |
| **E-SRC** | 第28-489行 |
| **构造函数** | 第63-68行：无参构造，初始化默认值 |
| **线程安全** | 非线程安全，需外部同步控制 |

### ② 结构（Structure）

| 维度 | 描述 |
|------|------|
| **核心标识字段** | `id` (Long), `billNo` (String), `orderNo` (String), `orderPass` (Integer) |
| **业务分类字段** | `bizType` (业务类型), `platformType` (平台类型), `businessType` (经营类型), `orderType` (订单类型) |
| **金额字段** | `orderTotalAmount`(订单总额), `orderDiscountAmount`(订单优惠), `payDiscountAmount`(支付优惠), `actualReceiptAmount`(实收金额), `pointAmount`(积分), `depositUnpaidAmount`(未付押金), `depositAmount`(押金), `serviceAmount`(服务费), `packingAmount`(包装费) |
| **关联实体** | `detailList`(List<OrderDetailDO>), `statusInfo`(OrderStatusDO), `saleInfo`(OrderSaleDO), `payList`(List<OrderPay>), `holdConsumeList`(List<OrderHoldConsume>), `pledgeAmountMap`(Map<CashPledge, BigDecimal>) |
| **辅助字段** | `workDate`(工作日期), `operatorId`(操作员ID), `operatorName`(操作员名), `userPhone`(用户手机), `originalOrderNo`(原订单号), `extOrderNo`(外部订单号), `revision`(乐观锁版本), `goodsBatchNo`(商品批次号), `isPosPrePaid`(POS预付标志) |
| **E-SRC** | 第30-61行（字段声明） |

### ③ 关系（Relations）

| 维度 | 描述 |
|------|------|
| **聚合关系** | 1:1 关联 `OrderStatusDO`（订单状态子实体） |
| **聚合关系** | 1:1 关联 `OrderSaleDO`（订单销售信息子实体） |
| **聚合关系** | 1:N 关联 `OrderDetailDO`（订单明细列表） |
| **聚合关系** | 1:N 关联 `OrderPay`（支付记录列表） |
| **聚合关系** | 1:N 关联 `OrderHoldConsume`（挂账消费列表） |
| **聚合关系** | 1:N 关联 `CashPledge`（押金映射） |
| **外部依赖** | 依赖 `CacheUtil.remove(PayMutexShare.class, billNo)` 清除支付互斥缓存 |
| **E-SRC** | 第51-54行（聚合关联） |

### ④ 行为（Behaviors）

| 行为 | 描述 | E-SRC |
|------|------|-------|
| `pay(OrderPay)` | 通用支付入口，委托现金支付 | 第70-72行 |
| `cashPay(OrderPay, BigDecimal)` | 现金支付处理：累加实收、记录支付、触发优惠分摊 | 第74-81行 |
| `onlinePay(OrderPay)` | 在线支付处理：无找零逻辑 | 第83-89行 |
| `cancelPay(OrderPay)` | 取消支付（反结账）：生成退款记录，重算优惠分摊 | 第91-113行 |
| `refund(OrderPay)` | 退款处理：回滚实收金额，关联原支付记录 | 第115-132行 |
| `payDiscount(OrderPay)` | 支付优惠计算与分摊 | 第134-149行 |
| `cancelPayDiscount(OrderPay)` | 取消支付优惠 | 第151-167行 |
| `apportionAmount(...)` | 优惠金额按比例分摊到明细项（支持套餐嵌套） | 第169-208行 |
| `getUnpaidAmount()` | 计算未付金额 | 第210-212行 |
| `isPayed()` | 判断订单是否已结清 | 第214-216行 |
| `payComplete()` | 结账完成：更新状态、清除缓存 | 第218-224行 |
| `isAppletPrepay()` | 判断是否为小程序预支付 | 第226-228行 |
| `isBuffet()` | 判断是否为自助餐订单 | 第230-232行 |

### ⑤ 交互（Interactions）

| 交互对象 | 交互方式 | E-SRC |
|----------|----------|-------|
| `OrderDetailDO` | 调用 `detailDO.cancelPayDiscount(orderPay)` 传递优惠取消 | 第103行 |
| `OrderSaleDO` | 调用 `saleInfo.pay/cancelPay()` 同步销售信息 | 第77,94,119行 |
| `OrderStatusDO` | 读取 `statusInfo.getRevCheckoutCount()` 确定支付序号 | 第110行 |
| `CacheUtil` | 清除支付互斥锁 `PayMutexShare` | 第223行 |
| `OrderDomainConvert` | 转换为退款支付记录 | 第105行 |

### ⑥ 生命时间线（Lifecycle）

| 阶段 | 触发条件 | 状态变更 | E-SRC |
|------|----------|----------|-------|
| **创建** | 无参构造 | `orderPass=1`, `originalOrderNo=""`, 初始化空集合 | 第63-68行 |
| **开台** | 设置桌台信息 | `businessType=IN_DINE` | - |
| **加菜** | 添加 `OrderDetailDO` | `goodsBatchNo` 递增 | - |
| **支付** | 调用 `pay/cashPay/onlinePay` | `actualReceiptAmount` 累加，`payList` 添加记录 | 第74-89行 |
| **反结账** | 调用 `cancelPay` | 生成退款记录，扣减实收 | 第91-113行 |
| **退款** | 调用 `refund` | `actualReceiptAmount` 回滚 | 第115-132行 |
| **结账完成** | 调用 `payComplete` | `OrderStatusDO.payComplete()` | 第218-224行 |
| **缓存清理** | 结账完成 | 移除 `PayMutexShare` 缓存 | 第223行 |

### ⑦ 实现（Implementation）

| 维度 | 描述 |
|------|------|
| **持久化框架** | 非 ORM 托管，内存对象，通过 DAO 层持久化 |
| **序列化** | 未实现 `Serializable` |
| **Equals/HashCode** | 未重写 |
| **Builder模式** | 无 |
| **依赖注入** | 无 |
| **设计模式** | 门面模式（聚合根统一管理子实体）、策略模式（cashPay/onlinePay） |

### ⑧ 失败（Failure Handling）

| 场景 | 失败表现 | E-SRC |
|------|----------|-------|
| `cancelPay` 无退款金额 | 直接返回，不做处理 | 第92-93行 |
| `cancelPay` relationPay 为空 | early return（第123-125行） | 第122-125行 |
| 优惠分摊超出商品金额 | 截断为商品最大金额 | 第187-189行 |
| 负数优惠金额 | 绝对值比较取最大 | 第195-197行 |

### ⑨ 证据（Evidence）

| 证据ID | 源码位置 | 关键发现 |
|--------|----------|----------|
| E-OM-001 | 第74-81行 | 现金支付三步曲：累加实收 → 添加支付记录 → 同步销售信息 |
| E-OM-002 | 第134-149行 | 优惠分摊核心算法：按商品实付金额比例分配 |
| E-OM-003 | 第169-208行 | 套餐嵌套分摊递归：支持 comboList 递归处理 |
| E-OM-004 | 第210-212行 | 未付金额公式：订单总额 - 订单优惠 - 支付优惠 - 实收金额 |
| E-OM-005 | 第218-224行 | 结账完成触发全链路状态同步 |

### ⑩ 未知（Unknowns）

| 标记 | 描述 |
|------|------|
| U-OM-001 | `isPosPrePaid` 字段用途不明，源码中未找到赋值处 |
| U-OM-002 | `goodsBatchNo` 批次号与加菜批次管理机制待确认 |
| U-OM-003 | `pledgeAmountMap` 与押金实物的关联逻辑未明 |
| U-OM-004 | `holdConsumeList` 挂账消费的生命周期管理 |

---

## 实体二：OrderDetailDO（订单明细实体）

### ① 身份（Identity）

| 维度 | 描述 |
|------|------|
| **类型名称** | `OrderDetailDO` |
| **包路径** | `com.shouqianba.localserver.order.domain.entity` |
| **职责定位** | 订单聚合中的实体（Entity），代表单个商品明细行 |
| **职责描述** | 封装商品的销售价格、实付金额、优惠分摊、套餐组合等完整信息 |
| **E-SRC** | 第27-524行 |
| **构造函数** | 第69-74行：初始化默认值 `isGroupBuying=0`, `ldStatus=0`, `operate=NONE` |
| **线程安全** | 非线程安全 |

### ② 结构（Structure）

| 维度 | 描述 |
|------|------|
| **核心标识** | `id` (Long), `detailId` (Long), `orderNo` (String) |
| **商品标识** | `goodsId`, `skuId`, `skuCode`, `goodsCode`, `goodsName` |
| **分类层级** | `firstCategoryId` (一级分类), `secondCategoryId` (二级分类), `categoryId` (末级分类) |
| **价格体系** | `salesPrice`(挂牌价), `originalPrice`(原价), `vipPrice`(会员价), `modifyPrice`(修改价), `goodsSendPrice`(配送价) |
| **金额字段** | `goodsPayPrice`(实付单价), `goodsQty`(数量), `goodsSaleAmount`(销售总额), `goodsPayAmount`(实付总额), `goodsDiscountAmount`(商品优惠), `payDiscountAmount`(支付优惠), `actualReceiptAmount`(实收), `pointAmount`(积分) |
| **业务标志** | `isRefundGoods`(退货标志), `isGroupBuying`(团购标志), `isGift`(赠品标志), `goodsType`(商品类型), `ldStatus`(联单状态), `isDel`(逻辑删除) |
| **关联实体** | `comboList`(List<OrderDetailDO>) - 套餐子项列表 |
| **优惠记录** | `promotionList`(List<OrderDetailPromotion>), `promotionMap`(Map<Long, OrderDetailPromotion>) |
| **操作追踪** | `operate`(OperateEnum), `goodsBatchNo`(批次号) |
| **E-SRC** | 第29-67行（字段声明） |

### ③ 关系（Relations）

| 维度 | 描述 |
|------|------|
| **父子关系** | 父项包含 `comboList` 套餐子项列表 |
| **聚合归属** | 属于 `OrderMasterDO.detailList` 的子项 |
| **优惠关联** | 通过 `promotionList` 记录每笔支付优惠明细 |
| **级联操作** | `payComplete()` 递归调用 `comboList.forEach()` | 第141-143行 |
| **E-SRC** | 第62行（comboList）, 第64-65行（promotionList/promotionMap） |

### ④ 行为（Behaviors）

| 行为 | 描述 | E-SRC |
|------|------|-------|
| `addPayDiscount(BigDecimal, BigDecimal, OrderPay)` | 新增支付优惠分摊 | 第76-80行 |
| `updatePayDiscount(BigDecimal, BigDecimal, OrderPay)` | 更新支付优惠分摊（用于残差处理） | 第82-101行 |
| `cancelPayDiscount(OrderPay)` | 取消指定支付的优惠分摊 | 第103-127行 |
| `payComplete()` | 结账完成：计算实收、标记状态 | 第129-144行 |
| `createPromotion(...)` | 创建优惠明细记录 | 第146-180行 |
| `getApportionAmount(BigDecimal, BigDecimal)` | 按比例计算分摊金额 | 第182-199行 |
| `addDiscountAmount(...)` | 内部方法：累加优惠金额 | 第201-211行 |

### ⑤ 交互（Interactions）

| 交互对象 | 交互方式 | E-SRC |
|----------|----------|-------|
| `OrderPay` | 接收支付对象获取支付ID、优惠信息 | 多处 |
| `BizBaseUtil.getOrgInfo()` | 获取组织信息用于优惠记录 | 第147行 |
| `RequestContext.getUser()` | 获取当前用户信息 | 第169行 |
| `TimeUtil.currentDateTime()` | 获取当前时间 | 第168行 |
| `comboList` 子项 | 递归调用优惠/结账方法 | 第88-91, 95-98, 122-126行 |

### ⑥ 生命时间线（Lifecycle）

| 阶段 | 触发条件 | 状态变更 | E-SRC |
|------|----------|----------|-------|
| **创建** | 无参构造 | `isGroupBuying=0`, `ldStatus=0`, `operate=NONE` | 第69-74行 |
| **加菜** | 设置商品信息 | 计算 `goodsPayAmount = goodsPayPrice * goodsQty` | - |
| **支付优惠** | `addPayDiscount` | 累减 `goodsPayAmount`，累加优惠记录 | 第76-80行 |
| **残差处理** | `updatePayDiscount` | 将剩余优惠分配给价格最高的套餐子项 | 第82-101行 |
| **取消优惠** | `cancelPayDiscount` | 恢复 `goodsPayAmount`，删除优惠记录 | 第103-127行 |
| **结账完成** | `payComplete` | 设置 `actualReceiptAmount = goodsPayAmount`，递归处理套餐 | 第129-144行 |

### ⑦ 实现（Implementation）

| 维度 | 描述 |
|------|------|
| **优惠分摊策略** | 按商品实付金额占总金额比例分配，支持套餐嵌套递归 |
| **精度处理** | `RoundingMode.HALF_UP`，保留2位小数 |
| **优惠记录** | 每笔支付生成一条 `OrderDetailPromotion` 记录 |
| **逻辑删除** | 通过 `isDel` 标志软删除优惠记录 | 第120行 |
| **操作标记** | 使用 `OperateEnum` 枚举追踪变更状态 |

### ⑧ 失败（Failure Handling）

| 场景 | 失败表现 | E-SRC |
|------|----------|-------|
| 取消优惠无对应记录 | early return | 第104-107行 |
| 退货/赠品结账 | `actualReceiptAmount = ZERO` | 第130-132行 |
| 负数挂牌价 | 取绝对值 | 第136-138行 |
| 实收为负 | 归零处理 | 第117-119行 |

### ⑨ 证据（Evidence）

| 证据ID | 源码位置 | 关键发现 |
|--------|----------|----------|
| E-OD-001 | 第182-199行 | 分摊算法核心：按比例 × 商品实付金额，截断保护 |
| E-OD-002 | 第76-80行 | 优惠记录追加模式：创建新 Promotion 对象 |
| E-OD-003 | 第82-101行 | 残差处理策略：找到最贵套餐子项吸收剩余优惠 |
| E-OD-004 | 第103-127行 | 优惠取消：逆向操作 + 逻辑删除 Promotion |
| E-OD-005 | 第129-144行 | 结账完成三判断：赠品/退货/数量为零 → 实收归零 |

### ⑩ 未知（Unknowns）

| 标记 | 描述 |
|------|------|
| U-OD-001 | `ldStatus`（联单状态）的具体枚举值含义 |
| U-OD-002 | `certificateNo`（凭证号）的使用场景 |
| U-OD-003 | `giveGoodsReason`（赠品原因）的必填规则 |
| U-OD-004 | `promotionMap` 与 `promotionList` 的同步机制 |

---

## 实体三：OrderStatusDO（订单状态实体）

### ① 身份（Identity）

| 维度 | 描述 |
|------|------|
| **类型名称** | `OrderStatusDO` |
| **包路径** | `com.shouqianba.localserver.order.domain.entity` |
| **职责定位** | 订单聚合中的值对象（Value Object），专门管理订单状态流转 |
| **职责描述** | 封装订单的支付状态、结账时间、收银员等状态信息 |
| **E-SRC** | 第12-106行 |
| **构造函数** | 无显式构造，使用字段默认值 |
| **线程安全** | 非线程安全 |

### ② 结构（Structure）

| 维度 | 描述 |
|------|------|
| **核心标识** | `id` (Long) |
| **状态字段** | `orderStatus`(订单状态), `isPay`(是否支付), `payMethod`(支付方式) |
| **时间字段** | `payTime`(支付时间), `checkoutTime`(结账时间), `firstCheckoutTime`(首次结账时间) |
| **人员字段** | `checkoutBy`(结账人) |
| **次数字段** | `revCheckoutCount`(反结账次数) |
| **E-SRC** | 第14-22行（字段声明） |

### ③ 关系（Relations）

| 维度 | 描述 |
|------|------|
| **聚合归属** | 作为 `OrderMasterDO.statusInfo` 子实体存在 |
| **状态枚举依赖** | `OrderStatusEnum.ORDER_YJZ`（已结账状态码） | 第26行 |
| **支付枚举依赖** | `IsPayEnum.YZF`（已支付状态码） | 第25行 |
| **上下文依赖** | `RequestContext.getUser()` 获取当前收银员 | 第28行 |
| **E-SRC** | 第24-33行（payComplete 方法） |

### ④ 行为（Behaviors）

| 行为 | 描述 | E-SRC |
|------|------|-------|
| `payComplete()` | 结账完成：设置支付状态、时间、结账人 | 第24-33行 |

### ⑤ 交互（Interactions）

| 交互对象 | 交互方式 | E-SRC |
|----------|----------|-------|
| `RequestContext` | 获取当前操作用户信息 | 第28行 |
| `TimeUtil` | 获取当前时间戳 | 第27行 |
| `IsPayEnum` | 支付状态枚举 | 第25行 |
| `OrderStatusEnum` | 订单状态枚举 | 第26行 |

### ⑥ 生命时间线（Lifecycle）

| 阶段 | 触发条件 | 状态变更 | E-SRC |
|------|----------|----------|-------|
| **创建** | 默认值 | `orderStatus=null`, `isPay=null` | - |
| **结账完成** | `payComplete()` | `isPay=YZF`, `orderStatus=ORDER_YJZ`, 记录时间和结账人 | 第24-33行 |
| **反结账** | 调用方重置状态 | 依赖外部重置（源码中未找到反结账重置逻辑） | - |

### ⑦ 实现（Implementation）

| 维度 | 描述 |
|------|------|
| **设计模式** | 值对象模式（无业务方法，仅状态承载） |
| **时间处理** | 使用 Long 时间戳（毫秒级） |
| **首次结账** | 通过 `revCheckoutCount` 判断是否首次结账 | 第30-32行 |
| **E-SRC** | 第30-32行（首次结账时间设置逻辑） |

### ⑧ 失败（Failure Handling）

| 场景 | 失败表现 | E-SRC |
|------|----------|-------|
| `revCheckoutCount` 为空 | 视为首次结账，设置 `firstCheckoutTime` | 第30-32行 |
| `RequestContext.getUser()` 为空 | 可能抛 NPE | 第28行 |

### ⑨ 证据（Evidence）

| 证据ID | 源码位置 | 关键发现 |
|--------|----------|----------|
| E-OS-001 | 第24-33行 | payComplete 五合一：isPay + orderStatus + payTime + checkoutBy + checkoutTime |
| E-OS-002 | 第30-32行 | 首次结账判断逻辑：revCheckoutCount == null 或 == 0 |

### ⑩ 未知（Unknowns）

| 标记 | 描述 |
|------|------|
| U-OS-001 | `payMethod` 字段的完整枚举值列表 |
| U-OS-002 | `revCheckoutCount` 的递增时机和触发条件 |
| U-OS-003 | 反结账时状态重置的完整逻辑 |

---

## 实体四：OrderPay（支付记录实体）

### ① 身份（Identity）

| 维度 | 描述 |
|------|------|
| **类型名称** | `OrderPay` |
| **包路径** | `com.shouqianba.localserver.dao.po` |
| **职责定位** | 数据持久化对象（PO），映射数据库表 `tbl_order_pay` |
| **职责描述** | 记录每笔支付/退款的完整信息，包括金额、渠道、优惠、活动等 |
| **E-SRC** | 第15-718行 |
| **ORM注解** | `@DatabaseTable(tableName = "tbl_order_pay")` | 第15行 |
| **序列化** | 实现 `Serializable`，serialVersionUID=661583425631302283L | 第16-18行 |

### ② 结构（Structure）

| 维度 | 描述 |
|------|------|
| **主键** | `id` (自增主键), `payId` (支付记录ID) |
| **组织字段** | `groupId`, `groupName`, `orgId`, `orgName` |
| **订单关联** | `orderNo`, `billNo`, `orderPass`(出入标识别 1=入/-1=出) |
| **序号字段** | `payIndex`(支付序号), `seqNo`(顺序号) |
| **交易类型** | `type`(1=支付 2=退款) |
| **支付渠道** | `payBusinessNo`(支付流水号), `payOrderNo`(支付订单号), `paySuccessChannelTransNo`(通道交易号) |
| **金额字段** | `payAmount`(支付金额), `actualReceiptAmount`(实收金额), `payDiscountAmount`(支付优惠), `overAmount`(超收金额), `rateAmount`(手续费), `invoiceAmount`(可开票金额), `platformSubsidy`(平台补贴), `commercialSubsidy`(商家补贴), `debitAmountGiftTotal`(代金券面值) |
| **支付科目** | `paySubjectCode`, `paySubjectName`, `paySubjectGroupCode`, `paySubjectGroupName`, `paySubjectRate`(支付费率) |
| **支付介质** | `payMedia`(1:扫码 2:刷卡 3:扫脸) |
| **活动优惠** | `promotionType`, `promotionId`, `promotionName`, `couponCodes`, `couponInfo`, `couponVerifyWay`, `isJoinReceived`, `isIncludeScore` |
| **会员信息** | `customerId`, `memberCardId`, `memberCardNo`, `crmChannelId`(会员渠道) |
| **收银信息** | `cashierId`, `cashierName`, `classes`(收银班次) |
| **扩展字段** | `payExtend`(支付扩展 JSON), `promotionDetail`(活动明细), `reqHeader`(请求头) |
| **退款关联** | `refundPayOrderNo`, `relationPayOrderId`, `refundSerialNo`, `isRefundPledge`, `cashPledgeId` |
| **业务字段** | `workDate`(营业日期), `payRemark`(备注), `onAccountCode`(挂账编号), `originalOrderNo`(原订单号), `payOriginalOrderNo`(支付时原订单号) |
| **审计字段** | `isDel`, `createBy`, `createTime`, `updateBy`, `updateTime`, `goodsBatchNo` |
| **特殊控制** | `isBilling`(开票支持), `balanceLimitRule`(余额限制规则), `trdPlatform`(第三方平台 0=未知 1=啦啦啦) |
| **E-SRC** | 第19-158行（字段 + DatabaseField 注解） |

### ③ 关系（Relations）

| 维度 | 描述 |
|------|------|
| **DB映射** | 表 `tbl_order_pay`，索引 `idx_order_no`, `idx_bill_no` | 第31-34行 |
| **DAO层** | `OrderPayDao.class` | 第15行 |
| **聚合归属** | 作为 `OrderMasterDO.payList` 元素存在 |
| **关联关系** | `relationPayOrderId` 关联原支付记录（退款场景） | 第51行 |
| **E-SRC** | 第15行（@DatabaseTable）, 第51行（relationPayOrderId） |

### ④ 行为（Behaviors）

| 行为 | 描述 | E-SRC |
|------|------|-------|
| `equals(Object)` | 深度相等判断（55个字段全量比较） | 第721-1640行 |
| `canEqual(Object)` | 类型检查 | 第1642-1644行 |
| `hashCode()` | 55个字段的哈希计算 | 第1647-1791行 |
| `toString()` | 全字段字符串表示 | 第1793-1796行 |

### ⑤ 交互（Interactions）

| 交互对象 | 交互方式 | E-SRC |
|----------|----------|-------|
| `OrderMasterDO` | 作为 payList 元素被操作 | - |
| `OrderDetailDO` | 通过 promotionList 关联明细优惠 | - |
| `OrderDomainConvert` | 转换为退款支付记录 | 第105行 |

### ⑥ 生命时间线（Lifecycle）

| 阶段 | 触发条件 | 状态变更 | E-SRC |
|------|----------|----------|-------|
| **创建** | 支付发起 | 设置 `payId`, `payAmount`, `payIndex` 等核心字段 | - |
| **支付成功** | 支付回调 | `payStatus=SUCCESS(1)` | - |
| **退款发起** | 反结账/退款 | `type=2`, 关联 `relationPayOrderId` | - |
| **逻辑删除** | 数据清理 | `isDel=1` | - |

### ⑦ 实现（Implementation）

| 维度 | 描述 |
|------|------|
| **ORM框架** | ORMLite `@DatabaseField` 注解 |
| **数据类型映射** | BigDecimal 使用 `DataType.BIG_DECIMAL_NUMERIC`，长文本使用 `DataType.LONG_STRING` |
| **精度定义** | 金额 DECIMAL(16,2)，费率 DECIMAL(12,4) |
| **equals实现** | 55个字段全量比较（包含所有业务字段） |
| **序列化** | 实现 Serializable，支持分布式传输 |

### ⑧ 失败（Failure Handling）

| 场景 | 失败表现 | E-SRC |
|------|----------|-------|
| equals 链式检查 | 任意字段不等返回 false | 第721-1640行 |
| canEqual 类型检查 | 非 OrderPay 类型返回 false | 第725-727行 |

### ⑨ 证据（Evidence）

| 证据ID | 源码位置 | 关键发现 |
|--------|----------|----------|
| E-OP-001 | 第15行 | 表名 `tbl_order_pay`，注释"订单支付表" |
| E-OP-002 | 第31-34行 | 双索引设计：orderNo + billNo 分别建索引 |
| E-OP-003 | 第39行 | type=1支付 type=2退款二元状态 |
| E-OP-004 | 第41行 | orderPass: 1=入/-1=出的出入标识别 |
| E-OP-005 | 第55-108行 | 金额字段体系：payAmount(应付) vs actualReceiptAmount(实收) vs payDiscountAmount(优惠) |
| E-OP-006 | 第721-1640行 | equals 方法覆盖55个字段，hashCode 同步覆盖 |

### ⑩ 未知（Unknowns）

| 标记 | 描述 |
|------|------|
| U-OP-001 | `trdPlatform=1` 对应的"啦啦啦"平台具体指代 |
| U-OP-002 | `balanceLimitRule` 三种规则的具体业务含义 |
| U-OP-003 | `payExtend` 扩展字段的 JSON 结构规范 |
| U-OP-004 | `reqHeader` 请求头信息的内容格式 |

---

## 实体五：OrderSaleDO（订单销售信息实体）

### ① 身份（Identity）

| 维度 | 描述 |
|------|------|
| **类型名称** | `OrderSaleDO` |
| **包路径** | `com.shouqianba.localserver.order.domain.entity` |
| **职责定位** | 订单聚合中的值对象（Value Object），专门管理销售收银信息 |
| **职责描述** | 封装订单的实付金额、找零、超收、桌台信息、会员信息等销售数据 |
| **E-SRC** | 第10-144行 |
| **构造函数** | 无显式构造 |
| **线程安全** | 非线程安全 |

### ② 结构（Structure）

| 维度 | 描述 |
|------|------|
| **核心标识** | `id` (Long) |
| **金额字段** | `actualPayAmount`(实付金额), `overAmount`(超收金额), `changeAmount`(找零金额), `pointAmount`(积分值) |
| **桌台信息** | `tableId`, `tableBrand`, `tableName`, `areaId` |
| **会员信息** | `cardId`, `cardNo`, `customerId` |
| **人数** | `dinnersNumber`(用餐人数) |
| **E-SRC** | 第12-24行（字段声明） |

### ③ 关系（Relations）

| 维度 | 描述 |
|------|------|
| **聚合归属** | 作为 `OrderMasterDO.saleInfo` 子实体存在 |
| **状态同步** | 与 `OrderMasterDO.pay/cancelPay` 同步实付金额 | 第26-39行 |
| **E-SRC** | 第26-39行（pay/cancelPay 方法） |

### ④ 行为（Behaviors）

| 行为 | 描述 | E-SRC |
|------|------|-------|
| `pay(OrderPay, BigDecimal)` | 支付成功：累加实付、记录找零和超收 | 第26-33行 |
| `cancelPay(BigDecimal)` | 取消支付：扣减实付、重置找零和超收 | 第35-39行 |

### ⑤ 交互（Interactions）

| 交互对象 | 交互方式 | E-SRC |
|----------|----------|-------|
| `OrderPay` | 读取 `orderPay.getActualReceiptAmount()`, `orderPay.getOverAmount()` | 第27,32行 |
| `BigDecimal` | 接收找零金额 changeAmount | 第28行 |

### ⑥ 生命时间线（Lifecycle）

| 阶段 | 触发条件 | 状态变更 | E-SRC |
|------|----------|----------|-------|
| **创建** | 默认值 | 所有字段为 null 或 0 | - |
| **支付** | `pay()` | 累加 `actualPayAmount`，设置 `changeAmount`，累加 `overAmount` | 第26-33行 |
| **取消支付** | `cancelPay()` | 扣减 `actualPayAmount`，重置 `changeAmount=0`，`overAmount=0` | 第35-39行 |

### ⑦ 实现（Implementation）

| 维度 | 描述 |
|------|------|
| **设计模式** | 值对象模式（无 ID 生成逻辑） |
| **精度处理** | 找零金额不允许为负，最小值为 0 | 第29-31行 |
| **累计策略** | 实付和超收支持多次支付累加 | 第27,32行 |
| **重置策略** | 取消支付时找零和超收归零（不累减） | 第37-38行 |

### ⑧ 失败（Failure Handling）

| 场景 | 失败表现 | E-SRC |
|------|----------|-------|
| 找零金额为负 | 强制归零 | 第29-31行 |
| 取消支付后超收为负 | 归零处理 | 第38行 |

### ⑨ 证据（Evidence）

| 证据ID | 源码位置 | 关键发现 |
|--------|----------|----------|
| E-OSa-001 | 第26-33行 | pay 方法：实付累加 + 找零记录 + 超收累加 |
| E-OSa-002 | 第35-39行 | cancelPay：扣减实付 + 重置找零/超收为零 |
| E-OSa-003 | 第29-31行 | 找零金额下限保护：changeAmount >= 0 |

### ⑩ 未知（Unknowns）

| 标记 | 描述 |
|------|------|
| U-OSa-001 | `tableBrand`（桌牌号）与 `tableName`（桌名）的区分 |
| U-OSa-002 | `overAmount`（超收金额）的触发条件和业务含义 |
| U-OSa-003 | `dinnersNumber` 的来源和校验规则 |

---

## 实体关系总图

```
┌─────────────────────────────────────────────────────────────────────┐
│                        OrderMasterDO                                │
│                      (订单聚合根 / Aggregate Root)                   │
│                                                                     │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐         │
│  │  OrderStatusDO │  │  OrderSaleDO   │  │  OrderPay[]    │         │
│  │  (1:1)         │  │  (1:1)         │  │  (1:N)         │         │
│  │  订单状态       │  │  销售收银信息   │  │  支付记录列表   │         │
│  └────────────────┘  └────────────────┘  └────────────────┘         │
│                                                                     │
│  ┌────────────────┐  ┌────────────────┐                            │
│  │ OrderDetailDO[]│  │OrderHoldConsume│                            │
│  │  (1:N)         │  │  [] (1:N)      │                            │
│  │  订单明细列表   │  │  挂账消费列表   │                            │
│  └───────┬────────┘  └────────────────┘                            │
│          │                                                          │
│          │ (comboList 套餐子项, 递归嵌套)                             │
│          ▼                                                          │
│  ┌────────────────┐                                                │
│  │ OrderDetailDO  │                                                │
│  │  (套餐子项)     │                                                │
│  └────────────────┘                                                │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 附录：E-SRC 索引表

| 实体 | E-SRC 范围 | 核心行为 |
|------|------------|----------|
| OrderMasterDO | E-SRC: L28-489 | pay/cashPay/onlinePay/cancelPay/refund, apportionAmount |
| OrderDetailDO | E-SRC: L27-524 | addPayDiscount, updatePayDiscount, cancelPayDiscount, payComplete |
| OrderStatusDO | E-SRC: L12-106 | payComplete |
| OrderPay | E-SRC: L15-1796 | equals, hashCode, toString |
| OrderSaleDO | E-SRC: L10-144 | pay, cancelPay |

---

## 附录：金额字段对照表

| 实体 | 字段 | 含义 | 计算公式 |
|------|------|------|----------|
| OrderMasterDO | orderTotalAmount | 订单总额 | sum(OrderDetail.goodsSaleAmount) |
| OrderMasterDO | orderDiscountAmount | 订单优惠金额 | 手动优惠/活动优惠 |
| OrderMasterDO | payDiscountAmount | 支付优惠金额 | 支付时减免 |
| OrderMasterDO | actualReceiptAmount | 实收金额 | sum(OrderPay.actualReceiptAmount) |
| OrderMasterDO | unpaidAmount | 未付金额 | orderTotalAmount - orderDiscountAmount - payDiscountAmount - actualReceiptAmount |
| OrderDetailDO | goodsSaleAmount | 销售总额 | goodsQty * salesPrice |
| OrderDetailDO | goodsPayAmount | 实付总额 | goodsQty * goodsPayPrice |
| OrderDetailDO | goodsDiscountAmount | 商品优惠 | 手动调价优惠 |
| OrderDetailDO | payDiscountAmount | 支付优惠分摊 | 按比例分摊的支付优惠 |
| OrderPay | payAmount | 应付金额 | 支付请求金额 |
| OrderPay | actualReceiptAmount | 实收金额 | 实际到账金额 |
| OrderPay | payDiscountAmount | 支付优惠 | 支付时减免金额 |
| OrderSaleDO | actualPayAmount | 实付累计 | sum(payAmount) |
| OrderSaleDO | changeAmount | 找零金额 | 超额支付时的找零 |
| OrderSaleDO | overAmount | 超收金额 | 超出订单金额的收款 |

---

**文档版本**: v1.0  
**生成工具**: 源码反编译分析 + LLM 结构化提取  
**维护建议**: 每次核心业务变更后更新对应实体的 E-SRC 范围
