package com.lowcode.metamodel.domain.enums;

/** 菜单目标元数据类型。 */
public enum MenuTargetTypeEnum implements CodeEnum {
  PAGE("page"),
  REPORT("report"),
  URL("url");

  private final String code;

  MenuTargetTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
