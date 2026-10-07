# nms4cloud-order 业务分析报告

## 版本信息

| 属性 | 值 |
|---|---|
| 分析对象 | nms4cloud-order 订单模块 |
| 图谱版本 | 9560e50e4696 |
| 图谱构建时间 | 2026-09-11T21:58:34 |
| 分支 | jujiao_master |
| SOP 版本 | v1.0 |
| 生成时间 | 2026-09-12 |

---

## 一、图库概览

| 统计项 | 数量 |
|--------|------|
| 节点数 | 3,167 |
| 边数 | 23,720 |
| 文件数 | 210 |
| 语言 | java, sql |

### 1.1 节点类型分布

| 节点类型 | 数量 | 说明 |
|----------|------|------|
| Field | 1,930 | 字段节点 |
| Function | 429 | 函数/方法 |
| Class | 216 | 类节点 |
| File | 210 | 文件节点 |
| DomainConcept | 201 | 领域概念 |
| Endpoint | 104 | API 端点 |
| EnumValue | 58 | 枚举值 |
| Test | 19 | 测试 |

### 1.2 边类型分布

| 边类型 | 数量 | 说明 |
|--------|------|------|
| CALLS | 11,773 | 调用关系 |
| IMPORTS_FROM | 2,862 | 导入关系 |
| HAS_ANNOTATION | 2,538 | 注解关系 |
| HAS_FIELD | 1,930 | 字段关系 |
| INJECTS | 1,283 | 依赖注入 |
| FIELD_TYPE | 1,275 | 字段类型 |
| CONTAINS | 667 | 包含关系 |
| TESTED_BY | 329 | 测试关系 |
| DOMAIN_CONCEPT | 201 | 领域概念 |
| CRUD_OPERATION | 195 | CRUD 操作 |
| INHERITS | 170 | 继承关系 |
| HAS_RULE | 165 | 业务规则 |
| HANDLES | 104 | API 处理 |
| HAS_ENUM_VALUE | 58 | 枚举值 |
| HAS_TEMPORAL | 43 | 时间字段 |
| SUPPORTS_READ | 36 | 读取操作 |
| SUPPORTS_CREATE | 20 | 创建操作 |
| WORKFLOW_ACTION | 19 | 工作流动作 |
| SUPPORTS_UPDATE | 17 | 更新操作 |
| HAS_SUBJECT | 13 | 主体关系 |

---

## 二、对象模型

### 2.1 核心类字段统计

按字段数量排序的核心类：

| 排名 | 类名 | 字段数 | 类型 |
|------|------|--------|------|
| 1 | OrderFoodVO | 102 | VO |
| 2 | OrderBillVO | 101 | VO |
| 3 | OrderBill | 94 | Entity |
| 4 | OrderFoodAddDTO | 80 | DTO |
| 5 | OrderFood | 76 | Entity |
| 6 | OrderBillAddDTO | 73 | DTO |
| 7 | OrderBillQueryDTO | 71 | DTO |
| 8 | OrderBillUpdateDTO | 66 | DTO |
| 9 | OrderFoodUpdateDTO | 58 | DTO |
| 10 | OrderFoodQueryDTO | 55 | DTO |
| 11 | OrderComment | 35 | Entity |
| 12 | BizPayWayVO | 34 | VO |
| 13 | OrderPay | 32 | Entity |
| 14 | OrderPayVO | 30 | VO |

**洞察**：OrderFoodVO 和 OrderBillVO 字段最多（100+），说明订单模块数据模型复杂，涉及大量业务属性。

### 2.2 枚举值分析

| 枚举类 | 枚举值 | 说明 |
|--------|--------|------|
| CartOpModeEnum | ADD, PLUS, MINUS, RMV, CLEAR, NONE | 购物车操作模式 |
| ConfirmStatusEnum | WATTING_CONFIRM, CONFIRMED, FAILED | 确认状态 |
| EvalTypeEnum | N, G, B | 评价类型（好评/中评/差评） |
| OrderMakingStatusEnum | WAITING_COOK, WAITING_SERVE, COMPLETED | 制作状态 |
| OrderMsgTypeEnum | DO_HEARTBEAT, DO_ORDER, CASH_REQUEST, DO_SYNC, DO_BOOK_STATE | 订单消息类型 |

---

## 三、行为模型

### 3.1 API 端点清单

| 模块 | 端点数 | 路径前缀 |
|------|--------|----------|
| order_bill | 30+ | /order_bill/* |
| order_food | 20+ | /order_food/* |
| order_pay | 15+ | /order_pay/* |
| order_comment | 10+ | /order_comment/* |
| shopping_cart | 15+ | /shopping_cart/* |

**核心 API**：
- `POST /order_bill/getInner` - 查询订单
- `POST /order_bill/list` - 订单列表
- `POST /order_bill/pay_order_inner` - 内部支付
- `POST /order_food/add` - 添加菜品
- `POST /order_food/update` - 更新菜品

### 3.2 状态转换

识别出 **9 个状态转换**：

| 转换 | 触发方法 |
|------|----------|
| OrderBill 取消 | OrderBillController.cancelOrder |
| 核销取消 | OrderBillController.cancelProductCouponWriteOff |
| Service 层取消 | OrderBillServicePlus.cancel |
| 优惠券核销取消 | OrderCouponServicePlus.cancelProductCouponWriteOff |
| 平台优惠券取消 | OrderCouponServicePlus.cancelPlatformProductCoupon |
| 支付取消 | PayOrderServiceImpl.cancel |

### 3.3 CRUD 操作

| 操作类型 | 数量 |
|----------|------|
| READ | 36 |
| CREATE | 20 |
| UPDATE | 17 |

---

## 四、主体模型

### 4.1 主体关系

识别出 **13 个主体关系**，主要包括：
- 用户相关字段（mid, sid）
- 客户相关字段

### 4.2 时间字段

识别出 **43 个时间字段**，包括：
- 创建时间
- 更新时间
- 过期时间
- 营业时间

---

## 五、规则模型

### 5.1 业务规则

识别出 **165 条业务规则**，涵盖：
- 数据校验规则
- 权限控制规则
- 业务流程规则

### 5.2 计算规则

识别出 **12 条计算规则**，包括：
- 价格计算
- 折扣计算
- 优惠计算

---

## 六、置信度汇总

| 维度 | 覆盖度 | 置信度 | 说明 |
|------|--------|--------|------|
| 对象模型 | 216 类 | L4 | 代码结构清晰 |
| 字段解析 | 1,930 字段 | L4 | 注解完整 |
| API 端点 | 104 个 | L5 | 路由明确 |
| 枚举值 | 58 个 | L5 | 代码直接事实 |
| 状态转换 | 9 个 | L3 | 方法调用分析 |
| 业务规则 | 165 个 | L3 | 代码模式识别 |

---

## 七、领域洞察

### 7.1 业务复杂度分析

**高复杂度信号**：
- VO/DTO 字段数量大（100+ 字段）→ 数据模型复杂
- 多层服务拆分（OrderBill/OrderFood/OrderPay 分别独立）→ 领域分化清晰
- 多种订单类型（pre_save/post/offline）→ 业务场景多样

### 7.2 订单流程推测

基于 API 和服务分析，订单模块支持以下场景：

```
点餐流程:
├── 购物车 (ShoppingCart)
├── 创建订单 (CrtPost/CrtPre/CrtTake)
├── 支付 (PayOrderService)
└── 核销/评价

订单类型:
├── pre_save   - 预保存订单
├── post       - 后付订单
├── offline    - 离线订单
└── take      - 外卖订单
```

---

## 八、未知项（U-*）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-1 | MQ 消息消费者未完整识别 | 异步流程可能遗漏 |
| U-2 | 补偿逻辑边界未确认 | 异常处理范围待验证 |
| U-3 | 权限检查注解覆盖率 | 需要人工复核 |
| U-4 | 优惠券/活动规则具体逻辑 | 需代码阅读确认 |
| U-5 | 状态机完整转换图 | 需枚举+代码交叉验证 |

---

## 九、证据引用

```
E-GPH: nodes:OrderBill
E-GPH: nodes:OrderFood
E-GPH: nodes:OrderPay
E-GPH: edges:CALLS (11773)
E-GPH: edges:HAS_FIELD (1930)
E-GPH: edges:HAS_ANNOTATION (2538)
```

---

## 十、后续步骤建议

1. **补充 MQ 消息消费** - 识别 @RabbitListener/@KafkaListener
2. **完善状态机建模** - 基于枚举值建立完整状态转换图
3. **补充补偿逻辑** - 识别回滚/补偿业务场景
4. **人工复核** - 验证 L2/L3 置信度结论
5. **深度代码阅读** - 确认核心业务规则实现
