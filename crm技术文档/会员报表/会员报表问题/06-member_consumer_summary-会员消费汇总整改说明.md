# member_consumer_summary 会员消费汇总整改说明

> 接口：`POST /ck/member_consumer_summary`
>
> 控制器：`MemberConsumerSummary`
>
> 优先级：P1，需要补来源门店字段或新增资金归属版本。
>
> 当前口径：消费发生门店。

---

## 一、当前逻辑

当前报表从 `crm_card_record` 查询，默认操作类型：

```text
Consume, CancelOrder, Repay, Reverse
```

按以下字段分组：

- `shopName`
- `memberName`
- `phone`

汇总字段：

- `amount`
- `principalAmount`
- `giveAmount`

查询基于通用 `getBaseQuery()`，门店筛选落在 `crm_card_record.shop_id`，也就是消费发生门店。

---

## 二、当前逻辑哪些成立

如果报表定义是“会员在哪里消费”，当前按 `shop_id` 统计是合理的。

场景：A 店充值，B 店消费。

该报表显示 B 店消费 30，是正确的发生口径。

---

## 三、当前逻辑哪里会误导

如果财务拿这张表解释“哪个门店的会员余额被扣了”，当前字段不够：

| 字段 | 当前含义 | 风险 |
|---|---|---|
| `shopName` | 消费发生门店 | 容易被理解为扣款来源门店 |
| `amount` | 发生门店消费金额 | 不代表该门店充值余额减少 |
| `principalAmount` | 消费流水本金部分 | 不说明扣的是哪个来源门店本金 |
| `giveAmount` | 消费流水赠送部分 | 不说明扣的是哪个来源门店赠送 |

---

## 四、字段级整改清单

| 字段 | 修改动作 | 说明 |
|---|---|---|
| `shopName` | 标题改为“消费门店”或“交易门店” | 保留旧 dataIndex，兼容前端 |
| 新增 `tradeSid` | 从 `shop_id` 取值 | 便于前端和导出追溯 |
| 新增 `tradeShopName` | 可与 `shopName` 同值 | 新字段语义更清楚 |
| 新增 `sourceSid` | `COALESCE(source_sid, shop_id)` | 余额来源门店 |
| 新增 `sourceShopName` | 根据 `sourceSid` 查门店名称 | 用于资金归属对账 |
| `amount` | 保留发生口径 | 标题改为“消费金额（发生口径）” |
| `principalAmount` | 保留发生口径 | 同时可用于来源拆分 |
| `giveAmount` | 保留发生口径 | 同上 |

---

## 五、两种实现方式

### 5.1 最小兼容实现

保持原分组不变，只新增来源门店字段不参与分组。

问题：同一个会员在同一个消费门店同一天可能扣多个来源门店余额，如果不按来源门店分组，`sourceShopName` 只能显示多个来源门店拼接值，不利于对账。

### 5.2 推荐实现

分组增加来源门店：

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
  AND operation_model IN ('Consume', 'CancelOrder', 'Repay', 'Reverse')
  AND shop_id IN (:tradeSidList)
GROUP BY shop_id, shop_name, COALESCE(source_sid, shop_id), member_name, phone
```

前端展示：

| 消费门店 | 余额来源门店 | 会员 | 手机 | 消费金额 | 消费本金 | 消费赠送 |
|---|---|---|---|---:|---:|---:|

---

## 六、资金归属版本

如果要做“来源门店会员消费汇总”，应新增参数或新接口，不要覆盖旧发生口径：

```sql
SELECT
  COALESCE(source_sid, shop_id) AS sourceSid,
  member_name,
  phone,
  SUM(amount) AS amount,
  SUM(principal_amount) AS principalAmount,
  SUM(give_amount) AS giveAmount
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND operation_model IN ('Consume', 'CancelOrder', 'Repay', 'Reverse')
  AND COALESCE(source_sid, shop_id) IN (:sourceSidList)
GROUP BY COALESCE(source_sid, shop_id), member_name, phone
```

---

## 七、权限规则

| 报表模式 | 门店筛选字段 |
|---|---|
| 消费发生口径 | `shop_id` |
| 资金归属口径 | `COALESCE(source_sid, shop_id)` |

如果一个接口同时支持两种模式，必须新增请求参数，例如：

```text
dimension = TRADE | FUND
```

默认保持 `TRADE`，避免破坏旧用户习惯。

---

## 八、验收用例

| 用例 | 发生口径预期 | 来源口径预期 |
|---|---|---|
| A 充 100，B 消 30 | B 消费 30，来源门店 A | A 来源消费 30 |
| B 消费扣 A 20、C 10 | B 两行或一行展示来源 A/C | A 消费 20，C 消费 10 |
| B 店角色查询发生口径 | 能看到 B 店发生消费 | 不代表 B 来源余额 |
| A 店角色查询来源口径 | 能看到扣 A 钱的消费 | 即使消费发生在 B 店也应看到 |

