package com.lowcode.metamodel.domain.enums;

/**
 * 元数据来源层。
 *
 * <p>M0 只记录来源类型。应用包的合并和升级规则由后续里程碑门禁控制。
 */
public enum MetaSourceKindEnum implements CodeEnum {
  SYSTEM("system"),
  VENDOR("vendor"),
  CUSTOMER("customer");

  private final String code;

  MetaSourceKindEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
