CREATE TABLE reportcenter.dws_crm_sex
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `card_type_lid` Int64 COMMENT '会员类型编号',
    `birthday` DateTime COMMENT '生日',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `male` Int32 COMMENT '男性',
    `female` Int32 COMMENT '女性',
    `unknown_` Int32 COMMENT '未知',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid, card_type_lid, birthday)
ORDER BY (mid, card_type_lid, birthday)
SETTINGS index_granularity = 8192
COMMENT '会员性别分析表'
;
