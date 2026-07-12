package com.lowcode.metamodel.domain.graph;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * JDBC-backed published metamodel repository.
 */
public class JdbcMetaVersionRepository implements MetaVersionRepository {

  private static final String FIND_SNAPSHOT_SQL = "select v.snapshot from lc_meta_version v join lc_meta_app a on a.id = v.app_id and a.tenant_id = v.tenant_id and a.deleted = 0 and a.delete_token = 0 where v.tenant_id = ? and a.code = ? and v.version_no = ? and v.publish_status = 'PUBLISHED' and v.deleted = 0 and v.delete_token = 0";
  private static final String FIND_CURRENT_SQL = "select v.version_no from lc_meta_version v join lc_meta_app a on a.id = v.app_id and a.tenant_id = v.tenant_id and a.deleted = 0 and a.delete_token = 0 where v.tenant_id = ? and a.code = ? and v.publish_status = 'PUBLISHED' and v.published_at is not null and v.deleted = 0 and v.delete_token = 0 order by v.published_at desc, v.id desc limit 1";

  private final MetaJdbcExecutor executor;
  private final ObjectMapper objectMapper;

  public JdbcMetaVersionRepository(MetaJdbcExecutor executor) {
    this(executor, new ObjectMapper());
  }

  JdbcMetaVersionRepository(MetaJdbcExecutor executor, ObjectMapper objectMapper) {
    this.executor = executor;
    this.objectMapper = objectMapper;
  }

  @Override
  public Optional<AppSnapshotDef> find(Long tenantId, String appCode, String metaVersion) {
    return executor.query(FIND_SNAPSHOT_SQL, List.of(tenantId, appCode, metaVersion)).stream()
        .findFirst()
        .map(row -> readSnapshot(row.get("snapshot")));
  }

  @Override
  public Optional<String> findCurrentVersion(Long tenantId, String appCode) {
    return executor.query(FIND_CURRENT_SQL, List.of(tenantId, appCode)).stream()
        .findFirst()
        .map(row -> String.valueOf(row.get("version_no")));
  }

  private AppSnapshotDef readSnapshot(Object rawSnapshot) {
    try {
      return objectMapper.readValue(String.valueOf(rawSnapshot), AppSnapshotDef.class);
    } catch (JsonProcessingException ex) {
      throw new MetaGraphLoadException("已发布元数据快照 JSON 无法解析", ex);
    }
  }
}
