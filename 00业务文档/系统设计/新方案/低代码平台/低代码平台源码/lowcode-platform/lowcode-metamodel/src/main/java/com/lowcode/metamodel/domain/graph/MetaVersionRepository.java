package com.lowcode.metamodel.domain.graph;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import java.util.Optional;

/**
 * 已发布版本快照仓储接口。
 */
public interface MetaVersionRepository {

  Optional<AppSnapshotDef> find(Long tenantId, String appCode, String metaVersion);

  Optional<String> findCurrentVersion(Long tenantId, String appCode);
}
