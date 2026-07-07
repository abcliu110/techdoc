package com.lowcode.app.api;

import com.lowcode.runtime.api.ImportCommitResult;
import com.lowcode.runtime.api.ImportPreview;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.api.RuntimeObjectMeta;
import com.lowcode.runtime.api.RuntimeRequestContext;
import com.lowcode.runtime.data.AddRecordCommand;
import com.lowcode.runtime.data.AddRecordResult;
import com.lowcode.runtime.data.DeleteRecordCommand;
import com.lowcode.runtime.data.DeleteRecordResult;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.FieldKind;
import com.lowcode.runtime.data.ListRecordCommand;
import com.lowcode.runtime.data.StateMachineDefinition;
import com.lowcode.runtime.data.TransitionCommand;
import com.lowcode.runtime.data.TransitionResult;
import com.lowcode.runtime.data.UpdateRecordCommand;
import com.lowcode.runtime.data.UpdateRecordResult;
import com.lowcode.runtime.permission.AccessExplain;
import com.lowcode.runtime.permission.Operation;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;
import org.springframework.lang.Nullable;

/**
 * HTTP facade backed by the runtime module API.
 */
@Component
@Primary
class RuntimeApiHttpFacade implements RuntimeHttpFacade {

  private final RuntimeApiFacade runtimeApiFacade;
  private final PublishedRuntimeObjectRegistry objectRegistry;

  RuntimeApiHttpFacade(RuntimeApiFacade runtimeApiFacade) {
    this(runtimeApiFacade, null, false);
  }

  RuntimeApiHttpFacade(RuntimeApiFacade runtimeApiFacade, PublishedRuntimeObjectRegistry objectRegistry) {
    this(runtimeApiFacade, objectRegistry, false);
  }

  @Autowired
  RuntimeApiHttpFacade(
      RuntimeApiFacade runtimeApiFacade,
      @Nullable PublishedRuntimeObjectRegistry objectRegistry,
      @Value("${lowcode.app.runtime.demo-enabled:false}") boolean runtimeDemoEnabled) {
    this.runtimeApiFacade = runtimeApiFacade;
    this.objectRegistry = objectRegistry;
    if (runtimeDemoEnabled && objectRegistry == null) {
      registerM1DemoObjects(runtimeApiFacade);
    }
  }

  @Override
  public AddRecordResponse add(AuthenticatedRuntimeContext context, AddRecordRequest request) {
    ensureRegistered(context);
    AddRecordResult result = runtimeApiFacade.add(
        runtimeContext(context),
        new AddRecordCommand(request.values(), request.requestMetaHash(), request.idempotencyKey()));
    return new AddRecordResponse(result.recordLid(), result.revision());
  }

  @Override
  public List<Map<String, Object>> list(AuthenticatedRuntimeContext context, ListRequest request) {
    ensureRegistered(context);
    return runtimeApiFacade.list(
        runtimeContext(context),
        new ListRecordCommand(request.fields(), List.of(), List.of(), request.pageNo(), request.pageSize()));
  }

  @Override
  public RuntimeObjectMetaResponse meta(AuthenticatedRuntimeContext context) {
    ensureRegistered(context);
    RuntimeObjectMeta meta = runtimeApiFacade.meta(runtimeContext(context));
    return new RuntimeObjectMetaResponse(meta.appCode(), meta.objectCode(), meta.metaHash(), meta.fields());
  }

  @Override
  public Map<String, Object> get(AuthenticatedRuntimeContext context, RecordReadRequest request) {
    ensureRegistered(context);
    return runtimeApiFacade.get(runtimeContext(context), request.recordLid(), request.fields());
  }

  @Override
  public UpdateRecordResponse update(AuthenticatedRuntimeContext context, UpdateRecordRequest request) {
    ensureRegistered(context);
    UpdateRecordResult result = runtimeApiFacade.update(
        runtimeContext(context),
        new UpdateRecordCommand(
            request.recordLid(),
            request.revision(),
            request.values(),
            request.requestMetaHash(),
            request.idempotencyKey()));
    return new UpdateRecordResponse(result.recordLid(), result.revision(), true);
  }

  @Override
  public DeleteRecordResponse delete(AuthenticatedRuntimeContext context, DeleteRecordRequest request) {
    ensureRegistered(context);
    DeleteRecordResult result = runtimeApiFacade.delete(
        runtimeContext(context),
        new DeleteRecordCommand(request.recordLid(), request.revision(), request.requestMetaHash()));
    return new DeleteRecordResponse(result.recordLid(), result.deleted());
  }

  @Override
  public TransitionResponse transition(AuthenticatedRuntimeContext context, TransitionRequest request) {
    ensureRegistered(context);
    TransitionResult result = runtimeApiFacade.transition(
        runtimeContext(context),
        new TransitionCommand(
            request.recordLid(),
            request.actionCode(),
            request.parameters(),
            request.requestMetaHash(),
            request.idempotencyKey()));
    return new TransitionResponse(result.recordLid(), result.fromState(), result.toState());
  }

  @Override
  public List<Map<String, Object>> suggest(AuthenticatedRuntimeContext context, SuggestRequest request) {
    ensureRegistered(context);
    return runtimeApiFacade.suggest(runtimeContext(context), request.keyword(), request.fields(), request.limit());
  }

  @Override
  public List<Map<String, Object>> export(AuthenticatedRuntimeContext context, ExportRequest request) {
    ensureRegistered(context);
    return runtimeApiFacade.export(runtimeContext(context), request.fields());
  }

  @Override
  public ImportPreviewResponse importPreview(AuthenticatedRuntimeContext context, ImportPreviewRequest request) {
    ensureRegistered(context);
    ImportPreview preview = runtimeApiFacade.importPreview(
        runtimeContext(context),
        request.rows() == null ? List.of() : request.rows());
    return new ImportPreviewResponse(preview.taskId(), preview.errors());
  }

  @Override
  public ImportCommitResponse importCommit(AuthenticatedRuntimeContext context, ImportCommitRequest request) {
    ensureRegistered(context);
    ImportCommitResult result = runtimeApiFacade.importCommit(
        runtimeContext(context),
        request.taskId(),
        request.idempotencyKey());
    return new ImportCommitResponse(result.taskId(), result.createdCount());
  }

  @Override
  public PermissionExplainResponse explain(AuthenticatedRuntimeContext context, PermissionExplainRequest request) {
    ensureRegistered(context);
    AccessExplain explain = runtimeApiFacade.explain(runtimeContext(context), operation(request.operation()));
    return new PermissionExplainResponse(explain.allowed(), explain.reasons());
  }

  private void ensureRegistered(AuthenticatedRuntimeContext context) {
    if (objectRegistry != null) {
      objectRegistry.ensureRegistered(context);
    }
  }

  private RuntimeRequestContext runtimeContext(AuthenticatedRuntimeContext context) {
    return new RuntimeRequestContext(
        context.tenantId(),
        context.workspaceId(),
        context.userLid(),
        context.roleCodes(),
        context.appCode(),
        context.objectCode(),
        context.metaHash(),
        context.traceId());
  }

  private Operation operation(String operation) {
    if (operation == null || operation.isBlank()) {
      return Operation.READ;
    }
    return Operation.valueOf(operation.trim().toUpperCase());
  }

  private void registerM1DemoObjects(RuntimeApiFacade facade) {
    facade.registerObject(DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .field("remark", FieldKind.TEXT)
        .field("secret_amount", FieldKind.CURRENCY)
        .field("approval_comment", FieldKind.TEXT)
        .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", Set.of("manager")))
        .build());
  }
}
