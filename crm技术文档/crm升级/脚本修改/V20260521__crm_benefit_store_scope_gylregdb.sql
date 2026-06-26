-- CRM 权益适用门店字段升级：消费返现规则。
-- 执行连接：nms4cloud-crm.yaml 中 mycat 数据源，目标库 gylregdb。
-- 说明：代码逻辑表 crm_cash_back / crm_card_level_and_cash_back 均路由到真实表 crm_card_level_and_cash_back。

USE gylregdb;

ALTER TABLE `crm_card_level_and_cash_back`
  ADD COLUMN `is_all_store` tinyint(1) NULL COMMENT '是否适用所有门店：1-所有门店，0-指定门店，NULL-兼容旧单门店规则' AFTER `shop_id`,
  ADD COLUMN `store_sids` json NULL COMMENT '适用门店ID列表，JSON数组；is_all_store=0时生效' AFTER `is_all_store`;

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'crm_card_level_and_cash_back'
  AND COLUMN_NAME IN ('is_all_store', 'store_sids')
ORDER BY FIELD(COLUMN_NAME, 'is_all_store', 'store_sids');
