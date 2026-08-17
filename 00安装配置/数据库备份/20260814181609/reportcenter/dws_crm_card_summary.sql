CREATE TABLE reportcenter.dws_crm_card_summary
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64,
    `member_id` Int64 COMMENT 'lmn内部编号',
    `year_` Int32,
    `month_` Int8,
    `sum_of_save_times` Decimal(18, 4) COMMENT '累计充值次数',
    `sum_of_save` Decimal(18, 4) COMMENT '累计充值金额',
    `sum_of_consume` Decimal(18, 4) COMMENT '累计消费金额',
    `sum_of_consume_times` Decimal(18, 4) COMMENT '累计消费次数',
    `last_consume_time` DateTime COMMENT '最近交易时间',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid, member_id, year_, month_)
ORDER BY (mid, member_id, year_, month_)
SETTINGS index_granularity = 8192
COMMENT '会员卡汇总表'
;
