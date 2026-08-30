# CRM 消费积分设计实现文档

日期：2026-08-28
作者：guoyun_liu
状态：已实现

## 1. 背景与目标

POS 会员结账后需要赠送积分，旧链路依赖 `crm_deal_task.give_point` 作为消费积分幂等状态，导致：
1. 无储值消费（现金/微信/支付宝）无法可靠赠积分
2. 同一笔消费重复结账/反结账时可能重复赠分或漏赠分
3. 积分任务和储值金额任务混用同一张表，职责不清

本设计目标：**消费积分统一由来源、生命周期、账单、订单和会员卡决定幂等，不再依赖储值扣款任务号。POS 和云端订单共用同一套积分引擎。**

## 2. 核心架构

```
POS 结账 / 云端订单完成
  → 调用统一积分接口
  → CrmConsumePointsServicePlus.grantConsumePoints()
    → findTask() 幂等查询
    → saveProcessingOrReturnExisting() 占位任务
    → 更新 crm_card.points（原子加）
    → 写入 crm_card_points_record 积分流水
    → 标记任务为 SUCCEEDED

POS 反结账 / 云端订单退款
  → CrmConsumePointsServicePlus.revokeConsumePoints()
    → 按 lifecycleId + orderId + cardLid 定位原任务
    → 写入 crm_card_points_record 负向流水
    → 扣减 crm_card.points（原子减）
    → 标记任务为 REVOKED
```

## 3. 表结构

### 3.1 `crm_consume_points_task`（统一消费积分任务表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | 门店 ID |
| `lid` | BIGINT | 业务逻辑主键（雪花算法） |
| `source_` | ENUM | **积分来源**：POS，云端订单 |
| `task_lid` | BIGINT | 历史兼容：固定为 0，不再作为积分幂等键 |
| `bill_lid` | BIGINT | POS 账单 LID（可为空） |
| `order_id` | VARCHAR | **消费订单号**，幂等键组成部分 |
| `lifecycle_id` | BIGINT | 消费生命周期 ID，幂等键组成部分 |
| `task_type` | ENUM | **任务类型**：GRANT-发放，REVOKE-撤销 |
| `card_lid` | BIGINT | 会员卡 LID |
| `card_no` | VARCHAR | 会员卡号 |
| `points` | DECIMAL(18,4) | 本次赠送/撤销的积分数量 |
| `target_points_record_lid` | BIGINT | 目标积分流水 LID（撤销时指向原正向流水） |
| `produced_points_record_lid` | BIGINT | 本次产生的积分流水 LID |
| `status_` | ENUM | **状态**：PROCESSING-处理中，SUCCEEDED-成功，FAILED-失败 |
| `operator` | VARCHAR | 操作人 |
| `comment` | VARCHAR | 备注 |
| `executed_time` | DATETIME | 执行时间 |
| `revision` | INT | 乐观锁版本号 |
| `created_by/created_time/updated_by/updated_time/deleted` | — | 标准审计字段 |

幂等键：`mid + source_ + lifecycle_id + task_type + bill_lid + card_lid + order_id`

### 3.2 `crm_card_points_record`（积分流水表，已有）

消费积分相关字段：

| 字段 | 类型 | 含义 |
|------|------|------|
| `company_id/shop_id` | BIGINT | 商户/门店 |
| `card_id` | VARCHAR | 会员卡 LID 字符串 |
| `card_id_alias` | VARCHAR | 会员卡号 |
| `operation_model` | ENUM | `Consume`（消费赠分），`CancelOrder`（撤销赠分） |
| `balance_before` | DECIMAL | 变动前积分余额 |
| `amount` | DECIMAL | 本次积分变动值；正向为正，撤销为负 |
| `balance_after` | DECIMAL | 变动后积分余额 |
| `order_bill_id` | VARCHAR | 关联订单号，用于账单关联和报表查询 |

### 3.3 `crm_card`（会员卡主表，已有）

| 字段 | 类型 | 含义 |
|------|------|------|
| `points` | DECIMAL | 当前可用积分余额；正向加，撤销减 |
| `sum_of_points` | DECIMAL | 累计积分（正向增，撤销减） |

## 4. API 设计

### 4.1 正向发放积分

调用方：POS 结账 afterCommit / 云端订单完成

```java
CrmCardOpGrantConsumePointsDTO request = new CrmCardOpGrantConsumePointsDTO();
request.setMid(mid);
request.setSid(sid);
request.setSource(CrmConsumePointsSourceEnum.POS);  // 或 ORDER
request.setOrderId(orderId);
request.setCardNo(cardNo);
request.setGivePoint(givePoint);  // 本次应赠积分（必须 > 0）
```

### 4.2 撤销积分

```java
CrmCardOpRevokeConsumePointsDTO request = new CrmCardOpRevokeConsumePointsDTO();
request.setMid(mid);
request.setSid(sid);
request.setSource(CrmConsumePointsSourceEnum.POS);
request.setOrderId(orderId);
request.setCardNo(cardNo);
request.setLifecycleId(lifecycleId);  // 定位原任务
```

## 5. 幂等与事务设计

### 5.1 幂等键组成

```
mid + source_ + lifecycle_id + task_type + bill_lid + card_lid + order_id
```

### 5.2 PROCESSING 占位任务机制

正向发放流程：

```
1. findTask() 查询是否已存在 GRANT 任务
   → 存在且 SUCCEEDED → 返回原结果（幂等）
   → 存在且 PROCESSING → 返回"正在处理"

2. saveProcessingOrReturnExisting() 尝试插入 PROCESSING 占位任务
   → 插入成功 → 继续
   → 唯一键冲突 → 回读既有任务（可能是并发请求）

3. 原子加积分 + 写正向流水 + 标记 SUCCEEDED
   （同一事务内任一步失败整体回滚）
```

撤销流程：

```
1. findTask() 查询原 GRANT 任务
   → 不存在 → 抛异常"消费赠分任务尚未生成，稍后重试撤销"
   → 存在但 FAILED → 拒绝撤销
   → 存在且 SUCCEEDED → 继续

2. 写入 REVOKE 负向任务（PROCESSING）

3. 原子减积分 + 写负向流水 + 标记 REVOKE SUCCEEDED
   （同一事务内任一步失败整体回滚）
```

### 5.3 撤销时找不到任务不能返回成功

POS 反结账可能先于正向积分事务提交到达 CRM。如果撤销时找不到 GRANT 任务就返回成功，POS 会把本地 round 标记为已完成，随后正向赠分成功后就不会再被撤销。因此找不到任务时抛出可重试异常，让 POS 继续补偿。

## 6. 与储值金额引擎的边界

| 职责 | 引擎 |
|------|------|
| 储值余额变动（充值、消费、退款） | `CrmCardOpServicePlus` / CardBalance |
| **消费积分变动（赠分、撤销）** | **`CrmConsumePointsServicePlus`** |
| 储值任务表 | `crm_deal_task` |
| **积分任务表** | **`crm_consume_points_task`** |
| 储值流水 | `crm_card_record` |
| **积分流水** | **`crm_card_points_record`** |
| 会员积分余额 | `crm_card.points` |

消费积分**不写** `crm_deal_task`，**不写** `crm_card_record`。

## 7. 负向积分流水追溯链

撤销时写入的负向积分流水，通过 `target_points_record_lid` 指向原正向积分流水，实现双向追溯：

```
crm_consume_points_task (SUCCEEDED, task_type=GRANT)
  → produced_points_record_lid = 正向流水 lid

crm_consume_points_task (SUCCEEDED, task_type=REVOKE)
  → produced_points_record_lid = 负向流水 lid
  → target_points_record_lid = 原正向流水 lid

crm_card_points_record (正向流水, amount > 0)
  ← target_points_record_lid 关联撤销流水

crm_card_points_record (负向流水, amount < 0)
  → target_points_record_lid 关联正向流水
```

## 8. 代码文件清单

| 文件 | 职责 |
|------|------|
| `CrmConsumePointsServicePlus.java` | 统一消费积分发放和撤销主逻辑 |
| `CrmConsumePointsTask.java` | 积分任务实体 |
| `ICrmConsumePointsTaskService.java` | 任务服务接口 |
| `CrmConsumePointsTaskTypeEnum.java` | 任务类型枚举 |
| `CrmConsumePointsTaskStatusEnum.java` | 任务状态枚举 |
| `CrmConsumePointsSourceEnum.java` | 积分来源枚举 |

## 9. 状态机

```
发放流程：
  GRANT PROCESSING → GRANT SUCCEEDED（终态）
                  → GRANT FAILED（终态）

撤销流程：
  REVOKE PROCESSING → REVOKE SUCCEEDED（终态）
                    → REVOKE FAILED（终态）

撤销时找不到 GRANT 任务 → 抛异常，POS 继续补偿重试
```

## 10. 后台管理页面

### 10.1 管理页面入口

| 功能 | 前端路径 | 前端组件 |
|------|---------|---------|
| 积分权益规则设置 | `/membermarketing/crmmembermrg/pointsrules` | `src/pages/CrmMemberMrg/components/PointsRules/index.tsx` |

### 10.2 后台管理接口

入口 Controller：`CrmPointsRuleController`（路径 `/crm_points_rule`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/crm_points_rule/add` | POST | `crm:pointsRule:add` | 新增积分权益规则 |
| `/crm_points_rule/update` | POST | `crm:pointsRule:update` | 修改积分权益规则 |
| `/crm_points_rule/save` | POST | `crm:pointsRule:add` 或 `update` | 新增或修改（按会员方案） |
| `/crm_points_rule/del` | POST | `crm:pointsRule:del` | 删除积分权益规则 |
| `/crm_points_rule/get` | POST | `crm:pointsRule:list` | 查询积分权益规则详情 |
| `/crm_points_rule/list` | POST | `crm:pointsRule:list` | 分页查询积分权益规则列表 |

### 10.3 积分权益规则配置维度

积分权益规则由 `crm_points_rule` 表承载，一个会员方案（`plan_lid`）对应一条规则记录，字段覆盖：

**积分获取规则（消费送积分）**
- `points_rule_enabled`：总开关（启用/禁用）
- `earning_enabled`：消费送积分开关
- `gift_amount_earn_enabled`：储值赠送金是否参与积分开关
- `earning_mode`：积分模式（当前仅支持按支付实收金额）
- `earning_product_scope_type`：`earning_specified_product_lids`：获取积分指定商品范围
- `level_rates`（JSON）：会员等级倍率配置——每个等级设置"每消费多少元"和"获得多少积分"
- `single_earn_limit_type` / `single_earn_limit_value`：单笔获取积分上限
- `bonus_enabled`：多倍积分总开关
- `birthday_enabled` / `birthday_period` / `birthday_multiplier`：生日多倍积分
- `member_day_enabled` / `member_day_period` / `member_day_days_of_week` / `member_day_days_of_month` / `member_day_multiplier`：会员日多倍积分
- `available_cycle` / `available_days_of_week` / `available_days_of_month`：积分可用周期（永久/按周/按月）
- `available_time_type` / `available_time_slots`（JSON）：积分可用时段（不限/指定时段）
- `wecom_exclusive_enabled` / `wecom_exclusive_type`：企微专享配置
- `order_scene_limit`（JSON）：订单场景限制（1-堂食，2-外卖，3-自提，4-外带）
- `order_channel_limit`（JSON）：订单渠道限制（1-门店POS，2-微信小程序，3-支付宝小程序，4-抖音小程序，5-商户中心，6-自助大屏，7-码牌收银）

**积分抵扣规则**
- `deduction_enabled`：积分抵现开关
- `deduction_rate`：抵扣比例（如每100积分抵1元）
- `min_deduction_type` / `min_deduction_value`：起扣积分门槛
- `deduction_multiple_type` / `deduction_multiple_value`：抵扣整数倍限制
- `deduction_ceiling_type` / `deduction_ceiling_points` / `deduction_ceiling_ratio`：抵扣上限（固定积分/账单比例）
- `deduct_cycle` / `deduct_days_of_week` / `deduct_days_of_month`：抵扣可用周期
- `deduct_time_type` / `deduct_time_slots`（JSON）：抵扣可用时段
- `product_limit_enabled`：商品限制开关
- `product_scope_type`：`deduct_specified_product_lids` / `deduct_pos_category_lids` / `deduct_miniapp_category_lids` / `deduct_exclude_product_lids`：抵扣商品范围配置
- `deduct_scene_limit`（JSON）：抵扣订单场景限制
- `deduct_channel_limit`（JSON）：抵扣订单渠道限制

**积分有效期规则**
- `validity_mode`：有效期模式（1-永久有效，2-每年固定日期清零）
- `validity_fixed_month` / `validity_fixed_day`：每年清零月日
- `validity_notify_enabled` / `validity_remind_days`：清零前消息提醒

**其他**
- `rule_description`：规则公示说明（前端展示给用户）

### 10.4 POS 同步机制

CRM 配置的积分权益规则通过 POS 同步接口下发到门店本地：

- `CrmPointsRuleController.listSync`（路径 `/crm_points_rule/listSync`）：POS 同步专用接口，按商户维度下发，不按门店缩小范围
- 返回 `CrmPointsRuleSyncVO`，所有枚举值转换为数字编码，JSON 字段序列化为字符串，便于 POS 端解析
- POS 接收后缓存在本地，结账时按会员卡类型匹配对应规则并计算应赠积分

## 12. 测试验证要点

- 同一订单重复发放：返回原 SUCCEEDED 任务，不重复加积分
- POS 反结账先于正向积分到达：CRM 抛异常，POS 继续补偿
- 反结账重复触发：撤销任务已存在，返回原撤销结果
- 积分余额不足撤销：允许扣为负数（会员欠积分）
- 消费积分不写储值流水 `crm_card_record`
