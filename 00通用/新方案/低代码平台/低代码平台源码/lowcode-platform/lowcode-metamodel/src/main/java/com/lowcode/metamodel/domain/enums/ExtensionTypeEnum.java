package com.lowcode.metamodel.domain.enums;

/** 标准对象定制元数据使用的扩展结构类型。 */
public enum ExtensionTypeEnum implements CodeEnum {
  FIELD_ADD("field_add"),
  FIELD_OVERRIDE("field_override"),
  ACTION_ADD("action_add");

  private final String code;

  ExtensionTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
