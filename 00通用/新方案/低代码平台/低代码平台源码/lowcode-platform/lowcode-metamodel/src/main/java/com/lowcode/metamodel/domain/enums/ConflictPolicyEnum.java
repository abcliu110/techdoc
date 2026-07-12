package com.lowcode.metamodel.domain.enums;

/** 冲突处理策略元数据。 */
public enum ConflictPolicyEnum implements CodeEnum {
  REJECT("reject"),
  WARN("warn"),
  OVERRIDE("override");

  private final String code;

  ConflictPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
