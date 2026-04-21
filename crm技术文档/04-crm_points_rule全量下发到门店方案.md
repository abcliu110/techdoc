# crm_points_rule 全量下发到门店方案

> 适用范围：CRM 积分权益主表 `crm_points_rule` 全量下发到门店 POS 本地库
>
> 依据：当前 `nms4cloud-crm`、`nms4cloud-pos2plugin`、`nms4cloud-pos3boot` 代码现状

## 1. 背景与目标

当前门店 POS 已经具备部分“会员相关配置”的本地下发能力，例如会员价、折扣规则、积分支付规则、菜品积分参与规则等，但仍然缺少 CRM 积分权益主表的本地落地能力。

这会带来两个直接问题：

1. 门店本地虽然能根据已有配置做一部分价格和折扣计算，但无法获取完整的积分权益规则。
2. 当网络异常或 CRM 服务不可用时，门店无法基于本地数据独立判断完整的积分抵现规则和积分权益边界。

本期目标是：

1. 以 `crm_points_rule` 作为唯一源表。
2. 将 `crm_points_rule` 通过现有 POS 全量同步机制下载到门店本地。
3. 在门店本地创建对应表结构并落库成功。
4. 本期不修改现有结算逻辑，不切换业务读取路径，不接入增量同步。

本期明确不做：

1. 不接入 `crm_points_rule` 增量同步。
2. 不切换积分抵现、会员结算、赠分逻辑到本地表。
3. 不同时兼容旧模型 `crm_card_type / crm_card_type_free_rule / crm_point_exchange` 的门店下发。

## 2. 现状分析

### 2.1 当前已经下发到门店的会员相关表

从 POS 同步清单看，当前已经进入门店全量/增量同步体系的会员相关配置主要包括：

1. `pt_member_price`
   会员价明细表，用于菜品会员价格计算。
2. `biz_discount`
   折扣规则主表。
3. `biz_discount_dish`
   折扣规则适用菜品。
4. `biz_discount_tbl_type`
   折扣规则适用台类。
5. `biz_pay_way`
   支付方式配置，包含积分支付相关规则字段，例如是否支持积分、积分抵现率、积分抵现上限比例。
6. `pt_dish`
   菜品基础信息，包含积分值等字段。
7. `pt_dish_unit`
   菜品单位信息，包含会员价、积分参与等配置。

这些表已经覆盖了：

1. 会员价
2. 会员折扣规则
3. 积分支付方式规则
4. 哪些菜参与积分/会员价

但这些表并不能完整表达 CRM 当前的积分权益主配置。

### 2.2 当前没有下发到门店的 CRM 会员权益表

当前未进入门店同步体系的 CRM 相关权益表包括：

1. `crm_card_type`
2. `crm_card_type_free_rule`
3. `crm_point_exchange`
4. `crm_points_rule`

其中最关键的是 `crm_points_rule`，因为它已经把积分获取、积分抵现、积分清零、规则说明等能力收敛到一张标准主表中。

### 2.3 为什么 `CrmCardTypeVO` 不是本地下发模型

`CrmCardTypeVO` 虽然包含很多和会员权益相关的字段，例如：

1. `pointsToCashPoint`
2. `pointsToCashMoney`
3. `pointsToCashMaxRule`
4. `pointsToCashMin`
5. `discountCode`
6. `integralPlanCode`
7. `integralPlanName`

但它本质上是 CRM 运行时接口返回的 VO，不是 POS 本地同步实体，原因如下：

1. 它定义在 API VO 层，不在本地 DAL 实体层。
2. 它没有 `@Table`，没有本地 `Mapper`。
3. 它没有进入 `SyncBaseDataService.classMapper`。
4. 它没有进入 `IncrementalSyncDataService.CLASS_MAP`。
5. 当前实际用法是门店运行时通过 `Nms4CloudCrmService.listCardType(...)` 远程调用 CRM 查询，而不是本地落库。

因此，`CrmCardTypeVO` 只能作为历史字段来源参考，不能作为本期门店本地下发表模型。

## 3. 源模型选择

### 3.1 旧模型

旧的积分权益数据散落在：

1. `crm_card_type`
2. `crm_card_type_free_rule`
3. `crm_point_exchange`

这种模型的问题是：

1. 规则分散，字段职责不统一。
2. 门店若按旧模型下发，后续仍需要在 POS 侧做较多组装。
3. 与 CRM 新标准积分权益模型不一致，后续维护成本高。

### 3.2 新模型

CRM 已经新增标准积分权益主表：

1. 表：`crm_points_rule`
2. 实体：`CrmPointsRule`
3. 对外 VO：`CrmPointsRuleVO`

该模型已经统一覆盖：

1. 积分获取规则
2. 积分抵现规则
3. 积分清零规则
4. 规则说明

并通过 JSON 字段承载复杂结构，例如：

1. 商品范围
2. 会员等级比率
3. 时段限制
4. 场景限制
5. 渠道限制

### 3.3 本期结论

本期门店全量下发方案，以 `crm_points_rule` 为唯一源表，不再围绕 `CrmCardTypeVO` 或旧表拼装门店本地权益模型。

## 4. 总体实现方案

### 4.1 CRM 侧新增 POS 集成接口

本期不直接复用后台管理控制器 `/crm_points_rule/list`，原因是：

1. 当前后台接口依赖登录态。
2. 控制器会用当前管理员的 `mid/sid` 覆盖请求体。
3. 不适合作为 POS 云端同步时的跨服务内部接口。

参考现有 POS 集成接口模式，应在 `CrmCardOpController` 下新增一个同步专用接口，例如：

`POST /crm_card_op/listPointsRule`

设计要求：

1. 使用 `@NeedVerifySignature`。
2. 请求 DTO 明确包含：
   - `mid`
   - `sid`
   - `current`
   - `pageSize`
   - `planLid`
3. 不依赖后台登录态。
4. 不覆盖请求中的 `mid/sid`。
5. 服务层直接调用 `CrmPointsRuleServicePlus` 的查询能力。

返回值建议：

`NmsResult<List<CrmPointsRuleVO>>`

这样可以保持与现有 `Nms4CloudCrmService` 调用风格一致。

### 4.2 POS 云端侧扩展 CRM Forest 客户端

POS 云端侧不新增 Feign 客户端，直接参考现有：

`com.nms4cloud.pos2plugin.service.member.cloud.Nms4CloudCrmService`

做法：

1. 在 `pos2plugin-api` 新增请求 DTO，例如 `CrmPointsRuleListDTO`。
2. 在 `Nms4CloudCrmService` 增加一个方法，例如：

`@Post("/crm_card_op/listPointsRule")`

3. 返回值使用 POS 侧可识别的模型，建议新增一个对齐 VO，例如：
   - `CrmPointsRuleVOForPos`
   或直接使用 `JSONObject` 过渡。

本期建议优先新增 POS 侧 VO，而不是直接依赖 CRM 模块 VO，避免直接引入 CRM API 依赖。

### 4.3 POS 云端同步服务扩展

在 `SyncBaseDataService` 中新增对 `CrmPointsRule` 的处理。

#### 4.3.1 注册本地实体映射

在 `classMapper` 中注册：

1. `CrmPointsRule.class -> crmPointsRuleMapper`

并按门店数据处理，不加入总部数据和平台数据集合。

#### 4.3.2 扩展 `/sync/list` 取数逻辑

`SyncBaseDataService.list(...)` 对 `CrmPointsRule` 增加特例分支：

1. 不从 POS 自身数据库查。
2. 根据请求中的 `mid/sid/current/pageSize` 组装 `CrmPointsRuleListDTO`。
3. 调用 `Nms4CloudCrmService.listPointsRule(...)`。
4. 将返回的 VO 映射成 POS 本地 `CrmPointsRule` 实体。
5. 交给现有 `/sync/list` 返回逻辑。

这样可以不改 `FullSyncDataService` 协议层，直接复用现有全量同步机制。

### 4.4 门店本地全量同步

门店侧不需要新增全量同步协议，只需要：

1. POS 本地存在 `crm_points_rule` 表和实体映射。
2. 该实体已经进入 `classMapper`。

则：

1. `/sync/all` 会自动把它纳入同步。
2. `FullSyncDataService` 会分页下载数据。
3. 落临时文件后再提交到门店本地数据库。

### 4.5 补充说明：Redis + Mono 是什么

在当前整套系统里，`Redis` 和 `Mono` 都是常见基础能力，但它们的职责不同：

#### 4.5.1 Redis 是什么

这里的 `Redis` 主要承担的是：

1. 缓存
2. 分布式锁
3. 进度状态保存
4. 临时幂等状态保存

在当前 POS 相关工程中，典型用法包括：

1. 保存全量同步进度
   - 例如 `SyncDataController.KEY_IN_REDIS`
2. 保存升级包下载状态
   - 例如 `UpgService` 中的升级包缓存 key
3. 控制重复操作
   - 例如某些下载、同步、支付流程中的加锁和幂等

所以，`Redis` 在这套系统里更偏向“状态存储层”和“运行时控制层”，而不是业务主数据的最终存储。

对于本次 `crm_points_rule` 全量下发来说：

1. `crm_points_rule` 的最终落地位置是门店本地 MySQL 表
2. 不是 Redis
3. Redis 最多只会参与“同步进度”“任务状态”“锁控制”等外围能力

#### 4.5.2 Mono 是什么

`Mono` 是 Project Reactor 提供的响应式类型，表示：

1. 一个异步结果
2. 结果数量为 0 或 1 个

它通常用于：

1. WebClient 异步调用
2. 非阻塞接口返回
3. 异步链式处理

常见形式例如：

```java
Mono<NmsResult<PosAppVerVO>>
```

表示“异步返回一个 `NmsResult<PosAppVerVO>`”。

在当前项目里，`Mono` 常见于：

1. 升级检查接口
2. 某些 WebClient 调用结果
3. 非阻塞控制器返回

#### 4.5.3 Redis + Mono 一起出现时通常表示什么

如果在同一条链路里同时出现 `Redis` 和 `Mono`，通常表示：

1. 用 `Mono` 处理异步调用
2. 用 `Redis` 保存异步流程中的状态、锁或中间结果

例如：

1. 异步下载升级包，Redis 记录当前是否正在下载
2. 异步全量同步任务，Redis 记录同步进度

#### 4.5.4 它和本次积分权益全量下发的关系

本次 `crm_points_rule` 全量下发的主链路，不以 `Redis + Mono` 为核心：

1. CRM 侧提供内部同步接口
2. POS 云端侧通过 `Nms4CloudCrmService` 拉取分页数据
3. 门店侧通过 `/sync/all` 下载并写入本地 MySQL

也就是说，本次主链路的核心是：

1. Forest 客户端调用
2. 全量同步分页下载
3. 本地数据库落表

而不是：

1. Redis 缓存主数据
2. Mono 响应式主流程

如果后续要扩展“异步触发全量下发任务”“后台轮询进度”之类能力，那么 Redis 可以继续承担任务进度缓存，Mono 可以承担异步接口返回，但这不是本期主实现方案。

## 5. 本地表设计

### 5.1 表名与维度

本地表名直接使用：

`crm_points_rule`

数据维度沿用源表：

1. `mid`
2. `sid`
3. `plan_lid`

原因：

1. 与源表一致，最容易追溯。
2. 避免在 POS 侧引入额外归并逻辑。
3. 便于后续增量同步直接对接。

### 5.2 实体放置位置

实体放置在：

`com.nms4cloud.pos2plugin.dal.entity`

原因：

1. `VerMgrServer` 只扫描该包下继承 `BaseEntity` 的实体。
2. 启动自动升级和 `/systemSetting/upgrade` 依赖这一扫描路径。

### 5.3 字段落地规则

#### 5.3.1 基础字段

以下字段保持常规强类型：

1. `mid`、`sid`、`lid`、`plan_lid`：`Long`
2. 金额/比例类：`BigDecimal`
3. 时间类：`LocalDateTime`
4. 普通文本：`String`
5. 版本号：`Integer`

#### 5.3.2 枚举字段

CRM 侧的枚举字段，在 POS 本地统一落为 `Integer` code 字段，不直接引入 CRM 枚举类。

例如：

1. `points_rule_enabled`
2. `earning_enabled`
3. `earning_mode`
4. `deduction_enabled`
5. `deduction_ceiling_type`
6. `expiry_enabled`
7. `expiry_mode`

原因：

1. 避免 POS 模块强耦合 CRM 枚举定义。
2. 与现有 POS 本地 DAL 枚举化程度保持一致。
3. 后续切读时再在 service 层做 code 到枚举语义映射。

#### 5.3.3 JSON/复杂字段

以下复杂结构统一按原始 JSON 文本保存为 `String`，并映射为 `longtext`：

1. `earning_specified_product_lids`
2. `level_rates`
3. `available_days_of_week`
4. `available_days_of_month`
5. `available_time_slots`
6. `order_scene_limit`
7. `order_channel_limit`
8. `deduct_days_of_week`
9. `deduct_days_of_month`
10. `deduct_time_slots`
11. `deduct_specified_product_lids`
12. `deduct_pos_category_lids`
13. `deduct_miniapp_category_lids`
14. `deduct_exclude_product_lids`
15. `deduct_scene_limit`
16. `deduct_channel_limit`

实现建议：

1. Java 字段使用 `String`
2. 字段注解使用 `@ColumnPlus(jdbcType = JdbcType.CLOB)`

这样可以保证：

1. 不需要在 POS 本地引入 CRM JSON 模型类。
2. 全量同步先保证“信息完整保真”。
3. 后续如果业务切读，再逐步解析这些 JSON 字段。

### 5.4 索引建议

建议补充至少这些索引：

1. `lid`
2. `plan_lid`

其中：

1. `lid` 可沿用现有自动建索引策略。
2. `plan_lid` 建议显式声明需要索引，便于后续按方案读取。

## 6. 全量同步时序

### 6.1 时序描述

1. 门店调用 `/sync/all`
2. `FullSyncDataService` 遍历 `classMapper`
3. 命中 `CrmPointsRule`
4. `SyncBaseDataService.list(...)` 识别该类为特例，不查本地 POS 库
5. `SyncBaseDataService` 调用 `Nms4CloudCrmService.listPointsRule(...)`
6. CRM 返回 `NmsResult<List<CrmPointsRuleVO>>`
7. POS 云端把 VO 映射成本地 `CrmPointsRule` 实体列表
8. `/sync/list` 返回分页结果给门店
9. 门店 `FullSyncDataService` 下载分页数据并写本地临时文件
10. 所有分页下载完成后，统一提交到门店本地 `crm_points_rule`

### 6.2 本期边界

本期完成后，门店本地只具备：

1. 有表
2. 有数据
3. 可查询

但不自动用于：

1. 积分抵现判断
2. 会员权益计算
3. 赠分规则执行

这些切读动作放到下一期。

## 7. 为什么本期不做增量同步

本期不接入增量同步，原因如下：

1. 首期目标是验证门店本地结构和全量数据闭环。
2. `crm_points_rule` 是新接入源表，先跑通全量链路更稳妥。
3. 增量同步需要同时补：
   - POS 门店端 `IncrementalSyncDataService.CLASS_MAP`
   - CRM 变更事件推送链路
   - 本地缓存清理
   - 事件语义对齐
4. 当前现有结算逻辑本期不切读，本地即使只有全量数据也足够支撑后续调试与验收。

## 8. 需要改动的模块

### 8.1 CRM 模块

需要改动：

1. `CrmCardOpController`
2. `CrmPointsRuleServicePlus`
3. 新增 `CrmPointsRuleListDTO`

### 8.2 POS 云端模块

需要改动：

1. `Nms4CloudCrmService`
2. 新增 POS 侧 `CrmPointsRuleListDTO`
3. 新增 POS 侧 `CrmPointsRuleVOForPos` 或等价 VO
4. `SyncBaseDataService`

### 8.3 POS 本地 DAL

需要改动：

1. 新增 `CrmPointsRule` 实体
2. 新增 `CrmPointsRuleMapper`

### 8.4 本地表结构升级

依赖现有：

1. 启动自动升级
2. `/systemSetting/upgrade`

不新增单独建表脚本作为唯一依赖。

## 9. 测试与验收

### 9.1 CRM 接口测试

验证项：

1. `POST /crm_card_op/listPointsRule` 能按 `mid/sid/current/pageSize` 正确分页返回。
2. `planLid` 过滤生效。
3. 无登录态情况下，签名校验通过即可调用。

### 9.2 POS 云端测试

验证项：

1. `Nms4CloudCrmService` 新方法可以成功调用 CRM。
2. `SyncBaseDataService.list()` 请求 `CrmPointsRule` 时能成功转调 CRM。
3. CRM 返回的 JSON/枚举/数值字段都能正确映射成本地实体。

### 9.3 门店侧测试

验证项：

1. 发布新版本后启动门店 POS，本地 `crm_points_rule` 表可以自动创建。
2. 手工调用 `/systemSetting/upgrade` 时也能创建该表。
3. 执行 `/sync/all` 后，本地 `crm_points_rule` 行数与 CRM 对应门店结果一致。
4. 空数据门店同步不报错。

### 9.4 回归测试

验证项：

1. `pt_member_price`、`biz_discount`、`biz_pay_way`、`pt_dish` 等现有同步不受影响。
2. 现有积分抵现、会员结算、赠分逻辑行为不变化。

## 10. 后续演进建议

第二期再补以下内容：

1. `crm_points_rule` 增量同步
2. 本地缓存清理机制
3. 本地权益读取服务
4. 订单结算逻辑切读
5. 旧模型 `crm_card_type / crm_card_type_free_rule / crm_point_exchange` 与新模型的迁移收口

## 11. 参考代码位置

### POS 侧

1. `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\member\cloud\Nms4CloudCrmService.java`
2. `D:\mywork\nms4pos\nms4cloud-pos2plugin\nms4cloud-pos2plugin-biz\src\main\java\com\nms4cloud\pos2plugin\service\sync\SyncBaseDataService.java`
3. `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\service\sync\FullSyncDataService.java`
4. `D:\mywork\nms4pos\nms4cloud-pos3boot\nms4cloud-pos3boot-biz\src\main\java\com\nms4cloud\pos3boot\service\local\VerMgrServer.java`

### CRM 侧

1. `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\card\CrmCardOpController.java`
2. `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-app\src\main\java\com\nms4cloud\crm\app\controller\pointsrule\CrmPointsRuleController.java`
3. `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\pointsrule\CrmPointsRuleServicePlus.java`
4. `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-dao\src\main\java\com\nms4cloud\crm\dao\entity\pointsrule\CrmPointsRule.java`
5. `D:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-api\src\main\java\com\nms4cloud\crm\api\vo\pointsrule\CrmPointsRuleVO.java`

## 12. 结论

本期最合适的落地方案是：

1. 以 `crm_points_rule` 为唯一权威源表。
2. CRM 在 `CrmCardOpController` 下新增 POS 集成查询接口。
3. POS 侧参考 `Nms4CloudCrmService` 扩展 Forest 调用。
4. `SyncBaseDataService` 对 `CrmPointsRule` 做全量同步特例代理。
5. 门店本地新增 `crm_points_rule` 表并通过现有升级能力自动建表。
6. 首期只做全量下发，不做增量同步和业务切读。
