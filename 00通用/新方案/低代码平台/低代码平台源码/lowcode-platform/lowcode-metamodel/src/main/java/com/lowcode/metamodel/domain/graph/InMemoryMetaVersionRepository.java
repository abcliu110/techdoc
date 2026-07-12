package com.lowcode.metamodel.domain.graph;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

/**
 * M0 内存版发布快照仓储。
 */
public class InMemoryMetaVersionRepository implements MetaVersionRepository {

  private final Map<String, AppSnapshotDef> snapshots = new LinkedHashMap<>();
  private final Map<String, String> currentVersions = new LinkedHashMap<>();

  public void save(AppSnapshotDef snapshot) {
    snapshots.put(key(snapshot.tenantId(), snapshot.appCode(), snapshot.versionNo()), snapshot);
    currentVersions.putIfAbsent(currentKey(snapshot.tenantId(), snapshot.appCode()), snapshot.versionNo());
  }

  public void setCurrent(Long tenantId, String appCode, String metaVersion) {
    currentVersions.put(currentKey(tenantId, appCode), metaVersion);
  }

  @Override
  public Optional<AppSnapshotDef> find(Long tenantId, String appCode, String metaVersion) {
    return Optional.ofNullable(snapshots.get(key(tenantId, appCode, metaVersion)));
  }

  @Override
  public Optional<String> findCurrentVersion(Long tenantId, String appCode) {
    return Optional.ofNullable(currentVersions.get(currentKey(tenantId, appCode)));
  }

  private static String key(Long tenantId, String appCode, String metaVersion) {
    return currentKey(tenantId, appCode) + ":" + metaVersion;
  }

  private static String currentKey(Long tenantId, String appCode) {
    return tenantId + ":" + appCode;
  }
}
