-- ====================================
-- 数据库创建脚本 - a_crm
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_crm` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_crm`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_crm

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:39:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for crm_actuator
-- ----------------------------
DROP TABLE IF EXISTS `crm_actuator`;
CREATE TABLE `crm_actuator`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `exec_type` int NOT NULL DEFAULT 1 COMMENT '执行类型',
  `filter_lid` bigint NULL DEFAULT NULL COMMENT '筛选器lid',
  `points` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '赠送积分',
  `give_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '赠送金额',
  `take_mode` int NOT NULL DEFAULT 2 COMMENT '领取模式',
  `remark` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '活动备注',
  `timed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '定时执行',
  `exec_period` int NULL DEFAULT NULL COMMENT '执行周期',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '执行周期-开始时间',
  `end_date` datetime NULL DEFAULT NULL COMMENT '执行周期-结束时间',
  `exec_mode` int NOT NULL DEFAULT 2 COMMENT '执行模式',
  `exec_val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行模式为月时的天数列表，逗号分割',
  `monday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周一',
  `tuesday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周二',
  `wednesday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周三',
  `thursday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周四',
  `friday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周五',
  `saturday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周六',
  `sunday` tinyint(1) NOT NULL DEFAULT 0 COMMENT '周日',
  `exec_time` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行时间',
  `exec_state` int NOT NULL DEFAULT 1 COMMENT '执行状态',
  `exec_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '执行信息：错误信息，执行成功信息',
  `last_exec_time` datetime NULL DEFAULT NULL COMMENT '上次执行时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `recharge_amount` decimal(24, 6) NOT NULL COMMENT '充值金额',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员执行器' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_actuator_coupon
-- ----------------------------
DROP TABLE IF EXISTS `crm_actuator_coupon`;
CREATE TABLE `crm_actuator_coupon`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `actuator_lid` bigint NOT NULL COMMENT '执行器lid',
  `coupon_lid` bigint NOT NULL COMMENT '优惠券lid',
  `coupon_num` int NOT NULL COMMENT '赠送数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_actuator_lid`(`mid` ASC, `actuator_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 188 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '执行器券列表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_actuator_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_actuator_record`;
CREATE TABLE `crm_actuator_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `actuator_lid` bigint NOT NULL COMMENT '执行器lid',
  `actuator_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行器名称',
  `total` int NOT NULL COMMENT '执行总数量',
  `suc_total` int NOT NULL COMMENT '执行成功数量',
  `fail_total` int NOT NULL COMMENT '执行失败数量',
  `exec_state` int NOT NULL COMMENT '执行状态',
  `finished_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `mid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_actuator_lid`(`mid` ASC, `actuator_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 459 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '执行器执行记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_birthday_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_birthday_record`;
CREATE TABLE `crm_birthday_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year_` int NOT NULL COMMENT '年',
  `month_` int NOT NULL COMMENT '月',
  `day_` int NOT NULL COMMENT '日',
  `card_lid` bigint NOT NULL COMMENT '会员卡lid',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员卡号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员名称',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员手机号',
  `birthday` datetime NOT NULL COMMENT '生日',
  `advance_days` int NOT NULL COMMENT '提前天数',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '赠券lid',
  `coupon_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠券名称',
  `points` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送积分',
  `rule_lid` bigint NOT NULL COMMENT '赠券规则lid',
  `rule_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '赠券规则名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_card_lid`(`mid` ASC, `report_date` ASC, `card_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_phone`(`mid` ASC, `report_date` ASC, `phone` ASC) USING BTREE,
  INDEX `idx_mid_report_date_id`(`mid` ASC, `report_date` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 364 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '生日营销赠送记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_birthday_rule
-- ----------------------------
DROP TABLE IF EXISTS `crm_birthday_rule`;
CREATE TABLE `crm_birthday_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '活动名称',
  `begin_date` datetime NOT NULL COMMENT '开始有效期',
  `end_date` datetime NOT NULL COMMENT '失效期',
  `advance_days` int NOT NULL COMMENT '提前天数',
  `is_suit_all` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否适用全部会员卡类型',
  `card_type_lids` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡类型lids',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '优惠券',
  `points` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送积分',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_begin_date`(`begin_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员员生日营销' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_balance
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_balance`;
CREATE TABLE `crm_card_balance`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '充值门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `cno` bigint NOT NULL COMMENT '卡号',
  `total` decimal(24, 6) NOT NULL COMMENT '总金额',
  `principal` decimal(24, 6) NOT NULL COMMENT '本金',
  `gift` decimal(24, 6) NOT NULL COMMENT '赠送金额',
  `source` int NULL DEFAULT NULL COMMENT '来源',
  `out_trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_cno`(`mid` ASC, `cno` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 872374 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '卡余额' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_cost_task
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_cost_task`;
CREATE TABLE `crm_card_cost_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员名称',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员手机号',
  `sex` int NOT NULL DEFAULT 0 COMMENT '性别',
  `birthday` datetime NULL DEFAULT NULL COMMENT '生日',
  `open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'openId',
  `union_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'unionId',
  `card_type_lid` bigint NOT NULL COMMENT '会员卡类型lid',
  `card_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡类型',
  `cost` decimal(24, 6) NOT NULL COMMENT '开卡费',
  `pay_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付终端号',
  `finished` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否支付',
  `finished_at` datetime NULL DEFAULT NULL COMMENT '支付完成时间',
  `join_at` datetime NULL DEFAULT NULL COMMENT '开卡时间',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '券编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '券名称',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_open_id`(`mid` ASC, `open_id` ASC) USING BTREE,
  INDEX `idx_mid_union_id`(`mid` ASC, `union_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 64 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '付费开卡记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_grade_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_grade_record`;
CREATE TABLE `crm_card_grade_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员名称',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员电话',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '卡号',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡lid',
  `member_lid` bigint NULL DEFAULT NULL COMMENT '会员lid',
  `org_card_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原会员等级',
  `org_card_level_lid` bigint NULL DEFAULT NULL COMMENT '原会员等级lid',
  `org_card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原会卡类型',
  `org_card_type_lid` bigint NULL DEFAULT NULL COMMENT '原会卡类型lid',
  `cur_card_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前会员等级',
  `cur_card_level_lid` bigint NULL DEFAULT NULL COMMENT '当前会员等级lid',
  `cur_card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前会员类型',
  `cur_card_type_lid` bigint NULL DEFAULT NULL COMMENT '当前会卡类型lid',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '本次操作金额',
  `principal_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '本次操作本金',
  `give_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '本次操作赠送',
  `balance` decimal(24, 6) NULL DEFAULT NULL COMMENT '总余额',
  `principal_balance` decimal(24, 6) NULL DEFAULT NULL COMMENT '本金余额',
  `give_balance` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送余额',
  `points` decimal(24, 6) NULL DEFAULT NULL COMMENT '积分余额',
  `sum_of_save` decimal(24, 6) NULL DEFAULT NULL COMMENT '累计充值',
  `sum_of_save_times` int NULL DEFAULT NULL COMMENT '累计充值次数',
  `sum_of_consume` decimal(24, 6) NULL DEFAULT NULL COMMENT '累计消费',
  `sum_of_consume_times` int NULL DEFAULT NULL COMMENT '累计消费次数',
  `sum_of_points` decimal(24, 6) NULL DEFAULT NULL COMMENT '累计积分',
  `grade_type` int NULL DEFAULT NULL COMMENT '类型',
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_report_date_mid_card_lid`(`report_date` ASC, `mid` ASC, `card_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4118 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员卡升级和降级记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_map
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_map`;
CREATE TABLE `crm_card_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NULL DEFAULT NULL COMMENT '逻辑编号',
  `card_lid` bigint NOT NULL COMMENT '会员卡的lid',
  `type` int NOT NULL COMMENT '类型',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编号(手机号、openid、或者实体卡号)',
  `unionid` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'unionid',
  `appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'appid',
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '密码',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `unionid_plus` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'unionid_plus',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_mid_id`(`mid` ASC, `id` ASC) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_card_lid`(`mid` ASC, `card_lid` ASC) USING BTREE,
  INDEX `crm_card_map_id_IDX`(`id` ASC) USING BTREE,
  INDEX `idx_unionid_plus`(`unionid_plus` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1497034 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '卡记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_upgrade_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_upgrade_record`;
CREATE TABLE `crm_card_upgrade_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '门店名称',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员卡号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员名称',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员手机号',
  `rule_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '储值名称',
  `rule_lid` bigint NOT NULL COMMENT '储值lid',
  `card_type_lid` bigint NULL DEFAULT NULL COMMENT '会员卡类型lid',
  `card_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡类型',
  `org_type_lid` bigint NULL DEFAULT NULL COMMENT '原会员卡类型lid',
  `org_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原会员卡类型',
  `amount` decimal(24, 6) NOT NULL COMMENT '工本费/购券金额',
  `points` decimal(24, 6) NOT NULL COMMENT '赠送积分',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '券编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '券名称',
  `coupon_num` int NULL DEFAULT NULL COMMENT '赠券数量',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `cancel` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否撤销',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_at` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `task_lid` bigint NOT NULL COMMENT '任务lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_task_lid`(`mid` ASC, `report_date` ASC, `task_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '购券/升级工本费记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_wx_user
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_wx_user`;
CREATE TABLE `crm_card_wx_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡的lid',
  `wx_user_lid` bigint NULL DEFAULT NULL COMMENT '微信用户的lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_wx_user_lid`(`mid` ASC, `wx_user_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员卡和微信会员的绑定关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_consumption_coupon_limit
-- ----------------------------
DROP TABLE IF EXISTS `crm_consumption_coupon_limit`;
CREATE TABLE `crm_consumption_coupon_limit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间段',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间段',
  `week_type` int NULL DEFAULT NULL COMMENT '周类型',
  `rule_lid` bigint NOT NULL COMMENT '活动规则lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 942 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '赠券限制' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_consumption_coupon_rule
-- ----------------------------
DROP TABLE IF EXISTS `crm_consumption_coupon_rule`;
CREATE TABLE `crm_consumption_coupon_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消费赠劵名称',
  `coupon_lid` bigint NOT NULL COMMENT '优惠券lid',
  `coupon_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '优惠券名称',
  `full_amount` decimal(24, 6) NOT NULL COMMENT '优惠券金额',
  `amount_method` int NOT NULL COMMENT '金额计算方式',
  `gift_quantity` int NOT NULL COMMENT '赠券数量',
  `term_of_validity_method` int NOT NULL COMMENT '有效期限方式',
  `effective_method` int NULL DEFAULT NULL COMMENT '相对期限生效方式',
  `effective_days` int NULL DEFAULT NULL COMMENT '开始生效的天数',
  `effective_time` int NULL DEFAULT NULL COMMENT '开始生效的小时数',
  `start_effective_time` datetime NULL DEFAULT NULL COMMENT '开始生效时间',
  `end_effective_time` datetime NULL DEFAULT NULL COMMENT '结束生效时间',
  `card_type_lid` bigint NULL DEFAULT NULL COMMENT '会员卡类型lid',
  `card_type_level_lid` bigint NULL DEFAULT NULL COMMENT '会员卡等级lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `gift_by_increase` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否按消费金额递增赠券',
  `gift_eve_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '依次递增赠券每满金额',
  `gift_max_quantity` int NOT NULL COMMENT '单次最多赠券数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '消费赠券' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_coupon_dish
-- ----------------------------
DROP TABLE IF EXISTS `crm_coupon_dish`;
CREATE TABLE `crm_coupon_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `coupon_lid` bigint NOT NULL COMMENT '优惠券lid',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '门店名称',
  `dish_lid` bigint NOT NULL COMMENT '菜品编号lid',
  `dish_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜品名称',
  `dish_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_dish_lid`(`mid` ASC, `sid` ASC, `dish_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 829 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '优惠券与菜品关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_coupon_task
-- ----------------------------
DROP TABLE IF EXISTS `crm_coupon_task`;
CREATE TABLE `crm_coupon_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `out_trade_no` bigint NULL DEFAULT NULL COMMENT '业务单号',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '优惠券id',
  `lock_state` int NULL DEFAULT NULL COMMENT '锁状态',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_report_date_mid_out_trade_no`(`report_date` ASC, `mid` ASC, `out_trade_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12380 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '券交易记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_deal_task
-- ----------------------------
DROP TABLE IF EXISTS `crm_deal_task`;
CREATE TABLE `crm_deal_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '门店名称',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡编号',
  `operation_model` int NULL DEFAULT NULL COMMENT '交易类型',
  `out_trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `trade_state` int NULL DEFAULT NULL COMMENT '交易状态',
  `card_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡类型',
  `card_type_code` bigint NULL DEFAULT NULL COMMENT '会员卡类型编号',
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人员',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注信息',
  `principal_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易本金',
  `give_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易赠送金额',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易金额',
  `give_point` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送积分',
  `pay_way` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付方式',
  `pay_way_code` bigint NULL DEFAULT NULL COMMENT '支付方式编号',
  `canceled` tinyint(1) NULL DEFAULT NULL COMMENT '已撤销',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '撤销人',
  `marketer` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营销人',
  `commission_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '提成比例',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `save_rule` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '充值套餐名称',
  `save_rule_code` bigint NULL DEFAULT NULL COMMENT '充值套餐lid',
  `balance` decimal(24, 6) NULL DEFAULT NULL COMMENT '剩余余额',
  `bill_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '账单金额',
  `unpaid` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '本次冻结金额',
  `as_upgrade_cost` tinyint(1) NOT NULL DEFAULT 0 COMMENT '作为升级工本费',
  `org_type_code` bigint NULL DEFAULT NULL COMMENT '原先的会员卡类型',
  `only_principal` tinyint(1) NOT NULL DEFAULT 0 COMMENT '仅扣本金',
  `dash_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '霸王餐赠送金额',
  `unpaid_at` datetime NULL DEFAULT NULL COMMENT '本次冻结时间',
  `give_unpaid` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '本次冻结赠送金额',
  `use_give` tinyint(1) NOT NULL DEFAULT 0 COMMENT '扣减指定赠送',
  `invoice_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '发票金额',
  `invoice` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否开发票',
  `rebate_lid` bigint NULL DEFAULT NULL COMMENT '返佣规则lid（撤销充值时用）',
  `last_rebate_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '返佣比例（撤销充值时用）',
  `last_rebate_lid` bigint NULL DEFAULT NULL COMMENT '上次返佣规则lid（撤销充值时用）',
  `canceled_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '已退金额',
  `canceled_principal_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '已退本金',
  `canceled_give_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '已退赠送',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_out_trade_no`(`mid` ASC, `out_trade_no` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1300489 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '交易任务' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_deal_task_item
-- ----------------------------
DROP TABLE IF EXISTS `crm_deal_task_item`;
CREATE TABLE `crm_deal_task_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `task_lid` bigint NULL DEFAULT NULL COMMENT '任务编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡编号',
  `operation_model` int NULL DEFAULT NULL COMMENT '交易类型',
  `principal_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易本金',
  `give_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易赠送金额',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '交易金额',
  `save_rule` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '充值套餐',
  `save_rule_code` bigint NULL DEFAULT NULL COMMENT '充值套餐编号',
  `give_point` decimal(24, 6) NULL DEFAULT NULL COMMENT '赠送积分',
  `give_coupon_num` int NULL DEFAULT NULL COMMENT '赠送券数量',
  `give_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠送券',
  `give_coupon_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠送券编号',
  `give_coupon_is_map` tinyint(1) NULL DEFAULT NULL COMMENT '赠送的是券包',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `first_charge_gift_coupon` tinyint(1) NULL DEFAULT NULL COMMENT '首次充值赠券',
  `rule_type_lid` bigint NULL DEFAULT NULL COMMENT '其他类型的lid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_task_lid`(`mid` ASC, `task_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1262251 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '交易任务明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_filter
-- ----------------------------
DROP TABLE IF EXISTS `crm_filter`;
CREATE TABLE `crm_filter`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '筛选条件名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 74 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员筛选' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_filter_item
-- ----------------------------
DROP TABLE IF EXISTS `crm_filter_item`;
CREATE TABLE `crm_filter_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `filter_lid` bigint NOT NULL COMMENT '筛选记录lid',
  `filter_type` int NOT NULL COMMENT '筛选类型',
  `opt_type` int NOT NULL COMMENT '操作类型',
  `val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '值',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `id_mid_filter_lid`(`mid` ASC, `filter_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员筛选项' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_member_gift_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_member_gift_record`;
CREATE TABLE `crm_member_gift_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `new_gift` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '新人礼包',
  `new_gift_code` bigint NULL DEFAULT NULL COMMENT '新人礼包编号',
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员名称',
  `member_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员电话',
  `card_lid` bigint NULL DEFAULT NULL COMMENT '会员卡lid',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员open_id',
  `gift_coupon_code` bigint NULL DEFAULT NULL COMMENT '赠券编号',
  `gift_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '赠券名称',
  `gift_num` int NULL DEFAULT NULL COMMENT '赠送数量',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_phone`(`mid` ASC, `sid` ASC, `member_phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1296 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '新人礼包领取记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_overlord_once
-- ----------------------------
DROP TABLE IF EXISTS `crm_overlord_once`;
CREATE TABLE `crm_overlord_once`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `times` int NOT NULL COMMENT '次数',
  `card_lid` bigint NOT NULL COMMENT '会员卡lid',
  `overlord_lid` bigint NOT NULL COMMENT '霸王餐lid',
  `type_` int NOT NULL COMMENT '类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_card_lid_overlord_lid`(`mid` ASC, `card_lid` ASC, `overlord_lid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 399 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '霸王餐参与关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_overlord_store
-- ----------------------------
DROP TABLE IF EXISTS `crm_overlord_store`;
CREATE TABLE `crm_overlord_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `overlord_lid` bigint NULL DEFAULT NULL COMMENT '霸王餐lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_overlord_lid`(`mid` ASC, `overlord_lid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '霸王餐店铺规则关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_purchase_coupon_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_purchase_coupon_record`;
CREATE TABLE `crm_purchase_coupon_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year_` int NOT NULL COMMENT '年',
  `month_` int NOT NULL COMMENT '月',
  `day_` int NOT NULL COMMENT '日',
  `card_lid` bigint NOT NULL COMMENT '会员卡lid',
  `card_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员卡号',
  `open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'openId',
  `union_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'unionId',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员名称',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员手机号',
  `volume` int NOT NULL COMMENT '购买数量',
  `price` decimal(24, 6) NOT NULL COMMENT '购买单价',
  `amount` decimal(24, 6) NOT NULL COMMENT '购买金额',
  `coupon_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '优惠券名称',
  `coupon_lid` bigint NOT NULL COMMENT '优惠券lid',
  `pay_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付终端号',
  `finished` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否支付',
  `finished_at` datetime NULL DEFAULT NULL COMMENT '支付完成时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 529 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '购买券记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_rebate_detail
-- ----------------------------
DROP TABLE IF EXISTS `crm_rebate_detail`;
CREATE TABLE `crm_rebate_detail`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `consume_card_lid` bigint NULL DEFAULT NULL COMMENT '消费卡lid',
  `consume_card_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消费会员卡号',
  `consume_member_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消费会员名称',
  `consume_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '消费会员手机号',
  `consume_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '消费金额',
  `consume_open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '被邀请人open_id',
  `consume_union_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '被邀请人union_id',
  `rebate_card_lid` bigint NULL DEFAULT NULL COMMENT '返佣卡lid',
  `rebate_card_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣会员卡号',
  `rebate_member_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣会员名称',
  `rebate_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣会员手机号',
  `rule_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规则名称',
  `rule_lid` bigint NULL DEFAULT NULL COMMENT '规则lid',
  `rebate_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '返佣比例',
  `rebate_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '返佣金额',
  `rebate_type` int NULL DEFAULT NULL COMMENT '返佣类型',
  `done` tinyint(1) NOT NULL DEFAULT 0 COMMENT '返佣是否处理',
  `done_at` datetime NULL DEFAULT NULL COMMENT '返佣处理完成时间',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消操作人',
  `cancel` tinyint(1) NOT NULL DEFAULT 0 COMMENT '返佣取消',
  `cancel_at` datetime NULL DEFAULT NULL COMMENT '返佣取消时间',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '返佣备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_rule_lid`(`mid` ASC, `rule_lid` ASC) USING BTREE,
  INDEX `idx_mid_rebate_card_lid_type`(`mid` ASC, `rebate_card_lid` ASC, `rebate_type` ASC) USING BTREE,
  INDEX `idx_mid_open_id`(`mid` ASC, `consume_open_id` ASC) USING BTREE,
  INDEX `idx_mid_union_id`(`mid` ASC, `consume_union_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '返佣明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_shareholder
-- ----------------------------
DROP TABLE IF EXISTS `crm_shareholder`;
CREATE TABLE `crm_shareholder`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '活动名称',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `enable` tinyint(1) NOT NULL DEFAULT 1 COMMENT '活动状态',
  `rebate_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '返佣比例',
  `markdown_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '活动描述',
  `rules` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '充值套餐列表',
  `stores` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '店铺列表',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `money_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '赚钱描述',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '共享股东活动' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
