package com.lowcode.metamodel.domain.enums;

/** lc_meta_ref 中的目标类型。 */
public enum MetaTargetTypeEnum implements CodeEnum {
  OBJECT("object"),
  FIELD("field"),
  ACTION("action"),
  PAGE("page"),
  RESOURCE("resource");

  private final String code;

  MetaTargetTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
