# CRM 消费积分设计说明

日期：2026-05-09  
状态：统一消费积分引擎设计版

## 1. 设计目标

CRM 消费积分用于处理“会员消费后按积分规则赠送积分”以及“反结账、退款、撤单后撤回已赠积分”。本设计统一储值消费和非储值消费的积分处理口径：只要是 POS 或订单消费产生的消费赠积分，都由同一套消费积分引擎负责。

消费积分引擎的目标：

- 支持会员卡储值支付、现金、微信、支付宝、第三方支付、会员折扣、会员价等消费场景。
- 支持有会员卡扣款任务 `taskLid/cardTaskLid` 的储值消费，也支持没有会员卡扣款任务的非储值消费。
- 防止同一笔订单重复赠积分。
- 防止同一笔订单反结账或退款时重复撤销积分。
- 积分余额继续维护在 `crm_card.points`。
- 积分明细继续写入 `crm_card_points_record`。
- 不把消费积分写入储值金额流水 `crm_card_record`。
- 不再用 `CrmDealTask.givePoint` 作为消费积分主状态。

核心边界：

```text
CardBalance 引擎：
  负责会员卡储值金额。
  维护本金、赠送金、储值余额。
  写 crm_card_record。

消费积分引擎：
  负责 POS/订单消费赠积分和撤销积分。
  维护 crm_card.points。
  写 crm_card_points_record。
  写统一消费积分任务表。
```

最关键原则：

```text
同一笔订单的同一种消费积分权益，只能由一个引擎负责赠送和撤销。
```

本设计不引入消费积分引擎额外灰度开关。统一引擎上线后，本次新增的消费积分入口按统一口径执行。`crm_points_rule` 中的消费积分开关只表示业务规则是否允许赠分，不是发布灰度开关。

### 1.1 边界澄清

| 类型 | 内容 | 本次处理口径 |
|---|---|---|
| 真正既有系统 | `crm_card`、`crm_card_points_record`、`crm_deal_task`、`CardBalanceService` | 保留兼容；不重写 CardBalance 现有金额和撤销逻辑 |
| 本次最终实现 | `grantConsumePointsSign/Inner`、`revokeConsumePointsSign/Inner`、`CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints`、统一消费积分任务表、POS 本地 `crm_consume_points_grant` | `CrmCardOpServicePlus` 中的两个消费积分方法是近期新增逻辑，不是旧储值金额逻辑；统一实现应在这套判重和撤销保护上演进，不应新建一套服务直接绕过 |
| 本任务过渡分叉 | `grantPosConsumePoints*`、`revokePosConsumePoints*`、`CrmPosConsumePointsServicePlus`、`crm_pos_consume_points_task`、`g_posConsumePointsEngineEnabled` | 需要删除或替换为统一实现；不作为兼容对象保留 |

储值和非储值消费共用同一套消费积分接口和一套消费积分语义。`taskLid` 只决定是否额外校验储值消费任务，不决定是否积分、不决定接口分流。当前代码中，`CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints` 已经承担了近期新增的消费积分发放和撤销职责；后续统一化必须保留其中已有的判重、撤销流水校验和负积分扣减边界。

POS 账单字段口径固定如下：

| 概念 | 字段 | 口径 |
|---|---|---|
| 统一幂等订单号 | `orderId` | POS 传 `dwd_bill.saas_order_key`；云端订单传云端订单号 |
| POS 账单逻辑号 | `billLid` | POS 传 `dwd_bill.lid`；只用于排查、反结账定位和本地补偿 |
| 会员卡定位 | `cardNo` -> `cardLid` | 外部接口传 `cardNo`；CRM 查到唯一会员卡后，任务落库和幂等统一使用 `cardLid` |

## 2. API 设计

### 2.1 正向发放消费积分

接口使用本次新增的消费积分最终路径，作为 POS 和云端唯一对接入口；不保留只服务非储值支付的独立接口和独立任务表。

| 调用方 | API | 说明 |
|---|---|---|
| POS 本地签名接口 | `POST /crm_card_op/grantConsumePointsSign` | POS 结账后调用，带签名校验；Controller 从签名字段回填 `mid/sid` |
| 内部 Feign 接口 | `POST /crm_card_op/grantConsumePointsInner` | 云端订单或服务内部调用 |

入口代码目标：

- `CrmCardOpController.grantConsumePointsSign`
- `CrmCardOpController.grantConsumePointsInner`
- `CrmCardOpServicePlus.grantConsumePoints`，在现有近期新增逻辑上补齐 `source/billLid/taskLid 可空` 能力；如拆出独立 Service，必须迁移并保留该方法已有判重保护，不能直接绕过
- POS 调用接口：`Nms4CloudCrmService.grantConsumePoints`

请求 DTO：`CrmCardOpGrantConsumePointsDTO`

| 字段 | 来源 | 必填 | 作用 |
|---|---|---:|---|
| `mid` | 签名字段或内部调用传入 | 是 | 商户 ID；所有查询、幂等和写入都按 `mid` 隔离 |
| `sid` | 签名字段或内部调用传入 | 是 | 门店 ID；写入积分任务和积分流水门店归属 |
| `source` | POS 或云端订单 | 是 | 消费积分来源；POS 固定为 `POS`，云端订单固定为 `ORDER`，参与 CRM 幂等 |
| `taskLid` | 储值扣款返回的 `CardBalanceVo.outTranNo` 或 POS `card_task_lid` | 否 | 可选关联字段；有值时只用于校验和排查，不作为积分主状态 |
| `billLid` | POS `dwd_bill.lid` 或云端订单对应账单 LID | 否 | 账单逻辑号；用于 POS 本地反结账和排查 |
| `orderId` | POS `dwd_bill.saas_order_key` 或云端订单号 | 是 | 统一幂等键之一；写入 `crm_card_points_record.order_bill_id` |
| `givePoint` | POS/订单积分规则计算结果 | 是 | 本次应赠积分；必须大于 0 |
| `cardNo` | 会员卡号 | 外部签名接口要求 | 定位和校验会员卡 |
| `operator` | 操作人 | 否 | 写入积分流水操作人；POS 补偿可传 `system` |
| `comment` | 备注 | 否 | 写入积分任务和积分流水备注 |
| `forBackground` | 后台操作标记 | 否 | 继承自基础 DTO，当前消费积分主流程不依赖 |

有 `taskLid` 时，CRM 应校验：

- `crm_deal_task` 存在。
- `operation_model = Consume`。
- `trade_state = SUCCESS`。
- 未被逻辑删除。
- `card_lid/cardNo/orderId` 和请求一致。

校验通过后，`taskLid` 非空链路必须保留 `CrmCardOpServicePlus.grantConsumePoints` 已有的重复发放保护；该保护当前包含 `crm_deal_task.give_point` 和 `crm_card_points_record` 正向流水检查。`taskLid` 为空链路不能依赖 `crm_deal_task.give_point`，应使用统一消费积分任务表和 POS 本地补偿表做幂等。

返回 VO：`CardBalanceVo`

| 字段 | 作用 |
|---|---|
| `outTranNo` | 消费积分任务 LID |
| `outTranNoStr` | 消费积分任务 LID 字符串；仅用于新接口调用方回显，不作为业务判定字段 |
| `pointsRecordLid` | CRM 积分流水 `crm_card_points_record.lmnid` |
| `cardLid/cardNo` | 会员卡标识 |
| `balance/principalBalance/giveBalance` | 当前储值余额信息，仅供展示和回显，不参与消费积分业务判定 |
| `amount/principalAmount/giveAmount` | 本次消费金额信息，有 `taskLid` 时可从储值消费任务带出；无任务时可为 0 |
| `points` | 本次赠送积分 |
| `pointsBalance` | 当前会员卡积分余额 |

### 2.2 撤销消费积分

接口使用本次新增的消费积分撤销最终路径，作为 POS 和云端唯一撤销入口；不保留只服务非储值支付的独立撤销接口和独立任务表。

| 调用方 | API | 说明 |
|---|---|---|
| POS 本地签名接口 | `POST /crm_card_op/revokeConsumePointsSign` | POS 反结账、退款、撤单后撤销赠分 |
| 内部 Feign 接口 | `POST /crm_card_op/revokeConsumePointsInner` | 云端订单内部撤销赠分 |

入口代码目标：

- `CrmCardOpController.revokeConsumePointsSign`
- `CrmCardOpController.revokeConsumePointsInner`
- `CrmCardOpServicePlus.revokeConsumePoints`，在现有近期新增逻辑上补齐 `source/billLid/taskLid 可空` 能力；如拆出独立 Service，必须迁移并保留该方法已有的原赠分流水校验、重复撤销保护和负积分扣减边界，不能直接绕过
- POS 调用接口：`Nms4CloudCrmService.revokeConsumePoints`

请求 DTO：`CrmCardOpRevokeConsumePointsDTO`

| 字段 | 来源 | 必填 | 作用 |
|---|---|---:|---|
| `mid` | 签名字段或内部调用传入 | 是 | 商户隔离 |
| `sid` | 签名字段或内部调用传入 | 是 | 门店归属 |
| `source` | POS 或云端订单 | 是 | 消费积分来源；必须和正向发放时一致 |
| `taskLid` | 原储值消费任务号 | 否 | 可选校验字段；有值时校验任务和原订单一致 |
| `billLid` | POS 账单 LID | 否 | 辅助定位和排查 |
| `orderId` | 原 POS `dwd_bill.saas_order_key` 或云端订单号 | 是 | 定位原消费积分任务 |
| `grantPointsRecordLid` | POS 本地保存的原赠分流水号 | 否 | 如果传入，CRM 校验必须等于原正向积分流水 |
| `givePoint` | 原赠分积分 | 否 | 如果传入，CRM 校验必须等于任务表原 `grant_points` |
| `cardNo` | 会员卡号 | 外部签名接口要求 | 定位和校验会员卡 |
| `operator` | 操作人 | 否 | 写入负向积分流水操作人 |
| `comment` | 撤销原因 | 否 | 写入负向积分流水备注 |

撤销成功时：

- `pointsRecordLid` 返回负向撤销积分流水号。
- `points` 返回负数积分。
- `pointsBalance` 返回扣回后的会员卡积分余额。
- 若原任务已撤销，接口直接返回已存在的撤销流水结果，不重复扣积分。

## 3. 表结构和字段作用

### 3.1 `crm_consume_points_task`：CRM 统一消费积分任务表

作用：记录一笔消费订单的积分发放和撤销状态。它是消费积分幂等、撤销和排查的权威任务表。

建议字段：

| 字段 | 作用 |
|---|---|
| `pid` | 物理主键 |
| `company_id` / `mid` | 商户 ID |
| `shop_id` / `sid` | 门店 ID |
| `lmnid` / `lid` | 消费积分任务逻辑号 |
| `source_` | 消费积分来源：`POS`-POS 本地账单，`ORDER`-云端订单 |
| `bill_lid` | POS 账单 LID，可为空 |
| `revoke_bill_lid` | 反结账/退款账单 LID，可为空 |
| `order_id` | 原 POS `dwd_bill.saas_order_key` 或云端订单号，必填 |
| `card_lid` | CRM 会员卡 LID |
| `card_no` | 会员卡号 |
| `task_lid` | 可选 CRM 储值消费任务号；只做关联和校验 |
| `grant_points` | 原始赠送积分，撤销时必须按它扣回 |
| `grant_points_record_lid` | 正向积分流水 LID |
| `revoke_points_record_lid` | 负向撤销积分流水 LID |
| `status_` | 任务状态：已发放、已撤销等 |
| `operator` | 发放操作人 |
| `revoke_operator` | 撤销操作人 |
| `comment` | 发放备注 |
| `revoke_comment` | 撤销备注 |
| `grant_time` | 发放时间 |
| `revoke_time` | 撤销时间 |
| `revision` | 版本号，保留给并发更新 |
| `created_by/created_time/updated_by/updated_time/deleted` | 审计和逻辑删除字段 |

建议索引：

| 索引 | 字段 | 作用 |
|---|---|---|
| 唯一索引 | `company_id + source_ + order_id + card_lid + deleted` | 防止同一来源、同一订单、同一会员卡重复赠积分 |
| 普通索引 | `company_id + bill_lid` | POS 按账单排查和反结账定位 |
| 普通索引 | `company_id + task_lid` | 有储值消费任务时关联排查 |
| 普通索引 | `company_id + grant_points_record_lid` | 按积分流水反查任务 |
| 普通索引 | `company_id + status_` | 任务状态查询 |

设计要点：

- 这张表不是报表主表，而是业务一致性表。
- 正向发分和撤销都必须先定位这张表。
- 反结账不能重新按当前规则计算积分，必须使用 `grant_points`。
- `task_lid` 允许为空，解决会员折扣、会员价、现金/微信/支付宝等非储值支付场景。
- 当前只支持整单发放和整单撤销；部分退款、部分撤销不在本次范围。
- 若撤销时会员可用积分不足，允许积分余额扣为负数，表示会员欠积分；不得因为积分已被后续使用而跳过储值金额反结账或 POS 退款撤销。

### 3.2 `crm_deal_task`：CRM 会员卡交易任务表

作用：继续记录会员卡充值、储值消费、储值撤销等金额任务。它属于 CardBalance 金额引擎，不是消费积分任务表。

消费积分相关定位：

| 字段 | 新口径 |
|---|---|
| `lid` | 可作为消费积分请求的可选 `taskLid`，用于校验储值消费真实性 |
| `card_lid` | 有 `taskLid` 时校验会员卡一致 |
| `operation_model` | 有 `taskLid` 时要求为 `Consume` |
| `out_trade_no` | 有 `taskLid` 时校验必须等于请求 `orderId` |
| `trade_state` | 有 `taskLid` 时要求为 `SUCCESS` |
| `canceled` | 已撤销任务不能再新发消费积分 |
| `give_point` | 对 `taskLid` 非空的近期新增消费积分链路，仍可作为重复发放保护字段；`taskLid` 为空链路不能依赖该字段 |

设计要点：

- CardBalance 只负责储值金额变动。
- `CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints` 是近期新增的消费积分发放和撤销逻辑，不属于 CardBalance 既有金额撤销逻辑。
- `taskLid` 非空链路必须保留 `CrmCardOpServicePlus` 已有的 `give_point` 判重、原赠分流水校验和重复撤销保护。
- `taskLid` 为空链路不能写入或依赖 `crm_deal_task.give_point`，应通过统一消费积分任务表和 POS 本地补偿表闭环。
- 本次任务不修改 CardBalance 现有金额和撤销逻辑，也不在 CardBalance 内新增消费积分处理分支；消费积分余额只通过 `crm_card.points` 和 `crm_card_points_record` 变动。

### 3.3 `crm_card`：CRM 会员卡主表

作用：保存会员卡当前余额和积分余额。

消费积分相关字段：

| 字段 | 作用 |
|---|---|
| `points` | 当前可用积分余额；正向赠分加，撤销赠分减 |
| `sum_of_points` | 当前代码口径下随正向赠分增加、撤销赠分减少 |
| `id` | 会员卡号，接口 `cardNo` 校验使用 |
| `lmnid/lid` | 会员卡逻辑号，写入积分任务和积分流水 |
| `member/member_code/phone/card_type/card_type_code/out_id` | 写入积分流水展示字段 |

设计要点：

- 积分余额最终以 `crm_card.points` 为准。
- 正向发分使用数据库原子表达式增加积分。
- 撤销积分使用数据库原子表达式扣减积分。
- 发分、写积分流水、更新消费积分任务必须在 CRM 单个事务中完成。

### 3.4 `crm_card_points_record`：CRM 积分流水表

作用：保存每次积分增加或减少的明细，是会员积分明细和积分详情报表的主要数据源。

消费积分相关字段：

| 字段 | 作用 |
|---|---|
| `lmnid/lid` | 积分流水逻辑号，接口返回 `pointsRecordLid` |
| `company_id/shop_id` | 商户和门店 |
| `card_id` | 会员卡逻辑号字符串 |
| `card_id_alias` | 会员卡号 |
| `operation_model` | 正向消费赠分为 `Consume`，撤销为 `CancelOrder` |
| `balance_before` | 变动前积分余额 |
| `amount` | 本次积分变动值；正向为正数，撤销为负数 |
| `balance_after` | 变动后积分余额 |
| `order_bill_id` | 原订单号 `orderId`，用于账单关联和报表查询 |
| `comment` | 发放或撤销原因 |
| `if_deal_success/is_third_party/year_month_day` | 统计和展示辅助字段 |

设计要点：

- 所有消费积分明细都进入这张表。
- 后续 BI / Report11 / 前端会员积分报表如要按账单查询，应补 `order_bill_id` 查询和展示。
- 消费积分不写 `crm_card_record.give_point`，会员账户详情和 PLUS 汇总的积分字段后续应改为从本表汇总。

### 3.5 `crm_consume_points_grant`：POS 本地消费赠分补偿记录

作用：POS 本地链路专用。记录一张 POS 账单对应的消费赠分是否已发放、是否失败待重试、是否已撤销。

字段口径：

| 字段 | 作用 |
|---|---|
| `bill_lid` | POS 账单 `dwd_bill.lid`；反结账时按账单查记录 |
| `order_id` | POS `dwd_bill.saas_order_key`；传给 CRM 作为统一幂等键 |
| `card_no` | 会员卡号 |
| `card_lid` | POS 本地会员卡 LID |
| `crm_task_lid` | 可选 CRM 储值消费任务号；只做校验和排查 |
| `grant_points` | 本单应赠积分；撤销时使用原值 |
| `grant_points_record_lid` | CRM 正向积分流水号 |
| `revoke_points_record_lid` | CRM 负向撤销积分流水号 |
| `status_` | 本地状态机 |
| `retry_count/next_retry_time/last_retry_time/last_error_msg` | 失败补偿控制字段 |

状态机：

| 状态 | 含义 |
|---|---|
| `PENDING` | 已创建本地记录，尚未成功调用 CRM 发放积分 |
| `GRANTED` | CRM 已成功发放积分，本地已保存正向流水号 |
| `GRANT_FAILED` | 上次发放失败，等待补偿任务重试 |
| `REVOKE_PENDING` | 已进入撤销流程，等待 CRM 撤销成功 |
| `REVOKED` | CRM 已成功撤销积分，本地已保存负向流水号 |
| `REVOKE_FAILED` | 上次撤销失败，等待补偿任务重试 |

设计要点：

- POS 本地补偿记录不再以 `crm_task_lid` 是否为空决定接口分流。
- 所有消费积分发放和撤销都调用统一 CRM 消费积分接口。
- `crm_task_lid` 为空时也允许发分和撤销。
- 本地幂等按 `mid + order_id + card_lid + deleted` 约束；`crm_task_lid` 只做追踪和校验，不进入本地唯一键。

### 3.6 `dwd_bill`：POS 本地账单主表

作用：POS 本地账单主表，提供消费积分计算和小票展示所需数据。

消费积分相关字段：

| 字段 | 作用 |
|---|---|
| `mid/sid/lid` | 商户、门店、账单 LID |
| `saas_order_key` | POS 订单号，传 CRM `orderId`，也是 CRM 消费积分幂等主键之一 |
| `card_no/card_lid/member_name` | 会员身份信息 |
| `card_task_lid` | 可选储值消费任务号 |
| `order_op_type` | 区分消费和回款/退款场景 |
| `checkout_time/checkout_by` | 积分规则按业务时间和操作人处理 |
| `consume_give_points` | 本单计算出的应赠积分，用于小票展示 |
| `card_points_after` | 本地预估或 CRM 返回的消费后积分余额，用于小票展示 |

设计要点：

- 小票打印字段是展示口径，不代表 CRM 已落账。
- CRM 是否已落账以本地补偿状态和 CRM 积分流水为准。

### 3.7 支付明细和积分规则表

`dwd_pay`、`biz_pay_way`、`order_pay`、`crm_points_rule` 继续承担积分计算输入职责：

- `dwd_pay`：提供 POS 本地支付方式、支付金额、本金/赠送金拆分、储值支付任务号等。
- `biz_pay_way`：控制普通支付方式是否参与积分。
- `order_pay`：云端/小程序自助结账支付明细，保存积分流水和积分余额展示字段。
- `crm_points_rule`：定义消费积分业务规则开关、会员等级倍率、生日/会员日倍率、可用周期、可用时段、单笔上限、支付方式口径等；这里的开关不是发布灰度开关。

这些表只参与积分计算或展示，不承担积分发放幂等主状态。

### 3.8 `crm_card_record`：CRM 会员卡储值流水表

作用：记录储值余额变动流水，属于会员储值扣款、充值、退款、反结账金额链路。

设计要点：

- 消费积分引擎不直接写 `crm_card_record`。
- 消费积分不写 `crm_card_record.give_point`。
- 金额报表继续读 `crm_card_record`。
- 积分明细报表继续读 `crm_card_points_record`。

## 4. 消费积分正向流程

### 4.1 POS 本地结账链路

入口：`CrmPointsEarnLocalService.grantConsumePointsForCheckout`

流程：

1. POS 账单提交成功后，在事务提交后执行消费积分逻辑。
2. 根据 `dwd_bill` 加载会员身份；没有会员身份则不赠积分。
3. 加载本地同步的 `crm_points_rule`。
4. 按支付明细计算可积分金额：
   - 普通支付方式：看 `biz_pay_way.can_integral`。
   - 会员卡储值支付：本金默认参与；赠送金是否参与由积分规则控制。
   - 积分抵现：不参与。
5. 按积分规则计算 `givePoint`。
6. `givePoint <= 0` 时跳过。
7. 读取可选 `crm_task_lid`，有则作为请求字段传给 CRM；无则留空。
8. 写入或复用 POS 本地 `crm_consume_points_grant`。
9. 调用统一 CRM 消费积分发放接口 `/crm_card_op/grantConsumePointsSign`。
10. CRM 创建或复用 `crm_consume_points_task`。
11. CRM 更新 `crm_card.points/sum_of_points`。
12. CRM 插入 `crm_card_points_record` 正向流水。
13. CRM 更新消费积分任务状态为已发放。
14. POS 本地把 `crm_consume_points_grant.status_` 更新为 `GRANTED`，保存 `grant_points_record_lid`。

### 4.2 云端/小程序自助结账链路

入口目标：云端订单在完成会员消费后调用统一消费积分接口。

流程：

1. 云端订单根据支付明细、会员方案和积分规则计算 `givePoint`。
2. 组装 `CrmCardOpGrantConsumePointsDTO`，`source` 固定为 `ORDER`。
3. 有储值扣款任务时带 `taskLid`；没有时不带。
4. 调用 `/crm_card_op/grantConsumePointsInner`。
5. CRM 落账逻辑和 POS 链路一致。
6. 云端订单保存 `pointsRecordLid/cardPointAfter` 等展示或追踪字段。

## 5. 反结账积分如何退回

### 5.1 POS 本地反结账/退款撤销

入口：`CrmPointsEarnLocalService.revokeConsumePointsForBill`

流程：

1. 反结账或全单退款拿到原 `DwdBill`；本次不处理部分退款、部分撤销。
2. POS 本地按 `mid + bill_lid` 查询 `crm_consume_points_grant`。
3. 状态为 `GRANTED`、`REVOKE_PENDING`、`REVOKE_FAILED` 时，直接进入撤销流程。
4. 状态为 `PENDING`、`GRANT_FAILED` 时，不能直接跳过；POS 必须停止该记录的继续发放，并改为调用统一 CRM 撤销接口 `/crm_card_op/revokeConsumePointsSign`。
5. 请求中带 `source/orderId/cardNo/grantPointsRecordLid/givePoint`，有 `crm_task_lid` 时也带上。
6. CRM 先用 `cardNo` 查到唯一 `cardLid`，再按 `mid + source + orderId + cardLid` 幂等确认并处理原消费积分任务。
7. 如果 CRM 未找到已发放任务，说明云端未落账或已无可撤销积分，返回“无需撤销”结果；POS 本地结束该补偿记录，不再重试发放。
8. 如果 CRM 已有已发放任务，CRM 在同一撤销接口内继续执行撤销，POS 本地转为 `REVOKE_PENDING` 并等待结果。
9. CRM 校验传入的原积分流水号和原赠分值。
10. 如果任务已撤销，直接返回原撤销流水结果。
11. 如果未撤销，按任务表 `grant_points` 扣回积分。
12. CRM 插入 `crm_card_points_record` 负向流水。
13. CRM 更新消费积分任务状态为已撤销。
14. POS 本地更新 `crm_consume_points_grant.status_ = REVOKED`，保存 `revoke_points_record_lid`。

### 5.2 储值金额反结账和积分撤销的边界

储值金额反结账仍由 CardBalance 引擎处理：

- 回退本金余额。
- 回退赠送金余额。
- 写 `crm_card_record`。
- 维护储值消费任务撤销状态。

消费积分撤销由消费积分引擎处理：

- 读取 `crm_consume_points_task.grant_points`。
- 扣减 `crm_card.points`。
- 写 `crm_card_points_record` 负向流水。
- 更新消费积分任务状态。

本次实现不重写 CardBalance 的老撤销逻辑。需要特别区分：

- `CrmCardOpServicePlus.revokeConsumePoints` 是近期新增的消费积分撤销逻辑，不能误判为 CardBalance 老储值金额撤销逻辑。
- `taskLid` 非空时，应保留该方法已有的原赠分流水定位和重复撤销保护。
- `taskLid` 为空时，才使用统一消费积分任务表定位原赠分任务；找不到任务可按无需撤销幂等成功处理。
- 不允许新增独立 POS-only 撤销接口绕开统一入口。

### 5.3 云端订单撤销

云端订单撤销和 POS 反结账使用同一套 CRM 撤销接口：

1. 根据订单号、会员卡号、原积分流水号定位原消费积分任务。
2. 调用 `/crm_card_op/revokeConsumePointsInner`。
3. CRM 执行统一撤销逻辑。
4. 云端订单保存撤销流水号或撤销状态。

## 6. 幂等和重复撤销保护

统一消费积分引擎有三层保护。

### 6.1 CRM 消费积分任务唯一约束

正向发分前，CRM 按以下口径查询或创建任务：

```text
mid + order_id + card_lid
```

如果任务已存在且已发放，直接返回原任务和原积分流水，不重复增加 `crm_card.points`。

### 6.2 POS 本地补偿状态保护

POS 本地状态为 `GRANTED`、`REVOKE_PENDING`、`REVOKE_FAILED` 时不会重复发放。

POS 本地状态为 `REVOKED` 时不会重复发起撤销。

### 6.3 CRM 撤销状态保护

CRM 撤销前先检查消费积分任务状态：

- 已撤销：直接返回原 `revoke_points_record_lid`。
- 已发放：继续撤销。
- 未找到任务：拒绝撤销，避免无原始赠分依据时误扣积分。

即使 POS 或云端重复调用撤销接口，CRM 也不会重复扣减 `crm_card.points`。

## 7. 失败重试和事务边界

### 7.1 POS 本地事务边界

POS 结账事务只负责账单、支付、菜品等本地业务提交。

消费积分发放必须在 POS 账单事务提交成功后执行，避免账单回滚但积分已经发放。

如果 CRM 调用失败：

- 不回滚已成功提交的 POS 账单。
- POS 本地 `crm_consume_points_grant` 标记为 `GRANT_FAILED`。
- 定时补偿任务继续重试。

### 7.2 CRM 云端事务边界

CRM 正向发放在同一事务内完成：

- 创建或复用 `crm_consume_points_task`。
- 更新 `crm_card.points/sum_of_points`。
- 插入 `crm_card_points_record` 正向流水。
- 更新任务 `grant_points_record_lid/status/grant_time`。

CRM 撤销在同一事务内完成：

- 校验原任务和原正向流水。
- 更新 `crm_card.points/sum_of_points`。
- 插入 `crm_card_points_record` 负向流水。
- 更新任务 `revoke_points_record_lid/status/revoke_time`。

任何一步失败，CRM 事务整体回滚。

任务状态只允许以下流转：

| 状态 | 含义 | 允许流转 |
|---|---|---|
| `INIT` | 任务已创建，尚未完成积分流水写入 | `GRANTED` |
| `GRANTED` | 已写正向积分流水并更新积分余额 | `REVOKED` |
| `REVOKED` | 已写负向积分流水并扣回积分余额 | 终态 |

正向发放只允许把 `INIT` 更新为 `GRANTED`。撤销只允许把 `GRANTED` 更新为 `REVOKED`。已是 `GRANTED` 的重复发放直接返回原发放结果，已是 `REVOKED` 的重复撤销直接返回原撤销结果。

### 7.3 POS 本地补偿

定时任务 `retryPendingConsumePointsGrants` 每 60 秒调度一次，处理：

- `PENDING`
- `GRANT_FAILED`
- `REVOKE_PENDING`
- `REVOKE_FAILED`

状态分流：

| 本地状态 | 定时任务动作 | 调用接口 |
|---|---|---|
| `PENDING` | 继续尝试发放消费积分 | `/crm_card_op/grantConsumePointsSign` |
| `GRANT_FAILED` | 上次发放失败，继续重试发放 | `/crm_card_op/grantConsumePointsSign` |
| `REVOKE_PENDING` | 继续尝试撤销已赠积分 | `/crm_card_op/revokeConsumePointsSign` |
| `REVOKE_FAILED` | 上次撤销失败，继续重试撤销 | `/crm_card_op/revokeConsumePointsSign` |
| `GRANTED` | 不扫描、不处理 | 已成功赠分，等待业务触发反结账/退款 |
| `REVOKED` | 不扫描、不处理 | 已完成撤销闭环 |

失败后：

- `retry_count + 1`
- `next_retry_time = 当前时间 + min(60, retry_count * 5) 分钟`
- `last_error_msg` 保存失败原因前 1000 字符
- 超过最大重试次数后保留失败状态，等待人工排查

如果账单已进入反结账或退款流程，补偿任务不得继续发放 `PENDING/GRANT_FAILED` 记录；必须改走 5.1 的云端状态确认和撤销闭环。

## 8. 小票打印口径

POS 小票可打印消费赠分和积分余额，字段主要来自：

| 表/对象 | 字段 | 说明 |
|---|---|---|
| `dwd_bill` | `consume_give_points` | 本单计算出的应赠积分 |
| `dwd_bill` | `card_points_after` | 本次计算或 CRM 返回后的积分余额 |
| `BillInfo` | `consumeGivePoints` | 小票账单信息展示字段 |
| `BillInfo` | `cardPointsAfter` | 小票账单信息展示字段 |
| `dwd_pay` | `card_point_after` | 会员卡支付明细上的积分余额展示 |

注意：

- 打印字段是 POS 本地展示口径。
- CRM 是否已真正落账，要看 `crm_consume_points_grant.status_ = GRANTED`、`crm_consume_points_task.status_` 和 `crm_card_points_record` 正向流水。
- 如果打印显示有应赠积分但 CRM 没有积分流水，优先排查 POS 本地补偿记录和 CRM 消费积分任务。

## 9. 报表影响

### 9.1 会员积分明细

会员积分明细继续以 `crm_card_points_record` 为主要数据源。

新统一消费积分流水会自然进入积分明细报表。

如果报表要按账单号查询或展示，需要补：

```text
crm_card_points_record.order_bill_id
```

### 9.2 会员储值金额报表

会员充值汇总、会员消费汇总、会员储值明细继续读 `crm_card_record`。

统一消费积分引擎不写 `crm_card_record`，因此不会污染储值金额报表。

### 9.3 会员账户详情和 PLUS 汇总

如果现有页面或报表中的积分字段来自 `crm_card_record.give_point`，统一消费积分上线后不会自动体现新积分口径。

后续应把积分统计口径调整为：

```text
crm_card_points_record 按 card_id / order_bill_id / operation_model / amount 汇总
```

## 10. 代码依据和目标改造点

| 位置 | 目标职责 |
|---|---|
| `CrmCardOpController.grantConsumePointsSign/Inner` | 统一消费赠分 API 入口 |
| `CrmCardOpController.revokeConsumePointsSign/Inner` | 统一消费赠分撤销 API 入口 |
| `CrmCardOpGrantConsumePointsDTO` | 支持可选 `taskLid`、可选 `billLid`、必填 `orderId/givePoint/cardNo` |
| `CrmCardOpRevokeConsumePointsDTO` | 支持可选 `taskLid/billLid`，按 `orderId/cardNo` 定位原积分任务 |
| `CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints` | 近期新增的 CRM 消费积分正向和撤销主逻辑；应在这里演进统一能力，或等价迁移其已有保护后再拆 Service |
| `crm_consume_points_task` | CRM 消费积分任务权威表 |
| `CrmPointsEarnLocalService.grantConsumePointsForCheckout` | POS 账单提交后计算并调用统一发分接口 |
| `CrmPointsEarnLocalService.revokeConsumePointsForBill` | POS 反结账/退款调用统一撤销接口 |
| `CrmPointsEarnLocalService.retryPendingConsumePointsGrants` | POS 本地补偿任务 |
| `Nms4CloudCrmService.grantConsumePoints/revokeConsumePoints` | POS 调 CRM 签名接口 |
| `PayOrderServiceImpl` 相关积分逻辑 | 云端/小程序自助结账调用统一消费积分接口 |

明确不再作为新消费积分主逻辑的点：

- 不再新增一套绕过 `CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints` 的消费积分主逻辑。
- `taskLid` 为空链路不再由 `CrmDealTask.givePoint` 承担消费积分幂等状态。
- 不再依赖 CardBalance 撤销消费积分。
- 不新增消费积分引擎额外灰度开关。
- 不新增另一套只服务非储值支付的独立接口分流。

### 10.1 必须删除或替换的本任务过渡实现

以下代码和表属于本任务前序过渡实现，不是老系统兼容对象，最终实现必须删除或替换：

| 对象 | 处理要求 |
|---|---|
| `grantPosConsumePointsSign/Inner`、`revokePosConsumePointsSign/Inner` | 删除接口入口和调用方，统一改为 `grantConsumePointsSign/Inner`、`revokeConsumePointsSign/Inner` |
| `CrmCardOpGrantPosConsumePointsDTO`、`CrmCardOpRevokePosConsumePointsDTO` | 删除 DTO，字段合并到统一 DTO |
| `CrmPosConsumePointsController`、`CrmPosConsumePointsServicePlus` | 删除或改造成统一消费积分 Service，不保留 POS 专用分支 |
| `crm_pos_consume_points_task`、`CrmPosConsumePointsTask*` | 废弃并替换为 `crm_consume_points_task` |
| `g_posConsumePointsEngineEnabled` | 删除配置和判断；业务是否赠分只看 `crm_points_rule` 业务规则 |
| POS 中 `taskLid == null` 走另一套接口的分支 | 删除；`taskLid` 为空也调用统一接口 |

删除完成的验收标准：

- 代码入口唯一：只剩 `grantConsumePoints*` / `revokeConsumePoints*`。
- 任务表唯一：只写 `crm_consume_points_task`。
- POS 调用唯一：只调用 `Nms4CloudCrmService.grantConsumePoints/revokeConsumePoints`。
- 配置唯一：不再存在消费积分发布灰度开关。

## 11. 验收标准

代码实现完成后，至少满足以下场景：

| 场景 | 预期 |
|---|---|
| 储值会员消费有 `taskLid` | 调统一消费积分接口，CRM 校验任务后保留 `CrmCardOpServicePlus` 已有判重保护，写正向积分流水 |
| 现金/微信/支付宝会员消费无 `taskLid` | 调统一消费积分接口，CRM 按订单和会员卡创建积分任务并发分 |
| 同一账单重复补偿发分 | 不重复增加积分，返回原正向流水 |
| 反结账一次 | 按原 `grant_points` 扣回积分，写一条负向流水 |
| 反结账重复触发 | 不重复扣积分，返回原负向流水 |
| 发分调用超时但 CRM 已落账后反结账 | POS 先确认 CRM 任务，再执行撤销，不让积分悬挂 |
| 部分退款或部分撤销 | 本次不支持，必须按整单撤销处理或拒绝进入消费积分撤销 |
| 储值消费反结账 | CardBalance 只处理储值金额；消费赠分撤销保留 `CrmCardOpServicePlus.revokeConsumePoints` 已有原赠分流水校验和重复撤销保护 |
| 小票显示积分但云端失败 | POS 本地补偿记录进入失败状态，定时任务继续重试 |
| 积分明细按账单排查 | `crm_card_points_record.order_bill_id` 可定位原账单 |

## 12. 最终结论

消费积分的核心问题不是积分余额模型，而是责任边界和幂等状态归属。

最终设计：

```text
保留 crm_card.points 作为积分余额。
保留 crm_card_points_record 作为积分明细。
新增或使用 crm_consume_points_task 作为消费积分任务权威表。
储值和非储值消费积分都走同一套消费积分引擎。
CardBalance 只处理储值金额，不处理消费积分。
CrmCardOpServicePlus.grantConsumePoints/revokeConsumePoints 是近期新增的消费积分主逻辑，统一化必须在这套逻辑上演进或等价迁移其保护。
taskLid 为空的非储值链路不依赖 CrmDealTask.givePoint。
```
