package com.lowcode.metamodel.domain.enums;

/** 插件挂载状态。M0 不实现加载和隔离。 */
public enum PluginStatusEnum implements CodeEnum {
  DRAFT("draft"),
  ENABLED("enabled"),
  DISABLED("disabled");

  private final String code;

  PluginStatusEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
