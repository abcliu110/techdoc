package com.lowcode.runtime.api;

import java.util.List;

/**
 * 运行态对象元数据摘要。
 */
public record RuntimeObjectMeta(String appCode, String objectCode, String metaHash, List<String> fields) {}
