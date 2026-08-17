-- 会员消费权益总开关系统参数定义。
-- 这里只注册后台“系统参数”页面可见的参数项，不给任何门店默认开启。
-- a_platform 库里 sys_config_type 和 sys_dict_* 可能使用不同 collation，字符串比较统一转成 utf8mb4_general_ci。

USE a_platform;

SET @crm_consume_benefit_key = 'g_crmConsumeBenefitEnabled';
SET @crm_consume_benefit_name = '启用会员消费权益';
SET @crm_consume_benefit_remark = '控制POS消费积分、消费赠券、消费返现；配置缺失或关闭时不执行。';
SET @crm_consume_benefit_lid = 202605260001;

-- 系统参数按 module 过滤展示；module 必须取 CONFIG_TYPE_MODULE 字典下“会员模块”的 lid。
SET @crm_module_lid = (
  SELECT d.lid
  FROM sys_dict_type t
  JOIN sys_dict_data d ON d.type_code = t.lid
  WHERE CONVERT(t.id USING utf8mb4) COLLATE utf8mb4_general_ci = 'CONFIG_TYPE_MODULE'
    AND COALESCE(t.deleted, 0) = 0
    AND COALESCE(d.deleted, 0) = 0
    AND (
      CONVERT(d.label USING utf8mb4) COLLATE utf8mb4_general_ci = '会员模块'
      OR CONVERT(d.value USING utf8mb4) COLLATE utf8mb4_general_ci = '1'
    )
  ORDER BY CASE WHEN CONVERT(d.label USING utf8mb4) COLLATE utf8mb4_general_ci = '会员模块' THEN 0 ELSE 1 END
  LIMIT 1
);

UPDATE sys_config_type
SET module = COALESCE(@crm_module_lid, module),
    name = @crm_consume_benefit_name,
    remark = @crm_consume_benefit_remark,
    type = 1,
    enums = NULL,
    defVal = 'false',
    `def` = 1,
    revision = COALESCE(revision, 0) + 1,
    updated_by = 'upgrade',
    updated_time = NOW(),
    deleted = 0
WHERE CONVERT(id USING utf8mb4) COLLATE utf8mb4_general_ci = @crm_consume_benefit_key;

INSERT INTO sys_config_type (
  mid,
  sid,
  lid,
  module,
  name,
  id,
  remark,
  type,
  enums,
  defVal,
  `def`,
  revision,
  created_by,
  created_time,
  updated_by,
  updated_time,
  deleted
)
SELECT
  -1,
  -1,
  @crm_consume_benefit_lid,
  @crm_module_lid,
  @crm_consume_benefit_name,
  @crm_consume_benefit_key,
  @crm_consume_benefit_remark,
  1,
  NULL,
  'false',
  1,
  0,
  'upgrade',
  NOW(),
  'upgrade',
  NOW(),
  0
WHERE @crm_module_lid IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM sys_config_type
    WHERE CONVERT(id USING utf8mb4) COLLATE utf8mb4_general_ci = @crm_consume_benefit_key
  );

-- 验证：应返回一行，且 module 不为空；门店启用值仍由 sys_config_data 单独配置。
SELECT id, name, module, type, defVal, `def`, deleted
FROM sys_config_type
WHERE CONVERT(id USING utf8mb4) COLLATE utf8mb4_general_ci = @crm_consume_benefit_key;
