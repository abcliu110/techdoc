package com.lowcode.metamodel.domain.enums;

/** 后续菜单和页面元数据使用的设备范围。 */
public enum DeviceScopeEnum implements CodeEnum {
  DESKTOP("desktop"),
  MOBILE("mobile"),
  ALL("all");

  private final String code;

  DeviceScopeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
