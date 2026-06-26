# member_charege_summary 会员充值汇总整改说明

> 接口：`POST /ck/member_charege_summary`
>
> 控制器：`MemberChargeSummary`
>
> 注意：接口名中 `charege` 是历史拼写，整改时不要直接改接口路径。
>
> 优先级：P2，主要是命名和来源字段补充。
>
> 当前口径：充值发生门店。

---

## 一、当前逻辑

当前报表查询 `crm_card_record`，默认操作类型：

```text
Charge, ChargeCancel, AccountingBluePatch, AccountingRedFlush
```

按以下字段分组：

- `shopName`
- `memberName`
- `phone`

汇总：

- `amount`
- `principalAmount`
- `giveAmount`

门店筛选落在 `crm_card_record.shop_id`。

---

## 二、当前逻辑是否错误

充值类报表与消费不同。大多数正常充值场景下：

```text
充值发生门店 = 余额来源门店
```

因此如果该报表定义为“哪个门店发生充值”，当前按 `shop_id` 基本合理。

但以下场景仍需要补充说明或字段：

| 场景 | 风险 |
|---|---|
| 充值撤销 | 需要确认撤销归还/冲减的是原充值来源门店 |
| 红冲/蓝补 | 可能作用于历史来源余额，不一定等于当前操作门店 |
| 门店财务对账 | 需要知道该笔充值形成哪个来源门店余额 |

---

## 三、字段级整改清单

| 字段 | 修改动作 | 说明 |
|---|---|---|
| `shopName` | 标题改为“充值门店” | 保留 dataIndex |
| 新增 `sourceSid` | `COALESCE(source_sid, shop_id)` | 余额来源门店 |
| 新增 `sourceShopName` | 根据 `sourceSid` 查门店 | 正常充值通常等于充值门店 |
| `amount` | 标题改为“储值金额（发生口径）” | 保持现有汇总 |
| `principalAmount` | 标题改为“储值本金” | 保持现有汇总 |
| `giveAmount` | 标题改为“储值赠送” | 保持现有汇总 |

---

## 四、推荐实现

为了不破坏旧发生口径，保留当前分组，同时增加来源门店拆分能力。

推荐分组：

```sql
SELECT
  shop_id AS tradeSid,
  shop_name AS tradeShopName,
  COALESCE(source_sid, shop_id) AS sourceSid,
  member_name AS memberName,
  phone,
  SUM(amount) AS amount,
  SUM(principal_amount) AS principalAmount,
  SUM(give_amount) AS giveAmount
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND operation_model IN ('Charge', 'ChargeCancel', 'AccountingBluePatch', 'AccountingRedFlush')
  AND shop_id IN (:tradeSidList)
GROUP BY shop_id, shop_name, COALESCE(source_sid, shop_id), member_name, phone
```

如果不希望增加行数，可以只在明细报表补来源门店，汇总报表保持发生门店维度。

---

## 五、门店权限规则

| 模式 | 筛选字段 |
|---|---|
| 充值发生口径 | `shop_id` |
| 余额来源口径 | `COALESCE(source_sid, shop_id)` |

默认保留发生口径。若财务要求按来源门店看充值形成的余额，应新增 `dimension=FUND`。

---

## 六、验收用例

| 用例 | 预期 |
|---|---|
| A 店充值 100 | 充值门店 A，来源门店 A |
| A 店充值撤销 100 | 充值门店按撤销发生门店展示，来源门店应能追到原充值来源 |
| 红冲/蓝补历史余额 | 如果 `source_sid` 有值，展示来源门店；为空则回退充值门店 |

---

## 七、结论

这张报表不属于 P0 错表。它作为“充值发生汇总”可以保留，但必须避免被误用为“门店余额结余表”。

