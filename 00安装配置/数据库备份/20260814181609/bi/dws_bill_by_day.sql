CREATE TABLE bi.dws_bill_by_day
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '商户编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '日期',
    `order_count` Int32 COMMENT '账单数',
    `person_num` Int32 COMMENT '客流',
    `food_amount` Decimal(18, 4) COMMENT '流水金额',
    `discount_amount` Decimal(18, 4) COMMENT '折扣额',
    `service_charge_amount` Decimal(18, 4) COMMENT '服务费',
    `fraction` Decimal(18, 4) COMMENT '零头',
    `mantissa` Decimal(18, 4) COMMENT '尾数',
    `platform_discount_amt` Decimal(18, 4) COMMENT '平台优惠金额',
    `paid_amount` Decimal(18, 4) COMMENT '实收金额',
    `invoice_amount` Decimal(18, 4) COMMENT '发票金额',
    `jiu_xi_amount` Decimal(18, 4) COMMENT '酒席金额',
    `cancel_amount` Decimal(18, 4) COMMENT '赠送金额',
    `send_amount` Decimal(18, 4) COMMENT '退菜金额',
    `avg_person_amount` Decimal(18, 4) COMMENT '客单价',
    `avg_order_amount` Decimal(18, 4) COMMENT '单均价',
    `time_amount` Decimal(18, 4) COMMENT '计时金额',
    `receivable_amount` Decimal(18, 4) COMMENT '应收金额',
    `free_service_charge_amount` Decimal(18, 4) COMMENT '免掉的服务费',
    `revenue` Decimal(18, 4) COMMENT '实收金额',
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
PRIMARY KEY (mid, sid, year_, month_, day_)
ORDER BY (mid, sid, year_, month_, day_)
SETTINGS index_granularity = 8192
COMMENT '账单天汇总'
;
INSERT INTO table (`version`, `mid`, `sid`, `shop_name`, `year_`, `month_`, `day_`, `season`, `created_time`, `report_date`, `order_count`, `person_num`, `food_amount`, `discount_amount`, `service_charge_amount`, `fraction`, `mantissa`, `platform_discount_amt`, `paid_amount`, `invoice_amount`, `jiu_xi_amount`, `cancel_amount`, `send_amount`, `avg_person_amount`, `avg_order_amount`, `time_amount`, `receivable_amount`, `free_service_charge_amount`, `revenue`, `net_sales_amt`, `gross_sales_amt`, `returned_amt`, `free_amt`, `food_service_charge_amt`, `food_discount_amt`, `food_processing_fee_amt`, `processing_service_charge_amt`, `processing_fee_discount_amt`, `service_charge_amt`, `discount_amt`, `mantissa_amt`, `fraction_amt`, `receivable_amt`, `price_diff_amt`, `dine_in_order_cnt`, `meituan_order_cnt`, `eleme_order_cnt`, `jd_order_cnt`) VALUES ('9a883740-05dd-48df-b87c-e1b820ac3b78', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 1, 2, '2026-06-01 18:50:35', '2026-06-01 12:00:00', 9, 9, 0, 0, 0, 0, 0, 0, 450, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 450, 450, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 450, 0, 9, 0, 0, 0), ('3c0040c5-33ec-4bce-a624-292531ed5074', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 2, 2, '2026-06-02 18:46:56', '2026-06-02 12:00:00', 30, 120, 0, 0, 0, 0, 0, 0, 2040, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2040, 2040, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2040, 0, 30, 0, 0, 0), ('b8038549-58fb-4c19-8eb8-78def7e31e3a', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 3, 2, '2026-06-03 18:56:14', '2026-06-03 12:00:00', 78, 78, 0, 0, 0, 0, 0, 0, 1480, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1480, 1480, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1480, 0, 78, 0, 0, 0), ('3764536d-d8b1-4424-861e-6c495cdc3965', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 4, 2, '2026-06-04 18:52:05', '2026-06-04 12:00:00', 118, 118, 0, 0, 0, 0, 0, 0, 2410, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2410, 2410, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2410, 0, 118, 0, 0, 0), ('a4bec4b7-281f-48a6-ad53-f1bce7329704', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 5, 2, '2026-06-05 18:53:22', '2026-06-05 12:00:00', 7, 7, 0, 0, 0, 0, 0, 0, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 0, 7, 0, 0, 0), ('78a6bb51-eba5-4632-85e1-a61d92ee0810', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 6, 2, '2026-06-06 18:53:27', '2026-06-06 12:00:00', 19, 19, 0, 0, 0, 0, 0, 0, 320, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 320, 320, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 320, 0, 19, 0, 0, 0), ('3e97fee3-281f-4d73-97fc-f589264ad944', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 7, 2, '2026-06-07 18:59:32', '2026-06-07 12:00:00', 6, 6, 0, 0, 0, 0, 0, 0, 62, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 62, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 0, 6, 0, 0, 0), ('c4eae20a-0eb9-49e9-8f7b-a9d50645f5ff', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 8, 2, '2026-06-08 18:48:40', '2026-06-08 12:00:00', 31, 31, 0, 0, 0, 0, 0, 0, 554, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 554, 554, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 554, 0, 31, 0, 0, 0), ('cf83c0c5-28b6-4287-ad51-4d4bbc6d5af8', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 9, 2, '2026-06-09 18:58:15', '2026-06-09 12:00:00', 31, 31, 0, 0, 0, 0, 0, 0, 370.8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 446, 446, 0, 0, 0, -75.2, 0, 0, 0, 0, -75.2, 0, 0, 370.8, 0, 31, 0, 0, 0), ('81a7ae15-eb72-4672-aa25-e20a63d0164b', 1940284000182472704, 1942885905090105345, '东莞店', 2026, 6, 10, 2, '2026-06-10 18:46:54', '2026-06-10 12:00:00', 11, 11, 0, 0, 0, 0, 0, 0, 484, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 600, 600, 0, 0, 0, -116, 0, 0, 0, 0, -116, 0, 0, 484, 0, 11, 0, 0, 0), ('2c5115f2-cd9c-4ce4-9db6-1cd2505267b7', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 5, 2, '2026-06-05 18:53:22', '2026-06-05 12:00:00', 3, 3, 0, 0, 0, 0, 0, 0, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 260, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 260, 0, 3, 0, 0, 0), ('5c0a3d64-ac3d-47b6-a73c-18b64b72749e', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 6, 2, '2026-06-06 18:53:27', '2026-06-06 12:00:00', 2, 2, 0, 0, 0, 0, 0, 0, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 146, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 146, 0, 2, 0, 0, 0), ('17b77cb9-6db7-4e30-93bd-21492eed8f91', 1940284000182472704, 1979737429467095041, '中山市', 2026, 6, 8, 2, '2026-06-08 18:48:40', '2026-06-08 12:00:00', 4, 4, 0, 0, 0, 0, 0, 0, 1060, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1060, 1060, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1060, 0, 4, 0, 0, 0), ('39c5fbc3-2b99-4a33-bf4b-2cf3d658411f', 1940284000182472704, 1985885291726794753, '巨焦', 2026, 6, 3, 2, '2026-06-03 18:56:14', '2026-06-03 12:00:00', 1, 1, 0, 0, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 130, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 130, 0, 1, 0, 0, 0);
