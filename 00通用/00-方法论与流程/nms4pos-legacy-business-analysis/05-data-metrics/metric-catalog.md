# 指标口径定义

## 1. 核心业务指标

### 1.1 收银指标

| 指标 ID | 名称 | 业务定义 | 公式 | 时间口径 | 数据源 | 负责人 | 证据 |
|---------|------|----------|------|----------|--------|--------|------|
| M001 | 日营收 | 当日所有已结账账单的实收金额总和 | Σ(real_amount) WHERE status=1 AND closed_time∈[当日] | 自然日 | dwd_bill | 财务 | 待验证 |
| M002 | 日账单数 | 当日结账的账单数量 | COUNT(*) WHERE status=1 AND closed_time∈[当日] | 自然日 | dwd_bill | 运营 | 待验证 |
| M003 | 客单价 | 平均每单消费金额 | M001 / M002 | 自然日 | dwd_bill | 运营 | 待验证 |
| M004 | 人均消费 | 平均每人消费金额 | M001 / 当日就餐人数 | 自然日 | dwd_bill | 运营 | 待验证 |
| M005 | 现金收款 | 当日现金支付总额 | Σ(pay_amount) WHERE type_=1 AND status=1 | 自然日 | dwd_pay | 财务 | 待验证 |

### 1.2 菜品指标

| 指标 ID | 名称 | 业务定义 | 公式 | 时间口径 | 数据源 | 负责人 | 证据 |
|---------|------|----------|------|----------|--------|--------|------|
| M010 | 菜品销量 | 某菜品的销售份数 | Σ(num) WHERE dish_id=? AND bill_id.status=1 | 自然日/时段 | dwd_food | 运营 | 待验证 |
| M011 | 菜品销售额 | 某菜品的销售金额 | Σ(amount) WHERE dish_id=? AND bill_id.status=1 | 自然日/时段 | dwd_food | 运营 | 待验证 |
| M012 | 菜品点击率 | 某菜品被点次数/总点单次数 | M010 / 总点单次数 | 自然日 | dwd_food | 产品 | 待验证 |
| M013 | 退菜率 | 退菜数量/总点单数量 | Σ(退菜数量) / Σ(num) | 自然日 | dwd_food | 运营 | 待验证 |
| M014 | 菜品利润率 | (售价-成本)/售价 | (price-cost)/price | 自然日 | pt_dish | 财务 | 待验证 |

### 1.3 会员指标

| 指标 ID | 名称 | 业务定义 | 公式 | 时间口径 | 数据源 | 负责人 | 证据 |
|---------|------|----------|------|----------|--------|--------|------|
| M020 | 会员消费占比 | 会员订单金额/总金额 | Σ(会员订单real_amount) / M001 | 自然日 | dwd_bill | 运营 | 待验证 |
| M021 | 会员充值额 | 当日会员充值总额 | Σ(recharge_amount) WHERE type=充值 | 自然日 | biz_member | 财务 | 待验证 |
| M022 | 积分使用率 | 使用积分抵扣金额/发放积分 | Σ(抵扣积分) / Σ(发放积分) | 自然日 | biz_member | 运营 | 待验证 |

### 1.4 支付指标

| 指标 ID | 名称 | 业务定义 | 公式 | 时间口径 | 数据源 | 负责人 | 证据 |
|---------|------|----------|------|----------|--------|--------|------|
| M030 | 微信收款占比 | 微信支付金额/总金额 | Σ(pay_amount) WHERE type_=2 / M001 | 自然日 | dwd_pay | 财务 | 待验证 |
| M031 | 支付宝收款占比 | 支付宝金额/总金额 | Σ(pay_amount) WHERE type_=3 / M001 | 自然日 | dwd_pay | 财务 | 待验证 |
| M032 | 优惠核销金额 | 当日优惠总金额 | Σ(discount_amount) | 自然日 | dwd_bill | 财务 | 待验证 |
| M033 | 离线收银金额 | 离线模式下收银金额 | Σ(pay_amount) WHERE offline_flag=1 | 自然日 | dwd_pay | 技术 | 待验证 |

### 1.5 同步指标

| 指标 ID | 名称 | 业务定义 | 公式 | 时间口径 | 数据源 | 负责人 | 证据 |
|---------|------|----------|------|----------|--------|--------|------|
| M040 | 同步延迟 | 最后同步时间与当前时间的差 | NOW() - last_sync_time | 实时 | sync_status | 技术 | SLICE-010 |
| M041 | 同步成功率 | 成功同步数/总同步数 | Σ(success) / Σ(total) | 自然日 | sync_queue | 技术 | SLICE-010 |
| M042 | 离线数据积压 | 待同步数据量 | COUNT(*) WHERE sync_status=0 | 实时 | sync_queue | 技术 | SLICE-008 |

## 2. 指标口径详情

### 2.1 日营收口径 (M001)

**定义**：当日（00:00:00 - 23:59:59）所有已结账账单的实收金额总和。

**SQL**：

```sql
SELECT SUM(real_amount) as daily_revenue
FROM dwd_bill
WHERE status = 1  -- 已结账
  AND closed_time >= '2024-01-01 00:00:00'
  AND closed_time < '2024-01-02 00:00:00'
```

**边界条件**：
- 仅统计 `status = 1`（已结账）的账单
- 时间范围基于 `closed_time`（结账时间），不是 `created_time`
- 使用 `real_amount`（实收金额），不是 `total_amount`（应付金额）
- 退款冲正的账单需要从当日营收中扣除

**数据延迟**：
- 实时性：准实时（结账后秒级）
- 准确性：100%

**责任方**：财务部门

**待验证**：需要确认退款冲正的计算口径

---

### 2.2 客单价口径 (M003)

**定义**：当日营收除以当日账单数。

**SQL**：

```sql
SELECT
    SUM(real_amount) / COUNT(*) as avg_order_value
FROM dwd_bill
WHERE status = 1
  AND closed_time >= '2024-01-01 00:00:00'
  AND closed_time < '2024-01-02 00:00:00'
```

**边界条件**：
- 仅统计已结账账单
- 账单数为去重后的账单数量
- 不包括挂账未结清的账单

**替代方案**（如需统计人均）：
- 如果有人数字段，可以计算人均消费
- 如果没有，需要从菜品明细推算或依赖人工录入

---

### 2.3 同步延迟口径 (M040)

**定义**：最后一条成功同步的事件时间与当前时间的差值。

**SQL**：

```sql
SELECT
    (UNIX_TIMESTAMP(NOW()) - MAX(execute_time)) as sync_delay_seconds
FROM canal_events
WHERE synced = 1
```

**告警阈值**：
- 正常：< 5 分钟
- 警告：5-10 分钟
- 告警：> 10 分钟

---

## 3. 指标口径对比

### 3.1 营收口径对比

| 口径定义 | 计算方式 | 差异 |
|----------|----------|------|
| 应付营收 | Σ(total_amount) | 未扣除优惠 |
| 实收营收 | Σ(real_amount) | 已扣除优惠 |
| 应收营收 | Σ(should_amount) | 已扣除优惠和抹零 |
| 到账营收 | Σ(实付金额) | 微信/支付宝实际到账 |

**建议**：财务对账使用实收营收，业务分析可使用应付营收。

### 3.2 账单统计口径对比

| 口径 | 包含 | 不包含 |
|------|------|--------|
| 开台账单 | 所有开台的账单 | - |
| 结账账单 | 已结账(status=1) | 开台、挂账、作废 |
| 有效账单 | 已结账且金额>0 | 零结账 |
| 实收账单 | 包含退菜冲正后的账单 | - |

## 4. 指标异常检测

### 4.1 营收异常检测

```sql
-- 检测日营收为0的异常
SELECT sid, closed_date, SUM(real_amount) as daily_revenue
FROM dwd_bill
WHERE status = 1
  AND closed_time >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY sid, DATE(closed_time)
HAVING SUM(real_amount) = 0

-- 检测营收环比异常（下降>50%）
WITH daily_revenue AS (
    SELECT
        DATE(closed_time) as date,
        SUM(real_amount) as revenue
    FROM dwd_bill
    WHERE status = 1
      AND closed_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY DATE(closed_time)
)
SELECT
    d1.date,
    d1.revenue as today_revenue,
    d2.revenue as yesterday_revenue,
    (d1.revenue - d2.revenue) / d2.revenue as change_rate
FROM daily_revenue d1
LEFT JOIN daily_revenue d2 ON d1.date = DATE_ADD(d2.date, INTERVAL 1 DAY)
WHERE d2.revenue > 0
  AND (d1.revenue - d2.revenue) / d2.revenue < -0.5
```

### 4.2 同步异常检测

```sql
-- 检测同步延迟告警
SELECT
    tbl_name,
    MAX(execute_time) as last_sync,
    (UNIX_TIMESTAMP(NOW()) - MAX(execute_time)) / 60 as delay_minutes
FROM canal_events
GROUP BY tbl_name
HAVING delay_minutes > 5

-- 检测同步失败积压
SELECT
    table_name,
    COUNT(*) as failed_count
FROM sync_queue
WHERE sync_status = 2  -- 同步失败
GROUP BY table_name
ORDER BY failed_count DESC
```

## 5. 证据索引

| 指标 ID | 证据来源 | 证据类型 | 验证状态 |
|---------|----------|----------|----------|
| M001-M005 | 待验证 | SRC | 待验证 |
| M010-M014 | 待验证 | SRC | 待验证 |
| M020-M022 | 待验证 | SRC | 待验证 |
| M030-M033 | 待验证 | SRC | 待验证 |
| M040-M042 | SLICE-010 | DOC | 已分析 |

