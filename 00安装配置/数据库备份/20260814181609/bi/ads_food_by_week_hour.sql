CREATE TABLE bi.ads_food_by_week_hour
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `week_` Int8 COMMENT '周',
    `hour_` Int8 COMMENT '小时',
    `order_number` Decimal(18, 4) COMMENT '下单数量',
    `food_number` Decimal(18, 4) COMMENT '流水数量',
    `send_number` Decimal(18, 4) COMMENT '赠送数量',
    `unit_adjutant_number` Decimal(18, 4) COMMENT '辅助数量',
    `food_amount` Decimal(18, 4) COMMENT '流水金额',
    `service_charge_amount` Decimal(18, 4) COMMENT '服务费',
    `discount_amount` Decimal(18, 4) COMMENT '折扣额',
    `processing_fee` Decimal(18, 4) COMMENT '加工费',
    `promotion_amount` Decimal(18, 4) COMMENT '优惠金额',
    `paid_amount` Decimal(18, 4) COMMENT '实际金额',
    `cancel_number` Decimal(18, 4) COMMENT '退菜数量',
    `cancel_amount` Decimal(24, 6) COMMENT '退菜金额',
    `send_amount` Decimal(24, 6) COMMENT '赠送金额',
    `processing_fee_service` Decimal(24, 6) COMMENT '加工服务费',
    `processing_fee_discount` Decimal(24, 6) COMMENT '加工折扣额',
    `actual_income` Decimal(18, 4) COMMENT '实收金额',
    `virtual_income` Decimal(18, 4) COMMENT '虚收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, week_, hour_)
ORDER BY (mid, sid, year_, month_, week_, hour_)
SETTINGS index_granularity = 8192
COMMENT '每周各个小时汇总'
;
