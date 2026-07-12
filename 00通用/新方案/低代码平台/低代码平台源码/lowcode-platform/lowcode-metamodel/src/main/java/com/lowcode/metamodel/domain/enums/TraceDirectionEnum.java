package com.lowcode.metamodel.domain.enums;

/** 后续单据上查/下查追踪使用的链路方向。 */
public enum TraceDirectionEnum implements CodeEnum {
  UPSTREAM("upstream"),
  DOWNSTREAM("downstream"),
  BIDIRECTIONAL("bidirectional");

  private final String code;

  TraceDirectionEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
