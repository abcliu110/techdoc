package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class JdbcRuntimeSideEffectRepositoryTest {

  @Test
  void shouldPersistIdempotencyAuditOutboxAndTransitionWithTenantGuard() {
    RecordingJdbcExecutor executor = new RecordingJdbcExecutor();
    RuntimeSideEffectRepository repository = new JdbcRuntimeSideEffectRepository(executor);
    RuntimeExecutionContext context = context(1L);

    RuntimeIdempotencyEntry missing = repository.findIdempotency(context, "add", "idem-1");
    repository.saveIdempotency(context, new RuntimeIdempotencyEntry("add", "idem-1", "01ABCDEFGHABCDEFGHABCDEFGH", "draft", "approved", 1L));
    repository.appendAudit(context, new AuditLog("create", "trace-1", "mh-1", 7L));
    repository.appendOutbox(context, new OutboxEvent("record.created", "01ABCDEFGHABCDEFGHABCDEFGH", "trace-1"));
    repository.appendTransition(context, new TransitionLog("01ABCDEFGHABCDEFGHABCDEFGH", "draft", "approved", "trace-1"));

    assertThat(missing).isNull();
    assertThat(executor.sqlHistory()).containsExactly(
        "select operation, idempotency_key, record_lid, from_state, to_state, revision from lc_rt_idempotency where tenant_id = ? and workspace_id = ? and app_code = ? and object_code = ? and operation = ? and idempotency_key = ?",
        "insert into lc_rt_idempotency (tenant_id, workspace_id, app_code, object_code, operation, idempotency_key, record_lid, from_state, to_state, revision, trace_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        "insert into lc_rt_audit_log (tenant_id, app_code, object_code, operation, trace_id, meta_hash, perm_version) values (?, ?, ?, ?, ?, ?, ?)",
        "insert into lc_rt_outbox (tenant_id, app_code, object_code, event_type, record_lid, trace_id) values (?, ?, ?, ?, ?, ?)",
        "insert into lc_rt_transition_log (tenant_id, app_code, object_code, record_lid, from_state, to_state, trace_id) values (?, ?, ?, ?, ?, ?, ?)");
    assertThat(executor.parametersHistory().get(1)).containsExactly(
        1L,
        1L,
        "sales",
        "order",
        "add",
        "idem-1",
        "01ABCDEFGHABCDEFGHABCDEFGH",
        "draft",
        "approved",
        1L,
        "trace-1");
  }

  @Test
  void shouldReplayPersistedIdempotencyEntryWithoutBusinessWrite() {
    RecordingJdbcExecutor executor = new RecordingJdbcExecutor();
    executor.nextQueryRows(List.of(Map.of(
        "operation", "add",
        "idempotency_key", "idem-1",
        "record_lid", "01ABCDEFGHABCDEFGHABCDEFGH",
        "from_state", "",
        "to_state", "",
        "revision", 1L)));
    RuntimeSideEffectRepository repository = new JdbcRuntimeSideEffectRepository(executor);

    RuntimeIdempotencyEntry replay = repository.findIdempotency(context(1L), "add", "idem-1");

    assertThat(replay.recordLid()).isEqualTo("01ABCDEFGHABCDEFGHABCDEFGH");
    assertThat(replay.revision()).isEqualTo(1L);
    assertThat(executor.sqlHistory()).containsExactly(
        "select operation, idempotency_key, record_lid, from_state, to_state, revision from lc_rt_idempotency where tenant_id = ? and workspace_id = ? and app_code = ? and object_code = ? and operation = ? and idempotency_key = ?");
  }

  private static RuntimeExecutionContext context(Long tenantId) {
    return new RuntimeExecutionContext(tenantId, 1L, "u1", java.util.Set.of("manager"), "sales", "order", "mh-1", "trace-1");
  }
}
