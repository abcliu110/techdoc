package com.lowcode.metamodel.domain.graph;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import java.util.List;
import org.junit.jupiter.api.Test;

class MetaGraphProviderTest {

  @Test
  void requirePublished_同应用不同版本_本地缓存按版本隔离() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    repository.save(MetaGraphBuilderTest.snapshot("sales", "v1", List.of()));
    repository.save(MetaGraphBuilderTest.snapshot("sales", "v2", List.of()));
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    pointer.setCurrent(1L, "sales", "v2");
    MetaGraphProvider provider = new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3);

    MetaGraph v1 = provider.requirePublished(1L, "sales", "v1");
    MetaGraph v2 = provider.requireLatestPublished(1L, "sales");

    assertThat(v1.metaVersion()).isEqualTo("v1");
    assertThat(v2.metaVersion()).isEqualTo("v2");
    assertThat(provider.findCached(1L, "sales", "v1")).containsSame(v1);
  }

  @Test
  void refreshLatest_redis版本键缺失_通过仓储当前版本轮询收敛() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    AppSnapshotDef v1 = MetaGraphBuilderTest.snapshot("sales", "v1", List.of());
    AppSnapshotDef v2 = MetaGraphBuilderTest.snapshot("sales", "v2", List.of());
    repository.save(v1);
    repository.save(v2);
    repository.setCurrent(1L, "sales", "v2");
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    pointer.setUnavailable(true);
    MetaGraphProvider provider = new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3);

    MetaGraph graph = provider.refreshLatest(1L, "sales");

    assertThat(graph.metaVersion()).isEqualTo("v2");
    assertThat(provider.degradedReadOnly()).isTrue();
    assertThatThrownBy(provider::assertWritable).isInstanceOf(MetaGraphReadOnlyException.class);
  }

  @Test
  void evict_清理指定应用本地缓存() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    repository.save(MetaGraphBuilderTest.snapshot("sales", "v1", List.of()));
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    pointer.setCurrent(1L, "sales", "v1");
    MetaGraphProvider provider = new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3);
    provider.requirePublished(1L, "sales", "v1");

    provider.evict(1L, "sales");

    assertThat(provider.findCached(1L, "sales", "v1")).isEmpty();
  }
}
