# 会员消费积分重构最终代码评审请求

请作为 Claude Code 对本次代码修改做独立代码评审。只读代码和文档，不要修改文件。

评审前必须阅读并遵守：

```text
D:\mywork\techdoc\saas\既有系统安全修改代码AI执行规范.md
```

## 背景约束

```text
1. 本地开发未上线，不做迁移，不做兼容，不考虑老数据。
2. 旧表不用的可以直接删除。
3. 第 7 点旧储值积分链路先不动：
   - 不能重写 CardBalanceService。
   - 不能重写 CrmDealTask.givePoint 老链路。
   - 新 POS 消费积分链路不能主动写 CrmDealTask.givePoint。
4. 当前目标是让 POS 消费积分拥有独立生命周期，避免重复赠分、重复撤销、退款晚回包导致错账。
```

## 重点评审问题

```text
0. 最新补充的 Java 注释是否详细、准确，是否把 session/round/event、task/ledger、退款快照重放、唯一键冲突回读等核心不变量讲清楚；是否存在注释与代码行为不一致或误导维护者的问题？
1. CRM 新消费积分 grant/revoke 是否只在 taskLid == null 的新 POS 链路启用？
2. 旧储值 CardBalanceService / CrmDealTask.givePoint 链路是否被保留，没有误接到新服务？
3. CRM consume_points_task 唯一键是否覆盖 source + lifecycle_id + task_type + task_lid + card_lid + order_id + deleted？
4. Java 服务里 taskLid == null 归一为 0 的逻辑是否与 DDL 一致？
5. POS session/round/event 状态机是否存在重复赠分、重复撤销、退款晚回包的明显缺陷？
6. CRM 正向积分流水与撤销负向流水是否能通过 related/target/produced points record 关联？
7. 新增测试是否覆盖关键回归？如果不够，指出必须补的阻断测试。
8. 是否存在编译会失败、旧类残留引用、枚举/DTO/Entity/DDL 不一致的问题？
```

## 最新补充注释重点文件

```text
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\points\CrmPointsEarnLocalService.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\points\CrmConsumePointsServicePlus.java
```

## 关键代码文件

CRM：

```text
D:\mywork\nms4cloud\docs\sql\migration\V20260509_crm_consume_points_task.sql
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-api\src\main\java\com\nms4cloud\crm\api\dto\CrmCardOpGrantConsumePointsDTO.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-api\src\main\java\com\nms4cloud\crm\api\dto\CrmCardOpRevokeConsumePointsDTO.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-api\src\main\java\com\nms4cloud\crm\api\enums\CrmConsumePointsTaskStatusEnum.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-api\src\main\java\com\nms4cloud\crm\api\enums\CrmConsumePointsTaskTypeEnum.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmCardPointsRecord.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\CrmConsumePointsTask.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\card\CrmCardOpServicePlus.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\points\CrmConsumePointsServicePlus.java
D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\test\java\com\nms4cloud\crm\service\points\CrmConsumePointsServicePlusTest.java
```

POS：

```text
D:\mywork\nms4pos\sql\update\2026-5-6.sql
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\dto\member\CrmCardOpGrantConsumePointsDTO.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\api\dto\member\CrmCardOpRevokeConsumePointsDTO.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\CrmConsumePointsEventStatusEnum.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\CrmConsumePointsEventTypeEnum.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\CrmConsumePointsRoundStatusEnum.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-api\src\main\java\com\nms4cloud\pos2plugin\enums\CrmConsumePointsSessionStatusEnum.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsSession.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsRound.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\entity\CrmConsumePointsEvent.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\mapper\CrmConsumePointsSessionMapper.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\mapper\CrmConsumePointsRoundMapper.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-dal\src\main\java\com\nms4cloud\pos2plugin\dal\mapper\CrmConsumePointsEventMapper.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\points\CrmPointsEarnLocalService.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\order\DwdBillOpsServiceImpl.java
D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\test\java\com\nms4cloud\pos2plugin\service\member\points\CrmPointsEarnLocalServiceTest.java
```

文档：

```text
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\01-会员消费积分企业级重做方案.md
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\02-DDL与状态机契约.md
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\03-实现任务与测试清单.md
```

## 已执行验证

```text
1. D:\mywork\nms4cloud> .\mvnw.cmd test
   结果：BUILD SUCCESS，83 个 Maven reactor 模块成功。

2. D:\mywork\nms4pos> mvn test
   结果：BUILD SUCCESS，34 个 Maven reactor 模块成功。

3. 残留扫描：
   - CRM 范围未命中 CrmConsumePointsGrant / CrmConsumePointsGrantStatusEnum / idempotencyKey / GRANTED / REVOKED 旧 task 状态引用。
   - POS 范围未命中 CrmConsumePointsGrant / CrmConsumePointsGrantStatusEnum / idempotencyKey 旧引用。

4. Java 文件 BOM 检查：
   结果：NO_BOM_DETECTED。
```

## 输出要求

请把评审结论写入：

```text
D:\mywork\techdoc\crm技术文档\积分权益技术实现\最新实现\claude-review\code-review-result.md
```

输出格式：

```text
# Claude Code Review Result

## 阻断问题
- 如无，写“无”。

## 高风险问题
- 如无，写“无”。

## 建议优化
- 只写与本次重构直接相关的问题。

## 测试缺口
- 区分“必须补”和“后续建议”。

## 结论
- CLEAR / WATCH / BLOCKED 三选一，并说明理由。
```
