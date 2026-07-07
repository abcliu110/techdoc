# 线上会员卡支付同步 POS 后的消费积分排查

## 背景

排查对象是小程序点餐使用会员卡付款后，会员积分是否增加，以及积分到底由线上订单/CRM 发放，还是由 POS 本地结账后发放。

当前明确前提：

- 小程序地址：`https://bosswx.gzjjzhy.com`
- 商户/会员接口：`http://bosswx.gzjjzhy.com:30080`
- POS 本地库：`jdbc:mysql://127.0.0.1:8066/nms`
- 本地库用户：`root`
- 本地库名：`nms`

注意：测试工程目录名包含 `newshop`，不代表本次测试环境。判断环境时以测试结果中的 `scanTarget` 和请求 URL 为准。

## 当前结论

当前证据不能再简单描述为“小程序会员卡支付后一定由 POS 本地计算积分”。

对当前可复核的 bosswx 成功样本 `2026062710036`，积分是线上 order/CRM 支付链路发放的，POS 本地只是同步并落库线上返回的积分结果：

- 会员 `18923865943`
- 金额 `38`
- 支付前积分 `809`
- 支付后积分 `812`
- 积分增加 `3`
- 本地 `crm_consume_points_session` 无记录
- 本地 `crm_consume_points_round` 无记录

因此，这笔单可以确定不是 POS 本地 `CrmPointsEarnLocalService` 发放的积分。

同时，本地 POS 库确实存在积分规则，不能再把“本地无规则”作为原因。当前本地 `crm_points_rule` 中会员方案 `2056286959058817026` 的规则为：

```text
points_rule_enabled = 1
earning_enabled = 1
gift_amount_earn_enabled = 0
level_rates = [{"consumeAmount":1,"earnPoints":1,"memberLevelId":"2056286959100760066","sortOrder":1}]
```

这条本地规则按 `1 元积 1 分` 计算；而 `2026062710036` 的 `38 元` 只增加 `3 分`，也反向证明这笔单不是按本地规则算出来的。

## 需要区分的四种状态

排查时必须先区分以下状态，否则很容易误判根因：

1. 没有付款：没有成功调用或完成 `pay_order`，会员余额、积分、POS 账单都不应作为积分失败证据。
2. 付款失败：创建了订单但支付未成功，不能分析积分。
3. 付款成功但线上未加积分：要查 order 调 CRM 发积分链路和 CRM 规则。
4. 线上已加积分但 POS 本地未生成 round：这说明积分不是 POS 本地发放，POS 只是同步线上结果；不能用本地 round 为空证明“没有积分”。

当前 bosswx 成功样本属于第 4 类。

## 当前可复核样本：bosswx 已加积分

测试结果文件：

```text
D:\mywork\pos-merchant-backend-autotest-newshop\.tmp\miniapp-order-pay-benefits-bosswx-18923865943.json
```

环境指纹：

```text
merchantApiBaseUrl = http://bosswx.gzjjzhy.com:30080
memberApiBaseUrl   = http://bosswx.gzjjzhy.com:30080
scanTarget         = https://bosswx.gzjjzhy.com/yszx?code=1c858c3046121002&p=0&mid=yszx
contains_newshop   = false
```

会员变化：

```text
member       = 18923865943
cardLid      = 2047945239853142017
beforePoints = 809
afterPoints  = 812
beforeBalance = 34008.38
afterBalance  = 33970.38
beforeConsume = 18738.15
afterConsume  = 18776.15
```

接口链路中已出现：

```text
/api/sorder/order_bill/crt_order
/api/sorder/order_bill/get_post_order
/api/sorder/order_bill/pay_order
/api/sorder/order_bill/query_my_order
```

这说明本次不是“没付款”或“付款失败”。

## 当前本地 POS 落库证据

本地 `dwd_bill` / `dwd_pay` 中存在订单 `2026062710036`：

```text
saas_order_key       = 2026062710036
phone                = 18923865943
card_lid             = 2047945239853142017
card_no              = 18923865943
member_name          = 微信会员
paid_amount          = 38
principal            = 38
give                 = 0
order_status         = 4
checkout_time        = 2026-06-27 19:50:25
card_points_before   = 809
card_points_after    = 812
consume_give_points  = null
card_task_lid        = 2070837138686480385
```

会员卡支付明细：

```text
name                 = 会员卡
type_                = 2
pay_amount           = 38
amount               = 38
card_task_lid        = 2070837138686480385
card_point_before    = 809
card_point_after     = 812
card_balance_after   = 33970.38
principal            = 38
give                 = 0
card_no/card_lid/member_name/phone = null
```

本地积分 round：

```text
crm_consume_points_session = 0
crm_consume_points_round   = 0
```

判断：

- POS 本地账单和支付明细同步到了线上积分前后值。
- 本地没有生成消费积分 session/round。
- 因此这笔积分不是 POS 本地发放的。

## 本地规则存在，但未参与这笔积分计算

当前本地库 `crm_points_rule` 表存在，总数为 `8` 条。

会员 `18923865943` 与 `19198074442` 当前对应会员方案：

```text
cardTypeCode      = 2056286959058817026
cardTypeLevelCode = 2056286959100760066
```

本地规则：

```text
plan_lid                  = 2056286959058817026
points_rule_enabled        = 1
earning_enabled            = 1
gift_amount_earn_enabled   = 0
earning_mode               = 1
level_rates                = [{"consumeAmount":1,"earnPoints":1,"memberLevelId":"2056286959100760066","sortOrder":1}]
order_scene_limit          = [1,2,3,4]
order_channel_limit        = [1,2,3,4,5,6,7]
updated_time               = 2026-06-21 00:00:00
```

这条规则存在且开启，但它无法解释 `38 元只加 3 分`。如果 POS 本地按该规则计算，应接近 `38 分`，而不是 `3 分`。

## 线上发分代码路径

线上会员卡支付后，order 模块会先扣会员卡余额，再补记消费积分：

```text
nms4cloud-order
PayOrderServiceImpl.payNext(...)
  -> 会员卡扣款成功
  -> grantConsumePointsAfterCardConsume(...)
  -> crmPointsEarnFeign.calculateEarnedPoints(...)
  -> crmCardOpServiceFeign.grantConsumePointsInner(...)
  -> orderPay.setPointsTaskLid(...)
  -> orderPay.setCardPointAfter(...)
  -> updateAndSave(...)
  -> OrderMsgTypeEnum.CASH_PAY 同步 POS
```

关键点：

- `grantConsumePointsAfterCardConsume(...)` 会把 `paidAmount`、会员卡本金消费金额 `principalAmount`、赠送金额 `giveAmount` 传给 CRM 计算。
- CRM 返回发分后的 `pointsBalance` 后，order 会写入 `OrderPay.cardPointAfter`。
- POS 收到 `CASH_PAY` 后，会把线上支付明细中的 `cardPointAfter` 映射到本地 `dwd_bill` / `dwd_pay`。

因此，在 `2026062710036` 这类场景下，POS 本地看到的 `card_points_after=812` 是线上结果同步，不是本地 round 发放后的结果。

## POS 本地发分代码路径

POS 本地仍然存在消费积分发放逻辑：

```text
nms4pos
CashPayHandler
  -> OrderServiceUtil.checkOut(...)
  -> crmPointsEarnLocalService.grantConsumePointsForCheckout(...)
  -> prepareGrantRecordForCheckout(...)
  -> crm_consume_points_session / crm_consume_points_round
```

本地发分成立的前提：

- 消费权益总开关开启。
- 账单符合可积分条件。
- 能识别会员信息。
- 能拿到会员卡或其他可积分支付明细。
- 本地能按 `mid + plan_lid` 找到有效 `crm_points_rule`。
- 计算结果大于 0。

如果本地发分路径真正执行并落事实记录，应能查到 `crm_consume_points_session` 或 `crm_consume_points_round`。

## 历史反例：POS 本地上下文缺失会导致不生成 round

历史排查曾记录过一个反例：

```text
会员手机号      = 19198074442
线上订单号      = 2070807052598018050
POS 本地账单号  = 2026062710012
历史本地 bill_lid = 2070802361683501058
```

当时观察到：

```text
dwd_order_msg.revision = 2
dwd_bill 有会员信息
dwd_pay 会员卡支付明细存在
dwd_pay.card_no/card_lid/member_name/phone 为空
crm_consume_points_session 无记录
crm_consume_points_round 无记录
```

该反例说明：如果 POS 本地需要补齐消费积分，但 `CashPayHandler` 新建会员卡支付明细后没有把会员上下文和 HYK 支付明细传回 `types`，本地消费积分入口可能拿不到完整信息，最终不会创建 round。

需要注意：当前本地库中再次查询 `2026062710012`，结果已经与历史记录不同：

```text
当前 lid              = 2070560612842303490
paid_amount           = 48
card_points_before    = 2343
card_points_after     = 2391
consume_give_points   = 48
crm_consume_points_session = 1
crm_consume_points_round   = 1
```

所以旧反例只能作为历史快照和排查思路保留，不能作为当前本地库可复核证据。

## 关于 `dwd_pay` 会员字段为空

`dwd_pay.card_no/card_lid/member_name/phone` 为空并不必然等于“不会积分”。

需要结合以下字段判断：

- `dwd_bill.card_points_before`
- `dwd_bill.card_points_after`
- `dwd_bill.consume_give_points`
- `dwd_pay.card_point_before`
- `dwd_pay.card_point_after`
- `crm_consume_points_session`
- `crm_consume_points_round`

例如 `2026062710036`：

- `dwd_pay` 会员字段为空。
- 但 `card_point_before=809`、`card_point_after=812` 已同步。
- 本地 round 为空。
- 说明积分来自线上，不是本地。

如果另一个订单 `dwd_pay` 会员字段为空，同时线上会员积分也没有变化、本地 round 也没有生成，才应继续怀疑 POS 本地上下文缺失。

## 判断流程

排查一笔小程序点餐会员卡支付积分问题时，按以下顺序判断：

1. 确认环境：检查测试结果中的 `scanTarget`、`merchantApiBaseUrl`、`memberApiBaseUrl`。
2. 确认是否付款成功：必须有 `pay_order` 成功响应，并且会员余额或订单状态发生变化。
3. 查线上会员快照：比较付款前后 `points`、`balance`、`sumOfConsume`。
4. 查本地 `dwd_bill` / `dwd_pay`：确认 POS 是否收到订单和积分前后值。
5. 查本地 `crm_consume_points_session` / `crm_consume_points_round`。
6. 如果线上积分已增加、本地 round 为空：这笔积分来自线上 order/CRM。
7. 如果线上积分未增加、本地 round 也为空：再分析线上 CRM 规则、order 发分链路或 POS 本地上下文。
8. 如果本地 round 存在但积分没到账：再分析 round 状态、补偿事件和 CRM 回调。

## 建议验证 SQL

### 查当前成功样本

```sql
select b.lid,b.saas_order_key,b.saas_order_no,b.bill_name,b.phone,b.card_lid,b.card_no,b.member_name,
       b.paid_amount,b.principal,b.give,b.points,b.order_status,b.checkout_time,
       b.card_points_before,b.card_points_after,b.consume_give_points,b.card_task_lid,b.card_point_lid,
       p.lid as pay_lid,p.name,p.type_,p.pay_amount,p.amount,
       p.card_no as pay_card_no,p.card_lid as pay_card_lid,
       p.member_name as pay_member_name,p.phone as pay_phone,
       p.card_task_lid as pay_card_task_lid,
       p.card_point_before,p.card_point_after,p.card_balance_after,
       p.principal as pay_principal,p.give as pay_give
from dwd_bill b
left join dwd_pay p on p.saas_order_no=b.lid
where b.saas_order_key='2026062710036';

select *
from crm_consume_points_session
where order_id='2026062710036';

select *
from crm_consume_points_round
where order_id='2026062710036'
   or crm_task_lid='2070837138686480385';
```

### 查本地积分规则

```sql
select pid,mid,sid,lid,plan_lid,points_rule_enabled,earning_enabled,gift_amount_earn_enabled,
       earning_mode,level_rates,order_scene_limit,order_channel_limit,updated_time,revision,deleted
from crm_points_rule
where plan_lid='2056286959058817026';
```

### 查消费权益总开关

```sql
select company_id, shop_id, name, boolean_val
from sys_config_data
where name = 'g_crmConsumeBenefitEnabled'
  and company_id = 1940284000182472704;
```

## 后续排查建议

如果后续再次出现“会员卡支付后没有积分”，不要先判断是 POS 本地问题。应先拿到同一笔订单的三组证据：

- 线上会员付款前后快照。
- 本地 `dwd_bill` / `dwd_pay`。
- 本地 `crm_consume_points_session` / `crm_consume_points_round`。

只有确认“付款成功、线上积分未增加、本地 round 未生成”之后，才继续分析：

- order 是否调用了 `grantConsumePointsAfterCardConsume(...)`。
- CRM `calculateEarnedPoints(...)` 根据线上规则是否计算为 0。
- POS 本地 `CashPayHandler` 是否丢失会员上下文或 HYK 支付明细。
- 本地 `crm_points_rule` 是否与线上规则不同步。

## 文档修订记录

- 2026-06-27：补充 bosswx 当前可复核样本 `2026062710036`，明确这笔积分来自线上 order/CRM，不是 POS 本地 round。
- 2026-06-27：补充本地 `crm_points_rule` 当前规则，说明本地有规则但未参与 `2026062710036` 的积分计算。
- 2026-06-27：将历史反例 `2026062710012` 标记为历史快照，避免与当前本地库状态混用。
