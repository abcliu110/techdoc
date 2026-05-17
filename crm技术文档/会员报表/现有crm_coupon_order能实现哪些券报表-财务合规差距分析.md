# 现有 crm_coupon_order 能实现哪些券报表 —— 财务合规差距分析

**日期**: 2026-05-13

## 1. 文档背景

本文档在《会员券报表理论与字段说明》定义的 8 表财务模型基础上，以**现有实际数据库中唯一存在的 `crm_coupon_order` 表**为起点，分析：

1. 该表现有字段能支撑哪些报表类型。
2. 财务合规口径下，哪些报表**可以做**、哪些**做不了**、哪些**做了但有风险**。
3. 缩小与 8 表财务模型差距所需的增量改造。

---

## 2. `crm_coupon_order` 现有字段盘点

### 2.1 字段完整清单与分类

| 字段 | 数据库列名 | 来源 | 可用于报表 |
|------|-----------|------|-----------|
| 券实例ID | `lmnid` | 雪花算法，全局唯一 | ✅ 券号、追溯 |
| 商户ID | `company_id` | 多租户隔离 | ✅ |
| 门店ID | `shop_id` | 归属口径 | ✅ |
| 券名称 | `coupon` | 快照 | ✅ |
| 券模板ID | `coupon_code` | 关联 crm_coupon.lmnid | ✅ 券种维度 |
| 券状态 | `coupon_status` | 1=未核销 / 2=已核销 / 3=已过期 / 4=已作废 / 5=未生效（Integer） | ✅ 状态筛选 |
| 券状态（文本标注） | — | 历史文档中标注 WHX/YHX/YGQ/YZF/WSX 等价于上行列举值 | ⚠️ 口径说明 |
| 券类型 | `type_` | XJQ/BLJ/SWQ/DISCOUNT | ✅ 券种分类 |
| 券面值 | `face_value` | 快照（见 2.2 说明） | ✅ 面额统计 |
| 消费单金额 | `bill_amount` | 核销时的订单金额 | ⚠️ 近似 |
| 领取时间 | `get_date` | 发放时间戳 | ✅ 发行时间 |
| 有效期截止 | `deadline` | 有效期快照 | ✅ 过期判断 |
| 生效时间 | `valid_date` | 生效时间快照 | ✅ |
| 核销时间 | `write_off_time` | 核销时间戳 | ✅ 核销时间 |
| 使用时间 | `used_time` | 核销时间戳 | ✅ 同 write_off_time |
| 核销门店 | `used_shop` | 核销时的门店名称 | ✅ 核销口径 |
| 核销门店编号 | `used_shop_code` | 核销时的门店ID | ✅ 核销门店维度 |
| 核销员 | `write_off_staff` | 操作人 | ✅ 人员维度（建议关联 hr_employee 表；若关联失败须在备注字段保留原始操作人文本以确保追溯链不断裂） |
| 外部订单号 | `order_bill_id` | 核销订单号 | ✅ 关联订单 |
| 领取渠道 | `get_channel` | 11种渠道枚举 | ✅ 来源分类 |
| 会员手机号 | `unionid` | 会员标识 | ✅ 会员维度 |
| 会员名称 | `member` | 快照 | ✅ 会员维度 |
| 微信昵称 | `nickname` | 快照 | ✅ |
| 作废时间 | `abandon_time` | 作废时间戳 | ✅ |
| 作废员工 | `abandon_staff` | 操作人 | ✅ |
| 券包名称 | `pkg_coupon` | 快照 | ✅ 券包维度 |
| 券包ID | `pkg_coupon_code` | 快照 | ✅ 券包维度 |
| 券模式 | `coupon_mode` | CP=券/RE=红包 | ✅ 财务分类 |
| 面值方式 | `face_value_method` | GDF/RDF/GDP/RDP | ⚠️ 仅知道方式 |
| 面值下限 | `face_value_min` | 随机/比例时的下限 | ⚠️ 近似 |
| 面值上限 | `face_value_max` | 随机/比例时的上限 | ⚠️ 近似 |
| 比例下限 | `proportion_min` | 范围比例时下限 | ⚠️ 近似 |
| 比例上限 | `proportion_max` | 范围比例时上限 | ⚠️ 近似 |
| 限用商品 | `dish_code` / `dish_name` | 快照 | ⚠️ 品类维度（不精确） |

### 2.2 `face_value` 字段的关键说明（重要！）

`face_value` 的语义在不同面值方式下含义不同：

| 面值方式 | `face_value` 的实际含义 | 财务口径的问题 |
|---------|----------------------|--------------|
| **GDF**（固定面值） | 固定面值，含义清晰 | ✅ 没问题 |
| **RDF**（随机面值） | 发放时的随机面值 | ⚠️ 需确认发放时是否写入了实际随机值 |
| **GDP**（固定比例） | 固定比例（需乘以 `bill_amount`） | ⚠️ `bill_amount` 为核销时订单金额，但 `face_value` 发放时无订单金额，怎么算的比例？存在口径风险 |
| **RDP**（范围比例） | 范围比例下限 | ⚠️ 发放时未确定，实际核销金额不确定 |

**建议**：对于 GDP/RDP 类券，必须在核销时回写一个 `redeemed_face_value`（实际核销面额），否则无法从 `crm_coupon_order` 追溯核销时实际抵扣金额。

---

## 3. 财务合规口径分析

### 3.1 财务合规三要素

财务合规的券报表必须满足：

| 要素 | 说明 | 当前表是否满足 |
|------|------|--------------|
| **可追溯** | 每笔数据能追溯到原始单据、时间、人、操作 | ⚠️ 部分满足（缺批次号、哈希校验、event_type 枚举值说明） |
| **可对账** | 期初 + 进出 - 期末 = 0 | ⚠️ 可以用 `face_value` 总和验算，但无本金/税额分拆；勾稽公式需包含退款冲回项；**财务正式月结须按本金/税额分拆验算（见会员券报表-理论与字段说明.md §2.5.3）** |
| **可冻结** | 历史期间数据月结后不可改写 | ❌ 现有表无 freeze_time / report_batch_no 字段 |

### 3.2 8 表模型 vs 现有表差距矩阵

| 财务模型字段/能力 | 8表模型 | 现有crm_coupon_order | 缺失类型 | 差距级别 |
|-----------------|---------|---------------------|---------|
| 券号追溯 | `coupon_code` ✅ | ✅ `lmnid` | 无差距 |
| 券种分类（XJQ/BLJ/SWQ/DISCOUNT） | ✅ type | ✅ `type_` | 无差距 |
| 发放渠道（11种） | ✅ get_channel | ✅ `get_channel` | 无差距 |
| 券状态流转 | ✅ coupon_status | ✅ `coupon_status` | 无差距 |
| 发行时间 | ✅ event_time | ✅ `get_date` | 无差距 |
| 核销时间 | ✅ event_time | ✅ `write_off_time` | 无差距 |
| 核销门店 | ✅ store_id | ✅ `used_shop_code` | 无差距 |
| 核销订单号 | ✅ order_no | ✅ `order_bill_id` | 无差距 |
| 会员标识 | ✅ member_id | ✅ `unionid` | 无差距 |
| 面值金额 | ✅ face_value | ⚠️ `face_value`（面值方式口径有风险） | 计算逻辑未实现（字段存在但口径需对齐） | 中等差距 |
| 消费单金额（核销基准） | ✅ bill_amount | ⚠️ `bill_amount`（发放时无 bill_amount，部分券种无法理解） | 中等差距 |
| 负债本金 | `liability_principal_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 负债税额 | `liability_tax_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 税额税率 | `tax_rate` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 核销本金释放 | `principal_release_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 核销税额释放 | `tax_release_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 确认收入金额 | `revenue_confirm_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 确认费用金额 | `expense_confirm_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 优惠金额 | `discount_amount` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 订单行级分摊 | `order_line_no` / `sku_id` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 总账凭证号 | `gl_voucher_no` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 总账同步状态 | `gl_sync_status` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 数据哈希校验 | `source_hash` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 报表批次号 | `report_batch_no` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 冻结时间戳 | `freeze_time` | ❌ 无此字段 | 物理字段缺失 | **大差距** |
| 实际核销面额（随机/比例类） | `redeemed_face_value` | ❌ 无此字段（部分券种无法精确统计） | 物理字段缺失 | **大差距** |
| 第三方补贴券应收补贴款 | `subsidy_receivable_amt` | ❌ 无此字段 | 物理字段缺失 | **大差距** |

---

## 4. 可实现的报表类型

### 4.1 业务运营报表（✅ 可直接实现）

这些报表利用 `crm_coupon_order` 现有字段即可构建，符合财务运营规范：

> **时间口径总则**：事件型报表必须带时间边界。发放用 `get_date`，核销用 `write_off_time`，作废用 `abandon_time`；过期统计按 `deadline` 只能表示“到期日批次”；余额/负债试算是“截至某日”的时点口径，允许只有截至日上界，但基于当前 `coupon_status` 不能可靠重算历史关账结果。

#### 报表1：券发行明细表

```
SELECT
    lid AS 券号,
    coupon AS 券名称,
    CASE type_
        WHEN 'XJQ' THEN '现金券'
        WHEN 'BLJ' THEN '比例券'
        WHEN 'SWQ' THEN '实物券'
        WHEN 'DISCOUNT' THEN '折扣券'
    END AS 券类型,
    CASE get_channel
        WHEN 1 THEN '自领'
        WHEN 2 THEN '购买获取'
        WHEN 3 THEN '充值赠送'
        WHEN 4 THEN '后台发放'
        WHEN 5 THEN '积分兑换'
        WHEN 6 THEN '消费赠送'
        WHEN 7 THEN '大转盘奖励'
        WHEN 8 THEN '新人礼包'
        WHEN 9 THEN '生日赠送'
        WHEN 10 THEN '购买会员等级赠送'
        WHEN 11 THEN '商家活动赠送'
        WHEN 12 THEN '购卡送券'
    END AS 发放渠道,
    face_value AS 券面值,
    unionid AS 会员手机号,
    member AS 会员名称,
    get_date AS 领取时间,
    valid_date AS 生效时间,
    deadline AS 有效期截止,
    CASE coupon_status
        WHEN 1 THEN '未核销'
        WHEN 2 THEN '已核销'
        WHEN 3 THEN '已过期'
        WHEN 4 THEN '已作废'
        WHEN 5 THEN '未生效'
    END AS 券状态,
    write_off_time AS 核销时间,
    used_shop AS 核销门店,
    write_off_staff AS 核销员,
    order_bill_id AS 核销订单号,
    pkg_coupon AS 所属券包,
    CASE coupon_mode
        WHEN 1 THEN '券'
        WHEN 2 THEN '红包'
    END AS 券模式,
    shop_id AS 门店ID,
    company_id AS 商户ID
FROM crm_coupon_order
WHERE company_id = :companyId
  AND get_date >= :beginDate
  AND get_date < :endDate
GROUP BY get_date, shop_id, get_channel, type_
```

#### 报表2：券核销明细表

```
SELECT
    lid AS 券号,
    coupon AS 券名称,
    type_ AS 券类型,
    face_value AS 核销面值,
    bill_amount AS 消费单金额,
    get_channel AS 来源渠道,
    used_shop_code AS 核销门店ID,
    used_shop AS 核销门店,
    write_off_time AS 核销时间,
    write_off_staff AS 核销员,
    order_bill_id AS 核销订单号,
    member AS 会员名称,
    unionid AS 会员手机号,
    company_id AS 商户ID,
    shop_id AS 归属门店ID
FROM crm_coupon_order
WHERE coupon_status = 2  -- 2=已核销，等价于 'YHX'，实际枚举以数据库为准
  AND write_off_time >= :beginDate
  AND write_off_time < :endDate
```

#### 报表3：券日均余额表（业务口径）

基于 `crm_coupon_order` 每日跑批生成：

```
统计口径：
  期初未核销券数 = COUNT(coupon_status = 1) -- 不含本次统计日，1=未核销
  本期新增 = COUNT(get_date = 统计日 AND coupon_status IN (1,5))  -- 5=未生效（发放但未到生效时间，也是新增但尚未可用）
  本期核销 = COUNT(write_off_time 在统计日内 AND coupon_status = 2)  -- 2=已核销
  本期作废 = COUNT(abandon_time 在统计日内 AND coupon_status = 4)  -- 4=已作废
  本期过期 = COUNT(deadline < 统计日 AND coupon_status = 1 AND 无作废时间)  -- 未核销且已过有效期
  本期退款冲回 = COUNT(refund_time 在统计日内 AND coupon_status = 6)  -- 6=已退款，券恢复可用
  期末未核销 = COUNT(coupon_status = 1) -- 含本次统计日

  -- 对账公式（必须包含退款冲回，否则期末余额失准）：
  -- 期初 + 本期新增 - 本期核销 - 本期作废 - 本期过期 + 本期退款冲回 = 期末
```

> **注意**：这里的"过期"没有专门事件字段，只能通过 `deadline < 当前时间 AND coupon_status = 1`（未核销）来近似计算，存在时间差。

#### 报表4：券过期统计表

```
SELECT
    shop_id AS 门店ID,
    type_ AS 券类型,
    get_channel AS 发放渠道,
    COUNT(*) AS 过期券数量,
    SUM(face_value) AS 过期面值总额,
    MIN(deadline) AS 最早过期日,
    MAX(deadline) AS 最晚过期日,
    coupon AS 券名称
FROM crm_coupon_order
WHERE company_id = :companyId
  AND coupon_status IN (1, 3)  -- 1=未核销，3=已过期；兼容定时任务已标记/未标记
  AND deadline >= :beginDate
  AND deadline < :endDate
GROUP BY shop_id, type_, get_channel, coupon
```

#### 报表5：券发放渠道汇总表

```
SELECT
    shop_id AS 门店ID,
    get_channel AS 发放渠道,
    type_ AS 券类型,
    COUNT(*) AS 发放券数,
    SUM(face_value) AS 发放面值总额,
    COUNT(CASE WHEN coupon_status = 2 THEN 1 END) AS 已核销数,      -- 2=已核销
    SUM(CASE WHEN coupon_status = 2 THEN face_value ELSE 0 END) AS 已核销面值,
    COUNT(CASE WHEN coupon_status = 1 THEN 1 END) AS 未核销数,      -- 1=未核销
    SUM(CASE WHEN coupon_status = 1 THEN face_value ELSE 0 END) AS 未核销面值
FROM crm_coupon_order
WHERE company_id = :companyId
  AND get_date >= :beginDate
  AND get_date < :endDate
GROUP BY shop_id, get_channel, type_
```

#### 报表6：券作废统计表

```
SELECT
    shop_id AS 门店ID,
    abandon_staff AS 作废员工,
    COUNT(*) AS 作废券数,
    SUM(face_value) AS 作废面值总额,
    DATE(abandon_time) AS 作废日期
FROM crm_coupon_order
WHERE company_id = :companyId
  AND coupon_status = 4  -- 4=已作废，等价于 'YZF'
  AND abandon_time >= :beginDate
  AND abandon_time < :endDate
GROUP BY shop_id, abandon_staff, DATE(abandon_time)
```

### 4.2 财务合规报表（⚠️ 部分可做，存在差距）

#### 报表7：券核销对账表（月结口径）

基于现有字段可做，但**无法区分本金/税额**：

```
SELECT
    shop_id AS 门店ID,
    used_shop_code AS 核销门店,
    type_ AS 券类型,
    get_channel AS 发放渠道,
    coupon_mode AS 券模式,
    COUNT(*) AS 核销券数,
    SUM(face_value) AS 核销面值总额,
    SUM(bill_amount) AS 消费单总额,
    ROUND(SUM(face_value) / NULLIF(SUM(bill_amount), 0) * 100, 2) AS 折扣率,
    COUNT(DISTINCT order_bill_id) AS 核销订单数,
    COUNT(DISTINCT unionid) AS 核销会员数,
    write_off_staff AS 核销员,
    DATE(write_off_time) AS 核销日期
FROM crm_coupon_order
WHERE coupon_status = 2  -- 2=已核销，等价于 'YHX'
  AND write_off_time >= :beginDate
  AND write_off_time < :endDate
GROUP BY shop_id, used_shop_code, type_, get_channel, coupon_mode, write_off_staff, DATE(write_off_time)
```

> **统计口径说明**：本表以核销日期（write_off_time的日期部分）为统计口径，WHERE条件使用时间戳范围确保精确（`>= :beginDate AND < :endDate`），GROUP BY使用DATE()函数统一截断为日粒度。注意：核销时间在23:00-23:59之间的数据，日期截断后归属于当日，与其他以时间戳直接分组的报表（如报表3）保持口径一致。

**财务合规差距**：
- ❌ 无法区分本金核销和税额核销
- ❌ 无法对接总账凭证
- ❌ 无法生成税额分摊
- ⚠️ `bill_amount` 可能为空（部分券种发放时未确定）

#### 报表8：月结券负债试算表（财务口径）

基于现有字段只能估算：

> **口径限制**：下列 SQL 是基于当前快照的月结试算。由于 `coupon_status` 不是历史状态流水，不能用它可靠重算已经关账的历史月份；正式月结必须在关账时落快照或事件流水。

```
期初未核销券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE coupon_status = 1  -- 1=未核销
      AND get_date < @期初日期
      AND deadline > @期初日期

本期新增券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE get_date >= @期初日期
      AND get_date < @期末日期

本期核销券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE write_off_time >= @期初日期
      AND write_off_time < @期末日期
      AND coupon_status = 2  -- 2=已核销

本期过期券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE deadline >= @期初日期
      AND deadline < @期末日期
      AND coupon_status IN (1, 3)  -- 1=未核销，3=已过期

本期作废券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE abandon_time >= @期初日期
      AND abandon_time < @期末日期
      AND coupon_status = 4  -- 4=已作废

本期退款冲回券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE refund_time >= @期初日期
      AND refund_time < @期末日期
      AND coupon_status = 6  -- 6=已退款（核销后退款冲回）

期末未核销券面值 =
    SELECT SUM(face_value) FROM crm_coupon_order
    WHERE coupon_status = 1  -- 1=未核销
      AND get_date <= @期末日期
      AND deadline > @期末日期

-- 验证公式（必须含退款冲回，否则公式不闭合）：
-- 期初未核销券面值 + 本期新增券面值 - 本期核销券面值 - 本期过期券面值 - 本期作废券面值 + 本期退款冲回券面值 ≈ 期末未核销券面值
-- 允许存在极小误差（因退款导致 coupon_status 在期初日前变化，产生跨期重复计数）

-- 勾稽公式：
期初 + 新增 - 核销 - 作废 - 过期 + 退款冲回 = 期末  (±容差)
```

**财务合规差距**：
- ❌ 无冻结字段，月结后历史数据仍可被修改
- ❌ 无报表批次号，无法区分同一期间多次重跑
- ❌ 无本金/税额分拆，无法入总账的合同负债科目
- ⚠️ `coupon_status` 中的过期状态（YGQ）是定时任务扫出来的，有延迟

---

## 5. 报表与财务合规差距总结

### 5.1 能做到的

| 报表类型 | 具体内容 | 合规等级 |
|---------|---------|---------|
| 券发行/核销/作废/过期明细 | 明细追溯到券号、时间、人 | 业务运营级 |
| 券日均余额（业务口径） | 期初/新增/核销/期末面值 | 业务运营级 |
| 券发放渠道分析 | 各渠道券数、面值、核销率 | 业务分析级 |
| 券种核销率分析 | 各券种的核销率、折扣率 | 业务分析级 |
| 券过期预警 | 即将过期/已过期券统计 | 风控预警级 |
| 月结试算 | 负债试算（面值总额口径） | 财务近似级 |

### 5.2 做不到的（需改造）

| 缺失能力 | 影响 | 改造建议 |
|---------|------|---------|
| 负债本金/税额分拆 | 无法入总账合同负债科目 | 需新增 `liability_principal_amt` + `liability_tax_amt` 字段 |
| 核销时税额分摊 | 无法生成税额凭证 | 需新增 `crm_coupon_redemption_alloc` 表 |
| 订单行级分摊 | 无法确认每行商品的折扣影响 | 需新增订单行关联 |
| 数据哈希校验 | 无法防止数据被篡改 | 需新增 `source_hash` 字段 |
| 报表批次号/冻结 | 月结后历史数据可被改写 | 需新增 `report_batch_no` + `freeze_time` 字段 |
| 总账凭证号 | 无法关联财务凭证 | 需新增 `gl_voucher_no` + `gl_sync_status` |
| 随机/比例类券实际核销面额 | GDP/RDP 类券核销金额不精确 | 需在核销时回写 `redeemed_face_value` |
| 积分转券对账 | 无法打通积分负债和券负债 | 需新增 `crm_points_coupon_recon` 表 |

---

## 6. 最小改造方案（先上业务合规报表）

如果目标只是"在现有 `crm_coupon_order` 上先跑出合规的券报表"，最小改造方案：

### 6.1 字段改造（3个）

```sql
-- 新增字段 1：实际核销面额（随机/比例类券必须）
ALTER TABLE crm_coupon_order
  ADD COLUMN redeemed_face_value DECIMAL(19,4) COMMENT '实际核销面额，随机/比例类券在核销时回写';

-- 新增字段 2：报表批次号
ALTER TABLE crm_coupon_order
  ADD COLUMN report_batch_no VARCHAR(64) COMMENT '月结批次号，同一批次月结的数据共享同一批次号';

-- 新增字段 3：冻结时间戳
ALTER TABLE crm_coupon_order
  ADD COLUMN freeze_time DATETIME COMMENT '冻结时间戳，月结后写入，表示该行数据已冻结';
```

### 6.2 新增表（2张，最小月结合规集）

> **存储引擎说明**：所有新增表统一使用 InnoDB 引擎（不使用 Memory，因财务数据需持久化且可能包含TEXT字段）。按月分区策略确保月结批量扫描高效，超期数据归档至冷存储。

> **表关系说明（重要）**：`crm_coupon_finance_event` 是最小改造方案中的过渡表，功能上等价于 `crm_coupon_event` 的财务子集。阶段一/二期间，运营查询继续走 `crm_coupon_order`，月结对账走 `crm_coupon_finance_event`；阶段三之后两者应合并，以理论文档（会员券报表-理论与字段说明.md）的8表模型为准。

```sql
-- 表1：券日余额快照（每日跑批生成）
CREATE TABLE crm_coupon_balance_day (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  stat_date DATE NOT NULL COMMENT '统计日期',
  source_type TINYINT COMMENT '发放渠道类型快照，携带发放时的渠道枚举，用于余额快照按来源分离',
  coupon_type_id VARCHAR(32) COMMENT '券类型ID快照，用于按券类型分离聚合',
  report_batch_no VARCHAR(64) COMMENT '报表批次号',

  -- 数量维度
  opening_whx_qty INT DEFAULT 0 COMMENT '期初未核销券数',
  issue_qty INT DEFAULT 0 COMMENT '本期新增券数',
  redeem_qty INT DEFAULT 0 COMMENT '本期核销券数',
  abandon_qty INT DEFAULT 0 COMMENT '本期作废券数',
  expire_qty INT DEFAULT 0 COMMENT '本期过期券数',
  closing_whx_qty INT DEFAULT 0 COMMENT '期末未核销券数',

  -- 面值维度
  opening_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '期初未核销面值',
  issue_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '本期新增面值',
  redeem_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '本期核销面值',
  abandon_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '本期作废面值',
  expire_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '本期过期面值',
  closing_face_amt DECIMAL(19,4) DEFAULT 0 COMMENT '期末未核销面值',

  -- 来源维度
  issue_recharge_amt DECIMAL(19,4) DEFAULT 0 COMMENT '充值赠送面值',
  issue_consume_amt DECIMAL(19,4) DEFAULT 0 COMMENT '消费赠送面值',
  issue_grant_amt DECIMAL(19,4) DEFAULT 0 COMMENT '后台发放面值',
  issue_exchange_amt DECIMAL(19,4) DEFAULT 0 COMMENT '积分兑换面值',
  issue_activity_amt DECIMAL(19,4) DEFAULT 0 COMMENT '活动赠送面值',
  issue_other_amt DECIMAL(19,4) DEFAULT 0 COMMENT '其他渠道面值',

  freeze_time DATETIME COMMENT '冻结时间戳',
  source_hash VARCHAR(64) COMMENT '来源数据哈希',
  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE INDEX uk_mid_sid_date_source (mid, sid, stat_date, source_type, coupon_type_id) COMMENT '每个门店+日期+来源类型+券类型单独一行聚合'
) COMMENT='券日余额快照表，按mid+sid+stat_date+source_type+coupon_type_id五键聚合'

**聚合维度说明**：本表按 mid + sid + stat_date + source_type + coupon_type_id 五键聚合，与理论文档（会员券报表-理论与字段说明.md §5.5）的五键设计一致。若因实施复杂度需进一步简化，须同步更新理论文档的字段说明。

> **存储引擎说明（补充）**：本表按月分区，历史数据只读归档。

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  PARTITION BY RANGE (TO_DAYS(stat_date)) (
    PARTITION p202605 VALUES LESS THAN (TO_DAYS('2026-06-01')),
    PARTITION p202606 VALUES LESS THAN (TO_DAYS('2026-07-01')),
    PARTITION p202607 VALUES LESS THAN (TO_DAYS('2026-08-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
  ) COMMENT='券日余额快照表，按月分区，历史数据只读归档'

-- 表2：券财务事件表（覆盖发放、核销、过期、作废的全量事件，用于月结对账）
CREATE TABLE crm_coupon_finance_event (
  pid BIGINT PRIMARY KEY AUTO_INCREMENT,
  mid BIGINT NOT NULL COMMENT '商户ID',
  sid BIGINT NOT NULL COMMENT '门店ID',
  event_lid BIGINT NOT NULL COMMENT '事件唯一ID（可用雪花算法）',
  coupon_lid BIGINT NOT NULL COMMENT '关联券实例ID',
  coupon_code VARCHAR(64) COMMENT '券码快照',

  event_type TINYINT NOT NULL COMMENT '事件类型：1=发放 2=核销 3=过期 4=作废 5=退款冲回',
  event_time DATETIME NOT NULL COMMENT '事件时间',
  event_face_value DECIMAL(19,4) NOT NULL COMMENT '事件面值金额',

  -- 财务金额（本金/税额分离，为后续入总账准备）
  principal_amt DECIMAL(19,4) DEFAULT 0 COMMENT '本金金额',
  tax_amt DECIMAL(19,4) DEFAULT 0 COMMENT '税额金额',

  -- 关联信息
  order_bill_id VARCHAR(64) COMMENT '关联订单号（核销时）',
  used_shop_code VARCHAR(64) COMMENT '核销门店（核销时）',
  channel_type TINYINT COMMENT '发放渠道快照',
  coupon_type VARCHAR(32) COMMENT '券类型快照',

  -- 追溯
  report_batch_no VARCHAR(64) COMMENT '月结批次号',
  gl_voucher_no VARCHAR(64) COMMENT '总账凭证号',
  gl_sync_status TINYINT DEFAULT 0 COMMENT '总账同步状态：0=未同步 1=已同步',
  remark VARCHAR(512) COMMENT '备注',

  created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_mid_sid_date (mid, sid, event_time),
  INDEX idx_coupon_lid (coupon_lid),
  INDEX idx_batch (mid, report_batch_no),
  INDEX idx_gl_voucher (gl_voucher_no)
) COMMENT='券财务事件表（月结对账核心表）';
```

### 6.3 月结流程

```
每日凌晨跑批：
  1. 扫描 crm_coupon_order 生成 crm_coupon_balance_day 快照
     → 用于业务余额对账

  2. 扫描 crm_coupon_order 按事件类型生成 crm_coupon_finance_event
     → 发放事件：get_date, face_value, get_channel
     → 核销事件：write_off_time, face_value / redeemed_face_value
     → 过期事件：deadline 到期日
     → 作废事件：abandon_time
     → 退款冲回事件：refund_time

  3. 月结时：
     → 按 report_batch_no 冻结数据
     → freeze_time 写入
     → 生成 gl_voucher_no（待对接财务系统）
     → 勾稽公式验证：期初 + 发放 - 核销 - 过期 - 作废 = 期末
```

---

## 7. 完整财务合规改造路线图

```
阶段一（最小可用）：补字段 + 1张快照表 + 月结跑批
  ├── 新增 redeemed_face_value / report_batch_no / freeze_time
  ├── 新增 crm_coupon_balance_day
  └── 实现：券日余额表 + 月结勾稽 + 业务核销明细

阶段二（财务合规）：新增 crm_coupon_finance_event
  ├── 覆盖全量事件（发放/核销/过期/作废/退款）
  ├── 本金/税额字段（预填默认值，后续精细化）
  └── 实现：财务事件流水 + 月结负债试算 + 总账对接准备

阶段三（精细化合规）：新增 crm_coupon_redemption_alloc
  ├── 券核销分摊到订单行/税率
  ├── 税额精确分摊
  └── 实现：订单行级核销分摊表 + 税额分摊表

阶段四（积分打通）：新增 crm_points_coupon_recon
  ├── 积分兑换券的负债转换追踪
  └── 实现：积分转券对账表
```

---

## 8. 结论

**`crm_coupon_order` 单表的能力边界**：

✅ **能做**：券发行/核销/作废/过期明细，券日均余额，发放渠道分析，核销率统计，月结面值勾稽（近似）

⚠️ **能做但有风险**：随机/比例类券的面值统计（`face_value` 口径问题），月结冻结（无冻结字段）

❌ **做不了**：本金/税额分拆，订单行级分摊，总账凭证对接，数据哈希校验，历史冻结

**推荐路径**：先做阶段一的最小改造，补齐月结基本合规能力，再按需推进阶段二/三。

---

## 9. 相关文档

- [会员券报表理论与字段说明](./会员券报表-理论与字段说明.md)
- [优惠券系统全链路设计文档](../02-优惠券与券包/优惠券系统全链路设计文档.md)
- [消费赠券企业级架构设计](../../消费赠券企业级架构设计.md)

---

**文档版本**: 1.0
**创建日期**: 2026-05-13
**最后更新**: 2026-05-13
**作者**: Claude
