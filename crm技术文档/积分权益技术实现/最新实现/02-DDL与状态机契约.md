# DDL 与状态机契约

日期：2026-05-10

## 1. POS 表结构

### 1.1 `crm_consume_points_session`

```sql
CREATE TABLE `crm_consume_points_session` (
  `lid` BIGINT NOT NULL COMMENT '生命周期主键',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `source_type` VARCHAR(32) NOT NULL COMMENT '来源类型，POS消费积分固定为POS_CONSUME_POINTS',
  `bill_lid` BIGINT NOT NULL COMMENT 'POS原账单LID',
  `order_id` VARCHAR(64) NOT NULL COMMENT 'POS原账单号',
  `card_lid` BIGINT NOT NULL COMMENT '会员卡LID',
  `card_no` VARCHAR(64) DEFAULT NULL COMMENT '会员卡号',
  `status_` VARCHAR(32) NOT NULL COMMENT 'OPEN/CLOSED/FAILED',
  `current_round_lid` BIGINT DEFAULT NULL COMMENT '当前有效round LID',
  `retry_count` INT NOT NULL DEFAULT 0 COMMENT '生命周期级补偿重试次数',
  `next_retry_time` DATETIME DEFAULT NULL COMMENT '下次补偿时间',
  `last_error_msg` VARCHAR(1000) DEFAULT NULL COMMENT '最近失败原因',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`lid`),
  UNIQUE KEY `uk_crm_consume_points_session_biz` (`mid`, `source_type`, `order_id`, `card_lid`),
  KEY `idx_crm_consume_points_session_bill` (`mid`, `bill_lid`),
  KEY `idx_crm_consume_points_session_round` (`current_round_lid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费积分总生命周期';
```

### 1.2 `crm_consume_points_round`

```sql
CREATE TABLE `crm_consume_points_round` (
  `lid` BIGINT NOT NULL COMMENT 'round主键，也是CRM lifecycle_id',
  `session_lid` BIGINT NOT NULL COMMENT '所属session LID',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `round_no` INT NOT NULL COMMENT '同一session下第几轮积分生命周期',
  `parent_round_lid` BIGINT DEFAULT NULL COMMENT '上一轮round LID，部分退款重发时填写',
  `status_` VARCHAR(32) NOT NULL COMMENT 'GRANT_PENDING/GRANT_PROCESSING/GRANTED/REVOKE_PENDING/REVOKE_PROCESSING/REVOKED/FAILED',
  `active_flag` TINYINT NOT NULL DEFAULT 1 COMMENT '1=当前有效或正在关闭，0=历史终态',
  `grant_points` DECIMAL(18,2) NOT NULL DEFAULT 0 COMMENT '本轮应赠积分',
  `current_effective_points` DECIMAL(18,2) NOT NULL DEFAULT 0 COMMENT '本轮当前有效积分',
  `grant_points_record_lid` BIGINT DEFAULT NULL COMMENT 'CRM正向积分流水LID',
  `revoke_points_record_lid` BIGINT DEFAULT NULL COMMENT 'CRM负向积分流水LID',
  `rule_lid` BIGINT DEFAULT NULL COMMENT '积分规则LID',
  `rule_revision` VARCHAR(64) DEFAULT NULL COMMENT '积分规则版本',
  `eligible_amount_snapshot` DECIMAL(18,2) DEFAULT NULL COMMENT '可积分金额快照',
  `pay_snapshot_json` JSON NOT NULL COMMENT '支付事实快照，包含支付方式、金额、本金、赠送金额、是否参与积分',
  `grant_basis_snapshot_json` JSON DEFAULT NULL COMMENT '授分依据快照，包含会员等级、规则关键字段、计算口径',
  `retry_count` INT NOT NULL DEFAULT 0 COMMENT '补偿重试次数',
  `next_retry_time` DATETIME DEFAULT NULL COMMENT '下次补偿时间',
  `last_error_msg` VARCHAR(1000) DEFAULT NULL COMMENT '最近失败原因',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`lid`),
  UNIQUE KEY `uk_crm_consume_points_round_no` (`session_lid`, `round_no`),
  KEY `idx_crm_consume_points_round_active` (`session_lid`, `active_flag`),
  KEY `idx_crm_consume_points_round_retry` (`status_`, `next_retry_time`),
  KEY `idx_crm_consume_points_round_parent` (`parent_round_lid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费积分轮次生命周期';
```

说明：

```text
MySQL 不能直接用普通唯一索引表达“同一 session 只允许一个 active_flag=1 round，但允许多个 active_flag=0 round”。
实现时需要二选一：
1. 使用 generated column 表达 active_round_session_lid，仅 active_flag=1 时有值，并建唯一索引。
2. 使用事务内 SELECT FOR UPDATE / CAS 更新保证同一 session 下只有一个 active round。
```

### 1.3 `crm_consume_points_event`

```sql
CREATE TABLE `crm_consume_points_event` (
  `lid` BIGINT NOT NULL COMMENT '事件主键',
  `session_lid` BIGINT NOT NULL COMMENT '所属session LID',
  `round_lid` BIGINT DEFAULT NULL COMMENT '所属round LID',
  `event_type` VARCHAR(64) NOT NULL COMMENT 'CHECKOUT_GRANT_REQUESTED/REVOKE_REQUESTED/REFUND_RECALCULATE_REQUESTED/CRM_GRANT_SUCCEEDED/CRM_GRANT_FAILED/CRM_REVOKE_SUCCEEDED/CRM_REVOKE_FAILED',
  `status_` VARCHAR(16) NOT NULL COMMENT 'NEW/HANDLED/FAILED',
  `payload_json` JSON DEFAULT NULL COMMENT '事件快照',
  `error_msg` VARCHAR(1000) DEFAULT NULL COMMENT '失败原因',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`lid`),
  KEY `idx_crm_consume_points_event_session` (`session_lid`),
  KEY `idx_crm_consume_points_event_round` (`round_lid`),
  KEY `idx_crm_consume_points_event_type` (`event_type`, `created_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费积分弱事件日志';
```

## 2. CRM 表结构

### 2.1 `crm_consume_points_task`

```sql
CREATE TABLE `crm_consume_points_task` (
  `pid` BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理主键',
  `company_id` BIGINT NOT NULL COMMENT '商户ID',
  `shop_id` BIGINT DEFAULT NULL COMMENT '门店ID',
  `lmnid` BIGINT NOT NULL COMMENT '业务逻辑主键',
  `source_` TINYINT NOT NULL COMMENT '积分来源：1-POS，2-云端订单',
  `task_lid` BIGINT NOT NULL DEFAULT 0 COMMENT 'CRM消费任务LID，仅储值消费链路存在；0表示非储值消费',
  `bill_lid` BIGINT DEFAULT NULL COMMENT 'POS账单LID',
  `order_id` VARCHAR(64) NOT NULL COMMENT '消费订单号',
  `lifecycle_id` BIGINT NOT NULL COMMENT '消费积分生命周期ID，POS来源传积分轮次LID',
  `task_type` TINYINT NOT NULL COMMENT '任务类型：1-发放，2-撤销',
  `card_lid` BIGINT NOT NULL COMMENT '会员卡LID',
  `card_no` VARCHAR(64) NOT NULL COMMENT '会员卡号',
  `points` DECIMAL(18,2) NOT NULL COMMENT '本次任务积分，发放为正数、撤销为负数',
  `target_points_record_lid` BIGINT DEFAULT NULL COMMENT '撤销目标正向积分流水LID',
  `produced_points_record_lid` BIGINT DEFAULT NULL COMMENT '本任务生成的积分流水LID',
  `status_` TINYINT NOT NULL COMMENT '状态：0-处理中，1-成功，2-失败',
  `operator` VARCHAR(64) DEFAULT NULL COMMENT '操作人',
  `comment` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `error_msg` VARCHAR(1000) DEFAULT NULL COMMENT '失败原因',
  `executed_time` DATETIME DEFAULT NULL COMMENT '任务执行时间',
  `revision` INT DEFAULT 0 COMMENT '数据版本',
  `created_by` VARCHAR(64) DEFAULT NULL COMMENT '创建人',
  `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(64) DEFAULT NULL COMMENT '修改人',
  `updated_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
  PRIMARY KEY (`pid`),
  UNIQUE KEY `uk_crm_consume_points_task_lifecycle_type` (`company_id`, `source_`, `lifecycle_id`, `task_type`, `task_lid`, `card_lid`, `order_id`, `deleted`),
  KEY `idx_crm_consume_points_task_lmnid` (`lmnid`),
  KEY `idx_crm_consume_points_task_order` (`order_id`),
  KEY `idx_crm_consume_points_task_lifecycle` (`lifecycle_id`),
  KEY `idx_crm_consume_points_task_task` (`task_lid`),
  KEY `idx_crm_consume_points_task_bill` (`bill_lid`),
  KEY `idx_crm_consume_points_task_status` (`status_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CRM消费积分幂等账务任务';
```

### 2.2 `crm_card_points_record`

```sql
ALTER TABLE `crm_card_points_record`
  ADD COLUMN `related_points_record_lid` BIGINT DEFAULT NULL COMMENT '负向撤销流水关联的原正向积分流水LID',
  ADD KEY `idx_crm_card_points_record_related` (`related_points_record_lid`);
```

## 3. 状态机契约

### 3.1 结账

```text
1. 创建或读取 session：
   status = OPEN

2. 创建 round：
   round_no = 1 或上一轮 + 1
   status = GRANT_PENDING
   active_flag = 1
   grant_points = 本轮应赠积分
   pay_snapshot_json = 本轮支付事实快照
   grant_basis_snapshot_json = 本轮授分依据快照

3. 事务提交后或补偿任务执行：
   GRANT_PENDING -> GRANT_PROCESSING -> GRANTED

4. CRM 成功后回写：
   grant_points_record_lid
   current_effective_points = grant_points
```

### 3.2 反结账 / 全额退款

```text
1. 找到当前 active round。
2. 推进：
   GRANTED/GRANT_PENDING/GRANT_FAILED -> REVOKE_PENDING

3. 补偿任务执行：
   REVOKE_PENDING -> REVOKE_PROCESSING -> REVOKED

4. CRM 成功后回写：
   revoke_points_record_lid
   current_effective_points = 0
   active_flag = 0
   session.status = CLOSED
```

### 3.3 部分退款

```text
1. 找到当前 active round。
2. 旧 round：
   REVOKE_PENDING -> REVOKED
   active_flag = 0

3. 按退款后的剩余支付事实重新计算应赠积分。
4. 如果应赠积分 > 0：
   创建新 round
   parent_round_lid = old_round.lid
   round_no = old_round.round_no + 1
   status = GRANT_PENDING
   active_flag = 1

5. session.status 保持 OPEN。
```

### 3.4 晚回包

```text
grant 成功回包到达时：
  如果 round 当前仍是 GRANT_PENDING / GRANT_PROCESSING / GRANT_FAILED：
    可以回写为 GRANTED。

  如果 round 当前已经是 REVOKE_PENDING / REVOKE_PROCESSING / REVOKED：
    只能补写 grant_points_record_lid。
    不能把状态覆盖回 GRANTED。
```

### 3.5 CRM 幂等

```text
GRANT:
  unique(mid, source_type, lifecycle_id, task_type=GRANT)
  重复请求返回已生成的正向积分流水。

REVOKE:
  unique(mid, source_type, lifecycle_id, task_type=REVOKE)
  重复请求返回已生成的负向积分流水。

REVOKE 查不到 GRANT 或正向积分流水：
  返回可重试失败。
  POS round 保持 REVOKE_PENDING / REVOKE_FAILED。
```

## 4. 账务真相

本轮定义：

```text
crm_card_points_record 是积分账本。
crm_card.points 是当前积分余额投影。
crm_consume_points_task 是 CRM 账务动作幂等记录。
```

CRM grant/revoke 必须在一个本地数据库事务中完成：

```text
1. 幂等判断或插入 task
2. 更新 crm_card.points
3. 写 crm_card_points_record
4. 回写 task.produced_points_record_lid
```

并发下需要保证：

```text
同一 lifecycle_id + task_type 只有一个任务成功。
重复请求不能重复更新 crm_card.points。
重复请求不能重复写 crm_card_points_record。
```
