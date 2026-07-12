package com.lowcode.metamodel.domain.enums;

/** 删除行为元数据；M0 不实现物理删除。 */
public enum DeletePolicyEnum implements CodeEnum {
  RESTRICT("restrict"),
  CASCADE("cascade"),
  SET_NULL("set_null");

  private final String code;

  DeletePolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
