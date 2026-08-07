# 数据语义定义

## 1. 核心字段语义

### 1.1 金额字段语义

| 字段 | 表 | 类型 | 业务语义 | 单位 | 精度 | 约束 |
|------|-----|------|----------|------|------|------|
| total_amount | dwd_bill | DECIMAL(10,2) | 应付总额（未优惠前） | 元 | 0.01 | ≥ 0 |
| real_amount | dwd_bill | DECIMAL(10,2) | 实收金额（优惠后） | 元 | 0.01 | ≥ 0 |
| discount_amount | dwd_bill | DECIMAL(10,2) | 优惠金额 | 元 | 0.01 | ≥ 0 |
| should_amount | dwd_bill | DECIMAL(10,2) | 应收金额（抹零后） | 元 | 0.01 | ≥ 0 |
| pay_amount | dwd_pay | DECIMAL(10,2) | 支付金额 | 元 | 0.01 | ≥ 0 |
| price | pt_dish | DECIMAL(10,2) | 菜品单价 | 元 | 0.01 | ≥ 0 |
| amount | dwd_food | DECIMAL(10,2) | 菜品小计 | 元 | 0.01 | ≥ 0 |

**金额语义规则**：
- 所有金额字段以"元"为单位，精度为 0.01
- 金额计算遵循：`total_amount - discount_amount = real_amount`
- 实付与支付明细之和的误差不得超过 0.01

### 1.2 数量字段语义

| 字段 | 表 | 类型 | 业务语义 | 单位 | 精度 |
|------|-----|------|----------|------|------|
| num | dwd_food | DECIMAL(10,2) | 菜品数量 | 份 | 0.01 |
| price_special_num | dwd_food | DECIMAL(10,2) | 特价菜数量 | 份 | 0.01 |

**数量语义规则**：
- 数量支持小数（用于称重菜）
- 退菜时数量可为小数

### 1.3 时间字段语义

| 字段 | 表 | 类型 | 业务语义 | 时区 | 格式 |
|------|-----|------|----------|------|------|
| created_time | dwd_bill | DATETIME | 账单创建时间（开台时间） | 门店本地时区 | YYYY-MM-DD HH:mm:ss |
| updated_time | dwd_bill | DATETIME | 最后更新时间 | 门店本地时区 | YYYY-MM-DD HH:mm:ss |
| closed_time | dwd_bill | DATETIME | 结账时间 | 门店本地时区 | YYYY-MM-DD HH:mm:ss |
| pay_time | dwd_pay | DATETIME | 支付时间 | 门店本地时区 | YYYY-MM-DD HH:mm:ss |

**时间语义规则**：
- 所有时间使用门店本地时区
- 反结账时间限制基于 closed_time 计算

### 1.4 标识字段语义

| 字段 | 表 | 类型 | 业务语义 | 生成方式 |
|------|-----|------|----------|----------|
| lid | 所有表 | BIGINT | 逻辑主键，全局唯一 | 雪花算法/DB自增 |
| mid | 所有表 | BIGINT | 商户ID，租户隔离标识 | 平台分配 |
| sid | 所有表 | BIGINT | 门店ID，门店隔离标识 | 平台分配 |
| order_no | dwd_bill | VARCHAR(32) | 账单业务编号 | 本地生成/云端下发 |
| saas_order_no | dwd_pay | VARCHAR(64) | 第三方支付订单号 | 支付平台返回 |
| lid | 表 | BIGINT | 逻辑主键 | 全局唯一 |

**标识语义规则**：
- `lid` 是全局唯一标识，用于跨系统关联
- `mid` + `sid` 是数据隔离的基本单位
- `order_no` 用于账单在本地与云端的关联

## 2. 状态字段语义

### 2.1 账单状态

```java
public enum BillStatus {
    OPEN(0, "开台"),           // 账单已开，可点餐
    CHECKED(1, "已结账"),      // 账单已结清
    CANCELLED(2, "已作废"),    // 账单已作废
    CREDIT(3, "挂账");         // 账单挂账，欠款未结
}
```

### 2.2 菜品明细状态

```java
public enum FoodStatus {
    NORMAL(0, "正常"),  // 正常销售
    REFUND(1, "已退"),  // 已退菜
    GIFT(2, "已赠");    // 已赠送
}
```

### 2.3 支付状态

```java
public enum PayStatus {
    PENDING(0, "待支付"),   // 等待支付
    PAID(1, "已支付"),      // 支付成功
    REFUNDED(2, "已退款");  // 已退款
}
```

### 2.4 同步状态

```java
public enum SyncStatus {
    PENDING(0, "待同步"),   // 等待同步
    SYNCED(1, "已同步"),     // 同步成功
    FAILED(2, "同步失败");  // 同步失败
}
```

## 3. 枚举字段映射

### 3.1 支付方式

| type_ | 名称 | 说明 | 离线支持 |
|-------|------|------|----------|
| 1 | 现金 | 现金支付 | ✅ |
| 2 | 微信支付 | 微信扫码/JSAPI | ❌ |
| 3 | 支付宝 | 支付宝扫码 | ❌ |
| 4 | 会员卡 | 会员卡余额支付 | ⚠️ 部分 |
| 5 | 银行卡 | 银行卡支付 | ❌ |
| 6 | 扫码付 | 混合扫码支付 | ❌ |
| 7 | 优惠券 | 优惠券抵扣 | ⚠️ 部分 |

### 3.2 桌台状态

| status | 名称 | 说明 |
|--------|------|------|
| 0 | 空闲 | 可开台 |
| 1 | 占用 | 已有账单 |
| 2 | 锁定 | 不可开台 |
| 3 | 停用 | 不再使用 |

### 3.3 菜品状态

| status | 名称 | 说明 |
|--------|------|------|
| 0 | 下架 | 不可销售 |
| 1 | 上架 | 正常销售 |

## 4. 数据语义异常

### 4.1 已知的语义问题

| 问题 | 描述 | 影响 | 处理建议 |
|------|------|------|----------|
| 金额字段混用 | 部分场景使用 Float 导致精度丢失 | 金额计算不准确 | 统一使用 DECIMAL |
| 时间戳混用 | created_time 有时存时间戳，有时存 DATETIME | 跨时区问题 | 统一规范 |
| 状态值歧义 | 某些状态值在不同表含义不同 | 理解困难 | 统一枚举定义 |

### 4.2 数据质量检查

```sql
-- 检查金额字段异常
SELECT * FROM dwd_bill
WHERE total_amount < 0
   OR real_amount < 0
   OR discount_amount < 0
   OR discount_amount > total_amount;

-- 检查状态字段异常
SELECT * FROM dwd_bill WHERE status NOT IN (0, 1, 2, 3);
SELECT * FROM dwd_food WHERE status NOT IN (0, 1, 2);
SELECT * FROM dwd_pay WHERE status NOT IN (0, 1, 2);

-- 检查时间字段异常
SELECT * FROM dwd_bill
WHERE created_time IS NULL
   OR closed_time < created_time;
```

## 5. 证据索引

| 语义定义 | 证据来源 | 证据类型 |
|----------|----------|----------|
| 金额字段 | 数据库表结构 | DAT |
| 状态枚举 | 代码枚举定义 | SRC |
| 标识字段 | 数据模型 | DOC |
| 语义异常 | 数据剖析 | DAT |

