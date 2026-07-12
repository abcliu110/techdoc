package com.lowcode.common.error;

/**
 * 稳定的平台错误码注册表。
 *
 * <p>从 T-001 起就用枚举承载错误码，避免后续模块把字符串散落到各个服务里。M0 只放公共启动阶段错误码，
 * 以及后续乐观锁测试需要的一个元模型冲突错误码。
 */
public enum ErrorCode {
  SUCCESS("0", "success"),
  PARAM_INVALID("LC-COMM-0400", "invalid parameter"),
  TENANT_REQUIRED("LC-COMM-0401", "tenant is required"),
  FEATURE_DISABLED("LC-COMM-0403", "feature disabled"),
  META_CONFLICT("LC-META-4090", "metadata revision conflict");

  private final String code;
  private final String message;

  ErrorCode(String code, String message) {
    this.code = code;
    this.message = message;
  }

  public String code() {
    return code;
  }

  public String message() {
    return message;
  }
}
