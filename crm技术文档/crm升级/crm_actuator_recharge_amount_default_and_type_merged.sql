-- Merged from V20260517__crm_actuator_recharge_amount_default.sql
UPDATE `crm_actuator`
SET `recharge_amount` = 0.00
WHERE `recharge_amount` IS NULL;

ALTER TABLE `crm_actuator`
  ALTER COLUMN `recharge_amount` SET DEFAULT 0.00;

-- Merged from V20260523__crm_actuator_type.sql
ALTER TABLE `crm_actuator`
  ADD COLUMN `actuator_type` tinyint NOT NULL DEFAULT 0 COMMENT '执行器类型：0历史未知，1批量赠券，2批量充值' AFTER `name`;

CREATE INDEX `idx_mid_type_deleted` ON `crm_actuator` (`mid`, `actuator_type`, `deleted`);

UPDATE `crm_actuator` a
LEFT JOIN (
  SELECT `actuator_lid`, COUNT(*) AS `coupon_count`
  FROM `crm_actuator_coupon`
  WHERE COALESCE(`deleted`, 0) = 0
  GROUP BY `actuator_lid`
) c ON c.`actuator_lid` = a.`lid`
SET a.`actuator_type` =
  CASE
    WHEN IFNULL(c.`coupon_count`, 0) > 0 THEN 1
    WHEN IFNULL(a.`recharge_amount`, 0) > 0
      OR IFNULL(a.`give_amount`, 0) > 0
      OR IFNULL(a.`points`, 0) > 0 THEN 2
    ELSE 0
  END
WHERE COALESCE(a.`deleted`, 0) = 0;
