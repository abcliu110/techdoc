-- ====================================
-- 数据库创建脚本 - a_wms
-- 适用于 MySQL 数据库
-- 执行工具: dbear
-- ====================================

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `a_wms` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `a_wms`;

/*
 Navicat Premium Dump SQL

 Source Server         : 172.16.0.12
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-txsql)
 Source Host           : 172.16.0.12:3306
 Source Schema         : a_wms

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-txsql)
 File Encoding         : 65001

 Date: 31/01/2026 12:38:56
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for order_item_depart_relate
-- ----------------------------
DROP TABLE IF EXISTS `order_item_depart_relate`;
CREATE TABLE `order_item_depart_relate`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `type_` int NOT NULL DEFAULT 1 COMMENT '订货单类型',
  `volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '数量',
  `item_lid` bigint NOT NULL COMMENT '物品lid',
  `order_lid` bigint NOT NULL COMMENT '订单lid',
  `depart_lid` bigint NOT NULL COMMENT '部门lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `report_date` datetime NULL DEFAULT NULL COMMENT '订货日期',
  `supplier_lid` bigint NULL DEFAULT NULL COMMENT '供应商lid',
  `goods_lid` bigint NULL DEFAULT NULL COMMENT '物品lid',
  `delivery_type` int NULL DEFAULT NULL COMMENT '配送方式',
  `order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单id',
  `order_state` int NULL DEFAULT NULL COMMENT '单据状态',
  `org_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '原订货数量（标准单位）',
  `inspect_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '验货数量',
  `amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '金额',
  `org_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '原金额',
  `inspect_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '验货金额',
  `inspect` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否验货',
  `counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '计量数量',
  `inbound_lid` bigint NULL DEFAULT NULL COMMENT '入库单lid',
  `inbound_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '入库单id',
  `scarce` tinyint(1) NULL DEFAULT 0 COMMENT '缺货',
  `reject` tinyint(1) NULL DEFAULT 0 COMMENT '拒收',
  `reject_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒收人',
  `reject_at` datetime NULL DEFAULT NULL COMMENT '拒收时间',
  `reject_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒收原因',
  `cancel` tinyint(1) NULL DEFAULT 0 COMMENT '取消',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_at` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `cancel_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `refund_state` int NULL DEFAULT 0 COMMENT '退货状态',
  `refund_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '退货数量',
  `refund_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货人',
  `refund_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货时间',
  `refund_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货原因',
  `refund_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货单号',
  `inspect_indent_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '订购验货数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `item_lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `order_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 116391 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订货单物品与部门关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_assist_cost
-- ----------------------------
DROP TABLE IF EXISTS `sc_assist_cost`;
CREATE TABLE `sc_assist_cost`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '辅助成本定义' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_auto_deduct_task
-- ----------------------------
DROP TABLE IF EXISTS `sc_auto_deduct_task`;
CREATE TABLE `sc_auto_deduct_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `warehouse_lid` bigint NOT NULL COMMENT '扣减仓库lid',
  `st_bill_lid` bigint NOT NULL COMMENT '库存单据lid',
  `st_bill_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '库存单据id',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '扣减数量',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '扣减金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_report_date_bill_lid`(`mid` ASC, `sid` ASC, `report_date` ASC, `st_bill_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 526 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '自动扣减记录（用于反扣减冲红）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_bill_invoice_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_bill_invoice_order`;
CREATE TABLE `sc_bill_invoice_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '记账日期',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额',
  `supplier_lid` bigint NOT NULL COMMENT '供应商lid',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `invoice_type` int NOT NULL COMMENT '发票类型',
  `invoice_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '发票号码',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发票备注',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_lid` bigint NULL DEFAULT NULL COMMENT '取消人lid',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `settle_type` int NOT NULL DEFAULT 1 COMMENT '结算类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_supplier_lid`(`mid` ASC, `supplier_lid` ASC) USING BTREE,
  INDEX `idx_mid_organ_lid`(`mid` ASC, `organ_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单据发票记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_bill_invoice_ref
-- ----------------------------
DROP TABLE IF EXISTS `sc_bill_invoice_ref`;
CREATE TABLE `sc_bill_invoice_ref`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '记账日期',
  `invoice_order_lid` bigint NOT NULL COMMENT '发票记录lid',
  `st_bill_lid` bigint NOT NULL COMMENT '仓库单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库单据id',
  `supplier_lid` bigint NOT NULL COMMENT '供应商lid',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `amount` decimal(24, 6) NOT NULL COMMENT '发票金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `invoice_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发票记录与单据关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_bill_pay_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_bill_pay_item`;
CREATE TABLE `sc_bill_pay_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '付款日期',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '付款名称',
  `supplier_lid` bigint NOT NULL COMMENT '供应商lid',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `st_bill_lid` bigint NOT NULL COMMENT '仓库单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库单据id',
  `type_` int NOT NULL COMMENT '付款类型',
  `amount` decimal(24, 6) NOT NULL COMMENT '核销金额',
  `balance_before` decimal(24, 6) NOT NULL COMMENT '核销前金额',
  `balance_after` decimal(24, 6) NOT NULL COMMENT '核销后金额',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '付款备注',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_lid` bigint NULL DEFAULT NULL COMMENT '取消人lid',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `bill_type` int NOT NULL DEFAULT 1 COMMENT '单据类型',
  `settle_type` int NOT NULL DEFAULT 1 COMMENT '结算类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_bill_lid`(`mid` ASC, `st_bill_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 50 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单据付款记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_bill_stock
-- ----------------------------
DROP TABLE IF EXISTS `sc_bill_stock`;
CREATE TABLE `sc_bill_stock`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year_` int NOT NULL COMMENT '年',
  `month_` int NOT NULL COMMENT '月',
  `day_` int NOT NULL COMMENT '日',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单编号',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `volume` decimal(24, 6) NOT NULL COMMENT '扣减数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `volume_for_counter` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '扣减计数数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_bill_id`(`mid` ASC, `sid` ASC, `bill_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38894 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '账单库存预扣减' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_check_prohibit
-- ----------------------------
DROP TABLE IF EXISTS `sc_check_prohibit`;
CREATE TABLE `sc_check_prohibit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_warehouse_lid`(`mid` ASC, `warehouse_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 45 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点禁用物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_check_template
-- ----------------------------
DROP TABLE IF EXISTS `sc_check_template`;
CREATE TABLE `sc_check_template`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '盘点模板名称',
  `rows_` int NOT NULL COMMENT '物品数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点模板' ROW_FORMAT = Dynamic;

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
  `goods_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品编号',
  `goods_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品名称',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '标准数量',
  `counting_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '计量数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_template_lid`(`mid` ASC, `template_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 708 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点模板物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_deduct_day
-- ----------------------------
DROP TABLE IF EXISTS `sc_deduct_day`;
CREATE TABLE `sc_deduct_day`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '日期',
  `deducted` tinyint(1) NOT NULL COMMENT '是否扣减',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 312 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '有未扣减记录天数' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_deduct_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_deduct_goods`;
CREATE TABLE `sc_deduct_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店名称',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year_` int NOT NULL COMMENT '年',
  `month_` int NOT NULL COMMENT '月',
  `day_` int NOT NULL COMMENT '日',
  `st_bill_lid` bigint NOT NULL COMMENT '库存单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '库存单据id',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '账单编号',
  `profit_lid` bigint NOT NULL COMMENT '毛利表lid,保留字段',
  `organ_lid` bigint NULL DEFAULT NULL COMMENT '扣减组织',
  `organ_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '扣减组织名称',
  `tbl_area_lid` bigint NULL DEFAULT NULL COMMENT '区域lid',
  `tbl_area_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域编号',
  `tbl_area_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品编号',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `product_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品单位',
  `product_idx` int NOT NULL COMMENT '商品索引',
  `product_volume` decimal(24, 6) NOT NULL DEFAULT 1.000000 COMMENT '商品数量',
  `product_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '商品金额',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `goods_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品名称',
  `goods_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品单位',
  `standard_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标准单位',
  `goods_unit_lid` bigint NOT NULL COMMENT '物品单位lid',
  `theory_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '理论用量',
  `actual_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '实际用量',
  `counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '计量数量',
  `diff_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '用量差异',
  `theory_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '理论成本',
  `actual_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '实际成本',
  `wastage_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '耗损成本',
  `diff_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '成本差异',
  `net_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '出净率',
  `net_weight` decimal(24, 6) NULL DEFAULT NULL COMMENT '净料重量',
  `yield_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '出成率',
  `cooked_weight` decimal(24, 6) NULL DEFAULT NULL COMMENT '熟菜重量',
  `unit_type` int NULL DEFAULT NULL COMMENT '扣库单位类型',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '商品小类lid',
  `small_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品小类名称',
  `super_type_lid` bigint NULL DEFAULT NULL COMMENT '商品大类lid',
  `super_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品大类名称',
  `source_type` int NULL DEFAULT NULL COMMENT '来源类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_profit_lid`(`mid` ASC, `profit_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '单据商品扣库详情' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_deduct_product
-- ----------------------------
DROP TABLE IF EXISTS `sc_deduct_product`;
CREATE TABLE `sc_deduct_product`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year_` int NOT NULL COMMENT '年',
  `month_` int NOT NULL COMMENT '月',
  `day_` int NOT NULL COMMENT '日',
  `st_bill_lid` bigint NOT NULL COMMENT '库存单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '库存单据id',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单编号',
  `organ_lid` bigint NULL DEFAULT NULL COMMENT '扣减组织',
  `organ_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '扣减组织名称',
  `tbl_area_lid` bigint NULL DEFAULT NULL COMMENT '区域lid',
  `tbl_area_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区域编号',
  `tbl_area_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '区域名称',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品编号',
  `product_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `product_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `product_idx` int NOT NULL COMMENT '商品索引',
  `product_volume` decimal(24, 6) NOT NULL DEFAULT 1.000000 COMMENT '商品数量',
  `product_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '商品金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_st_bill_lid`(`st_bill_lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_bill_id`(`mid` ASC, `sid` ASC, `bill_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7272 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单据商品扣减记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_deduct_rule
-- ----------------------------
DROP TABLE IF EXISTS `sc_deduct_rule`;
CREATE TABLE `sc_deduct_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `relate_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品/小类/大类的id',
  `relate_lid` bigint NOT NULL COMMENT '商品/小类/大类的lid',
  `tbl_area_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '台区id',
  `tbl_area_lid` bigint NOT NULL COMMENT '台区lid',
  `organ_lid` bigint NOT NULL COMMENT '要扣减的组织lid',
  `type` int NOT NULL DEFAULT 1 COMMENT '类型，1 商品 2小类 3 大类',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_relate_lid`(`mid` ASC, `relate_lid` ASC) USING BTREE,
  INDEX `idx_mid_tbl_area_lid`(`mid` ASC, `tbl_area_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 582 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品扣减规则' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_delivery_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_order`;
CREATE TABLE `sc_delivery_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单据编号',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `is_suit_all` tinyint(1) NOT NULL DEFAULT 1 COMMENT '全统一/部分例外',
  `quote_state` int NOT NULL COMMENT '报价状态',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `release_lid` bigint NULL DEFAULT NULL COMMENT '发布人lid',
  `release_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发布人',
  `release_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送报价单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_delivery_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_order_item`;
CREATE TABLE `sc_delivery_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `goods_type_lid` bigint NOT NULL COMMENT '物品类别lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `price` decimal(24, 6) NOT NULL COMMENT '报价',
  `added_tax_type` int NOT NULL COMMENT '采购税率',
  `last_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '上期价格',
  `last_order_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '最近一次进货价',
  `begin_date` datetime NOT NULL COMMENT '价格生效日期',
  `end_date` datetime NOT NULL COMMENT '价格失效日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_quote_lid`(`mid` ASC, `quote_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3714 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送报价物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_delivery_order_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_order_store`;
CREATE TABLE `sc_delivery_order_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '适用门店sid',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_quote_lid`(`mid` ASC, `quote_order_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送报价单适用组织' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_delivery_quote
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_quote`;
CREATE TABLE `sc_delivery_quote`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `goods_type_lid` bigint NOT NULL COMMENT '物品类别lid',
  `price` decimal(24, 6) NOT NULL COMMENT '售价/加价/比例系数',
  `last_order_price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '上次进货单价',
  `final_price` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '最终价格',
  `added_tax_type` int NOT NULL COMMENT '采购税率',
  `incr_type` int NOT NULL COMMENT '加价方式',
  `is_suit_all` tinyint(1) NOT NULL COMMENT '是否统一',
  `begin_date` datetime NOT NULL COMMENT '价格生效日期',
  `end_date` datetime NOT NULL COMMENT '价格失效日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_goods_lid_sid`(`mid` ASC, `goods_lid` ASC, `sid` ASC) USING BTREE,
  INDEX `idx_mid_created_time`(`mid` ASC, `created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27235 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送协议价' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_delivery_rule
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_rule`;
CREATE TABLE `sc_delivery_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '适用门店lid',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `delivery_type` int NOT NULL COMMENT '配送方式',
  `supplier_lid` bigint NOT NULL COMMENT '供应商lid',
  `def_supplier_lid` bigint NULL DEFAULT NULL COMMENT '默认供应商lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `price` decimal(24, 6) NOT NULL COMMENT '采购价格',
  `added_tax_type` int NOT NULL COMMENT '采购税率',
  `begin_date` datetime NOT NULL COMMENT '价格生效日期',
  `end_date` datetime NOT NULL COMMENT '价格失效日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_supplier_lid`(`mid` ASC, `supplier_lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 345163 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送规则' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_depart_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_depart_order`;
CREATE TABLE `sc_depart_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `store_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '门店订货单编号',
  `store_order_lid` bigint NULL DEFAULT NULL COMMENT '门店订货单lid',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `rows` int NOT NULL COMMENT '记录数',
  `volume` decimal(24, 6) NOT NULL COMMENT '总数量',
  `tax_amount` decimal(24, 6) NOT NULL COMMENT '含税金额',
  `amount` decimal(24, 6) NOT NULL COMMENT '总金额',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `reject_lid` bigint NULL DEFAULT NULL COMMENT '驳回人lid',
  `reject_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '驳回人',
  `reject_time` datetime NULL DEFAULT NULL COMMENT '驳回时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_org_lid`(`mid` ASC, `report_date` ASC, `organ_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_store_order_lid`(`mid` ASC, `report_date` ASC, `store_order_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1934 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '档口订货单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_depart_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_depart_order_item`;
CREATE TABLE `sc_depart_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `depart_order_lid` bigint NOT NULL COMMENT '档口订货单lid',
  `depart_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '档口订货单编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `volume` decimal(24, 6) NOT NULL COMMENT '标准数量',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `price` decimal(24, 6) NOT NULL COMMENT '订购价格',
  `amount` decimal(24, 6) NOT NULL COMMENT '订购总额',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `arrival_time` datetime NOT NULL COMMENT '到货日期',
  `delivery_type` int NOT NULL COMMENT '配送方式',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_depart_order_lid`(`mid` ASC, `report_date` ASC, `depart_order_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 84178 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '档口订货物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods`;
CREATE TABLE `sc_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品名称',
  `enable` tinyint(1) NULL DEFAULT NULL COMMENT '启用/禁用',
  `goods_type_lid` bigint NOT NULL COMMENT '物品类型lid',
  `mnemonic_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '助记码',
  `standards` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品规格',
  `reference_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '参考价',
  `subject_type` int NULL DEFAULT NULL COMMENT '统计科目',
  `check_in_type` int NULL DEFAULT NULL COMMENT '盘点频率',
  `indent` tinyint(1) NULL DEFAULT NULL COMMENT '可订货',
  `min_indent` decimal(24, 6) NULL DEFAULT NULL COMMENT '最小订购量',
  `single_indent` decimal(24, 6) NULL DEFAULT NULL COMMENT '单次订购量',
  `refund` tinyint(1) NULL DEFAULT NULL COMMENT '可退货',
  `inbound` tinyint(1) NULL DEFAULT NULL COMMENT '可入库',
  `min_indent_multiple` decimal(24, 6) NULL DEFAULT NULL COMMENT '最小订货单位倍数',
  `check_in_order` tinyint(1) NULL DEFAULT NULL COMMENT '订货校验库存',
  `safety_upper` decimal(24, 6) NULL DEFAULT NULL COMMENT '安全库存上限',
  `safety_lower` decimal(24, 6) NULL DEFAULT NULL COMMENT '安全库存下限',
  `mandatory` tinyint(1) NULL DEFAULT NULL COMMENT '必订物品',
  `weight` tinyint(1) NULL DEFAULT NULL COMMENT '称重物品',
  `loss_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '损耗率',
  `expiry` tinyint(1) NULL DEFAULT NULL COMMENT '保质期',
  `expiry_day` int NULL DEFAULT NULL COMMENT '保质期（天）',
  `reminder_day` int NULL DEFAULT NULL COMMENT '提前提醒天数',
  `in_expiry_day` int NULL DEFAULT NULL COMMENT '入库保质期临期天数',
  `out_expiry_day` int NULL DEFAULT NULL COMMENT '出库保质期临期天数',
  `batch_manage` tinyint(1) NULL DEFAULT NULL COMMENT '批次管理',
  `expend` tinyint(1) NULL DEFAULT NULL COMMENT '入库即耗用',
  `sn_manage` tinyint(1) NULL DEFAULT NULL COMMENT 'SN码管理',
  `inspect_type` int NULL DEFAULT NULL COMMENT '验货比率',
  `tax_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '税收分类编码',
  `tax_type` int NULL DEFAULT NULL COMMENT '税率',
  `label_lid` bigint NULL DEFAULT NULL COMMENT '标签lid',
  `producer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '产地',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `storage_factor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '储存条件',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `is_suit_all` tinyint(1) NOT NULL COMMENT '适用所有店铺',
  `shelve` tinyint(1) NOT NULL DEFAULT 1 COMMENT '上/下架',
  `indent_decimal` tinyint(1) NOT NULL DEFAULT 1 COMMENT '订货允许小数',
  `last_order_price` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '最近订货价',
  `pinyin` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拼音',
  `last_price_date` datetime NULL DEFAULT NULL COMMENT '最后一次价格订单日期',
  `indent_by_counting` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `id` ASC) USING BTREE,
  INDEX `idx_mid_name`(`mid` ASC, `name` ASC) USING BTREE,
  INDEX `idx_mid_good_type_lid`(`mid` ASC, `goods_type_lid` ASC) USING BTREE,
  INDEX `idx_mid_label_lid`(`mid` ASC, `label_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 72070 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods_img
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_img`;
CREATE TABLE `sc_goods_img`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品图片地址',
  `goods_lid` bigint NOT NULL COMMENT '物品Lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_goods_lid`(`goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 776 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品与图片关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods_in_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_in_warehouse`;
CREATE TABLE `sc_goods_in_warehouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `price` decimal(24, 6) NOT NULL COMMENT '库存价格',
  `volume` decimal(24, 6) NOT NULL COMMENT '当前数量',
  `amount` decimal(24, 6) NOT NULL COMMENT '当前金额',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `bill_lid` bigint NOT NULL COMMENT '单据lid',
  `item_lid` bigint NOT NULL COMMENT '物品的lid',
  `last_stock_time` datetime NOT NULL COMMENT '入库时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '当前数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_warehouse_lid`(`mid` ASC, `warehouse_lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `item_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 405363 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品仓库库存' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_store`;
CREATE TABLE `sc_goods_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `store_lid` bigint NOT NULL COMMENT '门店sid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_store_lid`(`mid` ASC, `store_lid` ASC) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 606 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品门店关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_type`;
CREATE TABLE `sc_goods_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编码',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '上一级',
  `level` int NOT NULL COMMENT '层级',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `id` ASC) USING BTREE,
  INDEX `idx_mid_name`(`mid` ASC, `name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1702 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品类型' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_goods_unit
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_unit`;
CREATE TABLE `sc_goods_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单位名称',
  `goods_lid` bigint NOT NULL COMMENT '物品Lid',
  `unit_lid` bigint NULL DEFAULT NULL COMMENT '单位lid(备用)',
  `type_` int NOT NULL COMMENT '单位类型',
  `bar_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '条码',
  `org_ratio` decimal(24, 6) NOT NULL COMMENT '标准单位数量',
  `ratio` decimal(24, 6) NOT NULL COMMENT '当前单位数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `for_counting` tinyint(1) NULL DEFAULT NULL COMMENT '用于计数',
  `generate` tinyint(1) NULL DEFAULT 0 COMMENT '已产生单据',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_name`(`mid` ASC, `name` ASC) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_unit_lid`(`mid` ASC, `unit_lid` ASC) USING BTREE,
  INDEX `idx_mid_barcode`(`mid` ASC, `bar_code` ASC) USING BTREE,
  INDEX `idx_goods_lid`(`goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 363537 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品单位' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_history_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_history_order`;
CREATE TABLE `sc_history_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `uid` bigint NOT NULL COMMENT '用户编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `rows` int NOT NULL COMMENT '记录数',
  `volume` decimal(24, 6) NOT NULL COMMENT '总数量',
  `amount` decimal(24, 6) NOT NULL COMMENT '总金额',
  `tax_amount` decimal(24, 6) NOT NULL COMMENT '含税金额',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_uid`(`mid` ASC, `uid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3536 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '最后一次订单记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_history_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_history_order_item`;
CREATE TABLE `sc_history_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `uid` bigint NOT NULL COMMENT '用户编号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `history_order_lid` bigint NOT NULL COMMENT '订单lid',
  `history_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `price` decimal(24, 6) NOT NULL COMMENT '订购价格',
  `amount` decimal(24, 6) NOT NULL COMMENT '订购总额',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `arrival_time` datetime NOT NULL COMMENT '到货日期',
  `delivery_type` int NOT NULL COMMENT '配送方式',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `history_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_uid`(`mid` ASC, `uid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 80916 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '最后一次订单物品记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_history_remark
-- ----------------------------
DROP TABLE IF EXISTS `sc_history_remark`;
CREATE TABLE `sc_history_remark`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `uid` bigint NOT NULL COMMENT '用户lid',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_uid`(`mid` ASC, `uid` ASC) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 136 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '历史备注' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_invoice_attachment
-- ----------------------------
DROP TABLE IF EXISTS `sc_invoice_attachment`;
CREATE TABLE `sc_invoice_attachment`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '记账日期',
  `invoice_order_lid` bigint NOT NULL COMMENT '发票记录lid',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '附件地址',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `invoice_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '发票附件列表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_item_attachment
-- ----------------------------
DROP TABLE IF EXISTS `sc_item_attachment`;
CREATE TABLE `sc_item_attachment`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '日期',
  `item_lid` bigint NOT NULL COMMENT '物品lid',
  `bill_lid` bigint NOT NULL COMMENT '单据lid',
  `type_` int NOT NULL COMMENT '类型',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '附件地址',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `item_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品附件' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_order_template
-- ----------------------------
DROP TABLE IF EXISTS `sc_order_template`;
CREATE TABLE `sc_order_template`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模板名称',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 56 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订货模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_order_template_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_order_template_item`;
CREATE TABLE `sc_order_template_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `order_lid` bigint NOT NULL COMMENT '模板lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `volume` decimal(24, 6) NOT NULL COMMENT '物品数量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_order_lid`(`mid` ASC, `sid` ASC, `order_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 542 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订货模板物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_organ_target
-- ----------------------------
DROP TABLE IF EXISTS `sc_organ_target`;
CREATE TABLE `sc_organ_target`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `year` int NOT NULL COMMENT '年份',
  `month` int NOT NULL COMMENT '月份',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `amount` decimal(24, 6) NOT NULL COMMENT '目标金额',
  `min_rate` decimal(24, 6) NOT NULL COMMENT '毛利润参考最小值',
  `max_rate` decimal(24, 6) NOT NULL COMMENT '毛利润参考最大值',
  `type_` int NOT NULL COMMENT '类型',
  `revision` int NOT NULL DEFAULT 0 COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_year_lid`(`mid` ASC, `year` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_year_sid_organ_lid`(`mid` ASC, `year` ASC, `sid` ASC, `organ_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 94 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组织目标管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_pay_task
-- ----------------------------
DROP TABLE IF EXISTS `sc_pay_task`;
CREATE TABLE `sc_pay_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `amount` decimal(24, 6) NOT NULL COMMENT '支付金额',
  `wms_type` int NOT NULL COMMENT '供应链业务类型',
  `state` int NOT NULL COMMENT '支付状态',
  `app_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'appId',
  `open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户open_id',
  `pay_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付单号',
  `finished_at` datetime NULL DEFAULT NULL COMMENT '支付完成时间',
  `order_lids` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单lid列表',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应链支付申请记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_prepay_checked_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_prepay_checked_item`;
CREATE TABLE `sc_prepay_checked_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '付款日期',
  `prepay_order_lid` bigint NOT NULL COMMENT '预付款单lid',
  `prepay_order_item_lid` bigint NOT NULL COMMENT '预付款项lid',
  `bill_pay_item_lid` bigint NOT NULL COMMENT '单据某次的预付款lid',
  `st_bill_lid` bigint NOT NULL COMMENT '仓库单据lid',
  `supplier_lid` bigint NOT NULL COMMENT '供货商的lid',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `type_` int NOT NULL COMMENT '付款类型',
  `amount` decimal(24, 6) NOT NULL COMMENT '核销金额',
  `balance_before` decimal(24, 6) NOT NULL COMMENT '核销前金额',
  `balance_after` decimal(24, 6) NOT NULL COMMENT '核销后金额',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_lid` bigint NULL DEFAULT NULL COMMENT '取消人lid',
  `cancel_time` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_pay_item_lid`(`mid` ASC, `bill_pay_item_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预付款核销记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_prepay_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_prepay_order`;
CREATE TABLE `sc_prepay_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单据编号',
  `report_date` datetime NOT NULL COMMENT '单据日期',
  `supplier_lid` bigint NOT NULL COMMENT '供货商编号',
  `rows` int NOT NULL COMMENT '记录数',
  `total_amount` decimal(24, 6) NOT NULL COMMENT '总金额',
  `surplus_amount` decimal(24, 6) NOT NULL COMMENT '剩余金额',
  `checked_amount` decimal(24, 6) NOT NULL COMMENT '已核销金额',
  `order_state` int NOT NULL COMMENT '订单状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_supplier_lid`(`mid` ASC, `supplier_lid` ASC) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商预付款' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_prepay_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_prepay_order_item`;
CREATE TABLE `sc_prepay_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '单据日期',
  `supplier_lid` bigint NOT NULL COMMENT '供货商编号',
  `order_state` int NOT NULL COMMENT '订单状态',
  `prepay_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预付款单据编号',
  `prepay_order_lid` bigint NOT NULL COMMENT '预付款单lid',
  `amount` decimal(24, 6) NOT NULL COMMENT '预付金额',
  `surplus_amount` decimal(24, 6) NOT NULL COMMENT '剩余金额',
  `checked_amount` decimal(24, 6) NOT NULL COMMENT '已核销金额',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预付款名称',
  `type_` int NOT NULL COMMENT '付款类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `prepay_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_supplier_lid`(`mid` ASC, `supplier_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商预付款项' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product
-- ----------------------------
DROP TABLE IF EXISTS `sc_product`;
CREATE TABLE `sc_product`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_type_lid` bigint NOT NULL COMMENT '商品类别lid',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜品编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜品名称',
  `enable` tinyint(1) NOT NULL DEFAULT 1 COMMENT '启用/禁用',
  `idx` int NOT NULL COMMENT '菜品顺序',
  `setup` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否设置',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid_id`(`mid` ASC, `sid` ASC, `id` ASC) USING BTREE,
  INDEX `idx_mid_product_type_lid`(`mid` ASC, `product_type_lid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1957452 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_cost
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_cost`;
CREATE TABLE `sc_product_cost`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '成本名称',
  `assist_lid` bigint NOT NULL COMMENT '辅助成本的lid',
  `rate` decimal(24, 6) NOT NULL COMMENT '占比',
  `cost` decimal(24, 6) NOT NULL COMMENT '成本',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_product_lid_unit`(`mid` ASC, `product_lid` ASC, `product_unit` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品其他成本' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_raw
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_raw`;
CREATE TABLE `sc_product_raw`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `goods_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品单位',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `raw_weight` decimal(24, 6) NOT NULL COMMENT '原料重量',
  `price` decimal(24, 6) NOT NULL COMMENT '原料单价',
  `net_rate` decimal(24, 6) NOT NULL COMMENT '出净率',
  `net_weight` decimal(24, 6) NOT NULL COMMENT '净料重量',
  `yield_rate` decimal(24, 6) NOT NULL COMMENT '出成率',
  `cooked_weight` decimal(24, 6) NOT NULL COMMENT '熟菜重量',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额（元）',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `unit_type` int NOT NULL DEFAULT 1 COMMENT '物品单位类型',
  `last_order_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '上次进货单价',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_product_lid_unit`(`mid` ASC, `product_lid` ASC, `product_unit` ASC) USING BTREE,
  INDEX `idx_mid_goods_lid`(`mid` ASC, `goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 987 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品原料' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_resource
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_resource`;
CREATE TABLE `sc_product_resource`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '资源地址',
  `type_` int NOT NULL COMMENT '资源类型',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_product_lid_type_`(`mid` ASC, `product_lid` ASC, `type_` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 591 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品视频/图片' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_sale_cost
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_sale_cost`;
CREATE TABLE `sc_product_sale_cost`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `profit_lid` bigint NOT NULL COMMENT '毛利表lid,保留字段',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `goods_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品单位',
  `goods_unit_lid` bigint NOT NULL COMMENT '物品单位lid',
  `theory_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '理论用量',
  `actual_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '实际用量',
  `diff_volume` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '用量差异',
  `theory_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '理论成本',
  `actual_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '实际成本',
  `wastage_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '耗损成本',
  `diff_cost` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '成本差异',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `organ_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `product_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `goods_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '计量数量',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账单编号',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_organ_lid`(`mid` ASC, `report_date` ASC, `organ_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_product_lid`(`mid` ASC, `report_date` ASC, `product_lid` ASC) USING BTREE,
  INDEX `idx_mid_profit_lid`(`mid` ASC, `profit_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12615 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品销售成本分析' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_sale_profit
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_sale_profit`;
CREATE TABLE `sc_product_sale_profit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `organ_lid` bigint NOT NULL COMMENT '组织lid',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `product_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品单位',
  `sale_volume` decimal(24, 6) NOT NULL COMMENT '销售数量',
  `sale_price` decimal(24, 6) NOT NULL COMMENT '平均售价',
  `sale_amount` decimal(24, 6) NOT NULL COMMENT '销售金额',
  `theory_cost` decimal(24, 6) NOT NULL COMMENT '理论成本',
  `actual_cost` decimal(24, 6) NOT NULL COMMENT '实际成本',
  `other_cost` decimal(24, 6) NOT NULL COMMENT '其他成本',
  `diff_cost` decimal(24, 6) NOT NULL COMMENT '成本差异',
  `bill_type` int NOT NULL DEFAULT 1 COMMENT '账单类型',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `organ_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组织名称',
  `product_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品名称',
  `shop_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `source_type` int NULL DEFAULT 0 COMMENT '来源类型',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '账单编号',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_organ_lid`(`mid` ASC, `report_date` ASC, `organ_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_product_lid`(`mid` ASC, `report_date` ASC, `product_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2824 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品销售毛利分析' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_type`;
CREATE TABLE `sc_product_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '上级分类',
  `idx` int NOT NULL COMMENT '顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 64281 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品类别' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_product_unit
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_unit`;
CREATE TABLE `sc_product_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商品id',
  `product_lid` bigint NOT NULL COMMENT '商品lid',
  `type_` int NOT NULL COMMENT '单位类型',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单位名称',
  `price` decimal(24, 6) NOT NULL COMMENT '单位价格',
  `make_duration` int NULL DEFAULT NULL COMMENT '制作时长',
  `process_flow` varchar(900) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工艺流程',
  `weight` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '重量',
  `raw_cost` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '原材料成本',
  `gross_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '毛利率',
  `assist_cost` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '辅助成本',
  `total_cost` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '综合总成本',
  `profit` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '纯利润',
  `profit_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '纯利率',
  `cost_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '成本率',
  `raw_weight` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '原料重量',
  `net_weight` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '净料重量',
  `cooked_weight` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '熟菜重量',
  `amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '金额（元）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_product_lid`(`mid` ASC, `product_lid` ASC) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 805763 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品单位' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_quote_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_quote_order`;
CREATE TABLE `sc_quote_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单据编号',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `quote_state` int NOT NULL COMMENT '报价状态',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `release_lid` bigint NULL DEFAULT NULL COMMENT '发布人lid',
  `release_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发布人',
  `release_time` datetime NULL DEFAULT NULL COMMENT '发布时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_report_date_lid`(`mid` ASC, `report_date` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 167 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商报价单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_quote_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_quote_order_item`;
CREATE TABLE `sc_quote_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `price` decimal(24, 6) NOT NULL COMMENT '报价',
  `added_tax_type` int NOT NULL COMMENT '采购税率',
  `last_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '上期价格',
  `begin_date` datetime NOT NULL COMMENT '价格生效日期',
  `end_date` datetime NOT NULL COMMENT '价格失效日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_report_date_order_lid`(`mid` ASC, `report_date` ASC, `quote_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_goods_lid`(`mid` ASC, `report_date` ASC, `goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5784 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商报价单物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_quote_order_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_quote_order_store`;
CREATE TABLE `sc_quote_order_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '适用门店sid',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_report_date_order_lid`(`mid` ASC, `report_date` ASC, `quote_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_sid`(`mid` ASC, `report_date` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1196 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商报价单适用组织' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_quote_order_supplier
-- ----------------------------
DROP TABLE IF EXISTS `sc_quote_order_supplier`;
CREATE TABLE `sc_quote_order_supplier`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '报价日期',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_report_date_order_lid`(`mid` ASC, `report_date` ASC, `quote_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_supplier_lid`(`mid` ASC, `report_date` ASC, `supplier_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 344 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商报价单适用供货商' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_rdc_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_rdc_order`;
CREATE TABLE `sc_rdc_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订货单号',
  `store_order_lid` bigint NULL DEFAULT NULL COMMENT '门店订货单lid',
  `store_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '门店订货单号',
  `purchase_order_lid` bigint NULL DEFAULT NULL COMMENT '采购单lid',
  `purchase_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '采购单号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `rows` int NOT NULL COMMENT '记录数',
  `volume` decimal(24, 6) NOT NULL COMMENT '总数量',
  `amount` decimal(24, 6) NOT NULL COMMENT '总金额',
  `tax_amount` decimal(24, 6) NOT NULL COMMENT '含税金额',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '标准数量',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `reject_lid` bigint NULL DEFAULT NULL COMMENT '驳回人lid',
  `reject_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '驳回人',
  `reject_time` datetime NULL DEFAULT NULL COMMENT '驳回时间',
  `submit_lid` bigint NULL DEFAULT NULL COMMENT '提交人lid',
  `submit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交人',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `inspect_rows` int NOT NULL DEFAULT 0 COMMENT '验货记录数',
  `payed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否付款',
  `delivery_fee` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '配送费',
  `paid_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '已付款金额',
  `checked_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '已核销金额',
  `invoice_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '已开金额',
  `settle_state` int NOT NULL DEFAULT 1 COMMENT '结算状态',
  `check_state` int NOT NULL DEFAULT 1 COMMENT '对账状态',
  `check_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '对账人',
  `check_lid` bigint NULL DEFAULT NULL COMMENT '对账人lid',
  `check_time` datetime NULL DEFAULT NULL COMMENT '对账时间',
  `to_paid_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '要付款金额',
  `task_lid` bigint NULL DEFAULT NULL COMMENT '支付任务lid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_organ_lid`(`mid` ASC, `report_date` ASC, `organ_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2864 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送中心订货单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_rdc_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_rdc_order_item`;
CREATE TABLE `sc_rdc_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `rdc_order_lid` bigint NOT NULL COMMENT '配送中心订货单lid',
  `rdc_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配送中心订货单号',
  `purchase_order_lid` bigint NULL DEFAULT NULL COMMENT '采购单lid',
  `purchase_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '采购单号',
  `org_item_lid` bigint NULL DEFAULT NULL COMMENT '原始物品lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `price` decimal(24, 6) NOT NULL COMMENT '订购价格',
  `amount` decimal(24, 6) NOT NULL COMMENT '订购总额',
  `org_volume` decimal(24, 6) NOT NULL COMMENT '原订购数量',
  `org_price` decimal(24, 6) NOT NULL COMMENT '原订购价格',
  `org_amount` decimal(24, 6) NOT NULL COMMENT '原订购总额',
  `total_amount` decimal(24, 6) NOT NULL COMMENT '合计数量',
  `total_volume` decimal(24, 6) NOT NULL COMMENT '合计金额',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `arrival_time` datetime NOT NULL COMMENT '到货日期',
  `delivery_type` int NOT NULL COMMENT '配送方式',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `submitted` tinyint(1) NULL DEFAULT NULL COMMENT '已提交',
  `submitted_lid` bigint NULL DEFAULT NULL COMMENT '提交人lid',
  `submitted_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交人',
  `submitted_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `split_lid` bigint NULL DEFAULT NULL COMMENT '拆单人lid',
  `split_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拆单人',
  `split_time` datetime NULL DEFAULT NULL COMMENT '拆单时间',
  `parented` tinyint(1) NOT NULL COMMENT '主单',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `inspect_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '验货数量',
  `inspect_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '验货单价',
  `inspect_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '验货金额',
  `inspected_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '已验货数量',
  `inspect_lid` bigint NULL DEFAULT NULL COMMENT '验货人lid',
  `inspect_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '验货人',
  `inspect_time` datetime NULL DEFAULT NULL COMMENT '验货时间',
  `out_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '发货数量',
  `inbound_lid` bigint NULL DEFAULT NULL COMMENT '入库单lid',
  `inbound_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '入库单编号',
  `production_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `batch_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `inspect_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '验货备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `out_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货备注',
  `weighted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '已称重',
  `scarce` tinyint(1) NOT NULL DEFAULT 0 COMMENT '物品缺货',
  `out_state` int NOT NULL DEFAULT 1 COMMENT '发货状态',
  `out_at` datetime NULL DEFAULT NULL COMMENT '发货时间',
  `out_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货人',
  `outbound_lid` bigint NULL DEFAULT NULL COMMENT '出库单lid',
  `outbound_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '出库单编号',
  `payed` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否付款',
  `delivery_fee` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '配送费',
  `counting_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '计量数量',
  `reject` tinyint(1) NULL DEFAULT 0 COMMENT '拒收',
  `reject_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒收人',
  `reject_at` datetime NULL DEFAULT NULL COMMENT '拒收时间',
  `reject_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒收原因',
  `cancel` tinyint(1) NULL DEFAULT 0 COMMENT '取消',
  `cancel_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消人',
  `cancel_at` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `cancel_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `refund_state` int NULL DEFAULT 0 COMMENT '退货状态',
  `refund_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '退货数量',
  `refund_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货人',
  `refund_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货时间',
  `refund_for` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货原因',
  `refund_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退货单号',
  `share_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分享汇总单号',
  `share_lid` bigint NULL DEFAULT NULL COMMENT '分享汇总单号lid',
  `share_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分享人',
  `share_at` datetime NULL DEFAULT NULL COMMENT '分享时间',
  `inspect_indent_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '订购验货数量',
  `printed` tinyint(1) NULL DEFAULT 0 COMMENT '打印状态',
  `print_state` int NULL DEFAULT 0 COMMENT '打印状态（位标志组合）',
  `sort_status` int NULL DEFAULT 0 COMMENT '分拣状态：0-未分拣，1-已分拣',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_rdc_order_lid`(`mid` ASC, `report_date` ASC, `rdc_order_id` ASC) USING BTREE,
  INDEX `idx_mid_report_date_lid`(`mid` ASC, `report_date` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 75670 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '配送中心订货单物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_sale_cost_relate
-- ----------------------------
DROP TABLE IF EXISTS `sc_sale_cost_relate`;
CREATE TABLE `sc_sale_cost_relate`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `relate_lid` bigint NOT NULL COMMENT '销售成本分析lid',
  `bill_lid` bigint NOT NULL COMMENT '账单lid',
  `item_lid` bigint NOT NULL COMMENT '账单物品lid',
  `volume` bigint NOT NULL COMMENT '用量',
  `price` decimal(24, 6) NOT NULL COMMENT '均价',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额',
  `type` int NOT NULL COMMENT '类型 扣库/盘点',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_relate_lid`(`mid` ASC, `relate_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品成本关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_account_period
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_account_period`;
CREATE TABLE `sc_st_account_period`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会计周期名称',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `post_date` datetime NULL DEFAULT NULL COMMENT '转结日期',
  `posted` tinyint(1) NULL DEFAULT NULL COMMENT '是否转结',
  `last_period_lid` bigint NULL DEFAULT NULL COMMENT '上一会计周期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 215 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会计周期' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_bill`;
CREATE TABLE `sc_st_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL DEFAULT -1 COMMENT '门店sid',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单据编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `type_` int NOT NULL COMMENT '票据类型',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `client` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户',
  `client_lid` bigint NULL DEFAULT NULL COMMENT '客户编号',
  `applicant_lid` bigint NULL DEFAULT NULL COMMENT '申请人编号',
  `applicant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '申请人',
  `keeper_lid` bigint NULL DEFAULT NULL COMMENT '库管员编号',
  `keeper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '库管员',
  `purchase_order_lid` bigint NULL DEFAULT NULL COMMENT '采购订单lid',
  `maker_lid` bigint NULL DEFAULT NULL COMMENT '制单人编号',
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '制单人',
  `manual_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手工单号',
  `supplier_lid` bigint NOT NULL DEFAULT -1 COMMENT '供货商lid',
  `manager_lid` bigint NULL DEFAULT NULL COMMENT '经办人编号',
  `manager` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '经办人',
  `arrival_time` datetime NULL DEFAULT NULL COMMENT '到货日期',
  `make_time` datetime NULL DEFAULT NULL COMMENT '开票时间',
  `post_time` datetime NULL DEFAULT NULL COMMENT '过帐日期',
  `poster_lid` bigint NULL DEFAULT NULL COMMENT '过账人编号',
  `poster` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '过账人',
  `posted` int NOT NULL COMMENT '是否过账',
  `post_id` bigint NULL DEFAULT NULL COMMENT '过账顺序;用于单据排序',
  `last_mod_time` datetime NULL DEFAULT NULL COMMENT '上一次修改的时间',
  `total_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '金额合计',
  `total_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '数量合计',
  `ref_flag` int NOT NULL COMMENT '是否冲红',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库编号',
  `take_warehouse_lid` bigint NULL DEFAULT NULL COMMENT '领用仓库编号',
  `in_bill_lid` bigint NULL DEFAULT NULL COMMENT '调入仓库单据编号',
  `in_warehouse_lid` bigint NULL DEFAULT NULL COMMENT '调入仓库编号',
  `out_bill_lid` bigint NULL DEFAULT NULL COMMENT '调出仓库单据编号',
  `out_warehouse_lid` bigint NULL DEFAULT NULL COMMENT '调出仓库编号',
  `org_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '原始单号',
  `shipper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发货方',
  `consignee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货方',
  `in_out_flag` int NULL DEFAULT NULL COMMENT '进出仓库的标志位',
  `check_bill_lid` bigint NULL DEFAULT NULL COMMENT '盘点单lid',
  `org_bill_lid` bigint NULL DEFAULT NULL COMMENT '原订单编号',
  `account_period_lid` bigint NULL DEFAULT NULL COMMENT '所属会计期间编号',
  `order_src` int NOT NULL COMMENT '单据来源',
  `purchaser_lid` bigint NULL DEFAULT NULL COMMENT '采购商商户id',
  `relate_bill_lid` bigint NULL DEFAULT NULL COMMENT '关联单据编号,入库和关联供货商单使用',
  `relate_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联单号',
  `shipment_bill_lid` bigint NULL DEFAULT NULL COMMENT '发货单号',
  `receipt_bill_lid` bigint NULL DEFAULT NULL COMMENT '收货单号',
  `tax_amount` decimal(24, 6) NOT NULL COMMENT '税额',
  `qi_state` int NOT NULL COMMENT '质检状态',
  `print_state` int NOT NULL COMMENT '打印状态',
  `promotion_amount` decimal(24, 6) NOT NULL COMMENT '优惠金额',
  `paid_amount` decimal(24, 6) NOT NULL COMMENT '已付款金额',
  `checked_amount` decimal(24, 6) NOT NULL COMMENT '已核销金额',
  `invoice_amount` decimal(24, 6) NOT NULL COMMENT '已开金额',
  `settle_state` int NOT NULL COMMENT '结算状态',
  `check_state` int NOT NULL COMMENT '对账状态',
  `check_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '对账人',
  `check_lid` bigint NULL DEFAULT NULL COMMENT '对账人lid',
  `check_time` datetime NULL DEFAULT NULL COMMENT '对账时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  `delivery_type` int NULL DEFAULT 1 COMMENT '配送方式',
  `process_factory_lid` bigint NULL DEFAULT NULL COMMENT '加工厂lid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 67415 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '仓库单据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_bill_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_bill_item`;
CREATE TABLE `sc_st_bill_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL DEFAULT -1 COMMENT '门店sid',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `bill_type_` int NOT NULL COMMENT '票据类型',
  `st_bill_lid` bigint NOT NULL COMMENT '仓库单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库单据编号',
  `make_time` datetime NOT NULL COMMENT '开票时间',
  `post_time` datetime NULL DEFAULT NULL COMMENT '过帐日期',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NOT NULL DEFAULT -1 COMMENT '供货商lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `take_warehouse_lid` bigint NULL DEFAULT NULL COMMENT '领用仓库编号',
  `goods_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品编号',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `unit_type` int NOT NULL COMMENT '单位类型',
  `actual_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '到货数量（用于采购订货）',
  `volume` decimal(24, 6) NOT NULL COMMENT '数量',
  `price` decimal(24, 6) NOT NULL COMMENT '单价',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额',
  `base_unit_lid` bigint NOT NULL COMMENT '基本单位lid',
  `base_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基本单位',
  `volume_of_base_unit` decimal(24, 6) NOT NULL COMMENT '基本数量',
  `price_of_base_unit` decimal(24, 6) NOT NULL COMMENT '基本单价',
  `old_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '原库存价',
  `new_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '新库存价',
  `beginning_volume_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库期初数量',
  `beginning_amount_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库期初金额',
  `beginning_volume_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库期初数量',
  `beginning_amount_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库期初金额',
  `in_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库收入数量',
  `in_amount_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库收入金额',
  `out_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库发出数量',
  `out_amount_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库发出金额',
  `ending_volume_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库结存数量',
  `ending_amount_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库结存金额',
  `ending_volume_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库结存数量',
  `ending_amount_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库结存金额',
  `account_period_lid` bigint NOT NULL COMMENT '所属会计期间编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `production_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `batch_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `posted` int NOT NULL COMMENT '是否过账',
  `ref_flag` int NOT NULL COMMENT '是否冲红',
  `qi_state` int NOT NULL COMMENT '质检状态',
  `qi_volume` tinyint(1) NOT NULL COMMENT '质检-数量',
  `qi_time` tinyint(1) NOT NULL COMMENT '质检-时间',
  `qi_mass` tinyint(1) NOT NULL COMMENT '质检-质量',
  `qi_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '质检备注',
  `org_item_lid` bigint NULL DEFAULT NULL COMMENT '原物品lid',
  `delivery_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送单价',
  `delivery_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送金额',
  `delivery_tax` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送税率',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  `org_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '原物品数量',
  `org_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '原物品价格',
  `org_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '原物品金额',
  `weighted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '已称重',
  `out_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '发货数量',
  `delivery_type` int NULL DEFAULT 1 COMMENT '配送方式',
  `rdc_order_lid` bigint NULL DEFAULT NULL COMMENT '配送单lid',
  `last_order_price` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '最后一次入库价格',
  `rdc_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配送单编号',
  `poster` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位的数量',
  `beginning_counting_volume_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库期初数量',
  `beginning_counting_volume_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库期初数量',
  `in_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库收入数量',
  `out_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库发出数量',
  `ending_counting_volume_of_in_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '入库仓库结存数量',
  `ending_counting_volume_of_out_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '出库仓库结存数量',
  `counting_unit_lid` bigint NULL DEFAULT NULL COMMENT '计数单位lid',
  `counting_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计数单位',
  `last_out_price` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '最后一次出库单价',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '小类lid',
  `supper_type_lid` bigint NULL DEFAULT NULL COMMENT '大类lid',
  `indent_volume` decimal(19, 10) NULL DEFAULT NULL COMMENT '订购数量',
  `tax_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '含税价格',
  `tax_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '含税金额',
  `process_factory_lid` bigint NULL DEFAULT NULL COMMENT '加工厂lid',
  `idx` int NULL DEFAULT NULL COMMENT '物品顺序',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_bill_lid`(`mid` ASC, `st_bill_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE,
  INDEX `idx_mid_period_lid`(`mid` ASC, `account_period_lid` ASC) USING BTREE,
  INDEX `idx_mid_post_time`(`mid` ASC, `post_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 484132 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单据物品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_check_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_check_bill`;
CREATE TABLE `sc_st_check_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单据编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_date` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库/部门编号',
  `check_for_beginning` tinyint(1) NULL DEFAULT NULL COMMENT '是否为期初盘点',
  `check_for_month_end` tinyint(1) NULL DEFAULT NULL COMMENT '是否为月末盘点',
  `finished` tinyint(1) NULL DEFAULT NULL COMMENT '是否已过账',
  `finisher_lid` bigint NULL DEFAULT NULL COMMENT '过账人lid',
  `finisher` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '过账人',
  `amount_of_balance` decimal(24, 6) NULL DEFAULT NULL COMMENT '结存金额',
  `amount_of_rofitand_loss` decimal(24, 6) NULL DEFAULT NULL COMMENT '盈亏金额',
  `check_in_type` int NULL DEFAULT NULL COMMENT '盘点类型',
  `account_period_lid` bigint NULL DEFAULT NULL COMMENT '所属会计期间lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  `pyd_lid` bigint NULL DEFAULT NULL COMMENT '盘盈单lid',
  `pkd_lid` bigint NULL DEFAULT NULL COMMENT '盘亏单lid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_lid_report_date`(`mid` ASC, `report_date` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_id_report_date`(`mid` ASC, `report_date` ASC, `id` ASC) USING BTREE,
  INDEX `idx_mid_account_lid_report_date`(`mid` ASC, `report_date` ASC, `account_period_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2057 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点单据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_check_bill_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_check_bill_item`;
CREATE TABLE `sc_st_check_bill_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `goods_lid` bigint NOT NULL COMMENT '被盘物品lid',
  `goods_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '被盘物品编号',
  `check_bill_lid` bigint NOT NULL COMMENT '盘点单编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '价格',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '金额',
  `real_unit_lid` bigint NOT NULL COMMENT '实盘单位lid',
  `real_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '实盘单位',
  `real_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '实盘数量',
  `real_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '实盘金额',
  `org_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '库存单价',
  `org_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '库存数量',
  `org_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '库存金额',
  `volmun_of_rofitand_loss` decimal(24, 6) NULL DEFAULT NULL COMMENT '盈亏数量',
  `amount_of_rofitand_loss` decimal(24, 6) NULL DEFAULT NULL COMMENT '盈亏金额',
  `prohibit` tinyint(1) NULL DEFAULT NULL COMMENT '是否禁盘',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  `goods_type_lid` bigint NOT NULL DEFAULT -1 COMMENT '物品类别',
  `real_volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位的实盘数量',
  `org_volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位的库存数量',
  `volmun_of_rofitand_loss_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位的盈亏数量',
  `counting_unit_lid` bigint NULL DEFAULT NULL COMMENT '计数单位lid',
  `counting_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '计数单位',
  `unit_type` int NOT NULL DEFAULT 1 COMMENT '单位类型',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_lid_report_date`(`mid` ASC, `report_date` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_check_bill_lid_report_date`(`mid` ASC, `report_date` ASC, `check_bill_lid` ASC) USING BTREE,
  INDEX `sc_st_check_bill_item_lid_IDX`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 426511 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '盘点单据物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_goods_day_book
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_goods_day_book`;
CREATE TABLE `sc_st_goods_day_book`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `bill_type_` int NOT NULL COMMENT '票据类型',
  `st_bill_lid` bigint NOT NULL COMMENT '仓库单据lid',
  `st_bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '仓库单据编号',
  `make_time` datetime NOT NULL COMMENT '开票时间',
  `post_time` datetime NULL DEFAULT NULL COMMENT '过帐日期',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NULL DEFAULT NULL COMMENT '供货商lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `take_warehouse_lid` bigint NULL DEFAULT NULL COMMENT '领用仓库编号',
  `goods_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品编号',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `unit_type` int NOT NULL COMMENT '单位类型',
  `actual_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '到货数量（用于采购订货）',
  `volume` decimal(24, 6) NOT NULL COMMENT '数量',
  `price` decimal(24, 6) NOT NULL COMMENT '单价',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额',
  `base_unit_lid` bigint NOT NULL COMMENT '基本单位lid',
  `base_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基本单位',
  `volume_of_base_unit` decimal(24, 6) NOT NULL COMMENT '基本数量',
  `price_of_base_unit` decimal(24, 6) NOT NULL COMMENT '基本单价',
  `old_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '原库存价',
  `new_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '新库存价',
  `beginning_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库期初数量',
  `beginning_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库期初金额',
  `in_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库收入数量',
  `in_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库收入金额',
  `out_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库发出数量',
  `out_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库发出金额',
  `ending_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库结存数量',
  `ending_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库结存金额',
  `account_period_lid` bigint NOT NULL COMMENT '所属会计期间编号',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `production_date` datetime NULL DEFAULT NULL COMMENT '生产日期',
  `batch_no` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `posted` int NOT NULL COMMENT '是否过账',
  `ref_flag` int NOT NULL COMMENT '是否冲红',
  `qi_state` int NOT NULL COMMENT '质检状态',
  `qi_volume` tinyint(1) NOT NULL COMMENT '质检-数量',
  `qi_time` tinyint(1) NOT NULL COMMENT '质检-时间',
  `qi_mass` tinyint(1) NOT NULL COMMENT '质检-质量',
  `qi_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '质检备注',
  `org_item_lid` bigint NULL DEFAULT NULL COMMENT '原物品lid',
  `delivery_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送单价',
  `delivery_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送金额',
  `delivery_tax` decimal(24, 6) NULL DEFAULT NULL COMMENT '配送税率',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  `delivery_type` int NULL DEFAULT 1 COMMENT '配送方式',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '物品小类lid',
  `supper_type_lid` bigint NULL DEFAULT NULL COMMENT '物品大类lid',
  `org_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '原订购数量',
  `org_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '原订购价格',
  `org_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '原订购总额',
  `bill_date` datetime NULL DEFAULT NULL COMMENT '开票日期',
  `volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位基本数量',
  `beginning_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库期初数量',
  `in_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库收入数量',
  `out_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库发出数量',
  `ending_counting_volume_of_warehouse` decimal(24, 6) NULL DEFAULT NULL COMMENT '仓库结存数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_report_date_goods_lid`(`mid` ASC, `report_date` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_warehouse_lid`(`mid` ASC, `report_date` ASC, `warehouse_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 567209 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品流水账' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_goods_summary
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_goods_summary`;
CREATE TABLE `sc_st_goods_summary`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `period_lid` bigint NOT NULL COMMENT '会计周期lid',
  `goods_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '物品编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '物品小类lid',
  `supper_type_lid` bigint NULL DEFAULT NULL COMMENT '物品大类lid',
  `unit_lid` bigint NULL DEFAULT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '基于计数单位的数量',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '单价',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '金额',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `beginning_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库期初数量',
  `beginning_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库期初金额',
  `in_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库收入数量',
  `in_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库收入金额',
  `out_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库发出数量',
  `out_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库发出金额',
  `ending_volume_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库结存数量',
  `ending_amount_of_warehouse` decimal(24, 6) NOT NULL COMMENT '仓库结存金额',
  `check_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点数量',
  `check_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点金额',
  `check_in_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点盈收数量',
  `check_in_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点盈收金额',
  `check_out_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点亏损数量',
  `check_out_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点亏损金额',
  `init_check_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库期初数量',
  `init_check_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库期初金额',
  `revision` int NULL DEFAULT 0 COMMENT '乐观锁',
  `beginning_counting_volume_of_warehouse` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库期初数量',
  `in_counting_volume_of_warehouse` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库收入数量',
  `out_counting_volume_of_warehouse` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库发出数量',
  `ending_counting_volume_of_warehouse` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库结存数量',
  `check_counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点数量',
  `check_in_counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点盈收数量',
  `check_out_counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库盘点亏损数量',
  `init_check_counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '仓库期初数量',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_period_lid_goods`(`mid` ASC, `period_lid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_period_lid_warehoue`(`mid` ASC, `period_lid` ASC, `warehouse_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 884433 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品汇总账' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_type_summary
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_type_summary`;
CREATE TABLE `sc_st_type_summary`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '营业日期',
  `year` int NOT NULL COMMENT '年',
  `month` int NOT NULL COMMENT '月',
  `day` int NOT NULL COMMENT '日',
  `type_` int NOT NULL COMMENT '单据类型',
  `period_lid` bigint NOT NULL COMMENT '会计周期lid',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '物品小类lid',
  `supper_type_lid` bigint NULL DEFAULT NULL COMMENT '物品大类lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `in_out_flag` int NOT NULL DEFAULT 0 COMMENT '出入库标识',
  `volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '数量',
  `counting_volume` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '计量数量',
  `amount` decimal(24, 6) NOT NULL COMMENT '金额',
  `revision` int NOT NULL DEFAULT 0 COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NOT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_period_lid_warehouse`(`mid` ASC, `period_lid` ASC, `warehouse_lid` ASC) USING BTREE,
  INDEX `idx_mid_period_lid_goods`(`mid` ASC, `period_lid` ASC, `goods_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 380907 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品单据类型汇总' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_stock_snapshot_of_month
-- ----------------------------
DROP TABLE IF EXISTS `sc_stock_snapshot_of_month`;
CREATE TABLE `sc_stock_snapshot_of_month`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `period_lid` bigint NOT NULL COMMENT '会计区间lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `price` decimal(24, 6) NOT NULL COMMENT '库存价格',
  `volume` decimal(24, 6) NOT NULL COMMENT '当前数量',
  `amount` decimal(24, 6) NOT NULL COMMENT '当前金额',
  `unit_lid` bigint NOT NULL COMMENT '单位lid',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `bill_lid` bigint NOT NULL COMMENT '单据lid',
  `item_lid` bigint NOT NULL COMMENT '物品的lid',
  `last_stock_time` datetime NOT NULL COMMENT '入库时间',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `volume_for_counting` decimal(24, 6) NULL DEFAULT NULL COMMENT '当前数量',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_period_lid_goods_lid`(`mid` ASC, `period_lid` ASC, `goods_lid` ASC) USING BTREE,
  INDEX `idx_mid_period_lid_warehouse_lid`(`mid` ASC, `period_lid` ASC, `warehouse_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 487343 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '月末转结快照' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_store_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_order`;
CREATE TABLE `sc_store_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号',
  `rdc_order_lid` bigint NULL DEFAULT NULL COMMENT '配送中心订货单lid',
  `rdc_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配送中心订货单编号',
  `merge_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '合并后订单id',
  `merge_order_lid` bigint NULL DEFAULT NULL COMMENT '合并后的订单lid',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `rows` int NOT NULL COMMENT '记录数',
  `volume` decimal(24, 6) NOT NULL COMMENT '总数量',
  `tax_amount` decimal(24, 6) NOT NULL COMMENT '含税金额',
  `amount` decimal(24, 6) NOT NULL COMMENT '总金额',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `audit_lid` bigint NULL DEFAULT NULL COMMENT '审核人lid',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `reject_lid` bigint NULL DEFAULT NULL COMMENT '驳回人lid',
  `reject_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '驳回人',
  `reject_time` datetime NULL DEFAULT NULL COMMENT '驳回时间',
  `submit_lid` bigint NULL DEFAULT NULL COMMENT '提交人lid',
  `submit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交人',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `rdc_audit_lid` bigint NULL DEFAULT NULL COMMENT '配送中心审核人lid',
  `rdc_audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '配送中心审核人',
  `rdc_audit_time` datetime NULL DEFAULT NULL COMMENT '配送中心审核时间',
  `receive_lid` bigint NULL DEFAULT NULL COMMENT '接单人lid',
  `receive_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '接单人',
  `receive_time` datetime NULL DEFAULT NULL COMMENT '接单时间',
  `split_lid` bigint NULL DEFAULT NULL COMMENT '拆单人lid',
  `split_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拆单人',
  `split_time` datetime NULL DEFAULT NULL COMMENT '拆单时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_organ_lid`(`mid` ASC, `report_date` ASC, `organ_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3536 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店订货单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_store_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_order_item`;
CREATE TABLE `sc_store_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '订货日期',
  `store_order_lid` bigint NOT NULL COMMENT '门店订货单lid',
  `store_order_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '门店订货单编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `organ_lid` bigint NOT NULL COMMENT '机构lid',
  `indent_volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `volume` decimal(24, 6) NOT NULL COMMENT '订购数量',
  `price` decimal(24, 6) NOT NULL COMMENT '订购价格',
  `amount` decimal(24, 6) NOT NULL COMMENT '订购总额',
  `org_volume` decimal(24, 6) NOT NULL COMMENT '原订购数量',
  `org_price` decimal(24, 6) NOT NULL COMMENT '原订购价格',
  `org_amount` decimal(24, 6) NOT NULL COMMENT '原订购总额',
  `tax_rate` decimal(24, 6) NOT NULL COMMENT '税率',
  `arrival_time` datetime NOT NULL COMMENT '到货日期',
  `delivery_type` int NOT NULL COMMENT '配送方式',
  `order_type` int NOT NULL COMMENT '订货单类型',
  `order_state` int NOT NULL COMMENT '订单状态',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_store_order_lid`(`mid` ASC, `report_date` ASC, `store_order_lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date_lid`(`mid` ASC, `report_date` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 87695 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店订货单物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier`;
CREATE TABLE `sc_supplier`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `supplier_type_lid` bigint NULL DEFAULT NULL COMMENT '供应商类别lid',
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人电话',
  `longitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '纬度',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在省',
  `province_code` bigint NULL DEFAULT NULL COMMENT '省编码',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在市',
  `city_code` bigint NULL DEFAULT NULL COMMENT '市编码',
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在区县',
  `county_code` bigint NULL DEFAULT NULL COMMENT '所在区县编码',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '详细地址',
  `enable` tinyint(1) NULL DEFAULT NULL COMMENT '启用/禁用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `is_suit_all` tinyint(1) NOT NULL DEFAULT 1 COMMENT '适用所有店铺',
  `pinyin` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拼音',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商编号',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_supplier_type_lid`(`mid` ASC, `supplier_type_lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1339 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier_apply
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_apply`;
CREATE TABLE `sc_supplier_apply`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `apply_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请账号',
  `apply_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请人',
  `apply_at` datetime NOT NULL COMMENT '申请时间',
  `apply_phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '申请电话',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `audit_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `apply_state` int NOT NULL DEFAULT 0 COMMENT '状态',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `supplier_lid` bigint NOT NULL DEFAULT -1 COMMENT '供货商lid',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 95 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商申请关联记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier_quote
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_quote`;
CREATE TABLE `sc_supplier_quote`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '适用门店',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `quote_order_lid` bigint NOT NULL COMMENT '报价单lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `price` decimal(24, 6) NOT NULL COMMENT '报价',
  `added_tax_type` int NOT NULL COMMENT '采购税率',
  `supplier_lid` bigint NOT NULL COMMENT '供货商lid',
  `begin_date` datetime NOT NULL COMMENT '价格生效日期',
  `end_date` datetime NOT NULL COMMENT '价格失效日期',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_mid_sid`(`mid` ASC, `sid` ASC) USING BTREE,
  INDEX `idx_mid_supplier_lid`(`mid` ASC, `supplier_lid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 111 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商报价' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier_relate
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_relate`;
CREATE TABLE `sc_supplier_relate`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商户企业账号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商户名称',
  `phone` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '商户手机号',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE,
  INDEX `idx_sid`(`sid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 83 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供货商与商户关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_store`;
CREATE TABLE `sc_supplier_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `store_lid` bigint NOT NULL COMMENT '门店lid',
  `supplier_lid` bigint NOT NULL COMMENT '供应商lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_supplier_store`(`mid` ASC, `store_lid` ASC) USING BTREE,
  INDEX `idx_supplier_supplier`(`mid` ASC, `supplier_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 299 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商和门店关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_supplier_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_type`;
CREATE TABLE `sc_supplier_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商名称',
  `parent_lid` bigint NULL DEFAULT NULL COMMENT '上一级分类',
  `level` int NULL DEFAULT NULL COMMENT '层级',
  `enable` tinyint(1) NULL DEFAULT NULL COMMENT '启用/禁用',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商类型编号',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`mid` ASC, `id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 413 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商类型' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_tbl_area
-- ----------------------------
DROP TABLE IF EXISTS `sc_tbl_area`;
CREATE TABLE `sc_tbl_area`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '台区编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '台区名称',
  `idx` int NOT NULL COMMENT '台区顺序',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_lid`(`lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7034 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '台区' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_warehouse`;
CREATE TABLE `sc_warehouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `mid` bigint NOT NULL COMMENT '集团;',
  `sid` bigint NULL DEFAULT NULL COMMENT '所属门店;',
  `lid` bigint NOT NULL COMMENT 'lmn内部编号',
  `init_bill_lid` bigint NULL DEFAULT NULL COMMENT '仓库期初编号',
  `check_bill_lid` bigint NULL DEFAULT NULL COMMENT '仓库盘点单号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库名称',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `enable` tinyint(1) NULL DEFAULT NULL COMMENT '启用/禁用',
  `address` varchar(900) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库地址',
  `reduce_level` int NULL DEFAULT NULL COMMENT '扣减顺序',
  `inited` tinyint(1) NULL DEFAULT NULL COMMENT '是否期初',
  `checking` tinyint(1) NULL DEFAULT NULL COMMENT '正在盘点',
  `for_default` tinyint(1) NULL DEFAULT NULL COMMENT '默认仓库',
  `last_inventory_time` datetime NULL DEFAULT NULL COMMENT '最近盘点日期',
  `last_order_time` datetime NULL DEFAULT NULL COMMENT '最近订货日期',
  `time_of_last_bill` datetime NULL DEFAULT NULL COMMENT '最近库存单据日期',
  `time_of_last_auto_out` datetime NULL DEFAULT NULL COMMENT '最后自动出库日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `init_time` datetime NULL DEFAULT NULL COMMENT '仓库期初时间',
  `owner_shop_id` bigint NULL DEFAULT NULL COMMENT '所属店铺编号',
  `owner_shop` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所属店铺',
  `longitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '纬度',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在省',
  `province_code` bigint NULL DEFAULT NULL COMMENT '省编码',
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在市',
  `city_code` bigint NULL DEFAULT NULL COMMENT '市编码',
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '所在区县',
  `county_code` bigint NULL DEFAULT NULL COMMENT '所在区县编码',
  `receiver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人',
  `receiver_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货人联系方式',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '收货地址',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库编号',
  `alias` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '别名',
  `outbound` tinyint(1) NULL DEFAULT NULL COMMENT '物品审核入库即耗用',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_owner_shop_id`(`mid` ASC, `owner_shop_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1065 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '仓库' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_weight_img
-- ----------------------------
DROP TABLE IF EXISTS `sc_weight_img`;
CREATE TABLE `sc_weight_img`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '日期',
  `order_lid` bigint NOT NULL COMMENT '订单lid',
  `item_lid` bigint NOT NULL COMMENT '订单物品lid',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图片地址',
  `idx` int NOT NULL DEFAULT 0 COMMENT '拍照索引',
  `type_` int NOT NULL DEFAULT 0 COMMENT '类型 0订货单 1入库单',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `order_lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `item_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '称重图片拍照' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_weight_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_weight_record`;
CREATE TABLE `sc_weight_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NOT NULL COMMENT '日期',
  `order_lid` bigint NOT NULL COMMENT '订单lid',
  `item_lid` bigint NOT NULL COMMENT '订单物品lid',
  `measure` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '读数',
  `tare` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '皮重',
  `weight_type` int NOT NULL DEFAULT 0 COMMENT '称重单位类型',
  `idx` int NOT NULL COMMENT '称重索引',
  `type_` int NOT NULL DEFAULT 0 COMMENT '类型 0订货单 1入库单',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_order_lid`(`mid` ASC, `order_lid` ASC) USING BTREE,
  INDEX `idx_mid_item_lid`(`mid` ASC, `item_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '称重记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_bom
-- ----------------------------
DROP TABLE IF EXISTS `wms_bom`;
CREATE TABLE `wms_bom`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NULL DEFAULT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `dish_id` bigint NULL DEFAULT NULL COMMENT '商品编号',
  `dish_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品',
  `hide` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '隐藏（酒水）',
  `audit_time` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `audited` tinyint(1) NULL DEFAULT NULL COMMENT '已审核',
  `audit_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核人',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid`(`mid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_dish_id`(`mid` ASC, `dish_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料清单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_bom_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_bom_item`;
CREATE TABLE `wms_bom_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NULL DEFAULT NULL COMMENT '逻辑编号',
  `bom_id` bigint NULL DEFAULT NULL COMMENT '物料清单编号',
  `unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品单位',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '物品编号',
  `goods` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品名称',
  `goods_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '物品单位',
  `goods_cost` decimal(24, 6) NULL DEFAULT NULL COMMENT '物品用量',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_mid_bom_id`(`mid` ASC, `bom_id` ASC) USING BTREE,
  INDEX `idx_mid_bom_id_unit`(`mid` ASC, `bom_id` ASC, `unit` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物料清单明细' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_cost_order
-- ----------------------------
DROP TABLE IF EXISTS `wms_cost_order`;
CREATE TABLE `wms_cost_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报损单号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '订单日期',
  `order_type` int NULL DEFAULT NULL COMMENT '报损单类型',
  `rows` int NULL DEFAULT NULL COMMENT '物品总数',
  `volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '总数量',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '总金额',
  `review` tinyint(1) NULL DEFAULT NULL COMMENT '审核',
  `review_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核人',
  `review_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报损原因',
  `remark` varchar(900) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '报损备注',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '成本报损单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_cost_order_item
-- ----------------------------
DROP TABLE IF EXISTS `wms_cost_order_item`;
CREATE TABLE `wms_cost_order_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `report_date` datetime NULL DEFAULT NULL COMMENT '订单日期',
  `order_type` int NULL DEFAULT NULL COMMENT '报损单类型',
  `cost_order_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '成本单号',
  `cost_order_lid` bigint NULL DEFAULT NULL COMMENT '成本单lid',
  `small_type_lid` bigint NULL DEFAULT NULL COMMENT '商品小类lid',
  `small_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品小类名称',
  `super_type_lid` bigint NULL DEFAULT NULL COMMENT '商品大类lid',
  `super_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品大类名称',
  `product_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品id',
  `product_lid` bigint NULL DEFAULT NULL COMMENT '商品lid',
  `product_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品名称',
  `product_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品单位',
  `product_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '商品数量',
  `product_price` decimal(24, 6) NULL DEFAULT NULL COMMENT '商品单价',
  `product_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '商品金额',
  `remark` varchar(900) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品备注',
  `review` tinyint(1) NULL DEFAULT NULL COMMENT '审核',
  `review_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `review_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '审核人',
  `raw_rows` bigint NULL DEFAULT NULL COMMENT '报损原材料数',
  `raw_volume` decimal(24, 6) NULL DEFAULT NULL COMMENT '原料材料扣库数量',
  `raw_amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '原料材料扣库金额',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`mid` ASC, `report_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '成本报损单物品' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_deduct_setting
-- ----------------------------
DROP TABLE IF EXISTS `wms_deduct_setting`;
CREATE TABLE `wms_deduct_setting`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `dish_id` bigint NULL DEFAULT NULL COMMENT '商品号',
  `dish` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品',
  `dish_super_type_id` bigint NULL DEFAULT NULL COMMENT '商品大类编号',
  `dish_super_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品大类',
  `dish_type_id` bigint NULL DEFAULT NULL COMMENT '商品小类编号',
  `dish_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '商品小类',
  `tbl_area_id` bigint NULL DEFAULT NULL COMMENT '台区编号',
  `tbl_area` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '台区',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库编号',
  `warehouse` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '仓库',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '商品扣仓设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_depart_goods
-- ----------------------------
DROP TABLE IF EXISTS `wms_depart_goods`;
CREATE TABLE `wms_depart_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `warehouse_lid` bigint NOT NULL COMMENT '仓库lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_warehouse_lid`(`mid` ASC, `warehouse_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4536 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门/仓库物品' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for wms_goods_last_price
-- ----------------------------
DROP TABLE IF EXISTS `wms_goods_last_price`;
CREATE TABLE `wms_goods_last_price`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NOT NULL COMMENT '租户号',
  `sid` bigint NOT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '价格',
  `type_` int NOT NULL DEFAULT 1 COMMENT '价格类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `warehouse_lid` bigint NOT NULL DEFAULT -1 COMMENT '仓库lid',
  `item_lid` bigint NULL DEFAULT NULL COMMENT '单据物品lid',
  `bill_lid` bigint NULL DEFAULT NULL COMMENT '单据lid',
  `bill_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单据id',
  `report_date` datetime NULL DEFAULT NULL COMMENT '最后一次价格订单日期',
  PRIMARY KEY (`pid`, `mid`, `sid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_sid_goods_lid_type_`(`mid` ASC, `sid` ASC, `goods_lid` ASC, `type_` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25871 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '物品上次入库价格' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_label_unit
-- ----------------------------
DROP TABLE IF EXISTS `wms_label_unit`;
CREATE TABLE `wms_label_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `remark` varchar(900) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `type_` int NULL DEFAULT NULL COMMENT '类型',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `idx_mid_lid`(`mid` ASC, `lid` ASC) USING BTREE,
  INDEX `idx_mid_type`(`mid` ASC, `type_` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 435 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '单位/标签' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wms_user_goods
-- ----------------------------
DROP TABLE IF EXISTS `wms_user_goods`;
CREATE TABLE `wms_user_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `user_lid` bigint NOT NULL COMMENT '用户lid',
  `goods_lid` bigint NOT NULL COMMENT '物品lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_user_lid`(`mid` ASC, `user_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9631 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户常用物品' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for wx_card_jump
-- ----------------------------
DROP TABLE IF EXISTS `wx_card_jump`;
CREATE TABLE `wx_card_jump`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `card_lid` bigint NOT NULL COMMENT '微信卡券lid',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '名称',
  `tips` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提示',
  `type_` int NOT NULL COMMENT '跳转类型',
  `page` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '页面',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路径',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_card_lid`(`card_lid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员卡券跳转' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
