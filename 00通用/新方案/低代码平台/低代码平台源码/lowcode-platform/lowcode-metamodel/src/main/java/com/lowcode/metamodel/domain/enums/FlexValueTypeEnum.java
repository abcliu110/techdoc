package com.lowcode.metamodel.domain.enums;

/** 弹性域值类型元数据。 */
public enum FlexValueTypeEnum implements CodeEnum {
  TEXT("text"),
  NUMBER("number"),
  OPTION("option");

  private final String code;

  FlexValueTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
