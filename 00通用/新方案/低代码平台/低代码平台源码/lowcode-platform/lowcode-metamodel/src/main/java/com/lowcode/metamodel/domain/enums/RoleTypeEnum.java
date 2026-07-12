package com.lowcode.metamodel.domain.enums;

/** 角色类别元数据。 */
public enum RoleTypeEnum implements CodeEnum {
  SYSTEM("system"),
  CUSTOM("custom");

  private final String code;

  RoleTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
