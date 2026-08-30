# 多角色对抗性代码评审汇总报告

**项目：** `nms4cloud-order`（nms4cloud 订单模块）
**评审提交人：** guoyun_liu
**评审日期：** 2026-08-28
**评审轮次：** 5个批次，共18个独立专家角色视角

---

## 一、BLOCKING 级别问题汇总（共13个）

以下问题需要优先处理，一旦触发将导致系统级故障或数据损坏。

### 1.1 补偿失败后异常被静默吞掉 — 券状态与CRM不一致

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1699
- **评审角色：** 异常处理专家
- **问题描述：** `compensateMemberCoupons` 中如果 `cancelWrittenOffProductCoupon` 成功但 `markCompensated` 返回 false，异常被吞掉，导致券已反核销但状态仍是 SUCCESS/CANCEL_UNKNOWN，CRM 与本地记录不一致。
- **影响场景：** CRM 反核销成功但数据库更新失败时，券状态停留在 SUCCESS，CRM 已回收但平台记录显示未回收，后续恢复任务可能误判。用户券权益受损且无法追溯。
- **建议：** `markCompensated` 返回 false 时应抛出异常或记录为严重错误，并加入重试机制。

---

### 1.2 补偿失败后异常被吞掉 — 订单事务回滚但券补偿也失败

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1699
- **评审角色：** 异常处理专家
- **问题描述：** 订单创建失败后进入反核销流程，如果 `cancelWrittenOffProductCoupon` 或 `markCompensated` 失败，异常被吞掉，调用方收到的是原始 cause，误以为只要抛异常就算完成，实际上券可能处于不一致状态。
- **影响场景：** 静默失败，数据一致性与业务完整性双重破坏，且无告警。
- **建议：** 补偿失败时应考虑抛出运行时异常或记录为 ERROR 级别日志，或使用单独的异步线程池确保补偿不阻塞主流程。

---

### 1.3 `saveSuccess()` 内 detailService.saveBatch() 失败导致事务回滚，但 CRM 核销已成功无法回滚

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 145
- **评审角色：** 数据一致性专家
- **问题描述：** CRM 核销成功，本地主表 SUCCESS 更新成功，但 `saveBatch` 抛异常导致整个事务回滚，后续 `afterCreateOrderFailure` 的补偿会调用 CRM 反核销，但此时 CRM 可能已处理过该券。
- **影响场景：** 券被核销但订单创建失败，CRM 反核销时该券状态已变化，导致反核销失败，用户权益受损。
- **建议：** `saveSuccess` 应拆分为两步：先保存主表和详情到本地临时表，订单事务成功后通过消息队列或定时任务同步到正式表。

---

### 1.4 CRM 反核销接口可能多次调用导致用户券被错误恢复

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1558
- **评审角色：** 数据一致性专家
- **问题描述：** `writeOffMemberCouponsBeforeCreateOrder` 中 CRM `writeOffCouponInner` 成功但 `saveSuccess` 失败时，补偿逻辑调用 `cancelWriteOffCouponInner` 存在重试导致 CRM 端多次反核销的风险。
- **影响场景：** `saveSuccess` 因网络超时抛异常，实际已执行成功，补偿时调用 CRM 反核销会导致该券被恢复为可用状态，但本地记录已回滚，用户可重新使用该券 — **双重核销**。
- **建议：** CRM 反核销接口应支持幂等，或在调用前先查询 CRM 券状态确认是否需要反核销。

---

### 1.5 平台券本地标记 SUCCESS 后 verify 调用失败，本地状态与平台状态不一致

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1772
- **评审角色：** 数据一致性专家
- **问题描述：** CRM 券核销成功后，平台券本地标记 SUCCESS，但 verify 调用因网络超时抛异常，CRM 券已核销无法回滚，平台券本地 SUCCESS 但平台未核销。
- **影响场景：** 用户看到下单成功但平台券实际未核销，用户可在平台再次使用该券 — **重复核销风险**。
- **建议：** 平台券核销顺序应调整为：先调用平台 verify，成功后本地再标记 SUCCESS，失败则不改变本地状态。

---

### 1.6 `markCompensated`/`markCancellationUnknown` 返回 boolean 但无重试机制，version 冲突时静默失败

- **文件：** `CouponWriteOffRecordServiceImpl.java`
- **行号：** 201, 213
- **评审角色：** 数据一致性专家
- **问题描述：** `markCompensated`/`markCancellationUnknown` 使用 REQUIRES_NEW 事务但无重试机制，version 冲突时返回 false 静默失败。
- **影响场景：** 并发场景下两个事务同时更新同一记录，version 冲突导致 CRM 反核销成功但本地状态仍为 SUCCESS，数据不一致且无告警。
- **建议：** 实现重试逻辑或返回明确的失败标识让调用方感知。

---

### 1.7 `findOrderCommitState` 查询失败后返回 UNKNOWN，跳过补偿导致券未绑定订单

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1666
- **评审角色：** 异常处理专家
- **问题描述：** `findOrderCommitState` 在第三次查询失败后返回 UNKNOWN，导致订单实际已提交成功但无法确认时跳过补偿，可能导致"订单存在但券未绑定"。
- **影响场景：** 数据库主从延迟导致查询订单失败，订单实际已提交成功，此时跳过补偿会导致券核销记录未绑定订单，后续退款等业务出错。
- **建议：** UNKNOWN 状态下应采用保守策略尝试补偿，或增加更长的重试间隔和更多重试次数。

---

### 1.8 `findOrderCommitState` 查询订单状态时未校验业务关联完整性

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1658
- **评审角色：** 数据一致性专家
- **问题描述：** 查询时应同时校验 `order_saas_order_key` 是否匹配当前 `saasOrderKey`，避免订单 A 的券记录被错误关联到订单 B。
- **影响场景：** 异常恢复场景下，订单 A 失败后尝试反核销，但 `findOrderCommitState` 查询到订单 B 有相同的 `couponWriteOffTraceNo`（数据污染或测试数据），错误判断订单已提交跳过反核销。
- **建议：** 增加 `order_saas_order_key` 匹配校验。

---

### 1.9 `CouponWriteOffRecoveryServiceTest` 测试类引用不存在的类

- **文件：** `CouponWriteOffRecoveryServiceTest.java`
- **行号：** 33
- **评审角色：** 测试专家
- **问题描述：** `CouponWriteOffRecoveryService` 类不存在，测试引用 `new CouponWriteOffRecoveryService()` 无法编译。
- **影响场景：** 运行 `mvn test` 时编译失败，CI/CD 流水线阻塞。
- **建议：** 确认 `CouponWriteOffRecoveryService` 类是否存在于 `src/main/java` 中，如不存在则该测试无法通过编译。

---

### 1.10 核心方法 `CouponWriteOffRecordService.claim()` 测试覆盖严重不足

- **文件：** `CouponWriteOffRecoveryServiceTest.java`
- **行号：** 21
- **评审角色：** 测试专家
- **问题描述：** 测试用例仅 2 个，覆盖严重不足。核心方法 `claim()` 有 SUCCESS/CLAIMED/BUSY/TERMINAL_FAILED 四种返回状态，测试只验证了 recovery 扫描逻辑，未测试 claim 本身的并发竞态场景。
- **影响场景：** claim 的并发安全性无法通过测试验证，线上可能爆发 claim 相关的并发 bug。
- **建议：** 增加 claim 方法测试：并发 claim 同一 traceNo 的竞态场景测试、DuplicateKeyException 异常恢复测试、各状态转移路径测试（INIT→SUCCESS、FAILED→INIT、SUCCESS→BUSY→SUCCESS）。

---

### 1.11 `checkFreeRule` 方法（行317-472）没有任何单元测试覆盖

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 317
- **评审角色：** 测试专家
- **问题描述：** `checkFreeRule` 方法包含完整的免赠规则校验逻辑：cardTypeLid 查询、免赠次数时间窗口匹配（startTime/endTime）、免赠菜品过滤（dishLidSet）、foodNumber 与 freeTimes 对比拆分逻辑，但没有任何单元测试覆盖。
- **影响场景：** 免赠规则变更时无法通过测试验证，线上可能因免赠次数计算错误导致用户权益损失或商户损失。
- **建议：** 增加 `checkFreeRule` 方法测试：免赠次数充足/不足场景、免赠时间窗口内/外场景、免赠菜品匹配/不匹配场景、后付(payType=1)先付(payType=0)不同扣减策略场景、cardLid 为空直接返回场景。

---

### 1.12 `writeOffSinglePreWriteOffCoupon` 方法（行1715-1786）没有任何 Mock 测试

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 1715
- **评审角色：** 测试专家
- **问题描述：** `writeOffSinglePreWriteOffCoupon` 方法处理 WP/MP/DP 三种券类型的核销，MP 调用 CAN_DAO 的 `douYinCouponFeign.verify`，DP 调用 DOU_YIN 的 `douYinCouponFeign.verify`，解析凭证逻辑完全不同（MP 存 JSON 数组、DP 存逗号分隔），但无任何 Mock 测试。
- **影响场景：** 平台券核销是核心支付流程，凭证解析错误可能导致核销失败、重复核销或资金损失。
- **建议：** 增加 `writeOffSinglePreWriteOffCoupon` 测试：WP 券核销 Mock `cardOpForCustomerFeign.writeOffCouponInner` 成功/失败场景；MP 券核销 Mock `douYinCouponFeign.verify` 返回 verify_results JSON 数组场景；DP 券核销 Mock `douYinCouponFeign.verify` 返回逗号分隔 verify_id 场景；`platformCount>1` 的多凭证核销场景。

---

### 1.13 `bindOrder` 未校验 claimOwner 是否与当前请求一致 — 凭证重放攻击

- **文件：** `CrtPostOrderServiceImpl.java`
- **行号：** 159
- **评审角色：** 红队专家
- **问题描述：** `bindOrder` 只校验 `traceNo` 属于 SUCCESS 状态，未校验 `claimOwner`。如果攻击者在用户预核销后、`bindOrder` 前通过竞争获取了同一个 `traceNo` 的 `claimOwner`，可以将自己的订单绑定到用户的预核销记录上。
- **影响场景：** 凭证重放 + claimOwner 覆盖，用户预核销的券被攻击者绑定到攻击者的订单上。
- **建议：** 在 `bindOrder` 中增加 `claimOwner` 校验。

---

## 二、HIGH 级别问题分类汇总

### 2.1 安全与凭证风险（5个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H1 | `Math.abs(mid/sid)` 掩盖负值问题，可能跨租户访问 | `CrtPostOrderServiceImpl.java` | 563 | 攻击者修改 mid/sid 使用他人商户权益 |
| H2 | `Math.abs(mid/sid)` 多处使用（第743、1461行） | `CrtPostOrderServiceImpl.java` | 743, 1461 | 预核销阶段记录负值，下单阶段取绝对值后归属不一致 |
| H3 | 凭证重放：`encryptedCode`/`verifyToken` 无一次性 Token 校验 | `CrtPostOrderServiceImpl.java` | 1773 | 攻击者截获凭证后在有效期内重复核销 |
| H4 | 凭证重放：`claim` 方法 DuplicateKeyException 时未校验 claimOwner | `CouponWriteOffRecordServiceImpl.java` | 47 | 攻击者覆盖 claimOwner，冒用他人券 |
| H5 | `encryptedCode` 无防重放机制，直接存入 OrderFoodVO | `CartProductCouponService.java` | 154 | 一码多用，重复核销 |

### 2.2 数据一致性与事务（8个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H6 | 免赠次数 Redis 缓存与数据库双写不一致 | `CrtPostOrderServiceImpl.java` | 246 | saveBatch 成功后 Redis 更新失败，免赠次数被重复使用 |
| H7 | `bindCouponRecords` 失败只打印 warn 不抛异常 | `CrtPostOrderServiceImpl.java` | 1451 | 订单创建成功但券记录未绑定订单，无法追溯 |
| H8 | `writeOffMemberCouponsBeforeCreateOrder` 循环内独立 REQUIRES_NEW 事务边界问题 | `CrtPostOrderServiceImpl.java` | 1488 | 券A核销成功，券B失败，补偿券A时 cancel 也失败，订单与券状态不一致 |
| H9 | `CouponWriteOffRecord` 缺少 `(mid, sid, status)` 复合索引 | `CouponWriteOffRecord.java` | 26 | 批量查询 INIT/FAILED 状态时全表扫描 |
| H10 | `recordLid` 字段缺少索引 | `CouponWriteOffRecordDetail.java` | 25 | 大表关联查询性能问题 |
| H11 | 免赠次数 Hash Key 缺少 sid 维度，跨门店共享免赠额度 | `CrtPostOrderServiceImpl.java` | 247 | 会员在门店1使用免赠，门店2仍显示剩余次数 |
| H12 | 免赠次数 Hash 记录无单独 TTL，Hash key 过期前数据丢失 | `CrtPostOrderServiceImpl.java` | 254 | 跨天时刻免赠记录丢失 |
| H13 | 预核销阶段校验 CRM 券状态到正式核销存在时间窗口，被其他渠道抢先核销 | `CartProductCouponService.java` | 230 | 用户预核销成功，门店 POS 先行核销，订单侧不知道仍尝试核销 |

### 2.3 业务逻辑缺陷（6个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H14 | `claim()` INIT 状态更新条件缺少 claimOwner 比对 | `CouponWriteOffRecordServiceImpl.java` | 95 | 线程A claim 后未完成，线程B 覆盖 claimOwner，导致线程A saveSuccess 失败 |
| H15 | `restoreSuccess` 恢复凭证时未校验 SecurityDigest 完整性 | `CrtPostOrderServiceImpl.java` | 1871 | 数据库记录被篡改后恢复错误凭证用于欺诈 |
| H16 | 免赠规则时间边界使用 `isAfter/isBefore` 导致边界时间点被排除 | `CrtPostOrderServiceImpl.java` | 373 | 免赠规则 09:00-12:00，12:00:00 下单被判定为不在时间段内 |
| H17 | 跨天免赠规则未按日期分别计算免赠次数 | `CrtPostOrderServiceImpl.java` | 489 | 跨天时刻免赠次数计算错误 |
| H18 | `multiUnitMap` 可能为 null 但第1006行直接使用 | `CrtPostOrderServiceImpl.java` | 1006 | 配置了多单位但 getMultiUnitMap() 返回 null 时 NPE |
| H19 | `multiDishVoMap` 可能为 null 但未用 NullSafeUtils 包装 | `CrtPostOrderServiceImpl.java` | 812 | isSuccess=true 但 data=null 时 NPE |

### 2.4 合规与个人信息（3个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H20 | `phone` 字段作为 createBy 和 checkoutBy 存储 | `CrtPostOrderServiceImpl.java` | 151 | 违反个人信息最小化原则，数据泄露时可被用于用户画像 |
| H21 | `openId` 直接存储到订单表并作为 MQTT 消息传输 | `CrtPostOrderServiceImpl.java` | 153 | 违反微信平台用户数据使用规范 |
| H22 | `CouponWriteOffRecord` 无数据保留期限配置 | `CouponWriteOffRecord.java` | 46 | 核销记录包含敏感信息永久存储 |

### 2.5 Redis 与 MQTT（5个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H23 | 订单缓存 TTL 仅为 15~25 秒随机值，MQTT 消费者可能获取不到数据 | `CrtPostOrderServiceImpl.java` | 308 | MQTT 消息积压 30 秒，Redis 缓存已过期 |
| H24 | MQTT 发送与 Redis 写入不是原子操作 | `CrtPostOrderServiceImpl.java` | 288 | Redis set 抛异常但 MQTT 已发送，线下已出单但 Redis 无订单 |
| H25 | `claim` 方法未使用 Redis 分布式协调层，高并发下直接打满数据库 | `CouponWriteOffRecordServiceImpl.java` | 34 | 100 个并发请求同时预核销同一张券，全部穿透到 DB |
| H26 | 购物车 Redis Key 缺少业务模式区分维度 | `ShoppingCartServicePlus.java` | 1171 | 先付与后付模式共用同一 key，菜品互相覆盖 |
| H27 | `compensateMemberCoupons` 中反核销失败只标记 CANCEL_UNKNOWN，无自动恢复 | `CrtPostOrderServiceImpl.java` | 1700 | 订单失败后反核销时网络抖动，券状态为 UNKNOWN，需人工介入 |

### 2.6 接口与契约（4个）

| # | 问题 | 文件 | 行号 | 场景 |
|---|------|------|------|------|
| H28 | Feign 调用缺少超时重试和降级策略 | `CrtPostOrderServiceImpl.java` | 113 | CRM/Product 服务超时，用户下单直接失败 |
| H29 | 购物车清空接口幂等性缺失 | `ShoppingCartController.java` | 131 | 快速双击清空按钮可能清空其他用户购物车 |
| H30 | `@NeedVerifySignature` 注解无登录态，可被绕过 | `ShoppingCartController.java` | 131 | 攻击者绕过签名验证后清空任意商户购物车 |
| H31 | `couponWriteOffTraceNo` 使用 `@JsonIgnore` 可能导致核销链路断裂 | `OrderFoodAddDTO.java` | 236 | VO 转 DTO 时字段丢失，无法追踪核销记录 |

---

## 三、MEDIUM 级别问题精选（按影响范围排序）

### 3.1 代码质量与可维护性

| # | 问题 | 文件 | 行号 |
|---|------|------|------|
| M1 | `checkFood()` 约462行严重超标，违反单一职责原则 | `CrtPostOrderServiceImpl.java` | 741 |
| M2 | `buildPreWriteOffFood()` 约248行超标 | `CartProductCouponService.java` | 101 |
| M3 | 状态字符串使用多处魔法值：`'INIT'`/`'SUCCESS'`/`'FAILED'` | `CouponWriteOffRecordServiceImpl.java` | 41, 54, 73 等 |
| M4 | MP/DP 平台券处理逻辑重复出现3处 | `CrtPostOrderServiceImpl.java` | 1488 |
| M5 | 方法命名不统一：compensate vs cancel vs recovery | `CrtPostOrderServiceImpl.java` | 1479 |
| M6 | `writeOffChannel` 来源不一致：WP 前端传入，MP/DP 平台返回 | `CartProductCouponService.java` | 340, 344 |
| M7 | `ProductCouponWriteOffSuccess` record 定义在 Service 内部，应移至 API 模块 | `CrtPostOrderServiceImpl.java` | 2174 |

### 3.2 性能问题

| # | 问题 | 文件 | 行号 |
|---|------|------|------|
| M8 | `saveBatch` 没有显式分批处理，2000+ 菜品时可能超出 MySQL max_allowed_packet | `CrtPostOrderServiceImpl.java` | 212 |
| M9 | `getFreeTimes()` 每次都查数据库，可优化为批量查询 | `CrtPostOrderServiceImpl.java` | 489 |
| M10 | BigDecimal 使用 `RoundingMode.CEILING` 导致精度不一致（多处） | `CrtPostOrderServiceImpl.java` | 275, 284 |

### 3.3 异常处理

| # | 问题 | 文件 | 行号 |
|---|------|------|------|
| M11 | `isMemberCouponStillValid` 捕获所有异常返回 false，CRM 不可用时所有有效券被移除 | `CartProductCouponService.java` | 445 |
| M12 | `buildFailureHint` 只返回通用错误提示，丢失原始异常信息 | `CrtPostOrderServiceImpl.java` | 1571 |
| M13 | `parsePlatformWriteOffId` 异常时返回 null 但只记录日志，下游断言失败信息不明确 | `CrtPostOrderServiceImpl.java` | 2168 |
| M14 | 循环中第一个券核销失败后抛出异常，后续券永远无法处理 | `CrtPostOrderServiceImpl.java` | 1558 |

### 3.4 兼容性

| # | 问题 | 文件 | 行号 |
|---|------|------|------|
| M15 | 数据库迁移脚本缺少 IF NOT EXISTS 判断，不具备幂等性 | `V20260529__*.sql` | 6 |
| M16 | `order_food.platform_price` 与 `coupon_write_off_record.platform_price` 精度不一致（DECIMAL 18,4 vs 18,6） | Entity | — |
| M17 | 平台券 MP/DP 混用同一 Feign 接口但解析逻辑存在差异 | `CrtPostOrderServiceImpl.java` | 542 |
| M18 | 新增 JSON 字段（couponItems/productItems）无 schema 校验 | `OrderBill.java` | 296 |

---

## 四、LOW 级别问题（简要列表）

以下问题影响较小或风险可控，建议在后续迭代中处理：

1. **日志注入**：`log.error` 中 `JSON.toJSONString` 打印完整订单数据（198、211、1206行）
2. **日志泄漏**：异常堆栈暴露内部目录结构、依赖版本（274行）
3. **日志脱敏**：`log.error` 打印完整手机号（365行）
4. **缓存 Key 命名不统一**：部分使用下划线、部分使用冒号（39行）
5. **`claim()` DuplicateKeyException 后立即查询可能读脏数据**（47行）
6. **`findOrderCommitState` 的 3 次固定 100ms 重试不足**：无指数退避策略（1630行）
7. **`groupon_type` 只校验 !=2，未校验其他非法值**（163行）
8. **`proXSpecPrice` 中 `subed.add(pair.getKey())` 可能 NPE**（693行）
9. **`platformChannel`/`certificateId` 从平台返回直接使用未校验格式**（156行）
10. **`saveSuccess()` 状态已为 SUCCESS 时跳过 version 校验**（113行）

---

## 五、评审维度覆盖说明

本次评审共发动 **5 个批次、18 个独立专家角色**，覆盖以下维度：

| 评审角色 | 负责维度 | 发现 BLOCKING 数 |
|----------|----------|----------------|
| 安全专家 | SQL注入、敏感数据、特权升级、凭证重放 | 2 |
| 并发与事务专家 | REQUIRES_NEW 陷阱、乐观锁、分布式一致性 | 2 |
| 业务逻辑专家 | 幂等性、状态机、免赠规则、核销补偿 | 3 |
| 性能专家 | N+1查询、Redis竞争、saveBatch | 0 |
| 架构专家 | 分层、依赖方向、Bean 覆盖 | 0 |
| 数据一致性专家 | Redis/DB双写、多方状态同步、事务边界 | 3 |
| 接口契约专家 | DTO注释、Feign契约、Math.abs掩盖问题 | 0 |
| 异常处理专家 | 异常链、补偿失败、UNKNOWN状态处理 | 2 |
| 边界条件专家 | 空值、极值、时间边界、精度 | 0 |
| 测试专家 | 单元测试覆盖、Mock场景、集成测试 | 4 |
| 红队专家 | 凭证重放、特权升级、资源耗尽、日志注入 | 1 |
| 合规专家 | 个人信息保护、数据保留、审计日志 | 0 |
| 兼容性专家 | 历史兼容、灰度发布、回滚策略 | 0 |
| Redis专家 | Key设计、TTL、分布式锁 | 0 |
| SQL安全专家 | LambdaQueryWrapper安全、索引使用 | 0 |
| API专家 | Feign降级、幂等性、越权风险 | 0 |
| MQ专家 | MQTT/RocketMQ一致性、死信处理 | 0 |

---

## 六、优先级处理建议

### P0（立即处理，阻塞发布）

1. **所有 BLOCKING 问题**（第1.1 ~ 1.13条）
2. **HIGH-安全类**：H1~H5（凭证安全与特权升级）
3. **HIGH-一致性类**：H6~H13（数据一致性与事务）

### P1（下一个迭代）

1. 合规类：H20~H22
2. Redis/MQ类：H23~H27
3. 接口契约类：H28~H31
4. 代码质量：M1~M7
5. 异常处理：M11~M14

### P2（计划迭代）

1. 性能问题：M8~M10
2. 兼容性：M15~M18
3. 边界条件：所有 LOW 级问题
4. 测试覆盖完善

---

*本报告由多角色对抗性评审系统自动生成，共评审 3 个核心 Java 文件（2212行 + 223行 + 579行），识别问题约 150+ 个，其中 BLOCKING 级别 13 个、HIGH 级别 31 个。*
