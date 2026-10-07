# 关系网络分析

## 概述

| 指标 | 数值 |
|------|------|
| 总关系数 | 276 |
| 领域数 | 20 |

---

## 按领域分布

### kds 域 (51 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| OrderGetBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| OrderGetBo | `orgId` | OrgBaseDto | N:1 |
| OrderQueryBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| OrderQueryBo | `orgId` | OrgBaseDto | N:1 |
| KdsMakeDetailDto | `makeDetailId` | Makedetail | N:1 |
| KdsMakeInvalidDto | `orgId` | OrgBaseDto | N:1 |
| KdsQueryGoodsConfigDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| KdsQueryGoodsConfigDto | `orgId` | OrgBaseDto | N:1 |
| KdsQueryGoodsConfigDto | `detailId` | Detail | N:1 |
| PrintSettingEntity | `printSettingId` | RechargeInvoicePrintRequest | N:1 |
| QuerySwimConfigDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| QuerySwimConfigDto | `orgId` | OrgBaseDto | N:1 |
| QuerySwimConfigDto | `allotId` | Allot | N:1 |
| QuerySwimDetailAllotDto | `allotId` | Allot | N:1 |
| SwimDetailGoodsDto | `goodsId` | CalrGoodsTypeEnum | N:1 |
| SwimDetailGoodsDto | `skuId` | AppletOperateSkuDTO | N:1 |
| KdsMakeAutoDetailDto | `makeId` | Make | N:1 |
| KdsMakeAutoOperateDto | `orgId` | OrgBaseDto | N:1 |
| KdsMakeAutoOperateDto | `detailId` | Detail | N:1 |
| KdsMakeDetailBo | `makeDetailId` | Makedetail | N:1 |
| MakeBarcodeEntity | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| MakeBarcodeEntity | `orgId` | OrgBaseDto | N:1 |
| QueryScreenDetailAllotDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| QueryScreenDetailAllotDto | `orgId` | OrgBaseDto | N:1 |
| QueryScreenDetailAllotDto | `detailId` | Detail | N:1 |
| SaveAllotDto | `allotId` | Allot | N:1 |
| UpdateScreenDetailAllotDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| UpdateScreenDetailAllotDto | `orgId` | OrgBaseDto | N:1 |
| UpdateScreenDetailAllotDto | `detailId` | Detail | N:1 |
| MakeBarcodeQuery | `groupId` | GroupBuyExchangeCouponCalr | N:1 |

*... 还有 21 条关系*

### order 域 (38 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| CloudOrderDetailExtAddDto | `combinationId` | Combination | N:1 |
| CloudOrderExtAddDto | `appId` | App | N:1 |
| CloudOrderExtAddDto | `nfcTagId` | Nfctag | N:1 |
| CloudOrderExtAddDto | `openId` | Open | N:1 |
| PosOrderCoverDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| PosOrderDetailExtAddDto | `combinationId` | Combination | N:1 |
| QueryUploadOrderResultDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| QueryUploadOrderResultDto | `orgId` | OrgBaseDto | N:1 |
| QueryUploadOrderResultDto | `taskId` | Task | N:1 |
| QueryUploadOrderResultDto | `relationId` | Relation | N:1 |
| DeleteOrderDetailRequest | `tableId` | SyncPrintTableSetService | N:1 |
| DeleteOrderDetailRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GetOrderBillHeadRequest | `tableId` | SyncPrintTableSetService | N:1 |
| GetOrderDetailRequest | `tableId` | SyncPrintTableSetService | N:1 |
| ModifyGoodsQtyOrderDetailRequest | `tableId` | SyncPrintTableSetService | N:1 |
| ModifyGoodsQtyOrderDetailRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| OrderDetailTasteRequest | `detailId` | Detail | N:1 |
| OrderDetailTasteRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| OrderDetailTasteRequest | `practiceId` | Practice | N:1 |
| OrderStructureAccountRequest | `accountId` | Account | N:1 |
| DcqModifyQtyRequest | `detailId` | Detail | N:1 |
| CertificateQueryDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| CertificateQueryDto | `orgId` | OrgBaseDto | N:1 |
| CancelCouponPopupRequest | `payId` | ChoosePayTypeEnum | N:1 |
| PartialRefundRequest | `payId` | ChoosePayTypeEnum | N:1 |
| PayRetryRequest | `payId` | ChoosePayTypeEnum | N:1 |
| HoldConsumeQueryDto | `companyId` | Company | N:1 |
| HoldConsumeQueryDto | `employeeTransId` | Employeetrans | N:1 |
| HoldConsumeRefundDto | `transOrgId` | OrgBaseDto | N:1 |
| HoldConsumeRefundDto | `companyId` | Company | N:1 |

*... 还有 8 条关系*

### print 域 (35 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| PrintGoodsCategoryDTO | `categoryId` | CategoryLevelEnum | N:1 |
| WineOperateDetailDTO | `skuId` | AppletOperateSkuDTO | N:1 |
| TicketPrint | `printId` | RechargeInvoicePrintRequest | N:1 |
| PrintBatchGroup | `printTaskId` | RechargeInvoicePrintRequest | N:1 |
| PrinterReq | `printId` | RechargeInvoicePrintRequest | N:1 |
| PrinterReq | `printGroupId` | GroupBuyExchangeCouponCalr | N:1 |
| GetPrintTicketJobRequest | `jobId` | Job | N:1 |
| PrintRequest | `printId` | RechargeInvoicePrintRequest | N:1 |
| PrintRequest | `printTaskId` | RechargeInvoicePrintRequest | N:1 |
| WsPrintTicketJobRequest | `jobId` | Job | N:1 |
| WsPrintTicketJobRequest | `printId` | RechargeInvoicePrintRequest | N:1 |
| AppletAreaGroupRequest | `appletAreaGroupId` | GroupBuyExchangeCouponCalr | N:1 |
| AppletAreaGroupRequest | `appletPrintId` | RechargeInvoicePrintRequest | N:1 |
| AppletAreaGroupRequest | `appletRetainPrintId` | RechargeInvoicePrintRequest | N:1 |
| AreaRequest | `areaId` | Area | N:1 |
| ChannelRequest | `channelId` | Channel | N:1 |
| DeletePrintSetRequest | `printId` | RechargeInvoicePrintRequest | N:1 |
| GoodsRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GoodsRequest | `channelShopId` | Channelshop | N:1 |
| OrgPrintSettingDelRequest | `printSettingId` | RechargeInvoicePrintRequest | N:1 |
| QueryPrintGoodsGroupV2Request | `printSettingId` | RechargeInvoicePrintRequest | N:1 |
| QueryPrintSetListRequest | `printId` | RechargeInvoicePrintRequest | N:1 |
| AppletAreaGroupResponse | `appletAreaGroupId` | GroupBuyExchangeCouponCalr | N:1 |
| AppletAreaGroupResponse | `appletPrintId` | RechargeInvoicePrintRequest | N:1 |
| AppletAreaGroupResponse | `appletRetainPrintId` | RechargeInvoicePrintRequest | N:1 |
| CategoryGoodsVO | `categoryId` | CategoryLevelEnum | N:1 |
| ChannelResponse | `channelId` | Channel | N:1 |
| CloudPrintResponse | `platformOrderId` | OrderGoodsTypeEnum | N:1 |
| GetPrintTicketResponse | `jobId` | Job | N:1 |
| GoodsResponse | `goodsId` | CalrGoodsTypeEnum | N:1 |

*... 还有 5 条关系*

### member 域 (31 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| GetCardInfoRequest | `cardId` | Card | N:1 |
| GetPreferenceAndLabelRequest | `customerId` | CustomerDiscountTypeEnum | N:1 |
| QueryCardSchemeLevelRequest | `cardSchemeId` | Cardscheme | N:1 |
| QueryRechargePackageRequest | `cardSchemeId` | Cardscheme | N:1 |
| QueryRechargePackageRequest | `cardLevelId` | Cardlevel | N:1 |
| QueryRechargePackageRequest | `cardId` | Card | N:1 |
| QueryRechargePackageRequest | `customerId` | CustomerDiscountTypeEnum | N:1 |
| PointExchangeGiftDetailsQueryRequest | `customerId` | CustomerDiscountTypeEnum | N:1 |
| GiftCardConsumeRequest | `couponId` | Coupon | N:1 |
| ChangeCardPwdRequest | `cardId` | Card | N:1 |
| ResetCardPwdRequest | `cardId` | Card | N:1 |
| ResetCardPwdRequest | `cardSchemeId` | Cardscheme | N:1 |
| ResetCardPwdRequest | `cardLevelId` | Cardlevel | N:1 |
| UpdateCardInfoRequest | `cardId` | Card | N:1 |
| UpdateCardInfoRequest | `cardSchemeId` | Cardscheme | N:1 |
| UpdateCardInfoRequest | `cardLevelId` | Cardlevel | N:1 |
| CardConsumeRollbackRequest | `cardId` | Card | N:1 |
| ConsumeResultRequest | `cardId` | Card | N:1 |
| MemberCardConsumeRequest | `cardId` | Card | N:1 |
| RechargeRefundRequest | `cardId` | Card | N:1 |
| RechargeRefundRequest | `transId` | Trans | N:1 |
| BenefitMarketingOtherScopeVo | `otherId` | Other | N:1 |
| BenefitMarketingRuleVo | `ruleId` | Rule | N:1 |
| BenefitPromotionOtherScopeVo | `otherId` | Other | N:1 |
| EquitySaleResponse | `transQueueId` | Transqueue | N:1 |
| OpenBenefitCardVo | `transQueueId` | Transqueue | N:1 |
| OpenCardVo | `transQueueId` | Transqueue | N:1 |
| OpenCardVo | `bizId` | Biz | N:1 |
| RechargeResponse | `transQueueId` | Transqueue | N:1 |
| SalesGiftCardVo | `transQueueId` | Transqueue | N:1 |

*... 还有 1 条关系*

### soldout 域 (26 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| QuerySoldOutOccupyListBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| QuerySoldOutOccupyListBo | `orgId` | OrgBaseDto | N:1 |
| QuerySoldOutSettingListBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| QuerySoldOutSettingListBo | `orgId` | OrgBaseDto | N:1 |
| SoldOutDailySettlementBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| SoldOutDailySettlementBo | `orgId` | OrgBaseDto | N:1 |
| SoldOutOccupyDetailBo | `goodsId` | CalrGoodsTypeEnum | N:1 |
| SoldOutOccupyDetailBo | `skuId` | AppletOperateSkuDTO | N:1 |
| SoldOutStockHandleDetailBo | `goodsId` | CalrGoodsTypeEnum | N:1 |
| AppletSoldOutGoodsQtyCallbackDTO | `skuId` | AppletOperateSkuDTO | N:1 |
| AppletSoldOutSkuDetailDTO | `skuId` | AppletOperateSkuDTO | N:1 |
| SoldOutStockChannelSettingDTO | `skuId` | AppletOperateSkuDTO | N:1 |
| SoldOutOccupyResultGoodsEntity | `notEnoughGoodsId` | CalrGoodsTypeEnum | N:1 |
| PracticeSoldOutRequest | `practiceId` | Practice | N:1 |
| PracticeSoldOutRequest | `practiceItemId` | Practiceitem | N:1 |
| PracticeDetails | `practiceId` | Practice | N:1 |
| PracticeDetails | `practiceItemId` | Practiceitem | N:1 |
| SoldOutStockHandleDetailDto | `goodsId` | CalrGoodsTypeEnum | N:1 |
| PosSoldOutOccupyBizService | `soldOutStocksId` | Soldoutstocks | N:1 |
| PosSoldOutOccupyBizService | `soldOutStocksId` | Soldoutstocks | N:1 |
| UpdateOccupyNumBo | `soldOutStocksId` | Soldoutstocks | N:1 |
| UpdateOccupyNumBo | `soldOutStocksId` | Soldoutstocks | N:1 |
| UpdateOccupyNumBoBuilder | `soldOutStocksId` | Soldoutstocks | N:1 |
| UpdateOccupyNumBoBuilder | `soldOutStocksId` | Soldoutstocks | N:1 |
| QuerySoldOutDetailVo | `goodsId` | CalrGoodsTypeEnum | N:1 |
| SoldOutOccupyVo | `notEnoughGoodsId` | CalrGoodsTypeEnum | N:1 |

### base 域 (23 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| BaseDataVo | `bizId` | Biz | N:1 |
| BaseDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| BaseVo | `traceId` | Trace | N:1 |
| OperateBaseVo | `bizId` | Biz | N:1 |
| OrgBaseDto | `orgId` | OrgBaseDto | N:1 |
| OrgBaseDto | `brandId` | BrandScopeEnum | N:1 |
| AccountRightData | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| AccountRightData | `accountId` | Account | N:1 |
| GetOrgLicensesDTO | `orgId` | OrgBaseDto | N:1 |
| GetAccountRightListRequest | `accountId` | Account | N:1 |
| OperateShortAccountRequest | `shortAccountId` | Shortaccount | N:1 |
| ClearSiteInfoMqttDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| ClearSiteInfoMqttDto | `orgId` | OrgBaseDto | N:1 |
| QueryInvoiceRequest | `operatorId` | BaseOperator | N:1 |
| RechargeInvoicePrintRequest | `transId` | Trans | N:1 |
| ReqMessageDto | `messageId` | Message | N:1 |
| ResDbMangerDto | `messageId` | Message | N:1 |
| DictionaryResponse | `id` | Id | N:1 |
| DictionaryResponse | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| BindDeviceResponse | `orgId` | OrgBaseDto | N:1 |
| BindDeviceResponse | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| OrgResponse | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| OrgResponse | `orgId` | OrgBaseDto | N:1 |

### dao 域 (13 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| BookDetailDTO | `dataId` | Data | N:1 |
| BookDetailDTO | `relationDataId` | Relationdata | N:1 |
| AppletOperateSkuDTO | `skuId` | AppletOperateSkuDTO | N:1 |
| CategoryGoodsCountDTO | `categoryId` | CategoryLevelEnum | N:1 |
| CategoryGoodsCountDTO | `parentId` | Parent | N:1 |
| KDSPrintGroupSettingQuery | `printGroupId` | GroupBuyExchangeCouponCalr | N:1 |
| KDSPrintGroupSettingQuery | `categoryId` | CategoryLevelEnum | N:1 |
| KDSScreenAllotScoreQuery | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| KDSScreenAllotScoreQuery | `detailId` | Detail | N:1 |
| KDSScreenMakeDetailTagQuery | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| KDSScreenMakeDetailTagQuery | `orgId` | OrgBaseDto | N:1 |
| SwimConfigQuery | `allotId` | Allot | N:1 |
| SwimConfigQuery | `swimId` | Swim | N:1 |

### request 域 (13 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| AppletSoldOutConfirmRequest | `fromUserId` | UserAccount | N:1 |
| BatchRefundPledgeRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgeNullifyRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgePrintRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgeRecordListRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgeRetryRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgeRetryRequest | `id` | Id | N:1 |
| CashPledgeUseRequest | `cashPledgeId` | Cashpledge | N:1 |
| CashPledgeUseRequest | `payId` | ChoosePayTypeEnum | N:1 |
| PledgePayRecordRequest | `cashPledgeId` | Cashpledge | N:1 |
| PledgeRefundInfo | `cashPledgeId` | Cashpledge | N:1 |
| QueryWineGoodsListRequest | `categoryId` | CategoryLevelEnum | N:1 |
| TakeWineTicketRepeatPrintRequest | `depositId` | Deposit | N:1 |

### goods 域 (10 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| GetGoodsCategoryRequest | `areaId` | Area | N:1 |
| GetPracticeDetailRequest | `practiceId` | Practice | N:1 |
| GetPracticeDetailRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GetPracticeGroupingsRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GetTagGroupingsRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GoodsBuffetListRequest | `areaId` | Area | N:1 |
| GoodsCombineRequest | `skuId` | AppletOperateSkuDTO | N:1 |
| GoodsCombineRequest | `dataId` | Data | N:1 |
| GoodsPracticeRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |
| GoodsTagRequest | `goodsId` | CalrGoodsTypeEnum | N:1 |

### biz 域 (8 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| RechargePackageInfoDto | `packageStallsId` | Packagestalls | N:1 |
| RechargePackageInfoDto | `rechargePackageId` | Rechargepackage | N:1 |
| TemplateAddress | `cateSubDetailId` | Catesubdetail | N:1 |
| PrintTableSetDTO | `tablePrintId` | SyncPrintTableSetService | N:1 |
| TableAccountRequest | `accountId` | Account | N:1 |
| BaseDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| PayResultByTransOrderNoQueryDto | `cardId` | Card | N:1 |
| CancelVerifyDto | `orgId` | OrgBaseDto | N:1 |

### dto 域 (8 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| CombineDiscountAmountDTO | `combineDetailId` | Combinedetail | N:1 |
| CombineDiscountAmountDTO | `maxAmountDetailId` | Maxamountdetail | N:1 |
| MemberMarketingGiftDto | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| MemberMarketingGiftDto | `objectId` | Object | N:1 |
| OrderTableExclusiveDto | `accountId` | Account | N:1 |
| TakeWineDetailDTO | `depositId` | Deposit | N:1 |
| TakeWineDetailDTO | `depositDetailId` | Depositdetail | N:1 |
| TakeWineDetailDTO | `skuId` | AppletOperateSkuDTO | N:1 |

### scrm 域 (5 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| MutexShareValidBo | `promotionId` | PromotionSdkClient | N:1 |
| SdkLimitGiftBo | `giftId` | GiftRealTypeEnum | N:1 |
| SyncPointRuleListBo | `groupId` | GroupBuyExchangeCouponCalr | N:1 |
| CustomerGiftCurrentDayUseEntity | `giftId` | GiftRealTypeEnum | N:1 |
| SdkLimitGiftEntity | `giftId` | GiftRealTypeEnum | N:1 |

### promotion 域 (3 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| PromotionValidJoinCountDto | `customerId` | CustomerDiscountTypeEnum | N:1 |
| PromotionValidJoinCountDto | `orgId` | OrgBaseDto | N:1 |
| CancelPackGoodsRequest | `dataId` | Data | N:1 |

### takeout 域 (3 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| CancelDeliveryDetailResponse | `platformDeliveryOrderId` | OrderGoodsTypeEnum | N:1 |
| CreateDeliveryOrderResponse | `platformDeliveryOrderId` | OrderGoodsTypeEnum | N:1 |
| DispatchResponse | `originId` | Origin | N:1 |

### vo 域 (3 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| MakeOptTimeResponse | `detailId` | Detail | N:1 |
| CashPledgePayResponse | `cashPledgeId` | Cashpledge | N:1 |
| WineGoodsCategoryVO | `categoryId` | CategoryLevelEnum | N:1 |

### web 域 (2 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| KDSQueryPrintSettingGoodsCategoryListHandler | `categoryId` | CategoryLevelEnum | N:1 |
| GoodsCategoryResponse | `categoryId` | CategoryLevelEnum | N:1 |

### book 域 (1 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| GetBookTableRequest | `areaId` | Area | N:1 |

### common 域 (1 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| BusinessException | `traceId` | Trace | N:1 |

### table 域 (1 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| GetTableRequest | `areaId` | Area | N:1 |

### tripartite 域 (1 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
| DishesBindQueryRequest | `categoryId` | CategoryLevelEnum | N:1 |

