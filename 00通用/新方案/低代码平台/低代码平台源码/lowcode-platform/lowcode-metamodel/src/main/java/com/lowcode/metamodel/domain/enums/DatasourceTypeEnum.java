package com.lowcode.metamodel.domain.enums;

/** 数据源元数据类型。连接器运行时不属于 M0。 */
public enum DatasourceTypeEnum implements CodeEnum {
  MYSQL("mysql"),
  HTTP("http"),
  CUSTOM("custom");

  private final String code;

  DatasourceTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
