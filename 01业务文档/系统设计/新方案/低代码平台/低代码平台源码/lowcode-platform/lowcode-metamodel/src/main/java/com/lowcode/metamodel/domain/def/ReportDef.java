package com.lowcode.metamodel.domain.def;

/** 报表元数据占位结构。M0 不执行报表或导出。 */
public record ReportDef(
    String reportCode,
    String requiredPermission,
    String titleI18nKey,
    boolean mobileSupported,
    boolean runtimeEnabled) {

  public ReportDef(String reportCode, boolean runtimeEnabled) {
    this(reportCode, null, null, true, runtimeEnabled);
  }
}
