package com.lowcode.runtime.data;

import java.util.List;

/**
 * 运行时副作用仓储。
 *
 * <p>幂等、审计、outbox 和流转日志都属于写路径的一部分，不能只存在 JVM 内存中。服务层通过该接口统一写入，后续可以用事务把业务记录和副作用提交绑定。
 */
public interface RuntimeSideEffectRepository {

  RuntimeIdempotencyEntry findIdempotency(RuntimeExecutionContext context, String operation, String idempotencyKey);

  void saveIdempotency(RuntimeExecutionContext context, RuntimeIdempotencyEntry entry);

  void appendAudit(RuntimeExecutionContext context, AuditLog auditLog);

  void appendOutbox(RuntimeExecutionContext context, OutboxEvent outboxEvent);

  void appendTransition(RuntimeExecutionContext context, TransitionLog transitionLog);

  List<AuditLog> auditLogs();

  List<TransitionLog> transitionLogs();

  List<OutboxEvent> outboxEvents();
}
