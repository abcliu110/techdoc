package com.lowcode.metamodel.dao.entity;

/** 动态物理结构登记行。M0 记录计划中的结构，不记录业务数据行。 */
public class PhysicalSchemaEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 被登记物理表的对象编码。 */
  private String objectCode;

  /** Schema Sync 生成的物理表名。 */
  private String tableName;

  /** 带版本的物理结构 JSON；在 Schema Sync 编解码器出现前保持文本形态。 */
  private String schemaJson;

  /** 后续对账任务用来发现结构漂移的哈希值。 */
  private String schemaHash;
}
