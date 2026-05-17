# POS 本地积分计算接入方案

更新时间：2026-05-06

## 1. 结论

积分权益规则已经同步到 POS 本地后，消费赠送积分应由 POS 本地计算。CRM 不再提供消费积分计算结果，只负责以下能力：

- 维护 `crm_points_rule` 规则。
- 将规则同步到 POS 本地。
- 执行会员储值扣款。
- 接收 POS 已计算出的赠送积分并完成积分余额、积分流水入账。

统一计算时机：

```text
所有支付结果确定之后，订单最终结账落库之前，统一计算本单赠送积分
```

统一计算金额：

```text
可积分金额 = 非会员储值实付金额 + 会员储值实际本金扣款金额
```

会员储值支付不能提前计算积分，因为只有 `cardConsume` 扣款完成后，CRM 才能返回本次实际扣了多少本金、多少赠送。隐藏规则是：会员储值消费按账单积分时，只对本金扣款金额积分，赠送余额扣款不积分。

## 2. 当前代码事实

### 2.1 POS 现状

POS 已经具备 `crm_points_rule` 本地镜像和同步链路，但消费结账主链路还没有接入自动赠分计算。

当前 `OrderServiceUtil.dealCard` 的会员卡消费逻辑只做以下事情：

- 构造 `CrmCardOpConsumeDTO`。
- 设置 `amount`、`billAmount`、`onlyPrincipal`、`cardNo`、`orderId` 等字段。
- 调用 CRM `cardConsume` 或 `cardRepay`。
- 根据 CRM 返回的 `CardBalanceVO` 更新 POS 账单和支付记录。

当前没有做的事情：

- 没有读取 POS 本地 `crm_points_rule`。
- 没有计算 `givePoint`。
- 没有调用 `CrmCardOpConsumeDTO.setGivePoint(...)`。
- 没有消费后补记积分。

### 2.2 CRM 现状

CRM 已具备积分账务落账能力。`CardBalanceService` 会使用 `CrmDealTask.givePoint` 生成积分流水并更新会员卡积分余额。

但 CRM 当前消费扣款逻辑不负责按 `crm_points_rule` 自动计算赠送积分。也就是说：

- 上游传入 `givePoint`，CRM 可以入账。
- 上游不传 `givePoint`，本次消费赠分就是 `0`。

CRM 中已有 `PointsEarnService` 和 `/crm_points_earn/calculate`，但 POS 不应调用这个云端计算接口。POS 已经有本地规则数据，应在本地完成计算。

## 3. 云端和 POS 职责边界

| 模块 | 职责 |
|---|---|
| CRM 后台 | 维护积分权益规则 |
| CRM 同步接口 | 按商户维度下发 `crm_points_rule` 到 POS |
| POS 本地 | 根据本地规则、会员、支付结果计算 `givePoint` |
| CRM 会员储值 | 执行 `cardConsume`，返回实际本金/赠送扣款拆分 |
| CRM 积分账务 | 接收 POS 计算结果，更新会员积分余额和积分流水 |

注意：这里不要求 CRM 云端计算积分，只要求 CRM 提供“消费后补记积分”的入账能力。

## 4. 计算时机

不再采用“调用 `cardConsume` 前计算积分”的方式。正确流程如下：

```text
1. POS 完成订单金额计算
2. POS 识别会员身份和支付方式
3. POS 处理非会员储值支付金额
4. 如果存在会员储值支付，先调用 CRM cardConsume
5. CRM 返回 CardBalanceVO.principalAmount / giveAmount
6. POS 汇总可积分金额
7. POS 读取本地 crm_points_rule 并计算 givePoint
8. POS 调用 CRM 消费后补记积分接口
9. POS 继续订单最终结账落库
```

这样处理后，纯微信/支付宝/现金支付和会员储值混合支付都使用同一个计算入口，不会出现部分提前算、部分延后算导致的重复或漏算。

## 5. 可积分金额规则

### 5.1 参与积分的金额

参与积分：

- 现金实付金额。
- 微信实付金额。
- 支付宝实付金额。
- 其他真实收款方式实付金额。
- 会员储值实际本金扣款金额。

不参与积分：

- 会员储值赠送余额扣款金额。
- 积分抵现 `PR`。
- 优惠券抵扣金额。
- 抹零金额。
- 赠送菜金额。
- 充值、还款、退款、反结账。

### 5.2 会员储值支付

会员储值支付必须使用 CRM 扣款后的实际拆分结果：

```java
BigDecimal memberPrincipalAmount = cardBalanceVO.getPrincipalAmount();
BigDecimal memberGiftAmount = cardBalanceVO.getGiveAmount();
```

积分只使用 `memberPrincipalAmount`。

示例：

| 支付组合 | CRM 返回 | 可积分金额 |
|---|---|---|
| 微信 100 | 无会员储值 | 100 |
| 会员储值 100 | 本金 70，赠送 30 | 70 |
| 微信 50 + 会员储值 50 | 储值本金 30，赠送 20 | 80 |
| 积分抵现 20 + 微信 80 | 无会员储值 | 80 |
| 会员储值 100 | 本金 0，赠送 100 | 0 |

## 6. POS 实现方案

### 6.1 新增本地积分计算服务

建议新增服务：

```text
nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/points/CrmPointsEarnLocalService.java
```

核心职责：

- 查询 POS 本地 `crm_points_rule`。
- 按 `mid + planLid` 匹配唯一规则，不使用 `sid`。
- 解析规则中的 JSON 字段。
- 根据会员等级、当前时间、订单渠道、可积分金额计算 `givePoint`。

建议方法：

```java
public BigDecimal calculate(
    DwdBill bill,
    MemberCheckVO member,
    BigDecimal eligibleAmount,
    Integer orderChannel)
```

关键取值：

| 字段 | 来源 |
|---|---|
| `mid` | `DwdBill.mid` |
| `planLid` | `MemberCheckVO.cardTypeCode` |
| `memberLevelId` | `MemberCheckVO.cardTypeLevelCode` |
| `birthday` | `MemberCheckVO.birthday` |
| `eligibleAmount` | 非储值实付 + 储值本金 |
| `orderChannel` | POS 固定为 `1` |

规则查询：

```text
where mid = ? and plan_lid = ?
```

不使用 `sid`，因为积分权益规则当前按 `mid + planLid` 唯一。

### 6.2 计算规则

本轮只实现 `BY_PAYMENT`。

基础公式：

```text
basePoints = eligibleAmount / consumeAmount * earnPoints
```

处理顺序：

1. 规则不存在，返回 `0`。
2. 积分规则总开关关闭，返回 `0`。
3. 消费送积分关闭，返回 `0`。
4. 可积分金额小于等于 `0`，返回 `0`。
5. 会员等级未匹配，返回 `0`。
6. 当前日期不满足可用周期，返回 `0`。
7. 当前时间不满足可用时段，返回 `0`。
8. 按 `eligibleAmount / consumeAmount * earnPoints` 计算基础积分。
9. 生日倍率生效时乘生日倍率。
10. 会员日倍率生效时乘会员日倍率。
11. 单笔获取上限生效时封顶。
12. 最终积分向下取整。

补充说明（2026-05-06）：

- POS 本地消费赠分计算已不再按 `orderChannelLimit` 做拦截判断。
- POS 本地消费赠分计算已不再按 `earningMode` 分支拒绝计算；当前前端口径固定为“按支付方式实收积分”，POS 直接按现行金额口径参与计算。
- `earningProductScopeType`、`earningSpecifiedProductLids` 相关“按商品实收积分”字段仍保留同步兼容，但当前 POS 本地计算不再依赖这些字段做执行分支。

### 6.3 JSON 字段解析

POS 本地 `CrmPointsRule` 中多值字段为 JSON 字符串，需要在本地计算服务中解析。

需要解析的字段包括：

- `levelRates`
- `memberDayDaysOfWeek`
- `memberDayDaysOfMonth`
- `availableDaysOfWeek`
- `availableDaysOfMonth`
- `availableTimeSlots`

解析失败时不应中断结账主流程，建议记录日志并返回 `0`，避免错误赠分。

### 6.4 调整会员卡消费返回值

当前 `OrderServiceUtil.dealCard(...)` 只返回 `MemberCheckVO`，不方便后续拿到本次储值本金扣款金额。

建议新增结果对象：

```java
public class CardConsumeResult {
  private MemberCheckVO member;
  private CardBalanceVO cardBalance;
}
```

并将会员卡消费处理调整为返回该对象。

如果为了降低改动面，也可以保留原方法，新增一个方法：

```java
public static CardConsumeResult dealCardWithBalance(
    Map<PayWayEnum, DwdPay> types,
    DwdBill dwdBill,
    DwdBillCheckOutDTO request)
```

老方法继续给旧调用方使用，新方法给积分计算链路使用。

### 6.5 汇总可积分金额

建议新增工具方法：

```java
public BigDecimal calculateEligibleAmount(
    Map<PayWayEnum, DwdPay> types,
    CardBalanceVO cardBalance)
```

逻辑：

```text
eligibleAmount = 0

遍历支付方式：
  如果是 HYK，跳过，后面用 cardBalance.principalAmount
  如果是 PR，跳过
  如果是优惠券/非真实收入/抹零，跳过
  其他真实收款方式，累加 dwdPay.amount

如果 cardBalance 不为空：
  eligibleAmount += cardBalance.principalAmount
```

注意：不能直接使用 `DwdBill.paidAmount`，否则会把会员储值赠送余额也算进去。

### 6.6 POS 主链路接入点

建议在 POS 订单结账主链路中，所有支付结果确定后、最终 `checkOut` 落库前加入积分计算。

伪代码：

```java
CardConsumeResult cardResult = null;
MemberCheckVO member = null;

if (types.containsKey(PayWayEnum.HYK)) {
  cardResult = OrderServiceUtil.dealCardWithBalance(types, dwdBill, request);
  member = cardResult.getMember();
} else {
  member = OrderServiceUtil.getMemberIfOrderHasMember(dwdBill, request);
}

BigDecimal eligibleAmount =
    pointsEarnLocalService.calculateEligibleAmount(types, cardResult == null ? null : cardResult.getCardBalance());

BigDecimal givePoint =
    pointsEarnLocalService.calculate(dwdBill, member, eligibleAmount, 1);

if (givePoint.compareTo(BigDecimal.ZERO) > 0 && cardResult != null) {
  crmPointsGrantService.grantConsumePoints(dwdBill, member, cardResult.getCardBalance(), givePoint);
}
```

如果本单没有会员身份，则不计算赠分。

## 7. CRM 实现方案

### 7.1 新增消费后补记积分接口

建议新增接口：

```text
POST /crm_card_op/grantConsumePoints
```

该接口只负责入账，不负责计算。

入参建议：

```java
public class GrantConsumePointsDTO {
  private Long mid;
  private Long sid;
  private String cardNo;
  private Long cardTaskLid;
  private String orderId;
  private BigDecimal givePoint;
  private String operator;
  private String comment;
}
```

字段说明：

| 字段 | 说明 |
|---|---|
| `cardTaskLid` | 会员储值消费任务号，作为幂等主键 |
| `orderId` | POS 订单号或云端订单号 |
| `cardNo` | 会员卡号 |
| `givePoint` | POS 本地计算出的赠送积分 |
| `operator` | 操作人 |
| `comment` | 备注 |

### 7.2 CRM 入账逻辑

接口处理流程：

1. 校验 `givePoint > 0`。
2. 根据 `cardTaskLid` 查询 `CrmDealTask`。
3. 校验任务存在，且 `cardNo/orderId` 与请求匹配。
4. 判断是否已经补记过积分。
5. 未补记时更新 `CrmDealTask.givePoint`。
6. 增加会员卡积分余额。
7. 生成 `crm_card_points_record`。
8. 返回成功。

### 7.3 幂等规则

同一个 `cardTaskLid` 只能补记一次。

推荐幂等判断：

```text
如果 CrmDealTask.givePoint > 0，直接返回成功
如果已存在同 cardTaskLid/orderId 的消费赠分流水，直接返回成功
否则执行补记
```

幂等的目标是：POS 因网络异常重试时，不会重复增加会员积分。

### 7.4 失败处理

如果会员储值扣款成功，但补记积分失败，不能静默丢失。

POS 应记录：

- `cardTaskLid`
- `orderId`
- `givePoint`
- 失败原因
- 重试状态

后续可按 `cardTaskLid` 重新调用补记接口，依赖 CRM 幂等保护。

## 8. 小程序接入差异

小程序如果没有会员储值支付，可以在支付结果确定后直接按非储值实付金额计算。

如果小程序存在会员储值支付，也应遵循同一规则：

```text
先扣储值，拿到 principalAmount/giveAmount，再计算积分
```

不建议小程序继续采用 `cardConsumeInner` 前直接计算 `givePoint` 的旧方案，否则无法处理“储值赠送余额不积分”。

## 9. 测试场景

| 场景 | 输入 | 期望 |
|---|---|---|
| 微信支付 | 微信 100，会员已识别 | 按 100 计算积分 |
| 储值支付 | 储值 100，返回本金 70、赠送 30 | 按 70 计算积分 |
| 混合支付 | 微信 50 + 储值 50，储值返回本金 30、赠送 20 | 按 80 计算积分 |
| 积分抵现 | 积分抵现 20 + 微信 80 | 按 80 计算积分 |
| 全赠送余额 | 储值 100，返回本金 0、赠送 100 | 积分为 0 |
| 扣款失败 | `cardConsume` 失败 | 不计算、不补记 |
| 补记重试 | 同一个 `cardTaskLid` 重复调用 | 不重复加积分 |
| 规则关闭 | 积分总开关关闭 | 积分为 0 |
| 等级不匹配 | 找不到会员等级规则 | 积分为 0 |
| 时间不满足 | 不在可用周期或时段 | 积分为 0 |

## 10. 文档更新建议

以下旧文档需要按本方案修正：

- `线下POS和小程序自动积分接入方案.md`：删除或修改“cardConsume 前计算并透传 givePoint”的描述。
- `crm-会员账单与会员积分接入分析.md`：补充 POS 本地规则同步后，本地计算是当前方向；会员储值必须扣款后计算。
- `积分权益设置-需求分析文档.md`：补充隐藏规则“储值赠送余额不参与消费赠分”。

`CrmPointsRule同步链路改造复盘.md` 与当前同步实现基本一致，可保留，只需避免把同步完成误读为自动赠分已完成。

## 11. POS 本地赠分流水与撤销补偿方案

### 11.1 为什么不能复用 `DwdBill.points/cardPointLid`

`DwdBill.points` 和 `DwdBill.cardPointLid` 是既有积分抵现语义：

- `points` 表示本单抵扣使用的积分。
- `cardPointLid` 表示积分抵现扣减流水。

消费赠分属于“增加积分”，积分抵现属于“扣减积分”。二者如果复用同一组字段，反结账、退款、对账时无法区分本单到底是扣积分还是赠积分，会破坏旧逻辑。因此 POS 本地消费赠分必须使用独立表记录，不写入 `DwdBill.points/cardPointLid`。

### 11.2 本地表职责

新增 POS 本地表 `crm_consume_points_grant`，只记录 POS 本地产生的消费赠分执行状态。它不是云端积分流水表的副本，也不作为整表同步数据上传云端。

本地表主要解决三个问题：

1. POS 本地结账后，云端补记积分接口弱网失败时可重试。
2. POS 反结账或全额退款时，可找到原消费赠分并调用云端撤销接口。
3. 本地可记录云端正向赠分流水号和撤销流水号，方便排查和幂等补偿。

### 11.3 本地表核心字段

| 字段 | 含义 |
|---|---|
| `mid/sid/lid` | 本地门店数据归属与本地业务主键 |
| `bill_lid` | POS 账单本地主键 |
| `order_id` | POS 订单号 |
| `card_no/card_lid` | 会员卡信息 |
| `crm_task_lid` | 云端会员消费任务号，即储值扣款任务 |
| `grant_points` | 本次消费赠分数量 |
| `grant_points_record_lid` | 云端正向赠分积分流水号 |
| `revoke_points_record_lid` | 云端撤销赠分积分流水号 |
| `status_` | 本地执行状态 |
| `retry_count/next_retry_time/last_error_msg` | 弱网失败后的补偿重试信息 |

### 11.4 状态机

| 状态 | 含义 | 后续动作 |
|---|---|---|
| `PENDING` | 已计算赠分，待调用云端补记 | 后台重试正向赠分 |
| `GRANTED` | 云端补记成功 | 反结账/全额退款时可撤销 |
| `GRANT_FAILED` | 正向补记失败 | 网络恢复后继续重试 |
| `REVOKE_PENDING` | 已触发撤销，待调用云端撤销 | 后台重试撤销 |
| `REVOKED` | 云端撤销成功 | 终态 |
| `REVOKE_FAILED` | 撤销失败 | 网络恢复后继续重试 |

重试按单条业务调用云端接口，依赖云端接口幂等保护，不同步整张本地表。

### 11.5 云端接口边界

云端 CRM 仍然是积分真实流水来源：

- 正向赠分：POS 调用 `grantConsumePoints`，云端生成 `crm_card_points_record` 正向流水。
- 撤销赠分：POS 调用 `revokeConsumePoints`，云端生成负向积分流水。
- 本地表仅保存云端返回的积分流水号，用于重试、撤销和问题排查。

小程序消费不经过 POS 本地表。小程序线上支付链路直接调用云端积分权益逻辑，由云端订单和 CRM 服务完成赠分和流水记录。

### 11.6 本地表唯一约束说明

`crm_consume_points_grant` 从业务语义上看，适合做“同一账单、同一消费任务只允许一条本地记录”的唯一约束，例如：

- `mid + bill_lid + crm_task_lid`

这样可以避免并发场景下“先查后插”导致本地补偿表出现重复记录。即使云端接口有幂等保护，不会重复赠分，本地表如果出现重复记录，仍可能带来以下问题：

- 重试任务重复执行
- 撤销任务重复尝试
- 状态统计不准确
- 问题排查困难

当前阶段先不改唯一约束/唯一索引，原因如下：

1. 本次优先保证主链路可用，即 POS 本地补偿表 + 云端幂等补记/撤销链路先跑通。
2. POS 本地自动建表与补字段机制对新增字段、普通索引支持较好，但对唯一约束的无侵入升级支持需要进一步确认。
3. 如果门店现场已经存在重复脏数据，直接加唯一约束可能导致升级失败，需要先做数据清洗。

当前处理策略：

- 代码层面继续使用“先查后插”控制重复。
- 云端接口通过幂等保证不会重复赠分或重复撤销。

后续如果观察到本地表重复记录，或确认自动升级机制可以安全支持唯一约束，再单独评估是否补充唯一索引方案。

### 11.7 撤销失败是否阻塞业务

当前实现口径：

- 反结账或整单退款触发消费赠分撤销时，如果云端撤销接口失败，POS 前台业务不阻塞。
- 本地表把记录更新为 `REVOKE_PENDING` 或 `REVOKE_FAILED`，后续由后台重试补偿。

这样做的优点：

- 弱网或 CRM 短时不可用时，门店前台不被卡住。
- 反结账、整单退款可以继续完成，减少现场操作中断。

这样做的代价：

- 退款或反结账已经完成，但会员积分可能稍后才真正扣回。
- 在补偿成功前，云端会员积分余额可能短暂偏高。

另一种更严格的口径是：

- 云端撤销赠分失败时，直接阻塞反结账或整单退款。
- 只有撤销成功后，才允许 POS 业务继续完成。

该问题当前先记录到方案文档，暂不改实现。后续根据门店可用性要求和账务一致性要求，再单独评估最终口径。

## 12. 付款方式积分属性结论

> 2026-05-07 源码复核修正：本节原先基于早期实现得出“当前会员消费赠分计算逻辑没有读取 `canIntegral`”的结论。当前 POS 本地代码已经接入 `canIntegral`，因此以下口径以 `CrmPointsEarnLocalService.calculateEligibleAmount(...)` 的现行实现为准。

### 12.1 现有付款方式字段

POS/云端付款方式模型当前与“积分”相关的字段主要有：

- `canIntegral`
- `pointsRate`
- `pointsBillRate`
- `actualIncome`

其中：

- `pointsRate` 表示积分抵现率。
- `pointsBillRate` 表示积分最多抵扣率。
- `actualIncome` 表示该付款方式是否计入真实收入。

### 12.2 `canIntegral` 的当前生效含义

当前代码中，`canIntegral` 对普通支付方式已经作为“是否参与会员消费赠分基数”的过滤条件生效。

具体口径：

- 普通支付方式：如果支付方式配置 `canIntegral = false`，则该支付金额不进入消费赠分基数。
- 找不到支付方式配置时：默认允许进入消费赠分基数，用于兼容老门店未同步支付方式积分开关的数据。
- `HYK` 会员卡支付：不走普通支付方式的 `canIntegral` 判断，单独按储值本金/赠送金额规则计算。
- `PR` 积分抵现：直接排除，不参与消费赠分，避免积分抵积分。

页面上的“参与积分”字段仍然映射为 `canIntegral`，当前 POS 本地消费赠分实现已经使用该字段过滤普通支付方式。

源码依据：

- `CrmPointsEarnLocalService.calculateEligibleAmount(...)`：普通支付遍历时排除 `HYK` 和 `PR`。
- `CrmPointsEarnLocalService.canEarnPoints(...)`：读取 `BizPayWay.canIntegral`；只有明确为 `false` 时才过滤。

### 12.3 是否存在其他字段表示“付款方式是否参与消费赠分”

当前未发现独立的新字段。

也就是说：

- **现有付款方式模型里，用于普通支付方式参与消费赠分过滤的字段就是 `canIntegral`**

当前会员消费赠分代码能参考的付款方式属性，实际上只有：

- `canIntegral`

注意：`isRealIncome` / `actualIncome` 仍然存在于支付方式和支付明细模型中，但当前 POS 本地消费赠分基数计算的普通支付过滤以 `canIntegral` 为准，不再是本文档早期版本记录的“只看真实收入”。

如果后续业务希望区分“积分抵现能力”和“消费赠分能力”，可以再新增语义更明确的字段，例如：

- `canEarnPoints`
- `canParticipateInConsumePoints`

## 13. 当前积分计算口径

### 13.1 总体公式

当前 POS 本地会员消费赠分的计算口径为：

```text
积分基数 = 普通可积分支付金额 + 会员卡本金 (+ 规则允许时的会员卡赠送金额)
基础积分 = 积分基数 * 会员等级积分比例
最终积分 = 基础积分 * 多倍系数（生日/会员日取最高倍数） -> 单笔上限截断 -> 向下取整
```

### 13.2 积分基数怎么取

1. 普通支付方式：

- 遍历支付明细；
- 排除 `HYK`（会员卡）和 `PR`（积分抵现）；
- 按支付方式 LID 加载 `BizPayWay`；
- 如果对应支付方式 `canIntegral = false`，该支付金额不纳入积分基数；
- 如果找不到支付方式配置，默认允许纳入积分基数；
- 纳入基数的金额使用支付明细 `amount`。

2. 会员卡支付方式：

- 不直接按整笔会员卡金额积分；
- 使用云端会员卡扣款返回的 `principalAmount` 作为会员卡本金部分；
- 如果积分规则 `giftAmountEarnEnabled = 1`，再把 `giveAmount` 计入积分基数；
- 如果该开关关闭，则赠送金额不积分。

3. 积分抵现：

- `PR` 不参与消费赠分基数。

### 13.3 付款方式属性在当前口径中的作用

当前会员消费赠分实现：

- **已经使用 `canIntegral` 判断普通支付方式是否参与消费赠分**
- 普通支付金额是否进入积分基数，使用的是：
  - `BizPayWay.canIntegral != false`

因此，当前的实际口径是“普通支付按 `canIntegral` 过滤 + 会员卡本金/赠送规则单独计算”。

这修正了本文档早期版本记录的差异：

- 页面配置层面，运营看到并配置的是“参与积分（`canIntegral`）”。
- 当前 POS 本地会员消费赠分实现层面，普通支付方式已经按 `canIntegral` 生效。

仍需注意：

- `HYK` 会员卡支付不走普通支付方式 `canIntegral`，而是按储值本金和赠送金额开关计算。
- `PR` 积分抵现不参与消费赠分。

### 13.4 小数处理规则

积分计算过程中可以出现小数，例如：

- 支付金额乘会员等级积分比例时出现小数；
- 命中生日/会员日多倍后继续出现小数。

但最终赠送积分的规则是：

- **统一向下取整**

即：

```text
最终积分 = points.setScale(0, RoundingMode.DOWN)
```

示例：

- 积分基数 `99`
- 积分比例 `1.5`
- 计算结果 `148.5`
- 最终赠送积分 `148`

因此：

- 中间计算值可以有小数；
- 最终发放积分一定是整数；
- 当前规则不是四舍五入，而是向下取整。
