# 小程序平台商品券核销凭证传递到 POS DwdCoupon 设计

## 1. 背景

小程序商品券下单链路中，平台券（美团/餐道 MP、抖音 DP）在云端订单服务内完成正式核销。平台核销成功后会产生后续撤销核销必须使用的凭证，例如餐道的 `verify_results`、抖音的 `verify_id`。

POS 端现有平台券撤销逻辑已经围绕 `DwdCoupon.couponNo`、`DwdCoupon.writeOffId` 和 `DwdCoupon.writeOffChannel` 工作：

- 美团/餐道：`MtCouponHandler` 从 `DwdCoupon.writeOffId` 解析 `verify_results` JSON 数组，再逐条取 `verify_id` 撤销。
- 抖音：`DyCouponHandler` 从 `DwdCoupon.writeOffId` 读取 `verify_id` 或逗号分隔的多个 `verify_id`，并把 `DwdCoupon.couponNo` 作为 `certificateId` 传给平台撤销接口。

因此，小程序云端下单产生的平台券核销凭证必须最终沉淀到 POS 本地 `dwd_coupon.coupon_no`、`dwd_coupon.write_off_id` 和 `dwd_coupon.write_off_channel`，否则 POS 后续撤单、退菜或撤销券时无法调用平台撤销接口。平台券金额和数量也必须同步沉淀到 `face_amount`、`paid_amount`、`numbers`，否则 POS 本地券支付汇总、报表和核对口径会偏离本地扫码核销链路。

## 2. 当前代码事实

### 2.1 云端小程序下单链路

代码位置：

- `D:\mywork\nms4cloud\nms4cloud-app\3_customer\nms4cloud-order\nms4cloud-order-service\src\main\java\com\nms4cloud\order\service\c\order\CrtPostOrderServiceImpl.java`

当前后付下单流程：

1. `crtOrder(...)` 先计算订单。
2. 保存 `OrderBill`。
3. 保存 `OrderFood`。
4. 调用 `writeOffPreWriteOffCoupons(...)` 对购物车中 `preWriteOff=true` 的券菜品做正式核销。
5. `postHandle(...)` 发送 `DO_ORDER` 消息到 POS。

关键现状：

- 平台正式核销发生在 `writeOffSinglePreWriteOffCoupon(...)`。
- 目前平台 `verify` 成功后只校验 `result.isSuccess()`，没有把撤销凭证写回订单菜品行。
- 因为 `OrderFood` 已经先保存，所以正式核销成功后需要更新已保存的 `order_food` 行，不能只修改购物车内存对象。

### 2.2 POS 接收小程序订单链路

代码位置：

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\handler\DoOrderHandler.java`

POS 收到 `DO_ORDER` 后不是直接使用 MQTT 消息中的完整订单，而是：

1. 从消息 `data.id` 取云端订单号。
2. 调用 `nms4cloudOrderService.doGetOrder(...)` 反查云端订单详情。
3. 读取返回的 `DoGetOrderVO.foodList`。
4. 通过 `DoOrderHandler.toCreateDTO(...)` 将云端 `OrderFoodVO` 转为 POS `DwdFoodCreateDTO`。
5. 调用 `DwdBillServicePlus.toOrder(...)` 落本地 `DwdFood`。

关键现状：

- 这条链路当前只落 POS 菜品明细 `dwd_food`。
- 云端平台券凭证没有字段传到 POS。
- POS 接单链路也没有根据云端券菜品创建/更新 `DwdCoupon`。

### 2.3 POS 平台券本地核销链路

代码位置：

- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\DwdBillOpsServiceImpl.java`
- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\coupon\MtCouponHandler.java`
- `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\coupon\DyCouponHandler.java`

POS 自己扫码核销平台券时：

1. `loadCoupons(...)` 加载平台券信息为 `DwdCoupon`。
2. `writeOff(...)` 调平台核销。
3. 核销成功后把平台撤销凭证写入 `DwdCoupon.writeOffId`。
4. `rmvCoupons(...)` 撤销时再读取 `DwdCoupon.writeOffId` 调平台撤销。

这说明 POS 侧已有成熟语义字段：`coupon_no`、`write_off_id`、`write_off_channel`、`face_amount`、`paid_amount`、`numbers`，不需要新增 POS 字段，只需要让云端订单详情和 POS 接单链路把这些值沉淀到 `DwdCoupon`。

## 3. 目标

让小程序云端已核销的平台商品券，在 POS 接单落本地订单时同步形成一条可撤销的 `DwdCoupon` 记录，并将平台 `certificate_id`、正式核销撤销凭证、核销渠道、金额和数量口径分别写入 `DwdCoupon.couponNo`、`DwdCoupon.writeOffId`、`DwdCoupon.writeOffChannel`、`DwdCoupon.faceAmount/paidAmount/numbers`。

达成后：

- POS 撤销平台券继续复用现有 `MtCouponHandler.cancelOff(...)` / `DyCouponHandler.cancelOff(...)`。
- 不改平台券撤销处理器核心逻辑。
- 不要求 POS 再次调用平台正式核销接口，避免重复核销。

## 4. 字段设计

### 4.1 云端 `order_food` 新增字段

建议新增字段：

```sql
ALTER TABLE order_food
  ADD COLUMN platform_certificate_id varchar(128) NULL COMMENT '平台券凭证ID：平台prepare返回的certificate_id，传给POS作为DwdCoupon.couponNo',
  ADD COLUMN platform_write_off_id text NULL COMMENT '平台券撤销凭证：餐道/美团存verify_results JSON，抖音存verify_id或逗号分隔verify_id',
  ADD COLUMN product_coupon_business_type varchar(16) NULL COMMENT '商品券业务类型：WP会员券、MP美团/餐道平台券、DP抖音平台券',
  ADD COLUMN platform_price decimal(18,4) NULL COMMENT '平台券面额，优先取amount.list_market_amount/100，用于POS DwdCoupon.faceAmount',
  ADD COLUMN platform_paid_amount decimal(18,4) NULL COMMENT '平台券实收/平台结算金额，用于POS DwdCoupon.paidAmount',
  ADD COLUMN write_off_channel varchar(64) NULL COMMENT '平台券核销渠道，传给POS作为DwdCoupon.writeOffChannel';
```

说明：如果实际库表已经存在可复用的 `write_off_channel` 字段，可以不重复建列；但 `OrderFood` entity、`OrderFoodVO` 和 `doGetOrder` 返回链路必须能稳定透传该字段，不能只停留在购物车临时 DTO 中。

DDL 交付要求：实现时必须同时提供 `order_food` 的迁移脚本，并和 `OrderFood` entity 字段一起提交。迁移脚本应使用幂等加列方式或先查列再加列，避免老环境重复执行失败；`platform_write_off_id` 必须使用 `text`，不能退化为短 `varchar`。验收时必须检查真实数据库字段已经补齐，不能只改 entity、VO 或接口透传代码。

字段含义：

- `platform_certificate_id` / `platformCertificateId`
  - POS `DwdCoupon.couponNo` 的来源，用于平台撤销和本地幂等匹配。
  - 优先取平台 `prepare` 阶段唯一 `certificates` 元素的 `certificate_id`；如果正式 `verify_results` 明确返回同一 `certificate_id`，可以用正式返回值校验一致性。
  - POS 接单后写入 `DwdCoupon.couponNo`。
  - 禁止保存用户扫码原始码或 `originalCouponCode`，否则 POS 撤销时会把原始码当 `certificateId` 传给平台。
- `platform_write_off_id` / `platformWriteOffId`
  - 平台商品券正式核销成功后返回的撤销凭证，供 POS 后续沉淀到 `DwdCoupon.writeOffId`。
  - MP/餐道：存 `verify_results` 的 JSON 数组字符串，格式 `[{"certificate_id":"...","verify_id":"..."}, ...]`，对齐 POS `MtCouponHandler.cancelOff` 的 `JSON.parseArray(writeOffId)` 解析。
  - DP/抖音：存逗号分隔的 `verify_id` 字符串，对齐 POS `DyCouponHandler.cancelOff` 的 `split("[,，]")` 解析。
  - 两种平台格式不可互换：MP 必须是 JSON 数组，DP 必须是逗号分隔字符串，否则 POS 撤销解析失败。
- `product_coupon_business_type` / `productCouponBusinessType`
  - 商品券业务类型，取值 `WP` / `MP` / `DP`。
  - POS 用于判断 `DwdCoupon.couponType` 和后续撤销处理器。
- `platform_price` / `platformPrice`
  - 平台券面额，优先取平台 `amount.list_market_amount / 100`，POS 接单后写入 `DwdCoupon.faceAmount`。
- `platform_paid_amount` / `platformPaidAmount`
  - 平台券实收/平台结算金额，POS 接单后写入 `DwdCoupon.paidAmount`。
  - POS 会在 `OrderServiceUtil.getSumCoupons(...)` 中按 `sum(paid_amount * numbers)` 聚合券实收金额，并生成券支付 `DwdPay.actualIncome`；平台券该字段必须有值，缺失时不能静默用 `platformPrice` 或券实际抵扣额替代。
- `write_off_channel` / `writeOffChannel`
  - 平台核销渠道，POS 接单后写入 `DwdCoupon.writeOffChannel`。
  - POS 撤销 MP/DP 时会继续传给平台取消接口，不能丢失。

数量口径：POS 本地平台券加载逻辑会把平台 `certificate.count` 写入 `DwdCoupon.numbers`。云端不新增 `platform_coupon_count` 字段，使用既有 `order_food.food_number` / `OrderFoodVO.foodNumber` 承接该数量；预核销阶段必须把券菜品数量设置为平台 `certificate.count`，或在无法确认一致时拒绝预核销。

为空含义：非平台券、未核销、老数据或不需要平台撤销凭证。

平台取值规则：

| 业务类型 | 平台 | `platformCertificateId` 存储内容 | `platformWriteOffId` 存储内容 | 对齐 POS |
|---|---|---|---|---|
| MP | 美团/餐道 | `prepare.certificates` 唯一元素的 `certificate_id`；正式返回有 `certificate_id` 时校验一致 | `verify_results` JSON 数组字符串 | `DwdCoupon.couponNo` + `MtCouponHandler.writeOffId` |
| DP | 抖音 | `prepare.certificates` 唯一元素的 `certificate_id`；正式返回有 `certificate_id` 时校验一致 | `verify_id` 字符串；多条时逗号分隔 | `DwdCoupon.couponNo` + `DyCouponHandler.writeOffId` |

注意：`originalCouponCode` 是用户扫码或前端传入的原始券码，只能用于购物车去重、审计和排查，不能作为 POS `DwdCoupon.couponNo` 的来源。
MVP 只支持一次预核销对应一个平台 `certificate_id` 并落一条 POS `DwdCoupon`。如果 `prepare.certificates` 返回多条，当前版本直接拒绝并提示暂不支持多凭证券包；不能静默取 `[0]`，也不能把多个 `certificate_id` 合并到一个 `platformCertificateId`。后续如要支持团购券包或多凭证，应拆成多条购物车券菜品和多条 `DwdCoupon`，幂等键也随单个 `certificate_id` 分别计算。
如果同一次正式核销返回多条 `verify_results` 且返回了 `certificate_id`，必须校验所有结果的 `certificate_id` 与 `platformCertificateId` 一致；如果不一致，MVP 阶段直接判定本次下单失败并触发同步反核销补偿，避免把多个平台凭证错误合并成一条 POS `DwdCoupon`。如果 `verify_results` 不返回 `certificate_id`，不得反向用 `verify_id` 覆盖 `platformCertificateId`。

### 4.2 云端 API / VO 字段

需要补字段：

- `OrderFood` entity：`platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`、`writeOffChannel`
- `OrderFoodVO`：`platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`、`writeOffChannel`

说明：

- `preWriteOffBusinessType`、`encryptedCode`、`verifyToken`、`originalCouponCode` 是购物车预核销临时字段，不应作为 POS 接单凭证字段暴露。
- `productCouponBusinessType` 表示正式核销成功后要传给 POS 的业务类型，必须随 `order_food` 持久化并经 `doGetOrder` 返回。
- 当前 `OrderFood` entity 只有 `couponWriteOffTraceNo`，没有平台正式核销凭证字段；实现时必须补 entity + 表字段 + VO，不能只在 `OrderFoodVO` 上加临时字段。

不建议补字段：

- `OrderFoodAddDTO`
- `OrderFoodUpdateDTO`

原因：`OrderFoodAddDTO`、`OrderFoodUpdateDTO` 是外部新增/修改菜品销售明细接口的请求体，不能暴露平台正式核销凭证写入口。正式核销凭证只能由下单事务内的平台 `verify` 结果回写。
如果现有购物车链路需要在内存 DTO 中临时携带 `platformPrice`、`writeOffChannel` 等正式核销入参，不能依赖公共 `order_food/add`、`order_food/update` 接口落库；最终仍必须在正式核销成功后由内部回写逻辑写入 `order_food`。

要求：字段必须有中文注释，说明平台、格式、是否必填、为空兼容语义。

### 4.3 POS 接单 DTO 字段

POS 侧用于承接云端订单详情的 DTO 需要补字段：

- `com.nms4cloud.pos2plugin.api.vo.order.OrderFoodVO`
  - `platformCertificateId`
  - `platformWriteOffId`
  - `productCouponBusinessType` 或等价平台券业务类型字段
  - `platformPrice`
  - `platformPaidAmount`
  - `writeOffChannel`
- `com.nms4cloud.pos2plugin.api.admin.dwd_food.dto.DwdFoodCreateDTO`
  - `platformCertificateId`
  - `platformWriteOffId`
  - `productCouponBusinessType` 或等价平台券业务类型字段
  - `platformPrice`
  - `platformPaidAmount`
  - `writeOffChannel`

说明：

- `OrderFoodVO` 用于接收云端 `doGetOrder` 返回值。
- `DwdFoodCreateDTO` 用于 `DoOrderHandler.toCreateDTO(...)` 后续传入 `DwdBillServicePlus.toOrder(...)`。
- 字段只用于 POS 接单阶段沉淀 `DwdCoupon`，不改变菜品价格、数量、口味、做法逻辑。
- 不复用当前云端 `ProductCouponOrderVO.certificateId` 的旧语义。该字段现有注释把 MP 与 DP 的撤销标识混在一起，不能作为 POS `DwdCoupon.couponNo` 的设计依据；POS 对齐链路必须使用明确的 `platformCertificateId`。

## 5. 云端实现方案

### 5.0 预核销阶段保存平台凭证

在 `CartProductCouponService.buildPreWriteOffFood(...)` 中，平台券 `prepare` 成功后不能只保存 `encryptedCode`、`verifyToken`、`platformPrice`、`writeOffChannel` 和 `originalCouponCode`。还必须先校验 `certificates` 只有一个元素，再解析并写入购物车券菜品：

- `platformCertificateId = certificates` 唯一元素的 `certificate_id`
- `platformPrice = amount.list_market_amount / 100`，缺失时口径按 7.5 兜底
- `platformPaidAmount`：MP/餐道取 `amount.pay_amount / 100`；DP/抖音优先取 `amount.coupon_pay_amount / 100`，缺失时退回 `amount.pay_amount / 100`；如果两个字段都缺失，按 7.5 直接失败或进入显式异常估算分支，不能静默用 `platformPrice` 兜底
- `foodNumber = certificate.count`，缺失时按 1 兜底并记录结构化日志

如果 `certificates` 返回多条，本阶段不能静默丢弃其他凭证。MVP 直接拒绝并提示当前不支持多凭证券包；后续只有在新增明确的用户选择或拆分规则后，才允许处理单个凭证或拆成多条凭证。无论哪种方式，都必须保证后续 `platformCertificateId` 唯一对应一条 POS `DwdCoupon`。
如果单条 `certificate.count > 1`，MVP 必须保证购物车券菜品数量与平台 `certificate.count` 一致；无法保证时应拒绝预核销，避免 POS 后续按 `paidAmount * numbers` 汇总金额被放大或缩小。

这些字段在购物车阶段仍属于后端内部临时态，不能开放给前端任意传入；正式核销成功后，再由下单事务回写到已保存的 `order_food` 行。

### 5.1 平台核销结果解析

在 `CrtPostOrderServiceImpl.writeOffSinglePreWriteOffCoupon(...)` 中，平台券 `verify` 成功后解析返回值：

- MP/餐道：
  - `platformCertificateId = 预核销 prepare 阶段保存的 certificate_id`；如果 `verify_results[*].certificate_id` 存在，校验和预核销值一致
  - `platformWriteOffId = data.verify_results` 序列化为 JSON 数组字符串
- DP/抖音：
  - `platformCertificateId = 预核销 prepare 阶段保存的 certificate_id`；如果 `verify_results[*].certificate_id` 存在，校验和预核销值一致
  - `platformWriteOffId = data.verify_results[*].verify_id`，单个直接保存，多个用英文逗号拼接

MP `platformWriteOffId` JSON 格式约束（必须对齐 POS 解析逻辑）：

- POS `MtCouponHandler.writeOff(...)` 会按 `certificate_id` 把 `verify_results` 分组，每张券的 `DwdCoupon.writeOffId` 只存自己 `certificate_id` 对应的 `verify_results` 子数组，格式为 `[{"certificate_id":"...","verify_id":"..."}, ...]`。
- POS `MtCouponHandler.cancelOff(...)` 撤销时执行 `JSON.parseArray(writeOffId)` 后逐个取 `verify_id`。因此云端写入的 `platformWriteOffId` 必须是 JSON 数组字符串，且数组元素至少包含 `verify_id` 字段，不能写成单个对象或逗号分隔字符串。
- MVP 限制单 `certificate`，所以云端 `data.verify_results` 整个数组即该券子数组，直接序列化即可。后续如支持多 `certificate`，云端必须按 `certificate_id` 分组，只把当前券对应的 `verify_results` 子数组写入该券的 `platformWriteOffId`，不能把整单所有券的 `verify_results` 混存到一条记录。
- DP `platformWriteOffId` 与 MP 不同：抖音 `DyCouponHandler.cancelOff(...)` 按 `split("[,，]")` 解析逗号分隔的 `verify_id`，所以 DP 必须存逗号分隔字符串，不能存 JSON 数组。两种平台格式不能互换。

校验规则：

- `verify_results` 不能为空。
- 每条 `verify_result` 都必须有 `verify_id`。
- `platformCertificateId` 必须在预核销阶段已保存；正式核销结果如果携带 `certificate_id`，必须和预核销值一致。
- `writeOffChannel` 必须在预核销阶段从平台 `prepare` 返回保存；平台未返回时下单失败，不允许用前端入参兜底。
- 多条 `verify_results` 的 `certificate_id` 如果存在，必须一致；不一致时当前版本直接判失败并走同步反核销补偿，不做多 `DwdCoupon` 拆分。

如果平台返回结构为空、预核销阶段缺少 `platformCertificateId/writeOffChannel`，或正式核销结果缺少撤销所需的 `verify_id`：

- 核销接口已返回成功但撤销凭证缺失，应该记录错误日志。
- 建议直接抛业务异常让下单事务回滚，因为没有撤销凭证会导致后续无法正确撤销平台券。
- 下单失败同步反核销时，平台取消参数 `count` 必须使用券菜品 `foodNumber`；缺失时按 1 兜底并记录结构化日志，不能长期固定写死为 1。

### 5.2 回写 `order_food`

由于 `OrderFood` 已经在正式核销前保存，核销成功后按以下条件更新对应菜品行：

- `mid = calcOrder.mid`
- `sid = calcOrder.sid`
- `saas_order_key = calcOrder.saasOrderKey`
- `lid = food.lid`

更新内容：

- `platform_certificate_id = 预核销 prepare 阶段保存的 certificate_id`
- `platform_write_off_id = 解析出的平台撤销凭证`
- `product_coupon_business_type = MP/DP`
- `platform_price = 平台券面额，优先取 amount.list_market_amount / 100`
- `platform_paid_amount = 预核销 prepare 阶段保存的实收/平台结算金额`
- `write_off_channel = 平台核销渠道`

注意：

- 只更新当前券菜品行，不批量覆盖整单菜品。
- 回写定位条件必须同时包含 `mid`、`sid`、`saas_order_key`、`lid`，其中 `lid` 必须是已保存的 `order_food.lid`，不能误用商品 ID、购物车临时 ID 或平台券凭证 ID。
- 回写执行方法必须能拿到数据库影响行数，并校验影响行数等于 1；如果现有 Service 更新封装拿不到影响行数，应改用可返回 row count 的 mapper/update wrapper。影响行数为 0 或大于 1 时，视为回写失败，触发已成功平台券的同步反核销补偿并让本次下单失败。
- 兼容老数据：没有该字段值的老订单不影响原下单流程。
- `crtOrder(...)` 带 `@Transactional`，同一事务内回写 `order_food`。如果回写失败，应触发已成功平台券的同步反核销补偿，并让本次下单失败。

### 5.3 `doGetOrder` 返回

`OrderBillServicePlus.doGetOrder(...)` 当前通过 `BeanUtilsPlus.mapList(foodList, OrderFoodVO.class)` 返回菜品。只要 entity 和 VO 字段同名，`platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`writeOffChannel` 可自然映射到返回值。
`platformPaidAmount` 也必须同名透传；如果缺失，POS 不应静默用 `platformPrice` 或实际抵扣额生成 `DwdCoupon.paidAmount`，应让接单失败或进入显式异常估算分支并记录结构化错误日志。

## 6. POS 实现方案

### 6.1 接单 DTO 映射

在 `DoOrderHandler.toCreateDTO(...)` 中增加字段透传：

```java
createDTO.setPlatformCertificateId(orderFoodVO.getPlatformCertificateId());
createDTO.setPlatformWriteOffId(orderFoodVO.getPlatformWriteOffId());
createDTO.setProductCouponBusinessType(orderFoodVO.getProductCouponBusinessType());
createDTO.setPlatformPrice(orderFoodVO.getPlatformPrice());
createDTO.setPlatformPaidAmount(orderFoodVO.getPlatformPaidAmount());
createDTO.setWriteOffChannel(orderFoodVO.getWriteOffChannel());
```

如果 POS 侧不希望依赖云端枚举类型，可改为字符串字段，例如：

- `productCouponBusinessType`
- 值：`WP` / `MP` / `DP`

推荐使用字符串，降低 nms4pos 对 nms4cloud-order 枚举包的依赖。

### 6.2 在 POS 下菜后沉淀 `DwdCoupon`

在 `DwdBillServicePlus.toOrder(...)` 中，`dwdFoodMapper.insertBatch(dwdFoods)` 成功后，扫描本次下菜 DTO 中带平台核销凭证的菜品，生成或更新 `DwdCoupon`。
`toOrder(...)` 当前有 `@Transactional`，平台券 `DwdCoupon` 沉淀必须留在同一事务内；不要放到事务外异步任务或独立新事务中，避免 POS 本地出现“菜品成功、券凭证失败”或“券凭证成功、后续做法/口味失败”的不一致。

识别条件：

- `platformWriteOffId` 非空
- `platformCertificateId` 非空
- `writeOffChannel` 非空
- 业务类型为 `MP` 或 `DP`

落库字段建议：

| `DwdCoupon` 字段 | 来源 |
|---|---|
| `mid` | 当前订单 `mid` |
| `sid` | 当前订单 `sid` |
| `reportDate` | 当前订单 `reportDate` |
| `dwdBillLid` | 当前 POS 账单 `lid` |
| `dwdBillId` | 当前 POS 账单 `saasOrderKey` |
| `couponNo` | 云端 `platformCertificateId` |
| `couponType` | `MP` 或 `DP` |
| `couponName` | 菜品行券名；没有则用菜品名兜底 |
| `numbers` | 云端券菜品 `foodNumber`；为空时按 1 兜底并记录日志，且必须与平台 `certificate.count` 一致 |
| `faceAmount` | 云端 `platformPrice`；为空时用本次券实际抵扣额兜底并记录日志 |
| `paidAmount` | 云端 `platformPaidAmount`；为空时不静默用 `platformPrice` 或实际券抵扣额兜底，应让接单失败或进入显式异常估算分支并记录结构化错误日志 |
| `writeOff` | `true` |
| `writeOffId` | `platformWriteOffId` |
| `writeOffChannel` | `writeOffChannel` |
| `writeOffAt` | 当前时间 |
| `writeOffBy` | 当前用户名称或“扫码点餐” |

类型映射：

| 云端 `productCouponBusinessType` | POS `ThirdPartyTypeEnum` | 是否进入本设计 |
|---|---|---|
| `MP` | `ThirdPartyTypeEnum.MP` | 是 |
| `DP` | `ThirdPartyTypeEnum.DP` | 是 |
| `WP` | `ThirdPartyTypeEnum.WP` | 否，会员商品券走 CRM 核销，不是平台券凭证传 POS |
| `MV` / `DV` / `WV` | 现金券类型 | 否，现金券走支付页/付款方式，不生成本设计的商品券 `DwdCoupon` |

幂等策略：

- 当前 MVP 不新增 POS trace 字段，按 `mid + sid + dwdBillId + platformCertificateId + couponType` 判断本次云端核销是否已沉淀。
- 如果存在：更新 `dwdBillLid`、`dwdBillId`、`reportDate`、`writeOff=true`、`writeOffId`、`writeOffChannel`、`faceAmount`、`paidAmount`、`numbers`。
- 如果不存在：插入新 `DwdCoupon`。

实现约束：

- 不能直接复用当前 `OrderServiceUtil.insertCoupons(...)` 作为唯一沉淀逻辑。该方法现有查重只按 `mid + couponNo` 查询，更新字段也不包含 `writeOffId`、`writeOffChannel`、`paidAmount`、`numbers`，与本设计的订单内幂等键和凭证字段不一致。
- 建议在 `DwdBillServicePlus.toOrder(...)` 的 `dwdFoodMapper.insertBatch(dwdFoods)` 成功后新增专用方法，例如 `saveCloudPlatformCoupons(...)`，按本节幂等键查询/更新/插入。
- 新插入 `DwdCoupon` 必须生成 `lid = IdWorkerPlus.getId()`，并设置 `createdBy`、`reportDate`、`dwdBillLid`、`dwdBillId`、`writeOffAt` 等 POS 后续查询/撤销依赖字段。
- 如果 `saveCloudPlatformCoupons(...)` 失败，必须抛异常让 `toOrder(...)` 整体回滚；依赖 `DO_ORDER` 重试和幂等键恢复，不在 POS 侧新增队列或补偿表。

这样可以兼容以下两种情况：

- POS 本地已有平台券草稿记录，只需要补核销状态、`writeOffId`、`writeOffChannel`、`faceAmount`、`paidAmount`、`numbers`。
- 小程序云端先核销，POS 本地从未加载过这张券，需要新建 `DwdCoupon`。

### 6.3 不修改 POS 平台撤销处理器

不建议修改：

- `MtCouponHandler.cancelOff(...)`
- `DyCouponHandler.cancelOff(...)`

原因：

- `MtCouponHandler.cancelOff(...)` 已经从 `DwdCoupon.writeOffId` 解析 `verify_results` 并取 `verify_id` 撤销。
- `DyCouponHandler.cancelOff(...)` 已经从 `DwdCoupon.writeOffId` 取 `verify_id`，并从 `DwdCoupon.couponNo` 取 `certificateId` 撤销。
- 两个处理器都会继续使用 `DwdCoupon.writeOffChannel` 作为平台撤销渠道。
- 本次需求的缺口是“云端 `platformCertificateId/platformWriteOffId/writeOffChannel` 没有传递并沉淀到 `DwdCoupon`”，不是撤销处理器不支持。

注意：`MtCouponHandler.cancelOff(...)` 当前取消时按餐道现有逻辑把 `verify_id` 同时传给 `verifyId/certificateId`。这是 POS 既有兼容行为，不代表云端可以把 `platformCertificateId` 改成 `verify_id`；云端传 POS 的 `DwdCoupon.couponNo` 仍必须保持平台 `prepare` 返回的 `certificate_id`，以对齐 POS 加载券时的 `couponNo` 语义和抖音撤销链路。

## 7. 兼容与风险

### 7.1 兼容老订单

老订单没有 `platform_certificate_id`、`platform_write_off_id`、`product_coupon_business_type`、`platform_price`、`platform_paid_amount`，或没有可用于平台券撤销的 `write_off_channel`：

- 云端查询不受影响。
- POS 接单时不会创建平台 `DwdCoupon`。
- 老逻辑保持原样。

### 7.2 重复接单风险

POS `DO_ORDER` 可能重试。沉淀 `DwdCoupon` 必须幂等：

- 不能每次重试都插入一条重复券。
- 当前 MVP 不新增 POS trace 字段，按 `mid + sid + dwdBillId + platformCertificateId + couponType` 查重后更新；这里的 `platformCertificateId` 会落到 `DwdCoupon.couponNo`，不能使用用户扫码原始码。

### 7.3 平台撤销凭证缺失风险

如果平台 `verify` 返回成功但解析不到 `platformCertificateId` 或 `platformWriteOffId`，建议云端下单失败并回滚。否则会出现：

- 平台券已核销。
- 云端订单已创建。
- POS 后续无法撤销平台券。

### 7.4 字段长度风险

餐道 `verify_results` 是 JSON 数组，`platform_write_off_id` 使用 `text`，避免多凭证或返回字段较长时被截断。

POS 本地 `DwdCoupon.writeOffId` 当前按 BLOB 类型映射，能够承接 `verify_results` JSON。实现时仍需要确认实际门店库表结构已同步到该类型，避免历史门店表字段长度不足。

### 7.5 平台券金额风险

POS 本地核销平台券时，`DwdCoupon.faceAmount` 使用平台返回的 `amount.list_market_amount / 100`。云端应保持同一口径：

- 优先 `list_market_amount / 100`。
- 缺失时可用本次券实际抵扣额兜底并记录日志。
- 不建议直接用 0 兜底，否则 POS 券金额、报表和核对会失真。

`DwdCoupon.paidAmount` 也要对齐 POS 本地加载口径：

- MP/餐道：`amount.pay_amount / 100`。
- DP/抖音：优先 `amount.coupon_pay_amount / 100`；缺失时按 POS 现有逻辑记录日志并退回 `amount.pay_amount / 100`。
- 如果以上字段都缺失，不能用 `platformPrice` 或本次券实际抵扣额直接兜底为 `paidAmount`。MVP 应直接判定预核销失败并提示平台未返回结算金额；如业务必须放行，只能显式记录结构化错误日志，并使用单独标识说明 `paidAmount` 为异常估算值，避免 POS 券支付汇总被误认为平台真实结算金额。

### 7.6 前端正式取消接口边界

本次 POS 对齐不暴露正式取消接口给小程序前端。

- 购物车预核销阶段没有正式核销，取消使用商品券只需要移除购物车里的预核销菜品。
- 正式核销只发生在下单事务中。
- 下单失败时由云端同步补偿反核销。
- 下单成功后，后续撤单、退菜、撤销券由 POS 现有平台券撤销逻辑处理。

## 8. 下阶段改造清单

### 8.1 nms4cloud

建议修改文件：

- `nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-dao/src/main/java/com/nms4cloud/order/dao/entity/OrderFood.java`
- `nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-api/src/main/java/com/nms4cloud/order/api/vo/OrderFoodVO.java`
- `nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-service/src/main/java/com/nms4cloud/order/service/c/cart/CartProductCouponService.java`
- `nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-service/src/main/java/com/nms4cloud/order/service/c/order/CrtPostOrderServiceImpl.java`
- `order_food` 表字段迁移脚本

验证重点：

- 迁移脚本新增 `platform_certificate_id`、`platform_write_off_id`、`product_coupon_business_type`、`platform_price`、`platform_paid_amount`、`write_off_channel`，其中 `platform_write_off_id` 为 `text`。
- 平台券预核销成功后，购物车券菜品已保存 `platformCertificateId`、`platformPaidAmount`，且值来源于后端调用平台 `prepare` 的返回值，不信任前端传入；券菜品 `foodNumber` 已按平台 `certificate.count` 校准。
- 平台券正式核销成功后，`order_food.platform_certificate_id`、`platform_write_off_id`、`product_coupon_business_type`、`platform_price`、`platform_paid_amount`、`write_off_channel` 有值。
- 核销成功后回写 `order_food` 使用 `mid + sid + saas_order_key + lid` 精确定位，影响行数必须等于 1。
- `doGetOrder` 返回的 `foodList` 中有 `platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`、`writeOffChannel`，并保留券菜品 `foodNumber`。
- MP 存储格式与 POS `MtCouponHandler.writeOffId` 一致。
- DP 存储格式与 POS `DyCouponHandler.writeOffId` 一致。
- `platformCertificateId` 来源于平台 prepare 返回的 `certificate_id`；正式核销返回 `certificate_id` 时只用于一致性校验，不使用用户扫码原始码。
- `OrderFoodAddDTO`、`OrderFoodUpdateDTO` 不暴露平台正式核销凭证写入口。

### 8.2 nms4pos

建议修改文件：

- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/order/OrderFoodVO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/admin/dwd_food/dto/DwdFoodCreateDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/order/handler/DoOrderHandler.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/admin/DwdBillServicePlus.java`

验证重点：

- POS 反查云端订单详情后能收到 `platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`、`writeOffChannel` 和券菜品 `foodNumber`。
- `DoOrderHandler.toCreateDTO(...)` 能透传字段。
- `DwdBillServicePlus.toOrder(...)` 落菜后能新增或更新 `DwdCoupon.couponNo`、`DwdCoupon.writeOffId`、`DwdCoupon.writeOffChannel`、`DwdCoupon.faceAmount`、`DwdCoupon.paidAmount`、`DwdCoupon.numbers`。
- `DwdCoupon.couponNo = platformCertificateId`。
- `DwdCoupon.writeOffChannel = writeOffChannel`。
- `DwdCoupon.faceAmount = platformPrice`，为空时按 7.5 的兜底规则记录结构化日志。
- `DwdCoupon.paidAmount = platformPaidAmount`；为空时不静默用 `platformPrice` 或实际券抵扣额兜底，应让接单失败或进入显式异常估算分支并记录结构化错误日志。
- `DwdCoupon.numbers = foodNumber`，为空时按 1 兜底并记录结构化日志。
- POS 撤销时现有 `MtCouponHandler.cancelOff(...)` / `DyCouponHandler.cancelOff(...)` 能读取该字段。

## 9. 建议测试用例

### 9.1 云端单元/契约测试

- MP 平台券 prepare 返回 `certificate_id`、正式核销返回 `verify_results`，断言 `OrderFood.platformCertificateId` 保存 prepare 阶段 `certificate_id`，`OrderFood.platformWriteOffId` 保存 JSON 数组。
- DP 平台券 prepare 返回 `certificate_id`、正式核销返回 `verify_id`，断言 `OrderFood.platformCertificateId` 保存 prepare 阶段 `certificate_id`，`OrderFood.platformWriteOffId` 保存字符串。
- 平台 prepare 缺少 `pay_amount/coupon_pay_amount` 时，断言预核销失败或进入显式异常估算分支；不能静默用 `platformPrice` 填充 `platformPaidAmount`。
- `order_food` 回写影响行数不是 1 时，断言下单失败并触发同步反核销补偿。
- 平台返回成功但无撤销凭证，断言下单失败。
- 多条 `verify_results` 的 `certificate_id` 不一致时，断言下单失败并触发同步反核销补偿。
- 下单失败触发同步反核销时，断言取消请求的 `count` 使用券菜品 `foodNumber`，而不是固定 1。
- `doGetOrder` 返回菜品字段包含 `platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`、`writeOffChannel`，并保留券菜品 `foodNumber`。

### 9.2 POS 单元/契约测试

- `OrderFoodVO.platformCertificateId/platformWriteOffId/productCouponBusinessType/platformPrice/platformPaidAmount/writeOffChannel` 和既有 `foodNumber` 透传到 `DwdFoodCreateDTO`。
- POS 接单时遇到 MP 券菜品，写入 `DwdCoupon.couponNo=platformCertificateId`、`couponType=MP`、`writeOff=true`、`writeOffId=verify_results JSON`、`faceAmount=platformPrice`、`paidAmount=platformPaidAmount`、`numbers=foodNumber`、`writeOffChannel=writeOffChannel`。
- POS 接单时遇到 DP 券菜品，写入 `DwdCoupon.couponNo=platformCertificateId`、`couponType=DP`、`writeOff=true`、`writeOffId=verify_id`、`faceAmount=platformPrice`、`paidAmount=platformPaidAmount`、`numbers=foodNumber`、`writeOffChannel=writeOffChannel`。
- 重复处理同一 `DO_ORDER` 不产生重复 `DwdCoupon`。

## 10. 结论

本需求必须形成完整链路：

```text
小程序平台券正式核销
  -> 云端 order_food.platform_certificate_id / platform_write_off_id / product_coupon_business_type / platform_price / platform_paid_amount / write_off_channel，并保留券菜品 food_number
  -> 云端 doGetOrder.foodList 透传平台券凭证字段
  -> POS DoOrderHandler.toCreateDTO 透传
  -> POS DwdBillServicePlus.toOrder 沉淀 DwdCoupon.couponNo / writeOffId / writeOffChannel / faceAmount / paidAmount / numbers
  -> POS 现有平台券撤销处理器复用 couponNo / writeOffId / writeOffChannel 撤销
```

最小可行实现是“两端都改”：

- 云端负责产生并返回 `platformCertificateId`、`platformWriteOffId`、`productCouponBusinessType`、`platformPrice`、`platformPaidAmount`，并透传 `writeOffChannel` 和既有券菜品 `foodNumber`。
- POS 负责把 `platformCertificateId` 变成 `DwdCoupon.couponNo`，把 `platformWriteOffId` 变成 `DwdCoupon.writeOffId`，把 `platformPrice/platformPaidAmount/foodNumber/writeOffChannel` 分别变成 `DwdCoupon.faceAmount/paidAmount/numbers/writeOffChannel`。

POS `dwd_coupon` 表不需要新增字段，已有 `coupon_no`、`write_off_id`、`write_off_channel`、`face_amount`、`paid_amount`、`numbers` 可承接本次 POS 对齐所需字段。
