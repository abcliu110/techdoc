package com.lowcode.metamodel.domain.def;

/** 打印模板占位结构。M0 不渲染打印内容，也不生成打印输出版本。 */
public record PrintTemplateDef(
    String templateCode,
    String objectCode,
    String requiredPermission,
    String titleI18nKey,
    boolean mobileSupported,
    boolean runtimeEnabled) {

  public PrintTemplateDef(String templateCode, String objectCode, boolean runtimeEnabled) {
    this(templateCode, objectCode, null, null, true, runtimeEnabled);
  }
}
