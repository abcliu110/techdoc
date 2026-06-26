# member_balance_summary 会员余额汇总整改说明

> 接口：`POST /ck/member_balance_summary`
>
> 控制器：`MemberBalanceSummaryController`
>
> 优先级：P2，取决于产品定义。
>
> 当前更接近：全商户会员余额总表。

---

## 一、当前逻辑

当前报表按 `mid` 汇总所有会员卡余额：

- 当日期末来自 `crm_card.balance/principal_balance/give_balance/points`
- 历史期末来自 `dws_crm_day_snapshoot_by_day`
- 本期发生额来自 `crm_card_record`
- 期初由期末和本期发生额倒推

当前代码基本没有按门店 `sids/sidList` 过滤余额和流水。

---

## 二、它什么时候是正确的

如果该报表定义为“商户整体会员余额汇总”，则跨店充值消费不会破坏总额：

| 场景 | 全商户结果 |
|---|---|
| A 充 100，B 消 30 | 充值 100，消费 30，期末 70 |

因为全商户范围内 A/B 门店差异会抵消，所以总额口径可以成立。

---

## 三、它什么时候有问题

如果门店角色打开该报表，或前端允许按门店筛选，则当前逻辑不自洽：

| 问题 | 说明 |
|---|---|
| 门店筛选无效或含义不清 | 报表主要按 `mid` 查询，不按 `sidList` 查来源余额 |
| 无法代表门店资金归属 | `crm_card.balance` 是卡总余额，不区分充值来源门店 |
| 发生额和余额缺少同一门店维度 | 卡余额总额不能与门店发生额直接倒推 |

---

## 四、字段级整改清单

| 字段 | 全商户口径 | 门店资金归属口径 |
|---|---|---|
| `beginBalance` | 可保留现逻辑 | 必须改为来源门店期初 |
| `beginPrincipalBalance` | 可保留现逻辑 | 按 `crm_card_balance.sid` + 来源流水倒推 |
| `beginGiveBalance` | 可保留现逻辑 | 同上 |
| `save*` | 全商户发生额可保留 | 按 `COALESCE(source_sid, shop_id)` 过滤/汇总 |
| `consume*` | 全商户发生额可保留 | 按 `COALESCE(source_sid, shop_id)` 过滤/汇总 |
| `endBalance` | 可保留 `crm_card.balance` 总额 | 改为 `crm_card_balance.total` 按来源门店汇总 |
| `endPrincipalBalance` | 可保留 | 改为 `crm_card_balance.principal` |
| `endGiveBalance` | 可保留 | 改为 `crm_card_balance.gift` |

---

## 五、推荐改法

### 5.1 保留全商户总表

如果产品只需要集团/商户总览：

1. 报表标题改为“会员余额总汇总（全商户）”。
2. 门店角色不展示该报表，或展示时明确“全商户数据”。
3. 前端去掉门店筛选，避免误导。
4. 后端如果收到 `sids/sidList`，直接忽略并记录说明，或返回错误提示“该报表不支持门店筛选”。

### 5.2 新增门店来源余额版本

如果必须给门店财务看：

1. 查询期末：

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

2. 查询本期发生额：

```sql
SELECT
  COALESCE(source_sid, shop_id) AS sid,
  SUM(...) AS saveTotal,
  SUM(...) AS consumeTotal
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND COALESCE(source_sid, shop_id) IN (:sidList)
GROUP BY COALESCE(source_sid, shop_id)
```

3. 按来源门店倒推期初。
4. 报表名称改为“门店会员余额汇总”，避免与全商户总表混淆。

---

## 六、权限规则

| 用户角色 | 推荐行为 |
|---|---|
| 集团财务/管理员 | 可看全商户总表 |
| 门店管理员/门店财务 | 默认不看全商户总表；如要看，必须看来源门店版本 |

门店来源版本中，`sids` 必须过滤 `crm_card_balance.sid` 和 `COALESCE(source_sid, shop_id)`。

---

## 七、验收用例

| 用例 | 全商户总表 | 门店来源版本 |
|---|---|---|
| A 充 100，B 消 30 | 充值 100，消费 30，期末 70 | A：充值 100，消费 30，期末 70；B：0 |
| A 店角色查询 | 如果保留全商户表，应禁止或明确全商户 | 只看到 A 来源余额 |
| B 店角色查询 | 如果保留全商户表，应禁止或明确全商户 | 不看到扣 A 钱的消费影响 |

---

## 八、结论

这张报表不是天然错误。它作为“全商户总余额表”可以成立；作为“门店余额表”则必须重做来源门店口径。

