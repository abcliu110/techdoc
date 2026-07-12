package com.lowcode.metamodel.domain.enums;

/**
 * 业务对象类型。
 *
 * <p>M0 只持久化类型意图。运行时表行为由 T-004 的 Schema Sync 决定。
 */
public enum ObjectTypeEnum implements CodeEnum {
  ENTITY("entity"),
  DOCUMENT("document"),
  VIEW("view");

  private final String code;

  ObjectTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
