# 微信点餐积分统一到 POS 本地计算修改方案

## 一、背景

本次问题来自微信小程序点餐会员付款后的消费积分不一致现象。

最初排查时发现：小程序点餐线上付款后，账单会同步到 POS 本地，但有些环境能积分，有些环境不能积分。进一步检查发现，系统里实际存在两条消费积分路径：

1. `nms4cloud-order`：线上小程序会员卡付款成功后，order 模块直接调用 CRM 计算并发放消费积分。
2. `nms4pos`：账单同步到 POS 本地后，POS 本地也有消费积分补记链路。

业务上已经明确：微信点餐线上付款最终会同步到 POS，本地 POS 应该像消费赠券、消费返现一样统一处理消费权益。因此消费积分也应统一由 POS 本地计算和补记，避免线上和本地两套口径并存。

## 二、当前现象

本地 POS 数据库中，微信点餐同步后的账单已经能看到完整账单会员信息：

- `dwd_bill.card_no`
- `dwd_bill.phone`
- `dwd_bill.card_lid`
- `dwd_bill.card_type_lid`
- `dwd_bill.member_name`
- `dwd_bill.card_task_lid`

同时，本地也已经存在付款行：

- `dwd_pay.saas_order_no = dwd_bill.lid`
- 存在会员卡付款行，例如 `type_ = HYK`
- 付款行有 `principal/give/balance/card_task_lid/card_point_before/card_point_after`

但部分线上同步账单没有生成本地消费积分记录：

- `crm_consume_points_round` 无记录
- `crm_consume_points_session` 无记录

这说明问题不是“本地完全没有账单或付款方式”，而是 POS 本地积分计算链路没有稳定拿到可用于计算的付款上下文。

## 三、代码归属确认

### 1. 线上 order 消费积分代码

经 git 确认，`nms4cloud-order` 中线上付款后直接发放消费积分的代码由 `guoyun_liu` 新增。

关键位置：

- `PayOrderServiceImpl.crmPointsEarnFeign`
- `PayOrderServiceImpl.payNext(...)` 中调用 `grantConsumePointsAfterCardConsume(...)`
- `PayOrderServiceImpl.grantConsumePointsAfterCardConsume(...)`

git 证据：

- commit：`29556750d`
- 作者：`guoyun_liu`
- 日期：`2026-03-09`
- 说明：`会员积分修改 会员储值支持会员储值方案`

`git log -L` 显示 `grantConsumePointsAfterCardConsume(...)` 是该提交一次性新增。因此这段线上消费积分代码符合“尽量只改 guoyun_liu 改过的代码”的约束，可以删除。

注意：`revokeGrantedConsumePoints(...)` 不应删除，因为取消订单/失败撤销路径仍有调用。

### 2. POS 本地消费积分代码

POS 本地消费积分核心类：

- `nms4pos/.../CrmPointsEarnLocalService.java`

该类由 `guoyun_liu` 在 `8d90fca10 / 2026-04-20` 新增，后续多次由 `guoyun_liu` 修改，属于本次优先修改范围。

`CashPayHandler.checkPays()` 的付款方式组装主体主要是 `lyh` 历史代码，会员卡 HYK、微信 WXZF 付款补写逻辑也主要不是 `guoyun_liu` 最近改动。因此本次不优先修改 `checkPays()` 主体。

## 四、为什么要修改

当前两套积分链路并存会带来三个问题：

1. 线上 order 和 POS 本地的积分规则、配置、付款上下文可能不一致。
2. 删除线上积分前，如果补强 POS 本地积分，可能出现线上发一次、本地再发一次的重复积分风险。
3. POS 本地链路当前依赖调用方传入的 `types` 付款 map；当小程序同步链路中 `types` 与本地已经落库的 `dwd_pay` 不一致时，即使本地付款事实已经完整，也可能算出 0 分并跳过 round/session 创建。

因此需要统一口径：

- 微信点餐线上付款不再由 order 直接发消费积分。
- 线上订单同步到 POS 后，由 POS 本地像消费赠券、消费返现一样统一处理消费积分。
- POS 本地积分计算应以 `dwd_bill` 的会员信息为准，不依赖 `dwd_pay` 会员字段。
- POS 本地积分计算应以本地 `dwd_pay` 为付款事实来源，不再依赖调用方传入的 `types` 付款 map。

## 五、修改方案

### 1. 删除线上 order 直接发积分

修改 `nms4cloud-order` 的 `PayOrderServiceImpl`：

- 删除会员卡扣款成功后的 `grantConsumePointsAfterCardConsume(...)` 调用。
- 删除 `grantConsumePointsAfterCardConsume(...)` 方法。
- 删除仅供该方法使用的 `calculateNonCrmEarnAmount(...)`。
- 删除不再使用的 `CrmPointsEarnFeign` 注入和相关 import。
- 保留 `revokeGrantedConsumePoints(...)`，因为它仍被撤销路径使用。

### 2. POS 本地积分改为按账单加载付款方式

修改 `nms4pos` 的 `CrmPointsEarnLocalService`：

- `prepareGrantRecordForCheckout(...)` 中，会员信息继续通过 `loadMemberIfNecessary(...)` 从 `dwdBill.cardNo` 加载。
- 不使用 `dwd_pay.card_no/card_lid/member_name/phone` 作为会员身份判断依据。
- 消费积分计算不再依赖调用方传入的 `types`：
  - 将付款方式来源统一收敛到积分服务内部，抽出一个无外部副作用的统一计算方法。
  - 统一计算方法按 `dwdBill.mid + dwdBill.sid + dwdBill.lid` 查询本地 `dwd_pay`。
  - 查询结果按 `DwdPay.type` 组装为 `Map<PayWayEnum, DwdPay>`，作为 `calculateEligibleAmount(...)`、`resolveCardTaskLid(...)` 和支付快照的统一付款上下文。
  - 同一账单存在多条相同 `type_` 付款行时，先过滤有效正向付款行，再按 `type_` 汇总 `amount/principal/give` 等金额字段；支付快照保留聚合依据，避免多券、多笔同类型支付或异常重复 HYK 被覆盖。
  - HYK 的 `card_task_lid` 优先取本次会员卡消费任务号；没有时从同类型付款行中取非空且与账单一致的一条。
  - `types` 只保留在其他仍需要当前内存付款上下文的权益链路中；消费积分链路不再把它作为入口参数。
- 统一计算方法需要被调用两次，但只能有一套计算口径：
  - 第一次在账单事务内、打印前调用，用于刷新 `dwd_bill.consume_give_points` 和 `dwd_bill.card_points_after`，保证小票能读到本次应赠积分。
  - 第二次在账单事务提交后调用，用同一计算方法创建/复用 `crm_consume_points_round` 并执行真正发放。
  - `refreshBillPointsForPrint(...)` 如果保留，只允许调用统一计算方法并刷新展示字段，不允许保留独立金额计算逻辑。
- 同步调整消费积分调用方，调用 `grantConsumePointsForCheckout(...)` 时不再传入 `types`：
  - `CashPayHandler`
  - `DwdBillOpsServiceImpl`
  - `CloseMpScHandler`
  - 相关单元测试
- 原有金额计算规则不改：
  - 有 `cardBalanceVO` 时优先使用 `cardBalanceVO.principalAmount/giveAmount`。
  - 没有 `cardBalanceVO` 时使用本地 HYK 付款行的 `principal/give`。
  - 普通付款方式仍按支付方式配置 `canIntegral` 判断是否参与积分。
  - PR 积分抵现仍不参与赠分。

## 六、不修改范围

本次不修改：

- `CashPayHandler.checkPays()` 主体。
- 付款行创建/删除/更新框架。
- 消费赠券、消费返现逻辑。
- CRM 积分规则计算接口。
- POS 退款撤销积分逻辑。

## 七、验证方案

### 编译验证

- `nms4cloud-order` 编译通过，确认删除线上积分代码后无未使用 import、无未解析引用。
- `nms4pos` 编译通过，确认本地积分按账单加载付款方式不破坏现有线下结账。

### 场景验证

使用微信小程序点餐会员付款：

1. order 线上付款成功后，不再调用：
   - `crmPointsEarnFeign.calculateEarnedPoints`
   - `crmCardOpServiceFeign.grantConsumePointsInner`
2. 账单同步到 POS 本地后，确认：
   - `dwd_bill` 存在会员信息。
   - `dwd_pay` 存在对应 `saas_order_no = dwd_bill.lid` 的付款行。
   - POS 本地产生 `crm_consume_points_round` / `crm_consume_points_session`。
   - `eligible_amount` 和 `grant_points` 符合本地积分规则。
3. 确认会员积分只增加一次。
4. 补充单元测试或集成测试覆盖：
   - 调用方不传 `types` 时，消费积分服务能按 `dwd_bill.lid` 加载 `dwd_pay` 并计算出应赠积分。
   - 同一账单多条同类型付款行会被正确汇总，不会覆盖金额。
   - `dwd_pay.card_no/card_lid` 为空但 `dwd_bill.card_no/card_lid` 完整时，仍能按账单会员发放积分。
   - 结账失败时不刷新 `dwd_bill.consume_give_points` 和 `card_points_after`。

## 八、风险与回滚

风险：

- 如果某些线上付款单没有同步到 POS，本次删除线上积分后，这类单据不会再由 order 发积分。
- 如果 POS 本地付款行确实未落库，积分服务仍无法计算积分，需要继续排查同步链路。
- 如果本地积分规则配置与线上配置不一致，删除线上积分后会以本地规则为准。

回滚方式：

- 恢复 `PayOrderServiceImpl.grantConsumePointsAfterCardConsume(...)` 及其调用。
- 回退 `CrmPointsEarnLocalService` 按账单加载付款方式及调用方签名调整。
- 回滚后系统恢复为线上 order 直接发积分、本地 POS 链路保留但不作为唯一事实来源的旧状态。
