# member_account_summary 会员账户汇总整改说明

> 接口：`POST /ck/member_account_summary`
>
> 控制器：`MemberBalanceFlowController`
>
> 优先级：P2，门店权限下需要修。
>
> 当前更接近：按会员卡维度的全商户账户汇总。

---

## 一、当前逻辑

当前报表按会员卡分页：

1. 从 `crm_card` 查询卡号、会员、卡类型、卡总余额。
2. 从 `dws_crm_day_snapshoot_by_day` 或当前 `crm_card` 取期末。
3. 从 `crm_card_record` 按 `card_id` 汇总本期充值、消费、红冲、蓝补等发生额。
4. 用期末和本期发生额倒推期初。

这套逻辑对“单卡全商户总余额”基本成立，因为一张卡的余额不需要按门店拆分。

---

## 二、门店模式下的问题

如果门店角色希望看“本店会员资金余额”，当前报表会有问题：

| 问题 | 说明 |
|---|---|
| `crm_card.balance` 是卡总余额 | 不区分 A 店充值余额和 B 店充值余额 |
| 本期流水按卡汇总 | 没有按 `source_sid` 拆分 |
| 门店筛选不完整 | 卡列表查询按 `mid`，不是来源门店 |
| 期初倒推不成立 | 卡总期末不能和某门店发生额倒推 |

---

## 三、字段级整改清单

| 字段 | 当前全商户口径 | 门店来源口径目标 |
|---|---|---|
| `memberName` | 可保留 | 可保留 |
| `phone` | 可保留 | 可保留 |
| `cardId` | 可保留 | 可保留 |
| `memberType` | 可保留 | 可保留 |
| `beginBalance` | 卡总期初 | 来源门店下该卡期初 |
| `save*` | 该卡全商户充值 | 该卡在来源门店下的充值/调整 |
| `consume*` | 该卡全商户消费 | 该卡扣减该来源门店余额的消费 |
| `endBalance` | 卡总期末 | 来源门店下该卡期末 |
| `endPrincipalBalance` | 卡总本金期末 | 来源门店下该卡本金期末 |
| `endGiveBalance` | 卡总赠送期末 | 来源门店下该卡赠送期末 |
| 新增 `sourceSid/sourceShopName` | 无 | 必须新增，用于标识余额来源门店 |

---

## 四、推荐改法

### 4.1 保留现接口为全商户单卡账户汇总

如果产品定义是“会员账户总览”：

- 报表名称改为“会员账户汇总（全商户）”。
- 门店角色不展示该报表，或明确展示的是全商户卡余额。
- 不允许按门店解释 `endBalance`。

### 4.2 新增或扩展门店来源账户汇总

如果要给门店财务使用，基础行应从 `crm_card_balance` 出发，而不是 `crm_card`：

```sql
SELECT
  c.card_lid,
  c.card_id,
  c.member_name,
  b.sid AS source_sid,
  SUM(b.total) AS endBalance,
  SUM(b.principal) AS endPrincipalBalance,
  SUM(b.gift) AS endGiveBalance
FROM crm_card_balance b
JOIN crm_card c ON c.lmnid = b.cno OR c.lmnid = b.card_lid
WHERE b.mid = :mid
  AND b.sid IN (:sidList)
GROUP BY c.card_lid, c.card_id, c.member_name, b.sid
```

具体关联字段需以当前表结构为准，原则是：余额行必须来自 `crm_card_balance.sid`。

本期发生额：

```sql
SELECT
  card_id AS card_lid,
  COALESCE(source_sid, shop_id) AS source_sid,
  SUM(...) AS saveTotal,
  SUM(...) AS consumeTotal
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND COALESCE(source_sid, shop_id) IN (:sidList)
  AND yingyeriqi BETWEEN :beginTime AND :endTime
GROUP BY card_id, COALESCE(source_sid, shop_id)
```

然后按 `(card_lid, source_sid)` 合并期末和本期发生额，倒推期初。

---

## 五、前端展示修改

门店来源版本建议增加列：

| 列 | 含义 |
|---|---|
| `sourceShopName` | 余额来源门店 |
| `cardId` | 会员卡号 |
| `memberName` | 会员姓名 |
| `beginBalance` | 该来源门店下该卡期初 |
| `save*` | 该来源门店下该卡本期增加 |
| `consume*` | 该来源门店下该卡本期减少 |
| `endBalance` | 该来源门店下该卡期末 |

如果一张卡有 A、C 两个来源门店余额，应出现两行，而不是合成一行。

---

## 六、验收用例

| 用例 | 全商户账户汇总 | 门店来源账户汇总 |
|---|---|---|
| 卡 1 在 A 充 100，B 消 30 | 卡 1 期末 70 | A 来源行期末 70；B 无来源行 |
| 卡 1 在 A 充 100，C 充 50，B 消 30，分别扣 A 20/C 10 | 卡 1 期末 120 | A 来源行 80，C 来源行 40 |
| A 店角色查询 | 不建议展示全商户版本 | 只看到 A 来源行 |

---

## 七、兼容建议

不要直接改旧接口返回粒度，否则前端分页和导出可能受影响。建议：

1. 旧接口保持全商户单卡总览。
2. 新增参数 `dimension=sourceShop` 或新增接口。
3. 文档和前端标题明确两者区别。

