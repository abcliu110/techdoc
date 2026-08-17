CREATE TABLE reportcenter.dws_bill_by_consumption
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '商户编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `price` Int32 COMMENT '客单价',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '日期',
    `order_count` Int32 COMMENT '账单数',
    `person_num` Int32 COMMENT '客流',
    `paid_amount` Decimal(18, 4) COMMENT '实收金额',
    `food_amount` Decimal(18, 4) DEFAULT 0 COMMENT '流水金额',
    `discount_amount` Decimal(18, 4) DEFAULT 0 COMMENT '折扣额',
    `service_charge_amount` Decimal(18, 4) DEFAULT 0 COMMENT '服务费',
    `fraction` Decimal(18, 4) DEFAULT 0 COMMENT '零头',
    `mantissa` Decimal(18, 4) DEFAULT 0 COMMENT '尾数',
    `cancel_amount` Decimal(18, 4) DEFAULT 0 COMMENT '退菜金额',
    `send_amount` Decimal(18, 4) DEFAULT 0 COMMENT '赠送金额',
    `platform_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',
    `net_sales_amt` Decimal(18, 4) DEFAULT 0 COMMENT '净销售额',
    `gross_sales_amt` Decimal(18, 4) DEFAULT 0 COMMENT '毛销售额',
    `returned_amt` Decimal(18, 4) DEFAULT 0 COMMENT '退菜金额',
    `free_amt` Decimal(18, 4) DEFAULT 0 COMMENT '赠送金额',
    `food_service_charge_amt` Decimal(18, 4) DEFAULT 0 COMMENT '食品服务费',
    `food_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '食品折扣额',
    `food_processing_fee_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工费',
    `processing_service_charge_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工服务费',
    `processing_fee_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工费折扣额',
    `service_charge_amt` Decimal(18, 4) DEFAULT 0 COMMENT '服务费',
    `discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '折扣额',
    `mantissa_amt` Decimal(18, 4) DEFAULT 0 COMMENT '零头',
    `fraction_amt` Decimal(18, 4) DEFAULT 0 COMMENT '尾数',
    `receivable_amt` Decimal(18, 4) DEFAULT 0 COMMENT '应收金额(菜品)',
    `price_diff_amt` Decimal(18, 4) DEFAULT 0 COMMENT '价差金额',
    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',
    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',
    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',
    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, price)
ORDER BY (mid, sid, year_, month_, day_, price)
SETTINGS index_granularity = 8192
COMMENT '客单价'
;
