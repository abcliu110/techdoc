-- reportcenter.dws_bill_by_area_name definition

CREATE TABLE reportcenter.dws_bill_by_area_name
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `area_name` String COMMENT '区域名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `order_count` Int32 COMMENT '账单数',

    `person_num` Int32 COMMENT '客流',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 area_name)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 area_name)
SETTINGS index_granularity = 8192
COMMENT '桌台区域分布';


-- reportcenter.dws_bill_by_checkout_time_name definition

CREATE TABLE reportcenter.dws_bill_by_checkout_time_name
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

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 checkout_time_name)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 checkout_time_name)
SETTINGS index_granularity = 8192
COMMENT '餐段分布';


-- reportcenter.dws_bill_by_consumption definition

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

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 price)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 price)
SETTINGS index_granularity = 8192
COMMENT '客单价';


-- reportcenter.dws_bill_by_day definition

CREATE TABLE reportcenter.dws_bill_by_day
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

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `fraction` Decimal(18,
 4) COMMENT '零头',

    `mantissa` Decimal(18,
 4) COMMENT '尾数',

    `platform_discount_amt` Decimal(18,
 4) COMMENT '平台优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `invoice_amount` Decimal(18,
 4) COMMENT '发票金额',

    `jiu_xi_amount` Decimal(18,
 4) COMMENT '酒席金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `send_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `avg_person_amount` Decimal(18,
 4) COMMENT '客单价',

    `avg_order_amount` Decimal(18,
 4) COMMENT '单均价',

    `time_amount` Decimal(18,
 4) COMMENT '计时金额',

    `receivable_amount` Decimal(18,
 4) COMMENT '应收金额',

    `free_service_charge_amount` Decimal(18,
 4) COMMENT '免掉的服务费',

    `revenue` Decimal(18,
 4) COMMENT '实收金额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '账单天汇总';


-- reportcenter.dws_bill_by_duration definition

CREATE TABLE reportcenter.dws_bill_by_duration
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `duration` Int64 COMMENT '消费时长（分钟）',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `order_count` Int32 COMMENT '账单数',

    `person_num` Int32 COMMENT '客流',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 duration)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 duration)
SETTINGS index_granularity = 8192
COMMENT '消费时长统计';


-- reportcenter.dws_bill_by_hour definition

CREATE TABLE reportcenter.dws_bill_by_hour
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `hour_` Int8 COMMENT '时',

    `season` Int8 COMMENT '季度',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `order_count` Int32 COMMENT '账单数',

    `person_num` Int32 COMMENT '客流',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 hour_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 hour_)
SETTINGS index_granularity = 8192
COMMENT '账单小时汇总';


-- reportcenter.dws_bill_by_order_sub_type definition

CREATE TABLE reportcenter.dws_bill_by_order_sub_type
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `order_sub_type` String COMMENT '时',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `order_count` Int32 COMMENT '账单数',

    `person_num` Int32 COMMENT '客流',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 order_sub_type)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 order_sub_type)
SETTINGS index_granularity = 8192
COMMENT '账单类型分布';


-- reportcenter.dws_bill_by_price definition

CREATE TABLE reportcenter.dws_bill_by_price
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `price` Int64 COMMENT '单均价',

    `season` Int8 COMMENT '季度',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `order_count` Int32 COMMENT '账单数',

    `person_num` Int32 COMMENT '客流',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '流水金额',

    `discount_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `fraction` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `mantissa` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `cancel_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额（平台费用分摊）',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额',

    `service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '服务费',

    `discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '折扣额',

    `mantissa_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '零头',

    `fraction_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '尾数',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额(菜品)',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额',

    `dine_in_order_cnt` Int32 DEFAULT 0 COMMENT '堂食订单数',

    `meituan_order_cnt` Int32 DEFAULT 0 COMMENT '美团订单数',

    `eleme_order_cnt` Int32 DEFAULT 0 COMMENT '饿了么订单数',

    `jd_order_cnt` Int32 DEFAULT 0 COMMENT '京东外卖订单数'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 price)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 price)
SETTINGS index_granularity = 8192
COMMENT '单均价';


-- reportcenter.dws_crm_activity definition

CREATE TABLE reportcenter.dws_crm_activity
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `card_type_lid` Int64 COMMENT '会员卡类型',

    `card_id` String COMMENT '会员卡编号',

    `type_` Int32 COMMENT '类型',

    `number` Int32 COMMENT '次数',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 year_,
 month_,
 day_,
 card_type_lid,
 card_id,
 type_)
ORDER BY (mid,
 year_,
 month_,
 day_,
 card_type_lid,
 card_id,
 type_)
SETTINGS index_granularity = 8192
COMMENT '会员活跃度';


-- reportcenter.dws_crm_by_day definition

CREATE TABLE reportcenter.dws_crm_by_day
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

    `op_type` String COMMENT '操作类型',

    `times` Int32 COMMENT '次数',

    `amount` Decimal(18,
 4) COMMENT '金额',

    `principal` Decimal(18,
 4) COMMENT '本金',

    `present` Decimal(18,
 4) COMMENT '赠送金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 op_type)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 op_type)
SETTINGS index_granularity = 8192
COMMENT '会员数据按天汇总';


-- reportcenter.dws_crm_card_summary definition

CREATE TABLE reportcenter.dws_crm_card_summary
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64,

    `member_id` Int64 COMMENT 'lmn内部编号',

    `year_` Int32,

    `month_` Int8,

    `sum_of_save_times` Decimal(18,
 4) COMMENT '累计充值次数',

    `sum_of_save` Decimal(18,
 4) COMMENT '累计充值金额',

    `sum_of_consume` Decimal(18,
 4) COMMENT '累计消费金额',

    `sum_of_consume_times` Decimal(18,
 4) COMMENT '累计消费次数',

    `last_consume_time` DateTime COMMENT '最近交易时间',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 member_id,
 year_,
 month_)
ORDER BY (mid,
 member_id,
 year_,
 month_)
SETTINGS index_granularity = 8192
COMMENT '会员卡汇总表';


-- reportcenter.dws_crm_day_snapshoot definition

CREATE TABLE reportcenter.dws_crm_day_snapshoot
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `type_` Int32 COMMENT '快照类型',

    `member_lid` Int64 COMMENT '会员号',

    `card_lid` Int64 COMMENT '卡号',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `balance` Decimal(18,
 4) COMMENT '卡余额',

    `principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `points` Decimal(18,
 4) COMMENT '积分余额',

    `save_times` Int32 COMMENT '累计充值次数',

    `consume_times` Int32 COMMENT '累计消费次数',

    `save_principal` Decimal(18,
 4) COMMENT '充值本金',

    `save_gift` Decimal(18,
 4) COMMENT '充值赠送金额',

    `consume_principal` Decimal(18,
 4) COMMENT '消费本金',

    `consume_gift` Decimal(18,
 4) COMMENT '消费赠送金额',

    `credit_principal` Decimal(18,
 4) COMMENT '挂账回款本金',

    `credit_gift` Decimal(18,
 4) COMMENT '挂账赠送金额',

    `red_punch_principal` Decimal(18,
 4) COMMENT '红冲本金',

    `red_punch_gift` Decimal(18,
 4) COMMENT '红冲赠送金额',

    `blue_punch_principal` Decimal(18,
 4) COMMENT '蓝补本金',

    `blue_punch_gift` Decimal(18,
 4) COMMENT '蓝补赠送金额',

    `cash_back_principal` Decimal(18,
 4) COMMENT '返现本金',

    `cash_back_gift` Decimal(18,
 4) COMMENT '返现赠送金额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `transfer_out_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_out_gift` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_gift` Decimal(18,
 4) DEFAULT 0
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 type_,
 member_lid,
 card_lid,
 year_,
 month_,
 day_)
ORDER BY (mid,
 type_,
 member_lid,
 card_lid,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日快照';


-- reportcenter.dws_crm_day_snapshoot_by_day definition

CREATE TABLE reportcenter.dws_crm_day_snapshoot_by_day
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `type_` Int32 COMMENT '快照类型',

    `member_lid` Int64 COMMENT '会员号',

    `card_lid` Int64 COMMENT '卡号',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `balance` Decimal(18,
 4) COMMENT '卡余额',

    `principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `points` Decimal(18,
 4) COMMENT '积分余额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 type_,
 member_lid,
 card_lid,
 year_,
 month_,
 day_)
ORDER BY (mid,
 type_,
 member_lid,
 card_lid,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日快照';


-- reportcenter.dws_crm_day_summary definition

CREATE TABLE reportcenter.dws_crm_day_summary
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `type_` Int32 COMMENT '快照类型',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `begin_balance` Decimal(18,
 4) COMMENT '卡余额',

    `begin_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `begin_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `begin_points` Decimal(18,
 4) COMMENT '积分余额',

    `end_balance` Decimal(18,
 4) COMMENT '卡余额',

    `end_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `end_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `end_points` Decimal(18,
 4) COMMENT '积分余额',

    `save_times` Int32 COMMENT '累计充值次数',

    `consume_times` Int32 COMMENT '累计消费次数',

    `save_principal` Decimal(18,
 4) COMMENT '充值本金',

    `save_gift` Decimal(18,
 4) COMMENT '充值赠送金额',

    `consume_principal` Decimal(18,
 4) COMMENT '消费本金',

    `consume_gift` Decimal(18,
 4) COMMENT '消费赠送金额',

    `credit_principal` Decimal(18,
 4) COMMENT '挂账回款本金',

    `credit_gift` Decimal(18,
 4) COMMENT '挂账赠送金额',

    `red_punch_principal` Decimal(18,
 4) COMMENT '红冲本金',

    `red_punch_gift` Decimal(18,
 4) COMMENT '红冲赠送金额',

    `blue_punch_principal` Decimal(18,
 4) COMMENT '蓝补本金',

    `blue_punch_gift` Decimal(18,
 4) COMMENT '蓝补赠送金额',

    `cash_back_principal` Decimal(18,
 4) COMMENT '返现本金',

    `cash_back_gift` Decimal(18,
 4) COMMENT '返现赠送金额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `transfer_out_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_out_gift` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_gift` Decimal(18,
 4) DEFAULT 0
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 type_,
 year_,
 month_,
 day_)
ORDER BY (mid,
 type_,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日汇总';


-- reportcenter.dws_crm_day_summary_by_day_with_sid definition

CREATE TABLE reportcenter.dws_crm_day_summary_by_day_with_sid
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `type_` Int32 COMMENT '快照类型',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `begin_balance` Decimal(18,
 4) COMMENT '卡余额',

    `begin_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `begin_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `begin_points` Decimal(18,
 4) COMMENT '积分余额',

    `end_balance` Decimal(18,
 4) COMMENT '卡余额',

    `end_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `end_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `end_points` Decimal(18,
 4) COMMENT '积分余额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 sid,
 type_,
 year_,
 month_,
 day_)
ORDER BY (mid,
 sid,
 type_,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日汇总';


-- reportcenter.dws_crm_day_summary_with_sid definition

CREATE TABLE reportcenter.dws_crm_day_summary_with_sid
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `type_` Int32 COMMENT '快照类型',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `begin_balance` Decimal(18,
 4) COMMENT '卡余额',

    `begin_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `begin_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `begin_points` Decimal(18,
 4) COMMENT '积分余额',

    `end_balance` Decimal(18,
 4) COMMENT '卡余额',

    `end_principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `end_give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `end_points` Decimal(18,
 4) COMMENT '积分余额',

    `save_times` Int32 COMMENT '累计充值次数',

    `consume_times` Int32 COMMENT '累计消费次数',

    `save_principal` Decimal(18,
 4) COMMENT '充值本金',

    `save_gift` Decimal(18,
 4) COMMENT '充值赠送金额',

    `consume_principal` Decimal(18,
 4) COMMENT '消费本金',

    `consume_gift` Decimal(18,
 4) COMMENT '消费赠送金额',

    `credit_principal` Decimal(18,
 4) COMMENT '挂账回款本金',

    `credit_gift` Decimal(18,
 4) COMMENT '挂账赠送金额',

    `red_punch_principal` Decimal(18,
 4) COMMENT '红冲本金',

    `red_punch_gift` Decimal(18,
 4) COMMENT '红冲赠送金额',

    `blue_punch_principal` Decimal(18,
 4) COMMENT '蓝补本金',

    `blue_punch_gift` Decimal(18,
 4) COMMENT '蓝补赠送金额',

    `cash_back_principal` Decimal(18,
 4) COMMENT '返现本金',

    `cash_back_gift` Decimal(18,
 4) COMMENT '返现赠送金额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `transfer_out_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_out_gift` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_principal` Decimal(18,
 4) DEFAULT 0,

    `transfer_in_gift` Decimal(18,
 4) DEFAULT 0
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 type_,
 year_,
 month_,
 day_)
ORDER BY (mid,
 sid,
 type_,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员余额每日汇总';


-- reportcenter.dws_crm_income_of_store definition

CREATE TABLE reportcenter.dws_crm_income_of_store
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `consume_times` Decimal(18,
 4) COMMENT '消费笔数',

    `consume_principal` Decimal(18,
 4) COMMENT '消费本金',

    `consume_present` Decimal(18,
 4) COMMENT '消费赠送',

    `charge_times` Decimal(18,
 4) COMMENT '储值笔数',

    `charge_principal` Decimal(18,
 4) COMMENT '储值本金',

    `charge_present` Decimal(18,
 4) COMMENT '储值赠送',

    `principal` Decimal(18,
 4) COMMENT '本金收支',

    `present` Decimal(18,
 4) COMMENT '赠送收支',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '会员连锁门店收支报表';


-- reportcenter.dws_crm_member_join_by_day definition

CREATE TABLE reportcenter.dws_crm_member_join_by_day
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

    `counter` Int64 COMMENT '新增数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_)
SETTINGS index_granularity = 8192
COMMENT '每日新增会员';


-- reportcenter.dws_crm_settlement_of_store definition

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

    `from_other_principal` Decimal(18,
 4) COMMENT '他店储值本店消费-本金卡值',

    `from_other_gift` Decimal(18,
 4) COMMENT '他店储值本店消费-赠送卡值',

    `from_other_subtotal` Decimal(18,
 4) COMMENT '他店储值本店消费-小计',

    `to_other_principal` Decimal(18,
 4) COMMENT '本店储值他店消费-现金卡值',

    `to_other_gift` Decimal(18,
 4) COMMENT '本店储值他店消费-赠送卡值',

    `to_other_subtotal` Decimal(18,
 4) COMMENT '本店储值他店消费-小计',

    `principal` Decimal(18,
 4) COMMENT '结算金额-本金',

    `gift` Decimal(18,
 4) COMMENT '结算金额-赠送卡值',

    `total` Decimal(18,
 4) COMMENT '结算金额-合计',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 counter)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 counter)
SETTINGS index_granularity = 8192
COMMENT '跨门店结算报表';


-- reportcenter.dws_crm_sex definition

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
PRIMARY KEY (mid,
 card_type_lid,
 birthday)
ORDER BY (mid,
 card_type_lid,
 birthday)
SETTINGS index_granularity = 8192
COMMENT '会员性别分析表';


-- reportcenter.dws_crm_summary definition

CREATE TABLE reportcenter.dws_crm_summary
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `card_type_lid` Int64 COMMENT '会员类型编号',

    `shop_name` String COMMENT '门店名称',

    `type_` Int32 COMMENT '类型',

    `person` Int32 COMMENT '会员总数',

    `principal_accruing_save` Decimal(18,
 4) COMMENT '累计充值本金',

    `present_accruing_save` Decimal(18,
 4) COMMENT '累计充值赠送',

    `principal_accruing_consume` Decimal(18,
 4) COMMENT '累计消费本金',

    `present_accruing_consume` Decimal(18,
 4) COMMENT '累计消费赠送',

    `point_accruing` Decimal(18,
 4) COMMENT '累计积分',

    `principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `present_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 card_type_lid,
 type_)
ORDER BY (mid,
 card_type_lid,
 type_)
SETTINGS index_granularity = 8192
COMMENT '会员汇总表';


-- reportcenter.dws_depart_sale_profit definition

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

    `sale_volume` Decimal(18,
 4) COMMENT '销售数量',

    `sale_price` Decimal(18,
 4) COMMENT '平均售价',

    `sale_amount` Decimal(18,
 4) COMMENT '销售金额',

    `theory_cost` Decimal(18,
 4) COMMENT '理论成本',

    `actual_cost` Decimal(18,
 4) COMMENT '实际成本',

    `other_cost` Decimal(18,
 4) COMMENT '其他成本',

    `diff_cost` Decimal(18,
 4) COMMENT '成本差异',

    `bill_type` String COMMENT '账单类型'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year,
 month,
 day,
 organ_lid)
ORDER BY (mid,
 sid,
 year,
 month,
 day,
 organ_lid)
SETTINGS index_granularity = 8192
COMMENT '部门销售利润统计';


-- reportcenter.dws_department_by_day definition

CREATE TABLE reportcenter.dws_department_by_day
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

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `send_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `free_service_charge_amount` Decimal(18,
 4) COMMENT '免掉的服务费',

    `revenue` Decimal(18,
 4) COMMENT '预估收入',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 department,
 source)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 department,
 source)
SETTINGS index_granularity = 8192
COMMENT '部门日销售汇总';


-- reportcenter.dws_food_by_cook definition

CREATE TABLE reportcenter.dws_food_by_cook
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

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `cook` String COMMENT '厨师',

    `cook_duration` Int64 COMMENT '制作时长（毫秒）',

    `counter` Int8 COMMENT '计数器',

    `order_number` Decimal(18,
 4) COMMENT '点菜数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_discount_rate` Decimal(18,
 4) COMMENT '折扣',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit,
 cook)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit,
 cook)
SETTINGS index_granularity = 8192
COMMENT '厨师统计';


-- reportcenter.dws_food_by_day definition

CREATE TABLE reportcenter.dws_food_by_day
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

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `food_pro_price` Decimal(18,
 4) COMMENT '售价',

    `food_org_price` Decimal(18,
 4) COMMENT '原价',

    `counter` Int32 COMMENT '计件数量',

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `cancel_amount` Decimal(24,
 6) COMMENT '退菜金额',

    `send_amount` Decimal(24,
 6) COMMENT '赠送金额',

    `processing_fee_service` Decimal(24,
 6) COMMENT '加工服务费',

    `processing_fee_discount` Decimal(24,
 6) COMMENT '加工折扣额',

    `food_id` String COMMENT '菜品编号',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
SETTINGS index_granularity = 8192
COMMENT '菜品日销售汇总';


-- reportcenter.dws_food_by_day_crm definition

CREATE TABLE reportcenter.dws_food_by_day_crm
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

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `food_pro_price` Decimal(18,
 4) COMMENT '售价',

    `food_org_price` Decimal(18,
 4) COMMENT '原价',

    `counter` Int32 COMMENT '计件数量',

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
SETTINGS index_granularity = 8192
COMMENT '会员菜品日销售汇总';


-- reportcenter.dws_food_by_day_mid definition

CREATE TABLE reportcenter.dws_food_by_day_mid
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

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `food_pro_price` Decimal(18,
 4) COMMENT '售价',

    `food_org_price` Decimal(18,
 4) COMMENT '原价',

    `counter` Int32 COMMENT '计件数量',

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `cancel_amount` Decimal(24,
 6) COMMENT '退菜金额',

    `send_amount` Decimal(24,
 6) COMMENT '赠送金额',

    `processing_fee_service` Decimal(24,
 6) COMMENT '加工服务费',

    `processing_fee_discount` Decimal(24,
 6) COMMENT '加工折扣额',

    `food_id` String COMMENT '菜品编号',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_name,
 food_unit)
SETTINGS index_granularity = 8192
COMMENT '菜品日销售汇总';


-- reportcenter.dws_food_category_by_day definition

CREATE TABLE reportcenter.dws_food_category_by_day
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

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `counter` Int32 COMMENT '计件数量',

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `send_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_category_name)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_category_name)
SETTINGS index_granularity = 8192
COMMENT '菜小类日销售汇总';


-- reportcenter.dws_food_super_category_by_day definition

CREATE TABLE reportcenter.dws_food_super_category_by_day
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

    `food_super_category_name` String COMMENT '菜品大类',

    `counter` Int32 COMMENT '计件数量',

    `order_number` Decimal(18,
 4) COMMENT '下单数量',

    `food_number` Decimal(18,
 4) COMMENT '流水数量',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `unit_adjutant_number` Decimal(18,
 4) COMMENT '辅助数量',

    `food_amount` Decimal(18,
 4) COMMENT '流水金额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `send_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `platform_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '平台优惠金额',

    `total_ordered_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售数量/总下单数量',

    `returned_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜数量(负数)',

    `free_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送数量(负数)',

    `net_sales_qty` Decimal(18,
 4) DEFAULT 0 COMMENT '净售数量',

    `gross_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '毛销售额',

    `net_sales_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '净销售额',

    `returned_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '退菜金额(负数)',

    `free_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '赠送金额(负数)',

    `food_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品服务费',

    `food_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '食品折扣额(负数)',

    `food_processing_fee_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费',

    `processing_service_charge_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工服务费',

    `processing_fee_discount_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '加工费折扣额(负数)',

    `receivable_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '应收金额',

    `price_diff_amt` Decimal(18,
 4) DEFAULT 0 COMMENT '价差金额(负数)：(实际售价-原价)×数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 food_super_category_name)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 food_super_category_name)
SETTINGS index_granularity = 8192
COMMENT '菜大类日销售汇总';


-- reportcenter.dws_pay_by_day definition

CREATE TABLE reportcenter.dws_pay_by_day
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

    `name` String COMMENT '支付方式名称',

    `type_` String COMMENT '支付方式类型',

    `false_revenue` Decimal(18,
 4) COMMENT '虚收金额',

    `amount` Decimal(18,
 4) COMMENT '实收金额',

    `count_` Int32 COMMENT '真实收入',

    `give_ammount` Decimal(18,
 4) COMMENT '赠送金额',

    `give_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `revenue` Decimal(18,
 4) COMMENT '实收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 name,
 type_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 name,
 type_)
SETTINGS index_granularity = 8192
COMMENT '支付名称类型汇总表';


-- reportcenter.dws_pay_by_name definition

CREATE TABLE reportcenter.dws_pay_by_name
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

    `name` String COMMENT '支付方式名称',

    `amount` Decimal(18,
 4) COMMENT '实收金额',

    `count_` Int32 COMMENT '真实收入',

    `mb_amount` Decimal(18,
 4) COMMENT '会员卡消费',

    `mb_false_amount` Decimal(18,
 4) COMMENT '会员卡赠送消费',

    `revenue` Decimal(18,
 4) COMMENT '实收金额',

    `false_revenue` Decimal(18,
 4) COMMENT '虚收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 name)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 name)
SETTINGS index_granularity = 8192
COMMENT '支付名称汇总表';


-- reportcenter.dws_pay_by_type definition

CREATE TABLE reportcenter.dws_pay_by_type
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

    `type_` String COMMENT '支付类型',

    `amount` Decimal(18,
 4) COMMENT '实收金额',

    `count_` Int32 COMMENT '真实收入'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 type_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 type_)
SETTINGS index_granularity = 8192
COMMENT '支付类型汇总表';


-- reportcenter.dws_product_sale_profit definition

CREATE TABLE reportcenter.dws_product_sale_profit
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` String COMMENT '集团编号',

    `sid` String COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `report_date` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int32 COMMENT '月',

    `day` Int32 COMMENT '日',

    `organ_lid` Int64 COMMENT '组织lid',

    `organ_name` String COMMENT '组织名称',

    `product_id` String COMMENT '商品id',

    `product_lid` Int64 COMMENT '商品lid',

    `product_name` String COMMENT '商品名称',

    `product_unit` String COMMENT '商品单位',

    `sale_volume` Decimal(18,
 4) COMMENT '销售数量',

    `sale_price` Decimal(18,
 4) COMMENT '平均售价',

    `sale_amount` Decimal(18,
 4) COMMENT '销售金额',

    `theory_cost` Decimal(18,
 4) COMMENT '理论成本',

    `actual_cost` Decimal(18,
 4) COMMENT '实际成本',

    `other_cost` Decimal(18,
 4) COMMENT '其他成本',

    `diff_cost` Decimal(18,
 4) COMMENT '成本差异',

    `bill_type` String COMMENT '账单类型',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year,
 month,
 day,
 organ_lid,
 product_lid,
 product_unit)
ORDER BY (mid,
 sid,
 year,
 month,
 day,
 organ_lid,
 product_lid,
 product_unit)
SETTINGS index_granularity = 8192
COMMENT '菜品销售利润统计';


-- reportcenter.dwt_daily_by_day definition

CREATE TABLE reportcenter.dwt_daily_by_day
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

    `value` Decimal(18,
 4) COMMENT '统计值'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 key_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 key_)
SETTINGS index_granularity = 8192
COMMENT '营业日报';