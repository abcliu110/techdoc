package com.lowcode.runtime.data;

import java.util.Map;

/**
 * 动态新增命令。
 */
public record AddRecordCommand(Map<String, Object> values, String requestMetaHash, String idempotencyKey) {}
