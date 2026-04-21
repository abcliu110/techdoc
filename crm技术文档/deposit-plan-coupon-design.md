git # 新储值方案发券与老充值发券异同设计说明

## 1. 文档目的

本文档用于整理 `nms4cloud-crm` 中以下两套发券链路的实现方式、公共能力、差异点和当前设计结论：

- 老充值链路
- 新储值方案链路

重点说明以下问题：

- 老充值如何发普通券
- 老充值如何发券包
- 新储值方案如何发普通券
- 新储值方案如何发券包
- 两套链路最终是否复用同一套发券引擎
- 券包发放时库存如何扣减
- 发券结果如何落库
- 当前新储值方案与老充值链路的相同点和不同点

## 2. 范围说明

本文档只讨论 CRM 内部“发券”相关逻辑，不展开支付渠道、订单关闭、退款逆向、前端展示等非核心内容。

本文档覆盖的主要代码位置如下：

- `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/charge/ChargeService.java`
- `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/balance/CardBalanceService.java`
- `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/charge/DepositPlanChargeService.java`
- `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/charge/DepositPlanCouponService.java`
- `nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/card/CrmCouponOpServicePlus.java`
- `nms4cloud-crm-api/src/main/java/com/nms4cloud/crm/api/model/DepositTierRule.java`
- `nms4cloud-crm-api/src/main/java/com/nms4cloud/crm/api/request/charge/ChargeNotifyAttach.java`
- `nms4cloud-crm-dao/src/main/java/com/nms4cloud/crm/dao/entity/CrmCouponOrder.java`
- `nms4cloud-crm-dao/src/main/java/com/nms4cloud/crm/dao/entity/CrmDepositCouponSchedule.java`

## 3. 核心结论

### 3.1 总体结论

老充值链路和新储值方案链路在“业务编排层”并不相同，但在“最终发券执行层”复用了同一套统一发券引擎 `CrmCouponOpServicePlus`。

### 3.2 当前状态结论

当前代码中：

- 新储值方案的普通券发放，始终是直接按普通券列表发放
- 新储值方案的券包发放，已经调整为按 `packageLid + packageQty` 调用统一发券服务
- 因此，新储值方案的“券包发放方式”已经与老充值链路一致
- 但从完整业务链路看，新储值方案与老充值链路仍然存在档位来源、建单方式、周期发放能力等差异

### 3.3 发券结果结论

无论老充值还是新储值方案，只要最终进入统一发券服务：

- 普通券会直接生成普通券订单
- 券包会先展开成子券，再生成多条普通券订单
- `crm_coupon_order` 中保存的是展开后的子券记录
- 如果来源是券包，每条子券记录会额外记录券包来源字段

## 4. 相关数据模型

### 4.1 老充值规则模型

老充值规则主要使用 `CrmSaveRule` 中的赠券字段：

- `giveCouponId`
- `giveCoupon`
- `giveCouponNum`

这组字段只保存一个赠券标识。这个标识既可能是普通券 ID，也可能是券包 ID。

### 4.2 新储值方案模型

新储值方案使用 `DepositTierRule.TierConfig` 描述每个档位的赠品配置，主要包括：

- `coupons`：直接赠送的普通券列表
- `couponPackages`：赠送的券包列表
- `issueRuleType`：一次性发放或周期发放
- `issueCycleType` / `issueCycleValues` / `issueTime` / `issueTimes`
- `firstIssueImmediate`

券包项 `CouponPackageItem` 主要字段如下：

- `packageLid`：券包 ID
- `packageQty`：本次发放的券包数量
- `coupons`：券包内券列表，仅用于配置、校验、展示

### 4.3 统一发券输入模型

统一发券服务的输入核心是 `CouponIssuanceDTO`：

- `couponCode`：要发的券 ID
- `couponNum`：要发的数量

这里的 `couponCode` 并不限定只能是普通券，也可以是券包 ID。是否属于券包，最终由 `CrmCoupon.isPkg` 决定。

### 4.4 发券结果模型

发券结果落在 `CrmCouponOrder` 表，对应实体 `CrmCouponOrder`，其中与券包相关的重要字段包括：

- `coupon`
- `couponCode`
- `pkgCoupon`
- `pkgCouponCode`
- `orderBillId`
- `getChannel`

含义如下：

- `coupon/couponCode`：实际发出去的那张券
- `pkgCoupon/pkgCouponCode`：如果这张券来自券包，记录其所属券包

## 5. 老充值发券流程

### 5.1 配置来源

老充值的赠券来源于 `CrmSaveRule`。

当规则保存赠券配置时，会把赠券对应的 `CrmCoupon` 记录下来，并将其 ID 放到 `giveCouponId` 中。这个 ID 既可能是普通券，也可能是券包。

### 5.2 建单阶段

老充值在创建 `CrmDealTaskItem` 时，会把赠券信息写入任务子项，包括：

- `giveCoupon`
- `giveCouponId`
- `giveCouponNum`
- `firstChargeGiftCoupon`

因此，后续发券不需要重新解析规则，只需要读取任务子项上的赠券信息即可。

### 5.3 发券触发阶段

老充值的发券触发点在余额处理流程中，由 `CardBalanceService` 执行。

执行过程如下：

1. 读取 `CrmDealTaskItem.giveCouponId`
2. 读取 `CrmDealTaskItem.giveCouponNum`
3. 构造 `CouponOpAddDTO`
4. 调用 `crmCouponOpServicePlus.couponOpAdd(...)`

此处并不会在外层区分“普通券还是券包”，只是把 `giveCouponId` 原样作为 `couponCode` 传入。

### 5.4 老充值发普通券

如果 `giveCouponId` 对应的是普通券：

1. `couponOpAdd(...)` 查询 `CrmCoupon`
2. 发现 `isPkg = false`
3. 进入 `toNormal(...)`
4. 根据数量循环生成 `CrmCouponOrder`
5. 批量保存到 `crm_coupon_order`

### 5.5 老充值发券包

如果 `giveCouponId` 对应的是券包：

1. `couponOpAdd(...)` 查询 `CrmCoupon`
2. 发现 `isPkg = true`
3. 进入 `toPkg(...)`
4. 按券包主券 ID 查询 `CrmCouponMap.mainCode`
5. 找到券包内子券和子券数量
6. 查询所有子券对应的 `CrmCoupon`
7. 按“子券数量 x 券包发放数量”展开
8. 调用 `toNormal(...)` 生成子券订单
9. 给每条子券订单补充 `pkgCoupon/pkgCouponCode`
10. 批量保存到 `crm_coupon_order`

### 5.6 老充值链路特点

- 业务上只关注一个 `giveCouponId`
- 外层不关心它是普通券还是券包
- 发券分流完全在统一发券服务内部完成
- 任务子项是发券的稳定数据来源

## 6. 新储值方案发券流程

### 6.1 配置来源

新储值方案不再依赖 `CrmSaveRule.giveCouponId`，而是直接从储值方案档位 `TierConfig` 中读取配置。

每个档位可以同时具备以下发放内容：

- 多张普通券
- 多个券包
- 积分
- 会员等级升级

### 6.2 支付成功后处理

新储值方案支付成功后，由 `DepositPlanChargeService` 完成后置处理：

1. 更新购买记录成功状态
2. 更新方案销售统计
3. 解析当前档位 `TierConfig`
4. 调用 `depositPlanCouponService.handleGiftIssuance(...)`
5. 调用会员升级处理
6. 调用积分处理

### 6.3 新储值方案一次性发券

一次性发券由 `DepositPlanCouponService.issueOneTime(...)` 处理。

发放分成两部分：

1. 发放普通券
2. 发放券包

#### 6.3.1 普通券部分

普通券发放读取 `tier.getCoupons()`。

每个 `CouponItem` 使用：

- `couponLid` 作为发券标识
- `issueQtyPerTime` 作为本次发放数量

然后统一组装为 `CouponIssuanceDTO` 列表，再调用 `couponOpAdd(...)`。

#### 6.3.2 券包部分

当前代码已经调整为读取 `tier.getCouponPackages()`，每个 `CouponPackageItem` 使用：

- `packageLid` 作为发券标识
- `packageQty` 作为本次发放数量

再组装为 `CouponIssuanceDTO` 列表，调用 `couponOpAdd(...)`。

这一点与老充值“把券包 ID 直接传入统一发券服务”的实现方式一致。

### 6.4 新储值方案周期发券

如果档位配置为周期发放，则不会在支付成功时一次性把所有券发完，而是：

1. 创建 `CrmDepositCouponSchedule`
2. 保存当前档位快照 `tierSnapshot`
3. 根据周期类型计算 `nextIssueDate`
4. 如果 `firstIssueImmediate = true`，先执行一次发放
5. 后续由定时任务读取计划表
6. 调用 `executeScheduledIssuance(...)`
7. 重新使用快照中的 `TierConfig` 执行 `issueOneTime(...)`

因此，新储值方案天然支持“首发 + 后续分期发放”，这是老充值链路没有的能力。

## 7. 两套链路共享的统一发券引擎

### 7.1 入口

统一发券入口是：

- `CrmCouponOpServicePlus.couponOpAdd(CouponOpAddDTO)`

它负责：

- 校验会员卡
- 校验手机号
- 校验发券列表
- 加载 `CrmCoupon`
- 检查库存及发放限制
- 执行普通券或券包发放
- 批量保存券订单

### 7.2 普通券处理

普通券使用 `toNormal(...)` 生成订单。

核心行为包括：

- 计算有效期
- 计算生效时间
- 设置渠道
- 设置订单号
- 写入会员信息
- 逐张生成 `CrmCouponOrder`

### 7.3 券包处理

券包使用 `toPkg(...)` 处理。

核心行为包括：

- 读取券包与子券的映射关系
- 查出全部子券定义
- 按映射数量展开实际发券数量
- 复用普通券发放逻辑生成子券订单
- 在子券订单上标记券包来源

### 7.4 落库行为

统一发券服务最终统一执行：

- `iCrmCouponOrderService.saveBatch(orderList)`

所以无论来源是老充值还是新储值方案，只要进入统一发券服务，最终落库行为保持一致。

## 8. 新旧链路相同点

### 8.1 都复用同一套统一发券服务

老充值和新储值方案最终都调用 `crmCouponOpServicePlus.couponOpAdd(...)`。

### 8.2 普通券最终都走同一套普通券发放逻辑

两者都会在统一发券服务内部进入 `toNormal(...)`。

### 8.3 券包最终都走同一套券包展开逻辑

两者都会在统一发券服务内部进入 `toPkg(...)`。

### 8.4 发券结果都统一落到 `crm_coupon_order`

普通券直接落普通券记录；券包先展开子券，再落子券记录。

### 8.5 券包来源信息保存方式一致

如果订单来源于券包，都会在 `CrmCouponOrder` 中写：

- `pkgCoupon`
- `pkgCouponCode`

### 8.6 库存扣减规则一致

两者都在统一发券入口先对“传入的券”扣库存：

- 传普通券 ID，则扣普通券库存
- 传券包 ID，则扣券包库存

## 9. 新旧链路不同点

### 9.1 配置来源不同

老充值来自 `CrmSaveRule` 的单个赠券字段。  
新储值来自 `TierConfig` 的结构化档位配置。

### 9.2 能力范围不同

老充值主要支持：

- 单个赠券或单个券包
- 首充赠券等传统规则

新储值支持：

- 多张普通券
- 多个券包
- 一次性发放
- 周期发放
- 首次立即发放
- 会员等级升级
- 积分发放

### 9.3 建单方式不同

老充值把赠券信息写入 `CrmDealTaskItem`，后续发券读取任务子项即可。  
新储值明确不依赖 `giveCouponId/giveCouponNum`，而是在支付成功后直接按档位配置独立发券。

### 9.4 回调取数据方式不同

老充值的赠券来源更偏向“建单时已固化的数据”。  
新储值支付成功时，会调用 `resolveTier(...)` 重新取档位数据。

如果 `ChargeNotifyAttach.tierSnapshot` 为空，则当前实现会：

1. 再次查询储值方案
2. 根据 `tierIndex` 重新读取当前档位

这意味着新储值对运行时方案配置更敏感。

### 9.5 周期任务持久化不同

新储值引入了 `crm_deposit_coupon_schedule` 表保存周期发券计划。  
老充值链路没有这张计划表，也没有同类调度流程。

## 10. 券包相关的关键设计点

### 10.1 券包配置和券包发放不是一回事

在新储值方案配置中，`couponPackages[].coupons` 表示“券包内券列表”，主要用于：

- 配置校验
- 列表展示
- 回显展示

它不应该直接作为最终发券指令使用。

### 10.2 正确的券包发放方式

正确的券包发放方式应该是：

1. 传入 `packageLid`
2. 传入 `packageQty`
3. 交给统一发券服务
4. 由统一发券服务判断 `isPkg`
5. 查询券包映射并展开子券

这也是当前代码已经采用的实现方式。

### 10.3 落库结果不是“存一条券包”

券包发放最终不会只生成一条“券包订单”。

真正落库的是：

- 多条子券订单
- 每条子券订单上带券包来源信息

因此查询会员优惠券时，看到的是实际可用的子券，而不是一个不可直接核销的“券包壳记录”。

## 11. 当前实现的风险点

### 11.1 档位快照已改为购买记录持久化

当前实现不再把完整档位快照放进支付回调附件，而是：

1. 下单时把档位快照写入 `crm_deposit_charge_record.tier_snapshot`
2. 支付成功时优先读取购买记录中的档位快照
3. 周期发券计划继续保存自己的 `tierSnapshot`

这样可以避免支付 `attach` 长度不足，也能降低方案中途修改导致的权益漂移风险。

### 11.2 主交易成功后，权益处理不是全局强一致事务

支付成功后的处理顺序大致是：

1. 余额入账
2. 更新购买记录状态
3. 更新方案销售统计
4. 发放赠品（优惠券/券包）
5. 处理会员等级升级
6. 处理积分

其中，赠品发放、会员升级、积分处理位于余额成功之后的后置流程。  
如果这部分发生异常，当前实现会记录日志，但不会把已经成功的余额入账整体回滚。

### 11.3 购买限制仍缺少并发安全保护

当前购买限制校验仍然是“先查询、再创建支付中记录”的模式：

1. 先检查每人限购 / 周期限购 / 售卖总量限制
2. 再创建 `crm_deposit_charge_record`

在高并发下，多个请求可能同时通过校验，随后一起落单，导致：

- 超过每人限购次数
- 超过总售卖量
- 超过周期售卖量

这一点仍需要通过锁或原子占位机制补齐。

## 12. 建议的设计认知

### 12.1 应把“统一发券引擎”视为唯一真实发券层

业务层不应在外部重复实现：

- 券包展开
- 子券数量换算
- 券包来源标记
- 订单落库逻辑

这些都应该统一下沉到 `CrmCouponOpServicePlus`。

### 12.2 业务层只负责组织发券输入

老充值和新储值方案在上层只需要负责：

- 决定什么时候发
- 决定发给谁
- 决定发什么
- 决定发多少

发券细节应统一交给公共引擎。

### 12.3 老代码发券的事务边界

老代码和当前新储值方案在“统一发券引擎”这一层的事务语义是一致的。

普通券或券包发放时，统一发券服务会先执行库存扣减，再生成券订单：

1. 先扣券真实库存（普通券扣普通券库存，券包扣券包库存）
2. 再展开券包或生成普通券订单
3. 最后批量保存 `crm_coupon_order`

这几个动作位于同一个数据库事务中，因此：

- 如果发券事务内部后续步骤失败，前面的库存扣减会一起回滚
- 不会出现“库存已扣减，但券订单完全未落库”的半成功状态

### 12.4 新储值方案的事务边界

新储值方案可以分成两层来看：

第一层：统一发券内部事务

- 普通券发放最终调用 `CrmCouponOpServicePlus.couponOpAdd(...)`
- 券包发放同样调用统一发券服务
- 扣库存、展开券包、生成券订单、保存券订单在同一事务内

因此，发券内部失败时，券库存会回滚。

第二层：支付成功后的外围业务流程

- 余额入账
- 更新购买记录成功状态
- 更新方案销量统计
- 发放赠品
- 会员等级升级
- 积分处理

这一层不是跨余额、发券、升级、积分的全局强一致事务。  
也就是说：

- 如果余额已经成功
- 后续赠品发放、会员升级或积分处理失败

当前实现不会把余额入账整体回滚，而是记录日志并进入后续补偿/排查范围。

### 12.3 券包配置列表应视为展示和校验数据

新储值方案中的券包内券列表，应视为配置辅助信息，而不是运行时发券的唯一依据。

运行时真正执行时，应以：

- `packageLid`
- 券包主数据
- 券包映射表 `CrmCouponMap`

作为最终依据。

## 13. 测试建议

建议至少覆盖以下场景：

### 13.1 普通券一次性发放

- 配置 1 张普通券
- 支付成功后检查会员是否收到对应数量的券
- 检查 `crm_coupon_order.couponCode`

### 13.2 单个券包一次性发放

- 配置 1 个券包
- 券包中配置多个子券和不同数量
- 支付成功后检查是否生成多条子券订单
- 检查 `pkgCoupon/pkgCouponCode`

### 13.3 同时配置普通券和券包

- 检查两部分是否都发出
- 检查普通券和券包子券订单是否同时存在

### 13.4 周期发放

- 创建周期计划
- 检查首次立即发放
- 检查定时任务执行后 `issuedTimes` 是否递增
- 检查后续是否继续生成券订单

### 13.5 方案变更场景

- 下单后修改档位
- 观察支付成功发放内容是否变化
- 验证是否需要补充 `tierSnapshot` 下单固化

## 14. 最终结论

新储值方案与老充值链路的关系可以概括为：

- 上层业务组织方式不同
- 发券输入来源不同
- 周期能力不同
- 但最终发券引擎相同

其中，“券包发放”这一核心问题，当前代码已经调整为与老充值链路一致，即：

- 传入券包 ID
- 由统一发券服务识别 `isPkg`
- 按券包映射展开子券
- 保存子券订单并记录券包来源

当前仍需关注的设计风险主要集中在：

- 新储值支付成功时档位数据的来源是否固化
- `tierSnapshot` 是否应在下单时完整写入支付回调附件
