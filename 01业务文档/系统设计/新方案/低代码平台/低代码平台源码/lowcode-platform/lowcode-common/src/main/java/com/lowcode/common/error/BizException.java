package com.lowcode.common.error;

/**
 * 携带稳定平台错误码的业务异常。
 *
 * <p>这个异常刻意只保存平台错误枚举和安全消息。字段级校验的结构化载荷由后续元模型服务补充，
 * 但不改变这个基础异常契约。
 */
public class BizException extends RuntimeException {

  private final ErrorCode errorCode;

  public BizException(ErrorCode errorCode, String message) {
    super(message);
    this.errorCode = errorCode;
  }

  public ErrorCode errorCode() {
    return errorCode;
  }
}
