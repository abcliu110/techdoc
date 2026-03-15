-- Generated from 需求分析.md

CREATE TABLE bonus_package (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_name VARCHAR(100) NOT NULL COMMENT '套餐名称/活动名称',
  category_id BIGINT NULL COMMENT '套餐分类ID（可新增分类）',
  brand_id BIGINT NULL COMMENT '品牌ID/组织范围标识',
  status ENUM('draft','enabled','disabled') NOT NULL DEFAULT 'draft' COMMENT '状态：草稿/启用/停用',
  remark VARCHAR(255) NULL COMMENT '备注说明',
  version INT NOT NULL DEFAULT 1 COMMENT '乐观锁版本号',
  created_by BIGINT NULL COMMENT '创建人',
  updated_by BIGINT NULL COMMENT '更新人',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_package_name_brand (package_name, brand_id)
) COMMENT='储值套餐主表，描述套餐基础信息与状态';

CREATE TABLE bonus_package_category (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  name VARCHAR(60) NOT NULL COMMENT '分类名称',
  brand_id BIGINT NULL COMMENT '品牌ID/组织范围标识',
  remark VARCHAR(255) NULL COMMENT '分类备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COMMENT='套餐分类，支持新增';

CREATE TABLE bonus_package_fixed_amount (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  amount DECIMAL(10,2) NOT NULL COMMENT '充值金额档位',
  bonus_amount DECIMAL(10,2) NULL COMMENT '赠送金额',
  bonus_points INT NULL COMMENT '赠送积分',
  sort_no INT NOT NULL DEFAULT 0 COMMENT '排序号',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_fixed_amount_pkg (package_id),
  CONSTRAINT fk_fixed_amount_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='固定金额档位配置（一个套餐可有多个档位）';

CREATE TABLE bonus_package_channel (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  channel_code VARCHAR(40) NOT NULL COMMENT '渠道编码（POS/小程序/商户中心等）',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_pkg_channel (package_id, channel_code),
  CONSTRAINT fk_channel_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='适用渠道（多选）';

CREATE TABLE bonus_package_org_scope (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  scope_type ENUM('all','store','region') NOT NULL DEFAULT 'all' COMMENT '组织范围：全部/指定门店/指定区域',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_pkg_scope (package_id),
  CONSTRAINT fk_scope_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='组织范围选择（单选）';

CREATE TABLE bonus_package_org_store (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  store_id BIGINT NOT NULL COMMENT '门店ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_pkg_store (package_id, store_id),
  CONSTRAINT fk_store_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='组织范围为指定门店时的门店清单';

CREATE TABLE bonus_package_org_region (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  region_id BIGINT NOT NULL COMMENT '区域ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_pkg_region (package_id, region_id),
  CONSTRAINT fk_region_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='组织范围为指定区域时的区域清单';

CREATE TABLE bonus_package_miniprogram_whitelist (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  app_code VARCHAR(60) NOT NULL COMMENT '小程序入口编码',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_pkg_app (package_id, app_code),
  CONSTRAINT fk_app_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='小程序白名单（当选择小程序渠道时）';

CREATE TABLE bonus_package_audit (
  id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键',
  package_id BIGINT NOT NULL COMMENT '所属套餐ID',
  action VARCHAR(40) NOT NULL COMMENT '操作类型（启用/停用/保存等）',
  operator_id BIGINT NULL COMMENT '操作人',
  payload JSON NULL COMMENT '变更快照',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  KEY idx_audit_pkg (package_id),
  CONSTRAINT fk_audit_pkg FOREIGN KEY (package_id) REFERENCES bonus_package(id) ON DELETE CASCADE
) COMMENT='审计日志';
