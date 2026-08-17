CREATE TABLE reportcenter.dws_pay_by_type
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `type_` String COMMENT '支付类型',
    `amount` Decimal(18, 4) COMMENT '实收金额',
    `count_` Int32 COMMENT '真实收入'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, type_)
ORDER BY (mid, sid, year_, month_, day_, type_)
SETTINGS index_granularity = 8192
COMMENT '支付类型汇总表'
;
