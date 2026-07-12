package com.lowcode.metamodel.domain.enums;

/** 转换幂等策略元数据；执行能力不属于 M0。 */
public enum ConversionIdempotencyStrategyEnum implements CodeEnum {
  SOURCE_TARGET_ONCE("source_target_once"),
  BUSINESS_KEY("business_key");

  private final String code;

  ConversionIdempotencyStrategyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
