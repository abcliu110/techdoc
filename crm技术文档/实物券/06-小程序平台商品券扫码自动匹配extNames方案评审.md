# 小程序平台商品券扫码自动匹配 extNames 方案评审

**日期**：2026-05-29  
**状态**：方案评审结论  
**范围**：小程序点餐平台商品券扫码预核销，涉及 `nms4cloud-order`、`nms4cloud-product`、平台券 `prepare/verify`，并参考 POS 美团/抖音券核销逻辑。

## 1. 背景问题

小程序点餐场景中，用户扫码美团或抖音券时，前端只能拿到平台券码 `couponCode`。但当前小程序商品券预核销接口仍要求传入 `foodId` 和 `unitId`，导致平台券无法做到“扫码后直接核销到购物车”。

当前代码现状：

1. `/shopping_cart/pre_write_off_coupon` 当前请求对象中，`foodId`、`unitId` 是必填字段。
2. `CartProductCouponService#buildPreWriteOffFood` 当前先按 `foodId/unitId` 查询菜品和单位，然后才调用平台 `prepare`。
3. 平台 `prepare` 已经返回 `sku.sku_id`、`title/coupon_name`、`encrypted_code`、`verify_token`、`channel`、`original_amount` 等数据。
4. 当前小程序后端没有使用 `sku.sku_id` 自动反查本地菜品。

因此，问题本质不是平台无法返回商品信息，而是小程序后端还没有把平台 SKU 和本地菜品绑定关系接入预核销流程。

## 2. POS 真实逻辑

POS 端美团、抖音平台券核销已经存在成熟逻辑，主要依赖 `PtDish.extNames`，不是 `takeout_food_map`。

POS 处理链路：

1. 扫码得到平台券码。
2. 调用平台 `prepare`。
3. 从 `prepare` 返回中取 `sku.sku_id`。
4. 将 `sku_id` 保存为 `DwdCoupon.productNo`。
5. 按 `mid/sid` 查询本地菜品 `PtDish.extNames`。
6. 解析 `extNames` JSON，匹配平台 SKU 或平台商品名。
7. 匹配到菜品后，使用菜品默认单位参与核销。

`extNames` 数据结构语义：

```json
[
  {
    "id": "平台SKU或外部商品ID",
    "name": "平台商品名或券商品名"
  }
]
```

POS 匹配规则可概括为：

1. 优先匹配 `extNames[].id == productNo`。
2. 其次匹配 `extNames[].name == productNo`。
3. 再匹配 `extNames[].name == productName`。
4. 最后才尝试菜品名称等于平台商品名。

## 3. 为什么不以 takeout_food_map 为主路径

`takeout_food_map` 是外卖商品映射表，不是平台商品券核销的主绑定来源。

不建议作为主路径的原因：

1. 商户可能没有导入外卖商品，表里可能没有数据。
2. 商户可能只维护了 POS 菜品 `extNames`，没有维护外卖映射。
3. POS 美团/抖音券核销代码本身没有依赖 `takeout_food_map`。
4. `takeout_food_map` 的现有 `get` 查询按 `sid + foodIdInChannel` 查询，没有带 `channelType`，跨平台 SKU 相同时存在串映射风险。
5. 外卖商品映射和平台券商品绑定虽然都涉及平台 SKU，但业务语义不同，不能默认等价。

结论：`takeout_food_map` 最多作为后续备用或排查参考，不应作为小程序扫码核销的主路径。

## 4. 推荐方案

小程序平台商品券扫码预核销应对齐 POS 的 `extNames` 主逻辑。

### 4.1 小程序请求规则

会员商品券 `WP`：

- 继续沿用当前逻辑。
- 前端仍传 `couponNo`、`foodId`、`unitId`。
- 后端校验 CRM `SWQ` 商品券、券状态、绑定菜品和单位。

平台商品券 `MP/DP`：

- 前端只需要传 `couponBusinessType` 和 `couponCode`。
- 不再要求前端传 `foodId` 和 `unitId`。
- `foodId/unitId` 由后端根据平台 `prepare` 返回的 SKU 自动匹配。

### 4.2 后端处理链路

平台券 `MP/DP` 预核销流程：

1. `/shopping_cart/pre_write_off_coupon` 收到 `couponBusinessType + couponCode`。
2. 后端根据券类型选择平台：
   - `MP`：美团/餐道平台。
   - `DP`：抖音平台。
3. 调用平台 `prepare`。
4. 从返回值中解析：
   - `sku.sku_id`
   - `sku.title`
   - `sku.coupon_name`
   - `encrypted_code`
   - `verify_token`
   - `channel`
   - `original_amount`
   - `groupon_type`
5. 如果 `groupon_type` 表示现金券，则拒绝在点餐页预核销。
6. 调用 `nms4cloud-product` 新增内部接口，按 `mid/sid/skuId/title/couponName` 匹配 `PtDish.extNames`。
7. 匹配唯一菜品后，默认使用菜品默认单位。
8. 后端设置 `foodId = PtDish.lid`，`unitId = -1`。
9. 复用当前购物车预核销逻辑，生成 `preWriteOff=true` 的券菜品行。
10. 下单时继续走当前 `/order_bill/crt_order` 中的平台 `verify` 逻辑。

## 5. product 内部匹配接口建议

建议在 `nms4cloud-product` 增加一个内部接口，专门封装平台券 SKU 到本地菜品的匹配逻辑。

接口职责：

- 输入：`mid`、`sid`、`platformSkuId`、`platformTitle`、`couponName`。
- 查询：当前门店下存在 `extNames` 的菜品。
- 解析：将 `extNames` 作为 JSON 数组解析。
- 匹配：按 POS 端 `MtCouponHandler#getProduct`、`DyCouponHandler#getProduct` 的候选查询和命中顺序查找菜品。
- 输出：匹配到的本地菜品信息和默认单位信息。

不建议让 `order` 服务直接扫描 `PtDish.extNames`：

1. 商品字段归属 product 服务。
2. `extNames` JSON 解析和匹配规则应集中管理。
3. 后续如果 `extNames` 字段结构变化，只需要改 product 服务。
4. 避免 order 服务直接依赖商品表内部结构。

## 6. 匹配规则

匹配优先级必须和 POS 一致：

| 优先级 | 匹配规则 | 是否可自动核销 |
|---|---|---|
| 1 | `extNames[].id == sku_id` | 是，与 POS 一致，首个命中返回 |
| 2 | `extNames[].name == sku_id` | 是，与 POS 一致，首个命中返回 |
| 3 | `extNames[].name == title/coupon_name` | 是，与 POS 一致，首个命中返回 |
| 4 | `PtDish.name == title/coupon_name` | 是，与 POS 一致，最后尝试菜品名匹配 |

严禁只依赖 SQL `LIKE` 的结果直接确认菜品。可以用 `LIKE` 缩小候选范围，但最终必须解析 JSON 做精确匹配。

候选查询也要复刻 POS：按 `mid/sid` 查询 `extNames` 非空，且 `extNames like sku_id` 或 `extNames like title/coupon_name` 或 `PtDish.name == title/coupon_name` 的菜品；再遍历候选列表，按上表顺序返回首个命中菜品。不要在小程序侧额外增加“多命中拒绝”规则，否则同一平台商品券可能出现 POS 可核销、小程序不可核销的差异。

## 7. 单位规则

POS 的 `extNames` 只解决“平台 SKU 对应哪个菜品”，不解决单位。

小程序 v1 建议沿用 POS 逻辑：

1. 平台券匹配到菜品后，默认使用菜品默认单位。
2. 小程序当前多单位查询中，默认单位对应 `unitId = -1`。
3. 因此平台券自动匹配成功后，后端写入 `unitId = -1`。

限制说明：

- 如果未来平台 SKU 明确对应某个多单位或规格，当前 `extNames` 结构不足以表达单位。
- 这种场景需要后续扩展绑定结构，不能在 v1 中静默猜测多单位。
- 如果命中的菜品是套餐，需确认小程序购物车和下单链路是否完整支持套餐菜品行；不支持时应明确拒绝。

## 8. 失败处理

平台券自动匹配必须做到失败不写购物车、不执行正式核销。

| 场景 | 处理方式 |
|---|---|
| 平台 `prepare` 失败 | 返回平台错误，不写购物车 |
| `prepare` 返回无 `certificates` | 返回“平台券无有效凭证” |
| `certificates` 中无 `sku` | 返回“平台券未返回商品信息” |
| `sku_id` 为空 | 返回“平台券商品编号为空，无法匹配菜品” |
| `groupon_type` 为现金券 | 返回“现金券不能在点餐页核销，请在支付页使用” |
| 未匹配到 `extNames` 菜品 | 返回“平台券商品未绑定本店菜品” |
| 多个菜品都可能匹配 | 按 POS 首个命中规则返回；如需改为唯一命中，必须同步评估 POS 行为调整 |
| 命中菜品已禁用或不可售 | 返回“绑定菜品不可售” |
| 命中套餐但小程序不支持套餐券 | 返回“该券绑定套餐暂不支持小程序核销” |
| 匹配成功但写购物车失败 | 不调用平台 `verify`，返回购物车错误 |

## 9. 兼容性要求

1. `WP` 会员商品券旧逻辑保持不变。
2. 平台券 `MP/DP` 需要兼容旧调用：
   - 如果前端仍传 `foodId/unitId`，可以继续走旧逻辑。
   - 如果前端只传 `couponCode`，走新增自动匹配逻辑。
3. 正式核销仍只发生在 `/order_bill/crt_order`。
4. 预核销阶段只调用平台 `prepare`，不调用平台 `verify`。
5. 取消预核销只删除购物车菜品行，不调用平台 `cancel`。
6. 商品券不得在支付页作为 `COUPON` 支付项再次抵扣。

## 10. 提交人与变更边界评估

从 git 记录看，POS 端“实物券/商品券扩展”业务线近期存在 `guoyun_liu` 的提交，说明该方向属于当前正在推进的商品券改造范围，可以继续在小程序链路中补齐平台券自动匹配能力。

但 POS 端 `MtCouponHandler`、`DyCouponHandler` 中 `extNames` 匹配函数的历史提交人主要不是 `guoyun_liu`，因此不建议改动 POS 现有匹配逻辑。小程序应参考 POS 逻辑，在 `nms4cloud` 侧新增能力，而不是重写 POS 代码。

建议变更边界：

1. 不修改 POS `MtCouponHandler`、`DyCouponHandler`。
2. `nms4cloud-product` 只做低风险扩展：
   - 补充 `PtDish.extNames` 字段映射。
   - 新增内部匹配接口。
3. `nms4cloud-order` 只改平台券预核销分支：
   - `MP/DP` 支持只传 `couponCode`。
   - 自动匹配出 `foodId/unitId`。
   - 复用现有购物车预核销和下单 `verify`。
4. 不把 `takeout_food_map` 作为主链路依赖。

## 11. 测试建议

至少覆盖以下场景：

1. `WP` 会员商品券仍要求并使用 `couponNo/foodId/unitId`。
2. `MP` 美团券只传 `couponCode`，`prepare` 返回 `sku_id`，按 `extNames[].id` 匹配成功。
3. `DP` 抖音券只传 `couponCode`，按 `extNames[].id` 匹配成功。
4. `extNames[].name` 匹配成功。
5. `extNames` 未命中但 `PtDish.name == title/coupon_name` 时，按 POS 逻辑匹配成功。
6. 多个菜品命中同一 `sku_id` 时按 POS 候选列表首个命中规则返回。
7. 未配置 `extNames` 时返回未绑定菜品。
8. `prepare` 返回现金券时拒绝点餐页核销。
9. 匹配成功后购物车菜品行使用默认单位，`unitId = -1`。
10. 下单时仍使用预核销阶段保存的 `verifyToken/encryptedCode/channel/platformPrice` 调平台 `verify`。

## 12. 最终结论

小程序平台商品券扫码自动核销应以 POS 已验证的 `extNames` 绑定逻辑为主路径。

`takeout_food_map` 不应作为主路径，因为它是外卖商品映射，数据可能不存在，且与平台商品券核销绑定语义不完全一致。

推荐落地方式是在 `nms4cloud-product` 新增平台券 SKU 匹配内部接口，由 `nms4cloud-order` 在平台券预核销时调用。这样既能复用 POS 成熟业务规则，又能保持服务边界清晰，并且不影响会员商品券和正式下单核销旧逻辑。
