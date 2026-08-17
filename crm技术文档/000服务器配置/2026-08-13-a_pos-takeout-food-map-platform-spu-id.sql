-- Target database: a_pos
-- Evidence: nms4cloud-pos.yaml declares its default datasource as a_pos.
-- The table has no explicit ShardingSphere actual-data-nodes entry in the Nacos export.
-- Purpose: fix full-sync failure caused by missing takeout_food_map.platform_spu_id.
-- Compatible with MySQL 5.7+ and safe to rerun.

USE `a_pos`;

SET @column_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'takeout_food_map'
      AND COLUMN_NAME = 'platform_spu_id'
);

SET @migration_sql := IF(
    @column_exists = 0,
    'ALTER TABLE `takeout_food_map` ADD COLUMN `platform_spu_id` VARCHAR(64) NULL COMMENT ''外卖平台SPU ID'' AFTER `food_id_in_channel`',
    'SELECT ''platform_spu_id already exists'' AS migration_result'
);

PREPARE migration_statement FROM @migration_sql;
EXECUTE migration_statement;
DEALLOCATE PREPARE migration_statement;

SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'a_pos'
  AND TABLE_NAME = 'takeout_food_map'
  AND COLUMN_NAME = 'platform_spu_id';
