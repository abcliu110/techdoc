-- ====================================
-- 数据库创建脚本 - a_captail
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_captail` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_captail`;

/*
 Navicat Premium Dump SQL

 Source Server         : tdsql
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 Source Host           : 172.16.0.144:3306
 Source Schema         : a_captail

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-cynos-3.1.16.003)
 File Encoding         : 65001

 Date: 31/01/2026 12:39:41
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户地址' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '第三方平台用户信息' ROW_FORMAT = Dynamic;

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
  `business_type` int NULL DEFAULT NULL COMMENT '业务类型',
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
  `effective_time` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `expiry_time` datetime NULL DEFAULT NULL COMMENT '失效时间',
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
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_type_username`(`mid` ASC, `user_type` ASC, `username` ASC) USING BTREE,
  INDEX `idx_mid_type_phone`(`mid` ASC, `user_type` ASC, `phone` ASC) USING BTREE,
  INDEX `idx_mid_type_email`(`mid` ASC, `user_type` ASC, `email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '账户' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '系统权限' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '员工角色' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权限角色与员工关系' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 94 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额流水表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 93 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '余额变动任务表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券类型' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '领券记录' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '优惠券记录锁定任务表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益流水表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '权益表变动任务表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流量包' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流量包任务表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '区县' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '城市' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '省份' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '配置参数' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '参数列表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '字典数据' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '字典' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 235 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '登录日志' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 437 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '操作日志' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '组织机构' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
