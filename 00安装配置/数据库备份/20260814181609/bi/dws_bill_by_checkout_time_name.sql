CREATE TABLE bi.dws_bill_by_checkout_time_name
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '商户编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `checkout_time_name` String COMMENT '餐段',
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
PRIMARY KEY (mid, sid, year_, month_, day_, checkout_time_name)
ORDER BY (mid, sid, year_, month_, day_, checkout_time_name)
SETTINGS index_granularity = 8192
COMMENT '餐段分布'
;
INSERT INTO table (`version`, `mid`, `sid`, `shop_name`, `year_`, `month_`, `day_`, `season`, `checkout_time_name`, `created_time`, `report_date`, `order_count`, `person_num`, `paid_amount`, `food_amount`, `discount_amount`, `service_charge_amount`, `fraction`, `mantissa`, `cancel_amount`, `send_amount`, `platform_discount_amt`, `net_sales_amt`, `gross_sales_amt`, `returned_amt`, `free_amt`, `food_service_charge_amt`, `food_discount_amt`, `food_processing_fee_amt`, `processing_service_charge_amt`, `processing_fee_discount_amt`, `service_charge_amt`, `discount_amt`, `mantissa_amt`, `fraction_amt`, `receivable_amt`, `price_diff_amt`, `dine_in_order_cnt`, `meituan_order_cnt`, `eleme_order_cnt`, `jd_order_cnt`) VALUES ('f60b5f7a-d87d-4f13-b27a-8b68bbbb7032', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 1, 2, '全天', '2026-06-01 18:50:34', '2026-06-01 12:00:00', 9, 9, 450, 0, 0, 0, 0, 0, 0, 0, 0, 450, 450, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 450, 0, 9, 0, 0, 0), ('ae214a73-3d0a-4247-8d24-f88db74f47cd', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 2, 2, '全天', '2026-06-02 18:46:56', '2026-06-02 12:00:00', 30, 120, 2040, 0, 0, 0, 0, 0, 0, 0, 0, 2040, 2040, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2040, 0, 30, 0, 0, 0), ('ad2c512e-bd70-4d5d-8f07-c692b39d0a5d', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 3, 2, '全天', '2026-06-03 18:56:14', '2026-06-03 12:00:00', 78, 78, 1480, 0, 0, 0, 0, 0, 0, 0, 0, 1480, 1480, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1480, 0, 78, 0, 0, 0), ('2faa6bdf-1758-4fa9-a5db-efbe6f8baa8c', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 4, 2, '全天', '2026-06-04 18:52:04', '2026-06-04 12:00:00', 118, 118, 2410, 0, 0, 0, 0, 0, 0, 0, 0, 2410, 2410, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2410, 0, 118, 0, 0, 0), ('c82fec60-7522-4e52-9da5-84a200a0f9ae', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 5, 2, '全天', '2026-06-05 18:53:22', '2026-06-05 12:00:00', 7, 7, 260, 0, 0, 0, 0, 0, 0, 0, 0, 260, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 0, 7, 0, 0, 0), ('77f75278-96f3-4f1d-8559-fe87840a5ad9', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 6, 2, '全天', '2026-06-06 18:53:27', '2026-06-06 12:00:00', 19, 19, 320, 0, 0, 0, 0, 0, 0, 0, 0, 320, 320, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 320, 0, 19, 0, 0, 0), ('ad5fca68-5142-46e6-a5f7-8e7aba9af516', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 7, 2, '全天', '2026-06-07 18:59:32', '2026-06-07 12:00:00', 6, 6, 62, 0, 0, 0, 0, 0, 0, 0, 0, 62, 62, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 0, 6, 0, 0, 0), ('318d826d-193b-4b20-9976-c26c990f466e', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 8, 2, '全天', '2026-06-08 18:48:40', '2026-06-08 12:00:00', 31, 31, 554, 0, 0, 0, 0, 0, 0, 0, 0, 554, 554, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 554, 0, 31, 0, 0, 0), ('ae0f6a60-a197-498e-8580-7b834566d900', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 9, 2, '全天', '2026-06-09 18:58:15', '2026-06-09 12:00:00', 31, 31, 370.8, 0, 0, 0, 0, 0, 0, 0, 0, 446, 446, 0, 0, 0, 0, 0, 0, 0, 0, -75.2, 0, 0, 370.8, 0, 31, 0, 0, 0), ('eedf41f6-cfe0-4a5c-aa91-985e70297627', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 10, 2, '全天', '2026-06-10 18:46:54', '2026-06-10 12:00:00', 11, 11, 484, 0, 0, 0, 0, 0, 0, 0, 0, 600, 600, 0, 0, 0, 0, 0, 0, 0, 0, -116, 0, 0, 484, 0, 11, 0, 0, 0), ('d4c2acb6-b767-44d2-b721-25b31c692949', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 5, 2, '全天', '2026-06-05 18:53:22', '2026-06-05 12:00:00', 3, 3, 260, 0, 0, 0, 0, 0, 0, 0, 0, 260, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 0, 3, 0, 0, 0), ('6167c9c1-bd37-4935-bf67-8317111e31e4', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 6, 2, '全天', '2026-06-06 18:53:27', '2026-06-06 12:00:00', 2, 2, 146, 0, 0, 0, 0, 0, 0, 0, 0, 146, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 146, 0, 2, 0, 0, 0), ('deda9cfe-b718-4ddf-9938-2ecb0994a33a', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 8, 2, '全天', '2026-06-08 18:48:40', '2026-06-08 12:00:00', 4, 4, 1060, 0, 0, 0, 0, 0, 0, 0, 0, 1060, 1060, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1060, 0, 4, 0, 0, 0), ('3be6a6ed-aff9-4577-91db-057b7a66076c', 1940284000182472704, 1985885291726794753, '巨焦', 2026, 6, 3, 2, '全天', '2026-06-03 18:56:14', '2026-06-03 12:00:00', 1, 1, 130, 0, 0, 0, 0, 0, 0, 0, 0, 130, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 0, 1, 0, 0, 0);
