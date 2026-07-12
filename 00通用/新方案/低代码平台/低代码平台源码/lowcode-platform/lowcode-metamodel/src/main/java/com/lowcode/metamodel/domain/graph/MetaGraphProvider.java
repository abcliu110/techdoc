package com.lowcode.metamodel.domain.graph;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

/**
 * MetaGraph Provider。
 *
 * <p>Provider 负责“按版本加载”和“按当前版本刷新”两件事。下游运行时拿到 RequestRuntimeContext 后不能再读取 latest。
 */
public class MetaGraphProvider {

  private final MetaVersionRepository repository;
  private final MetaVersionPointer pointer;
  private final MetaGraphBuilder builder;
  private final int maxCachedVersions;
  private final Map<String, MetaGraph> cache = new LinkedHashMap<>();
  private boolean degradedReadOnly;

  public MetaGraphProvider(MetaVersionRepository repository, MetaVersionPointer pointer, MetaGraphBuilder builder, int maxCachedVersions) {
    this.repository = repository;
    this.pointer = pointer;
    this.builder = builder;
    this.maxCachedVersions = maxCachedVersions;
  }

  public MetaGraph requirePublished(Long tenantId, String appCode, String metaVersion) {
    String key = key(tenantId, appCode, metaVersion);
    MetaGraph cached = cache.get(key);
    if (cached != null) {
      return cached;
    }
    AppSnapshotDef snapshot =
        repository.find(tenantId, appCode, metaVersion)
            .orElseThrow(() -> new MetaGraphNotFoundException("发布快照不存在：" + appCode + "@" + metaVersion));
    MetaGraph graph = builder.build(snapshot);
    cache.put(key, graph);
    trimCache();
    return graph;
  }

  public MetaGraph requireLatestPublished(Long tenantId, String appCode) {
    Optional<String> pointerVersion = pointer.findCurrent(tenantId, appCode);
    if (pointerVersion.isPresent()) {
      degradedReadOnly = false;
      return requirePublished(tenantId, appCode, pointerVersion.get());
    }
    degradedReadOnly = true;
    String dbVersion =
        repository.findCurrentVersion(tenantId, appCode)
            .orElseThrow(() -> new MetaGraphNotFoundException("当前发布版本不存在：" + appCode));
    return requirePublished(tenantId, appCode, dbVersion);
  }

  public MetaGraph refreshLatest(Long tenantId, String appCode) {
    return requireLatestPublished(tenantId, appCode);
  }

  public Optional<MetaGraph> findCached(Long tenantId, String appCode, String metaVersion) {
    return Optional.ofNullable(cache.get(key(tenantId, appCode, metaVersion)));
  }

  public void evict(Long tenantId, String appCode) {
    cache.keySet().removeIf(key -> key.startsWith(tenantId + ":" + appCode + ":"));
  }

  public boolean degradedReadOnly() {
    return degradedReadOnly;
  }

  public void assertWritable() {
    if (degradedReadOnly) {
      throw new MetaGraphReadOnlyException("MetaGraph 版本指针不可用，当前处于只读降级");
    }
  }

  private void trimCache() {
    while (cache.size() > maxCachedVersions) {
      String firstKey = cache.keySet().iterator().next();
      cache.remove(firstKey);
    }
  }

  private static String key(Long tenantId, String appCode, String metaVersion) {
    return tenantId + ":" + appCode + ":" + metaVersion;
  }
}
