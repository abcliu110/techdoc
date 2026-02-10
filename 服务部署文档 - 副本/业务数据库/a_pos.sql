-- ====================================
-- 数据库创建脚本 - a_pos
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_pos` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_pos`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_pos

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:40:35
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for dwd_bill
-- ----------------------------
DROP TABLE IF EXISTS `dwd_bill`;
CREATE TABLE `dwd_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `shop_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `report_date` datetime NULL DEFAULT NULL COMMENT '日期',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单号',
  `saas_order_no` bigint NOT NULL COMMENT '账单流水号',
  `year_` int NULL DEFAULT NULL COMMENT '年',
  `month_` bigint NULL DEFAULT NULL COMMENT '月',
  `day_` bigint NULL DEFAULT NULL COMMENT '日',
  `hour_` bigint NULL DEFAULT NULL COMMENT '时',
  `season` bigint NULL DEFAULT NULL COMMENT '季度',
  `person_num` int NULL DEFAULT NULL COMMENT '客流',
  `amount_per_person` decimal(10, 0) NULL DEFAULT NULL COMMENT '客单价',
  `food_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '流水金额',
  `discount_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣额',
  `service_charge_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '服务费',
  `fraction` decimal(10, 0) NULL DEFAULT NULL COMMENT '零头',
  `mantissa` decimal(10, 0) NULL DEFAULT NULL COMMENT '尾数',
  `timing_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '计时金额',
  `timing_discount_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '计时折扣额',
  `timing_service_charge_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '计时服务费',
  `overcharge_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '多收金额',
  `less_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '少收金额',
  `promotion_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '优惠金额',
  `paid_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '实收金额',
  `cancel_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '退菜金额',
  `send_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '赠送金额',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `checkout_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收银员',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `duration` bigint NULL DEFAULT NULL COMMENT '消费时长(毫秒)',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型;堂食、外卖、自提',
  `channel_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `create_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '开台人员',
  `table_leader` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台负责人',
  `waiter_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务员',
  `channel_order_key_t_p` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '三方单号',
  `device_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备编号',
  `device_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备名称',
  `discount_range` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '折扣方式',
  `discount_rate` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣率',
  `discount_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打折人',
  `service_charge_rate` decimal(10, 0) NULL DEFAULT NULL COMMENT '服务率',
  `fraction_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '零头调整人',
  `fjz_count` int NULL DEFAULT NULL COMMENT '反结账次数',
  `invoice_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '发票金额',
  `invoice_title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发票抬头',
  `is_vip_price` tinyint(1) NULL DEFAULT NULL COMMENT '使用了会员价',
  `card_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员类型',
  `card_level` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员等级',
  `card_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `saas_order_remark` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `order_type` int NULL DEFAULT NULL COMMENT '账单类型;快餐、酒楼、酒吧',
  `order_status` int NULL DEFAULT NULL COMMENT '状态',
  `num_of_jiu_xi` decimal(10, 0) NULL DEFAULT NULL COMMENT '席数',
  `single_jiu_xi_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '单席金额',
  `jiu_xi_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '酒席金额',
  `is_jiu_xi` tinyint(1) NULL DEFAULT NULL COMMENT '酒席单',
  `remark` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标记',
  `jiu_xi_order_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '酒席订金',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `card_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '食品卡号',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '账单明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwd_food
-- ----------------------------
DROP TABLE IF EXISTS `dwd_food`;
CREATE TABLE `dwd_food`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `food_no` bigint NULL DEFAULT NULL COMMENT '菜品流水号',
  `food_code` bigint NULL DEFAULT NULL COMMENT '菜品编码',
  `food_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品名称',
  `food_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  `food_super_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品大类',
  `food_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品小类',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `ordering_time` datetime NULL DEFAULT NULL COMMENT '点菜时间',
  `ordered_time` datetime NULL DEFAULT NULL COMMENT '上菜时间',
  `cook_duration` bigint NULL DEFAULT NULL COMMENT '制作时长（毫秒）',
  `cook` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '厨师',
  `food_pro_price` decimal(10, 0) NULL DEFAULT NULL COMMENT '售价',
  `food_org_price` decimal(10, 0) NULL DEFAULT NULL COMMENT '原价',
  `food_number` decimal(10, 0) NULL DEFAULT NULL COMMENT '流水数量',
  `send_number` decimal(10, 0) NULL DEFAULT NULL COMMENT '赠送数量',
  `unit_adjutant_number` decimal(10, 0) NULL DEFAULT NULL COMMENT '辅助数量',
  `food_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '流水金额',
  `service_charge_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '服务费',
  `discount_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣额',
  `discount_range` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打折方式',
  `processing_fee` decimal(10, 0) NULL DEFAULT NULL COMMENT '加工费',
  `processing_fee_discount` decimal(10, 0) NULL DEFAULT NULL COMMENT '加工费折扣额',
  `processing_fee_service` decimal(10, 0) NULL DEFAULT NULL COMMENT '加工费服务费',
  `promotion_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '优惠金额',
  `paid_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '实收金额',
  `food_discount_rate` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣率',
  `department_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出品部门',
  `food_subject_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品收入科目',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型',
  `channel_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道',
  `food_taste` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '口味',
  `food_practice` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '做法',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `order_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '点菜人',
  `checkout_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收银员',
  `remark` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单号',
  `saas_order_no` bigint NOT NULL COMMENT '账单流水号',
  `food_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `send_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '赠送人',
  `send_for` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '赠送原因',
  `send_time` datetime NULL DEFAULT NULL COMMENT '赠送时间',
  `cancel_number` decimal(10, 0) NULL DEFAULT NULL COMMENT '退菜数量',
  `cancel_for` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退菜原因',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退菜人',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '退菜时间',
  `is_rename` tinyint(1) NULL DEFAULT NULL COMMENT '修改过菜名',
  `rename_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜名修改人',
  `is_mod_price` tinyint(1) NULL DEFAULT NULL COMMENT '修改过价格',
  `mod_price_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '价格修改人',
  `mode_price_time` datetime NULL DEFAULT NULL COMMENT '改价时间',
  `discount_rate` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣率',
  `discount_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打折人',
  `year_` int NULL DEFAULT NULL COMMENT '年',
  `month_` bigint NULL DEFAULT NULL COMMENT '月',
  `day_` bigint NULL DEFAULT NULL COMMENT '日',
  `season` bigint NULL DEFAULT NULL COMMENT '季度',
  `is_jiu_xi` tinyint(1) NULL DEFAULT NULL COMMENT '酒席菜',
  `card_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '食品卡号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品销售明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwd_pay
-- ----------------------------
DROP TABLE IF EXISTS `dwd_pay`;
CREATE TABLE `dwd_pay`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单号',
  `saas_order_no` bigint NOT NULL COMMENT '账单流水号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式名称',
  `type_` int NULL DEFAULT NULL COMMENT '支付类型',
  `pay_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '支付金额',
  `exchange_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '找回金额',
  `amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '实收金额',
  `is_real_income` tinyint(1) NULL DEFAULT NULL COMMENT '真实收入',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `checkout_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收银员',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `year_` int NULL DEFAULT NULL COMMENT '年',
  `month_` bigint NULL DEFAULT NULL COMMENT '月',
  `day_` bigint NULL DEFAULT NULL COMMENT '日',
  `season` bigint NULL DEFAULT NULL COMMENT '季度',
  `card_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '食品卡号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for dwd_taste
-- ----------------------------
DROP TABLE IF EXISTS `dwd_taste`;
CREATE TABLE `dwd_taste`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '集团编号',
  `sid` bigint NOT NULL COMMENT '门店编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `saas_order_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '订单编号',
  `saas_order_no` bigint NOT NULL COMMENT '订单流水号',
  `food_super_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品大类',
  `food_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品小类',
  `food_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品',
  `food_no` bigint NULL DEFAULT NULL COMMENT '菜品流水号',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  `adjutant_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '辅助规格',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `number` decimal(10, 0) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(10, 0) NULL DEFAULT NULL COMMENT '价格',
  `taste_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '费用',
  `discount_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '折扣额',
  `service_charge_amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '服务费',
  `amount` decimal(10, 0) NULL DEFAULT NULL COMMENT '实际收费',
  `department_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '出品部门',
  `department` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '利润部门',
  `send_number` decimal(10, 0) NULL DEFAULT NULL COMMENT '赠送数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `card_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '食品卡号',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '口味做法明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission_module
-- ----------------------------
DROP TABLE IF EXISTS `permission_module`;
CREATE TABLE `permission_module`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `view_lid` bigint NULL DEFAULT NULL COMMENT '视角编号',
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标识符',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `sort_index` int NULL DEFAULT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `package_lid` bigint NULL DEFAULT NULL COMMENT '权限包编号',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限模块' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for permission_package
-- ----------------------------
DROP TABLE IF EXISTS `permission_package`;
CREATE TABLE `permission_package`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标识符',
  `sort_index` int NULL DEFAULT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限包' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for permission_page
-- ----------------------------
DROP TABLE IF EXISTS `permission_page`;
CREATE TABLE `permission_page`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NULL DEFAULT NULL COMMENT '逻辑编号',
  `module_lid` bigint NULL DEFAULT NULL COMMENT '视角编号',
  `code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '标识符',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `sort_index` int NULL DEFAULT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `view_lid` bigint NULL DEFAULT NULL COMMENT '视角编号',
  `package_lid` bigint NULL DEFAULT NULL COMMENT '权限包编号',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1856 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限页面' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for permission_right
-- ----------------------------
DROP TABLE IF EXISTS `permission_right`;
CREATE TABLE `permission_right`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `page_lid` bigint NULL DEFAULT NULL COMMENT '页面编号',
  `code` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '标识符',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `sort_index` int NULL DEFAULT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `view_lid` bigint NULL DEFAULT NULL COMMENT '视角编号',
  `package_lid` bigint NULL DEFAULT NULL COMMENT '权限包编号',
  `module_lid` bigint NULL DEFAULT NULL COMMENT '视角编号',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2479 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限资源' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for permission_view
-- ----------------------------
DROP TABLE IF EXISTS `permission_view`;
CREATE TABLE `permission_view`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `package_lid` bigint NULL DEFAULT NULL COMMENT '权限包编号',
  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标识符',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `sort_index` int NULL DEFAULT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限视角' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for pos_app_ver
-- ----------------------------
DROP TABLE IF EXISTS `pos_app_ver`;
CREATE TABLE `pos_app_ver`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `app` int NULL DEFAULT NULL COMMENT '应用',
  `ver` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '版本号',
  `gradual` tinyint(1) NULL DEFAULT NULL COMMENT '灰度升级',
  `dev_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '适用于灰度升级的设备',
  `installer_package` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '安装包路径',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `sids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '门店列表',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '发布备注',
  `mids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '集团列表',
  `force_install` tinyint(1) NULL DEFAULT NULL COMMENT '是否强制安装升级包',
  `immediate_update` tinyint(1) NULL DEFAULT NULL COMMENT '是否立即更新',
  `scheduled_update_time` datetime NULL DEFAULT NULL COMMENT '计划安装时间',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_app`(`app` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '应用版本记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_approval_config
-- ----------------------------
DROP TABLE IF EXISTS `pos_approval_config`;
CREATE TABLE `pos_approval_config`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预留字段，编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '事件名称',
  `approval_type` int NOT NULL COMMENT '事件类型',
  `approval_conf` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '审批人配置',
  `approval_extend` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '预留字段，审批扩展',
  `enable` tinyint(1) NOT NULL COMMENT '审批开关',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批配置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_approval_order
-- ----------------------------
DROP TABLE IF EXISTS `pos_approval_order`;
CREATE TABLE `pos_approval_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '预留字段，审批单号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '单据日期',
  `title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批主题',
  `module` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审批模块',
  `urgency_level` int NULL DEFAULT NULL COMMENT '紧急程度',
  `desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '变动说明/描述',
  `attachments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '附件列表',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '审批内容',
  `approval_conf` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '审批配置',
  `approval_type` int NOT NULL COMMENT '事件类型',
  `initiator` bigint NULL DEFAULT NULL COMMENT '审批人lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '审批单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_auto_discount
-- ----------------------------
DROP TABLE IF EXISTS `pos_auto_discount`;
CREATE TABLE `pos_auto_discount`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `discount_lid` bigint NULL DEFAULT NULL COMMENT '折扣lid',
  `discount_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '折扣名称',
  `tbl_type_lid` bigint NULL DEFAULT NULL COMMENT '桌台类型lid',
  `tbl_type_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台类型名称',
  `period_lid` bigint NULL DEFAULT NULL COMMENT '营业时段lid',
  `period_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '营业时段名称',
  `auto_discount_type` int NULL DEFAULT NULL COMMENT '自动打折类型',
  `discount_time_type` int NULL DEFAULT NULL COMMENT '打折时间类型',
  `start_at` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_at` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `monday` tinyint(1) NULL DEFAULT NULL COMMENT '周一',
  `tuesday` tinyint(1) NULL DEFAULT NULL COMMENT '周二',
  `wednesday` tinyint(1) NULL DEFAULT NULL COMMENT '周三',
  `thursday` tinyint(1) NULL DEFAULT NULL COMMENT '周四',
  `friday` tinyint(1) NULL DEFAULT NULL COMMENT '周五',
  `saturday` tinyint(1) NULL DEFAULT NULL COMMENT '周六',
  `sunday` tinyint(1) NULL DEFAULT NULL COMMENT '周日',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '自动打折' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_customer_bill_setting
-- ----------------------------
DROP TABLE IF EXISTS `pos_customer_bill_setting`;
CREATE TABLE `pos_customer_bill_setting`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `prn_queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '打印队列',
  `by_mobile` tinyint(1) NULL DEFAULT NULL COMMENT '移动设备发起的操作',
  `for_checkout` tinyint(1) NULL DEFAULT NULL COMMENT '适用于结账单',
  `pc_lid` bigint NULL DEFAULT NULL COMMENT '电脑编号',
  `tbl_area_lid` bigint NULL DEFAULT NULL COMMENT '桌台区域编号',
  `tbl_type_lid` bigint NULL DEFAULT NULL COMMENT '桌台类型编号',
  `tbl_lid` bigint NULL DEFAULT NULL COMMENT '桌台编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1342 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '顾客联设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_dept
-- ----------------------------
DROP TABLE IF EXISTS `pos_dept`;
CREATE TABLE `pos_dept`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `type` int NULL DEFAULT NULL COMMENT '类型',
  `profit_dept` bigint NULL DEFAULT NULL COMMENT '利润部门',
  `prn_queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '打印队列',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `wms_dept_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '供应链部门lids',
  `cashier_dept_names` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '收银部门lids',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1358 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '出品部门和出品部门管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_dev
-- ----------------------------
DROP TABLE IF EXISTS `pos_dev`;
CREATE TABLE `pos_dev`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备名称',
  `type_` int NULL DEFAULT NULL,
  `model` int NULL DEFAULT NULL COMMENT '设备型号',
  `extra_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '附加信息',
  `app_ver` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '软件版本',
  `online` tinyint(1) NULL DEFAULT NULL COMMENT '在线',
  `last_active_time` datetime NULL DEFAULT NULL COMMENT '上次激活时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `master_` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否主设备',
  `self_start` tinyint(1) NOT NULL DEFAULT 0 COMMENT '自启动',
  `app` int NOT NULL DEFAULT 1 COMMENT '软件类型',
  `app_pack_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '软件包名',
  `old_pack_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '软件旧包名',
  `pc_lid` bigint NULL DEFAULT 0 COMMENT '服务器',
  `dev_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备UUID',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备IP',
  `hostname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主机名',
  `compile_time` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '编译时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 709 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '设备列表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_dish_hide
-- ----------------------------
DROP TABLE IF EXISTS `pos_dish_hide`;
CREATE TABLE `pos_dish_hide`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `day_of_the_week` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '星期几',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `dish_type_lid_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品类别编号',
  `dish_lid_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品编号',
  `sellout_or_hide` tinyint(1) NULL DEFAULT NULL COMMENT '用于隐藏或者估清的标志位',
  `state` tinyint(1) NULL DEFAULT NULL COMMENT '是否启用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `pos_biz_type` int NULL DEFAULT NULL COMMENT '业务类型',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 474 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品隐藏设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_dish_to_prn_dept
-- ----------------------------
DROP TABLE IF EXISTS `pos_dish_to_prn_dept`;
CREATE TABLE `pos_dish_to_prn_dept`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `prn_dept_lid` bigint NULL DEFAULT NULL COMMENT '出品部门编号',
  `pc_lid` bigint NULL DEFAULT NULL COMMENT '电脑编号',
  `tbl_area_lid` bigint NULL DEFAULT NULL COMMENT '台区编号',
  `dish_type_lid` bigint NULL DEFAULT NULL COMMENT '菜品类别编号',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `type` int NULL DEFAULT NULL COMMENT '类型',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26249 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品与出品部门的映射' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_group_dish_book
-- ----------------------------
DROP TABLE IF EXISTS `pos_group_dish_book`;
CREATE TABLE `pos_group_dish_book`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `brand_lid` bigint NULL DEFAULT NULL COMMENT '品牌编号',
  `published_time` datetime NULL DEFAULT NULL COMMENT '上次发布时间',
  `published_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发布人',
  `activation_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `status_` int NULL DEFAULT NULL COMMENT '发布状态',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `ldx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 171 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '集团菜谱' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_group_dish_book_release
-- ----------------------------
DROP TABLE IF EXISTS `pos_group_dish_book_release`;
CREATE TABLE `pos_group_dish_book_release`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `book_lid` bigint NULL DEFAULT NULL COMMENT '菜谱',
  `store_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '发布门店',
  `book_release_rule` int NULL DEFAULT NULL COMMENT '发布规则',
  `dish_release_rule` int NULL DEFAULT NULL COMMENT '菜品信息发布规则',
  `release_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `release_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发布人',
  `done` tinyint(1) NULL DEFAULT NULL COMMENT '发布完成',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `done_time` datetime NULL DEFAULT NULL COMMENT '发布完成时间',
  `brand_lid` bigint NULL DEFAULT NULL COMMENT '品牌lid',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2916 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜谱发布记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_operating_cost
-- ----------------------------
DROP TABLE IF EXISTS `pos_operating_cost`;
CREATE TABLE `pos_operating_cost`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `share` tinyint(1) NULL DEFAULT NULL COMMENT '分摊到部门',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '经营成本' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_operating_target
-- ----------------------------
DROP TABLE IF EXISTS `pos_operating_target`;
CREATE TABLE `pos_operating_target`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `cost_lid` bigint NULL DEFAULT NULL COMMENT '成本lid',
  `cost_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '成本名称',
  `dept_lid` bigint NULL DEFAULT NULL COMMENT '部门lid',
  `dept_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门名称',
  `year_` int NULL DEFAULT NULL COMMENT '年',
  `month_` int NULL DEFAULT NULL COMMENT '月',
  `day_` int NULL DEFAULT NULL COMMENT '天',
  `value` decimal(19, 10) NULL DEFAULT NULL COMMENT '金额/百分比',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `report_date` datetime NULL DEFAULT NULL COMMENT '日期',
  `organ_type` int NOT NULL DEFAULT 1 COMMENT '组织类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '经营成本目标' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_perform_target
-- ----------------------------
DROP TABLE IF EXISTS `pos_perform_target`;
CREATE TABLE `pos_perform_target`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dept_lid` bigint NULL DEFAULT NULL COMMENT '部门lid',
  `dept_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门名称',
  `perform_type` int NULL DEFAULT NULL COMMENT '业绩类型',
  `statistics_type` int NULL DEFAULT NULL COMMENT '统计类型',
  `year_` int NULL DEFAULT NULL COMMENT '年',
  `month_` int NULL DEFAULT NULL COMMENT '月',
  `day_` int NULL DEFAULT NULL COMMENT '天',
  `value` decimal(19, 10) NULL DEFAULT NULL COMMENT '金额/百分比',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `report_date` datetime NULL DEFAULT NULL COMMENT '日期',
  `person` decimal(19, 10) NULL DEFAULT NULL COMMENT '人数',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '业绩目标' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_pricing_by_time
-- ----------------------------
DROP TABLE IF EXISTS `pos_pricing_by_time`;
CREATE TABLE `pos_pricing_by_time`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `pricing_type` int NULL DEFAULT NULL COMMENT '计价类型',
  `timeout_type` int NULL DEFAULT NULL COMMENT '超时类型',
  `time_period_type` int NULL DEFAULT NULL COMMENT '时段类型',
  `constant_time` int NULL DEFAULT NULL COMMENT '固定时间',
  `constant_charge` decimal(10, 0) NULL DEFAULT NULL COMMENT '固定收费',
  `ceiling_charge` decimal(10, 0) NULL DEFAULT NULL COMMENT '封顶费',
  `timing_free_time` int NULL DEFAULT NULL COMMENT '计时免费时间',
  `minimum_spending_duration` int NULL DEFAULT NULL COMMENT '最低消费时长',
  `minimum_billing_duration` int NULL DEFAULT NULL COMMENT '最小计费时长',
  `timing_participation_member_discount` tinyint(1) NULL DEFAULT NULL COMMENT '计时参与会员折扣',
  `added_service_fee` tinyint(1) NULL DEFAULT NULL COMMENT '加收服务费',
  `advance_session_charge` tinyint(1) NULL DEFAULT NULL COMMENT '超前场收费',
  `advance_session_free_time` int NULL DEFAULT NULL COMMENT '超前场免费时间',
  `advance_session_hourly_price` decimal(10, 0) NULL DEFAULT NULL COMMENT '超前场每小时价格',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '计时计价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_pricing_by_time_period
-- ----------------------------
DROP TABLE IF EXISTS `pos_pricing_by_time_period`;
CREATE TABLE `pos_pricing_by_time_period`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `time_period_type` int NULL DEFAULT NULL COMMENT '时段类型',
  `start_time` datetime NULL DEFAULT NULL COMMENT '起始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `single_price` int NULL DEFAULT NULL COMMENT '时段金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '计时计价时段表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_pricing_by_time_timeout
-- ----------------------------
DROP TABLE IF EXISTS `pos_pricing_by_time_timeout`;
CREATE TABLE `pos_pricing_by_time_timeout`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `pricing_type` int NULL DEFAULT NULL COMMENT '计价类型',
  `timeout_type` int NULL DEFAULT NULL COMMENT '超时类型',
  `free_time_for_due_timeout` int NULL DEFAULT NULL COMMENT '到点超时免收时间',
  `interval_free_time` int NULL DEFAULT NULL COMMENT '区间免收时间',
  `interval_time_period` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '区间时间段',
  `interval_hourly_price` decimal(10, 0) NULL DEFAULT NULL COMMENT '区间每小时价格',
  `session_free_time` int NULL DEFAULT NULL COMMENT '按场次免收时间',
  `hourly_free_time` int NULL DEFAULT NULL COMMENT '按小时免收时间',
  `hourly_extra_charge_per_hour` decimal(10, 0) NULL DEFAULT NULL COMMENT '按小时每小时加收',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '计时计价超时表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_job
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_job`;
CREATE TABLE `pos_prn_job`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `biz_bill_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务单号',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `purpose` int NULL DEFAULT NULL COMMENT '用途',
  `prn_count` int NULL DEFAULT NULL COMMENT '打印次数',
  `prn_queue_lid` bigint NULL DEFAULT NULL COMMENT '打印队列编号',
  `prn_printer_lid` bigint NULL DEFAULT NULL COMMENT '打印机编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_printer
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_printer`;
CREATE TABLE `pos_prn_printer`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `pc_lid` bigint NULL DEFAULT NULL COMMENT '所属计算机',
  `type` int NULL DEFAULT NULL COMMENT '类型',
  `model` int NULL DEFAULT NULL COMMENT '型号',
  `extra_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '附加信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 678 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印机' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_queue
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_queue`;
CREATE TABLE `pos_prn_queue`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `pc_lid` bigint NULL DEFAULT NULL COMMENT '所属计算机',
  `primary_printer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '主打印机',
  `standby_printer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备用打印机',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 681 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印队列' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_style
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_style`;
CREATE TABLE `pos_prn_style`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type_` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型',
  `extra_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '附加信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_type`(`mid` ASC, `type_` ASC) USING BTREE,
  INDEX `idx_sid_type`(`sid` ASC, `type_` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印单据样式' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_style_col
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_style_col`;
CREATE TABLE `pos_prn_style_col`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `style_type` int NULL DEFAULT NULL COMMENT '单据类型',
  `row_lid` bigint NULL DEFAULT NULL COMMENT '行编号',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `ds_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数据源编号',
  `ds_field_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数据源字段编号',
  `customized_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '自定义内容',
  `customized_content_suffix` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '自定义内容(后)',
  `width80` int NULL DEFAULT NULL COMMENT '宽度(80毫米热敏纸)',
  `width76` int NULL DEFAULT NULL COMMENT '宽度(76毫米针式打印机)',
  `width58` int NULL DEFAULT NULL COMMENT '宽度(58毫米热敏纸)',
  `align` int NULL DEFAULT NULL COMMENT '对齐方式',
  `font_size` int NULL DEFAULT NULL COMMENT '字体',
  `bold` tinyint(1) NULL DEFAULT NULL COMMENT '加粗',
  `show_index` int NULL DEFAULT NULL COMMENT '显示顺序',
  `insert_separator_line` int NULL DEFAULT NULL COMMENT '插入分割线数',
  `insert_blank_line` int NULL DEFAULT NULL COMMENT '插入空行数',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `condition_ds_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显示条件的数据源编号',
  `condition_operator` int NULL DEFAULT NULL COMMENT '显示条件的操作符',
  `condition_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显示条件的右值',
  `color` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '颜色',
  `bg` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '背景颜色',
  `summarize` tinyint(1) NULL DEFAULT NULL COMMENT '需要打印汇总',
  `line_spacing` int NULL DEFAULT NULL COMMENT '行间距',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 56419 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印样式列' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_style_item
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_style_item`;
CREATE TABLE `pos_prn_style_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `style` bigint NULL DEFAULT NULL COMMENT '样式',
  `idx` int NULL DEFAULT NULL COMMENT '顺序',
  `type_` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型',
  `condition_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打印条件',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打印内容',
  `align` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '对齐方式',
  `width` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '宽度设置',
  `bold` tinyint(1) NULL DEFAULT NULL COMMENT '加粗',
  `w_size` int NULL DEFAULT NULL COMMENT '字体宽度',
  `h_size` int NULL DEFAULT NULL COMMENT '字体高度',
  `reverse` tinyint(1) NULL DEFAULT NULL COMMENT '反显',
  `underline` tinyint(1) NULL DEFAULT NULL COMMENT '下划线',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_style`(`style` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印单据样式内容' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_prn_style_row
-- ----------------------------
DROP TABLE IF EXISTS `pos_prn_style_row`;
CREATE TABLE `pos_prn_style_row`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `ds_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数据源编号',
  `style_type` int NULL DEFAULT NULL COMMENT '单据类型',
  `show_index` int NULL DEFAULT NULL COMMENT '显示顺序',
  `display_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '显示条件',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `condition_ds_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显示条件的数据源编号',
  `condition_operator` int NULL DEFAULT NULL COMMENT '显示条件的操作符',
  `condition_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '显示条件的右值',
  `summarize` tinyint(1) NULL DEFAULT NULL COMMENT '需要打印汇总',
  `summarize_col_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '汇总列的名字',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`mid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29186 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印样式行' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_promote_rule
-- ----------------------------
DROP TABLE IF EXISTS `pos_promote_rule`;
CREATE TABLE `pos_promote_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `sids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '适用门店',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '促销名称',
  `enable` tinyint(1) NULL DEFAULT NULL COMMENT '是否启用',
  `type_` int NULL DEFAULT NULL COMMENT '折扣类型',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `monday` tinyint(1) NULL DEFAULT NULL COMMENT '星期一',
  `tuesday` tinyint(1) NULL DEFAULT NULL COMMENT '星期二',
  `wednesday` tinyint(1) NULL DEFAULT NULL COMMENT '星期三',
  `thursday` tinyint(1) NULL DEFAULT NULL COMMENT '星期四',
  `friday` tinyint(1) NULL DEFAULT NULL COMMENT '星期五',
  `saturday` tinyint(1) NULL DEFAULT NULL COMMENT '星期六',
  `sunday` tinyint(1) NULL DEFAULT NULL COMMENT '星期日',
  `everyone` tinyint(1) NULL DEFAULT NULL COMMENT '所有顾客可参与',
  `only_member` tinyint(1) NULL DEFAULT NULL COMMENT '仅会员可参与',
  `only_part_type` tinyint(1) NULL DEFAULT NULL COMMENT '指定会员可参与',
  `part_types` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '会员类型列表',
  `promote_foods` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '促销菜品',
  `same_day_limit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当日限次',
  `rule_extend` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '规则扩展',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `review` tinyint(1) NULL DEFAULT NULL COMMENT '审核',
  `review_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核时间',
  `review_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核人',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '促销方案' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_reason_type
-- ----------------------------
DROP TABLE IF EXISTS `pos_reason_type`;
CREATE TABLE `pos_reason_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `reason_type` int NULL DEFAULT NULL COMMENT '原因类型',
  `reason_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原因名称',
  `print_status` tinyint(1) NULL DEFAULT NULL COMMENT '打印状态',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 527 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '退赠起菜原因' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_tag_template
-- ----------------------------
DROP TABLE IF EXISTS `pos_tag_template`;
CREATE TABLE `pos_tag_template`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模板名称',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '背景图片',
  `idx` int NOT NULL DEFAULT 0 COMMENT '模板顺序',
  `def` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否默认',
  `used` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否使用',
  `extra_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '附加信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '价签模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pos_waiter_bill_setting
-- ----------------------------
DROP TABLE IF EXISTS `pos_waiter_bill_setting`;
CREATE TABLE `pos_waiter_bill_setting`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `prn_dept` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '出品部门',
  `tbl_area` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '桌台区域',
  `prn_queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '打印队列',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '传菜联设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for print_job_type_switch
-- ----------------------------
DROP TABLE IF EXISTS `print_job_type_switch`;
CREATE TABLE `print_job_type_switch`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type` int NULL DEFAULT NULL COMMENT '打印任务类型',
  `disabled_kitchen` tinyint(1) NULL DEFAULT NULL COMMENT '不打印档口联',
  `disabled_waiter` tinyint(1) NULL DEFAULT NULL COMMENT '不打印传菜联',
  `disabled_customer` tinyint(1) NULL DEFAULT NULL COMMENT '不打印顾客联',
  `num_of_kitchen` int NULL DEFAULT NULL COMMENT '档口联打印份数',
  `num_of_waiter` int NULL DEFAULT NULL COMMENT '传菜联打印份数',
  `num_of_customer` int NULL DEFAULT NULL COMMENT '顾客联打印份数',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 408 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打印任务开关' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_dish_price_special
-- ----------------------------
DROP TABLE IF EXISTS `pt_dish_price_special`;
CREATE TABLE `pt_dish_price_special`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type` int NULL DEFAULT NULL COMMENT '价格类型',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品编号',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品单位',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '菜品价格',
  `out_type_no` bigint NULL DEFAULT NULL COMMENT '关联编号',
  `festival` bigint NULL DEFAULT NULL COMMENT '节日编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `ldx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 195 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜品特殊价格' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_festival
-- ----------------------------
DROP TABLE IF EXISTS `pt_festival`;
CREATE TABLE `pt_festival`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `state` bigint NULL DEFAULT NULL COMMENT '启用状态',
  `day_of_the_week` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '星期几',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '节日' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_check_template
-- ----------------------------
DROP TABLE IF EXISTS `sc_check_template`;
CREATE TABLE `sc_check_template`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '盘点模板名称',
  `rows_` int NOT NULL COMMENT '物品数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '盘点模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_check_template_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_check_template_item`;
CREATE TABLE `sc_check_template_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `template_lid` bigint NOT NULL COMMENT '模板lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `goods_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品编号',
  `goods_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品名称',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '标准数量',
  `counting_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '计量数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_template_lid`(`mid` ASC, `template_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '盘点模板物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for takeout_aggregation_platform_channel
-- ----------------------------
DROP TABLE IF EXISTS `takeout_aggregation_platform_channel`;
CREATE TABLE `takeout_aggregation_platform_channel`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `channel_type` int NULL DEFAULT NULL COMMENT '通道类型',
  `channel_merchant_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '在通道中的商户号',
  `channel_store_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '在通道中的门店号',
  `channel_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通道信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `terminal_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终端号',
  `terminal_token` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终端密钥',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_channel_store_code`(`channel_store_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '外卖聚合平台通道' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for takeout_food_map
-- ----------------------------
DROP TABLE IF EXISTS `takeout_food_map`;
CREATE TABLE `takeout_food_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `channel_type` int NULL DEFAULT NULL COMMENT '渠道类型',
  `food_id_in_channel` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道菜品编号',
  `food_unit_in_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道菜品单位',
  `food_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品名称',
  `food_id_in_nms` bigint NULL DEFAULT NULL COMMENT '我们系统的菜品编号',
  `food_unit_in_nms` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '我们系统的菜品单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `food_code_in_nms` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '我们系统的菜品编号',
  `attr_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性名称',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `spu` tinyint(1) NULL DEFAULT NULL COMMENT '是否SPU',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31931 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '外卖菜品映射表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
