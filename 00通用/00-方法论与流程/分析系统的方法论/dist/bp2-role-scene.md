# BP-2 业务角色与场景

**系统**: kaci-pos-localserver
**分析时间**: 2026-09-03
**分析依据**: 394个Handler类 + 129个Processor类

---

## 1. 角色清单

### 1.1 角色总表

| 角色名称 | 类型 | 所属域 | 核心操作数 |
|---------|------|--------|-----------|
| 收银员 (Cashier) | 人 | pay | 28 |
| 服务员 (Waiter) | 人 | order/table | 25 |
| 厨师 (Chef) | 人 | kds | 24 |
| 会员顾客 (Member) | 人 | member | 22 |
| 店长 (Manager) | 人 | shiftdaily/report | 18 |
| 预定管理员 (BookingAgent) | 人 | book | 12 |
| 外卖员 (DeliveryPerson) | 人 | takeout | 9 |
| 系统管理员 (SysAdmin) | 人 | basic/device/account | 15 |
| KDS设备 (KDS Device) | 设备 | kds | 24 |
| 云打印机 (Cloud Printer) | 设备 | cloudPrint | 14 |
| 前台打印机 (Front Printer) | 设备 | print | 12 |
| POS终端 (POS Terminal) | 设备 | device | 5 |
| 会员系统 (Member System) | 系统 | member | 22 |
| 支付网关 (Payment Gateway) | 系统 | pay | 28 |
| 云端后台 (Cloud Backend) | 系统 | cloudPrint/basic | 20 |
| 第三方系统 (Third Party) | 系统 | tripartite | 8 |

### 1.2 角色分类说明

#### 1.2.1 人员角色

| 角色 | 说明 | 典型用户 |
|-----|------|---------|
| 收银员 | 执行收银操作、支付、退款、结账 | 前台收银人员 |
| 服务员 | 执行开台、点菜、加菜、划菜等前台服务 | 餐厅服务员 |
| 厨师 | 通过KDS查看菜品制作进度、标记完成 | 后厨厨师 |
| 店长 | 执行日结班结、查看营业报表、管理门店 | 店长 |
| 会员顾客 | 使用会员卡消费、充值、查询余额 | 持卡会员 |
| 预定管理员 | 管理预约、预定单处理 | 前台接待 |
| 外卖员 | 取餐、配送外卖订单 | 配送人员 |
| 系统管理员 | 管理系统设备、账户权限、基础配置 | IT/管理员 |

#### 1.2.2 设备角色

| 角色 | 说明 | 典型设备 |
|-----|------|---------|
| KDS设备 | 厨房显示系统，展示菜品制作状态 | 厨房显示屏 |
| 云打印机 | 云端配置的打印设备 | 云打印设备 |
| 前台打印机 | 本地小票打印机 | 小票打印机 |
| POS终端 | 收银POS设备 | 收银机 |

#### 1.2.3 系统角色

| 角色 | 说明 | 外部系统 |
|-----|------|---------|
| 会员系统 | 会员管理、储值、积分 | 云会员系统 |
| 支付网关 | 第三方支付接入 | 微信/支付宝 |
| 云端后台 | 总部管理系统 | 云平台 |
| 第三方系统 | 标签系统、RFID等 | 物联网设备 |

---

## 2. 角色-操作矩阵

### 2.1 收银员 (Cashier) - 支付域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 执行支付 (Pay) | 顾客确认结账，选择支付方式 | UI点击 |
| 取消支付 (PayCancel) | 支付中异常或顾客取消 | UI点击 |
| 关闭账单 (PayClose) | 支付窗口超时或放弃 | 超时/UI |
| 现金支付 (PayCash) | 选择现金支付方式 | UI点击 |
| 刷卡支付 (PayCard) | 选择银行卡支付 | 刷卡设备 |
| 扫码支付 (ScanCard) | 选择微信/支付宝 | 扫码枪 |
| 部分退款 (PartialRefund) | 顾客要求部分退款 | UI输入 |
| 整单退款 (WholeRefund) | 整单取消退款 | UI确认 |
| 重试支付 (PayRetry) | 支付失败重试 | 系统重试 |
| 打印小票 (PrintTicket) | 支付成功后 | 自动触发 |
| 使用优惠券 (UseCoupon) | 顾客出示优惠券 | UI核销 |
| 会员卡支付 (CardPay) | 选择会员卡支付 | 刷卡 |
| 储值卡消费 (CardConsume) | 使用储值余额 | 刷卡 |
| 积分抵扣 (PointDeduct) | 使用会员积分 | UI选择 |
| 企业结算 (CompanyPay) | 企业账户挂账 | UI选择 |
| 挂单 (HoldConsume) | 顾客暂时离开 | UI操作 |
| 取单 (TakeOrder) | 顾客返回继续 | UI操作 |
| 开钱箱 (OpenCashBox) | 现金收款找零 | 物理触发 |
| 充一赠送 (RechargeGift) | 会员充值活动 | UI操作 |
| 交接班 (ShiftChange) | 班次交接 | UI确认 |
| 日结 (DailySettle) | 营业日结束 | UI触发 |
| 反结账 (RevCheckout) | 需要重新结算 | UI操作 |
| 发票开具 (Invoicing) | 顾客需要发票 | UI申请 |
| 发票作废 (CancelInvoice) | 发票错误 | UI操作 |
| 预结账 (PreSettlement) | 先预结后正式结 | UI操作 |
| 预结取消 (CancelPreSettle) | 取消预结 | UI操作 |
| 押金收取 (CashPledge) | 收取押金 | UI操作 |
| 押金退还 (CashPledgeRefund) | 退还押金 | UI操作 |

### 2.2 服务员 (Waiter) - 订单/台桌域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 开台 (OpenTable) | 顾客入座 | UI点击 |
| 关台 (CloseTable) | 顾客离开 | UI点击 |
| 并桌 (MergeTable) | 顾客合并座位 | UI操作 |
| 拆桌 (SplitTable) | 顾客分开座位 | UI操作 |
| 换桌 (ChangeTable) | 顾客换座位 | UI操作 |
| 创建订单 (CreateOrder) | 开始点菜 | UI确认 |
| 落单 (PlaceOrder) | 确认菜品 | UI确认 |
| 加菜 (Replenish) | 追加菜品 | UI操作 |
| 退菜 (DelDetail) | 删除菜品项 | UI操作 |
| 改数量 (ModifyQty) | 修改菜品数量 | UI操作 |
| 划菜 (Serve) | 菜品已上桌 | UI操作 |
| 取消划菜 (CancelServe) | 撤销上菜标记 | UI操作 |
| 做法要求 (Practice) | 特殊做法 | UI选择 |
| 口味要求 (Taste) | 特殊口味 | UI选择 |
| 整单备注 (OrderRemark) | 添加备注 | UI输入 |
| 菜品备注 (DetailRemark) | 单品备注 | UI输入 |
| 叫起 (WakeUp) | 延迟菜品叫起 | UI操作 |
| 催菜 (Urge) | 催促上菜 | UI操作 |
| 打包 (PackGoods) | 顾客要求打包 | UI操作 |
| 取消打包 (CancelPack) | 取消打包 | UI操作 |
| 外卖订单 (TakeoutOrder) | 外卖平台订单 | 系统推送 |
| 沽清设置 (SoldOut) | 菜品售完 | UI操作 |
| 估清取消 (CancelSoldOut) | 取消估清 | UI操作 |
| 做法估清 (PracticeSoldOut) | 做法售完 | UI操作 |

### 2.3 厨师 (Chef) - KDS域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 查看菜品 (QueryGoods) | KDS显示菜品 | 自动触发 |
| 筛选分类 (QueryCategory) | 按分类查看 | UI操作 |
| 查看制作详情 (QueryDetail) | 查看具体菜品 | UI操作 |
| 完成制作 (MakeComplete) | 菜品完成 | UI点击 |
| 批量完成 (BatchComplete) | 多菜同时完成 | UI操作 |
| 叫号 (CallNumber) | 通知取餐 | UI操作 |
| 完成并叫号 (CompleteCall) | 完成同时叫号 | UI操作 |
| 自动完成 (AutoComplete) | 系统自动完成 | 定时触发 |
| 撤回 (Revert) | 撤销完成操作 | UI操作 |
| 设置估清 (SaveSoldOut) | 设置菜品估清 | UI操作 |
| 取消估清 (DeleteSoldOut) | 取消估清 | UI操作 |
| 查询估清 (QuerySoldOut) | 查看估清列表 | UI查询 |
| 保存屏幕配置 (SaveScreen) | 配置显示参数 | UI保存 |
| 查询屏幕配置 (QueryScreen) | 查看屏幕设置 | UI查询 |
| 临时保存配置 (TempSaveScreen) | 临时保存参数 | UI操作 |
| 查询配置列表 (QueryParamList) | 查看参数列表 | UI查询 |
| 分配屏幕 (UpdateAllot) | 分配菜品到屏幕 | UI操作 |
| 查询分配 (QueryAllot) | 查看分配情况 | UI查询 |
| 游泳道配置 (SwimConfig) | 配置工作流 | UI操作 |
| 查询游泳道 (QuerySwim) | 查看游泳道 | UI查询 |
| 更新游泳道开关 (SwimSwitch) | 开关游泳道 | UI操作 |
| 条码查询 (BarcodeQuery) | 扫描条码查询 | 扫码触发 |
| 查询工作日 (QueryWorkDate) | 查看营业日 | UI查询 |

### 2.4 会员顾客 (Member) - 会员域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 刷卡查询 (QueryByCard) | 刷会员卡 | 刷卡设备 |
| 手机查询 (QueryByPhone) | 输入手机号 | UI输入 |
| 开卡 (OpenCard) | 新会员注册 | UI操作 |
| 开优惠卡 (OpenBenefitCard) | 开通优惠权益 | UI操作 |
| 换卡 (ChangeCard) | 会员换卡 | UI操作 |
| 改密码 (ChangePwd) | 修改会员密码 | UI操作 |
| 重置密码 (ResetPwd) | 忘记密码重置 | UI操作 |
| 充值 (Recharge) | 储值充值 | UI操作 |
| 消费 (Consume) | 持卡消费 | 刷卡+UI |
| 余额退款 (BalanceRefund) | 余额退还 | UI操作 |
| 充值退款 (RechargeRefund) | 充值退款 | UI操作 |
| 积分查询 (QueryPoints) | 查看积分 | UI查询 |
| 积分兑换 (ExchangeGift) | 积分换礼 | UI操作 |
| 礼品赠送 (SendGift) | 转赠礼品 | UI操作 |
| 权益销售 (EquitySale) | 购买权益 | UI操作 |
| 权益退款 (EquityRefund) | 退还权益 | UI操作 |
| 企业挂账 (CompanySettle) | 企业账户消费 | UI操作 |
| 企业结算 (SettlePay) | 企业账单支付 | UI操作 |
| 取消挂账 (CancelSettle) | 取消企业挂账 | UI操作 |
| 更新资料 (UpdateInfo) | 更新会员信息 | UI操作 |
| 修改手机 (ChangePhone) | 修改手机号 | UI操作 |

### 2.5 店长 (Manager) - 班结/报表域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 日结 (DailySettle) | 营业日结束 | UI触发 |
| 日结预检 (DailyPreCheck) | 日结前检查 | 自动检查 |
| 自动日结 (AutoDaily) | 定时自动日结 | 定时任务 |
| 班次确认 (ShiftConfirm) | 班次交接确认 | UI确认 |
| 班次查询 (ShiftQuery) | 查看班次信息 | UI查询 |
| 班次预检 (ShiftPreCheck) | 班次交接前检查 | 自动检查 |
| 最大班次检查 (MaxClassesCheck) | 检查班次数量 | 系统检查 |
| 营业汇总 (BusinessSum) | 查看营业汇总 | UI查询 |
| 营业明细 (BusinessDetail) | 查看营业明细 | UI查询 |
| 时段报表 (TimeInterval) | 各时段统计 | UI查询 |
| 商品销售 (GoodsSale) | 商品销售报表 | UI查询 |
| 退菜统计 (GoodsRefund) | 退菜统计报表 | UI查询 |
| 赠送统计 (GoodsGift) | 赠送商品统计 | UI查询 |
| 账单支付 (BillPay) | 账单支付报表 | UI查询 |
| 反结账统计 (RevCheckout) | 反结账统计 | UI查询 |
| 交接班报表 (ShiftForm) | 打印交接班报表 | UI打印 |
| 上传订单 (UploadOrder) | 上传订单到云端 | 系统触发 |

### 2.6 系统管理员 (SysAdmin) - 基础域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 基础数据同步 (BasicSync) | 初始化/更新基础数据 | 系统触发 |
| 设备注册 (DeviceReg) | 新设备接入 | UI操作 |
| 清除站点 (ClearSite) | 清除设备站点信息 | UI操作 |
| 参数配置 (ParamSetting) | 业务参数设置 | UI操作 |
| 临时保存参数 (TempSaveParam) | 临时保存参数 | UI操作 |
| 获取参数 (GetParams) | 获取参数列表 | UI查询 |
| 词典查询 (DictQuery) | 获取词典数据 | UI查询 |
| 支付方式 (PayMethod) | 配置支付方式 | UI操作 |
| 餐次管理 (MealTime) | 设置餐次时段 | UI操作 |
| 发票二维码 (InvoiceQR) | 发票二维码开关 | UI操作 |
| 打印配置 (PrintConfig) | 本地打印配置 | UI操作 |
| 模板配置 (TemplateConfig) | 打印模板设置 | UI操作 |
| 账户管理 (AccountManage) | 添加/修改账户 | UI操作 |
| 权限配置 (RightConfig) | 账户权限设置 | UI操作 |
| 账户授权 (AccountAuth) | 权限认证 | UI操作 |

### 2.7 预定管理员 (BookingAgent) - 预定域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 添加预定 (AddBook) | 新建预订 | UI操作 |
| 批量添加 (AddBatch) | 批量创建预订 | UI操作 |
| 修改预定 (UpdateBook) | 修改预订信息 | UI操作 |
| 更新状态 (UpdateStatus) | 更新预订状态 | UI操作 |
| 更新桌台 (UpdateTable) | 分配/更换桌台 | UI操作 |
| 查询预定 (QueryList) | 查看预订列表 | UI查询 |
| 发送短信 (SendSms) | 发送通知短信 | UI触发 |
| 区域查询 (QueryArea) | 查看区域列表 | UI查询 |
| 桌台查询 (QueryTable) | 查看可用桌台 | UI查询 |
| 顾客查询 (QueryCustomer) | 按手机查询顾客 | UI查询 |
| 取消预定 (CancelBook) | 取消预订 | UI操作 |

### 2.8 外卖员 (DeliveryPerson) - 外卖域

| 操作 | 触发条件 | 触发类型 |
|-----|---------|---------|
| 第三方配送列表 (ThirdDeliveryList) | 第三方配送订单 | 系统推送 |
| 创建配送 (CreateDelivery) | 创建配送单 | UI操作 |
| 确认配送 (ConfirmDelivery) | 开始配送 | UI操作 |
| 取消配送 (CancelDelivery) | 取消配送 | UI操作 |
| 加价配送 (AddPriceDelivery) | 增加配送费 | UI操作 |
| 配送订单列表 (DeliveryList) | 查看配送订单 | UI查询 |
| 小程序取餐 (AppletPickup) | 小程序扫码取餐 | 扫码触发 |
| 更新工作日 (UpdateWorkDate) | 更新营业日 | 系统触发 |

---

## 3. 典型业务场景

### 场景1: 堂食点餐结账流程

**场景描述**: 顾客到店入座，服务员完成点餐、收银员完成结账的完整流程

**角色**: 服务员 -> 收银员

**操作序列**:
1. 服务员执行开台 (OpenTable) - 触发条件: 顾客入座
2. 服务员执行创建订单 (CreateOrder) - 触发条件: 开始点菜
3. 服务员执行落单 (PlaceOrder) - 触发条件: 确认菜品
4. 服务员执行加菜 (Replenish) - 触发条件: 追加菜品
5. 服务员执行做法/口味 (Practice/Taste) - 触发条件: 特殊要求
6. 服务员执行划菜 (Serve) - 触发条件: 菜品上桌
7. 收银员执行反结账 (RevCheckout) - 触发条件: 需要重新结算
8. 收银员执行执行支付 (Pay) - 触发条件: 顾客确认结账
9. 收银员执行使用优惠券 (UseCoupon) - 触发条件: 顾客出示优惠券
10. 系统执行打印小票 (PrintTicket) - 触发条件: 支付成功
11. 服务员执行关台 (CloseTable) - 触发条件: 顾客离开

**数据流**:
- 订单数据: OrderService -> OrderCreateRecordProcessor
- 支付数据: ScanCardService -> PayCloseRecordProcessor
- 台桌数据: TableOperateSelector -> TableOperateRecordProcessor

---

### 场景2: 厨房菜品制作流程

**场景描述**: 订单落单后，厨房通过KDS查看菜品并完成制作

**角色**: 厨师 -> KDS设备

**操作序列**:
1. 系统推送订单到KDS (系统自动) - 触发条件: 落单成功
2. 厨师执行查看菜品 (QueryGoods) - 触发条件: KDS显示菜品
3. 厨师执行完成制作 (MakeComplete) - 触发条件: 菜品完成
4. 厨师执行叫号 (CallNumber) - 触发条件: 通知取餐
5. 厨师执行设置估清 (SaveSoldOut) - 触发条件: 菜品售完

**数据流**:
- KDS数据: ScreenMakeService -> KdsCompleteRecordProcessor
- 估清数据: SoldOutService -> PracticeSoldOutRecordProcessor

---

### 场景3: 会员开卡充值消费

**场景描述**: 新会员注册、开卡、充值、使用会员卡消费

**角色**: 收银员 -> 会员顾客 -> 系统

**操作序列**:
1. 会员顾客执行刷卡查询 (QueryByCard) - 触发条件: 刷会员卡
2. 收银员执行开卡 (OpenCard) - 触发条件: 新会员注册
3. 收银员执行充值 (Recharge) - 触发条件: 会员充值
4. 收银员执行会员卡支付 (CardPay) - 触发条件: 使用会员卡支付
5. 系统执行储值卡消费 (CardConsume) - 触发条件: 支付成功
6. 会员顾客执行积分兑换 (ExchangeGift) - 触发条件: 积分换礼

**数据流**:
- 会员数据: MemberCardService -> MemberRechargeRecordProcessor
- 消费数据: CardConsumeService -> GiftCardConsumeRecordProcessor

---

### 场景4: 日结班结流程

**场景描述**: 店长执行日结班结，汇总当日营业数据

**角色**: 店长 -> 收银员 -> 系统

**操作序列**:
1. 收银员执行交接班 (ShiftChange) - 触发条件: 班次交接
2. 店长执行班次确认 (ShiftConfirm) - 触发条件: 确认班次数据
3. 系统执行最大班次检查 (MaxClassesCheck) - 触发条件: 系统自动检查
4. 店长执行日结 (DailySettle) - 触发条件: 营业日结束
5. 系统执行日结预检 (DailyPreCheck) - 触发条件: 日结前自动检查
6. 系统执行自动日结 (AutoDaily) - 触发条件: 定时任务
7. 系统执行上传订单 (UploadOrder) - 触发条件: 日结成功后
8. 店长执行打印交接班报表 (PrintShiftForm) - 触发条件: 需要打印报表

**数据流**:
- 班结数据: DailySettlementOperationService -> DailySettlementRecordProcessor
- 班次数据: ShiftService -> ShiftConfirmRecordProcessor

---

### 场景5: 外卖订单处理流程

**场景描述**: 接收外卖平台订单，完成制作后通知外卖员取餐

**角色**: 系统 -> 服务员 -> 外卖员

**操作序列**:
1. 系统接收外卖订单 (TakeoutOrder) - 触发条件: 第三方平台推送
2. 系统执行更新工作日 (UpdateWorkDate) - 触发条件: 同步营业日
3. 服务员查看订单详情 (DetailTakeoutOrder) - 触发条件: 查看订单
4. 服务员完成制作 (MakeCompleteTakeout) - 触发条件: 外卖制作完成
5. 外卖员执行小程序取餐 (AppletPickup) - 触发条件: 扫码取餐
6. 顾客申请退款 (RefundTakeoutOrder) - 触发条件: 顾客申请

**数据流**:
- 外卖数据: TakeoutService -> MakeCompleteTakeoutOrderRecordProcessor
- 配送数据: DeliveryService -> AppletPickUpMealRecordProcessor

---

### 场景6: 押金管理流程

**场景描述**: 收取酒水押金、消费后取酒退还押金

**角色**: 收银员 -> 会员顾客

**操作序列**:
1. 收银员执行添加酒水 (AddWine) - 触发条件: 收取酒水押金
2. 会员顾客执行取酒 (TakeWine) - 触发条件: 消费时取酒
3. 收银员执行押金收取 (CashPledge) - 触发条件: 收取押金
4. 收银员执行押金退还 (CashPledgeRefund) - 触发条件: 退还押金
5. 收银员执行押金转账 (CashPledgeCarryover) - 触发条件: 押金转消费
6. 会员顾客执行打印取酒小票 (TakeWineTicketPrint) - 触发条件: 补打小票

**数据流**:
- 押金数据: CashPledgeService -> CreateBuffetPledgeRecordProcessor
- 酒水数据: DepositService -> TakeWineRecordProcessor

---

### 场景7: 发票开具流程

**场景描述**: 顾客消费后需要开具发票

**角色**: 收银员 -> 会员顾客 -> 系统

**操作序列**:
1. 收银员执行发票开具 (Invoicing) - 触发条件: 顾客申请发票
2. 收银员执行发票作废 (CancelInvoice) - 触发条件: 发票错误需要作废
3. 会员顾客执行充值发票 (RechargeInvoice) - 触发条件: 充值后开票
4. 收银员执行发票配置 (RechargeInvoiceConfig) - 触发条件: 设置发票配置
5. 系统查询发票状态 (QueryInvoice) - 触发条件: 查询发票信息

**数据流**:
- 发票数据: InvoiceService -> InvoicingRecordProcessor
- 配置数据: InvoiceConfigService -> RechargeInvoiceConfigRecordProcessor

---

### 场景8: 会员优惠核销

**场景描述**: 收银员使用优惠券、促销折扣

**角色**: 收银员 -> 系统

**操作序列**:
1. 收银员执行优惠券验证 (VerifyCoupon) - 触发条件: 顾客出示优惠券
2. 收银员执行批量核销 (BatchVerifyCoupon) - 触发条件: 多张优惠券
3. 收银员执行优惠执行 (ExecutePromotion) - 触发条件: 执行满减等促销
4. 收银员执行优惠检查 (CheckPromotion) - 触发条件: 检查可用优惠
5. 收银员执行折扣检查 (CheckDiscount) - 触发条件: 检查折扣可用

**数据流**:
- 优惠数据: PromotionService -> ExecutePromotionRecordProcessor
- 券数据: CouponService -> HandVerifyCouponRecordProcessor

---

### 场景9: 台桌并换转流程

**场景描述**: 服务员对桌台进行调整操作

**角色**: 服务员

**操作序列**:
1. 服务员执行并桌 (MergeTable) - 触发条件: 顾客合并座位
2. 服务员执行取消并桌 (CancelMerge) - 触发条件: 取消并桌
3. 服务员执行拆桌 (SplitTable) - 触发条件: 顾客分开
4. 服务员执行换桌 (ChangeTable) - 触发条件: 顾客换座位
5. 服务员执行换桌确认 (MergeCheck) - 触发条件: 检查能否换桌

**数据流**:
- 台桌数据: TableOperateSelector -> MergeUnionTableRecordProcessor
- 操作数据: TableService -> TableOperateRecordProcessor

---

### 场景10: 估清管理流程

**场景描述**: 餐厅对菜品进行沽清设置和管理

**角色**: 服务员 -> 厨师 -> 系统

**操作序列**:
1. 服务员执行设置估清 (SoldOutSet) - 触发条件: 菜品售完
2. 服务员执行取消估清 (CancelSoldOut) - 触发条件: 取消估清
3. 服务员执行做法估清 (PracticeSoldOut) - 触发条件: 做法售完
4. 厨师执行设置估清 (SaveSoldOut) - 触发条件: 厨房设置估清
5. 厨师执行取消估清 (DeleteSoldOut) - 触发条件: 取消估清
6. 系统执行手动同步 (ManualSync) - 触发条件: 同步估清数据
7. 服务员执行估清打印 (SoldOutTicketPrint) - 触发条件: 打印估清单

**数据流**:
- 估清数据: SoldOutService -> SoldOutSetRecordProcessor
- KDS估清: ScreenMakeService -> KdsSaveScreenDetailRecordProcessor

---

## 4. Handler-Processor映射表

### 4.1 核心Handler与Processor对应关系

| Handler类 | 路径 | Processor类 | 操作类型 |
|-----------|------|-------------|---------|
| OrderLdHandler | /order/create | OrderCreateRecordProcessor | 创建订单 |
| PlaceOrderHandler | /order/placeOrder | PlaceOrderRecordProcessor | 落单 |
| RevCheckoutHandler | /order/revCheckout | RevCheckoutRecordProcessor | 反结账 |
| WholeOrderRefundHandler | /order/wholeOrderRefund | WholeOrderRefundRecordProcessor | 整单退款 |
| KDSMakeCompleteHandler | /pos/screen/kds/complete | KdsCompleteRecordProcessor | KDS完成 |
| TableOperateHandler | /table/tableOperate | TableOperateRecordProcessor | 台桌操作 |
| LoginHandler | /login | LoginRecordProcessor | 登录 |
| LogoutHandler | /logout | LogoutRecordProcessor | 登出 |
| DailySettlementHandler | /shiftDaily/dailySettlement | DailySettlementRecordProcessor | 日结 |
| ShiftConfirmHandler | /shiftDaily/shiftConfirm | ShiftConfirmRecordProcessor | 班次确认 |
| PayCloseHandler | /pay/close | PayCloseRecordProcessor | 支付关闭 |
| RechargeHandler | /member/recharge | MemberRechargeRecordProcessor | 会员充值 |
| CashPledgePayHandler | /cashPledge/cashPledgePay | CashPledgePayRecordProcessor | 押金支付 |
| InvoicingHandler | /invoice/invoicing | InvoicingRecordProcessor | 开具发票 |
| SoldOutSetHandler | /soldOut/soldOutSet | SoldOutSetRecordProcessor | 设置估清 |

---

## 5. 业务域分布统计

### 5.1 Handler数量按域分布

| 业务域 | Handler数量 | 占比 |
|-------|------------|------|
| member (会员) | 52 | 13.2% |
| order (订单) | 30 | 7.6% |
| report (报表) | 28 | 7.1% |
| kds (厨房显示) | 27 | 6.9% |
| pay (支付) | 20 | 5.1% |
| goods (菜品) | 20 | 5.1% |
| print (打印) | 16 | 4.1% |
| table (台桌) | 15 | 3.8% |
| cloudPrint (云打印) | 14 | 3.6% |
| shiftdaily (班结) | 13 | 3.3% |
| cashPledge (押金) | 13 | 3.3% |
| takeout/delivery (外卖) | 12 | 3.0% |
| basic (基础) | 11 | 2.8% |
| book (预定) | 11 | 2.8% |
| wine (酒水) | 9 | 2.3% |
| coupon (券) | 5 | 1.3% |
| invoice (发票) | 5 | 1.3% |
| login (登录) | 4 | 1.0% |
| account (账户) | 4 | 1.0% |
| soldout (估清) | 5 | 1.3% |
| device (设备) | 2 | 0.5% |
| org (组织) | 3 | 0.8% |
| 其他 | 55 | 14.0% |

### 5.2 Processor数量按域分布

| 业务域 | Processor数量 | 占比 |
|-------|-------------|------|
| order (订单) | 15 | 11.6% |
| member (会员) | 18 | 14.0% |
| table (桌台) | 9 | 7.0% |
| cashPledge (押金) | 8 | 6.2% |
| kds (厨房) | 8 | 6.2% |
| pay (支付) | 6 | 4.7% |
| delivery (配送) | 7 | 5.4% |
| print (打印) | 3 | 2.3% |
| other (其他) | 28 | 21.7% |
| 其他 | 27 | 20.9% |

---

## 6. 触发类型分类

### 6.1 用户触发型

由用户主动发起的操作:
- UI点击操作 (按钮点击、菜单选择)
- UI输入操作 (数字输入、文字输入)
- UI确认操作 (确认对话框、提交表单)

### 6.2 系统触发型

由系统自动触发的操作:
- 定时任务 (自动日结、订单超时)
- 事件驱动 (支付成功、落单成功)
- 消息推送 (外卖订单、第三方回调)
- 设备触发 (刷卡、扫码)

### 6.3 物理触发型

由物理设备或外部事件触发:
- 钱箱弹开 (现金收款)
- 打印机打印 (小票打印)
- 刷卡器读取 (会员卡)

---

**文档版本**: v1.0
**分析依据**: kaci-pos-localserver Handler/Processor 源代码
**产出位置**: D:\mywork\techdoc\00通用\00-方法论与流程\分析系统的方法论\dist\bp2-role-scene.md
