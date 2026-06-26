-- 小程序商品券（实物券/平台券）点餐核销相关字段迁移。
-- 覆盖 order_food 券菜品核销凭证字段，以及 order_bill 券核算快照字段。
-- 字段为空表示：非商品券菜品、未核销或历史老数据，不影响原有下单流程。
--
-- order_food / order_bill 物理表位于 a_order 数据库。
-- 依据：D:\mywork\techdoc\crm技术文档\字段的映射关系.md 中 nms4cloud-order.yaml 映射，
-- 数据源别名 order -> 目标数据库 a_order。
-- 脚本对每个字段做存在性检查，可重复执行（幂等）。

SET @order_food_schema = 'a_order';
SET @order_bill_schema = 'a_order';

-- ===================== order_food 字段 =====================

-- coupon_no：优惠券编号（会员商品券领券记录ID，平台券为空）
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'coupon_no');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `coupon_no` BIGINT NULL COMMENT ''优惠券编号'''),
  'SELECT ''order_food.coupon_no already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- coupon_write_off_trace_no：券核销追踪号（唯一定位券菜品行，用于核销/取消）
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'coupon_write_off_trace_no');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `coupon_write_off_trace_no` VARCHAR(64) NULL COMMENT ''券核销追踪号'''),
  'SELECT ''order_food.coupon_write_off_trace_no already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- platform_certificate_id：平台券凭证ID（certificate_id），POS 撤销时作为 DwdCoupon.couponNo
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'platform_certificate_id');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `platform_certificate_id` VARCHAR(128) NULL COMMENT ''平台券凭证ID(certificate_id)，POS作为DwdCoupon.couponNo'''),
  'SELECT ''order_food.platform_certificate_id already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- platform_write_off_id：平台券撤销凭证（MP存verify_results JSON数组，DP存逗号分隔verify_id）
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'platform_write_off_id');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `platform_write_off_id` TEXT NULL COMMENT ''平台券撤销凭证:MP存verify_results JSON,DP存逗号分隔verify_id'''),
  'SELECT ''order_food.platform_write_off_id already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- product_coupon_business_type：商品券业务类型 WP/MP/DP
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'product_coupon_business_type');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `product_coupon_business_type` VARCHAR(16) NULL COMMENT ''商品券业务类型:WP会员券,MP美团/餐道,DP抖音'''),
  'SELECT ''order_food.product_coupon_business_type already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- platform_price：平台券面额，供 POS DwdCoupon.faceAmount
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'platform_price');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `platform_price` DECIMAL(18,4) NULL COMMENT ''平台券面额,供POS DwdCoupon.faceAmount'''),
  'SELECT ''order_food.platform_price already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- platform_paid_amount：平台券实收/结算金额，供 POS DwdCoupon.paidAmount
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'platform_paid_amount');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `platform_paid_amount` DECIMAL(18,4) NULL COMMENT ''平台券实收金额,供POS DwdCoupon.paidAmount'''),
  'SELECT ''order_food.platform_paid_amount already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- write_off_channel：平台券核销渠道，供 POS DwdCoupon.writeOffChannel
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_food_schema AND TABLE_NAME = 'order_food' AND COLUMN_NAME = 'write_off_channel');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_food_schema, '`.`order_food` ADD COLUMN `write_off_channel` VARCHAR(64) NULL COMMENT ''平台券核销渠道,供POS DwdCoupon.writeOffChannel'''),
  'SELECT ''order_food.write_off_channel already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ===================== order_bill 字段 =====================

-- coupon_items：券维度核算明细 JSON
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_bill_schema AND TABLE_NAME = 'order_bill' AND COLUMN_NAME = 'coupon_items');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_bill_schema, '`.`order_bill` ADD COLUMN `coupon_items` TEXT NULL COMMENT ''券维度核算明细JSON'''),
  'SELECT ''order_bill.coupon_items already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- product_items：商品维度核算明细 JSON
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_bill_schema AND TABLE_NAME = 'order_bill' AND COLUMN_NAME = 'product_items');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_bill_schema, '`.`order_bill` ADD COLUMN `product_items` TEXT NULL COMMENT ''商品维度核算明细JSON'''),
  'SELECT ''order_bill.product_items already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- product_coupon_items：商品券与商品关系核算明细 JSON
SET @c = (SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @order_bill_schema AND TABLE_NAME = 'order_bill' AND COLUMN_NAME = 'product_coupon_items');
SET @sql = IF(@c = 0,
  CONCAT('ALTER TABLE `', @order_bill_schema, '`.`order_bill` ADD COLUMN `product_coupon_items` TEXT NULL COMMENT ''商品券与商品关系核算明细JSON'''),
  'SELECT ''order_bill.product_coupon_items already exists''');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
