# 小程序实物券付款方式 COUPON 同步到 POS 设计

## 1. 背景

小程序实物券/商品券下单链路中，券本身不是用户在支付页主动选择的普通现金券付款方式。用户在点餐页核销实物券后，云端会把券抵扣结果体现在订单菜品和订单金额中，支付页只对剩余金额做会员卡、微信等真实付款。

但 POS 自动接单和结账链路并不只依赖 `DwdCoupon` 判断账单是否平账。POS 结账时会汇总本地 `dwd_pay.pay_amount`，并用这个合计与账单应收/实收金额核对。因此，云端下发给 POS 的订单详情必须同时包含完整的支付明细：实物券抵扣也要作为云端 `order_pay` 的 `COUPON` 支付项存在。POS 本地会把云端 `COUPON` 映射为本地 `DwdPay` 的 `FJ`（付券）付款方式。

本文补充的是付款方式同步契约，和 `07-小程序平台商品券核销凭证传递到POS DwdCoupon设计.md` 互补：

- `07` 解决核销凭证沉淀到 POS `DwdCoupon`，用于撤销、退菜、券明细和券核销追踪。
- 本文解决云端付款时生成 `COUPON/FJ` 支付明细，用于 POS 本地 `DwdPay`、结账平账和支付方式同步。

## 2. 问题现象

2026-06-02 小程序实物券测试订单出现 POS 本地账不平：

- 云端订单 ID：`2061720699561840642`
- POS 本地单号：`2026060210003`
- 菜品：`开胃酸菜焖鹅血`
- 菜品金额：`10`
- 实物券抵扣：`5`
- 会员卡实付：`5`

云端 `doGetOrder` 日志显示：

- `foodList` 中有实物券信息：`couponNo=2059054922852868098`，`productCouponBusinessType=WP`。
- `order.paidAmount=5.00`，`order.promotionAmount=5.00`。
- `payList` 只有一条 `type=CRM`、`amount=5.00` 的会员卡支付。
- `payList` 没有 `type=COUPON`、金额 `5.00` 的券支付项。

POS 本地数据表现为：

- `dwd_bill.food_amount=10`
- `dwd_bill.coupon_amount=5`
- `dwd_bill.paid_amount=5`
- `dwd_coupon` 已有核销记录，`face_amount=5`、`write_off=1`
- `dwd_pay` 曾生成一条券支付行：
  - `pay_way_lid=-5`
  - `type_=5`
  - `name=开胃酸菜焖鹅血`
  - `pay_amount=5`
  - `coupon_type=2`
  - 但最终 `deleted=1`
- 会员卡支付行仍为 `deleted=0`、金额 `5`

最终 POS 结账校验报错：

```text
扫码结账错误:包厢002【2026060210003】应收【10】与实收【5】不等
```

## 3. 问题出现的原因

### 3.1 云端付款明细缺失券支付项

当前云端付款成功后，`order_pay` 只保存了会员卡等实际付款项。实物券抵扣金额虽然体现在订单菜品和订单优惠中，但没有同时保存一条 `type=COUPON` 的 `order_pay`。

`doGetOrder` 返回 `payList` 时，只查询云端 `order_pay` 表并映射为 `OrderPayVO`。由于云端付款时没有落 `COUPON` 支付记录，POS 反查订单详情时自然只能拿到 `CRM=5`，拿不到券抵扣 `COUPON=5`。

根因第一层是：**云端支付明细表没有表达完整支付构成。**

### 3.2 POS 本地存在“空支付时按 DwdCoupon 补 FJ”的兜底逻辑

POS 侧历史上有本地补券支付的逻辑：当本地账单有 `couponAmount>0`，但 `dwd_pay` 为空时，会调用 `OrderServiceUtil.addCoupons(...)`，根据本地 `DwdCoupon` 汇总生成一条 `FJ` 付款方式。

这段逻辑本来服务于 POS 本地结账、线下核券、报表汇总等场景。它的前提是：POS 本地掌握券数据，但没有对应 `DwdPay` 时，需要补齐本地支付方式，保证结账金额能平。

在小程序云端付款链路里，这个兜底逻辑变成了副作用：POS 先根据 `DwdCoupon` 补出 `FJ=5`，但云端 `payList` 仍然没有 `COUPON=5`。

### 3.3 POS 支付同步又以云端 payList 为准删除本地多余支付

`CashPayHandler.checkPays()` 的同步逻辑会把云端 `payList` 视为支付方式来源：

- 云端有的支付方式，本地更新或新增。
- 云端没有的本地支付方式，视为残留支付方式，加入删除集合。

由于云端 `payList` 只有 `CRM=5`，没有 `COUPON=5`，POS 本地刚补出的 `FJ=5` 在同一个同步流程中又被判断为“云端不存在的多余支付方式”，最终调用逻辑删除，把 `dwd_pay.deleted` 置为 `1`。

根因第二层是：**POS 同时存在“本地补 FJ”和“按云端 payList 删除本地多余支付”两套规则，在云端缺少 COUPON 支付项时互相冲突。**

### 3.4 最终导致账不平

POS 结账校验汇总的是未删除的 `dwd_pay.pay_amount`。当本地 `FJ=5` 被逻辑删除后，未删除支付只剩会员卡 `5`。

账单实际口径是：

- 菜品金额 `10`
- 实物券抵扣 `5`
- 会员卡实付 `5`

POS 支付明细口径变成：

- 会员卡 `5`
- 券支付缺失

所以结账时出现“应收 10 与实收 5 不等”。

一句话总结根因：**云端付款时没有生成实物券 `COUPON` 支付明细，POS 为了平账本地补了 `FJ`，但又按云端缺失的 `payList` 把这条 `FJ` 删除，最终造成 POS 本地支付明细少 5 元。**

## 4. 正确设计原则

### 4.1 云端付款时必须落完整支付明细

小程序实物券订单付款完成时，云端 `order_pay` 必须包含完整支付构成：

```text
COUPON/FJ 实物券抵扣金额 + CRM/WECHAT 等实际付款金额 = 订单应结金额
```

以本次测试订单为例，云端付款后应保存两条支付明细：

| 类型 | 名称 | 金额 | 说明 |
|---|---|---:|---|
| `COUPON` | 开胃酸菜焖鹅血 / 付券 | 5 | 实物券抵扣 |
| `CRM` | 会员卡 | 5 | 会员卡实付 |

云端枚举仍使用 `PayTypeEnum.COUPON`；POS 接收到后映射为本地 `PayWayEnum.FJ`。文档中写 `COUPON/FJ` 是为了说明两端语义对应关系，不是要求云端新增名为 `FJ` 的枚举。

### 4.2 前端支付页不提交商品券付款项

旧设计中“商品券不进入支付页 `orderPayList` 的普通 `COUPON` 付款项”仍然成立。

新的边界是：

- 前端支付页不需要、也不应该把已核销实物券再次作为付款方式提交，避免二次抵扣。
- 云端在付款落库时，根据订单中已核销的实物券/商品券抵扣结果，内部生成系统级 `COUPON` 支付明细。

也就是说，**不是让前端多传一条 COUPON，而是让云端付款服务在保存支付明细时补齐这条 COUPON。**

### 4.3 POS 云端付款链路不再本地派生同一条 FJ

云端 `order_pay` 正确保存 `COUPON` 后，POS `CashPayHandler` 在处理云端 `CASH_PAY/DO_ORDER` 自动结账时，应只消费云端 `payList`。

这条链路不应再因为本地 `couponAmount>0` 且 `dwd_pay` 为空，就调用 `OrderServiceUtil.addCoupons(...)` 派生 FJ。

需要保留的是：

- POS 本地核券/线下结账/手工加券等本地业务里的 `addCoupons(...)`。
- 这些场景仍可能需要根据本地 `DwdCoupon` 补齐本地 `DwdPay`。

需要禁用的是：

- 小程序云端付款同步链路中，`CashPayHandler.checkPays()` 的空支付兜底补 FJ。

## 5. 云端实现要求

### 5.1 触发时机

云端应在 `pay_order` 付款处理并保存 `OrderPay` 时生成实物券 `COUPON` 支付方式。

不建议只在 `doGetOrder` 返回时临时派生，原因：

- `doGetOrder` 临时派生只能修返回值，不能修正云端 `order_pay` 数据源。
- 后续撤销、查询、支付明细审计仍会缺失券支付。
- 本问题与历史数据无关，不需要为旧订单做查询时补偿。

本次设计只要求新付款订单从付款落库开始数据正确。

### 5.2 生成条件

满足以下条件时，云端付款服务应生成 `OrderPay(type=COUPON)`：

- 订单存在已核销的实物券/商品券抵扣结果。
- 该抵扣已经体现在订单菜品或订单优惠金额中。
- 当前付款请求只包含剩余实付金额，例如会员卡、微信等。

如果订单没有商品券抵扣，不生成额外 `COUPON`。

如果前端错误地提交了商品券 `COUPON`，云端应避免重复生成；同一张券/同一订单只能有一条对应的券支付明细或按明确聚合规则生成。

### 5.3 字段口径

云端 `OrderPay` 建议字段口径：

| 字段 | 建议值 |
|---|---|
| `type` | `PayTypeEnum.COUPON` |
| `name` | 优先券名/菜品名；缺失时用“付券”或“优惠券” |
| `payAmount` | 实物券抵扣金额 |
| `amount` | 实物券抵扣金额 |
| `couponNo` | 对应券号；多券聚合时需明确是否为空或使用主券号 |
| `saasOrderNo` | 当前订单 `OrderBill.lid` |
| `saasOrderKey` | 当前订单号 |
| `mid/sid/reportDate` | 与订单一致 |
| `deleted` | `false` |

金额口径必须与订单优惠/抵扣口径一致，保证：

```text
sum(order_pay.pay_amount) >= order_bill.paid_amount 或 POS 结账要求的支付合计口径
```

对本次小程序实物券先付场景，POS 预期看到：

```text
COUPON 5 + CRM 5 = 10
```

### 5.4 不处理历史数据

本次不做历史订单修复：

- 不扫描旧订单补 `order_pay`。
- 不在 `doGetOrder` 为旧订单临时派生 `COUPON`。
- 不为了兼容旧错误数据增加复杂分支。

测试环境中已产生的脏单可单独按测试数据处理，不纳入产品逻辑。

## 6. POS 实现要求

### 6.1 云端付款同步链路只消费 payList

`CashPayHandler.checkPays()` 在处理云端 `payList` 时：

- 云端 `type=COUPON` 的支付项，创建/更新本地 `DwdPay.type=FJ`。
- 金额取云端 `OrderPayVO.payAmount/amount`。
- 名称优先取云端 `OrderPayVO.name`。
- 不再因为本地 `couponAmount>0` 且 `dwd_pay` 为空主动调用 `OrderServiceUtil.addCoupons(...)`。

这样 POS 本地的 FJ 来源只有一个：云端 `payList` 的 `COUPON`。

### 6.2 保留本地链路 addCoupons

不能全局删除 `OrderServiceUtil.addCoupons(...)`。

它仍服务于 POS 本地业务：

- POS 本地核券后补支付方式。
- 本地结账/预结账需要按 `DwdCoupon` 汇总券支付。
- 线下或手工加券链路需要生成本地 `DwdPay`。

本次只限制云端小程序付款同步链路，防止同一张实物券在 POS 本地被二次派生 FJ。

### 6.3 防重复规则

POS 处理云端 `COUPON` 支付项时，应避免重复插入本地 FJ：

- 如果本地已有同订单、同类型、同券号或同名称金额的 FJ，应更新或复用。
- 如果云端本次 `payList` 中没有 `COUPON`，不应再本地兜底派生 FJ；应让问题暴露为云端支付明细缺失，便于排查。

## 7. 预期修复后的链路

修复后，小程序实物券先付订单链路应为：

```text
小程序点餐页核销实物券
  -> 云端订单保存菜品和券抵扣
  -> 用户付款剩余金额
  -> 云端 pay_order 保存 CRM/WECHAT 等真实付款
  -> 云端同时保存 COUPON 实物券抵扣支付项
  -> DO_ORDER 到 POS
  -> POS doGetOrder 反查订单
  -> payList 返回 COUPON + CRM/WECHAT
  -> POS 创建 DwdPay(FJ) + DwdPay(会员卡/微信)
  -> POS 结账校验通过
```

本次测试订单修复后预期：

```text
云端 payList:
  COUPON 开胃酸菜焖鹅血 5
  CRM 会员卡 5

POS dwd_pay:
  FJ 开胃酸菜焖鹅血 5 deleted=0
  HYK 会员卡 5 deleted=0

结账:
  应收 10
  实收 10
  不再产生“应收 10 与实收 5 不等”
```

## 8. 与既有文档的关系

### 8.1 与 03/04 的关系

`03-小程序商品券核销设计文档.md` 和 `04-小程序商品券后端接口实现说明.md` 中“商品券不作为支付页 `COUPON` 付款项提交”的要求仍保留。

本文补充的是云端内部付款落库规则：

- 支付页不提交商品券 `COUPON`。
- 云端付款服务必须根据已核销商品券结果生成系统支付明细 `COUPON`。

这两个要求不冲突。

### 8.2 与 07 的关系

`07-小程序平台商品券核销凭证传递到POS DwdCoupon设计.md` 关注 POS `DwdCoupon`：

- 券号
- 核销凭证
- 撤销凭证
- 核销渠道
- 券面额/平台实收/数量

本文关注 POS `DwdPay`：

- 云端 `OrderPay(type=COUPON)`
- POS `DwdPay(type=FJ)`
- 结账支付合计
- 防止 POS 云端链路本地二次补 FJ

两份文档共同覆盖完整链路：`DwdCoupon` 负责券凭证和撤销，`DwdPay/FJ` 负责付款方式和平账。

## 9. 验证用例

### 9.1 云端付款测试

场景：小程序实物券抵扣 5 元，会员卡支付 5 元，菜品金额 10 元。

期望：

- 付款成功。
- 云端 `order_pay` 有两条记录：
  - `type=COUPON`，金额 `5`
  - `type=CRM`，金额 `5`
- `doGetOrder.payList` 返回两条记录。
- `payList` 合计金额满足 POS 结账口径。

### 9.2 POS 接单测试

场景：POS 收到云端订单，`payList` 包含 `COUPON=5` 和 `CRM=5`。

期望：

- POS 本地生成或保留 `DwdPay(FJ)=5`。
- POS 本地生成或更新 `DwdPay(HYK)=5`。
- `DwdPay(FJ).deleted=0`。
- 不调用云端付款链路中的本地 `addCoupons(...)` 兜底生成同一条 FJ。
- 结账不再报“应收 10 与实收 5 不等”。

### 9.3 防重复测试

场景：同一 `DO_ORDER/CASH_PAY` 因 MQ 重试重复处理。

期望：

- POS 不重复生成多条相同 FJ。
- 云端不重复生成多条相同 `COUPON` 支付项。
- 重复处理后账单支付合计仍正确。

### 9.4 非实物券订单测试

场景：普通会员卡或微信支付订单，无实物券抵扣。

期望：

- 云端不生成 `COUPON`。
- POS 不生成 FJ。
- 原有支付方式同步逻辑不变。

### 9.5 POS 本地核券链路回归

场景：POS 本地扫码核券或线下结账时已有 `DwdCoupon`，需要本地补 FJ。

期望：

- `OrderServiceUtil.addCoupons(...)` 仍可在本地链路使用。
- 不因为禁用云端付款链路的兜底补 FJ 而影响 POS 本地业务。

## 10. 结论

本问题不是 POS 单纯误删支付方式，也不是 `DwdCoupon` 凭证沉淀问题，而是云端付款明细契约缺失导致的双端规则冲突。

最终处理原则：

1. 云端付款时必须保存实物券 `COUPON` 支付明细。
2. POS 云端付款同步链路不再本地派生同一条 FJ。
3. POS 本地核券/线下结账链路继续保留 `addCoupons(...)`。
4. 不处理历史数据，只保证新订单从付款落库开始数据正确。

修复后，云端 `order_pay`、`doGetOrder.payList`、POS `dwd_pay` 三者对实物券抵扣金额的表达应保持一致，避免再次出现“云端缺 COUPON、POS 本地补 FJ 后又删除、最终账不平”的问题。

---

## 11. 最终落地口径（合并方案，施工依据）

> 本节合并了此前"最小改动版"与"二次评估"的全部正确结论，删除被推翻的错误写法（如"见 COUPON 即跳过"、"派生 COUPON 填 couponNo"）。第 1-10 节的现象、根因、链路分析全部保留。**本节为最终施工依据。**

### 11.1 核心判断

本问题唯一根因是**云端付款时没有生成实物券 `COUPON` 支付明细**。POS 侧"补 FJ / 删多余 FJ"的冲突都是其连锁反应。

已核实的事实：

1. POS `CashPayHandler.checkPays()` 已完整支持云端 `COUPON`：把 `OnlinePayTypeEnum.COUPON` 收为 `couponPays`，逐条建 `DwdPay(type=FJ)`，名称取云端 `OrderPayVO.name`，金额取 `payAmount/amount`，`FJ.actualIncome=false`（不计实收）。
2. 云端 `PayTypeEnum.COUPON(5)` 与 POS `OnlinePayTypeEnum.COUPON → PayWayEnum.FJ` 映射都已存在，无需新增枚举。
3. POS 兜底 `if (dwdPays 为空 && couponAmount>0) addCoupons(...)` 只在"本地完全无 dwd_pay"时触发。云端补齐 `COUPON` 后不再进入"补 FJ 又被删除"的冲突路径。

**结论：只改云端一处即可闭环，POS 端零改动。**

### 11.2 改动范围

- 文件：`nms4cloud-order/.../service/c/order/PayOrderServiceImpl.java`
- 方法：`pay(WrapperDTO<...>)`
- POS 端：**不改动**，仅验证。

### 11.3 关键约束（必须遵守，来自二次评估的真实风险）

以下约束是避免线上事故的硬性要求，已逐条核对代码确认：

1. **不能复用现有普通券 COUPON 分支，不能进入 `couponAmount`。**
   `pay()` 现有 `PayTypeEnum.COUPON` 分支会累加 `couponAmount`，最终 `payNext(..., order.getPaidAmount() - couponAmount)` 把它从有效账单金额再扣一次。实物券抵扣**已经**体现在 `order.paidAmount`（crt_order 已扣）。若派生 COUPON 进入 `couponAmount`，会出现 `validAmount = paidAmount - couponAmount` 二次扣减，导致会员卡/积分实扣金额被清零。
   因此实物券派生 COUPON 必须是**独立补充步骤**：加入最终 `payList`、参与 `sumPayAmount` 校验，但**不进** `couponAmount/couponIdList/couponDTOS`，**不触发** CRM 普通券核销流程。

2. **派生 COUPON 不能填 `couponNo`、不能填 `coupons`（最高优先级约束）。**
   已确认 `OrderPay.couponNo` 是 `Long` 类型；取消订单 `cancel()` 会遍历所有 `OrderPay(type=COUPON)`，把 `couponNo` 加入 `couponIdSet`、把 `coupons` 解析为 `CrmCouponDTO`，然后调用 `cardOpForCustomerFeign.cancelWriteOffCouponInner` 走 **CRM 普通券撤销**。
   实物券/平台券的核销与撤销走的是 crt_order → POS DwdCoupon 链路（见文档 07），与 CRM 普通券撤销完全不同。若派生 COUPON 填了 `couponNo/coupons`，取消订单时会误把实物券/会员券号送进 CRM 撤销（平台券的 `couponWriteOffTraceNo` 字符串键 CRM 更不认识），造成误撤销或报错。
   **因此派生 COUPON 的 `couponNo`、`coupons` 必须保持为空。** 它只用于 POS 平账展示（DwdPay/FJ），不承担任何核销/撤销职责。

3. **幂等按实物券维度判断，不能用"见 COUPON 即跳过"。**
   支付页普通券也是 `type=COUPON`。若用户既用普通券又有实物券，"只要存在 COUPON 就跳过"会漏掉实物券对应的 FJ。应在派生前先判断 payList 中是否已存在**实物券派生的** COUPON（按金额来源 `productCouponItems` 维度），而非全局按 type 跳过。当前实现层面：派生逻辑只读 `order.productCouponItems` 生成，本身只在付款落库时执行一次，配合"按条目生成"即可保证不与支付页普通券混淆。

4. **按 `productCouponItems` 条目逐条生成，不是物理券张数。**
   金额来源 `productCouponItems[].coupon_amt` 是按 `food_lid`（券菜品行）维度写的；平台券 count>1 时该 `coupon_amt` 已是该行总额（与文档 07 修正后的 faceAmount 总额口径一致）。因此"每条 `productCouponItems` 一条 `OrderPay`"是正确量纲，措辞统一为**按条目**而非"每张物理券"。

### 11.4 数据来源与字段口径

数据来源（crt_order 的 `applyProductCouponAccounting` 已写入 `order`）：

```text
productCouponItems[]: { coupon_no, food_lid, coupon_amt }
productItems[]:       { food_lid, food_no, food_name, food_number, food_amt, coupon_amt }
```

注意：`productCouponItems` 自身不含菜名，菜名在 `productItems.food_name`，通过 `food_lid` 关联。

派生 `OrderPay` 字段口径：

| 字段 | 取值 |
|---|---|
| `type` | `PayTypeEnum.COUPON` |
| `name` | 按 `food_lid` 从 `productItems` 取 `food_name`（**与 POS FJ 的 name=菜名对齐**）；缺失兜底"付券" |
| `payAmount` / `amount` | 该条 `coupon_amt`（纯券优惠，不信前端） |
| `isRealIncome` | `false`（券抵扣非实收，对齐 POS FJ `actualIncome=false`） |
| `mid` / `sid` / `saasOrderNo` / `saasOrderKey` / `reportDate` / `checkoutBy` | 与 `order` 一致 |
| `deleted` | `false` |
| `couponNo` | **必须为空**（见 11.3 第 2 条） |
| `coupons` | **必须为空**（见 11.3 第 2 条） |

### 11.5 实现方式（独立方法，不污染普通券链路）

```text
PayOrderServiceImpl.pay()
  1. 保留现有 request.orderPayList -> payList 组装逻辑不变
  2. 在 sumPayAmount 校验之前，调用 appendProductCouponPays(order, payList)
  3. appendProductCouponPays 只读 order.productCouponItems / order.productItems，逐条目追加派生 COUPON
  4. 派生 COUPON 不进入 couponAmount / couponIdList / couponDTOS
  5. 派生 COUPON 不填 couponNo / coupons
  6. 派生 COUPON 计入 sumPayAmount；因 order.paidAmount 是扣券后剩余应付，sumPayAmount >= paidAmount 仍成立，校验安全
```

### 11.6 POS 侧（零改动，仅验证）

云端补 `COUPON` 后验证：

- `doGetOrder.payList` 返回 `COUPON(菜名, 5)` + `CRM(会员卡, 5)`。
- POS `checkPays` 走 couponPays 分支建 `DwdPay(FJ, 菜名, 5, deleted=0)`。
- POS 不再触发"本地补 FJ 后又删除"路径。
- 结账：应收 10 = 实收(CRM 5) + 付券(FJ 5)，不再报"应收 10 与实收 5 不等"。

### 11.7 边界与回归

- 普通订单（无实物券抵扣）：`productCouponItems` 为空，不生成 COUPON，原逻辑零变化。
- 支付页普通券订单：派生逻辑只读 `productCouponItems`，不干扰普通券 `couponAdds/couponNo` 流程。
- 多券订单：按 `productCouponItems` 条目逐条 COUPON，与 POS 逐条建 FJ 对齐。
- 取消订单：派生 COUPON 无 `couponNo/coupons`，不会被 CRM 普通券撤销逻辑消费。
- 不处理历史数据，沿用第 5.4 节口径。

### 11.8 落地清单

- [ ] 云端新增 `appendProductCouponPays(order, payList)`，在 `pay()` 的 `sumPayAmount` 校验前调用。
- [ ] 派生 COUPON：name 取 `productItems.food_name`，金额取 `productCouponItems.coupon_amt`，`isRealIncome=false`，`couponNo/coupons` 留空，不进 `couponAmount`。
- [ ] POS 端不改动。
- [ ] 验证：实物券 5 + 会员卡 5 / 菜品 10：云端 `order_pay` 两条、`doGetOrder.payList` 两条、POS `dwd_pay` 生成 FJ=5 不被删、结账平账。
- [ ] 回归：普通订单、支付页普通券订单、多券订单、取消订单、MQ 重试。
