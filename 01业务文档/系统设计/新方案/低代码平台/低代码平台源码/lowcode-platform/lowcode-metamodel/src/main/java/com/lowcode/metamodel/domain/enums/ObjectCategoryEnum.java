package com.lowcode.metamodel.domain.enums;

/** 对象归属类别，用于标准对象、模板对象、客户对象和扩展对象。 */
public enum ObjectCategoryEnum implements CodeEnum {
  STANDARD("standard"),
  TEMPLATE("template"),
  CUSTOM("custom"),
  EXTENSION("extension");

  private final String code;

  ObjectCategoryEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
