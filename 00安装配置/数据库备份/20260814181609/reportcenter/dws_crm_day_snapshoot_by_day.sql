CREATE TABLE reportcenter.dws_crm_day_snapshoot_by_day
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
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid, type_, member_lid, card_lid, year_, month_, day_)
ORDER BY (mid, type_, member_lid, card_lid, year_, month_, day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日快照'
;
