# nms4pos - guoyun_liu 文件清单

口径：只统计当前分支中 `guoyun_liu` 非 merge 提交触达且当前仍存在的文件。只要该作者曾以 `A` 状态新增该文件，即使后续提交又修改，仍归为新增；否则归为修改。

- 新增文件：33
- 修改文件：14

## 新增文件
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/CrmCardOpGrantConsumePointsDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/CrmCardOpRevokeConsumePointsDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/CrmDepositPlanAvailableQueryDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/CrmPointsRuleListDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/DepositPlanChargeExDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/dto/member/DepositPlanPosChargeDTO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/service/CrmPointsRuleSyncRemoteService.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/member/CrmDepositPlanAvailableVO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/member/CrmPointsRuleSyncVO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/receipts/CouponPlatformDetailInfo.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsEventStatusEnum.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsEventTypeEnum.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsRoundStatusEnum.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsSessionStatusEnum.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/enums/CrmConsumePointsSourceEnum.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/controller/biz/DwdBillDepositPlanOpsForBizController.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/controller/biz/MemberDepositPlanForBizController.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/cloud/CrmPointsRuleForestServiceImpl.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/points/CrmPointsEarnLocalService.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/util/DepositPlanChargeUtil.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/test/java/com/nms4cloud/pos2plugin/service/member/points/CrmPointsEarnLocalServiceTest.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmConsumePointsEvent.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmConsumePointsRound.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmConsumePointsSession.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/CrmPointsRule.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/mapper/CrmConsumePointsEventMapper.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/mapper/CrmConsumePointsRoundMapper.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/mapper/CrmConsumePointsSessionMapper.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/mapper/CrmPointsRuleMapper.java`
- `nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/resources/application-local.yml`
- `nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/resources/application-self.yml`
- `nms4cloud-pos4cloud/nms4cloud-pos4cloud-feign/src/main/java/com/nms4cloud/pos2plugin/api/sync/CrmPointsRuleSyncRemoteServiceImpl.java`
- `sql/update/2026-5-6.sql`

## 修改文件
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/member/CardBalanceVO.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-api/src/main/java/com/nms4cloud/pos2plugin/api/vo/receipts/BillInfo.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/controller/biz/MemberForBizController.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/app/PrnDataSourceServiceForDebug.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/member/cloud/Nms4CloudCrmService.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/order/DwdBillOpsServiceImpl.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/order/handler/CashPayHandler.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/print/provider/DaySaleProviderImpl.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/service/sync/SyncBaseDataService.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/src/main/java/com/nms4cloud/pos2plugin/util/OrderServiceUtil.java`
- `nms4cloud-pos2plugin/nms4cloud-pos2plugin-dal/src/main/java/com/nms4cloud/pos2plugin/dal/entity/DwdBill.java`
- `nms4cloud-pos3boot/nms4cloud-pos3boot-app/src/main/resources/application-gzjjtest.yml`
- `nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/local/CloseMpScHandler.java`
- `nms4cloud-pos4cloud/nms4cloud-pos4cloud-app/src/main/java/com/nms4cloud/pos4cloud/Pos4cloudApplication.java`
