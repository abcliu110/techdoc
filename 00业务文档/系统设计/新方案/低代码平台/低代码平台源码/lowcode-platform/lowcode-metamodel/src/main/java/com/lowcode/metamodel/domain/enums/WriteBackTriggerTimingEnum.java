package com.lowcode.metamodel.domain.enums;

/** 反写触发时机元数据。 */
public enum WriteBackTriggerTimingEnum implements CodeEnum {
  AFTER_SOURCE_SAVE("after_source_save"),
  AFTER_TARGET_APPROVE("after_target_approve");

  private final String code;

  WriteBackTriggerTimingEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
