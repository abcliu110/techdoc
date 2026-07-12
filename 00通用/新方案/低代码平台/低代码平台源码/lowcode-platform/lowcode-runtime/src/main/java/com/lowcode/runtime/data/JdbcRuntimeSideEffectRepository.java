package com.lowcode.runtime.data;

import java.util.List;
import java.util.Map;

/**
 * JDBC/MySQL 副作用仓储。
 *
 * <p>SECURITY: 表名和列名全部固定在平台代码中，请求数据只能进入参数列表；每条副作用记录都携带 tenant/app/object 上下文。
 */
public class JdbcRuntimeSideEffectRepository implements RuntimeSideEffectRepository {

  private final RuntimeJdbcExecutor executor;

  public JdbcRuntimeSideEffectRepository(RuntimeJdbcExecutor executor) {
    this.executor = executor;
  }

  @Override
  public RuntimeIdempotencyEntry findIdempotency(RuntimeExecutionContext context, String operation, String idempotencyKey) {
    requireTenant(context);
    List<Map<String, Object>> rows = executor.query(
        "select operation, idempotency_key, record_lid, from_state, to_state, revision from lc_rt_idempotency where tenant_id = ? and workspace_id = ? and app_code = ? and object_code = ? and operation = ? and idempotency_key = ?",
        List.of(context.tenantId(), context.workspaceId(), context.appCode(), context.objectCode(), operation, idempotencyKey));
    if (rows.isEmpty()) {
      return null;
    }
    Map<String, Object> row = rows.getFirst();
    return new RuntimeIdempotencyEntry(
        String.valueOf(row.get("operation")),
        String.valueOf(row.get("idempotency_key")),
        String.valueOf(row.get("record_lid")),
        blankToNull(row.get("from_state")),
        blankToNull(row.get("to_state")),
        toLong(row.get("revision")));
  }

  @Override
  public void saveIdempotency(RuntimeExecutionContext context, RuntimeIdempotencyEntry entry) {
    requireTenant(context);
    executor.update(
        "insert into lc_rt_idempotency (tenant_id, workspace_id, app_code, object_code, operation, idempotency_key, record_lid, from_state, to_state, revision, trace_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        List.of(
            context.tenantId(),
            context.workspaceId(),
            context.appCode(),
            context.objectCode(),
            entry.operation(),
            entry.idempotencyKey(),
            entry.recordLid(),
            nullToBlank(entry.fromState()),
            nullToBlank(entry.toState()),
            entry.revision(),
            context.traceId()));
  }

  @Override
  public void appendAudit(RuntimeExecutionContext context, AuditLog auditLog) {
    requireTenant(context);
    executor.update(
        "insert into lc_rt_audit_log (tenant_id, app_code, object_code, operation, trace_id, meta_hash, perm_version) values (?, ?, ?, ?, ?, ?, ?)",
        List.of(
            context.tenantId(),
            context.appCode(),
            context.objectCode(),
            auditLog.operation(),
            auditLog.traceId(),
            auditLog.metaHash(),
            auditLog.permVersion()));
  }

  @Override
  public void appendOutbox(RuntimeExecutionContext context, OutboxEvent outboxEvent) {
    requireTenant(context);
    executor.update(
        "insert into lc_rt_outbox (tenant_id, app_code, object_code, event_type, record_lid, trace_id) values (?, ?, ?, ?, ?, ?)",
        List.of(
            context.tenantId(),
            context.appCode(),
            context.objectCode(),
            outboxEvent.eventType(),
            outboxEvent.recordLid(),
            outboxEvent.traceId()));
  }

  @Override
  public void appendTransition(RuntimeExecutionContext context, TransitionLog transitionLog) {
    requireTenant(context);
    executor.update(
        "insert into lc_rt_transition_log (tenant_id, app_code, object_code, record_lid, from_state, to_state, trace_id) values (?, ?, ?, ?, ?, ?, ?)",
        List.of(
            context.tenantId(),
            context.appCode(),
            context.objectCode(),
            transitionLog.recordLid(),
            transitionLog.fromState(),
            transitionLog.toState(),
            transitionLog.traceId()));
  }

  @Override
  public List<AuditLog> auditLogs() {
    return List.of();
  }

  @Override
  public List<TransitionLog> transitionLogs() {
    return List.of();
  }

  @Override
  public List<OutboxEvent> outboxEvents() {
    return List.of();
  }

  private void requireTenant(RuntimeExecutionContext context) {
    if (context.tenantId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "租户不能为空");
    }
  }

  private Long toLong(Object value) {
    if (value instanceof Number number) {
      return number.longValue();
    }
    return Long.valueOf(String.valueOf(value));
  }

  private String blankToNull(Object value) {
    if (value == null || String.valueOf(value).isBlank()) {
      return null;
    }
    return String.valueOf(value);
  }

  private String nullToBlank(String value) {
    return value == null ? "" : value;
  }
}
