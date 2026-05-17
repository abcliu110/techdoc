-- project: nms4pos
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `dwd_bill`
  ADD COLUMN `deposit_plan_lid` BIGINT NULL COMMENT '储值方案ID（新储值方案充值时使用）' AFTER `card_task_lid`,
  ADD COLUMN `deposit_tier_index` INT NULL COMMENT '储值方案档位索引（0起）' AFTER `deposit_plan_lid`,
  ADD COLUMN `consume_give_points` DECIMAL(18,2) NULL COMMENT '本次消费应赠积分';

SET FOREIGN_KEY_CHECKS = 1;
