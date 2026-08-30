# CRM 消费赠券设计实现文档

日期：2026-08-28
作者：guoyun_liu
状态：已实现

## 1. 背景与目标

POS 会员结账后触发消费赠券，旧链路由 MQ 消费者异步处理，存在重投导致重复发券、发券失败难以追溯、反结账无法可靠回收券等问题。

本设计目标：**POS 在结账成功后同步调用 CRM 幂等接口，CRM 负责匹配规则、调用通用发券能力、持久化幂等记录和券订单关联，反结账时按幂等记录回收券**。不改变旧 MQ 消费赠券逻辑。

## 2. 核心架构

```
POS 结账 afterCommit
  → 生成 roundKey（同一次赠券轮次唯一）
  → POST /crm_consume_coupon/grantSign
    → CrmConsumeCouponOpServicePlus.grant()
      → findOrCreateRecord() 幂等
      → matchRule() 匹配消费赠券规则
      → couponOpAdd() 调用通用发券
      → 保存 couponOrderLids
  → POST /crm_consume_coupon/revokeSign（反结账/退款）
    → CrmConsumeCouponOpServicePlus.revoke()
      → findRecord() 按 roundKey 查找
      → couponOpRevoke() 或批量更新券状态为已作废
```

## 3. 接口设计

### 3.1 发放赠券

```
POST /crm_consume_coupon/grantSign
签名校验：NeedVerifySignature（自动从签名字段落入 mid/sid）
```

| 字段 | 来源 | 必填 | 含义 |
|------|------|------|------|
| `merchantNo` | 签名字段 | — | 落入 `mid` |
| `terminalId` | 签名字段 | — | 落入 `sid` |
| `roundKey` | POS 本地生成 | ✅ | POS 赠券轮次幂等键，同一键只发券一次 |
| `outOrderId` | POS 外部订单号 | ✅ | 用于记录追踪 |
| `cardLid` | POS 会员卡 LID | 否 | CRM 以此为主键 |
| `cardNo` | 会员卡号 | ✅ | 定位会员卡 |
| `checkOutTime` | POS 结账时间 | ✅ | 用于规则有效期和星期/时段限制 |
| `billAmount` | 账单总金额 | ✅ | 按账单总额维度匹配规则 |
| `crmAmount` | 会员卡支付金额 | 否 | 按会员卡支付维度匹配规则（优先级更高） |
| `otherAmount` | 非会员卡支付金额 | 否 | 按非会员卡维度匹配规则 |
| `online` | 是否线上订单 | 否 | 用于规则匹配 |
| `operator` | POS 操作人 | 否 | 写入操作记录 |

返回 `CrmConsumeCouponResultVO`：

| 字段 | 含义 |
|------|------|
| `status` | PENDING/GRANTED/NO_MATCH/REVOKED/FAILED |
| `roundKey` | POS 赠券轮次幂等键 |
| `ruleLid` | 命中的消费赠券规则 LID |
| `couponLid` | 发放的券模板 LID |
| `couponNum` | 发放券数量 |
| `couponOrderLids` | 本次发券生成的券订单 LID 列表 |
| `message` | 业务提示信息 |

### 3.2 撤销赠券

```
POST /crm_consume_coupon/revokeSign
签名校验：NeedVerifySignature
```

| 字段 | 来源 | 必填 | 含义 |
|------|------|------|------|
| `roundKey` | POS 本地生成 | ✅ | 定位原赠券记录 |
| `outOrderId` | POS 外部订单号 | 否 | 兜底排查 |
| `cardNo` | 会员卡号 | 否 | 兜底排查 |
| `couponLids` | 券模板 LID 列表 | 否 | 兜底用，正常使用幂等记录内券模板 |

## 4. 表结构

### 4.1 `crm_consume_coupon_op_record`（消费赠券 POS 轮次幂等记录）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | 门店 ID |
| `lid` | BIGINT | 业务逻辑主键（雪花算法） |
| `round_key` | VARCHAR(128) | **POS 赠券轮次幂等键**，同一键只发券一次 |
| `order_id` | VARCHAR(64) | POS 外部订单号 |
| `card_lid` | BIGINT | 会员卡 LID |
| `card_no` | VARCHAR(64) | 会员卡号 |
| `phone` | VARCHAR(32) | **CRM 会员手机号**，撤销时定位券订单 |
| `status_` | INT | **状态：1-待处理，2-已发券，3-未命中，4-已撤销，5-失败** |
| `rule_lid` | BIGINT | 命中的消费赠券规则 LID |
| `coupon_lid` | BIGINT | 券模板 LID |
| `coupon_num` | INT | 发券数量 |
| `coupon_order_lids_json` | TEXT | **本轮生成的券订单 LID JSON 数组**，撤销时使用 |
| `request_json` | TEXT | 发券请求快照 JSON |
| `response_json` | TEXT | 最近一次 CRM 响应快照 JSON |
| `error_msg` | TEXT | 最近一次失败原因 |
| `grant_time` | DATETIME | 成功发券时间 |
| `revoke_time` | DATETIME | 成功撤销时间 |
| `revision` | INT | 乐观锁版本号 |
| `created_by/created_time/updated_by/updated_time/deleted` | — | 标准审计字段 |

索引：

```sql
UNIQUE KEY uk_crm_consume_coupon_op_lid (lid)                              -- lid 唯一
UNIQUE KEY uk_crm_consume_coupon_op_round (mid, sid, round_key, deleted)  -- 幂等键唯一
KEY idx_crm_consume_coupon_op_order (mid, order_id)                      -- 按订单排查
KEY idx_crm_consume_coupon_op_status (status_)                             -- 状态查询
```

### 4.2 关联规则表（已有）

#### `crm_consumption_coupon_rule`（消费赠券规则）

| 字段 | 类型 | 含义 |
|------|------|------|
| `lid` | BIGINT | 业务逻辑主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `is_all_store` | BOOLEAN | 是否全门店适用 |
| `store_sids` | JSON | 适用门店列表 |
| `coupon_lid` | BIGINT | 赠送的券模板 LID |
| `coupon_name` | VARCHAR | 券模板名称（快照） |
| `full_amount` | DECIMAL | 满额门槛（满足此金额才赠券） |
| `amount_method` | ENUM | 金额口径：**H**-会员卡支付金额，**F**-非会员卡支付金额，**B**-账单总金额 |
| `gift_quantity` | INT | 固定赠券数量 |
| `gift_max_quantity` | INT | 单次最大赠券数量 |
| `term_of_validity_method` | ENUM | 有效期方式：**GD**-固定日期，**XD**-相对日期 |
| `effective_method` | ENUM | 生效方式：**XS**-小时，**TS**-天 |
| `effective_days` | INT | 相对生效天数 |
| `effective_time` | INT | 相对生效小时数 |
| `start_effective_time/end_effective_time` | DATETIME | 固定有效期起止时间 |
| `card_type_lid` | BIGINT | 适用会员卡类型 LID |
| `card_type_level_lid` | BIGINT | 适用会员卡等级 LID |
| `gift_by_increase` | BOOLEAN | 是否开启每满递增赠券 |
| `gift_eve_amount` | DECIMAL | 每满多少金额递增一张券 |

#### `crm_consumption_coupon_limit`（消费赠券规则限制条件）

| 字段 | 类型 | 含义 |
|------|------|------|
| `lid` | BIGINT | 业务逻辑主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `rule_lid` | BIGINT | 所属规则 LID |
| `week_type` | INT(1-7) | 适用星期限制（可多行配置） |
| `start_time/end_time` | DATETIME | 适用时段限制（可多行配置） |

## 5. 幂等状态机

```
┌─────────────┐    grant()    ┌──────────────┐
│   PENDING   │ ────────────→ │   GRANTED    │ ← 终态，不重复发券
└─────────────┘              └──────────────┘
       │                             │
       │ revoke()                    │
       ↓                             │ revoke()
┌─────────────┐                 ┌──────────────┐
│  REVOKED    │ ←────────────── │   REVOKED    │ ← 终态，不重复撤销
└─────────────┘   revoke()     └──────────────┘
       │
       │ grant()（撤销先到时）
       ↓
┌─────────────┐
│ NO_MATCH /  │
│  FAILED     │ ← 终态，不重复发券
└─────────────┘
```

状态枚举 `CrmConsumeCouponOpStatusEnum`：

| code | 枚举值 | 含义 |
|------|--------|------|
| 1 | PENDING | 待处理 |
| 2 | GRANTED | 已发券 |
| 3 | NO_MATCH | 未命中规则 |
| 4 | REVOKED | 已撤销 |
| 5 | FAILED | 处理失败（可重试） |

## 6. 规则匹配逻辑

### 6.1 匹配口径与旧 MQ 消费者一致

刻意保持与旧 MQ 消费者 `CrmConsumerCouponQueueConsumer` 相同的匹配口径，不直接改旧 consumer，避免历史 MQ 链路行为变化。

### 6.2 匹配顺序

1. **星期/时段排除**：先查 `crm_consumption_coupon_limit`，按星期值和时段匹配；配置过限制的规则必须命中限制，否则排除
2. **会员卡类型/等级过滤**：`card_type_lid` 和 `card_type_level_lid` 支持为空（不限）
3. **有效期过滤**：按 `term_of_validity_method` 区分固定日期和相对日期
4. **金额口径匹配**：优先按 `crmAmount`（会员卡支付），其次 `otherAmount`（非会员卡），最后 `billAmount`（账单总额）
5. **满额门槛**：取 `full_amount` 最大且 <= 实际金额的那条规则

### 6.3 发券数量计算

```
fixed = giftQuantity（默认1）
step = 每满递增时 = 实际金额 / giftEveAmount（向下取整）
total = fixed × step
上限 = min(total, giftMaxQuantity)  -- giftMaxQuantity > 0 时生效
```

## 7. 撤销策略

撤销时优先使用幂等记录中保存的 `couponOrderLids`（本轮生成的券订单 LID 列表），批量更新券状态为已作废：

```sql
UPDATE crm_coupon_order
SET coupon_status = 'YZF'  -- 已作废
WHERE mid = ? AND lmnid IN (券订单LID列表)
AND coupon_status IN ('WHX', 'YGQ')  -- 只作废未使用和已过期
```

如果 `couponOrderLids` 为空，则按 `couponLid + phone + orderId` 调用通用 `couponOpRevoke()`。

## 8. 代码文件清单

| 文件 | 职责 |
|------|------|
| `CrmConsumeCouponOpController.java` | 接口入口，签名解析 |
| `CrmConsumeCouponOpServicePlus.java` | 幂等编排、规则匹配、发券执行、撤销 |
| `CrmConsumeCouponGrantDTO.java` | 发放请求 DTO |
| `CrmConsumeCouponRevokeDTO.java` | 撤销请求 DTO |
| `CrmConsumeCouponResultVO.java` | 返回 VO |
| `CrmConsumeCouponOpStatusEnum.java` | 状态枚举 |
| `CrmConsumeCouponOpRecord.java` | 实体（DAO） |
| `ICrmConsumeCouponOpRecordService.java` | 实体服务接口 |
| `CrmConsumeCouponOpRecordServiceImpl.java` | 实体服务实现 |
| `V20260515__crm_consume_coupon_op_record.sql` | 建表 SQL |
| `V20260515__consume_coupon_session_round_event.sql` | Session/Round/Event 三表（POS 端本地补偿用） |

## 9. 与旧 MQ 链路的关系

| 项目 | 新 POS 同步链路 | 旧 MQ 异步链路 |
|------|---------------|--------------|
| 入口 | `/crm_consume_coupon/grantSign` | `CRM_CONSUMER_COUPON_QUEUE` |
| 幂等键 | `roundKey` | 依赖 `couponOpAdd()` 内部幂等 |
| 状态记录 | `crm_consume_coupon_op_record` | 无独立幂等记录 |
| 撤销 | 按 roundKey 精确撤销 | 按 orderId 模糊撤销 |
| 规则匹配 | 与旧 consumer 口径一致 | 原有逻辑 |

旧 MQ 链路保持不变，新 POS 同步链路独立演进。

## 10. 后台管理页面

### 10.1 管理页面入口

| 功能 | 前端路径 | 前端组件 |
|------|---------|---------|
| 消费赠券规则管理 | `CrmMarketingMrg` 下的消费赠券子路由 | `src/pages/CrmMarketingMrg/components/CrmConsumptionCouponRule/` |

### 10.2 后台管理接口

入口 Controller：`CrmConsumptionCouponRuleController`（路径 `/crm_consumption_coupon_rule`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/crm_consumption_coupon_rule/get` | POST | `crm:consumption:coupon:rule:list` | 获取消费赠券规则详情（含限制条件） |
| `/crm_consumption_coupon_rule/list` | POST | 登录后可见 | 分页查询消费赠券规则列表 |
| `/crm_consumption_coupon_rule/add` | POST | `crm:consumption:coupon:rule:add` | 新增消费赠券规则 |
| `/crm_consumption_coupon_rule/update` | POST | `crm:consumption:coupon:rule:update` 或 `edit` | 修改消费赠券规则 |
| `/crm_consumption_coupon_rule/del` | POST | `crm:consumption:coupon:rule:del` | 删除消费赠券规则（含关联限制条件） |
| `/crm_consumption_coupon_rule/export` | POST | `crm:consumption:coupon:rule:export` | 导出消费赠券规则 |

### 10.3 消费赠券规则配置维度

消费赠券规则由 `crm_consumption_coupon_rule` 表承载，限制条件由 `crm_consumption_coupon_limit` 表承载：

**crm_consumption_coupon_rule 字段覆盖：**

| 维度 | 字段 | 说明 |
|------|------|------|
| 基本信息 | `mid/sid`、`name` | 商户/门店、规则名称 |
| 适用门店 | `is_all_store`、`store_sids`（JSON） | 全门店或指定门店列表 |
| 赠送券品 | `coupon_lid`、`coupon_name` | 赠送的券模板 LID 和名称快照 |
| 金额门槛 | `full_amount` | 满额门槛，满足此金额才赠券 |
| 金额口径 | `amount_method`（H/F/B） | **H**-会员卡支付金额，**F**-非会员卡支付金额，**B**-账单总金额 |
| 赠送数量 | `gift_quantity` | 固定赠券数量（默认1） |
| 每满递增 | `gift_by_increase`（布尔）、`gift_eve_amount` | 开启后按金额除以递增步长计算赠券数量 |
| 赠送上限 | `gift_max_quantity` | 单次最大赠券数量上限 |
| 有效期方式 | `term_of_validity_method`（GD/XD） | **GD**-固定日期，**XD**-相对日期 |
| 生效方式 | `effective_method`（XS/TS） | **XS**-小时，**TS**-天 |
| 相对天数/小时 | `effective_days`（天）、`effective_time`（小时） | 相对日期有效期长度 |
| 固定有效期 | `start_effective_time`/`end_effective_time` | 固定日期有效期起止 |
| 适用会员 | `card_type_lid`、`card_type_level_lid` | 适用会员卡类型和等级（可为空表示不限） |

**crm_consumption_coupon_limit 字段覆盖：**

限制条件表按规则 LID 关联，支持多行配置（星期和时段分开提交）：

| 字段 | 说明 |
|------|------|
| `rule_lid` | 所属规则 LID |
| `week_type` | 适用星期（1-7），多行可配置多个星期 |
| `start_time`/`end_time` | 适用时段（DATEETIME），多行可配置多个时段段 |

### 10.4 与 POS 幂等链路的分工

| 角色 | 说明 |
|------|------|
| 后台管理（`CrmConsumptionCouponRuleController`） | 消费赠券规则的 CRUD，关联限制条件、券模板 |
| POS 幂等链路（`CrmConsumeCouponOpController`） | 结账后按规则匹配并执行发券/撤销 |

规则匹配逻辑与旧 MQ 消费者 `CrmConsumerCouponQueueConsumer` 保持口径一致：

1. 星期/时段排除（`crm_consumption_coupon_limit`）
2. 会员卡类型/等级过滤
3. 有效期过滤（固定日期或相对日期）
4. 金额口径优先顺序：会员卡支付金额 > 非会员卡支付金额 > 账单总金额
5. 取 `full_amount` 最大且 ≤ 实际金额的规则

## 12. 测试验证要点

- 同一 roundKey 重复发放：返回原 GRANTED 结果，不重复发券
- 撤销先到、发放后到：发放命中 REVOKED 终态，返回"已撤销"
- 规则未命中：状态为 NO_MATCH
- 发券成功但 CRM 返回超时：POS 重试，`couponOpAdd()` 幂等返回，CRM 查 couponOrderLids 补录
- 反结账撤销：按 `couponOrderLids` 批量作废，不误删已使用券
