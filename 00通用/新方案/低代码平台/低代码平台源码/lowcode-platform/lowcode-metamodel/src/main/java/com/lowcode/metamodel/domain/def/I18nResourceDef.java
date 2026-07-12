package com.lowcode.metamodel.domain.def;

/** i18n 资源占位结构。M0 只记录文案资源，不加载前端运行时。 */
public record I18nResourceDef(String resourceKey, String locale, String text, boolean runtimeEnabled) {

  public I18nResourceDef(String resourceKey, String locale, boolean runtimeEnabled) {
    this(resourceKey, locale, null, runtimeEnabled);
  }
}
