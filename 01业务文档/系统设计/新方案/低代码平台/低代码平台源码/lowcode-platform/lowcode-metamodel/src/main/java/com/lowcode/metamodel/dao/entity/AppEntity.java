package com.lowcode.metamodel.dao.entity;

/** 应用元数据行。M0 把应用视为设计期聚合边界。 */
public class AppEntity extends BaseMetaEntity {

  /** 可选工作区归属。允许为空，用于兼容租户级应用。 */
  private Long workspaceId;

  /** 租户内稳定的应用编码。 */
  private String code;

  /** 面向用户展示的应用名称。 */
  private String name;

  /** 带版本的应用配置 JSON；可承载商业能力占位结构。 */
  private String config;
}
