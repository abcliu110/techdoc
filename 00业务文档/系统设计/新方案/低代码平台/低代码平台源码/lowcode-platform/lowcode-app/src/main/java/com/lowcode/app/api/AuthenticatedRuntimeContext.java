package com.lowcode.app.api;

import java.util.Set;

/**
 * 运行态受控请求上下文。
 *
 * <p>当前阶段由受控请求头注入，避免控制器再硬编码默认租户、工作区和角色。
 */
public record AuthenticatedRuntimeContext(
    Long tenantId,
    Long workspaceId,
    String userLid,
    Set<String> roleCodes,
    String appCode,
    String objectCode,
    String metaHash,
    String traceId) {}
