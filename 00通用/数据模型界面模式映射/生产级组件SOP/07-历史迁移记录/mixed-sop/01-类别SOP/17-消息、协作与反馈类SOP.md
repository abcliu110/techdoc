# 17 消息、协作与反馈类生产级组件类别 SOP

> 组件数：20
>
> 关注域：消息身份、对象版本、离线队列、冲突、通知范围与审计
>
> 风险初始分布：R1 0 / R2 19 / R3 1

本类别 SOP 继承[组件 SOP 治理与认证规则](../00-治理总纲/组件SOP治理与认证规则.md)。风险分布是基于现有原型事实的暂定结果，不是最终认证。

## 1. 类别不变量

- 每个组件首先守住自己的 catalog 不变量和适用边界。
- 类别核心关注：消息身份、对象版本、离线队列、冲突、通知范围与审计。
- 类别状态模型：连接、会话、消息/批注 ID、发送状态、对象版本、离线队列、冲突与已读状态。
- 不能用统一壳层的“开始/异常/恢复”动作代替组件自己的状态转换。

## 2. 专属失败模式

- 网络中断、重复发送或乱序到达
- 对象版本冲突、草稿丢失或合并错误
- 通知无权接收者、敏感内容泄露或审计链不完整

## 3. 强制验证

- 验证客户端生成稳定幂等 ID、乱序、重复和离线重放
- 验证版本冲突、草稿恢复、权限变化和合并结果
- 验证实时区域播报、焦点不被远端更新抢夺及敏感内容不泄露

## 4. 性能与规模基线

以 10,000 条消息、100 个并发协作者和 1,000 个离线待重放动作的逻辑基准；输入反馈 p95 不高于 100ms。

Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。

## 5. 风险升级规则

涉及凭证、安全审计、不可抵赖记录或跨租户协作时为 R3；其他协作默认至少 R2。

风险只能向上调整。任何组件命中权限、多租户、敏感数据、金额、库存、订单、支付、不可逆操作或跨系统一致性，都必须按 R3 执行。

## 6. 组件清单

| 组件 | 组件键 | B/C | 暂定风险 | 状态 |
|---|---|---:|---:|---|
| [即时聊天](../02-组件SOP/17-消息、协作与反馈类/17-instant-chat.md) | `17:instant-chat` | B | R2 | Draft / 未认证 |
| [会话列表](../02-组件SOP/17-消息、协作与反馈类/17-conversation-list.md) | `17:conversation-list` | B | R2 | Draft / 未认证 |
| [评论组件](../02-组件SOP/17-消息、协作与反馈类/17-comments.md) | `17:comments` | B | R2 | Draft / 未认证 |
| [楼层回复](../02-组件SOP/17-消息、协作与反馈类/17-threaded-replies.md) | `17:threaded-replies` | B | R2 | Draft / 未认证 |
| [文档批注](../02-组件SOP/17-消息、协作与反馈类/17-document-annotation.md) | `17:document-annotation` | B | R2 | Draft / 未认证 |
| [图片批注](../02-组件SOP/17-消息、协作与反馈类/17-image-annotation.md) | `17:image-annotation` | B | R2 | Draft / 未认证 |
| [@成员选择器](../02-组件SOP/17-消息、协作与反馈类/17-mention-picker.md) | `17:mention-picker` | B | R2 | Draft / 未认证 |
| [消息中心](../02-组件SOP/17-消息、协作与反馈类/17-message-center.md) | `17:message-center` | B | R2 | Draft / 未认证 |
| [通知中心](../02-组件SOP/17-消息、协作与反馈类/17-notification-center.md) | `17:notification-center` | B | R2 | Draft / 未认证 |
| [实时在线状态](../02-组件SOP/17-消息、协作与反馈类/17-online-presence.md) | `17:online-presence` | B | R2 | Draft / 未认证 |
| [协作光标](../02-组件SOP/17-消息、协作与反馈类/17-collaborative-cursor.md) | `17:collaborative-cursor` | B | R2 | Draft / 未认证 |
| [多人协同编辑](../02-组件SOP/17-消息、协作与反馈类/17-collaborative-editing.md) | `17:collaborative-editing` | B | R2 | Draft / 未认证 |
| [修改冲突处理器](../02-组件SOP/17-消息、协作与反馈类/17-conflict-resolver.md) | `17:conflict-resolver` | B | R2 | Draft / 未认证 |
| [活动时间线](../02-组件SOP/17-消息、协作与反馈类/17-activity-timeline.md) | `17:activity-timeline` | B | R2 | Draft / 未认证 |
| [操作日志](../02-组件SOP/17-消息、协作与反馈类/17-operation-log.md) | `17:operation-log` | B | R2 | Draft / 未认证 |
| [审计轨迹](../02-组件SOP/17-消息、协作与反馈类/17-audit-trail.md) | `17:audit-trail` | B | R3 | Draft / 未认证 |
| [工单对话组件](../02-组件SOP/17-消息、协作与反馈类/17-ticket-conversation.md) | `17:ticket-conversation` | B | R2 | Draft / 未认证 |
| [消息模板编辑器](../02-组件SOP/17-消息、协作与反馈类/17-message-template.md) | `17:message-template` | B | R2 | Draft / 未认证 |
| [消息订阅配置器](../02-组件SOP/17-消息、协作与反馈类/17-subscription-config.md) | `17:subscription-config` | B | R2 | Draft / 未认证 |
| [离线消息与重连面板](../02-组件SOP/17-消息、协作与反馈类/17-offline-reconnect.md) | `17:offline-reconnect` | B | R2 | Draft / 未认证 |
