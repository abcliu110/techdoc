# 消费赠券 CRM 与门店 POS 联动设计

## 1. 当前结论

本阶段先实现“消费赠券”，不实现消费赠券与消费返现的统一底座。统一底座留到消费赠券稳定后，再评估消费返现是否复用同一套 POS 本地 session/round/event 模型。

责任边界调整为：

- CRM 只提供新的同步接口：幂等发券、幂等撤销发券。
- POS 门店维护消费赠券状态机，负责结账、反结账、退款、补偿重试和多轮生命周期。
- CRM 现有 MQ 消费赠券链路继续保留，不作为本次 POS 新链路的主路径。
- POS 门店已有 ActiveMQ，但首版不把 ActiveMQ 放进主链路；本地 round 表承担轻量 outbox/work queue 职责。

## 2. 已有能力与新增能力

### 2.1 CRM 已有能力

CRM 当前已经存在消费赠券 MQ 链路：

`CrmCardOpController.consumerGiveCoupon` -> `CrmCardOpServicePlus.consumerGiveCoupon` -> `CRM_CONSUMER_COUPON_QUEUE` -> `CrmConsumerCouponQueueConsumer` -> `CrmCouponOpServicePlus.couponOpAdd`。

这条链路是历史兼容契约，继续保留，不改语义。

CRM 已有通用发券与撤销能力：

- `CrmCouponOpServicePlus.couponOpAdd(CouponOpAddDTO)`：执行实际发券。
- `CrmCouponOpServicePlus.couponOpRevoke(CouponOpRevokeDTO)`：按会员、订单号、券模板撤销未核销/已过期券。

### 2.2 CRM 需要补充

CRM 新增 POS 专用同步接口：

- `POST /crm_consume_coupon/grantSign`：按 `roundKey` 幂等发券。
- `POST /crm_consume_coupon/revokeSign`：按 `roundKey` 幂等撤销。

CRM 新增幂等记录表，记录 `roundKey`、订单号、会员、规则、券模板、发券数量、券订单 LID、请求/响应快照和状态。重复 grant 不再重复发券；重复 revoke 不再重复撤销。

### 2.3 POS 已有能力

POS 当前已有消费积分本地状态机：

- `CrmConsumePointsSession`
- `CrmConsumePointsRound`
- `CrmConsumePointsEvent`
- `CrmPointsEarnLocalService`

它已经覆盖结账后发放、反结账撤销、退款后重算、失败补偿、afterCommit 调用 CRM 等企业级流程。

### 2.4 POS 需要补充

POS 新增消费赠券本地状态机：

- `crm_consume_coupon_session`
- `crm_consume_coupon_round`
- `crm_consume_coupon_event`
- `CrmConsumeCouponLocalService`

并接入：

- 正常结账成功后登记发券 round，并在事务提交后调用 CRM。
- 反结账、全单退款时登记撤销 round，并调用 CRM 撤销。
- 部分退款需要按实际剩余消费重新进入“撤旧券、必要时新建下一轮发券”的模型。
- 补偿任务扫描失败 round，继续调用 CRM grant/revoke。

## 3. 模块改动范围

### 3.1 CRM：nms4cloud-crm

新增或修改位置：

- `nms4cloud-crm-api`：新增 POS 消费赠券 DTO、VO、状态枚举。
- `nms4cloud-crm-dao`：新增幂等记录实体、Mapper、Service、DDL。
- `nms4cloud-crm-service`：新增消费赠券幂等服务。
- `nms4cloud-crm-app`：新增 POS 专用签名接口 Controller。

不改动旧 MQ 消费者的业务语义。

### 3.2 POS：nms4cloud-pos2plugin

新增或修改位置：

- `nms4cloud-pos2plugin-api`：新增消费赠券状态/来源/事件枚举。
- `nms4cloud-pos2plugin-dal`：新增 session/round/event 实体与 Mapper。
- `nms4cloud-pos2plugin-biz`：新增 `CrmConsumeCouponLocalService`，并接入结账、反结账、退款流程。
- `Nms4CloudCrmService`：新增 CRM grant/revoke 调用。
- `sql/update`：新增 POS 本地表 DDL。

## 4. 状态机设计

### 4.1 POS round 状态

| 状态 | 含义 | 是否终态 |
| --- | --- | --- |
| `PENDING` | 已登记，等待调用 CRM 发券 | 否 |
| `GRANTED` | CRM 已确认发券成功 | 否 |
| `GRANT_FAILED` | 发券失败，等待补偿 | 否 |
| `REVOKE_PENDING` | 已登记撤销意图，等待调用 CRM 撤销 | 否 |
| `REVOKED` | CRM 已确认撤销成功 | 是 |
| `REVOKE_FAILED` | 撤销失败，等待补偿 | 否 |
| `NO_MATCH` | CRM 确认无匹配赠券规则，无需发券 | 是 |
| `VOIDED` | 未产生外部发券影响前被本地作废 | 是 |

状态事实源在 POS round 表，event 表只做审计，不参与判定。

### 4.2 CRM 状态

CRM 不承担完整业务状态机，只维护接口幂等状态：

- `GRANTED`：该 `roundKey` 已发券，重复 grant 返回原结果。
- `NO_MATCH`：该 `roundKey` 已判定无规则，重复 grant 返回无规则。
- `REVOKED`：该 `roundKey` 已撤销，重复 revoke 返回成功。
- `FAILED`：本次 CRM 内部处理失败，允许 POS 后续以同一 `roundKey` 重试。

## 5. 数据模型

### 5.1 POS session

一张消费单和会员卡对应一个消费赠券会话：

- `mid`、`sid`
- `source`
- `bill_lid`
- `order_id`
- `card_lid`
- `card_no`
- `current_round_lid`
- `status`

唯一约束：`mid + source + bill_lid + card_lid + deleted`。

### 5.2 POS round

round 是一次可补偿的外部权益操作，也是本方案的轻量 outbox：

- `round_key`：传给 CRM 的幂等键，建议使用 `mid:sid:billLid:cardLid:roundNo` 或 POS round LID。
- `round_no`：从 1 开始，多轮反复结账/撤销时递增。
- `parent_round_lid`：新一轮关联上一轮。
- `status`
- `next_retry_time`
- `retry_count`
- `grant_time`
- `revoke_time`
- `rule_lid`
- `coupon_lid`
- `coupon_num`
- `coupon_order_lids_json`
- 金额和支付快照 JSON。

同一 session 同一时间只允许一个 active round。

### 5.3 POS event

event 只记录审计轨迹：创建 round、调用 CRM、CRM 成功、CRM 失败、状态变更。

### 5.4 CRM 幂等记录

CRM 记录 `roundKey` 到实际券订单的映射：

- `mid`、`sid`
- `round_key`
- `order_id`
- `card_lid`、`card_no`、`phone`
- `status`
- `rule_lid`
- `coupon_lid`
- `coupon_num`
- `coupon_order_lids_json`
- `request_json`
- `response_json`
- `error_msg`

唯一约束：`mid + sid + round_key + deleted`。

## 6. 核心流程

### 6.1 正常结账发券

1. POS 完成账单结账和支付落库。
2. POS 在本地事务内创建或复用消费赠券 session/round，状态为 `PENDING`。
3. POS 在事务提交后调用 CRM `grantSign`。如果没有事务上下文，则直接调用。
4. CRM 按 `roundKey` 查幂等记录：
   - 已 `GRANTED`：返回原券订单，不重复发券。
   - 已 `NO_MATCH`：返回无规则。
   - 已 `REVOKED`：返回已撤销，不重新发券。
   - 无记录或失败记录：匹配规则并调用通用发券。
5. POS 根据 CRM 返回更新 round：
   - `GRANTED`：记录券订单。
   - `NO_MATCH`：终态。
   - 失败：`GRANT_FAILED`，等待补偿。

### 6.2 反结账或全单退款撤销

1. POS 查询当前 active round。
2. 如果 round 还未产生外部影响，允许本地置为 `VOIDED`。
3. 如果 round 已发券、发券结果未知、或可能正在补偿，置为 `REVOKE_PENDING`。
4. POS 调用 CRM `revokeSign(roundKey)`。
5. CRM 按 `roundKey` 查询记录：
   - 未找到：认为无外部影响，幂等返回成功。
   - `NO_MATCH`/`REVOKED`：幂等返回成功。
   - `GRANTED`：调用通用撤销并更新 `REVOKED`。
6. POS 更新 round 为 `REVOKED`，关闭 session 当前轮次。

### 6.3 部分退款后重算

部分退款不是简单撤销，也不是直接补差。推荐流程：

1. POS 先把当前 active round 推进到撤销链路。
2. 撤销完成或登记撤销意图后，按退款后的剩余账单事实创建下一轮 round。
3. 下一轮用新的 `roundKey` 调 CRM grant。
4. 这样可以覆盖“结账付款-发券-撤销付款-撤销发券-再次付款-再次发券”的反复流程。

### 6.4 晚返回处理

如果 POS 已经把 round 改为 `REVOKE_PENDING`，而之前的 grant 调用晚返回成功：

- POS 只补写券订单信息。
- round 保持撤销链路，不回退为 `GRANTED`。
- 下一次补偿继续执行 revoke。

## 7. 重试与一致性

POS round 表就是首版 outbox：

- `PENDING`/`GRANT_FAILED` 到期后重试 grant。
- `REVOKE_PENDING`/`REVOKE_FAILED` 到期后重试 revoke。
- 每次失败增加 `retry_count`，按退避时间写 `next_retry_time`。
- 最大重试次数用于保护 CRM，不作为业务放弃依据；超过阈值后应留给人工处理。

不使用 POS ActiveMQ 的原因：

- 门店本地表已经能表达“事务内登记、事务后投递、失败补偿”的 outbox 语义。
- ActiveMQ 不能替代本地状态事实源，仍需要数据库状态机解决反结账、退款、多轮和幂等问题。
- 首版少引入一个异步中间件，可降低部署和排障复杂度。

## 8. 兼容与回滚

兼容措施：

- CRM 旧 MQ 消费赠券接口和消费者保持不变。
- POS 新链路只在新增调用点启用，不改变积分链路。
- CRM 新接口以 `roundKey` 幂等，重复请求不会重复发券。
- POS 本地状态机允许失败重试，不把 CRM 短暂不可用反向打断结账。

回滚方案：

- POS 关闭或移除新增结账/撤销调用点，已登记 round 保留用于排查。
- CRM 保留新表和接口不影响旧 MQ 链路。
- 如果需要人工补偿，可通过 POS round 的 `roundKey`、CRM record 的 `coupon_order_lids_json` 定位。

## 9. 后续可复用到返现的条件

消费返现可以复用 POS session/round/event 模型，但不建议现在抽统一底座。等消费赠券跑通后，再看下面条件是否成立：

- 返现也需要结账后发放、反结账撤销、退款重算、多轮补偿。
- CRM 返现也能提供 `roundKey` 幂等 grant/revoke。
- 两类权益的差异只在 CRM 调用参数和返回结果，不在 POS 状态机。

满足后再抽象公共 `benefit_session/benefit_round` 或 Java 共享状态机，风险会比现在直接抽象低。