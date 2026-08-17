CREATE TABLE reportcenter.dws_depart_sale_profit
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` String COMMENT '集团编号',
    `sid` String COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `report_date` DateTime COMMENT '营业日期',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `year` Int32 COMMENT '年',
    `month` Int32 COMMENT '月',
    `day` Int32 COMMENT '日',
    `organ_lid` Int64 COMMENT '组织lid',
    `organ_name` String COMMENT '组织名称',
    `sale_volume` Decimal(18, 4) COMMENT '销售数量',
    `sale_price` Decimal(18, 4) COMMENT '平均售价',
    `sale_amount` Decimal(18, 4) COMMENT '销售金额',
    `theory_cost` Decimal(18, 4) COMMENT '理论成本',
    `actual_cost` Decimal(18, 4) COMMENT '实际成本',
    `other_cost` Decimal(18, 4) COMMENT '其他成本',
    `diff_cost` Decimal(18, 4) COMMENT '成本差异',
    `bill_type` String COMMENT '账单类型'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year, month, day, organ_lid)
ORDER BY (mid, sid, year, month, day, organ_lid)
SETTINGS index_granularity = 8192
COMMENT '部门销售利润统计'
;
