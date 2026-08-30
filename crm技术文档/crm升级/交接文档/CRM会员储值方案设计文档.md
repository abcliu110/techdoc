# CRM 会员储值方案设计实现文档

日期：2026-08-28
作者：guoyun_liu
状态：已实现

## 1. 背景与目标

老 POS 充值（`cardCharge`）只支持固定规则（`CrmSaveRule`），不支持新储值方案（`DepositPlan`）的多档位、赠券（一次性/周期性）、会员升级、积分等能力。

本设计目标：**在 POS 端新增 `depositPlanCharge` 接口，完整复用老充值的 DwdBill 管道（打印/短信/撤销/支付方式），同时触发新储值方案的全部后置逻辑（发券、升级、积分、销售统计）。不改动老的 `cardCharge` 方法。**

## 2. 核心架构

```
POS 结账
  → depositPlanCharge()
    → 创建 DwdBill（OrderOpTypeEnum.E）+ DwdFood（1行）
    → DwdBillOpsServiceImpl.checkOut()
      → OrderServiceUtil.dealDepositPlanCharge()
        → Nms4CloudCrmService.depositPlanCharge()
          → POST /deposit-plan/charge/commitByPos
            → DepositPlanChargeService.commitByPos()
              → Redis 幂等锁 + 三态检查
              → 校验储值方案/档位（以 tier 主数据为准）
              → 创建 CrmDealTask（USERPAYING）
              → 创建 CrmDepositChargeRecord（USERPAYING）
              → onPaymentSuccess()
                ├─ CardBalanceService.execute()  余额（含幂等）
                ├─ updateChargeRecordSuccess()   充值记录更新
                ├─ updatePlanSoldStats()         销售统计
                ├─ handleGiftIssuance()         发券（一次性/周期性）
                ├─ handleMemberUpgrade()        会员升级
                └─ handlePoints()              积分

撤销（入口复用 revokeCharge，仅回滚余额与赠券）：
  → revokeCharge(taskLid)
    → revokeInner() → CardBalanceService 余额反向扣减
    → couponOpRevoke() 作废未核销/已过期券
```

## 3. 功能对比：老充值 vs 新储值方案

| 功能 | 老充值（cardCharge） | 新储值方案（depositPlanCharge） |
|---|---|---|
| DwdBill 账单 | ✅ | ✅ 必须保留（打印/报表/撤销依赖） |
| 打印充值单 | ✅ `MemberSavingBill` | ✅ 同 |
| 短信通知 | ✅ `SMS_CRM_RECHARGE` | ✅ 同 |
| 撤销 | ✅ | ✅ 入口复用，余额和赠券回滚 |
| CRM 余额变更 | ✅ `CardBalanceService.execute()` | ✅ 同 |
| 赠券（一次性/周期性） | ❌ 仅单张 | ✅ CRM 新接口负责 |
| 会员升级/延期 | ❌ | ✅ CRM 新接口负责 |
| 积分发放 | 有限支持 | ✅ CRM 新接口负责 |
| 销售统计 | ❌ | ✅ `updatePlanSoldStats` |
| 购买记录 | ❌ | ✅ `CrmDepositChargeRecord` |

## 4. 后台管理页面

### 4.1 管理页面入口

| 功能 | 前端路径 | 前端组件 |
|------|---------|---------|
| 储值方案管理 | `CrmMarketingMrg` 下的 TopUpCampaignMrg 子路由 | `src/pages/CrmMarketingMrg/components/TopUpCampaignMrg/` |
| 储值方案充值（POS） | POS 端会员操作区 | `MemberForBizController.depositPlanCharge` |

### 4.2 后台管理接口

#### 储值方案 CRUD

入口 Controller：`CrmDepositPlanController`（路径 `/crm_deposit_plan`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/crm_deposit_plan/get` | POST | `crm:deposit:plan:list` | 获取储值方案详情 |
| `/crm_deposit_plan/list` | POST | `crm:deposit:plan:list` | 分页查询储值方案列表 |
| `/crm_deposit_plan/listAvailable` | POST | `@NeedVerifySignature` | 查询可用储值方案（POS/小程序调用） |
| `/crm_deposit_plan/listByWx` | POST | 登录后可见 | 查询可用储值方案（微信小程序） |
| `/crm_deposit_plan/add` | POST | `crm:deposit:plan:add` | 新增储值方案 |
| `/crm_deposit_plan/update` | POST | `crm:deposit:plan:update` | 修改储值方案 |
| `/crm_deposit_plan/state` | POST | `crm:deposit:plan:update` | 修改储值方案状态（启用/禁用） |
| `/crm_deposit_plan/del` | POST | `crm:deposit:plan:del` | 删除储值方案 |
| `/crm_deposit_plan/export` | POST | `crm:deposit:plan:export` | 导出储值方案 |
| `/crm_deposit_plan/getCardLevelsByTypes` | POST | `crm:deposit:plan:list` | 根据卡类型查询卡等级 |

#### 储值方案充值

入口 Controller：`DepositPlanChargeController`（路径 `/deposit-plan/charge`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/deposit-plan/charge/commit` | POST | `@SaCheckLogin` + `@ForbidRepeatSubmit` | 提交储值方案充值（小程序/H5） |
| `/deposit-plan/charge/query_charge_status` | POST | `@SaCheckLogin` | 查询充值状态（轮询） |
| `/deposit-plan/charge/commitByPos` | POST | `@NeedVerifySignature` | POS 端储值方案充值（同步接口） |

## 5. 表结构

### 5.1 `crm_deposit_category`（储值方案分类表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | 门店 ID |
| `lid` | BIGINT | 逻辑编号（雪花算法） |
| `name` | VARCHAR(100) | 分类名称 |
| `sort_order` | INT | 排序 |
| `brand_ids` | JSON | 关联品牌列表 |
| `remark` | VARCHAR(500) | 备注 |

### 5.2 `crm_deposit_agreement`（储值协议表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT | 物理主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `lid` | BIGINT | 逻辑编号 |
| `name` | VARCHAR(100) | 协议名称 |
| `agreement_type` | TINYINT | **协议类型**：1-用户注册，2-会员储值，3-隐私协议，4-点单协议，5-操作指引，6-付费权益卡协议，7-权益包售卖协议，8-存酒服务须知 |
| `content` | TEXT | 协议内容（富文本） |
| `guide_text` | VARCHAR(500) | 引导语 |
| `version` | VARCHAR(50) | 协议版本号 |
| `status` | TINYINT | 状态：0-禁用，1-启用 |
| `is_default` | TINYINT | 是否默认：0-否，1-是 |

### 5.3 `crm_deposit_plan`（储值方案主表）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT | 物理主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `lid` | BIGINT | 逻辑编号 |
| `plan_type` | TINYINT | **方案类型**：1-储值分期送礼，2-智能储值，3-储值套餐 |
| `brand_rule` | JSON | 品牌规则：`{"type":"ALL\|SPECIFIED","brandIds":[...]}` |
| `category_id` | BIGINT | 活动分类 |
| `name` | VARCHAR(100) | 活动名称 |
| `date_type` | TINYINT | **活动日期类型**：1-指定日期，2-永久有效 |
| `begin_time/end_time` | DATETIME | 活动起止日期 |
| `cycle_rule` | JSON | 可用周期：`{"type":"DAILY\|WEEKLY\|MONTHLY","values":[...]}` |
| `time_periods` | JSON | 可用时段：`{"type":"ALL_DAY\|SPECIFIED","periods":[{"startMin":0,"endMin":1440}]}` |
| `exclude_dates` | JSON | 排除日期：`["2026-01-01",...]` |
| `agreement_enabled` | TINYINT | 开启储值协议：0-关闭，1-开启 |
| `agreement_lids` | JSON | 储值协议 ID 列表 |
| `description` | TEXT | 活动说明 |
| `image_url` | VARCHAR(255) | 图片地址 |
| `status` | TINYINT | 状态：0-禁用，1-启用 |
| `save_type` | TINYINT | **储值规则类型**：1-固定金额档位，2-区间金额档位 |
| `sort_no` | INT | 排序 |
| `channels` | JSON | 渠道规则：`{"type":"ALL\|SPECIFIED","channels":[...]}` |
| `applicable_orgs` | JSON | 适用组织规则 |
| `member_level_rule` | JSON | 适用用户规则 |
| `purchase_limit_rule` | JSON | **购买限制规则**：单人总限、单人周期限、总量限、周期总量限 |
| `tier_rule` | JSON | **梯度规则**：含档位、赠送金额、会员升级、优惠券发放配置 |
| `total_sold_count` | INT | 已售总数量 |
| `total_sold_amount` | DECIMAL(18,2) | 已售总金额 |
| `is_mini_program_recommend` | TINYINT | 小程序下单页推荐：0-否，1-是 |
| `amount_limit_type` | TINYINT | **可用金额限制类型**：0-不限制，1-储值当日限制，2-储值当餐限制 |
| `max_amount_value` | DECIMAL(18,2) | 可用储值金额上限 |

索引：
```sql
INDEX idx_mid (mid)
INDEX idx_sid (sid)
UNIQUE INDEX uk_lid (lid)
INDEX idx_status (status)
INDEX idx_category_lid (category_lid)
INDEX idx_total_sold_count (total_sold_count)
```

### 5.4 `crm_deposit_charge_record`（储值方案购买记录）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT | 物理主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `lid` | BIGINT | 逻辑编号 |
| `name` | VARCHAR(100) | 记录名称 |
| `plan_lid` | BIGINT | 储值方案 LID（FK） |
| `tier_index` | INT | 档位索引（从 0 开始） |
| `card_lid` | BIGINT | 会员卡 LID（FK） |
| `task_lid` | BIGINT | 交易任务 LID（FK） |
| `save_amount` | DECIMAL(18,2) | 储值本金 |
| `gift_amount` | DECIMAL(18,2) | 赠送金额 |
| `gift_points` | DECIMAL(18,2) | 赠送积分 |
| `tier_snapshot` | JSON | **档位快照**（TierConfig 完整 JSON，防止方案修改后影响已购买权益） |
| `channel_code` | VARCHAR(50) | 渠道编码（POS/MINI_PROGRAM/H5 等） |
| `trade_state` | TINYINT | 状态：2-成功，4-已关闭，6-支付中 |

索引：
```sql
UNIQUE INDEX uk_lid (lid)
INDEX idx_plan_lid (plan_lid)
INDEX idx_card_lid (card_lid)
INDEX idx_task_lid (task_lid)
```

### 5.5 `crm_deposit_coupon_schedule`（储值方案周期发券计划）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT | 物理主键 |
| `mid/sid` | BIGINT | 商户/门店 |
| `lid` | BIGINT | 逻辑编号 |
| `name` | VARCHAR(100) | 计划名称 |
| `plan_lid` | BIGINT | 储值方案 LID |
| `tier_index` | INT | 档位索引 |
| `card_lid` | BIGINT | 会员卡 LID |
| `charge_record_lid` | BIGINT | 购买记录 LID（FK） |
| `tier_snapshot` | JSON | 档位快照（TierConfig 完整 JSON） |
| `issue_cycle_type` | VARCHAR(20) | **周期类型**：DAILY/WEEKLY/MONTHLY |
| `issue_cycle_values` | JSON | 周期值：`[1,3,5]` 等 |
| `issue_time` | TIME | 发放时间（HH:mm:ss） |
| `total_issue_times` | INT | 总发放次数 |
| `issued_times` | INT | 已发放次数 |
| `first_issue_immediate` | TINYINT | 首次是否立即发放：0-否，1-是 |
| `next_issue_date` | DATE | 下次发放日期 |
| `status` | TINYINT | 状态：0-已完成，1-进行中，2-已暂停 |

索引：
```sql
UNIQUE INDEX uk_lid (lid)
INDEX idx_card_lid (card_lid)
INDEX idx_status_next_date (status, next_issue_date)
```

### 5.6 关联核心表

| 表 | 作用 |
|---|---|
| `crm_deal_task` | 储值交易任务（trade_state 记录支付状态） |
| `crm_card` | 会员卡余额（balance/principal_balance/give_balance/points） |
| `crm_coupon_order` | 赠送优惠券的券订单（由 handleGiftIssuance 创建） |

## 6. 储值方案配置维度详解

### 6.1 基本信息

- **方案类型**（`plan_type`）：储值分期送礼 / 智能储值 / 储值套餐
- **品牌规则**（`brand_rule`）：ALL 或 SPECIFIED（指定品牌列表）
- **活动日期**（`date_type`）：指定日期范围 或 永久有效
- **可用周期**（`cycle_rule`）：每日 / 每周几 / 每月几号
- **可用时段**（`time_periods`）：全日 或 指定时段段（startMin-endMin）
- **排除日期**（`exclude_dates`）：节假日等不适用日期

### 6.2 购买限制（`purchase_limit_rule`）

| 限制维度 | JSON 字段 | 说明 |
|---|---|---|
| 单人总限 | `perUserTotalLimit` | 每人最多购买 N 次 |
| 单人周期限 | `perUserPeriodLimit` | 每人每周期最多购买 M 次 |
| 总量限 | `totalSaleLimit` | 方案总限量 N 份 |
| 周期总量限 | `totalSalePeriodLimit` | 每日/每周/每月最多销售 M 份 |

### 6.3 梯度规则（`tier_rule`）

每个档位（Tier）包含：
- **储值本金**：`saveAmount`
- **赠送金额**：`giftAmount`
- **赠送积分**：`giftPoints`
- **会员升级**：升级到的卡等级和有效期
- **优惠券发放**：券模板、数量、有效期

### 6.4 渠道与组织

- **渠道规则**（`channels`）：控制哪些渠道（POS/小程序/H5）可展示和购买
- **适用组织**（`applicable_orgs`）：ALL_STORES / SPECIFIED_STORES / SPECIFIED_REGIONS
- **适用用户**（`member_level_rule`）：不限 / 指定会员方案 / 指定会员等级

### 6.5 储值协议

- **开启协议**（`agreement_enabled`）：充值前是否必须阅读并同意储值协议
- **协议内容**（`agreement_lids`）：关联 `crm_deposit_agreement` 表中 `agreement_type=2` 的记录

## 7. 充值接口详解

### 7.1 POS 端充值 `commitByPos`

POS 调用路径：`POST /deposit-plan/charge/commitByPos`（`@NeedVerifySignature`）

请求 DTO：`DepositPlanPosChargeDTO`

| 字段 | 来源 | 必填 | 含义 |
|------|------|------|------|
| `mid` | 签名解析 | — | 商户 ID（自动落入） |
| `sid` | 签名解析 | — | 门店 ID（自动落入） |
| `planLid` | POS 传入 | ✅ | 储值方案 LID |
| `tierIndex` | POS 传入 | ✅ | 档位索引（从 0 开始） |
| `cardNo` | POS 传入 | ✅ | 会员卡号 |
| `orderId` | POS 传入 | ✅ | POS 订单号（= DwdBill.saasOrderKey） |
| `saveAmount` | POS 传入 | ✅ | 本金（仅用于 CRM 防篡改校验，最终以 tier 为准） |
| `giftAmount` | POS 传入 | — | 赠送金额（POS 展示用，CRM 不信任） |
| `giftPoints` | POS 传入 | — | 赠送积分（POS 展示用，CRM 不信任） |
| `payWay` | POS 传入 | — | 支付方式描述 |
| `payWayCode` | POS 传入 | — | 支付方式编码 |
| `operator` | POS 传入 | — | 操作人 |
| `comment` | POS 传入 | — | 备注 |

### 7.2 幂等三态

| 状态 | 判断条件 | 处理 |
|------|----------|------|
| 未处理 | `CrmDealTask` 不存在 | 正常执行完整流程 |
| 处理中 | `CrmDealTask` 存在且 `tradeState=USERPAYING` | 返回错误"订单处理中，请稍后查询结果" |
| 已成功 | `CrmDealTask` 存在且 `tradeState=SUCCESS` | 幂等返回已有 `CardBalanceVo` |

### 7.3 防篡改设计

CRM **不信任**前端传入的 `giftAmount` 和 `giftPoints`，一律以档位配置（`tier.giftAmount` / `tier.giftPoints`）为准：

```java
BigDecimal saveAmount = tier.getSaveAmount();       // 校验：request.saveAmount == tier.saveAmount
BigDecimal giftAmount = NullSafeUtils.nullSafe(tier.getGiftAmount());   // 以档位为准
BigDecimal giftPoints = NullSafeUtils.nullSafe(tier.getGiftPoints());    // 以档位为准
```

### 7.4 事务边界

```
阶段1（强一致，@Transactional）：
  ①~③ 校验
  ④ 创建 CrmDealTask（USERPAYING）
  ⑤ 创建 CrmDepositChargeRecord（USERPAYING）

阶段2（CardBalanceService 有独立 Redis 锁 + 子事务）：
  CardBalanceService.execute() → 余额变更（含幂等）
  updateChargeRecordSuccess() + updatePlanSoldStats()

阶段3（try-catch 隔离，失败只记日志）：
  handleGiftIssuance()     → 发券（一次性/周期性）
  handleMemberUpgrade()    → 会员升级
  handlePoints()           → 积分
```

## 8. 撤销流程

**撤销入口**：复用老 `revokeCharge`，入参、权限、POS 侧账单处理完全不变。

```
revokeCharge(taskLid)
  → CardBalanceService.execute(..., revoke=true)  余额反向扣减
  → couponOpRevoke()  作废未核销/已过期券（按 orderBillId=task.lid 查找）
```

**回滚范围**：

| 项目 | 是否回滚 | 说明 |
|---|---|---|
| 会员卡余额 | ✅ | CardBalanceService 反向操作 |
| 赠券（未核销/已过期） | ✅ | couponOpRevoke 按 orderBillId 作废 |
| 已核销的券 | ❌ | 已使用不回收 |
| CrmDepositChargeRecord 状态 | ❌ | 仍为 SUCCESS |
| 销售统计 | ❌ | 不回减 |
| 会员等级升级 | ❌ | 不降级 |
| 积分 | ❌ | 不扣回 |

## 9. 代码文件清单

| 文件 | 职责 |
|------|------|
| `CrmDepositPlanController.java` | 储值方案 CRUD 管理接口 |
| `CrmDepositPlanServicePlus.java` | 储值方案管理业务逻辑 |
| `DepositPlanChargeController.java` | 储值方案充值接口（含 POS 同步接口） |
| `DepositPlanChargeService.java` | 充值核心业务逻辑（幂等/校验/onPaymentSuccess） |
| `DepositPlanCouponService.java` | 一次性/周期性发券逻辑 |
| `DepositPlanChargeMockSuccessDTO.java` | Mock 充值成功（测试用） |
| `CrmDepositPlanConstant.java` | 储值方案常量定义 |
| `DepositPlanTypeEnum.java` | 方案类型枚举 |
| `CrmDepositPlanAddDTO.java` | 新增请求 DTO |
| `CrmDepositPlanUpdateDTO.java` | 修改请求 DTO |
| `CrmDepositPlanGetDTO.java` | 查询请求 DTO |
| `CrmDepositPlanQueryDTO.java` | 分页查询请求 DTO |
| `CrmDepositPlanVO.java` | 详情返回 VO |
| `CrmDepositPlanListVO.java` | 列表返回 VO |
| `DepositPlanChargeCommitDTO.java` | 充值提交请求 DTO（小程序/H5） |
| `DepositPlanPosChargeDTO.java` | POS 充值请求 DTO |
| `DepositPlanChargeCommitVO.java` | 充值提交返回 VO |
| `CrmDepositPlanAvailableVO.java` | 可用方案返回 VO |
| `DepositPlanChargeRecord.java` | 充值记录实体 |
| `CrmDepositPlan.java` | 储值方案实体 |
| `CrmDepositCategory.java` | 储值分类实体 |
| `CrmDepositAgreement.java` | 储值协议实体 |
| `CrmDepositCouponSchedule.java` | 周期发券计划实体 |
| `V20260417_储值方案.sql` | 建表 SQL |

## 10. 异常监控

### 10.1 异常单识别

充值成功但 `card_task_lid` 为空的账单需要人工处理：

```sql
SELECT lid, mid, sid, saas_order_key, deposit_plan_lid, order_status, create_time
FROM dwd_bill
WHERE deposit_plan_lid IS NOT NULL
  AND card_task_lid IS NULL
  AND order_status NOT IN ('CANCEL')
ORDER BY create_time DESC;
```

### 10.2 日志关键字

| 场景 | 日志关键字 |
|------|----------|
| 幂等命中（已成功） | `[depositPlan][commitByPos] idempotent-hit SUCCESS` |
| 幂等命中（处理中） | `[depositPlan][commitByPos] idempotent-hit USERPAYING` |
| 幂等未命中（新请求） | `[depositPlan][commitByPos] idempotent-miss` |
| 充值成功 | `[depositPlan][commitByPos] success` |
| 充值失败 | `[depositPlan][commitByPos] failed` |

## 11. 与老充值的关系

| 维度 | 老充值 | 新储值方案 |
|------|-------|-----------|
| 接口 | `/crm_card_op/chargeSign` | `/deposit-plan/charge/commitByPos` |
| POS 端方法 | `MemberForBizController.cardCharge` | `MemberForBizController.depositPlanCharge` |
| 规则数据 | `crm_save_rule` | `crm_deposit_plan.tier_rule` |
| DwdFood.foodNo | 规则 LID | `-1`（非标准规则，planLid 存于 DwdBill.depositPlanLid） |
| 撤销接口 | `/crm_card_op/revokeChargeSign` | 同（复用老接口） |

老充值接口保持完全不变，新储值方案独立演进。
