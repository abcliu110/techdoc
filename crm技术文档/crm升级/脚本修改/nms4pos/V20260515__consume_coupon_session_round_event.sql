-- ---------------------------------------------------------------
-- POS 消费赠券 Session / Round / Event 三表
-- 日期: 2026-05-15
-- 说明: 参照 crm_consume_points_task 结构
-- ---------------------------------------------------------------

-- 会话：一轮消费（含多次结账/反结账）
CREATE TABLE IF NOT EXISTS crm_consume_coupon_session (
    pid                BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理主键',
    mid                BIGINT NOT NULL COMMENT '商户ID',
    sid                BIGINT NOT NULL COMMENT '门店ID',
    card_lid           BIGINT NOT NULL COMMENT '会员卡LID',
    card_no            VARCHAR(32) COMMENT '会员卡号',
    origin_lifecycle_id VARCHAR(64) COMMENT '消费生命周期ID（POS清台/round ID）',
    source             TINYINT NOT NULL DEFAULT 1 COMMENT '来源：1-POS，2-线上订单',
    status             VARCHAR(16) NOT NULL DEFAULT 'ACTIVE' COMMENT '会话状态：ACTIVE/COMPLETED/CLOSED',
    created_time       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted            TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
    revision           INT NOT NULL DEFAULT 0 COMMENT '数据版本',
    PRIMARY KEY (pid),
    INDEX idx_mid_sid (mid, sid),
    INDEX idx_card_lifecycle (card_lid, origin_lifecycle_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费赠券会话表';

-- 轮次：每个赠券操作（含 grant / revoke）
CREATE TABLE IF NOT EXISTS crm_consume_coupon_round (
    pid               BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理主键',
    session_lid       BIGINT NOT NULL COMMENT '所属会话PID',
    mid               BIGINT NOT NULL COMMENT '商户ID',
    sid               BIGINT NOT NULL COMMENT '门店ID',
    card_lid          BIGINT NOT NULL COMMENT '会员卡LID',
    card_no           VARCHAR(32) COMMENT '会员卡号',
    bill_lid          BIGINT COMMENT '账单LID（幂等键字段）',
    out_order_id      VARCHAR(64) COMMENT '外部订单号（幂等键字段）',
    event_type        TINYINT NOT NULL COMMENT '事件类型：1-发放，2-撤销',
    status            TINYINT NOT NULL DEFAULT 1 COMMENT '轮次状态：1-待处理，2-等待CRM回调，3-已发放成功，4-发放失败，5-撤销待处理，6-撤销中，7-已撤销，8-撤销失败，9-需人工处理',
    -- 幂等键: mid + sid + source + bill_lid + event_type + out_order_id + card_lid
    business_key      VARCHAR(128) NOT NULL COMMENT '业务幂等键，格式：mid|sid|source|billLid|eventType|outOrderId|cardLid',
    crm_task_lid      VARCHAR(64) COMMENT 'CRM任务LID（回调后更新）',
    rule_lid          BIGINT COMMENT '命中的规则LID',
    rule_snapshot     JSON COMMENT '规则快照（JSON）',
    grant_amount      DECIMAL(18,2) COMMENT '赠券金额（快照）',
    error_message     VARCHAR(256) COMMENT '最近失败原因',
    retry_count       INT DEFAULT 0 COMMENT '重试次数',
    next_retry_time   DATETIME COMMENT '下次重试时间',
    created_time      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_time      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted           TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
    revision          INT NOT NULL DEFAULT 0 COMMENT '数据版本',
    PRIMARY KEY (pid),
    UNIQUE KEY uk_business_key (business_key, deleted),
    INDEX idx_status_retry (status, next_retry_time),
    INDEX idx_session (session_lid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费赠券轮次表';

-- 事件：操作流水（可排查性）
CREATE TABLE IF NOT EXISTS crm_consume_coupon_event (
    pid               BIGINT NOT NULL AUTO_INCREMENT COMMENT '物理主键',
    round_lid         BIGINT NOT NULL COMMENT '所属轮次PID',
    event_type        TINYINT NOT NULL COMMENT '事件类型：1-发放，2-撤销',
    event_status      VARCHAR(16) NOT NULL COMMENT '事件状态：SUCCESS/FAILED/PENDING',
    request_payload   TEXT COMMENT '发出时的请求体（JSON）',
    response_payload  TEXT COMMENT 'CRM返回体（JSON）',
    error_message     VARCHAR(256) COMMENT '错误原因',
    created_time      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    deleted           TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-否，1-是',
    revision          INT NOT NULL DEFAULT 0 COMMENT '数据版本',
    PRIMARY KEY (pid),
    INDEX idx_round (round_lid),
    INDEX idx_created (created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='POS消费赠券事件流水表';