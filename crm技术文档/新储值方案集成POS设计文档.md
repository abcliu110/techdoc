# 新储值方案集成到 POS 端 — 设计文档

## 背景

老的 POS 充值（`cardCharge`）只支持固定规则（`CrmSaveRule`），不支持新的储值方案（`DepositPlan`）的多档位、赠券（一次性/周期性）、会员升级、积分等能力。

**目标**：在 POS 端新增 `depositPlanCharge` 接口，完整复用老充值的 DwdBill 管道（打印/短信/撤销/支付方式），同时触发新储值方案的全部后置逻辑（发券、升级、积分、销售统计）。**不改动老的 `cardCharge` 方法。**

---

## 一、功能对比：老充值 vs 新储值方案

| 功能 | 老充值 | 新储值方案 |
|---|---|---|
| 会员验证 | `memberCheck` | 同 |
| DwdBill 账单 | ✅ | ✅ 必须保留（打印/报表/撤销依赖） |
| DwdFood 明细 | 每个 rule 一行 | 每个 tier 一行（planName/planLid） |
| 支付方式 | 现金/微信/支付宝/付款码/挂账 | 同 |
| 打印充值单 | `MemberSavingBill` | ✅ 同 |
| 短信通知 | `SMS_CRM_RECHARGE` | ✅ 同 |
| 撤销 | `revokeCharge` | ✅ 入口复用，余额和赠券回滚，升级/积分/统计不回滚 |
| CRM 余额变更 | `CardBalanceService.execute()` | ✅ 同（新接口内部调用） |
| 赠券（一次性/周期性） | ❌ 仅单张 | ✅ CRM 新接口负责 |
| 会员升级/延期 | ❌ | ✅ CRM 新接口负责 |
| 积分发放 | 有限支持 | ✅ CRM 新接口负责 |
| 销售统计 | ❌ | ✅ `updatePlanSoldStats` |
| 购买记录 | ❌ | ✅ `CrmDepositChargeRecord` |

---

## 二、核心设计思路

POS 端新增 `depositPlanCharge` 方法，流程与 `cardCharge` **完全一致**，区别只在：

1. **入参**：`planLid + tierIndex + saveAmount`（saveAmount 仅供 CRM 防篡改校验）替代 `rules`，CRM 最终以 `tier` 主数据为准
2. **结账时**：调 `dealDepositPlanCharge()`（新），而非 `dealCharge()`（旧）
3. **CRM 端**：新增同步接口 `POST /deposit-plan/charge/commitByPos`，内部执行完整的 `onPaymentSuccess` 逻辑

**撤销**：入口复用 `revokeCharge`，余额和未核销赠券会被回滚，其他权益（升级/积分/销售统计）不回滚。

### 路径规范（全文统一）

| 层次 | 路径 |
|---|---|
| CRM Controller `@RequestMapping` | `/deposit-plan/charge` |
| CRM 新接口完整路径 | `POST /deposit-plan/charge/commitByPos` |
| POS Forest `@Post(value=...)` | `/deposit-plan/charge/commitByPos` |
| POS Forest 最终 URL | `${baseUrl}/api/scrm/deposit-plan/charge/commitByPos` |

### 整体调用链

```
POS: depositPlanCharge(DepositPlanChargeExDTO)
  │
  ├─ 1. memberCheck（验证会员）
  ├─ 2. 创建 DwdBill（OrderOpTypeEnum.E）+ DwdFood（1行）
  │       DwdBill.depositPlanLid  = planLid
  │       DwdBill.depositTierIndex = tierIndex
  │       DwdFood.foodNo = -1（非标准规则）
  │       DwdFood.foodName = planName（由 POS 前端传入，仅用于展示/打印）
  │
  └─ 3. DwdBillOpsServiceImpl.checkOut()
          │
          └─ OrderServiceUtil.checkOut()
                │
                ├─ dealDepositPlanCharge()（新，替换 dealCharge）
                │       │
                │       └─ nms4CloudCrmService.depositPlanCharge()
                │               Forest: POST /deposit-plan/charge/commitByPos
                │               │
                │               └─ CRM: commitByPos()
                │                     ├─ [幂等] Redis 锁 + 三态检查
                │                     ├─ 校验方案/档位（以 tier 主数据为准）
                │                     ├─ 校验 saveAmount == tier.saveAmount（防篡改）
                │                     ├─ 创建 CrmDealTask（tradeState=USERPAYING）
                │                     ├─ 创建 CrmDepositChargeRecord
                │                     └─ onPaymentSuccess()
                │                           ├─ CardBalanceService.execute()（余额，含自身幂等）
                │                           ├─ updateChargeRecordSuccess()
                │                           ├─ updatePlanSoldStats()
                │                           ├─ handleGiftIssuance()（发券）
                │                           ├─ handleMemberUpgrade()（升级）
                │                           └─ handlePoints()（积分）
                │
                ├─ checkOutService.normalCheckOut()（CLOSED）
                └─ 打印 MemberSavingBill + 短信 SMS_CRM_RECHARGE

撤销（入口复用，仅回滚余额与赠券）：
revokeCharge(taskLid)
  ├─ revokeInner() → 找 DwdBill（by saasOrderKey）→ revokeBill()（处理退款）
  └─ nms4CloudCrmService.revokeCharge()
        → CRM: /crm_card_op/revokeChargeSign
              ├─ CardBalanceService.execute(revoke=true)（余额反向扣减）
              └─ couponOpRevoke()（作废未核销/已过期券）
              ❌ 不回滚：CrmDepositChargeRecord / 销售统计 / 升级 / 积分
```

---

## 三、改动清单

### CRM 平台侧（nms4cloud）—— 3个文件

#### 1. 新增 DTO：`DepositPlanPosChargeDTO.java`

**路径**：`nms4cloud-crm-api/src/main/java/com/nms4cloud/crm/api/dto/`

```java
public class DepositPlanPosChargeDTO extends CrmCardOpBaseDTO {
    @NotNull  Long planLid;            // 储值方案ID
    @NotNull  Integer tierIndex;       // 档位索引（0起）
    @NotBlank String cardNo;           // 会员卡号
    @NotBlank String orderId;          // POS订单号（= DwdBill.saasOrderKey，作为 outTradeNo）
    @NotNull  BigDecimal saveAmount;   // 本金（仅用于 CRM 侧校验是否与档位一致，最终入账以 tier 为准）
              BigDecimal giftAmount;   // 赠送金额（仅供 POS 请求携带，CRM 忽略，以 tier.giftAmount 为准）
              BigDecimal giftPoints;   // 赠送积分（仅供 POS 请求携带，CRM 忽略，以 tier.giftPoints 为准）
              String operator;         // 操作人
              String payWay;           // 支付方式描述（如"微信支付,现金"）
              Long payWayCode;         // 支付方式编码
              String comment;          // 备注
}
```

> **字段语义说明**：`saveAmount` 由 CRM 侧与 `tier.saveAmount` 比对（防篡改校验），`giftAmount/giftPoints` CRM 侧不使用，最终入账金额和积分一律以 `tier` 主数据为准。`planName` 仅由 POS 用于 `DwdFood.foodName` 展示，不传给 CRM。

#### 2. 修改 `DepositPlanChargeController.java`

**路径**：`nms4cloud-crm-app/.../controller/charge/DepositPlanChargeController.java`

新增接口：

```java
@NeedVerifySignature
@PostMapping(value = "/commitByPos")
public NmsResult<CardBalanceVo> commitByPos(
    @Valid @RequestBody DepositPlanPosChargeDTO request) {
    return depositPlanChargeService.commitByPos(request);
}
```

**完整路由**：`POST /deposit-plan/charge/commitByPos`
**POS Forest 调用路径**：`/deposit-plan/charge/commitByPos`（baseURL 已含 `/api/scrm`，最终为 `${baseUrl}/api/scrm/deposit-plan/charge/commitByPos`）

#### 3. 修改 `DepositPlanChargeService.java`

**路径**：`nms4cloud-crm-service/.../service/charge/DepositPlanChargeService.java`

新增方法 `commitByPos()`，执行流程与事务边界：

```
【事务边界】
阶段1 @Transactional（强一致，失败整体回滚）：
  ├─ 步骤1~3（校验）
  ├─ 步骤4（创建 CrmDealTask）
  └─ 步骤5（创建 CrmDepositChargeRecord）

阶段2 onPaymentSuccess()（CardBalanceService 有独立事务和 Redis 锁）：
  ├─ CardBalanceService.execute()：余额变更，失败则整体报错，阶段1数据保留（task=USERPAYING）
  ├─ updateChargeRecordSuccess() + updatePlanSoldStats()：与余额在同一子事务
  └─ 发券/升级/积分：try-catch 隔离，失败只记日志，不影响余额

【执行流程】
1. [幂等入口] Redis tryLock(key="depositPlan:pos:charge:{orderId}", 30s)
   - 加锁失败 → 返回错误"订单处理中，请勿重复提交"
   - 锁内查 CrmDealTask（by outTradeNo=orderId）：
     · 不存在             → 继续执行（未处理）
     · tradeState=SUCCESS → 直接返回已有 CardBalanceVo（已成功，幂等返回）
     · tradeState=USERPAYING → 返回错误"订单处理中，请稍后查询"（处理中，拒绝重入）

2. 校验储值方案 + 档位
   - 方案存在且已启用
   - 档位索引有效（0 <= tierIndex < tiers.size()）
   - isPlanAvailable()（日期/时段/门店/会员等级）
   - purchaseLimitChecker.check()（购买限制）

3. 校验 saveAmount（防篡改）
   - Assert: request.saveAmount.compareTo(tier.saveAmount) == 0
   - giftAmount/giftPoints：不从 request 取，统一以 tier.giftAmount / tier.giftPoints 为准

4. 查询会员卡（by cardNo → CrmCard）

5. 创建 CrmDealTask
   - tradeState = USERPAYING
   - outTradeNo = request.orderId（= DwdBill.saasOrderKey）
   - principalAmount = tier.saveAmount（tier 主数据）
   - giveAmount     = tier.giftAmount（tier 主数据）
   - givePoint      = tier.giftPoints（tier 主数据）
   - payWay/payWayCode = request 传入
   - saveRule = plan.getName()，saveRuleCode = plan.getLid()

6. 创建 CrmDepositChargeRecord
   - tradeState = USERPAYING，tierSnapshot = JSON.toJSONString(tier)

7. 调用 onPaymentSuccess(task, notifyAttach)
   → 余额变更 + 购买记录更新 + 销售统计 + 发券 + 升级 + 积分

8. 返回 CardBalanceVo
   - outTranNo = task.getLid()（POS 回写 DwdBill.cardTaskLid，用于撤销）
   - balance/principalBalance/giveBalance/pointsBalance
     （从 CardBalanceService.execute() 返回的 CardBalanceVo 中取，非重新查询）
```

> **`buildCardBalanceVo(existing)` 实现说明**：幂等返回时，从已有 `CrmDealTask` 查询关联的 `crm_card_record`（最新一条，`task_lid=existing.lid`），取其 `balance_after/principal_balance_after/give_balance_after/points_balance_after` 字段填充返回值，`outTranNo = existing.getLid()`。

---

### POS 侧（nms4pos）—— 6个文件 + 1个 DDL

#### 4. 新增 DTO：`DepositPlanChargeExDTO.java`（POS 前端请求）

**路径**：`nms4cloud-pos2plugin-api/.../api/dto/member/`

```java
public class DepositPlanChargeExDTO extends BaseDevVO {
    @NotNull  Long mid;
    @NotNull  Long sid;
    @NotBlank String cardNo;          // 会员卡号
    @NotNull  Long planLid;           // 储值方案ID
    @NotNull  Integer tierIndex;      // 档位索引（0起）
    @NotNull  BigDecimal saveAmount;  // 本金
              BigDecimal giftAmount;  // 赠送金额
              BigDecimal giftPoints;  // 赠送积分
              String planName;        // 方案名称（用于 DwdFood.foodName，可选）
              String authNo;          // 付款码（B扫C时使用）
              Long lid;               // 已存在的账单lid（二次提交时传入）
    @NotEmpty List<DwdPayCreateDTO> pays;  // 支付方式列表
}
```

#### 5. 新增 DTO：`DepositPlanPosChargeDTO.java`（POS 调用 CRM 的请求）

**路径**：`nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/`

> **说明**：POS 项目不依赖 CRM API jar，所有 CRM 相关 DTO 均在 POS 侧独立定义（同 `CrmCardOpChargeDTO`、`CrmCardOpBaseDTO` 的做法）。此类在 POS 侧自行维护，字段与 CRM 侧保持一致即可，无需共享。

```java
/** 储值方案充值 POS 请求 DTO（调用 CRM /deposit-plan/charge/commitByPos） */
@Data
@ToString
@Accessors(chain = true)
@EqualsAndHashCode(callSuper = true)
public class DepositPlanPosChargeDTO extends CrmCardOpBaseDTO {
    // CrmCardOpBaseDTO 已含：mid, sid, cardNo, operator, comment 等公共字段

    @NotNull  Long planLid;          // 储值方案ID
    @NotNull  Integer tierIndex;     // 档位索引（0起）
    @NotBlank String orderId;        // POS订单号（= DwdBill.saasOrderKey，作为 CRM outTradeNo）
    @NotNull  BigDecimal saveAmount; // 本金（仅用于 CRM 防篡改校验，实际入账以 tier 主数据为准）
              BigDecimal giftAmount; // 赠送金额（透传，CRM 不使用，以 tier.giftAmount 为准）
              BigDecimal giftPoints; // 赠送积分（透传，CRM 不使用，以 tier.giftPoints 为准）
              String payWay;         // 支付方式描述（如"微信支付:100,现金:50"）
              Long payWayCode;       // 支付方式编码
}

#### 6. 修改 `Nms4CloudCrmService.java`（新增 Forest 接口方法）

**路径**：`nms4cloud-pos2plugin-biz/.../service/member/cloud/Nms4CloudCrmService.java`

```java
/** 储值方案充值（POS专用同步接口） */
@Post(value = "/deposit-plan/charge/commitByPos")
NmsResult<CardBalanceVO> depositPlanCharge(@JSONBody DepositPlanPosChargeDTO request);
```

#### 7. 修改 `DwdBill.java`（新增扩展字段）

**路径**：`nms4cloud-pos2plugin-dal/.../dal/entity/DwdBill.java`

```java
/** 储值方案ID（新储值方案充值时使用，与 depositTierIndex 配套） */
@TableField("deposit_plan_lid")
private Long depositPlanLid;

/** 储值方案档位索引（0起，新储值方案充值时使用） */
@TableField("deposit_tier_index")
private Integer depositTierIndex;
```

**DDL**：
```sql
ALTER TABLE dwd_bill
    ADD COLUMN deposit_plan_lid   BIGINT COMMENT '储值方案ID',
    ADD COLUMN deposit_tier_index INT    COMMENT '储值方案档位索引';
```

#### 8. 修改 `OrderServiceUtil.java`（新增 dealDepositPlanCharge 方法 + checkOut 路由判断）

**路径**：`nms4cloud-pos2plugin-biz/.../service/order/util/OrderServiceUtil.java`

**新增方法**（仿 `dealCharge`，约在 3361 行之后）：

```java
/** 处理储值方案充值（新），仿 dealCharge */
public static void dealDepositPlanCharge(
    DwdBill dwdBill, List<DwdFood> foods, OrderOpTypeEnum orderOpType, BizAdminVO user) {
  if (ObjectUtil.notEqual(orderOpType, OrderOpTypeEnum.E)) return;
  if (Objects.isNull(dwdBill.getDepositPlanLid())) return;

  List<DwdPay> pays = getPays(dwdBill.getMid(), dwdBill.getLid());
  String payWayDesc = CollUtil.isEmpty(pays) ? "柠檬树POS储值"
      : pays.stream()
            .map(i -> String.format("%s:%s", i.getName(), NullSafeUtils.formatZero(i.getAmount())))
            .collect(Collectors.joining(","));

  DepositPlanPosChargeDTO chargeDTO = new DepositPlanPosChargeDTO();
  chargeDTO.setOrderId(dwdBill.getSaasOrderKey());
  chargeDTO.setCardNo(dwdBill.getCardNo());
  chargeDTO.setPlanLid(dwdBill.getDepositPlanLid());
  chargeDTO.setTierIndex(dwdBill.getDepositTierIndex());
  chargeDTO.setSaveAmount(dwdBill.getPaidAmount());
  chargeDTO.setGiftAmount(dwdBill.getSendAmount());
  chargeDTO.setOperator(user.getName());
  chargeDTO.setPayWay(payWayDesc);
  chargeDTO.setComment("柠檬树POS储值方案充值");

  NmsResult<CardBalanceVO> result = nms4CloudCrmService.depositPlanCharge(chargeDTO);
  Assert.isTrue(result.isSuccess(), result.getErrorMessage());

  CardBalanceVO balanceVO = result.getData();
  OrderServiceUtil.forOrderUpdate()
      .set(DwdBill::getCardBalanceAfter,    NullSafeUtils.nullSafe(balanceVO.getBalance()))
      .set(DwdBill::getCardPrincipalAfter,  NullSafeUtils.nullSafe(balanceVO.getPrincipalBalance()))
      .set(DwdBill::getCardGiveAfter,       NullSafeUtils.nullSafe(balanceVO.getGiveBalance()))
      .set(DwdBill::getPoints,              NullSafeUtils.nullSafe(balanceVO.getPoints()))
      .set(DwdBill::getCardPointsAfter,     NullSafeUtils.nullSafe(balanceVO.getPointsBalance()))
      .set(DwdBill::getCardTaskLid,         balanceVO.getOutTranNo())
      .eq(DwdBill::getMid, dwdBill.getMid())
      .eq(DwdBill::getSid, dwdBill.getSid())
      .eq(DwdBill::getLid, dwdBill.getLid())
      .update();
}
```

**修改 `checkOut()` 方法**（在 `dealCharge` 调用前加判断，约 3270 行）：

```java
// 处理充值
if (Objects.nonNull(dwdBill.getDepositPlanLid())) {
    dealDepositPlanCharge(dwdBill, foods, orderOpType, user);  // 新储值方案
} else {
    dealCharge(dwdBill, foods, orderOpType, user);              // 老充值规则（不改动）
}
```

#### 9. 修改 `MemberForBizController.java`（新增 depositPlanCharge 方法）

**路径**：`nms4cloud-pos2plugin-biz/.../controller/biz/MemberForBizController.java`

新增方法（仿 `cardCharge`，建议放在 `cardCharge` 方法之后）：

```java
@ClientOpLog("储值方案充值")
@Operation(summary = "储值方案充值")
@SaBizCheckPermission(
    value = {"member:ops:card:charge", "pos:func:member:charge"},
    mode = SaMode.OR,
    orRole = {RolesConstants.ADMIN, RolesConstants.STORE_ADMIN})
@Idempotent
@PostMapping(value = "/depositPlanCharge")
public NmsResult<CheckOutVO> depositPlanCharge(
    @Valid @RequestBody DepositPlanChargeExDTO request) throws Throwable {

  Long lid = request.getLid();
  String authNo = request.getAuthNo();
  if (StrUtil.isNotBlank(authNo)) {
    Assert.isTrue(Objects.nonNull(lid), "使用付款码支付，充值订单lid不能为空");
  }
  List<DwdPayCreateDTO> pays = request.getPays();
  BizAdminVO user = getBizAdmin();

  if (Objects.isNull(lid)) {
    // ① 验证入参
    Assert.isTrue(CollUtil.isNotEmpty(pays), "支付方式不能为空");
    Assert.isTrue(Objects.nonNull(request.getPlanLid()), "储值方案ID不能为空");
    Assert.isTrue(Objects.nonNull(request.getTierIndex()), "档位索引不能为空");
    Assert.isTrue(Objects.nonNull(request.getSaveAmount())
        && request.getSaveAmount().compareTo(BigDecimal.ZERO) > 0, "储值金额必须大于0");

    // ② 验证会员
    NmsResult<MemberCheckVO> result =
        nms4CloudCrmService.memberCheck(
            new MemberCheckDTO().setCardId(request.getCardNo()).setUseOnlyCard(true));
    Assert.isTrue(result.isSuccess(), result.getErrorMessage());
    MemberCheckVO memberCheckVO = result.getData();

    // ③ 获取营业时段
    BizBusinessHoursVO business =
        OrderServiceUtil.getCurrentBusiness(request.getMid(), request.getSid());
    LocalDateTime startDate = business.getCurrentReportDate().atStartOfDay().with(LocalTime.MIN);
    LocalDateTime endDate = startDate.plusDays(1L).minusSeconds(1);

    // ④ 查找或创建 DwdBill
    DwdBill dwdBill =
        OrderServiceUtil.forOrderQuery()
            .eq(DwdBill::getMid, request.getMid())
            .eq(DwdBill::getSid, request.getSid())
            .between(DwdBill::getReportDate, startDate, endDate)
            .eq(DwdBill::getOrderOpType, OrderOpTypeEnum.E)
            .notIn(DwdBill::getOrderStatus, OrderStatusEnum.CLOSED, OrderStatusEnum.CANCEL)
            .eq(DwdBill::getDeviceCode, request.getDevId())
            .eq(DwdBill::getDepositPlanLid,   request.getPlanLid())    // 按方案区分
            .eq(DwdBill::getDepositTierIndex, request.getTierIndex())   // 同方案不同档位不复用
            .orderByDesc(DwdBill::getLid)
            .onlyOne();

    if (Objects.isNull(dwdBill)) {
      dwdBill = OrderServiceUtil.createFalseBill(
          request.getMid(), request.getSid(), OrderOpTypeEnum.E, business, user);
      String billName = StrUtil.isNotBlank(request.getPlanName())
          ? request.getPlanName() : "储值方案充值单";
      dwdBill.setBillName(billName);
    } else {
      OrderServiceUtil.rmvFoods(dwdBill.getMid(), dwdBill.getLid());
    }

    // ⑤ 设置会员信息
    dwdBill.setCardNo(memberCheckVO.getId());
    dwdBill.setPhone(memberCheckVO.getPhone());
    dwdBill.setMemberName(memberCheckVO.getName());
    dwdBill.setCardTypeLid(memberCheckVO.getCardTypeCode());
    dwdBill.setMemberTypeName(memberCheckVO.getCardType());
    dwdBill.setCardBalanceBefore(memberCheckVO.getBalance());
    dwdBill.setCardPrincipalBefore(memberCheckVO.getPrincipalBalance());
    dwdBill.setCardGiveBefore(memberCheckVO.getGiveBalance());
    dwdBill.setCardPointsBefore(memberCheckVO.getPoints());
    dwdBill.setDeviceCode(request.getDevId());

    // ⑥ 设置储值方案扩展字段
    dwdBill.setDepositPlanLid(request.getPlanLid());
    dwdBill.setDepositTierIndex(request.getTierIndex());

    // ⑦ 计算金额（档位金额由前端传入）
    BigDecimal saveAmount = NullSafeUtils.nullSafe(request.getSaveAmount());
    BigDecimal giftAmount = NullSafeUtils.nullSafe(request.getGiftAmount());
    BigDecimal totalAmount = NumberUtil.add(saveAmount, giftAmount);
    dwdBill.setPaidAmount(saveAmount);
    dwdBill.setReceivableAmount(saveAmount);
    dwdBill.setFoodAmount(totalAmount);
    dwdBill.setSendAmount(giftAmount);
    dwdBill.setBalance(totalAmount);
    dwdBill.setPrincipal(saveAmount);
    dwdBill.setGive(giftAmount);
    dwdBill.setDiscountAmount(giftAmount.negate());
    dwdBill.setPromotionAmount(dwdBill.getDiscountAmount());

    // ⑧ 构建 DwdFood（1行代表该档位）
    // planName 由前端传入，仅用于 DwdFood.foodName 展示和打印；
    // 方案真实名称以 CRM 侧 plan.getName() 为准，不影响入账逻辑。
    String foodName = StrUtil.isNotBlank(request.getPlanName())
        ? request.getPlanName() : String.format("储值方案-档位%d", request.getTierIndex() + 1);
    DwdFood dwdFood = new DwdFood();
    dwdFood.setMid(request.getMid());
    dwdFood.setSid(request.getSid());
    dwdFood.setLid(IdWorkerPlus.getId());
    dwdFood.setFoodNo(-1L);          // -1 表示非标准规则，planLid 存在 DwdBill.depositPlanLid
    dwdFood.setFoodName(foodName);
    dwdFood.setFoodOrgPrice(totalAmount);
    dwdFood.setFoodProPrice(totalAmount);
    dwdFood.setPaidAmount(saveAmount);
    dwdFood.setFoodAmount(totalAmount);
    dwdFood.setSendAmount(giftAmount);
    dwdFood.setDiscountAmount(giftAmount.negate());
    dwdFood.setPromotionAmount(dwdFood.getDiscountAmount());
    dwdFood.setSendNumber(BigDecimal.ONE);
    dwdFood.setFoodNumber(BigDecimal.ONE);
    dwdFood.setCancelNumber(BigDecimal.ZERO);
    dwdFood.setCancelAmount(BigDecimal.ZERO);
    dwdFood.setServiceChargeAmount(BigDecimal.ZERO);
    dwdFood.setProcessingFee(BigDecimal.ZERO);
    dwdFood.setProcessingFeeDiscount(BigDecimal.ZERO);
    dwdFood.setProcessingFeeService(BigDecimal.ZERO);
    dwdFood.setReportDate(dwdBill.getReportDate());
    dwdFood.setYear(dwdBill.getYear());
    dwdFood.setMonth(dwdBill.getMonth());
    dwdFood.setDay(dwdBill.getDay());
    dwdFood.setOrderedTime(LocalDateTime.now());
    dwdFood.setOrderOpType(dwdBill.getOrderOpType());
    dwdFood.setOrderStatus(OrderStatusEnum.UNSETTLED);
    dwdFood.setSaasOrderNo(dwdBill.getLid());

    // ⑨ 保存账单和明细
    String lockKey = String.format("order::%s:lock", OrderOpTypeEnum.P);
    LockServiceUtil lockServiceUtil = SpringUtil.getBean(LockServiceUtil.class);
    List<DwdFood> dwdFoods = List.of(dwdFood);
    if (Objects.isNull(dwdBill.getPid())) {
      DwdBill finalDwdBill = dwdBill;
      lockServiceUtil.run(() -> {
        finalDwdBill.setSaasOrderKey(
            OrderServiceUtil.genOrderId(
                request.getMid(), request.getSid(),
                finalDwdBill.getReportDate().toLocalDate(), OrderOpTypeEnum.E));
        finalDwdBill.setSaasOrderNo(finalDwdBill.getLid());
        OrderServiceUtil.insertBill(finalDwdBill);
        OrderServiceUtil.insertFoods(dwdFoods);
      }, lockKey);
    } else {
      // 更新已有账单金额和方案信息
      OrderServiceUtil.forOrderUpdate()
          .set(DwdBill::getCardNo,            dwdBill.getCardNo())
          .set(DwdBill::getMemberName,        dwdBill.getMemberName())
          .set(DwdBill::getDepositPlanLid,    dwdBill.getDepositPlanLid())
          .set(DwdBill::getDepositTierIndex,  dwdBill.getDepositTierIndex())
          .set(DwdBill::getPaidAmount,        dwdBill.getPaidAmount())
          .set(DwdBill::getSendAmount,        dwdBill.getSendAmount())
          .set(DwdBill::getFoodAmount,        dwdBill.getFoodAmount())
          // ... 其余金额字段同 cardCharge
          .eq(DwdBill::getMid, request.getMid())
          .eq(DwdBill::getSid, request.getSid())
          .eq(DwdBill::getLid, dwdBill.getLid())
          .update();
      OrderServiceUtil.insertFoods(dwdFoods);
    }
    lid = dwdBill.getLid();
  }

  // ⑩ 结账（复用完整的 checkOut 管道）
  DwdBillCheckOutDTO dwdBillCheckOutDTO = new DwdBillCheckOutDTO();
  dwdBillCheckOutDTO.setMid(request.getMid());
  dwdBillCheckOutDTO.setSid(request.getSid());
  dwdBillCheckOutDTO.setLid(lid);
  dwdBillCheckOutDTO.setAuthNo(authNo);
  dwdBillCheckOutDTO.setDevId(request.getDevId());
  dwdBillCheckOutDTO.setPays(pays);
  dwdBillCheckOutDTO.setCheckType(CheckTypeEnum.N);
  return NmsResult.data(dwdBillOpsService.checkOut(dwdBillCheckOutDTO, user));
}
```

---

## 四、文件改动汇总

> **实现状态**：✅ 已完成编码（2026-04-10）

### CRM 侧（nms4cloud）

| 文件 | 改动类型 | 状态 | 完整路径 |
|---|---|---|---|
| `DepositPlanPosChargeDTO.java` | **新增** | ✅ | `nms4cloud-crm-api/.../crm/api/dto/DepositPlanPosChargeDTO.java` |
| `DepositPlanChargeController.java` | **修改** | ✅ | `nms4cloud-crm-app/.../crm/app/controller/charge/DepositPlanChargeController.java` |
| `DepositPlanChargeService.java` | **修改** | ✅ | `nms4cloud-crm-service/.../crm/service/charge/DepositPlanChargeService.java` |

**Controller 新增**：`POST /deposit-plan/charge/commitByPos`（加 `@NeedVerifySignature`）

**Service 新增方法**：
- `commitByPos(DepositPlanPosChargeDTO)` — 幂等三态 + 防篡改校验 + 同步调 `onPaymentSuccess`，Redis 锁 key = `depositPlan:pos:charge:{orderId}`
- `buildCardBalanceVo(CrmDealTask)` — 查 `crm_card` 当前余额构建返回 VO

### POS 侧（nms4pos）

| 文件 | 改动类型 | 状态 | 完整路径 |
|---|---|---|---|
| `DepositPlanChargeExDTO.java` | **新增** | ✅ | `nms4cloud-pos2plugin-api/.../pos2plugin/api/dto/member/DepositPlanChargeExDTO.java` |
| `DepositPlanPosChargeDTO.java` | **新增** | ✅ | `nms4cloud-pos2plugin-api/.../pos2plugin/api/dto/member/DepositPlanPosChargeDTO.java` |
| `Nms4CloudCrmService.java` | **修改** | ✅ | `nms4cloud-pos2plugin-biz/.../pos2plugin/service/member/cloud/Nms4CloudCrmService.java` |
| `DwdBill.java` | **修改** | ✅ | `nms4cloud-pos2plugin-dal/.../pos2plugin/dal/entity/DwdBill.java` |
| `OrderServiceUtil.java` | **修改** | ✅ | `nms4cloud-pos2plugin-biz/.../pos2plugin/util/OrderServiceUtil.java` |
| `MemberForBizController.java` | **修改** | ✅ | `nms4cloud-pos2plugin-biz/.../pos2plugin/controller/biz/MemberForBizController.java` |
| `dwd_bill` 表（DDL） | **DDL** | ⬜ 待执行 | 见下方 SQL |

**DDL（上线前必须执行）**：
```sql
ALTER TABLE dwd_bill
    ADD COLUMN deposit_plan_lid   BIGINT COMMENT '储值方案ID',
    ADD COLUMN deposit_tier_index INT    COMMENT '储值方案档位索引';
```

**OrderServiceUtil 关键改动**：
- `dealCharge()` 头部加路由判断：`depositPlanLid != null` → 调 `dealDepositPlanCharge()`
- 新增 `dealDepositPlanCharge()` 方法（第 3368 行）

**不改动**：`cardCharge`、`revokeCharge`、`DwdBillOpsServiceImpl`、`CheckOutServiceImpl`、打印/短信逻辑。

---

## 五、撤销流程——入口复用，仅回滚余额与赠券，不回滚其他权益

**撤销入口**：复用 `revokeCharge()`，入参、权限、POS 侧账单处理完全不变。

**CRM 侧执行链**：
```
nms4CloudCrmService.revokeCharge() → /crm_card_op/revokeChargeSign
  └─ CrmCardOpServicePlus.revokeCharge()
        ├─ CardBalanceService.execute(..., revoke=true)   → 余额反向扣减
        └─ CompletableFuture.runAsync(dealOtherItemTaskCancel)
              └─ couponOpRevoke()  → 将 orderBillId=task.lid 的未核销/已过期券改为 YZF（已作废）
```

**回滚范围**：

| 项目 | 是否回滚 | 说明 |
|---|---|---|
| 会员卡余额 | ✅ | 反向入账，余额减回 |
| 赠券（未核销/已过期） | ✅ | `couponOpRevoke` 按 `orderBillId` 作废，与老充值完全一致 |
| 已核销的券 | ❌ | 已使用不回收（老充值同样不处理） |
| `CrmDepositChargeRecord` 状态 | ❌ | 仍为 SUCCESS（新增场景，后续补） |
| 销售统计（`total_sold_count`） | ❌ | 不回减（新增场景，后续补） |
| 会员等级升级 | ❌ | 不降级（老充值同样不处理） |
| 积分 | ❌ | 不扣回（老充值同样不处理） |

**余额和赠券的回滚行为与老充值完全一致**，不需要额外产品确认。`CrmDepositChargeRecord` 和销售统计的回滚属于新增场景，统计偏差可接受，不阻塞上线，后续补充。

---

## 六、风险、边界与待闭环事项

### 风险 1：`commitByPos` 幂等——"先查后写"并发仍可超卖

**问题**：原 `onPaymentSuccess` 由 MQ 消费者调用，有天然幂等保护（Redis key + `tradeState` 检查）。`commitByPos` 改为同步直调，"先查 outTradeNo 是否存在、再执行写入"的模式在并发重试下仍有窗口期，同一笔订单可能两次进入写入阶段，导致余额双倍入账或购买限制超卖。

**已有能力分析**：
- `CardBalanceService.execute()` 内部有 Redis 分布式锁（per cardLid）+ `tradeState` 幂等检查，**余额层面已防重**。
- 但 `updatePlanSoldStats`（销售统计原子自增）、`createChargeRecord`（购买记录插入）、`purchaseLimitChecker.check()`（购买限制校验）**均无并发保护**，仍是"先查后写"。

**幂等三态处理**：

| 状态 | 判断条件 | 返回行为 |
|---|---|---|
| **未处理**（首次请求） | `outTradeNo` 对应的 `CrmDealTask` 不存在 | 正常执行完整流程 |
| **处理中**（并发/崩溃恢复） | `CrmDealTask` 存在且 `tradeState = USERPAYING` | 返回错误"订单处理中，请稍后查询结果"，不重复执行 |
| **已成功**（POS 超时重试） | `CrmDealTask` 存在且 `tradeState = SUCCESS` | 幂等返回已有的 `CardBalanceVo`，不重复执行 |

**处理方案**：在 `commitByPos` 入口加 Redis 分布式锁（per `orderId`）+ 三态检查：

```java
String lockKey = "depositPlan:pos:charge:" + request.getOrderId();
boolean locked = redisLock.tryLock(lockKey, 30, TimeUnit.SECONDS);
Assert.isTrue(locked, "订单正在处理中，请勿重复提交");
try {
    CrmDealTask existing = queryByOutTradeNo(request.getMid(), request.getOrderId());
    if (existing != null) {
        if (TradeStateEnum.SUCCESS.equals(existing.getTradeState())) {
            return buildCardBalanceVo(existing);   // 已成功：幂等返回
        }
        throw new BizException("订单处理中，请稍后查询结果");  // 处理中：拒绝重入
    }
    // 未处理：正常执行
    // ...
} finally {
    redisLock.unlock(lockKey);
}
```

**购买限制校验**：`purchaseLimitChecker.check()` 的"先查后写"问题建议在写入 `CrmDepositChargeRecord` 时加唯一索引（`mid + card_lid + plan_lid + trade_state=SUCCESS` 维度的计数），或接受极低概率的超卖（取决于业务容忍度）。

---

### 风险 2：撤销边界——赠券实际上会被撤销

**老充值撤销的实际行为**：撤销走 `revokeChargeSign` → `CardBalanceService.cancelOrder()` → 异步执行 `dealOtherItemTaskCancel()` → `couponOpRevoke()`，**将该订单发出的未核销（WHX）/已过期（YGQ）券状态改为 YZF（已作废）**。

**关联机制**：发券时 `CrmCouponOrder.orderBillId = task.getLid()`，撤销时按同一 `orderBillId` 查找并作废。

**新储值方案是否能复用此逻辑**：已确认 ✅

| 条件 | 新储值方案 | 结论 |
|---|---|---|
| `dealOtherItemTaskCancel` 触发条件：`task.saveRuleCode != null` | `DepositPlanChargeService.createDealTask()` 设置了 `saveRuleCode = plan.getLid()` | ✅ 能触发 |
| 发券时 `CrmCouponOrder.orderBillId` 值 | `DepositPlanCouponService.issueCoupons()` 设置 `orderId = task.getLid()` | ✅ 与撤销时匹配 |

**结论：新储值方案的赠券撤销与老充值行为完全一致，不需要额外实现，也不需要产品单独确认。**

**撤销完整性更新：**

| 项目 | 是否回滚 | 说明 |
|---|---|---|
| 会员卡余额 | ✅ | `revokeChargeSign` → `CardBalanceService` 反向操作 |
| 赠券（未核销/已过期） | ✅ | `dealOtherItemTaskCancel` 异步作废，与老充值一致 |
| 已核销的券 | ❌ | 已使用的券不回收（老充值同样不处理） |
| `CrmDepositChargeRecord` 状态 | ❌ | 仍为 SUCCESS（老充值无此表，新增场景） |
| 销售统计（`total_sold_count`） | ❌ | 不回减（老充值无此表，新增场景） |
| 会员等级升级 | ❌ | 不降级（老充值同样不处理） |
| 积分 | ❌ | 不扣回（老充值同样不处理） |

**需要额外处理的仅两项**（新储值方案特有）：`CrmDepositChargeRecord` 状态回滚 + 销售统计回减。建议在 `revokeChargeSign` CRM 侧增加对这两项的处理，**但不阻塞上线**（统计偏差可接受，后续补）。

---

### 风险 3：`DwdFood.foodNo` 语义污染

**问题**：原设计将 `planLid` 塞入 `DwdFood.foodNo`。老系统中 `foodNo` 指向 `crm_save_rule.lid`，报表 JOIN、打印模板、数据分析可能假设 `foodNo` 是规则ID，混入 `planLid` 会造成数据异常。

**修正方案**：

- `DwdFood.foodNo` 置为 `-1`（与普通充值的"自定义充值"保持一致，语义为"非标准规则"）
- `DwdFood.foodName` 存方案名称（如"黄金会员方案-档位1"），供打印和展示使用
- `planLid` 只存在 `DwdBill.depositPlanLid`，不污染 `DwdFood`

```java
dwdFood.setFoodNo(-1L);    // -1 表示非标准规则，与普通充值一致
dwdFood.setFoodName(foodName);
```

---

### 风险 4：`commitByPos` 异常与事务边界

**场景**：`commitByPos` 在 `onPaymentSuccess()` 执行中途失败（如发券异常、网络超时），此时：
- `CrmDealTask` 可能已创建（USERPAYING）
- `CrmDepositChargeRecord` 可能已创建
- 余额可能已变更（`CardBalanceService.execute()` 内有独立事务）
- POS 侧 `DwdBill` 已 CLOSED（POS 事务独立）

**当前 `onPaymentSuccess` 的异常处理**（已有代码）：赠品发放异常只记日志、不回滚余额——余额变更是核心，赠品失败不影响充值成功。这个策略沿用到 `commitByPos` 是合适的。

**需要明确的事务边界**：

```
commitByPos() 事务划分：
  ├─ 阶段1（强一致）：创建 CrmDealTask + CrmDepositChargeRecord，@Transactional
  └─ 阶段2：调用 onPaymentSuccess()
        ├─ CardBalanceService.execute()（有独立 Redis 锁 + 自己的事务）→ 失败则整体报错
        ├─ updateChargeRecordSuccess() + updatePlanSoldStats()（与余额同事务）
        └─ 发券/升级/积分（try-catch，失败只记日志，不影响余额）
```

**补偿方案**（POS 侧 DwdBill 已建但 CRM 未成功）：

| 场景 | 现象 | 处理 |
|---|---|---|
| `commitByPos` 超时，CRM 实际已成功 | POS 报错，DwdBill 状态未知 | 重试时幂等锁返回已有结果；POS 查 `DwdBill` 状态修复 |
| `commitByPos` 失败，CRM 未执行 | POS 报错，DwdBill=CLOSED 但 cardTaskLid 为空 | 运营后台查 `dwd_bill.card_task_lid IS NULL AND deposit_plan_lid IS NOT NULL` 识别异常单，人工补偿或重新触发 |
| `commitByPos` 成功，发券失败 | 余额已入账，券未发 | CRM 告警日志捞出，人工补发券（现有运营能力） |

---

### 风险 5：POS 侧账单复用条件缺 `tierIndex`

**问题**：当前查找未关闭账单的条件是：

```java
.eq(DwdBill::getDepositPlanLid, request.getPlanLid())
```

若同一设备同一班次对同一方案的不同档位各充一次，第二次会复用第一次的账单（档位不同但 planLid 相同），导致档位覆盖。

**修正**：查询条件加上 `tierIndex`：

```java
.eq(DwdBill::getDepositPlanLid,   request.getPlanLid())
.eq(DwdBill::getDepositTierIndex, request.getTierIndex())
```

---

### 风险 6：CRM 侧不信任前端传入的 `giftAmount/giftPoints`

**问题**：前端传入 `giftAmount/giftPoints`，CRM 只校验了 `saveAmount`，赠金/积分未校验，可能被篡改。

**修正**：`commitByPos` 中一律以档位配置为准，忽略前端传入的赠金/积分：

```java
// 不信任前端传入的 giftAmount/giftPoints，统一以 tier 覆盖
BigDecimal saveAmount = tier.getSaveAmount();           // 校验：request.saveAmount == tier.saveAmount
BigDecimal giftAmount = NullSafeUtils.nullSafe(tier.getGiftAmount());   // 以档位为准
BigDecimal giftPoints = NullSafeUtils.nullSafe(tier.getGiftPoints());   // 以档位为准
```

前端传入的 `giftAmount/giftPoints` 仅用于 POS 本地展示（`DwdBill.sendAmount`），不影响 CRM 实际入账金额。

---

### 待补充（上线前必须闭环）

| 事项 | 负责方 | 状态 |
|---|---|---|
| `commitByPos` 成功率监控告警 | 后端 | ✅ 已明确方案（见下） |
| 重复提交命中率统计（幂等锁命中日志） | 后端 | ✅ 已明确方案（见下） |
| 异常单监控：`dwd_bill.card_task_lid IS NULL AND deposit_plan_lid IS NOT NULL` | 运维 | ✅ 已明确方案（见下） |
| 灰度策略：哪些门店先开放，异常如何回切 | 运维/产品 | ⬜ 待规划 |
| CRM `revokeChargeSign` 侧补充对 `CrmDepositChargeRecord` 状态和销售统计的回滚（不阻塞上线） | 后端 | ⬜ 待排期 |

#### 监控方案详述

**① `commitByPos` 成功率监控告警**

在 `DepositPlanChargeService.commitByPos()` 入口和异常处打日志，用现有日志平台（ELK/Loki）按接口路径统计错误率，配告警阈值：

```java
// 入口
log.info("[depositPlan][commitByPos] start, mid={}, orderId={}", request.getMid(), request.getOrderId());
// 成功
log.info("[depositPlan][commitByPos] success, mid={}, orderId={}, taskLid={}", ...);
// 异常（已有 @ControllerAdvice 全局捕获，额外在业务层加）
log.error("[depositPlan][commitByPos] failed, mid={}, orderId={}, error={}", ..., e.getMessage());
```

日志平台告警规则：`[depositPlan][commitByPos] failed` 在 5 分钟内出现超过 N 次则触发告警。

---

**② 幂等锁命中日志（重复提交统计）**

在三态判断的每个分支加一行 `log.info`，日志平台统计关键字频率：

```java
CrmDealTask existing = queryByOutTradeNo(request.getMid(), request.getOrderId());
if (existing != null) {
    if (TradeStateEnum.SUCCESS.equals(existing.getTradeState())) {
        log.info("[depositPlan][commitByPos] idempotent-hit SUCCESS, orderId={}", request.getOrderId());
        return buildCardBalanceVo(existing);
    }
    log.warn("[depositPlan][commitByPos] idempotent-hit USERPAYING, orderId={}", request.getOrderId());
    throw new BizException("订单处理中，请勿重复提交");
}
log.info("[depositPlan][commitByPos] idempotent-miss, orderId={}", request.getOrderId());
```

---

**③ 异常单监控 SQL**

结账成功后 `card_task_lid` 应有值；若为空说明 CRM 调用失败但 POS 账单未回滚，需人工介入：

```sql
-- 每日巡检或加入数据库定时任务
SELECT lid, mid, sid, saas_order_key, deposit_plan_lid, order_status, create_time
FROM dwd_bill
WHERE deposit_plan_lid IS NOT NULL
  AND card_task_lid IS NULL
  AND order_status NOT IN ('CANCEL')
  AND create_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY create_time DESC;
```

加入现有的巡检 SQL 集合或 DBA 定时告警任务即可，无需新增代码。

---

## 七、验证方式

### 1. CRM 侧接口测试

```
POST ${baseUrl}/api/scrm/deposit-plan/charge/commitByPos
{
  "planLid": xxx,
  "tierIndex": 0,
  "cardNo": "xxx",
  "orderId": "E2024xxxx",
  "saveAmount": 100,
  "giftAmount": 20,
  "operator": "测试员"
}
```

验证点：
- `crm_deal_task`：记录存在，`trade_state = SUCCESS`
- `crm_deposit_charge_record`：记录存在，`trade_state = SUCCESS`
- `crm_card`：`balance` 增加 120，`principal_balance` 增加 100，`give_balance` 增加 20
- `crm_coupon_order`：有赠券记录（如档位配置了赠券）

### 2. POS 侧接口测试

```
POST /merchant/member_ops/depositPlanCharge
{
  "mid": xxx, "sid": xxx,
  "cardNo": "xxx",
  "planLid": xxx,
  "tierIndex": 0,
  "saveAmount": 100,
  "giftAmount": 20,
  "planName": "黄金会员方案",
  "pays": [{"type": "FX", "amount": 100}],
  "devId": "xxx"
}
```

验证点：
- `dwd_bill`：`order_status = CLOSED`，`card_task_lid` 有值，`deposit_plan_lid` 有值
- `dwd_food`：1行，`food_no = -1`，`food_name` = 方案名称
- 打印任务生成（`MemberSavingBill`）
- 短信发送（`SMS_CRM_RECHARGE`）

### 3. 撤销测试

```
POST /merchant/member_ops/revokeCharge
{
  "taskLid": DwdBill.cardTaskLid的值
}
```

验证点：
- `dwd_bill`：`order_status = CANCEL`
- `crm_card`：余额正确扣减
