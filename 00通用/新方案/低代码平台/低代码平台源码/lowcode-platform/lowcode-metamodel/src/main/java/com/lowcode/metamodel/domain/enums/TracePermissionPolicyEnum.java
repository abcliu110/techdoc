package com.lowcode.metamodel.domain.enums;

/** 链路追踪元数据的权限策略。 */
public enum TracePermissionPolicyEnum implements CodeEnum {
  INHERIT("inherit"),
  CHECK_TARGET("check_target"),
  DENY("deny");

  private final String code;

  TracePermissionPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
