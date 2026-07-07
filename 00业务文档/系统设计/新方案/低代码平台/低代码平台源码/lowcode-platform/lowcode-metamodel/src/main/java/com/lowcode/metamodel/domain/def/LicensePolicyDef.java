package com.lowcode.metamodel.domain.def;

/**
 * License 策略元数据占位结构。
 *
 * <p>当前 mode 先保持稳定 code 字符串。后续绑定 LicenseModeEnum 时必须保留已序列化契约。
 */
public record LicensePolicyDef(
    String licenseMode,
    String degradePolicy,
    boolean allowDataRead,
    boolean allowAuditRead,
    boolean allowPrivateOfflineFallback,
    boolean runtimeEnabled) {

  public LicensePolicyDef(String licenseMode, boolean runtimeEnabled) {
    this(licenseMode, "read_only", true, true, false, runtimeEnabled);
  }
}
