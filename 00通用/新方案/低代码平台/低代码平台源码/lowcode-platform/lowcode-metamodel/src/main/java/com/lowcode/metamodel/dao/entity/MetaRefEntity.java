package com.lowcode.metamodel.dao.entity;

/** 可重建的元数据引用索引。它用于加速分析，但不是事实源。 */
public class MetaRefEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 来源元数据类型，例如 object/page/rule。 */
  private String sourceType;

  /** 稳定的来源元数据编码。 */
  private String sourceCode;

  /** 产生该引用的来源 JSON 路径。 */
  private String sourcePath;

  /** 引用类型编码，例如 object/field/page。 */
  private String refType;

  /** 目标元数据类型。 */
  private String targetType;

  /** 稳定的目标元数据编码。 */
  private String targetCode;

  /** 可选引用详情 JSON。 */
  private String detail;
}
