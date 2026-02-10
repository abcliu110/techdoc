-- ====================================
-- 数据库创建脚本 - a_order
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_order` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_order`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_order

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:40:15
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for order_bill
-- ----------------------------
DROP TABLE IF EXISTS `order_bill`;
CREATE TABLE `order_bill`  (
  `mid` bigint NOT NULL COMMENT '商户编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `report_date` datetime NOT NULL COMMENT '日期',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单号',
  `lid` bigint NOT NULL COMMENT '账单流水号',
  `person_num` int NULL DEFAULT NULL COMMENT '客流',
  `food_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '流水金额',
  `discount_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣额',
  `service_charge_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '服务费',
  `fraction` decimal(24, 6) NULL DEFAULT NULL COMMENT '零头',
  `mantissa` decimal(24, 6) NULL DEFAULT NULL COMMENT '尾数',
  `timing_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '计时金额',
  `timing_discount_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '计时折扣额',
  `timing_service_charge_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '计时服务费',
  `overcharge_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '多收金额',
  `less_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '少收金额',
  `promotion_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '优惠金额',
  `paid_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实收金额',
  `cancel_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '退菜金额',
  `send_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送金额',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `checkout_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收银员',
  `checkout_time_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐段',
  `duration` bigint NULL DEFAULT NULL COMMENT '消费时长(毫秒)',
  `shift_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '班次',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型;堂食、外卖、自提',
  `channel_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '渠道',
  `area_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '桌台号',
  `table_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `create_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开台人员',
  `table_leader` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '桌台负责人',
  `waiter_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务员',
  `channel_order_key_t_p` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '三方单号',
  `device_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备编号',
  `device_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备名称',
  `discount_range` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '折扣方式',
  `discount_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣率',
  `discount_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '打折人',
  `service_charge_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '服务率',
  `fraction_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '零头调整人',
  `fjz_count` int NULL DEFAULT NULL COMMENT '反结账次数',
  `invoice_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '发票金额',
  `invoice_title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票抬头',
  `is_vip_price` tinyint(1) NULL DEFAULT NULL COMMENT '使用了会员价',
  `card_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员类型',
  `card_level` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员等级',
  `card_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `saas_order_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `order_type` int NULL DEFAULT NULL COMMENT '账单类型;快餐、酒楼、酒吧',
  `order_status` int NULL DEFAULT NULL COMMENT '状态状态',
  `num_of_jiu_xi` decimal(24, 6) NULL DEFAULT NULL COMMENT '席数',
  `single_jiu_xi_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '单席金额',
  `jiu_xi_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '酒席金额',
  `is_jiu_xi` tinyint(1) NULL DEFAULT NULL COMMENT '酒席单',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '标记',
  `jiu_xi_order_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '酒席订金',
  `card_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '食品卡号',
  `org_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '线下原订单号',
  `pay_type` int NULL DEFAULT NULL COMMENT '支付模式（1后付，0先付）',
  `out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付平台订单号',
  `phone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `open_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'open_id',
  `confirm_status` int NULL DEFAULT NULL COMMENT '确认状态',
  `has_free` tinyint NULL DEFAULT 0 COMMENT '是否有免赠',
  `cust_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `cust_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人手机号',
  `cust_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人地址',
  `delivery_fee` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送费',
  `packing_fee` decimal(24, 6) NULL DEFAULT NULL COMMENT '打包费',
  `self_pick_up_time` datetime NULL DEFAULT NULL COMMENT '自提时间',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡lid',
  `org_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '原价合计',
  `evaluated` tinyint(1) NOT NULL DEFAULT 0 COMMENT '已评价',
  `eval_lid` bigint NOT NULL DEFAULT -1 COMMENT '评价lid',
  `pick_number` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取餐号',
  `order_making_status` int NULL DEFAULT 1 COMMENT '制作状态',
  `discount_lid` bigint NULL DEFAULT NULL COMMENT '折扣lid',
  `buffet_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自助餐id',
  `buffet_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '自助餐名称',
  `buffet_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '自助餐数量',
  `coupon_items` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '智简券抵金额原始列表',
  `product_items` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '智简券商品原始列表',
  `product_coupon_items` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '智简券商品平分金额原始列表',
  PRIMARY KEY (`lid`) USING BTREE,
  INDEX `idx_mid_sid_saas_key`(`mid` ASC, `sid` ASC, `saas_order_key` ASC) USING BTREE,
  INDEX `idx_mid_sid_report_date`(`mid` ASC, `sid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_sid_lid`(`mid` ASC, `sid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `order_bill_mid_IDX`(`mid` ASC, `open_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '账单明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_comment
-- ----------------------------
DROP TABLE IF EXISTS `order_comment`;
CREATE TABLE `order_comment`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `user_id` bigint NULL DEFAULT NULL COMMENT '评价人的用户编号',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价人名称',
  `user_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户手机号',
  `card_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户卡号',
  `user_avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价人头像',
  `anonymous` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否匿名',
  `order_id` bigint NOT NULL COMMENT '订单编号',
  `scores` int NOT NULL COMMENT '综合评分',
  `taste_scores` decimal(24, 6) NOT NULL COMMENT '口味',
  `env_scores` decimal(24, 6) NOT NULL COMMENT '环境',
  `performance_scores` decimal(24, 6) NOT NULL COMMENT '性价比',
  `benefit_scores` decimal(24, 6) NOT NULL COMMENT '商家服务',
  `description_scores` decimal(24, 6) NOT NULL COMMENT '描述相符',
  `content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评价内容',
  `pic_urls` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评价图片地址数组',
  `visible` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否可见',
  `reply_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '商家是否回复',
  `reply_user_id` bigint NULL DEFAULT NULL COMMENT '回复管理员编号',
  `reply_user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复管理员名称',
  `reply_content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商家回复内容',
  `reply_time` datetime NULL DEFAULT NULL COMMENT '商家回复时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '线下账单编号',
  `table_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '桌台号',
  `open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户openid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_order_lid`(`mid` ASC, `report_date` ASC, `order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3919 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单评价' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_food
-- ----------------------------
DROP TABLE IF EXISTS `order_food`;
CREATE TABLE `order_food`  (
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `lid` bigint NOT NULL COMMENT '流水号',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单号',
  `saas_order_no` bigint NOT NULL COMMENT '账单流水号',
  `food_no` bigint NULL DEFAULT NULL COMMENT '菜品标识',
  `food_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品编码',
  `food_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品名称',
  `food_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格',
  `ordering_time` datetime NULL DEFAULT NULL COMMENT '点菜时间',
  `ordered_time` datetime NULL DEFAULT NULL COMMENT '上菜时间',
  `cook_duration` bigint NULL DEFAULT NULL COMMENT '制作时长（毫秒）',
  `cook` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '厨师',
  `food_pro_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '售价',
  `food_org_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '原价',
  `food_number` decimal(24, 6) NULL DEFAULT NULL COMMENT '流水数量',
  `send_number` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送数量',
  `unit_adjutant_number` decimal(24, 6) NULL DEFAULT NULL COMMENT '辅助数量',
  `food_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '流水金额',
  `service_charge_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '服务费',
  `discount_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣额',
  `discount_range` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '打折方式',
  `food_discount_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣率',
  `processing_fee` decimal(24, 6) NULL DEFAULT NULL COMMENT '加工费',
  `processing_fee_discount` decimal(24, 6) NULL DEFAULT NULL COMMENT '加工费折扣额',
  `processing_fee_service` decimal(24, 6) NULL DEFAULT NULL COMMENT '加工费服务费',
  `promotion_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '优惠金额',
  `paid_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实收金额',
  `department_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '出品部门',
  `food_subject_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品收入科目',
  `channel_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '渠道',
  `food_taste` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '口味',
  `food_practice` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '做法',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '班次',
  `order_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '点菜人',
  `remark` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `food_remark` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐段',
  `send_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠送人',
  `send_for` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠送原因',
  `send_time` datetime NULL DEFAULT NULL COMMENT '赠送时间',
  `cancel_number` decimal(24, 6) NULL DEFAULT NULL COMMENT '退菜数量',
  `cancel_for` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退菜原因',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退菜人',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '退菜时间',
  `is_rename` tinyint(1) NULL DEFAULT NULL COMMENT '修改过菜名',
  `rename_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜名修改人',
  `is_mod_price` tinyint(1) NULL DEFAULT NULL COMMENT '修改过价格',
  `mod_price_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '价格修改人',
  `mode_price_time` datetime NULL DEFAULT NULL COMMENT '改价时间',
  `discount_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣率',
  `discount_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '打折人',
  `is_jiu_xi` tinyint(1) NULL DEFAULT NULL COMMENT '酒席菜',
  `food_type_code` bigint NULL DEFAULT NULL COMMENT '菜品小类编号',
  `food_main_code` bigint NULL DEFAULT NULL COMMENT '主菜编号',
  `coupon_no` bigint NULL DEFAULT NULL COMMENT '优惠券编号',
  `auto_order` tinyint(1) NULL DEFAULT 0 COMMENT '自动点菜',
  `by_person` tinyint(1) NULL DEFAULT 0 COMMENT '跟人数有关',
  `packing_fee` decimal(24, 6) NULL DEFAULT NULL COMMENT '打包费',
  `enable_give_balance` tinyint(1) NOT NULL DEFAULT 1 COMMENT '能使用赠送余额',
  `spec_x_price` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否第X份特价',
  `food_image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片地址',
  PRIMARY KEY (`lid`) USING BTREE,
  INDEX `idx_mid_sid_saas_key`(`mid` ASC, `sid` ASC, `saas_order_key` ASC) USING BTREE,
  INDEX `idx_mid_sid_report_date`(`mid` ASC, `sid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_sid_lid`(`mid` ASC, `sid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_saas_no`(`mid` ASC, `sid` ASC, `saas_order_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品销售明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_free_food_record
-- ----------------------------
DROP TABLE IF EXISTS `order_free_food_record`;
CREATE TABLE `order_free_food_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '卡lid',
  `order_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单id',
  `dish_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品名称',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品lid',
  `dish_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品单位',
  `dish_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '菜品价格',
  `dish_num` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送数量',
  `is_valid` tinyint(1) NULL DEFAULT NULL COMMENT '是否有效的',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_card_lid`(`mid` ASC, `card_lid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_order_id`(`mid` ASC, `sid` ASC, `order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单免赠记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_pay
-- ----------------------------
DROP TABLE IF EXISTS `order_pay`;
CREATE TABLE `order_pay`  (
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单号',
  `saas_order_no` bigint NOT NULL COMMENT '账单流水号',
  `lid` bigint NOT NULL COMMENT '流水号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付方式编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付方式名称',
  `type` int NULL DEFAULT NULL COMMENT '支付类型',
  `pay_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '支付金额',
  `exchange_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '找回金额',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实收金额',
  `is_real_income` tinyint(1) NULL DEFAULT NULL COMMENT '真实收入',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '班次',
  `checkout_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收银员',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '餐段',
  `coupon_no` bigint NULL DEFAULT NULL COMMENT '优惠券编号',
  `task_lid` bigint NULL DEFAULT NULL COMMENT '任务编号',
  `give_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送金额',
  `deleted` tinyint(1) NULL DEFAULT NULL COMMENT '是否删除',
  `use_give` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否赠送',
  `points_task_lid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '积分流水号',
  `points` decimal(24, 9) NULL DEFAULT NULL COMMENT '本次扣款积分',
  `card_balance_before` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款前余额',
  `card_principal_before` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款前本金',
  `card_give_before` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款前赠送',
  `card_point_before` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款前积分',
  `card_balance_after` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款后余额',
  `card_principal_after` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款后本金',
  `card_give_after` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款后赠送',
  `card_point_after` decimal(24, 9) NULL DEFAULT NULL COMMENT '扣款后积分',
  `coupons` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '优惠券列表',
  PRIMARY KEY (`lid`) USING BTREE,
  INDEX `idx_mid_sid_saas_key`(`mid` ASC, `sid` ASC, `saas_order_key` ASC) USING BTREE,
  INDEX `idx_mid_sid_report_date`(`mid` ASC, `sid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_sid_lid`(`mid` ASC, `sid` ASC, `report_date` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_saas_no`(`mid` ASC, `sid` ASC, `saas_order_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_rebate
-- ----------------------------
DROP TABLE IF EXISTS `order_rebate`;
CREATE TABLE `order_rebate`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `share_lid` bigint NOT NULL COMMENT '分享lid',
  `rebate` decimal(24, 6) NOT NULL COMMENT '返佣金额',
  `rebate_card_lid` bigint NOT NULL COMMENT '返佣卡lid',
  `rebate_user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣人',
  `rebate_card_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '返佣卡号',
  `rebate_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣手机号',
  `rebate_open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '返佣人openId',
  `open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '下单人openId',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下单人名称',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '下单人卡lid',
  `card_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下单人卡号',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '下单人手机号',
  `order_lid` bigint NOT NULL COMMENT '订单lid',
  `dish_lid` bigint NOT NULL COMMENT '商品lid',
  `dish_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品名',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_share_lid`(`mid` ASC, `sid` ASC, `share_lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_rebate_card_lid`(`mid` ASC, `sid` ASC, `rebate_card_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品返佣记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for order_taste
-- ----------------------------
DROP TABLE IF EXISTS `order_taste`;
CREATE TABLE `order_taste`  (
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `lid` bigint NOT NULL COMMENT '流水号',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `saas_order_no` bigint NOT NULL COMMENT '订单流水号',
  `food_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品',
  `taste_no` bigint NULL DEFAULT NULL COMMENT '做法编号',
  `food_no` bigint NULL DEFAULT NULL COMMENT '菜品流水号',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格',
  `adjutant_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '辅助规格',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `number` decimal(24, 6) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '价格',
  `taste_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '费用',
  `discount_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '折扣额',
  `service_charge_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '服务费',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实际收费',
  `department_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '出品部门',
  `department` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '利润部门',
  `send_number` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送数量',
  `related_dish_num` tinyint(1) NULL DEFAULT NULL COMMENT '跟菜品数量相关',
  `can_discount` tinyint(1) NULL DEFAULT NULL COMMENT '参与打折',
  `collect_service_fee` tinyint(1) NULL DEFAULT NULL COMMENT '收取服务费',
  PRIMARY KEY (`lid`) USING BTREE,
  INDEX `idx_mid_sid_saas_key`(`mid` ASC, `sid` ASC, `saas_order_key` ASC, `food_no` ASC) USING BTREE,
  INDEX `idx_mid_sid_report_date`(`mid` ASC, `sid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_sid_lid`(`mid` ASC, `sid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_saas_no`(`mid` ASC, `sid` ASC, `saas_order_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '口味做法明细' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
