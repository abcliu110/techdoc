# card_settle_summary 会员卡金额结算表整改说明

> 接口：`POST /ck/card_settle_summary`
>
> 控制器：`SettlementController`
>
> 聚合任务：`CalcTask.reCalcDwsCrmSettlementOfStore`
>
> 优先级：P0，必须修。
>
> 目标口径：跨门店消费产生的门店间应收应付。

---

## 一、当前逻辑

该报表字段本身已经具备跨店结算语义：

| 字段 | 当前标题 |
|---|---|
| `fromOtherPrincipal/fromOtherGift/fromOtherSubtotal` | 他店储值本店消费，应收 |
| `toOtherPrincipal/toOtherGift/toOtherSubtotal` | 本店储值他店消费，应付 |
| `principal/gift/total` | 结算金额 |

但当前聚合任务只按 `crm_card_record.shop_id` 汇总，并把全部金额写入 `fromOther*`，`toOther*` 写 0。

这会导致报表看起来有“应收”，但没有对应门店“应付”，无法形成跨店结算闭环。

---

## 二、正确结算模型

场景：A 店充值 100，B 店消费 30，扣 A 店余额。

| 门店 | 结算方向 | 字段 |
|---|---|---|
| B 店 | 他店储值本店消费，应收 A 店 30 | `fromOther* = 30` |
| A 店 | 本店储值他店消费，应付 B 店 30 | `toOther* = 30` |

全商户合计应满足：

```text
sum(fromOtherSubtotal) = sum(toOtherSubtotal)
sum(total) = 0
```

如果全商户合计不为 0，说明有跨店结算分录漏记或方向错误。

---

## 三、字段级整改清单

| 字段 | 当前问题 | 目标逻辑 |
|---|---|---|
| `shop` | 结算店铺本身可保留 | 表示当前结算主体门店 |
| `fromOtherPrincipal` | 当前按 `shop_id` 汇总所有本金，未判断是否他店储值 | 仅当 `shop_id != fund_sid` 时，在消费发生门店记录应收本金 |
| `fromOtherGift` | 同上 | 仅当 `shop_id != fund_sid` 时，在消费发生门店记录应收赠送 |
| `fromOtherSubtotal` | 同上 | `fromOtherPrincipal + fromOtherGift` |
| `toOtherPrincipal` | 当前固定 0 | 仅当 `shop_id != fund_sid` 时，在余额来源门店记录应付本金 |
| `toOtherGift` | 当前固定 0 | 仅当 `shop_id != fund_sid` 时，在余额来源门店记录应付赠送 |
| `toOtherSubtotal` | 当前固定 0 | `toOtherPrincipal + toOtherGift` |
| `principal` | 当前用 `from - to`，但 `to` 为 0 | 保持 `fromOtherPrincipal - toOtherPrincipal` |
| `gift` | 同上 | 保持 `fromOtherGift - toOtherGift` |
| `total` | 同上 | 保持 `fromOtherSubtotal - toOtherSubtotal` |

---

## 四、DWS 生成修改细节

### 4.1 只处理跨店消费类流水

来源行定义：

```sql
fund_sid = COALESCE(source_sid, shop_id)
```

纳入结算的条件：

```sql
company_id = :mid
AND if_deal_success = 1
AND fund_sid <> shop_id
AND operation_model IN ('Consume', 'CancelOrder')
```

`Repay/Reverse` 是否纳入，需要业务确认。如果它们本质是会员卡回款并影响跨店结算，也要按相同原则补充方向。

### 4.2 双边分录 SQL 形态

建议生成一张中间结果，再 `UNION ALL` 成两边：

```sql
WITH base AS (
  SELECT
    company_id AS mid,
    shop_id AS trade_sid,
    COALESCE(source_sid, shop_id) AS fund_sid,
    CASE
      WHEN operation_model = 'Consume' THEN 1
      WHEN operation_model = 'CancelOrder' THEN -1
      ELSE 0
    END AS settle_sign,
    ABS(principal_amount) AS principal_amount,
    ABS(give_amount) AS give_amount,
    ABS(principal_amount + give_amount) AS total_amount
  FROM crm_card_record
  WHERE company_id = :mid
    AND if_deal_success = 1
    AND yingyeriqi BETWEEN :beginTime AND :endTime
    AND COALESCE(source_sid, shop_id) <> shop_id
    AND operation_model IN ('Consume', 'CancelOrder')
)
SELECT
  mid,
  trade_sid AS sid,
  SUM(settle_sign * principal_amount) AS from_other_principal,
  SUM(settle_sign * give_amount) AS from_other_gift,
  SUM(settle_sign * total_amount) AS from_other_subtotal,
  0 AS to_other_principal,
  0 AS to_other_gift,
  0 AS to_other_subtotal
FROM base
GROUP BY mid, trade_sid

UNION ALL

SELECT
  mid,
  fund_sid AS sid,
  0 AS from_other_principal,
  0 AS from_other_gift,
  0 AS from_other_subtotal,
  SUM(settle_sign * principal_amount) AS to_other_principal,
  SUM(settle_sign * give_amount) AS to_other_gift,
  SUM(settle_sign * total_amount) AS to_other_subtotal
FROM base
GROUP BY mid, fund_sid
```

落入 `dws_crm_settlement_of_store` 时再按 `sid`、日期、版本聚合。

---

## 五、接口查询修改细节

`SettlementController` 当前查询字段方向基本可以保留，但需要注意：

1. DWS 中 `fromOther*` 和 `toOther*` 应保存正向业务值，接口层不应再用不明原因的 `-1 *` 修正。
2. 如果为了兼容历史数据保留 `-1 *`，必须在 DWS 生成文档中明确“库内保存负数、展示取正”的约定。
3. `sidList` 过滤的是结算主体门店，不是交易发生门店，也不是来源门店筛选。

建议最终接口查询：

```sql
SELECT
  sid,
  SUM(from_other_principal) AS fromOtherPrincipal,
  SUM(from_other_gift) AS fromOtherGift,
  SUM(from_other_subtotal) AS fromOtherSubtotal,
  SUM(to_other_principal) AS toOtherPrincipal,
  SUM(to_other_gift) AS toOtherGift,
  SUM(to_other_subtotal) AS toOtherSubtotal,
  SUM(from_other_principal - to_other_principal) AS principal,
  SUM(from_other_gift - to_other_gift) AS gift,
  SUM(from_other_subtotal - to_other_subtotal) AS total
FROM dws_crm_settlement_of_store
WHERE mid = :mid
  AND sid IN (:sidList)
  AND report_date BETWEEN :beginTime AND :endTime
GROUP BY sid
```

---

## 六、验收用例

| 用例 | A 店 | B 店 | 全商户合计 |
|---|---:|---:|---:|
| A 充 100，B 消 30 | 应付 30，结算 -30 | 应收 30，结算 +30 | 0 |
| B 消费撤销 30 | 应付冲回到 0 | 应收冲回到 0 | 0 |
| A 充 100，A 消 30 | 不产生跨店结算 | 不产生跨店结算 | 0 |
| B 消费扣 A 20、C 10 | A 应付 20，C 应付 10 | B 应收 30 | 0 |

---

## 七、兼容建议

1. 先新增新版结算任务，旧表可按版本区分。
2. 重算历史时以 `source_sid` 是否存在为准；为空则 `fund_sid = shop_id`，不会产生跨店结算。
3. 修改后把 `card_settle_summary` 作为校验余额来源报表的配套报表：跨店消费在来源余额表减少，同时在结算表产生应收应付。

