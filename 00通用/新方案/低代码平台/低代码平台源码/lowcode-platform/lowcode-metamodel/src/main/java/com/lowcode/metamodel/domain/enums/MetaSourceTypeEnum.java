package com.lowcode.metamodel.domain.enums;

/** lc_meta_ref 中的来源类型。 */
public enum MetaSourceTypeEnum implements CodeEnum {
  OBJECT("object"),
  PAGE("page"),
  ROLE("role"),
  PLUGIN("plugin");

  private final String code;

  MetaSourceTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
