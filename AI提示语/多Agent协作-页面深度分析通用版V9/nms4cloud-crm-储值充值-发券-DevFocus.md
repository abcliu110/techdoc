# 功能级业务深挖说明书（Dev Focus）

## 1. 功能概览（业务目标 + 功能边界）
- **储值充值**：会员发起储值，系统根据规则匹配套餐/小额/霸王餐，生成支付订单并创建交易任务与子项。
- **发券/发券规则**：系统支持按券列表批量发券（含券包拆分），并对领取时间、库存、次数限制进行校验。
- **券核销**：**盲区（未定位入口与主流程）**，无法确认具体核销链路与状态更新规则。

证据索引：[R1][R2][R3]

---

## 2. 入口与调用链总览

### 储值充值入口
- `POST /charge/commit` → `ChargeService.commit(...)`
- `POST /charge/success` → `ChargeService.success(...)`
- `POST /charge/query_charge_status` → `ChargeService.queryChargeStatus(...)`

证据索引：[R1]

### 发券入口（服务级）
- `CrmCouponOpServicePlus.couponOpAdd(...)`
  - 带卡信息的重载：`couponOpAdd(CouponOpAddDTO, CrmCard, Map<Long, CrmCoupon>)`
  - 通过 `lid` 拉取会员卡的重载：`couponOpAdd(CouponOpAddDTO)`

证据索引：[R2]

### 券核销入口
- **盲区（Blind Spot）**：未在该模块中检索到明显的 `writeOff/核销/consume` 主入口。
建议后续指定“券核销模块名/Controller名/接口路径”进行深挖。

---

## 3. 关键链路详解（含分支）

### 3.1 储值充值主链路（ChargeService.commit）

**主链路**
1) 登录与门店/会员卡校验
2) 根据 `ruleType` 选择规则来源
3) 规则校验后计算总金额
4) 调用支付下单
5) 创建交易任务 `CrmDealTask` 与 `CrmDealTaskItem`
6) 发送延时关单消息

证据索引：[R1]

**关键分支（规则类型）**
- `ruleType == 0`：储值套餐（必须传 `ruleIds`）
- `ruleType == -1`：小额储值（校验账单金额与订单ID）
- `ruleType == -2`：霸王餐储值（校验账单与线下账单唯一性）

证据索引：[R1]

**影响金额/权益节点**
- `principalAmount/giveAmount/points/dashAmount` 计算
- 规则中携带赠券时触发 `addCoupon(...)`
- 交易任务保存时写入赠券信息摘要

证据索引：[R1]

---

### 3.2 发券主链路（CrmCouponOpServicePlus）

**发券入口 → 校验 → 发券**
1) 校验参数（mid、orderId、渠道、券列表、数量上限）
2) 读取券定义（确保券存在）
3) 校验领取规则（审核状态、终止状态、领取时间、库存、次数限制）
4) 扣减库存（乐观更新）
5) 生成券订单
6) 发送领取通知

证据索引：[R2][R3]

**券包发放分支**
- 若 `is_pkg=true`：展开子券 → 对每个子券按数量生成订单
- 若 `is_pkg=false`：直接生成普通券订单
证据索引：[R2]

**使用期计算分支**
- `UseRestrictionEnum.GDTS`：按固定天数计算 `beginUseTime/endUseTime`
证据索引：[R2]

---

## 4. 规则清单（含行号与影响）

### 储值充值规则
- 规则类型必须是 `0/-1/-2`，否则抛出“**不支持储值类型**”
- 小额储值与霸王餐必须提供 `billAmount/orderId`
- 充值规则可能包含“升级卡类型”限制（防止重复收取工本费）
- 充值规则可配置“可选赠券”，必须从指定券列表中选 1 张
证据索引：[R1]

### 发券规则
- 发券列表券码不得重复
- 单次券数量不得超过 1000
- 券必须已审核、未终止
- 领取必须在 `begin_reception_time ~ end_reception_time`
- 库存不足即失败
- 每日领取上限/总领取上限（若开启检查）
证据索引：[R2][R3]

---

## 5. 数据与副作用清单

### 储值充值副作用
- 写入：`CrmDealTask`
- 写入：`CrmDealTaskItem`
- 发送 MQ 延时关单消息
- 调用支付下单接口（外部系统）
证据索引：[R1]

### 发券副作用
- 更新券库存（`received_number` 递减）
- 创建券订单（`CrmCouponOrder`）
- 发送领取通知消息
证据索引：[R2]

---

## 6. 风险与边界假设（明确盲区）

- **盲区**：券核销入口与流程未定位
- **盲区**：充值成功后的“余额到账/发券触发”链路未在当前代码范围内定位
- **风险**：发券库存扣减为数据库更新，若并发超高可能出现领取失败，需要上层补偿机制（未发现补偿逻辑）
- **风险**：储值规则分支多且依赖配置，规则变更易引发链路差异

---

## 7. 修改建议（安全点/危险点）

### 安全修改点（优先改）
- `CrmCouponOpServicePlus.checkForAdd(...)`：调整领取规则（时窗/次数/审核/终止）
- `ChargeService.commit(...)`：规则校验逻辑（`ruleType` 分支）
证据索引：[R1][R3]

### 危险修改点（谨慎改）
- `issuance(...)` 内部库存扣减与券订单创建：牵涉库存一致性与通知
- `createDealTask(...)` 中金额与任务字段写入：影响账务与统计口径
证据索引：[R1][R2]

---

## 8. 验证方案（最小可行验证）

### 单元测试建议
- 充值：`ruleType=0/-1/-2` 分支校验
- 发券：库存不足、领取时间未到/已过、每日/总次数上限
- 赠券：可选赠券未选应报错

### 集成测试路径
- 会员充值 → 规则校验 → 支付下单 → 任务创建
- 发券（普通券） → 库存扣减 → 券订单生成
- 发券（券包） → 子券展开 → 多订单生成

### 关键日志/指标
- 充值异常日志：`“充值异常”`
- 发券失败：库存不足、券包子券缺失、数量超限
证据索引：[R1][R2][R3]

---

## 9. 代码证据索引（文件/方法/行号）

**[R1] 储值充值与任务创建**
```1:210:d:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\charge\ChargeService.java
// commit(), createDealTask(), addCoupon() 等
```

**[R2] 发券主流程与券包拆分**
```1:238:d:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\card\CrmCouponOpServicePlus.java
// couponOpAdd(), issuance(), toPkg(), toNormal()
```

**[R3] 发券规则校验（时窗/库存/次数）**
```239:370:d:\mywork\nms4cloud\nms4cloud-app\2_business\nms4cloud-crm\nms4cloud-crm-service\src\main\java\com\nms4cloud\crm\service\card\CrmCouponOpServicePlus.java
// checkForAdd()
```
