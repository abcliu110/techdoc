# 业务模式分析

## 概述

发现 **7** 种业务模式：

### Order-Payment

**描述**: 订单与支付
**匹配对象数**: 797
**置信度**: 1.0

**匹配对象** (前20个):
- `ChoosePayTypeEnum`
- `OrderGoodsTypeEnum`
- `ExecOrderEngineBo`
- `OrderBo`
- `PromotionPayBo`
- `SdkExecuteOrderBo`
- `SyncExecuteOrderListBo`
- `OrderBo`
- `OrderDetailBo`
- `OrderPayBo`
- `OrderDetailEntity`
- `OrderEntity`
- `DiscountPayCalr`
- `OrderDiscountCalr`
- `OrderGiveCalr`
- `OrderReduceCalr`
- `JointOrderOperator`
- `SyncOrgPaySubjectCategoryService`
- `SyncOrgPaySubjectService`
- `PromotionTypeExecOrderVo`
- ... 还有 777 个

### Master-Detail

**描述**: 主从明细
**匹配对象数**: 481
**置信度**: 1.0

**匹配对象** (前20个):
- `DetailGoodsPromotionBo`
- `OrderDetailBo`
- `OrderDetailEntity`
- `CombinationGoodsDetail`
- `GoodsPracticeItem`
- `GoodsTagDetail`
- `OrgGoodsItemVo`
- `BookDetailConvert`
- `BookDetailConvertImpl`
- `RefreshOnlineStatusRequest`
- `SyncGoodsItemService`
- `SyncKDSScreenDetailService`
- `SyncOrgPosuiTemplateService`
- `SyncPrintOnlineSetService`
- `PosuiTemplateService`
- `GoodsDetail`
- `PosuiTemplateAddress`
- `PayDetailStatistics`
- `PromotionDetailStatistics`
- `GoodsDetailStatistics`
- ... 还有 461 个

### User-Role

**描述**: 用户权限
**匹配对象数**: 159
**置信度**: 1.0

**匹配对象** (前20个):
- `BaseAuthPageDto`
- `MultipleMemberTypeEnum`
- `UserAccount`
- `UserAccountConvert`
- `UserAccountConvertImpl`
- `UserAuthEnum`
- `AccountRightAuthRequest`
- `AccountRightAuthService`
- `UserAccountService`
- `SyncAccountAuthInfoService`
- `SyncOrgUserAuthService`
- `SyncUserAccountService`
- `UserInfo`
- `BusinessPermission`
- `AppletMemberInfoDTO`
- `UserAuthEnum`
- `MemberChangeTypeEnum`
- `MemberPaySubjectEnum`
- `MemberTransTypeEnum`
- `MemberCardBenefitEffectRecordVo`
- ... 还有 139 个

### Category-Tree

**描述**: 树形分类
**匹配对象数**: 73
**置信度**: 1.0

**匹配对象** (前20个):
- `CategoryLevelEnum`
- `SyncGoodsCategoryService`
- `SyncOrgPaySubjectCategoryService`
- `GoodsCategoryStatistics`
- `ZcPosCategoryDisplayEnum`
- `PaySubjectCategoryEnum`
- `CategoryManager`
- `GoodsCategoryDao`
- `OrgPaySubjectCategoryDao`
- `PrintGroupRelationCategoryDao`
- `MysqlGoodsCategoryDao`
- `MysqlOrgPaySubjectCategoryDao`
- `MysqlPrintGroupRelationCategoryDao`
- `SqliteGoodsCategoryDao`
- `SqliteOrgPaySubjectCategoryDao`
- `SqlitePrintGroupRelationCategoryDao`
- `GoodsCategory`
- `OrgPaySubjectCategory`
- `PrintGroupRelationCategory`
- `CategoryGoodsCountDTO`
- ... 还有 53 个

### Config-Reference

**描述**: 配置参照
**匹配对象数**: 443
**置信度**: 1.0

**匹配对象** (前20个):
- `OSSConst`
- `ErrorCodeEnum`
- `AliyunOssAutoConfiguration`
- `BaseCodeEnum`
- `YesOrNoEnum`
- `AmountRuleEnum`
- `AutoExecuteEnum`
- `BalanceLimittRuleEnum`
- `BrandScopeEnum`
- `CalrGoodsTypeEnum`
- `CalrRuleEnum`
- `CardLevelJoinTypeEnum`
- `CategoryLevelEnum`
- `CertificateChannelEnum`
- `ChannelTypeEnum`
- `CheckResultEnum`
- `ChoosePayTypeEnum`
- `CouponStatusEnum`
- `CrmExclusiveEnum`
- `CustomerDiscountTypeEnum`
- ... 还有 423 个

### Print-Label

**描述**: 打印标签
**匹配对象数**: 651
**置信度**: 1.0

**匹配对象** (前20个):
- `RechargeInvoicePrintRequest`
- `SyncOrgPrintTemplateService`
- `SyncPrintDeviceSetService`
- `SyncPrintGoodsGroupSetService`
- `SyncPrintGoodsSetService`
- `SyncPrintGroupFreeTimeService`
- `SyncPrintGroupRelationService`
- `SyncPrintOnlineSetService`
- `SyncPrintSetService`
- `SyncPrintTableSetService`
- `KitchenPrinterConfigService`
- `PrinterBookVo`
- `PrinterPickUpWinVo`
- `CloudPrinter`
- `Printer`
- `PrinterInfo`
- `PrintSettingVO`
- `BasePrintDTO`
- `PrintDeviceSetDTO`
- `PrintGoodsSetDTO`
- ... 还有 631 个

### Goods-SKU

**描述**: 商品SKU
**匹配对象数**: 396
**置信度**: 1.0

**匹配对象** (前20个):
- `CalrGoodsTypeEnum`
- `GoodsApplyTypeEnum`
- `OrderGoodsTypeEnum`
- `UnDiscountGoodsJoinEnum`
- `ComGoodsData`
- `ComLessGoodsData`
- `DetailGoodsPromotionBo`
- `ExecuteGoodsBo`
- `GoodsBo`
- `GoodsEngineBo`
- `GoodsEngineListBo`
- `GoodsPromotionBo`
- `JardiniereGoodsPromotionBo`
- `SdkPointRuleGoodsBo`
- `ExecuteGoodsEntity`
- `GoodsEntity`
- `GoodsPromotionEntity`
- `RuleGoodsScopeEntity`
- `FullQuantityGoodsDiscountCalr`
- `GoodsRecommendCalr`
- ... 还有 376 个

