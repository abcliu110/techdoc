CREATE TABLE bi.dwt_daily_by_day
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `op` String COMMENT '操作类型',
    `ts_ms` Int64 COMMENT '更新时间',
    `mid` Int64 COMMENT '商户编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `key_` Int32 COMMENT '统计指标',
    `report_date` DateTime COMMENT '日期',
    `season` Int8 COMMENT '季度',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `value` Decimal(18, 4) COMMENT '统计值'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, key_)
ORDER BY (mid, sid, year_, month_, day_, key_)
SETTINGS index_granularity = 8192
COMMENT '营业日报'
;
