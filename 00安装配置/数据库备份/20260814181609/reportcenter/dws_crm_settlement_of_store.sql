CREATE TABLE reportcenter.dws_crm_settlement_of_store
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `counter` Int8 COMMENT '标志位',
    `from_other_principal` Decimal(18, 4) COMMENT '他店储值本店消费-本金卡值',
    `from_other_gift` Decimal(18, 4) COMMENT '他店储值本店消费-赠送卡值',
    `from_other_subtotal` Decimal(18, 4) COMMENT '他店储值本店消费-小计',
    `to_other_principal` Decimal(18, 4) COMMENT '本店储值他店消费-现金卡值',
    `to_other_gift` Decimal(18, 4) COMMENT '本店储值他店消费-赠送卡值',
    `to_other_subtotal` Decimal(18, 4) COMMENT '本店储值他店消费-小计',
    `principal` Decimal(18, 4) COMMENT '结算金额-本金',
    `gift` Decimal(18, 4) COMMENT '结算金额-赠送卡值',
    `total` Decimal(18, 4) COMMENT '结算金额-合计',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, counter)
ORDER BY (mid, sid, year_, month_, day_, counter)
SETTINGS index_granularity = 8192
COMMENT '跨门店结算报表'
;
