package com.lowcode.metamodel.domain.enums;

/** 编号序列断号策略元数据。 */
public enum CodeRuleGapPolicyEnum implements CodeEnum {
  ALLOW_GAP("allow_gap"),
  NO_GAP("no_gap");

  private final String code;

  CodeRuleGapPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
