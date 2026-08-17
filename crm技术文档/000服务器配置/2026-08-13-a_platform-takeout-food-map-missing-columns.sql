USE `a_platform`;

ALTER TABLE `takeout_food_map`
    ADD COLUMN `platform_spu_id` VARCHAR(64) NULL COMMENT '外卖平台SPU ID' AFTER `food_id_in_channel`,
    ADD COLUMN `has_picture` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否有图片' AFTER `platform_spu_id`;
