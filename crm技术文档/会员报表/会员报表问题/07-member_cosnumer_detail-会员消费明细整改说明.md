# member_cosnumer_detail 会员消费明细整改说明

> 接口：`POST /ck/member_cosnumer_detail`
>
> 控制器：`MemberConsumerDetail`
>
> 注意：接口名中 `cosnumer` 是历史拼写，整改时不要直接改接口路径。
>
> 优先级：P1，需要补来源门店字段。
>
> 当前口径：消费发生明细。

---

## 一、当前逻辑

当前明细查询 `crm_card_record`，默认操作类型：

```text
Consume, CancelOrder, Repay, Reverse
```

展示字段包括：

- `shop_name`
- `create_time`
- `member_name`
- `phone`
- `card_id_alias`
- `amount`
- `principal_amount`
- `give_amount`
- `balance_after`
- `order_bill_id`
- `subject`
- `comment`
- `operation`
- `operator`

当前 `shop_name` 是交易发生门店，不是余额来源门店。

---

## 二、主要问题

| 字段 | 当前问题 | 影响 |
|---|---|---|
| `shop_name` | 标题是“门店名称”，未说明是消费门店 | 财务容易误认为该门店余额被扣 |
| 缺少 `source_sid` | 无法知道扣的是哪个充值门店余额 | 跨店消费无法对账 |
| 缺少 `sourceShopName` | 前端不能直接展示来源门店 | 人工查账成本高 |
| `balance_after` | 是卡交易后余额，不是来源门店余额 | 不能用于门店资金余额对账 |

---

## 三、字段级整改清单

| 字段 | 修改动作 | 说明 |
|---|---|---|
| `shop_name` | 标题改为“消费门店” | 保留 dataIndex 兼容 |
| 新增 `trade_sid` | `shop_id` | 交易发生门店 ID |
| 新增 `trade_shop_name` | `shop_name` | 交易发生门店名称 |
| 新增 `source_sid` | `COALESCE(source_sid, shop_id)` | 余额来源门店 ID |
| 新增 `source_shop_name` | 根据 `source_sid` 查门店 | 余额来源门店名称 |
| `amount` | 标题改为“消费金额” | 保持明细原值或按现有展示规则 |
| `principal_amount` | 标题改为“消费本金” | 表示本次扣减本金部分 |
| `give_amount` | 标题改为“消费赠送” | 表示本次扣减赠送部分 |
| `balance_after` | 标题改为“卡交易后总余额” | 明确不是来源门店余额 |

---

## 四、查询修改细节

### 4.1 明细选择字段

```sql
SELECT
  shop_id AS trade_sid,
  shop_name AS trade_shop_name,
  COALESCE(source_sid, shop_id) AS source_sid,
  create_time,
  member_name,
  phone,
  card_id_alias,
  amount,
  principal_amount,
  give_amount,
  balance_after,
  order_bill_id,
  IF(IFNULL(subject, '') = '', pay_way, subject) AS subject,
  operation_model,
  operator,
  comment
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND operation_model IN ('Consume', 'CancelOrder', 'Repay', 'Reverse')
  AND shop_id IN (:tradeSidList)
  AND yingyeriqi BETWEEN :beginTime AND :endTime
ORDER BY create_time ASC
```

### 4.2 来源门店名称

不要在 SQL 中硬编码门店名称。建议：

1. 查询结果收集 `source_sid`。
2. 调用 `ShopCacheService` 批量取门店名称。
3. 回填 `source_shop_name`。

历史 `source_sid` 为空时，使用 `shop_id`，来源门店等于消费门店。

---

## 五、筛选项建议

保留旧筛选：

- 消费门店：过滤 `shop_id`
- 会员姓名
- 会员手机
- 会员卡号
- 单号

新增可选筛选：

- 来源门店：过滤 `COALESCE(source_sid, shop_id)`

如果同时传消费门店和来源门店，表示交集：

```text
消费发生在 B 店，且扣 A 店余额
```

这对跨店对账很有价值。

---

## 六、合计行修改

合计行只应合计金额字段：

- `amount`
- `principal_amount`
- `give_amount`

不要合计 `balance_after`。如果当前实现没有合计 `balance_after`，保持不变；如果后续统一明细合计逻辑，要明确排除。

---

## 七、验收用例

| 用例 | 明细预期 |
|---|---|
| A 充 100，B 消 30 | 消费门店 B，来源门店 A，消费金额 30 |
| A 充 100，B 消 30 后撤销 | 一条消费、一条撤销，来源门店均为 A，金额方向按现有展示规则 |
| B 店筛选 | 查到发生在 B 的消费 |
| A 来源门店筛选 | 查到扣 A 余额的消费，即使发生在 B |

