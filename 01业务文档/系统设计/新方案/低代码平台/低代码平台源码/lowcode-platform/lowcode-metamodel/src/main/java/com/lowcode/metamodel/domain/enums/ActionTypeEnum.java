package com.lowcode.metamodel.domain.enums;

/** 动作元数据类型。M0 只保存定义。 */
public enum ActionTypeEnum implements CodeEnum {
  TRANSITION("transition"),
  COMMAND("command"),
  UI("ui");

  private final String code;

  ActionTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
