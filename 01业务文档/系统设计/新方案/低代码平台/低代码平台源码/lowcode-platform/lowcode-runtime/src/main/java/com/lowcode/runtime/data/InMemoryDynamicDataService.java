package com.lowcode.runtime.data;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

/**
 * M1 动态数据运行态内核。
 *
 * <p>当前实现是内存版，用于锁定动态 API 的业务语义：租户隔离、字段白名单、权限裁剪、幂等、状态机和审计事件。
 * 它不替代后续 JDBC/MyBatis 持久化实现。
 */
public class InMemoryDynamicDataService {

  private final DynamicObjectDefinition definition;
  private final DynamicRecordRepository recordRepository;
  private final RuntimeSideEffectRepository sideEffectRepository;

  public InMemoryDynamicDataService(DynamicObjectDefinition definition) {
    this(definition, new InMemoryDynamicRecordRepository(), new InMemoryRuntimeSideEffectRepository());
  }

  public InMemoryDynamicDataService(DynamicObjectDefinition definition, DynamicRecordRepository recordRepository) {
    this(definition, recordRepository, new InMemoryRuntimeSideEffectRepository());
  }

  public InMemoryDynamicDataService(
      DynamicObjectDefinition definition,
      DynamicRecordRepository recordRepository,
      RuntimeSideEffectRepository sideEffectRepository) {
    this.definition = definition;
    this.recordRepository = recordRepository;
    this.sideEffectRepository = sideEffectRepository;
  }

  public AddRecordResult add(RuntimeExecutionContext context, AccessView accessView, AddRecordCommand command) {
    requireTenant(context);
    requireMetaHash(context, command.requestMetaHash());
    requireOperation(accessView, Operation.CREATE);
    RuntimeIdempotencyEntry replay = sideEffectRepository.findIdempotency(context, "add", command.idempotencyKey());
    if (replay != null) {
      return new AddRecordResult(replay.recordLid(), replay.revision());
    }
    Map<String, Object> values = convertAndFilterForWrite(command.values(), accessView);
    String lid = "01" + UUID.randomUUID().toString().replace("-", "").substring(0, 24).toUpperCase();
    String state = definition.stateMachine() == null ? null : definition.stateMachine().initialState();
    DynamicRecord record = new DynamicRecord(lid, context.tenantId(), values, state, 1L, false);
    recordRepository.insert(definition, context, record);
    AddRecordResult result = new AddRecordResult(lid, 1L);
    sideEffectRepository.saveIdempotency(context, new RuntimeIdempotencyEntry("add", command.idempotencyKey(), lid, null, null, 1L));
    sideEffectRepository.appendAudit(context, new AuditLog("create", context.traceId(), context.metaHash(), accessView.permVersion()));
    sideEffectRepository.appendOutbox(context, new OutboxEvent("record.created", lid, context.traceId()));
    return result;
  }

  public List<Map<String, Object>> list(RuntimeExecutionContext context, AccessView accessView, ListRecordCommand command) {
    requireTenant(context);
    requireOperation(accessView, Operation.READ);
    command.filters().forEach(filter -> requireField(filter.field()));
    command.sorts().forEach(sort -> requireField(sort.field()));
    return recordRepository.list(definition, context, command.filters(), command.sorts(), command.pageNo(), command.pageSize()).stream()
        .map(record -> project(record, command.fields(), accessView))
        .toList();
  }

  public Map<String, Object> get(RuntimeExecutionContext context, AccessView accessView, String recordLid, Set<String> fields) {
    requireTenant(context);
    requireOperation(accessView, Operation.READ);
    DynamicRecord record = recordRepository.require(definition, context, recordLid);
    return project(record, fields, accessView);
  }

  public UpdateRecordResult update(RuntimeExecutionContext context, AccessView accessView, UpdateRecordCommand command) {
    requireTenant(context);
    requireMetaHash(context, command.requestMetaHash());
    requireOperation(accessView, Operation.UPDATE);
    RuntimeIdempotencyEntry replay = findReplay(context, "update", command.idempotencyKey());
    if (replay != null) {
      return new UpdateRecordResult(replay.recordLid(), replay.revision());
    }
    if (command.values().containsKey("state_code")) {
      throw new RuntimeDataException(RuntimeDataErrorCode.STATE_NOT_EDITABLE, "普通更新不能修改状态字段");
    }
    DynamicRecord record = recordRepository.require(definition, context, command.recordLid());
    if (!Objects.equals(record.revision(), command.revision())) {
      throw new RuntimeDataException(RuntimeDataErrorCode.REVISION_CONFLICT, "记录版本冲突");
    }
    record.values().putAll(convertAndFilterForWrite(command.values(), accessView));
    DynamicRecord updated = record.nextRevision();
    recordRepository.update(definition, context, updated);
    saveReplay(context, new RuntimeIdempotencyEntry("update", command.idempotencyKey(), updated.lid(), null, null, updated.revision()));
    sideEffectRepository.appendAudit(context, new AuditLog("update", context.traceId(), context.metaHash(), accessView.permVersion()));
    return new UpdateRecordResult(updated.lid(), updated.revision());
  }

  public DeleteRecordResult delete(RuntimeExecutionContext context, AccessView accessView, DeleteRecordCommand command) {
    requireTenant(context);
    requireMetaHash(context, command.requestMetaHash());
    requireOperation(accessView, Operation.DELETE);
    recordRepository.softDelete(definition, context, command.recordLid(), command.revision());
    sideEffectRepository.appendAudit(context, new AuditLog("delete", context.traceId(), context.metaHash(), accessView.permVersion()));
    sideEffectRepository.appendOutbox(context, new OutboxEvent("record.deleted", command.recordLid(), context.traceId()));
    return new DeleteRecordResult(command.recordLid(), true);
  }

  public TransitionResult transition(RuntimeExecutionContext context, AccessView accessView, TransitionCommand command) {
    requireTenant(context);
    requireMetaHash(context, command.requestMetaHash());
    requireOperation(accessView, Operation.TRANSITION);
    RuntimeIdempotencyEntry replay = sideEffectRepository.findIdempotency(context, "transition", command.idempotencyKey());
    if (replay != null) {
      return new TransitionResult(replay.recordLid(), replay.fromState(), replay.toState());
    }
    DynamicRecord record = recordRepository.require(definition, context, command.recordLid());
    StateMachineDefinition machine = definition.stateMachine();
    StateTransition transition = machine.transition(command.actionCode(), record.stateCode());
    if (!accessView.actionSet().contains(command.actionCode())) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无动作权限");
    }
    if (new BigDecimal(String.valueOf(record.values().getOrDefault("amount", "0"))).compareTo(new BigDecimal("10000")) > 0
        && String.valueOf(command.parameters().getOrDefault("approval_comment", "")).isBlank()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.RULE_VALIDATE_FAILED, "金额大于 10000 时审批意见必填");
    }
    record.values().putAll(command.parameters());
    DynamicRecord updated = new DynamicRecord(record.lid(), record.tenantId(), record.values(), transition.toState(), record.revision() + 1, false);
    recordRepository.update(definition, context, updated);
    TransitionResult result = new TransitionResult(record.lid(), transition.fromState(), transition.toState());
    sideEffectRepository.saveIdempotency(
        context,
        new RuntimeIdempotencyEntry("transition", command.idempotencyKey(), record.lid(), transition.fromState(), transition.toState(), updated.revision()));
    sideEffectRepository.appendTransition(context, new TransitionLog(record.lid(), transition.fromState(), transition.toState(), context.traceId()));
    sideEffectRepository.appendAudit(context, new AuditLog("transition", context.traceId(), context.metaHash(), accessView.permVersion()));
    sideEffectRepository.appendOutbox(context, new OutboxEvent("state.transitioned", record.lid(), context.traceId()));
    return result;
  }

  public List<AuditLog> auditLogs() {
    return sideEffectRepository.auditLogs();
  }

  public List<TransitionLog> transitionLogs() {
    return sideEffectRepository.transitionLogs();
  }

  public List<OutboxEvent> outboxEvents() {
    return sideEffectRepository.outboxEvents();
  }

  private Map<String, Object> convertAndFilterForWrite(Map<String, Object> values, AccessView accessView) {
    Map<String, Object> result = new HashMap<>();
    values.forEach((field, value) -> {
      requireField(field);
      if (accessView.fieldAccess(field) != FieldAccess.WRITE) {
        throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "字段无写权限");
      }
      result.put(field, definition.fields().get(field).convert(value));
    });
    return result;
  }

  private Map<String, Object> project(DynamicRecord record, Set<String> fields, AccessView accessView) {
    Map<String, Object> result = new LinkedHashMap<>();
    result.put("lid", record.lid());
    Set<String> requested = fields.isEmpty() ? definition.fields().keySet() : fields;
    for (String field : requested) {
      requireField(field);
      FieldAccess access = accessView.fieldAccess(field);
      if (access == FieldAccess.NONE) {
        continue;
      }
      result.put(field, access == FieldAccess.MASKED ? "***" : record.values().get(field));
    }
    return result;
  }

  private void requireTenant(RuntimeExecutionContext context) {
    if (context.tenantId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "租户不能为空");
    }
  }

  private void requireMetaHash(RuntimeExecutionContext context, String requestMetaHash) {
    if (!Objects.equals(context.metaHash(), requestMetaHash)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.META_VERSION_STALE, "元数据版本已过期");
    }
  }

  private void requireOperation(AccessView accessView, Operation operation) {
    if (!accessView.can(operation)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无操作权限");
    }
  }

  private void requireField(String field) {
    if (!definition.fields().containsKey(field)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "字段不在元数据白名单内");
    }
  }

  private RuntimeIdempotencyEntry findReplay(RuntimeExecutionContext context, String operation, String idempotencyKey) {
    return isBlank(idempotencyKey) ? null : sideEffectRepository.findIdempotency(context, operation, idempotencyKey);
  }

  private void saveReplay(RuntimeExecutionContext context, RuntimeIdempotencyEntry entry) {
    if (!isBlank(entry.idempotencyKey())) {
      sideEffectRepository.saveIdempotency(context, entry);
    }
  }

  private boolean isBlank(String value) {
    return value == null || value.isBlank();
  }

}

record AuditLog(String operation, String traceId, String metaHash, Long permVersion) {}

record OutboxEvent(String eventType, String recordLid, String traceId) {}

record TransitionLog(String recordLid, String fromState, String toState, String traceId) {}

record DynamicRecord(String lid, Long tenantId, Map<String, Object> values, String stateCode, Long revision, boolean deleted) {

  DynamicRecord {
    values = new HashMap<>(values);
  }

  DynamicRecord nextRevision() {
    return new DynamicRecord(lid, tenantId, values, stateCode, revision + 1, deleted);
  }
}

record FieldDefinition(String code, FieldKind kind) {

  Object convert(Object value) {
    if (value == null) {
      return null;
    }
    return switch (kind) {
      case INTEGER -> convertInteger(value);
      case DECIMAL, CURRENCY -> convertDecimal(value);
      case BOOLEAN -> convertBoolean(value);
      case JSON -> value;
      case TEXT, REFERENCE, TEMPORAL, AUTONUMBER -> String.valueOf(value);
    };
  }

  private Long convertInteger(Object value) {
    try {
      return value instanceof Number number ? number.longValue() : Long.valueOf(String.valueOf(value));
    } catch (NumberFormatException ex) {
      throw new RuntimeDataException(RuntimeDataErrorCode.FIELD_TYPE_INVALID, "整数字段格式错误");
    }
  }

  private BigDecimal convertDecimal(Object value) {
    try {
      return value instanceof BigDecimal decimal ? decimal : new BigDecimal(String.valueOf(value));
    } catch (NumberFormatException ex) {
      throw new RuntimeDataException(RuntimeDataErrorCode.FIELD_TYPE_INVALID, "数值字段格式错误");
    }
  }

  private Boolean convertBoolean(Object value) {
    if (value instanceof Boolean booleanValue) {
      return booleanValue;
    }
    throw new RuntimeDataException(RuntimeDataErrorCode.FIELD_TYPE_INVALID, "布尔字段格式错误");
  }
}

record StateTransition(String actionCode, String fromState, String toState, Set<String> allowedRoles) {}
