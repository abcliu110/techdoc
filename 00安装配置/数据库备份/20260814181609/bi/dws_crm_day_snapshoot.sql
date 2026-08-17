CREATE TABLE bi.dws_crm_day_snapshoot
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `type_` Int32 COMMENT '快照类型',
    `member_lid` Int64 COMMENT '会员号',
    `card_lid` Int64 COMMENT '卡号',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `balance` Decimal(18, 4) COMMENT '卡余额',
    `principal_balance` Decimal(18, 4) COMMENT '本金余额',
    `give_balance` Decimal(18, 4) COMMENT '赠送余额',
    `points` Decimal(18, 4) COMMENT '积分余额',
    `save_times` Int32 COMMENT '累计充值次数',
    `consume_times` Int32 COMMENT '累计消费次数',
    `save_principal` Decimal(18, 4) COMMENT '充值本金',
    `save_gift` Decimal(18, 4) COMMENT '充值赠送金额',
    `consume_principal` Decimal(18, 4) COMMENT '消费本金',
    `consume_gift` Decimal(18, 4) COMMENT '消费赠送金额',
    `credit_principal` Decimal(18, 4) COMMENT '挂账回款本金',
    `credit_gift` Decimal(18, 4) COMMENT '挂账赠送金额',
    `red_punch_principal` Decimal(18, 4) COMMENT '红冲本金',
    `red_punch_gift` Decimal(18, 4) COMMENT '红冲赠送金额',
    `blue_punch_principal` Decimal(18, 4) COMMENT '蓝补本金',
    `blue_punch_gift` Decimal(18, 4) COMMENT '蓝补赠送金额',
    `cash_back_principal` Decimal(18, 4) COMMENT '返现本金',
    `cash_back_gift` Decimal(18, 4) COMMENT '返现赠送金额',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期',
    `transfer_out_principal` Decimal(18, 4) DEFAULT 0,
    `transfer_out_gift` Decimal(18, 4) DEFAULT 0,
    `transfer_in_principal` Decimal(18, 4) DEFAULT 0,
    `transfer_in_gift` Decimal(18, 4) DEFAULT 0
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, type_, member_lid, card_lid, year_, month_, day_)
ORDER BY (mid, type_, member_lid, card_lid, year_, month_, day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日快照'
;
