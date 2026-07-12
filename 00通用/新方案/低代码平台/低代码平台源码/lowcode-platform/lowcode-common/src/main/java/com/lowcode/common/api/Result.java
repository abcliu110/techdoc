package com.lowcode.common.api;

import com.lowcode.common.error.ErrorCode;

/**
 * 全模块共享的统一 API 响应结构。
 *
 * <p>M0 只冻结响应契约；HTTP 异常绑定和 traceId 注入等能力等设计器或运行时 API 出现后再补。这里保持很小，
 * 是为了从第一个里程碑开始就稳定字段名，后续做 API 兼容测试时有清晰边界。
 *
 * @param code 稳定的平台错误码
 * @param message 可安全返回给调用方的消息
 * @param data 响应数据
 * @param traceId 请求追踪标识
 */
public record Result<T>(String code, String message, T data, String traceId) {

  public static <T> Result<T> success(T data, String traceId) {
    // 成功码集中在这里，避免控制器以后散落魔法字符串。
    return new Result<>(ErrorCode.SUCCESS.code(), ErrorCode.SUCCESS.message(), data, traceId);
  }

  public static <T> Result<T> failure(ErrorCode errorCode, String message, String traceId) {
    // 消息由调用方传入，后续字段级校验错误可以携带更具体的上下文。
    return new Result<>(errorCode.code(), message, null, traceId);
  }
}
