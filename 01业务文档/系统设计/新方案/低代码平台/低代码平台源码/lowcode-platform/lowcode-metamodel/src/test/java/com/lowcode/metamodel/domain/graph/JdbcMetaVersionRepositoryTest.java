package com.lowcode.metamodel.domain.graph;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class JdbcMetaVersionRepositoryTest {

  @Test
  void shouldLoadPublishedSnapshotAndCurrentVersionByTenantAndAppCode() {
    RecordingMetaJdbcExecutor executor = new RecordingMetaJdbcExecutor();
    executor.nextQueryRows(List.of(Map.of("snapshot", """
        {"_v":1,"tenantId":3,"appCode":"sales","versionNo":"mh-1","objects":[],"pages":[],"roles":[],"datasources":[],"plugins":[],"commercial":{"_v":1}}
        """)));
    executor.nextQueryRows(List.of(Map.of("version_no", "mh-1")));
    JdbcMetaVersionRepository repository = new JdbcMetaVersionRepository(executor);

    assertThat(repository.find(3L, "sales", "mh-1")).hasValueSatisfying(snapshot -> {
      assertThat(snapshot.tenantId()).isEqualTo(3L);
      assertThat(snapshot.appCode()).isEqualTo("sales");
      assertThat(snapshot.versionNo()).isEqualTo("mh-1");
    });
    assertThat(repository.findCurrentVersion(3L, "sales")).contains("mh-1");
    assertThat(executor.sqlHistory()).containsExactly(
        "select v.snapshot from lc_meta_version v join lc_meta_app a on a.id = v.app_id and a.tenant_id = v.tenant_id and a.deleted = 0 and a.delete_token = 0 where v.tenant_id = ? and a.code = ? and v.version_no = ? and v.publish_status = 'PUBLISHED' and v.deleted = 0 and v.delete_token = 0",
        "select v.version_no from lc_meta_version v join lc_meta_app a on a.id = v.app_id and a.tenant_id = v.tenant_id and a.deleted = 0 and a.delete_token = 0 where v.tenant_id = ? and a.code = ? and v.publish_status = 'PUBLISHED' and v.published_at is not null and v.deleted = 0 and v.delete_token = 0 order by v.published_at desc, v.id desc limit 1");
  }

  private static final class RecordingMetaJdbcExecutor implements MetaJdbcExecutor {

    private final List<String> sqlHistory = new ArrayList<>();
    private final List<List<Object>> parametersHistory = new ArrayList<>();
    private final List<List<Map<String, Object>>> queryRows = new ArrayList<>();

    @Override
    public List<Map<String, Object>> query(String sql, List<Object> parameters) {
      sqlHistory.add(sql);
      parametersHistory.add(List.copyOf(parameters));
      if (queryRows.isEmpty()) {
        return List.of();
      }
      return queryRows.remove(0);
    }

    void nextQueryRows(List<Map<String, Object>> rows) {
      queryRows.add(rows.stream().map(LinkedHashMap::new).map(row -> (Map<String, Object>) row).toList());
    }

    List<String> sqlHistory() {
      return List.copyOf(sqlHistory);
    }
  }
}
