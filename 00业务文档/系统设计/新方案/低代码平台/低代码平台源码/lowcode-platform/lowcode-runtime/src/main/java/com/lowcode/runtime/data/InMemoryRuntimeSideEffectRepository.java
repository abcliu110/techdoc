package com.lowcode.runtime.data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 内存副作用仓储。
 *
 * <p>保留原有单元测试和本地演示行为；生产持久化路径应切到 JDBC 实现。
 */
class InMemoryRuntimeSideEffectRepository implements RuntimeSideEffectRepository {

  private final Map<String, RuntimeIdempotencyEntry> idempotencyEntries = new ConcurrentHashMap<>();
  private final List<AuditLog> auditLogs = new ArrayList<>();
  private final List<TransitionLog> transitionLogs = new ArrayList<>();
  private final List<OutboxEvent> outboxEvents = new ArrayList<>();

  @Override
  public RuntimeIdempotencyEntry findIdempotency(RuntimeExecutionContext context, String operation, String idempotencyKey) {
    return idempotencyEntries.get(key(context, operation, idempotencyKey));
  }

  @Override
  public void saveIdempotency(RuntimeExecutionContext context, RuntimeIdempotencyEntry entry) {
    idempotencyEntries.put(key(context, entry.operation(), entry.idempotencyKey()), entry);
  }

  @Override
  public void appendAudit(RuntimeExecutionContext context, AuditLog auditLog) {
    auditLogs.add(auditLog);
  }

  @Override
  public void appendOutbox(RuntimeExecutionContext context, OutboxEvent outboxEvent) {
    outboxEvents.add(outboxEvent);
  }

  @Override
  public void appendTransition(RuntimeExecutionContext context, TransitionLog transitionLog) {
    transitionLogs.add(transitionLog);
  }

  @Override
  public List<AuditLog> auditLogs() {
    return List.copyOf(auditLogs);
  }

  @Override
  public List<TransitionLog> transitionLogs() {
    return List.copyOf(transitionLogs);
  }

  @Override
  public List<OutboxEvent> outboxEvents() {
    return List.copyOf(outboxEvents);
  }

  private String key(RuntimeExecutionContext context, String operation, String idempotencyKey) {
    return context.tenantId()
        + ":"
        + context.workspaceId()
        + ":"
        + context.appCode()
        + ":"
        + context.objectCode()
        + ":"
        + operation
        + ":"
        + idempotencyKey;
  }
}
