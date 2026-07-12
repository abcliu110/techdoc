package com.lowcode.metamodel.domain.enums;

/** 标准对象扩展策略。 */
public enum ExtensionPolicyEnum implements CodeEnum {
  NONE("none"),
  COPY("copy"),
  EXTENSION_LAYER("extension_layer");

  private final String code;

  ExtensionPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
