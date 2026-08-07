# 核心业务对象

## 1. 对象概览

| 对象 | 中文名 | 物理表 | 唯一标识 | 核心属性 | 生命周期 |
|------|--------|--------|----------|----------|----------|
| DwdBill | 账单 | dwd_bill | lid | mid, sid, order_no, status, total_amount | 开台→结账 |
| DwdFood | 菜品明细 | dwd_food | lid | bill_id, dish_id, num, price, amount | 加菜→退菜 |
| DwdPay | 支付明细 | dwd_pay | lid | bill_id, type_, pay_amount, status | 结账→核销 |
| PtDish | 菜品 | pt_dish | lid | mid, sid, name, price, status | 上架→下架 |
| PtTbl | 桌台 | pt_tbl | lid | sid, name, area_id, status | 创建→删除 |
| BizMember | 会员 | biz_member | lid | mid, name, phone, balance, integral | 注册→注销 |
| SyncQueue | 同步队列 | sync_queue | id | operation_type, table_name, data, sync_status | 离线→同步 |

## 2. 核心对象详细定义

### 2.1 DwdBill (账单)

账单是一次用餐的完整消费记录，是订单的核心实体。

**标识体系**：
| 字段 | 类型 | 说明 | 用途 |
|------|------|------|------|
| lid | BIGINT | 逻辑主键 | 全局唯一标识 |
| mid | BIGINT | 商户ID | 租户隔离 |
| sid | BIGINT | 门店ID | 门店隔离 |
| order_no | VARCHAR | 账单编号 | 业务主键，本地/云端协同 |

**状态字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| status | INT | 账单状态：0-开台, 1-已结账, 2-已作废, 3-挂账 |

**金额字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| total_amount | DECIMAL | 应付总额 |
| real_amount | DECIMAL | 实收金额（优惠后） |
| discount_amount | DECIMAL | 优惠金额 |
| should_amount | DECIMAL | 应收金额（抹零后） |

**时间字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| created_time | DATETIME | 创建时间 |
| updated_time | DATETIME | 更新时间 |
| closed_time | DATETIME | 结账时间 |

**关系**：
```
DwdBill (1) ──┬── (*) DwdFood (菜品明细)
              └── (*) DwdPay (支付明细)
```

### 2.2 DwdFood (菜品明细)

菜品明细是账单中的每一道菜及其属性记录。

**核心字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 逻辑主键 |
| bill_id | BIGINT | 所属账单ID |
| dish_id | BIGINT | 菜品ID (pt_dish.lid) |
| num | DECIMAL | 数量 |
| price | DECIMAL | 单价 |
| amount | DECIMAL | 小计金额 |
| status | INT | 菜品状态：0-正常, 1-已退, 2-已赠 |

**制作属性**：
| 字段 | 类型 | 说明 |
|------|------|------|
| cook_id | BIGINT | 做法ID |
| taste_id | BIGINT | 口味ID |
| remark | VARCHAR | 备注 |

**关联对象**：
```
DwdFood ──(dish_id)── PtDish
DwdFood ──(bill_id)── DwdBill
```

### 2.3 DwdPay (支付明细)

支付明细记录账单的每一笔支付。

**核心字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 逻辑主键 |
| bill_id | BIGINT | 所属账单ID |
| type_ | INT | 支付方式：1-现金, 2-微信, 3-支付宝, 4-会员卡, 5-银行卡 |
| pay_amount | DECIMAL | 支付金额 |
| status | INT | 支付状态：0-待支付, 1-已支付, 2-已退款 |
| offline_flag | INT | 离线标识：0-在线, 1-离线 |

### 2.4 PtDish (菜品)

菜品是菜品管理的核心实体。

**核心字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| lid | BIGINT | 逻辑主键 |
| mid | BIGINT | 商户ID |
| sid | BIGINT | 门店ID |
| name | VARCHAR | 菜品名称 |
| price | DECIMAL | 标准价格 |
| status | INT | 状态：0-下架, 1-上架 |
| type_id | BIGINT | 分类ID |

### 2.5 SyncQueue (同步队列)

同步队列用于离线数据的暂存和同步。

**核心字段**：
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键 |
| operation_type | VARCHAR | 操作类型：INSERT/UPDATE/DELETE |
| table_name | VARCHAR | 目标表名 |
| record_id | BIGINT | 记录ID |
| data | JSON | 操作数据 |
| sync_status | INT | 同步状态：0-待同步, 1-已同步, 2-同步失败 |
| created_time | DATETIME | 创建时间 |

## 3. 对象关系图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              账单领域                                    │
│                                                                         │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│  │   PtTbl     │     │   DwdBill   │     │   DwdPay    │           │
│  │   (桌台)    │────▶│   (账单)    │◀────│  (支付明细)  │           │
│  └─────────────┘     └──────┬──────┘     └─────────────┘           │
│                             │                                          │
│                             │ 1:N                                        │
│                             ▼                                          │
│                      ┌─────────────┐                                   │
│                      │   DwdFood   │                                   │
│                      │ (菜品明细)  │                                   │
│                      └──────┬──────┘                                   │
│                             │                                          │
│                             ▼                                          │
│                      ┌─────────────┐                                   │
│                      │   PtDish    │                                   │
│                      │   (菜品)    │                                   │
│                      └─────────────┘                                   │
└─────────────────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              同步领域                                    │
│                                                                         │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐           │
│  │  SyncQueue  │────▶│ CanalEvent │────▶│ Kafka Topic │           │
│  │ (同步队列)  │     │ (增量事件)  │     │ (消息队列)  │           │
│  └─────────────┘     └─────────────┘     └─────────────┘           │
└─────────────────────────────────────────────────────────────────────────┘
```

## 4. 对象生命周期

### 4.1 账单生命周期

```
开台 ──▶ 点餐 ──▶ 结账 ──▶ 完成
 │       │        │
 │       │        └── 可选：反结账 → 重新结账
 │       │
 │       └── 可选：退菜/加菜
 │
 └── 可选：挂账 ──▶ 赊账还款 ──▶ 结账
```

### 4.2 菜品明细生命周期

```
加菜 ──▶ 制作中 ──▶ 已上菜 ──▶ 已结账
  │                          │
  └── 可选：退菜 ──▶ 已退 ──▶ (不可逆)
  │
  └── 可选：赠送 ──▶ 已赠 ──▶ 已结账
```

### 4.3 同步队列生命周期

```
离线操作 ──▶ 写入队列(待同步) ──▶ 网络恢复
   │                                    │
   │                                    ▼
   │                            同步到云端 ──▶ 删除本地
   │                                    │
   │                                    ▼ (失败)
   │                            重试队列 ──▶ 人工处理
```

## 5. 对象状态汇总

| 对象 | 状态字段 | 状态值定义 |
|------|----------|------------|
| DwdBill | status | 0-开台, 1-已结账, 2-已作废, 3-挂账 |
| DwdFood | status | 0-正常, 1-已退, 2-已赠 |
| DwdPay | status | 0-待支付, 1-已支付, 2-已退款 |
| PtDish | status | 0-下架, 1-上架 |
| PtTbl | status | 0-空闲, 1-占用, 2-锁定, 3-停用 |
| SyncQueue | sync_status | 0-待同步, 1-已同步, 2-同步失败 |
| CanalEvent | type | INSERT, UPDATE, DELETE |

## 6. 证据索引

| 对象 | 主要代码位置 | 证据类型 |
|------|--------------|----------|
| DwdBill | DwdBillOpsService | SRC |
| DwdFood | DwdFoodOpsService | SRC |
| DwdPay | dwd_pay 表结构 | DAT |
| PtDish | pt_dish 表结构 | DAT |
| SyncQueue | slice-008-flow.md | DOC |
| CanalEvent | CanalEventService | SRC |

