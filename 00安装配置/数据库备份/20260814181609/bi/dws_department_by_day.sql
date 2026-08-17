CREATE TABLE bi.dws_department_by_day
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
    `department` String COMMENT '菜品大类',
    `source` Int32 COMMENT '数据来源',
    `counter` Int32 COMMENT '计件数量',
    `order_number` Decimal(18, 4) COMMENT '下单数量',
    `food_number` Decimal(18, 4) COMMENT '流水数量',
    `send_number` Decimal(18, 4) COMMENT '赠送数量',
    `unit_adjutant_number` Decimal(18, 4) COMMENT '辅助数量',
    `food_amount` Decimal(18, 4) COMMENT '流水金额',
    `service_charge_amount` Decimal(18, 4) COMMENT '服务费',
    `discount_amount` Decimal(18, 4) COMMENT '折扣额',
    `processing_fee` Decimal(18, 4) COMMENT '加工费',
    `promotion_amount` Decimal(18, 4) COMMENT '优惠金额',
    `paid_amount` Decimal(18, 4) COMMENT '实收金额',
    `cancel_amount` Decimal(18, 4) COMMENT '赠送金额',
    `send_amount` Decimal(18, 4) COMMENT '退菜金额',
    `cancel_number` Decimal(18, 4) COMMENT '退菜数量',
    `free_service_charge_amount` Decimal(18, 4) COMMENT '免掉的服务费',
    `revenue` Decimal(18, 4) COMMENT '预估收入',
    `platform_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '平台优惠金额',
    `total_ordered_qty` Decimal(18, 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',
    `returned_qty` Decimal(18, 4) DEFAULT 0 COMMENT '退菜数量(负数)',
    `free_qty` Decimal(18, 4) DEFAULT 0 COMMENT '赠送数量(负数)',
    `net_sales_qty` Decimal(18, 4) DEFAULT 0 COMMENT '净售数量',
    `gross_sales_amt` Decimal(18, 4) DEFAULT 0 COMMENT '毛销售额',
    `net_sales_amt` Decimal(18, 4) DEFAULT 0 COMMENT '净销售额',
    `returned_amt` Decimal(18, 4) DEFAULT 0 COMMENT '退菜金额(负数)',
    `free_amt` Decimal(18, 4) DEFAULT 0 COMMENT '赠送金额(负数)',
    `food_service_charge_amt` Decimal(18, 4) DEFAULT 0 COMMENT '食品服务费',
    `food_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '食品折扣额(负数)',
    `food_processing_fee_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工费',
    `processing_service_charge_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工服务费',
    `processing_fee_discount_amt` Decimal(18, 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',
    `receivable_amt` Decimal(18, 4) DEFAULT 0 COMMENT '应收金额',
    `price_diff_amt` Decimal(18, 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_, department, source)
ORDER BY (mid, sid, year_, month_, day_, department, source)
SETTINGS index_granularity = 8192
COMMENT '部门日销售汇总'
;
