CREATE TABLE bi.dws_crm_summary
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `card_type_lid` Int64 COMMENT '会员类型编号',
    `shop_name` String COMMENT '门店名称',
    `type_` Int32 COMMENT '类型',
    `person` Int32 COMMENT '会员总数',
    `principal_accruing_save` Decimal(18, 4) COMMENT '累计充值本金',
    `present_accruing_save` Decimal(18, 4) COMMENT '累计充值赠送',
    `principal_accruing_consume` Decimal(18, 4) COMMENT '累计消费本金',
    `present_accruing_consume` Decimal(18, 4) COMMENT '累计消费赠送',
    `point_accruing` Decimal(18, 4) COMMENT '累计积分',
    `principal_balance` Decimal(18, 4) COMMENT '本金余额',
    `present_balance` Decimal(18, 4) COMMENT '赠送余额',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid, card_type_lid, type_)
ORDER BY (mid, card_type_lid, type_)
SETTINGS index_granularity = 8192
COMMENT '会员汇总表'
;
