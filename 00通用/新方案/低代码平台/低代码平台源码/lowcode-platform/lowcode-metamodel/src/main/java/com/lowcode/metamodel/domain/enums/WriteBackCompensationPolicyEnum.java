package com.lowcode.metamodel.domain.enums;

/** 后续反写副作用使用的补偿策略。 */
public enum WriteBackCompensationPolicyEnum implements CodeEnum {
  MANUAL("manual"),
  AUTO_RETRY("auto_retry");

  private final String code;

  WriteBackCompensationPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
