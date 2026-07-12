package com.lowcode.designer.service;

import com.lowcode.common.error.ErrorCode;

/**
 * 设计态门面的稳定业务异常。
 *
 * <p>设计态校验和版本冲突通过该异常向 app 层暴露稳定错误码，内部原因保留在 cause 中，不直接暴露给外部响应。
 */
public class DesignerApiException extends RuntimeException {

  private final ErrorCode errorCode;
  private final String safeMessage;
  private final Object safeData;

  public DesignerApiException(ErrorCode errorCode, String safeMessage, Object safeData) {
    super(safeMessage);
    this.errorCode = errorCode;
    this.safeMessage = safeMessage;
    this.safeData = safeData;
  }

  public DesignerApiException(ErrorCode errorCode, String safeMessage, Object safeData, Throwable cause) {
    super(safeMessage, cause);
    this.errorCode = errorCode;
    this.safeMessage = safeMessage;
    this.safeData = safeData;
  }

  public ErrorCode errorCode() {
    return errorCode;
  }

  public String safeMessage() {
    return safeMessage;
  }

  public Object safeData() {
    return safeData;
  }
}
