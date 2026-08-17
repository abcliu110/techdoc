-- CRM 权益适用门店字段升级：消费赠券规则。
-- 执行连接：nms4cloud-crm.yaml 中 crm 数据源，目标库 a_crm。

USE a_crm;

ALTER TABLE `crm_consumption_coupon_rule`
  ADD COLUMN `is_all_store` tinyint(1) NULL COMMENT '是否适用所有门店：1-所有门店，0-指定门店，NULL-兼容旧单门店规则' AFTER `sid`,
  ADD COLUMN `store_sids` json NULL COMMENT '适用门店ID列表，JSON数组；is_all_store=0时生效' AFTER `is_all_store`;

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'crm_consumption_coupon_rule'
  AND COLUMN_NAME IN ('is_all_store', 'store_sids')
ORDER BY FIELD(COLUMN_NAME, 'is_all_store', 'store_sids');
