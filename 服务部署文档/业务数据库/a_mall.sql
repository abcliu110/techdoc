-- ====================================
-- 数据库创建脚本 - a_mall
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_mall` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_mall`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_mall

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:39:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for after_sale_pic
-- ----------------------------
DROP TABLE IF EXISTS `after_sale_pic`;
CREATE TABLE `after_sale_pic`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `after_sale_lid` bigint NOT NULL COMMENT '售后申请lid',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '售后申请图片地址',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_sale_lid`(`sid` ASC, `after_sale_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '售后申请图片' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_address
-- ----------------------------
DROP TABLE IF EXISTS `mall_address`;
CREATE TABLE `mall_address`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `default_status` tinyint(1) NULL DEFAULT NULL COMMENT '是否默认收货地址',
  `receive_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收发货人姓名',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人电话',
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省份编码',
  `province` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '省/直辖市',
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市编码',
  `city` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '城市',
  `region_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区编码',
  `region` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区',
  `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '详细地址',
  `addr_tag` int NULL DEFAULT NULL COMMENT '地址标签',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_id`(`mid` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收货地址' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_after_sale
-- ----------------------------
DROP TABLE IF EXISTS `mall_after_sale`;
CREATE TABLE `mall_after_sale`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `after_sale_state` int NOT NULL COMMENT '售后状态',
  `after_sale_type` int NOT NULL COMMENT '售后类型',
  `order_item_lid` bigint NOT NULL COMMENT '商品lid',
  `order_lid` bigint NOT NULL DEFAULT -1 COMMENT '订单lid',
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请原因',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '售后备注',
  `tracking_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '快递单号',
  `user_id` bigint NOT NULL COMMENT '用户lid',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名称',
  `user_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户手机号',
  `apply_at` datetime NOT NULL COMMENT '申请时间',
  `process_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `process_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '处理人',
  `refund` tinyint(1) NOT NULL DEFAULT 0 COMMENT '已退款',
  `refund_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退款人',
  `refund_at` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `order_item_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_user_lid`(`mid` ASC, `report_date` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '微商城售后' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_attr
-- ----------------------------
DROP TABLE IF EXISTS `mall_attr`;
CREATE TABLE `mall_attr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售属性表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_attr_value
-- ----------------------------
DROP TABLE IF EXISTS `mall_attr_value`;
CREATE TABLE `mall_attr_value`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `attr_id` bigint NULL DEFAULT NULL COMMENT '销售属性ID',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售属性值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售属性值描述',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_attr_id`(`mid` ASC, `attr_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '销售属性值' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_brands
-- ----------------------------
DROP TABLE IF EXISTS `mall_brands`;
CREATE TABLE `mall_brands`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌描述',
  `logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '品牌logo图片',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '品牌表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_category
-- ----------------------------
DROP TABLE IF EXISTS `mall_category`;
CREATE TABLE `mall_category`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `show_order` int NULL DEFAULT NULL COMMENT '显示顺序',
  `obsolete` tinyint(1) NULL DEFAULT NULL COMMENT '已经下架',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '类别表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation`;
CREATE TABLE `mall_evaluation`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `order_lid` bigint NOT NULL COMMENT '订单编号',
  `user_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收货人电话',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人名称',
  `head_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评价',
  `eval_type` int NOT NULL COMMENT '评价类型',
  `reply` tinyint(1) NULL DEFAULT 0 COMMENT '是否回复',
  `reply_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复人',
  `reply_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_spu_lid`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_report_date_user_lid`(`mid` ASC, `report_date` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation_detail
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation_detail`;
CREATE TABLE `mall_evaluation_detail`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `eval_lid` bigint NOT NULL COMMENT '评价lid',
  `item_lid` bigint NOT NULL COMMENT '条目lid',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '条目名称',
  `star` decimal(24, 6) NOT NULL COMMENT '星级',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_eval_lid`(`mid` ASC, `eval_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价详情' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation_img
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation_img`;
CREATE TABLE `mall_evaluation_img`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `order_lid` bigint NOT NULL COMMENT '订单编号',
  `eval_lid` bigint NOT NULL COMMENT '评价lid',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_eval_lid`(`mid` ASC, `eval_lid` ASC, `idx` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价图片' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation_item
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation_item`;
CREATE TABLE `mall_evaluation_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '条目名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品评价条目' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation_ref
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation_ref`;
CREATE TABLE `mall_evaluation_ref`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `order_lid` bigint NOT NULL COMMENT '订单编号',
  `order_item_lid` bigint NOT NULL COMMENT '订单物品编号',
  `spu_lid` bigint NOT NULL COMMENT 'spu产品lid',
  `eval_lid` bigint NOT NULL COMMENT '评价lid',
  `sku_lid` bigint NOT NULL COMMENT '规格lid',
  `eval_type` int NOT NULL DEFAULT 1 COMMENT '评论类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_spu_lid_eval_lid`(`mid` ASC, `spu_lid` ASC, `eval_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评价关联商品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_evaluation_reply
-- ----------------------------
DROP TABLE IF EXISTS `mall_evaluation_reply`;
CREATE TABLE `mall_evaluation_reply`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `eval_lid` bigint NOT NULL COMMENT '评价lid',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '回复内容',
  `type_` int NOT NULL COMMENT '类型 1商家回复用户 2用户回复商家',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '上一级lid',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_eval_lid_idx`(`mid` ASC, `eval_lid` ASC, `idx` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商家评价回复' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_feedback
-- ----------------------------
DROP TABLE IF EXISTS `mall_feedback`;
CREATE TABLE `mall_feedback`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `user_lid` bigint NOT NULL COMMENT '反馈用户lid',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈用户名称',
  `user_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈用户手机号码',
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '反馈内容',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商城意见反馈' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_order
-- ----------------------------
DROP TABLE IF EXISTS `mall_order`;
CREATE TABLE `mall_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `task_lid` bigint NULL DEFAULT NULL COMMENT '付款任务lid',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `state` int NULL DEFAULT NULL COMMENT '状态',
  `freight` decimal(24, 6) NULL DEFAULT NULL COMMENT '运费',
  `total_quantity` int NULL DEFAULT NULL COMMENT '总数量',
  `total_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '总金额',
  `pay_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实际支付金额',
  `total_points` decimal(24, 6) NULL DEFAULT NULL COMMENT '总积分',
  `pay_points` decimal(24, 6) NULL DEFAULT NULL COMMENT '耗用积分',
  `pay_type` int NULL DEFAULT NULL COMMENT '支付类型',
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `head_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `out_refund_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退款订单号',
  `out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付订单号',
  `delivery_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货人',
  `delivery_at` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `receiving_at` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `delivery_method` int NULL DEFAULT NULL COMMENT '配送方式',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户名称',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'openId',
  `app_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'appId',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户id',
  `user_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货电话',
  `addr_lid` bigint NULL DEFAULT NULL COMMENT '收货地址lid',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `cancel_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_at` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `refund_at` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `refund_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退款人',
  `order_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单备注',
  `delivery_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货备注',
  `tracking_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '快递单号',
  `evaluated` tinyint(1) NULL DEFAULT 0 COMMENT '是否已评价',
  `eval_lid` bigint NULL DEFAULT NULL COMMENT '评价lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `refund` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否退款',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_report_date_mid_lid`(`report_date` ASC, `mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_report_date_mid_user_id`(`report_date` ASC, `mid` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 879 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_order_item
-- ----------------------------
DROP TABLE IF EXISTS `mall_order_item`;
CREATE TABLE `mall_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `state` int NOT NULL COMMENT '状态',
  `order_id` bigint NOT NULL COMMENT '订单号',
  `sku_standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'sku规格',
  `sku_id` bigint NOT NULL COMMENT 'sku',
  `spu_id` bigint NOT NULL COMMENT '产品id',
  `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品名称',
  `spu_imge` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产品图片',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `buy_num` int NULL DEFAULT NULL COMMENT '购买数量',
  `total_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '总金额',
  `total_points` decimal(24, 6) NULL DEFAULT NULL COMMENT '总积分',
  `price_fee` int NULL DEFAULT NULL COMMENT '售价，整数方式保存',
  `price_scale` int NULL DEFAULT NULL COMMENT '售价，金额对应的小数位数',
  `market_price_fee` int NULL DEFAULT NULL COMMENT '市场价，整数方式保存',
  `market_price_scale` int NULL DEFAULT NULL COMMENT '市场价，金额对应的小数位数',
  `points_fee` int NULL DEFAULT NULL COMMENT '所需积分，整数方式保存',
  `points_scale` int NULL DEFAULT NULL COMMENT '所需积分，金额对应的小数位数',
  `after_sale_lid` bigint NULL DEFAULT NULL COMMENT '售后lid',
  `type` int NULL DEFAULT NULL COMMENT '商品类型',
  `type_lid` bigint NULL DEFAULT NULL COMMENT '其他类型商品的lid',
  `type_num` decimal(24, 6) NULL DEFAULT NULL COMMENT '其他类型商品的数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `user_id` bigint NOT NULL DEFAULT -1 COMMENT '用户lid',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `order_id` ASC) USING BTREE,
  INDEX `idx_mid_user_id_sku_lid`(`mid` ASC, `user_id` ASC, `sku_id` ASC) USING BTREE,
  INDEX `idx_mid_date_user_sku`(`mid` ASC, `report_date` ASC, `user_id` ASC, `sku_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 891 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_order_task
-- ----------------------------
DROP TABLE IF EXISTS `mall_order_task`;
CREATE TABLE `mall_order_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `out_trans_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付订单号',
  `points` decimal(24, 6) NOT NULL COMMENT '积分',
  `order_id` bigint NOT NULL COMMENT '订单lid',
  `deal_state` int NOT NULL COMMENT '处理状态',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_id`(`mid` ASC, `order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 748 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单处理记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_pay_item
-- ----------------------------
DROP TABLE IF EXISTS `mall_pay_item`;
CREATE TABLE `mall_pay_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `amount` decimal(24, 6) NOT NULL COMMENT '支付金额',
  `give_amount` decimal(24, 6) NOT NULL COMMENT '赠送金额',
  `refund_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '已退款金额',
  `refund_give_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '已退款赠送金额',
  `order_lid` bigint NOT NULL COMMENT '订单lid',
  `task_lid` bigint NOT NULL COMMENT '付款任务lid',
  `card_task_lid` bigint NULL DEFAULT NULL COMMENT '会员卡扣款lid',
  `type_` int NOT NULL COMMENT '支付方式',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid_task_lid`(`mid` ASC, `order_lid` ASC, `task_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1492 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单支付记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_sku
-- ----------------------------
DROP TABLE IF EXISTS `mall_sku`;
CREATE TABLE `mall_sku`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'SPU ID',
  `attrs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '销售属性值;{attr_value_id}-{attr_value_id} 多个销售属性值逗号分隔',
  `banner_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'banner图片;多个图片逗号分隔',
  `main_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品介绍主图;多个图片逗号分隔',
  `price_fee` int NULL DEFAULT NULL COMMENT '售价，整数方式保存',
  `price_scale` int NULL DEFAULT NULL COMMENT '售价，金额对应的小数位数',
  `market_price_fee` int NULL DEFAULT NULL COMMENT '市场价，整数方式保存',
  `market_price_scale` int NULL DEFAULT NULL COMMENT '市场价，金额对应的小数位数',
  `points_fee` int NULL DEFAULT NULL COMMENT '所需积分，整数方式保存',
  `points_scale` int NULL DEFAULT NULL COMMENT '所需积分，金额对应的小数位数',
  `sales_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '销量',
  `cost` decimal(24, 6) NULL DEFAULT NULL COMMENT '成本',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `type_lid` bigint NULL DEFAULT NULL COMMENT '值',
  `type_num` decimal(24, 6) NULL DEFAULT NULL COMMENT '数量',
  `show_order` int NULL DEFAULT NULL COMMENT '显示顺序',
  `obsolete` tinyint(1) NULL DEFAULT 0 COMMENT '已经下架',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_spu_id`(`mid` ASC, `spu_id` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 159 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '标准库存单元' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `mall_sku_stock`;
CREATE TABLE `mall_sku_stock`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `quantity` int NULL DEFAULT NULL COMMENT '库存',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_sku_id`(`mid` ASC, `sku_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 159 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'sku库存表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_spu
-- ----------------------------
DROP TABLE IF EXISTS `mall_spu`;
CREATE TABLE `mall_spu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `selling_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '卖点',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `banner_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT 'banner图片;多个图片逗号分隔',
  `main_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '商品介绍主图;多个图片逗号分隔',
  `show_order` int NULL DEFAULT NULL COMMENT '显示顺序',
  `show_in_home` tinyint(1) NULL DEFAULT NULL COMMENT '显示在首页',
  `obsolete` tinyint(1) NULL DEFAULT 0 COMMENT '已经下架',
  `purchase_limit_per_person` int NULL DEFAULT NULL COMMENT '每人总限购数',
  `purchase_limit_per_person_per_day` int NULL DEFAULT NULL COMMENT '每人每天限购数',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_brand_id`(`mid` ASC, `brand_id` ASC) USING BTREE,
  INDEX `idx_mid_category_id`(`mid` ASC, `category_id` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 159 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '标准产品单元' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_spu_sku_attr_map
-- ----------------------------
DROP TABLE IF EXISTS `mall_spu_sku_attr_map`;
CREATE TABLE `mall_spu_sku_attr_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'SPU ID',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `attr_id` bigint NULL DEFAULT NULL COMMENT '销售属性ID',
  `attr_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售属性名称',
  `attr_value_id` bigint NULL DEFAULT NULL COMMENT '销售属性值ID',
  `attr_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '销售属性值',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_spu_id`(`mid` ASC, `spu_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关联关系冗余表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for mall_user_count
-- ----------------------------
DROP TABLE IF EXISTS `mall_user_count`;
CREATE TABLE `mall_user_count`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户编号',
  `new_count` int NULL DEFAULT NULL COMMENT '待付款',
  `paid_count` int NULL DEFAULT NULL COMMENT '待发货',
  `shipped_count` int NULL DEFAULT NULL COMMENT '待收货',
  `delivered_count` int NULL DEFAULT NULL COMMENT '已完成',
  `cancel_count` int NULL DEFAULT NULL COMMENT '已取消',
  `refunded_count` int NULL DEFAULT NULL COMMENT '已退款',
  `evaluated_count` int NULL DEFAULT NULL COMMENT '待评价',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_id`(`mid` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 206 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户订单数' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
