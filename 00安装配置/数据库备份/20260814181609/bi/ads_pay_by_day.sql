CREATE TABLE bi.ads_pay_by_day
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
    `name` String COMMENT '支付方式名称',
    `type_` String COMMENT '支付方式类型',
    `count_` Int32 COMMENT '支付笔数',
    `amount` Decimal(18, 4) COMMENT '支付金额',
    `give_amount` Decimal(18, 4) COMMENT '赠送金额',
    `actual_income` Decimal(18, 4) COMMENT '实收金额',
    `virtual_income` Decimal(18, 4) COMMENT '虚收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, name, type_)
ORDER BY (mid, sid, year_, month_, day_, name, type_)
SETTINGS index_granularity = 8192
COMMENT '支付名称类型汇总表'
;
