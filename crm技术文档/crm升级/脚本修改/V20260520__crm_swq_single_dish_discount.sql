ALTER TABLE `gylregdb`.`sc_mall_coupon`
  ADD COLUMN `dish_discount_type` VARCHAR(32) NULL COMMENT '实物券单品优惠方式：FREE免费兑换，DISCOUNT折扣，AMOUNT_OFF立减' AFTER `dish_unit`,
  ADD COLUMN `dish_discount_value` DECIMAL(19,2) NULL COMMENT '实物券单品优惠值：折扣券为几折，立减券为金额' AFTER `dish_discount_type`;

ALTER TABLE `gylregdb`.`sc_mall_coupon_order`
  ADD COLUMN `dish_discount_type` VARCHAR(32) NULL COMMENT '领取时实物券单品优惠方式快照' AFTER `face_value`,
  ADD COLUMN `dish_discount_value` DECIMAL(19,2) NULL COMMENT '领取时实物券单品优惠值快照' AFTER `dish_discount_type`;
