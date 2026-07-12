package com.lowcode.metamodel.domain.enums;

/** 元模型对象的草稿/已发布生命周期状态。 */
public enum ObjectStatusEnum implements CodeEnum {
  DRAFT("draft"),
  PUBLISHED("published"),
  DISABLED("disabled");

  private final String code;

  ObjectStatusEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
