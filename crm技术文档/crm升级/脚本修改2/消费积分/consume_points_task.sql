-- project: nms4cloud
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `crm_consume_points_task`;
CREATE TABLE `crm_consume_points_task` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL DEFAULT 0 COMMENT '门店ID；非门店来源统一为0，参与幂等唯一键',
  `lid` BIGINT NOT NULL COMMENT '逻辑编号(雪花算法)',
  `source_` TINYINT NOT NULL COMMENT '积分来源:1-POS,2-云端订单',
  `task_lid` BIGINT NOT NULL DEFAULT 0 COMMENT 'CRM消费任务LID；无任务时统一为0，参与幂等唯一键',
  `bill_lid` BIGINT NOT NULL DEFAULT 0 COMMENT 'POS账单LID；非POS来源统一为0，参与幂等唯一键',
  `order_id` VARCHAR(64) NOT NULL COMMENT '消费订单号',
  `lifecycle_id` BIGINT NOT NULL COMMENT '消费积分生命周期ID',
  `task_type` TINYINT NOT NULL COMMENT '任务类型:1-赠分,2-撤销',
  `card_lid` BIGINT NOT NULL COMMENT '会员卡LID',
  `card_no` VARCHAR(64) NOT NULL COMMENT '会员卡号',
  `points` DECIMAL(18,2) NOT NULL COMMENT '本次消费积分，赠分为正数，撤销为负数',
  `target_points_record_lid` BIGINT COMMENT '撤销关联的原赠分流水LID',
  `produced_points_record_lid` BIGINT COMMENT '本次任务生成的积分流水LID',
  `status_` TINYINT NOT NULL COMMENT '状态:0-处理中,1-成功',
  `operator` VARCHAR(64) COMMENT '操作人',
  `comment` VARCHAR(255) COMMENT '备注',
  `executed_time` DATETIME COMMENT '任务执行时间',
  `created_by` VARCHAR(64) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(64) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='CRM统一消费积分任务';

CREATE INDEX `idx_mid` ON `crm_consume_points_task`(`mid`);
CREATE INDEX `idx_sid` ON `crm_consume_points_task`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_consume_points_task`(`lid`);
CREATE UNIQUE INDEX `uk_biz` ON `crm_consume_points_task`(`mid`, `sid`, `source_`, `lifecycle_id`, `task_type`, `task_lid`, `bill_lid`, `card_lid`, `order_id`, `deleted`);
CREATE INDEX `idx_task_lid` ON `crm_consume_points_task`(`task_lid`);
CREATE INDEX `idx_bill_lid` ON `crm_consume_points_task`(`bill_lid`);
CREATE INDEX `idx_status` ON `crm_consume_points_task`(`status_`);

SET FOREIGN_KEY_CHECKS = 1;
