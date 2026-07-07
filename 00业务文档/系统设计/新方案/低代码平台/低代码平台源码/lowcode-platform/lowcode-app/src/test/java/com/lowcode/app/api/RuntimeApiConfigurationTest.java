package com.lowcode.app.api;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.graph.JdbcMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaJdbcExecutor;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaVersionRepository;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.RuntimeJdbcExecutor;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

class RuntimeApiConfigurationTest {

  @Test
  void shouldCreateRuntimeApiFacadeBackedByJdbcExecutorWhenExecutorExists() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();
    RuntimeJdbcExecutor executor = new RuntimeJdbcExecutor() {
      @Override
      public int update(String sql, List<Object> parameters) {
        return 1;
      }

      @Override
      public List<Map<String, Object>> query(String sql, List<Object> parameters) {
        return List.of();
      }
    };

    RuntimeApiFacade facade = configuration.runtimeApiFacade(executor);

    assertThat(facade).isNotNull();
  }

  @Test
  void shouldCreateMetaVersionRepositoryBackedByJdbcExecutorWhenExecutorExists() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();
    MetaJdbcExecutor executor = (sql, parameters) -> List.of();

    MetaVersionRepository repository = configuration.metaVersionRepository(Optional.of(executor));

    assertThat(repository).isInstanceOf(JdbcMetaVersionRepository.class);
  }

  @Test
  void shouldCreateMetaJdbcExecutorFromJdbcTemplate() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();
    JdbcTemplate jdbcTemplate = new JdbcTemplate();

    MetaJdbcExecutor executor = configuration.metaJdbcExecutor(jdbcTemplate);

    assertThat(executor).isNotNull();
  }

  @Test
  void shouldSerializePublishedDesignerSnapshotAsMetaGraphSnapshot() throws Exception {
    RecordingJdbcTemplate jdbcTemplate = new RecordingJdbcTemplate();
    JdbcPublishSnapshotSink sink = new JdbcPublishSnapshotSink(jdbcTemplate);
    com.lowcode.designer.service.DesignerDraftFacade facade = new com.lowcode.designer.service.DesignerDraftFacade(sink);
    facade.add(3L, "sales", "invoice", "Invoice", null, List.of(new com.lowcode.designer.service.FieldDraft("title", "Title", "text", false)));

    facade.publish(3L, "sales", "invoice", 1L);

    String snapshotJson = String.valueOf(jdbcTemplate.updates.get(2)[4]);
    com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
    com.lowcode.metamodel.domain.def.AppSnapshotDef snapshot =
        mapper.readValue(snapshotJson, com.lowcode.metamodel.domain.def.AppSnapshotDef.class);
    assertThat(new MetaGraphBuilder().build(snapshot).object("invoice").code()).isEqualTo("invoice");
  }

  private static final class RecordingJdbcTemplate extends JdbcTemplate {
    private final List<Object[]> updates = new ArrayList<>();

    @Override
    public List<Map<String, Object>> queryForList(String sql, Object... args) {
      return List.of();
    }

    @Override
    public int update(String sql, Object... args) {
      updates.add(args);
      return 1;
    }
  }
}
