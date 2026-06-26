# card_income_summary 会员卡连锁门店收支报表整改说明

> 接口：`POST /ck/card_income_summary`
>
> 计算接口：`POST /ck/card_income_summary_calc`
>
> 控制器：`CrmIncomeController`
>
> 优先级：P0，必须修。
>
> 推荐目标口径：资金归属门店收支结余。

---

## 一、当前逻辑

该报表标题是“会员卡连锁门店收支报表”，列包含：

- 消费：`consume_times`、`consume_total`、`consume_principal`、`consume_present`
- 充值：`charge_times`、`charge_total`、`charge_principal`、`charge_present`
- 收支：`total_amount`、`principal_amount`、`present_amount`
- 结余：`end_balance`、`endPrincipal_balance`、`endGive_balance`

当前逻辑存在两套来源：

| 数据块 | 当前来源 | 当前门店字段 |
|---|---|---|
| 充值/消费/收支 | `dws_crm_income_of_store` | `sid`，生成时来自 `crm_card_record.shop_id` |
| 结余 | `dws_crm_day_summary_by_day_with_sid` | `sid`，应来自余额归属门店 |

也就是说：本期收支是交易发生门店，期末结余是余额来源门店。

---

## 二、为什么现在不自洽

A 店充值 100，B 店消费 30，扣 A 店余额。

当前报表会倾向于：

| 门店 | 充值 | 消费 | 结余 |
|---|---:|---:|---:|
| A 店 | 100 | 0 | 70 |
| B 店 | 0 | 30 | 0 |

如果用户按“连锁门店收支结余”理解，就会问：

```text
A 店为什么期末少了 30，但消费为 0？
B 店为什么有消费 30，但没有对应余额来源？
```

根因是 `dws_crm_income_of_store` 的 `sid` 不是资金归属门店。

---

## 三、产品口径必须二选一

### 方案 A：交易发生门店收支报表

如果产品定义是“交易发生在哪里”，则：

- 充值、消费继续按 `shop_id`。
- `shopName` 改为“交易门店”。
- 结余字段必须删除或拆出，因为交易门店没有自然的余额结余。
- 可新增来源门店列辅助对账。

### 方案 B：资金归属门店收支结余报表

如果产品定义是“哪个门店的钱发生了增减”，则：

- 充值、消费、收支、结余全部按 `fund_sid = COALESCE(source_sid, shop_id)`。
- `shopName` 改为“余额来源门店/资金归属门店”。
- 这是推荐方案，因为报表已经展示结余字段。

---

## 四、字段级整改清单

| 字段 | 当前问题 | 目标逻辑 |
|---|---|---|
| `shopName` | 标题是交易门店，但结余是余额来源门店 | 改为“资金归属门店”；或拆成 `tradeShopName` 和 `sourceShopName` |
| `consume_times` | 当前按消费发生门店 | 按 `fund_sid` 汇总扣款次数；撤销反向冲回 |
| `consume_total` | 当前按消费发生门店 | 按 `fund_sid` 汇总扣减金额，展示正数 |
| `consume_principal` | 当前按消费发生门店 | 按 `fund_sid` 汇总扣减本金 |
| `consume_present` | 当前按消费发生门店 | 按 `fund_sid` 汇总扣减赠送金额 |
| `charge_times` | 充值通常发生门店等于来源门店，但撤销/调整仍需统一 | 按 `fund_sid` 汇总 |
| `charge_total` | 同上 | 按 `fund_sid` 汇总 |
| `charge_principal` | 同上 | 按 `fund_sid` 汇总本金 |
| `charge_present` | 同上 | 按 `fund_sid` 汇总赠送金额 |
| `total_amount` | 当前是发生门店净额 | 改为来源门店净额：充值 - 消费 +/- 其他影响余额操作 |
| `principal_amount` | 同上 | 来源门店本金净额 |
| `present_amount` | 同上 | 来源门店赠送净额 |
| `end_balance` | 字段口径可能正确，但与收支混用 | 保持来源门店口径 |
| `endPrincipal_balance` | 存在字段命名大小写不统一风险 | 建议统一为 `endPrincipalBalance`，前端兼容旧字段一段时间 |
| `endGive_balance` | 同上 | 建议统一为 `endGiveBalance`，前端兼容旧字段一段时间 |

---

## 五、DWS 修改细节

### 5.1 不建议直接覆盖旧表

`dws_crm_income_of_store` 当前可能被其他发生口径报表使用。建议新增来源口径表：

```text
dws_crm_income_of_store_by_source_sid
```

或增加维度字段：

```text
sid_type = 'TRADE' | 'FUND'
```

### 5.2 来源口径 DWS 生成逻辑

目标 SQL 形态：

```sql
SELECT
  company_id AS mid,
  COALESCE(source_sid, shop_id) AS sid,
  toYear(yingyeriqi) AS year_,
  toMonth(yingyeriqi) AS month_,
  toDayOfMonth(yingyeriqi) AS day_,
  SUM(CASE operation_model WHEN 'Consume' THEN 1 WHEN 'CancelOrder' THEN -1 ELSE 0 END) AS consume_times,
  SUM(CASE operation_model WHEN 'Consume' THEN -1 WHEN 'CancelOrder' THEN -1 ELSE 0 END * principal_amount) AS consume_principal,
  SUM(CASE operation_model WHEN 'Consume' THEN -1 WHEN 'CancelOrder' THEN -1 ELSE 0 END * give_amount) AS consume_present,
  SUM(CASE operation_model WHEN 'Charge' THEN 1 WHEN 'ChargeCancel' THEN -1 ELSE 0 END) AS charge_times,
  SUM(CASE operation_model WHEN 'Charge' THEN 1 WHEN 'ChargeCancel' THEN 1 ELSE 0 END * principal_amount) AS charge_principal,
  SUM(CASE operation_model WHEN 'Charge' THEN 1 WHEN 'ChargeCancel' THEN 1 ELSE 0 END * give_amount) AS charge_present
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND yingyeriqi BETWEEN :beginTime AND :endTime
GROUP BY company_id, COALESCE(source_sid, shop_id), year_, month_, day_
```

`principal/present` 净收支建议按展示口径重算：

```text
principal = charge_principal - consume_principal + 其他增加 - 其他减少
present   = charge_present   - consume_present   + 其他增加 - 其他减少
```

如果继续沿用现有有符号金额，也必须在文档和字段注释中写明。

---

## 六、接口查询修改细节

### 6.1 查询来源口径收支

`getPage()` 中查询 `dws_crm_income_of_store` 的 SQL 应切换到来源口径表或带 `sid_type='FUND'` 的数据。

门店筛选：

```sql
AND sid IN (:sidList)
```

这里的 `sid` 必须代表资金归属门店，不是交易发生门店。

### 6.2 查询结余

结余继续来自来源口径余额快照：

```sql
SELECT
  sid,
  argMax(end_balance, toDate(report_date)) AS endBalance,
  argMax(end_principal_balance, toDate(report_date)) AS endPrincipalBalance,
  argMax(end_give_balance, toDate(report_date)) AS endGiveBalance
FROM dws_crm_day_summary_by_source_sid
WHERE mid = :mid
  AND sid IN (:sidList)
  AND report_date BETWEEN :begin AND :end
GROUP BY sid
```

如果短期仍使用旧 `dws_crm_day_summary_by_day_with_sid`，必须确认它的 `sid` 是余额来源门店。

---

## 七、验收用例

| 用例 | 资金归属口径预期 |
|---|---|
| A 充 100，A 消 30 | A：充值 100，消费 30，净收支 70，结余 70 |
| A 充 100，B 消 30 | A：充值 100，消费 30，净收支 70，结余 70；B：无资金归属收支 |
| B 店交易发生口径查询 | 应通过另一张发生报表体现 B 消费 30，不应在本表混入 |
| 消费撤销 30 | A 消费冲回，结余回到 100 |
| 门店权限 | A 店角色能看到 B 店消费扣 A 来源余额的影响；B 店角色不能看到 A 来源余额结余 |

---

## 八、兼容措施

1. 不删除旧 `dws_crm_income_of_store`。
2. 新增来源口径表或 `sid_type`，先双写一段时间。
3. 前端字段名 `endPrincipal_balance/endGive_balance` 保留兼容，同时新增标准驼峰字段。
4. 报表标题建议改成“会员卡资金归属门店收支结余表”。

