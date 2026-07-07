package com.lowcode.metamodel.domain.enums;

/** 应用包来源类型。 */
public enum PackageSourceKindEnum implements CodeEnum {
  SYSTEM("system"),
  VENDOR("vendor"),
  CUSTOMER("customer");

  private final String code;

  PackageSourceKindEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
