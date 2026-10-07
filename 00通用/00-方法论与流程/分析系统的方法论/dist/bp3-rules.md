# BP-3.1 业务规则挖掘报告

## 挖掘概要

| 项目 | 值 |
|------|-----|
| 挖掘系统 | kaci-pos-localserver |
| 核心域 | 订单、支付、会员、商品、桌台 |
| 挖掘范围 | service/order/, service/pay/, service/member/, service/goods/, service/table/, service/promotion/ |
| 挖掘方法 | throw 语句提取 + 条件判断分析 + 代码上下文分析 |

---

## 资格规则

### 订单取消/反结账资格

| 规则ID | 规则描述 | 触发条件 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| EL-001 | 订单状态必须为"已结账" | `OrderStatusEnum.ORDER_YJZ` | `RevCheckoutService.java:103-104` | B1 |
| EL-002 | 订单不存在退款中状态 | `!isExistRefunding(refundOrderNos)` | `RevCheckoutService.java:107-111` | B1 |
| EL-003 | 反结账时间窗口限制 | `hours > closedBillModifyTimeLimit` (默认12小时) | `RevCheckoutService.java:123-126` | B1 |
| EL-004 | 跨工作日反结账需授权 | `revFlag == 0 && !BizBaseUtil.getBusinessDate().equals(orderMaster.getWorkDate())` | `RevCheckoutService.java:117-121` | B2 |
| EL-005 | 外卖平台订单禁止反结账 | `PlatformTypeEnum.isTakeoutPlatformType(orderMaster.getPlatformType())` | `RevCheckoutService.java:214-220` | B1 |
| EL-006 | 订单状态不能为"待结账" | `!OrderStatusEnum.ORDER_DJZ.getCode().equals(orderStatus.getOrderStatus())` | `OrderService.java:504-506` | B1 |
| EL-007 | 整单退款订单状态校验 | `status NOT IN (ORDER_DJZ, ORDER_YQX)` | `WholeOrderRefundService.java:319-320` | B1 |
| EL-008 | 外卖平台订单禁止整单退款 | `PlatformTypeEnum.isTakeoutPlatformType(orderMaster.getPlatformType())` | `WholeOrderRefundService.java:315-316` | B1 |
| EL-009 | 会员卡号不能为空 | `StringUtils.isBlank(orderPay.getMemberCardId())` | `WholeOrderRefundService.java:554-556` | B1 |
| EL-010 | 交易流水号不能为空 | `StringUtils.isEmpty(payOrderNo)` | `WholeOrderRefundService.java:576-578` | B1 |

### 促销执行资格

| 规则ID | 规则描述 | 触发条件 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| EL-011 | 订单版本号必须匹配 | `!context.getOrderMaster().getRevision().equals(request.getRevision())` | `ExecutePromotionService.java:194-195` | B1 |
| EL-012 | 折扣促销需授权用户存在 | `userAuthInfo == null \|\| userAuthInfo.isEmpty()` | `CheckDiscountService.java:176-178` | B1 |
| EL-013 | 短账账号激活状态校验 | `!shortAccount.getIsActive().equals(YesNoEnum.YES)` | `CheckDiscountService.java:141-143` | B1 |
| EL-014 | 密码校验失败 | `!shortAccount.getShortLoginPwd().equals(authLoginPwd)` | `CheckDiscountService.java:138-140` | B1 |
| EL-015 | 角色权限校验 | `accountIds.stream().noneMatch(roleIdList::contains)` | `CheckDiscountService.java:126-128` | B2 |
| EL-016 | 起售数量校验 | `goodsQty < minSaleQty` | `ExecutePromotionService.java:2318` | B1 |

### 桌台操作资格

| 规则ID | 规则描述 | 触发条件 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| EL-017 | 桌台代码必须存在 | `tableInfo == null` | `OrderService.java:989` | B1 |
| EL-018 | 桌台状态必须为预结账 | `status NOT IN (PREORDER, PRESETTLEMENT, TOSETTLEMENT)` | `OrderService.java:991-992` | B1 |
| EL-019 | 订单商品必须有做法选择 | `做法必需` | `OrderService.java:679-682` | B1 |
| EL-020 | 订单商品必须有加料选择 | `加料必需` | `OrderService.java:749-752` | B1 |
| EL-021 | 桌台状态必须为预清台 | `TableStatusEnum.FREE.getCode().equals(tableInfo.getTableStatus()) \|\| TableStatusEnum.PRECLEAR.getCode().equals(tableInfo.getTableStatus())` | `RevCheckoutService.java:139` | B2 |

---

## 数量规则

### 退款数量限制

| 规则ID | 规则描述 | 取值范围 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| QR-001 | 退款商品数量不能为负 | `payAmount >= 0` | `WholeOrderRefundService.java:333-334` | B1 |
| QR-002 | 退款商品明细不能为空 | `CollectionUtils.isNotEmpty(orderDetails)` | `WholeOrderRefundService.java:841-842` | B1 |
| QR-003 | 估清剩余数量校验 | `goodsQty > soldOutStockEntity.getUsableNum()` | `OrderService.java:570-571` | B1 |

### 促销数量规则

| 规则ID | 规则描述 | 取值范围 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| QR-004 | 单品最大折扣权限 | `discount <= businessPermission.getSingleItemMaxDiscount()` | `CheckDiscountService.java:78-80` | B2 |
| QR-005 | 整单最大折扣权限 | `discount <= businessPermission.getWholeOrderMaxDiscount()` | `CheckDiscountService.java:84-86` | B2 |
| QR-006 | 单笔最大免单金额 | `existDiscountAmount <= businessPermission.getSingleMaxFreeAmount()` | `CheckDiscountService.java:97-99` | B2 |
| QR-007 | 会员卡折扣不能低于最低折扣 | `PromotionTypeEnum.POS_DISCOUNT && discount < singleItemMaxDiscount` | `CheckDiscountService.java:595-597` | B2 |
| QR-008 | 整单折扣不能超过权限 | `discount < wholeOrderMaxDiscount` | `CheckDiscountService.java:599-601` | B2 |
| QR-009 | 立减金额不能超过商品金额 | `discount > goodsDetail.joinPosDiscountAmount()` | `CheckDiscountService.java:282-284` | B1 |
| QR-010 | 整单立减不能超过订单总额 | `discount > totalAmount` | `CheckDiscountService.java:302-304` | B1 |

### 桌台数量规则

| 规则ID | 规则描述 | 取值范围 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| QR-011 | 合台目标桌台状态校验 | `TableStatusEnum.PRECLEAR.getCode().equals(tableInfo.getTableStatus())` | `UnionTableService.java:559` | B1 |
| QR-012 | 合台分组校验 | `同一分组桌台才能合并` | `UnionTableService.java:562` | B1 |
| QR-013 | 做法数量限制 | `detailPracticeList.size() >= limitNum` (类型2限制) | `OrderService.java:652-655` | B1 |

---

## 时间规则

### 反结账时间窗口

| 规则ID | 规则描述 | 时间窗口 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| TR-001 | 结账后反结账时间限制 | `hours <= closedBillModifyTimeLimit` (默认12小时) | `RevCheckoutService.java:123-126` | B1 |
| TR-002 | 跨工作日反结账控制 | `revFlag == 0 时禁止跨日` | `RevCheckoutService.java:117-121` | B2 |
| TR-003 | 反结账重试机制 | 最多20次，每次间隔2000ms | `WholeOrderRefundService.java:661-689` | B2 |

### 业务日期规则

| 规则ID | 规则描述 | 时间窗口 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| TR-004 | 退款业务日期控制 | `refundBizDay=1时使用原订单工作日期` | `WholeOrderRefundService.java:762-765` | B2 |
| TR-005 | 估清占用时间点 | `落单时占库存` | `OrderService.java:524-529` | B1 |
| TR-006 | 估清归还时间点 | `整单退款时归还` | `WholeOrderRefundService.java:262-279` | B1 |

### 促销时间规则

| 规则ID | 规则描述 | 时间窗口 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| TR-007 | 订单刷新推送延迟 | 200ms延迟 | `ExecutePromotionService.java:406-414` | B3 |
| TR-008 | 估清同步延迟 | 异步执行 | `ExecutePromotionService.java:341` | B3 |

---

## 金额规则

### 退款金额计算

| 规则ID | 规则描述 | 计算规则 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| AR-001 | 整单退款金额 | `= 订单实收金额` | `WholeOrderRefundService.java:821-839` | B1 |
| AR-002 | 退款单金额为负 | `orderDetails.stream().filter(qty > 0)` | `WholeOrderRefundService.java:823` | B1 |
| AR-003 | 会员卡退款金额 | `= payAmount (原路退回)` | `WholeOrderRefundService.java:586-590` | B1 |
| AR-004 | 扫描支付退款金额 | `= orderPay.getPayAmount()` | `WholeOrderRefundService.java:623` | B1 |
| AR-005 | 挂账退款金额 | `通过 HoldConsumeRefundDto 传递` | `WholeOrderRefundService.java:595-605` | B1 |

### 促销金额规则

| 规则ID | 规则描述 | 计算规则 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| AR-006 | 单品折扣金额 | `discount = promotionValue * goodsAmount / 100` | `CheckDiscountService.java:271-272` | B1 |
| AR-007 | 单品立减金额 | `discount = promotionValue` (固定值) | `CheckDiscountService.java:285` | B1 |
| AR-008 | 整单折扣金额 | `discount = promotionValue * totalAmount / 100` | `CheckDiscountService.java:308` | B1 |
| AR-009 | 整单立减金额 | `discount = request.getDiscount()` | `CheckDiscountService.java:305` | B1 |
| AR-010 | 折扣封顶计算 | `min(discountAmount, maxDiscountAmount)` | `ExecutePromotionService.java:722-724` | B1 |
| AR-011 | 订单待收金额 | `unpaidAmount = orderTotalAmount - orderDiscountAmount - payDiscountAmount - actualReceiptAmount` | `RevCheckoutService.java:141` | B1 |

### 费用计算规则

| 规则ID | 规则描述 | 计算规则 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| AR-012 | 服务费计算 | `serviceAmount = getServiceAmount(detailList, promotionList)` | `ExecutePromotionService.java:234` | B2 |
| AR-013 | 服务费修改 | `orderTotalAmount = oldTotalAmount - oldServiceAmount + newServiceAmount` | `OrderService.java:961-964` | B2 |
| AR-014 | 人均计算 | `avgEatNumber = totalEatNumber / dinnersNumber` | `ExecutePromotionService.java:351` | B2 |
| AR-015 | 人均菜品重量 | `avgFoodWeight = totalFoodWeight / dinnersNumber` | `ExecutePromotionService.java:352` | B2 |

---

## 组合规则

### 促销互斥关系

| 规则ID | 规则描述 | 互斥关系 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| CR-001 | 整单折扣互斥 | `ORDER_DISCOUNT 只能存在一个` | `ExecutePromotionService.java:645-686` | B1 |
| CR-002 | 整单立减互斥 | `ORDER_REDUCE 只能存在一个` | `ExecutePromotionService.java:669-683` | B1 |
| CR-003 | 会员卡折扣与POS折扣互斥 | `PromotionTypeEnum.POS_DISCOUNT && existDiscount` | `CheckDiscountService.java:96-99` | B1 |
| CR-004 | 优惠券与整单优惠互斥 | `usedCouponIdList 校验` | `ExecutePromotionService.java:538-569` | B1 |
| CR-005 | 积分支付与礼金卡互斥 | `balanceCanUse, giftCardCanUse, pointCanUse` | `ExecutePromotionService.java:311-327` | B2 |
| CR-006 | 整单立减与单品立减累计 | `discountAmount = orderReduce + allReduces` | `CheckDiscountService.java:210-229` | B1 |

### 支付方式互斥

| 规则ID | 规则描述 | 互斥关系 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| CR-007 | 扫描支付退款互斥 | `同一 payOrderNo 的会员卡支付只退一次` | `WholeOrderRefundService.java:362-376` | B1 |
| CR-008 | 优惠券与团购券互斥 | `PromotionTypeEnum.isCoupon vs isGroupBuying` | `WholeOrderRefundService.java:391-399` | B1 |
| CR-009 | 会员卡支付子类互斥 | `REFUND_MEMBER_PAY_CODES 只包含特定子类` | `WholeOrderRefundService.java:988` | B1 |

### 订单状态转移

| 规则ID | 规则描述 | 转移条件 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| CR-010 | 结账后 -> 待结账 | `反结账操作` | `RevCheckoutService.java:132-137` | B1 |
| CR-011 | 待结账 -> 已完成 | `结账成功` | `OrderService.java:783` | B1 |
| CR-012 | 桌台状态 -> 预结算 | `反结账时桌台为空或已预清` | `RevCheckoutService.java:139-148` | B1 |
| CR-013 | 发票状态 -> 已开 | `开票成功后` | `OrderInvoiceService.java:92` | B1 |
| CR-014 | 发票状态 -> 已红冲 | `整单退款时发票已开` | `WholeOrderRefundService.java:239-248` | B1 |

### 估清与促销组合

| 规则ID | 规则描述 | 组合规则 | 代码位置 | 证据等级 |
|--------|----------|----------|----------|----------|
| CR-015 | 估清商品参与促销 | `估清后仍可参与` | `ExecutePromotionService.java:227-232` | B2 |
| CR-016 | 估清强停标志 | `isForceSoldOut=1 时强制停售` | `IGoodsListService.java:348-350` | B1 |
| CR-017 | 估清数量预占 | `落单时占用估清库存` | `OrderService.java:520-529` | B1 |
| CR-018 | 估清库存归还 | `整单退款时归还估清库存` | `WholeOrderRefundService.java:262-279` | B1 |

---

## 估清触发条件详细分析

### 估清类型

| 类型 | 触发条件 | 代码位置 |
|------|----------|----------|
| 每日估清 | `workDate = BizBaseUtil.getBusinessDate()` | `OrderService.java:551` |
| 餐段估清 | 需配置 `SoldOutStockEntity` | `OrderService.java:551` |
| 永久估清 | `UsableNum = 0 && isForceSoldOut = 1` | `IGoodsListService.java:348-350` |

### 估清强制销售

| 场景 | 条件 | 代码位置 |
|------|------|----------|
| POS端强停 | `isForceSoldOut = 1` 时不检查库存 | `OrderService.java:538-539` |
| 小程序端 | 所有估清SKU都检查 | `OrderService.java:542-543` |
| RFID操作 | 过滤非强制估清SKU | `RfidOperateService.java:622` |

### 估清前置条件

```java
// OrderService.java:532-547
void checkSoldOut(final List<GoodsDetail> detailList, final Long workDate, final Integer isFormPos) {
    // 1. 提取所有SKU
    List<Long> skuIds = detailList.stream().map(GoodsDetail::getSkuId).distinct()
        .collect(Collectors.toList());

    // 2. POS端只检查非强制估清
    if (YesNoEnum.YES.getCode().equals(isFormPos)) {
        noForceSkuIds = soldOutSettingService.listBySkuIds(skuIds)
            .stream().filter(item -> YesNoEnum.NO.getCode().equals(item.getIsForceSoldOut()))
            .map(SoldOutSettingEntity::getSkuId).collect(Collectors.toList());
    } else {
        noForceSkuIds = soldOutSettingService.listBySkuIds(skuIds)
            .stream().map(SoldOutSettingEntity::getSkuId).collect(Collectors.toList());
    }

    // 3. 验证库存
    this.validSoldOutStock(detailList, noForceSkuIds, workDate);
}
```

---

## 附录：异常代码索引

| 异常代码 | 异常信息 | 关联规则 |
|----------|----------|----------|
| 0101010103 | 订单不存在 | EL-001, EL-009, EL-018 |
| 0101010113 | 订单商品为空 | EL-006 |
| 0101010125 | 订单状态不正确 | EL-006, CR-010 |
| 0101010131 | 桌台状态不正确 | EL-018 |
| 0101010136 | 订单不能操作 | EL-010 |
| 0101010149 | 商品已存在 | EL-006 |
| 0101010150 | 订单不能下挂 | EL-002 |
| 0101010520 | 桌台不存在 | EL-017 |
| 0101010537 | 促销不能合台 | EL-014 |
| 0101010601 | 会员卡号不存在 | EL-009 |
| 0101010602 | 交易流水号不存在 | EL-010 |
| 0101010803 | 商品不能参与促销 | QR-003 |
| 0101010804 | 商品未选择做法 | EL-019 |
| 0101010807 | 商品未选择加料 | EL-020 |
| 0101010810 | 商品未达到起售数量 | QR-016 |
| 0101010900 | 支付金额不能为空 | AR-004, AR-005 |
| 0101010903 | 支付金额不匹配 | AR-005 |
| 0101010910 | 支付失败 | AR-002 |
| 0101010912 | 订单已取消 | EL-001 |
| 0101010913 | 订单未结账 | EL-001 |
| 0101010915 | 反结账超时 | TR-001 |
| 0101010953 | 跨工作日反结账 | TR-002 |
| 0101010964 | 退款重试超时 | TR-003 |
| 0101010965 | 退款状态异常 | TR-003 |
| 0101010978 | 券号为空 | EL-011 |
| 0101011001 | 待结算订单不能作废 | EL-001 |
| 0101011005 | 订单已结算不能作废 | EL-001 |
| 0101011006 | 订单已退款 | EL-007 |
| 0101011007 | 订单已取消 | EL-007 |
| 0101011009 | 商品已退款 | QR-002 |
| 0101011010 | 商品已取消 | QR-002 |
| 0101011300 | 促销类型不存在 | EL-012 |
| 0101011304 | 立减金额超限 | QR-009, QR-010 |
| 0101011305 | 用户不存在 | EL-013 |
| 0101011306 | 密码错误 | EL-014 |
| 0101011307 | 折扣超权限 | QR-004, QR-005, QR-007, QR-008 |
| 0101011308 | 免单超权限 | QR-006 |
| 0101011313 | 授权信息为空 | EL-012 |
| 0101011314 | 权限不足 | EL-015 |
| 0101011316 | 无折扣权限 | EL-012, QR-007, QR-008 |
| 0101011317 | 赠品商品不存在 | QR-015 |
| 0101011319 | 商品不能参与折扣 | QR-010 |
| 0101011322 | 促销不适用 | CR-001 |
| 0101011505 | 估清数量不足 | QR-003 |
| 0101012002 | 外卖订单不能整单退款 | EL-008 |
| 0101012003 | 订单状态不能整单退款 | EL-007 |
| 0101012004 | 订单存在退款中 | EL-002 |
| 0101012005 | 退款商品为空 | QR-002 |
| 0101012006 | 支付金额异常 | QR-001 |
| 0101012100 | 押金退款失败 | AR-003 |

---

## 证据等级说明

| 等级 | 定义 | 说明 |
|------|------|------|
| B1 | 直接代码证据 | throw 语句 + 完整条件判断链 |
| B2 | 配置推断证据 | 通过组织参数或权限配置推断 |
| B3 | 间接推断证据 | 异步处理或日志推断 |

---

*文档生成时间: 2026-09-03*
*生成工具: BP-3.1 业务规则挖掘 SOP*
