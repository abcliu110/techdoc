# member_charege_detail 会员充值明细整改说明

> 接口：`POST /ck/member_charege_detail`
>
> 控制器：`MemberChargeDetail`
>
> 注意：接口名中 `charege` 是历史拼写，整改时不要直接改接口路径。
>
> 优先级：P2，主要是补来源门店字段和明确字段语义。
>
> 当前口径：充值发生明细。

---

## 一、当前逻辑

当前明细查询 `crm_card_record`，默认操作类型包含：

```text
Charge, ChargeCancel, AccountingBluePatch, AccountingRedFlush
```

展示字段包括：

- `shop_name`
- `create_time`
- `member_name`
- `phone`
- `card_id_alias`
- `amount`
- `give_amount`
- `principal_amount`
- `balance_after`
- `order_bill_id`
- `subject`
- `comment`
- `operation_model2`
- `operator`

当前 `shop_name` 是操作发生门店。

---

## 二、需要修正的点

| 字段 | 当前问题 | 修改方向 |
|---|---|---|
| `shop_name` | 标题“门店名称”不够明确 | 改为“充值门店/操作门店” |
| 缺少 `source_sid` | 无法确认形成或冲减哪个来源门店余额 | 新增 |
| 缺少 `source_shop_name` | 前端无法直观看来源门店 | 新增 |
| `balance_after` | 是卡交易后总余额 | 标题明确，不参与门店来源余额对账 |

---

## 三、字段级整改清单

| 字段 | 修改动作 | 说明 |
|---|---|---|
| `shop_name` | 标题改为“充值门店” | 对红冲/蓝补可理解为操作门店 |
| 新增 `trade_sid` | `shop_id` | 操作发生门店 |
| 新增 `trade_shop_name` | `shop_name` | 操作发生门店名称 |
| 新增 `source_sid` | `COALESCE(source_sid, shop_id)` | 余额来源门店 |
| 新增 `source_shop_name` | 根据 `source_sid` 查门店 | 正常充值通常等于充值门店 |
| `amount` | 标题保留“金额”或“储值金额” | 按现有方向展示 |
| `principal_amount` | 标题“实付金额/本金”需要统一 | 建议用“储值本金” |
| `give_amount` | 标题“赠送金额” | 保留 |
| `balance_after` | 改为“卡交易后总余额” | 不用于门店余额来源对账 |

---

## 四、查询修改细节

```sql
SELECT
  shop_id AS trade_sid,
  shop_name AS trade_shop_name,
  COALESCE(source_sid, shop_id) AS source_sid,
  DATE_FORMAT(create_time, '%Y-%m-%d %H:%i:%s') AS create_time,
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
  AND operation_model IN ('Charge', 'ChargeCancel', 'AccountingBluePatch', 'AccountingRedFlush')
  AND shop_id IN (:tradeSidList)
  AND yingyeriqi BETWEEN :beginTime AND :endTime
ORDER BY create_time ASC
```

新增来源门店筛选：

```sql
AND COALESCE(source_sid, shop_id) IN (:sourceSidList)
```

---

## 五、合计规则

合计行可以合计：

- `amount`
- `principal_amount`
- `give_amount`

不应合计：

- `balance_after`

如果需要展示期末余额，应由余额报表提供，不应在充值明细合计行计算。

---

## 六、验收用例

| 用例 | 预期 |
|---|---|
| A 店充值 100 | 充值门店 A，来源门店 A |
| A 店充值撤销 | 能展示撤销操作门店和来源门店 |
| 红冲/蓝补 | 如果业务写入 `source_sid`，明细展示来源门店；否则回退操作门店 |
| 合计行 | 金额字段合计，`balance_after` 为空 |

