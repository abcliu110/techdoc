package com.lowcode.runtime.api;

import java.util.Set;

/**
 * API 层请求上下文。
 */
public record RuntimeRequestContext(
    Long tenantId,
    Long workspaceId,
    String userLid,
    Set<String> roleCodes,
    String appCode,
    String objectCode,
    String metaHash,
    String traceId) {}
