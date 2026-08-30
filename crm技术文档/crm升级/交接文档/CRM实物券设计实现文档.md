# CRM 实物券设计实现文档

日期：2026-08-29
作者：guoyun_liu
状态：已实现

## 1. 概述

### 1.1 什么是实物券

实物券（`CouponTypeEnum.SWQ`，code=3）是 CRM 优惠券体系中的一种券类型，语义为"实物兑换券/菜品兑换券"——持券人可在指定门店兑换特定菜品。

实物券与现金券、比例券、折扣券的本质区别：

| 券类型 | 枚举 | 核销方式 | 典型场景 |
|--------|------|----------|---------|
| 现金券（XJQ） | code=1 | 订单金额抵扣 | 满100减20 |
| 比例券（BLJ） | code=2 | 按比例折扣 | 8折券 |
| **实物券（SWQ）** | **code=3** | **兑换菜品** | **免费领一份小菜** |
| 折扣券（DISCOUNT） | code=4 | 全单折扣 | 75折 |

实物券的"单品优惠方式"（`dishDiscountType`）决定了兑换菜品的优惠形式：

| 优惠方式 | 枚举值 | 含义 | 示例 |
|---------|--------|------|------|
| 免费兑换 | `FREE=1` | 券面值为0，菜品完全免费 | "免费兑换价值28元小菜一份" |
| 单品折扣 | `DISCOUNT=2` | 菜品按折扣价核销 | "小菜享受5折优惠" |
| 单品立减 | `AMOUNT_OFF=3` | 菜品减免固定金额 | "小菜立减15元" |

### 1.2 概念澄清

业务层面需要区分两个概念：

| 概念 | 业务含义 | 当前代码实现 |
|------|---------|-----------|
| 单品券 | 指定某一个菜品，只能兑换这个菜品 | 当前 SWQ 的默认行为 |
| 实物券 | 可兑换实物类商品，通常可配置多个可兑换菜品候选 | 当前每门店只允许绑定一个菜品 |

> ⚠️ 当前实现中，同一个门店只允许配置一个绑定菜品（同门店 `findAny()` 取第一条），如果业务需要"同门店多个可兑换菜品候选"，需要调整保存校验和核销匹配逻辑。

## 2. 核心数据模型

### 2.1 实体关系图

```
crm_coupon (券模板)
    │
    ├── crm_coupon_dish (菜品绑定)  ← 一对多，按 sid 隔离
    │       │
    │       └── dish_unit_lid (菜品单位选项ID，稳定键)
    │
    └── crm_coupon_order (券领取/核销记录)
            │
            └── order_bill_id (关联消费单，用于撤销)
```

### 2.2 `crm_coupon`（券模板主表）

实物券模板由 `crm_coupon` 表承载，核心字段：

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `lid` | BIGINT | 业务逻辑主键（雪花算法） |
| `name` | VARCHAR | 券名称 |
| `coupon_type` | ENUM | **券类型**：XJQ-现金券，BLJ-比例券，**SWQ-实物券**，DISCOUNT-折扣券 |
| `status_` | INT | 模板状态 |
| **实物券专属字段** | | |
| `dish_discount_type` | ENUM | **单品优惠方式**：FREE(免费)/DISCOUNT(折扣)/AMOUNT_OFF(立减) |
| `dish_discount_value` | DECIMAL | 优惠值：折扣时为折扣率，立减时为立减金额 |
| `dish_shop_id` | BIGINT | 菜品所属门店（绑定菜品时填入） |
| `dish_name` | VARCHAR | 菜品名称（快照） |
| `dish_code` | VARCHAR | 菜品 LID（快照） |
| `dish_unit` | VARCHAR | 菜品单位名称（展示用，见稳定ID设计） |
| **通用字段** | | |
| `is_all_store` | BOOLEAN | 是否全门店适用 |
| `is_pkg` | BOOLEAN | 是否为券包 |
| `enable_direct_take` | BOOLEAN | 是否支持直接领取 |
| `is_enable_purchase` | BOOLEAN | 是否支持购买 |
| `purchase_price` | DECIMAL | 购买价格 |
| `receiving_limit_number` | INT | 总限领数量（0=不限） |
| `every_day_limit_number` | INT | 每日限领数量（0=不限） |
| `received_number` | INT | 已发放数量 |
| `begin_reception_time` | DATETIME | 领取开始时间 |
| `end_reception_time` | DATETIME | 领取结束时间 |
| `begin_use_time` | DATETIME | 使用开始时间 |
| `end_use_time` | DATETIME | 使用结束时间 |
| `limit_use_day` | INT | 领取后多少天内有效（相对有效期） |
| `fixed_begin_date` | DATE | 固定有效期起 |
| `fixed_end_date` | DATE | 固定有效期止 |
| `moday/tuesday/.../sunday` | BOOLEAN | 星期可用限制 |
| `start_time_slot` | TIME | 可用时段起 |
| `end_time_slot` | TIME | 可用时段止 |

### 2.3 `crm_coupon_dish`（实物券菜品绑定表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | **门店 ID**（按门店绑定，同门店唯一） |
| `lid` | BIGINT | 逻辑编号（雪花算法） |
| `coupon_lid` | BIGINT | 所属券模板 LID（FK） |
| `dish_lid` | BIGINT | 菜品 LID |
| `dish_name` | VARCHAR | 菜品名称（快照） |
| `dish_unit` | VARCHAR | 菜品单位名称（展示用，可能因改名失效） |
| `dish_unit_lid` | BIGINT | **菜品单位选项 ID**（稳定匹配键） |
| `shop_name` | VARCHAR | 门店名称（快照） |
| `deleted` | SHORT | 逻辑删除 |

> **稳定ID设计**：`dish_unit_lid` 用于解决单位改名导致核销失败的问题。
> - 默认单位：`dishUnitLid = 菜品 lid`
> - 多单位：`dishUnitLid = pt_dish_unit.lid`
> - 新券：优先按 `dishUnitLid` 匹配
> - 旧券（无 `dishUnitLid`）：回退按 `dishUnit` 名称匹配

索引：
```sql
INDEX idx_coupon_lid (coupon_lid)
INDEX idx_sid (sid)
```

### 2.4 `crm_coupon_order`（券领取/核销记录表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | 门店 ID |
| `lid` | BIGINT | 逻辑编号（雪花算法） |
| `id` | VARCHAR | 券实例编号（对外展示） |
| `name` | VARCHAR | 券实例名称 |
| `coupon` | VARCHAR | 券模板名称（快照） |
| `coupon_code` | VARCHAR | 券模板 LID（快照） |
| `type` | ENUM | 券类型 |
| `coupon_status` | ENUM | **券状态**：WHX-未核销，YHX-已核销，YGQ-已过期，YZF-已作废，WSX-未生效 |
| `coupon_mode` | ENUM | **券模式**：CP-优惠券，RE-红包 |
| `member_code` | VARCHAR | 会员 LID（快照） |
| `member_id_alias` | VARCHAR | 会员卡号 |
| `member` | VARCHAR | 会员名称 |
| `get_date` | DATETIME | 领取时间 |
| `deadline` | DATETIME | 有效期截止 |
| `get_channel` | ENUM | **获取渠道**：SelfTake-自领，Purchase-购买，Recharge-充值赠送，Grant-后台发放，Exchange-积分兑换，ConsumeGive-消费赠送，ActivityGive-商家活动赠送 |
| `used_time` | DATETIME | 使用时间（核销时间） |
| `write_off_time` | DATETIME | 核销时间 |
| `write_off_staff` | VARCHAR | 核销员 |
| `order_bill_id` | VARCHAR | 关联消费单号（幂等撤销键） |
| **实物券专属字段** | | |
| `dish_discount_type` | ENUM | **单品优惠方式** |
| `dish_discount_value` | DECIMAL | 优惠值 |
| `bill_amount` | DECIMAL | 消费单金额 |
| `used_shop` | VARCHAR | 使用门店 |
| `used_shop_code` | VARCHAR | 使用门店编号 |

## 3. 枚举建模

### 3.1 券类型（`CouponTypeEnum`）

| code | 枚举值 | 描述 |
|------|--------|------|
| 1 | XJQ | 现金券 |
| 2 | BLJ | 比例券 |
| 3 | SWQ | **实物券** |
| 4 | DISCOUNT | 折扣券 |

### 3.2 券状态（`CouponStatusEnum`）

| code | 枚举值 | 描述 |
|------|--------|------|
| 1 | WHX | 未核销 |
| 2 | YHX | 已核销 |
| 3 | YGQ | 已过期 |
| 4 | YZF | **已作废** |
| 5 | WSX | 未生效 |
| 6 | YSX | 已生效 |
| 7 | KGQ | 即将过期 |
| 8 | LSQ | 历史券 |

### 3.3 券获取渠道（`CouponChannelEnum`）

| code | 枚举值 | 描述 |
|------|--------|------|
| 1 | SelfTake | 自领 |
| 2 | Purchase | 购买获取 |
| 3 | Recharge | 充值赠送 |
| 4 | Grant | 后台发放 |
| 5 | Exchange | 积分兑换 |
| 6 | ConsumeGive | 消费赠送 |
| 7 | Turntable | 大转盘奖励 |
| 8 | NewGift | 新人礼包 |
| 9 | BirthdayGift | 生日赠送 |
| 10 | UpgLevelGive | 购买会员等级赠送 |
| 11 | ActivityGive | 商家活动赠送 |
| 12 | PurchaseCardGive | 购卡送券 |

### 3.4 实物券单品优惠方式（`DishDiscountTypeEnum`）

| code | 枚举值 | 描述 | 优惠值语义 |
|------|--------|------|-----------|
| 1 | FREE | 免费兑换 | 券面值为0，菜品完全免费 |
| 2 | DISCOUNT | 单品折扣 | 值为折扣率，如5表示5折 |
| 3 | AMOUNT_OFF | 单品立减 | 值为立减金额，如15表示减15元 |

## 4. 后台管理页面

### 4.1 管理页面入口

| 功能 | 前端路径 | 说明 |
|------|---------|------|
| 优惠券管理 | CRM 优惠券列表页 | 管理所有券类型（含实物券） |
| 券模板配置 | `CrmCouponController` 管理 | 新增/编辑/审核/停用 |
| 菜品绑定 | 券模板编辑页内嵌 | 为实物券配置可兑换菜品 |

### 4.2 后台管理接口

入口 Controller：`CrmCouponController`（路径 `/crm_coupon`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/crm_coupon/get` | POST | `crm:coupon:list` | 获取券模板详情（含菜品绑定列表） |
| `/crm_coupon/list` | POST | 登录后可见 | 分页查询券模板列表 |
| `/crm_coupon/list_valid` | POST | `crm:coupon:list` | 查询有效的券模板（审核通过且未停用） |
| `/crm_coupon/add` | POST | `crm:coupon:add` 或 `crm:coupon:red:add` | 新增券模板（含菜品绑定 `dishList`） |
| `/crm_coupon/update` | POST | `crm:coupon:update` 或 `crm:coupon:edit` | 修改券模板（含菜品绑定） |
| `/crm_coupon/state` | POST | `crm:coupon:state` 或 `crm:coupon:red:enable` | 停用/启用券模板 |
| `/crm_coupon/review` | POST | `crm:coupon:review` 或 `crm:coupon:red:review` | 审核券模板 |
| `/crm_coupon/del` | POST | `crm:coupon:del` 或 `crm:coupon:red:del` | 删除券模板 |
| `/crm_coupon/export` | POST | `crm:coupon:export` | 导出券模板列表 |

### 4.3 实物券菜品绑定配置

菜品绑定通过 `CrmCouponDishAddDTO` 在新增/编辑券模板时一起提交：

| DTO 字段 | 类型 | 含义 |
|---------|------|------|
| `sid` | Long | 门店 ID |
| `dishLid` | Long | 菜品 LID |
| `dishUnit` | String | 菜品单位名称（展示用） |
| `dishUnitLid` | Long | **菜品单位选项 ID**（稳定键） |

> ⚠️ **同门店唯一限制**：当前代码用 `Set<Long> sids` 限制同一个门店只能绑定一个菜品。如果需要同门店多个可兑换菜品候选，需调整 `addCouponDish()` 的校验逻辑和核销匹配逻辑。

### 4.4 菜品绑定保存流程

新增/编辑券模板时，`CrmCouponServicePlus` 调用 `addCouponDish()`：

```
1. 非 SWQ 券直接忽略 dishList
2. 清空券模板主表旧菜品字段（dishUnit、dishShopId、dishName、dishCode）
3. 遍历请求中的 dishList
4. 校验：菜品必须存在、门店存在、单位存在
5. 按 sid 查重：同门店只能绑定一个菜品（Set<Long> sids 限制）
6. 生成 CrmCouponDish 记录
7. 修改场景先删除旧 crm_coupon_dish 记录
8. 批量保存新的 crm_coupon_dish 记录
```

菜品存在性校验调用商品服务：
```java
ptDishFeign.getPtDish(mid, sid, dishCode)
```

## 5. 核销链路

### 5.1 核销校验入口

核销校验统一入口：`CheckCouponUtil.check()`

当券类型为 `SWQ` 时，进入实物券专属分支：

```
1. 从 orderVO.getDishList() 获取绑定菜品列表
2. 如果列表为空 → 报错"该菜品券没有设置菜品"
3. 按当前门店 sid 过滤 → 找不到绑定菜品 → 报错"菜品券所绑定的菜品不属于该门店"
4. 按 dishUnitLid（稳定ID）优先匹配，其次按 dishUnit（名称）回退
5. 写入 orderVO 的 dishCode、dishName、dishUnit、dishShopId
6. 按菜品价格计算抵扣金额（FREE=0, DISCOUNT=折扣价, AMOUNT_OFF=立减值）
```

**与限抵商品（`crm_consume_coupon_food`）的区别**：

| 逻辑 | 表 | 适用场景 | 核销含义 |
|------|------|---------|---------|
| 实物券菜品绑定 | `crm_coupon_dish` | `SWQ` 实物券 | 兑换命中的菜品 |
| 优惠券限抵商品 | `crm_consume_coupon_food` | 现金券、比例券等 | 限定哪些商品金额可参与抵扣 |

> ⚠️ `SWQ` 分支会提前 `return`，不会继续走 `checkLimitFood()` 限抵商品逻辑。

### 5.2 核销时的单位匹配优先级

```
if (couponDish.dishUnitLid != null && food.foodUnitLid != null):
    优先按 dishUnitLid == foodUnitLid 匹配
else:
    回退按 dishUnit == food.unit 匹配（名称匹配）
```

## 6. 多渠道核销场景

### 6.1 POS 核销（本地券）

POS 实物券核销通过 `DwdBillOpsForBizController.addCoupons()` 入口：

```
POS 扫券/录入券码
  → /dwd_bill_ops/addCoupons
    → DwdBillOpsServiceImpl.addCoupons()
      → POS 本地 DwdCoupon 查券记录
      → NmsCouponHandler.writeOff()
        → CRM writeOffCouponInner()
```

### 6.2 小程序点餐核销（购物车预核销）

小程序商品券按"用券点菜"设计，核销链路分为两阶段：

**阶段1：预核销（点餐页）**
```
用户打开商品券面板
  → POST /shopping_cart/get_available_product_coupon  查询可用券
    ← 返回 SWQ 实物券列表（含菜品绑定）
用户选择券
  → POST /shopping_cart/pre_write_off_coupon  预核销
    → 校验券状态、类型、绑定菜品、单位
    → 写入购物车 Redis 草稿（preWriteOff=true 的券菜品行）
  → 刷新购物车展示预核销菜品
```

**阶段2：正式核销（下单时）**
```
用户点击下单
  → POST /order_bill/crt_order
    → 遍历 preWriteOff=true 的菜品
    → CRM writeOffCouponInner(orderId=真实订单saasOrderKey)
    → 更新 crm_coupon_order.coupon_status = YHX
    → 订单核销快照写入 OrderFood.coupon_no
```

### 6.3 平台券（美团/抖音）核销

| 来源 | 类型前缀 | 识别规则 |
|------|---------|---------|
| 会员实物券 | WP | 默认识别 |
| 美团商品券 | MP | 券码 9-14 位 |
| 抖音商品券 | DP | 券码以 http 开头 或 15-18 位 |

平台券不走 CRM 实物券链路，而是调用各平台 SDK 的 `prepare` → `verify` 接口。

## 7. 撤销与作废

### 7.1 撤销（退单/反结账）

撤销入口：`CrmCouponOpServicePlus.couponOpRevoke()`

```java
// 按 couponCode + orderBillId + 会员手机/unionid 精确命中
UPDATE crm_coupon_order
SET coupon_status = 'YZF',
    abandon_staff = ?,
    abandon_time = NOW()
WHERE mid = ? AND unionid = ? AND coupon_code IN (...)
  AND order_bill_id = ?
  AND coupon_status IN ('WHX', 'YGQ')  -- 只作废未核销和已过期
```

### 7.2 券包展开

如果传入的是券包 LID，撤销时会先展开为子券 code，再按子券精确撤销：

```java
// 查询券包关联的子券
List<CrmCouponMap> = SELECT deputy_code FROM crm_coupon_map
    WHERE main_code = ? AND status = 1
// 合并子券 code 到撤销列表
```

### 7.3 券状态流转图

```
┌───────┐   后台发放/领券   ┌───────┐
│ 未生效 │ ────────────────→ │ 未核销 │
└───────┘                  └───────┘
     │                           │
     │ 核销                    │ 过期时间到达
     ↓                          ↓
┌───────┐                  ┌───────┐
│ 已核销 │ ←─────────────── │ 已过期 │
└───────┘   撤销退单         └───────┘
     ↑                           │
     │                           │
     │ 撤销作废                  │
     └───────────────────────────┘
                     ┌───────┐
                     │ 已作废 │
                     └───────┘
```

## 8. 稳定ID设计（dishUnitLid）

### 8.1 问题背景

实物券菜品绑定时保存了菜品单位名称（`dishUnit`），如"份"、"盒"、"斤"。但单位名称可能因商户修改而变化：

- 商户改名：如"份"改成"例"
- 多单位调整：如"盒"改成"小盒"
- 历史券保存旧名称，POS 同步后名称不匹配

这导致 POS 加载或核销实物券时按旧名称找不到匹配项。

### 8.2 解决方案

新增 `dish_unit_lid`（菜品单位选项 ID）作为稳定匹配键：

| 单位类型 | `dishUnitLid` 来源 | 说明 |
|---------|---------------------|------|
| 默认单位 | 菜品 `lid` | 默认单位没有独立记录，用菜品 LID 表示 |
| 多单位 | `pt_dish_unit.lid` | 多单位有独立记录，使用单位记录 LID |

保留 `dishUnit` 用于展示和兼容：

- `dishUnit`：单位名称，用于展示、旧数据兼容、日志排查
- `dishUnitLid`：稳定 ID，用于跨系统长期匹配

### 8.3 匹配优先级

```
新券（有 dishUnitLid）:
  1. 按 dishUnitLid == foodUnitLid 匹配
  2. 命中则核销通过

旧券（无 dishUnitLid）:
  1. 按 dishUnit == food.unit 匹配（回退名称匹配）
```

### 8.4 兼容性矩阵

| 场景 | 行为 |
|------|------|
| 历史券没有 `dishUnitLid` | 继续按 `dishUnit` 名称匹配 |
| POS 未升级 | 仍使用 `dishUnit` 名称，行为不变 |
| POS 已升级但 CRM 未返回 ID | 回退名称匹配 |
| CRM 与 POS 都升级 | 优先按稳定 ID 匹配 |

## 9. 代码文件清单

| 文件 | 职责 |
|------|------|
| `CrmCouponController.java` | 券模板 CRUD 管理接口（`/crm_coupon`） |
| `CrmCouponServicePlus.java` | 券模板管理业务逻辑（含 `addCouponDish`） |
| `CrmCouponDishServicePlus.java` | 菜品绑定管理业务逻辑 |
| `CrmCouponOpServicePlus.java` | 券发放（`couponOpAdd`）和撤销（`couponOpRevoke`） |
| `CheckCouponUtil.java` | 核销校验入口，含实物券专属分支 |
| `CrmCoupon.java` | 券模板实体 |
| `CrmCouponDish.java` | 菜品绑定实体 |
| `CrmCouponOrder.java` | 券领取/核销记录实体 |
| `CouponTypeEnum.java` | 券类型枚举（SWQ=3） |
| `DishDiscountTypeEnum.java` | 实物券优惠方式枚举 |
| `CouponStatusEnum.java` | 券状态枚举 |
| `CouponChannelEnum.java` | 券获取渠道枚举 |
| `CrmCouponDishAddDTO.java` | 菜品绑定新增 DTO（含 `dishUnitLid`） |
| `CrmCouponDishVO.java` | 菜品绑定返回 VO（含 `dishUnitLid`） |

## 10. 表结构速查

### `crm_coupon`

```sql
crm_coupon (
  pid, mid, sid, lid, name,
  coupon_type,           -- SWQ=3 实物券
  dish_discount_type,    -- FREE/DISCOUNT/AMOUNT_OFF
  dish_discount_value,   -- 优惠值
  dish_shop_id, dish_name, dish_code, dish_unit,  -- 快照字段
  is_all_store, status_,
  receiving_limit_number, every_day_limit_number,
  begin_reception_time, end_reception_time,
  begin_use_time, end_use_time,
  moday/tuesday/.../sunday, start_time_slot, end_time_slot,
  ...
)
```

### `crm_coupon_dish`

```sql
crm_coupon_dish (
  pid, mid, sid, lid,
  coupon_lid,            -- FK → crm_coupon.lid
  dish_lid, dish_name, dish_unit, dish_unit_lid,  -- 稳定ID
  shop_name,
  deleted
)
```

### `crm_coupon_order`

```sql
crm_coupon_order (
  pid, mid, sid, lid, id, name,
  coupon, coupon_code,   -- 快照
  type,                  -- 券类型
  coupon_status,         -- WHX/YHX/YGQ/YZF
  member_code, member_id_alias, member,
  get_date, deadline,
  get_channel,           -- SelfTake/Purchase/Recharge/Grant/...
  order_bill_id,        -- 关联消费单
  used_time, write_off_time, write_off_staff,
  dish_discount_type, dish_discount_value, bill_amount,
  ...
)
```
