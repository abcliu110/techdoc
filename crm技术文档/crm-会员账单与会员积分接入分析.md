# CRM 会员账单与会员积分接入分析

## 1. 结论摘要

当前 CRM 与订单链路里，会员相关能力已经分成三类并且部分跑通：

1. 会员折扣/会员价
2. 会员卡支付
3. 积分抵现

但新建的 `crm_points_rule` 这套积分权益规则，目前还没有真正接入现有结账主链路的自动赠分计算。换句话说，当前系统已经支持“消费时透传赠送积分并入账”，但还不支持“结账时自动读取 `crm_points_rule` 并计算赠分”。

账单也不是只有一份：

- 云端业务账单是 `order_bill`
- POS/BI 原始账单是 `dwd_bill`
- 某些线下后付/拉单场景下，云端会基于 POS 返回的数据保存一份 `order_bill` 镜像，供支付、会员、优惠券、积分等业务使用

因此，如果要把会员积分功能完整接入，正确的落点不是直接改 POS 账单，而是：

- 以 `order_bill` 作为积分计算主账单
- 以 `dwd_bill` 作为线下原始账单来源与对账依据
- 在订单结账链路中按 `crm_points_rule` 计算应赠积分
- 继续复用 CRM 现有的积分账务与积分流水能力落账

## 2. 当前账单模型与会员账单特征

### 2.1 两层账单模型

当前项目里，账单存在两层：

#### 云端业务账单：`order_bill`

对应实体：

- `nms4cloud-app/3_customer/nms4cloud-order/nms4cloud-order-dao/src/main/java/com/nms4cloud/order/dao/entity/OrderBill.java`

关键字段：

- `saasOrderKey`：云端订单号/业务主键
- `lid`：云端账单逻辑编号
- `orgBillId`：线下原始账单号
- `cardLid` / `cardNo`：会员身份绑定信息
- `discountRate` / `discountRange`：会员折扣/折扣规则信息
- `isVipPrice`：是否使用会员价
- `paidAmount`：应付/实付基准金额
- `checkoutTime` / `checkoutBy`：结账信息

#### POS 原始账单：`dwd_bill`

对应实体：

- `nms4cloud-app/2_business/nms4cloud-pos/nms4cloud-pos-dal/src/main/java/com/nms4cloud/pos/dal/entity/DwdBill.java`

关键字段：

- `lid`：POS 账单逻辑编号
- `saasOrderKey`：反向挂接云端订单号
- `saasOrderNo`：反向挂接云端订单逻辑编号
- `reportDate`：营业日期
- `paidAmount`：账单支付金额
- `checkoutTime`：POS 结账时间

### 2.2 两者的关系

不是二选一，而是并存：

- `dwd_bill` 是门店 POS/BI 的原始消费账单
- `order_bill` 是云端业务账单
- 线下后付/拉单场景下，系统会先从门店/POS 拉取线下账单，再在云端保存 `order_bill`
- `order_bill.orgBillId` 用来关联 POS 原始账单号
- `dwd_bill.saasOrderKey / saasOrderNo` 用来反向关联云端订单

### 2.3 什么是会员账单

本次文档采用“所有会员身份绑定账单”口径。

即只要订单能够明确识别出会员身份，就视为会员账单。判定优先级如下：

1. `order_bill.cardLid` 非空
2. `order_bill.cardNo` 非空
3. 下单或购物车阶段已经按会员身份计算了会员折扣/会员价
4. 支付阶段存在会员卡支付或积分支付

会员账单不等于“必须会员卡付款”。

以下都应视为会员账单：

- 用会员价/会员折扣下单，但用微信付款
- 会员卡支付
- 积分抵现
- 会员卡支付 + 微信混合支付
- 会员卡支付 + 优惠券 + 积分抵现混合支付

## 3. 当前会员消费相关能力的真实实现

## 3.1 会员折扣/会员价

会员折扣发生在下单或购物车阶段，而不是支付阶段。

关键入口：

- `ShoppingCartServicePlus.getOrderDiscount()`
- `CrtPreOrderServiceImpl.setOrderDiscount()`
- `CrtTakeOrderServiceImpl.setOrderDiscount()`

当前实现特征：

- 如果请求里带了 `cardLid`，系统会查询会员卡或会员卡类型
- 再根据会员卡类型/折扣规则生成 `discountRate`
- 折扣结果会写到 `order_bill.discountRate / discountRange / discountBy`
- 对应菜品折扣会写到 `order_food.discountRate / foodDiscountRate / discountRange`

因此，会员折扣是“订单金额形成过程的一部分”，会直接影响后续积分计算基数。

## 3.2 会员卡支付

会员卡支付发生在支付阶段。

主入口：

- `PayOrderServiceImpl.checkCrmPay()`
- `PayTypeEnum.CRM`

执行链路：

1. Order 侧识别 `CRM` 支付腿
2. 根据会员卡余额、支付比例限制等规则计算本次会员卡实际支付金额
3. 调用 CRM `cardConsumeInner`
4. CRM 侧进入 `CrmCardOpServicePlus.cardConsume()`
5. 再进入 `CardBalanceService.execute()` 执行余额变更、流水落库、任务更新

这条链路已经是当前会员消费主链路之一。

## 3.3 积分抵现

积分抵现同样发生在支付阶段。

主入口：

- `PayOrderServiceImpl.checkPointsPay()`
- `PayTypeEnum.PR`

当前实现：

- 从门店支付配置 `BizPayWayVO` 中读取：
  - `pointsRate`
  - `pointsBillRate`
- 按剩余应付金额、最高抵现比例、当前会员积分余额，计算：
  - 本次可抵现金额
  - 本次需要扣除的积分数
- 支付执行时调用 CRM 的 `adjustPointsInner`
- CRM 通过 `adjustPoints()` 修改积分余额并生成积分流水

所以当前“积分”能力里，真正已经稳定在线的是积分抵现，不是消费送积分。

## 3.4 CRM 里的积分入账能力

CRM 侧已经具备“消费时赠送积分并落账”的能力，但赠送积分值需要上游传入。

关键 DTO：

- `CrmCardOpConsumeDTO.givePoint`

关键链路：

- `CrmCardOpServicePlus.cardConsume()`
- `CardBalanceService.execute()`
- `CardBalanceService.genPointsRecord()`

当前逻辑是：

- 订单支付时如果调用 CRM 消费接口，并透传了 `givePoint`
- CRM 会把本次赠分写入 `CrmDealTask.givePoint`
- 执行余额/消费任务时更新会员卡积分余额
- 生成 `CrmCardPointsRecord`
- 在积分记录里通过 `orderBillId` 记录来源订单号

这说明当前 CRM 不缺“积分账务能力”，缺的是“结账时自动算赠分”。

## 4. 为什么说 `crm_points_rule` 还没真正接入

当前 `crm_points_rule` 已完成的部分：

- 表结构
- DTO / VO
- Controller
- Service 校验逻辑
- CRUD 能力

对应入口：

- `CrmPointsRuleController`
- `CrmPointsRuleServicePlus`
- `crm_points_rule`

规则内容已经覆盖：

- 消费送积分总开关
- 积分模式
- 商品范围
- 会员等级赠分规则
- 单笔上限
- 生日/会员日多倍积分
- 周期/时段
- 企微专享
- 场景/渠道限制
- 积分抵现规则
- 过期清零规则

但是在现有结账主链路中，没有看到任何地方：

- 查询 `crm_points_rule`
- 根据订单、菜品、支付腿、会员等级、生日、企微身份去计算 `givePoint`
- 再把计算结果写回 `CrmCardOpConsumeDTO.givePoint`

所以当前结论必须明确：

`crm_points_rule` 目前是规则配置面，不是已上线的自动赠分引擎。

## 5. 会员积分功能如何接入

本节给出“一次性完整接入 `crm_points_rule`” 的设计方案。

### 5.1 接入原则

1. Order 负责积分计算
2. CRM 负责积分记账
3. `order_bill` 作为积分计算主账单
4. `dwd_bill` 只作为原始账单来源，不直接参与积分计算
5. 所有赠分都要可追溯、可撤销、可重放

### 5.2 计算主入口

建议在 Order 支付成功主链路中新增“赠分计算与发放”步骤。

推荐接入点：

- `PayOrderServiceImpl.updateAndSave()` 之后
- 仅在订单最终进入 `CHECKED` 或业务定义的“已完成可积分”状态后触发

原因：

- 此时订单金额、支付腿、优惠券、积分抵现、会员卡支付结果都已确定
- 不会因为中途支付失败导致重复或错误赠分
- 撤销时也容易按订单维度回滚

### 5.3 会员账单积分计算输入

统一从以下数据组装计算上下文：

#### 订单主数据

来自 `order_bill`：

- `mid`
- `sid`
- `saasOrderKey`
- `lid`
- `orgBillId`
- `paidAmount`
- `discountRate`
- `discountRange`
- `cardLid`
- `cardNo`
- `checkoutTime`
- `orderSubType`
- `channelName`
- `payType`

#### 菜品明细

来自 `order_food`：

- `foodNo`
- `foodUnit`
- `foodAmount`
- `paidAmount`
- `discountAmount`
- `sendNumber`
- `cancelNumber`

#### 支付明细

来自 `order_pay`：

- `type`
- `payAmount`
- `amount`
- `isRealIncome`
- `points`
- `couponNo`

#### 会员上下文

来自 CRM：

- `CrmCardVO.cardTypeLevelCode`
- `CrmCardVO.cardTypeCode`
- `CrmCardVO.unionid`
- `CrmCardVO.phone`

同时新增一个 CRM 内部查询，用于补充积分规则计算所需但订单侧拿不到的数据：

- `CrmMemberVO.birthday`
- 企微会员资格/类型
- 会员主体信息

建议新增“会员积分上下文查询”接口，而不是在 Order 侧拼多个散调用。

### 5.4 规则选择

计算时按以下维度定位规则：

- `mid`
- `sid`
- `planLid`

实现上需要先明确“会员卡 -> 会员方案”的映射来源。
当前 `crm_points_rule` 是按 `planLid` 挂规则，因此完整接入必须补足：

- 订单中的会员卡如何找到所属会员方案

若当前会员卡模型里没有现成直连字段，则需要新增一层 CRM 查询或映射能力。

### 5.5 积分计算口径

#### 一、总开关

- `pointsRuleEnabled=0` 时，本单不赠分

#### 二、消费送积分开关

- `earningEnabled=0` 时，本单不赠分

#### 三、积分模式

##### 模式 A：按支付方式实收积分

积分基数取最终支付明细汇总，但只统计满足以下条件的支付腿：

- `order_pay.isRealIncome = true`
- 支付方式配置 `BizPayWayVO.canIntegral = true`
- 排除优惠券腿
- 排除积分抵现腿

会员卡支付腿是否参与积分，继续由支付方式配置决定，而不是硬编码。

##### 模式 B：按商品实收积分

积分基数取 `order_food.paidAmount` 汇总，并过滤：

- 赠送菜
- 退菜
- 不参与赠分的商品

商品范围按 `earningProductScopeType + earningSpecifiedProductLids` 判定。

#### 四、会员等级赠分

使用 `levelRates`，按会员等级匹配：

- `memberLevelId = cardTypeLevelCode`

每条规则的含义保持与当前表定义一致：

- 每消费 `consumeAmount`
- 获得 `earnPoints`

#### 五、单笔上限

若配置 `singleEarnLimitType=限制`，则最终赠分不能超过 `singleEarnLimitValue`

#### 六、多倍积分

- 生日多倍：依赖 `CrmMemberVO.birthday`
- 会员日多倍：按规则配置的周/月周期匹配
- 若两个同时命中，文档采用“倍率相乘”还是“取最大值”必须统一

本方案默认：

- 生日多倍与会员日多倍可叠加，相乘计算

#### 七、周期/时段限制

- `availableCycle`
- `availableDaysOfWeek`
- `availableDaysOfMonth`
- `availableTimeType`
- `availableTimeSlots`

统一以订单结账时间 `checkoutTime` 判定。

#### 八、企微专享

若 `wecomExclusiveEnabled=1`，必须通过新增 CRM 积分上下文接口判定会员是否满足企微条件。

#### 九、场景/渠道限制

- `orderSceneLimit`
- `orderChannelLimit`

需要先把 `order_bill` 现有字段映射为积分规则识别的场景/渠道编码。
若现有字段不足，需新增统一映射函数，不允许在多处散写判断。

### 5.6 积分发放方式

#### 场景 A：订单中存在会员卡支付腿

此时直接复用现有 CRM 消费链路。

做法：

- Order 侧先算出本单赠分 `earnedPoints`
- 在调用 `cardConsumeInner` 时把 `givePoint=earnedPoints` 一并透传
- CRM 继续按现有 `CrmDealTask -> CardBalanceService -> genPointsRecord` 链路落账

优点：

- 会员消费与赠分属于同一 CRM 交易任务
- 撤销时天然可一起回滚

#### 场景 B：会员账单但没有会员卡支付腿

例如：

- 会员折扣 + 微信支付
- 会员折扣 + 现金支付
- 会员身份绑定但只走非会员资金支付

此时无法复用 `cardConsumeInner` 任务内的 `givePoint`。

做法：

- 订单支付成功后，Order 单独调用 CRM 积分入账接口
- 使用正向积分调整能力落账
- `orderId` 传 `saasOrderKey`
- `cardOpPointsType` 使用新的消费赠分类型，建议不要复用普通 `POINTS_OP_ADJUST`

建议新增独立的“消费赠分”积分类型，以便后续查询、统计和回滚。

### 5.7 订单表需要补的追踪字段

为了让赠分可审计、可撤销，建议在 `order_bill` 增加以下字段：

- `points_rule_lid`：命中的积分规则编号
- `earned_points`：本单实际赠分
- `earn_points_task_lid`：CRM 积分任务号/积分流水号
- `earn_points_status`：未发放 / 已发放 / 已撤销 / 发放失败

如果希望保留更细审计，可再加一份积分计算快照 JSON，但不是本次最小必需项。

### 5.8 退款与撤销

必须保证消费赠分可逆。

#### 有 `CRM` 支付腿的订单

- 优先沿用原消费任务撤销链路
- CRM 撤销消费时同步回滚 `givePoint`

#### 无 `CRM` 支付腿、单独赠分的订单

- 按 `earn_points_task_lid` 找到对应积分流水
- 发起一条负向积分冲销
- 订单状态更新为“已撤销赠分”

退款规则必须与订单最终有效状态绑定，不允许仅因为提交了退款申请就提前扣回积分。

## 6. 会员账单接入积分后的业务特征定义

接入完成后，一张可参与积分的会员账单将具备以下特征：

### 6.1 账单层特征

- 有明确会员身份：`cardLid/cardNo`
- 有明确结账结果：`orderStatus=CHECKED` 或等价完成态
- 有可追踪的积分规则：`points_rule_lid`
- 有可追踪的赠分结果：`earned_points`

### 6.2 折扣层特征

- 会员折扣只是积分计算输入，不等于积分发放动作
- 折扣后金额才是积分计算基数的一部分
- 会员价、会员折扣不会单独决定是否发积分，仍然要看 `crm_points_rule`

### 6.3 支付层特征

- `CRM` 支付：可复用消费任务发积分
- `PR` 积分抵现：应影响最终实收，但本身不计作赠分基数
- 现金/微信等普通支付：只要账单有会员身份，也可参与赠分

### 6.4 审计层特征

- 可以从订单追到积分记录
- 可以从积分记录追到来源订单
- 可以按规则追踪本单为什么赠分或为什么不赠分

## 7. 风险与实现注意点

### 7.1 `crm_points_rule` 与会员方案关系未完全打通

当前规则按 `planLid` 挂载，但订单主链路中尚未直接看到“会员卡 -> 会员方案”的现成读取口。
完整接入前必须先补齐这个映射。

### 7.2 生日与企微专享上下文不足

当前 Order 侧直接拿到的 `CrmCardVO` 不包含生日。
生日积分和企微专享如果要落地，必须新增 CRM 查询上下文接口。

### 7.3 支付方式积分口径必须统一

按支付方式实收积分时，不应简单累加 `orderPay.payAmount`。
必须统一口径：

- 只统计真实收入
- 只统计参与积分的支付方式
- 排除优惠券与积分抵现

否则会出现账务和积分口径不一致。

### 7.4 撤销链路必须设计为幂等

赠分落账后，订单可能出现：

- 用户取消
- 门店撤销
- 部分退款
- 整单退款

赠分回滚必须保证：

- 只撤一次
- 能重试
- 状态可追踪

## 8. 推荐落地顺序

1. 补齐“会员卡 -> 会员方案”映射
2. 新增 CRM 会员积分上下文查询接口
3. 在 Order 侧实现积分计算器
4. 在支付完成后接入积分发放
5. 为 `order_bill` 增加积分追踪字段
6. 接入撤销/退款回滚逻辑
7. 最后补文档和联调用例

## 9. 最终结论

当前系统里：

- 会员折扣已接入
- 会员卡支付已接入
- 积分抵现已接入
- CRM 积分账务能力已接入
- `crm_points_rule` 自动赠分未接入

如果要把“会员账单”完整纳入会员积分体系，正确方案不是去改 POS 原始账单，而是：

- 以云端 `order_bill` 为会员积分计算主账单
- 以 POS `dwd_bill` 为来源与对账依据
- 在 Order 侧按 `crm_points_rule` 完整计算赠分
- 在 CRM 侧统一落积分账、积分流水和回滚

## 10. 为了支持各种形式的报表，order_bill 还需要做哪些改进

如果后续要支撑大量会员报表、经营报表、积分报表、对账报表，那么 order_bill 不能只做“订单当前状态表”，而要逐步升级成“云端结算事实表”。

核心原则是：

- 不只记录当前值，还要记录结算时快照
- 不只记录订单状态，还要记录规则解释结果
- 不只记录业务号，还要记录来源链路

### 10.1 补全来源追溯字段

当前 saasOrderKey 和 orgBillId 只能解决一部分追溯问题，不足以支撑复杂报表和跨系统排障。

建议新增：

- sourceType：订单来源类型，例如堂食、外卖、自助点餐、POS拉单、人工补单
- sourceSystem：来源系统，例如 order、pos、i、wechat、miniapp
- sourceBillId：来源账单号，统一表达外部来源单号
- sourceTraceId：链路追踪号/请求追踪号
- posBillLid：如果能拿到，直接关联 POS dwd_bill.lid

这样后续能直接做：

- 云端订单与 POS 账单映射报表
- 订单来源分布报表
- 跨系统对账报表
- 订单链路排障报表

### 10.2 补全会员快照字段

后续大量会员报表一定不能每次都去回查当前会员表，否则会员升级、换卡、改名后，历史数据口径会漂移。

建议在 order_bill 直接落会员快照：

- memberLid
- cardLid
- cardNo
- cardTypeLid
- cardTypeName
- cardLevelLid
- cardLevelName
- isMemberOrder
- memberBindChannel
- memberSnapshotJson

当前表里虽然已经有一部分字段，例如：

- cardLid
- cardNo
- cardType
- cardLevel

但还不够稳定，也没有形成完整会员快照。

### 10.3 补全折扣口径字段

后续报表最容易乱的就是金额口径。为了让报表稳定，建议把关键折扣拆开存，不依赖运行时再重算。

建议新增或明确沉淀以下结果字段：

- grossAmount：原始订单金额/原始菜金
- memberDiscountAmount：会员折扣金额
- couponDiscountAmount：优惠券抵扣金额
- promotionDiscountAmount：活动优惠金额
- pointsDeductionAmount：积分抵现金额
- serviceChargeAmount：服务费金额
- cancelAmount：退菜金额
- sendAmount：赠送金额
- settlementAmount：最终参与结算金额
- ealIncomeAmount：最终计入实收金额

这样后续就能直接出：

- 会员折扣报表
- 优惠券影响报表
- 积分抵现报表
- 订单实收分析报表
- 折扣结构报表

### 10.4 补全支付结构字段

现在支付结构更多落在 order_pay，但如果报表主要按订单维度统计，order_bill 仍然需要把支付结构汇总快照下来。

建议新增：

- crmPayAmount
- wechatPayAmount
- cashPayAmount
- ankPayAmount
- pointsPayAmount
- otherPayAmount
- mixedPay

如果后面支付方式很多，也可以考虑：

- paySummaryJson

这样后续会员分析里可以直接做：

- 会员卡支付占比
- 会员单微信支付占比
- 积分抵现渗透率
- 混合支付订单分析

### 10.5 补全积分与规则快照字段

如果会员积分要成为正式能力，这块必须直接落在 order_bill，否则以后很难做可解释报表。

建议新增：

- pointsRuleLid
- pointsRuleName
- pointsCalcMode
- pointsBaseAmount
- earnedPoints
- usedPoints
- earnPointsTaskLid
- pointsRevokeTaskLid
- pointsStatus
- pointsCalcSnapshotJson

其中 pointsCalcSnapshotJson 建议至少记录：

- 命中的规则编号
- 会员等级
- 计算模式
- 积分基数
- 倍率命中情况
- 上限裁剪结果
- 最终赠分
- 不赠分原因（如果本单最终为0）

这样后面才能直接支撑：

- 会员赠分报表
- 积分规则效果分析
- 订单赠分追溯
- 积分撤销对账报表

### 10.6 补全生命周期时间字段

大量报表会同时关心“下单时间”“结账时间”“营业日”“退款时间”，仅靠 eportDate 和 checkoutTime 不够。

建议补充：

- orderCreatedTime
- orderConfirmedTime
- paySuccessTime
- settlementTime
- cancelTime
- efundTime
- completeTime

这样后续可以同时做：

- 下单趋势报表
- 结账趋势报表
- 营业日口径报表
- 退款回冲报表
- 会员活跃时段分析

### 10.7 补全状态与逆向追踪字段

如果后面报表要可追溯，就必须让正向和逆向动作成对。

建议补充：

- illingStatus
- memberSettleStatus
- pointsStatus
- efundStatus
- everseStatus
- everseReason
- everseSourceId

这样在报表里才能分清：

- 正常完成订单
- 已退款订单
- 已撤销订单
- 已赠分未撤销
- 已赠分已回滚

### 10.8 报表口径字段要提前标准化

如果后续要做大量会员报表，建议直接在文档和模型里提前统一这些指标字段，不要等报表 SQL 自己猜：

- 是否会员单
- 是否使用会员折扣
- 是否使用会员卡支付
- 是否使用积分抵现
- 是否赠分
- 是否退款
- 是否撤销
- 是否线下POS来源
- 是否云端原生订单

这些布尔型或枚举型字段，能极大降低后续报表复杂度。

### 10.9 为报表查询准备索引

如果 order_bill 后面要承担会员经营分析主表，建议至少保证这些查询键：

- mid + sid + reportDate
- mid + checkoutTime
- mid + memberLid
- mid + cardLid
- mid + saasOrderKey
- mid + sourceBillId
- mid + pointsRuleLid
- mid + orderStatus + confirmStatus

如果数据量持续增长，再考虑按 eportDate 做归档或分区。

### 10.10 最终要求

为了支持各种形式的会员报表，order_bill 后续设计应满足：

1. 能追到原始来源单
2. 能追到会员身份快照
3. 能追到折扣与支付结构
4. 能追到积分规则与积分结果
5. 能追到撤销与退款逆向动作
6. 能直接作为订单级报表事实表使用

一句话总结：

order_bill 后续不能只存“订单当前状态”，必须同时沉淀“来源快照、会员快照、金额快照、支付快照、积分快照”。只有这样，后面的大量会员报表才会真正稳定、可追溯、可解释。
