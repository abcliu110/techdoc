# 业务领域详情

---

## order 领域

**描述**: 订单域
**对象数**: 612
**聚合根数**: 17
**实体数**: 107
**值对象数**: 488

### 聚合根

- `PayResultByTransOrderNoQueryDto`
- `OrderTableExclusiveDto`
- `OrderGetBo`
- `OrderQueryBo`
- `CloudOrderDetailExtAddDto`
- `CloudOrderExtAddDto`
- `PosOrderCoverDto`
- `PosOrderDetailExtAddDto`
- `QueryUploadOrderResultDto`
- `DeleteOrderDetailRequest`
- `GetOrderBillHeadRequest`
- `GetOrderDetailRequest`
- `ModifyGoodsQtyOrderDetailRequest`
- `OrderDetailTasteRequest`
- `OrderStructureAccountRequest`
- `GetOrderDetailPromotionRequest`
- `CreateDeliveryOrderResponse`

### ID引用关系 (共 38 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| CloudOrderDetailExtAddDto | combinationId | Combination |
| CloudOrderExtAddDto | appId | App |
| CloudOrderExtAddDto | nfcTagId | Nfctag |
| CloudOrderExtAddDto | openId | Open |
| PosOrderCoverDto | groupId | GroupBuyExchangeCouponCalr |
| PosOrderDetailExtAddDto | combinationId | Combination |
| QueryUploadOrderResultDto | groupId | GroupBuyExchangeCouponCalr |
| QueryUploadOrderResultDto | orgId | OrgBaseDto |
| QueryUploadOrderResultDto | taskId | Task |
| QueryUploadOrderResultDto | relationId | Relation |
| DeleteOrderDetailRequest | tableId | SyncPrintTableSetService |
| DeleteOrderDetailRequest | goodsId | CalrGoodsTypeEnum |
| GetOrderBillHeadRequest | tableId | SyncPrintTableSetService |
| GetOrderDetailRequest | tableId | SyncPrintTableSetService |
| ModifyGoodsQtyOrderDetailRequest | tableId | SyncPrintTableSetService |
| ModifyGoodsQtyOrderDetailRequest | goodsId | CalrGoodsTypeEnum |
| OrderDetailTasteRequest | detailId | Detail |
| OrderDetailTasteRequest | goodsId | CalrGoodsTypeEnum |
| OrderDetailTasteRequest | practiceId | Practice |
| OrderStructureAccountRequest | accountId | Account |

*... 还有 18 条关系*

---

## goods 领域

**描述**: 商品域
**对象数**: 360
**聚合根数**: 26
**实体数**: 75
**值对象数**: 259

### 聚合根

- `AppletOperateSkuDTO`
- `CategoryGoodsCountDTO`
- `GetGoodsCategoryRequest`
- `GoodsBuffetListRequest`
- `GoodsCombineRequest`
- `GoodsPracticeRequest`
- `GoodsTagRequest`
- `KdsQueryGoodsConfigDto`
- `SwimDetailGoodsDto`
- `QueryOrgPrintSettingGoodsRequest`
- `PayGoodsDto`
- `PrintGoodsCategoryDTO`
- `GoodsRequest`
- `QueryPrintGoodsGroupV2Request`
- `CategoryGoodsVO`
- `GoodsResponse`
- `PrintGoodsGroupPosResponse`
- `CancelPackGoodsRequest`
- `QueryWineGoodsListRequest`
- `AppletSoldOutGoodsQtyCallbackDTO`
- ... 还有 6 个

### ID引用关系 (共 10 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| GetGoodsCategoryRequest | areaId | Area |
| GetPracticeDetailRequest | practiceId | Practice |
| GetPracticeDetailRequest | goodsId | CalrGoodsTypeEnum |
| GetPracticeGroupingsRequest | goodsId | CalrGoodsTypeEnum |
| GetTagGroupingsRequest | goodsId | CalrGoodsTypeEnum |
| GoodsBuffetListRequest | areaId | Area |
| GoodsCombineRequest | skuId | AppletOperateSkuDTO |
| GoodsCombineRequest | dataId | Data |
| GoodsPracticeRequest | goodsId | CalrGoodsTypeEnum |
| GoodsTagRequest | goodsId | CalrGoodsTypeEnum |

---

## print 领域

**描述**: 打印域
**对象数**: 274
**聚合根数**: 19
**实体数**: 34
**值对象数**: 221

### 聚合根

- `RechargeInvoicePrintRequest`
- `PrintTableSetDTO`
- `KDSPrintGroupSettingQuery`
- `PrintSettingEntity`
- `PrintSettingVo`
- `TicketPrint`
- `PrintBatchGroup`
- `PrinterReq`
- `GetPrintTicketJobRequest`
- `PrintRequest`
- `WsPrintTicketJobRequest`
- `DeletePrintSetRequest`
- `OrgPrintSettingDelRequest`
- `QueryPrintSetListRequest`
- `CloudPrintResponse`
- `GetPrintTicketResponse`
- `PrintOnlineSetV2Response`
- `CashPledgePrintRequest`
- `TakeWineTicketRepeatPrintRequest`

### ID引用关系 (共 35 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| PrintGoodsCategoryDTO | categoryId | CategoryLevelEnum |
| WineOperateDetailDTO | skuId | AppletOperateSkuDTO |
| TicketPrint | printId | RechargeInvoicePrintRequest |
| PrintBatchGroup | printTaskId | RechargeInvoicePrintRequest |
| PrinterReq | printId | RechargeInvoicePrintRequest |
| PrinterReq | printGroupId | GroupBuyExchangeCouponCalr |
| GetPrintTicketJobRequest | jobId | Job |
| PrintRequest | printId | RechargeInvoicePrintRequest |
| PrintRequest | printTaskId | RechargeInvoicePrintRequest |
| WsPrintTicketJobRequest | jobId | Job |
| WsPrintTicketJobRequest | printId | RechargeInvoicePrintRequest |
| AppletAreaGroupRequest | appletAreaGroupId | GroupBuyExchangeCouponCalr |
| AppletAreaGroupRequest | appletPrintId | RechargeInvoicePrintRequest |
| AppletAreaGroupRequest | appletRetainPrintId | RechargeInvoicePrintRequest |
| AreaRequest | areaId | Area |
| ChannelRequest | channelId | Channel |
| DeletePrintSetRequest | printId | RechargeInvoicePrintRequest |
| GoodsRequest | goodsId | CalrGoodsTypeEnum |
| GoodsRequest | channelShopId | Channelshop |
| OrgPrintSettingDelRequest | printSettingId | RechargeInvoicePrintRequest |

*... 还有 15 条关系*

---

## member 领域

**描述**: 会员域
**对象数**: 179
**聚合根数**: 3
**实体数**: 39
**值对象数**: 137

### 聚合根

- `CustomerGiftCurrentDayUseEntity`
- `MemberMarketingGiftDto`
- `MemberCardConsumeRequest`

### ID引用关系 (共 31 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| GetCardInfoRequest | cardId | Card |
| GetPreferenceAndLabelRequest | customerId | CustomerDiscountTypeEnum |
| QueryCardSchemeLevelRequest | cardSchemeId | Cardscheme |
| QueryRechargePackageRequest | cardSchemeId | Cardscheme |
| QueryRechargePackageRequest | cardLevelId | Cardlevel |
| QueryRechargePackageRequest | cardId | Card |
| QueryRechargePackageRequest | customerId | CustomerDiscountTypeEnum |
| PointExchangeGiftDetailsQueryRequest | customerId | CustomerDiscountTypeEnum |
| GiftCardConsumeRequest | couponId | Coupon |
| ChangeCardPwdRequest | cardId | Card |
| ResetCardPwdRequest | cardId | Card |
| ResetCardPwdRequest | cardSchemeId | Cardscheme |
| ResetCardPwdRequest | cardLevelId | Cardlevel |
| UpdateCardInfoRequest | cardId | Card |
| UpdateCardInfoRequest | cardSchemeId | Cardscheme |
| UpdateCardInfoRequest | cardLevelId | Cardlevel |
| CardConsumeRollbackRequest | cardId | Card |
| ConsumeResultRequest | cardId | Card |
| MemberCardConsumeRequest | cardId | Card |
| RechargeRefundRequest | cardId | Card |

*... 还有 11 条关系*

---

## payment 领域

**描述**: 支付域
**对象数**: 177
**聚合根数**: 5
**实体数**: 30
**值对象数**: 142

### 聚合根

- `PayRetryRequest`
- `OnlinePayDto`
- `CancelSettlePayRequest`
- `PledgePayRecordRequest`
- `CashPledgePayResponse`

---

## kds 领域

**描述**: 厨房显示域
**对象数**: 122
**聚合根数**: 12
**实体数**: 20
**值对象数**: 90

### 聚合根

- `KDSScreenAllotScoreQuery`
- `KDSScreenMakeDetailTagQuery`
- `KdsMakeDetailDto`
- `KdsMakeInvalidDto`
- `KdsMakeAutoDetailDto`
- `KdsMakeAutoOperateDto`
- `KdsMakeDetailBo`
- `KdsMakeAutoDetailRequest`
- `KdsMakeAutoOperateRequest`
- `KDSMakeBathOperateShopRequest`
- `KDSMakeOperateShopDTO`
- `KDSQueryWorkDateRequest`

### ID引用关系 (共 51 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| OrderGetBo | groupId | GroupBuyExchangeCouponCalr |
| OrderGetBo | orgId | OrgBaseDto |
| OrderQueryBo | groupId | GroupBuyExchangeCouponCalr |
| OrderQueryBo | orgId | OrgBaseDto |
| KdsMakeDetailDto | makeDetailId | Makedetail |
| KdsMakeInvalidDto | orgId | OrgBaseDto |
| KdsQueryGoodsConfigDto | groupId | GroupBuyExchangeCouponCalr |
| KdsQueryGoodsConfigDto | orgId | OrgBaseDto |
| KdsQueryGoodsConfigDto | detailId | Detail |
| PrintSettingEntity | printSettingId | RechargeInvoicePrintRequest |
| QuerySwimConfigDto | groupId | GroupBuyExchangeCouponCalr |
| QuerySwimConfigDto | orgId | OrgBaseDto |
| QuerySwimConfigDto | allotId | Allot |
| QuerySwimDetailAllotDto | allotId | Allot |
| SwimDetailGoodsDto | goodsId | CalrGoodsTypeEnum |
| SwimDetailGoodsDto | skuId | AppletOperateSkuDTO |
| KdsMakeAutoDetailDto | makeId | Make |
| KdsMakeAutoOperateDto | orgId | OrgBaseDto |
| KdsMakeAutoOperateDto | detailId | Detail |
| KdsMakeDetailBo | makeDetailId | Makedetail |

*... 还有 31 条关系*

---

## table 领域

**描述**: 餐桌域
**对象数**: 116
**聚合根数**: 5
**实体数**: 16
**值对象数**: 95

### 聚合根

- `TableAccountRequest`
- `GetBookTableRequest`
- `AllotTableAreaVo`
- `TableResponse`
- `GetTableRequest`

### ID引用关系 (共 1 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| GetTableRequest | areaId | Area |

---

## takeout 领域

**描述**: 外卖域
**对象数**: 44
**聚合根数**: 1
**实体数**: 0
**值对象数**: 43

### 聚合根

- `CancelDeliveryDetailResponse`

### ID引用关系 (共 3 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| CancelDeliveryDetailResponse | platformDeliveryOrderId | OrderGoodsTypeEnum |
| CreateDeliveryOrderResponse | platformDeliveryOrderId | OrderGoodsTypeEnum |
| DispatchResponse | originId | Origin |

---

## book 领域

**描述**: 预订域
**对象数**: 29
**聚合根数**: 1
**实体数**: 6
**值对象数**: 22

### 聚合根

- `BookDetailDTO`

### ID引用关系 (共 1 条)

| 源对象 | 引用字段 | 目标推断 |
|--------|----------|----------|
| GetBookTableRequest | areaId | Area |

---

