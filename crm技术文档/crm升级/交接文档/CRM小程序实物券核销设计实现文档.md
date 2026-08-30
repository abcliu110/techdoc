# CRM 小程序实物券核销设计实现文档

日期：2026-08-29
作者：guoyun_liu
状态：已实现

## 1. 背景与目标

小程序点餐流程中，用户在点餐页操作的是购物车草稿，正式订单 ID 在点击"现在下单"后才生成。客户要求单品券在点餐页就可以使用，但点餐页没有正式订单 ID，因此本设计将点餐阶段的券使用定义为"预核销"，正式核销由下单接口统一处理。

本设计目标：**小程序商品券按"用券点菜"设计，核销链路分两阶段——点餐页预核销（写入购物车 Redis 草稿）、下单时正式核销（调用 CRM 或平台 SDK）。现金券仍在支付页作为付款方式处理，商品券不能作为支付页 COUPON 付款项二次扣减。**

## 2. 核心架构

```
┌─────────────────────────────────────────────────────────────────┐
│                     小程序点餐页                                  │
│  ① 打开商品券面板  →  POST /shopping_cart/get_available_product_coupon │
│  ② 选择会员券 WP  →  POST /shopping_cart/pre_write_off_coupon     │
│  ③ 扫码平台券     →  同上（MP/DP）                              │
│  ④ 下单           →  POST /order_bill/crt_order                  │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                    云端订单服务（nms4cloud-order）                   │
│  ShoppingCartController / CrtPostOrderServiceImpl                │
│  CartProductCouponService → 预核销写入 Redis 草稿                  │
│  CrmCouponOpServicePlus → 正式核销（WP 调用 CRM）                 │
│  微信服务 SDK        → 正式核销（MP/DP 调用平台 prepare+verify）   │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│              CRM / 平台（美团/抖音）                               │
│  CRM mutGetCoupon / writeOffCouponInner → SWQ 实物券核销           │
│  微信服务团购券 prepare+verify → 平台商品券核销                  │
└─────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│              POS 端（DO_ORDER MQTT 消息）                          │
│  DoOrderHandler → DwdBillServicePlus.toOrder()                   │
│  沉淀 DwdCoupon（平台 MP/DP 凭证：certificateId/writeOffId/...）   │
│  撤销时复用 MtCouponHandler / DyCouponHandler                    │
└─────────────────────────────────────────────────────────────────┘
```

## 3. 券类型边界

| 类型 | 枚举 | 含义 | 小程序处理 |
|------|------|------|-----------|
| 会员商品券 | WP | CRM 实物券（SWQ） | 点餐页预核销，生成购物车券菜品行；下单时正式核销 |
| 美团商品券 | MP | 平台商品券（美团/餐道） | 点餐页预核销，生成购物车券菜品行；下单时正式核销 |
| 抖音商品券 | DP | 平台商品券（抖音） | 点餐页预核销，生成购物车券菜品行；下单时正式核销 |
| 会员现金券 | WV | CRM 现金券 | 支付页付款方式模型 |
| 美团现金券 | MV | 平台现金券 | 支付页付款方式模型 |
| 抖音现金券 | DV | 平台现金券 | 支付页付款方式模型 |

> ⚠️ 购物车预核销和订单商品券接口只接受 WP/MP/DP 作为点餐商品券类型。识别为 WV/MV/DV 时不能生成券菜品行。

## 4. 核销链路详解

### 4.1 阶段一：预核销（点餐页）

**会员商品券 WP 预核销**：

```
1. 查询 foodId 对应菜品和 unitId 对应单位
2. 调 CRM mutGetCoupon 查询 couponNo 对应券实例
3. 校验：券存在、type==SWQ、couponStatus==WHX
4. 校验：券绑定菜品 dishCode == 请求 foodId
5. 校验：券绑定 dishUnit 与菜品单位名称一致（dishUnitLid 优先匹配）
6. 按优惠类型计算优惠金额：
   - FREE 或空 → 优惠金额 = 菜品单价
   - DISCOUNT  → 优惠金额 = 原价 × (10 - dishDiscountValue) / 10
   - AMOUNT_OFF → 优惠金额 = dishDiscountValue（最高不超过菜品价格）
7. 构造 OrderFoodVO，标记 preWriteOff=true
8. 写入购物车 Redis 草稿
```

**平台商品券 MP/DP 预核销**：

```
1. 按券类型选择平台：MP → CAN_DAO，DP → DOU_YIN
2. 调用微信服务团购券 prepare
3. 解析返回值：verifyToken、encryptedCode、channel、skuId、title、couponName、originalAmount、grouponType
4. 校验 grouponType != 2（grouponType==2 为现金券，不能在点餐页核销）
5. 调用商品服务按 PtDish.extNames 自动匹配本地菜品（匹配规则见 4.3）
6. 取 foodId=PtDish.lid，unitId=-1，查询菜品和默认单位
7. 优惠金额以平台 prepare 返回 originalAmount 为准
8. 构造 OrderFoodVO，标记 preWriteOff=true
9. 写入购物车 Redis 草稿
```

### 4.2 阶段二：正式核销（下单时）

```
CrtPostOrderServiceImpl 在保存订单、菜品后遍历 foodList 中 preWriteOff=true 的菜品：

WP（会员实物券）：
  → CRM writeOffCouponInner(orderId=真实订单saasOrderKey)
  → 更新 crm_coupon_order.coupon_status = YHX

MP/DP（平台商品券）：
  → 微信服务团购券 verify（使用预核销保存的 verifyToken/encryptedCode/channel/platformPrice）
  → 解析平台返回的 verifyId、verifyResults
  → 回写 order_food.platform_certificate_id / platform_write_off_id 等字段
```

任一券核销失败 → 抛出 BizException，下单整体失败，用户需重新处理商品券。

### 4.3 平台 SKU 自动匹配规则

平台商品券扫码后，后端按 `PtDish.extNames` 自动匹配本地菜品，必须与 POS 端一致：

| 优先级 | 匹配条件 | 说明 |
|--------|---------|------|
| 1 | `extNames[].id == sku_id` | 平台 SKU 或外部商品 ID 与本地菜品绑定 |
| 2 | `extNames[].name == sku_id` | 兼容部分历史数据把平台 SKU 写入名称字段 |
| 3 | `extNames[].name == title/coupon_name` | 平台商品名或券商品名匹配 |
| 4 | `PtDish.name == title/coupon_name` | 最后使用菜品名称匹配平台商品名 |

候选查询和命中行为：
1. 先按 `mid/sid` 查询候选菜品
2. 候选条件为 `PtDish.extNames` 非空，且 extNames 包含 sku_id 或 title 或 coupon_name
3. 遍历候选菜品，解析 extNames JSON 数组
4. 按优先级逐条匹配，命中后返回首个匹配菜品

> ⚠️ 不使用 `takeout_food_map` 作为主路径——该表是外卖商品映射，可能缺失数据且缺少 channelType 维度。

## 5. 接口设计

### 5.1 查询可用商品券

```
POST /shopping_cart/get_available_product_coupon
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `phone` | String | 否 | 会员手机号；不传时取登录用户手机号 |
| `mid` | Long | ✅ | 商户编号 |
| `sid` | Long | ✅ | 门店编号 |
| `tblId` | String | ✅ | 桌台编号 |
| `cardLid` | Long | 否 | 会员卡 LID |

返回 CRM SWQ 实物券列表。预核销时使用字段：

| 字段 | 说明 |
|------|------|
| `lid` | 券领取记录 LID；预核销时作为 couponNo |
| `name` | 券实例名称（展示用） |
| `type` | 券类型；只返回 SWQ |
| `couponStatus` | 券状态；预核销要求 WHX |
| `dishCode` | 绑定菜品 LID |
| `dishUnit` | 绑定菜品单位名称 |
| `dishDiscountType` | 优惠方式：FREE/DISCOUNT/AMOUNT_OFF |
| `dishDiscountValue` | 优惠值 |
| `deadline` | 有效期截止（展示用） |

### 5.2 预核销商品券

```
POST /shopping_cart/pre_write_off_coupon
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `couponBusinessType` | Enum | ✅ | WP-会员商品券，MP-美团/餐道，DP-抖音 |
| `couponNo` | Long | WP ✅ | 会员券 LID；从可用券列表获取 |
| `couponCode` | String | MP/DP ✅ | 平台券扫码原始券码 |
| `foodId` | Long | WP ✅ | 券绑定菜品 LID |
| `unitId` | Long | WP ✅ | 券绑定菜品单位 LID；MP/DP 可不传 |
| `mid` | Long | ✅ | 商户编号 |
| `sid` | Long | ✅ | 门店编号 |
| `tblId` | String | ✅ | 桌台编号 |

返回最新 `ShoppingCartVO`。预核销券菜品行关键字段：

| 字段 | 说明 |
|------|------|
| `lid` | 购物车菜品行编号（后端新生成） |
| `foodNo` | 菜品编号 |
| `foodName` | 菜品名称 |
| `foodUnit` | 菜品单位 |
| `foodNumber` | 数量（MP/DP 取平台 certificate.count） |
| `foodOrgPrice` | 菜品原价 |
| `promotionAmount` | 商品券优惠金额 |
| `preWriteOff` | 固定 `true`；下单时识别待正式核销券菜品 |
| `preWriteOffBusinessType` | WP/MP/DP；正式核销分支依据 |
| `couponNo` | WP 有值；平台券为空 |
| `couponWriteOffTraceNo` | 预核销追踪号（雪花 ID） |
| `encryptedCode` | MP/DP 有值；平台 prepare 返回 |
| `verifyToken` | MP/DP 有值；平台 prepare 返回 |
| `platformPrice` | MP/DP 有值；平台 prepare 返回 |
| `writeOffChannel` | MP/DP 有值；平台 prepare 返回 |
| `originalCouponCode` | MP/DP 有值；扫码原始券码 |

### 5.3 查询购物车（含失效清理）

```
POST /shopping_cart/get
```

返回购物车前，后端调用 `validateAndRemoveExpiredPreWriteOff`：
- 只检查 WP 会员商品券
- 如果会员券不再是 WHX 状态，自动移除对应预核销券菜品
- MP/DP 平台券不做二次校验；prepare 凭证过期由下单 verify 报错

### 5.4 创建订单（正式核销边界）

```
POST /order_bill/crt_order
```

正式核销触发时机：保存订单和菜品后，遍历 `preWriteOff=true` 的菜品。

**WP 正式核销调用 CRM**：

| 字段 | 说明 |
|------|------|
| `mid` | 商户编号 |
| `sid` | 门店编号 |
| `cardNo` | 会员卡号（订单请求 cardId） |
| `couponNoList` | 券 LID 列表 |
| `orderId` | 真实订单 saasOrderKey |
| `operator` | 核销操作人（phone 或 wechat-miniapp） |

**MP/DP 正式核销调用平台 SDK**：

| 字段 | 说明 |
|------|------|
| `mid/sid` | 商户/门店编号 |
| `verifyToken` | 预核销保存的 token |
| `encryptedCodes` | 预核销保存的加密码列表 |
| `thirdPlatformType` | MP → CAN_DAO，DP → DOU_YIN |
| `price` | 平台券价格 |
| `extOrderId` | 真实订单 saasOrderKey |
| `channel` | 预核销保存的渠道 |
| `staffId` | 下单用户 openId |
| `staffName` | 下单用户昵称 |

## 6. 平台券凭证透传设计（POS 对齐）

### 6.1 问题背景

小程序云端下单链路中，平台券（MP/DP）正式核销成功后会产生撤销凭证（如美团的 verifyResults、抖音的 verifyId）。POS 端现有平台券撤销处理器已经围绕 `DwdCoupon.couponNo`、`DwdCoupon.writeOffId`、`DwdCoupon.writeOffChannel` 工作：

- **美团/餐道**：`MtCouponHandler` 从 `writeOffId` 解析 `verifyResults` JSON 数组，取 `verifyId` 撤销
- **抖音**：`DyCouponHandler` 从 `writeOffId` 读取逗号分隔的 `verifyId`，从 `couponNo` 取 `certificateId` 撤销

因此，云端平台券核销凭证必须最终透传到 POS 本地 `DwdCoupon`。

### 6.2 字段透传链路

```
云端预核销（CartProductCouponService）
  → 解析平台 prepare 返回的 certificateId / verifyToken / channel / price / certificate.count
  → 保存到购物车券菜品行

云端正式核销（CrtPostOrderServiceImpl）
  → 调用平台 verify
  → 解析 verifyId / verifyResults
  → 回写 order_food.platform_certificate_id / platform_write_off_id / write_off_channel 等字段

云端返回订单详情（doGetOrder）
  → OrderFoodVO 透传 platform_certificate_id / platform_write_off_id / write_off_channel 等

POS 接单（DoOrderHandler）
  → toCreateDTO() 透传字段
  → DwdBillServicePlus.toOrder() 沉淀 DwdCoupon
```

### 6.3 order_food 新增字段

| 字段 | 说明 |
|------|------|
| `platform_certificate_id` | 平台券凭证 ID（prepare 返回的 certificate_id）；写入 DwdCoupon.couponNo |
| `platform_write_off_id` | 平台券撤销凭证；MP 存 verifyResults JSON 数组字符串，DP 存逗号分隔的 verifyId |
| `product_coupon_business_type` | 商品券业务类型：WP/MP/DP |
| `platform_price` | 平台券面额；写入 DwdCoupon.faceAmount |
| `platform_paid_amount` | 平台券实收金额；写入 DwdCoupon.paidAmount |
| `write_off_channel` | 平台核销渠道；写入 DwdCoupon.writeOffChannel |

> ⚠️ MP 存 JSON 数组字符串（对齐 `MtCouponHandler.cancelOff` 的 `JSON.parseArray` 解析），DP 存逗号分隔字符串（对齐 `DyCouponHandler.cancelOff` 的 `split("[,，]")` 解析）。两种格式不能互换。

### 6.4 DwdCoupon 沉淀字段

| DwdCoupon 字段 | 来源 |
|--------------|------|
| `couponNo` | `platform_certificate_id`（必须，不能用扫码原始码） |
| `writeOffId` | `platform_write_off_id` |
| `writeOffChannel` | `write_off_channel` |
| `faceAmount` | `platform_price` |
| `paidAmount` | `platform_paid_amount`（不能静默兜底，必须有值或报错） |
| `numbers` | `order_food.food_number`（MP/DP 取平台 certificate.count） |

幂等策略：按 `mid + sid + dwdBillId + platform_certificate_id + couponType` 查重，存在则更新，不存在则插入。

## 7. 金额核算规则

| 优惠类型 | 优惠金额计算 | 备注 |
|---------|------------|------|
| FREE 或空 | `promotionAmount = 菜品单价` | 券面值0，菜品完全免费 |
| DISCOUNT | `promotionAmount = 原价 × (10 - dishDiscountValue) / 10` | 折扣率 |
| AMOUNT_OFF | `promotionAmount = dishDiscountValue`（最高不超过菜品价格） | 立减金额 |
| MP/DP | `promotionAmount = platform_price`（platform prepare 返回） | 平台口径 |

金额规则：
- 免费商品券优惠金额等于菜品价格
- 折扣券按折扣值计算
- 立减券按立减值计算，最多减到菜品价格
- 平台券优惠金额以平台 prepare 返回价格为准
- 券菜品保留菜品原价，优惠额单独落 `promotionAmount`
- 订单头 `promotionAmount` 增加商品券优惠额，`paidAmount` 扣减商品券优惠额
- **商品券不能作为支付方式二次扣减**，否则订单头、订单行和付款方式不平

## 8. 异常边界

| 场景 | 响应 |
|------|------|
| WV/MV/DV 现金券调用预核销 | 拒绝，提示现金券不能在点餐页核销 |
| 会员券不存在 | 拒绝，提示优惠券不存在 |
| 会员券非 SWQ 类型 | 拒绝，提示只有商品券可以在点餐页核销 |
| 会员券状态非 WHX | 拒绝，提示该券已被使用或已失效 |
| 会员券绑定菜品不匹配 | 拒绝，提示券与菜品不匹配 |
| 会员券绑定单位不匹配 | 拒绝，提示券与菜品单位不匹配 |
| 同一会员券重复加入购物车 | 拒绝，提示该券已在购物车中 |
| 平台券码为空 | 拒绝，提示平台券码不能为空 |
| 平台 prepare 无有效凭证 | 拒绝，提示平台券无有效凭证 |
| 平台返回 groupon_type==2（现金券） | 拒绝，提示请在支付页使用 |
| 平台券未匹配到本地菜品 | 拒绝，提示平台券商品未绑定本店菜品 |
| 下单时平台券缺少 verifyToken | 拒绝，提示预核销已失效，请重新核销券 |
| 下单时平台券缺少 encryptedCode | 拒绝，提示预核销已失效，请重新核销券 |
| 平台券正式核销失败 | 下单失败，提示商品券核销失败和具体菜品名 |

## 9. 后台管理页面（CRM 实物券配置）

### 9.1 管理页面入口

| 功能 | 路径 | 说明 |
|------|------|------|
| 优惠券管理 | CRM 优惠券列表页 | 管理所有券类型（含 SWQ 实物券） |
| 券模板配置 | `CrmCouponController`（`/crm_coupon`） | 新增/编辑/审核/停用 |

### 9.2 实物券菜品绑定配置

菜品绑定通过 `CrmCouponDishAddDTO` 在新增/编辑券模板时一起提交：

| 字段 | 类型 | 说明 |
|------|------|------|
| `sid` | Long | 门店 ID |
| `dishLid` | Long | 菜品 LID |
| `dishUnit` | String | 菜品单位名称（展示用） |
| `dishUnitLid` | Long | **菜品单位选项 ID**（稳定匹配键） |

> ⚠️ **同门店唯一限制**：当前代码限制同一门店只能绑定一个菜品。同门店多个可兑换菜品候选需调整保存校验和核销匹配逻辑。

菜品绑定保存流程：
1. 非 SWQ 券直接忽略菜品绑定
2. 遍历菜品绑定列表，校验菜品存在、门店存在、单位存在
3. 按 sid 去重：同门店只能绑定一个菜品
4. 修改时先删除旧绑定，再批量保存新绑定

## 10. 幂等设计

### 10.1 购物车幂等

| 券类型 | 幂等条件 | 响应 |
|--------|---------|------|
| WP | 购物车中已有 `preWriteOff=true` 且 `couponNo` 相同 | 拒绝，提示"该券已在购物车中" |
| MP/DP | 购物车中已有 `preWriteOff=true`、类型非 WP、且 `originalCouponCode` 相同 | 拒绝，提示"该券已在购物车中" |

### 10.2 POS 接单幂等

按 `mid + sid + dwdBillId + platform_certificate_id + couponType` 查重：
- 存在：更新 `dwdBillLid`、`writeOff=true`、`writeOffId`、`faceAmount`、`paidAmount`、`numbers`
- 不存在：插入新 `DwdCoupon`

## 11. 与 POS 本地扫码核销的对比

| 维度 | 小程序云端下单 | POS 本地扫码核销 |
|------|-------------|---------------|
| 预核销 | 有（购物车 Redis） | 无（直接核销） |
| 核销时机 | 下单时正式核销 | 扫码时立即核销 |
| 平台券凭证存储 | 云端 order_food → doGetOrder → POS DwdCoupon | POS DwdCoupon 本地存储 |
| 平台 SKU 匹配 | 后端按 PtDish.extNames 自动匹配 | POS NmsCouponHandler / MtCouponHandler / DyCouponHandler |
| 撤销凭证 | DwdCoupon.writeOffId | DwdCoupon.writeOffId（复用） |

小程序和 POS 共用相同的平台撤销处理器（`MtCouponHandler.cancelOff` / `DyCouponHandler.cancelOff`），区别只是凭证的来源路径不同。

## 12. 代码文件清单

| 文件 | 职责 |
|------|------|
| **云端（nms4cloud-order）** | |
| `ShoppingCartController.java` | 购物车接口（含预核销入口） |
| `CartProductCouponService.java` | 预核销逻辑、平台券 prepare 调用、SKU 匹配 |
| `CrtPostOrderServiceImpl.java` | 下单正式核销（含平台 verify 和 CRM 核销） |
| `CalcGenericOrderServiceImpl.java` | 商品券金额核算快照 |
| `OrderCouponServicePlus.java` | 会员可用券查询 |
| `OrderBillServicePlus.java` | 订单详情返回（含 doGetOrder） |
| **CRM（nms4cloud-crm）** | |
| `CrmCouponOpServicePlus.java` | 券发放（couponOpAdd）和撤销（couponOpRevoke） |
| `CheckCouponUtil.java` | 核销校验（含 SWQ 专属分支） |
| `CrmCouponServicePlus.java` | 券模板管理（含菜品绑定 addCouponDish） |
| **POS（nms4pos）** | |
| `DoOrderHandler.java` | 接单 DTO 透传 |
| `DwdBillServicePlus.java` | 沉淀 DwdCoupon |
| `MtCouponHandler.java` | 美团平台券撤销 |
| `DyCouponHandler.java` | 抖音平台券撤销 |
| **实体/DTO/VO** | |
| `OrderFood.java` | 订单菜品实体（含平台券凭证字段） |
| `OrderFoodVO.java` | 订单菜品 VO |
| `CrmCouponOrder.java` | 券领取/核销记录实体 |
| `CrmCouponDish.java` | 实物券菜品绑定实体 |
| `DwdCoupon.java` | POS 本地券记录实体 |
| `CartPreWriteOffCouponRequest.java` | 预核销请求 DTO |
| `ProductCouponBusinessTypeEnum.java` | 商品券业务类型枚举（WP/MP/DP） |

## 13. 测试验证要点

- WP 预核销：同一会员券重复加入购物车 → 返回"已在购物车中"
- MP/DP 预核销：平台券码重复 → 返回"已在购物车中"
- 预核销后购物车查询：会员券失效 → 自动移除券菜品
- 下单正式核销：WP → CRM 核销成功，crm_coupon_order 状态变 YHX
- 下单正式核销：MP/DP → 平台 verify 成功，order_food 回写凭证字段
- POS 接单：收到 DO_ORDER 消息 → 正确沉淀 DwdCoupon
- POS 撤销：调用 MtCouponHandler / DyCouponHandler → 平台撤销成功
- 订单核算：商品券优惠金额正确快照到 coupon_items / product_items
- 平台 SKU 自动匹配：扫抖音/美团券 → 命中本地菜品（extNames 规则）
