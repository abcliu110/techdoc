package com.lowcode.metamodel.domain.enums;

/** 打印模板数据快照策略元数据。 */
public enum TemplateDataSnapshotPolicyEnum implements CodeEnum {
  RENDER_TIME("render_time"),
  PUBLISH_TIME("publish_time");

  private final String code;

  TemplateDataSnapshotPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
