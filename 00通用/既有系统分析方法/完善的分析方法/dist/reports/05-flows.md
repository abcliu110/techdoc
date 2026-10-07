# 业务服务分析

## 概述

| 指标 | 数值 |
|------|------|
| 总服务数 | 409 |
| Service服务 | 409 |
| Processor处理器 | 0 |

---

## 按领域分布

- **order**: 74 个服务
- **base**: 65 个服务
- **biz**: 62 个服务
- **other**: 58 个服务
- **kds**: 26 个服务
- **table**: 26 个服务
- **member**: 24 个服务
- **takeout**: 18 个服务
- **book**: 16 个服务
- **soldout**: 16 个服务
- **promotion**: 9 个服务
- **print**: 8 个服务
- **goods**: 7 个服务

## 服务列表

### AccountRightAuthService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.account`
- **文件**: AccountRightAuthService.java
- **方法数**: 1

**方法列表**:
- `auth(final)`

---

### ShortAccountService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.account`
- **文件**: ShortAccountService.java
- **方法数**: 1

**方法列表**:
- `operateShortAccount(final)`

---

### UserAccountService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.account`
- **文件**: UserAccountService.java
- **方法数**: 1

**方法列表**:
- `syncAccountData()`

---

### BatchGetOrgLicensesService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.auth`
- **文件**: BatchGetOrgLicensesService.java
- **方法数**: 3

**方法列表**:
- `buildLicensesInfoCache()`
- `checkLicenses(final)`
- `checkLicensesByTask(final, final)`

---

### GroupParamService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.basic`
- **文件**: GroupParamService.java
- **方法数**: 2

**方法列表**:
- `buildGroupParamCache()`
- `deletedAndCreate(final)`

---

### NotifyWorkDateService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.basic`
- **文件**: NotifyWorkDateService.java
- **方法数**: 1

**方法列表**:
- `notifyWorkDateChange(final, Integer)`

---

### OrgParamService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.basic`
- **文件**: OrgParamService.java
- **方法数**: 2

**方法列表**:
- `buildOrgParamCache()`
- `deletedAndCreate(final)`

---

### PosMcToPosMqttService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.basic`
- **文件**: PosMcToPosMqttService.java
- **方法数**: 1

**方法列表**:
- `mqttClear(final)`

---

### SyncCashPledgeService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.cashPledge`
- **文件**: SyncCashPledgeService.java
- **方法数**: 1

**方法列表**:
- `syncCashPledge(final, final, final)`

---

### OrgBasicInfoSyncService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: OrgBasicInfoSyncService.java
- **方法数**: 9

**方法列表**:
- `asyncTask(final)`
- `basicInfoSync(final)`
- `syncPromotionParam()`
- `syncCombineHandle(final, final, final)`
- `syncGoodsTag(final, final, final)`

---

### SyncAccountAuthInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncAccountAuthInfoService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncBasicInfoSelector

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncBasicInfoSelector.java
- **方法数**: 1

**方法列表**:
- `select(final)`

---

### SyncBuffetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncBuffetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncCombinationGoodsService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncCombinationGoodsService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncDeviceAreaService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncDeviceAreaService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGoodsCategoryService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGoodsCategoryService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGoodsItemService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGoodsItemService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGoodsPictureService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGoodsPictureService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGoodsPracticeService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGoodsPracticeService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGoodsTagService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGoodsTagService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGroupDictionaryService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGroupDictionaryService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncGroupParamService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncGroupParamService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncKDSScreenDetailService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncKDSScreenDetailService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncKDSScreenParamService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncKDSScreenParamService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgAllotService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgAllotService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgBusinessTimeSlotService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgBusinessTimeSlotService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgDeviceInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgDeviceInfoService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgInfoService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgMealTimeSlotService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgMealTimeSlotService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgMenuPosTemplateService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgMenuPosTemplateService.java
- **方法数**: 2

**方法列表**:
- `sync(final, final)`
- `deleteDirectory(final)`

---

### SyncOrgParamService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgParamService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgPaySubjectCategoryService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgPaySubjectCategoryService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgPaySubjectService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgPaySubjectService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgPosuiTemplateService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgPosuiTemplateService.java
- **方法数**: 2

**方法列表**:
- `sync(final, final)`
- `deleteDirectory(final)`

---

### SyncOrgPrintTemplateService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgPrintTemplateService.java
- **方法数**: 2

**方法列表**:
- `sync(final, final)`
- `deleteDirectory(final)`

---

### SyncOrgShiftTimeSlotService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgShiftTimeSlotService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgTagRelationService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgTagRelationService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncOrgUserAuthService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncOrgUserAuthService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintDeviceSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintDeviceSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintGoodsGroupSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintGoodsGroupSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintGoodsSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintGoodsSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintGroupFreeTimeService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintGroupFreeTimeService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintGroupRelationService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintGroupRelationService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintOnlineSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintOnlineSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncPrintTableSetService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncPrintTableSetService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncReceiptTemplateService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncReceiptTemplateService.java
- **方法数**: 2

**方法列表**:
- `sync(final, final)`
- `deleteDirectory(final)`

---

### SyncShortAccountService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncShortAccountService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncSupportedGroupBuyingService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncSupportedGroupBuyingService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncTableDishesService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncTableDishesService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncTableInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncTableInfoService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncTSGoodsInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncTSGoodsInfoService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### SyncUserAccountService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dataSync`
- **文件**: SyncUserAccountService.java
- **方法数**: 1

**方法列表**:
- `sync(final, final)`

---

### DbManagerService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dbManager`
- **文件**: DbManagerService.java
- **方法数**: 7

**方法列表**:
- `operate(final)`
- `reCalculateOrder(final, final)`
- `updateCloudWorkDate(final, final)`
- `kdsScreenMakeUpload(final, final)`
- `syncCashPledge(final)`

---

### ClearSiteInfoService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.device`
- **文件**: ClearSiteInfoService.java
- **方法数**: 1

**方法列表**:
- `clear()`

---

### DeviceRegService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.device`
- **文件**: DeviceRegService.java
- **方法数**: 1

**方法列表**:
- `deviceRegister(final)`

---

### DictionaryService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.dictionary`
- **文件**: DictionaryService.java
- **方法数**: 1

**方法列表**:
- `buildDictCache()`

---

### PingTask

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.health`
- **文件**: PingTask.java
- **方法数**: 1

**方法列表**:
- `checkDeviceIsOnline()`

---

### InvoiceService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.invoice`
- **文件**: InvoiceService.java
- **方法数**: 3

**方法列表**:
- `create(final)`
- `count(final)`
- `pageList(final)`

---

### KDSBasicManagerService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.kds`
- **文件**: KDSBasicManagerService.java
- **方法数**: 1

**方法列表**:
- `updateScreenStatus(final)`

---

### LocalCacheService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.localCahe`
- **文件**: LocalCacheService.java
- **方法数**: 10

**方法列表**:
- `expireAt(final, final, final)`
- `expire(final, final)`
- `deleteByFieldAndLikeKey(final, final)`
- `exists(final)`
- `del(final)`

---

### LoginService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.login`
- **文件**: LoginService.java
- **方法数**: 3

**方法列表**:
- `login(final)`
- `logout(final)`
- `clearOrderTableExclusive(final)`

---

### KitchenPrinterConfigService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.org`
- **文件**: KitchenPrinterConfigService.java
- **方法数**: 1

**方法列表**:
- `syncKitchenPrinterConfig()`

---

### OrgRegService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.org`
- **文件**: OrgRegService.java
- **方法数**: 4

**方法列表**:
- `orgRegister(final)`
- `orgRegCheck(final)`
- `orgIsRegister(final)`
- `registerPOS(final)`

---

### ModifyServerTimeService

- **领域**: base
- **包路径**: `com.shouqianba.localserver.base.service.time`
- **文件**: ModifyServerTimeService.java
- **方法数**: 3

**方法列表**:
- `modifyTime(final)`
- `modifyLocalTime(final)`
- `run()`

---

### GoodsDetail

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.bean.order`
- **文件**: GoodsDetail.java
- **方法数**: 10

**方法列表**:
- `calculateTotalSaleAmount()`
- `isDifferent(final)`
- `notPosDiscount()`
- `joinPosDiscountAmount()`
- `calcPackingRemainAmount()`

---

### UploadOrderCallBackDto

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.bean.order`
- **文件**: UploadOrderCallBackDto.java
- **方法数**: 1

**方法列表**:
- `isSuccess()`

---

### PushMessage

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.bean.websocket`
- **文件**: PushMessage.java
- **方法数**: 23

**方法列表**:
- `createOrderReminder(final)`
- `createWorkClasses(final)`
- `createOrgParamUpdate(final)`
- `createPrintTicketMessage(final)`
- `createPrintTicketMessage(final, final)`

---

### WebSocketMessage

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.bean.ws`
- **文件**: WebSocketMessage.java
- **方法数**: 1

**方法列表**:
- `message2JSON()`

---

### CheckParamsService

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.common`
- **文件**: CheckParamsService.java
- **方法数**: 2

**方法列表**:
- `checkGoods(final)`
- `checkPromotion(final)`

---

### SaasIniProperties

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.config.saasini`
- **文件**: SaasIniProperties.java
- **方法数**: 7

**方法列表**:
- `isTestActive()`
- `putSaasProperty(final, final, final)`
- `writeShopInfo2SaasIni(final)`
- `isPrintDebug()`
- `enableFoodUnitSerialNo()`

---

### SaasIniPropertiesInitHelper

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.config.saasini`
- **文件**: SaasIniPropertiesInitHelper.java
- **方法数**: 1

**方法列表**:
- `refresh(final, final, final)`

---

### OrderPayConvertImpl

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.convert`
- **文件**: OrderPayConvertImpl.java
- **方法数**: 2

**方法列表**:
- `convertPayBakToPay(final)`
- `convertPayBakToPay(final)`

---

### CompanyEmployeeQueryDto

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.dto`
- **文件**: CompanyEmployeeQueryDto.java
- **方法数**: 1

**方法列表**:
- `isNeedCard()`

---

### ClientTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums`
- **文件**: ClientTypeEnum.java
- **方法数**: 8

**方法列表**:
- `isOpenTableAutoAddGoods(final)`
- `isApplet(final)`
- `isOnlineApp(final)`
- `isMobileApp(final)`
- `is3Em(final)`

---

### OrgParamEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums`
- **文件**: OrgParamEnum.java
- **方法数**: 2

**方法列表**:
- `isEnableExt()`
- `isEnableExt()`

---

### PaySubjectEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums`
- **文件**: PaySubjectEnum.java
- **方法数**: 4

**方法列表**:
- `isMemberBalance(final)`
- `isMemberCardPay(final)`
- `isJoinMutexShare(final)`
- `promotionPayTypeMap()`

---

### PledgeTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums`
- **文件**: PledgeTypeEnum.java
- **方法数**: 1

**方法列表**:
- `isBuffetDeposit(final)`

---

### SpecialGoodsCodeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums`
- **文件**: SpecialGoodsCodeEnum.java
- **方法数**: 2

**方法列表**:
- `allCode()`
- `allCodeExceptDelivery()`

---

### GoodsTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.goods`
- **文件**: GoodsTypeEnum.java
- **方法数**: 4

**方法列表**:
- `isCombine(final)`
- `isSpec(final)`
- `isSideDish(final)`
- `isHotPot(final)`

---

### GiftCardTransTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.member`
- **文件**: GiftCardTransTypeEnum.java
- **方法数**: 2

**方法列表**:
- `isConsume()`
- `isTransType(final, final)`

---

### BusinessTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.order`
- **文件**: BusinessTypeEnum.java
- **方法数**: 1

**方法列表**:
- `isPickup(final)`

---

### MakeStatusEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.order`
- **文件**: MakeStatusEnum.java
- **方法数**: 2

**方法列表**:
- `isNotCompleted(final)`
- `isCompleted(final)`

---

### PlatformTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.order`
- **文件**: PlatformTypeEnum.java
- **方法数**: 1

**方法列表**:
- `isTakeoutPlatformType(final)`

---

### PayStatus

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.pay`
- **文件**: PayStatus.java
- **方法数**: 5

**方法列表**:
- `isFinalStatus(final)`
- `isPaySuccess(final)`
- `isRefundSuccess(final)`
- `isCancelSuccess(final)`
- `isPayInProgress(final)`

---

### PayStatusEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.pay`
- **文件**: PayStatusEnum.java
- **方法数**: 1

**方法列表**:
- `paySuccess(final)`

---

### PaySubjectCategoryEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.pay`
- **文件**: PaySubjectCategoryEnum.java
- **方法数**: 1

**方法列表**:
- `ofCode(final)`

---

### PayWay

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.pay`
- **文件**: PayWay.java
- **方法数**: 1

**方法列表**:
- `toPaySubject(final)`

---

### SceneEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.pay`
- **文件**: SceneEnum.java
- **方法数**: 1

**方法列表**:
- `convertToMemberScene(final)`

---

### PromotionEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.promotion`
- **文件**: PromotionEnum.java
- **方法数**: 4

**方法列表**:
- `isDiscount(final)`
- `isItemDiscount(final)`
- `isOrderDiscount(final)`
- `isGift(final)`

---

### PromotionTypeEnum

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.enums.promotion`
- **文件**: PromotionTypeEnum.java
- **方法数**: 10

**方法列表**:
- `isGive(final)`
- `isExchange(final)`
- `isPromotion(final)`
- `isPosPromotion(final)`
- `isMemberPromotion(final)`

---

### ServiceRegistry

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.jmdns`
- **文件**: ServiceRegistry.java
- **方法数**: 2

**方法列表**:
- `register(final, final, final)`
- `unregister()`

---

### CategoryManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: CategoryManager.java
- **方法数**: 1

**方法列表**:
- `buildCategoryCache(final)`

---

### OrderDetailManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: OrderDetailManager.java
- **方法数**: 2

**方法列表**:
- `countExistNonServeGoodsByOrderNo(final)`
- `updateConditionByDetailId(final)`

---

### OrderMasterManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: OrderMasterManager.java
- **方法数**: 1

**方法列表**:
- `updatePrintCountByOrderNo(final)`

---

### OrderPayManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: OrderPayManager.java
- **方法数**: 1

**方法列表**:
- `mergeRefundPay(final)`

---

### OrderStatusManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: OrderStatusManager.java
- **方法数**: 2

**方法列表**:
- `updateAllDishesServedByOrderNo(final, final)`
- `updateByOrderNo(final)`

---

### PrintGroupManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: PrintGroupManager.java
- **方法数**: 1

**方法列表**:
- `queryKdsTemporaryGoodsConfigGroup()`

---

### PrintSetManager

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.manager`
- **文件**: PrintSetManager.java
- **方法数**: 1

**方法列表**:
- `updatePrintStatus(final)`

---

### OperateConvertImpl

- **领域**: biz
- **包路径**: `com.shouqianba.localserver.biz.common.operate`
- **文件**: OperateConvertImpl.java
- **方法数**: 2

**方法列表**:
- `OperateInfo2PO(final)`
- `toOperateRecordListResponse(final)`

---

