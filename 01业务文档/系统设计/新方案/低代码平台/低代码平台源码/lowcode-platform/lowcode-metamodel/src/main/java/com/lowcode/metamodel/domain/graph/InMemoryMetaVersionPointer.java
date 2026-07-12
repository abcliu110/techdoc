package com.lowcode.metamodel.domain.graph;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

/**
 * M0 内存版当前版本指针。
 */
public class InMemoryMetaVersionPointer implements MetaVersionPointer {

  private final Map<String, String> currentVersions = new LinkedHashMap<>();
  private boolean unavailable;

  public void setCurrent(Long tenantId, String appCode, String metaVersion) {
    currentVersions.put(key(tenantId, appCode), metaVersion);
  }

  public void setUnavailable(boolean unavailable) {
    this.unavailable = unavailable;
  }

  @Override
  public Optional<String> findCurrent(Long tenantId, String appCode) {
    if (unavailable) {
      return Optional.empty();
    }
    return Optional.ofNullable(currentVersions.get(key(tenantId, appCode)));
  }

  private static String key(Long tenantId, String appCode) {
    return tenantId + ":" + appCode;
  }
}
