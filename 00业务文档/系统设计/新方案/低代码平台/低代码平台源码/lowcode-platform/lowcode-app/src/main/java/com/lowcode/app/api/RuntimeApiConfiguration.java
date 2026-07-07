package com.lowcode.app.api;

import com.lowcode.metamodel.domain.graph.JdbcMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaJdbcExecutor;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaGraphProvider;
import com.lowcode.metamodel.domain.graph.MetaVersionPointer;
import com.lowcode.metamodel.domain.graph.MetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaVersionStorageFactory;
import com.lowcode.designer.service.PublishSnapshotSink;
import com.lowcode.plugin.service.PackageMarketplaceService;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.JdbcDynamicRecordRepository;
import com.lowcode.runtime.data.JdbcRuntimeSideEffectRepository;
import com.lowcode.runtime.data.RuntimeJdbcExecutor;
import com.lowcode.workflow.service.WorkflowDemoFactory;
import com.lowcode.workflow.service.WorkflowHttpService;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Runtime API wiring for the application HTTP layer.
 */
@Configuration
class RuntimeApiConfiguration {

  @Bean
  RuntimeApiFacade runtimeApiFacadeBean(
      Optional<RuntimeJdbcExecutor> jdbcExecutor,
      @Value("${lowcode.app.runtime.demo-enabled:false}") boolean demoEnabled) {
    return runtimeApiFacade(jdbcExecutor, demoEnabled);
  }

  RuntimeApiFacade runtimeApiFacade(Optional<RuntimeJdbcExecutor> jdbcExecutor, boolean demoEnabled) {
    return jdbcExecutor
        .map(this::runtimeApiFacade)
        .orElseGet(() -> {
          if (!demoEnabled) {
            throw new IllegalStateException("Runtime demo fallback requires lowcode.app.runtime.demo-enabled=true");
          }
          return new RuntimeApiFacade();
        });
  }

  RuntimeApiFacade runtimeApiFacade(Optional<RuntimeJdbcExecutor> jdbcExecutor) {
    return runtimeApiFacade(jdbcExecutor, false);
  }

  RuntimeApiFacade runtimeApiFacade(RuntimeJdbcExecutor jdbcExecutor) {
    return new RuntimeApiFacade(
        ignored -> new JdbcDynamicRecordRepository(jdbcExecutor),
        ignored -> new JdbcRuntimeSideEffectRepository(jdbcExecutor));
  }

  @Bean
  MetaVersionRepository metaVersionRepositoryBean(
      Optional<MetaJdbcExecutor> jdbcExecutor,
      @Value("${lowcode.app.runtime.demo-enabled:false}") boolean demoEnabled) {
    return metaVersionRepository(jdbcExecutor, demoEnabled);
  }

  MetaVersionRepository metaVersionRepository(Optional<MetaJdbcExecutor> jdbcExecutor, boolean demoEnabled) {
    if (jdbcExecutor.isPresent()) {
      return new JdbcMetaVersionRepository(jdbcExecutor.get());
    }
    if (!demoEnabled) {
      throw new IllegalStateException("Meta version demo fallback requires lowcode.app.runtime.demo-enabled=true");
    }
    return MetaVersionStorageFactory.inMemoryRepository();
  }

  MetaVersionRepository metaVersionRepository(Optional<MetaJdbcExecutor> jdbcExecutor) {
    return metaVersionRepository(jdbcExecutor, false);
  }

  @Bean
  @ConditionalOnBean(JdbcTemplate.class)
  MetaJdbcExecutor metaJdbcExecutor(JdbcTemplate jdbcTemplate) {
    return (sql, parameters) -> jdbcTemplate.queryForList(sql, parameters.toArray());
  }

  @Bean
  PublishSnapshotSink publishSnapshotSink(Optional<JdbcTemplate> jdbcTemplate) {
    return jdbcTemplate
        .<PublishSnapshotSink>map(JdbcPublishSnapshotSink::new)
        .orElseGet(PublishSnapshotSink::noop);
  }

  @Bean
  MetaVersionPointer metaVersionPointerBean(
      @Value("${lowcode.app.runtime.demo-enabled:false}") boolean demoEnabled) {
    return metaVersionPointer(demoEnabled);
  }

  MetaVersionPointer metaVersionPointer(boolean demoEnabled) {
    if (demoEnabled) {
      return MetaVersionStorageFactory.inMemoryPointer();
    }
    return (tenantId, appCode) -> Optional.empty();
  }

  MetaVersionPointer metaVersionPointer() {
    return metaVersionPointer(false);
  }

  @Bean
  MetaGraphProvider metaGraphProvider(MetaVersionRepository repository, MetaVersionPointer pointer) {
    return new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 16);
  }

  @Bean
  PackageMarketplaceService.PackageCapabilityContextProvider packageCapabilityContextProvider(
      Optional<PackageCapabilityContextSource> capabilityContextSource) {
    return capabilityContextSource
        .<PackageMarketplaceService.PackageCapabilityContextProvider>map(source -> source::resolve)
        .orElse(tenantId -> PackageManifestHttpFacade.failClosedCapabilityContext());
  }

  @Bean
  PackageMarketplaceService packageMarketplaceService(
      PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider) {
    return new PackageMarketplaceService(capabilityContextProvider);
  }

  @Bean
  WorkflowHttpService workflowHttpServiceBean(
      @Value("${lowcode.app.workflow.demo-enabled:false}") boolean demoEnabled) {
    return workflowHttpService(demoEnabled);
  }

  WorkflowHttpService workflowHttpService(boolean demoEnabled) {
    if (!demoEnabled) {
      throw new IllegalStateException("Workflow demo fallback requires lowcode.app.workflow.demo-enabled=true");
    }
    return WorkflowDemoFactory.createHttpService();
  }

  WorkflowHttpService workflowHttpService() {
    return workflowHttpService(false);
  }
}
