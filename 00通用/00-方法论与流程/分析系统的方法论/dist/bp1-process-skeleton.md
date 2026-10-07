# BP-1 业务流程骨架

> 系统: kaci-pos-localserver  
> 分析日期: 2026-09-02  
> 基础: 22个processor子包, ~130个Processor类, 13个Task类

---

## 1. 业务域划分

| 域代码 | 域名称 | Processor子包 | 业务含义 |
|--------|--------|--------------|----------|
| ORDER | 订单 | order, book, delivery, nonTable | 订单生命周期管理 |
| PAY | 支付 | pay, cashPledge | 支付与押金 |
| FOOD | 菜品 | food | 菜品操作 |
| TABLE | 桌台 | table | 桌台管理 |
| MEMBER | 会员 | member | 会员卡与权益 |
| KDS | 厨房显示 | kds | KDS叫号系统 |
| BILL_PRINT | 打印 | print | 小票打印 |
| BASE_OPERATE | 基础操作 | account, device, org, other | 基础运营 |
| OTHER | 其他 | tripartite, wine, invoice, basic, coupon | 辅助功能 |

> **域数量说明**：bp1 列出了 9 个域（含合并基础操作），SOP 整合章节将基础操作并入"日结/班次+基础"，最终汇总为 12 个分析域（含 PROCESS 公共部分）。

---

## 2. 业务动作清单

### 2.1 订单域 (ORDER)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| PlaceOrderRecordProcessor | 落单 | ACTION | POS前端 | 高 |
| OrderCreateRecordProcessor | 创建订单 | ACTION | POS前端 | 高 |
| OrderModifyRecordProcessor | 修改订单 | ACTION | POS前端 | 高 |
| RevCheckoutRecordProcessor | 反结账 | COMPENSATION | POS前端 | 高 |
| WholeOrderRefundRecordProcessor | 整单退款 | COMPENSATION | POS前端 | 高 |
| CancelPreSettlementRecordProcessor | 取消预结 | ACTION | POS前端 | 中 |
| ModifyOrderDetailRecordProcessor | 修改菜品明细 | ACTION | POS前端 | 中 |
| ModifyServiceAmountRecordProcessor | 修改服务费 | ACTION | POS前端 | 中 |
| OrderRemarkRecordProcessor | 订单备注 | ACTION | POS前端 | 中 |
| OrderDetailDelRecordProcessor | 删除菜品 | ACTION | POS前端 | 中 |
| MarkTestOrderRecordProcessor | 标记测试单 | ACTION | 后台/测试 | 低 |
| CreateWithOpenTableNoOccupyRecordProcessor | 不占桌开单 | ACTION | POS前端 | 中 |
| CjcdOrderLdRecordProcessor | 叫起订单 | ACTION | POS前端 | 低 |

### 2.2 预订域 (BOOK)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| AddBookOrderRecordProcessor | 新增预订单 | ACTION | POS/小程序 | 高 |
| AddBatchBookOrderRecordProcessor | 批量新增预订 | ACTION | 批量导入 | 中 |
| UpdateBookOrderRecordProcessor | 修改预订单 | ACTION | POS前端 | 高 |
| UpdBookOrderStatusRecordProcessor | 修改预订状态 | ACTION | POS前端 | 高 |
| UpdBookOrderTableRecordProcessor | 预订换桌 | ACTION | POS前端 | 中 |
| SendMessageRecordProcessor | 发送预订短信 | ACTION | 自动触发 | 高 |

### 2.3 外卖配送域 (DELIVERY)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| CreateDeliveryOrderRecordProcessor | 创建配送单 | ACTION | 小程序/三方 | 高 |
| BookLdTakeoutOrderRecordProcessor | 预订外卖单 | ACTION | 小程序 | 高 |
| ConfirmDeliveryRecordProcessor | 确认送达 | ACTION | 配送员 | 高 |
| CancelDeliveryOrderRecordProcessor | 取消配送 | COMPENSATION | 用户/系统 | 高 |
| RefundTakeoutOrderRecordProcessor | 外卖退款 | COMPENSATION | 用户/系统 | 高 |
| MakeCompleteTakeoutOrderRecordProcessor | 外卖制作完成 | ACTION | 后厨 | 高 |
| AppletPickUpMealRecordProcessor | 小程序取餐 | ACTION | 用户 | 高 |
| AddPriceDeliveryRecordProcessor | 加价配送 | ACTION | 用户 | 中 |

### 2.4 支付域 (PAY)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| PayRecordProcessor | 订单支付 | ACTION | POS前端 | 高 |
| PayCompleteRecordProcessor | 结账完成 | ACTION | POS前端 | 高 |
| PayCancelRecordProcessor | 取消支付 | COMPENSATION | 用户/系统 | 高 |
| PartialRefundRecordProcessor | 部分退款 | COMPENSATION | POS前端 | 高 |
| ScanCardRecordProcessor | 刷卡支付 | ACTION | POS前端 | 高 |
| ScanCardSupplementRecordProcessor | 刷卡补录 | ACTION | 补录 | 中 |
| PayCashRecordProcessor | 现金支付 | ACTION | POS前端 | 高 |
| PayCardRecordProcessor | 卡支付 | ACTION | POS前端 | 高 |
| CouponConsumeRecordProcessor | 优惠券核销 | ACTION | 用户 | 高 |
| CardConsumeRecordProcessor | 卡消费 | ACTION | POS前端 | 高 |
| ManualRoundDownRecordProcessor | 手动抹零 | ACTION | POS前端 | 中 |
| PayCashPledgeRecordProcessor | 押金支付 | ACTION | POS前端 | 高 |
| PayCloseRecordProcessor | 支付关闭 | ACTION | 系统 | 中 |
| HoldConsumeRecordProcessor | 挂账 | ACTION | POS前端 | 中 |
| PayVoucherKeyRecordProcessor | 凭证密钥 | ACTION | 系统 | 低 |

### 2.5 押金域 (CASH_PLEDGE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| CashPledgePayRecordProcessor | 押金支付 | ACTION | POS前端 | 高 |
| CashPledgeRefundRecordProcessor | 押金退款 | COMPENSATION | 系统/用户 | 高 |
| CashPledgeCarryoverRecordProcessor | 结转押金 | ACTION | 日结 | 高 |
| CreateBuffetPledgeRecordProcessor | 生成自助餐押金 | ACTION | 开台 | 高 |
| PledgeChangeOrderRecordProcessor | 押金换单 | ACTION | 换单 | 中 |
| RefundBuffetPledgeRecordProcessor | 自助餐押金退款 | COMPENSATION | 退订 | 高 |
| RefundOrderPledgeRecordProcessor | 订单押金退款 | COMPENSATION | 退订 | 高 |

### 2.6 会员域 (MEMBER)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| OpenCardRecordProcessor | 会员开卡 | ACTION | POS前端 | 高 |
| OpenCardPayRecordProcessor | 开卡支付 | ACTION | POS前端 | 高 |
| MemberRechargeRecordProcessor | 会员充值 | ACTION | POS前端 | 高 |
| RechargeRefundRecordProcessor | 充值退款 | COMPENSATION | 用户 | 高 |
| BscPayRecordProcessor | 储值支付 | ACTION | POS前端 | 高 |
| SettlePayRecordProcessor | 企业结算支付 | ACTION | POS前端 | 高 |
| CompanySettleRecordProcessor | 企业挂账 | ACTION | POS前端 | 高 |
| CancelSettlePayRecordProcessor | 取消结算支付 | COMPENSATION | 用户 | 高 |
| CancelSettleRecordProcessor | 取消挂账 | COMPENSATION | 用户 | 高 |
| UpdateCardStatusRecordProcessor | 修改卡状态 | ACTION | 系统/人工 | 中 |
| UpdateCardLevelRecordProcessor | 等级变更 | ACTION | 系统/人工 | 中 |
| ChangeCardPwdRecordProcessor | 修改卡密码 | ACTION | 用户 | 中 |
| ResetCardPwdRecordProcessor | 重置密码 | ACTION | 人工 | 中 |
| CardBindSerialRecordProcessor | 实体卡绑定 | ACTION | POS前端 | 中 |
| ChangeNewCardRecordProcessor | 会员换卡 | ACTION | 用户 | 中 |
| ChangeCustomerPhoneRecordProcessor | 修改手机号 | ACTION | 用户 | 中 |
| UpdateCustomerInfoRecordProcessor | 修改会员信息 | ACTION | 用户 | 中 |
| SendGiftRecordProcessor | 会员发券 | ACTION | 系统/营销 | 中 |
| MemberCardTransferRecordProcessor | 转卡 | ACTION | 用户 | 中 |
| BalanceRefundRecordProcessor | 会员卡退款 | COMPENSATION | 用户 | 高 |
| OpenBenefitCardRecordProcessor | 开权益卡 | ACTION | 营销 | 中 |
| GiftCardConsumeRecordProcessor | 礼品卡消费 | ACTION | 用户 | 中 |
| EquitySaleOrderRecordProcessor | 权益销售 | ACTION | 销售 | 高 |
| EquitySaleRefundRecordProcessor | 权益销售退款 | COMPENSATION | 用户 | 高 |
| HandVerifyCouponRecordProcessor | 手动验券 | ACTION | 门店 | 中 |

### 2.7 桌台域 (TABLE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| OpenBuffetTableRecordProcessor | 开自助餐台 | ACTION | POS前端 | 高 |
| TableOperateRecordProcessor | 桌台操作 | ACTION | POS前端 | 高 |
| TableEditRecordProcessor | 桌台编辑 | ACTION | 后台 | 中 |
| UnionTableRecordProcessor | 联台 | ACTION | POS前端 | 高 |
| MergeUnionTableRecordProcessor | 合并联台 | ACTION | POS前端 | 高 |
| CancelUnionTableRecordProcessor | 取消联台 | COMPENSATION | POS前端 | 高 |
| RemoveUnionTableRecordProcessor | 移除联台 | COMPENSATION | POS前端 | 中 |
| BatchRevokeOpenTableRecordProcessor | 批量撤台 | COMPENSATION | 系统/人工 | 高 |
| BatchRevokeSplitTableRecordProcessor | 批量撤分台 | COMPENSATION | 系统 | 中 |

### 2.8 菜品域 (FOOD)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| ReplenishOrderLdRecordProcessor | 补录订单 | ACTION | 补录 | 中 |
| PackGoodsRecordProcessor | 菜品组合 | ACTION | 后厨 | 中 |
| CancelPackGoodsRecordProcessor | 取消组合 | COMPENSATION | 后厨 | 中 |
| ExecutePromotionRecordProcessor | 执行促销 | ACTION | 系统 | 中 |

### 2.9 KDS域 (KDS)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| KdsCompleteRecordProcessor | KDS划菜 | ACTION | 后厨 | 高 |
| KdsMakeCompleteAndCallRecordProcessor | 制作完成并叫号 | ACTION | 后厨 | 高 |
| KdsBatchMakeCompleteRecordProcessor | 批量制作完成 | ACTION | 后厨 | 中 |
| KdsRevertRecordProcessor | KDS撤销划菜 | COMPENSATION | 后厨 | 中 |
| KdsMakeAutoCompleteRecordProcessor | 自动制作完成 | ACTION | 系统 | 中 |
| KdsUpdateScreenAllotRecordProcessor | 更新屏幕分配 | ACTION | 配置 | 低 |
| KdsSaveScreenDetailRecordProcessor | 保存屏幕详情 | ACTION | 配置 | 低 |
| KdsSwimSaveConfigRecordProcessor | 保存泳道配置 | ACTION | 配置 | 低 |
| KdsSwimUpdateSwitchRecordProcessor | 更新泳道开关 | ACTION | 配置 | 低 |
| KdsTempSaveScreenParamsRecordProcessor | 临时保存屏幕参数 | ACTION | 配置 | 低 |
| ScreenDetailAllotUpdateRecordProcessor | 屏幕分配更新 | ACTION | 配置 | 低 |

### 2.10 打印域 (BILL_PRINT)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| PrintBillTicketRecordProcessor | 打印小票 | ACTION | 多种触发 | 高 |
| PrintBusinessTicketRecordProcessor | 打印业务单 | ACTION | 多种触发 | 高 |
| SaveTemplateConfigRecordProcessor | 保存模板配置 | ACTION | 后台 | 低 |

### 2.11 基础操作域 (BASE_OPERATE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| LoginRecordProcessor | 登录 | ACTION | 员工 | 高 |
| LogoutRecordProcessor | 退出 | ACTION | 员工 | 高 |
| DailySettlementRecordProcessor | 日结 | ACTION | 手动/自动 | 高 |
| ShiftConfirmRecordProcessor | 班次确认 | ACTION | 手动/自动 | 高 |
| DeviceRegisterRecordProcessor | 设备注册 | ACTION | 首次使用 | 高 |
| OrgRegisterRecordProcessor | 店铺注册 | ACTION | 初始化 | 高 |
| OrgUnbindRecordProcessor | 设备解绑 | ACTION | 管理员 | 中 |
| ClearSiteInfoRecordProcessor | 清除站点信息 | ACTION | 管理员 | 中 |
| ReserveFundRecordProcessor | 备用金 | ACTION | 财务 | 中 |
| OperateShortAccountRecordProcessor | 修改短账号密码 | ACTION | 管理员 | 低 |
| TempSaveShopParamRecordProcessor | 临时保存参数 | ACTION | 系统 | 低 |

### 2.12 其他操作域 (OTHER)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| OpenTheCashBoxRecordProcessor | 开钱箱 | ACTION | 员工 | 中 |
| SoldOutSetRecordProcessor | 设置售罄 | ACTION | 后厨/前台 | 中 |
| CancelSoldOutSetRecordProcessor | 取消售罄 | ACTION | 后厨/前台 | 中 |
| PracticeSoldOutRecordProcessor | 模拟售罄 | ACTION | 测试 | 低 |
| RechargeInvoiceRecordProcessor | 充值开票 | ACTION | 用户 | 中 |
| RechargeInvoiceConfigRecordProcessor | 充值开票配置 | ACTION | 后台 | 低 |
| SwitchTakeoutModifyNoticePrintRecordProcessor | 外卖修改通知打印开关 | ACTION | 配置 | 低 |
| KDSLoginRecordProcessor | KDS登录 | ACTION | KDS设备 | 中 |
| KDSQuickLoginRecordProcessor | KDS快速登录 | ACTION | KDS设备 | 中 |

### 2.13 存酒域 (WINE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| AddWineRecordProcessor | 添加存酒 | ACTION | 门店 | 高 |
| TakeWineRecordProcessor | 取酒 | ACTION | 用户 | 高 |

### 2.14 发票域 (INVOICE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| InvoicingRecordProcessor | 开具发票 | ACTION | 用户 | 中 |

### 2.15 非桌台域 (NON_TABLE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| DelBillRecordProcessor | 删除账单 | ACTION | 后台 | 中 |
| GenerateEmptyBillRecordProcessor | 生成空账单 | ACTION | 测试 | 低 |

### 2.16 三方域 (TRIPARTITE)

| Processor类名 | 业务动作 | 动作类型 | 触发源 | 证据等级 |
|--------------|----------|----------|--------|----------|
| BindTagsRecordProcessor | 绑定商品标签 | ACTION | 三方系统 | 低 |

---

## 3. 核心业务链路

### 3.1 餐饮收银主链路

```
[开台/落单] → [点菜] → [修改订单] → [结账] → [支付] → [打印小票] → [日结/班次]
     ↓            ↓          ↓           ↓         ↓
 桌台操作    菜品操作    订单修改    订单支付   支付域
```

### 3.2 完整订单生命周期

```
1. 开台/预订 → 2. 落单 → 3. 点菜/加菜 → 4. 划菜(KDS) → 5. 结账 → 6. 支付 → 7. 完成
   (OpenBuffetTable) (PlaceOrder) (OrderModify) (KdsComplete) (PayComplete) (PayRecord)

补偿路径:
- 反结账: 6 → RevCheckoutRecordProcessor → 2
- 整单退款: 6 → WholeOrderRefundRecordProcessor → 结束
- 部分退款: 6 → PartialRefundRecordProcessor → 6
```

### 3.3 会员支付链路

```
[开卡] → [充值] → [消费支付] → [余额退款]
   ↓        ↓          ↓          ↓
开卡    充值    储值支付   退款
```

### 3.4 外卖配送链路

```
[小程序下单] → [创建配送单] → [制作] → [完成制作] → [确认送达] → [退款]
                ↓
            叫号(KDS)
```

### 3.5 押金链路

```
[开台] → [生成自助餐押金] → [支付押金] → [结转] → [退款]
            ↓                    ↓              ↓         ↓
      自助餐押     押金支付    日结班次    押金退款
```

---

## 4. 补偿路径清单

| 原动作 | 补偿动作 | 触发条件 | 补偿Processor |
|--------|----------|----------|---------------|
| 订单支付 | 反结账 | 用户取消/操作失误 | RevCheckoutRecordProcessor |
| 订单支付 | 整单退款 | 整单退货 | WholeOrderRefundRecordProcessor |
| 订单支付 | 部分退款 | 部分退货 | PartialRefundRecordProcessor |
| 取消预结 | 恢复订单 | 用户取消操作 | CancelPreSettlementRecordProcessor |
| 开台 | 撤台 | 取消用餐 | BatchRevokeOpenTableRecordProcessor |
| 联台 | 取消联台 | 取消合并 | CancelUnionTableRecordProcessor |
| 押金的支付 | 押金退款 | 取消预订 | CashPledgeRefundRecordProcessor |
| 自助餐押金 | 取消自助餐押金 | 取消用餐 | RefundBuffetPledgeRecordProcessor |
| 订单押金 | 取消订单押金 | 取消订单 | RefundOrderPledgeRecordProcessor |
| 充值 | 充值退款 | 用户申请 | RechargeRefundRecordProcessor |
| 会员卡消费 | 卡余额退款 | 退货 | BalanceRefundRecordProcessor |
| 权益销售 | 权益退款 | 退货 | EquitySaleRefundRecordProcessor |
| KDS划菜 | 撤销划菜 | 误操作 | KdsRevertRecordProcessor |
| 配送单 | 取消配送 | 用户取消 | CancelDeliveryOrderRecordProcessor |
| 外卖订单 | 外卖退款 | 用户取消 | RefundTakeoutOrderRecordProcessor |
| 菜品组合 | 取消组合 | 取消操作 | CancelPackGoodsRecordProcessor |
| 预订单 | 预订状态变更 | 预订变更 | UpdBookOrderStatusRecordProcessor |
| 支付 | 取消支付 | 用户取消 | PayCancelRecordProcessor |

---

## 5. 自动业务节拍

> 由 ScheduleTask 统一调度

### 5.1 定时任务清单

| 任务类 | 执行周期 | 业务动作 | 说明 |
|--------|----------|----------|------|
| **系统健康检查** ||||
| PingTask | 60秒 | 设备在线检测 | 检查设备是否在线 |
| **订单同步** ||||
| CompensateBookOrderTask | 1分钟 | 预订单补偿同步 | 从云端同步预订单 |
| QueryAppletOrderTask | 1分钟 | 小程序订单查询 | 同步小程序订单 |
| **支付补偿** ||||
| CsbPayTask | 1分钟 | 磁商宝支付结果查询 | 轮询支付结果 |
| **数据上传** ||||
| UploadLog2SlsTask | 1分钟 | 日志上传SLS | 阿里云日志服务 |
| UploadCashPledgeTask | 12分钟 | 押金上传 | 上传押金数据 |
| UploadOperateRecordTask | 1分钟 | 操作记录上传 | 上传操作日志 |
| OrderUploadRecords2SlsTask | 30分钟 | 订单上传记录 | 订单上传追踪 |
| **数据同步** ||||
| SyncCloudTableInfoTask | 1分钟 | 桌台信息同步 | 云端桌台数据同步 |
| SoldOutSyncTask | 1分钟 | 售罄数据同步 | 菜品售罄状态同步 |
| AdvanceOrderTakeoutTask | 1分钟 | 预订单外卖处理 | 预售外卖订单 |
| CompensateOrderTakeoutTask | 1分钟 | 外卖订单补偿 | 外卖订单同步 |
| **日结班次** ||||
| AutoDailySettlementTask | 动态(次日) | 自动日结 | 定时执行日结 |
| AutoShiftClassesTask | 3分钟 | 自动结班 | 定时结班 |
| **数据备份** ||||
| OrderDataBakService.orderDataBak | 2分钟 | MySQL数据备份 | 备份当日数据 |
| **KDS管理** ||||
| ScreenMakeDetailService.scheduleUpdateScreenStatus | 120分钟 | KDS屏幕状态更新 | 清理超时屏幕 |
| **订单校验** ||||
| OrderWholeValidService.execute | 5分钟 | 订单完整性校验 | 校验异常订单 |
| HistoryOrderWholeValidService.execute | 60分钟 | 历史订单校验 | 清理异常历史单 |
| **失败重试** ||||
| FailTaskRecordsTryTask | 6分钟 | 失败任务重试 | 重试失败的数据上传 |
| **数据库维护** ||||
| SqliteMonitorTask | 1小时 | SQLite维护 | Vacuum/优化 |
| **License管理** ||||
| LicenseExpireRemindTask | 每天10:00,17:00 | 授权到期提醒 | 发送WebSocket通知 |

### 5.2 任务依赖关系

```
启动时:
  → PingTask (设备在线)
  → WsServerManager (WebSocket服务)
  → WsClientManager (WebSocket客户端)
  → MqttClient (MQTT连接)

周期性:
  ├── 订单同步类
  │    ├── CompensateBookOrderTask
  │    └── QueryAppletOrderTask
  │
  ├── 支付补偿类
  │    └── CsbPayTask
  │
  ├── 数据上传类
  │    ├── UploadLog2SlsTask
  │    ├── UploadCashPledgeTask
  │    ├── UploadOperateRecordTask
  │    └── OrderUploadRecords2SlsTask
  │
  ├── 数据同步类
  │    ├── SyncCloudTableInfoTask
  │    ├── SoldOutSyncTask
  │    ├── AdvanceOrderTakeoutTask
  │    └── CompensateOrderTakeoutTask
  │
  ├── 日结班次类
  │    ├── AutoDailySettlementTask
  │    └── AutoShiftClassesTask
  │
  ├── 数据备份类
  │    └── OrderDataBakService
  │
  ├── KDS管理类
  │    └── ScreenMakeDetailService
  │
  ├── 订单校验类
  │    ├── OrderWholeValidService
  │    └── HistoryOrderWholeValidService
  │
  └── 失败重试类
       └── FailTaskRecordsTryTask
```

---

## 6. 触发类型分类

| 触发类型 | 说明 | 占比 |
|----------|------|------|
| USER | 用户主动触发(POS前端/小程序) | ~60% |
| SYSTEM | 系统自动触发(定时任务/状态变更) | ~25% |
| MANUAL | 人工后台触发 | ~10% |
| THIRD_PARTY | 三方系统触发 | ~5% |

---

## 7. 统计汇总

| 维度 | 数量 |
|------|------|
| Processor子包 | 22 |
| Processor类 | ~130 |
| Task类 | 13 |
| 业务域 | 9 (本表) / 12 (含基础合并) |
| 业务动作类型(OperateLogType枚举) | 80+ |
| 补偿类Processor | ~14 |

---

## 8. 关键发现

1. **支付域为补偿密集区**: 支付相关的补偿Processor最多(PayCancel, PartialRefund, WholeOrderRefund, RechargeRefund, BalanceRefund, EquitySaleRefund等)，体现了支付环节的高风险特性

2. **Task调度高度集中**: ScheduleTask 统一管理所有定时任务，采用 ScheduledThreadPool 执行

3. **KDS独立成域**: KDS 作为厨房显示系统独立管理，有完整的划菜、叫号、撤销等操作

4. **押金链路完整**: 押金域覆盖支付、结转、退款的完整生命周期

5. **会员域功能丰富**: 会员相关 Processor 超过20个，涵盖开卡、充值、消费、退款、权益等全场景

---

## 9. 证据等级说明

| 等级 | 含义 | 适用情况 |
|------|------|----------|
| 高 | 直接证据 | 代码中明确实现并可追溯 |
| 中 | 间接证据 | 通过单元测试或常见调用推断 |
| 低 | 推测证据 | 仅在历史提交或文档中出现 |
