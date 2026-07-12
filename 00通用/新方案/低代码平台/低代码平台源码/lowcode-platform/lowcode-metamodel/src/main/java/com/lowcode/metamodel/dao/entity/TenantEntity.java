package com.lowcode.metamodel.dao.entity;

/** 租户元数据行。M0 只把租户配置作为带版本的 JSON 文本保存。 */
public class TenantEntity extends BaseMetaEntity {

  /** 稳定租户编码，不是运行时业务记录 lid。 */
  private String code;

  /** 面向用户展示的租户名称。 */
  private String name;

  /** 带版本的租户配置 JSON；服务层编解码器在 T-002 之后引入。 */
  private String config;
}
