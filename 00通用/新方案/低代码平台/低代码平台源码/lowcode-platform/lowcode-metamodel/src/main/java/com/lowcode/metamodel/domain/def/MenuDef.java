package com.lowcode.metamodel.domain.def;

/** 菜单元数据占位结构。M0 要避免把导航塞进 PageSchema 自由属性。 */
public record MenuDef(
    String menuCode,
    String requiredPermission,
    String titleI18nKey,
    String targetType,
    String targetCode,
    String deviceScope,
    boolean mobileSupported,
    boolean runtimeEnabled) {

  public MenuDef(String menuCode, boolean runtimeEnabled) {
    this(menuCode, null, null, null, null, "desktop", true, runtimeEnabled);
  }
}
