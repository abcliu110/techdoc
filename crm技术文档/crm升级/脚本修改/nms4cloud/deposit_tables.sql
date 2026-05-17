-- project: nms4cloud
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `crm_deposit_category`;
CREATE TABLE `crm_deposit_category` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `lid` BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `brand_ids` JSON COMMENT '品牌（多选）',
  `remark` VARCHAR(500) COMMENT '备注',
  `created_by` VARCHAR(100) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(100) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='管理储值套餐的自定义分组';

CREATE INDEX `idx_mid` ON `crm_deposit_category`(`mid`);
CREATE INDEX `idx_sid` ON `crm_deposit_category`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_deposit_category`(`lid`);

DROP TABLE IF EXISTS `crm_deposit_agreement`;
CREATE TABLE `crm_deposit_agreement` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `lid` BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  `name` VARCHAR(100) NOT NULL COMMENT '协议名称',
  `agreement_type` TINYINT NOT NULL DEFAULT 2 COMMENT '协议类型:1-用户注册,2-会员储值,3-隐私协议,4-点单协议,5-操作指引,6-付费权益卡协议,7-权益包售卖协议,8-存酒服务须知',
  `content` TEXT COMMENT '协议内容(富文本)',
  `guide_text` VARCHAR(500) COMMENT '引导语',
  `version` VARCHAR(50) COMMENT '协议版本号',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
  `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认协议:0-否,1-是',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
  `created_by` VARCHAR(100) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(100) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='储值协议表';

CREATE INDEX `idx_mid` ON `crm_deposit_agreement`(`mid`);
CREATE INDEX `idx_sid` ON `crm_deposit_agreement`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_deposit_agreement`(`lid`);
CREATE INDEX `idx_status` ON `crm_deposit_agreement`(`status`);
CREATE INDEX `idx_agreement_type` ON `crm_deposit_agreement`(`agreement_type`);

DROP TABLE IF EXISTS `crm_deposit_plan`;
CREATE TABLE `crm_deposit_plan` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `lid` BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  `plan_type` TINYINT NOT NULL DEFAULT 1 COMMENT '方案类型:1-储值分期送礼,2-智能储值,3-储值套餐',
  `brand_rule` JSON COMMENT '品牌: {"type":"ALL|SPECIFIED","brandIds":[100001,100002]}',
  `category_lid` BIGINT COMMENT '活动分类',
  `name` VARCHAR(100) NOT NULL COMMENT '活动名称',
  `date_type` TINYINT NOT NULL DEFAULT 1 COMMENT '活动日期类型:1-指定日期,2-永久有效',
  `begin_time` DATETIME COMMENT '开始日期',
  `end_time` DATETIME COMMENT '结束日期',
  `cycle_rule` JSON COMMENT '可用周期: {"type":"DAILY|WEEKLY|MONTHLY","values":[...]}',
  `time_periods` JSON COMMENT '可用时段: {"type":"ALL_DAY|SPECIFIED","periods":[{"startMin":0,"endMin":1440}]}',
  `exclude_dates` JSON COMMENT '排除日期: ["2026-01-01","2026-05-01"]',
  `agreement_enabled` TINYINT NOT NULL DEFAULT 0 COMMENT '开启储值协议:0-关闭,1-开启',
  `agreement_lids` JSON COMMENT '储值协议ID列表: [100001,100002]',
  `description` TEXT COMMENT '活动说明',
  `image_url` VARCHAR(255) COMMENT '图片地址',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-禁用,1-启用',
  `save_type` TINYINT NOT NULL DEFAULT 1 COMMENT '储值规则类型:1-固定金额档位,2-区间金额档位',
  `sort_no` INT DEFAULT 0 COMMENT '排序',
  `channels` JSON COMMENT '渠道规则: {"type":"ALL|SPECIFIED","channels":[{"code":"POS","name":"门店POS","appId":"wx123..."}]}',
  `applicable_orgs` JSON COMMENT '适用组织规则: {"type":"ALL|SPECIFIED_STORES|SPECIFIED_REGIONS","storeIds":[...],"regionIds":[...]}',
  `member_level_rule` JSON COMMENT '适用用户规则: {"type":"UNLIMITED|SPECIFIC_PLANS|SPECIFIC_LEVELS","memberPlanLids":[100001],"memberLevels":[{"memberPlanLid":100001,"memberLevelLids":[200001,200002]}]}',
  `purchase_limit_rule` JSON COMMENT '购买限制规则: {"perUserTotalLimit":{"enabled":true,"limit":10,"limitMessage":"您已达到购买上限"},"perUserPeriodLimit":{"enabled":true,"periodType":"DAILY","limit":5,"limitMessage":"您的购买次数今日已达上限，请明日再来"},"totalSaleLimit":{"enabled":true,"limit":1000,"limitMessage":"储值套餐已售罄"},"totalSalePeriodLimit":{"enabled":true,"periodType":"DAILY","limit":100,"limitMessage":"储值套餐今日已被抢光，请明日再来"}}',
  `tier_rule` JSON COMMENT '档位规则JSON，含充值档位、赠送金额、会员升级及优惠券发放配置',
  `total_sold_count` INT NOT NULL DEFAULT 0 COMMENT '已售总数量',
  `total_sold_amount` DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '已售总金额',
  `is_mini_program_recommend` TINYINT DEFAULT 0 COMMENT '小程序下单页是否推荐:0-不推荐,1-推荐',
  `amount_limit_type` TINYINT DEFAULT 0 COMMENT '可用金额限制类型:0-不限制,1-储值当日限制,2-储值当餐限制',
  `max_amount_value` DECIMAL(18,2) COMMENT '可用储值金额比例(0,100]',
  `created_by` VARCHAR(100) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(100) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='储值方案主表';

CREATE INDEX `idx_mid` ON `crm_deposit_plan`(`mid`);
CREATE INDEX `idx_sid` ON `crm_deposit_plan`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_deposit_plan`(`lid`);
CREATE INDEX `idx_status` ON `crm_deposit_plan`(`status`);
CREATE INDEX `idx_category_lid` ON `crm_deposit_plan`(`category_lid`);
CREATE INDEX `idx_total_sold_count` ON `crm_deposit_plan`(`total_sold_count`);

DROP TABLE IF EXISTS `crm_deposit_charge_record`;
CREATE TABLE `crm_deposit_charge_record` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `lid` BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  `name` VARCHAR(100) NOT NULL COMMENT '记录名称',
  `plan_lid` BIGINT NOT NULL COMMENT '储值方案ID(FK→crm_deposit_plan.lid)',
  `tier_index` INT NOT NULL COMMENT '档位索引(从0开始)',
  `card_lid` BIGINT NOT NULL COMMENT '会员卡ID(FK→crm_card.lid)',
  `task_lid` BIGINT NOT NULL COMMENT '交易任务ID(FK→crm_deal_task.lid)',
  `save_amount` DECIMAL(18,2) NOT NULL COMMENT '储值本金',
  `gift_amount` DECIMAL(18,2) NOT NULL DEFAULT 0 COMMENT '赠送金额',
  `gift_points` DECIMAL(18,2) NOT NULL DEFAULT 0 COMMENT '赠送积分',
  `tier_snapshot` JSON NOT NULL COMMENT '档位快照(TierConfig的完整JSON，防止方案修改后影响已购买权益)',
  `channel_code` VARCHAR(50) COMMENT '渠道编码(POS/MINI_PROGRAM/H5等)',
  `trade_state` TINYINT NOT NULL DEFAULT 6 COMMENT '状态:2-成功,4-已关闭,6-支付中',
  `created_by` VARCHAR(100) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(100) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='储值方案购买记录，用于购买限制检查';

CREATE INDEX `idx_mid` ON `crm_deposit_charge_record`(`mid`);
CREATE INDEX `idx_sid` ON `crm_deposit_charge_record`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_deposit_charge_record`(`lid`);
CREATE INDEX `idx_plan_lid` ON `crm_deposit_charge_record`(`plan_lid`);
CREATE INDEX `idx_card_lid` ON `crm_deposit_charge_record`(`card_lid`);
CREATE INDEX `idx_task_lid` ON `crm_deposit_charge_record`(`task_lid`);

DROP TABLE IF EXISTS `crm_deposit_coupon_schedule`;
CREATE TABLE `crm_deposit_coupon_schedule` (
  `pid` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '物理编号',
  `mid` BIGINT NOT NULL COMMENT '商户ID',
  `sid` BIGINT NOT NULL COMMENT '门店ID',
  `lid` BIGINT NOT NULL UNIQUE COMMENT '逻辑编号(雪花算法)',
  `name` VARCHAR(100) NOT NULL COMMENT '计划名称',
  `plan_lid` BIGINT NOT NULL COMMENT '储值方案ID',
  `tier_index` INT NOT NULL COMMENT '档位索引',
  `card_lid` BIGINT NOT NULL COMMENT '会员卡ID',
  `charge_record_lid` BIGINT NOT NULL COMMENT '购买记录ID(FK→crm_deposit_charge_record.lid)',
  `tier_snapshot` JSON NOT NULL COMMENT '档位快照(TierConfig的完整JSON)',
  `issue_cycle_type` VARCHAR(20) NOT NULL COMMENT '周期类型:DAILY/WEEKLY/MONTHLY',
  `issue_cycle_values` JSON COMMENT '周期值[1,3,5]等',
  `issue_time` TIME COMMENT '发放时间(HH:mm:ss)',
  `total_issue_times` INT NOT NULL COMMENT '总发放次数',
  `issued_times` INT NOT NULL DEFAULT 0 COMMENT '已发放次数',
  `first_issue_immediate` TINYINT NOT NULL DEFAULT 0 COMMENT '首次是否立即发放:0-否,1-是',
  `next_issue_date` DATE COMMENT '下次发放日期',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0-已完成,1-进行中,2-已暂停',
  `created_by` VARCHAR(100) COMMENT '创建人',
  `created_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_by` VARCHAR(100) COMMENT '更新人',
  `updated_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '逻辑删除(0-否,1-是)',
  `revision` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号'
) COMMENT='储值方案周期发券计划';

CREATE INDEX `idx_mid` ON `crm_deposit_coupon_schedule`(`mid`);
CREATE INDEX `idx_sid` ON `crm_deposit_coupon_schedule`(`sid`);
CREATE UNIQUE INDEX `uk_lid` ON `crm_deposit_coupon_schedule`(`lid`);
CREATE INDEX `idx_card_lid` ON `crm_deposit_coupon_schedule`(`card_lid`);
CREATE INDEX `idx_status_next_date` ON `crm_deposit_coupon_schedule`(`status`, `next_issue_date`);

SET FOREIGN_KEY_CHECKS = 1;
