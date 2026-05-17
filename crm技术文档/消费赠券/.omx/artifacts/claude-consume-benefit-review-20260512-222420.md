# Claude 消费权益架构评审

## Original user task
阅读 5 份消费赠券/消费权益中心文档，使用多 agent 进行评审。

## Final prompt sent to Claude CLI

```text
请作为独立 Claude Code 架构评审者，只读评审以下 5 份 nms4cloud CRM 消费赠券/消费权益中心设计文档。请输出中文，按 CRITICAL/HIGH/MEDIUM/LOW 排序，给出问题、风险、证据、建议，并给出最终 Architecture Status: CLEAR/WATCH/BLOCK。

重点检查：
1. 文档之间是否自洽，是否存在“消费赠券企业级设计”和“消费赠券+赠现金统一底座”之间的边界冲突。
2. Inbox/Outbox、业务幂等键、任务状态机、补偿、撤销/反结账、规则快照是否完整。
3. 是否保留老逻辑、是否适合 nms4cloud CRM 现有分层和规范。
4. 是否遗漏 POS/线上订单生命周期、多会员/拆单、门店 sid 隔离、外部签名入口重放、现金冲正财务策略。
5. 是否存在过度设计或阶段落地顺序不合理。

文档路径：
- D:\mywork\techdoc\crm技术文档\消费赠券\会员消费赠券-业务设计架构评审.md
- D:\mywork\techdoc\crm技术文档\消费赠券\消费后立即赠券与赠现金统一底座设计.md
- D:\mywork\techdoc\crm技术文档\消费赠券\消费权益中心架构建议.md
- D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券企业级架构设计.md
- D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券最终结果说明.md

补充代码证据：
- 图谱已更新：D:\mywork\nms4cloud，last_updated=2026-05-12T22:17:18，60893 nodes。
- PayOrderServiceImpl.java:909-910 sendShare(order) 执行，但 sendConsumeCoupon(order, orderPayList) 被注释。
- CrmConsumerCouponQueueConsumer.java:237-248 直接调用 couponOpAdd 发券，250-252 捕获异常只打日志且 throw e 被注释。
- CrmCouponOpServicePlus.java:101-153 couponOpAdd 要求 orderId/channel/cardLid，但未见消费赠券专属任务幂等；300-318 发券明细只落 getChannel 和 orderBillId。
- CrmCouponOpServicePlus.java:55-73 couponOpRevoke 按 mid/phone/coupon/orderId/status 更新，未按 sid/getChannel 收口。
- CrmConsumptionCouponRuleServicePlus.java:227-230 删除规则后按 CrmConsumptionCouponLimit.lid in request.lids 删除限制，但限制关联规则字段是 ruleLid。
```

## Claude output (raw)

```text
D:\.omx\artifacts\claude-claude-code-5-nms4cloud-crm-critical-high-medium-low-archite-2026-05-12T14-29-26-311Z.md
```

## Concise summary

D:\.omx\artifacts\claude-claude-code-5-nms4cloud-crm-critical-high-medium-low-archite-2026-05-12T14-29-26-311Z.md

## Action items / next steps

待主代理综合多代理结论。
