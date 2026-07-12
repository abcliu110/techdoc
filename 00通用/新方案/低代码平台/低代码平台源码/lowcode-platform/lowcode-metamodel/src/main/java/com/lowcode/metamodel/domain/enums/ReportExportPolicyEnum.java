package com.lowcode.metamodel.domain.enums;

/** 报表导出策略元数据。 */
public enum ReportExportPolicyEnum implements CodeEnum {
  DENY("deny"),
  ALLOW("allow"),
  WATERMARK("watermark");

  private final String code;

  ReportExportPolicyEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
