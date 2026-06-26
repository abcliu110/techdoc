# member_shop_balance_summary 门店会员余额汇总整改说明

> 接口：`POST /ck/member_shop_balance_summary`
>
> 控制器：`MemberShopBalanceSummaryController`
>
> 优先级：P0，必须修。
>
> 目标口径：余额来源门店 / 资金归属门店。

---

## 一、当前逻辑

当前报表展示“期初、充值、消费、回款、红冲、蓝补、返现、转账、结余”等字段，字段形态看起来是门店会员卡余额报表。

现有取数路径：

| 数据块 | 当前来源 | 当前门店字段 |
|---|---|---|
| 当日期末 | `crm_card_balance` 汇总 `total/principal/gift` | `crm_card_balance.sid` |
| 历史期末 | `dws_crm_day_summary_by_day_with_sid` 的 `end_balance/end_principal_balance/end_give_balance` | DWS `sid` |
| 本期发生额 | `crm_card_record` 按 `operation_model` 聚合 | `crm_card_record.shop_id`，实体中为 `CrmCardRecord.sid` |
| 期初 | 用期末和本期发生额倒推 | 继承上面两个口径 |

代码中期末按 `sid` 聚合余额，本期流水按 `shop_id` 聚合后再按同一个 `sid` 合并。跨店消费时这两个 `sid` 不是同一个业务含义。

---

## 二、为什么现在不自洽

场景：A 店充值 100，B 店消费 30，扣的是 A 店充值余额。

当前逻辑会得到：

| 门店 | 期末来源 | 本期消费来源 | 报表表现 |
|---|---|---|---|
| A 店 | `crm_card_balance.sid=A`，期末 70 | 消费按 `shop_id=B`，A 没消费 | A 店看起来充值 100、消费 0、期末 70 |
| B 店 | B 无余额来源，期末 0 | `shop_id=B`，消费 30 | B 店看起来消费 30、期末 0 |

这个结果无法通过余额公式：

```text
期初 + 本期充值 - 本期消费 = 期末
```

根因不是“没有设计期初字段”，而是期初倒推所依赖的“期末”和“本期发生额”门店口径不同。

---

## 三、字段级整改清单

| 字段 | 当前问题 | 目标逻辑 |
|---|---|---|
| `shopName` | 实际混用了余额来源门店和交易发生门店 | 改为“余额来源门店”；数据来自 `fund_sid` 对应门店 |
| `beginBalance` | 用来源门店期末 + 发生门店流水倒推 | 用来源门店期末 + 来源门店本期流水倒推 |
| `beginPrincipalBalance` | 同上 | 同上，本金维度 |
| `beginGiveBalance` | 同上 | 同上，赠送维度 |
| `saveTimes/saveTotal/savePrincipal/saveGift` | 充值通常问题较小，但撤销/调整仍应统一口径 | 按 `fund_sid = COALESCE(source_sid, shop_id)` 聚合 |
| `consumeTimes/consumeTotal/consumePrincipal/consumeGift` | 当前按消费发生门店 `shop_id` | 改为按扣款来源门店 `fund_sid` |
| `credit*` | 当前按发生门店 | 如果影响余额，改为按 `fund_sid` |
| `redPunch*` | 当前按发生门店 | 如果红冲作用于来源余额，按 `fund_sid` |
| `bluePunch*` | 当前按发生门店 | 如果蓝补作用于来源余额，按 `fund_sid` |
| `cashBack*` | 当前按发生门店 | 如果返现冲减来源余额，按 `fund_sid` |
| `transferOut* / transferIn*` | 当前按发生门店 | 按实际余额来源门店；如转账有转出/转入来源，需要补全业务定义 |
| `endBalance/endPrincipalBalance/endGiveBalance` | 字段本身按来源门店基本合理，但与发生额混用 | 保持来源门店口径，并加门店权限过滤 |

---

## 四、后端查询修改细节

### 4.1 定义来源门店表达式

ClickHouse / SQL 中统一使用：

```sql
fund_sid = COALESCE(source_sid, shop_id)
```

MyBatis-Flex 中可以用 RawQueryColumn：

```java
new RawQueryColumn("COALESCE(source_sid, shop_id)").as("sid")
```

### 4.2 本期发生额改造

当前按 `shop_id` 分组：

```sql
SELECT shop_id, ...
FROM crm_card_record
WHERE company_id = :mid
GROUP BY shop_id
```

目标按 `fund_sid` 分组：

```sql
SELECT
  COALESCE(source_sid, shop_id) AS sid,
  SUM(CASE operation_model WHEN 'Charge' THEN 1 WHEN 'ChargeCancel' THEN -1 ELSE 0 END) AS saveTimes,
  SUM(CASE operation_model WHEN 'Consume' THEN 1 WHEN 'CancelOrder' THEN -1 ELSE 0 END) AS consumeTimes,
  SUM(CASE operation_model WHEN 'Charge' THEN 1 WHEN 'ChargeCancel' THEN 1 ELSE 0 END * (principal_amount + give_amount)) AS saveTotal,
  SUM(CASE operation_model WHEN 'Consume' THEN -1 WHEN 'CancelOrder' THEN -1 ELSE 0 END * (principal_amount + give_amount)) AS consumeTotal
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND yingyeriqi BETWEEN :beginTime AND :endTime
  AND COALESCE(source_sid, shop_id) IN (:sidList)
GROUP BY COALESCE(source_sid, shop_id)
```

其余 `credit/redPunch/bluePunch/cashBack/transfer` 字段按现有 `operation_model` 规则迁移分组字段，不要改金额正负逻辑。

### 4.3 期末余额改造

当日查询：

```sql
SELECT
  sid,
  SUM(total) AS endBalance,
  SUM(principal) AS endPrincipalBalance,
  SUM(gift) AS endGiveBalance
FROM crm_card_balance
WHERE mid = :mid
  AND sid IN (:sidList)
GROUP BY sid
```

历史查询：

优先新增来源口径快照表：

```text
dws_crm_day_summary_by_source_sid
```

如果短期仍使用 `dws_crm_day_summary_by_day_with_sid`，必须先确认该表的 `sid` 是从 `crm_card_balance.sid` 生成，而不是从 `crm_card_record.shop_id` 生成。无法确认时，不允许用它做财务结余依据。

### 4.4 期初倒推公式

当前代码的倒推思路可以保留，但输入必须统一为来源门店口径：

```text
期初 = 期末
     - 充值
     + 消费
     + 回款
     + 红冲
     - 蓝补
     - 返现
     + 转出
     - 转入
```

本金和赠送分别套用同一公式。

---

## 五、权限修改细节

门店角色查询该报表时，`sids/sidList` 必须过滤：

- `crm_card_balance.sid`
- `COALESCE(crm_card_record.source_sid, crm_card_record.shop_id)`

不能过滤 `crm_card_record.shop_id`，否则 A 店资金在 B 店消费时，A 店看不到自己余额被扣减。

---

## 六、验收用例

| 用例 | 预期 |
|---|---|
| A 店充 100，A 店消 30 | A 店期初 0，充值 100，消费 30，期末 70 |
| A 店充 100，B 店消 30，`source_sid=A` | A 店期初 0，充值 100，消费 30，期末 70；B 店在本报表不体现余额变动 |
| B 店角色查询余额来源报表 | 只能看到来源门店为 B 的余额，不看到仅发生在 B 但扣 A 钱的消费 |
| A 店角色查询余额来源报表 | 能看到 B 店消费扣减 A 来源余额的 30 |
| 撤销 B 店消费 30 | A 店消费字段冲回，期末回到 100 |

---

## 七、兼容建议

不要直接把旧接口改成发生门店口径。该报表名称是“门店余额汇总”，应以资金归属为准。

如前端已有用户习惯按发生门店查看消费，应新增“会员消费发生门店汇总”报表，而不是让余额汇总继续混用口径。

