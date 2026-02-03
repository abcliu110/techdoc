-- ====================================
-- 数据库创建脚本 - a_ams
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_ams` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_ams`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_ams

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:39:16
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for account_addr
-- ----------------------------
DROP TABLE IF EXISTS `account_addr`;
CREATE TABLE `account_addr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户编号',
  `consignee` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `email` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人邮箱',
  `mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人手机',
  `country_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家编号',
  `country_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家名称',
  `province_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份编号',
  `province_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份名称',
  `city_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市编号',
  `city_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市名称',
  `county_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区县编号',
  `county_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区县名称',
  `street_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '街道编号',
  `street_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '街道名称',
  `detailed_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '详细地址',
  `postal_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮编',
  `is_default` tinyint(1) NULL DEFAULT NULL COMMENT '默认地址',
  `label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签',
  `longitude` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '经度',
  `latitude` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '纬度',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_id`(`mid` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户地址' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for account_platform
-- ----------------------------
DROP TABLE IF EXISTS `account_platform`;
CREATE TABLE `account_platform`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `third_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '第三方平台的用户标识;比如微信公众号的OPENID',
  `user_id` bigint NOT NULL COMMENT '用户编号',
  `org_type` int NOT NULL COMMENT '组织类型',
  `user_type` int NOT NULL COMMENT '类型',
  `app_type` int NOT NULL COMMENT '平台类型',
  `app_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '平台id;比如微信公众号的appid',
  `nickname` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '删除标志;（0代表存在 1代表删除）',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_third_id`(`third_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14376 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '第三方平台用户信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for account_user
-- ----------------------------
DROP TABLE IF EXISTS `account_user`;
CREATE TABLE `account_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_type` int NOT NULL COMMENT '类型',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户名',
  `password` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `salt` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '盐',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工姓名',
  `email` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `gender` int NULL DEFAULT NULL COMMENT '员工性别',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工头像(相对路径)',
  `nickname` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '员工昵称',
  `province_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份编号',
  `province_label` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份名称',
  `city_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市编号',
  `city_label` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市名称',
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '街道地址',
  `signature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '个性签名',
  `resume` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '个人简介',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认',
  `create_ip_at` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建ip',
  `last_login_at` datetime NULL DEFAULT NULL COMMENT '最后一次登录时间',
  `last_login_ip_at` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后一次登录ip',
  `login_times` int NULL DEFAULT 0 COMMENT '登录次数',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '删除标志;（0代表存在 1代表删除）',
  `effective_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `expiry_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `business_type` int NULL DEFAULT NULL COMMENT '业务类型',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_type_username`(`mid` ASC, `user_type` ASC, `username` ASC) USING BTREE,
  INDEX `idx_mid_type_phone`(`mid` ASC, `user_type` ASC, `phone` ASC) USING BTREE,
  INDEX `idx_mid_type_email`(`mid` ASC, `user_type` ASC, `email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25046 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '账户' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_item
-- ----------------------------
DROP TABLE IF EXISTS `auth_item`;
CREATE TABLE `auth_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限标识',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT NULL COMMENT '显示顺序',
  `is_dir` tinyint(1) NULL DEFAULT NULL COMMENT '目录',
  `invisible` tinyint(1) NULL DEFAULT NULL COMMENT '隐藏',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 175 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统权限' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_role
-- ----------------------------
DROP TABLE IF EXISTS `auth_role`;
CREATE TABLE `auth_role`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'id(权限字符)的md5',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限字符',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色描述',
  `display_order` int NULL DEFAULT NULL COMMENT '显示顺序',
  `data_scope` int NULL DEFAULT NULL COMMENT '数据权限',
  `data_scope_set` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '数据权限集',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `auth_item_set` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '权限集合 多个值,号隔开',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '删除标志;（0代表存在 1代表删除）',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_id_key`(`mid` ASC, `id_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工角色' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for auth_role_staff
-- ----------------------------
DROP TABLE IF EXISTS `auth_role_staff`;
CREATE TABLE `auth_role_staff`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NULL DEFAULT NULL COMMENT '逻辑编号',
  `staff_id` bigint NOT NULL COMMENT '员工id',
  `role_set` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '角色集合 多个值,号隔开',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_staff_id`(`mid` ASC, `staff_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25043 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限角色与员工关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_balance
-- ----------------------------
DROP TABLE IF EXISTS `cap_balance`;
CREATE TABLE `cap_balance`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `account_id` bigint NOT NULL COMMENT '账户id',
  `currency_type` int NOT NULL COMMENT '币种',
  `scale` int NOT NULL COMMENT '金额对应的小数位数;用于转成浮点数',
  `total` int NOT NULL COMMENT '总余额',
  `principal` int NOT NULL COMMENT '本金',
  `gift` int NOT NULL COMMENT '赠送金额',
  `state` int NOT NULL COMMENT '状态',
  `ver` int NOT NULL COMMENT '余额版本号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_account_id`(`mid` ASC, `account_id` ASC) USING BTREE,
  INDEX `idx_mid_biz_type`(`mid` ASC, `cap_biz_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 772701 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_balance_flow
-- ----------------------------
DROP TABLE IF EXISTS `cap_balance_flow`;
CREATE TABLE `cap_balance_flow`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '流水id',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `deal_type` int NULL DEFAULT NULL COMMENT '交易类型;由各个业务模块自己定义，比如充值、退款',
  `voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '凭证 ID;一般是业务单号（如订单 ID、退款单 ID 等）',
  `total` int NOT NULL COMMENT '发生总金额',
  `scale` int NOT NULL COMMENT '金额对应的小数位数;用于转成浮点数',
  `principal` int NOT NULL COMMENT '发生本金',
  `gift` int NOT NULL COMMENT '发生赠送金额',
  `total_before` int NOT NULL COMMENT '起始总金额',
  `principal_before` int NOT NULL COMMENT '起始本金',
  `gift_before` int NOT NULL COMMENT '起始赠送金额',
  `total_after` int NOT NULL COMMENT '终止总金额',
  `principal_after` int NOT NULL COMMENT '终止本金',
  `gift_after` int NOT NULL COMMENT '终止赠送金额',
  `direction` int NOT NULL COMMENT '变动方向',
  `is_rollback` tinyint(1) NULL DEFAULT NULL COMMENT '回滚单;1为回滚单，0为正常单',
  `org_id` bigint NULL DEFAULT NULL COMMENT '原始订单;撤销单时，才有值',
  `src_account_id` bigint NOT NULL COMMENT '源账户id',
  `dest_account_id` bigint NULL DEFAULT NULL COMMENT '目的账号id',
  `currency_type` int NOT NULL COMMENT '币种',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `ver` int NULL DEFAULT NULL COMMENT '余额版本号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `report_date` datetime NULL DEFAULT NULL COMMENT '会计日期',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_voucher_id`(`voucher_id` ASC) USING BTREE,
  INDEX `idx_src_account_id`(`src_account_id` ASC) USING BTREE,
  INDEX `idx_mid_biz_type_report_time`(`mid` ASC, `cap_biz_type` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 773334 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_balance_task
-- ----------------------------
DROP TABLE IF EXISTS `cap_balance_task`;
CREATE TABLE `cap_balance_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `deal_type` int NULL DEFAULT NULL COMMENT '交易类型',
  `voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '凭证 ID;一般是业务单号（如订单 ID、退款单 ID 等）',
  `org_voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原始凭证 ID;撤销单该字段才有值，标识被撤销的原始单据',
  `total` int NOT NULL COMMENT '发生总金额',
  `scale` int NOT NULL COMMENT '金额对应的小数位数;用于转成浮点数',
  `principal` int NOT NULL COMMENT '发生本金',
  `gift` int NOT NULL COMMENT '发生赠送金额',
  `src_account_id` bigint NOT NULL COMMENT '源账户id',
  `dest_account_id` bigint NULL DEFAULT NULL COMMENT '目的账号id',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `currency_type` int NOT NULL COMMENT '币种',
  `delay_time_to_check_for_rollback` int NULL DEFAULT NULL COMMENT '延时检查时间',
  `redis_key_for_rollback` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '判断是否需要回滚的;延迟delay_time_to_check_for_rollback，如果key存在，就需要回滚',
  `rolled_back` tinyint(1) NULL DEFAULT NULL COMMENT '已经回滚',
  `rollback_time` datetime NULL DEFAULT NULL COMMENT '回滚时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_voucher_id`(`org_voucher_id` ASC) USING BTREE,
  INDEX `idx_mid_create_time`(`mid` ASC, `created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 915 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额变动任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_coupon
-- ----------------------------
DROP TABLE IF EXISTS `cap_coupon`;
CREATE TABLE `cap_coupon`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `category_id` bigint NULL DEFAULT NULL COMMENT '目录',
  `title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `state` int NULL DEFAULT NULL COMMENT '发布状态',
  `image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '图片',
  `price` int NULL DEFAULT NULL COMMENT '价格',
  `user_limit` int NULL DEFAULT NULL COMMENT '每人限领张数',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始有效时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `pulish_count` int NULL DEFAULT NULL COMMENT '发行总数',
  `stock` int NULL DEFAULT NULL COMMENT '当前库存',
  `condition_price` int NULL DEFAULT NULL COMMENT '满多少才可以使用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_category`(`mid` ASC, `category_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_coupon_category
-- ----------------------------
DROP TABLE IF EXISTS `cap_coupon_category`;
CREATE TABLE `cap_coupon_category`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券类型' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_coupon_record
-- ----------------------------
DROP TABLE IF EXISTS `cap_coupon_record`;
CREATE TABLE `cap_coupon_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `coupon_id` bigint NULL DEFAULT NULL COMMENT '优惠券id',
  `coupon_name` bigint NULL DEFAULT NULL COMMENT '优惠券标题',
  `state` int NULL DEFAULT NULL COMMENT '状态',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户id',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `order_id` bigint NULL DEFAULT NULL COMMENT '订单编号',
  `price` int NULL DEFAULT NULL COMMENT '抵扣架构',
  `condition_price` int NULL DEFAULT NULL COMMENT '满多少才可以使用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_id`(`mid` ASC, `user_id` ASC) USING BTREE,
  INDEX `idx_mid_order_id`(`mid` ASC, `order_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '领券记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_coupon_task
-- ----------------------------
DROP TABLE IF EXISTS `cap_coupon_task`;
CREATE TABLE `cap_coupon_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `coupon_record_id` bigint NULL DEFAULT NULL COMMENT '优惠券记录id',
  `out_trade_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单号',
  `state` int NULL DEFAULT NULL COMMENT '锁定状态',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_record_id`(`mid` ASC, `coupon_record_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券记录锁定任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_rights
-- ----------------------------
DROP TABLE IF EXISTS `cap_rights`;
CREATE TABLE `cap_rights`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `account_id` bigint NOT NULL COMMENT '账户id',
  `expired_time` datetime NOT NULL COMMENT '过期时间',
  `state` int NOT NULL COMMENT '状态',
  `ver` bigint NULL DEFAULT NULL COMMENT '过期时间版本号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_biz_type_account_id`(`mid` ASC, `cap_biz_type` ASC, `account_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 652742 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_rights_flow
-- ----------------------------
DROP TABLE IF EXISTS `cap_rights_flow`;
CREATE TABLE `cap_rights_flow`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '流水id',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `deal_type` int NULL DEFAULT NULL COMMENT '交易类型;由各个业务模块自己定义，比如充值、退款',
  `voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '凭证 ID;一般是业务单号（如订单 ID、退款单 ID 等）',
  `time_value` int NOT NULL COMMENT '改变时间',
  `time_unit` int NOT NULL COMMENT '时间单位;用于转成浮点数',
  `expired_time_before` datetime NOT NULL COMMENT '变更前',
  `expired_time_after` datetime NOT NULL COMMENT '变更后',
  `direction` int NOT NULL COMMENT '变动方向;1为入账，0为出账',
  `is_rollback` tinyint(1) NULL DEFAULT NULL COMMENT '回滚单;1为回滚单，0为正常单',
  `org_id` bigint NULL DEFAULT NULL COMMENT '原始订单;退款单时，才有值',
  `src_account_id` bigint NOT NULL COMMENT '源账户id',
  `dest_account_id` bigint NULL DEFAULT NULL COMMENT '目的账号id',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `ver` int NULL DEFAULT NULL COMMENT '余额版本号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `report_date` datetime NULL DEFAULT NULL COMMENT '会计日期',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_account_id_report_time`(`mid` ASC, `cap_biz_type` ASC, `src_account_id` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_voucher_id_report_time`(`mid` ASC, `cap_biz_type` ASC, `voucher_id` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 645198 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_rights_task
-- ----------------------------
DROP TABLE IF EXISTS `cap_rights_task`;
CREATE TABLE `cap_rights_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `deal_type` int NULL DEFAULT NULL COMMENT '交易类型',
  `voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '凭证 ID;一般是业务单号（如订单 ID、退款单 ID 等）',
  `org_voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原始凭证 ID;撤销单该字段才有值，标识被撤销的原始单据',
  `time_value` int NULL DEFAULT NULL COMMENT '变化时间',
  `time_unit` int NULL DEFAULT NULL COMMENT '时间单位;用于转成浮点数',
  `expired_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `src_account_id` bigint NULL DEFAULT NULL COMMENT '源账户id',
  `dest_account_id` bigint NULL DEFAULT NULL COMMENT '目的账号id',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `delay_time_to_check_for_rollback` int NULL DEFAULT NULL COMMENT '延时检查时间',
  `redis_key_for_rollback` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '判断是否需要回滚的;延迟delay_time_to_check_for_rollback，如果key存在，就需要回滚',
  `rolled_back` tinyint(1) NULL DEFAULT NULL COMMENT '已经回滚',
  `rollback_time` datetime NULL DEFAULT NULL COMMENT '回滚时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2094 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益表变动任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_traffic
-- ----------------------------
DROP TABLE IF EXISTS `cap_traffic`;
CREATE TABLE `cap_traffic`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `account_id` bigint NOT NULL COMMENT '账户id',
  `expired_time` datetime NOT NULL COMMENT '过期时间',
  `spu_lid` bigint NULL DEFAULT NULL COMMENT 'spu',
  `spu_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'spu名称',
  `sku_lid` bigint NULL DEFAULT NULL COMMENT 'sku',
  `limit_times` int NULL DEFAULT NULL COMMENT '限制次数',
  `used_times` int NULL DEFAULT NULL COMMENT '已用次数',
  `app_trade_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商城订单号',
  `billing_type` int NULL DEFAULT NULL COMMENT '计费类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_account_id`(`mid` ASC, `account_id` ASC) USING BTREE,
  INDEX `idx_mid_app_trade_no`(`mid` ASC, `app_trade_no` ASC) USING BTREE,
  INDEX `idx_expired_time`(`expired_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流量包' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for cap_traffic_task
-- ----------------------------
DROP TABLE IF EXISTS `cap_traffic_task`;
CREATE TABLE `cap_traffic_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `org_type` int NOT NULL COMMENT '机构类型',
  `use_type` int NULL DEFAULT NULL COMMENT '用户类型',
  `cap_biz_type` int NOT NULL COMMENT '业务类型',
  `account_id` bigint NOT NULL COMMENT '账户id',
  `use_times` int NOT NULL COMMENT '扣减次数',
  `voucher_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '凭证 ID;一般是业务单号（如订单 ID、退款单 ID 等）',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `delay_time_to_check_for_rollback` int NULL DEFAULT NULL COMMENT '延时检查时间',
  `redis_key_for_rollback` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '判断是否需要回滚的;延迟delay_time_to_check_for_rollback，如果key存在，就需要回滚',
  `rolled_back` tinyint(1) NULL DEFAULT NULL COMMENT '已经回滚',
  `rollback_time` datetime NULL DEFAULT NULL COMMENT '回滚时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_voucher_id`(`voucher_id` ASC) USING BTREE,
  INDEX `idx_biz_type_account_id`(`mid` ASC, `cap_biz_type` ASC, `account_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流量包任务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_recharge_pkg
-- ----------------------------
DROP TABLE IF EXISTS `crm_recharge_pkg`;
CREATE TABLE `crm_recharge_pkg`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_lid` bigint NULL DEFAULT NULL COMMENT 'spu',
  `sku_lid` bigint NULL DEFAULT NULL COMMENT 'sku',
  `save_amount` bigint NULL DEFAULT NULL COMMENT '充值金额',
  `give_amount` bigint NULL DEFAULT NULL COMMENT '赠送金额',
  `give_point` bigint NULL DEFAULT NULL COMMENT '赠送积分',
  `give_coupon_id` bigint NULL DEFAULT NULL COMMENT '赠送券编号',
  `give_coupon_num` int NULL DEFAULT NULL COMMENT '赠送券数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `idx_mid_sku`(`mid` ASC, `sku_lid` ASC) USING BTREE,
  UNIQUE INDEX `idx_mid_spu`(`mid` ASC, `spu_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '充值套餐' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_rights_pkg
-- ----------------------------
DROP TABLE IF EXISTS `crm_rights_pkg`;
CREATE TABLE `crm_rights_pkg`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_lid` bigint NULL DEFAULT NULL COMMENT 'spu',
  `sku_lid` bigint NULL DEFAULT NULL COMMENT 'sku',
  `add_time` int NULL DEFAULT NULL COMMENT '增加时间',
  `time_unit` int NULL DEFAULT NULL COMMENT '时间单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sku`(`mid` ASC, `sku_lid` ASC) USING BTREE,
  INDEX `idx_mid_spu`(`mid` ASC, `spu_lid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员权益套餐' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_traffic_pkg
-- ----------------------------
DROP TABLE IF EXISTS `crm_traffic_pkg`;
CREATE TABLE `crm_traffic_pkg`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_lid` bigint NULL DEFAULT NULL COMMENT 'spu',
  `sku_lid` bigint NULL DEFAULT NULL COMMENT 'sku',
  `times` int NULL DEFAULT NULL COMMENT '次数',
  `billing_type` int NULL DEFAULT NULL COMMENT '计费类型',
  `valid_time` int NULL DEFAULT NULL COMMENT '有效时间',
  `valid_time_unit` int NULL DEFAULT NULL COMMENT '有效时间单位',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sku`(`mid` ASC, `sku_lid` ASC) USING BTREE,
  INDEX `idx_mid_spu`(`mid` ASC, `spu_lid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流量包' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for deal_order
-- ----------------------------
DROP TABLE IF EXISTS `deal_order`;
CREATE TABLE `deal_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单编号',
  `src` int NULL DEFAULT NULL COMMENT '来源',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户编号',
  `user_lever` int NULL DEFAULT NULL COMMENT '用户等级',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户姓名',
  `user_gender` int NULL DEFAULT NULL COMMENT '用户性别',
  `user_avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户头像',
  `skus_amount` int NULL DEFAULT NULL COMMENT '商品总金额',
  `pay_amount` int NULL DEFAULT NULL COMMENT '实际支付金额',
  `freight_amount` int NULL DEFAULT NULL COMMENT '运费金额',
  `promotion_amount` int NULL DEFAULT NULL COMMENT '优惠金额',
  `integration_amount` int NULL DEFAULT NULL COMMENT '积分抵扣金额',
  `coupon_amount` int NULL DEFAULT NULL COMMENT '优惠券抵扣金额',
  `discount_amount` int NULL DEFAULT NULL COMMENT '管理调整金额',
  `used_integration` int NULL DEFAULT NULL COMMENT '扣除积分',
  `status` int NULL DEFAULT NULL COMMENT '订单状态',
  `type` int NULL DEFAULT NULL COMMENT '订单类型',
  `biz_type` int NULL DEFAULT NULL COMMENT '业务类型;对应ProductBizTypeEnum',
  `cap_biz_type` int NULL DEFAULT NULL COMMENT '资金账户类型',
  `auto_confirm_day` int NULL DEFAULT NULL COMMENT '自动确认时间;单位为天',
  `integration` int NULL DEFAULT NULL COMMENT '可获积分',
  `growth` int NULL DEFAULT NULL COMMENT '成长值',
  `promotion_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动信息',
  `invoice_type` int NULL DEFAULT NULL COMMENT '发票类型',
  `invoice_header` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发票抬头',
  `invoice_content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '发票内容',
  `invoice_receiver_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收票人电话',
  `invoice_receiver_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收票人邮箱',
  `paid` tinyint(1) NULL DEFAULT NULL COMMENT '已支付',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `pay_method_map` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式',
  `delivery_time` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '收货时间',
  `comment_time` datetime NULL DEFAULT NULL COMMENT '评论时间',
  `modify_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单备注',
  `logistics_company` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流公司',
  `logistics_sn` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物流单号',
  `consignee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人姓名',
  `consignee_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人邮箱',
  `consignee_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人手机',
  `consignee_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人地址',
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '订单摘要',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `org_type` int NULL DEFAULT NULL COMMENT '机构类型',
  `user_type` int NULL DEFAULT NULL COMMENT '用户类型',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `sn` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for deal_order_item
-- ----------------------------
DROP TABLE IF EXISTS `deal_order_item`;
CREATE TABLE `deal_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `order_lid` bigint NULL DEFAULT NULL COMMENT '订单逻辑编号',
  `order_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单条码',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'sku_id',
  `sku_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'sku条码',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'spu_id',
  `spu_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品图片',
  `spu_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `spu_category_id` bigint NULL DEFAULT NULL COMMENT '商品类目编号',
  `spu_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品类目名称',
  `price` bigint NULL DEFAULT NULL COMMENT '销售价格',
  `quantity` bigint NULL DEFAULT NULL COMMENT '销售数量',
  `pay_amount` int NULL DEFAULT NULL COMMENT '实际支付金额',
  `skus_amount` int NULL DEFAULT NULL COMMENT '商品总金额',
  `freight_amount` int NULL DEFAULT NULL COMMENT '运费金额',
  `promotion_amount` int NULL DEFAULT NULL COMMENT '优惠金额',
  `integration_amount` int NULL DEFAULT NULL COMMENT '积分抵扣金额',
  `coupon_amount` int NULL DEFAULT NULL COMMENT '优惠券抵扣金额',
  `discount_amount` int NULL DEFAULT NULL COMMENT '管理调整金额',
  `used_integration` int NULL DEFAULT NULL COMMENT '扣除积分',
  `integration` int NULL DEFAULT NULL COMMENT '可获积分',
  `growth` int NULL DEFAULT NULL COMMENT '成长值',
  `attr_map` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '销售属性',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_sn`(`mid` ASC, `order_sn` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单商品明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for deal_order_pay
-- ----------------------------
DROP TABLE IF EXISTS `deal_order_pay`;
CREATE TABLE `deal_order_pay`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `order_lid` bigint NULL DEFAULT NULL COMMENT '订单逻辑编号',
  `order_sn` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单条码',
  `type` int NULL DEFAULT NULL COMMENT '支付方式',
  `method` int NULL DEFAULT NULL COMMENT '支付方式类型',
  `amount` bigint NULL DEFAULT NULL COMMENT '支付金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_id`(`mid` ASC, `order_lid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '订单支付明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for deal_shopping_cart
-- ----------------------------
DROP TABLE IF EXISTS `deal_shopping_cart`;
CREATE TABLE `deal_shopping_cart`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_id` bigint NULL DEFAULT NULL COMMENT '用户编号',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'spu_id',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'sku_id',
  `sku_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品条码',
  `spu_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `price` bigint NULL DEFAULT NULL COMMENT '价格',
  `quantity` int NULL DEFAULT NULL COMMENT '数量',
  `attr_map` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '销售属性',
  `spu_main_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品主图',
  `spu_brand` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品品牌',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_id`(`mid` ASC, `user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '购物车' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nms_online_log
-- ----------------------------
DROP TABLE IF EXISTS `nms_online_log`;
CREATE TABLE `nms_online_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户名称',
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `product` int NULL DEFAULT NULL COMMENT '产品类型',
  `first_request` datetime NULL DEFAULT NULL COMMENT '首次请求',
  `last_request` datetime NULL DEFAULT NULL COMMENT '最后一次请求',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `dev_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `inst` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '代理商',
  `inst_code` bigint NULL DEFAULT NULL COMMENT '代理商编号',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_report_date`(`report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 272513 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '在线记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for nms_overtime_log
-- ----------------------------
DROP TABLE IF EXISTS `nms_overtime_log`;
CREATE TABLE `nms_overtime_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户名称',
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `product` int NULL DEFAULT NULL COMMENT '产品类型',
  `expired` tinyint(1) NULL DEFAULT NULL COMMENT '已经过期',
  `expired_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `surplus_days` int NULL DEFAULT NULL COMMENT '剩余天数',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `dev_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '设备编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `inst` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '代理商',
  `inst_code` bigint NULL DEFAULT NULL COMMENT '代理商编号',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_report_date`(`report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8904 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '产品过期记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_channel
-- ----------------------------
DROP TABLE IF EXISTS `pay_channel`;
CREATE TABLE `pay_channel`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type` int NULL DEFAULT NULL COMMENT '通道类型',
  `merchant_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户名称',
  `merchant_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `terminal_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终端号',
  `access_token` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '秘钥',
  `app_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'appId',
  `api_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '证书key',
  `api_cert` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '证书cert',
  `api_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付门店号',
  `private_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '商户私钥',
  `public_key` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '平台公钥',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付通道' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_log_data
-- ----------------------------
DROP TABLE IF EXISTS `pay_log_data`;
CREATE TABLE `pay_log_data`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `app_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用方订单号',
  `trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本次交易唯一id;整个支付系统唯一，生成他的原因主要是 order_id对于其它应用来说可能重复',
  `request_params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '支付的请求参数',
  `type` int NULL DEFAULT NULL COMMENT '类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `idx_sid_app_trade_no`(`sid` ASC, `app_trade_no` ASC) USING BTREE,
  INDEX `trade_no`(`trade_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_refund
-- ----------------------------
DROP TABLE IF EXISTS `pay_refund`;
CREATE TABLE `pay_refund`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `pay_type` int NULL DEFAULT NULL COMMENT '支付渠道',
  `pay_way` int NULL DEFAULT NULL COMMENT '支付方式',
  `channel_type` int NULL DEFAULT NULL COMMENT '通道类型',
  `channel_no` bigint NULL DEFAULT NULL COMMENT '通道号',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户',
  `merchant_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `app_refund_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用方的退款id',
  `org_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '源支付单号',
  `refund_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退款单编号',
  `third_refund_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方支付的退款单号',
  `channel_refund_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付通道退款单号',
  `bank_refund_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '银行退款单号',
  `refund_fee` decimal(10, 0) NULL DEFAULT NULL COMMENT '退款金额',
  `refund_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '退款理由',
  `refund_status` int NULL DEFAULT NULL COMMENT '退款状态',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid_app_no`(`sid` ASC, `app_refund_no` ASC) USING BTREE,
  INDEX `idx_org_trade_no`(`org_trade_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '退款单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_store_and_channel
-- ----------------------------
DROP TABLE IF EXISTS `pay_store_and_channel`;
CREATE TABLE `pay_store_and_channel`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `channel_no` bigint NULL DEFAULT NULL COMMENT '支付通道号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE,
  INDEX `idx_channel_no`(`channel_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '门店的通道设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_transaction
-- ----------------------------
DROP TABLE IF EXISTS `pay_transaction`;
CREATE TABLE `pay_transaction`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `lid` bigint NOT NULL COMMENT '订单号',
  `pay_type` int NULL DEFAULT NULL COMMENT '支付渠道',
  `pay_way` int NULL DEFAULT NULL COMMENT '支付方式',
  `channel_type` int NULL DEFAULT NULL COMMENT '通道类型',
  `channel_no` bigint NULL DEFAULT NULL COMMENT '通道号',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户',
  `merchant_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `app_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '应用方订单号',
  `trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本次交易唯一id;整个支付系统唯一，生成他的原因主要是 order_id对于其它应用来说可能重复',
  `third_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方支付平台的单号',
  `channel_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通道订单号，微信订单号、支付宝订单号等，返回时不参与签名',
  `bank_trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '银行渠道订单号，微信支付时显示在支付成功页面的条码，可用作扫码查询和扫码退款时匹配',
  `terminal_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终端号',
  `terminal_time` datetime NULL DEFAULT NULL COMMENT '终端交易时间，yyyyMMddHHmmss，全局统一时间格式',
  `total_fee` int NULL DEFAULT NULL COMMENT '金额，单位分',
  `receipt_fee` int NULL DEFAULT NULL COMMENT '实收金额',
  `refund_fee` int NULL DEFAULT NULL COMMENT '退款金额',
  `trade_state` int NULL DEFAULT NULL COMMENT '交易状态',
  `return_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付后的跳转',
  `pay_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '二维码链接',
  `notify_time` datetime NULL DEFAULT NULL COMMENT '支付平台回调时间',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `refund_time` datetime NULL DEFAULT NULL COMMENT '退款时间',
  `close_time` datetime NULL DEFAULT NULL COMMENT '关闭时间',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '顾客的邮箱',
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '付款方用户id，“微信openid”、“支付宝账户”、“qq号”等，返回时不参与签名',
  `attach` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '附加数据,原样返回',
  `notify_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '回调地址',
  `deal_type` int NULL DEFAULT NULL COMMENT '支付种类',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_sid_app_trade_no`(`sid` ASC, `app_trade_no` ASC) USING BTREE,
  INDEX `idx_trade_no`(`trade_no` ASC) USING BTREE,
  INDEX `idx_created_time`(`created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付流水表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for pay_transaction_extension
-- ----------------------------
DROP TABLE IF EXISTS `pay_transaction_extension`;
CREATE TABLE `pay_transaction_extension`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `trade_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '本次交易唯一id',
  `call_num` bigint NULL DEFAULT NULL COMMENT '发起调用的次数;异步通知的时候回填给应用端',
  `extension_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '扩展内容',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_tarde_no`(`trade_no` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '交易扩展表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for plat_area
-- ----------------------------
DROP TABLE IF EXISTS `plat_area`;
CREATE TABLE `plat_area`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `code` bigint NOT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `city_code` bigint NOT NULL COMMENT '城市编号',
  `province_code` bigint NOT NULL COMMENT '省份编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_province_code`(`province_code` ASC) USING BTREE,
  INDEX `idx_city_code`(`city_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2979 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '区县' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for plat_city
-- ----------------------------
DROP TABLE IF EXISTS `plat_city`;
CREATE TABLE `plat_city`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `code` bigint NOT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  `province_code` bigint NOT NULL COMMENT '省份编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_province_code`(`province_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 343 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '城市' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for plat_province
-- ----------------------------
DROP TABLE IF EXISTS `plat_province`;
CREATE TABLE `plat_province`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `code` bigint NOT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '名称',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '省份' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_attr
-- ----------------------------
DROP TABLE IF EXISTS `product_attr`;
CREATE TABLE `product_attr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `category` bigint NULL DEFAULT NULL COMMENT '类别编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '描述',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_category`(`mid` ASC, `category` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '销售属性' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_attr_value
-- ----------------------------
DROP TABLE IF EXISTS `product_attr_value`;
CREATE TABLE `product_attr_value`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `attr_id` bigint NULL DEFAULT NULL COMMENT '属性编号',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '属性值描述',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_attr`(`mid` ASC, `attr_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '销售属性值' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_brands
-- ----------------------------
DROP TABLE IF EXISTS `product_brands`;
CREATE TABLE `product_brands`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '品牌名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '品牌描述',
  `logo_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'logo',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '品牌' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_category
-- ----------------------------
DROP TABLE IF EXISTS `product_category`;
CREATE TABLE `product_category`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `biz_type` int NULL DEFAULT NULL COMMENT '产品类型',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述',
  `pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '图片',
  `previous` bigint NULL DEFAULT NULL COMMENT '上一级',
  `path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '分类地址',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商品类别' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_sku
-- ----------------------------
DROP TABLE IF EXISTS `product_sku`;
CREATE TABLE `product_sku`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'SPU_ID',
  `biz_type` int NULL DEFAULT NULL COMMENT '产品类型',
  `cap_biz_type` int NULL DEFAULT NULL COMMENT '资金账户类型',
  `attrs` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '销售属性值;{attr_value_id}-{attr_value_id} 多个销售属性值逗号分隔',
  `attrs_md5` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售属性值的md5',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `banner_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'banner图片;多个图片逗号分隔',
  `main_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '商品介绍主图;多个图片逗号分隔',
  `price_fee` int NULL DEFAULT NULL COMMENT '售价;整数方式保存',
  `price_scale` bigint NULL DEFAULT NULL COMMENT '售价;金额对应的小数位数',
  `market_price_fee` int NULL DEFAULT NULL COMMENT '市场价;整数方式保存',
  `market_price_scale` bigint NULL DEFAULT NULL COMMENT '市场价;金额对应的小数位数',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `amount_in_spu` int NULL DEFAULT NULL COMMENT '对应spu包含的sku数量',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_spu`(`mid` ASC, `spu_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标准库存单位' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_sku_stock
-- ----------------------------
DROP TABLE IF EXISTS `product_sku_stock`;
CREATE TABLE `product_sku_stock`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `quantity` int NULL DEFAULT NULL COMMENT '库存',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sku`(`mid` ASC, `sku_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '库存表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_spu
-- ----------------------------
DROP TABLE IF EXISTS `product_spu`;
CREATE TABLE `product_spu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `biz_type` int NULL DEFAULT NULL COMMENT '产品类型',
  `cap_biz_type` int NULL DEFAULT NULL COMMENT '资金账户类型',
  `brand_id` bigint NULL DEFAULT NULL COMMENT '品牌ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '描述',
  `selling_point` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '卖点',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位',
  `banner_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'banner图片;多个图片逗号分隔',
  `main_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '商品介绍主图;多个图片逗号分隔',
  `price_fee` int NULL DEFAULT NULL COMMENT '售价;整数方式保存',
  `price_scale` bigint NULL DEFAULT NULL COMMENT '售价;金额对应的小数位数',
  `market_price_fee` int NULL DEFAULT NULL COMMENT '市场价;整数方式保存',
  `market_price_scale` bigint NULL DEFAULT NULL COMMENT '市场价;金额对应的小数位数',
  `begin_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '终止时间',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '停用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `org_type` int NULL DEFAULT NULL COMMENT '机构类型',
  `user_type` int NULL DEFAULT NULL COMMENT '用户类型',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_brand`(`mid` ASC, `brand_id` ASC) USING BTREE,
  INDEX `idx_mid_category`(`mid` ASC, `category_id` ASC) USING BTREE,
  INDEX `idx_mid_biz_type`(`mid` ASC, `biz_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标准产品单位' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_spu_sku_attr_map
-- ----------------------------
DROP TABLE IF EXISTS `product_spu_sku_attr_map`;
CREATE TABLE `product_spu_sku_attr_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `spu_id` bigint NULL DEFAULT NULL COMMENT 'SPU ID',
  `sku_id` bigint NULL DEFAULT NULL COMMENT 'SKU ID',
  `attr_id` bigint NULL DEFAULT NULL COMMENT '销售属性ID',
  `attr_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售属性名称',
  `attr_value_id` bigint NULL DEFAULT NULL COMMENT '销售属性值ID',
  `attr_value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '销售属性值',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_spu`(`mid` ASC, `spu_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '关联关系冗余表;-- 1. spu下 有哪些sku\r\n-- 2. spu下 有那些销售属性\r\n-- 3. spu下 每个销售属性对应的销售属性值(一对多)\r\n-- 4. spu下 每个销售属性值对应的sku(一对多)' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_dog_and_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_dog_and_store`;
CREATE TABLE `sc_dog_and_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dog_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '加密狗号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `dog_pid` bigint NULL DEFAULT NULL COMMENT '加密狗pid',
  `inst` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '代理商',
  `inst_code` bigint NULL DEFAULT NULL COMMENT '代理商编号',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE,
  INDEX `idx_dog_id`(`dog_id` ASC) USING BTREE,
  INDEX `idx_dog_pid`(`dog_pid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2425 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '加密狗和门店的隐射关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_config_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_config_data`;
CREATE TABLE `sys_config_data`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号;',
  `mid` bigint NOT NULL COMMENT '商户号;',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号;',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type_id_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '键名;',
  `val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '字符串值',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_id_key`(`mid` ASC, `sid` ASC, `type_id_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '配置参数' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_config_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_config_type`;
CREATE TABLE `sys_config_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `module` int NULL DEFAULT NULL COMMENT '模块',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参数名称',
  `id_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参数键名',
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参数键名',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `type` int NULL DEFAULT NULL COMMENT '类型',
  `enums` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '对应的枚举',
  `def_val` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '默认值',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '系统内置',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_id_key`(`mid` ASC, `id_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '参数列表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型',
  `sort` int NULL DEFAULT 0 COMMENT '排序',
  `code` int NULL DEFAULT NULL COMMENT '字典编码',
  `label` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签',
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '键值',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '系统内置',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_type`(`mid` ASC, `type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '字典数据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `id_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'id的md5',
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '类型',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '系统内置',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_id_key`(`mid` ASC, `id_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '字典' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_login_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户账号',
  `user_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户姓名',
  `operator_group` int NULL DEFAULT NULL COMMENT '操作员分组',
  `login_type` int NULL DEFAULT NULL COMMENT '操作类型',
  `success` tinyint(1) NULL DEFAULT NULL COMMENT '登录成功',
  `ip` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主机地址',
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '登录地点',
  `browser` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '浏览器',
  `os` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作系统',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_data_type_mid_created_time`(`mid` ASC, `created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1555 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '登录日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_op_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_op_log`;
CREATE TABLE `sys_op_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `title` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务模块',
  `operator_group` int NULL DEFAULT NULL COMMENT '操作员分组',
  `business_type` int NULL DEFAULT NULL COMMENT '业务类型',
  `business_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务说明',
  `method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '方法名称',
  `request_method` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求方式',
  `terminal_type` int NULL DEFAULT NULL COMMENT '终端类型',
  `oper_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作人员',
  `dept_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '请求url',
  `oper_ip` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '操作地点',
  `oper_param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '请求参数',
  `json_result` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '返回参数',
  `success` tinyint(1) NULL DEFAULT NULL COMMENT '成功',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '错误信息',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_data_type_mid_created_time`(`operator_group` ASC, `mid` ASC, `created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3000 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_org
-- ----------------------------
DROP TABLE IF EXISTS `sys_org`;
CREATE TABLE `sys_org`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `app_type` int NOT NULL COMMENT '应用类型',
  `org_type` int NOT NULL COMMENT '组织类型',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '父编号',
  `principal` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_org_type`(`mid` ASC, `org_type` ASC) USING BTREE,
  INDEX `idx_org_type_id`(`org_type` ASC, `id` ASC) USING BTREE,
  INDEX `idx_parent_id_org_type`(`parent_lid` ASC, `org_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19663 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组织机构' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for third_app_conf
-- ----------------------------
DROP TABLE IF EXISTS `third_app_conf`;
CREATE TABLE `third_app_conf`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '商户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `third_appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方平台 appid',
  `authorizer_appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号或小程序的 appid',
  `app_type` int NULL DEFAULT NULL COMMENT '应用类型',
  `bridge_model` int NULL DEFAULT NULL COMMENT '对接模式',
  `secret` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '秘钥',
  `token` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'token',
  `aes_key` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'EncodingAESKey',
  `msg_data_format` int NULL DEFAULT NULL COMMENT '消息格式',
  `nick_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `principal_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主体名称',
  `head_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `user_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原始 ID',
  `alias` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号所设置的微信号，可能为空',
  `service_type_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号或者小程序类型',
  `verify_type_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号或者小程序认证类型',
  `qrcode_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '二维码图片的 URL',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_appid`(`authorizer_appid` ASC) USING BTREE,
  INDEX `idx_mid_sid_app_type`(`mid` ASC, `sid` ASC, `app_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '第三方平台配置数据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_menu
-- ----------------------------
DROP TABLE IF EXISTS `wx_menu`;
CREATE TABLE `wx_menu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `tag_id` bigint NULL DEFAULT NULL COMMENT '用户标签的id',
  `show_order` int NULL DEFAULT NULL COMMENT '显示顺序',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '父编号',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '名称',
  `key_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'key',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'url',
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'appid',
  `pagepath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'pagepath',
  `article_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'article_id',
  `media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'media_id',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '公众号菜单栏' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_msg_tmpl
-- ----------------------------
DROP TABLE IF EXISTS `wx_msg_tmpl`;
CREATE TABLE `wx_msg_tmpl`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_type` int NULL DEFAULT NULL COMMENT '产品类型',
  `biz_type` int NULL DEFAULT NULL COMMENT '业务类型',
  `template_id_short` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模板库中模板的编号，有“TM**”和“OPENTMTM**”等形式,对于类目模板，为纯数字ID',
  `first_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '一级类目',
  `second_category_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '二级类目',
  `class_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'class_id',
  `ref_cnt` int NULL DEFAULT NULL COMMENT 'ref_cnt',
  `tid` int NULL DEFAULT NULL COMMENT '编号',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标题',
  `type` int NULL DEFAULT NULL COMMENT 'type',
  `version` int NULL DEFAULT NULL COMMENT 'version',
  `disable` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `template_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模板ID',
  `jump_type` int NULL DEFAULT NULL COMMENT '跳转类型',
  `appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'appid',
  `page_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '跳转页面',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_biz_type`(`mid` ASC, `biz_type` ASC) USING BTREE,
  INDEX `idx_mid_tid`(`mid` ASC, `tid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '模板消息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_msg_tmpl_item
-- ----------------------------
DROP TABLE IF EXISTS `wx_msg_tmpl_item`;
CREATE TABLE `wx_msg_tmpl_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `biz_type` int NULL DEFAULT NULL COMMENT '业务类型',
  `tmlp_lid` bigint NULL DEFAULT NULL COMMENT '模板编号',
  `color` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '颜色',
  `editable` tinyint(1) NULL DEFAULT NULL COMMENT '可以编辑',
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内容',
  `example` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '示例',
  `kid` int NULL DEFAULT NULL COMMENT 'kid',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关键字',
  `rule` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '值',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_biz_type`(`mid` ASC, `biz_type` ASC) USING BTREE,
  INDEX `idx_mid_tmpl_lid`(`mid` ASC, `tmlp_lid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '模板消息内容' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_user
-- ----------------------------
DROP TABLE IF EXISTS `wx_user`;
CREATE TABLE `wx_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'appid',
  `openid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `unionid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'unionid',
  `nick_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `language` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '语言',
  `city` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市',
  `province` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份',
  `country` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `phone_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `pure_phone_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `country_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家码',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_openid`(`openid` ASC) USING BTREE,
  INDEX `idx_appid`(`appid` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '微信用户' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
