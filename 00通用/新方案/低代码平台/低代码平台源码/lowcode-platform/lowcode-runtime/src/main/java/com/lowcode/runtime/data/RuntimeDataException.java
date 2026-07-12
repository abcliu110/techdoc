package com.lowcode.runtime.data;

/**
 * 运行态数据异常。
 */
public class RuntimeDataException extends RuntimeException {

  private final RuntimeDataErrorCode errorCode;

  public RuntimeDataException(RuntimeDataErrorCode errorCode, String message) {
    super(message);
    this.errorCode = errorCode;
  }

  public RuntimeDataErrorCode getErrorCode() {
    return errorCode;
  }
}
