package com.lowcode.metamodel.domain.enums;

/** i18n 回退策略元数据。 */
public enum I18nFallbackPolicyEnum implements CodeEnum {
  DEFAULT_LOCALE("default_locale"),
  EMPTY("empty"),
  KEY("key");

  private final String code;

  I18nFallbackPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
