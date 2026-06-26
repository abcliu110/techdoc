# SWQ 实物券扩展为单品折扣与立减券设计

> 状态说明：本文是 CRM `SWQ` 优惠方式扩展的背景设计文档。小程序商品券核销当前实现口径以 `03-小程序商品券核销设计文档.md` 和 `04-小程序商品券后端接口实现说明.md` 为准。

## 1. 设计结论

现有 CRM 中的 `SWQ` 不建议推翻重做，也不建议新增一套独立“单品券”系统。更稳妥的方案是：保留 `SWQ` 作为“实物券/菜品券”的主类型，在其下新增“单品优惠方式”，让同一张 `SWQ` 可以表达以下三种业务形态：

| 优惠方式 | 业务含义 | 示例 |
|---|---|---|
| `FREE` | 免费兑换一份指定菜品 | 招牌牛肉面免费券 |
| `DISCOUNT` | 指定菜品按折扣优惠 | 招牌牛肉面 5 折券 |
| `AMOUNT_OFF` | 指定菜品固定立减 | 招牌牛肉面减 5 元券 |

核心判断：现有 `SWQ + crm_coupon_dish + crm_coupon_order + CheckCouponUtil` 链路已经具备单品券所需的大部分能力，包括门店菜品绑定、单位校验、订单菜品匹配、领取券实例、核销与取消核销。因此本次改造应围绕“优惠金额计算方式”做小范围扩展。

## 2. 现有能力分析

### 2.1 券模板

现有 `crm_coupon` 通过 `coupon_type = SWQ` 表达实物券。模板层已有以下能力可以复用：

- 券名称、领取时间、使用时间、有效期规则。
- 限发、限领、每日限领、使用频次限制。
- 门店范围、可购买、可直接领取、审核和终止状态。
- 券模式 `coupon_mode = CP`，表示普通券。

不建议继续用 `crm_coupon.dishShopId / dishName / dishCode / dishUnit` 作为新能力主来源。这几个字段更像旧兼容字段。现有代码已经把 `crm_coupon_dish` 作为实物券菜品绑定主表。

### 2.2 菜品绑定

现有 `crm_coupon_dish` 是本次改造最关键的复用点：

| 字段 | 含义 |
|---|---|
| `coupon_lid` | 绑定的券模板 |
| `sid` | 适用门店 |
| `shop_name` | 门店名称快照 |
| `dish_lid` | 可使用的菜品 |
| `dish_name` | 菜品名称快照 |
| `dish_unit` | 菜品单位限制 |

当前代码限制同一张 `SWQ` 在同一门店只能绑定一个菜品。这个规则适合“指定某个菜品 5 折”或“指定某个菜品减 5 元”的第一版需求，应保留，不在本次扩大为多菜品任选。

### 2.3 校验与核销

当前 `CheckCouponUtil.check(...)` 对 `SWQ` 的处理流程是：

1. 检查券状态、门店、时段、使用限制。
2. 根据当前门店 `sid` 从 `dishList` 中找到绑定菜品。
3. 检查订单菜品列表中是否包含该 `dish_lid`。
4. 如果配置了 `dish_unit`，继续校验单位一致。
5. 命中后取一份菜品，返回 `CheckCouponOrderVO.amount = 菜品单价`。

这等价于“免费兑换一份菜品”。本次改造只需要把第 5 步改为按优惠方式计算金额。

核销接口 `writeOffOne`、`writeOffInner` 已经负责把 `crm_coupon_order` 更新为已核销，并记录门店、订单号、核销人、核销时间。本次不应改动核销状态流转。

## 3. 推荐方案

### 3.1 模型扩展

新增枚举：`DishDiscountTypeEnum`。

| 枚举 | code 建议 | 含义 | 金额字段要求 |
|---|---:|---|---|
| `FREE` | 1 | 免费兑换一份菜品 | `dishDiscountValue` 可为空 |
| `DISCOUNT` | 2 | 单品折扣 | `0 < dishDiscountValue < 10` |
| `AMOUNT_OFF` | 3 | 单品立减 | `dishDiscountValue > 0` |

新增字段建议：

| 表 | 字段 | 类型建议 | 说明 |
|---|---|---|---|
| `crm_coupon` | `dish_discount_type` | varchar 或 tinyint，按项目枚举映射习惯确定 | 单品优惠方式 |
| `crm_coupon` | `dish_discount_value` | decimal(19,2) | 折扣值或立减金额 |
| `crm_coupon_order` | `dish_discount_type` | 同模板字段 | 领取时快照 |
| `crm_coupon_order` | `dish_discount_value` | decimal(19,2) | 领取时快照 |

必须在 `crm_coupon_order` 保存快照。原因是客人领取后，商家可能修改券模板。如果只读取 `crm_coupon`，已领取券的优惠金额会随模板变化，影响用户权益、核销口径和财务对账。

### 3.2 API 契约

新增字段建议进入以下 DTO/VO：

| 类型 | 是否需要 | 说明 |
|---|---|---|
| `CrmCouponAddDTO` | 必须 | 新增券时配置单品优惠方式 |
| `CrmCouponUpdateDTO` | 必须 | 修改券时配置单品优惠方式 |
| `CrmCouponVO` | 必须 | 后台和外部系统展示模板规则 |
| `CrmCouponOrderVO` | 必须 | 顾客/POS 展示已领取券规则和快照 |
| `CrmCouponOrderAddDTO` | 建议 | 管理端手工发券或导入时可写快照 |
| `CrmCouponOrderUpdateDTO` | 建议 | 保持实体字段可维护，但业务上不建议随意改已领取券权益 |
| `CrmCouponQueryDTO` | 非必须 | 仅当后台需要按优惠方式筛选时再增加 |

第一版不建议把筛选能力做大。核心目标是支持配置、展示、领取快照和核销计算。

### 3.3 计算规则

`CheckCouponOrderVO.amount` 继续表示“优惠金额”，不表示“券后价”。这是兼容现有调用方的关键点。

假设命中的一份菜品单价为 `dishPrice`：

| 优惠方式 | 计算公式 | 示例 |
|---|---|---|
| `FREE` | `amount = dishPrice` | 28 元菜品，优惠 28 元 |
| `DISCOUNT` | `amount = dishPrice * (10 - dishDiscountValue) / 10` | 28 元菜品 5 折，优惠 14 元 |
| `AMOUNT_OFF` | `amount = min(dishDiscountValue, dishPrice)` | 28 元菜品减 5 元，优惠 5 元 |

折扣录入口径使用“几折”：

- 5 折存 `5.00`。
- 8 折存 `8.00`。
- 不使用 `0.5` 或 `50`，避免运营和后端理解不一致。

金额边界：

- 立减金额不能超过菜品实际应收单价，超过时按菜品单价抵扣。
- 折扣金额不能小于 0。
- `DISCOUNT = 10` 等价于不优惠，建议保存时不允许，避免无意义券。
- `DISCOUNT = 0` 等价于免费，应使用 `FREE`，不建议允许。

### 3.4 保存校验

当 `couponType = SWQ`：

1. `dishList` 仍必须至少有一个有效菜品绑定。
2. `dishDiscountType` 为空时默认 `FREE`，兼容历史实物券。
3. `FREE`：清空或忽略 `dishDiscountValue`。
4. `DISCOUNT`：`dishDiscountValue` 必须大于 0 且小于 10。
5. `AMOUNT_OFF`：`dishDiscountValue` 必须大于 0。
6. 保留现有“同一门店只能绑定一个菜品”的规则。

当 `couponType != SWQ`：

- 不允许保留 `dishDiscountType / dishDiscountValue`。
- 建议在 Convert 或 Service 保存前清空为 `null`，避免和现金券、比例券、红包券语义混用。

### 3.5 领取快照

发券生成 `crm_coupon_order` 时，应从模板复制以下字段：

- `couponType/type_`
- `couponMode`
- `faceValue` 等已有快照字段
- `dishDiscountType`
- `dishDiscountValue`

核销和可用券列表优先使用 `crm_coupon_order` 上的快照字段。如果历史券实例没有快照字段，则回退到 `FREE`。

### 3.6 与现有券类型的边界

不要把“指定菜品减 5 元”建模为 `XJQ` 现金券。

原因：

- `XJQ` 是金额券，天然偏整单或限抵商品集合。
- `SWQ` 已经天然绑定门店菜品和单位。
- 单品立减必须只作用一份指定菜品，不能变成整单抵扣。

不要把“指定菜品 5 折”建模为现有 `DISCOUNT` 类型。

原因：

- 当前 `DISCOUNT` 在 `CheckCouponUtil` 中没有完整单品菜品匹配逻辑。
- `DISCOUNT` 名称更像整单折扣券或历史预留券型。
- 若复用 `DISCOUNT`，需要额外补齐菜品绑定、单位校验、门店绑定，反而扩大改动范围。

## 4. 方案对比

| 方案 | 优点 | 缺点 | 结论 |
|---|---|---|---|
| 扩展 `SWQ` 优惠方式 | 最小改动，复用菜品绑定和核销链路，历史券可兼容 | `SWQ` 名称仍叫实物券，需要文档说明其扩展语义 | 推荐 |
| 新增 `SINGLE_ITEM` 券类型 | 语义最干净 | 枚举、前端、接口、查询、核销入口都要扩展，历史链路复用成本高 | 暂不推荐 |
| 复用 `XJQ/DISCOUNT` | 表面字段少 | 会混淆整单券和单品券，容易造成错误抵扣 | 不推荐 |

## 5. 数据兼容与迁移

历史数据不需要批量迁移。

兼容策略：

```text
couponType = SWQ 且 dish_discount_type 为空 => FREE
couponType = SWQ 且 dish_discount_value 为空且 dish_discount_type = FREE => 合法
couponType = SWQ 且 dish_discount_type = DISCOUNT/AMOUNT_OFF => 按新规则计算
```

数据库字段新增后，历史 `crm_coupon` 和 `crm_coupon_order` 的新字段为空即可。业务逻辑负责默认解释为 `FREE`。

## 6. 测试场景

必须覆盖：

1. 历史 `SWQ` 无新字段，命中 28 元菜品，优惠金额仍为 28 元。
2. `SWQ + DISCOUNT = 5`，命中 28 元菜品，优惠金额为 14 元。
3. `SWQ + DISCOUNT = 8`，命中 28 元菜品，优惠金额为 5.60 元。
4. `SWQ + AMOUNT_OFF = 5`，命中 28 元菜品，优惠金额为 5 元。
5. `SWQ + AMOUNT_OFF = 5`，命中 3 元菜品，优惠金额为 3 元。
6. 当前订单没有绑定菜品，券不可用。
7. 当前订单菜品单位和券配置单位不一致，券不可用。
8. 当前门店没有配置该券菜品，券不可用。
9. 已领取券后修改模板优惠方式或金额，已领取券仍按实例快照计算。
10. 非 `SWQ` 券传入单品优惠字段，保存后字段为空或校验失败，不能污染其他券型。

## 7. 实施边界

第一版建议只做 CRM 后端模型和计算规则：

- 数据库字段。
- 枚举和 DTO/VO 字段。
- 保存校验。
- 领取快照。
- `CheckCouponUtil` 的 `SWQ` 金额计算。
- 聚焦单元测试或服务层测试。

后台页面、顾客端页面、POS 展示文案可以后续再接入，但接口字段应一次设计稳定。

## 8. 最终建议

本设计没有发现不可行问题。推荐按“扩展 `SWQ` 优惠方式”的方案实施：

```text
SWQ = 单品/菜品券主类型
crm_coupon_dish = 指定门店菜品绑定
DishDiscountTypeEnum = FREE / DISCOUNT / AMOUNT_OFF
crm_coupon_order = 已领取券权益快照
CheckCouponUtil.amount = 本次优惠金额
```

这能在保留旧实物券免费兑换能力的同时，支持“指定菜品 5 折”和“指定菜品减 5 元”，并且不会把单品优惠误做成整单优惠。
