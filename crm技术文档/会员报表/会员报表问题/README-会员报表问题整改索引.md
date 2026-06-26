# 会员报表问题整改索引

> 目录：`D:\mywork\techdoc\crm技术文档\会员报表\会员报表问题`
>
> 生成日期：2026-06-02
>
> 目标：把会员报表在多门店充值、跨店消费、来源余额扣款模型下的问题拆成可执行整改项。

---

## 一、核心结论

CRM 会员卡模型不是简单的：

```text
门店余额 = 该门店充值 - 该门店消费
```

真实模型是：

```text
会员在 A 店充值，形成 A 店来源余额；
会员可以在 B 店消费；
B 店消费时可以扣 A 店来源余额；
消费流水的 shop_id = B；
扣款来源的 source_sid = A；
当前剩余余额在 crm_card_balance.sid = A。
```

因此报表必须区分：

| 维度 | 字段 | 含义 |
|---|---|---|
| 交易发生门店 | `crm_card_record.shop_id` | 操作在哪里发生 |
| 余额来源门店 | `COALESCE(crm_card_record.source_sid, crm_card_record.shop_id)` | 钱属于哪个充值来源门店 |
| 期末余额门店 | `crm_card_balance.sid` | 当前余额归属哪个门店 |

---

## 二、整改优先级

| 优先级 | 报表 | 问题性质 | 详细文档 |
|---|---|---|---|
| P0 | `member_shop_balance_summary` | 期末按余额来源门店，本期流水按交易发生门店，期初倒推必错 | `01-member_shop_balance_summary-门店会员余额汇总整改说明.md` |
| P0 | `card_income_summary` | 收支按发生门店，结余按来源门店，报表整体不自洽 | `02-card_income_summary-会员卡连锁门店收支报表整改说明.md` |
| P0 | `card_settle_summary` | 跨店结算没有按 `source_sid` 生成双边应收应付 | `03-card_settle_summary-会员卡金额结算表整改说明.md` |
| P1 | `member_consumer_summary` | 发生口径可保留，但缺少余额来源门店字段 | `06-member_consumer_summary-会员消费汇总整改说明.md` |
| P1 | `member_cosnumer_detail` | 消费明细缺少来源门店，无法跨店对账 | `07-member_cosnumer_detail-会员消费明细整改说明.md` |
| P1 | `member_trans_detail` | 交易明细缺少来源门店，`balance_after` 合计/语义需修正 | `08-member_trans_detail-会员交易明细整改说明.md` |
| P2 | `member_balance_summary` | 全商户总表可成立，门店口径不成立 | `04-member_balance_summary-会员余额汇总整改说明.md` |
| P2 | `member_account_summary` | 单卡全商户可成立，门店来源余额需按 `crm_card_balance` 拆行 | `05-member_account_summary-会员账户汇总整改说明.md` |
| P2 | `member_charege_summary` | 充值发生口径基本成立，但需补来源门店和命名 | `09-member_charege_summary-会员充值汇总整改说明.md` |
| P2 | `member_charege_detail` | 充值明细需补来源门店，避免红冲/蓝补无法追溯 | `10-member_charege_detail-会员充值明细整改说明.md` |

---

## 三、字段问题总表

| 报表 | 重点问题字段 |
|---|---|
| `member_shop_balance_summary` | `beginBalance`、`beginPrincipalBalance`、`beginGiveBalance`、`consume*`、`credit*`、`redPunch*`、`bluePunch*`、`cashBack*`、`transferOut*`、`transferIn*`、`end*` |
| `card_income_summary` | `consume_*`、`charge_*`、`total_amount`、`principal_amount`、`present_amount`、`end_balance`、`endPrincipal_balance`、`endGive_balance`、`shopName` |
| `card_settle_summary` | `fromOther*`、`toOther*`、`principal`、`gift`、`total` |
| `member_balance_summary` | 门店口径下的 `begin*`、`save*`、`consume*`、`end*` |
| `member_account_summary` | 门店口径下的 `beginBalance`、`save*`、`consume*`、`end*`，新增 `sourceSid/sourceShopName` |
| `member_consumer_summary` | `shopName`、`amount`、`principalAmount`、`giveAmount`，新增 `sourceSid/sourceShopName` |
| `member_cosnumer_detail` | `shop_name`、`balance_after`，新增 `source_sid/source_shop_name` |
| `member_trans_detail` | `shop_name`、`balance_after`、`amount`、`principal_amount`、`give_amount`，新增来源门店 |
| `member_charege_summary` | `shopName`，新增 `sourceSid/sourceShopName` |
| `member_charege_detail` | `shop_name`、`balance_after`，新增 `source_sid/source_shop_name` |

---

## 四、建议落地顺序

1. 先改 `member_shop_balance_summary`，验证“期初 + 增加 - 减少 = 期末”。
2. 再改 `card_income_summary`，统一收支和结余口径。
3. 再改 `card_settle_summary`，生成跨店应收应付双边分录。
4. 给消费汇总、消费明细、交易明细补来源门店字段。
5. 最后处理 `member_balance_summary` 和 `member_account_summary` 的门店权限与产品定义。
6. 充值汇总/明细保持发生口径，但补来源门店和字段标题。

---

## 五、开发注意事项

1. 不要直接把所有 `shop_id` 替换成 `source_sid`。
2. 发生口径报表继续用 `shop_id`。
3. 余额/结余/资金归属报表必须用 `COALESCE(source_sid, shop_id)`。
4. 期末余额必须来自 `crm_card_balance.sid` 或同口径快照。
5. 门店权限的 `sids` 要按报表口径过滤不同字段。
6. 旧接口如果已有用户依赖，优先新增 `dimension=TRADE|FUND` 或新增 DWS 表，不要静默改变旧口径。

---

## 六、统一验收 SQL 思路

余额来源口径报表必须满足：

```text
期初余额 + 本期来源门店增加 - 本期来源门店减少 = 期末余额
```

跨店结算报表必须满足：

```text
全商户 sum(应收) = 全商户 sum(应付)
全商户 sum(结算合计) = 0
```

发生口径报表必须满足：

```text
消费发生门店汇总 = 消费明细按 shop_id 求和
来源门店汇总 = 消费明细按 COALESCE(source_sid, shop_id) 求和
```

