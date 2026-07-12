package com.lowcode.metamodel.dao.entity;

/** 插件挂载元数据。M0 保存配置，但不加载插件代码。 */
public class MetaPluginEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 应用内稳定的插件编码。 */
  private String code;

  /** 面向用户展示的插件名称。 */
  private String name;

  /** 带版本的插件配置 JSON，可包含应用包和 License 占位结构。 */
  private String config;
}
