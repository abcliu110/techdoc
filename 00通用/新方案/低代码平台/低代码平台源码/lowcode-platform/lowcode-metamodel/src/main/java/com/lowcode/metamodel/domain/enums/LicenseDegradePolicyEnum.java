package com.lowcode.metamodel.domain.enums;

/** License 降级策略元数据。 */
public enum LicenseDegradePolicyEnum implements CodeEnum {
  READ_ONLY("read_only"),
  DENY_NEW("deny_new"),
  GRACE_PERIOD("grace_period");

  private final String code;

  LicenseDegradePolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
