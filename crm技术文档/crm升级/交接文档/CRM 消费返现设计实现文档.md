# CRM 消费返现设计实现文档

日期：2026-08-28
作者：guoyun_liu
状态：已实现

## 1. 背景与目标

POS 会员结账后触发消费返现，旧链路由 POS 直接裸调 `CrmCardOpServicePlus.cardCashBack()` 接口，存在断网重试时重复增加会员余额的风险。

本设计目标：**POS 只负责在结账成功后生成 roundKey 并调用 CRM 幂等接口，CRM 负责匹配规则、调用旧返现能力、持久化幂等记录和撤销时需要的原 taskLid**。不修改旧的会员卡返现接口，不让 POS 直接操控余额表。

## 2. 核心架构

```
POS 结账 afterCommit
  → 生成 roundKey（同一次结账轮次唯一）
  → POST /crm_consume_cash/grantSign
    → CrmConsumeCashOpServicePlus.grant()
      → findOrCreateRecord() 幂等
      → matchRule() 匹配返现规则
      → cardCashBack() 调用旧接口
      → 保存 taskLid
  → POST /crm_consume_cash/revokeSign（反结账/退款）
    → CrmConsumeCashOpServicePlus.revoke()
      → findRecord() 按 roundKey 查找
      → revokeCashBack() 撤销原 taskLid
```

## 3. 接口设计

### 3.1 发放返现

```
POST /crm_consume_cash/grantSign
签名校验：NeedVerifySignature（自动从签名字段落入 mid/sid）
```

| 字段 | 来源 | 必填 | 含义 |
|------|------|------|------|
| `merchantNo` | 签名字段 | — | 落入 `mid` |
| `terminalId` | 签名字段 | — | 落入 `sid` |
| `roundKey` | POS 本地生成 | ✅ | POS 返现轮次幂等键，同一键只返现一次 |
| `outOrderId` | POS 外部订单号 | ✅ | 用于记录追踪 |
| `cardLid` | POS 会员卡 LID | 否 | CRM 以此为主键 |
| `cardNo` | 会员卡号 | ✅ | 定位会员卡 |
| `checkOutTime` | POS 结账时间 | ✅ | 用于返现规则有效期校验 |
| `billAmount` | 整单实付金额 | ✅ | 用于规则金额门槛匹配 |
| `operator` | POS 操作人 | 否 | 写入操作记录 |

返回 `CrmConsumeCashResultVO`：

| 字段 | 含义 |
|------|------|
| `status` | PENDING/GRANTED/NO_MATCH/REVOKED/FAILED |
| `roundKey` | POS 返现轮次幂等键 |
| `ruleLid` | 命中的返现规则 LID |
| `cashBackAmount` | 本次返现金额（单位元） |
| `taskLid` | CRM 返现任务 LID（撤销时必须） |
| `message` | 业务提示信息 |

### 3.2 撤销返现

```
POST /crm_consume_cash/revokeSign
签名校验：NeedVerifySignature
```

| 字段 | 来源 | 必填 | 含义 |
|------|------|------|------|
| `roundKey` | POS 本地生成 | ✅ | 定位原返现记录 |
| `outOrderId` | POS 外部订单号 | 否 | 兜底排查 |
| `cardNo` | 会员卡号 | 否 | 兜底排查 |

## 4. 表结构

### 4.1 `crm_consume_cash_op_record`（消费返现 POS 轮次幂等记录）

| 字段 | 类型 | 含义 |
|------|------|------|
| `pid` | BIGINT AUTO_INCREMENT | 物理主键 |
| `mid` | BIGINT | 商户 ID |
| `sid` | BIGINT | 门店 ID |
| `lid` | BIGINT | 业务逻辑主键（雪花算法） |
| `round_key` | VARCHAR(128) | **POS 返现轮次幂等键**，同一键只返现一次 |
| `order_id` | VARCHAR(64) | POS 外部订单号 |
| `card_lid` | BIGINT | 会员卡 LID |
| `card_no` | VARCHAR(64) | 会员卡号 |
| `status_` | INT | **状态：1-待处理，2-已返现，3-未命中，4-已撤销，5-失败** |
| `rule_lid` | BIGINT | 命中的消费返现规则 LID |
| `bill_amount` | DECIMAL(18,2) | 参与返现的消费金额快照 |
| `check_out_time` | DATETIME | POS 结账时间快照（用于幂等校验和规则有效期判定） |
| `cash_back_amount` | DECIMAL(18,2) | 本次返现金额 |
| `task_lid` | BIGINT | **CRM 返现任务 LID，撤销时必须** |
| `balance_record_lid` | BIGINT | 会员余额流水 LID（预留） |
| `request_json` | TEXT | 返现请求快照 JSON |
| `response_json` | TEXT | 最近一次 CRM 响应快照 JSON |
| `error_msg` | TEXT | 最近一次失败原因 |
| `grant_time` | DATETIME | 成功返现时间 |
| `revoke_time` | DATETIME | 成功撤销时间 |
| `revision` | INT | 乐观锁版本号 |
| `created_by/created_time/updated_by/updated_time/deleted` | — | 标准审计字段 |

索引：

```sql
UNIQUE KEY uk_crm_consume_cash_op_round (mid, sid, round_key, deleted)  -- 幂等键唯一
KEY idx_crm_consume_cash_op_order (mid, order_id)                    -- 按订单排查
KEY idx_crm_consume_cash_op_status (status_)                         -- 状态查询
```

## 5. 幂等状态机

```
┌─────────────┐    grant()    ┌──────────────┐
│   PENDING   │ ────────────→ │   GRANTED    │ ← 终态，不重复返现
└─────────────┘              └──────────────┘
       │                             │
       │ revoke()                    │
       ↓                             │ revoke()
┌─────────────┐                 ┌──────────────┐
│  REVOKED    │ ←────────────── │   REVOKED    │ ← 终态，不重复撤销
└─────────────┘   revoke()     └──────────────┘
       │
       │ grant()（撤销先到时）
       ↓
┌─────────────┐
│ NO_MATCH /  │
│  FAILED     │ ← 终态，不重复返现
└─────────────┘
```

状态枚举 `CrmConsumeCashOpStatusEnum`：

| code | 枚举值 | 含义 |
|------|--------|------|
| 1 | PENDING | 待处理 |
| 2 | GRANTED | 已返现 |
| 3 | NO_MATCH | 未命中规则 |
| 4 | REVOKED | 已撤销 |
| 5 | FAILED | 处理失败（可重试） |

## 6. 关键设计决策

### 6.1 幂等键为 roundKey，不是订单号

同一笔 POS 消费单可能发生多次结账/反结账/再次结账，如果用订单号做幂等键，后续轮次会被误判为重复。roundKey 由 POS 每一轮结账/反结账固定生成，保证每个轮次独立幂等。

### 6.2 撤销先到时的 Tombstone 机制

POS 退款/反结账可能发生在 afterCommit 发放请求到达 CRM 之前。若撤销时找不到发放记录，CRM 写入 `status_=REVOKED` 的墓碑记录（只有 roundKey 等键字段，无金额）。后续迟到的发放请求命中 REVOKED 终态后幂等返回"已撤销"，不再调用旧返现接口。

### 6.3 载荷一致性校验

roundKey 是资金类操作幂等键，不能只按键命中后直接返回旧结果。重复发放请求时必须校验订单号、会员卡、金额、结账时间是否一致；不一致时返回 `FAILED`，避免 POS 侧状态错误被掩盖。

### 6.4 返现交易单号隔离

撤销返现必须依赖原返现任务 taskLid，不能复用原消费单号。因为同一 POS 消费单若发生多次结账，原消费单号相同，直接复用会导致后续轮次返现被误判为已处理。

返现交易单号格式：`CB + record.lid`（如 CB192837465），控制在 32 字符以内。

## 7. 规则匹配逻辑

沿用现有 `crm_cash_back` 配置表，匹配维度：

- 商户 + 门店（支持全门店 `is_all_store`）
- 会员卡类型（`card_type_code`）
- 会员卡等级（`card_type_level_code`）
- 有效期（`valid_begin_time` / `valid_end_time`）
- 金额门槛（`min_amount` / `max_amount`）

匹配优先级（从高到低）：
1. `card_type_level_code` 非空 > 空
2. `card_type_code` 非空 > 空
3. `min_amount` 更大（更精确的门槛优先）
4. `pid` 更小（稳定排序）

## 8. 代码文件清单

| 文件 | 职责 |
|------|------|
| `CrmConsumeCashOpController.java` | 接口入口，签名解析 |
| `CrmConsumeCashOpServicePlus.java` | 幂等编排、规则匹配、返现执行 |
| `CrmConsumeCashGrantDTO.java` | 发放请求 DTO |
| `CrmConsumeCashRevokeDTO.java` | 撤销请求 DTO |
| `CrmConsumeCashResultVO.java` | 返回 VO |
| `CrmConsumeCashOpStatusEnum.java` | 状态枚举 |
| `CrmConsumeCashOpRecord.java` | 实体（DAO） |
| `ICrmConsumeCashOpRecordService.java` | 实体服务接口 |
| `CrmConsumeCashOpRecordServiceImpl.java` | 实体服务实现 |
| `V20260516__crm_consume_cash_op_record.sql` | 建表 SQL |

## 9. 与旧接口的边界

| 角色 | 职责 |
|------|------|
| POS | 生成 roundKey、调用幂等接口、处理 CRM 返回结果 |
| `CrmConsumeCashOpServicePlus.grant()` | 唯一可调用旧 `cardCashBack()` 的位置 |
| `CrmCardOpServicePlus.cardCashBack()` | 旧会员卡返现接口，不感知 roundKey 幂等 |
| `crm_consume_cash_op_record` | 幂等状态权威记录 |

## 10. 后台管理页面

### 10.1 管理页面入口

| 功能 | 前端路径 | 前端组件 |
|------|---------|---------|
| 消费返现规则管理 | `CrmMarketingMrg` 下的消费返现子路由 | `src/pages/CrmMarketingMrg/components/CrmCashBack/index.tsx` |

### 10.2 后台管理接口

入口 Controller：`CrmCashBackController`（路径 `/crm_cash_back`）

| 接口 | 方法 | 权限 | 说明 |
|------|------|------|------|
| `/crm_cash_back/get` | POST | 登录后可见 | 获取消费返现详情（含菜品绑定列表） |
| `/crm_cash_back/list` | POST | 登录后可见 | 分页查询消费返现规则列表 |
| `/crm_cash_back/add` | POST | `crm:cash:back:add` | 新增消费返现规则 |
| `/crm_cash_back/update` | POST | `crm:cash:back:update` 或 `edit` | 修改消费返现规则 |
| `/crm_cash_back/del` | POST | `crm:cash:back:del` | 删除消费返现规则 |
| `/crm_cash_back/add_cash_back_dish` | POST | `crm:cash:back:dish` 或 `set:goods` | 设置参与返现的菜品（不参与返现菜品） |
| `/crm_cash_back/export` | POST | `crm:cash:back:export` | 导出消费返现规则 |

### 10.3 消费返现规则配置维度

消费返现规则由 `crm_cash_back` 表承载，字段覆盖：

| 维度 | 字段 | 说明 |
|------|------|------|
| 基本信息 | `mid/sid`、`name`、`status` | 商户/门店、规则名称、启用状态 |
| 适用门店 | `is_all_store`、`store_sids`（JSON） | 全门店适用或指定门店列表 |
| 会员卡类型 | `card_type_code`、`card_type` | 适用会员卡类型（可为空表示不限） |
| 会员卡等级 | `card_type_level_code`、`card_type_level` | 适用会员卡等级（可为空表示不限） |
| 有效期 | `valid_begin_time`、`valid_end_time` | 规则有效起止时间 |
| 金额门槛 | `min_amount`、`max_amount` | 消费金额区间，满足此区间才返现 |
| 返现方式 | `cash_back_type`（固定金额/比例返现） | 返现类型枚举 |
| 返现金额 | `cash_back_amount`（固定金额）或 `cash_back_amount_rate`（比例） | 返现值，比例前端传百分比后端除以100存小数 |
| 返现上限 | `cash_back_max_amount` | 单次返现最大金额上限 |
| 菜品排除 | `crm_cash_back_food` 关联表 | 不参与返现的菜品列表 |

### 10.4 与 POS 幂等链路的分工

| 角色 | 说明 |
|------|------|
| 后台管理（`CrmCashBackController`） | 消费返现规则的 CRUD 操作，关联菜品绑定 |
| POS 幂等链路（`CrmConsumeCashOpController`） | 结账后按 `crm_cash_back` 规则匹配并执行返现 |

后台修改 `crm_cash_back` 配置后，POS 通过本地缓存的规则数据在下一轮结账时生效。

## 12. 测试验证要点

- 同一 roundKey 重复发放：返回原 GRANTED 结果，不重复返现
- 撤销先到、发放后到：发放命中 REVOKED 终态，返回"已撤销"
- 载荷不一致：返回 FAILED，POS 告警
- 规则未命中：状态为 NO_MATCH
- 反结账撤销：使用原 taskLid 撤销，不误撤其他轮次
