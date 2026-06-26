# member_trans_detail 会员交易明细整改说明

> 接口：`POST /ck/member_trans_detail`
>
> 控制器：`MemberTransactionDetail`
>
> 优先级：P1，需要补来源门店字段，并修正合计语义。
>
> 当前口径：会员卡交易发生明细。

---

## 一、当前逻辑

当前报表查询 `crm_card_record`，如果未指定 `operationModels`，则展示全部会员卡操作。

展示字段包括：

- `shop_name`
- `create_time`
- `member_name`
- `phone`
- `card_id_alias`
- `amount`
- `give_amount`
- `principal_amount`
- `give_point`
- `balance_after`
- `order_bill_id`
- `subject`
- `comment`
- `operation_model2`
- `operator`

当前 `shop_name` 是交易发生门店。

---

## 二、主要问题

| 字段 | 当前问题 | 影响 |
|---|---|---|
| `shop_name` | 未说明是交易发生门店 | 财务可能误认为是余额来源门店 |
| 缺少 `source_sid/source_shop_name` | 无法追踪余额来源 | 跨店扣款、撤销、调整无法对账 |
| `balance_after` | 明细字段可以展示，但合计无意义 | 当前合计如果求和，会产生错误解释 |
| `amount/principal_amount/give_amount` | 不同操作正负方向不同 | 需要明确“按流水原值展示”还是“按业务方向展示” |

---

## 三、字段级整改清单

| 字段 | 修改动作 | 说明 |
|---|---|---|
| `shop_name` | 标题改为“交易门店” | 保留 dataIndex |
| 新增 `trade_sid` | `shop_id` | 交易发生门店 ID |
| 新增 `trade_shop_name` | `shop_name` | 交易发生门店名称 |
| 新增 `source_sid` | `COALESCE(source_sid, shop_id)` | 余额来源门店 ID |
| 新增 `source_shop_name` | 根据 `source_sid` 查门店 | 余额来源门店名称 |
| `amount` | 标题保留“总金额”，注释说明按流水方向 | 不直接解释为门店收入 |
| `principal_amount` | 标题保留“本金” | 对消费表示扣减本金，对充值表示增加本金 |
| `give_amount` | 标题保留“赠送” | 同上 |
| `balance_after` | 标题改为“卡交易后总余额” | 不参与合计 |

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
  give_point,
  balance_after,
  order_bill_id,
  IF(IFNULL(subject, '') = '', pay_way, subject) AS subject,
  operation_model,
  operator,
  comment
FROM crm_card_record
WHERE company_id = :mid
  AND if_deal_success = 1
  AND yingyeriqi BETWEEN :beginTime AND :endTime
  AND shop_id IN (:tradeSidList)
ORDER BY create_time ASC
```

当用户按资金来源查账时，新增筛选：

```sql
AND COALESCE(source_sid, shop_id) IN (:sourceSidList)
```

---

## 五、合计行必须修改

当前交易明细如果合计 `balance_after`，逻辑不成立。

原因：

```text
balance_after 是每笔交易后的卡余额快照。
多笔交易的余额快照不能相加。
```

合计行规则：

| 字段 | 是否合计 |
|---|---|
| `amount` | 可以 |
| `principal_amount` | 可以 |
| `give_amount` | 可以 |
| `give_point` | 可以 |
| `balance_after` | 不可以，合计行置空或显示 `--` |

---

## 六、前端展示建议

列顺序建议：

1. 交易门店
2. 余额来源门店
3. 交易日期
4. 会员姓名
5. 会员手机
6. 会员卡号
7. 会员卡操作
8. 总金额
9. 本金
10. 赠送
11. 积分
12. 卡交易后总余额
13. 单号
14. 其他信息
15. 备注
16. 操作人

---

## 七、验收用例

| 用例 | 预期 |
|---|---|
| A 充 100 | 交易门店 A，来源门店 A |
| B 消费扣 A 30 | 交易门店 B，来源门店 A |
| B 消费撤销 | 交易门店 B，来源门店 A |
| 合计行 | 金额字段合计，`balance_after` 不合计 |
| 来源门店筛选 A | 能查到 B 店消费扣 A 钱的流水 |

