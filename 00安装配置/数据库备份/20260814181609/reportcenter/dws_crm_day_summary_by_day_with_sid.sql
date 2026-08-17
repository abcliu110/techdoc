CREATE TABLE reportcenter.dws_crm_day_summary_by_day_with_sid
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `type_` Int32 COMMENT '快照类型',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `begin_balance` Decimal(18, 4) COMMENT '卡余额',
    `begin_principal_balance` Decimal(18, 4) COMMENT '本金余额',
    `begin_give_balance` Decimal(18, 4) COMMENT '赠送余额',
    `begin_points` Decimal(18, 4) COMMENT '积分余额',
    `end_balance` Decimal(18, 4) COMMENT '卡余额',
    `end_principal_balance` Decimal(18, 4) COMMENT '本金余额',
    `end_give_balance` Decimal(18, 4) COMMENT '赠送余额',
    `end_points` Decimal(18, 4) COMMENT '积分余额',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid, sid, type_, year_, month_, day_)
ORDER BY (mid, sid, type_, year_, month_, day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日汇总'
;
