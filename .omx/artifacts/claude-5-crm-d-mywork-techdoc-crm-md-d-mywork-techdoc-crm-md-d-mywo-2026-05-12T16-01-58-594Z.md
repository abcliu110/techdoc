# claude advisor artifact

- Provider: claude
- Exit code: 0
- Created at: 2026-05-12T16:01:58.594Z

## Original task

请对以下 5 份设计文档做架构/设计评审，重点检查契约一致性、幂等、状态机、反结账回收、CRM 落地规范、迁移风险。请输出阻断问题/建议/结论，不要泛泛总结。

文档：
D:\mywork\techdoc\crm技术文档\消费赠券\会员消费赠券-业务设计架构评审.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费后立即赠券与赠现金统一底座设计.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费权益中心架构建议.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券企业级架构设计.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券最终结果说明.md

已知收敛口径：
- 主契约为《消费后立即赠券与赠现金统一底座设计》
- 幂等键：mid + sid + originSource + originLifecycleId + eventType + outOrderId + cardLid
- originSource: ONLINE_ORDER / POS_CLEAR
- deliverySource: NORMAL / MANUAL_REPLAY / SYSTEM_RETRY
- 固定字段使用枚举：CrmConsumeBenefitEventTypeEnum、CrmConsumeBenefitOriginSourceEnum、CrmConsumeBenefitDeliverySourceEnum、CrmConsumeBenefitEventStatusEnum、CrmConsumeCouponTaskStatusEnum、CrmConsumeCashTaskStatusEnum、CrmConsumeRevokeStrategyEnum
- CRM 命名使用 Crm...ServicePlus / Mapper / DTO / VO，不新增 Repository/ApplicationService 分层

## Final prompt

请对以下 5 份设计文档做架构/设计评审，重点检查契约一致性、幂等、状态机、反结账回收、CRM 落地规范、迁移风险。请输出阻断问题/建议/结论，不要泛泛总结。

文档：
D:\mywork\techdoc\crm技术文档\消费赠券\会员消费赠券-业务设计架构评审.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费后立即赠券与赠现金统一底座设计.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费权益中心架构建议.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券企业级架构设计.md
D:\mywork\techdoc\crm技术文档\消费赠券\消费赠券最终结果说明.md

已知收敛口径：
- 主契约为《消费后立即赠券与赠现金统一底座设计》
- 幂等键：mid + sid + originSource + originLifecycleId + eventType + outOrderId + cardLid
- originSource: ONLINE_ORDER / POS_CLEAR
- deliverySource: NORMAL / MANUAL_REPLAY / SYSTEM_RETRY
- 固定字段使用枚举：CrmConsumeBenefitEventTypeEnum、CrmConsumeBenefitOriginSourceEnum、CrmConsumeBenefitDeliverySourceEnum、CrmConsumeBenefitEventStatusEnum、CrmConsumeCouponTaskStatusEnum、CrmConsumeCashTaskStatusEnum、CrmConsumeRevokeStrategyEnum
- CRM 命名使用 Crm...ServicePlus / Mapper / DTO / VO，不新增 Repository/ApplicationService 分层

## Raw output

```text


现在对五份文档做逐项契约对照评审。

---

# 消费赠券设计文档架构评审报告

**主契约**：《消费后立即赠券与赠现金统一底座设计》（下称"主设计"）
**收敛口径**：幂等键 `mid + sid + originSource + originLifecycleId + eventType + outOrderId + cardLid`；`deliverySource` 不参与幂等

---

## 一、契约一致性（阻断）

### 🔴 阻断 1：撤销任务唯一键缺少 `outOrderId`

| 文档 | 唯一键 |
|---|---|
| 主设计 | `mid + sid + origin_source + origin_lifecycle_id + event_type + card_lid + order_id + deleted` |
| 企业级架构设计（9.1 节） | `mid + sid + origin_source + origin_lifecycle_id + event_type + grant_task_lid + deleted` |

**问题**：撤销任务（REVOKE）唯一键中缺少 `out_order_id` 和 `card_lid`。

- 同一笔消费、同一个 `origin_lifecycle_id`，在多会员卡 / 多账单 / 多次补偿重放场景下，可能命中同一撤销任务，导致重复撤销或互相覆盖。
- 没有 `card_lid` 意味着同一 `origin_lifecycle_id` 下多张会员卡的撤销无法区分。
- 没有 `out_order_id` 意味着同一生命周期 ID 内多张订单的撤销无法区分。

**修正建议**：撤销任务唯一键应与发放任务一致，改为：
```sql
uk_consume_coupon_revoke:
mid + sid + origin_source + origin_lifecycle_id + event_type + card_lid + out_order_id + deleted
```
`event_type` 在撤销任务中固定为 `CONSUME_REVOKED`，但保留字段以保证唯一性。

---

### 🔴 阻断 2：撤销事件接口缺少 `delivery_source`

| 文档 | 字段 |
|---|---|
| 主设计 18.2 节 `CrmConsumeBenefitRevokeDTO` | 包含 `originSource`、`deliverySource`、`mid`… |
| 企业级架构设计 7.1 节撤销事件 | 列出 `eventId` / `origin_source` / `delivery_source` / `mid` / `sid` / …（字段名不一致） |
| 消费赠券最终结果说明 6 | "deliverySource 只作为 deliverySource" |

**问题**：

1. 主设计 `CrmConsumeBenefitRevokeDTO` 明确要求 `delivery_source`，但企业级架构设计 7.1 节撤销事件示例（`ConsumeCouponRevokeEvent`）的字段列表中 `delivery_source` 未出现在正文描述里。
2. 主设计要求 "所有事件入口统一 `POST`"，而企业级架构设计 7.1 节示例中没有明确说明 HTTP 方法。
3. `delivery_source` 在撤销流程中参与"是重放还是正常撤销"的业务判断，不能缺失。

**修正建议**：撤销事件接口应显式包含 `delivery_source`（`NORMAL` / `MANUAL_REPLAY` / `SYSTEM_RETRY`），并在字段级约束中说明不参与幂等，只参与业务路由。

---

### 🔴 阻断 3：字段命名风格未统一

| 位置 | 当前写法 | 主设计要求 |
|---|---|---|
| 企业级架构设计 5.1 节任务表 | `out_order_id` | `outOrderId` |
| 企业级架构设计 5.1 节任务表 | `origin_lifecycle_id` | `originLifecycleId` |
| 企业级架构设计 5.1 节任务表 | `event_type` | `eventType` |
| 企业级架构设计 5.1 节任务表 | `card_lid` | `cardLid` |
| 企业级架构设计 7.1 节撤销事件 | `origin_lifecycle_id` | `originLifecycleId` |
| 企业级架构设计 7.1 节撤销事件 | `revoke_lifecycle_id` | `revokeLifecycleId` |

**问题**：企业级架构设计文档在任务表字段和事件字段中混用 snake_case，与主设计明确的 camelCase 不一致。代码落地后若按文档字段名直接建表，会与主契约产生语义偏差。

**修正建议**：全文统一使用 camelCase，所有代码落地字段与主设计保持一致。

---

### 🔴 阻断 4：`revokeStatus` 枚举值不完整

| 文档 | 列出的值 |
|---|---|
| 主设计 9.2 节赠券明细表 | `NOT_REQUIRED / REVOKED / REVOKE_FAILED / USED_CANNOT_REVOKE` |
| 企业级架构设计 5.2 节明细表 | `PENDING / USED / REVOKED / REVOKE_FAILED / COMPENSATION_REQUIRED` |

**问题**：

- 主设计明确 `revokeStatus` 的四个枚举值，企业级架构设计给出了五个且语义不匹配（`PENDING` / `COMPENSATION_REQUIRED` 不在主设计中）。
- `USED_CANNOT_REVOKE` 在企业级架构设计中没有对应枚举值，只出现在 7.3 节策略表格描述中。
- 两份文档在枚举值上的分歧会导致代码落地时的状态语义混淆。

**修正建议**：以主设计为基准：
```
revokeStatus: NOT_REQUIRED / REVOKED / REVOKE_FAILED / USED_CANNOT_REVOKE
```
新增 `USED_CANNOT_REVOKE` 状态，明确其语义为"券已核销，无法自动回收，需进入人工处理"，不得静默返回成功。

---

### 🟡 高风险 1：消费赠券最终结果说明中的幂等键与主设计不一致

| 文档 | 幂等键 |
|---|---|
| 主设计 7.3 节 | `mid + sid + originSource + originLifecycleId + eventType + outOrderId + cardLid` |
| 最终结果说明 4.3 节 | `mid + sid + originSource + originLifecycleId + eventType + outOrderId + cardLid` |

这两份文档在该字段上是一致的，无问题。但 **最终结果说明 6** 提到 "deliverySource 只作为 deliverySource"，表述不够精确。应明确为：`deliverySource` 不参与幂等键，只作为投递来源标记。

---

### 🟡 高风险 2：架构建议文档与主设计存在字段名不一致

消费权益中心架构建议（第 146 条）提到 `origin_source` / `delivery_source` / `origin_lifecycle_id` / `sid` 应与主设计保持一致，但未同步更新为 camelCase。若后续实现者直接引用该文档建表，会产生 snake_case 字段名与主设计不匹配的问题。

---

## 二、幂等设计

### ✅ 一致：通过

| 检查项 | 主设计 | 企业级架构设计 | 最终结果说明 |
|---|---|---|---|
| 幂等键字段组合 | ✅ | ✅（5.1 节任务表唯一键） | ✅ |
| 幂等键不含 delivery_source | ✅ | ✅ | ✅ |
| Inbox 按业务键去重，不依赖 MQ messageId | ✅（8.3 节） | ✅（5.3 节） | ✅（3.2 节） |
| Outbox 状态：PENDING → SENT / FAILED | ✅（8.2 节） | ✅（5.3 节） | ✅（3.1 节） |
| Inbox 状态：RECEIVED → DONE / FAILED | ✅（8.3 节） | ✅（5.3 节） | ✅（3.3 节） |
| 幂等键不含 delivery_source | ✅ | ✅ | ✅ |

**结论**：幂等设计在主设计、企业级架构设计、最终结果说明三份文档中一致。无阻断问题，但需注意企业级架构设计 5.1 节的任务唯一键中 `out_order_id` 应改为 `outOrderId`（命名风格问题，见阻断 3）。

---

## 三、状态机

### ✅ 底座事件状态：一致

```
RECEIVED → DISPATCHING → DISPATCHED → DONE
                              → PARTIAL_FAILED
                              → FAILED
```

主设计 11.1 节、企业级架构设计 10.1 节（《消费赠券企业级架构设计》10.1 节图示）一致。

### ⚠️ 赠券任务状态：语义一致，但命名有歧义

| 主设计 11.2 节 | 企业级架构设计 10.1 节 |
|---|---|
| PROCESSING → SUCCEEDED / FAILED / REVOKE_PENDING_GRANT / REVOKING → REVOKED / REVOKE_FAILED | PROCESSING → SUCCEEDED / FAILED / REVOKE_PENDING_GRANT / REVOKING → REVOKED / REVOKE_FAILED |

**无阻断问题**。两处状态流一致。

但需注意：主设计 11.2 节的状态机从 `PROCESSING` 出发，列出了 `REVOKING` 作为中间态，企业级架构设计 10.1 节用同一条路径描述。两者在状态命名和转换路径上无歧义，可以合并为一份状态说明文档。

### ⚠️ 赠现金任务状态：一致

```
PROCESSING → SUCCEEDED / FAILED / REVERSE_PENDING_GRANT / REVERSING → REVERSED / REVERSE_FAILED
```

主设计 11.3 节与企业级架构设计 10.1 节（cash 部分）一致。

### 🟡 状态机缺失说明：状态收敛矩阵未落地

主设计 11.4 节给出了底座与子域状态收敛矩阵，但没有文档明确说明：
- 当底座为 `PARTIAL_FAILED` 时，赠券失败但赠现金成功的情况下，底座如何感知子域状态并更新？
- 当 `coupon_status = FAILED` 且 `cash_status = SUCCEEDED` 时，`PARTIAL_FAILED` 是否由调度器主动更新，还是由子域回调触发？

建议在实现设计中补充"状态收敛写入时机"的触发规则，避免底座状态与子域状态漂移。

---

## 四、反结账回收

### 🔴 阻断 5：已使用券的回收策略枚举不完整

| 文档 | 策略 |
|---|---|
| 主设计 13 节 | `BLOCK` / `EXCEPTION`（业务确认点：是否阻断） |
| 消费权益中心架构建议 7.3 节 | `BLOCK` / `EXCEPTION` / `PARTIAL_COMPENSATE` |
| 企业级架构设计 7.3 节 | `BLOCK` / `EXCEPTION` / `PARTIAL_COMPENSATE` |

**问题**：

- 主设计将 `PARTIAL_COMPENSATE` 列为"需要业务确认"的决策项，企业级架构设计和架构建议文档已直接作为确定策略写入。
- 如果业务尚未确认 `PARTIAL_COMPENSATE` 的具体执行方式（如何生成负向权益？补偿记录写到哪里？谁审批？），直接进入实现会产生不确定性。

**修正建议**：明确标注 `PARTIAL_COMPENSATE` 为"待业务确认"，实现时用开关或枚举控制策略扩展，不得在业务未确认前默认选此策略。

---

### 🟡 高风险 3：撤销任务创建时的并发处理说明不足

主设计 12.2 节（"撤销只对原任务明细执行一次"）和企业级架构设计 7.2 节（"如果原任务不存在，创建 REVOKE_PENDING_GRANT 状态"）均提到了 `REVOKE_PENDING_GRANT` 挂起态，但：

1. 未明确"撤销请求先到、发放事件后到"场景下的状态轮转路径：撤销任务创建 → 原发放任务到达 → 挂起态变更为正常态 → 撤销继续执行。
2. 未定义挂起态的最大等待时间，超过后是否生成异常单。
3. 未明确在 `REVOKE_PENDING_GRANT` 期间，如果原发放任务也进入失败状态，撤销任务如何处理。

**建议**：补充状态机扩展路径：
```
REVOKE_PENDING_GRANT
  → GRANT_SUCCEEDED → 自动触发撤销（REVOKING → REVOKED）
  →

```

## Concise summary

Provider completed successfully. Review the raw output for details.

## Action items

- Review the response and extract decisions you want to apply.
- Capture follow-up implementation tasks if needed.
