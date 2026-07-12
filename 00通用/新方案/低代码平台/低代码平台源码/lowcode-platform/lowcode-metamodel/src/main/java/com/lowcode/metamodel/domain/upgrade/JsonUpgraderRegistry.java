package com.lowcode.metamodel.domain.upgrade;

import com.lowcode.metamodel.domain.def.VersionedJson;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 带版本元数据 JSON 升级器的严格注册表。
 *
 * <p>T-002 阶段注册表刻意保持很小。它的主要职责是让 T-005 加载旧快照时无法忽略缺失的升级链。
 */
public class JsonUpgraderRegistry {

  private final Map<Key, JsonUpgrader<? extends VersionedJson>> upgraders = new HashMap<>();

  public JsonUpgraderRegistry(List<? extends JsonUpgrader<? extends VersionedJson>> upgraders) {
    for (JsonUpgrader<? extends VersionedJson> upgrader : upgraders) {
      this.upgraders.put(new Key(upgrader.targetType(), upgrader.fromVersion()), upgrader);
    }
  }

  public <T extends VersionedJson> void validateChain(
      Class<T> targetType, int minSupportedVersion, int currentVersion) {
    for (int version = minSupportedVersion; version < currentVersion; version++) {
      JsonUpgrader<? extends VersionedJson> upgrader = upgraders.get(new Key(targetType, version));
      if (upgrader == null || upgrader.toVersion() != version + 1) {
        throw new JsonUpgradeException(
            "missing upgrader for " + targetType.getSimpleName() + " from " + version);
      }
    }
  }

  public <T extends VersionedJson> T upgrade(T value, int currentVersion) {
    if (value.schemaVersion() > currentVersion) {
      throw new JsonUpgradeException("future version " + value.schemaVersion());
    }
    T current = value;
    while (current.schemaVersion() < currentVersion) {
      JsonUpgrader<T> upgrader = find(current);
      current = upgrader.upgrade(current);
    }
    return current;
  }

  @SuppressWarnings("unchecked")
  private <T extends VersionedJson> JsonUpgrader<T> find(T value) {
    JsonUpgrader<? extends VersionedJson> upgrader =
        upgraders.get(new Key(value.getClass(), value.schemaVersion()));
    if (upgrader == null) {
      throw new JsonUpgradeException(
          "missing upgrader for " + value.getClass().getSimpleName() + " from " + value.schemaVersion());
    }
    return (JsonUpgrader<T>) upgrader;
  }

  private record Key(Class<?> targetType, int fromVersion) {}
}
