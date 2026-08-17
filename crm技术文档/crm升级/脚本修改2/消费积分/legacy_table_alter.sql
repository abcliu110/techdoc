-- project: nms4cloud
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `crm_card_points_record`
  ADD COLUMN `related_points_record_lid` BIGINT DEFAULT NULL COMMENT '关联积分流水LID' AFTER `order_bill_id`;

SET FOREIGN_KEY_CHECKS = 1;
