package com.lowcode.app.api;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 运行态 HTTP 门面。
 *
 * <p>当前放在 app 模块内，是为了让 `lowcode-app` 在独立测试选择集下也能完成 HTTP 契约验证。
 * 这里不承担持久化或框架安全职责，只维持最小运行态闭环和受控上下文约束。
 */
interface RuntimeHttpFacade {

  AddRecordResponse add(AuthenticatedRuntimeContext context, AddRecordRequest request);

  List<Map<String, Object>> list(AuthenticatedRuntimeContext context, ListRequest request);

  RuntimeObjectMetaResponse meta(AuthenticatedRuntimeContext context);

  Map<String, Object> get(AuthenticatedRuntimeContext context, RecordReadRequest request);

  UpdateRecordResponse update(AuthenticatedRuntimeContext context, UpdateRecordRequest request);

  DeleteRecordResponse delete(AuthenticatedRuntimeContext context, DeleteRecordRequest request);

  TransitionResponse transition(AuthenticatedRuntimeContext context, TransitionRequest request);

  List<Map<String, Object>> suggest(AuthenticatedRuntimeContext context, SuggestRequest request);

  List<Map<String, Object>> export(AuthenticatedRuntimeContext context, ExportRequest request);

  ImportPreviewResponse importPreview(AuthenticatedRuntimeContext context, ImportPreviewRequest request);

  ImportCommitResponse importCommit(AuthenticatedRuntimeContext context, ImportCommitRequest request);

  PermissionExplainResponse explain(AuthenticatedRuntimeContext context, PermissionExplainRequest request);

  default void requireAnyRole(AuthenticatedRuntimeContext context) {
    if (context.roleCodes() == null || context.roleCodes().isEmpty()) {
      throw new com.lowcode.common.error.BizException(
          com.lowcode.common.error.ErrorCode.PARAM_INVALID,
          "请求处理失败");
    }
  }
}

record AddRecordRequest(String requestMetaHash, String idempotencyKey, Map<String, Object> values) {}

record AddRecordResponse(String recordLid, long revision) {}

record UpdateRecordRequest(String recordLid, long revision, String requestMetaHash, String idempotencyKey, Map<String, Object> values) {}

record UpdateRecordResponse(String recordLid, long revision, boolean updated) {}

record DeleteRecordRequest(String recordLid, long revision, String requestMetaHash) {}

record DeleteRecordResponse(String recordLid, boolean deleted) {}

record TransitionRequest(String recordLid, String actionCode, Map<String, Object> parameters, String requestMetaHash, String idempotencyKey) {}

record TransitionResponse(String recordLid, String fromState, String toState) {}

record RuntimeObjectMetaResponse(String appCode, String objectCode, String metaHash, List<String> fields) {}

record ExportRequest(Set<String> fields) {}

record ImportPreviewRequest(List<Map<String, Object>> rows) {}

record ImportPreviewResponse(String taskId, List<String> errors) {}

record ImportCommitRequest(String taskId, String idempotencyKey) {}

record ImportCommitResponse(String taskId, int createdCount) {}

record PermissionExplainResponse(boolean allowed, List<String> reasons) {}

record RecordSnapshot(String lid, long revision, String state, Map<String, Object> values) {}

record RuntimeObjectDefinition(
    String objectCode,
    String tableName,
    List<String> fields,
    Set<String> hiddenFields,
    Set<String> transitionRoles,
    String initialState,
    String terminalState) {}
