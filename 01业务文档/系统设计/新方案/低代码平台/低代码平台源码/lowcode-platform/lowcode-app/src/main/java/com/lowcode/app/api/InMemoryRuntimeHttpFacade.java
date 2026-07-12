package com.lowcode.app.api;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * 运行态最小内存实现。
 *
 * <p>它只服务当前 HTTP 契约测试与本地闭环，不代表正式运行态存储方案。
 * 设计目标是让 app 模块在不依赖外部安全或数据库基础设施时，也能验证上下文解析、脱敏和基本行为。
 */
@Component
@ConditionalOnProperty(name = "lowcode.app.runtime.demo-enabled", havingValue = "true")
class InMemoryRuntimeHttpFacade implements RuntimeHttpFacade {

  private static final String IMPORT_OBJECT_KEY = "sales:order";

  private final Map<String, RuntimeObjectDefinition> definitions = new ConcurrentHashMap<>();
  private final Map<String, RecordSnapshot> records = new ConcurrentHashMap<>();
  private final Map<String, ImportPreviewState> importPreviews = new ConcurrentHashMap<>();
  private final Map<String, ImportCommitResponse> importCommitReplays = new ConcurrentHashMap<>();
  private final AtomicLong recordSequence = new AtomicLong(1);

  InMemoryRuntimeHttpFacade() {
    definitions.put(
        IMPORT_OBJECT_KEY,
        new RuntimeObjectDefinition(
            "order",
            "lc_rt_order",
            List.of("amount", "remark", "secret_amount", "approval_comment"),
            Set.of("secret_amount"),
            Set.of("manager"),
            "draft",
            "approved"));
  }

  @Override
  public AddRecordResponse add(AuthenticatedRuntimeContext context, AddRecordRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    Map<String, Object> values = new LinkedHashMap<>(request.values() == null ? Map.of() : request.values());
    String lid = "R" + recordSequence.getAndIncrement();
    records.put(recordKey(context, lid), new RecordSnapshot(lid, 1L, definition.initialState(), values));
    return new AddRecordResponse(lid, 1L);
  }

  @Override
  public List<Map<String, Object>> list(AuthenticatedRuntimeContext context, ListRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    return records.entrySet().stream()
        .filter(entry -> entry.getKey().startsWith(recordKeyPrefix(context)))
        .map(Map.Entry::getValue)
        .sorted(Comparator.comparing(RecordSnapshot::lid).reversed())
        .map(snapshot -> visibleValues(definition, snapshot, request.fields()))
        .toList();
  }

  @Override
  public RuntimeObjectMetaResponse meta(AuthenticatedRuntimeContext context) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    return new RuntimeObjectMetaResponse(context.appCode(), context.objectCode(), context.metaHash(), definition.fields());
  }

  @Override
  public Map<String, Object> get(AuthenticatedRuntimeContext context, RecordReadRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    RecordSnapshot snapshot = record(context, request.recordLid());
    return visibleValues(definition, snapshot, request.fields());
  }

  @Override
  public UpdateRecordResponse update(AuthenticatedRuntimeContext context, UpdateRecordRequest request) {
    requireAnyRole(context);
    RecordSnapshot snapshot = record(context, request.recordLid());
    ensureRevision(snapshot, request.revision(), "记录版本冲突");
    Map<String, Object> values = new LinkedHashMap<>(snapshot.values());
    if (request.values() != null) {
      values.putAll(request.values());
    }
    RecordSnapshot updated = new RecordSnapshot(snapshot.lid(), snapshot.revision() + 1, snapshot.state(), values);
    records.put(recordKey(context, snapshot.lid()), updated);
    return new UpdateRecordResponse(snapshot.lid(), updated.revision(), true);
  }

  @Override
  public DeleteRecordResponse delete(AuthenticatedRuntimeContext context, DeleteRecordRequest request) {
    requireAnyRole(context);
    RecordSnapshot snapshot = record(context, request.recordLid());
    ensureRevision(snapshot, request.revision(), "记录版本冲突");
    records.remove(recordKey(context, snapshot.lid()));
    return new DeleteRecordResponse(snapshot.lid(), true);
  }

  @Override
  public TransitionResponse transition(AuthenticatedRuntimeContext context, TransitionRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    RecordSnapshot snapshot = record(context, request.recordLid());
    if (!context.roleCodes().stream().anyMatch(definition.transitionRoles()::contains)) {
      throw new BizException(ErrorCode.PARAM_INVALID, "请求处理失败");
    }
    RecordSnapshot updated = new RecordSnapshot(snapshot.lid(), snapshot.revision() + 1, definition.terminalState(), mergeTransitionComment(snapshot.values(), request.parameters()));
    records.put(recordKey(context, snapshot.lid()), updated);
    return new TransitionResponse(snapshot.lid(), snapshot.state(), updated.state());
  }

  @Override
  public List<Map<String, Object>> suggest(AuthenticatedRuntimeContext context, SuggestRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    String keyword = request.keyword() == null ? "" : request.keyword();
    int limit = Math.max(1, Math.min(request.limit(), 20));
    return records.entrySet().stream()
        .filter(entry -> entry.getKey().startsWith(recordKeyPrefix(context)))
        .map(Map.Entry::getValue)
        .sorted(Comparator.comparing(RecordSnapshot::lid).reversed())
        .map(snapshot -> visibleValues(definition, snapshot, request.fields()))
        .filter(row -> row.values().stream().filter(Objects::nonNull).map(String::valueOf).anyMatch(value -> value.contains(keyword)))
        .limit(limit)
        .toList();
  }

  @Override
  public List<Map<String, Object>> export(AuthenticatedRuntimeContext context, ExportRequest request) {
    requireAnyRole(context);
    return list(context, new ListRequest(request.fields(), List.of(), List.of(), 1, 200));
  }

  @Override
  public ImportPreviewResponse importPreview(AuthenticatedRuntimeContext context, ImportPreviewRequest request) {
    requireAnyRole(context);
    RuntimeObjectDefinition definition = definition(context);
    List<String> errors = new ArrayList<>();
    List<Map<String, Object>> rows = request.rows() == null ? List.of() : request.rows();
    for (int index = 0; index < rows.size(); index++) {
      for (String field : rows.get(index).keySet()) {
        if (!definition.fields().contains(field)) {
          errors.add("第 " + (index + 1) + " 行字段 " + field + " 不存在");
        }
      }
    }
    String taskId = importTaskId(context);
    importPreviews.put(taskId, new ImportPreviewState(context.workspaceId(), rows, errors));
    return new ImportPreviewResponse(taskId, errors);
  }

  @Override
  public ImportCommitResponse importCommit(AuthenticatedRuntimeContext context, ImportCommitRequest request) {
    requireAnyRole(context);
    String replayKey =
        context.tenantId()
            + ":"
            + context.workspaceId()
            + ":"
            + request.taskId()
            + ":"
            + request.idempotencyKey();
    ImportCommitResponse replay = importCommitReplays.get(replayKey);
    if (replay != null) {
      return replay;
    }
    ImportPreviewState preview = importPreviews.get(request.taskId());
    if (preview == null
        || !Objects.equals(preview.workspaceId(), context.workspaceId())
        || !preview.errors().isEmpty()) {
      throw new BizException(ErrorCode.PARAM_INVALID, "请求处理失败");
    }
    int createdCount = 0;
    for (Map<String, Object> row : preview.rows()) {
      add(context, new AddRecordRequest(context.metaHash(), request.idempotencyKey() + "-" + createdCount, row));
      createdCount++;
    }
    ImportCommitResponse response = new ImportCommitResponse(request.taskId(), createdCount);
    importCommitReplays.put(replayKey, response);
    return response;
  }

  @Override
  public PermissionExplainResponse explain(AuthenticatedRuntimeContext context, PermissionExplainRequest request) {
    RuntimeObjectDefinition definition = definition(context);
    boolean allowed = !context.roleCodes().isEmpty();
    if ("TRANSITION".equalsIgnoreCase(request.operation()) || "ACTION".equalsIgnoreCase(request.operation())) {
      allowed = context.roleCodes().stream().anyMatch(definition.transitionRoles()::contains);
    }
    return new PermissionExplainResponse(
        allowed,
        List.of(allowed ? "运行态角色权限通过" : "运行态角色权限未通过"));
  }

  private RuntimeObjectDefinition definition(AuthenticatedRuntimeContext context) {
    RuntimeObjectDefinition definition = definitions.get(context.appCode() + ":" + context.objectCode());
    if (definition == null) {
      throw new BizException(ErrorCode.PARAM_INVALID, "请求处理失败");
    }
    return definition;
  }

  private RecordSnapshot record(AuthenticatedRuntimeContext context, String recordLid) {
    RecordSnapshot snapshot = records.get(recordKey(context, recordLid));
    if (snapshot == null) {
      throw new BizException(ErrorCode.PARAM_INVALID, "请求处理失败");
    }
    return snapshot;
  }

  private String recordKey(AuthenticatedRuntimeContext context, String recordLid) {
    return recordKeyPrefix(context) + recordLid;
  }

  private String recordKeyPrefix(AuthenticatedRuntimeContext context) {
    return context.tenantId()
        + ":"
        + context.workspaceId()
        + ":"
        + context.appCode()
        + ":"
        + context.objectCode()
        + ":";
  }

  private String importTaskId(AuthenticatedRuntimeContext context) {
    return context.traceId() + "-import";
  }

  private void ensureRevision(RecordSnapshot snapshot, long expectedRevision, String message) {
    if (snapshot.revision() != expectedRevision) {
      throw new BizException(ErrorCode.PARAM_INVALID, message);
    }
  }

  private Map<String, Object> visibleValues(RuntimeObjectDefinition definition, RecordSnapshot snapshot, Set<String> requestedFields) {
    Set<String> fields = requestedFields == null || requestedFields.isEmpty()
        ? new LinkedHashSet<>(definition.fields())
        : new LinkedHashSet<>(requestedFields);
    Map<String, Object> data = new LinkedHashMap<>();
    data.put("lid", snapshot.lid());
    data.put("revision", snapshot.revision());
    fields.stream()
        .filter(field -> !definition.hiddenFields().contains(field))
        .filter(snapshot.values()::containsKey)
        .forEach(field -> data.put(field, snapshot.values().get(field)));
    return data;
  }

  private Map<String, Object> mergeTransitionComment(Map<String, Object> currentValues, Map<String, Object> parameters) {
    Map<String, Object> merged = new LinkedHashMap<>(currentValues);
    if (parameters != null && parameters.containsKey("approval_comment")) {
      merged.put("approval_comment", parameters.get("approval_comment"));
    }
    return merged;
  }
}

record ImportPreviewState(Long workspaceId, List<Map<String, Object>> rows, List<String> errors) {}
