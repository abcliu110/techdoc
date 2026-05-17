# CRM 消费积分 event 表作用说明

日期：2026-05-13  
状态：说明文档

## 1. 先给结论

`crm_consume_points_event` 是消费积分链路的动作流水表、审计表、排障表。

它记录的是“做过什么、做成了没有、失败了什么”，不是“当前积分权益现在是什么状态”。

真正的状态源还是：

- `crm_consume_points_session`
- `crm_consume_points_round`

`event` 只负责把过程留下来，方便回放、追查、排障和人工核对。

## 2. 这张表到底记什么

表结构里最关键的字段是：

| 字段 | 作用 |
|---|---|
| `session_lid` | 归属哪一个消费积分生命周期 |
| `round_lid` | 归属哪一轮权益 |
| `event_type` | 发生了什么动作 |
| `status_` | 这条事件本身的结果 |
| `payload_json` | 事件附带的业务内容 |
| `error_msg` | 失败原因 |

代码里给 `session_lid` 和 `round_lid` 都建了索引，说明它就是按生命周期和轮次来查历史的。[CrmConsumePointsEvent.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmConsumePointsEvent.java:22)

## 3. 它记录哪些动作

当前代码里的事件类型主要有：

- `SESSION_CREATED`
- `ROUND_CREATED`
- `GRANT_CALLED`
- `REVOKE_CALLED`
- `ROUND_STATUS_CHANGED`

这些事件把“生命周期开始、轮次创建、调 CRM 发分、调 CRM 撤销、轮次状态变化”串成完整链路。[CrmConsumePointsEventTypeEnum.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsEventTypeEnum.java:13)

## 4. 它为什么重要

### 4.1 还原时间线

同一张单、同一张会员卡，在反复结账、反结账、回包晚到、补偿重试时，只看 `round` 很难还原过程。

`event` 可以把“先做了什么、后做了什么、哪一步失败了”完整记下来。

### 4.2 排障

外部 CRM 调用成功还是失败、请求带了什么、失败原因是什么，都能从 `event` 里看到。

### 4.3 审计

出了积分争议，可以按 `session_lid` 或 `round_lid` 把整条过程翻出来看。

## 5. 它不负责什么

`event` 不负责推进状态机。

代码里是先更新 `session/round`，再插入 `event`；`recordEvent(...)` 失败时只会记日志，不会反过来改 `round` 状态。[CrmPointsEarnLocalService.java](D:/mywork/nms4pos/nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/points/CrmPointsEarnLocalService.java:1893)

所以：

- `round.status` 才是当前状态
- `event.status_` 只是事件本身的结果
- `event` 不能当状态裁判

## 6. 用一句话记

**`round` 管现在，`event` 管过程。**

## 7. 你那个反复结账场景里，它怎么用

以 `100 -> 反结账 -> 200 -> 反结账 -> 150` 为例：

- 每次新 round 创建时，会写一条 `ROUND_CREATED`
- 每次调 CRM 发分，会写一条 `GRANT_CALLED`
- 每次反结账触发撤销，会写一条 `REVOKE_CALLED`
- 每次 round 状态变化，会写一条 `ROUND_STATUS_CHANGED`

这样同一个 `session` 下会出现多条 `event`，但 `round` 仍然只保存当前这轮的状态快照。

## 8. 排查时怎么用

优先顺序建议是：

1. 先看 `session`，确认当前生命周期有没有闭环
2. 再看 `round`，确认当前活跃轮次是什么状态
3. 最后看 `event`，回放每一步做了什么

如果你只想知道“现在积分应该算到哪一步”，看 `round`。

如果你想知道“中间为什么会这样”，看 `event`。
