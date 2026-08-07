# API 契约登记

## 1. 核心 API 契约

### 1.1 POS 收银端 API

| 契约 ID | 接口 | 方法 | 消费方 | 提供方 | 作用域 |
|---------|------|------|--------|--------|--------|
| API001 | /api/pos4cloud/app/bill/open | POST | POS前端 | pos4cloud | mid, sid |
| API002 | /api/pos4cloud/app/bill/close | POST | POS前端 | pos4cloud | mid, sid |
| API003 | /api/pos4cloud/app/food/add | POST | POS前端 | pos4cloud | mid, sid, bill_id |
| API004 | /api/pos4cloud/app/food/remove | POST | POS前端 | pos4cloud | mid, sid, bill_id |
| API005 | /api/pos4cloud/app/checkout | POST | POS前端 | pos4cloud | mid, sid, bill_id |
| API006 | /api/pos4cloud/app/calc | POST | POS前端 | pos4cloud | mid, sid, lid |
| API007 | /api/pos4cloud/app/sync/upload | POST | POS前端 | pos4cloud | mid, sid |

### 1.2 云端管理 API

| 契约 ID | 接口 | 方法 | 消费方 | 提供方 | 作用域 |
|---------|------|------|--------|--------|--------|
| API010 | /boss/dish/* | GET | 前端 | pos11report | mid, sid |
| API011 | /boss/bill/* | GET | 前端 | pos11report | mid, sid |
| API012 | /boss/report/* | GET | 前端 | pos11report | mid, sid |
| API013 | /shopping_cart/add | POST | 顾客小程序 | nms4cloud-order | mid, sid |
| API014 | /order_bill/* | POST | 顾客小程序 | nms4cloud-order | mid, sid |

### 1.3 外部系统 API

| 契约 ID | 接口 | 方法 | 消费方 | 提供方 | 作用域 |
|---------|------|------|--------|--------|--------|
| API020 | 美团外卖 API | HTTP | nms4pos | 美团 | sid |
| API021 | 饿了么 API | HTTP | nms4pos | 饿了么 | sid |
| API022 | 微信支付回调 | HTTP | nms4pos | 微信支付 | mid |
| API023 | 支付宝回调 | HTTP | nms4pos | 支付宝 | mid |

## 2. API 详细契约

### 2.1 开台接口 (API001)

**请求**：
```json
{
    "mid": 1001,
    "sid": 2001,
    "tbl_id": 3001,
    "operator_id": 4001,
    "customer_count": 4
}
```

**响应**：
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "lid": 1234567890,
        "order_no": "S20240101120000001",
        "tbl_name": "A01",
        "status": 0
    }
}
```

**契约约束**：
- lid 全局唯一，用于后续所有操作
- order_no 用于本地与云端关联
- status=0 表示开台成功

---

### 2.2 加菜接口 (API003)

**请求**：
```json
{
    "mid": 1001,
    "sid": 2001,
    "lid": 1234567890,
    "foods": [
        {
            "dish_id": 5001,
            "num": 2,
            "cook_id": 6001,
            "taste_ids": [7001, 7002],
            "remark": "少辣"
        }
    ]
}
```

**响应**：
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "food_items": [
            {
                "lid": 8001,
                "dish_id": 5001,
                "num": 2,
                "price": 38.00,
                "amount": 76.00
            }
        ],
        "total_amount": 76.00
    }
}
```

---

### 2.3 结账接口 (API005)

**请求**：
```json
{
    "mid": 1001,
    "sid": 2001,
    "lid": 1234567890,
    "payments": [
        {
            "type_": 1,
            "pay_amount": 76.00
        }
    ],
    "coupon_ids": [],
    "operator_id": 4001
}
```

**响应**：
```json
{
    "code": 0,
    "msg": "success",
    "data": {
        "lid": 1234567890,
        "total_amount": 76.00,
        "real_amount": 76.00,
        "should_amount": 76.00,
        "pay_amount": 76.00,
        "change": 0.00,
        "status": 1
    }
}
```

**契约约束**：
- 支付总额必须等于实收金额
- status=1 表示结账成功

## 3. 消息契约

### 3.1 Canal 事件消息

**Topic**：`nms4cloud-pos5sync`

**消息格式**：
```json
{
    "mid": 1001,
    "sid": 2001,
    "lid": 1234567890,
    "tbl_name": "pt_dish",
    "type": "UPDATE",
    "log_file_name": "binlog.001",
    "execute_time": 1700000000,
    "content": {
        "lid": "1234567890",
        "name": "宫保鸡丁",
        "price": "38.00"
    }
}
```

**契约约束**：
- tbl_name 必须是配置中的同步表
- sid 必须是配置的同步门店

### 3.2 Kafka 消息（内部）

**Topic**：待确认

**消息格式**：
```json
{
    "event_type": "SYNC_BILL",
    "mid": 1001,
    "sid": 2001,
    "data": {},
    "timestamp": 1700000000
}
```

## 4. 定时任务契约

### 4.1 日结任务

**Cron**：`0 0 2 * * ?` (每日凌晨2点)

**任务内容**：
1. 生成日结报表
2. 上报数据到云端
3. 清理过期数据

**契约约束**：
- 日结前必须确保所有离线数据已同步
- 日结后账单不可反结账

### 4.2 数据同步任务

**Cron**：`0 */5 * * * ?` (每5分钟)

**任务内容**：
1. 检测同步延迟
2. 触发增量同步
3. 处理同步失败记录

## 5. 契约变更管理

| 契约 ID | 变更日期 | 变更内容 | 负责人 | 影响评估 |
|---------|----------|----------|--------|----------|
| API001 | 2024-01-01 | 新增 customer_count 字段 | - | - |
| API005 | 2024-01-15 | 新增 coupon_ids 字段 | - | - |

## 6. 废弃候选

| 契约 ID | 候选原因 | 发现日期 | 状态 |
|---------|----------|----------|------|
| API010 | /boss/* 接口由 pos11report 承担 | 2024-01 | 候选废弃 |

## 7. 证据索引

| 契约类型 | 证据来源 | 证据类型 |
|----------|----------|----------|
| POS API | Controller 代码 | SRC |
| 消息契约 | SLICE-010 | DOC |
| 定时任务 | 待验证 | SRC |

