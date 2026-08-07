# 数据异常登记

## 1. 已识别异常

### 1.1 金额异常

| 异常 ID | 异常描述 | 检测 SQL | 影响 | 处理建议 |
|---------|----------|----------|------|----------|
| DA001 | 账单应付金额与菜品明细之和不一致 | `total_amount ≠ Σ(dwd_food.amount)` | 财务对账差异 | 重新计算 |
| DA002 | 实收金额与支付明细之和不一致 | `real_amount ≠ Σ(dwd_pay.pay_amount)` | 支付差异 | 核对支付记录 |
| DA003 | 优惠金额大于应付金额 | `discount_amount > total_amount` | 数据错误 | 人工审核 |
| DA004 | 金额为负数 | `amount < 0` | 数据错误 | 检查业务逻辑 |

### 1.2 状态异常

| 异常 ID | 异常描述 | 检测 SQL | 影响 | 处理建议 |
|---------|----------|----------|------|----------|
| DA010 | 账单状态无效 | `status NOT IN (0,1,2,3)` | 系统错误 | 修正状态 |
| DA011 | 菜品明细状态无效 | `status NOT IN (0,1,2)` | 系统错误 | 修正状态 |
| DA012 | 已作废账单仍有支付记录 | `status=2 AND EXISTS dwd_pay` | 财务问题 | 核对退款 |
| DA013 | 账单已结账但菜品明细仍为开台状态 | `status=1 AND 未上菜` | 数据不一致 | 检查流程 |

### 1.3 时间异常

| 异常 ID | 异常描述 | 检测 SQL | 影响 | 处理建议 |
|---------|----------|----------|------|----------|
| DA020 | 结账时间早于开台时间 | `closed_time < created_time` | 数据错误 | 人工审核 |
| DA021 | 账单结账时间在未来 | `closed_time > NOW()` | 时钟不同步 | 同步时钟 |
| DA022 | 菜品明细创建时间早于账单创建时间 | `food.created_time < bill.created_time` | 数据错误 | 人工审核 |

### 1.4 关联异常

| 异常 ID | 异常描述 | 检测 SQL | 影响 | 处理建议 |
|---------|----------|----------|------|----------|
| DA030 | 菜品明细引用不存在的账单 | `bill_id NOT IN dwd_bill.lid` | 孤儿记录 | 清理或修复 |
| DA031 | 菜品明细引用不存在的菜品 | `dish_id NOT IN pt_dish.lid` | 孤儿记录 | 清理或修复 |
| DA032 | 占用状态的桌台无关联账单 | `pt_tbl.status=1 AND 无 dwd_bill` | 数据不一致 | 检查开台/关台 |
| DA033 | 已结账账单关联的桌台为空闲 | `dwd_bill.status=1 AND pt_tbl.status=0` | 数据不一致 | 检查状态同步 |

## 2. 异常检测 SQL

### 2.1 金额一致性检测

```sql
-- 检测账单金额与菜品明细不一致
SELECT
    b.lid as bill_id,
    b.total_amount,
    COALESCE(SUM(f.amount), 0) as food_sum,
    b.total_amount - COALESCE(SUM(f.amount), 0) as diff
FROM dwd_bill b
LEFT JOIN dwd_food f ON f.bill_id = b.lid
WHERE b.status IN (0, 1)  -- 开台或已结账
GROUP BY b.lid, b.total_amount
HAVING ABS(b.total_amount - COALESCE(SUM(f.amount), 0)) > 0.01
```

### 2.2 支付一致性检测

```sql
-- 检测实收金额与支付明细不一致
SELECT
    b.lid as bill_id,
    b.real_amount,
    COALESCE(SUM(p.pay_amount), 0) as pay_sum,
    b.real_amount - COALESCE(SUM(p.pay_amount), 0) as diff
FROM dwd_bill b
LEFT JOIN dwd_pay p ON p.bill_id = b.lid AND p.status = 1
WHERE b.status = 1  -- 已结账
GROUP BY b.lid, b.real_amount
HAVING ABS(b.real_amount - COALESCE(SUM(p.pay_amount), 0)) > 0.01
```

### 2.3 状态完整性检测

```sql
-- 检测孤立菜品明细
SELECT f.*
FROM dwd_food f
WHERE NOT EXISTS (
    SELECT 1 FROM dwd_bill b WHERE b.lid = f.bill_id
)

-- 检测孤立支付记录
SELECT p.*
FROM dwd_pay p
WHERE NOT EXISTS (
    SELECT 1 FROM dwd_bill b WHERE b.lid = p.bill_id
)
```

### 2.4 时间合理性检测

```sql
-- 检测时间异常
SELECT *
FROM dwd_bill
WHERE closed_time IS NOT NULL
  AND closed_time < created_time

-- 检测跨日异常账单
SELECT
    b.*,
    DATE(b.created_time) as open_date,
    DATE(b.closed_time) as close_date
FROM dwd_bill b
WHERE b.status = 1
  AND DATE(b.created_time) != DATE(b.closed_time)
```

## 3. 异常处理流程

```
检测异常
    │
    ▼
┌─────────────────────────────────────────┐
│ 异常分类                                   │
│ - 金额异常 → 财务审核                     │
│ - 状态异常 → 运维修复                     │
│ - 时间异常 → 运维/业务审核                │
│ - 关联异常 → 技术修复                     │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ 修复执行                                   │
│ - 自动修复（规则明确）                    │
│ - 人工修复（需审核）                      │
│ - 记录修复日志                            │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ 验证完成                                   │
│ - 重新执行检测 SQL                        │
│ - 确认修复结果                            │
└─────────────────────────────────────────┘
```

## 4. 异常预防措施

### 4.1 金额类

| 预防措施 | 说明 |
|----------|------|
| 金额计算统一入口 | 所有金额计算通过 CalcOrderService |
| 事务一致性保证 | 结账操作在同一事务内更新金额和状态 |
| 双重校验 | 结账前校验金额一致性 |

### 4.2 状态类

| 预防措施 | 说明 |
|----------|------|
| 状态机强制约束 | 禁止非法状态转换 |
| 状态更新统一入口 | 通过 Service 方法更新状态 |

### 4.3 关联类

| 预防措施 | 说明 |
|----------|------|
| 外键约束 | 数据库层约束关联关系 |
| 级联处理 | 删除时自动处理关联记录 |

## 5. 证据索引

| 异常类型 | 证据来源 | 证据类型 |
|----------|----------|----------|
| 金额异常 | 04-models/invariants.md | DOC |
| 状态异常 | 04-models/state-machines.md | DOC |
| 关联异常 | 数据模型定义 | DAT |

