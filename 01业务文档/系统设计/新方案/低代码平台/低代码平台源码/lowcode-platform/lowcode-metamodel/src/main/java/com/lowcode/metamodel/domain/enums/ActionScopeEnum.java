package com.lowcode.metamodel.domain.enums;

/** 动作调用范围。运行时分发从 M0 之后开始。 */
public enum ActionScopeEnum implements CodeEnum {
  OBJECT("object"),
  RECORD("record"),
  BATCH("batch");

  private final String code;

  ActionScopeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
