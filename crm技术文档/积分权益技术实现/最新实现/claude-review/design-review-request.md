# 会员消费积分重构最终设计评审请求

请作为架构评审者，对本次会员消费积分重构做设计评审。只读代码和文档，不要修改文件。

## 设计目标

```text
1. POS 侧建立独立消费积分生命周期：session / round / event。
2. round.lid 作为 CRM lifecycleId。
3. CRM 侧不关心 POS 状态机，只做 GRANT / REVOKE 幂等账务任务。
4. crm_card_points_record 是积分账本事实，crm_card.points 是余额投影。
5. REVOKE 写负向流水，并关联原正向流水。
6. 第 7 点旧储值链路不动：老 CardBalanceService / CrmDealTask.givePoint 保留。
```

## 当前关键契约

```text
POS:
- session 唯一键：mid + source + bill_lid + card_lid + deleted。
- round 唯一键：session_lid + round_no + deleted。
- 每次退款重算创建新 round，老 round 先撤销再发新 round。
- event 只做弱审计，不作为强幂等依据。

CRM:
- task 唯一键：company_id + source_ + lifecycle_id + task_type + task_lid + card_lid + order_id + deleted。
- 新 POS 链路 task_lid 传空，CRM 归一为 0。
- 旧储值链路有 taskLid，仍走旧分支。
- GRANT 成功写正向积分流水；REVOKE 成功写负向积分流水，并关联原正向流水。
```

## 评审问题

```text
0. 最新补充的代码注释是否把企业级设计的不变量讲清楚：POS session/round/event 边界、CRM task/ledger 边界、退款必须按原 round 快照撤销/重发、event 只是弱审计、唯一键冲突必须回读；是否有注释与设计不一致？
1. 这个边界是否足以解决重复赠分？
2. 这个边界是否足以解决重复撤销？
3. 退款重算时，POS round 替换 + CRM revoke/grant 是否存在明显错账窗口？
4. CRM 不感知 POS 生命周期，只按 lifecycleId 做账务幂等，这个边界是否清晰？
5. task_lid 放入 CRM 唯一键作为兼容维度是否合理？是否破坏新 POS lifecycleId 主锚点？
6. session 主要作为 bill/card 聚合壳，round 承担真实轮次状态，这个设计是否可接受？
7. 当前未实现单独投影器，而是在 grant/revoke 事务内直接更新 crm_card.points，是否可接受？
8. 哪些风险必须在上线前补，哪些可以后续迭代？
```

## 参考文件

```text
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\01-会员消费积分企业级重做方案.md
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\02-DDL与状态机契约.md
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\03-实现任务与测试清单.md
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\points\CrmConsumePointsServicePlus.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\card\CrmCardOpServicePlus.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\points\CrmPointsEarnLocalService.java
```

## 输出要求

请把评审结论写入：

```text
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\claude-review\design-review-result.md
```

输出格式：

```text
# Claude Design Review Result

## 阻断设计问题
- 如无，写“无”。

## 高风险设计问题
- 如无，写“无”。

## 观察项
- 可以上线但需要关注的设计债。

## 必须补齐
- 上线前必须补的测试、约束或实现。

## 结论
- CLEAR / WATCH / BLOCKED 三选一，并说明理由。
```
