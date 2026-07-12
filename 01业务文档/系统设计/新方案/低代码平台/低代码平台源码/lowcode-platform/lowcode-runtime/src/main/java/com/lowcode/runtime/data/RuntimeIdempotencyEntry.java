package com.lowcode.runtime.data;

/**
 * 运行态幂等结果摘要。
 *
 * <p>重复请求只返回第一次执行的业务摘要，不重新执行业务写入、审计或 outbox。
 */
public record RuntimeIdempotencyEntry(
    String operation,
    String idempotencyKey,
    String recordLid,
    String fromState,
    String toState,
    Long revision) {}
