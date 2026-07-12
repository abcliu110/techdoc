package com.lowcode.metamodel.domain.enums;

/** 多组织元数据中的组织角色类型。 */
public enum OrgRoleTypeEnum implements CodeEnum {
  OWNER("owner"),
  SALES("sales"),
  DELIVERY("delivery");

  private final String code;

  OrgRoleTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
