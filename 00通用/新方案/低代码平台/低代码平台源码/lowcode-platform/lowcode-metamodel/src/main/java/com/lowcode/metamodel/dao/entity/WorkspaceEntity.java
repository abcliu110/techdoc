package com.lowcode.metamodel.dao.entity;

/** 工作区元数据行。工作区用于组织应用，M0 不在这里执行运行时行为。 */
public class WorkspaceEntity extends BaseMetaEntity {

  /** 租户内稳定的工作区编码。 */
  private String code;

  /** 面向用户展示的工作区名称。 */
  private String name;

  /** 带版本的工作区配置 JSON；实体层保持不解析。 */
  private String config;
}
