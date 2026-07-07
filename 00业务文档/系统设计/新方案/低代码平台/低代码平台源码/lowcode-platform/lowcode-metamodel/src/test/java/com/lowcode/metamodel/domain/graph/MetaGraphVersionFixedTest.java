package com.lowcode.metamodel.domain.graph;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.List;
import org.junit.jupiter.api.Test;

class MetaGraphVersionFixedTest {

  @Test
  void requestContext_创建后固定metaGraph_后续latest变化不影响当前请求() {
    InMemoryMetaVersionRepository repository = new InMemoryMetaVersionRepository();
    repository.save(MetaGraphBuilderTest.snapshot("sales", "v1", List.of()));
    repository.save(MetaGraphBuilderTest.snapshot("sales", "v2", List.of()));
    InMemoryMetaVersionPointer pointer = new InMemoryMetaVersionPointer();
    pointer.setCurrent(1L, "sales", "v1");
    MetaGraphProvider provider = new MetaGraphProvider(repository, pointer, new MetaGraphBuilder(), 3);
    RequestRuntimeContext context = RequestRuntimeContext.open(1L, "u001", provider.requireLatestPublished(1L, "sales"), "trace-001");

    pointer.setCurrent(1L, "sales", "v2");
    MetaGraph latest = provider.requireLatestPublished(1L, "sales");

    assertThat(latest.metaVersion()).isEqualTo("v2");
    assertThat(context.metaGraph().metaVersion()).isEqualTo("v1");
    assertThat(context.metaHash()).isEqualTo("v1");
  }

  @Test
  void assertRequestMetaHash_请求版本过旧_拒绝写入() {
    RequestRuntimeContext context =
        RequestRuntimeContext.open(1L, "u001", new MetaGraphBuilder().build(MetaGraphBuilderTest.snapshot("sales", "v2", List.of())), "trace-001");

    assertThatThrownBy(() -> context.assertRequestMetaHash("v1"))
        .isInstanceOf(MetaVersionStaleException.class)
        .hasMessageContaining("元数据版本已过期");
  }
}
