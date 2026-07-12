package com.lowcode.runtime.api;

/**
 * 运行态 API 安全异常。
 */
public class RuntimeApiException extends RuntimeException {

  private final String code;

  public RuntimeApiException(String message) {
    this("PARAM_INVALID", message);
  }

  public RuntimeApiException(String code, String message) {
    super(message);
    this.code = code;
  }

  public RuntimeApiException(String message, Throwable cause) {
    super(message, cause);
    this.code = cause instanceof com.lowcode.runtime.data.RuntimeDataException runtimeDataException
        ? runtimeDataException.getErrorCode().name()
        : "PARAM_INVALID";
  }

  public RuntimeApiException(String code, String message, Throwable cause) {
    super(message, cause);
    this.code = code;
  }

  public String code() {
    return code;
  }
}
