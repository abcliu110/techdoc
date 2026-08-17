CREATE TABLE bi.dws_crm_by_day
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '商户编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '日期',
    `op_type` String COMMENT '操作类型',
    `times` Int32 COMMENT '次数',
    `amount` Decimal(18, 4) COMMENT '金额',
    `principal` Decimal(18, 4) COMMENT '本金',
    `present` Decimal(18, 4) COMMENT '赠送金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, op_type)
ORDER BY (mid, sid, year_, month_, day_, op_type)
SETTINGS index_granularity = 8192
COMMENT '会员数据按天汇总'
;
