CREATE TABLE bi.dws_crm_activity
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `card_type_lid` Int64 COMMENT '会员卡类型',
    `card_id` String COMMENT '会员卡编号',
    `type_` Int32 COMMENT '类型',
    `number` Int32 COMMENT '次数',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, year_, month_, day_, card_type_lid, card_id, type_)
ORDER BY (mid, year_, month_, day_, card_type_lid, card_id, type_)
SETTINGS index_granularity = 8192
COMMENT '会员活跃度'
;
