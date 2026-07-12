package com.lowcode.metamodel.domain.enums;

/**
 * License 模式元数据。
 *
 * <p>M0 禁止把产品行为绑定到在线校验。运行时检查在本阶段刻意缺席。
 */
public enum LicenseModeEnum implements CodeEnum {
  NONE("none"),
  OFFLINE("offline"),
  ONLINE("online"),
  HYBRID("hybrid");

  private final String code;

  LicenseModeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
