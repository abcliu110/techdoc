package com.lowcode.app.api;

import com.lowcode.metamodel.domain.graph.InMemoryMetaVersionPointer;
import com.lowcode.metamodel.domain.graph.InMemoryMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.JdbcMetaVersionRepository;
import com.lowcode.metamodel.domain.graph.MetaJdbcExecutor;
import com.lowcode.metamodel.domain.graph.MetaGraphBuilder;
import com.lowcode.metamodel.domain.graph.MetaGraphProvider;
import com.lowcode.metamodel.domain.graph.MetaVersionPointer;
import com.lowcode.metamodel.domain.graph.MetaVersionRepository;
import com.lowcode.designer.service.PublishSnapshotSink;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.JdbcDynamicRecordRepository;
import com.lowcode.runtime.data.JdbcRuntimeSideEffectRepository;
import com.lowcode.runtime.data.RuntimeJdbcExecutor;
import com.lowcode.workflow.service.WorkflowHttpService;
import java.util.Optional;
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
  RuntimeApiFacade runtimeApiFacade(Optional<RuntimeJdbcExecutor> jdbcExecutor) {
    return jdbcExecutor
        .map(this::runtimeApiFacade)
        .orElseGet(RuntimeApiFacade::new);
  }

  RuntimeApiFacade runtimeApiFacade(RuntimeJdbcExecutor jdbcExecutor) {
    return new RuntimeApiFacade(
        ignored -> new JdbcDynamicRecordRepository(jdbcExecutor),
        ignored -> new JdbcRuntimeSideEffectRepository(jdbcExecutor));
  }

  @Bean
  MetaVersionRepository metaVersionRepository(Optional<MetaJdbcExecutor> jdbcExecutor) {
    if (jdbcExecutor.isPresent()) {
      return new JdbcMetaVersionRepository(jdbcExecutor.get());
    }
    return new InMemoryMetaVersionRepository();
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
  MetaVersionPointer metaVersionPointer() {
    return new InMemoryMetaVersionPointer();
  }

  @Bean
  MetaGraphProvider metaGraphProvider(MetaVersionRepository repository, MetaVersionPointer pointer) {
    return new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 16);
  }

  @Bean
  WorkflowHttpService workflowHttpService() {
    return new WorkflowHttpService();
  }
}
