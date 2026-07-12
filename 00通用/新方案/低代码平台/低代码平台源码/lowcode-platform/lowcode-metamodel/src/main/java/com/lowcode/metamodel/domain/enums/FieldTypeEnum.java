package com.lowcode.metamodel.domain.enums;

/**
 * M0 内置字段类型目录。
 *
 * <p>这 22 个 code 是后续 FieldTypeHandler 测试消费的可执行事实源。有数据后禁止改名；需要变化时只能新增 code 和迁移路径。
 */
public enum FieldTypeEnum implements CodeEnum {
  TEXT("text"),
  TEXTAREA("textarea"),
  RICHTEXT("richtext"),
  CODE("code"),
  INTEGER("integer"),
  DECIMAL("decimal"),
  PERCENT("percent"),
  CURRENCY("currency"),
  DATE("date"),
  DATETIME("datetime"),
  TIME("time"),
  SELECT("select"),
  MULTISELECT("multiselect"),
  CHECKBOX("checkbox"),
  LINK("link"),
  TABLE("table"),
  MULTILINK("multilink"),
  AUTONUMBER("autonumber"),
  USER("user"),
  ORG("org"),
  ATTACHMENT("attachment"),
  FORMULA("formula");

  private final String code;

  FieldTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
