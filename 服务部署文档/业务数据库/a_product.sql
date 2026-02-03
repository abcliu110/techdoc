-- ====================================
-- 数据库创建脚本 - a_product
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_product` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_product`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_product

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:40:44
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for pt_area_in_period
-- ----------------------------
DROP TABLE IF EXISTS `pt_area_in_period`;
CREATE TABLE `pt_area_in_period`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `area_lid` bigint NOT NULL COMMENT '台区lid',
  `period_lid` bigint NOT NULL COMMENT '时段lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_period_lid`(`mid` ASC, `period_lid` ASC) USING BTREE,
  INDEX `idx_mid_area_lid`(`mid` ASC, `area_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30999 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售时段中的台区' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_area_period
-- ----------------------------
DROP TABLE IF EXISTS `pt_area_period`;
CREATE TABLE `pt_area_period`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `begin_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5186 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '区域销售时段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_card_type_free_rule
-- ----------------------------
DROP TABLE IF EXISTS `pt_card_type_free_rule`;
CREATE TABLE `pt_card_type_free_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规则名称',
  `card_type_lid` bigint NULL DEFAULT NULL COMMENT '会员编号',
  `free_content` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '免赠次数内容',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_card_type`(`mid` ASC, `card_type_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员免赠规则' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_cook_ref
-- ----------------------------
DROP TABLE IF EXISTS `pt_cook_ref`;
CREATE TABLE `pt_cook_ref`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `cook_type_lid` bigint NOT NULL COMMENT '做法分类lid',
  `cook_lid` bigint NOT NULL COMMENT '做法lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_cook_lid`(`mid` ASC, `sid` ASC, `cook_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2893103 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '做法分类下的做法' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_cook_type
-- ----------------------------
DROP TABLE IF EXISTS `pt_cook_type`;
CREATE TABLE `pt_cook_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '做法编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '做法名称',
  `order_idx` int NOT NULL COMMENT '排序号',
  `min_practice` int NOT NULL COMMENT '最小做法',
  `max_practice` int NOT NULL COMMENT '最大做法',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 158119 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '做法分类' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_data_sync_record
-- ----------------------------
DROP TABLE IF EXISTS `pt_data_sync_record`;
CREATE TABLE `pt_data_sync_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `src_sid` bigint NULL DEFAULT NULL COMMENT '源门店',
  `src_store_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原门店名称',
  `dest_sid` bigint NULL DEFAULT NULL COMMENT '目标门店',
  `dest_store_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '目标门店名称',
  `back_up_sid` bigint NULL DEFAULT NULL COMMENT '备份门店',
  `status` int NULL DEFAULT NULL COMMENT '状态',
  `error_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '错误信息',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `end_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '数据同步记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_dish_area
-- ----------------------------
DROP TABLE IF EXISTS `pt_dish_area`;
CREATE TABLE `pt_dish_area`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dish_code` bigint NULL DEFAULT NULL COMMENT '菜品编号',
  `dish_type_code` bigint NULL DEFAULT NULL COMMENT '小类编号',
  `dish_supper_type_code` bigint NULL DEFAULT NULL COMMENT '大类编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '部位名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 64 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品部位' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_dish_flavor
-- ----------------------------
DROP TABLE IF EXISTS `pt_dish_flavor`;
CREATE TABLE `pt_dish_flavor`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '口味名称',
  `flavor_type_code` bigint NULL DEFAULT NULL COMMENT '类型编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7167 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品口味' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_dish_table_price
-- ----------------------------
DROP TABLE IF EXISTS `pt_dish_table_price`;
CREATE TABLE `pt_dish_table_price`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `table_type_code` bigint NULL DEFAULT NULL COMMENT '桌台类型',
  `dish_code` bigint NULL DEFAULT NULL COMMENT '菜品编号',
  `dish_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品单位',
  `dish_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '菜品价格',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_dish_lid`(`mid` ASC, `sid` ASC, `dish_code` ASC) USING BTREE,
  INDEX `idx_mid_sid_type_lid_dish_lid`(`mid` ASC, `sid` ASC, `table_type_code` ASC, `dish_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12780655 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品房台价格' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_flavor_type
-- ----------------------------
DROP TABLE IF EXISTS `pt_flavor_type`;
CREATE TABLE `pt_flavor_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 364 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '口味类型' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_free_rule_dish
-- ----------------------------
DROP TABLE IF EXISTS `pt_free_rule_dish`;
CREATE TABLE `pt_free_rule_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `free_rule_lid` bigint NULL DEFAULT NULL COMMENT '免赠规则lid',
  `dish_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品lid',
  `dish_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_rule_id`(`mid` ASC, `sid` ASC, `free_rule_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '免赠规则关联菜品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_image_compress
-- ----------------------------
DROP TABLE IF EXISTS `pt_image_compress`;
CREATE TABLE `pt_image_compress`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片md5值',
  `image_biz_type` int NULL DEFAULT NULL COMMENT '业务类型',
  `origin_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '源路径',
  `target_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '目标路径',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `idx_mid_sid_id`(`mid` ASC, `sid` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13297 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '图片压缩记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_member_price
-- ----------------------------
DROP TABLE IF EXISTS `pt_member_price`;
CREATE TABLE `pt_member_price`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品Lid',
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品单位',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '菜品价格',
  `card_type_lid` bigint NULL DEFAULT NULL COMMENT '会员卡类型Lid',
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '会员卡类型名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `mid_sid_card_type_lid`(`mid` ASC, `sid` ASC, `card_type_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3551297 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员价格' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_queue
-- ----------------------------
DROP TABLE IF EXISTS `pt_queue`;
CREATE TABLE `pt_queue`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '队列编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '队列名称（取号首字母）',
  `min_people` int NOT NULL DEFAULT 1 COMMENT '最少可入座人数',
  `max_people` int NOT NULL DEFAULT 1 COMMENT '最多可入座人数',
  `enable` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否启用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `time_cost` int NOT NULL DEFAULT 0 COMMENT '预估耗时',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1157 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队队列' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_queue_open
-- ----------------------------
DROP TABLE IF EXISTS `pt_queue_open`;
CREATE TABLE `pt_queue_open`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员手机号',
  `open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'open_id',
  `app_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'app_id',
  `type_` int NOT NULL COMMENT '类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `app_id_phone`(`app_id` ASC, `phone` ASC) USING BTREE,
  INDEX `open_id`(`open_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1519 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队叫号openId' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_queue_record
-- ----------------------------
DROP TABLE IF EXISTS `pt_queue_record`;
CREATE TABLE `pt_queue_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `queue_lid` bigint NOT NULL COMMENT '队列lid',
  `queue_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '队列名称',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户手机号',
  `nick_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名称',
  `avatar` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户头像',
  `open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户open_id',
  `period` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时段名',
  `call_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '叫号人',
  `call_at` datetime NULL DEFAULT NULL COMMENT '叫号时间',
  `call_num` int NULL DEFAULT NULL COMMENT '叫号次数',
  `meal_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '就餐人',
  `meal_at` datetime NULL DEFAULT NULL COMMENT '就餐时间',
  `over_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '过号人',
  `over_at` datetime NULL DEFAULT NULL COMMENT '过号时间',
  `queue_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '排队序列号',
  `people` int NOT NULL COMMENT '人数',
  `queue_state` int NOT NULL DEFAULT 1 COMMENT '队列状态',
  `queue_channel` int NOT NULL DEFAULT 2 COMMENT '领号渠道',
  `wait_minute` int NULL DEFAULT NULL COMMENT '等待分钟数',
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '二维码链接',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `reserve` tinyint(1) NOT NULL DEFAULT 0 COMMENT '保留号码',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_queue_lid`(`mid` ASC, `report_date` ASC, `queue_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 75256 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队叫号记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_tbl_area_dish
-- ----------------------------
DROP TABLE IF EXISTS `pt_tbl_area_dish`;
CREATE TABLE `pt_tbl_area_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `tbl_area_lid` bigint NULL DEFAULT NULL COMMENT '区域lid',
  `dish_lid` bigint NULL DEFAULT NULL COMMENT '菜品lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_area_lid`(`mid` ASC, `sid` ASC, `tbl_area_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 35796718 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '区域菜品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pt_x_spec_price
-- ----------------------------
DROP TABLE IF EXISTS `pt_x_spec_price`;
CREATE TABLE `pt_x_spec_price`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dish_lid` bigint NOT NULL COMMENT '菜品lid',
  `price` decimal(24, 6) NOT NULL COMMENT '价格',
  `start_val` decimal(24, 6) NOT NULL COMMENT '开始份数',
  `end_val` decimal(24, 6) NOT NULL COMMENT '结束份数',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_dish_lid`(`mid` ASC, `sid` ASC, `dish_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4578 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '第X份特价' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
