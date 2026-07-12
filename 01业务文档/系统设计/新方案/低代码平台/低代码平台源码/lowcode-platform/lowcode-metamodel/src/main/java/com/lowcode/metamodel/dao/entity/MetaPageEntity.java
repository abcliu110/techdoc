package com.lowcode.metamodel.dao.entity;

/** 页面元数据聚合。M0 保存视图定义，但不渲染 UI。 */
public class MetaPageEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 应用内稳定的页面编码。 */
  private String code;

  /** 面向用户展示的页面名称。 */
  private String name;

  /** 带版本的视图 schema JSON。渲染器行为不属于 T-002。 */
  private String views;
}
