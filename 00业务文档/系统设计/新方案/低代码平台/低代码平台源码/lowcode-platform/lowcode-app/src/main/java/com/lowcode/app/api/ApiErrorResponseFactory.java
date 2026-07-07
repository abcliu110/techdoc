package com.lowcode.app.api;

import com.lowcode.common.api.Result;
import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/**
 * 统一构造对外安全的错误响应。
 *
 * <p>内部异常 message 可能包含 SQL、物理表名或类名，这些内容只能保留在服务端异常链路里，
 * 不能直接进入外部响应。控制器统一通过这里映射成稳定错误码、安全消息和 traceId。
 */
@Component
public class ApiErrorResponseFactory {

  /**
   * 映射业务异常。
   *
   * @param ex 业务异常
   * @param request 当前请求
   * @return 业务异常对应的 HTTP 状态和响应体
   */
  public ApiErrorResponse fromBizException(BizException ex, HttpServletRequest request) {
    HttpStatus status = ex.errorCode() == ErrorCode.TENANT_REQUIRED ? HttpStatus.BAD_REQUEST : HttpStatus.BAD_REQUEST;
    return new ApiErrorResponse(status, Result.failure(ex.errorCode(), ex.getMessage(), traceId(request)));
  }

  /**
   * 映射运行态异常。
   *
   * @param ex 运行态异常
   * @param request 当前请求
   * @return 脱敏后的统一错误响应
   */
  public ApiErrorResponse fromRuntimeException(RuntimeException ex, HttpServletRequest request) {
    return new ApiErrorResponse(
        HttpStatus.BAD_REQUEST,
        Result.failure(ErrorCode.PARAM_INVALID, "请求处理失败", traceId(request)));
  }

  /**
   * 映射未知异常。
   *
   * @param request 当前请求
   * @return 脱敏后的统一错误响应
   */
  public ApiErrorResponse fromUnexpectedException(HttpServletRequest request) {
    return new ApiErrorResponse(
        HttpStatus.INTERNAL_SERVER_ERROR,
        Result.failure(ErrorCode.PARAM_INVALID, "系统繁忙，请稍后重试", traceId(request)));
  }

  private String traceId(HttpServletRequest request) {
    String value = request.getHeader("X-Trace-Id");
    return value == null || value.isBlank() ? "trace-http" : value.trim();
  }
}

record ApiErrorResponse(HttpStatus status, Result<Object> body) {}
