# 业务不变量

## 1. 不变量概览

| 不变量 ID | 业务表述 | 验证方式 | 严重性 | 证据 |
|-----------|----------|----------|--------|------|
| INV001 | 账单金额 = 菜品明细金额之和 | SQL 聚合验证 | P0 | SLICE-001 |
| INV002 | 结账支付总额 = 账单实收金额 | 支付汇总验证 | P0 | SLICE-001 |
| INV003 | 退菜后金额一致性 | 重新计算验证 | P0 | SLICE-001 |
| INV004 | 重复支付不重复入账 | 幂等键验证 | P0 | 待验证 |
| INV005 | 退款总额 ≤ 实付总额 | 金额校验 | P0 | 待验证 |
| INV006 | 同步后云端与本地数据一致 | 校验和验证 | P1 | SLICE-010 |
| INV007 | 账单状态不可逆 | 状态机验证 | P1 | SLICE-001 |
| INV008 | 离线数据最终一致性 | 同步队列验证 | P1 | SLICE-008 |

## 2. 财务完整性不变量

### INV001: 账单金额 = 菜品明细金额之和

**业务表述**：账单应付金额必须等于其所有菜品明细金额的加总

**数学表达**：

```
dwd_bill.total_amount = Σ(dwd_food.amount) WHERE dwd_food.bill_id = dwd_bill.lid
```

**验证方式**：

```sql
-- 检测金额不一致的账单
SELECT b.lid, b.total_amount, SUM(f.amount) as food_sum
FROM dwd_bill b
LEFT JOIN dwd_food f ON f.bill_id = b.lid
GROUP BY b.lid, b.total_amount
HAVING ABS(b.total_amount - IFNULL(SUM(f.amount), 0)) > 0.01
```

**触发时机**：
- 每次加菜、退菜后
- 每次结账前
- 日结对账时

**违反处理**：
- 触发金额不一致告警
- 人工审核后决定以哪个为准
- 记录差异日志

**证据**：SLICE-001 / GeneralCalcOrderServiceImpl

---

### INV002: 结账支付总额 = 账单实收金额

**业务表述**：账单的实收金额必须等于所有支付明细的支付金额之和

**数学表达**：

```
dwd_bill.real_amount = Σ(dwd_pay.pay_amount) WHERE dwd_pay.bill_id = dwd_bill.lid AND dwd_pay.status = 1
```

**验证方式**：

```sql
-- 检测支付金额不一致
SELECT b.lid, b.real_amount, SUM(p.pay_amount) as pay_sum
FROM dwd_bill b
LEFT JOIN dwd_pay p ON p.bill_id = b.lid AND p.status = 1
WHERE b.status = 1  -- 已结账
GROUP BY b.lid, b.real_amount
HAVING ABS(b.real_amount - IFNULL(SUM(p.pay_amount), 0)) > 0.01
```

**触发时机**：
- 每次支付成功后
- 每日对账时
- 财务审计时

**违反处理**：
- 标记为异常账单
- 不允许日结通过
- 人工介入处理

**证据**：SLICE-001 / CheckOutServiceImpl

---

### INV003: 退菜后金额一致性

**业务表述**：退菜后重新计算的账单金额必须与退菜后的金额一致

**数学表达**：

```
退菜后 calc(total_amount) = 退菜前 total_amount - 退菜金额
```

**验证方式**：
- 退菜操作后立即调用 CalcOrderService 重新计算
- 比对计算结果与更新后的 total_amount

**违反处理**：
- 回滚退菜操作
- 记录异常日志
- 告警通知

**证据**：待验证 DwdFoodOpsService

---

### INV004: 重复支付不重复入账

**业务表述**：同一笔支付回调到达多次，不得重复入账

**验证方式**：

```sql
-- 检测重复支付记录
SELECT saas_order_no, COUNT(*) as cnt
FROM dwd_pay
GROUP BY saas_order_no
HAVING COUNT(*) > 1
```

**幂等键**：saas_order_no (第三方支付订单号)

**触发时机**：
- 支付回调到达时
- 异步消息消费时

**违反处理**：
- 使用幂等键去重
- 只处理第一条记录
- 后续请求返回成功但不重复处理

**证据**：待验证支付回调处理

---

### INV005: 退款总额 ≤ 实付总额

**业务表述**：累计退款金额不得超过原始实付金额

**数学表达**：

```
Σ(refund_amount) ≤ original_pay_amount
```

**验证方式**：

```sql
-- 检测超额退款
SELECT p.lid, p.pay_amount, SUM(r.refund_amount) as total_refund
FROM dwd_pay p
LEFT JOIN dwd_pay_refund r ON r.pay_id = p.lid
WHERE p.status = 2  -- 已退款
GROUP BY p.lid, p.pay_amount
HAVING SUM(r.refund_amount) > p.pay_amount
```

**触发时机**：
- 每次退款操作前
- 每日对账时

**违反处理**：
- 拒绝退款操作
- 记录异常日志
- 告警通知风控

**证据**：待验证退款逻辑

## 3. 数据一致性不变量

### INV006: 同步后云端与本地数据一致

**业务表述**：云端和门店本地数据库的同一记录在同步完成后必须一致

**验证方式**：

```sql
-- 检测云端与本地差异（需对比两边数据库）
SELECT '云端有，本地无' as diff_type, lid FROM cloud_db.pt_dish
WHERE lid NOT IN (SELECT lid FROM local_db.local_dish)
UNION ALL
SELECT '本地有，云端无' as diff_type, lid FROM local_db.local_dish
WHERE lid NOT IN (SELECT lid FROM cloud_db.pt_dish)
```

**触发时机**：
- 每次增量同步后
- 每日全量校验时
- 发现同步延迟告警时

**违反处理**：
- 使用 sync_delay 作为判断
- 延迟超过阈值（5分钟）触发告警
- 人工确认后执行强制同步

**证据**：SLICE-010

---

### INV007: 账单状态不可逆（部分）

**业务表述**：特定状态转换是单向的，不可逆

**不可逆转换**：
| 从状态 | 到状态 | 原因 |
|--------|--------|------|
| 已作废(2) | 任意 | 不可恢复 |
| 已退款(2) | 已支付(1) | 财务规范 |

**可逆转换**：
| 从状态 | 到状态 | 条件 |
|--------|--------|------|
| 已结账(1) | 开台(0) | 反结账，需当日 |

**验证方式**：
- 状态机强制校验
- 历史状态记录

**违反处理**：
- 代码层面阻止非法转换
- 记录尝试非法转换的日志

**证据**：SLICE-001

---

### INV008: 离线数据最终一致性

**业务表述**：离线期间产生的所有数据必须在网络恢复后最终同步到云端

**验证方式**：

```sql
-- 检测未同步的离线数据
SELECT COUNT(*) FROM sync_queue
WHERE sync_status = 0  -- 待同步
AND created_time < DATE_SUB(NOW(), INTERVAL 24 HOUR)
```

**触发时机**：
- 网络恢复时立即触发
- 每日凌晨检查长期未同步数据

**违反处理**：
- 重试同步
- 重试超过阈值后标记失败
- 人工处理

**证据**：SLICE-008

## 4. 业务约束不变量

### INV009: 租户隔离

**业务表述**：每个租户(mid)的数据必须严格隔离，不能跨租户访问

**验证方式**：
- 所有查询必须包含 mid 条件
- 数据权限校验

**违反处理**：
- 安全漏洞
- 立即告警

**证据**：系统架构设计

---

### INV010: 账单与桌台绑定

**业务表述**：占用状态的桌台必须绑定一个开台状态的账单

**验证方式**：

```sql
-- 检测孤立占用桌台
SELECT t.lid FROM pt_tbl t
WHERE t.status = 1  -- 占用
AND NOT EXISTS (
    SELECT 1 FROM dwd_bill b
    WHERE b.tbl_id = t.lid AND b.status = 0  -- 开台
)
```

**违反处理**：
- 清理孤立占用记录
- 告警通知

**证据**：待验证

---

### INV011: 菜品明细归属唯一账单

**业务表述**：每个菜品明细只能归属于一个账单

**验证方式**：
- bill_id 字段唯一性校验
- 不允许跨账单移动菜品

**违反处理**：
- 数据错误
- 需人工修复

**证据**：数据模型设计

## 5. 验证用例

### 5.1 金额一致性验证用例

```sql
-- 完整金额一致性验证
WITH bill_food_sum AS (
    SELECT bill_id, SUM(amount) as food_total
    FROM dwd_food
    GROUP BY bill_id
),
bill_pay_sum AS (
    SELECT bill_id, SUM(pay_amount) as pay_total
    FROM dwd_pay
    WHERE status = 1
    GROUP BY bill_id
)
SELECT
    b.lid,
    b.total_amount,
    COALESCE(f.food_total, 0) as food_sum,
    CASE
        WHEN ABS(b.total_amount - COALESCE(f.food_total, 0)) > 0.01
        THEN '金额不一致'
        ELSE '正常'
    END as food_status,
    b.real_amount,
    COALESCE(p.pay_total, 0) as pay_sum,
    CASE
        WHEN ABS(b.real_amount - COALESCE(p.pay_total, 0)) > 0.01
        THEN '金额不一致'
        ELSE '正常'
    END as pay_status
FROM dwd_bill b
LEFT JOIN bill_food_sum f ON f.bill_id = b.lid
LEFT JOIN bill_pay_sum p ON p.bill_id = b.lid
WHERE b.status IN (0, 1)  -- 开台或已结账
```

## 6. 证据索引

| 不变量 ID | 证据来源 | 证据类型 |
|-----------|----------|----------|
| INV001 | GeneralCalcOrderServiceImpl | SRC |
| INV002 | CheckOutServiceImpl | SRC |
| INV003 | DwdFoodOpsService | SRC |
| INV004 | 支付回调处理 | SRC |
| INV005 | 退款处理 | SRC |
| INV006 | CanalEventService | SRC |
| INV007 | DwdBill.status 状态机 | SRC |
| INV008 | SyncQueue | DAT |
| INV009 | 系统架构 | DOC |
| INV010 | pt_tbl/dwd_bill 关系 | DAT |
| INV011 | dwd_food.bill_id | DAT |

