package com.lowcode.metamodel.domain.def;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 所有元数据表 JSON 聚合共同遵守的契约。
 *
 * <p>持久化字段名使用 `_v`，用于保证快照可以安全升级。Java 方法名保留 `schemaVersion`，
 * 是为了在领域代码中表达清楚意图，而不是直接暴露传输层命名。
 */
public interface VersionedJson {

  @JsonProperty("_v")
  int schemaVersion();
}
