package com.lowcode.app.api;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.common.error.BizException;
import com.lowcode.metamodel.domain.graph.JdbcMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaJdbcExecutor;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaVersionPointer;
import com.lowcode.metamodel.domain.graph.MetaVersionRepository;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.plugin.service.PackageMarketplaceService;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.RuntimeJdbcExecutor;
import com.lowcode.workflow.service.WorkflowHttpService;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.runner.ApplicationContextRunner;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockHttpServletRequest;

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
  void shouldFailFastWhenWorkflowHttpServiceIsCreatedWithoutExplicitDemoFlag() {
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
  void shouldStartWithoutRuntimeOrMetaStoresAndFailClosedOnRuntimeCalls() {
    new ApplicationContextRunner()
        .withBean(RuntimeApiHttpFacade.class)
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).hasSingleBean(RuntimeApiHttpFacade.class);
          assertThat(context).doesNotHaveBean(RuntimeApiFacade.class);
          assertThat(context).doesNotHaveBean(MetaVersionRepository.class);
          assertThat(context).doesNotHaveBean(InMemoryRuntimeHttpFacade.class);

          assertThatThrownBy(() -> context.getBean(RuntimeApiHttpFacade.class).meta(authenticatedContext()))
              .isInstanceOf(BizException.class)
              .hasMessageContaining("运行时服务未启用");
        });
  }

  @Test
  void shouldCreateInMemoryRuntimeHttpFacadeOnlyWhenRuntimeDemoIsExplicitlyEnabled() {
    new ApplicationContextRunner()
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .run(context -> assertThat(context).doesNotHaveBean(InMemoryRuntimeHttpFacade.class));

    new ApplicationContextRunner()
        .withPropertyValues("lowcode.app.runtime.demo-enabled=true")
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .run(context -> assertThat(context).hasSingleBean(InMemoryRuntimeHttpFacade.class));
  }

  @Test
  void shouldWireRuntimeDataControllerToFailClosedRuntimeFacadeByDefault() {
    new ApplicationContextRunner()
        .withBean(AuthenticatedRuntimeContextResolver.class, () -> new AuthenticatedRuntimeContextResolver("test-gateway-secret"))
        .withBean(ApiErrorResponseFactory.class)
        .withBean(RuntimeApiHttpFacade.class)
        .withBean(RuntimeDataController.class)
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).hasSingleBean(RuntimeHttpFacade.class);
          assertThat(context.getBean(RuntimeHttpFacade.class)).isInstanceOf(RuntimeApiHttpFacade.class);
          assertThat(context).doesNotHaveBean(InMemoryRuntimeHttpFacade.class);

          assertThatThrownBy(() -> context.getBean(RuntimeDataController.class)
              .meta("sales", "order", signedRuntimeRequest()))
              .isInstanceOf(BizException.class)
              .hasMessageContaining("运行时服务未启用");
        });
  }

  @Test
  void shouldWireRuntimeDataControllerToExplicitDemoRuntimeWhenRuntimeDemoIsEnabled() {
    new ApplicationContextRunner()
        .withPropertyValues("lowcode.app.runtime.demo-enabled=true")
        .withBean(AuthenticatedRuntimeContextResolver.class, () -> new AuthenticatedRuntimeContextResolver("test-gateway-secret"))
        .withBean(ApiErrorResponseFactory.class)
        .withBean(RuntimeApiHttpFacade.class)
        .withBean(RuntimeDataController.class)
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .withUserConfiguration(PublishedRuntimeObjectRegistry.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).hasSingleBean(RuntimeApiFacade.class);
          assertThat(context).doesNotHaveBean(com.lowcode.metamodel.domain.graph.MetaGraphProvider.class);
          assertThat(context).doesNotHaveBean(PublishedRuntimeObjectRegistry.class);

          Object response = context.getBean(RuntimeDataController.class)
              .meta("sales", "order", signedRuntimeRequest());

          assertThat(response).isInstanceOf(RuntimeObjectMetaResponse.class);
          RuntimeObjectMetaResponse meta = (RuntimeObjectMetaResponse) response;
          assertThat(meta.objectCode()).isEqualTo("order");
          assertThat(meta.fields()).contains("amount", "remark");
        });
  }

  @Test
  void shouldKeepExplicitRuntimeDemoIndependentFromPublishedRegistryWhenJdbcTemplateExists() {
    new ApplicationContextRunner()
        .withPropertyValues("lowcode.app.runtime.demo-enabled=true")
        .withBean(JdbcTemplate.class, RecordingJdbcTemplate::new)
        .withBean(AuthenticatedRuntimeContextResolver.class, () -> new AuthenticatedRuntimeContextResolver("test-gateway-secret"))
        .withBean(ApiErrorResponseFactory.class)
        .withBean(RuntimeApiHttpFacade.class)
        .withBean(RuntimeDataController.class)
        .withUserConfiguration(InMemoryRuntimeHttpFacade.class)
        .withUserConfiguration(PublishedRuntimeObjectRegistry.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).hasSingleBean(RuntimeApiFacade.class);
          assertThat(context).hasSingleBean(MetaVersionRepository.class);
          assertThat(context).doesNotHaveBean(com.lowcode.metamodel.domain.graph.MetaGraphProvider.class);
          assertThat(context).doesNotHaveBean(PublishedRuntimeObjectRegistry.class);

          Object response = context.getBean(RuntimeDataController.class)
              .meta("sales", "order", signedRuntimeRequest());

          assertThat(response).isInstanceOf(RuntimeObjectMetaResponse.class);
          RuntimeObjectMetaResponse meta = (RuntimeObjectMetaResponse) response;
          assertThat(meta.objectCode()).isEqualTo("order");
          assertThat(meta.fields()).contains("amount", "remark");
        });
  }

  @Test
  void shouldMapFeatureDisabledBizExceptionToForbidden() {
    ApiErrorResponse response = new ApiErrorResponseFactory().fromBizException(
        new BizException(com.lowcode.common.error.ErrorCode.FEATURE_DISABLED, "运行时服务未启用"),
        signedRuntimeRequest());

    assertThat(response.status()).isEqualTo(HttpStatus.FORBIDDEN);
    assertThat(response.body().code()).isEqualTo("LC-COMM-0403");
  }

  @Test
  void shouldNotCreateWorkflowDemoBeanByDefault() {
    new ApplicationContextRunner()
        .withBean(RuntimeJdbcExecutor.class, () -> new RuntimeJdbcExecutor() {
          @Override
          public int update(String sql, List<Object> parameters) {
            return 1;
          }

          @Override
          public List<Map<String, Object>> query(String sql, List<Object> parameters) {
            return List.of();
          }
        })
        .withBean(MetaJdbcExecutor.class, () -> (sql, parameters) -> List.of())
        .withBean(WorkflowHttpFacade.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).doesNotHaveBean(WorkflowHttpService.class);
          assertThat(context).hasSingleBean(WorkflowHttpFacade.class);
        });
  }

  @Test
  void shouldFailClosedWhenWorkflowFacadeIsCalledWithoutWorkflowService() {
    new ApplicationContextRunner()
        .withBean(RuntimeJdbcExecutor.class, () -> new RuntimeJdbcExecutor() {
          @Override
          public int update(String sql, List<Object> parameters) {
            return 1;
          }

          @Override
          public List<Map<String, Object>> query(String sql, List<Object> parameters) {
            return List.of();
          }
        })
        .withBean(MetaJdbcExecutor.class, () -> (sql, parameters) -> List.of())
        .withBean(WorkflowHttpFacade.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> assertThatThrownBy(() ->
            context.getBean(WorkflowHttpFacade.class)
                .start(authenticatedContext(), "approval", new WorkflowStartRequest(null, "rec-1", null, null)))
            .isInstanceOf(BizException.class)
            .hasMessageContaining("工作流服务未启用"));
  }

  @Test
  void shouldNotCreatePackageMarketplaceDemoServiceByDefault() {
    new ApplicationContextRunner()
        .withBean(RuntimeJdbcExecutor.class, () -> new RuntimeJdbcExecutor() {
          @Override
          public int update(String sql, List<Object> parameters) {
            return 1;
          }

          @Override
          public List<Map<String, Object>> query(String sql, List<Object> parameters) {
            return List.of();
          }
        })
        .withBean(MetaJdbcExecutor.class, () -> (sql, parameters) -> List.of())
        .withBean(PackageMarketplaceHttpFacade.class)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).doesNotHaveBean(PackageMarketplaceService.class);
          assertThat(context).hasSingleBean(PackageMarketplaceHttpFacade.class);
          assertThatThrownBy(() ->
              context.getBean(PackageMarketplaceHttpFacade.class).list(authenticatedContext()))
              .isInstanceOf(BizException.class)
              .hasMessageContaining("包市场服务未启用");
        });
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
  void shouldCreateMetaVersionRepositoryWhenJdbcTemplateCreatesMetaJdbcExecutor() {
    new ApplicationContextRunner()
        .withBean(JdbcTemplate.class, RecordingJdbcTemplate::new)
        .withUserConfiguration(RuntimeApiConfiguration.class)
        .run(context -> {
          assertThat(context).hasSingleBean(MetaJdbcExecutor.class);
          assertThat(context).hasSingleBean(MetaVersionRepository.class);
        });
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
    public void afterPropertiesSet() {
      // Test fixture: no real DataSource is needed for configuration wiring assertions.
    }

    @Override
    public int update(String sql, Object... args) {
      updates.add(args);
      return 1;
    }
  }

  private static AuthenticatedRuntimeContext authenticatedContext() {
    return new AuthenticatedRuntimeContext(
        3L,
        7L,
        "user-1",
        Set.of("manager"),
        "trace-1",
        "sales",
        "order",
        "mh-1");
  }

  private static MockHttpServletRequest signedRuntimeRequest() {
    MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/data/sales/order/meta");
    request.addHeader("X-Tenant-Id", "3");
    request.addHeader("X-Workspace-Id", "7");
    request.addHeader("X-User-Lid", "user-1");
    request.addHeader("X-Role-Codes", "manager");
    request.addHeader("X-Meta-Hash", "mh-1");
    request.addHeader("X-Trace-Id", "trace-1");
    String timestamp = String.valueOf(System.currentTimeMillis());
    request.addHeader("X-Gateway-Timestamp", timestamp);
    request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp)));
    return request;
  }

  private static String canonicalPayload(MockHttpServletRequest request, String timestamp) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        header(request, "X-Meta-Hash").isBlank() ? "mh-1" : header(request, "X-Meta-Hash"));
  }

  private static String hmac(String payload) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec("test-gateway-secret".getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
      return HexFormat.of().formatHex(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception ex) {
      throw new IllegalStateException(ex);
    }
  }

  private static String header(MockHttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }
}
