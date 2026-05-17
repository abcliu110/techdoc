# 会员券报表财务合规实施方案

**日期**: 2026-05-14

**文档状态**: V2（评审修复版）

**评审记录**：

| 版本 | 日期 | 评审内容 | 修复问题 |
|------|------|---------|---------|
| V1 初稿 | 2026-05-14 | — | — |
| V2 评审修复版 | 2026-05-14 | 三轮并行评审（财务合规/数据库技术/CRM业务） | 修复 SQL 逻辑错误 3 处（R03期末未核销条件/过期统计双状态/折扣率NULL处理）、新增 R09 退款冲回报表、修正勾稽公式增加退款冲回维度、补充作废与过期财务处理差异说明、明确红包与券的报表边界、增加与现有 R15/R16/R17 报表的关系说明 |
| V3 时间口径修正版 | 2026-05-14 | 复核财务报表时间过滤习惯 | 明确事件型报表必须有会计期间；R03/R08 说明为时点余额试算且不能用当前状态重算历史；修正 R04/R06/R08/R09 的时间边界和勾稽口径 |

## 1. 文档范围

本文档以现有唯一数据库表 `crm_coupon_order` 为数据源，说明基于该表能够实现的券报表类型、字段口径、SQL 示例、勾稽公式、月结流程及合规边界。

本文档的定位是**财务合规最低可行方案**：在不新增表的前提下，穷尽现有字段的报表能力，并对无法满足合规要求的部分明确标注差距和改造建议。

本文档与以下文档构成配套关系：

- [会员券报表理论与字段说明](./会员券报表-理论与字段说明.md) —— 财务理论框架和目标模型
- [现有 crm_coupon_order 能实现哪些券报表-财务合规差距分析](./现有crm_coupon_order能实现哪些券报表-财务合规差距分析.md) —— 逐字段逐报表的差距矩阵

---

## 2. 券类型与字段口径

### 2.1 券类型枚举

`crm_coupon_order.type_` 字段映射如下：

| type_ 值 | 中文名称 | 说明 | 财务口径 |
|---------|---------|------|---------|
| `XJQ` | 现金券 | 按固定金额抵扣 | 折扣/合同负债 |
| `BLJ` | 比例券 | 按订单金额比例抵扣 | 折扣/合同负债 |
| `SWQ` | 实物券 | 兑换指定商品 | 或有负债/代收代付 |
| `DISCOUNT` | 折扣券 | 按折扣率抵扣 | 折扣 |

### 2.2 券模式

`crm_coupon_order.coupon_mode` 字段：

| coupon_mode 值 | 中文名称 | 财务口径 |
|---------------|---------|---------|
| `CP` | 券 | 折扣/合同负债 |
| `RE` | 红包 | 代收代付或营销激励 |

### 2.3 发放渠道

`crm_coupon_order.get_channel` 字段（11 种主要渠道）：

| get_channel 值 | 中文名称 | 对应财务分类 |
|---------------|---------|------------|
| 1 | 自领 | 营销赠券 |
| 2 | 购买获取 | 现金购买券/预收款 |
| 3 | 充值赠送 | 充值赠券/合同负债 |
| 4 | 后台发放 | 营销赠券 |
| 5 | 积分兑换 | 积分兑换券/负债转换 |
| 6 | 消费赠送 | 消费赠券 |
| 7 | 大转盘奖励 | 营销赠券 |
| 8 | 新人礼包 | 营销赠券 |
| 9 | 生日赠送 | 营销赠券 |
| 10 | 购买会员等级赠送 | 营销赠券 |
| 11 | 商家活动赠送 | 营销赠券 |
| 12 | 购卡送券 | 储值赠券/合同负债 |

### 2.4 券状态

`crm_coupon_order.coupon_status` 字段：

| coupon_status 值 | 中文名称 | 含义 |
|-----------------|---------|------|
| `WHX` | 未核销 | 券在有效期内，尚未使用 |
| `YHX` | 已核销 | 券已被使用 |
| `YGQ` | 已过期 | 券超过有效期未使用 |
| `YZF` | 已作废 | 券被主动作废（主动失效，非过期） |
| `WSX` | 未生效 | 券尚未到生效时间 |

> **作废（YZF）与过期（YGQ）的财务处理差异**：两者均释放合同负债或营销负债，但处理时点不同：
> - **作废（YZF）**：由人工或业务系统主动触发，通常在有效期内失效。财务上，视为负债立即释放，可能进入"营业外收入"或冲减对应营销费用科目。
> - **过期（YGQ）**：由时间自然流逝导致有效期内未使用。财务上，未使用权利通常在行权可能性极低时才确认收入（IFRS 15/收入准则），不能直接转为收入。

### 2.5 面值方式说明

`crm_coupon_order.face_value_method` 字段：

| face_value_method 值 | 中文名称 | 面值含义 | 财务合规说明 |
|---------------------|---------|---------|------------|
| `GDF` | 固定面值 | 固定金额，含义清晰 | ✅ 可直接用于面值统计 |
| `RDF` | 随机面值 | 发放时随机生成 | ⚠️ 需确认发放时是否写入了实际随机值；核销时以 `redeemed_face_value` 为准 |
| `GDP` | 固定比例 | 按 `bill_amount` 的固定比例抵扣 | ⚠️ 发放时 `bill_amount` 为空，实际核销面额不确定；需在核销时回写实际面值 |
| `RDP` | 范围比例 | 在 `[proportion_min, proportion_max]` 范围内按比例抵扣 | ⚠️ 发放时面额无法确定；需在核销时回写实际面值 |

**重要**：对于 `RDF`/`GDP`/`RDP` 类券，必须在核销时回写 `redeemed_face_value`（实际核销面额）。现有表若无此字段，核销面额以 `face_value`（发放时的预估值）代替，存在口径误差。

---

### 2.6 报表时间口径总则

财务报表必须先区分时间口径，再写查询条件。不能把事件期间、时点余额和发放批次混在同一个 `WHERE` 条件中解释。

| 口径类型 | 适用报表 | 必须时间条件 | 说明 |
|---------|---------|-------------|------|
| 事件型明细/汇总 | R01、R02、R06、R07 | 对应事件时间必须在 `:beginDate` 至 `:endDate` 内 | 发放用 `get_date`，核销用 `write_off_time`，作废用 `abandon_time` |
| 到期日批次 | R04 | `deadline` 必须在指定到期区间内 | 这是“到期日 cohort”，不是严格事件流水；若用于财务入账，应以过期事件表或月结快照为准 |
| 发放批次分析 | R05 | `get_date` 必须在发放区间内 | 核销率是“该批发放券截至查询时的当前核销率”，会随时间变化；如需固定结果，必须落快照 |
| 时点余额/试算 | R03、R08 | 允许只有截至日上界（如 `get_date <= :statDate` / `:endDate`） | 这是截至某日的余额口径，不是遗漏时间过滤；但基于当前 `coupon_status` 只能重算当前时点，不能可靠重算历史关账结果 |
| 退款冲回 | R09 | 阶段一无独立退款时间，不能作为独立期间报表 | 只能列为风险提示或通过订单退款时间辅助推断；阶段二以事件流水 `event_time` 为准 |

---

## 3. 报表类型总览

基于 `crm_coupon_order` 现有字段，可实现以下 9 类报表：

| 报表编号 | 报表名称 | 合规等级 | 报表层级 | 与现有报表的关系 |
|---------|---------|---------|---------|----------------|
| R01 | 券发行明细表 | 业务运营级 | 明细层 | 本方案财务合规版，对应现有会员赠券记录(R15)、会员红包记录(R16)的发行部分；本方案增加财务口径说明和面值校验 |
| R02 | 券核销明细表 | 业务运营级 | 明细层 | 对应现有会员赠券/红包记录(R15/R16)的核销部分；本方案增加实际核销面额、折扣率字段 |
| R03 | 券日均余额表 | 业务运营级 | 汇总层 | 新增报表，弥补现有系统无日余额快照的空白 |
| R04 | 券过期统计表 | 风控预警级 | 汇总层 | 新增报表，基于现有 crm_coupon_order 的 deadline 字段实现 |
| R05 | 券发放渠道汇总表 | 业务分析级 | 汇总层 | 增强现有报表，增加核销率分析和各渠道面值分拆 |
| R06 | 券作废统计表 | 业务运营级 | 汇总层 | 新增报表，对应会员赠券/红包记录(R15/R16)中的作废场景 |
| R07 | 券核销对账表 | 财务近似级 | 汇总层 | 月结专用，对应现有会员赠券/红包记录的核销统计；本方案增加按发放渠道分拆核销面值（区分合同负债/营销费用/积分转券负债） |
| R08 | 月结券负债试算表 | 财务近似级 | 汇总层 | 新增报表，弥补现有系统无月结负债试算的空白 |
| R09 | 券退款冲回明细表 | 业务运营级 | 明细层 | 新增报表，填补现有赠券/红包记录(R15/R16)中未单独处理的退款场景 |

> **说明**：现有报表编号 R15/R16/R17 来自《会员报表取数与字段说明》，为本方案的已有基础。本方案在功能上是这些报表的财务合规增强版，同时新增了 R03/R04/R06/R08/R09 五类新报表。

---

**红包（coupon_mode = 'RE'）与普通券（coupon_mode = 'CP'）的报表边界**：

- 所有报表（R01~R09）均同时支持 CP 和 RE 两种模式，默认展示全部
- 如需单独查看红包或券的数据，可在 SQL 中增加 `WHERE co.coupon_mode = 'RE'` 或 `= 'CP'` 过滤条件
- 财务口径上，红包按"代收代付或营销激励"处理，普通券按"折扣/合同负债"处理，核销时分拆到不同科目

---

## 4. 明细层报表

### 4.1 R01：券发行明细表

**报表作用**：记录每一张券的发放信息，是所有报表的明细追溯源头。

**适用场景**：运营查询、问题溯源、审计备查。

**数据筛选**：`get_date` 在统计区间内。

**SQL 示例**：

```sql
SELECT
    co.lmnid                                      AS 券号,
    co.coupon                                     AS 券名称,
    co.coupon_code                                AS 券模板ID,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型,
    CASE co.coupon_mode
        WHEN 'CP' THEN '券'
        WHEN 'RE' THEN '红包'
    END                                           AS 券模式,
    CASE co.face_value_method
        WHEN 'GDF' THEN '固定面值'
        WHEN 'RDF' THEN '随机面值'
        WHEN 'GDP' THEN '固定比例'
        WHEN 'RDP' THEN '范围比例'
    END                                           AS 面值方式,
    co.face_value                                 AS 券面值,
    co.face_value_min                             AS 面值下限,
    co.face_value_max                             AS 面值上限,
    co.unionid                                    AS 会员手机号,
    co.member                                     AS 会员名称,
    co.nickname                                   AS 微信昵称,
    co.get_date                                   AS 领取时间,
    co.valid_date                                 AS 生效时间,
    co.deadline                                   AS 有效期截止,
    co.pkg_coupon                                 AS 所属券包,
    co.pkg_coupon_code                            AS 券包ID,
    co.get_channel                                AS 发放渠道代码,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    CASE co.coupon_status
        WHEN 'WHX' THEN '未核销'
        WHEN 'YHX' THEN '已核销'
        WHEN 'YGQ' THEN '已过期'
        WHEN 'YZF' THEN '已作废'
        WHEN 'WSX' THEN '未生效'
    END                                           AS 券状态,
    co.shop_id                                    AS 归属门店ID,
    co.company_id                                 AS 商户ID,
    co.dish_name                                  AS 限用商品名称
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.get_date >= :beginDate
  AND co.get_date < :endDate
  -- 可选：AND co.shop_id IN (:shopIdList)
  -- 可选：AND co.coupon_status = :status
  -- 可选：AND co.get_channel = :channel
  -- 可选：AND co.type_ = :couponType
ORDER BY co.get_date DESC, co.lmnid DESC
```

**字段口径说明**：

| 字段 | 来源 | 口径说明 |
|------|------|---------|
| 券号 | `lmnid` | 雪花算法生成，全局唯一，作为追溯主键 |
| 券面值 | `face_value` | ⚠️ GDP/RDP 类为预估值，非实际核销面额 |
| 会员手机号 | `unionid` | 用于关联会员身份 |
| 领取时间 | `get_date` | 券发放的时间戳 |
| 有效期截止 | `deadline` | 用于判断券是否过期 |

---

### 4.2 R02：券核销明细表

**报表作用**：记录每一张券的核销信息，用于追溯核销去向。

**适用场景**：核销审计、订单关联、门店对账。

**数据筛选**：`coupon_status = 'YHX'` 且 `write_off_time` 在统计区间内。

**SQL 示例**：

```sql
SELECT
    co.lmnid                                      AS 券号,
    co.coupon                                     AS 券名称,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型,
    CASE co.coupon_mode
        WHEN 'CP' THEN '券'
        WHEN 'RE' THEN '红包'
    END                                           AS 券模式,
    co.face_value                                 AS 券面值,
    -- 核销面额优先取实际核销值，无则取面值（口径说明见 2.5）
    IFNULL(co.redeemed_face_value, co.face_value) AS 实际核销面额,
    co.bill_amount                                AS 消费单金额,
    -- 折扣率 = 核销面额 / 消费单金额（bill_amount 可能为空，用 NULLIF 安全处理）
    ROUND(IFNULL(co.redeemed_face_value, co.face_value)
        / NULLIF(co.bill_amount, 0) * 100, 2)     AS 折扣率_百分比,
    co.unionid                                    AS 会员手机号,
    co.member                                     AS 会员名称,
    co.write_off_time                             AS 核销时间,
    co.used_shop_code                             AS 核销门店ID,
    co.used_shop                                  AS 核销门店,
    co.write_off_staff                            AS 核销员,
    co.order_bill_id                              AS 核销订单号,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    co.coupon_code                                AS 券模板ID,
    co.shop_id                                    AS 归属门店ID,
    co.company_id                                 AS 商户ID
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.coupon_status = 'YHX'
  AND co.write_off_time >= :beginDate
  AND co.write_off_time < :endDate
  -- 可选：AND co.used_shop_code IN (:shopIdList)
  -- 可选：AND co.type_ = :couponType
  -- 可选：AND co.get_channel = :channel
ORDER BY co.write_off_time DESC, co.lmnid DESC
```

**字段口径说明**：

| 字段 | 来源 | 口径说明 |
|------|------|---------|
| 实际核销面额 | `redeemed_face_value` 或 `face_value` | ⚠️ 现有表若无 `redeemed_face_value`，则 GDP/RDP 类券取 `face_value` 仅为预估值 |
| 消费单金额 | `bill_amount` | 核销时的订单金额；⚠️ 部分券种发放时无 `bill_amount`（比例类） |
| 折扣率 | 计算字段 | `核销面额 / 消费单金额 * 100%` |
| 核销门店 | `used_shop` / `used_shop_code` | 核销发生时的门店 |

---

## 5. 汇总层报表

### 5.1 R03：券日均余额表（业务口径）

**报表作用**：按日统计券的期初、进出、期末数量和面额，用于业务余额对账和客服查询。

**适用场景**：日常运营监控、券余额核对。

**时间口径**：R03 是“截至统计日”的时点余额试算，`WHERE co.get_date <= :statDate` 是有意只设上界，用于纳入统计日前所有已发放且仍可能影响余额的券；不是普通期间报表。由于 `crm_coupon_order.coupon_status` 是当前快照状态，用它重算历史统计日会受后续核销、作废、过期、退款影响，正式月结应落 `crm_coupon_balance_day` 快照。

**核心勾稽公式（含退款冲回）**：

```
期初未核销数量 + 本期新增数量 - 本期核销数量 - 本期作废数量 - 本期过期数量 + 本期退款冲回数量 = 期末未核销数量
期初未核销面值 + 本期新增面值 - 本期核销面值 - 本期作废面值 - 本期过期面值 + 本期退款冲回面值 = 期末未核销面值
```

> ⚠️ **重要**：退款冲回场景在阶段一无独立字段支撑时，退款后券若被恢复（重新变为 `coupon_status = 'WHX'`），本次退款冲回数量计入"本期新增"；若退款后券彻底作废，则计入"本期作废"。具体如何处理取决于业务系统对退款券的恢复逻辑。阶段二新增 `crm_coupon_finance_event` 事件流水表后，退款冲回应作为独立事件类型记录。

⚠️ 注意：`coupon_status = 'YGQ'`（已过期）状态由定时任务扫出，存在最多一天的延迟。若月结时仍存在 `deadline < 期末日期 AND coupon_status = 'WHX'` 的券，应单独列为"潜在过期积压"并先完成状态修正；不要把期前积压混入本期过期发生额。

**SQL 示例**（按门店+券类型日汇总，修正版）：

```sql
SELECT
    co.shop_id                                    AS 门店ID,
    co.type_                                      AS 券类型,
    :statDate                                     AS 统计日期,

    -- 期初（截止统计日之前所有有效未核销券）
    -- 条件：券在统计日之前发放 且 未核销 且 有效期在统计日之后
    COUNT(CASE WHEN co.coupon_status = 'WHX'
               AND co.get_date < :statDate
               AND co.deadline >= :statDate THEN 1 END)
                                                      AS 期初未核销数量,
    SUM(CASE WHEN co.coupon_status = 'WHX'
             AND co.get_date < :statDate
             AND co.deadline >= :statDate THEN co.face_value ELSE 0 END)
                                                      AS 期初未核销面值,

    -- 本期新增（统计当日发放的券）
    COUNT(CASE WHEN co.coupon_status = 'WHX'
               AND co.get_date = :statDate
               AND co.deadline > :statDate THEN 1 END)
                                                      AS 本期新增数量,
    SUM(CASE WHEN co.coupon_status = 'WHX'
             AND co.get_date = :statDate
             AND co.deadline > :statDate THEN co.face_value ELSE 0 END)
                                                      AS 本期新增面值,

    -- 本期核销（统计当日核销的券）
    COUNT(CASE WHEN co.coupon_status = 'YHX'
               AND DATE(co.write_off_time) = :statDate THEN 1 END)
                                                      AS 本期核销数量,
    SUM(CASE WHEN co.coupon_status = 'YHX'
             AND DATE(co.write_off_time) = :statDate
             THEN IFNULL(co.redeemed_face_value, co.face_value) ELSE 0 END)
                                                      AS 本期核销面值,

    -- 本期作废（统计当日作废的券）
    COUNT(CASE WHEN co.coupon_status = 'YZF'
               AND DATE(co.abandon_time) = :statDate THEN 1 END)
                                                      AS 本期作废数量,
    SUM(CASE WHEN co.coupon_status = 'YZF'
             AND DATE(co.abandon_time) = :statDate THEN co.face_value ELSE 0 END)
                                                      AS 本期作废面值,

    -- 本期过期（deadline 在统计日当日届满的券，排除已核销的）
    -- 同时统计：1) 已标记YGQ的券（定时任务已处理）；2) 仍为WHX但deadline当日已到的券（定时任务延迟补偿）
    COUNT(CASE WHEN (co.coupon_status = 'YGQ'
                     AND co.deadline >= :statDate
                     AND co.deadline < DATE_ADD(:statDate, INTERVAL 1 DAY))
                OR (co.coupon_status = 'WHX'
                    AND co.deadline >= :statDate
                    AND co.deadline < DATE_ADD(:statDate, INTERVAL 1 DAY)) THEN 1 END)
                                                       AS 本期过期数量,
    SUM(CASE WHEN (co.coupon_status = 'YGQ'
                    AND co.deadline >= :statDate
                    AND co.deadline < DATE_ADD(:statDate, INTERVAL 1 DAY))
              OR (co.coupon_status = 'WHX'
                  AND co.deadline >= :statDate
                  AND co.deadline < DATE_ADD(:statDate, INTERVAL 1 DAY)) THEN co.face_value ELSE 0 END)
                                                       AS 本期过期面值,

    -- 本期退款冲回（阶段一无独立事件时间，不能从 crm_coupon_order 精确统计）
    -- 阶段二启用 crm_coupon_finance_event 后按 event_type = 5 AND event_time 落入统计日统计。

    -- 期末（截止统计日所有有效未核销券）
    -- 条件：券在统计日及之前发放 且 未核销 且 有效期在统计日之后
    COUNT(CASE WHEN co.coupon_status = 'WHX'
               AND co.get_date <= :statDate
               AND co.deadline > :statDate THEN 1 END)
                                                      AS 期末未核销数量,
    SUM(CASE WHEN co.coupon_status = 'WHX'
             AND co.get_date <= :statDate
             AND co.deadline > :statDate THEN co.face_value ELSE 0 END)
                                                      AS 期末未核销面值

FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.shop_id = :shopId
  AND co.get_date <= :statDate  -- 时点余额口径：纳入截至统计日已发放的全部相关券
GROUP BY co.shop_id, co.type_
```

> 📌 **R03 SQL 修正说明**（V2）：
> - **期末未核销**：原版仅按 `get_date <= :statDate AND coupon_status = 'WHX'` 过滤，错误地将"期前已核销后又退款的券"排除在外。修正版增加 `deadline > :statDate` 条件，确保只统计在统计日仍有效且未使用的券。
> - **本期过期**：只统计 `deadline` 落在统计日当天的券；若要统计“统计日前累计已过期仍未处理”的潜在异常，应另列“潜在过期积压”指标，不能混入本期发生额。
> - **退款冲回**：以注释形式预留，待阶段二支持后启用。

**合规边界**：

- ⚠️ 无 `report_batch_no`，同一期间可被多次重跑，无法区分版本
- ⚠️ 无 `freeze_time`，月结后历史数据仍可被修改
- ⚠️ 无本金/税额分拆，无法入总账合同负债科目
- ⚠️ `YGQ` 状态由定时任务扫出，有延迟，过期统计存在时间差

---

### 5.2 R04：券过期统计表

**报表作用**：统计在指定时间范围内过期的券，用于过期权益管理和财务未使用权利评估。

**适用场景**：过期预警、未使用权益分析。

**时间口径**：本表按 `deadline` 统计“到期日批次”，用于观察某一到期区间内的券。`deadline` 是有效期属性，不是独立事件流水；若要做财务月结入账，应以 R08 月结试算或阶段二 `crm_coupon_finance_event.event_type = 3` 的过期事件为准。

**SQL 示例**：

```sql
SELECT
    co.shop_id                                    AS 门店ID,
    co.type_                                      AS 券类型,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型名称,
    co.coupon                                     AS 券名称,
    co.coupon_code                                AS 券模板ID,
    co.get_channel                                AS 发放渠道代码,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    COUNT(*)                                      AS 过期券数量,
    SUM(co.face_value)                            AS 过期面值总额,
    MIN(co.deadline)                              AS 最早过期日,
    MAX(co.deadline)                              AS 最晚过期日
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.coupon_status IN ('WHX', 'YGQ')  -- 未核销且到期，兼容定时任务已标记和未标记两种状态
  AND co.deadline >= :beginDate
  AND co.deadline < :endDate
  -- 可选：AND co.shop_id IN (:shopIdList)
GROUP BY co.shop_id, co.type_, co.coupon, co.coupon_code, co.get_channel
ORDER BY co.shop_id, COUNT(*) DESC
```

**财务说明**：过期券是否转收入，取决于财务口径和业务规则。按 IFRS 15 / 收入准则，未使用权利通常在行权可能性极低时才确认收入。

---

### 5.3 R05：券发放渠道汇总表

**报表作用**：按门店、券类型、发放渠道维度统计发放数量、面值、核销率，用于渠道效果分析和财务预算控制。

**适用场景**：渠道 ROI 分析、券发放成本核算。

**时间口径**：本表是发放批次（cohort）分析，`get_date >= :beginDate AND get_date < :endDate` 表示统计该期间发放的券。已核销/未核销数量取的是查询时的当前状态，核销率会随查询时间变化；若用于财务留档，必须按报表批次落快照。

**核销率公式**：`COUNT(coupon_status='YHX') / COUNT(*) * 100%`

**SQL 示例**：

```sql
SELECT
    co.shop_id                                    AS 门店ID,
    co.get_channel                                AS 发放渠道代码,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    co.type_                                      AS 券类型,
    COUNT(*)                                      AS 发放券数,
    SUM(co.face_value)                            AS 发放面值总额,
    COUNT(CASE WHEN co.coupon_status = 'YHX' THEN 1 END)
                                                      AS 已核销数量,
    SUM(CASE WHEN co.coupon_status = 'YHX'
             THEN IFNULL(co.redeemed_face_value, co.face_value) ELSE 0 END)
                                                      AS 已核销面值,
    COUNT(CASE WHEN co.coupon_status = 'WHX' THEN 1 END)
                                                      AS 未核销数量,
    SUM(CASE WHEN co.coupon_status = 'WHX'
             THEN co.face_value ELSE 0 END)
                                                      AS 未核销面值,
    -- 核销率
    ROUND(COUNT(CASE WHEN co.coupon_status = 'YHX' THEN 1 END) * 100.0
        / NULLIF(COUNT(*), 0), 2)                  AS 核销率_百分比
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.get_date >= :beginDate
  AND co.get_date < :endDate
  -- 可选：AND co.shop_id IN (:shopIdList)
GROUP BY co.shop_id, co.get_channel, co.type_
ORDER BY co.shop_id, COUNT(*) DESC
```

---

### 5.4 R06：券作废统计表

**报表作用**：统计被主动作废的券，用于风控和运营合规审查。

**适用场景**：作废审计、异常行为监控。

**时间口径**：作废是事件型报表，必须按 `abandon_time` 过滤会计期间。汇总维度应使用 `DATE(abandon_time)`，避免完整时间戳进入 `GROUP BY` 后把每条记录拆成单独分组。

**SQL 示例**：

```sql
SELECT
    co.shop_id                                    AS 门店ID,
    co.abandon_staff                              AS 作废员工,
    co.coupon                                     AS 券名称,
    co.type_                                      AS 券类型,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型名称,
    COUNT(*)                                      AS 作废券数,
    SUM(co.face_value)                            AS 作废面值总额,
    DATE(co.abandon_time)                         AS 作废日期,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.coupon_status = 'YZF'
  AND co.abandon_time >= :beginDate
  AND co.abandon_time < :endDate
  -- 可选：AND co.shop_id IN (:shopIdList)
GROUP BY co.shop_id, co.abandon_staff, co.coupon, co.type_, co.get_channel, DATE(co.abandon_time)
ORDER BY co.shop_id, DATE(co.abandon_time) DESC
```

---

### 5.5 R09：券退款冲回明细表

**报表作用**：记录每一张券的退款冲回事件，用于追溯退款后券的恢复或作废情况，是 R03 勾稽公式中"本期退款冲回"维度的明细源头。

**适用场景**：退款审计、券余额核对（退款冲回维度）。

**数据筛选**：退款操作使券状态发生变化（从 `YHX` 恢复到 `WHX`，或直接从 `WHX` 变为 `YZF`）。

> ⚠️ 阶段一无独立退款字段、无状态变更历史、无 `refund_time` 时，`crm_coupon_order` 不能独立生成合格的退款冲回期间报表。若必须临时查看，只能通过订单退款表的退款时间与 `order_bill_id` 关联辅助推断，并在报表中标注“推断口径”。阶段二新增事件流水后以 `crm_coupon_finance_event.event_type = 5` 和 `event_time` 为准。

**SQL 示例**（阶段一辅助推断版，需要订单退款表提供时间边界）：

> `order_refund` 为示意表名，实施时应替换为系统真实订单退款表或退款流水视图；若没有可关联的退款时间来源，阶段一不应生成 R09 期间报表。

```sql
SELECT
    co.lmnid                                      AS 券号,
    co.coupon                                     AS 券名称,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型,
    CASE co.coupon_mode
        WHEN 'CP' THEN '券'
        WHEN 'RE' THEN '红包'
    END                                           AS 券模式,
    co.face_value                                 AS 券面值,
    co.unionid                                    AS 会员手机号,
    co.member                                     AS 会员名称,
    co.get_date                                   AS 券发放时间,
    co.order_bill_id                              AS 原核销订单号,
    co.write_off_time                             AS 原核销时间,
    co.write_off_staff                            AS 原核销操作员,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    co.coupon_status                              AS 退款后券状态,
    CASE co.coupon_status
        WHEN 'WHX' THEN '已恢复（可继续使用）'
        WHEN 'YZF' THEN '已作废'
        ELSE '其他'
    END                                           AS 退款处理结果,
    co.abandon_time                               AS 作废时间（如已作废）,
    co.abandon_staff                              AS 作废操作员（如已作废）,
    co.shop_id                                    AS 归属门店ID,
    co.company_id                                 AS 商户ID
FROM crm_coupon_order co
JOIN order_refund rf
  ON rf.order_bill_id = co.order_bill_id
 AND rf.company_id = co.company_id
WHERE co.company_id = :companyId
  AND rf.refund_time >= :beginDate
  AND rf.refund_time < :endDate
  AND co.coupon_status IN ('WHX', 'YZF')
  -- 阶段一只能辅助推断：需结合订单退款记录确认该券确实发生过核销冲回
  -- 阶段二启用后改用 crm_coupon_finance_event.event_type = 5 AND event_time >= :beginDate AND event_time < :endDate
ORDER BY rf.refund_time DESC, co.order_bill_id DESC, co.lmnid DESC
```

**R09 与 R03 勾稽公式的关系**：

R09 的汇总数据（退款恢复数量/面值）应填入 R03 勾稽公式的"本期退款冲回"维度。在阶段一无法精确追踪时，退款恢复的券若重新变为 `WHX` 则计入 R03 的"本期新增"；退款后直接作废的计入"本期作废"。阶段二启用后以 `crm_coupon_finance_event` 中 `event_type = 5（退款冲回）` 的事件流水为准。

---

## 6. 月结层报表

### 6.1 R07：券核销对账表（月结口径）

**报表作用**：在月结周期内按门店、券类型、发放渠道维度汇总核销数据，用于月结对账和财务入账参考。

**适用场景**：月结对账、经营分析。

**数据筛选**：`coupon_status = 'YHX'` 且 `write_off_time` 在会计期间内。

**SQL 示例**：

```sql
SELECT
    co.shop_id                                    AS 归属门店ID,
    co.used_shop_code                             AS 核销门店ID,
    co.used_shop                                  AS 核销门店名称,
    co.type_                                      AS 券类型,
    CASE co.type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型名称,
    CASE co.coupon_mode
        WHEN 'CP' THEN '券'
        WHEN 'RE' THEN '红包'
    END                                           AS 券模式,
    co.get_channel                                AS 发放渠道代码,
    CASE co.get_channel
        WHEN 1  THEN '自领'
        WHEN 2  THEN '购买获取'
        WHEN 3  THEN '充值赠送'
        WHEN 4  THEN '后台发放'
        WHEN 5  THEN '积分兑换'
        WHEN 6  THEN '消费赠送'
        WHEN 7  THEN '大转盘奖励'
        WHEN 8  THEN '新人礼包'
        WHEN 9  THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END                                           AS 发放渠道,
    COUNT(*)                                      AS 核销券数,
    SUM(IFNULL(co.redeemed_face_value, co.face_value))
                                                      AS 核销面值总额,
    SUM(co.bill_amount)                           AS 消费单总额,
    -- 平均折扣率
    ROUND(SUM(IFNULL(co.redeemed_face_value, co.face_value))
        / NULLIF(SUM(co.bill_amount), 0) * 100, 2)
                                                      AS 平均折扣率_百分比,
    COUNT(DISTINCT co.order_bill_id)              AS 核销订单数,
    COUNT(DISTINCT co.unionid)                    AS 核销会员数,
    co.write_off_staff                            AS 核销操作员,
    DATE(co.write_off_time)                       AS 核销日期
FROM crm_coupon_order co
WHERE co.company_id = :companyId
  AND co.coupon_status = 'YHX'
  AND co.write_off_time >= :beginDate
  AND co.write_off_time < :endDate
  -- 可选：AND co.used_shop_code IN (:shopIdList)
GROUP BY
    co.shop_id, co.used_shop_code, co.used_shop,
    co.type_, co.coupon_mode, co.get_channel,
    co.write_off_staff, DATE(co.write_off_time)
ORDER BY co.shop_id, DATE(co.write_off_time) DESC
```

**合规边界**：

- ⚠️ 无本金/税额分拆（`liability_principal_amt` / `liability_tax_amt` 缺失）
- ⚠️ 无法对接总账凭证（`gl_voucher_no` / `gl_sync_status` 缺失）
- ⚠️ 无法生成税额分摊（`tax_rate` 缺失）
- ⚠️ `bill_amount` 可能为空（比例类券发放时未确定）

---

### 6.2 R08：月结券负债试算表（财务口径）

**报表作用**：在月末计算券负债的期初、本期新增、本期核销、本期过期、期末余额，用于月结试算和总账对接准备。

**适用场景**：财务月结、负债余额核对。

**时间口径**：R08 同时包含时点余额（期初/期末）和期间发生额（新增/核销/作废/过期/退款冲回）。基于 `crm_coupon_order` 当前快照只能做“当前状态下的试算”，不能可靠重算已关账历史；正式财务月结必须使用月结快照或阶段二事件流水冻结结果。

**核心勾稽公式**：

```
期初未核销券面值 + 本期新增券面值 - 本期核销券面值 - 本期作废券面值 - 本期过期券面值 + 本期退款冲回券面值 = 期末未核销券面值
（± 容差，容差应为零或接近零）
```

**SQL 示例**（月结汇总）：

```sql
-- 期初未核销券面值（截止期初日期之前所有有效未核销券）
SELECT '期初未核销' AS item,
       COUNT(CASE WHEN coupon_status = 'WHX'
                  AND get_date < :startDate
                  AND deadline > :startDate THEN 1 END) AS qty,
       SUM(CASE WHEN coupon_status = 'WHX'
                AND get_date < :startDate
                AND deadline > :startDate THEN face_value ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId

UNION ALL

-- 本期新增券面值（期内发放的有效未核销券）
SELECT '本期新增' AS item,
       COUNT(CASE WHEN get_date >= :startDate
                  AND get_date < :endDate
                  AND coupon_status IN ('WHX', 'YHX')
                  AND deadline > :startDate THEN 1 END) AS qty,
       SUM(CASE WHEN get_date >= :startDate
                AND get_date < :endDate
                THEN face_value ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId

UNION ALL

-- 本期核销券面值
SELECT '本期核销' AS item,
       COUNT(CASE WHEN coupon_status = 'YHX'
                  AND write_off_time >= :startDate
                  AND write_off_time < :endDate THEN 1 END) AS qty,
       SUM(CASE WHEN coupon_status = 'YHX'
                AND write_off_time >= :startDate
                AND write_off_time < :endDate
                THEN IFNULL(redeemed_face_value, face_value) ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId

UNION ALL

-- 本期过期券面值
-- 同时统计：1) 已标记YGQ且deadline在期内的；2) 仍为WHX但deadline在期内已到期的（定时任务延迟补偿）
SELECT '本期过期' AS item,
       COUNT(CASE WHEN (coupon_status = 'YGQ'
                        AND deadline >= :startDate
                        AND deadline < :endDate)
                  OR (coupon_status = 'WHX'
                      AND deadline >= :startDate
                      AND deadline < :endDate) THEN 1 END) AS qty,
       SUM(CASE WHEN (coupon_status = 'YGQ'
                      AND deadline >= :startDate
                      AND deadline < :endDate)
                OR (coupon_status = 'WHX'
                    AND deadline >= :startDate
                    AND deadline < :endDate) THEN face_value ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId

UNION ALL

-- 本期作废券面值
SELECT '本期作废' AS item,
       COUNT(CASE WHEN coupon_status = 'YZF'
                  AND abandon_time >= :startDate
                  AND abandon_time < :endDate THEN 1 END) AS qty,
       SUM(CASE WHEN coupon_status = 'YZF'
                AND abandon_time >= :startDate
                AND abandon_time < :endDate THEN face_value ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId

UNION ALL

-- 本期退款冲回（预留，待阶段二支持）
SELECT '本期退款冲回' AS item, 0 AS qty, 0 AS amount
FROM crm_coupon_order
WHERE 1=0  -- 阶段二启用

UNION ALL

-- 期末未核销券面值（截止期末日期所有有效未核销券）
SELECT '期末未核销' AS item,
       COUNT(CASE WHEN coupon_status = 'WHX'
                  AND get_date <= :endDate
                  AND deadline > :endDate THEN 1 END) AS qty,
       SUM(CASE WHEN coupon_status = 'WHX'
                AND get_date <= :endDate
                AND deadline > :endDate THEN face_value ELSE 0 END) AS amount
FROM crm_coupon_order
WHERE company_id = :companyId
```

**按券类型分拆的月结试算（修正版）**：

```sql
SELECT
    type_                                         AS 券类型,
    CASE type_
        WHEN 'XJQ'     THEN '现金券'
        WHEN 'BLJ'     THEN '比例券'
        WHEN 'SWQ'     THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END                                           AS 券类型名称,
    SUM(CASE WHEN coupon_status = 'WHX'
             AND get_date < :startDate
             AND deadline > :startDate THEN face_value ELSE 0 END)
                                                      AS 期初未核销面值,
    SUM(CASE WHEN get_date >= :startDate
             AND get_date < :endDate
             THEN face_value ELSE 0 END)
                                                      AS 本期新增面值,
    SUM(CASE WHEN coupon_status = 'YHX'
             AND write_off_time >= :startDate
             AND write_off_time < :endDate
             THEN IFNULL(redeemed_face_value, face_value) ELSE 0 END)
                                                      AS 本期核销面值,
    SUM(CASE WHEN (coupon_status = 'YGQ'
                   AND deadline >= :startDate
                   AND deadline < :endDate)
             OR (coupon_status = 'WHX'
                 AND deadline >= :startDate
                 AND deadline < :endDate) THEN face_value ELSE 0 END)
                                                      AS 本期过期面值,
    SUM(CASE WHEN coupon_status = 'YZF'
             AND abandon_time >= :startDate
             AND abandon_time < :endDate THEN face_value ELSE 0 END)
                                                      AS 本期作废面值,
    0                                                 AS 本期退款冲回面值,
    SUM(CASE WHEN coupon_status = 'WHX'
             AND get_date <= :endDate
             AND deadline > :endDate THEN face_value ELSE 0 END)
                                                      AS 期末未核销面值,
    -- 勾稽验证（加入退款冲回维度）
    SUM(CASE WHEN coupon_status = 'WHX'
             AND get_date < :startDate
             AND deadline > :startDate THEN face_value ELSE 0 END)
    + SUM(CASE WHEN get_date >= :startDate
             AND get_date < :endDate
             THEN face_value ELSE 0 END)
    - SUM(CASE WHEN coupon_status = 'YHX'
               AND write_off_time >= :startDate
               AND write_off_time < :endDate
               THEN IFNULL(redeemed_face_value, face_value) ELSE 0 END)
    - SUM(CASE WHEN (coupon_status = 'YGQ'
                     AND deadline >= :startDate
                     AND deadline < :endDate)
               OR (coupon_status = 'WHX'
                   AND deadline >= :startDate
                   AND deadline < :endDate) THEN face_value ELSE 0 END)
    - SUM(CASE WHEN coupon_status = 'YZF'
               AND abandon_time >= :startDate
               AND abandon_time < :endDate THEN face_value ELSE 0 END)
    + 0
    - SUM(CASE WHEN coupon_status = 'WHX'
             AND get_date <= :endDate
             AND deadline > :endDate THEN face_value ELSE 0 END)
                                                      AS 勾稽差异
FROM crm_coupon_order
WHERE company_id = :companyId
GROUP BY type_
```

> 📌 **R08 SQL 修正说明**（V2）：
> - **期初未核销**：增加 `deadline > :startDate` 条件，排除期前已过期的券
> - **期末未核销**：增加 `deadline > :endDate` 条件，排除期末已过期的券
> - **本期过期**：只统计 `deadline` 落在本期内的 `YGQ`/`WHX` 券，覆盖定时任务延迟场景；期前已过期未处理券应作为月结前数据异常清理，不混入本期过期发生额
> - **本期作废**：纳入勾稽公式，按 `abandon_time` 过滤本期作废事件
> - **退款冲回**：以独立行预留，待阶段二事件流水启用；阶段一无独立退款时间时不能精确填入该项

**合规边界**：

- ⚠️ 无冻结字段（`freeze_time` 缺失），月结后历史数据仍可被修改
- ⚠️ 无报表批次号（`report_batch_no` 缺失），无法区分同一期间多次重跑
- ⚠️ 无本金/税额分拆，无法入总账合同负债科目
- ⚠️ 无总账凭证号（`gl_voucher_no` / `gl_sync_status` 缺失），无法关联财务凭证
- ⚠️ `YGQ` 状态由定时任务扫出，有延迟
- ⚠️ `crm_coupon_order.coupon_status` 是当前状态快照，基于该表重算历史月结只能作为试算，不能替代冻结后的月结结果

---

## 7. 月结流程

### 7.1 月结前置条件

月结前需确认以下数据状态已完成：

1. 当月所有核销订单已回写 `write_off_time`
2. 当月所有作废已回写 `abandon_time`
3. 过期扫描任务已完成，`deadline < 月末 AND coupon_status='WHX'` 的券状态已更新为 `YGQ`（或保持 `WHX` 但单独统计）
4. 随机/比例类券核销时已回写 `redeemed_face_value`

### 7.2 月结操作步骤

```
步骤 1：数据核对
  → 执行 R08 月结试算 SQL
  → 验证勾稽公式：期初 + 新增 - 核销 - 作废 - 过期 + 退款冲回 = 期末（差异应为 0 或 ±容差）

步骤 2：生成月结快照
  → 按门店/券类型/发放渠道生成 R03 日均余额汇总
  → 按月汇总 R07 券核销对账数据
  → 如有 R04 过期统计，执行过期券统计

步骤 3：报表批次登记
  → 记录本次月结的批次号（⚠️ 现有表无此字段，建议在应用层记录）
  → 登记月结时间和操作人

步骤 4：冻结确认
  → 确认月结期间数据已锁定（⚠️ 现有表无 freeze_time，建议月结后对 crm_coupon_order 加只读权限或备份快照表）

步骤 5：生成财务凭证数据（待对接财务系统）
  → 提供月结期内核销面值总额（按券类型/发放渠道分拆）
  → ⚠️ 现有表无本金/税额分拆，需人工按税率估算或等待后续改造

步骤 6：月结报告归档
  → 将 R03/R07/R08 结果归档为 PDF/Excel
  → 与总账对账
```

### 7.3 历史期间数据修改规则

**原则**：历史流水只追加，不应直接改写。调整通过冲销或调整事件处理。

由于现有表无事件流水表（`crm_coupon_event`），当前实现在业务层面应遵守：

- 月结后：`coupon_status`、`face_value`、`write_off_time` 等字段**不应直接 UPDATE**
- 如需调整：应通过**新增一条反向记录**（退款、作废冲销）来处理，而不是直接改历史数据

---

## 8. 合规边界总结

### 8.1 能做到的

| 能力 | 报表/功能 | 合规等级 |
|------|---------|---------|
| 券发行/核销/作废/过期明细追溯 | R01, R02, R06 | 业务运营级 |
| 券日均余额（面值口径） | R03 | 业务运营级 |
| 券发放渠道分析 | R05 | 业务分析级 |
| 券种核销率分析 | R05 | 业务分析级 |
| 券过期预警 | R04 | 风控预警级 |
| 月结面值勾稽 | R08 | 财务近似级 |

### 8.2 做不到的（需改造）

| 缺失能力 | 影响报表 | 改造建议 |
|---------|---------|---------|
| 负债本金/税额分拆 | R07, R08 | 需新增 `liability_principal_amt` + `liability_tax_amt` 字段 |
| 核销时税额分摊 | R07, R08 | 需新增 `crm_coupon_redemption_alloc` 表 |
| 订单行级分摊 | R07 | 需新增订单行关联字段 |
| 数据哈希校验 | R01~R08 | 需新增 `source_hash` 字段 |
| 报表批次号 | R03, R07, R08 | 需新增 `report_batch_no` 字段 |
| 冻结时间戳 | R03, R07, R08 | 需新增 `freeze_time` 字段 |
| 总账凭证号 | R07, R08 | 需新增 `gl_voucher_no` + `gl_sync_status` 字段 |
| 随机/比例类实际核销面额 | R02, R03, R07, R08 | 需在核销时回写 `redeemed_face_value` |
| 积分转券对账 | - | 需新增 `crm_points_coupon_recon` 表 |
| 券事件流水表 | - | 需新增 `crm_coupon_finance_event` 表 |

---

## 9. 改造路线图

### 阶段一：最小月结合规（推荐优先实施）

**目标**：补齐月结基本合规能力，解决随机/比例类券口径问题。

**新增字段**：

```sql
-- 新增字段 1：实际核销面额（随机/比例类券必须）
ALTER TABLE crm_coupon_order
  ADD COLUMN redeemed_face_value DECIMAL(19,4)
  COMMENT '实际核销面额，随机/比例类券在核销时回写';

-- 新增字段 2：报表批次号
ALTER TABLE crm_coupon_order
  ADD COLUMN report_batch_no VARCHAR(64)
  COMMENT '月结批次号，同一批次月结的数据共享同一批次号';

-- 新增字段 3：冻结时间戳
ALTER TABLE crm_coupon_order
  ADD COLUMN freeze_time DATETIME
  COMMENT '冻结时间戳，月结后写入，表示该行数据已冻结';
```

**实施收益**：R02/R03/R07/R08 的核销面额口径统一，`redeemed_face_value` 有值时优先取，无值时回退到 `face_value`，向前兼容。

### 阶段二：财务事件流水

**新增表**：`crm_coupon_finance_event`（覆盖发放/核销/过期/作废/退款的全量事件）

**实施收益**：历史数据只追加不修改，调整通过冲销事件处理，满足财务可追溯要求。

### 阶段三：核销分摊

**新增表**：`crm_coupon_redemption_alloc`（核销分摊到订单行/税率）

**实施收益**：税额精确分摊，可对接总账凭证。

### 阶段四：积分打通

**新增表**：`crm_points_coupon_recon`（积分转券对账）

**实施收益**：积分负债和券负债之间不断链。

---

## 10. 相关文档

- [会员券报表理论与字段说明](./会员券报表-理论与字段说明.md)
- [现有 crm_coupon_order 能实现哪些券报表-财务合规差距分析](./现有crm_coupon_order能实现哪些券报表-财务合规差距分析.md)
- [会员报表取数与字段说明](./会员报表取数与字段说明.md)

---

**文档版本**: 1.0
**创建日期**: 2026-05-14
**最后更新**: 2026-05-14
**作者**: Claude
