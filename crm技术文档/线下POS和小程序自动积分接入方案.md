# 线下 POS 和小程序自动积分接入方案

> 文档位置：`D:\mywork\techdoc\crm技术文档\线下POS和小程序自动积分接入方案.md`
> 依据源码：`D:\mywork\techdoc\crm技术文档\会员消费扣款与自动积分全链路分析.md`

---

## 一、现状与缺口

### 核心结论

当前系统具备完整的积分账务落账能力（`CardBalanceService` 已可处理 `givePoint`），CRM 已配置 `crm_points_rule` 规则并下发至 POS 本地，但消费结账主链路中**从未读取规则、从未计算积分、从未透传 givePoint**。

### 两端缺口一致

| 缺口项 | 小程序线上（PayOrderServiceImpl） | 线下 POS（DwdBillOpsServiceImpl） |
|---|---|---|
| 调用 `cardConsumeInner` 前 set givePoint | ❌ 没有 | ❌ 没有 |
| 账单实体有 earnedPoints 追踪字段 | ❌ 没有（order_bill） | ❌ 没有（dwd_bill） |
| 前端展示本单赠送积分 | ❌ 没有 | ❌ 没有 |

### 已有基础设施（可直接复用）

| 能力 | 位置 | 说明 |
|---|---|---|
| `CrmCardOpConsumeDTO.givePoint` 字段 | `CrmCardOpConsumeDTO.java:31` | 已定义，下游已接上 |
| `CardBalanceService.executeInner()` 处理 givePoint | `CardBalanceService.java:606` | 已完整，会写余额和流水 |
| `CrmPointsRule` 本地镜像表 | POS `CrmPointsRule.java` | 已同步 60+ 字段 |
| `CrmPointsRuleServicePlus.findUniqueRuleByPlan()` | 云端 `CrmPointsRuleServicePlus.java:338` | 已存在 |
| `CrmMemberServicePlus.getMemberInfo()` | 云端 | 已存在 |
| 积分抵现规则 `pointsRate` | POS `DwdBillOpsServiceImpl.java:4002` | 已在线 |
| 小程序支付成功页 | `taro-mall/.../paycenter/index.tsx:445` | 入口已就绪 |

---

## 二、方案架构

```
消费结账完成
     │
     ▼
┌──────────────────────────────────────────────────────────┐
│           统一的积分计算服务: PointsEarnService           │
│  输入: 账单 + 会员上下文 + crm_points_rule                │
│  输出: earnedPoints (BigDecimal)                         │
└──────────────────────────────────────────────────────────┘
     │
     ├── 线上小程序: PayOrderServiceImpl 在 cardConsumeInner 前调 PointsEarnService
     │                 将 givePoint 透传给 cardConsumeInner DTO
     │
     ├── 线下 POS: DwdBillOpsServiceImpl 结账后调 PointsEarnService
     │              调用 CRM 消费赠分接口写入积分
     │
     └── 前端: 支付成功页 / 结账成功页展示本单赠送积分
```

---

## 三、积分计算引擎 PointsEarnService

### 源码位置（新建）

```
nms4cloud-crm/nms4cloud-crm-service/src/main/java/com/nms4cloud/crm/service/pointsearn/PointsEarnService.java
```

### 内部 DTO：PointsEarnContext

```java
@Data
public class PointsEarnContext {
    private String cardTypeCode;        // 卡类型编码
    private Integer cardTypeLevelCode;  // 等级数值
    private LocalDate birthday;         // 生日
    private boolean isBirthdayToday;
    private String wecomOpenid;         // 企微标识
    private Integer channel;            // 订单渠道
    private CrmPointsRule activeRule;  // 当前命中的规则
}
```

### 计算公式

#### BY_PAYMENT_AMOUNT（按支付方式实收金额）

```
basePoints = billAmount × levelRate(X元:Y积分)
if (birthdayEnabled && isBirthdayToday) basePoints ×= birthdayMultiplier
if (memberDayEnabled && isMemberDay)    basePoints ×= memberDayMultiplier
if (singleEarnLimitType == 1 && basePoints > limit) basePoints = limit（取固定上限）
if (singleEarnLimitType == 2 && basePoints > limit) basePoints = limit（取比例上限）
earnedPoints = floor(basePoints)
```

#### BY_PRODUCT_AMOUNT（按商品实收金额）

```
遍历 order_food，按商品分类或指定商品计算加权积分
其他逻辑同 BY_PAYMENT_AMOUNT
```

### 关键输入获取路径

| 数据 | 获取方式 |
|---|---|
| `crm_points_rule`（云端） | `CrmPointsRuleServicePlus.findUniqueRuleByPlan(mid, sid, planLid)` |
| `crm_points_rule`（POS 本地） | `select * from crm_points_rule where plan_lid = ?` |
| planLid 匹配路径 | `CrmCard.cardTypeCode(Long)` → `CrmCardType.lmnid(Long)` → `CrmPointsRule.planLid(Long)` |
| 会员卡等级 `cardTypeLevelCode` | `CrmCard.cardTypeLevelCode`（直接字段） |
| 会员生日 | `CrmMemberServicePlus.getMemberInfo(mid, cardLid).getBirthday()` |
| 企微身份 | `CrmMemberServicePlus.getMemberInfo(...).getWecomOpenid()` |
| 订单实收金额 | 从 bill 获取 |
| 订单渠道 `orderChannel` | CRM 消费接口中传入 |

> **⚠️ 注意**：`CrmCardType` 有两个标识字段：`id`（String）和 `lmnid`（Long）。`integralPlanCode` 是 String 类型，不参与规则匹配。匹配统一走 `CrmCard.cardTypeCode(Long) → CrmCardType.lmnid(Long) → crm_points_rule.planLid`。

### 复用已有能力（不重复造轮子）

- `CrmPointsRuleServicePlus.findUniqueRuleByPlan(mid, sid, planLid)` — 已存在
- `CrmMemberServicePlus.getMemberInfo()` — 已存在
- `CardBalanceService.executeInner()` 中的 givePoint 处理逻辑 — **不改动**，只需上游传入
- `CrmPointsRuleServicePlus.validateEarningRule()` — 复用做规则校验

---

## 四、小程序线上自动积分

### 修改点 1：PayOrderServiceImpl.java（约 line 310-330）

在调用 `cardConsumeInner` **之前**，增加积分计算和 givePoint 填充：

```java
// 在 crmCardOpConsumeDTO 构造完成后、cardConsumeInner 调用前
BigDecimal earnedPoints = pointsEarnService.calculateEarnedPoints(
    request.getMid(),
    request.getSid(),
    bill,           // order_bill 主账单
    payList,        // order_pay 列表
    crmCardOpConsumeDTO.getLid(),  // cardLid
    request.getOrderChannel()       // 渠道: 2-微信小程序
);
crmCardOpConsumeDTO.setGivePoint(earnedPoints);
```

**关键约束**：积分抵现本身不算赠分腿，只按实收金额算分。

### 追踪数据说明

> **重要澄清**：`givePoint` 落账**不依赖 order_bill 表字段**。`CardBalanceService` 在执行 `givePoint` 时已将积分变动写入 `crm_card_points_record`（积分流水）和会员积分余额，云端 `order_bill` 不需要加字段即可完成落账。

若需在订单侧保留最小追踪能力（用于对账、展示），可选方案：

- **方案A（推荐）**：以 `crm_card_points_record` 积分流水作为唯一追踪来源，前端查询 CRM 流水展示"本单赠送积分"
- **方案B**：在 `order_bill` 表新增 `earned_points` 等字段，由 `PayOrderServiceImpl` 写成功后回填

两种方案互斥，**建议选方案A**避免双写一致性问题。

### 修改点 2：小程序前端 paycenter/index.tsx

**支付成功回调**（`handleSuccess`，约 line 440-470）：
- 积分查询来源：调 CRM 流水接口查 `crm_card_points_record`，按 `orderId` 过滤，类型为"消费赠分"
- 返回 `{ earnedPoints, ruleName }`
- 在支付成功弹层或跳转的订单详情页展示

修改点：
- `src/common/service/api/auth.ts` 已有积分记录接口（`getPointsRecord`），可复用
- 支付成功页增加"本单赠送 X 积分"文案
- 订单详情页增加"积分来源说明"

---

## 五、线下 POS 自动积分

### 修改点 1：DwdBillOpsServiceImpl.java（约 line 1202-1210）

在 `dealCard` 返回后，增加积分计算和 CRM 回写：

```java
MemberCheckVO memberCheckVO = OrderServiceUtil.dealCard(types, dwdBill, request);

// 新增: 消费自动赠分
if (dwdBill.getCardLid() != null) {
    BigDecimal earnedPoints = OrderServiceUtil.calculateEarnedPointsLocal(dwdBill, types);
    if (earnedPoints != null && earnedPoints.compareTo(BigDecimal.ZERO) > 0) {
        OrderServiceUtil.saveEarnedPoints(dwdBill, earnedPoints, request);
        // 写 dwd_bill 赠分追踪字段
    }
}

OrderServiceUtil.dealCardPoint(types, dwdBill, memberCheckVO, request);
```

### 修改点 2：OrderServiceUtil.java（新增方法）

```java
// 本地计算消费赠分
public static BigDecimal calculateEarnedPointsLocal(DwdBill dwdBill, Map<PayWayEnum, DwdPay> types)

// 写 CRM 积分入账
public static void saveEarnedPoints(DwdBill dwdBill, BigDecimal earnedPoints, DwdBillCheckOutDTO request)
```

### 修改点 3：DwdBillEarnPointsService.java（POS 后端新建）

```java
public class DwdBillEarnPointsService {
    // 读取本地 crm_points_rule
    // 计算 earnedPoints
    // 调用 nms4CloudCrmService.saveEarnedPoints(dwdBill, earnedPoints)
}
```

### 修改点 4：dwd_bill 表新增字段

```sql
ALTER TABLE dwd_bill
  ADD COLUMN earned_points DECIMAL(18,2) DEFAULT NULL COMMENT '本单赠送积分',
  ADD COLUMN points_rule_lid VARCHAR(64) DEFAULT NULL COMMENT '积分规则 LID',
  ADD COLUMN earn_points_status TINYINT DEFAULT 0 COMMENT '赠分状态: 0-未发放, 1-已发放, 2-失败',
  ADD COLUMN earn_points_task_lid VARCHAR(64) DEFAULT NULL COMMENT '赠分任务号';
```

### 修改点 5：POS 前端 nms4pos-ui

- 结账成功页 `usePtPay.ts`：展示"本单赠送 X 积分"
- 账单详情页：展示赠分记录

---

## 六、退款 / 反结账幂等处理

### 小程序线上

> **追踪来源**：以 CRM 积分流水（`crm_card_points_record`）作为唯一追踪来源，退款时先查询该会员卡最近的消费赠分流水（按 `orderId` 匹配），再执行逆向回滚。

在 `PayOrderServiceImpl.refund()` 或 `voidOrder()` 中：

```java
// 查询本单已赠积分（从 CRM 积分流水）
CrmCardPointsRecord record = crmCardPointsRecordService.findByOrderIdAndType(
    cardLid, orderId, PointsRecordTypeEnum.CONSUME_EARN);
if (record != null && record.getPoints().compareTo(BigDecimal.ZERO) > 0) {
    // 撤销积分: 调 adjustPointsInner 加回已赠积分
    adjustPointsInner(cardLid, record.getPoints().negate(), "撤销订单-积分回退", orderId);
}
```

使用 `orderId` 作为幂等 key，防止重复回退。

### 线下 POS

在 `DwdBillOpsServiceImpl` 反结账分支（约 line 1443 / 3320）增加：

```java
// 已赠积分回退
if (dwdBill.getEarnedPoints() != null && dwdBill.getEarnedPoints().compareTo(BigDecimal.ZERO) > 0) {
    OrderServiceUtil.revokeEarnedPoints(dwdBill);
}
```

---

## 七、CRM 新增接口

### 积分上下文查询接口

```
GET /crm_card/points_context?mid=X&cardLid=Y
```

返回：
```json
{
  "cardTypeCode": "VIP",
  "cardTypeLevelCode": 2,
  "birthday": "1990-05-15",
  "isBirthdayToday": false,
  "wecomOpenid": "xxx",
  "activeRuleLid": "rule_xxx"
}
```

作用：支持线上线下统一从 CRM 获取会员积分上下文，不必各自查多处。

---

## 八、关键文件清单

### 云端 nms4cloud

| 文件 | 操作 |
|---|---|
| `.../pointsearn/PointsEarnService.java` | **新建** — 积分计算引擎 |
| `.../pointsearn/PointsEarnContext.java` | **新建** — 计算上下文 DTO |
| `.../PayOrderServiceImpl.java` | 修改，约 line 310-330 增加 givePoint 填充 |
| `.../crm_card_points_record` 流水表 | 查询已有流水用于退款回滚 |
| `taro-mall/src/common/service/api/auth.ts` | 复用已有积分记录接口 |
| `taro-mall/src/pagePop/paycenter/index.tsx` | 展示本单赠送积分 |
| `taro-mall/src/pages/bill/index.tsx`（订单详情页） | 展示积分来源说明 |

### POS 后端 nms4pos

| 文件 | 操作 |
|---|---|
| `.../DwdBillOpsServiceImpl.java` | 修改，约 line 1202-1210 增加赠分逻辑 |
| `.../OrderServiceUtil.java` | 新增 `calculateEarnedPointsLocal` / `saveEarnedPoints` / `revokeEarnedPoints` |
| `.../DwdBillEarnPointsService.java` | **新建** — 封装本地积分计算 |
| `dwd_bill` 表 | 新增 earned_points / points_rule_lid / earn_points_status / earn_points_task_lid 4个字段 |

### POS 前端 nms4pos-ui

| 文件 | 操作 |
|---|---|
| `api/pos4plugin/src/hooks/usePtPay.ts` | 结账成功页展示赠分 |
| `api/pos4plugin/src/enums/BasePayTypeEnum.ts` | 已有，可复用 |

---

## 九、CRM 已有能力（不改动）

以下部分代码保持不变，PointsEarnService 只需将计算结果传入即可：

- `CardBalanceService.executeInner()` — 已有完整的 givePoint → 积分余额 + 积分流水逻辑
- `CrmCardOpConsumeDTO.givePoint` 字段 — 已存在，下游已接上
- `CrmPointsRuleServicePlus.findUniqueRuleByPlan()` — 查询规则，已存在
- `CrmPointsRuleServicePlus.validateEarningRule()` — 规则校验，已存在
- `CrmMemberServicePlus.getMemberInfo()` — 会员信息查询，已存在

---

## 十、验证方案

### 小程序线上

1. 用测试会员账号（已知卡类型和生日）完成一笔含会员卡支付的订单
2. 支付成功后检查：CRM 积分余额 +earnedPoints，积分流水有"消费赠分"记录
3. 检查小程序订单详情页显示"本单赠送 X 积分"
4. 退款后检查积分回退

### 线下 POS

1. 用测试会员在 POS 完成一笔结账（含会员卡支付）
2. 查看 `dwd_bill` 表 `earned_points` 字段有值
3. 查看 CRM 积分余额 +earnedPoints，积分流水有"消费赠分"记录
4. POS 结账成功页展示"本单赠送 X 积分"
5. 反结账后检查积分回退

### 边界条件验证

- ❌ 非会员账单 → 不赠分
- ❌ 会员但未开启积分规则 → 不赠分
- ✅ 生日多倍和会员日多倍 → 正确叠加
- ✅ 单次上限拦截 → 正确
- ✅ 积分抵现腿不算赠分基数（按实收金额算，不是折前金额）