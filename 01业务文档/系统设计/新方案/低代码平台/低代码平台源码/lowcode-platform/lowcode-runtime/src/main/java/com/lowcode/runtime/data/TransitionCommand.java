package com.lowcode.runtime.data;

import java.util.Map;

/**
 * 状态流转命令。
 */
public record TransitionCommand(String recordLid, String actionCode, Map<String, Object> parameters, String requestMetaHash, String idempotencyKey) {}
