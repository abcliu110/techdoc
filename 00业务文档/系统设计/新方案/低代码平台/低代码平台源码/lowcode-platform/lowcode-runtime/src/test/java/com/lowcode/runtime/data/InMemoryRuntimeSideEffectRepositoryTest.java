package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import org.junit.jupiter.api.Test;

class InMemoryRuntimeSideEffectRepositoryTest {

  @Test
  void shouldScopeIdempotencyEntriesByWorkspace() {
    InMemoryRuntimeSideEffectRepository repository = new InMemoryRuntimeSideEffectRepository();
    RuntimeExecutionContext workspace1 = context(1L, 1L);
    RuntimeExecutionContext workspace2 = context(1L, 2L);
    RuntimeIdempotencyEntry workspace1Entry =
        new RuntimeIdempotencyEntry("add", "idem-1", "01AAAAAAAAAAAAAAAAAAAAAAAA", null, null, 1L);
    RuntimeIdempotencyEntry workspace2Entry =
        new RuntimeIdempotencyEntry("add", "idem-1", "01BBBBBBBBBBBBBBBBBBBBBBBB", null, null, 2L);

    repository.saveIdempotency(workspace1, workspace1Entry);
    repository.saveIdempotency(workspace2, workspace2Entry);

    assertThat(repository.findIdempotency(workspace1, "add", "idem-1")).isEqualTo(workspace1Entry);
    assertThat(repository.findIdempotency(workspace2, "add", "idem-1")).isEqualTo(workspace2Entry);
  }

  private static RuntimeExecutionContext context(Long tenantId, Long workspaceId) {
    return new RuntimeExecutionContext(
        tenantId,
        workspaceId,
        "user-1",
        Set.of("manager"),
        "sales",
        "order",
        "mh-1",
        "trace-1");
  }
}
