package com.lowcode.metamodel.domain.enums;

/** 规则触发点元数据。M0 只校验结构，不执行规则。 */
public enum RuleTriggerEnum implements CodeEnum {
  BEFORE_SAVE("before_save"),
  AFTER_SAVE("after_save"),
  ON_SUBMIT("on_submit");

  private final String code;

  RuleTriggerEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
