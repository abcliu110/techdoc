package com.lowcode.app.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.metamodel.domain.graph.JdbcMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaJdbcExecutor;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaVersionPointer;
import com.lowcode.metamodel.domain.graph.MetaVersionRepository;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.plugin.service.PackageMarketplaceService;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.RuntimeJdbcExecutor;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
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
  void shouldFailFastWhenRuntimeApiFacadeFallsBackToImplicitInMemoryDefaults() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    assertThatThrownBy(() -> configuration.runtimeApiFacade(Optional.empty()))
        .isInstanceOf(IllegalStateException.class)
        .hasMessageContaining("lowcode.app.runtime.demo-enabled");
  }

  @Test
  void shouldFailFastWhenMetaVersionRepositoryFallsBackToImplicitInMemoryDefaults() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    assertThatThrownBy(() -> configuration.metaVersionRepository(Optional.empty()))
        .isInstanceOf(IllegalStateException.class)
        .hasMessageContaining("lowcode.app.runtime.demo-enabled");
  }

  @Test
  void shouldFailFastWhenWorkflowHttpServiceFallsBackToImplicitInMemoryDefaults() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    assertThatThrownBy(() -> configuration.workflowHttpService())
        .isInstanceOf(IllegalStateException.class)
        .hasMessageContaining("lowcode.app.workflow.demo-enabled");
  }

  @Test
  void shouldCreateDbPollingMetaVersionPointerWithoutDemoStorage() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    MetaVersionPointer pointer = configuration.metaVersionPointer();

    assertThat(pointer.findCurrent(3L, "sales")).isEmpty();
  }

  @Test
  void shouldCreateDemoFallbacksOnlyWhenExplicitlyEnabled() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    assertThat(configuration.runtimeApiFacade(Optional.empty(), true)).isNotNull();
    assertThat(configuration.metaVersionRepository(Optional.empty(), true)).isNotNull();
    assertThat(configuration.metaVersionPointer(true).findCurrent(3L, "sales")).isEmpty();
    assertThat(configuration.workflowHttpService(true)).isNotNull();
  }

  @Test
  void shouldWirePackageMarketplaceServiceWithTrustedCapabilityProvider() {
    RuntimeApiConfiguration configuration = new RuntimeApiConfiguration();

    PackageMarketplaceService.PackageCapabilityContextProvider provider =
        tenantId -> new PackageManifestValidationContext(
            Map.of(),
            Set.of("customer"),
            Set.of(),
            Set.of(),
            Set.of(),
            Set.of("customer:read"),
            "1.1.0",
            "M4",
            Set.of("commercial"),
            true);
    PackageMarketplaceService service =
        configuration.packageMarketplaceService(provider);

    PackageMarketplaceService.PackageInstallResult result =
        service.install(
            "3",
            "operator",
            "trace-1",
            new com.lowcode.metamodel.domain.def.PackageManifestDef(
                "customer_pkg",
                "1.0.0",
                List.of(),
                "commercial",
                List.of("customer"),
                List.of(),
                List.of(),
                List.of(),
                List.of("customer:read"),
                new com.lowcode.metamodel.domain.def.PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
                true),
            null);

    assertThat(result.installed()).isTrue();
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
