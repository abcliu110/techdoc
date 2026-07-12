package com.lowcode.metamodel.domain.enums;

/** 预留给 M1 执行能力的规则类型元数据。 */
public enum RuleTypeEnum implements CodeEnum {
  VALIDATION("validation"),
  ASSIGNMENT("assignment"),
  AUTOMATION("automation");

  private final String code;

  RuleTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
