package com.lowcode.metamodel.domain.enums;

/** 后续单据状态机使用的状态节点类型。 */
public enum StateTypeEnum implements CodeEnum {
  INITIAL("initial"),
  NORMAL("normal"),
  FINAL("final");

  private final String code;

  StateTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
