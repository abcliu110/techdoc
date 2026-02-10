-- ads_department_by_day definition

CREATE TABLE bi.ads_department_by_day
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

    `department` String COMMENT '统计指标',

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
 4) COMMENT '实际金额',

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

    `actual_income` Decimal(18,
 4) COMMENT '实收金额',

    `virtual_income` Decimal(18,
 4) COMMENT '虚收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 department)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 department)
SETTINGS index_granularity = 8192
COMMENT '部门日销售汇总';


-- ads_food_by_week_hour definition

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
 4) COMMENT '实际金额',

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

    `actual_income` Decimal(18,
 4) COMMENT '实收金额',

    `virtual_income` Decimal(18,
 4) COMMENT '虚收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 week_,
 hour_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 week_,
 hour_)
SETTINGS index_granularity = 8192
COMMENT '每周各个小时汇总';


-- ads_pay_by_day definition

CREATE TABLE bi.ads_pay_by_day
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

    `count_` Int32 COMMENT '支付笔数',

    `amount` Decimal(18,
 4) COMMENT '支付金额',

    `give_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `actual_income` Decimal(18,
 4) COMMENT '实收金额',

    `virtual_income` Decimal(18,
 4) COMMENT '虚收金额'
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


-- caishifa definition

CREATE TABLE bi.caishifa
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '菜品食法名称',

    `status_` Int32 COMMENT '记录状态',

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `cai` Int64 COMMENT '所属菜品',

    `caishifaid` String COMMENT '编号',

    `caishifaname` String COMMENT '名称',

    `miaoshu` String COMMENT '描述符',

    `miaoshutmp` String COMMENT '描述符',

    `shangcaishuliang` Decimal(18,
 4) COMMENT '上菜数量',

    `buwei` String COMMENT '部位',

    `zuofa` String COMMENT '做法',

    `kuowei` String COMMENT '口味',

    `yaoqiu` String COMMENT '要求',

    `xiaofeidanid` String COMMENT '所属消费单编号',

    `xiaofeicaipingid` String COMMENT '所属消费菜编号',

    `xiaofeicaipingpid` Int64 COMMENT '所属消费菜pid',

    `pidtmp` Int64 COMMENT '线下的PID',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192
COMMENT '';


-- canal_event_log definition

CREATE TABLE bi.canal_event_log
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `tbl_name` String COMMENT '表名',

    `lid` Int64 COMMENT '逻辑编号',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `type` String COMMENT '事件类型',

    `log_file_name` String COMMENT '日志文件名称',

    `execute_time` DateTime COMMENT '执行时间',

    `content` String COMMENT '事件内容'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(execute_time)
PRIMARY KEY (mid,
 sid,
 tbl_name,
 lid)
ORDER BY (mid,
 sid,
 tbl_name,
 lid)
SETTINGS index_granularity = 8192
COMMENT 'canal消费日志表';


-- crm_card definition

CREATE TABLE bi.crm_card
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡名称',

    `status_` Int8 COMMENT '记录状态',

    `member` String COMMENT '会员',

    `member_code` String COMMENT '会员编号',

    `member_id_alias` String COMMENT '会员编号(id字段）',

    `phone` String COMMENT '手机号',

    `agent_lmnid` String COMMENT '经办人lmnid',

    `agent` String COMMENT '经办人',

    `invitees_lmnid` String COMMENT '邀请人lmnid',

    `invitees` String COMMENT '邀请人',

    `salesman_lmnid` String COMMENT '业务员lmnid',

    `salesman` String COMMENT '业务员',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` String COMMENT '会员卡类型编号',

    `card_type_level` String COMMENT '会员卡等级',

    `card_type_level_code` String COMMENT '会员卡等级编号',

    `join_time` DateTime COMMENT '开卡日期',

    `balance` Decimal(18,
 4) COMMENT '卡余额',

    `principal_balance` Decimal(18,
 4) COMMENT '本金余额',

    `give_balance` Decimal(18,
 4) COMMENT '赠送余额',

    `unpaid_amount` Decimal(18,
 4) COMMENT '未到账金额（冻结金额）',

    `points` Decimal(18,
 4) COMMENT '积分余额',

    `sum_of_save_times` Decimal(18,
 4) COMMENT '累计充值次数',

    `sum_of_save` Decimal(18,
 4) COMMENT '累计充值金额',

    `sum_of_consume` Decimal(18,
 4) COMMENT '累计消费金额',

    `sum_of_consume_times` Decimal(18,
 4) COMMENT '累计消费次数',

    `over_time` DateTime COMMENT '有效期',

    `last_consume_time` DateTime COMMENT '最近交易时间',

    `last_card_level_time` DateTime COMMENT '卡升级时间',

    `openid` String COMMENT 'openid',

    `unionid` String COMMENT 'unionid',

    `appid` String COMMENT 'appid',

    `session_key` String COMMENT '登录票据',

    `out_id` String COMMENT '卡面编号',

    `headimgurl` String COMMENT '头像地址',

    `pwd` String COMMENT '密码',

    `disable` Int8 COMMENT '停用',

    `province` String COMMENT '所在省',

    `province_code` String COMMENT '省编码',

    `city` String COMMENT '所在市',

    `city_code` String COMMENT '市编码',

    `county` String COMMENT '所在区县',

    `county_code` String COMMENT '所在区县编码',

    `owner_shop` String COMMENT '店铺',

    `owner_shop_id` String COMMENT '店铺编号',

    `card_status` String COMMENT '会员卡状态',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `join_timestamp` Int64
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(company_id))
PRIMARY KEY (company_id,
 lmnid)
ORDER BY (company_id,
 lmnid)
SETTINGS index_granularity = 8192;


-- crm_card_balance definition

CREATE TABLE bi.crm_card_balance
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64 COMMENT '物理编号',

    `mid` Int64 COMMENT '租户号',

    `sid` Int64 COMMENT '充值门店号',

    `lid` Int64 COMMENT '逻辑编号',

    `cno` Int64 COMMENT '卡号',

    `total` Decimal(18,
 4) COMMENT '总金额',

    `principal` Decimal(18,
 4) COMMENT '本金',

    `gift` Decimal(18,
 4) COMMENT '赠送金额',

    `source` Int32 COMMENT '来源',

    `out_trade_no` String COMMENT '业务单号',

    `revision` Int32 COMMENT '乐观锁',

    `created_by` String COMMENT '创建人',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `updated_by` String COMMENT '更新人',

    `updated_time` DateTime COMMENT '更新时间',

    `counter` Int8 COMMENT '计数器'
)
ENGINE = ReplacingMergeTree(created_time)
PRIMARY KEY (mid,
 sid,
 lid)
ORDER BY (mid,
 sid,
 lid)
SETTINGS index_granularity = 8192
COMMENT '卡余额';


-- crm_card_level definition

CREATE TABLE bi.crm_card_level
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡等级名称',

    `status_` Int32 COMMENT '记录状态',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` Int64 COMMENT '会员卡类型编号',

    `logo` String COMMENT 'logo',

    `bg_img` String COMMENT '背景图片',

    `font_color` String COMMENT '字体颜色',

    `bg_color` String COMMENT '背景色',

    `description` String COMMENT '会员等级说明',

    `upg_by_cumulative_consumption_amount` Int8 COMMENT '按累计消费金额升级',

    `cumulative_consumption_amount` Decimal(18,
 4) COMMENT '累计消费金额',

    `upg_by_cumulative_consumption_count` Int8 COMMENT '按累计消费次数升级',

    `cumulative_consumption_count` Decimal(18,
 4) COMMENT '累计消费次数',

    `upg_by_cumulative_consumption_amount_and_count` Int8 COMMENT '消费金额和次数均满足才可以升级',

    `upg_by_cumulative_save_amount` Int8 COMMENT '按累计储值金额升级',

    `cumulative_save_amount` Decimal(18,
 4) COMMENT '累计储值金额',

    `upg_by_earn_points` Int8 COMMENT '按累计获取积分升级',

    `earn_points` Decimal(18,
 4) COMMENT '累计获取积分',

    `upg_by_points_balance` Int8 COMMENT '按积分余额升级',

    `earn_balance` Decimal(18,
 4) COMMENT '积分余额',

    `deg_by_expiration_date` Int8 COMMENT '按有效期降级',

    `expiration_date` Decimal(18,
 4) COMMENT '当前等级满x天时降级',

    `deg_by_balance` Int8 COMMENT '按余额降级',

    `balance` Decimal(18,
 4) COMMENT '会员卡余额不足x元时',

    `deg_by_consumption_limit` Int8 COMMENT '按消费不足降级',

    `consumption_limit_day` Int32 COMMENT '累计x天',

    `consumption_limit_amount` Decimal(18,
 4) COMMENT '消费不足x元时降级',

    `add_point_rule_amount` Decimal(18,
 4) COMMENT '每消费x元',

    `add_point_rule_point` Decimal(18,
 4) COMMENT '积x分',

    `add_point_rule_max_point_one_time` Decimal(18,
 4) COMMENT '单笔积分上限',

    `discount_rate` Decimal(18,
 4) COMMENT '享受折扣率',

    `discount_range` String COMMENT '折扣范围',

    `member_price_discount_can_use_at_the_same_time` Int8 COMMENT '会员价和折扣是否同时使用',

    `can_credit` Int8 COMMENT '是否可以挂账',

    `can_use_member_price` Int8 COMMENT '是否显示会员价',

    `can_not_use_member_price_and_discount_when_balance_below` Int8 COMMENT '储值余额不足x元时',

    `coupon_code` String COMMENT '新人领券编号',

    `coupon` String COMMENT '新人领券',

    `coupon_pkg_code` String COMMENT '新人领券包编号',

    `coupon_pkg` String COMMENT '新人领券包',

    `level_upgrade_price` Decimal(18,
 4) COMMENT '等级升级价格',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(company_id))
PRIMARY KEY (company_id,
 lmnid)
ORDER BY (company_id,
 lmnid)
SETTINGS index_granularity = 8192
COMMENT '';


-- crm_card_op_record definition

CREATE TABLE bi.crm_card_op_record
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡操作记录名称',

    `status_` Int32 COMMENT '记录状态',

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `owner_shop` String COMMENT '店铺',

    `owner_shop_id` Int64 COMMENT '店铺编号',

    `create_time` DateTime COMMENT '日期',

    `member_name` String COMMENT '会员姓名',

    `member_id` String COMMENT '会员编号',

    `member_id_alias` String COMMENT '会员编号(id字段）',

    `phone` String COMMENT '手机号',

    `card_id` String COMMENT '会员卡号',

    `card_id_alias` String COMMENT '会员卡编号(id字段）',

    `card_out_id` String COMMENT '会员卡卡面编号',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` String COMMENT '会员卡类型编号',

    `operation_model` String COMMENT '交易类型',

    `operator` String COMMENT '操作人员',

    `comment` String COMMENT '备注信息',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (pid,
 company_id,
 lmnid)
ORDER BY (pid,
 company_id,
 lmnid)
SETTINGS index_granularity = 8192
COMMENT '';


-- crm_card_points_record definition

CREATE TABLE bi.crm_card_points_record
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡积分变动记录名称',

    `status_` Int8 COMMENT '记录状态',

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `shop_name` String COMMENT '店铺',

    `create_time` DateTime COMMENT '日期',

    `member_name` String COMMENT '会员姓名',

    `member_id` Int64 COMMENT '会员lmnid',

    `member_id_alias` String COMMENT '会员编号(id字段）',

    `phone` String COMMENT '手机号',

    `card_id` Int64 COMMENT '会员卡lmnid',

    `card_id_alias` String COMMENT '会员卡编号(id字段）',

    `card_out_id` String COMMENT '会员卡卡面编号',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` Int64 COMMENT '会员卡类型编号',

    `operation_model` String COMMENT '交易类型',

    `operator` String COMMENT '操作人员',

    `comment` String COMMENT '备注信息',

    `balance_before` Decimal(18,
 4) COMMENT '交易前的积分',

    `balance_after` Decimal(18,
 4) COMMENT '交易后的积分',

    `amount` Decimal(18,
 4) COMMENT '交易积分',

    `save_rule` String COMMENT '充值套餐',

    `save_rule_code` String COMMENT '充值套餐编号',

    `tran_source` String COMMENT '交易来源',

    `subject` String COMMENT '科目',

    `is_third_party` Int8 COMMENT '是否对接外部系统',

    `out_order_bill_id` String COMMENT '外部系统单号',

    `if_deal_success` Int8 COMMENT '外部系统是否处理成功',

    `order_bill_id` String COMMENT '关联单号',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (pid,
 company_id,
 lmnid)
ORDER BY (pid,
 company_id,
 lmnid)
SETTINGS index_granularity = 8192
COMMENT '';


-- crm_card_record definition

CREATE TABLE bi.crm_card_record
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡交易记录名称',

    `status_` Int32 COMMENT '记录状态',

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `shop_name` String COMMENT '店铺',

    `create_time` DateTime COMMENT '日期',

    `member_name` String COMMENT '会员姓名',

    `member_id` Int64 COMMENT '会员编号',

    `member_id_alias` String COMMENT '会员编号(id字段）',

    `phone` String COMMENT '手机号',

    `card_id` Int64 COMMENT '会员卡号',

    `card_id_alias` String COMMENT '会员卡编号(id字段）',

    `card_out_id` String COMMENT '会员卡卡面编号',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` String COMMENT '会员卡类型编号',

    `operation_model` String COMMENT '交易类型',

    `operator` String COMMENT '操作人员',

    `comment` String COMMENT '备注信息',

    `balance_before` Decimal(18,
 4) COMMENT '交易前的余额',

    `balance_after` Decimal(18,
 4) COMMENT '交易后的余额',

    `principal_amount_before` Decimal(18,
 4) COMMENT '交易前的本金余额',

    `principal_amount_after` Decimal(18,
 4) COMMENT '交易后的本金余额',

    `give_amount_before` Decimal(18,
 4) COMMENT '交易前的赠送金额',

    `give_amount_after` Decimal(18,
 4) COMMENT '交易后的赠送金额',

    `principal_amount` Decimal(18,
 4) COMMENT '交易本金',

    `give_amount` Decimal(18,
 4) COMMENT '交易赠送金额',

    `amount` Decimal(18,
 4) COMMENT '交易金额',

    `save_rule` String COMMENT '充值套餐',

    `save_rule_code` String COMMENT '充值套餐编号',

    `recharge_number` Int32 COMMENT '充值套餐的充值次数',

    `pay_way` String COMMENT '支付方式',

    `pay_way_code` String COMMENT '支付方式编号',

    `order_bill_id` String COMMENT '关联单号',

    `invoice_amount` Decimal(18,
 4) COMMENT '发票金额',

    `give_point` Decimal(18,
 4) COMMENT '本次的赠送积分',

    `is_refund` Int8 COMMENT '是否退款',

    `is_cancel` Int8 COMMENT '是否撤销',

    `subject` String COMMENT '科目',

    `is_third_party` Int8 COMMENT '是否对接外部系统',

    `out_order_bill_id` String COMMENT '外部系统单号',

    `if_deal_success` Int8 COMMENT '外部系统是否处理成功',

    `source` String COMMENT '来源',

    `give_coupon` String COMMENT '赠送券',

    `give_coupon_id` String COMMENT '赠送券的编号',

    `marketer` String COMMENT '营销人',

    `commission_amount` Decimal(18,
 4) COMMENT '提成金额',

    `commission_ratio` Decimal(18,
 4) COMMENT '提成比例',

    `created_time` DateTime DEFAULT now(),

    `source_sid` Int64 COMMENT '源门店',

    `task_lid` Int64 COMMENT '任务id'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (pid,
 company_id,
 shop_id,
 year,
 month,
 day,
 if_deal_success)
ORDER BY (pid,
 company_id,
 shop_id,
 year,
 month,
 day,
 if_deal_success)
SETTINGS index_granularity = 8192;


-- crm_card_type definition

CREATE TABLE bi.crm_card_type
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员卡名称',

    `status_` Int8 COMMENT '记录状态',

    `kind` String COMMENT '种类',

    `phone` String COMMENT '客服电话',

    `logo` String COMMENT 'logo',

    `bg_img` String COMMENT '背景图片',

    `font_color` String COMMENT '字体颜色',

    `bg_color` String COMMENT '背景色',

    `description` String COMMENT '会员卡说明',

    `points_to_cash_point` Decimal(18,
 4) COMMENT '积分抵现-每【x】分',

    `pay_by_rate` Decimal(18,
 4) COMMENT '限制余额支付比例',

    `points_to_cash_money` Decimal(18,
 4) COMMENT '积分抵现-可以抵现【x】元',

    `points_to_cash_max_rule` String COMMENT '抵扣上限',

    `points_to_cash_max` Decimal(18,
 4) COMMENT '抵扣上限数值',

    `points_to_cash_rule` String COMMENT '抵扣方式',

    `points_to_cash_min` Decimal(18,
 4) COMMENT '起扣积分',

    `offline_cost` Decimal(18,
 4) COMMENT '线下卡工本费',

    `online_cost` Decimal(18,
 4) COMMENT '线上卡工本费',

    `deposit` Decimal(18,
 4) COMMENT '卡押金',

    `save_amount_while_apply` Decimal(18,
 4) COMMENT '开卡需要先充值【x】元',

    `deduction_rule` String COMMENT '扣款方式',

    `enable_on_line_save` Int8 COMMENT '线上可以充值',

    `enable_on_line_deduction` Int8 COMMENT '线上可以消费',

    `use_rule` String COMMENT '使用限制',

    `save_desc` String COMMENT '充值须知',

    `default_card_type` Int8 COMMENT '默认会员卡类型',

    `disable` Int8 COMMENT '禁用',

    `upg_by_cumulative_consumption_amount` Int8 COMMENT '按累计消费金额升级',

    `cumulative_consumption_amount` Decimal(18,
 4) COMMENT '累计消费金额',

    `upg_by_cumulative_consumption_count` Int8 COMMENT '按累计消费次数升级',

    `cumulative_consumption_count` Decimal(18,
 4) COMMENT '累计消费次数',

    `upg_by_cumulative_save_amount` Int8 COMMENT '按累计储值金额升级',

    `cumulative_save_amount` Decimal(18,
 4) COMMENT '累计储值金额',

    `upg_by_earn_points` Int8 COMMENT '按累计获取积分升级',

    `earn_points` Decimal(18,
 4) COMMENT '累计获取积分',

    `upg_by_points_balance` Int8 COMMENT '按积分余额升级',

    `earn_balance` Decimal(18,
 4) COMMENT '积分余额',

    `deg_by_expiration_date` Int8 COMMENT '按有效期降级',

    `expiration_date` Decimal(18,
 4) COMMENT '当前等级满x天时降级',

    `deg_by_balance` Int8 COMMENT '按余额降级',

    `balance` Decimal(18,
 4) COMMENT '会员卡余额不足x元时',

    `deg_by_consumption_limit` Int8 COMMENT '按消费不足降级',

    `consumption_limit_day` Int32 COMMENT '累计x天',

    `consumption_limit_amount` Decimal(18,
 4) COMMENT '消费不足x元时降级',

    `discount_code` String COMMENT '打折方式id',

    `discount_name` String COMMENT '打折方式名称',

    `integral_plan_code` String COMMENT '积分计划id',

    `integral_plan_name` String COMMENT '积分计划名称',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(company_id))
PRIMARY KEY (company_id,
 lmnid)
ORDER BY (company_id,
 lmnid)
SETTINGS index_granularity = 8192
COMMENT '';


-- crm_member definition

CREATE TABLE bi.crm_member
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `pid` Int64,

    `company_id` Int64,

    `shop_id` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '会员名称',

    `status_` Int8 COMMENT '记录状态',

    `phone` String COMMENT '手机号',

    `agent_lmnid` String COMMENT '经办人lmnid',

    `agent` String COMMENT '经办人',

    `invitees_lmnid` String COMMENT '邀请人lmnid',

    `invitees` String COMMENT '邀请人',

    `salesman_lmnid` String COMMENT '业务员lmnid',

    `salesman` String COMMENT '业务员',

    `contact_details` String COMMENT '联系方式',

    `sex` String COMMENT '性别',

    `birthday` DateTime COMMENT '生日',

    `birthday_type` String COMMENT '生日类型',

    `certificate` String COMMENT '证件类型',

    `certificate_code` String COMMENT '证件号码',

    `email` String COMMENT '电子邮箱',

    `postal_code` String COMMENT '邮政编码',

    `addr` String COMMENT '常用地址',

    `company` String COMMENT '单位名称',

    `position` String COMMENT '客户职位',

    `comment` String COMMENT '备注信息',

    `submitter` String COMMENT '提交人',

    `card_id` String COMMENT '会员卡编号',

    `card_out_id` String COMMENT '会员卡卡面编号',

    `owner_shop` String COMMENT '店铺',

    `join_time` DateTime COMMENT '入会日期',

    `owner_shop_id` String COMMENT '店铺编号',

    `counter` Int8 COMMENT '计数器',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `join_timestamp` Int64
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(company_id))
PRIMARY KEY (company_id,
 lmnid)
ORDER BY (company_id,
 lmnid)
SETTINGS index_granularity = 8192;


-- dwd_bill definition

CREATE TABLE bi.dwd_bill
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `hour_` Int8 COMMENT '时',

    `season` Int8 COMMENT '季度',

    `counter` Int8 COMMENT '计数器',

    `person_num` Int32 COMMENT '客流',

    `amount_per_person` Decimal(18,
 4) COMMENT '客单价',

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

    `timing_amount` Decimal(18,
 4) COMMENT '计时金额',

    `timing_discount_amount` Decimal(18,
 4) COMMENT '计时折扣额',

    `timing_service_charge_amount` Decimal(18,
 4) COMMENT '计时服务费',

    `overcharge_amount` Decimal(18,
 4) COMMENT '多收金额',

    `less_amount` Decimal(18,
 4) COMMENT '少收金额',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `checkout_by` String COMMENT '收银员',

    `checkout_time_name` String COMMENT '餐段',

    `duration` Int64 COMMENT '消费时长(毫秒)',

    `shift_name` String COMMENT '班次',

    `order_sub_type` String COMMENT '账单类型',

    `channel_name` String COMMENT '渠道',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `create_by` String COMMENT '开台人员',

    `table_leader` String COMMENT '桌台负责人',

    `waiter_by` String COMMENT '服务员',

    `channel_order_key_t_p` String COMMENT '三方单号',

    `device_code` String COMMENT '设备编号',

    `device_name` String COMMENT '设备名称',

    `discount_range` String COMMENT '折扣方式',

    `discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `discount_by` String COMMENT '打折人',

    `service_charge_rate` Decimal(18,
 4) COMMENT '服务率',

    `fraction_by` String COMMENT '零头调整人',

    `fjz_count` Int32 COMMENT '反结账次数',

    `invoice_amount` Decimal(18,
 4) COMMENT '发票金额',

    `invoice_title` String COMMENT '发票抬头',

    `is_vip_price` Int8 COMMENT '使用了会员价',

    `card_type` String COMMENT '会员类型',

    `card_level` String COMMENT '会员等级',

    `card_no` String COMMENT '会员卡号',

    `saas_order_remark` String COMMENT '备注',

    `order_type` String COMMENT '账单类型',

    `order_status` String COMMENT '状态状态',

    `num_of_jiu_xi` Decimal(18,
 4) COMMENT '席数',

    `single_jiu_xi_amount` Decimal(18,
 4) COMMENT '单席金额',

    `jiu_xi_amount` Decimal(18,
 4) COMMENT '酒席金额',

    `is_jiu_xi` Int8 COMMENT '酒席单',

    `remark` String COMMENT '标记',

    `jiu_xi_order_amount` Decimal(18,
 4) COMMENT '酒席订金',

    `card_number` String COMMENT '食品卡号',

    `free_service_charge_amount` Decimal(18,
 4) COMMENT '免掉的服务费',

    `free_service_charge` Int8 COMMENT '该单是否免服务费',

    `receivable_amount` Decimal(18,
 4) COMMENT '应收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no)
SETTINGS index_granularity = 8192
COMMENT '账单明细';


-- dwd_bill_mid definition

CREATE TABLE bi.dwd_bill_mid
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '商户编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '日期',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `hour_` Int8 COMMENT '时',

    `season` Int8 COMMENT '季度',

    `counter` Int8 COMMENT '计数器',

    `person_num` Int32 COMMENT '客流',

    `amount_per_person` Decimal(18,
 4) COMMENT '客单价',

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

    `timing_amount` Decimal(18,
 4) COMMENT '计时金额',

    `timing_discount_amount` Decimal(18,
 4) COMMENT '计时折扣额',

    `timing_service_charge_amount` Decimal(18,
 4) COMMENT '计时服务费',

    `overcharge_amount` Decimal(18,
 4) COMMENT '多收金额',

    `less_amount` Decimal(18,
 4) COMMENT '少收金额',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `cancel_amount` Decimal(18,
 4) COMMENT '退菜金额',

    `send_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `checkout_by` String COMMENT '收银员',

    `checkout_time_name` String COMMENT '餐段',

    `duration` Int64 COMMENT '消费时长(毫秒)',

    `shift_name` String COMMENT '班次',

    `order_sub_type` String COMMENT '账单类型',

    `channel_name` String COMMENT '渠道',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `create_by` String COMMENT '开台人员',

    `table_leader` String COMMENT '桌台负责人',

    `waiter_by` String COMMENT '服务员',

    `channel_order_key_t_p` String COMMENT '三方单号',

    `device_code` String COMMENT '设备编号',

    `device_name` String COMMENT '设备名称',

    `discount_range` String COMMENT '折扣方式',

    `discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `discount_by` String COMMENT '打折人',

    `service_charge_rate` Decimal(18,
 4) COMMENT '服务率',

    `fraction_by` String COMMENT '零头调整人',

    `fjz_count` Int32 COMMENT '反结账次数',

    `invoice_amount` Decimal(18,
 4) COMMENT '发票金额',

    `invoice_title` String COMMENT '发票抬头',

    `is_vip_price` Int8 COMMENT '使用了会员价',

    `card_type` String COMMENT '会员类型',

    `card_level` String COMMENT '会员等级',

    `card_no` String COMMENT '会员卡号',

    `saas_order_remark` String COMMENT '备注',

    `order_type` String COMMENT '账单类型',

    `order_status` String COMMENT '状态状态',

    `num_of_jiu_xi` Decimal(18,
 4) COMMENT '席数',

    `single_jiu_xi_amount` Decimal(18,
 4) COMMENT '单席金额',

    `jiu_xi_amount` Decimal(18,
 4) COMMENT '酒席金额',

    `is_jiu_xi` Int8 COMMENT '酒席单',

    `remark` String COMMENT '标记',

    `jiu_xi_order_amount` Decimal(18,
 4) COMMENT '酒席订金',

    `card_number` String COMMENT '食品卡号',

    `free_service_charge_amount` Decimal(18,
 4) COMMENT '免掉的服务费',

    `free_service_charge` Int8 COMMENT '该单是否免服务费',

    `receivable_amount` Decimal(18,
 4) COMMENT '应收金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 report_date)
SETTINGS index_granularity = 8192
COMMENT '账单明细';


-- dwd_food definition

CREATE TABLE bi.dwd_food
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `food_no` Int64 COMMENT '菜品流水号',

    `food_code` String COMMENT '菜品编码',

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `ordering_time` DateTime COMMENT '点菜时间',

    `ordered_time` DateTime COMMENT '上菜时间',

    `cook_duration` Int64 COMMENT '制作时长（毫秒）',

    `cook` String COMMENT '厨师',

    `food_pro_price` Decimal(18,
 4) COMMENT '售价',

    `food_org_price` Decimal(18,
 4) COMMENT '原价',

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

    `discount_range` String COMMENT '打折方式',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `processing_fee_discount` Decimal(18,
 4) COMMENT '加工费折扣额',

    `processing_fee_service` Decimal(18,
 4) COMMENT '加工费服务费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `department_name` String COMMENT '出品部门',

    `food_subject_name` String COMMENT '菜品收入科目',

    `order_sub_type` String COMMENT '账单类型',

    `channel_name` String COMMENT '渠道',

    `food_taste` String COMMENT '口味',

    `food_practice` String COMMENT '做法',

    `shift_name` String COMMENT '班次',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `order_by` String COMMENT '点菜人',

    `checkout_by` String COMMENT '收银员',

    `remark` String COMMENT '备注',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `food_remark` String COMMENT '备注',

    `checkout_time_name` String COMMENT '餐段',

    `send_by` String COMMENT '赠送人',

    `send_for` String COMMENT '赠送原因',

    `send_time` DateTime COMMENT '赠送时间',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `cancel_for` String COMMENT '退菜原因',

    `cancel_by` String COMMENT '退菜人',

    `cancel_time` DateTime COMMENT '退菜时间',

    `is_rename` Int8 COMMENT '修改过菜名',

    `rename_by` String COMMENT '菜名修改人',

    `is_mod_price` Int8 COMMENT '修改过价格',

    `mod_price_by` String COMMENT '价格修改人',

    `mode_price_time` DateTime COMMENT '改价时间',

    `discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `discount_by` String COMMENT '打折人',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `is_jiu_xi` Int8 COMMENT '酒席菜',

    `free_service_charge` Int8 COMMENT '该单是否免服务费',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `online` Int8 COMMENT '线上订单',

    `commission` Decimal(18,
 4) COMMENT '提成',

    `pack_lid` Int64 COMMENT '套餐lid'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
SETTINGS index_granularity = 8192
COMMENT '菜品销售明细';


-- dwd_food_mid definition

CREATE TABLE bi.dwd_food_mid
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `food_no` Int64 COMMENT '菜品流水号',

    `food_code` String COMMENT '菜品编码',

    `food_name` String COMMENT '菜品名称',

    `food_unit` String COMMENT '规格',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `ordering_time` DateTime COMMENT '点菜时间',

    `ordered_time` DateTime COMMENT '上菜时间',

    `cook_duration` Int64 COMMENT '制作时长（毫秒）',

    `cook` String COMMENT '厨师',

    `food_pro_price` Decimal(18,
 4) COMMENT '售价',

    `food_org_price` Decimal(18,
 4) COMMENT '原价',

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

    `discount_range` String COMMENT '打折方式',

    `processing_fee` Decimal(18,
 4) COMMENT '加工费',

    `processing_fee_discount` Decimal(18,
 4) COMMENT '加工费折扣额',

    `processing_fee_service` Decimal(18,
 4) COMMENT '加工费服务费',

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额',

    `food_discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `department_name` String COMMENT '出品部门',

    `food_subject_name` String COMMENT '菜品收入科目',

    `order_sub_type` String COMMENT '账单类型',

    `channel_name` String COMMENT '渠道',

    `food_taste` String COMMENT '口味',

    `food_practice` String COMMENT '做法',

    `shift_name` String COMMENT '班次',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `order_by` String COMMENT '点菜人',

    `checkout_by` String COMMENT '收银员',

    `remark` String COMMENT '备注',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `food_remark` String COMMENT '备注',

    `checkout_time_name` String COMMENT '餐段',

    `send_by` String COMMENT '赠送人',

    `send_for` String COMMENT '赠送原因',

    `send_time` DateTime COMMENT '赠送时间',

    `cancel_number` Decimal(18,
 4) COMMENT '退菜数量',

    `cancel_for` String COMMENT '退菜原因',

    `cancel_by` String COMMENT '退菜人',

    `cancel_time` DateTime COMMENT '退菜时间',

    `is_rename` Int8 COMMENT '修改过菜名',

    `rename_by` String COMMENT '菜名修改人',

    `is_mod_price` Int8 COMMENT '修改过价格',

    `mod_price_by` String COMMENT '价格修改人',

    `mode_price_time` DateTime COMMENT '改价时间',

    `discount_rate` Decimal(18,
 4) COMMENT '折扣率',

    `discount_by` String COMMENT '打折人',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `is_jiu_xi` Int8 COMMENT '酒席菜',

    `free_service_charge` Int8 COMMENT '该单是否免服务费',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `online` Int8 COMMENT '线上订单',

    `commission` Decimal(18,
 4) COMMENT '提成',

    `pack_lid` Int64 COMMENT '套餐lid'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_,
 report_date)
SETTINGS index_granularity = 8192
COMMENT '菜品销售明细';


-- dwd_income definition

CREATE TABLE bi.dwd_income
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `pay_time` DateTime COMMENT '支付时间',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season_` Int8 COMMENT '季度',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` String COMMENT '账单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `income_type` String COMMENT '收入类型',

    `pay_type` String COMMENT '支付方式',

    `online` Int8 COMMENT '线上支付',

    `type` String COMMENT '类型',

    `table_name` String COMMENT '桌台',

    `amount` Decimal(18,
 4) COMMENT '金额',

    `give_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `principal_amount` Decimal(18,
 4) COMMENT '本金'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 season_,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 season_,
 saas_order_key,
 saas_order_no,
 no_)
SETTINGS index_granularity = 8192
COMMENT '收入明细表';


-- dwd_invoice_bill definition

CREATE TABLE bi.dwd_invoice_bill
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

    `bill_id_off_line` String COMMENT '支付方式名称',

    `extractcode` String COMMENT '提取码',

    `tradetime` DateTime COMMENT '交易时间',

    `tradeno` String COMMENT '交易单号',

    `qrcodeno` String COMMENT '开票二维码编号',

    `invoiceurl` String COMMENT '开票url',

    `cashier` String COMMENT '收银员',

    `table` String COMMENT '桌台',

    `amountofconsumption` Decimal(18,
 4) COMMENT '消费金额',

    `invoiceamount` Decimal(18,
 4) COMMENT '开票金额',

    `invoicereqserialno` String COMMENT '发票请求流水号，可以根据该值查询详细的发票信息。此值为空时为未开票',

    `invoiceitemamount` Decimal(18,
 4) COMMENT '实际的开票金额',

    `taxpayernum` String COMMENT '纳税人识别号',

    `invoicetype` String COMMENT '开票类型:1 蓝票;2 红票;3 蓝废;4 红废 注：电子发票会出现验签失败自动作废',

    `code` String COMMENT '发票状态码（0000：开票成功；6666：未开票；7777：开票中；9999：开票失败',

    `msg` String COMMENT '发票状态描述（成功/失败原因）',

    `securitycode` String COMMENT '校验码.发票状态为成功时，必传，普通发票使用，增值税发票返回为空',

    `qrcode` String COMMENT '二维码',

    `invoicecode` String COMMENT '发票代码',

    `invoiceno` String COMMENT '发票号码',

    `invoicedate` DateTime COMMENT '开票日期',

    `notaxamount` Decimal(18,
 4) COMMENT '不含税金额',

    `taxamount` String COMMENT '税额',

    `downloadurl` String COMMENT '发票下载 Url',

    `vatplatforminvpreviewurl` String COMMENT '公 共 服 务 平 台 发票预览 Url'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year_,
 month_,
 day_,
 tradeno)
ORDER BY (mid,
 sid,
 year_,
 month_,
 day_,
 tradeno)
SETTINGS index_granularity = 8192
COMMENT '发票订单';


-- dwd_pay definition

CREATE TABLE bi.dwd_pay
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `id` String COMMENT '支付方式编号',

    `name` String COMMENT '支付方式名称',

    `type_` String COMMENT '支付类型',

    `pay_amount` Decimal(18,
 4) COMMENT '支付金额',

    `exchange_amount` Decimal(18,
 4) COMMENT '找回金额',

    `amount` Decimal(18,
 4) COMMENT '实收金额',

    `is_real_income` Int8 COMMENT '真实收入',

    `shift_name` String COMMENT '班次',

    `checkout_by` String COMMENT '收银员',

    `checkout_time_name` String COMMENT '餐段',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `give_amount` Decimal(18,
 4) COMMENT '赠送金额',

    `signer` String COMMENT '签单人',

    `account_holder` String COMMENT '挂账人',

    `account_holder_id` String COMMENT '挂账人编号',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `order_sub_type` Int32 COMMENT '账单类型;堂食、外卖、自提',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `remark` String COMMENT '标记',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `free_service_charge` Int8 COMMENT '免服务费',

    `online` Int8 COMMENT '线上订单'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
SETTINGS index_granularity = 8192
COMMENT '支付明细表';


-- dwd_pay_mid definition

CREATE TABLE bi.dwd_pay_mid
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '账单号',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `id` String COMMENT '支付方式编号',

    `name` String COMMENT '支付方式名称',

    `type_` String COMMENT '支付类型',

    `pay_amount` Decimal(18,
 4) COMMENT '支付金额',

    `exchange_amount` Decimal(18,
 4) COMMENT '找回金额',

    `amount` Decimal(18,
 4) COMMENT '实收金额',

    `is_real_income` Int8 COMMENT '真实收入',

    `shift_name` String COMMENT '班次',

    `checkout_by` String COMMENT '收银员',

    `checkout_time_name` String COMMENT '餐段',

    `year_` Int32 COMMENT '年',

    `month_` Int8 COMMENT '月',

    `day_` Int8 COMMENT '日',

    `season` Int8 COMMENT '季度',

    `give_amount` Decimal(18,
 4) COMMENT '实收金额',

    `signer` String COMMENT '签单人',

    `account_holder` String COMMENT '挂账人',

    `account_holder_id` String COMMENT '挂账人编号',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `order_sub_type` Int32 COMMENT '账单类型;堂食、外卖、自提',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `remark` String COMMENT '标记',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `free_service_charge` Int8 COMMENT '免服务费',

    `online` Int8 COMMENT '线上订单'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY sipHash64(toString(mid))
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_,
 report_date)
SETTINGS index_granularity = 8192
COMMENT '支付明细表';


-- dwd_taste definition

CREATE TABLE bi.dwd_taste
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `partition_in_kafka` Int64 COMMENT '消息分区',

    `offset_in_kafka` Int64 COMMENT '消息偏移量',

    `saas_order_key` String COMMENT '订单编号',

    `saas_order_no` Int64 COMMENT '订单流水号',

    `no_` Int64 COMMENT '流水号',

    `counter` Int8 COMMENT '计数器',

    `food_super_category_name` String COMMENT '菜品大类',

    `food_category_name` String COMMENT '菜品小类',

    `food_name` String COMMENT '菜品',

    `food_no` String COMMENT '菜品流水号',

    `unit` String COMMENT '规格',

    `adjutant_unit` String COMMENT '辅助规格',

    `name` String COMMENT '名称',

    `number` Decimal(18,
 4) COMMENT '数量',

    `price` Decimal(18,
 4) COMMENT '价格',

    `taste_amount` Decimal(18,
 4) COMMENT '费用',

    `discount_amount` Decimal(18,
 4) COMMENT '折扣额',

    `service_charge_amount` Decimal(18,
 4) COMMENT '服务费',

    `amount` Decimal(18,
 4) COMMENT '实际收费',

    `department_name` String COMMENT '出品部门',

    `department` String COMMENT '利润部门',

    `send_number` Decimal(18,
 4) COMMENT '赠送数量',

    `free_service_charge` Int8 COMMENT '该单是否免服务费'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(report_date)
PRIMARY KEY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
ORDER BY (mid,
 sid,
 saas_order_key,
 saas_order_no,
 no_)
SETTINGS index_granularity = 8192
COMMENT '口味做法明细';


-- dws_bill_by_area_name definition

CREATE TABLE bi.dws_bill_by_area_name
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
 4) COMMENT '实收金额'
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


-- dws_bill_by_checkout_time_name definition

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

    `paid_amount` Decimal(18,
 4) COMMENT '实收金额'
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


-- dws_bill_by_consumption definition

CREATE TABLE bi.dws_bill_by_consumption
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
 4) COMMENT '实收金额'
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


-- dws_bill_by_day definition

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

    `promotion_amount` Decimal(18,
 4) COMMENT '优惠金额',

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
 4) COMMENT '免掉的服务费'
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


-- dws_bill_by_duration definition

CREATE TABLE bi.dws_bill_by_duration
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
 4) COMMENT '实收金额'
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


-- dws_bill_by_hour definition

CREATE TABLE bi.dws_bill_by_hour
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
 4) COMMENT '实收金额'
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


-- dws_bill_by_order_sub_type definition

CREATE TABLE bi.dws_bill_by_order_sub_type
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
 4) COMMENT '实收金额'
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


-- dws_bill_by_price definition

CREATE TABLE bi.dws_bill_by_price
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
 4) COMMENT '实收金额'
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


-- dws_crm_activity definition

CREATE TABLE bi.dws_crm_activity
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


-- dws_crm_by_day definition

CREATE TABLE bi.dws_crm_by_day
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


-- dws_crm_card_summary definition

CREATE TABLE bi.dws_crm_card_summary
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


-- dws_crm_day_snapshoot definition

CREATE TABLE bi.dws_crm_day_snapshoot
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


-- dws_crm_day_summary definition

CREATE TABLE bi.dws_crm_day_summary
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


-- dws_crm_day_summary_with_sid definition

CREATE TABLE bi.dws_crm_day_summary_with_sid
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


-- dws_crm_income_of_store definition

CREATE TABLE bi.dws_crm_income_of_store
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


-- dws_crm_member_join_by_day definition

CREATE TABLE bi.dws_crm_member_join_by_day
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


-- dws_crm_settlement_of_store definition

CREATE TABLE bi.dws_crm_settlement_of_store
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


-- dws_crm_sex definition

CREATE TABLE bi.dws_crm_sex
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


-- dws_crm_summary definition

CREATE TABLE bi.dws_crm_summary
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


-- dws_department_by_day definition

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
 4) COMMENT '免掉的服务费'
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


-- dws_depart_sale_profit definition

CREATE TABLE bi.dws_depart_sale_profit
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


-- dws_food_by_cook definition

CREATE TABLE bi.dws_food_by_cook
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
 4) COMMENT '退菜数量'
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


-- dws_food_by_day definition

CREATE TABLE bi.dws_food_by_day
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

    `food_id` String COMMENT '菜品编号'
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


-- dws_food_by_day_crm definition

CREATE TABLE bi.dws_food_by_day_crm
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
 4) COMMENT '退菜数量'
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


-- dws_food_by_day_mid definition

CREATE TABLE bi.dws_food_by_day_mid
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

    `food_id` String COMMENT '菜品编号'
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


-- dws_food_category_by_day definition

CREATE TABLE bi.dws_food_category_by_day
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
 4) COMMENT '退菜数量'
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


-- dws_food_super_category_by_day definition

CREATE TABLE bi.dws_food_super_category_by_day
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
 4) COMMENT '退菜数量'
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


-- dws_pay_by_day definition

CREATE TABLE bi.dws_pay_by_day
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

    `false_revenue` Int8 COMMENT '是否虚收',

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


-- dws_pay_by_name definition

CREATE TABLE bi.dws_pay_by_name
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

    `count_` Int32 COMMENT '真实收入'
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


-- dws_pay_by_type definition

CREATE TABLE bi.dws_pay_by_type
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


-- dws_product_sale_profit definition

CREATE TABLE bi.dws_product_sale_profit
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


-- dwt_daily_by_day definition

CREATE TABLE bi.dwt_daily_by_day
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


-- export_record definition

CREATE TABLE bi.export_record
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `lid` Int64 COMMENT '逻辑编号',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `updated_time` DateTime DEFAULT now() COMMENT '更新时间',

    `report_date` DateTime COMMENT '营业日期',

    `done_time` DateTime COMMENT '导出完成时间',

    `state` Int8 COMMENT '状态',

    `path` String COMMENT 'oss存放路径',

    `description` String COMMENT '描述',

    `biz_clazz` String COMMENT '业务类名',

    `request` String COMMENT '请求参数',

    `created_by` String COMMENT '创建人',

    `updated_by` String COMMENT '更新人'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 lid)
ORDER BY (mid,
 lid)
SETTINGS index_granularity = 8192
COMMENT '报表导出记录';


-- fukuanqingkuang definition

CREATE TABLE bi.fukuanqingkuang
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '付款记录名称',

    `status_` String COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `counter` Int8 COMMENT '计数器',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `xiaofeid` Int64 COMMENT '所属消费单',

    `diancaipici` Int64 COMMENT '所属点菜批次',

    `fukuanqingkuangid` String COMMENT '编号',

    `fukuanqingkuangname` String COMMENT '支付方式',

    `zhifujine` Decimal(18,
 4) COMMENT '支付金额',

    `huilv` Decimal(18,
 4) COMMENT '汇率',

    `hsjine` Decimal(18,
 4) COMMENT '换算后的金额',

    `tuikuanjine` Decimal(18,
 4) COMMENT '退款金额',

    `zhenshishouru` Decimal(18,
 4) COMMENT '真实收入',

    `exchangable` Decimal(18,
 4) COMMENT '是否可以兑换',

    `type` String COMMENT '类型',

    `zhaohuijine` Decimal(18,
 4) COMMENT '找回金额',

    `shishoujine` Decimal(18,
 4) COMMENT '实收金额',

    `sumofintegrate` Decimal(18,
 4) COMMENT '积分',

    `huiyuankaid` String COMMENT '会员卡号',

    `huiyuanname` String COMMENT '会员名称',

    `guazhangid` String COMMENT '挂账账号',

    `guazhangname` String COMMENT '挂账账户名称',

    `qiandanren` String COMMENT '签单人',

    `returnbillid` String COMMENT '回款单号',

    `xianjinjuanid` String COMMENT '现金劵编号',

    `yujiaodingjinid` String COMMENT '订金单号',

    `shouyinyuan` String COMMENT '收银员',

    `billnumber` String COMMENT '对应的一卡易账单编号',

    `availablepoint` Decimal(18,
 4) COMMENT '消费后的积分',

    `availablevalue` Decimal(18,
 4) COMMENT '消费后的金额',

    `morememberkaid` String COMMENT '对会员卡卡号',

    `morememberid` String COMMENT '对会员编号',

    `moremembername` String COMMENT '对会员卡会员名称',

    `paymoney` Decimal(18,
 4) COMMENT '多会员卡支付金额',

    `norealincome` Int8 COMMENT '虚收',

    `shishoulv` Decimal(18,
 4) COMMENT '实收率',

    `xiaofeidanid` String COMMENT '所属消费单编号',

    `posserialno` String COMMENT 'pos机序列号',

    `paychanel` String COMMENT '支付通道',

    `payplatform` String COMMENT '支付平台',

    `paystatus` String COMMENT '支付状态',

    `shopname` String COMMENT '店名',

    `is_inline` Int8 COMMENT '是否为线上订单',

    `subject` String COMMENT '支付项目',

    `pidtmp` Int64 COMMENT '线下的PID',

    `shop_name` String COMMENT '店铺名称',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `order_sub_type` Int32 COMMENT '账单类型;堂食、外卖、自提',

    `shift_name` String COMMENT '班次',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `checkout_by` String COMMENT '收银员',

    `remark` String COMMENT '标记',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `checkout_time_name` String COMMENT '餐段',

    `free_service_charge` Int8 COMMENT '免服务费',

    `online` Int8 COMMENT '线上订单'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192;


-- jiaobanxinxi definition

CREATE TABLE bi.jiaobanxinxi
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '交班信息名称',

    `status_` Int32 COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `jiaobanhao` String COMMENT '交班号',

    `stationname` String COMMENT '计算机名称',

    `jiaobanrenname` String COMMENT '交班人名称',

    `alive` Int8 COMMENT '是否还在使用',

    `starttime` DateTime COMMENT '开始时间',

    `endtime` DateTime COMMENT '结束时间',

    `billnum` Int32 COMMENT '账单数',

    `sumofconsume` Decimal(18,
 4) COMMENT '消费合计',

    `sumofservice` Decimal(18,
 4) COMMENT '服务费合计',

    `sumofdiscount` Decimal(18,
 4) COMMENT '折扣合计',

    `sumofincome` Decimal(18,
 4) COMMENT '收入合计',

    `shijijine` Decimal(18,
 4) COMMENT '实际金额',

    `beiyongjin` Decimal(18,
 4) COMMENT '备用金',

    `printcount` Int32 COMMENT '打印次数',

    `upload` Int8 COMMENT '是否已经上传到总部',

    `stationid` String COMMENT '计算机编号',

    `jiaobanrenid` String COMMENT '交班人工号',

    `counter` Int8 COMMENT '计数器'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day,
 counter)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day,
 counter)
SETTINGS index_granularity = 8192
COMMENT '';


-- kouwei definition

CREATE TABLE bi.kouwei
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '口味名称',

    `status_` Int32 COMMENT '记录状态',

    `kouweiid` String COMMENT '编号',

    `kouweiname` String COMMENT '名称',

    `leixing` String COMMENT '口味类型',

    `counter` Int32 COMMENT '计数器',

    `yingyeriqi` DateTime COMMENT '营业日期',

    `created_time` DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid)
ORDER BY (company_id,
 shop_id,
 pid)
SETTINGS index_granularity = 8192
COMMENT '';


-- sc_product_sale_cost definition

CREATE TABLE bi.sc_product_sale_cost
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `mid` String COMMENT '集团编号',

    `sid` String COMMENT '门店编号',

    `shop_name` String COMMENT '门店名称',

    `report_date` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int32 COMMENT '月',

    `day` Int32 COMMENT '日',

    `lid` Int64 COMMENT '逻辑编号',

    `profit_lid` Int64 COMMENT '毛利表lid,
\r\n保留字段',

    `organ_lid` Int64 COMMENT '组织lid',

    `organ_name` String COMMENT '组织名称',

    `product_id` String COMMENT '商品id',

    `product_lid` Int64 COMMENT '商品lid',

    `product_name` String COMMENT '商品名称',

    `product_unit` String COMMENT '商品单位',

    `goods_lid` Int64 COMMENT '物品lid',

    `goods_name` String COMMENT '物品名称',

    `goods_unit` String COMMENT '物品单位',

    `goods_unit_lid` Int64 COMMENT '物品单位lid',

    `theory_volume` Decimal(18,
 4) COMMENT '理论用量',

    `actual_volume` Decimal(18,
 4) COMMENT '实际用量',

    `diff_volume` Decimal(18,
 4) COMMENT '用量差异',

    `theory_cost` Decimal(18,
 4) COMMENT '理论成本',

    `actual_cost` Decimal(18,
 4) COMMENT '实际成本',

    `wastage_cost` Decimal(18,
 4) COMMENT '耗损成本',

    `diff_cost` Decimal(18,
 4) COMMENT '成本差异',

    `revision` Int32 COMMENT '乐观锁',

    `created_by` String COMMENT '创建人',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `updated_by` String COMMENT '更新人',

    `updated_time` DateTime COMMENT '更新时间',

    `deleted` Int8 COMMENT '是否删除'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 sid,
 year,
 month,
 day,
 lid)
ORDER BY (mid,
 sid,
 year,
 month,
 day,
 lid)
SETTINGS index_granularity = 8192
COMMENT '菜品成本明细';


-- sms_send_record definition

CREATE TABLE bi.sms_send_record
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `mid` Int64 COMMENT '集团编号',

    `sid` Int64 COMMENT '门店编号',

    `lid` Int64 COMMENT '逻辑编号',

    `created_time` DateTime DEFAULT now() COMMENT '创建时间',

    `report_date` DateTime COMMENT '营业日期',

    `error_msg` String COMMENT '发送错误消息',

    `phone` String COMMENT '手机号',

    `content` String COMMENT '发送内容',

    `send` Int8 COMMENT '是否已经发送',

    `success` Int8 COMMENT '是否发送成功',

    `created_by` String COMMENT '创建人',

    `deleted` Int8 COMMENT '是否删除'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid,
 lid)
ORDER BY (mid,
 lid)
SETTINGS index_granularity = 8192
COMMENT '报表导出记录';


-- xiaofeicaiping definition

CREATE TABLE bi.xiaofeicaiping
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '消费商品名称',

    `status_` Int32 COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `xiaofeid` Int64 COMMENT '所属消费单',

    `diancaipici` Int64 COMMENT '所属点菜批次',

    `xiafeicaipingid` String COMMENT '菜号',

    `shopname` String COMMENT '店名',

    `xiafeicaipingname` String COMMENT '菜名',

    `diancaicanduanid` String COMMENT '点菜时的餐段编号',

    `diancaicanduanname` String COMMENT '点菜时的餐段名称',

    `xiaoleiid` String COMMENT '菜品小类id',

    `xiaolei` String COMMENT '菜品小类名称',

    `daleiid` String COMMENT '菜品大类id',

    `dalei` String COMMENT '菜品大类名称',

    `zuofa` String COMMENT '做法',

    `jifenduihuan` Int8 COMMENT '积分兑换',

    `zengsong` Int8 COMMENT '赠送',

    `zengsongren` String COMMENT '赠送人',

    `zengsongyuanyin` String COMMENT '赠送原因',

    `diancaishuliang` Decimal(18,
 4) COMMENT '点菜数量',

    `shangcaishijian` DateTime COMMENT '上菜时间',

    `yilingqushuliang` Decimal(18,
 4) COMMENT '已领取数量',

    `yishangcaishuliang` Decimal(18,
 4) COMMENT '已上菜数量',

    `tuicaishuliang` Decimal(18,
 4) COMMENT '退菜数量',

    `tuicaishijian` DateTime COMMENT '退菜时间',

    `tuicairen` String COMMENT '退菜人',

    `xiaofeishuliang` Decimal(18,
 4) COMMENT '实际消费数量',

    `tuicaijine` Decimal(18,
 4) COMMENT '退菜金额',

    `xiaohaojifen` Decimal(18,
 4) COMMENT '消耗积分',

    `zengsongjine` Decimal(18,
 4) COMMENT '赠送金额',

    `shipinfei` Decimal(18,
 4) COMMENT '食品费',

    `jiagongfei` Decimal(18,
 4) COMMENT '加工费',

    `shipinfuwufei` Decimal(18,
 4) COMMENT '食品服务费',

    `jiagongfuwufei` Decimal(18,
 4) COMMENT '加工服务费',

    `shipinzhekuoe` Decimal(18,
 4) COMMENT '食品费折扣额',

    `jiagongzhekuoe` Decimal(18,
 4) COMMENT '加工费折扣额',

    `yuancailiaodangechengben` Decimal(18,
 4) COMMENT '单个物品成本',

    `yuancailiaozongchengben` Decimal(18,
 4) COMMENT '物品总成本',

    `jiagongchengben` Decimal(18,
 4) COMMENT '加工成本',

    `danwei` String COMMENT '单位',

    `nobillingunit` String COMMENT '不参与计费的单位',

    `nobillingamount` Decimal(18,
 4) COMMENT '不参与计费的数量',

    `jibendanwei` String COMMENT '基本单位',

    `danweibilv` Decimal(18,
 4) COMMENT '基于基本单位的比率',

    `jiage` Decimal(18,
 4) COMMENT '价格',

    `yuanshijiage` Decimal(18,
 4) COMMENT '原始价格',

    `shifa` String COMMENT '食法',

    `diancairen` String COMMENT '点菜人',

    `dangeticheng` Decimal(18,
 4) COMMENT '单个销售提成',

    `zongticheng` Decimal(18,
 4) COMMENT '总提成',

    `tuicaiyuanyin` String COMMENT '退菜原因',

    `sfquerenshuliang` Int8 COMMENT '是否已确认数量',

    `shuliangquerenyuan` String COMMENT '数量确认员',

    `diancaishijian` DateTime COMMENT '点菜时间',

    `xiadanshijian` DateTime COMMENT '下单时间',

    `overtime` Int32 COMMENT '制作超时时间',

    `cuicairenshijian` String COMMENT '催菜人',

    `caipinginzhuotai` String COMMENT '菜品所在的桌台',

    `precaipinginzhuotai` String COMMENT '菜品先前所在的桌台',

    `zhuantaishuliang` Decimal(18,
 4) COMMENT '转台数量',

    `bumen` String COMMENT '该消费菜品的利润归属部门',

    `chupingbumen` String COMMENT '该消费菜品的出品部门',

    `chupingbumenorg` String COMMENT '该消费菜品的出品部门（原始）',

    `pricemoder` String COMMENT '价格修改人',

    `pricemodtime` DateTime COMMENT '价格修改时间',

    `shougonggaijia` Int8 COMMENT '是否手工修改过价格',

    `renamedtime` DateTime COMMENT '修改菜名时间',

    `namemoder` String COMMENT '菜名修改人',

    `renamed` Int8 COMMENT '是否修改过菜名',

    `chushi` String COMMENT '厨师',

    `maincai` Int64 COMMENT '作为套餐时的所属主菜',

    `fenchengqianjiage` Decimal(18,
 4) COMMENT '套餐分成前价格',

    `idxinbill` Int32 COMMENT '在单中的索引',

    `peicaimaincai` Int32 COMMENT '作为配菜时的所属主菜',

    `zhekoulv` Decimal(18,
 4) COMMENT '折扣率',

    `dazheren` String COMMENT '打折人',

    `dazhebyman` Int8 COMMENT '人为折扣',

    `mensetdiscount` Int8 COMMENT '是否直接设定折扣额',

    `canyizuidixiaofei` Int8 COMMENT '参与最低消费',

    `paid` Int8 COMMENT '是否已经付款',

    `rendian` Int8 COMMENT '是否为任点菜',

    `orgpid` Int64 COMMENT '在原始单中的pid',

    `xishu` Int32 COMMENT '席数',

    `isjiuxi` Int8 COMMENT '是否为酒席菜',

    `autosubwarehouse` Int64 COMMENT '自动销售扣减仓库的pid',

    `autosubbumem` Int64 COMMENT '自动销售利润归属部门的pid',

    `subbumen` Int8 COMMENT '扣减部门',

    `autosale` Int8 COMMENT '自动销售出库',

    `subed` Int8 COMMENT '已经扣减',

    `prnidx` Int32 COMMENT '点菜顺序',

    `prnsum` Int32 COMMENT '点菜总数',

    `fuzhutaihao` String COMMENT '辅助台号',

    `fuzhutaiming` String COMMENT '辅助台名',

    `songdanidx` Int32 COMMENT '送单流水号',

    `tichengren` String COMMENT '提成人',

    `tichengpercent` Decimal(18,
 4) COMMENT '单个提成百分比',

    `istichengper` Int8 COMMENT '使用百分比提成',

    `yufu` Int8 COMMENT '预付',

    `orderbypad` Int8 COMMENT '从移动端点的菜品',

    `strzf1` String COMMENT '做法1',

    `chengbengjia` Decimal(18,
 4) COMMENT '成本价',

    `istejiacai` Int8 COMMENT '是否为特价菜',

    `orderwsid` String COMMENT '点菜电脑编号',

    `orderwsname` String COMMENT '点菜电脑名称',

    `yichulibanjia` Int8 COMMENT '已经处理第几杯半价',

    `xiaofeidanid` String COMMENT '所属消费单编号',

    `caipingtype` Int32 COMMENT '菜品类型',

    `saletaxlv` Int32 COMMENT '消费税率',

    `saletaxjine` Decimal(18,
 4) COMMENT '消费税金额',

    `factory_brand` String COMMENT '厂家品牌',

    `factory_brand_code` String COMMENT '厂家品牌编号',

    `memberid` String COMMENT '会员编号(id)',

    `memberlmnid` String COMMENT '会员lmnid',

    `membername` String COMMENT '会员姓名',

    `membersex` String COMMENT '会员性别',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` String COMMENT '会员卡类型编号',

    `card_type_level` String COMMENT '会员卡等级',

    `card_type_level_code` String COMMENT '会员卡等级编号',

    `cardlmnid` String COMMENT '会员卡lmnid',

    `huiyuancahao` String COMMENT '会员卡号',

    `marketing_plan` String COMMENT '营销内容',

    `item_number` String COMMENT '货号',

    `is_offline` Int8 COMMENT '是否为线下已点菜',

    `is_inline` Int8 COMMENT '是否为线上订单',

    `upload_time` DateTime COMMENT '上传时间',

    `additionalcost` Decimal(18,
 4) COMMENT '加收费用',

    `counter` Int8 COMMENT '计数器',

    `shop_name` String COMMENT '店铺名称',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `order_sub_type` Int32 COMMENT '账单类型;堂食、外卖、自提',

    `shift_name` String COMMENT '班次',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `checkout_by` String COMMENT '收银员',

    `remark` String COMMENT '标记',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `checkout_time_name` String COMMENT '餐段',

    `free_service_charge` Int8 COMMENT '免服务费',

    `online` Int8 COMMENT '线上订单',

    `promotion_amount` Decimal(19,
 10) COMMENT '优惠金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192;


-- xiaofeidan definition

CREATE TABLE bi.xiaofeidan
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '消费账单名称',

    `status_` Int32 COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `sum_of_cost` Decimal(18,
 4) COMMENT '成本总价',

    `sum_of_org_price` Decimal(18,
 4) COMMENT '原始总价',

    `xiaofeidanid` String COMMENT '编号',

    `xiaofeidanname` String COMMENT '名称',

    `taihao` String COMMENT '桌台号',

    `taiming` String COMMENT '桌台名',

    `taiquhao` String COMMENT '台区号',

    `taiquming` String COMMENT '台区名',

    `canduan` String COMMENT '餐段',

    `canduanid` String COMMENT '餐段编号',

    `renshu` Int8 COMMENT '人数',

    `yanchidanhao` String COMMENT '原始单号',

    `kaitaishijian` DateTime COMMENT '开台时间',

    `firstjiezhangshijian` DateTime COMMENT '第一次结账时间',

    `jiezhangshijian` DateTime COMMENT '结账时间',

    `booktime` DateTime COMMENT '预订时间',

    `kaitairen` String COMMENT '开台人',

    `maidanren` String COMMENT '埋单人',

    `maidanshijian` DateTime COMMENT '埋单时间',

    `shouyinren` String COMMENT '收银人',

    `yewuyuan` String COMMENT '业务员',

    `rendiancha` Decimal(18,
 4) COMMENT '任点菜差额',

    `tuicaijine` Decimal(18,
 4) COMMENT '退菜金额',

    `zengsongjine` Decimal(18,
 4) COMMENT '赠送金额',

    `fuwufeilv` Decimal(18,
 4) COMMENT '服务费率',

    `dazheren` String COMMENT '打折人',

    `dazhefangshi` String COMMENT '打折方式',

    `zhekoulv` Decimal(18,
 4) COMMENT '打折率',

    `membertypeid` String COMMENT '会员类型编号',

    `membertypename` String COMMENT '会员类型名称',

    `memberid` String COMMENT '会员编号(id)',

    `memberlmnid` Int64 COMMENT '会员lmnid',

    `membername` String COMMENT '会员姓名',

    `membersex` String COMMENT '会员性别',

    `card_type` String COMMENT '会员卡类型',

    `card_type_code` String COMMENT '会员卡类型编号',

    `card_type_level` String COMMENT '会员卡等级',

    `card_type_level_code` Int64 COMMENT '会员卡等级编号',

    `cardlmnid` Int64 COMMENT '会员卡lmnid',

    `huiyuancahao` String COMMENT '会员卡号',

    `huiyuanbalance` Decimal(18,
 4) COMMENT '会员账户余额',

    `huiyuanintegral` Decimal(18,
 4) COMMENT '会员积分余额',

    `mianfuwufei` Int8 COMMENT '免收服务费',

    `miandiaofuwufei` Decimal(18,
 4) COMMENT '免掉的服务费',

    `shipingfei` Decimal(18,
 4) COMMENT '食品费',

    `fuwufei` Decimal(18,
 4) COMMENT '服务费',

    `zhekoue` Decimal(18,
 4) COMMENT '折扣额',

    `weishu` Decimal(18,
 4) COMMENT '尾数',

    `lingtou` Decimal(18,
 4) COMMENT '零头',

    `lingtouor` String COMMENT '零头调整人',

    `fanjiezhangren` String COMMENT '反结账人员',

    `fanjiezhangshijian` DateTime COMMENT '反结账时间',

    `zuidixiaofei` Decimal(18,
 4) COMMENT '最低消费',

    `zuidixiaofeicha` Decimal(18,
 4) COMMENT '最低消费与应收的差额',

    `quxiaozdxf` Int8 COMMENT '取消最低消费',

    `quxiaozdxfor` String COMMENT '取消最低消费人员',

    `taxrate` Decimal(18,
 4) COMMENT '地税税率',

    `tax` Decimal(18,
 4) COMMENT '地税税额',

    `statetaxrate` Decimal(18,
 4) COMMENT '国税税率',

    `statetax` Decimal(18,
 4) COMMENT '国税税额',

    `yingshoujine` Decimal(18,
 4) COMMENT '应收金额',

    `shishoujine` Decimal(18,
 4) COMMENT '实收金额',

    `shoudaojine` Decimal(18,
 4) COMMENT '收到客户的金额',

    `zhaohuijine` Decimal(18,
 4) COMMENT '找回给客户的金额',

    `fapiaojine` Decimal(18,
 4) COMMENT '发票金额',

    `maidancishu` Int8 COMMENT '埋单次数',

    `maidanzhuangtai` String COMMENT '埋单状态',

    `pretable` String COMMENT '原先台名',

    `lastcaozuoren` String COMMENT '最后操作人',

    `lastaction` String COMMENT '最后操作的动作',

    `printcount` Int8 COMMENT '打印次数',

    `jiaobanhao` String COMMENT '交班号',

    `firststationid` String COMMENT '第一次结账的计算机编号',

    `stationid` String COMMENT '计算机编号',

    `stationname` String COMMENT '计算机名称',

    `kaitaistationid` String COMMENT '计算机编号',

    `kaitaistationname` String COMMENT '计算机名称',

    `jiezhangfangshi` String COMMENT '结账方式',

    `booktype` String COMMENT '预订类型',

    `bookbilltype` String COMMENT '预订单类型',

    `xinkaitai` Int8 COMMENT '是否为新开台',

    `isorder` Int8 COMMENT '是否为预订单',

    `beizhu` String COMMENT '备注',

    `orderbillid` String COMMENT '对应的预订单编号',

    `alltblname` String COMMENT '对应的多个台名',

    `xishu` Int32 COMMENT '席数',

    `isjiuxi` Int8 COMMENT '是否为酒席',

    `danxijine` Decimal(18,
 4) COMMENT '单席金额',

    `jiuxijine` Decimal(18,
 4) COMMENT '酒席金额',

    `jiuxidingjin` Decimal(18,
 4) COMMENT '酒席订金',

    `bulu` Int8 COMMENT '补录单',

    `shopname` String COMMENT '店名',

    `songcanaddr` String COMMENT '送餐地址',

    `songcanjifen` Decimal(18,
 4) COMMENT '送餐积分',

    `songcanphone` String COMMENT '送餐电话',

    `songcanren` String COMMENT '送餐人',

    `diancanrenunionid` String COMMENT '点餐人标识',

    `dingcanren` String COMMENT '订餐人',

    `songcanshijian` DateTime COMMENT '送餐时间',

    `youhuihuodongid` String COMMENT '优惠活动编号',

    `youhuihuodongname` String COMMENT '优惠活动名称',

    `youhuijine` Decimal(18,
 4) COMMENT '优惠金额',

    `qtmodel` String COMMENT '前台模式',

    `shangzhongshijian` DateTime COMMENT '上钟时间',

    `luozhongshijian` DateTime COMMENT '落钟时间',

    `jishijine` Decimal(18,
 4) COMMENT '计时计价金额',

    `isshoudongzhekou` Int8 COMMENT '是否手动打折',

    `songcantuicai` Int8 COMMENT '送餐退菜标志',

    `kaitaiyushouyajin` Decimal(18,
 4) COMMENT '开台预收押金',

    `buffetid` String COMMENT '自助餐编号',

    `buffetname` String COMMENT '自助餐名称',

    `buffetdazhe` Int8 COMMENT '自助餐参与打折',

    `buffetamount` Decimal(18,
 4) COMMENT '自助餐数量',

    `buffetprice` Decimal(18,
 4) COMMENT '自助餐价格',

    `buffetmoney` Decimal(18,
 4) COMMENT '自助餐价格',

    `jifenjishu` Decimal(18,
 4) COMMENT '积分基数',

    `jifene` Decimal(18,
 4) COMMENT '积分额/基数',

    `alpay_out_trade_no` String COMMENT '支付宝交易号',

    `alpay_finish` Int8 COMMENT '支付宝交易号',

    `billprntype` String COMMENT '打印单据类型',

    `jishizhekoue` Decimal(18,
 4) COMMENT '计时计价折扣额',

    `youhuijuanchae` Decimal(18,
 4) COMMENT '优惠劵差额',

    `fapiaodanhao` String COMMENT '发票单号',

    `bucanyudazhejine` Decimal(18,
 4) COMMENT '不参与打折的金额',

    `msgdealstate` Int32 COMMENT '消息处理状态',

    `dealstate` Int32 COMMENT '业务处理状态',

    `wmptbillid` String COMMENT '外卖平台单号',

    `manjianjine` Decimal(18,
 4) COMMENT '满减金额',

    `dantype` String COMMENT '订单类型',

    `tips` Decimal(18,
 4) COMMENT '小费',

    `xjtips` Decimal(18,
 4) COMMENT '结账后现金小费',

    `xyktips` Decimal(18,
 4) COMMENT '结账后信用卡小费',

    `wmptdaynum` Int32 COMMENT '外卖单顺序号',

    `additionalcost` Decimal(18,
 4) COMMENT '加收费用',

    `notax` Int8 COMMENT '是否免税',

    `additionalchargecp` Decimal(18,
 4) COMMENT '菜品加收费用',

    `payxfdtype` Int32 COMMENT '订单支付类型',

    `danmode` Int32 COMMENT '订单支付类型',

    `pickupcode` Int32 COMMENT '取货随机码',

    `viewmode` Int32 COMMENT '查看模式',

    `is_inline` Int8 COMMENT '是否为线上订单',

    `uploadtosaas` Int8 COMMENT '上传至saas服务器',

    `counter` Int8 COMMENT '计数器',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `takeout_channel_order_number` String COMMENT '外卖渠道单号',

    `takeout_order_amount` Decimal(19,
 10) COMMENT '订单总金额',

    `commission_amount` Decimal(19,
 10) COMMENT '佣金金额',

    `business_amount` Decimal(19,
 10) COMMENT '商家应收金额',

    `favourable_amount` Decimal(19,
 10) COMMENT '优惠总金额（商家承担+平台承担+商家替用户承担的配送费用）',

    `business_favourable_amount` Decimal(19,
 10) COMMENT '商家承担金额',

    `platform_favourable_amount` Decimal(19,
 10) COMMENT '平台承担金额',

    `businesses_deliveryroute_fees` Decimal(19,
 10) COMMENT '商家替用户承担的配送费用',

    `delivery_amount` Decimal(19,
 10) COMMENT '配送费',

    `box_amount` Decimal(19,
 10) COMMENT '打包盒金额',

    `takeout_pay_amount` Decimal(19,
 10) COMMENT '支付金额'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192;


-- yaoqiuinshifa definition

CREATE TABLE bi.yaoqiuinshifa
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '要求名称',

    `status_` Int8 COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `shifa` Int64 COMMENT '所属食法',

    `xiaofeidanid` String COMMENT '所属消费单编号',

    `xiaofeicaipingid` Int64 COMMENT '所属消费菜编号',

    `xiaofeicaipingpid` Int64 COMMENT '所属消费菜pid',

    `counter` Int8 COMMENT '计数器',

    `pidtmp` Int64 COMMENT '线下的PID'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192
COMMENT '';


-- zuofainshifa definition

CREATE TABLE bi.zuofainshifa
(

    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',

    `op` String COMMENT '操作类型',

    `ts_ms` Int64 COMMENT '更新时间',

    `company_id` Int64,

    `shop_id` Int64,

    `pid` Int64,

    `id` String,

    `lmnid` Int64 COMMENT 'lmn内部编号',

    `name` String COMMENT '做法名称',

    `status_` Int8 COMMENT '记录状态',

    `created_time` DateTime DEFAULT now(),

    `yingyeriqi` DateTime COMMENT '营业日期',

    `year` Int32 COMMENT '年',

    `month` Int8 COMMENT '月',

    `day` Int8 COMMENT '日',

    `caipingzuofapid` String COMMENT '做法pid',

    `caipingzuofaid` String COMMENT '做法id',

    `jiage` Decimal(18,
 4) COMMENT '附加价格',

    `chengbendanjia` Decimal(18,
 4) COMMENT '成本单价',

    `selfamount` Decimal(18,
 4) COMMENT '自身数量',

    `yaochengyushuliang` Int8 COMMENT '要确认菜品数量',

    `shufuwufei` Int8 COMMENT '要服务费',

    `canyidazhe` Int8 COMMENT '参与打折',

    `ishandwrited` Int8 COMMENT '是否为手写做法',

    `writer` String COMMENT '手写做法输入人',

    `bumen` String COMMENT '利润归属部门',

    `jiagongfei` Decimal(18,
 4) COMMENT '加工费(单价乘以数量)',

    `chengbenzongjia` Decimal(18,
 4) COMMENT '成本总价(单价乘以数量)',

    `fuwufei` Decimal(18,
 4) COMMENT '服务费',

    `biaoqian` String COMMENT '标签',

    `biaoqianpid` String COMMENT '标签pid',

    `biaoqianid` String COMMENT '标签id',

    `zhekoue` Decimal(18,
 4) COMMENT '折扣额',

    `unit` String COMMENT '单位',

    `chupingbumen` String COMMENT '该消费菜品的出品部门',

    `isyaoqiu` Int8 COMMENT '是否为要求',

    `xiaofeidanid` String COMMENT '所属消费单编号',

    `xiaofeicaipingid` String COMMENT '所属消费菜编号',

    `xiaofeicaipingpid` String COMMENT '所属消费菜pid',

    `counter` Int8 COMMENT '计数器',

    `shifa` Int64 COMMENT '食法',

    `shop_name` String COMMENT '店铺名称',

    `start_time` DateTime COMMENT '开台时间',

    `checkout_time` DateTime COMMENT '结账时间',

    `order_sub_type` Int32 COMMENT '账单类型;堂食、外卖、自提',

    `shift_name` String COMMENT '班次',

    `area_name` String COMMENT '区域名称',

    `table_name` String COMMENT '桌台名称',

    `checkout_by` String COMMENT '收银员',

    `remark` String COMMENT '标记',

    `saas_order_no` Int64 COMMENT '账单流水号',

    `takeout_channel` Int32 COMMENT '外卖渠道',

    `checkout_time_name` String COMMENT '餐段',

    `free_service_charge` Int8 COMMENT '免服务费',

    `online` Int8 COMMENT '线上订单',

    `department` String COMMENT '部门',

    `send_number` Decimal(19,
 10) COMMENT '赠送数量'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMMDD(yingyeriqi)
PRIMARY KEY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
ORDER BY (company_id,
 shop_id,
 pid,
 year,
 month,
 day)
SETTINGS index_granularity = 8192;