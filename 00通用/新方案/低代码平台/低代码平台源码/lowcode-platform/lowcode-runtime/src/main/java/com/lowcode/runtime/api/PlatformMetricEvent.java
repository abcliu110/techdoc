package com.lowcode.runtime.api;

import java.util.Map;

/**
 * 平台指标事件。指标只记录对象、租户、trace，不记录业务字段值。
 */
public record PlatformMetricEvent(
    String metricCode,
    Long tenantId,
    String appCode,
    String objectCode,
    String traceId,
    Map<String, String> tags) {

  static PlatformMetricEvent safe(String metricCode, Long tenantId, String appCode, String objectCode, String traceId) {
    return new PlatformMetricEvent(metricCode, tenantId, appCode, objectCode, traceId, Map.of("source", "runtime"));
  }
}
