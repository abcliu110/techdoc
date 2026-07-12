package com.lowcode.metamodel.dao.entity;

/** 角色元数据聚合。M0 保存权限定义，但不进行权限判定。 */
public class MetaRoleEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 应用内稳定的角色编码。 */
  private String code;

  /** 面向用户展示的角色名称。 */
  private String name;

  /** 带版本的权限 JSON；权限运行时属于后续里程碑。 */
  private String permissions;
}
