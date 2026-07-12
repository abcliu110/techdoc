package com.lowcode.metamodel.domain.enums;

/** 从 link/table/multilink 字段派生的关系形态。 */
public enum RelationTypeEnum implements CodeEnum {
  MANY_TO_ONE("many_to_one"),
  ONE_TO_MANY("one_to_many"),
  MANY_TO_MANY("many_to_many");

  private final String code;

  RelationTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
