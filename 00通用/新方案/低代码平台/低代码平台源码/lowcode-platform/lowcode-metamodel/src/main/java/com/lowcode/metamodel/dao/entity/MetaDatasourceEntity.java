package com.lowcode.metamodel.dao.entity;

/** 外部数据源元数据。密钥在进入实体前必须已经加密或脱敏。 */
public class MetaDatasourceEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 应用内稳定的数据源编码。 */
  private String code;

  /** 面向用户展示的数据源名称。 */
  private String name;

  /** 带版本的数据源配置 JSON。运行时连接不属于 T-002。 */
  private String config;
}
