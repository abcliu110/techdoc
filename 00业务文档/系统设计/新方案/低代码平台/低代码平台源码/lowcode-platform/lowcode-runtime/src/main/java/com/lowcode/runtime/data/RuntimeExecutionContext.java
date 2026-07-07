package com.lowcode.runtime.data;

import java.util.Set;

/**
 * 运行态请求固定上下文。
 */
public record RuntimeExecutionContext(
    Long tenantId,
    Long workspaceId,
    String userLid,
    Set<String> roleCodes,
    String appCode,
    String objectCode,
    String metaHash,
    String traceId) {}
