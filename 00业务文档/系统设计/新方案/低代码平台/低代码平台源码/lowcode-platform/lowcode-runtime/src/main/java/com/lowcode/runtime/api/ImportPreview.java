package com.lowcode.runtime.api;

import java.util.List;
import java.util.Map;

/**
 * 导入试跑结果。
 */
public record ImportPreview(String taskId, List<Map<String, Object>> rows, List<String> errors) {}
